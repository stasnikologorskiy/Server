﻿unit s_OnlineProcedures;

interface
uses Classes, System.Types, System.Contnrs, SysUtils, Math, Variants, DateUtils,
     DB, IBDatabase, IBSQL, IBQuery,
     n_free_functions, v_constants, v_Functions, v_DataTrans,
     n_LogThreads, n_DataCacheInMemory, n_constants, n_DataSetsManager, n_server_common,IniFiles,s_Utils;

function fnHeaderRedisign(var userInf:TUserInfo;Autenticated: Boolean=true) : string;
procedure prGeneralNewSystemProcOrder(Stream: TBoBMemoryStream; ThreadData: TThreadData);
function fnFooterRedisign(var userInf:TUserInfo): string;


const
  StandartErrorMessage        : string = 'Произошла ошибка выполнения. Если эта ошибка происходит регулярно, сообщите об этом по адресу '; //+cSupportEmail
  coReloginText               : string = 'Войдите в систему заново введя свои логин и пароль.'; //Ошибка входа.
  SessionTimeMin              : integer = 30;
  constPayInvoiceFilterHeader : integer = 165;
  GoogleAnalytics     : string='<script type="text/javascript" > '#13#10'  (function(i,s,o,g,r,a,m){i[''GoogleAnalyticsObject'']=r;i[r]=i[r]||function(){'#13#10+
                               '  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),'#13#10+
                               '  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)'#13#10+
                               '  })(window,document,''script'',''//www.google-analytics.com/analytics.js'',''ga'');'#13#10#13#10+
                               '  ga(''create'', ''UA-41098000-1'', ''vladislav.ua'');'#13#10'  ga(''send'', ''pageview'');'#13#10#13#10'</script>'#13#10;


type
 GetPageData=function (Stream: TBoBMemoryStream): string;




implementation
uses  t_ExcelXmlUse,s_CommandFunc,s_OnlineCommandFunc,n_CSSservice, n_CSSThreads, n_IBCntsPool, n_DataCacheObjects,n_WebArmProcedures,t_function,t_WebArmProcedures,n_OnlinePocedures;

//---------------------------------------------------------------
// страница списка контрактов
function fnGetNewContactsPage(var userInf:TUserInfo; Stream: TBoBMemoryStream): string;
var
  s, stemp,deprtShortName,deprtName,FirmName,SelfCommentary,temp,CurrencyContractName,CurrentContractNum,PayForm,Color,BKColor: string;
  i, Count, j, CurrentContractCode,ReprieveContract,ContractStatus,BlockCount,k,ContractDutyCurrency: integer;
  Blocked: Boolean;
  DebtContract,CreditContractSum,ContractRedSum,ContractVioletSum,ContractOrderSum,SumProfDebtAll,SumCreditContract,ProfDebtAll:Double;
begin
 Result:='';
 s:='<script>'#13#10;
 s:=s+'var flCredProfile='+BoolToStr(flCredProfile)+';'#13#10;
 s:=s+'var cTitleLegal="Юр. лицо";'#13#10;
 s:=s+'TStream.length=0;'#13#10;
 // ############################################################################
 if flCredProfile then begin
   BlockCount:=Stream.ReadInt;
   SumProfDebtAll:=0;
   SumCreditContract:=0;
   s:=s+'TStream.BlockCount='+IntToStr(BlockCount)+';'#13#10;
   s:=s+'TStream.ContractId='+IntToStr(userInf.ContractId)+';'#13#10;
   s:=s+'TStream.arrtable=new Array();'#13#10;
   for k := 0 to BlockCount-1 do begin
     Count:=Stream.ReadInt; //rowspan="2"
     s:=s+'TStream.arrtable['+IntToStr(k)+']={';
     s:=s+'Count: '+IntToStr(Count)+', ';
     s:=s+'RowData: new Array()};'#13#10;
     for i := 0 to Count-1 do begin
       s:=s+'TStream.arrtable['+IntToStr(k)+'].RowData['+IntToStr(i)+']={ ';
       CurrentContractCode:=Stream.ReadInt;
       s:=s+'CurrentContractCode:'+IntToStr(CurrentContractCode)+', ';
       CurrentContractNum:=Stream.ReadStr;
       s:=s+'CurrentContractNum:"'+CurrentContractNum+'", ';
       j:=Stream.ReadInt;
       PayForm:=fnPayFormByCode(j);
       s:=s+'PayForm:"'+PayForm+'", ';
       FirmName:=Stream.ReadStr;
       s:=s+'FirmName:"'+FirmName+'", ';
       ContractDutyCurrency:=Stream.ReadInt;
       s:=s+'ContractDutyCurrency:'+IntToStr(ContractDutyCurrency)+', ';
       deprtShortName:=Stream.ReadStr;
       deprtName:=Stream.ReadStr;
       s:=s+'deprtShortName:"'+deprtShortName+'", deprtName:"'+deprtName+'", ';
       CreditContractSum:=Stream.ReadDouble;
       s:=s+'CreditContractSum:"'+StringReplace(FormatFloat('# ##0.##', CreditContractSum),',','.',[rfReplaceAll])+'", ';
       CurrencyContractName:=Stream.ReadStr;
       s:=s+'CurrencyContractName:"'+CurrencyContractName+'", ';
       ReprieveContract:=Stream.ReadInt;
       s:=s+'ReprieveContract:'+IntToStr(ReprieveContract)+', ';
       ProfDebtAll:=Stream.ReadDouble;
       s:=s+'ProfDebtAll:"'+StringReplace(FormatFloat('# ##0.##', ProfDebtAll),',','.',[rfReplaceAll])+'", ';
       DebtContract:=Stream.ReadDouble;
       s:=s+'DebtContract:"'+fnIfStr(DebtContract=0,'',StringReplace(FormatFloat('# ##0.##', DebtContract),',','.',[rfReplaceAll]))+'", ';
       ContractOrderSum:=Stream.ReadDouble; // резерв
       s:=s+'ContractOrderSum:"'+StringReplace(FormatFloat('# ##0.##', ContractOrderSum),',','.',[rfReplaceAll])+'", ';
       ContractStatus:=Stream.ReadInt;
       s:=s+'ContractStatus:'+IntToStr(ContractStatus)+', ';
       if not (ContractStatus in [0,1,2]) then begin
          Result:='jqswMessageError("Не найден Статус:'+IntToStr(ContractStatus)+'");'#13#10;
          Exit;
        end;
       if deprtShortName<>'' then begin
          if i=0 then begin
            SumCreditContract:=SumCreditContract+CreditContractSum;
            SumProfDebtAll:=SumProfDebtAll+SumProfDebtAll;
          end;
        end;
        Blocked:=Stream.ReadBool;
        s:=s+'Blocked:'+BoolToStr(Blocked)+', ';
        stemp:=Stream.ReadStr;
        s:=s+'stemp:"'+stemp+'", ';
        ContractRedSum:=Stream.ReadDouble;
        s:=s+'ContractRedSum:"'+fnIfStr(ContractRedSum=0,'',StringReplace(FormatFloat('# ##0.##', ContractRedSum),',','.',[rfReplaceAll]))+'", ';
        ContractVioletSum:=Stream.ReadDouble;
        s:=s+'ContractVioletSum:"'+fnIfStr(ContractVioletSum=0,'',StringReplace(FormatFloat('# ##0.##', ContractVioletSum),',','.',[rfReplaceAll]))+'", ';
        SelfCommentary:=Stream.ReadStr;
        temp:=SelfCommentary;
        if (Length(SelfCommentary)>11) then  begin
          temp:=SelfCommentary;
          Delete(temp,8,Length(temp));
          temp:=temp+'...';
        end;
        s:=s+'temp:"'+temp+'",SelfCommentary:"'+SelfCommentary+'" ,';
        j:=getBackGrColor(stemp,ContractStatus,Blocked);
        Color:=arDelayWarningsColorRedisign[j];
        s:=s+'Color:"'+Color+'", ContStatusNames:"'+ContStatusNames[ContractStatus]+'"';
        s:=s+'};'#13#10;
     end;
   end;
   s:=s+'TStream.SumCreditContract="'+StringReplace(FormatFloat('# ##0.##', SumCreditContract),',','.',[rfReplaceAll])+'";'#13#10;
   s:=s+'TStream.SumProfDebtAll="'+StringReplace(FormatFloat('# ##0.##', SumProfDebtAll),',','.',[rfReplaceAll])+'";'#13#10;
  end
  else begin
    Count:=Stream.ReadInt; //rowspan="2"
    s:=s+' TStream.arlen='+IntToStr(Count)+'; '#13#10;
    s:=s+' TStream.arrtable= new Array(); '#13#10;
    for i := 0 to Count-1 do begin
      s:=s+' TStream.arrtable['+IntToStr(i)+']={';
      CurrentContractCode:=Stream.ReadInt;
      s:=s+'CurrentContractCode:'+IntToStr(CurrentContractCode)+', ';
      CurrentContractNum:=Stream.ReadStr;
      s:=s+'CurrentContractNum:"'+CurrentContractNum+'", ';
      j:=Stream.ReadInt;
      PayForm:=fnPayFormByCode(j);
      s:=s+'PayForm:"'+PayForm+'", ';
      FirmName:=Stream.ReadStr;
      s:=s+'FirmName:"'+FirmName+'", ';
      j:=Stream.ReadInt;
      ContractDutyCurrency:=Stream.ReadInt;
      s:=s+'ContractDutyCurrency:'+IntToStr(ContractDutyCurrency)+', ';
      deprtShortName:=Stream.ReadStr;
      deprtName:=Stream.ReadStr;
      s:=s+'deprtShortName:"'+deprtShortName+'", deprtName:"'+deprtName+'", ';
      CreditContractSum:=Stream.ReadDouble;
      s:=s+'CreditContractSum:"'+StringReplace(FormatFloat('# ##0.##', CreditContractSum),',','.',[rfReplaceAll])+'", ';
      CurrencyContractName:=Stream.ReadStr;
      s:=s+'CurrencyContractName:"'+CurrencyContractName+'", ';
      ReprieveContract:=Stream.ReadInt;
      s:=s+'ReprieveContract:'+IntToStr(ReprieveContract)+', ';
      DebtContract:=Stream.ReadDouble;
      s:=s+'DebtContract:"'+fnIfStr(DebtContract=0,'',StringReplace(FormatFloat('# ##0.##', DebtContract),',','.',[rfReplaceAll]))+'", ';
      ContractOrderSum:=Stream.ReadDouble; // резерв
      s:=s+'ContractOrderSum:"'+StringReplace(FormatFloat('# ##0.##', ContractOrderSum),',','.',[rfReplaceAll])+'", ';
      ContractStatus:=Stream.ReadInt;
      s:=s+'ContractStatus:'+IntToStr(ContractStatus)+', ';
      if not (ContractStatus in [0,1,2]) then begin
        Result:='jqswMessageError("Не найден Статус:'+IntToStr(ContractStatus)+'");'#13#10;
        Exit;
      end;
      Blocked:=Stream.ReadBool;
      s:=s+'Blocked:'+BoolToStr(Blocked)+', ';
      stemp:=Stream.ReadStr;
      s:=s+'stemp:"'+stemp+'", ';
      ContractRedSum:=Stream.ReadDouble;
      s:=s+'ContractRedSum:"'+fnIfStr(ContractRedSum=0,'',StringReplace(FormatFloat('# ##0.##', ContractRedSum),',','.',[rfReplaceAll]))+'", ';
      ContractVioletSum:=Stream.ReadDouble;
      s:=s+'ContractVioletSum:"'+fnIfStr(ContractVioletSum=0,'',StringReplace(FormatFloat('# ##0.##', ContractVioletSum),',','.',[rfReplaceAll]))+'", ';
      SelfCommentary:=Stream.ReadStr;
      temp:=SelfCommentary;
      if (Length(SelfCommentary)>11) then  begin
        temp:=SelfCommentary;
        Delete(temp,8,Length(temp));
        temp:=temp+'...';
      end;
      s:=s+'temp:"'+temp+'",SelfCommentary:"'+SelfCommentary+'" ,';
      j:=getBackGrColor(stemp,ContractStatus,Blocked);
      Color:=arDelayWarningsColorRedisign[j];
      s:=s+'Color:"'+Color+'", ContStatusNames:"'+ContStatusNames[ContractStatus]+'"';
      s:=s+'};'#13#10;
    end;
  end;
  s:=s+'New_getContractListPage();'#13#10;
  s:=s+'setActiveIcon("left li a.contacts");'#13#10;
  s:=s+'</script>'#13#10;
  Result:=s;
end;

// страница списка заказов
function fnGetNewOrdersPage(var userInf:TUserInfo; Stream: TBoBMemoryStream; SortOrder:string; SortDesc:string): string;
var
  OrdersCount,RowCount,i,CurContractID,ii:integer;
  CurOrderID,CurContractName,orderDate,orderNum,ComentSum,orderSum,orderCurrency,StatusName,OrderWeight,OrderStatus:String;
  DocType,Commentary,OrderType,DocNum,OrderStore,DocId,SelfCommentary,temp,SumDoc,CurrencyDoc,DateDoc,Commentary2:String;
  b:byte;
  IsWareListImport:boolean;
begin
 Result:='';
 Result:=Result+'<script>'#13#10;
 Result:=Result+'var arOrderStatusNames=new Array("Формируется", "Готов к отправке", "На обработке", "Принят", "Подтвержден", '+
    '"Отгружен", "Отправлен", "Закрыт", "Аннулирован", "Удален", "Не определен"); '#13#10;
      // константы - статусы заказа
 Result:=Result+'var orstForming         =  0;  // Формируется'#13#10;
 Result:=Result+'var orstReadyToSent     =  1;  // Готов к отправке'#13#10;
 Result:=Result+'var orstProcessing      =  2;  // На обработке '#13#10;
 Result:=Result+'var orstAccepted        =  3;  // Принят '#13#10;
 Result:=Result+'var orstConfirmed       =  4;  // Подтвержден '#13#10;
 Result:=Result+'var orstAssembled       =  5;  // Отгружен'#13#10;
 Result:=Result+'var orstSended          =  6;  // Отправлен  '#13#10;
 Result:=Result+'var orstClosed          =  7;  // Закрыт  '#13#10;
 Result:=Result+'var orstAnnulated       =  8;  // Аннулирован'#13#10;
 Result:=Result+'var orstDeleted         =  9;  // Удален '#13#10;
 Result:=Result+'var orstNoDefinition    = 10;  // Не определен '#13#10;
 Result:=Result+'var flGetExcelWareList='+BoolToStr(flGetExcelWareList)+';'#13#10;
 Result:=Result+'var flNewOrderMode='+BoolToStr(flNewOrderMode)+';'#13#10;
 Result:=Result+'TStream.length=0;'#13#10;
 Result:=Result+'TStream.ContractsCount='+IntToStr(userInf.ContractsCount)+';'#13#10;
 Result:=Result+'TStream.SortOrder="'+SortOrder+'";'#13#10;
 Result:=Result+'TStream.SortDesc="'+SortDesc+'";'#13#10;
 Result:=Result+'TStream.ContractID="'+IntToStr(userInf.ContractId)+'";'#13#10;
 Result:=Result+'TStream.ballsName="'+userInf.ballsName+'";'#13#10;
 Result:=Result+'setActiveIcon("left li a.orders");'#13#10;
 OrdersCount:=Stream.ReadInt;
 Result:=Result+'TStream.OrdersCount='+IntToStr(OrdersCount)+';'#13#10;
 Result:=Result+'TStream.arrtable=new Array();'#13#10;
 for i:=0 to OrdersCount-1 do begin
   Result:=Result+'TStream.arrtable['+IntToStr(i)+']={';
   RowCount:=Stream.ReadInt;
   CurOrderID:=IntToStr(Stream.ReadInt);
   CurContractID:=Stream.ReadInt;
   Result:=Result+'RowCount:'+IntToStr(RowCount)+', CurOrderID:"'+CurOrderID+'", CurContractID:'+IntToStr(CurContractID);
   CurContractName:=Stream.ReadStr;
   orderDate:=Stream.ReadStr;
   orderNum:=Stream.ReadStr;
   Result:=Result+', CurContractName:"'+CurContractName+'", orderDate:"'+orderDate+'", orderNum:"'+orderNum+'"';
   ComentSum:=Stream.ReadStr;
   orderSum:=Stream.ReadStr;
   orderCurrency:=Stream.ReadStr;
   Result:=Result+', ComentSum:"'+StringReplace(ComentSum,',','.',[rfReplaceAll])+'", orderSum:"'+StringReplace(orderSum,',','.',[rfReplaceAll])+'", orderCurrency:"'+orderCurrency+'"';
   StatusName:=Stream.ReadStr;
   OrderStatus:=Stream.ReadStr;
   OrderWeight:=Stream.ReadStr; //Вес заказа
   Result:=Result+', StatusName:"'+StatusName+'", OrderStatus:"'+OrderStatus+'", OrderStatusColor:"'+arOrderStatusDecorRedisign[fnInStrArray(StatusName, arOrderStatusNames, False)].WebStyle+'", OrderWeight:"'+OrderWeight+'"';
   Result:=Result+', RowData:new Array( ';
   for ii:=0 to RowCount-1 do begin
     b:=Stream.ReadByte;
     OrderType:=Stream.ReadStr;
     DocType:=Stream.ReadStr;
     Result:=Result+'new Array({b:'+IntToStr(b)+', OrderType:"'+OrderType+'", DocType:"'+DocType+'"';
     DocId:=Stream.ReadStr;
     OrderStore:=Stream.ReadStr;
     DocNum:=Stream.ReadStr;
     Result:=Result+', DocId:"'+DocId+'", OrderStore:"'+OrderStore+'", DocNum:"'+DocNum+'"';
     Commentary:=Stream.ReadStr;
     SumDoc:=Stream.ReadStr;
     CurrencyDoc:=Stream.ReadStr;
     DateDoc:=Stream.ReadStr;
     if (ii=RowCount-1) then
       Result:=Result+', Commentary:"'+Commentary+'", SumDoc:"'+StringReplace(SumDoc,',','.',[rfReplaceAll])+'", CurrencyDoc:"'+CurrencyDoc+'", DateDoc:"'+DateDoc+'"})'
     else
       Result:=Result+', Commentary:"'+Commentary+'", SumDoc:"'+StringReplace(SumDoc,',','.',[rfReplaceAll])+'", CurrencyDoc:"'+CurrencyDoc+'", DateDoc:"'+DateDoc+'"}),';
   end;
   Result:=Result+' )';
   SelfCommentary:=Stream.ReadStr;
   Result:=Result+', SelfCommentary:"'+SelfCommentary+'"';
   temp:=SelfCommentary;
   if (Length(SelfCommentary)>9) then  begin
     temp:=SelfCommentary;
     Delete(temp,8,Length(temp));
     temp:=temp+'...';
   end;

   Result:=Result+', temp:"'+temp+'"';
   Result:=Result+'};'#13#10;
 end;
 Commentary2:=Stream.ReadStr;
 Result:=Result+'TStream.Commentary2="'+Commentary2+'";'#13#10;
 if flGetExcelWareList then begin
   IsWareListImport:=Stream.ReadBool;
   Result:=Result+'TStream.IsWareListImport='+BoolToStr(IsWareListImport)+';'#13#10;
 end
 else
  Result:=Result+'TStream.IsWareListImport='+BoolToStr(false)+';'#13#10;
  Result:=Result+'New_getOrdersListPage();'#13#10;
  Result:=Result+'</script>'#13#10;
end;

// страница  заказа
function fnGetNewOrderPage(var userInf:TUserInfo; Stream: TBoBMemoryStream;OrderCode:String;ExcelFileName:string): string;
 var
   CurWareCode,ORDRNUM,AccountNum,ORDRDATE,ORDRSUM,CURRENCY,acctype,Delivery,STATUSNAME,WEIGHT,Creator,Sender_,flNotRemindComment: string;
   STATUS,StoragesCount,LineQty,i,j,CurLine,DocCount,DocCode:integer;
   warantDate,Zakaz:Double;
   Storages: TaSD;
   deliveryStr,warantNum,warantPerson,Commentary,SelfCommentary,AnnulInfo,AccMeetText,Analogue,Brand,WareName,CurValue,WareQv: string;
   WarePrice,WarePriceSum,ballCount,ballsSum,ComentSum,Commentary2:string;
begin
 Result:='';
 Result:=Result+'<script>'#13#10;
 Result:=Result+'var arOrderStatusNames=new Array("Формируется", "Готов к отправке", "На обработке", "Принят", "Подтвержден", '+
    '"Отгружен", "Отправлен", "Закрыт", "Аннулирован", "Удален", "Не определен"); '#13#10;
      // константы - статусы заказа
 Result:=Result+'var orstForming         =  0;  // Формируется'#13#10;
 Result:=Result+'var orstReadyToSent     =  1;  // Готов к отправке'#13#10;
 Result:=Result+'var orstProcessing      =  2;  // На обработке '#13#10;
 Result:=Result+'var orstAccepted        =  3;  // Принят '#13#10;
 Result:=Result+'var orstConfirmed       =  4;  // Подтвержден '#13#10;
 Result:=Result+'var orstAssembled       =  5;  // Отгружен'#13#10;
 Result:=Result+'var orstSended          =  6;  // Отправлен  '#13#10;
 Result:=Result+'var orstClosed          =  7;  // Закрыт  '#13#10;
 Result:=Result+'var orstAnnulated       =  8;  // Аннулирован'#13#10;
 Result:=Result+'var orstDeleted         =  9;  // Удален '#13#10;
 Result:=Result+'var orstNoDefinition    = 10;  // Не определен '#13#10;
 Result:=Result+'var flGetExcelWareList='+BoolToStr(flGetExcelWareList)+';'#13#10;
 Result:=Result+'var flNewOrderMode='+BoolToStr(flNewOrderMode)+';'#13#10;
 Result:=Result+'var flMeetPerson='+BoolToStr(flMeetPerson)+';'#13#10;
 Result:=Result+'TStream.length=0;'#13#10;
 Result:=Result+'TStream.ContractsCount='+IntToStr(userInf.ContractsCount)+';'#13#10;
 Result:=Result+'TStream.ContractName="'+userInf.ContractName+'";'#13#10;
 Result:=Result+'TStream.OrderCode="'+OrderCode+'";'#13#10;
 Result:=Result+'TStream.ContractID="'+IntToStr(userInf.ContractId)+'";'#13#10;
 Result:=Result+'TStream.ballsName="'+userInf.ballsName+'";'#13#10;
 Result:=Result+'TStream.flUber='+BoolToStr(userInf.flUber)+';'#13#10;
 Result:=Result+'TStream.IsUberClient='+BoolToStr(userInf.IsUberClient)+';'#13#10;
 Result:=Result+'TStream.ExcelFileName="'+ExcelFileName+'";'#13#10;
 Result:=Result+'TStream.IsBonus="'+fnIfStr((StrToBoolDef(fnGetFieldStrList(userInf.strPost,userInf.strGet,'bonus'),false)=false),'false','true')+'";'#13#10;
 ORDRNUM:=Stream.ReadStr;
 Result:=Result+'TStream.ORDRNUM="'+ORDRNUM+'";'#13#10;
 AccountNum:=Stream.ReadStr;
 Result:=Result+'TStream.AccountNum="'+AccountNum+'";'#13#10;
 ORDRDATE:=Stream.ReadStr;
 Result:=Result+'TStream.ORDRDATE="'+ORDRDATE+'";'#13#10;
 ORDRSUM:=Stream.ReadStr;
 //ORDRSUM:=StringReplace(ORDRSUM,',','.',[rfReplaceAll]);
 Result:=Result+'TStream.ORDRSUM="'+ORDRSUM+'";'#13#10;
 CURRENCY:=Stream.ReadStr;
 Result:=Result+'TStream.CURRENCY="'+CURRENCY+'";'#13#10;
 acctype:=IntToStr(Stream.ReadInt); // ACCOUNTINGTTYPE
 Result:=Result+'TStream.acctype="'+acctype+'";'#13#10;
 Delivery:=IntToStr(Stream.ReadInt);
 Result:=Result+'TStream.Delivery="'+Delivery+'";'#13#10;
 STATUS:=Stream.ReadInt;
 Result:=Result+'TStream.STATUS="'+IntToStr(STATUS)+'";'#13#10;
 STATUSNAME:='<span class=statusinh1 style=''color:'+arOrderStatusDecor[Status].WebStyle+'''>'+Stream.ReadStr+'</span>'+Stream.ReadStr;
 Result:=Result+'TStream.STATUSNAME="'+STATUSNAME+'";'#13#10;
 WEIGHT:=Stream.ReadStr;
 Result:=Result+'TStream.WEIGHT="'+WEIGHT+'";'#13#10;
 Creator:=Stream.ReadStr;
 Result:=Result+'TStream.Creator="'+Creator+'";'#13#10;
 Sender_:=Stream.ReadStr;
 Result:=Result+'TStream.Sender_="'+Sender_+'";'#13#10;
 flNotRemindComment:=Stream.ReadStr;// пропуск признака напоминания о незаполненнном комментарии
 Result:=Result+'TStream.flNotRemindComment="'+flNotRemindComment+'";'#13#10;
 deliveryStr:=Stream.ReadStr;
 Result:=Result+'TStream.flNotRemindComment="'+flNotRemindComment+'";'#13#10;
 warantNum:=Stream.ReadStr;
 Result:=Result+'TStream.warantNum="'+warantNum+'";'#13#10;
 warantDate:=Stream.ReadDouble;
 Result:=Result+'TStream.warantDate="'+fnIfStr(Date=0, '', FormatDateTime('dd.mm.yy', warantDate))+'";'#13#10;
 warantPerson:=Stream.ReadStr;
 Result:=Result+'TStream.warantPerson="'+warantPerson+'";'#13#10;
 Commentary:=Stream.ReadStr;
 SelfCommentary:=Stream.ReadStr;
 Result:=Result+'TStream.SelfCommentary="'+SelfCommentary+'";'#13#10;
 Commentary:=StringReplace(Commentary, '"', '\"', [rfReplaceAll]);
 Commentary:=StringReplace(Commentary, #13#10, '"+String.fromCharCode(10)+"', [rfReplaceAll]);
 Commentary:=StringReplace(Commentary, #13, '"+String.fromCharCode(10)+"', [rfReplaceAll]);
 Commentary:=StringReplace(Commentary, #10, '"+String.fromCharCode(10)+"', [rfReplaceAll]);
 Result:=Result+'TStream.Commentary="'+Commentary+'";'#13#10;
 AnnulInfo:=Stream.ReadStr;
 Result:=Result+'TStream.AnnulInfo="'+AnnulInfo+'";'#13#10;
 if flMeetPerson  then begin
   AccMeetText:=Stream.ReadStr;
   Result:=Result+'TStream.AccMeetText="'+AccMeetText+'";'#13#10;
 end
 else
   Result:=Result+'TStream.AccMeetText="";'#13#10;
 StoragesCount:=0;
 if (STATUS=orstForming) then begin
   Storages:=fnReceiveStorages(Stream);
   StoragesCount:=Length(Storages);
   Result:=Result+'TStream.StoragesCount='+IntToStr(StoragesCount)+';'#13#10;
 end
 else
   Result:=Result+'TStream.StoragesCount=0;'#13#10;
 Result:=Result+'TStream.Storages=new Array();'#13#10;
 for i:=0 to StoragesCount-1 do begin
   Result:=Result+'TStream.Storages['+IntToStr(i)+']={';
   if (Copy(Storages[i].FullName,1,1)='-') then begin
     Storages[i].FullName:=Copy(Storages[i].FullName,2,1000000);
     j:=pos(',', Storages[i].FullName);
     Storages[i].FullName:=Copy(Storages[i].FullName,1,j-1);
   end;
   Result:=Result+'Code:"'+Storages[i].Code+'", FullName:"'+Storages[i].FullName+'", ShortName:"'+Storages[i].ShortName+'", IsReserve: '+BoolToStr(Storages[i].IsReserve);
   //s:=s+'<th title="'+Storages[i].FullName+'">'+Storages[i].ShortName+'</th>';
   Result:=Result+'};'#13#10;
 end;
 Result:=Result+'TStream.arrtable=new Array();'#13#10;
 LineQty:=Stream.ReadInt;
 Result:=Result+'TStream.LineQty="'+IntToStr(LineQty)+'";'#13#10;
 Result:=Result+'TStream.arrtable=new Array();'#13#10;
 for i:=0 to LineQty-1 do begin
   Result:=Result+'TStream.arrtable['+IntToStr(i)+']={';
   CurLine:=Stream.ReadInt;
   CurWareCode:=Stream.ReadStr;
   Analogue:=Stream.ReadStr;           // код группы аналогов
   Result:=Result+'CurLine:'+IntToStr(CurLine)+', CurWareCode:"'+CurWareCode+'", Analogue:"'+Analogue+'"';
   Brand:=Stream.ReadStr;              // бренд
   WareName:=Stream.ReadStr;
   Zakaz:=Stream.ReadDouble;
   //Zakaz:=StringReplace(Zakaz, '#$#$#$#$', FloatToStr(Zakaz), [rfIgnoreCase]);
   Result:=Result+', Brand:"'+Brand+'", WareName:"'+WareName+'", Zakaz:"'+FloatToStr(Zakaz)+'"';
   Result:=Result+', StoragesData:new Array( ';
   for j:=0 to Length(Storages)-1 do begin
     if Storages[j].IsReserve then begin
       CurValue:=Stream.ReadStr;
       Result:=Result+'new Array({CurValue:"'+CurValue+'", Style:"'+fnIfStr(CurValue='0', '', ' border: 1px solid '+InputbackColor)+'"';
     if (j=Length(Storages)-1) then
      Result:=Result+', FromStorages:"'+fnIfStr(Storages[j].FullName='', '', ' со склада `'+trim(StringReplace(Storages[j].FullName, 'СКЛАД', '', [])))+'`"})'
     else
      Result:=Result+', FromStorages:"'+fnIfStr(Storages[j].FullName='', '', ' со склада `'+trim(StringReplace(Storages[j].FullName, 'СКЛАД', '', [])))+'`"}), ';
     end else begin;
       CurValue:=Stream.ReadStr;
       if (j=Length(Storages)-1) then
         Result:=Result+'new Array({CurValue:"'+CurValue+'"})'
       else
         Result:=Result+'new Array({CurValue:"'+CurValue+'"}),';
     end;
   end;
   Result:=Result+' )';
   WareQv:=Stream.ReadStr;
   WarePrice:=Stream.ReadStr;
   //WarePrice:=StringReplace(WarePrice,',','.',[rfReplaceAll]);
   WarePriceSum:=Stream.ReadStr;
   //WarePriceSum:=StringReplace(WarePriceSum,',','.',[rfReplaceAll]);
   Result:=Result+', WareQv:"'+WareQv+'", WarePrice:"'+WarePrice+'", WarePriceSum:"'+WarePriceSum+'"';
   Stream.ReadStr;// наценка
   ballCount:=Stream.ReadStr;
   Result:=Result+', ballCount:"'+ballCount+'"';
   Result:=Result+'};'#13#10;
 end;
 ballsSum:='';
 if userInf.flUber then begin
   if not userInf.IsUberClient then
     ballsSum:=Stream.ReadStr;
 end
 else
   ballsSum:=Stream.ReadStr;
 Result:=Result+'TStream.ballsSum="'+ballsSum+'";'#13#10;
 DocCount:=Stream.ReadInt;
 Result:=Result+'TStream.DocCount='+IntToStr(DocCount)+';'#13#10;
 Result:=Result+'TStream.Docs=new Array();'#13#10;
 if ((STATUS>=orstAccepted) and (STATUS<orstDeleted)) then begin
   if (STATUS=orstAnnulated) then begin
   end else
        if (STATUS>=orstAccepted) and (STATUS<=orstClosed) then begin
          if DocCount>0 then begin
            for i:=0 to DocCount-1 do begin
              Result:=Result+'TStream.Docs['+IntToStr(i)+']={';
              DocCode:=Stream.ReadInt;
              Commentary2:=Stream.ReadStr;
              Result:=Result+'DocCode:'+IntToStr(DocCode)+', Commentary:"'+Commentary+'";';
              Result:=Result+'};'#13#10;
            end;
          end;
        end;
 end; // if (STATUS>=orstAccepted) and (STATUS<orstDeleted) then begin
 ComentSum:=Stream.ReadStr;
 Result:=Result+'TStream.ComentSum="'+ComentSum+'";'#13#10;
 if (flGetExcelWareList) and (ExcelFileName<>'') then
   //if FileExists(BaseDir+'\zip_files\'+ExcelFileName) then begin
   Result:=Result+'TStream.ExcelFileNameSRC="'+userInf.DescrUrl+'/ifbj?act=getexcellocalfile&filename='+ExcelFileName+'";'#13#10
   //end;
 else
   Result:=Result+'TStream.ExcelFileNameSRC="";'#13#10;
 Result:=Result+'New_getOrderListPage();'#13#10;
 Result:=Result+'</script>'#13#10;
end;



//-------------------------------------------------------------
function fnContactInformationRedisign(var userInf:TUserInfo;Auth: boolean): string;
begin
  Result:='';
  Result:=Result+'<div id="telcontacts">';
  Result:=Result+'<table width=100% ><tr><td style="border-right: 1px solid #d4d9e3; width: 50%;">';
  Result:=Result+'<div style="margin-left: 25%; text-align: left; margin-bottom: 15px;font-weight: 600; color: #666666; line-height: 1.6;font-family: Open Sans; font-size: 117%;">';
  Result:=Result+'<div style="font-size: 11pt;"><strong>ЦЕНТР ОБСЛУЖИВАНИЯ КЛИЕНТОВ:</strong></div>';
  //Result:=Result+'<div style="font-size: 24pt;"><strong>0-800-30-15-15</strong></div>';
  //Result:=Result+'<div style="font-size: 24pt;"><strong>0-800-60-14-14</strong></div>';
  Result:=Result+'<div style="font-size: 24pt;"><strong>'+userInf.PhoneClientCentr+'</strong></div>';
  Result:=Result+'<div style="font-size: 8pt; font-weight: normal;">Звонки в пределах Украины бесплатны</div>';
  Result:=Result+'<div style="font-size: 11pt; margin-bottom: 15px; ';
  Result:=Result+'color: #2c80c9;">order@vladislav.ua</div>';
  Result:=Result+'<div style="margin-top: 10px;font-size: 11pt; line-height: 1.5;">ГРАФИК РАБОТЫ:</div>';
  Result:=Result+'<div style="font-weight: normal;font-size: 11pt;line-height: 1.5; ">';
  Result:=Result+'<span style="font-weight: normal;font-size: 11pt; ">Понедельник - Суббота: круглосуточно</span><br>';
  Result:=Result+'<span style="font-weight: normal;font-size: 11pt; ">Воскресенье: с 10:00</span><br></div>';
  Result:=Result+'</div></td>';
  Result:=Result+'</td>';
  Result:=Result+'<td ><div style="margin-left: 20%; text-align: left;margin-bottom: 15px;font-weight: 600;color: #666666; line-height: 1.6;font-family: Open Sans; font-size: 117%;">';
  Result:=Result+'<div style="font-size: 11pt;">СЛУЖБА ПОДДЕРЖКИ / <span class="hot-motul-line">ГОРЯЧАЯ ЛИНИЯ <img class="" src="/images/motul-55x15.jpg" alt="motul-55x15" height="15" width="55"></span></div>';
  //Result:=Result+'<div style="font-size: 24pt;">0-800-30-20-02</div>';
  Result:=Result+'<div style="font-size: 24pt;">'+userInf.PhoneSupport+'</div>';
  Result:=Result+'<div style="font-size: 8pt; font-weight: normal;">Звонки в пределах Украины бесплатны</div>';
  Result:=Result+'<div style="font-size: 11pt; font-weight: 600; margin-bottom: 15px; ';
  Result:=Result+'color: #2c80c9;">customerservice@vladislav.ua</div>';
  Result:=Result+'<div style="margin-top: 10px;font-size: 11pt; line-height: 1.5;"><strong>ГРАФИК РАБОТЫ:</strong></div>';
  Result:=Result+'<div style="font-weight: normal;font-size: 11pt;line-height: 1.5; ">';
  Result:=Result+'<span style="font-weight: normal;font-size: 11pt; ">Понедельник - Суббота: круглосуточно</span><br>';
  Result:=Result+'<span style="font-weight: normal;font-size: 11pt;">Воскресенье: с 10:00</span><br></div>';
  Result:=Result+'</div></td>';
  Result:=Result+'</tr></table>';
  Result:=Result+'</div>';
end;

// Общее, пригодное для всех страниц окончание
function fnFooterRedisign(var userInf:TUserInfo):string;
 var
   btn_class:string;
begin
  Result:='';
  Result:=Result+'<!-- footer -->'#13#10;
  Result:=Result+'<footer class="main-footer">'#13#10;
  Result:=Result+'  <div class="row">'#13#10;
  Result:=Result+'    <div class="col-xs-3">'#13#10;
    Result:=Result+'       <div class="shipment-wrap">'#13#10;
    Result:=Result+'          <a '+ fnIfStr(userInf.PageName='contracts', '', 'href="'+userInf.ScriptName+'/contracts" ');
    if (userInf.SaleBlock) then begin
      btn_class:='danger';
    end
    else begin
      if (userInf.WarningMessage<>'') then
        btn_class:='warning'
      else
        btn_class:='success';
    end;
    Result:=Result+'class="shipment btn btn-'+btn_class+'"'+
    ' style='' color:#fff; font-weight: bold';
//    Result:=Result+ fnIfStr(SaleBlock, arDelayWarningsColor[2], fnIfStr(WarningMessage='', arDelayWarningsColor[0], arDelayWarningsColor[1]))+';'' title="'+WarningMessage+'">Отгрузка ' ;
    Result:=Result+' ;'' title="'+userInf.WarningMessage+'">Отгрузка ' ;
    Result:=Result+ fnIfStr(userInf.SaleBlock, 'запрещена', 'разрешена')+'</a>'#13#10 ;
    if userInf.flUber then begin
      if not userInf.IsUberClient then
        Result:=Result+'          <p class="exchange-rates">1 y.e ='+StringReplace(FormatFloat('# ##0.00', userInf.Curs), ' ', '&nbsp;', [rfReplaceAll])+' грн.</p>'#13#10;
    end
    else
      Result:=Result+'          <p class="exchange-rates">1 y.e ='+StringReplace(FormatFloat('# ##0.00', userInf.Curs), ' ', '&nbsp;', [rfReplaceAll])+' грн.</p>'#13#10;
end;


function fnAutenticationFormShortRedisign2(var userInf:TUserInfo; text: string ='') : string;
begin
  if (text<>'') then begin
    Result:=Result+'<span class="info-message">'+text+'</span>';
  end;

  Result:=Result+'<form method=post action="'+userInf.DescrUrl+'/nabj" onSubmit="return sfba(this, ''nabj'');" >';
  Result:=Result+'<input type=hidden name=act value=backjob'+fnIfStr(text='', 'main', '')+'autentication>';

  Result:=Result+'<span style="white-space: nowrap;"><span style="margin-right: 12px;">Логин</span><input type=text class="login-input" name=psw maxlength=20></span><br>';
  Result:=Result+'<span style="white-space: nowrap;"><span>Пароль</span><input type=password class="login-input" name=lgn maxlength=20></span><br>';
  Result:=Result+'<span style="white-space: nowrap; text-align: center;"><input type=submit class="login btn btn-enter"  value="Вход" ></span><br>';
  Result:=Result+'</form>';
end;

//==============================================================================
function fnExistFileIcon(var userInf:TUserInfo;icon: string): string;
var FileName: string;
    SR: TSearchRec;
    FindRes: integer;
begin
result:=icon;
          FileName:= userInf.DescrDir+'\images\manufacturers\'+copy(icon, 1, pos('.',icon)-1)+'truck*'+'.png';
//prTestLog('start FileName='+FileName);
          FindRes:=FindFirst(FileName,faAnyFile,SR);
          if FindRes<>0 then begin
            FileName:= userInf.BaseUrl+copy(icon, 1, pos('.',icon))+'comm*'+'.png';
            FindRes:=FindFirst(FileName,faAnyFile,SR);
          end;
          if FindRes=0 then begin
            result:= ExtractFileName(SR.Name);
//prTestLog('FileName='+result);
          end;
end;
//==============================================================================

//==============================================================================
function fnListCatalogsAvto(var userInf:TUserInfo; avto: string):string;
var SLLaximoCat: TStringList;
    FName, Res, s: string;
    cat, brand, code, icon, name, version, vinexample, frameexample: string;
    i, count, ir, left, top: integer;
    Lrows: tas;
    j: integer;
    quickgroups,  wizardsearch2, operation: string;
    flOp: boolean;
    countR: integer;
begin
//prTestLog('fnListCatalogsAvto');
  result:= '';
  if avto = 'pc' then countR:= 7
  else countR:= 5;
//prTestLog('Request='+Request.Content);
//prTestLog('avto='+avto);
  flOp:= false;
  SLLaximoCat:= nil;
  SLLaximoCat:= TStringList.Create;

  if userInf.flCV then
    FName:= IniFile.ReadString('Laximo', 'FileCatLaximo', '')+'_'+avto+'.csv'
  else FName:= IniFile.ReadString('Laximo', 'FileCatLaximo', '');
    if pos('.csv',FName)=0 then Fname:= Fname+'.csv';

//prTestLog('FName='+FName);
//FName:='e:\host\worder\app\PlaximoCatNew.csv';
  if FileExists(FName) then begin
    SLLaximoCat.LoadFromFile(FName);
    Res:='';
    ir:= 0;
    icon:='';
    cat:='';
  if userInf.flRedesign then begin
    res:=res+'<nav class="header-link">'#13#10;
    res:=res+'<span class="ware-info-text" >Поиск по VIN-коду (17 символов): </span>'#13#10;
    res:=res+'  <form onsubmit="return vs(this);" class="vin-search search-form" >'#13#10;     //
    res:=res+'    <div class="vin-search" placeholder="Поиск по VIN" title=""> '#13#10;
    res:=res+'      <input type=submit style="display: none;">'#13#10;
    res:=res+'      <select id="vin-search-catalog-select'+fnIfStr(avto='pc','-pc','-cv')+'" _id="vin-search-catalog-input'+fnIfStr(avto='pc','','')+'" class="input-field"> '#13#10;
    res:=res+'      </select> '#13#10;
    res:=res+'    </div>'#13#10;
    res:=res+'  </form>'#13#10;
    res:=res+'</nav>'#13#10;


    res:= res+'<hr><span class="ware-info-name-span">Оригинальные каталоги</span>';
  end
  else begin
    res:=res+'<form onsubmit="return vs(this);">Поиск по VIN-коду (17 символов): '     //
            +'<input type=text maxlength=17 id=vin'+fnIfStr(avto='pc','-pc','-cv')+' size=20><input type=submit value="Искать" style="display: none;">';
    res:=res+'<a class="abgslide" style="position: relative; left: -1px; top: 6px; display: inline-block; width: 19px; height: 22px; background-image: url('''+fnIfStr(userInf.FirmID=IntToStr(isWe), userInf.DescrImageUrl, '')+'/images/combobox.png'');" '
                      +' title="Последние поисковые запросы по VIN" onclick=''var auto=$("#vin'+fnIfStr(avto='pc','-pc','-cv')+'"); if (auto.attr("opened")=="true") {auto.autocomplete("close")} else {auto.autocomplete("search" , "");} auto[0].focus();''></a>';
    res:=res+'<a class="abgslide" style="position: relative; left: 3px; top: 6px; display: inline-block; width: 23px; height: 22px; background-image: url('''+fnIfStr(userInf.FirmID=IntToStr(isWe), userInf.DescrImageUrl, '')+'/images/lupa.png'');" '
            +'href="#" title="Поиск по VIN" onclick="$(''#origprogs'+fnIfStr(avto='pc','','-cv')+' .currentdiv form'').submit();"></a></form>';//'if($(\''#podbortabs\'').attr(\''avto\'')==\''cv\'') {$(\''#origprogscv .currentdiv form\'').submit();} else {$(\''#origprogs .currentdiv form\'').submit();}

    Res:= Res+'<hr>Оригинальные каталоги';
  end;
    left:= 0;
    top:= 1;
    count:= SLLaximoCat.Count;
    top:= (count div countR)*84+fnIfInt(count mod countR>0,1,0)*84 ;
    Res:= Res+'<div style = "width: 588px; height: '+IntToStr(top)+'px; position: relative;">';
    top:= 1;
    for i := 0 to count-1 do begin
      s:= SLLaximoCat[i];
//prTestLog('s:='+s);
//prErrorLog('s:='+s);
      if ir=0 then begin
        left:=0;
      end;
      if s<>'' then
        Lrows:= fnSplitString(s)
      else break;;

      if Lrows[0]='True' then begin
        brand:= Lrows[1];
        code:= Lrows[2];
        icon:= Lrows[3];
        icon:= StringReplace(icon,' ','%20',[rfReplaceAll]);
        name:= Lrows[4];
        version:= Lrows[5];
        if avto = 'cv' then icon:= fnExistFileIcon(userInf,icon);
        for j:= 6 to length(Lrows)-1 do begin
//prTestLog('Lrows'+IntToStr(j)+':='+Lrows[j]);
          if pos('framesearch',Lrows[j])>0  then frameexample:= copy(Lrows[j],pos('=',Lrows[j])+1,length(Lrows[j]));
          if pos('vinsearch',Lrows[j])>0  then vinexample:= copy(Lrows[j],pos('=',Lrows[j])+1,length(Lrows[j]));
          if pos('wizardsearch2',Lrows[j])>0  then wizardsearch2:= copy(Lrows[j],pos('=',Lrows[j])+1,length(Lrows[j]));
          if pos('quickgroups',Lrows[j])>0  then quickgroups:= copy(Lrows[j],pos('=',Lrows[j])+1,length(Lrows[j]));
          if (pos('operation',Lrows[j])>0) then begin
            flOp:= true;
            if operation<>'' then operation:= operation+')(';
            operation:= operation+'('+copy(Lrows[j],pos('=',Lrows[j])+1,length(Lrows[j]));
          end;
          if (pos('field',Lrows[j])>0) and (operation<>'') then operation:= operation+';'+copy(Lrows[j],pos('=',Lrows[j])+1,length(Lrows[j]));
        end;
        if flOp and (copy(operation,length(operation)-1,length(operation))<>')') then operation:= operation+')';
        Res:=Res+'<a row="'+IntToStr((top-1) div 82)+'" code="'+code+'" title="'+name+' ( '+version+' )" class="abgslide" style="width: 82px; height: 82px; left: '+IntToStr(left)+'px; top: '+IntToStr(top)+'px; background-image: url('''+userInf.DescrImageUrl+'/images/manufacturers/'+icon+''');" '
                +'href="#" onclick=''ec("opencatalog", "icon='+icon+'&brand='+brand+'&code='+code+'&vinexample='+vinexample{+'&catvin='+catvin}+'&frameexample='+frameexample{+'&catframe='+catframe}+'&wizardsearch2='+wizardsearch2+'&quickgroups='+quickgroups+'&operation='+operation+'&avto='+avto+'", "abj");'' ></a>';
        frameexample:='';
        vinexample:='';
        wizardsearch2:='';
        quickgroups:='';
        operation:='';
        left:= left+ 84;
        inc(ir);
        if ir=countR then begin
           //Res:= Res+'</tr>';
          top:= top+82;
          ir:=0;
        end;
      end;
    end;
    Res:= Res+'</div>';
  end;
result:= Res;
//prTestLog(result);
end;
//==============================================================================


function fngetPodborWindow(var userInf:TUserInfo;isNew: boolean) : string;
 var
  i:integer;
begin
    Result:=Result+' <section id="popup-search-tree" class="popup-search-tree popup-box hide">'#13#10;
    Result:=Result+'   <div class="search-tree-container" id="search-tree-container">'#13#10;
    Result:=Result+'     <div class="search-tree-header">'#13#10;
    Result:=Result+'       <h3 class="title">Подбор</h3>'#13#10;
    Result:=Result+'       <div class="maximize" onclick="maximizedialog(this);" style="border: 3px solid rgb(238, 238, 238);"></div>'#13#10;
    Result:=Result+'       <button type="button" class="close"><span aria-hidden="true" >&times;</span></button>'#13#10;
    Result:=Result+'     </div>'#13#10;
    Result:=Result+'     <div class="search-tree-body" id="search-tree-body" >'#13#10;
    Result:=Result+'       <div id="search-tree-tabs" avto="pc" class="search-tree-tabs">'#13#10;
    Result:=Result+'         <ul class="search-tree-tabs-header">'#13#10;
    Result:=Result+'           <li><a href="#tabs-1" title="Подбор по оригинальным программам">Оригинальные каталоги</a></li>'#13#10;
    Result:=Result+'           <li><a onclick="fillPodborWindow(''auto'');" href="#tabs-2" title="Подбор по модели автомобиля">Авто</a></li>'#13#10;
    Result:=Result+'           <li><a onclick="fillPodborWindow(''engine'');" href="#tabs-3" title="Подбор по двигателю автомобиля">Двигатель</a></li>'#13#10;
    Result:=Result+'     <li><a onclick="fillPodborWindow(''cv'');" href="#tabs-6" title="Подбор по моделям грузовых автомобилей">Грузовики</a></li>'#13#10;
    Result:=Result+'     <li><a onclick="fillPodborWindow(''ax'');" href="#tabs-7" title="Подбор по моделям осей">Оси</a></li>'#13#10;
    Result:=Result+'           <li><a onclick="fillPodborWindow(''moto'');" href="#tabs-4" title="Подбор по модели мотоцикла">Мото</a></li>'#13#10;
    Result:=Result+'           <li><a onclick="ec(''getattributegrouplist'', ''tablename=motoattrlisttable&sys=2'', ''abj'');" href="#tabs-5" title="Подбор по параметрам" class="'+fnIfStr(isNew,'sup-new','')+'">По параметрам</a></li> '#13#10;
    Result:=Result+'         </ul>'#13#10;
//vv ---------------
//    Result:=Result+'         <div id="tabs-1" >'#13#10;
    Result:=Result+'         <div id="tabs-1" data-mcs-theme="inset-dark">'#13#10;
    Result:=Result+'<ul>'
    +'<li><a href="#origprogs" onclick="$(''#search-tree-tabs'').attr(''avto'',''pc''); " title="Подбор по оригинальным программам">Легковые авто</a></li>'#13#10;
    if userInf.flCV then
      Result:=Result+'<li><a href="#origprogs-cv" onclick="$(''#search-tree-tabs'').attr(''avto'',''cv''); " title="Подбор по оригинальным программам">Грузовые авто</a></li>'#13#10;
    Result:=Result+'</ul>'#13#10;

//    Result:=Result+{<div id="accordion" >}'<h1 ><a class="ware-info-name-span" tabnum="0" href="#" onclick="$(''#search-tree-tabs'').attr(''avto'',''pc'');console.log($(''#search-tree-tabs'').attr(''avto''));">Легковые авто</a></h1>'#13#10;
    Result:=Result+'           <div id="origprogs" data-mcs-theme="inset-dark" style="position: relative;">'#13#10;
    Result:=Result+'             <div id="origprogsheader" class="selectpartsdivheader">'#13#10;
    Result:=Result+'               <nav class="header-link">'#13#10;
    Result:=Result+'                 <a title="Назад" onclick='''' href="#" class="back-btn"></a>'#13#10;
    Result:=Result+'                 <span id="origheaderlogo" class="prod-logo"></span>'#13#10;
    Result:=Result+'                 <a href="#" onclick="ec(''laximostartpage'', ''avto=pc'', ''abj'');" class="start-btn">Начало</a>'#13#10;
    Result:=Result+'               </nav>'#13#10;
    Result:=Result+'             </div>'#13#10;
    for i:=0 to 9 do begin
//      Result:=Result+'           <div class="selectpartsdiv'+fnIfStr(i=0,' currentdiv" ','" headerdiv="origprogsheader"')+' number="'+IntToStr(i)+'"></div>';

      Result:=Result+'<div class="selectpartsdiv'+fnIfStr(i=0,' currentdiv" ','" headerdiv="origprogsheader"')+' number="'+IntToStr(i)+'">';
      if i=0 then
        Result:=Result+fnListCatalogsAvto(userInf,'pc');
      Result:=Result+'</div>';
    end;
    prOnReadyScriptAdd('searchautocompleteinit("#vin-search-catalog-input-pc");'#13#10);                 // vc_new
    prOnReadyScriptAdd('savesearchhistory("#vin-search-catalog-input", "", "vinsearchhistory", 10);'#13#10); // vc_new
    prOnReadyScriptAdd('$(''#vin-search-catalog-select-pc'').searchVinBox();'#13#10);
    prOnReadyScriptAdd('$("select.login-input-oe").selectmenu({'#13#10);
    prOnReadyScriptAdd('  change: function( event, ui ) {'#13#10);
    prOnReadyScriptAdd(' $("#origprogs .selectpartsdiv .header-link form").submit(); }'#13#10);
    prOnReadyScriptAdd('});'#13#10);
    Result:=Result+'           </div>'#13#10;

    if userInf.flCV then begin
//    Result:=Result+'<h1><a href="#" class="ware-info-name-span" tabnum="1" onclick="$(''#search-tree-tabs'').attr(''avto'',''cv'');console.log($(''#search-tree-tabs'').attr(''avto''));">Грузовые авто</a></h1>'#13#10;
    Result:=Result+'           <div id="origprogs-cv" data-mcs-theme="inset-dark" style="position: relative;">'#13#10;
    Result:=Result+'             <div id="origprogsheader-cv" class="selectpartsdivheader">'#13#10;
    Result:=Result+'               <nav class="header-link">'#13#10;
    Result:=Result+'                 <a title="Назад" onclick='''' href="#" class="back-btn"></a>'#13#10;
    Result:=Result+'                 <span id="origheaderlogo-cv" class="prod-logo"></span>'#13#10;
    Result:=Result+'                 <a href="#" onclick="ec(''laximostartpage'', ''avto=cv'', ''abj'');" class="start-btn">Начало</a>'#13#10;
    Result:=Result+'               </nav>'#13#10;
    Result:=Result+'             </div>'#13#10;
    for i:=0 to 9 do begin
//      Result:=Result+'           <div class="selectpartsdiv'+fnIfStr(i=0,' currentdiv" ','" headerdiv="origprogsheader-cv"')+' number="'+IntToStr(i)+'"></div>';
      Result:=Result+'<div class="selectpartsdiv'+fnIfStr(i=0,' currentdiv" ','" headerdiv="origprogsheader-cv"')+' number="'+IntToStr(i)+'">';
      if i=0 then
        Result:=Result+fnListCatalogsAvto(userInf,'cv');
      Result:=Result+'</div>';
    end;
    prOnReadyScriptAdd('savesearchhistory("#vin-search-catalog-input", "", "vinsearchhistory", 10);'#13#10); // vc_new
    prOnReadyScriptAdd('searchautocompleteinit("#vin-search-catalog-input-cv");'#13#10);                 // vc_new
    prOnReadyScriptAdd('savesearchhistory("#vin-search-catalog-input-cv", "", "vinsearchhistory", 10);'#13#10); // vc_new
    prOnReadyScriptAdd('$(''#vin-search-catalog-select-cv'').searchVinBox();'#13#10);
    prOnReadyScriptAdd('$("select.login-input-oe").selectmenu({'#13#10);
    prOnReadyScriptAdd('  change: function( event, ui ) {'#13#10);
    prOnReadyScriptAdd(' $("#origprogs .selectpartsdiv .header-link form").submit(); }'#13#10);
    prOnReadyScriptAdd('});'#13#10);
    Result:=Result+'           </div>'#13#10;
    prOnReadyScriptAdd('searchautocompleteinit("#vin-search-catalog-input-cv");'#13#10);                 // vc_new
    prOnReadyScriptAdd('savesearchhistory("#vin-search-catalog-input-cv", "", "vinsearchhistory", 10);'#13#10); // vc_new
    prOnReadyScriptAdd('$(''#vin-search-catalog-select-cv'').searchVinBox();'#13#10);
    prOnReadyScriptAdd('$("select.login-input-oe").selectmenu({'#13#10);
    prOnReadyScriptAdd('  change: function( event, ui ) {'#13#10);
    prOnReadyScriptAdd(' $("#origprogs .selectpartsdiv .header-link form").submit(); }'#13#10);
    prOnReadyScriptAdd('});'#13#10);

end;
//vv ---------------
(*    Result:=Result+'         <div id="tabs-1" data-mcs-theme="inset-dark">'#13#10;
    Result:=Result+'           <div id="origprogs" style="position: relative;">'#13#10;
    Result:=Result+'             <div id="origprogsheader" class="selectpartsdivheader">'#13#10;
    Result:=Result+'               <nav class="header-link">'#13#10;
    Result:=Result+'                 <a title="Назад" onclick='''' href="#" class="back-btn"></a>'#13#10;
    Result:=Result+'                 <span id="origheaderlogo" class="prod-logo"></span>'#13#10;
    Result:=Result+'                 <a href="#" onclick="ec(''laximostartpage'', '''', ''abj'');" class="start-btn">Начало</a>'#13#10;
    Result:=Result+'               </nav>'#13#10;
    Result:=Result+'             </div>'#13#10;
    for i:=0 to 9 do begin
      Result:=Result+'           <div class="selectpartsdiv'+fnIfStr(i=0,' currentdiv" ','" headerdiv="origprogsheader"')+' number="'+IntToStr(i)+'"></div>';
    end;
    Result:=Result+'           </div>'#13#10;
    Result:=Result+'         </div>'#13#10;    //"tabs-1
//vv -----------------
    Result:=Result+'         <div id="tabs-11" data-mcs-theme="inset-dark">'#13#10;
    Result:=Result+'           <div id="origprogscv" style="position: relative;">'#13#10;
    Result:=Result+'             <div id="origprogsheadercv" class="selectpartsdivheader">'#13#10;
    Result:=Result+'               <nav class="header-link">'#13#10;
    Result:=Result+'                 <a title="Назад" onclick='''' href="#" class="back-btn"></a>'#13#10;
    Result:=Result+'                 <span id="origheaderlogocv" class="prod-logo"></span>'#13#10;
    Result:=Result+'                 <a href="#" onclick="ec(''laximostartpage'', '''', ''abj'');" class="start-btn">Начало</a>'#13#10;
    Result:=Result+'               </nav>'#13#10;
    Result:=Result+'             </div>'#13#10;
    for i:=0 to 9 do begin
      Result:=Result+'           <div class="selectpartsdiv'+fnIfStr(i=0,' currentdiv" ','" headerdiv="origprogsheader"')+' number="'+IntToStr(i)+'"></div>';
    end;
    Result:=Result+'           </div>'#13#10;  *)
//vv ----------------
    Result:=Result+'         </div>'#13#10;    //"tabs-11"
    Result:=Result+'         <div id="tabs-2" data-mcs-theme="inset-dark">'#13#10;
    Result:=Result+'           <div class="selectpartsdiv" id="selbymodeldivauto" number="0">'#13#10;
    Result:=Result+'             <div>'#13#10;
    Result:=Result+'               <table class="table-auto-model">'#13#10;
    Result:=Result+'                 <tr>'#13#10;
    Result:=Result+'                   <td><span class="ware-info-name-span auto-find-span">Производитель: </span></td>'#13#10;
    Result:=Result+'                   <td><select id="manuflistauto" class="login-input" style="width: 550px; margin-right: 16px;" onchange=''loadmodellinelist(this, "modellisttableauto", "modellinelistauto", '+IntToStr(constIsAuto)+');''></select></td></tr>';
    Result:=Result+'                 <tr>'#13#10;
    Result:=Result+'                   <td><span class="ware-info-name-span auto-find-span">Модельный ряд: </span></td>'#13#10;
    Result:=Result+'                   <td><select id="modellinelistauto" class="login-input"  onchange=''loadmodelslist(this, "modellisttableauto", '+IntToStr(constIsAuto)+');''></select></td></tr>';
    Result:=Result+'               </table>'#13#10;
    Result:=Result+'               <div id="modellisttableauto-body-wrap"  data-mcs-theme="inset-dark"> ';
    Result:=Result+'                 <table id="modellisttableauto" class="table table-body debt-table-body pointer" style="width: 100%;">';
    Result:=Result+'                 </table>';
    Result:=Result+'               </div>';  //
    Result:=Result+'             </div>';
    Result:=Result+'             <div  data-mcs-theme="inset-dark" id="autotop10-body-wrap" >'; // +++ див для топ10
    Result:=Result+'               <table class="top10tbl table table-body debt-table-body pointer" id="autotop10" width=100%>';
    Result:=Result+'               </table>';
    Result:=Result+'             </div>';  // --- див для топ10
    Result:=Result+'           </div>';  // --- selbymodeldivauto
    Result:=Result+'           <div class="selectpartsdivheader"  id="automodelheaderdiv">';
    Result:=Result+'             <button class="white-btn btn" title="К списку моделей" '
                                 +'onclick="setpodborsubdiv(-1,0); ">Назад</button>';  //
    Result:=Result+'             <h1 class="grayline" id=automodeltreeheader style=''height: 32px;''>Двойной клик по узлу - переход к отображению товаров</h1><br/>';
    Result:=Result+'             <form onSubmit="if ($(''#nodesearchauto'').val()!='''') { search_node2(''sel_auto'', ''autotreediv'', ''nodesearchauto''); return false;}" >';
    Result:=Result+'                <div class="search-input">'#13#10;
    Result:=Result+'                  <input id="nodesearchauto" type="text">'#13#10;
    Result:=Result+'                  <span onclick="if ($(''#nodesearchauto'').val()!='''') { search_node2(''sel_auto'', ''autotreediv'', ''nodesearchauto''); }" class="search-btn btn">Поиск</span>'#13#10;
    Result:=Result+'                </div>'#13#10;
    Result:=Result+'             </form>';  //
    Result:=Result+'           </div>'#13#10;// id="automodeldivheader"
    Result:=Result+'           <div class="tree-view selectpartsdiv" id=selbymodeltreedivauto number="1" headerdiv="automodelheaderdiv">';
    Result:=Result+'             <div id=autotreediv>';
    Result:=Result+'               <ul id=sel_auto_ul_0 style=''position: relative;''></ul>';  //
    Result:=Result+'             </div>';
    Result:=Result+'           </div>';  //selbymodeltreedivauto
    Result:=Result+'         </div> '#13#10;
    Result:=Result+'         <div id="tabs-3" data-mcs-theme="inset-dark">'#13#10;
    Result:=Result+'           <div id="selectbyengineautodiv" >';
    Result:=Result+'             <div class="selectpartsdiv" id="selbyenginedivauto" number="0">';
    Result:=Result+'               <div>';
    Result:=Result+'                 <span class="ware-info-name-span auto-find-span">Производитель: </span>';
    Result:=Result+'                 <select id="manuflistautoengine" class="login-input engine"  onchange=''$("#listautoengine")[0].options.length=0; if (this.value!=-1) ec("loadengines", "id="+this.value, "abj");''></select><br />'#13#10;
    Result:=Result+'                 <span class="ware-info-name-span auto-find-span" >Двигатель: </span>';
    Result:=Result+'                 <select class="login-input engine" id="listautoengine"></select><br />';
    Result:=Result+'                 <span class="ware-info-text" >Двигатель . . . Объем . . . кВт . . . л.с. . . . К-во цилиндров</span><br />'#13#10;
    Result:=Result+'                <button href="#" onclick=''if ($("#listautoengine")[0].options.length) ec("showengineoptions", "engineid="+$("#listautoengine").val(), "abj");'' class="btn green-btn pointer">Характеристики</button>'#13#10;
    Result:=Result+'                <button href="#" class="btn blue-btn pointer" onclick=''if ($("#listautoengine")[0].options.length) '+
    'showmodtree($("#listautoengine").val(), "selbymodeltreedivautoengine", "selbymodelauenobj", "sel_auen");''>Далее</button>'#13#10;
    Result:=Result+'               </div>'#13#10;
    Result:=Result+'               <div  style="text-align: left; height: 250px; width: 100%; overflow-y: auto;" >'#13#10; // +++ див для топ10
    Result:=Result+'                 <span class="ware-info-name-span auto-find-span">Последние выбранные</span>'#13#10;
    Result:=Result+'                 <table class="top10tbl" id="auentop10" style="width: 100%;">'#13#10;
    Result:=Result+'                 </table>'#13#10;
    Result:=Result+'               </div>'#13#10; // --- див для топ10
    Result:=Result+'             </div>'#13#10; // --- див для топ10
    Result:=Result+'             <div class="selectpartsdivheader"  id="engineheaderdiv">'; //
    Result:=Result+'             <button class="white-btn btn" title="К списку двигателей" '
                                 +'onclick="setpodborsubdiv(-1, 0); ">Назад</button>';  //
    Result:=Result+'               <h1 class="grayline" id=auenmodeltreeheader style=''height: 32px;''>Двойной клик по узлу - переход к отображению товаров</h1><br/>';
    Result:=Result+                '<form onSubmit="if ($(''#nodesearchengineauto'').val()!='''') { search_node2(''sel_auen'',''nodesearchengineauto'', ''auentreediv''); return false; }" >';
    Result:=Result+'                  <div class="search-input">'#13#10;
    Result:=Result+'                    <input id="nodesearchengineauto" type="text">'#13#10;
    Result:=Result+'                    <span onclick=" if ($(''#nodesearchengineauto'').val()!='''') { search_node2(''sel_auen'',''autotreediv'',''nodesearchengineauto'' ); }" class="search-btn btn">Поиск</span>'#13#10;
    Result:=Result+'                  </div>'#13#10;
    Result:=Result+'                </form>'#13#10;  //
    Result:=Result+'             </div>'#13#10;
    Result:=Result+'             <div class="selectpartsdiv" id="selbymodeltreedivautoengine"  number="1" headerdiv="engineheaderdiv">';
    Result:=Result+'               <div class="tree-view" id="auentreediv" >'#13#10;
    Result:=Result+'                 <ul id="sel_auen_ul_0" style=''position: relative;''></ul>'#13#10;  //
    Result:=Result+'               </div>'#13#10; //auentreediv
    Result:=Result+'             </div>';  //selbymodeltreedivautoengine
    Result:=Result+'          </div>'#13#10; // id="selectbyengineautodiv"
    Result:=Result+'         </div>'#13#10;
    Result:=Result+'         <div id="tabs-6" data-mcs-theme="inset-dark">'#13#10;
    Result:=Result+'           <div class="selectpartsdiv" id="selbymodeldivcv" number="0">'#13#10;
    Result:=Result+'             <div>'#13#10;
    Result:=Result+'               <table class="table-auto-model">'#13#10;
    Result:=Result+'                 <tr>'#13#10;
    Result:=Result+'                   <td><span class="ware-info-name-span auto-find-span">Производитель: </span></td>'#13#10;
    Result:=Result+'                   <td><select id="manuflistcv" class="login-input" style="width: 550px; margin-right: 16px;" onchange=''loadmodellinelist(this, "modellisttablecv", "modellinelistcv", '+IntToStr(constIscv)+');''></select></td></tr>';
    Result:=Result+'                 <tr>'#13#10;
    Result:=Result+'                   <td><span class="ware-info-name-span auto-find-span">Модельный ряд: </span></td>'#13#10;
    Result:=Result+'                   <td><select id="modellinelistcv" class="login-input"  onchange=''loadmodelslist(this, "modellisttablecv", '+IntToStr(constIscv)+');''></select></td></tr>';
    Result:=Result+'               </table>'#13#10;
    Result:=Result+'               <div id="modellisttablecv-body-wrap"  data-mcs-theme="inset-dark"> ';
    Result:=Result+'                 <table id="modellisttablecv" class="table table-body debt-table-body pointer" style="width: 100%;">';
    Result:=Result+'                 </table>';
    Result:=Result+'               </div>';  //
    Result:=Result+'             </div>';
    Result:=Result+'             <div  data-mcs-theme="inset-dark" id="cvtop10-body-wrap" >'; // +++ див для топ10
    Result:=Result+'               <table class="top10tbl table table-body debt-table-body pointer" id="cvtop10" width=100%>';
    Result:=Result+'               </table>';
    Result:=Result+'             </div>';  // --- див для топ10
    Result:=Result+'           </div>';  // --- selbymodeldivcv
    Result:=Result+'           <div class="selectpartsdivheader"  id="cvmodelheaderdiv">';
    Result:=Result+'             <button class="white-btn btn" title="К списку моделей" '
                                   +'onclick="setpodborsubdiv(-1,0); ">Назад</button>';  //
    Result:=Result+'             <h1 class="grayline" id=cvmodeltreeheader style=''height: 32px;''>Двойной клик по узлу - переход к отображению товаров</h1><br/>';
    Result:=Result+'             <form onSubmit="if ($(''#nodesearchcv'').val()!='''') { search_node2(''sel_cv'', ''cvtreediv'', ''nodesearchcv''); return false;}" >';
    Result:=Result+'                <div class="search-input">'#13#10;
    Result:=Result+'                  <input id="nodesearchcv" type="text">'#13#10;
    Result:=Result+'                  <span onclick="if ($(''#nodesearchcv'').val()!='''') { search_node2(''sel_cv'', ''cvtreediv'', ''nodesearchcv''); }" class="search-btn btn">Поиск</span>'#13#10;
    Result:=Result+'                </div>'#13#10;
    Result:=Result+'             </form>';  //
    Result:=Result+'           </div>'#13#10;// id="cvmodeldivheader"
    Result:=Result+'           <div class="tree-view selectpartsdiv" id=selbymodeltreedivcv number="1" headerdiv="cvmodelheaderdiv">';
    Result:=Result+'             <div id=cvtreediv>';
    Result:=Result+'               <ul id=sel_cv_ul_0 style=''position: relative;''></ul>';  //
    Result:=Result+'             </div>';
    Result:=Result+'           </div>';  //selbymodeltreedivcv
    Result:=Result+'         </div> '#13#10;

    Result:=Result+'         <div id="tabs-7" data-mcs-theme="inset-dark">'#13#10;
    Result:=Result+'           <div class="selectpartsdiv" id="selbymodeldivax" number="0">'#13#10;
    Result:=Result+'             <div>'#13#10;
    Result:=Result+'               <table class="table-auto-model">'#13#10;
    Result:=Result+'                 <tr>'#13#10;
    Result:=Result+'                   <td><span class="ware-info-name-span auto-find-span">Производитель: </span></td>'#13#10;
    Result:=Result+'                   <td><select id="manuflistax" class="login-input" style="width: 550px; margin-right: 16px;" onchange=''loadmodellinelist(this, "modellisttableax", "modellinelistax", '+IntToStr(constIsAx)+');''></select></td></tr>';
    Result:=Result+'                 <tr>'#13#10;
    Result:=Result+'                   <td><span class="ware-info-name-span auto-find-span">Модельный ряд: </span></td>'#13#10;
    Result:=Result+'                   <td><select id="modellinelistax" class="login-input"  onchange=''loadmodelslist(this, "modellisttableax", '+IntToStr(constIsAx)+');''></select></td></tr>';
    Result:=Result+'               </table>'#13#10;
    Result:=Result+'               <div id="modellisttableax-body-wrap"  data-mcs-theme="inset-dark"> ';
    Result:=Result+'                 <table id="modellisttableax" class="table table-body debt-table-body pointer" style="width: 100%;">';
    Result:=Result+'                 </table>';
    Result:=Result+'               </div>';  //
    Result:=Result+'             </div>';
    Result:=Result+'             <div  data-mcs-theme="inset-dark" id="cvtop10-body-wrap" >'; // +++ див для топ10
    Result:=Result+'               <table class="top10tbl table table-body debt-table-body pointer" id="axtop10" width=100%>';
    Result:=Result+'               </table>';
    Result:=Result+'             </div>';  // --- див для топ10
    Result:=Result+'           </div>';  // --- selbymodeldivcv
    Result:=Result+'           <div class="selectpartsdivheader"  id="axmodelheaderdiv">';
    Result:=Result+'             <button class="white-btn btn" title="К списку моделей" '
                                   +'onclick="setpodborsubdiv(-1,0); ">Назад</button>';  //
    Result:=Result+'             <h1 class="grayline" id=axmodeltreeheader style=''height: 32px;''>Двойной клик по узлу - переход к отображению товаров</h1><br/>';
    Result:=Result+'             <form onSubmit="if ($(''#nodesearchax'').val()!='''') { search_node2(''sel_ax'', ''axtreediv'', ''nodesearchax''); return false;}" >';
    Result:=Result+'                <div class="search-input">'#13#10;
    Result:=Result+'                  <input id="nodesearchax" type="text">'#13#10;
    Result:=Result+'                  <span onclick="if ($(''#nodesearchax'').val()!='''') { search_node2(''sel_ax'', ''axtreediv'', ''nodesearchax''); }" class="search-btn btn">Поиск</span>'#13#10;
    Result:=Result+'                </div>'#13#10;
    Result:=Result+'             </form>';  //
    Result:=Result+'           </div>'#13#10;// id="cvmodeldivheader"
    Result:=Result+'           <div class="tree-view selectpartsdiv" id=selbymodeltreedivax number="1" headerdiv="axmodelheaderdiv">';
    Result:=Result+'             <div id=axtreediv>';
    Result:=Result+'               <ul id=sel_ax_ul_0 style=''position: relative;''></ul>';  //
    Result:=Result+'             </div>';
    Result:=Result+'           </div>';  //selbymodeltreedivcv
    Result:=Result+'         </div> '#13#10;
    Result:=Result+'         <div id="tabs-4" data-mcs-theme="inset-dark"> '#13#10;
    Result:=Result+'           <div class="selectpartsdiv" id="selectbymodelmotodiv" number="0">'#13#10;
    Result:=Result+'             <div>'#13#10;
    Result:=Result+'               <table class="table-auto-model">'#13#10;
    Result:=Result+'                 <tr>'#13#10;
    Result:=Result+'                   <td><span class="ware-info-name-span auto-find-span">Производитель: </span></td>'#13#10;
    Result:=Result+'                   <td><select id="manuflistmoto" class="login-input moto"  onchange=''loadmodellinelist(this, "modellisttablemoto", "modellinelistmoto", '+IntToStr(constIsMoto)+');''></select></td></tr>';
    Result:=Result+'                 <tr>'#13#10;
    Result:=Result+'                   <td><span class="ware-info-name-span auto-find-span">Модельный ряд: </span></td>'#13#10;
    Result:=Result+'                   <td><select id="modellinelistmoto" class="login-input moto"  onchange=''loadmodelslist(this, "modellisttablemoto", '+IntToStr(constIsMoto)+');''></select></td></tr>';
    Result:=Result+'               </table>'#13#10;
    Result:=Result+'               <div id="modellisttablemoto-body-wrap"  data-mcs-theme="inset-dark"> ';
    Result:=Result+'                 <table id="modellisttablemoto" class="table table-body debt-table-body pointer" style="width: 100%;">';
    Result:=Result+'                 </table>';
    Result:=Result+'               </div>';  //
    Result:=Result+'             </div>';
    Result:=Result+'             <div  data-mcs-theme="inset-dark" id="mototop10-body-wrap" >'; // +++ див для топ10
    Result:=Result+'               <table class="top10tbl table table-body debt-table-body pointer" id="mototop10" width=100%>';
    Result:=Result+'               </table>';
    Result:=Result+'             </div>';  // --- див для топ10
    Result:=Result+'           </div>'#13#10; // --- див для топ10
    Result:=Result+'             <div class="selectpartsdivheader"  id="motomodelheaderdiv">'; //
    Result:=Result+'             <button class="white-btn btn" title="К списку моделей" '
                                 +'onclick="setpodborsubdiv(-1, 0); ">Назад</button>';  //
    Result:=Result+'               <h1 class="grayline" id="motomodeltreeheader" style=''height: 32px;''>Двойной клик по узлу - переход к отображению товаров</h1>';
    Result:=Result+'               <form onSubmit="if ($(''#nodesearchmoto'').val()!='''') { search_node2(''sel_moto'', ''selbymodeltreediv'', ''nodesearchmoto''); return false;}" >';
    Result:=Result+'                  <div class="search-input">'#13#10;
    Result:=Result+'                    <input id="nodesearchmoto" type="text">'#13#10;
    Result:=Result+'                    <span onclick="if ($(''#nodesearchmoto'').val()!='''') { search_node2(''sel_moto'', ''selbymodeltreediv'', ''nodesearchmoto''); }" class="search-btn btn">Поиск</span>'#13#10;
    Result:=Result+'                  </div>'#13#10;
    Result:=Result+'               </form>';  //
    Result:=Result+'             </div>';
    Result:=Result+'             <div class="tree-view selectpartsdiv" id="selbymodeltreediv" number="1" headerdiv="motomodelheaderdiv">'; //
    Result:=Result+'               <ul id="sel_moto_ul_0" style=''position: relative;''></ul>';  //
    Result:=Result+'             </div>';
    Result:=Result+'        </div> '#13#10;
    Result:=Result+'         <div id="tabs-5">'#13#10;
    Result:=Result+'           <div id="selectbyattributemotodiv" style="position: relative;">';
    Result:=Result+'             <div class="selectpartsdiv" id="selbyattrdiv" number="0">';
    Result:=Result+'               <div>';
    Result:=Result+'                 <table id="motoattrlisttable" >';
    Result:=Result+'                 </table>';
    Result:=Result+'               </div>';
    Result:=Result+'             </div>';  //selbyattrdiv
    Result:=Result+'             <div class="selectpartsdivheader"  id="motoattrheaderdiv">'; //
    Result:=Result+'             <a class="back-btn" title="Назад"  onclick="setpodborsubdiv(-1, 0);" href="#"></a>';
    Result:=Result+'               <span class="attr-back-text" style="margin: 0px;">Введите значения для подбора</span>';
    Result:=Result+'             </div>';
    Result:=Result+'             <div class="selectpartsdiv" id="selmotobyattrdiv"  number="1" headerdiv="motoattrheaderdiv"> ';
    Result:=Result+'               <input type=hidden id="selmotobyattrinp" name="selmotobyattrinp">';
    Result:=Result+'               <input type=hidden id="selmotobyattridgroup" name="selmotobyattridgroup" value="">';
    Result:=Result+'               <table id="main-podbor-param-table">'#13#10;
    Result:=Result+'                 <tr>'#13#10;
    Result:=Result+'                   <td>'#13#10;
    Result:=Result+'                     <table id="motoattrtable" > '#13#10;
    Result:=Result+'                     </table>'#13#10;
    Result:=Result+'                   </td>'#13#10;
    Result:=Result+'                   <td>'#13#10;
    Result:=Result+'                     <div id="sampleimgdiv2">'#13#10;
    Result:=Result+'                       <span style="text-align: center;">Типы креплений для передних дворников</span>';
    Result:=Result+'                       <img class="sampleimg" src="'+userInf.DescrImageUrl+'/images/Fixing_wipersForward.png" onclick="changeSizeImage(this,1);" class="" title="">';
    Result:=Result+'                     </div>'#13#10;
    Result:=Result+'                   </td>'#13#10;
    Result:=Result+'                   <td>'#13#10;
    Result:=Result+'                     <div id="sampleimgdiv"><span style="text-align: center;">Типы креплений для задних дворников</span>';
    Result:=Result+'                     <img class="sampleimg" src="'+userInf.DescrImageUrl+'/images/Fixing_wipersBack.png" onclick="changeSizeImage(this,2);" class="" title=""></div>';
    Result:=Result+'                   </td>';  //
    Result:=Result+'                 </tr>'#13#10;
    Result:=Result+'               </table>';
    Result:=Result+'             </div>';  //selmotobyattrdiv
    Result:=Result+'           </div>'#13#10; // id="selectbyattributemotodiv"
    Result:=Result+'         </div>'#13#10;
    Result:=Result+'       </div>'#13#10;
    Result:=Result+'     </div> '#13#10;
    Result:=Result+'   </div> '#13#10;
    Result:=Result+' </section> '#13#10;
end;




function fnAutenticationFormShortRedisign(var userInf:TUserInfo; text: string ='') : string;
begin
  if (text<>'') then begin
    Result:=Result+'<span style="color: #000;">'+text+'</span>';
  end;
  Result:=Result+'<div id="authformdiv">';
  Result:=Result+'<div id="authformsubdiv">'#13#10;
  Result:=Result+'<form method=post id="authform" action="'+userInf.DescrUrl+'/nabj" onSubmit="return sfba(this, ''nabj'');" >'#13#10;
  Result:=Result+'<div id="authforms-inputdiv">'#13#10;
  Result:=Result+'<input type=hidden name=act value=backjob'+fnIfStr(text='', 'main', '')+'autentication>';
  Result:=Result+'<span id="authformloginspan">Логин&nbsp;</span><input type=text class="login-input" name="psw" maxlength=50><br><br><br>';
  Result:=Result+'<span id="authformpassspan">Пароль&nbsp;</span><input type=password class="login-input" name="lgn" maxlength=50><br><br>';
  Result:=Result+'</div>'#13#10;
  Result:=Result+'<div class="login-wrap">'#13#10;
  Result:=Result+' <input type=submit class="login btn btn-enter"  value="Вход" ><a class="authforms-link-forget" onclick="remindpass();">Забыли пароль?</a><br>'#13#10;
  Result:=Result+' <a class="authforms-link-registr" href="'+userInf.ScriptName+'/registration">Зарегистрироваться</a>'#13#10;
  Result:=Result+'</div>';
  Result:=Result+'</form>';
  Result:=Result+fnContactInformationRedisign(userInf,false);
  Result:=Result+'</div>';
  Result:=Result+'</div>';
  Result:=Result+'<script>'#13#10;
  Result:=Result+'$(".main-content").css("height","700px");'#13#10;
  Result:=Result+'$("span.hot-motul-line").tooltipster({'#13#10;
  Result:=Result+'content: $("<div class=''tooltip-container-div''>'+ //<p>Звоните, наши специалисты:</p>
      ' <ul  class=''motul-ul''> <li><ul>'+
          '<li class=''''>подбор масел и жидкостей MOTUL'+
          '<li class=''''>информация по продукции и действующим акциям  '+
          '<li class=''''>вопросы касательно бренда и работы с ним '+
          '</ul>'+
      '</ul>'+
      '</div>")'#13#10;
   Result:=Result+'});'#13#10;
   Result:=Result+' $("span.hot-motul-line").tooltipster();'#13#10;
   Result:=Result+'</script>'#13#10;
end;

function fnAutenticationFormRedisign(var userInf:TUserInfo) : string;
begin
  Result:='';
  if (userInf.flTechWork) then begin
   end else begin
    Result:=Result+'<div id="authhederdiv"><span id="authhederspan">Вход</span></div>';
    Result:=Result+fnAutenticationFormShortRedisign(userInf);
    //Result:=Result+'<input type=button class=input1 style=''position: relative; left: 1px; margin-top: 20px;'' value="Регистрация" onClick=''location.href="'+Request.ScriptName+'/registration";''><br>';
    //Result:=Result+'<input type=button class=input1 style=''position: relative; left: 1px; margin-top: 20px; font-size: 12px;'' value="Напомнить пароль" onclick=''remindpass();''><br>';
    //Result:=Result+'</div>';
  end;
end;

function fnDefaultPageRedisign(var userInf:TUserInfo; AuthMess: string): string;
var
  s, s2, s3: string;
  f: text;
begin
  s:='';
  if userInf.ResetPassword then begin
    s:=s+'<div id=chpassdiv>';
    s:=s+'<form method=post action='+userInf.ScriptName+'>';
    s:=s+'В соответствии с политикой безопасности системы пользователь с логином "'+userInf.UserLogin+'" должен сменить текущий пароль.  ';
    s:=s+'Для этого введите новый пароль дважды в поля расположенной ниже формы и нажмите клавишу "Enter" или кнопку "Ввод". ';
    s:=s+'Пароль должен быть длиной от 5 до 20 символов и состоять только из латинских букв и цифр.<br>';
    s:=s+'<input type=hidden name=act value=resetpass>';
    s:=s+'<input type=hidden name=psw value="'+userInf.UserLogin+'">';
    s:=s+'<input type=hidden name=lgn value="'+userInf.UserPass+'">';
    s:=s+'<span style="white-space: nowrap;"><span style=''visibility: hidden;''>(повторно )</span>Пароль:<input type=password class=input1 name=change1 maxlength=20></span><br>';
    s:=s+'<span style="white-space: nowrap;">Пароль (повторно):<input type=password class=input1 name=change2 maxlength=20></span><br>';
    s:=s+'<span style="white-space: nowrap;"><span style=''visibility: hidden;''>Пароль:(повторно )</span><input type=submit class=input1 style=''position: relative; left: 1px;'' value=Ввод></span><br>';
    s:=s+'</form>';
    s:=s+'</div>';
  end else begin
    s:=s+'<hr>';
    s3:='';
    if FileExists('whatsnew.html') then try

      AssignFile(f, 'whatsnew.html');
      Reset(f);
      ReadLn(f, s2);
      if Copy(s2, 1, 3)='<b>' then begin
        s2:=Copy(s2, 4, 10);
        if (EncodeDate(Abs(StrToIntDef(Copy(s2, 7, 4), 2009)), Abs(StrToIntDef(Copy(s2, 4, 2), 1)), Abs(StrToIntDef(Copy(s2, 1, 2), 1)))+10)>Date then begin
          Repeat
            ReadLn(f, s2);
            s3:=s3+s2;
          Until EOF(f) or (Pos('</ul>', s2)>0);
        end;
      end;
    finally
      CloseFile(f);
    end;
    if s3<>'' then s:=s+'<h1 class=doctitle color=red>Новости системы:</h1>'+s3+'<hr color=red>';
  end;
  //Result:=s;
end;  // fnDefaultPage

// Общее, пригодное для всех страниц начало
function fnHeaderRedisign(var userInf:TUserInfo;Autenticated: Boolean=true) : string;

{ ##############################################################################
  функция, взозвращающая элемент меню
  MenuText - текст элемента меню
  Address - адрес страницы перехода
  aPageName - имя страницы для сравнения с текущей
  Collapsed - false - расширеный вариант, true - свернутый
  ##############################################################################}

var
  s,serverDate,s1: string;
  i: integer;
  ars: tas;
  Notifies: tas;

begin
  Result:='';
  Result:=Result+'<!DOCTYPE html>'#13#10;
  Result:=Result+'<html lang="en">'#13#10;
  Result:=Result+'<head>'#13#10;
  Result:=Result+'<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'#13#10;
  Result:=Result+'<meta name="description" content="webkid react starterkit">'#13#10;
  Result:=Result+'<meta name="viewport" content="width=device-width, initial-scale=1">'#13#10;
  Randomize;
  Result:=Result+'<link rel="stylesheet" id="opensans400600subsetlatincyrillic-css"  href="//fonts.googleapis.com/css?family=Open+Sans%3A400%2C600&#038;subset=latin%2Ccyrillic&#038;ver=f44c3a3528c4244c15f828a6d22096a1" type="text/css" media="all" />'#13#10;
  Result:=Result+'  <script src="'+userInf.OuterJSPatch+'"></script>'#13#10;
  Result:=Result+'  <link rel="stylesheet" href="'+userInf.OuterCssPatch+'" /> '#13#10;
  Result:=Result+'  <script src="'+userInf.DescrImageUrl+'/js/main.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
  Result:=Result+'<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-select/1.7.5/css/bootstrap-select.min.css">'#13#10;
  Result:=Result+'<script src="'+userInf.DescrImageUrl+'/js/bootstrap-select.js"></script>'#13#10;
  Result:=Result+'<link rel="stylesheet" type="text/css" href="'+userInf.DescrImageUrl+'/css/orders_.css?'+FormatDateTime(cDateTimeFormatY2S, Now)+'">'#13#10;
  if userInf.PageName='contacts' then
   Result:=Result+'<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?v=3.exp"></script>'#13#10;
  Result:=Result+'  <script src="'+userInf.DescrImageUrl+'/js/orders_.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
  Result:=Result+'  <script src="'+userInf.DescrImageUrl+'/js/common_.js?'+FormatDateTime(cDateTimeFormatY2S, Now)+'"></script>'#13#10;
  if userInf.PageName='loyalty' then
    Result:=Result+'  <script src="'+userInf.DescrImageUrl+'/js/gift.js"></script>'#13#10;
  Result:=Result+'<link rel="stylesheet" type="text/css" href="'+userInf.DescrImageUrl+'/css/main.css?'+FormatDateTime(cDateTimeFormatY2S, Now)+'">'#13#10;
  if userInf.PageName='orders' then begin
    Result:=Result+'<title>'+userInf.TitleStr+' - "Заказы"</title>'#13#10;
  end else
    Result:=Result+'<title>'+userInf.TitleStr+'</title>'#13#10;
  Result:=Result+'<script type="text/javascript">'#13#10;
  Result:=Result+'scriptname="'+userInf.ScriptName+'";'#13#10;
  DateTimeToString(s, 'm', userInf.ServerTime);
  DateTimeToString(s, 'yyyy, '+IntToStr(StrToInt(s)-1)+', d, h, n, s', userInf.ServerTime);
  s:=StringReplace(s, ', ', '", "', [rfReplaceAll]);
  Result:=Result+'flNewModeCGI='+fnIfStr(flNewModeCGI,'true','false')+';'#13#10;
  Result:=Result+'flRedesign='+fnIfStr(userInf.flRedesign,'true','false')+';'#13#10;
  if userInf.flUber then begin
    Result:=Result+'IsUberClient='+BoolToStr(userInf.IsUberClient)+';'#13#10;
  end;
  Result:=Result+'page="'+userInf.PageName+'";'#13#10;
  Result:=Result+'var usermail="'+userInf.PrsnEmail+'";'#13#10;
  Result:=Result+'var descrurl="'+userInf.DescrUrl+'";'#13#10;
  Result:=Result+'var descrimageurl="'+userInf.DescrImageUrl+'";'#13#10;
  Result:=Result+'allowbonuses=true;'#13#10;
  Result:=Result+'$(".main-content").css("height","none");'#13#10;

  s:='';
  if Autenticated and userInf.FirstEnter and (userInf.WarningMessage<>'') then begin
    s1:=s1+'<div id="warningdiv" >';
    if userInf.SaleBlock then begin
      s1:=s1+'<h1  style="color: '+arDelayWarningsColor[2]+';">ОТГРУЗКА ЗАПРЕЩЕНА</h1>';
    end else begin
      s1:=s1+'<h1 style="color: '+arDelayWarningsColor[1]+';">'+userInf.WarningMessage+'</h1>';
    end;
    s1:=s1+'Показать перечень неоплаченных документов?<br>';
    s1:=s1+'<a class="apply-btn btn info-close" onclick="location.href=\'''+userInf.ScriptName+'/debt\''; ">Да</a>';
    s1:=s1+'<a class="close-btn btn info-close" onclick="">Нет</a>';
    s1:=s1+'</div>';
    s:=s+'jqswfillInfo('''+s1+''',"",20,0,35); '#13#10;
  end;
  if Autenticated and userInf.FirstEnter and (trim(userInf.strCookie.Values['notifies'])<>'') then begin
    Notifies:=fnSplitString(trim(userInf.strCookie.Values['notifies']), ',');
    for i:=0 to Length(Notifies)-1 do begin
      s:=s+'ec("shownotification", "notifcode='+Notifies[i]+'", "abj");'#13#10;
    end;
  end;

  if (s<>'') then prOnreadyScriptAdd(s);
  Result:=Result+'</script>';
  Result:=Result+GoogleAnalytics;
  Result:=Result+'</head>';
  Result:=Result+'<body  onresize="ResizeSVK();">';
  Result:=Result+' <div class="container-fluid main-page">';
  Result:=Result+'<div id="jqdialog" data-mcs-theme="inset-dark" style="display: none;" ></div>'; // див под диалоги jQuery

  if Autenticated then begin
  //  Result:=Result+'<div style="display: none;">'; // чисто спрятать внутренние дивы, а когда их fancybox начнет показывать, hide с них уйдет

    Result:=Result+'<div style="position: absolute; left: -1000000px;">'#13#10; // чисто спрятать внутренние дивы, а когда их fancybox начнет показывать, hide с них уйдет
    Result:=Result+'<iframe id="downloadframe"></iframe>'; // фрейм для загрузки файлов

    Result:=Result+'<div id="bjauthdiv" style="text-align: right; width: 205px; padding: 10px;">'+fnAutenticationFormShortRedisign2(userInf, 'Пожалуйста, введите свои пароль и логин для продолжения работы.')+'</div>';


    if (userInf.ContractsCount>0) then begin
      Result:=Result+'<div id=contractlistdiv style="">'+'</div>';
    end;
    if (userInf.PageName='order') or (userInf.PageName='loyalty') then begin
      DateTimeToString(serverDate, 'm', userInf.ServerTime);
      DateTimeToString(serverDate, 'yyyy, '+IntToStr(StrToInt(serverDate)-1)+', d, h, n, s', userInf.ServerTime);
      serverDate:=StringReplace(serverDate, ', ', '", "', [rfReplaceAll]);

      prOnReadyScriptAdd('  $("#fillheaderbeforeprocessingdiv input[name^=''typeofgetting'']").bind(''click, change'', function(event) {'#13#10);
      prOnReadyScriptAdd('clickDeliveryRadioButton (); ');
      prOnReadyScriptAdd('  });'#13#10);

      prOnReadyScriptAdd('');
      prOnReadyScriptAdd('');
      prOnReadyScriptAdd('');
      prOnReadyScriptAdd('');
      prOnReadyScriptAdd('');
      prOnReadyScriptAdd('');
    end;
    Result:=Result+'</div>';  //hidded divs

  end;

  Result:=Result+' <main class="main-content" id="main-content">   '#13#10;
  if Autenticated then begin
    Result:=Result+'       <!-- Header -->'#13#10;
    Result:=Result+'    <header class="main-header">'#13#10;
    Result:=Result+'      <nav class="header-top">'#13#10;
    Result:=Result+'        <div class="row">'#13#10;
    Result:=Result+'          <div class="col-xs-5"> '#13#10;
    if userInf.flTest then begin
      Result:=Result+'<div class="test-div-header" >Тестирование </div>'#13#10;
    end
    else begin
      Result:=Result+'            <a href="http://www.vladislav.ua/"> '#13#10;
      Result:=Result+'              <img src="/images/header-logo.png" alt="header-logo">'#13#10;
      Result:=Result+'            </a> '#13#10;
    end;
    Result:=Result+'          </div>'#13#10;

    Result:=Result+'          <div class="header-tel"> '#13#10;
    Result:=Result+'            <div class="user-name" > '#13#10;
    prOnReadyScriptAdd('$("div.user-name").tooltipster({'#13#10);
    prOnReadyScriptAdd('content: $("<div class=''tooltip-container-div''><p>ЦЕНТР ОБСЛУЖИВАНИЯ КЛИЕНТОВ</p><p>Звонки в пределах Украины бесплатны</p></div>")'#13#10);
    prOnReadyScriptAdd('});'#13#10);
    prOnReadyScriptAdd('$("div.user-name").tooltipster();'#13#10);
    Result:=Result+'              <img src="/images/basket.png" alt="dowloadd">'#13#10;
    Result:=Result+'               <span>'+userInf.PhoneClientCentr+'</span></div>'#13#10;
    Result:=Result+'            <div class="user-id">'#13#10;
    prOnReadyScriptAdd('$("div.user-id").tooltipster({'#13#10);
    prOnReadyScriptAdd(' position: "top", '#13#10);
    prOnReadyScriptAdd('background: "green",'#13#10);
    prOnReadyScriptAdd('content: $("<div class=''tooltip-container-div''><p>СЛУЖБА ПОДДЕРЖКИ / ГОРЯЧАЯ ЛИНИЯ <img src=''/images/motul-55x15.jpg'' height=''15'' width=''55''></p><p>Звонки в пределах Украины бесплатны</p></div>")'#13#10);
    prOnReadyScriptAdd('});'#13#10);
    prOnReadyScriptAdd('$("div.user-id").tooltipster();'#13#10);
    Result:=Result+'              <img src="/images/voice-support.png" alt="dowloadd">'#13#10;
    Result:=Result+'               <span>'+userInf.PhoneSupport+'</span></div>'#13#10;
    Result:=Result+'          </div>'#13#10;
    prOnReadyScriptAdd('$("span.hot-motul-line").tooltipster({'#13#10);
    prOnReadyScriptAdd('content: $("<div class=''tooltip-container-div''>'+ //<p>Звоните, наши специалисты:</p>
      ' <ul  class=''motul-ul''> <li><ul>'+
          '<li class=''''>подбор масел и жидкостей MOTUL'+
          '<li class=''''>информация по продукции и действующим акциям  '+
          '<li class=''''>вопросы касательно бренда и работы с ним '+
          '</ul>'+
      '</ul>'+
      '</div>")'#13#10);
    prOnReadyScriptAdd('});'#13#10);
    prOnReadyScriptAdd('$("span.hot-motul-line").tooltipster();'#13#10);
    Result:=Result+'          <div class="col-xs-7 text-right">'#13#10;
    Result:=Result+'            <div class="user-data data-txt"> '#13#10;
    Result:=Result+'              <p class="user-name">'+userInf.UserName+'</p> '#13#10;
    Result:=Result+'              <p class="user-id">Контракт '+userInf.ContractName+'</p>'#13#10;
    Result:=Result+'            </div>'#13#10;
    Result:=Result+'            <div class="user-data data-btn">'#13#10;
    Result:=Result+'              <a class="user-data-btn" href="#">Инфо</a> '#13#10;
    Result:=Result+'               <div class="user-data-popup hide">'#13#10;
    Result:=Result+'                <span class="popup-close-btn">x</span> '#13#10;
    Result:=Result+'                <div class="options"> '#13#10;
    if (Pos(cSpecDelim,userInf.FirmName)>0) then begin
      s1:=Copy(userInf.FirmName,1,Pos(cSpecDelim,userInf.FirmName)-1);
      Result:=Result+'                  <p class="data-item "><span>'+s1+'</span></p> '#13#10;
      s1:='Код клиента '+Copy(userInf.FirmName,Pos(cSpecDelim,userInf.FirmName)+Length(cSpecDelim),Length(userInf.FirmName));
      Result:=Result+'                  <p class="data-item firm-name"><span>'+s1+'</span></p> '#13#10;
    end
    else
      Result:=Result+'                  <p class="data-item firm-name"><span>'+userInf.FirmName+'</span></p> '#13#10;
    if userInf.flUber then begin
      if not userInf.IsUberClient then
        Result:=Result+'                  <p class="data-item">Кр. условия: <span>'+FormatFloat('# ##0.##', userInf.CredLimit)+' '+userInf.CredCurrency+'</span><span>&#47</span><span>'+IntToStr(userInf.CredDelay)+' дн.</span></p> '#13#10;
    end
    else
      Result:=Result+'                  <p class="data-item">Кр. условия: <span>'+FormatFloat('# ##0.##', userInf.CredLimit)+' '+userInf.CredCurrency+'</span><span>&#47</span><span>'+IntToStr(userInf.CredDelay)+' дн.</span></p> '#13#10;
    Result:=Result+'                  <p class="data-item">'+fnIfStr(userInf.Debt>0, 'Долг', 'Переплата')+': <span>'+FormatFloat('# ##0.00', Abs(userInf.Debt))+' '+userInf.CredCurrency+'</span></p>'#13#10;
    if (Pos(cSpecDelim,userInf.FirmName)>0) then begin
      Result:=Result+'<p class="data-item">'+
                     '<input class="btn blue-btn" value="Создать счет на оплату" onclick="ec(''createnewacc'','''',''newbj'');" >'+
                     '</p>'#13#10;
    end;
    Result:=Result+'                </div> '#13#10;
    if userInf.flUber then begin
      if not userInf.IsUberClient then begin
        Result:=Result+'                <div class="unit"> '#13#10;
        Result:=Result+'                  <p class="data-item">'+UpperCase(userInf.ballsName)+'-резерв: <span id="user-unit-reserv">'+FloatToStr(userInf.contBonusReserv)+'</span></p> '#13#10;
        Result:=Result+'                  <p class="data-item">'+UpperCase(userInf.ballsName)+'-баланс: <span id="user-unit-limit">'+FloatToStr(userInf.BonusQty)+'</span></p> '#13#10;
        Result:=Result+'                </div> '#13#10;
      end;
    end
    else begin
      Result:=Result+'                <div class="unit"> '#13#10;
      Result:=Result+'                  <p class="data-item">'+UpperCase(userInf.ballsName)+'-резерв: <span id="user-unit-reserv">'+FloatToStr(userInf.contBonusReserv)+'</span></p> '#13#10;
      Result:=Result+'                  <p class="data-item">'+UpperCase(userInf.ballsName)+'-баланс: <span id="user-unit-limit">'+FloatToStr(userInf.BonusQty)+'</span></p> '#13#10;
      Result:=Result+'                </div> '#13#10;
    end;
    Result:=Result+'                <div class="reserve"> '#13#10;
    Result:=Result+'                  <p class="data-item" title="'+fnIfStr(userInf.ResLimit>=0, 'Лимит резерва ('+fnIfStr(userInf.ResLimitRest>=0,'остаток - '+FormatFloat('# ##0.00', userInf.ResLimitRest),'превышение - '+FormatFloat('# ##0.00', Abs(userInf.ResLimitRest)))+ ' '+userInf.CredCurrency+')','')+'"><span>Резерв:'+FormatFloat('# ##0.00', userInf.OrderSum)+fnIfStr(userInf.ResLimit>=0, ' /'+FormatFloat('# ##0.00', userInf.ResLimit)+' ',' ')+userInf.CredCurrency+'</span></p>  '#13#10;
    Result:=Result+'                </div>'#13#10;
    Result:=Result+'               </div>'#13#10;
    Result:=Result+'            </div> '#13#10;
    Result:=Result+'          </div> '#13#10;
    Result:=Result+'        </div>'#13#10;
    Result:=Result+'      </nav> '#13#10;
    Result:=Result+'      <nav class="header-navigation"> '#13#10;
    Result:=Result+'        <ul class="navigation-list left">  '#13#10;
    if flNewOrdersMode then
      Result:=Result+'          <li><a href="'+userInf.ScriptName+'/universal?act=orders" class="orders" onclick=" setActiveIcon(this);" title="Заказы">Заказы</a></li>  '#13#10
    else
      Result:=Result+'          <li><a href="'+userInf.ScriptName+'/orders" class="orders" onclick=" setActiveIcon(this);" title="Заказы">Заказы</a></li>  '#13#10;
    Result:=Result+'          <li><a href="'+userInf.ScriptName+'/reserv" class="reserve" title="Резерв">Резерв</a></li>'#13#10;
    Result:=Result+'          <li><a href="'+userInf.ScriptName+'/universal?act=contracts" class="contacts" title="Перейти к списку контрактов, сменить текущий контракт">Контракты</a></li>'#13#10;
    if (not userInf.flUber) or (userInf.flUber and not userInf.IsUberClient) then
       Result:=Result+'          <li><a href="'+userInf.ScriptName+'/loyalty?&contract='+IntToStr(userInf.contBonusOrd)+'" class="gifts" title="Подарки">Подарки</a></li>'#13#10;
    Result:=Result+'        </ul>'#13#10;
    Result:=Result+'      <form action="'+userInf.ScriptName+'/abj" class="main-search search-form" onsubmit="return ws();">'#13#10;
    Result:=Result+'        <div class="main-search" title=""> '#13#10;
    Result:=Result+'            <input type=submit style="display: none;">'#13#10;
    Result:=Result+'            <input id="forfirmid" name="forfirmid" value="0" type="hidden">'#13#10;
    Result:=Result+'            <input id="addlines" name="addlines" value="" type="hidden">'#13#10;
    Result:=Result+'            <input id="contract" name="contract" value="'+IntToStr(userInf.ContractId)+'" type="hidden">'#13#10;
    Result:=Result+'            <input type=hidden name="act" id="act" value="waresearch">';
    Result:=Result+'          <select id="main-search-input" _id="waresearch" class="input-field">'#13#10;
    //Result:=Result+'            <option value="markdown">УЦЕНКА</option>'#13#10;
    //Result:=Result+'            <option value="sale">РАСПРОДАЖА</option>'#13#10;
    Result:=Result+'          </select>'#13#10;
    Result:=Result+'        </div> '#13#10;
    Result:=Result+'      </form> '#13#10;
    Result:=Result+'      <form action="'+userInf.ScriptName+'/abj" class="vin-search search-form" onsubmit="return vs(this);">'#13#10;
    Result:=Result+'        <div class="vin-search" title=""> '#13#10;
    Result:=Result+'            <input  type=submit style="display: none;">'#13#10;
    Result:=Result+'            <select id="vin-search-input" _id="vinsearch" class="input-field"> '#13#10;
    //Result:=Result+'            <!-- <option value="test1">рыба vin-1</option>'#13#10;
    //Result:=Result+'            <option value="test2">рыба vin-2</option> --> '#13#10;
    Result:=Result+'          </select> '#13#10;
    Result:=Result+'        </div>'#13#10;
    Result:=Result+'      </form>'#13#10;
    if flMotulTree  then begin
      Result:=Result+'<span class="podbor-search-all-with-motul pointer"> '#13#10;
      Result:=Result+'  <span class="magnifier-search-all motul pointer" title="Все подборы в одном окне"></span> '#13#10;;
      Result:=Result+'  <img class="podbor-motul-inline header pointer"  src="/images/motul-55x15.jpg" title="">';
      Result:=Result+'</span> '#13#10;
    end
    else
      Result:=Result+'      <span class="magnifier-search-all" title="Все подборы в одном окне"></span> '#13#10;
    Result:=Result+'        <ul class="navigation-list right">'#13#10;
    Result:=Result+'          <li><a href="'+userInf.ScriptName+'/debt" class="chart" title="Финансовая информация"></a></li>'#13#10;
    Result:=Result+'          <li><a href="'+userInf.ScriptName+'/contacts" class="phone" title="Контакты"></a></li>  '#13#10;
    Result:=Result+'          <li><a href="javascript: omf();" class="email" title="'+
    fnIfStr(userInf.PrsnEmail='', 'В Ваших персональных данных не указан e-mail, нажмите на конверт, чтобы перейти к редактированию персональных данных', 'Отправить сообщение менеджеру')+'"></a></li>'#13#10;
    Result:=Result+'          <li><a href="'+userInf.ScriptName+'/info" class="info" title="Информация для клиента"></a></li>'#13#10;
    Result:=Result+'          <li><a href="'+userInf.ScriptName+'/options" class="set" title="Настройки"></a></li>'#13#10;
    Result:=Result+'          <li><a href="#" class="logout" onclick="quit();" title="Выход"></a></li>  '#13#10;
    Result:=Result+'        </ul>'#13#10;
    Result:=Result+'      </nav>'#13#10;
    Result:=Result+'    </header> '#13#10;
    Result:=Result+'    <!-- Header --> '#13#10;
    Result:=Result+' <section id="main-banner" class="main-banner page-block popup-box hide"> '#13#10;
    Result:=Result+' </section>'#13#10;
    Result:=Result+' <section id="delivery-info-tree" class="general-info-tree popup-box hide">'#13#10;
    Result:=Result+'    <div class="info-tree-container" id="delivery-info-container" data-mcs-theme="inset-dark"> '#13#10;
    Result:=Result+'       <div class="info-tree-header"> '#13#10;
    Result:=Result+'          <h3 class="title">Доставка</h3> '#13#10;
    Result:=Result+'          <button type="button" class="close"><span aria-hidden="true" >&times;</span></button> '#13#10;
    Result:=Result+'       </div> '#13#10;
    Result:=Result+'       <div class="info-tree-body" id="delivery-info-body" >  '#13#10;

    Result:=Result+'<div id=fillheaderbeforeprocessingdiv style="width: auto;"><form onsubmit="return false">';
    //Result:=Result+'<input type=hidden name="act" value="so">';
    Result:=Result+'<input type=hidden id="ordr" name="ordr">';
    Result:=Result+'<input type=hidden id="shedulercode" name="shedulercode">';
    Result:=Result+'<input type=hidden id="deliverydatetext" name="deliverydatetext">';
    Result:=Result+'<input type=hidden id="savemark" name="savemark" >';
    Result:=Result+'<input type=hidden id="sendordermark" name="sendordermark" value="1">';
    Result:=Result+'<input type=hidden id="paymenttype" name="paymenttype" >';
    Result:=Result+'<input type=hidden id="forcheckorder" name="forcheckorder" value="0">';   //если он включен не делать запрос на сервер о наличии
    Result:=Result+'<fieldset class="delivery-border"><legend>Способ получения товара</legend>';
    if not flNotReserve then begin
      Result:=Result+'<input name="typeofgetting" type="radio" id="getting1" value="1" checked title="Заказываемый товар будет зарезервирован для Вас на складе отгрузки"><label for="getting1"'+
      ' title="Заказываемый товар будет зарезервирован для Вас на складе отгрузки">Резерв </label>';
    end;
    Result:=Result+'<input name="typeofgetting" type="radio" id="getting2" value="2" title="Заказываемый товар будет собран для самовывоза к указанным дате и времени"><label for="getting2"'+
    ' title="Заказываемый товар будет собран для самовывоза к указанным дате и времени">Самовывоз</label> ';
    Result:=Result+'<input name="typeofgetting" type="radio" id="getting0" value="0" title="Заказываемый товар будет доставлен Вам с учетом Ваших пожеланий по способу и времени доставки"><label for="getting0" title="Заказываемый товар будет доставлен Вам с учетом'+
      ' Ваших пожеланий по способу и времени доставки">Доставка</label>';
    Result:=Result+'</fieldset>';

    Result:=Result+'<fieldset class="delivery-border" id="datetimediv_field">';
    Result:=Result+'<div name="datetimediv">';
    Result:=Result+'<table class="delivery-data-time-table"><tbody><tr>';
    Result:=Result+'<td>Дата: </td><td>';
    Result:=Result+'<select name="deliverydate" _oldvalue="" id="delivery-date-select" class="login-input"  onchange="checkWareOnStorage(); changeDataDelivery();" >';
    Result:=Result+'</select>';
    //Result:=Result+'<input opened="false" type="text" name="deliverydate" id="deliverydatespan" class="input-field" placeholder="Дата доставки" title="Выберите дату доставки">'#13#10;
    //Result:=Result+'<span class="arrow"></span>'#13#10;
    //Result:=Result+'<span class="magnifier" ></span> '#13#10;
    Result:=Result+'</td>';
    Result:=Result+'<td><span id="pickuptimespan"> Время: <select  id="pick-up-time-select" _OldTime="" class="login-input" name="pickuptime"  onchange="changeTimeDelivery(this);" >';
    //Result:=Result+'<td><span id="pickuptimespan"> Время: <select  id="pick-up-time-select" _OldTime="" class="login-input" name="pickuptime"  >';
    Result:=Result+'</select></span></td>'#13#10;
    if flMeetPerson then begin
      Result:=Result+'<td>';
      Result:=Result+'  <span id="meet-person-span"> Встречающий: ';
      Result:=Result+'  </span> ';
      Result:=Result+'</td>';
      Result:=Result+'<td>';
      Result:=Result+'    <select  id="meet-person-select" class="login-input" name="meet-person"  onchange="changeMeetPerson(this);" ></select>';
      Result:=Result+'    <a class="info tooltip" href="#" title=""></a>';
      Result:=Result+'</td>';
    end;
    prOnReadyScriptAdd('$("table.delivery-data-time-table a.info").tooltipster({'#13#10);
    prOnReadyScriptAdd('content: $("<div class=''tooltip-container-div''>'+ //<p>Звоните, наши специалисты:</p>
      ' <p  class=''motul-ul''>Поле обязательно к заполнению.</p>'+
      ' <p  class=''motul-ul''>Изменить или добавить контактные данные можно самостоятельно в </p>'+
      ' <p  class=''motul-ul''>разделе  “Настройки > Персональные данные”  или позвонив в </p>'+
      ' <p  class=''motul-ul''>Службу поддержки по тел. '+PhoneSupport+'. </p>'+
      '</div>")'#13#10);
    prOnReadyScriptAdd('});'#13#10);
    prOnReadyScriptAdd('$("table.delivery-data-time-table a.info").tooltipster();'#13#10);
    Result:=Result+'</tr>'#13#10;
    Result:=Result+'<tr><td><span id="ttCaption">Торговая точка:</span></td><td>';
    Result:=Result+'<select class="login-input" _oldvalue="" id="_tt-order-select" name="tt" _deliverykind="-1" _deliverytimeout="-1" _deliverytimein="-1" _shedulercode="-1" onChange="checkWareOnStorage(); changeTTDelivery(this);" >';
    Result:=Result+' </select></td><td></td>'#13#10;
    if flMeetPerson then
      Result:=Result+' <td></td><td></td>'#13#10;
    Result:=Result+' </tr>'#13#10;
    Result:=Result+'<tr><td></td>';
    Result:=Result+'<td align="left">';
    Result:=Result+'    <button class="notation-delivery-btn btn" disabled="disabled" id="showdeliveriesbtn" title="Показать доступные отправки" style=" font-color:#000000;"  onClick="clickDeliveryBtn(this); ">Выбрать расписание</button>';
    Result:=Result+' </td><td></td>';
    if flMeetPerson then
      Result:=Result+' <td></td><td></td>';
    Result:=Result+' </tr></tbody></table>'#13#10;
    Result:=Result+'</div>';
    Result:=Result+'<div id=deliverychoicediv>';
    Result:=Result+'  <div id=deliverydescribe style="width: 100%; height: 100px;">';
    Result:=Result+'    <span></span>';
    Result:=Result+'   <br>';
    Result:=Result+' <table class="table table-header" cellspacing="5" id="dopdatatable-delivery-header" style="font-size:14px;"><tbody>';
    Result:=Result+'<tr><td align="left">Время отгрузки со склада</td> <td align="left" >Способ доставки</td><td align=left" >Прибытие до:</td>';
    Result:=Result+'</tr>';
    Result:=Result+'<tr class="sheduler-data" >';
    Result:=Result+' <td> <span id="deliverytimeout"  style="color: #2F4F4F;font-weight:bold;"></span></td>';
    Result:=Result+' <td><span id="deliverykind" style="color: #2F4F4F;font-weight:bold;" ></span></td>';
    Result:=Result+' <td><span id="deliverytimein" style="color: #2F4F4F;font-weight:bold;" ></span> </td></tr>';
    Result:=Result+' </tbody></table>';
    Result:=Result+'  </div>';
    Result:=Result+'</div>';
    Result:=Result+'<div id="deliverychelpdeskdiv" style="display: block;"><span id=helpdesk ></span></div>';
    Result:=Result+'</fieldset>';
    Result:=Result+'<div id=warningwarestrdiv style="display: block;"><span id=warningwarestr style="color: #f0f;"></span></div>';
    Result:=Result+'<div id="warrantydiv">';
    Result:=Result+'№ доверенности: <input class="login-input" name=warrantnum id=warrantnum maxlength=12>&nbsp;';
    Result:=Result+'Дата доверенности: <input class="login-input" name=warrantdate size=10 ><br>';
    Result:=Result+'Через: <input class="login-input" name=warrantperson id=warrantperson maxlength=100 size=68><br>';
    Result:=Result+'</div>';
    Result:=Result+'<div id="deliverycommentdiv" style="display: block;">';
    Result:=Result+'Комментарий (можно ввести еще <span id=symleft>150</span> симв.): <br>';
    Result:=Result+'<textarea class="login-input" name=ordercomment id=ordercomment maxlength=150 style="width: 100%; " onChange="prcnioc(this);" onKeyUp="prcnioc(this);"></textarea>';   // переделать, чтобы обрабатывалось this
    Result:=Result+'<input type=submit style="display: none;">';
    Result:=Result+'</div>';
    Result:=Result+'</form></div>'; //fillheaderbeforeprocessingdiv
    Result:=Result+'       </div> '#13#10;
    Result:=Result+'<div class="text-right">'#13#10;
    Result:=Result+'<button class="btn blue-btn" style="top: 15px;margin-left: 20px;" onclick="if ( $(''#sendordermark'').val()!=''3'' ){ $(''#savemark'').val(''1''); jqswConfirmOrder(''Вы действительно хотите отправить заказ на обработку?''); }">Отправить заказ</button>'#13#10;
    Result:=Result+'<button class="btn blue-btn" style="top: 15px;margin-left: 20px;" onclick="if ($(''#sendordermark'').val()!=''3'' ){ $(''#savemark'').val(''0''); saveAllData();} ">Сохранить</button>'#13#10;
    Result:=Result+'<button class="btn white-btn info-close" style="top: 15px; margin-left: 20px;" onclick="$(''#delivery-info-tree'').addClass(''hide'');">Закрыть</button>'#13#10;
    Result:=Result+'</div>'#13#10;
    Result:=Result+'    </div> '#13#10;
    Result:=Result+' </section>'#13#10;
    Result:=Result+' <section id="sheduler-info-tree" class="general-info-tree popup-box hide">'#13#10;
    Result:=Result+'    <div class="info-tree-container" id="sheduler-info-container"> '#13#10;
    Result:=Result+'       <div class="info-tree-header"> '#13#10;
    Result:=Result+'          <h3 class="title">Выберите расписание</h3> '#13#10;
    Result:=Result+'          <button type="button" class="close"><span aria-hidden="true" >&times;</span></button> '#13#10;
    Result:=Result+'       </div> '#13#10;
    Result:=Result+'       <div class="info-tree-body" id="sheduler-info-body" >  '#13#10;
    Result:=Result+'       <div id="deliveryshedulerdiv_caption" >Добавить к заявке по расписанию</div>';
    Result:=Result+'          <table class="table table-header" cellspacing="5" id="sheduler-delivery-header" style="font-size:14px;"><tbody>';
    Result:=Result+'            <tr>'#13#10;
    Result:=Result+'              <td class="col" style="visibility: hidden; width: 2px;"></td>'#13#10;
    Result:=Result+'              <td class="col">Время отгрузки со склада</td>'#13#10;
    Result:=Result+'              <td class="col">Способ доставки</td>'#13#10;
    Result:=Result+'              <td class="col">Прибытие до:</td>'#13#10;
    Result:=Result+'            </tr>'#13#10;
    Result:=Result+'          </table>'#13#10;
    Result:=Result+'          <div id="deliveryshedulerdiv"  tt="-1" deliverydate="-1">';//див таблицы расписания
    Result:=Result+'             <table class="table table-body" id="deliveryshedulerdiv_table">'#13#10; //eliveryshedulerdiv_table
    Result:=Result+'             </table>'#13#10;//class="sheduler-data"
    Result:=Result+'<div id="deliverysheduler_viewall" >'+
    '<button class="btn blue-btn" id="showalldeliverybtn" title="Показать доступные отправки" Onclick="ShowAllSchedulerDelivery();">'+
    'Все расписания</button></div>';
    Result:=Result+'          </div>'#13#10;
    Result:=Result+'       </div> '#13#10;
    Result:=Result+'    </div> '#13#10;
    Result:=Result+' </section>'#13#10;
    Result:=Result+' <section id="general-info-tree" class="general-info-tree popup-box hide">'#13#10;
    Result:=Result+'    <div class="info-tree-container" id="info-tree-container"> '#13#10;
    Result:=Result+'       <div class="info-tree-header"> '#13#10;
    Result:=Result+'          <h3 class="title">Информация</h3> '#13#10;
    Result:=Result+'          <button type="button" class="close"><span aria-hidden="true" >&times;</span></button> '#13#10;
    Result:=Result+'       </div> '#13#10;
    Result:=Result+'       <div class="info-tree-body" id="info-tree-body" >  '#13#10;
//    Result:=Result+'          <div id="info-tree-tabs" class="info-tree-tabs"> '#13#10;
//    Result:=Result+'          </div> '#13#10;
    Result:=Result+'       </div> '#13#10;
    Result:=Result+'    </div> '#13#10;
    Result:=Result+' </section>'#13#10;
    if flMotulTree then begin
      Result:=Result+' <section id="motul-podbor-tree" class="general-info-tree popup-box hide">'#13#10;
      Result:=Result+'    <div class="podbor-motul-tree-container" id="motul-podbor-container"> '#13#10;
      Result:=Result+'       <div class="info-tree-header"> '#13#10;
      Result:=Result+'          <h3 class="title">Подбор Motul</h3> '#13#10;
      Result:=Result+'          <button type="button" class="close"><span aria-hidden="true" >&times;</span></button> '#13#10;
      Result:=Result+'       </div> '#13#10;
      Result:=Result+'       <div class="motul-podbor-body" id="motul-podbor-body" >  '#13#10;
      Result:=Result+'         <div id="motul-model-header-div" class="selectpartsdivheader" style="display: block;">'#13#10;
      Result:=Result+'           <button class="white-btn btn" onclick="$(''#motul-podbor-tree'').addClass(''hide''); $(''#popup-search-tree'').removeClass(''hide'');" title="К дереву узлов">Назад</button>'#13#10;
      Result:=Result+'           <span id="motul-model-header-title" class="grayline" style="height: 32px;">Модель -'#13#10;
      Result:=Result+'           </span>'#13#10;
      Result:=Result+'           <a class="ware-info-name-span" id="motul-model-header-text" style="height: 32px;">'#13#10;
      Result:=Result+'           </a>'#13#10;
      Result:=Result+'        </div> '#13#10;
      Result:=Result+'         <div id="motul-model-icon-div" class="" style="display: block;">'#13#10;
      Result:=Result+'           <ul class="motul-podbor-list-icon" id="motul-podbor-list-icon">'#13#10;
      Result:=Result+'           </ul>'#13#10;
      Result:=Result+'        </div> '#13#10;
      Result:=Result+'        <div id="motul-podbor-tree" class="" style="display: block;">'#13#10;
      Result:=Result+'          <table  id="motul-podbor-table-header" class="table">'#13#10;
      Result:=Result+'          </table>'#13#10;
      Result:=Result+'          <div class="" id="motul-podbor-table-body-wrap" data-mcs-theme="inset-dark"> '#13#10;
      Result:=Result+'            <table class="table table-body" id="motul-podbor-table-body">'#13#10;
      Result:=Result+'            </table>'#13#10;
      Result:=Result+'          </div> '#13#10;
      Result:=Result+'       </div> '#13#10;
      Result:=Result+'    </div> '#13#10;
      Result:=Result+'  </div> '#13#10;
      Result:=Result+' </section>'#13#10;
    end;
    Result:=Result+' <section id="animation" class="animation popup-box hide">'#13#10;
    Result:=Result+'    <div id="animation-container"> '#13#10;
    Result:=Result+' <img src="/images/svg/spin.svg" ondblclick="$(''#animation'').addClass(''hide'');" alt="dowloadd"> '#13#10;
    Result:=Result+'    </div> '#13#10;
    Result:=Result+' </section>'#13#10;
    Result:=Result+' <section id="popup-calendar" class="popup-calendar popup-box hide">'#13#10;
    Result:=Result+'   <div class="popup-calendar-container" id="popup-calendar-container">'#13#10;
    Result:=Result+'     <div class="popup-calendar-header"> '#13#10;
    Result:=Result+'       <h3 class="title">Фильтр заказов</h3>'#13#10;
    Result:=Result+'       <button type="button" class="close"><span aria-hidden="true" >&times;</span></button>'#13#10;
    Result:=Result+'     </div>'#13#10;
    Result:=Result+'     <div class="popup-calendar-body" id="popup-calendar-body" > '#13#10;
    Result:=Result+'       <h3 class="title">Показать заказы со статусами:</h3>'#13#10;
    Result:=Result+'       <div class="col">'#13#10;
    Result:=Result+'         <div class="checkbox-wrap">'#13#10;
    Result:=Result+'           <input type="checkbox" name="cbForming" id="cbForming" >'#13#10;
    Result:=Result+'           <label for="cbForming"></label>'#13#10;
    Result:=Result+'           <span>Формируется</span>'#13#10;
    Result:=Result+'         </div>'#13#10;
    Result:=Result+'         <div class="checkbox-wrap">'#13#10;
    Result:=Result+'           <input type="checkbox" name="cbProcessing" id="cbProcessing" >'#13#10;
    Result:=Result+'           <label for="cbProcessing"></label> '#13#10;
    Result:=Result+'           <span>На обработке</span>'#13#10;
    Result:=Result+'         </div>'#13#10;
    Result:=Result+'         <div class="checkbox-wrap">'#13#10;
    Result:=Result+'           <input type="checkbox" name="cbAccepted" id="cbAccepted">'#13#10;
    Result:=Result+'           <label for="cbAccepted"></label>'#13#10;
    Result:=Result+'           <span>Принят</span>'#13#10;
    Result:=Result+'         </div>'#13#10;
    Result:=Result+'       </div>'#13#10;
    Result:=Result+'       <div class=" col">'#13#10;
    Result:=Result+'         <div class="checkbox-wrap">'#13#10;
    Result:=Result+'           <input type="checkbox" name="cbClosed" id="cbClosed" >'#13#10;
    Result:=Result+'           <label for="cbClosed"></label>'#13#10;
    Result:=Result+'           <span>Закрыт</span>'#13#10;
    Result:=Result+'         </div>'#13#10;
    Result:=Result+'         <div class="checkbox-wrap">'#13#10;
    Result:=Result+'           <input type="checkbox" name="cbAnulated" id="cbAnulated" >'#13#10;
    Result:=Result+'           <label for="cbAnulated"></label>'#13#10;
    Result:=Result+'           <span>Аннулирован</span>'#13#10;
    Result:=Result+'         </div>'#13#10;
    Result:=Result+'         <div class="checkbox-wrap">'#13#10;
    Result:=Result+'           <input onclick="sfcaa(this.checked);" type="checkbox" name="cbAll" id="cbAll">'#13#10;
    Result:=Result+'           <label for="cbAll"></label>'#13#10;
    Result:=Result+'           <span>Все</span>'#13#10;
    Result:=Result+'         </div>'#13#10;
    Result:=Result+'       </div>'#13#10;
    Result:=Result+'       <span>За период:</span>'#13#10;
    Result:=Result+'       <div>'#13#10;
    Result:=Result+'         <div class="input-group date" id="popup-datepicker-from">'#13#10;
    Result:=Result+'           <span class="input-group-addon txt" id="basic-addon1">c</span>'#13#10;
    Result:=Result+'           <input type="text" id="dataFrom" name="dataFrom" class="form-control"><span class="input-group-addon input-img"></span>'#13#10;
    Result:=Result+'         </div>'#13#10;
    Result:=Result+'         <div class="input-group date" id="popup-datepicker-to">'#13#10;
    Result:=Result+'           <span class="input-group-addon txt" id="basic-addon1">по</span>'#13#10;
    Result:=Result+'           <input type="text" id="dataTo" name="dataTo" class="form-control"><span class="input-group-addon input-img"></span>'#13#10;
    Result:=Result+'         </div>'#13#10;
    Result:=Result+'       </div>'#13#10;
    Result:=Result+'       <div class="text-right">'#13#10;
    Result:=Result+'         <a href="#" class="apply-btn btn"  onclick="sof();">Применить</a>'#13#10;
    Result:=Result+'       </div>'#13#10;
    Result:=Result+'     </div>'#13#10;
    Result:=Result+'   </div>'#13#10;
    Result:=Result+' </section>'#13#10;
    if (((userInf.PageName='users') or (userInf.PageName='options')) and (userInf.Supervisor)) then begin  // vc +++
      Result:=Result+'  <section id="popup-newcontactpersonorder" class="popup-box hide">'#13#10;
      Result:=Result+'    <div class="popup-container">'#13#10;
      Result:=Result+'        <div class="popup-header">'#13#10;
      Result:=Result+'          <h3 class="title">Заявка на добавление сотрудника</h3>'#13#10;
      Result:=Result+'          <button type="button" class="close"><span aria-hidden="true" >&times;</span></button>'#13#10;
      Result:=Result+'        </div>'#13#10;
      Result:=Result+'        <div class="popup-body" id="popup-calendar-body" >'#13#10;
      Result:=Result+'          <form onsubmit="return sendorderfornewcontactadd(this);">'; // id=newcontactpersonorderdiv
      Result:=Result+'            <input type=hidden name=act value="sendorderfornewcontactadd">';
      Result:=Result+'            <table>';
      Result:=Result+'              <tr><td>ФИО</td><td><input class=svkinput type=text name=fio></td></tr>';
      Result:=Result+'              <tr><td>Должность</td><td><input class=svkinput type=text name=post></td></tr>';
      Result:=Result+'              <tr><td>Телефоны</td><td><textarea class=svkinput name=phones></textarea></td></tr>';
      Result:=Result+'              <tr><td>E-mail</td><td><textarea class=svkinput name=email></textarea></td></tr>';
      Result:=Result+'            </table>';
      Result:=Result+'          </form>'; //newcontactpersonorderdiv
      Result:=Result+'        </div>'#13#10; // body
      Result:=Result+'        <div class="popup-buttons">'#13#10; // buttons
      Result:=Result+'          <button class="btn blue-btn" title="Отправить заявку" onclick="$(''#popup-newcontactpersonorder'').addClass(''hide''); '+
      '$(''#popup-newcontactpersonorder form'').submit();">Отправить</button>'#13#10;
      Result:=Result+'          <button class="btn white-btn" title="Закрыть окно" onclick="$(''#popup-newcontactpersonorder'').addClass(''hide'');">Закрыть</button>'#13#10;
      Result:=Result+'        </div>'#13#10; // buttons
      Result:=Result+'      </div>'#13#10; // container
      Result:=Result+'  </section>'#13#10;
    end; // vc ---

    Result:=Result+' <section id="search-result" lastwaresearch="" class="search-result hide ">'#13#10;//секция поиска
    Result:=Result+'  <div class="search-container">'#13#10;
    Result:=Result+'    <div class="search-header">'#13#10;
    Result:=Result+'      <button type="button" class="close"><span aria-hidden="true" >&times;</span></button>'#13#10;
    Result:=Result+'      <div class="search-title">'#13#10;
    Result:=Result+'         <span class="title">Результат подбора товара по: </span>'#13#10;
    Result:=Result+'         <span id="search-title-search-str" class="name"></span>'#13#10;
    Result:=Result+'      </div>'#13#10;
    Result:=Result+'      <div class="search-header-table">'#13#10;
    Result:=Result+'        <table class="table">'#13#10;
    Result:=Result+'          <tr>'#13#10;
    Result:=Result+'            <td>'#13#10;
    Result:=Result+'              <button title="Отметьте два или более товара для сравнения" onclick="warecompare(this);" id="compare-btn" class="compare-btn">Сравнить</button>'#13#10;
    Result:=Result+'            </td>'#13#10;
    Result:=Result+'            <td class="col before-sort-select">Сортировать</td>'#13#10;
    Result:=Result+'            <td class="col-sort-select">'#13#10;
    Result:=Result+'                <select name="sort" id="table-sort" class="login-input">'#13#10;
    Result:=Result+'                  <option disabled selected>По умолчанию</option>'#13#10;
    Result:=Result+'                  <option value="name">По наименованию</option>'#13#10;
    Result:=Result+'                  <option value="decs">По убыванию цены</option>'#13#10;
    Result:=Result+'                  <option value="asc">По возрастанию цены</option>'#13#10;
    Result:=Result+'                </select>'#13#10;
    Result:=Result+'            </td>'#13#10;
    Result:=Result+'            <td class="col">'#13#10;
    Result:=Result+'              <button type="button" name="button" class="slider-btn left show-retail"></button>'#13#10;
    Result:=Result+'                <span class="cost retail">Розн., грн</span>'#13#10;
    Result:=Result+'                <span class="cost wholesale hide">Вход., грн</span>'#13#10;
    Result:=Result+'              <button type="button" name="button" class="slider-btn right show-wholesale"></button>'#13#10;
    Result:=Result+'            </td>'#13#10;
    Result:=Result+'            <td class="col">'#13#10;
    Result:=Result+'              <span>Единица</span>'#13#10;
    Result:=Result+'            </td>'#13#10;
    Result:=Result+'            <td class="col">'#13#10;
    Result:=Result+'              <span>Количество</span>'#13#10;
    Result:=Result+'            </td>'#13#10;
    Result:=Result+'            <td class="col">'#13#10;
    Result:=Result+'            </td>'#13#10;
    Result:=Result+'            <td class="col">'#13#10;
    Result:=Result+'            </td>'#13#10;
    Result:=Result+'          </tr>'#13#10;
    Result:=Result+'        </table>'#13#10;
    Result:=Result+'      </div>'#13#10;
    Result:=Result+'    </div>'#13#10;
    Result:=Result+'    <div class="search-body" id="search-body" data-mcs-theme="inset-dark">'#13#10;
    Result:=Result+'      <table class="table" id="search-table">'#13#10;
    Result:=Result+'      </table>'#13#10;
    Result:=Result+'    </div>'#13#10;
    Result:=Result+'  </div><!-- search-container -->'#13#10;
    Result:=Result+' </section>'#13#10;//поиск
    Result:=Result+'<!-- Modal -->'#13#10;
    Result:=Result+'<div id="myModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">'#13#10;
    Result:=Result+'  <div class="modal-header">'#13#10;
    Result:=Result+'    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>'#13#10;
    Result:=Result+'    <h3 id="myModalLabel">Modal header</h3>'#13#10;
    Result:=Result+'  </div>'#13#10;
    Result:=Result+'  <div class="modal-body">'#13#10;
    Result:=Result+'    <p>One fine body…</p>'#13#10;
    Result:=Result+'  </div>'#13#10;
    Result:=Result+'  <div class="modal-footer">'#13#10;
    Result:=Result+'    <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>'#13#10;
    Result:=Result+'    <button class="btn btn-primary">Save changes</button>'#13#10;
    Result:=Result+'  </div>'#13#10;
    Result:=Result+'</div>'#13#10;
    Result:=Result+fngetPodborWindow(userInf,userInf.ShowNewAttr);
  end else begin
    Result:=Result+'<header class="main-header">'#13#10;
    Result:=Result+'      <nav class="header-top">'#13#10;
    Result:=Result+'        <div class="row">'#13#10;
    Result:=Result+'          <div class="col-xs-5"> '#13#10;
    if userInf.flTest then begin
      Result:=Result+'<div class="test-div-header" >Тестирование </div>'#13#10;
    end
    else begin
      Result:=Result+'            <a href="http://www.vladislav.ua/"> '#13#10;
      Result:=Result+'              <img src="/images/header-logo.png" alt="header-logo">'#13#10;
      Result:=Result+'            </a> '#13#10;
    end;
    Result:=Result+'          </div>'#13#10;
    Result:=Result+'        </div>'#13#10;
    Result:=Result+'      </nav>'#13#10;
    Result:=Result+'</header>'#13#10;
    Result:=Result+' <section id="animation" class="animation popup-box hide">'#13#10;
    Result:=Result+'    <div id="animation-container"> '#13#10;
    Result:=Result+' <img src="/images/svg/spin.svg" ondblclick="$(''#animation'').addClass(''hide'');" alt="dowloadd"> '#13#10;
    Result:=Result+'    </div> '#13#10;
    Result:=Result+' </section>'#13#10;
    if userInf.Pagename<>'registr' then
      Result:=Result+fnAutenticationFormRedisign(userInf);
  end;



  //Result:=Result+'<div id=maindiv>'#13#10;

   // Для найденного товара
  Result:=Result+'<div id="viewsearchingwarediv" data-mcs-theme="inset-dark" _oldcodeproduct="-1" _model="-1" _node="-1"></div>'#13#10;    //окно вывода описания товара при поиске
  prOnReadyScriptAdd('  $("#viewsearchingwarediv").dialog({'#13#10);
  prOnReadyScriptAdd('        autoOpen: false,'#13#10);
  prOnReadyScriptAdd('        show: ''fade'','#13#10);
  prOnReadyScriptAdd('        heigth: ''auto'','#13#10);
  prOnReadyScriptAdd('        draggable: true,'#13#10);
  prOnReadyScriptAdd('        modal: true,'#13#10);
  prOnReadyScriptAdd('        hide: ''fade'','#13#10);
  prOnReadyScriptAdd('        position: ''top'','#13#10);
  prOnReadyScriptAdd('        width: 900,'#13#10);
  //prOnReadyScriptAdd('        left: 50%,'#13#10);
  prOnReadyScriptAdd('        title: "Описание товара", '#13#10);
  //prOnReadyScriptAdd('        beforeClose: clearAllInput,'#13#10);
  prOnReadyScriptAdd('      });'#13#10);

  // Для дворников
  Result:=Result+'<div id="viewdvornikdiv" _oldcodeproduct="-1" _model="-1" _node="-1"></div>'#13#10;    //окно вывода описания товара при поиске
  prOnReadyScriptAdd('  $("#viewdvornikdiv").dialog({'#13#10);
  prOnReadyScriptAdd('        autoOpen: false,'#13#10);
  prOnReadyScriptAdd('        show: ''fade'','#13#10);
  prOnReadyScriptAdd('        heigth: ''auto'','#13#10);
  prOnReadyScriptAdd('        draggable: true,'#13#10);
  prOnReadyScriptAdd('        modal: true,'#13#10);
  prOnReadyScriptAdd('        hide: ''fade'','#13#10);
  prOnReadyScriptAdd('        position: ''top'','#13#10);
  prOnReadyScriptAdd('        width: 900,'#13#10);
  //prOnReadyScriptAdd('        left: 50%,'#13#10);
  prOnReadyScriptAdd('        title: "Перечень дворников", '#13#10);
  //prOnReadyScriptAdd('        beforeClose: clearAllInput,'#13#10);
  prOnReadyScriptAdd('      });'#13#10);

  prOnReadyScriptAdd('  $("#bjauthdiv").dialog({'#13#10);
  prOnReadyScriptAdd('        autoOpen: false,'#13#10);
  prOnReadyScriptAdd('        position: ''center'','#13#10);
  prOnReadyScriptAdd('        width: 500,'#13#10);
  //prOnReadyScriptAdd('        left: 50%,'#13#10);
  prOnReadyScriptAdd('        title: "Авторизация", '#13#10);
  //prOnReadyScriptAdd('        beforeClose: clearAllInput,'#13#10);
  prOnReadyScriptAdd('      });'#13#10);

  if userInf.flUber then begin
    if userInf.IsUberClient then begin
      //prOnReadyScriptAdd('$(".navigation-list a.gifts").css("visibility","hidden");'#13#10);
      //prOnReadyScriptAdd('$(".navigation-list a.chart").css("visibility","hidden");'#13#10);
    end
    else begin
      prOnReadyScriptAdd('$(".navigation-list a.gifts").css("visibility","visible");'#13#10);
      //prOnReadyScriptAdd('$(".navigation-list a.chart").css("visibility","visible");'#13#10);
    end;
  end;
end;



procedure prGeneralNewSystemProcOrder(Stream: TBoBMemoryStream; ThreadData: TThreadData);
 var
  StreamNew: TBoBMemoryStream;
  s,s1, ErrorPos, sid,nmProc,Result: string;
  i,Res,Position,filesize,AnalogCount,Sys: integer;
  curUserInfo:TUserInfo;
  v,j,kindSave:integer;
  oldShedulercode,OrderCode,ExcelFileName:String;
  flag:boolean;
  Template: string;
  IgnoreSpec: byte;
  Top10Cookie:String;
  CurOrderQty,TotalOrderQty:double;
  Data: TDate;
  Variants: Tas;
begin
  Stream.Position:= 0;
  try
   curUserInfo.Short := false;
   curUserInfo.ResetPassword:= false;
   curUserInfo.UserLogin:= '';
   curUserInfo.UserPass := '';
   curUserInfo.SessionID:= '';
   curUserInfo.FirmName:= '';
   curUserInfo.PrsnEmail:= '';
   curUserInfo.SuperVisor:= false;
   curUserInfo.riSendOrder:= false;
   curUserInfo.riViewOwnPrice:= false;
   curUserInfo.riViewDiscountTable:= false;
   curUserInfo.ContractsCount:= 0;
   curUserInfo.ContractName:= '';
   curUserInfo.LegalFirmName:='';
   curUserInfo.StoreName:= '';
   curUserInfo.square_height:=108;
   curUserInfo.DrawVinButton:= false;
   curUserInfo.FullData:=true;
   curUserInfo.ActionText:= '';
   curUserInfo.FastMessage:='';
    curUserInfo.strPost:=TStringList.Create;
    curUserInfo.strGet:=TStringList.Create;
    curUserInfo.strCookie:=TStringList.Create;
    curUserInfo.strOther:=TStringList.Create;
    curUserInfo.strPost.Text:=Stream.ReadStr;
    curUserInfo.strGet.Text:=Stream.ReadStr;
    curUserInfo.strCookie.Text:=Stream.ReadStr;
    curUserInfo.strOther.Text:=Stream.ReadStr;
    curUserInfo.ScriptName:=curUserInfo.strOther.Values['scriptname'];
    curUserInfo.PageName:=curUserInfo.strOther.Values['pagename'];
    curUserInfo.TitleStr:= 'Компания Владислав. Система online-заказов';
    curUserInfo.IP:=curUserInfo.strOther.Values['ip'];
    if FileExists('.\'+'server.ini') then begin
      IniFile:=TINIFile.Create('.\'+'server.ini');
    end else begin
      raise Exception.Create('Не найден ini-файл');
    end;
    curUserInfo.DescrDir:=IniFile.ReadString('Options', 'DescrDir', '..\orders\www');
    curUserInfo.BaseDir:=IniFile.ReadString('Options', 'BaseDir', '');
    curUserInfo.BaseUrl:='';
    curUserInfo.DescrUrl:=IniFile.ReadString('Options', 'DescrUrl', 'http://order.vladislav.ua/app/orders.cgi');
    curUserInfo.DescrImageUrl:=IniFile.ReadString('Options', 'DescrImageUrl', 'http://order.vladislav.ua');
    curUserInfo.BlockedIP:=IniFile.ReadString('Options', 'BlockedIP', '');
    curUserInfo.TechWork:=IniFile.ReadString('Options', 'TechWorkText', 'UrMessage.html');
    curUserInfo.FastMessage:=IniFile.ReadString('Options', 'FastMessageText', 'techwork.html');  //для показа срочного сообщения в шапке
    curUserInfo.OuterCssPatch:=IniFile.ReadString('Options', 'OuterCssPatch', curUserInfo.DescrImageUrl+'/css/outer.css');
    curUserInfo.OuterJSPatch:=IniFile.ReadString('Options', 'OuterJSPatch', curUserInfo.DescrImageUrl+'/js/outer.js');
    curUserInfo.PhoneClientCentr:= IniFile.ReadString('Options', 'PhoneClientCentr', '0-800-30-15-15'); //обслуживание клиентов
    curUserInfo.PhoneSupport:= IniFile.ReadString('Options', 'PhoneSupport', '0-800-30-20-02'); //служба поддержки
    if FileExists('.\InfoFiles\'+curUserInfo.FastMessage) then begin
     curUserInfo.flFastMessage:=true;
    end;
    if FileExists('.\'+curUserInfo.TechWork) then begin
     curUserInfo.flTechWork:=true;
     Result:=nonAutenticatedMessage(not curUserInfo.FullData, not curUserInfo.FullData);
    end
    else begin
      if  Pos(';'+curUserInfo.IP+';', curUserInfo.BlockedIP)>0  then begin
        raise Exception.Create('');
      end;
    end;

     //----------------------флаги
    curUserInfo.flRedesign:= IniFile.ReadInteger('Options', 'flRedesign', 0)=1;
    curUserInfo.flUber:= IniFile.ReadInteger('Options', 'flUber', 0)=1;   // флаг запуска работы с UBER
    curUserInfo.flCV:= IniFile.ReadInteger('Laximo', 'flCV', 0)=1; //vv
    curUserInfo.flInitMedia:=IniFile.ReadInteger('Options', 'flInitMedia', 0)=1;   // флаг запуска работы с UBER
    curUserInfo.flInitMediaUber:=IniFile.ReadInteger('Options', 'flInitMediaUber', 0)=1;   // флаг запуска работы с UBER
    curUserInfo.flTest:= IniFile.ReadInteger('Options', 'flTest', 0)=1;   // флаг запуска работы с UBER
     //----------------------флаги
    StreamNew:=TBoBMemoryStream.Create;
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // начинаем аутентикацию
ErrorPos:='0';
   try
     sid:=curUserInfo.strCookie.Values['sid'];
   except
     s:=StringReplace(curUserInfo.strCookie.Text, '; ', #13#10, [rfReplaceAll]);
     s:=StringReplace(s, '%7C', '|', [rfReplaceAll]);
     s:=StringReplace(s, '%2C', ',', [rfReplaceAll]);
     curUserInfo.strCookie.Text:=s;
     sid:=curUserInfo.strCookie.Values['sid'];
   end;
ErrorPos:='00';
   sid:=trim(sid);

   ErrorPos:='0-0-1';
   if (((trim(curUserInfo.strCookie.Values['psw'])<>'') and (trim(curUserInfo.strCookie.Values['lgn'])<>'')) or (sid<>'') or (curUserInfo.PageName='wareinfo')) then begin
ErrorPos:='0-1';
  //  if false then begin
      StreamNew.Clear;
ErrorPos:='0-1-1';
      StreamNew.WriteStr(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'psw')));
ErrorPos:='0-2';
      StreamNew.WriteStr(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'lgn')));
ErrorPos:='0-3';
      StreamNew.WriteStr(sid);
ErrorPos:='0-4';
      StreamNew.WriteStr(curUserInfo.IP);
ErrorPos:='0-5';
      StreamNew.WriteStr(curUserInfo.strOther.Values['agent']);
ErrorPos:='0-6';
      StreamNew.WriteByte(byte(StrToBool(curUserInfo.strOther.Values['fulldata'])));
ErrorPos:='0-7';
      StreamNew.WriteInt(StrToIntDef(curUserInfo.strOther.Values['contractid'], 0));
      curUserInfo.FirstEnter:=trim(curUserInfo.strCookie.Values['firstenter'])<>'';
ErrorPos:='1';
      prAutenticateOrd(StreamNew,ThreadData);
      Res:=StreamNew.ReadInt;
      if Res=aeSuccess then begin
        Result:='';
        curUserInfo.UserID:=IntToStr(StreamNew.ReadInt);
        curUserInfo.UserLogin:=StreamNew.ReadStr;
        curUserInfo.UserPass:=StreamNew.ReadStr;
        curUserInfo.FirmID:=IntToStr(StreamNew.ReadInt);
  //        UserLogin:=StreamNew.ReadStr;
        curUserInfo.SessionID:=StreamNew.ReadStr;
        curUserInfo.ResetPassword:=Boolean(StreamNew.ReadByte);
        curUserInfo.Autenticated:=not curUserInfo.ResetPassword;
ErrorPos:='2';
        Result:=Result+'<script>'#13#10;
        Result:=Result+'setCookie_("sid", "'+curUserInfo.SessionID+'", getExpDate_(3650,0,0),"/",0,0);'#13#10;
{ TODO : Это время нужно убрать нафиг. Куки вечны }
        StreamNew.ReadInt; // время существования куков
        curUserInfo.FirmName:=GetJSSafeStringArgMonoQuote(StreamNew.ReadStr);
        curUserInfo.UserName:=Copy(curUserInfo.FirmName,0,Pos(',',curUserInfo.FirmName)-1);
        curUserInfo.FirmName:=trim(Copy(curUserInfo.FirmName,Pos(',',curUserInfo.FirmName)+1,Length(curUserInfo.FirmName)));
        curUserInfo.PrsnEmail:=StreamNew.ReadStr;
        curUserInfo.SuperVisor:=boolean(StreamNew.ReadByte);
ErrorPos:='3';
        if not curUserInfo.SuperVisor then begin
          curUserInfo.riSendOrder:=boolean(StreamNew.ReadByte);
          curUserInfo.riViewOwnPrice:=boolean(StreamNew.ReadByte);
          curUserInfo.riViewDiscountTable:=boolean(StreamNew.ReadByte);
        end;
        curUserInfo.ContractId:=StreamNew.ReadInt;
ErrorPos:='4';
        if (StrToBool(curUserInfo.strOther.Values['fulldata'])) then begin
          curUserInfo.CredLimit:=StreamNew.ReadDouble;
          curUserInfo.Debt:=StreamNew.ReadDouble;
          curUserInfo.OrderSum:=StreamNew.ReadDouble;
          curUserInfo.ResLimit:=StreamNew.ReadDouble;
          curUserInfo.ResLimitRest:=StreamNew.ReadDouble; // пересчет в валюту Contract.CredCurrency  ???
              // ResLimit<0 - ничего не делаем, >=0 дописываем к резерву через /,
              // в подсказке на этой цифре "Лимит резерва (остаток - ResLimitRest)"

          curUserInfo.PlanOutSum:=StreamNew.ReadDouble;

          curUserInfo.CredCurrencyCode:=StreamNew.ReadInt;
          curUserInfo.CredCurrency:=StreamNew.ReadStr;
          curUserInfo.WarningMessage:=GetHTMLSafeString(StreamNew.ReadStr);
          curUserInfo.SaleBlock:=StreamNew.ReadBool;
          curUserInfo.CredDelay:=StreamNew.ReadInt;
          if not curUserInfo.SaleBlock then begin
            curUserInfo.WhenBlocked:=StreamNew.ReadInt;
          end;
          curUserInfo.DrawVinButton:=StreamNew.ReadBool;
          curUserInfo.ActionText:=StreamNew.ReadStr;
          curUserInfo.Curs:=StreamNew.ReadDouble;
          curUserInfo.CursBonus:=StreamNew.ReadDouble;
          curUserInfo.BonusQty:=StreamNew.ReadDouble;
          curUserInfo.ContractsCount:=StreamNew.ReadInt;
          curUserInfo.ContractName:=StreamNew.ReadStr;
          curUserInfo.LegalFirmName:=StreamNew.ReadStr;
          curUserInfo.StoreName:=StreamNew.ReadStr;
          curUserInfo.ballsName:=StreamNew.ReadStr;
          curUserInfo.contBonusOrd:=StreamNew.ReadInt;
          curUserInfo.contBonusReserv:=StreamNew.ReadDouble;
          curUserInfo.DirectParams:=StreamNew.ReadInt;   // Кол-во направлений
          Result:=Result+'BallsName="'+curUserInfo.ballsName+'";'#13#10;
          Result:=Result+'InitMediaFlag='+BoolToStr(curUserInfo.flInitMedia)+';'#13#10;
          Result:=Result+'InitMediaFlagUber='+BoolToStr(curUserInfo.flInitMediaUber)+';'#13#10;
          for i:=0 to curUserInfo.DirectParams-1 do begin
            curUserInfo.DirectName:=StreamNew.ReadStr;   // название направления
            curUserInfo.LevelCount:=StreamNew.ReadInt;  // Кол-во уровней
            curUserInfo.FirmModel_Rating:=StreamNew.ReadInt; // Текущий уровень
            curUserInfo.FirmModel_Sales:=StreamNew.ReadInt; // Показатель оборота текущего уровня
            curUserInfo.NextModel_Rating:=StreamNew.ReadInt;// Уровень, до которого к/а не дотягивает по обороту текущего месяца
            curUserInfo.NextModel_Sales:=StreamNew.ReadInt;// Показатель оборота уровня, до которого к/а не дотягивает
            curUserInfo.ProcToNext:=StreamNew.ReadInt;// Процент участка шкалы, которого не хватает до уровня, до которого к/а не дотягивает
            curUserInfo.FirmSales:=StreamNew.ReadInt;// Показатель текущего оборота к/а
            Result:=Result+'arrRateCol['+IntToStr(i)+'] = new Array('''+curUserInfo.DirectName+''', '+IntToStr(curUserInfo.LevelCount-1)+', '+IntToStr(curUserInfo.FirmModel_Rating)+
            ','+IntToStr(curUserInfo.FirmModel_Sales)+','+IntToStr(curUserInfo.NextModel_Rating)+','+IntToStr(curUserInfo.NextModel_Sales)+
            ','+IntToStr(curUserInfo.ProcToNext)+','+IntToStr(curUserInfo.FirmSales)+');'#13#10;
          end;
          curUserInfo.ShowNewAttr:=StreamNew.ReadBool;
          if curUserInfo.DirectParams>0 then begin
            Result:=Result+'checkColection.showrate=1; '#13#10;
            if curUserInfo.flRedesign  then begin
              //Новый эквалайзер
            end
            else
              Result:=Result+'showhiderate2(30,100);'#13#10;
          end;
          Result:=Result+'</script>'#13#10;
        end;

ErrorPos:='5';
          curUserInfo.ServerTime:=StreamNew.ReadDouble;
          curUserInfo.FirmCode:=StreamNew.ReadStr;
          curUserInfo.IsUberClient:=boolean(StreamNew.ReadByte);
          s:='';
          i:=StreamNew.ReadInt;
          while (i>0) do begin
            Dec(i);
            if (s<>'') then begin
              s:=s+','
            end;
            s:=s+IntToStr(StreamNew.ReadInt);
          end;
ErrorPos:='6';
ErrorPos:='7';
          if (trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet, 'psw'))<>'') then begin
{TODO разобраться, нафига тут это условие и нафига этот сид...  был}
           Result:=Result+'setCookie_("sid", "'+s+'", getExpDate_(3650,0,0),"/",0,0);';
          end;
          // завершаем аутентикацию


          if (curUserInfo.strOther.Values['act']='getfile') then begin
            nmProc := 'getfile'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));

            if fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'doc_type')='price' then begin
              nmProc := 'prDownloadPrice'; // имя процедуры/функции
              StreamNew.WriteInt(curUserInfo.ContractId);
              StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'version'),0));
              prDownloadPrice(StreamNew, ThreadData);
            end;
            if fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'doc_type')='invoice' then begin
              nmProc := 'prGetOutInvoiceXml'; // имя процедуры/функции
              StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'doc_id'));
              prGetOutInvoiceXml(StreamNew, ThreadData);
            end;
            if fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'doc_type')='bankaccountfile' then begin
              nmProc := 'prGetBankAccountFile'; // имя процедуры/функции
              StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'baccid'),0));
              prGetBankAccountFile(StreamNew, ThreadData);
            end;
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              StreamNew.Position:=0;
              StreamNew.WriteInt(aeSuccessFile);
              StreamNew.Position:=0;
              Stream.CopyFrom(StreamNew, StreamNew.Size);
            end
            else begin
              setErrorCommand(StreamNew,Stream);
             end;
          end

          else if (curUserInfo.strOther.Values['act']='getlistopenorders') then begin
            nmProc := 'prGetFormingOrdersList'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            prGetFormingOrdersList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              //if flRedesign then
                Stream.WriteStr(fnOpenOrdersListRedisign(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordrcode'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'warecode'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'wareqty'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'inline_'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'dialogname')))
              //else
              //  Stream.WriteStr(fnOpenOrdersList(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordrcode'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'warecode'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'wareqty'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'inline_'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'dialogname')));
            end
            else begin
              setErrorCommand(StreamNew,Stream);
             end;
          end


          else if (curUserInfo.strOther.Values['act']='getlistopenordersformcheckqty') then begin
            nmProc := 'prGetFormingOrdersList'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            prGetFormingOrdersList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              (*AnalogCount:=0;
              for i:=3 to Request.ContentFields.Count-1 do begin
                CurOrderQty:=abs(StrToFloatDef(Request.ContentFields.Values[Request.ContentFields.Names[i]], 0));
                if (CurOrderQty>constDeltaZero) then begin
                  Stream.WriteStr(Request.ContentFields.Names[i]); // код аналога
                  Stream.WriteDouble(CurOrderQty);                 // а это его кол-во
                  TotalOrderQty:=TotalOrderQty+CurOrderQty;
                  Inc(AnalogCount);
                end;
              end;
              if (TotalOrderQty<constDeltaZero) then begin
                setErrorCommandStr(Stream,'Для добавления товаров в заказ нужно ввести кол-во хотя бы в одно поле ввода');
              end;
              Stream.Position:=12;
              Stream.WriteInt((AnalogCount)); // кол-во аналогов*)
              Stream.WriteStr(fnOpenOrdersListQtyRedisign(StreamNew,curUserInfo.strPost,curUserInfo.strGet))
            end
            else begin
              setErrorCommand(StreamNew,Stream);
             end;
          end



          else if (curUserInfo.strOther.Values['act']='moveincurrentorder') then begin
            nmProc := 'moveincurrentorder'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'),0));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr'));  // код заказа к которому добавить строки
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'warecode'));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'wareqty'));
            prAddLineFromSearchResToOrderOrd(StreamNew, ThreadData);
            Res:=StreamNew.ReadInt;
            if Res=aeSuccess then begin
              s:='';
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:='  '+fnIfStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'inline')='true','parent.','')+'document.location.href="'+curUserInfo.ScriptName+'/order?order='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr')+'&contract='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract')+'&bonus=false";'#13#10;
              s:=s+fnIfStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'dialogname')='','','$("#'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'dialogname')+'").dialog("close");'#13#10 );
              Stream.WriteStr(s);
            end else if Res=erFindedDouble then begin
                       //s:='';
                       Stream.Clear;
                       Stream.WriteInt(aeSuccess);
                       Stream.WriteStr('jqswMessageError(''Этот товар уже есть в заказе.'');');
                       //s:='if (confirm("Этот товар уже есть в заказе. Открыть окно подбора количеств?")) {'#13#10;
                       //s:='  '+fnIfStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'inline')='true','parent.','')+'document.location.href="'+ScriptName+'/order?order='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr')+'";'#13#10;
                       //s:=s+fnIfStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'dialogname')='','','$("#'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'dialogname')+'").dialog("close");'#13#10 );
                       //s:=s+'  setTimeout(ec("getqtybyanalogsandstorages", "&warecode='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'warecode')+'&ordr='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr')+'&wareqty='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'wareqty')+'&contract='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract')+'", "abj"), 3000);'#13#10;
                       //s:=s+'};';
                       //Stream.WriteStr(s);
                     end
                     else begin
                       setErrorCommand(StreamNew,Stream);
                     end;
          end

          else if (curUserInfo.strOther.Values['act']='moveincurrentorderfromformqty') then begin
              nmProc := 'moveincurrentorderfromformqty'; // имя процедуры/функции
              StreamNew.Clear;
              StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
              StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
              i:=StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0);
              StreamNew.WriteInt(i);
              StreamNew.WriteInt(7);  // место под кол-во аналогов
              StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr'));  // код заказа к которому добавить строки
              AnalogCount:=0; TotalOrderQty:=0;
              for i:=3 to curUserInfo.strPost.Count-1 do begin
                CurOrderQty:=abs(StrToIntDef(curUserInfo.strPost.ValueFromIndex[i],0));
                if (CurOrderQty>constDeltaZero) then begin
                   StreamNew.WriteStr(curUserInfo.strPost.Names[i]); // код аналога
                   StreamNew.WriteDouble(CurOrderQty);                 // а это его кол-во
                   TotalOrderQty:=TotalOrderQty+CurOrderQty;
                   Inc(AnalogCount);
                end;
              end;
              if (TotalOrderQty<constDeltaZero) then begin
                raise EBOBError.Create('Для добавления товаров в заказ нужно ввести кол-во хотя бы в одно поле ввода');
              end;
              StreamNew.Position:=12;
              StreamNew.WriteInt((AnalogCount)); // кол-во аналогов
              prAddLinesToOrderOrd(StreamNew, ThreadData);
              Res:=StreamNew.ReadInt;
              if Res=aeSuccess then begin
                Stream.Clear;
                Stream.WriteInt(aeSuccess);
                s:='document.location.href="'+curUserInfo.ScriptName+'/order?order='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr')+'&contract='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract')+'&bonus=false";'#13#10;
                s:=s+fnIfStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'dialogname')='','','$("#'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'dialogname')+'").dialog("close");'#13#10 );
                Stream.WriteStr(s);
              end
              else begin
                 setErrorCommand(StreamNew,Stream);
              end;
          end

          else if (curUserInfo.strOther.Values['act']='gettimelistselfdelivery') then begin
            nmProc := 'prgetTimeListSelfDelivery'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteDouble(StrToDate(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'date')));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'OldTime'), 0));
            prgetTimeListSelfDelivery(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fngetTimeListSelfDelivery(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'OldTime')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='contracts') then begin
            nmProc := 'prContractList'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            prContractList(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              //curUserInfo.ContractId:=StrToIntDef(curUserInfo.strOther.Values['contractid'],0);
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeaderRedisign(curUserInfo)+#13#10+Result);
              Stream.WriteLongStr(fnGetNewContactsPage(curUserInfo,StreamNew));
              Stream.WriteStr(fnFooterRedisign(curUserInfo));
              Stream.WriteStr(curUserInfo.UserID);
              Stream.WriteStr(curUserInfo.FirmID);
              Stream.WriteInt(curUserInfo.ContractId);
            end else begin
              setErrorStrsOrder(curUserInfo,Stream,StreamNew);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='orders') then begin
            nmProc := 'prGetOrderListOrd'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteByte(fnIfInt(curUserInfo.strCookie.Values['ofForming']='1', 1, 0));
            StreamNew.WriteByte(fnIfInt(curUserInfo.strCookie.Values['ofClosed']='1', 1, 0));
            StreamNew.WriteByte(fnIfInt(curUserInfo.strCookie.Values['ofProcessing']='1', 1, 0));
            StreamNew.WriteByte(fnIfInt(curUserInfo.strCookie.Values['ofAnulated']='1', 1, 0));
            StreamNew.WriteByte(fnIfInt(curUserInfo.strCookie.Values['ofAccepted']='1', 1, 0));
            try
              Data:=StrToDate(curUserInfo.strCookie.Values['ofDataFrom']);
            except
              Data:=0;
            end;
            StreamNew.WriteDouble(Data);
            try
              Data:=StrToDate(curUserInfo.strCookie.Values['ofDataTo']);
            except
              Data:=0;
            end;
            StreamNew.WriteDouble(Data);
            Setlength(Variants, 5);
            Variants[0]:='ORDRDATE';
            Variants[1]:='ORDRNUM';
            Variants[2]:='ORDRSUMORDER';
            Variants[3]:='ORDRCURRENCY';
            Variants[4]:='ORDRSTATUS';
            s:=fnIfStr(fnInStrArray(curUserInfo.strCookie.Values['ordersorder'], Variants)>-1, curUserInfo.strCookie.Values['ordersorder'], 'ORDRDATE');//SortOrder
            s1:=fnIfStr(curUserInfo.strCookie.Values['ordersdesc']='desc', 'desc', '');  //SortDesc
            StreamNew.WriteStr(s);
            StreamNew.WriteStr(s1);
            prGetOrderListOrd(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeaderRedisign(curUserInfo)+#13#10+Result);
              Stream.WriteLongStr(fnGetNewOrdersPage(curUserInfo,StreamNew,s,s1));
              Stream.WriteStr(fnFooterRedisign(curUserInfo));
              Stream.WriteStr(curUserInfo.UserID);
              Stream.WriteStr(curUserInfo.FirmID);
              Stream.WriteInt(curUserInfo.ContractId);
            end else begin
              setErrorStrsOrder(curUserInfo,StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='order') then begin
            nmProc := 'prShowOrderOrd'; // имя процедуры/функции
            OrderCode:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordernum'));
            if flGetExcelWareList then begin
               if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filename')<>'') then
                 ExcelFileName:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'filename')
               else
                 ExcelFileName:='';
            end;
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(curUserInfo.ContractId);
            StreamNew.WriteStr(OrderCode);
            StreamNew.WriteBool(True); //порядок  вывода адреса
            prShowOrderOrd(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              curUserInfo.PageName:=curUserInfo.strOther.Values['act'];
              Stream.WriteInt(aeSuccess);
              Stream.WriteLongStr(fnHeaderRedisign(curUserInfo)+#13#10+Result);
              Stream.WriteLongStr(fnGetNewOrderPage(curUserInfo,StreamNew,OrderCode,ExcelFileName));
              Stream.WriteStr(fnFooterRedisign(curUserInfo));
              Stream.WriteStr(curUserInfo.UserID);
              Stream.WriteStr(curUserInfo.FirmID);
              Stream.WriteInt(curUserInfo.ContractId);
            end else begin
               setErrorStrsOrder(curUserInfo,StreamNew,Stream);
            end;
          end

          else if (curUserInfo.strOther.Values['act']='contractlist') then begin
            nmProc := 'prContractList'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            prContractList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnGetContractList(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'edit'),StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'),0)));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='obm') then begin
            nmProc := 'prCreateOrderByMarkedOrd'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            i:=0;
            s1:='';
            while fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'name'+IntToStr(i))<>'' do begin
              s1:=s1+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'name'+IntToStr(i))+', ';
             Inc(i);
            end;
            s1:=Copy(s1, 1, Length(s1)-2); //убираем лишнюю запятую с пробелом
            StreamNew.WriteStr(s1);
            prCreateOrderByMarkedOrd(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnGetObm_JMAction(StreamNew,curUserInfo.ScriptName));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='jm') then begin
            nmProc := 'prJoinMarkedOrdersOrd'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            i:=0;
            s1:='';
            while fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'name'+IntToStr(i))<>'' do begin
              s1:=s1+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'name'+IntToStr(i))+', ';
             Inc(i);
            end;
            s1:=Copy(s1, 1, Length(s1)-2); //убираем лишнюю запятую с пробелом
            StreamNew.WriteStr(s1);
            prJoinMarkedOrdersOrd(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnGetObm_JMAction(StreamNew,curUserInfo.ScriptName));
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='new_order') then begin
            nmProc := 'prCreateNewOrderOrd'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            prCreateNewOrderOrd(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:='';
              s1:=IntToStr(StreamNew.ReadInt);
              s:=s+'location.href="'+curUserInfo.ScriptName+'/order?order='+s1+'&contract='+IntToStr(StreamNew.ReadInt)+'"; '#13#10;
              Stream.WriteStr(s);
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='refreshprices') then begin
            nmProc := 'prRefreshPricesOrd'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'order'));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            prRefreshPricesOrd(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s1:=Stream.ReadStr;
              s:='<script>'#13#10;
              s:=s+'jqswMessage("'+GetJSSafeString(s1)+'");'#13#10;;
              if (Pos('не изменились', s1)=0) then
                s:=s+'reloadpage();';//location.href="'+Request.ScriptName+'/order?order='+Request.ContentFields.Values['order']+'"';
              s:=s+'</script>'#13#10;
              Stream.WriteStr(s);
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
           end



           else if (curUserInfo.strOther.Values['act']='refresh_prices') then begin
            nmProc := 'prRefreshPricesInFormingOrdersOrd'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            prRefreshPricesInFormingOrdersOrd(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:='';
              s:=s+'jqswMessage("Цены в неотправленных заказах успешно обновлены")'#13#10;
              s:=s+'reloadpage();'#13#10;
              Stream.WriteStr(s);
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='delorders') then begin
            nmProc := 'prDeleteOrderByMarkOrd'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            s1:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordercodes');
            i:=Length(s1);
            if (i>0) and (Copy(s1, i, 1)=',') then begin
              s1:=Copy(s1, 1, i-1);
            end;
            StreamNew.WriteStr(s1);
            prDeleteOrderByMarkOrd(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:='reloadpage();';
              Stream.WriteStr(s);
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getdestpointparams') then begin
            nmProc := 'prGetDestPointParams'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            prGetDestPointParams(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnGetDestPointParams(StreamNew));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='filldeliverysheduler') then begin
            nmProc := 'prGetAvailableTimeTablesList'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(curUserInfo.ContractId);
            StreamNew.WriteInt(0);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_tt'),0));
            StreamNew.WriteDouble(StrToDateDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_deliverydate'),0));
            oldShedulercode:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_shedulercode');
            prGetAvailableTimeTablesList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnFillDeliverySheduler(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_tt'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_deliverydate')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end


           else if (curUserInfo.strOther.Values['act']='getmeetpersonslist') then begin //
             nmProc := 'prGetMeetPersonList'; // имя процедуры/функции
             StreamNew.Clear;
             StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
             StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
             prGetMeetPersonsList(StreamNew, ThreadData);
             if StreamNew.ReadInt=aeSuccess then begin
               Stream.Clear;
               Stream.WriteInt(aeSuccess);
               Stream.WriteStr(fngetMeetPersonsList(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'value')));
             end else begin
                setErrorCommand(StreamNew,Stream);
             end;
           end

           else if (curUserInfo.strOther.Values['act']='changecontract') then begin
            nmProc := 'prChangeClientLastContract'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'newcontr'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordercode'), 0));
            prChangeClientLastContract(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:='';
              if (StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordercode'), 0)=0) then begin
                s:=s+'reloadpage();'#13#10;
              end else begin
                s:=s+'location.href="'+curUserInfo.ScriptName+'/order?order='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordercode')+'&contract='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'newcontr')+'";'#13#10;
              end;
              Stream.WriteStr(s);
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='changecontractbonus') then begin
            nmProc := 'prChangeClientLastContract'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'newcontr'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordercode'), 0));
            prChangeClientLastContract(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:='';
              if (StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordercode'), 0)=0) then begin
                s:=s+'reloadpage();'#13#10;
              end else begin
                s:=s+'location.href="'+curUserInfo.ScriptName+'/loyalty?&contract='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordercode')+'&contract='+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'newcontr')+'";'#13#10;
              end;
              Stream.WriteStr(s);
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end


           else if (curUserInfo.strOther.Values['act']='getcontractdestpointslist') then begin
            nmProc := 'prGetContractDestPointsList'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(curUserInfo.ContractId);
            StreamNew.WriteBool(true);   //признак направления адреса. труе - начиная с дома            prGetWareSatellites(StreamNew, ThreadData);
            prGetContractDestPointsList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fngetContractDestPointsList(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'value'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'isEmpty')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getattrlist') then begin
            nmProc := 'prGetListGroupAttrs'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'), 0));
            prGetListGroupAttrs(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnGetAttrList(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='linestoorder') then begin
            nmProc := 'prAddLinesToOrderOrd'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            i:=StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0);
            StreamNew.WriteInt(i);
            StreamNew.WriteInt(7);  // место под кол-во аналогов
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr'));  // код заказа к которому добавить строки
            //Stream.WriteStr(Request.ContentFields.Values['WareRequestId']);  // ID запроса для последующей аналитики
            //Stream.WriteStr(Request.ContentFields.Names[3]); // это тот товар, из-за которого собственно сыр-бор
            //TotalOrderQty:=abs(StrToFloatDef(Request.ContentFields.Values[Request.ContentFields.Names[4]], 0));
            //Stream.WriteDouble(TotalOrderQty);               // а это его кол-во
            s1:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id');  //warecode
            AnalogCount:=0;
            for i:=3 to curUserInfo.strPost.Count-1 do begin
              CurOrderQty:=abs(StrToFloatDef(curUserInfo.strPost.Values[curUserInfo.strPost.Names[i]], 0));
              if (CurOrderQty>constDeltaZero) then begin
                Stream.WriteStr(curUserInfo.strPost.Names[i]); // код аналога
                Stream.WriteDouble(CurOrderQty);                 // а это его кол-во
                //TotalOrderQty:=TotalOrderQty+CurOrderQty;
                Inc(AnalogCount);
              end;
            end;
           // if (TotalOrderQty<constDeltaZero) then begin
            // raise EBOBError.Create('Для добавления товаров в заказ нужно ввести кол-во хотя бы в одно поле ввода');
            //end;
            StreamNew.Position:=12;
            StreamNew.WriteInt((AnalogCount)); // кол-во аналогов
            prAddLinesToOrderOrd(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnaddLinesToOrder(StreamNew,curUserInfo.ScriptName,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end



           else if (curUserInfo.strOther.Values['act']='getdatelistselfdelivery') then begin
            nmProc := 'prGetDprtAvailableShipDates'; // имя процедуры/функции
            s1:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'));
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteDouble(StrToFloatDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'Olddate'),0));
            i:=StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'Olddate'),0);
            flag:=true;
            prGetDprtAvailableShipDates(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fngetDateListSelfDelivery(StreamNew,flag,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'Olddate')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getqtybyanalogsandstorages') then begin
            nmProc := 'prGetQtyByAnalogsAndStoragesOrd'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr'));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'warecode'));
            StreamNew.WriteDouble(StrToFloatDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'wareqty'), 1));  // кол-во
            prGetQtyByAnalogsAndStoragesOrd(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnGetQtyByAnalogsAndStorages(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'bonus'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end



           else if (curUserInfo.strOther.Values['act']='checkorderwarerests') then begin
            nmProc := 'prCheckOrderWareRests'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            s:='';
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr'),0));
            StreamNew.WriteDouble(StrToDateDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'shipdate'),0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'deliverykind'),0));
            prCheckOrderWareRests(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              s1:=StreamNew.ReadStr;
              s:=s+' $("#warningwarestr").text('''+s1+'''); '#13#10;
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(s);
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end



          else if (curUserInfo.strOther.Values['act']='fillparametrsallorder') then begin
            nmProc := 'prGetOrderHeaderParams'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordercode'));
            StreamNew.WriteBool(True); //порядок  вывода адреса
            prGetOrderHeaderParams(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnfillParametrsAllOrder(StreamNew));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='createnewacc') then begin
            nmProc := 'prNewBankAccount'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            prNewBankAccount(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fngetNewBankAccountParams(StreamNew));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='savenewacc') then begin
            nmProc := 'prSaveBankAccount'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contId'),0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'persID'),0));
            s:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'phone');
            StreamNew.WriteStr(s);
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'email'));
            s:=StringReplace(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'sum'),'.',',',[rfReplaceAll]);
            StreamNew.WriteDouble(StrToFloatDef(s,0));
            prSaveBankAccount(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnsaveNewBankAccountParams(StreamNew,curUserInfo.ScriptName,StrToBoolDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'isfrominfo'),false)));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='sendsmsfrombankaccount') then begin
            nmProc := 'prSendSMSfromBankAccount'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'baccid'),0));
            prSendSMSfromBankAccount(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              s:='var btn = document.getElementById("btn'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'baccid')+'");'#13#10;
              s:=s+'btn.disabled = true;'#13#10;
              s:=s+'$(btn).attr("title","SMS сообщение с данными по счету уже отправлено");'#13#10;
              s:=s+'jqswMessage("SMS отправлено");'#13#10;
              Stream.WriteStr(s);
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end




           else if (curUserInfo.strOther.Values['act']='saveparametrsfromorder') then begin
            nmProc := 'prEditOrderHeaderParams'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr'));
            StreamNew.WriteStr(Utf8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'warrantnum')));
            StreamNew.WriteStr(Utf8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'warrantperson')));
            StreamNew.WriteDouble(StrToDateDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'warrantdate'),0));
            StreamNew.WriteStr(Utf8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordercomment')));
            v:=StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'typeofgetting'),0);
            //Ini.WriteString('log','str','1');
            StreamNew.WriteInt(v);
           //Ini.WriteString('log','str','2');
           //Ini.Free;
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'tt'),0));
            StreamNew.WriteDouble(StrToFloatDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'deliverydate'),0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'shedulercode'),0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'pickuptime'),0));
            kindSave:=StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'savemark'));
            StreamNew.WriteBool(StrToBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'savemark')));
            prEditOrderHeaderParams(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnsaveParametrsFromOrder(StreamNew,v,kindSave,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'deliverytext'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'deliverydate')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end


          else if (curUserInfo.strOther.Values['act']='getdeliverieslist') then begin
            nmProc := 'prWebarmGetDeliveries'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteBool(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'priceinuah')='1');
            prWebarmGetDeliveries(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(s);
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

          else if (curUserInfo.strOther.Values['act']='fillheaderbeforeprocessing') then begin
            nmProc := 'fillheaderbeforeprocessing'; // имя процедуры/функции
            StreamNew.Clear;
            s:='';
            s:=s+'$("#fillheaderbeforeprocessingdiv").dialog("open");'#13#10;
            s:=s+'$("#fillheaderbeforeprocessingdiv input[name^=''typeofgetting'']:checked").trigger("change");'#13#10;
            s:=s+''#13#10;
            s:=s+''#13#10;
            s:=s+''#13#10;
            Stream.Clear;
            Stream.WriteInt(aeSuccess);
            Stream.WriteStr(s);
           end

           else if (curUserInfo.strOther.Values['act']='getcontractdestpointslist') then begin
            nmProc := 'prGetContractDestPointsList'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(isWe);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contractid'), 0));
            StreamNew.WriteBool(true);   //признак направления адреса. труе - начиная с дома            prGetWareSatellites(StreamNew, ThreadData);
            prGetContractDestPointsList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fngetContractDestPointsList(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'value'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'isEmpty')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='fillparametrsallorder') then begin
            nmProc := 'prGetAccountShipParams'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(isWe);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'accid'));
            prGetAccountShipParams(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnfillParametrsAllWebArm(StreamNew));
            end else begin
               setErrorCommand(StreamNew,Stream);
             end;
           end

           else if (curUserInfo.strOther.Values['act']='saveparametrsfromorder') then begin
            nmProc := 'prSetAccountShipParams'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(isWe);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmiddeliv'), 0));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr'));
            v:=StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'typeofgetting'),0);
            StreamNew.WriteInt(v);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'t'),0));
            StreamNew.WriteDouble(StrToFloatDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'deliverydate'),0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'shedulercode'),0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'pickuptime'),0));
            prSetAccountShipParams(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnsaveParametrsFromWebArm(StreamNew,v,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'deliverytext'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'deliverydate')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='filldeliverysheduler') then begin
            nmProc := 'prGetAvailableTimeTablesList'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(isWe);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ordr'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_tt'),0));
            Stream.WriteDouble(StrToDateDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_deliverydate'),0));
            oldShedulercode:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_shedulercode');
            prGetAvailableTimeTablesList(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnFillDeliverySheduler(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_tt'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'_deliverydate')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getdatelistselfdelivery') then begin
            nmProc := 'prGetDprtAvailableShipDates'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(isWe);
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contractid'), 0));
            StreamNew.WriteDouble(StrToFloatDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'Olddate'),0));
            i:=StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'Olddate'),0);
            flag:=true;
            prGetDprtAvailableShipDates(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fngetDateListSelfDelivery(StreamNew,flag,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'Olddate')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='waresearch') then begin
            nmProc := 'prCommonWareSearch'; // имя процедуры/функции
            s:='';
            Template:=AnsiUpperCase(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'waresearch')));
            if length(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'waresearch'))<3 then begin
              s:=s+'document.getElementById("waresearch").value="'+fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'waresearch')+'";';
              s:=s+'jqswMessage("Строка поиска должна содержать не менее трех символов, не считая лидирующих и завершающих пробелов.");';
            end else begin
              if ((fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'groups')='') and (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'lampbase')<>'true'))then Template:=UTF8ToAnsi(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'waresearch'));
              StreamNew.Clear;
              StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
              StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
              StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
              StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
              StreamNew.WriteStr(Template);
              if (fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'lampbase')='true') then begin
                IgnoreSpec:=coLampBaseIgnoreSpec;
              end else begin
                IgnoreSpec:=fnIfInt(curUserInfo.strCookie.Values['ignorspec']='false', 0, 2);
              end;
              StreamNew.WriteByte(IgnoreSpec);
              StreamNew.WriteBool(curUserInfo.strCookie.Values['show_in_uah']='true');
              StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'groups'));
              prCommonWareSearch(StreamNew, ThreadData);
              if StreamNew.ReadInt=aeSuccess then begin
                Stream.Clear;
                Stream.WriteInt(aeSuccessLong);
                s:=s+fnWareSearch(curUserInfo,StreamNew,curUserInfo.LogText,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'groups'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'waresearch'),curUserInfo.strCookie.Values['ignorspec'],curUserInfo.strCookie.Values['one_line_mode'],fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'),AnsiUpperCase(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'waresearch'))));
                Stream.WriteLongStr(s);
              end else begin
                 setErrorCommand(StreamNew,Stream);
              end;
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getsatellites') then begin
            nmProc := 'prGetWareSatellites'; // имя процедуры/функции
            s1:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'));
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(s1));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteBool(curUserInfo.strCookie.Values['show_in_uah']='true');
            prGetWareSatellites(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccessLong);
              s:=fnGetSatellites(curUserInfo,StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'));
              Stream.WriteLongStr(s);
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getattrlistselected') then begin
            nmProc := 'prGetFilteredGBGroupAttValues'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'groupid'),0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'count'),0));
            for i:=0 to curUserInfo.strPost.Count-1 do begin
              if ((curUserInfo.strPost.Names[i]<>'act')
                 and (curUserInfo.strPost.Names[i]<>'selectname')
                 and (curUserInfo.strPost.Names[i]<>'groupid')
                 and (curUserInfo.strPost.Names[i]<>'count')
                 and (curUserInfo.strPost.Names[i]<>'')
              ) then begin
                 StreamNew.WriteInt(StrToInt(curUserInfo.strPost.Names[i]));
                 StreamNew.WriteInt(StrToInt(curUserInfo.strPost.Values[curUserInfo.strPost.Names[i]]));
              end;
            end;
            prGetFilteredGBGroupAttValues(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnGetAttrListSelected(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'selectname')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='fillattrlistselected') then begin
            nmProc := 'prGetFilteredGBGroupAttValues'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'groupid'),0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'count'),0));
            for i:=0 to curUserInfo.strPost.Count-1 do begin
              if ((curUserInfo.strPost.Names[i]<>'act')
                 and (curUserInfo.strPost.Names[i]<>'selectname')
                 and (curUserInfo.strPost.Names[i]<>'groupid')
                 and (curUserInfo.strPost.Names[i]<>'count')
                 and (curUserInfo.strPost.Names[i]<>'')
              ) then begin
                 StreamNew.WriteInt(StrToInt(curUserInfo.strPost.Names[i]));
                 StreamNew.WriteInt(StrToInt(curUserInfo.strPost.Values[curUserInfo.strPost.Names[i]]));
              end;
            end;
            prGetFilteredGBGroupAttValues(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnFillAttrListSelected(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'selectname')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getattrlist') then begin
            nmProc := 'prGetListGroupAttrs'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'), 0));
            prGetListGroupAttrs(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnGetAttrList(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id')));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getwaresbyattr') then begin
            nmProc := 'prCommonSearchWaresByAttr'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            Position:=StreamNew.Position;
            v:=0; //WareCount
            StreamNew.WriteInt(0);
            for i:=0 to curUserInfo.strPost.Count-1 do begin
              if ((curUserInfo.strPost.Names[i]<>'act')
                and (curUserInfo.strPost.Names[i]<>'forfirmid')
                and (curUserInfo.strPost.Names[i]<>'contract')
                and (curUserInfo.strPost.Names[i]<>'')) then begin
                  StreamNew.WriteInt(StrToInt(curUserInfo.strPost.Names[i]));
                  StreamNew.WriteInt(StrToInt(curUserInfo.strPost.Values[curUserInfo.strPost.Names[i]]));
                  Inc(v);
                end;
            end;
            StreamNew.Position:=Position;
            StreamNew.WriteInt(v);
            StreamNew.Position:=StreamNew.Size;
            StreamNew.WriteBool(curUserInfo.strCookie.Values['show_in_uah']='true');
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            prCommonSearchWaresByAttr(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnGetWaresByAttr(curUserInfo,StreamNew));
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getanalogs') then begin
            nmProc := 'prGetWareAnalogs'; // имя процедуры/функции
            s1:=trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'));
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(s1));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteBool(curUserInfo.strCookie.Values['show_in_uah']='true');
            StreamNew.WriteByte(fnIfInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'is_on')='0', constThisIsWare, constThisIsOrNum));
            prGetWareAnalogs(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccessLong);
              s:=fnGetAnalogs(curUserInfo,StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'),fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'is_on'));
              Stream.WriteLongStr(s);
            end else begin
               setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getnodewaresmotul') then begin
            nmProc := 'prCommonGetNodeWares_Motul'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'model'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'node'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), -1));
            StreamNew.WriteBool(curUserInfo.strCookie.Values['show_in_uah']='true');
            prCommonGetNodeWares_Motul(StreamNew,ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
                Stream.Clear;
                Stream.WriteInt(aeSuccessLong);
                //Stream.WriteStr('');
                Stream.WriteLongStr(fnGetNodeWares_Motul(StreamNew,curUserInfo,curUserInfo.ScriptName));
              end else begin
                setErrorCommand(StreamNew,Stream);
              end;
           end


           else if (curUserInfo.strOther.Values['act']='getaresdescrview') then begin
            nmProc := 'prWebArmGetWaresDescrView'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'warecodes'));
            prWebArmGetWaresDescrView(StreamNew, ThreadData);
            if StreamNew.ReadInt=aeSuccess then begin
              Stream.Clear;
              Stream.WriteInt(aeSuccess);
              Stream.WriteStr(fnWebArmGetWaresDescrView(StreamNew));
            end else begin
              setErrorCommand(StreamNew,Stream);
            end;
           end

           else if (curUserInfo.strOther.Values['act']='gettop10') then begin
            nmProc := 'prGetTop10Model'; // имя процедуры/функции
            Top10Cookie:=fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'objdiv');
            Sys:=0;
            if (Top10Cookie='autotop10') or (Top10Cookie='mototop10') or (Top10Cookie='auentop10') then begin
              if (Top10Cookie='autotop10') then begin
                Sys:=constIsAuto;
              end;
              if (Top10Cookie='mototop10') then begin
                Sys:=constIsMoto;
              end;
              if (Top10Cookie='auentop10') then begin
                Sys:=30+constIsAuto;
              end;
              StreamNew.Clear;
              StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
              StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
              StreamNew.WriteInt(Sys);
              StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'id'))); // код модели
              StreamNew.WriteStr(curUserInfo.strCookie.Values[Top10Cookie]);
              prGetTop10Model(StreamNew,ThreadData);
              if StreamNew.ReadInt=aeSuccess then begin
                Stream.Clear;
                Stream.WriteInt(aeSuccess);
                s:=fnRefreshTop10List(StreamNew,Top10Cookie,Sys);
                Stream.WriteStr(s);
              end else begin
                setErrorCommand(StreamNew,Stream);
              end;
            end
            else begin
              setErrorCommandStr(Stream,'Неверно указан элемент для заполнения - '+Top10Cookie+' , сообщите об этой ошибке разработчику');
            end;
           end

           else if (curUserInfo.strOther.Values['act']='getattributegrouplist') then begin
            nmProc := 'prGetListAttrGroupNames'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'sys'))); // код модели
            prGetListAttrGroupNames(StreamNew,ThreadData);
              if StreamNew.ReadInt=aeSuccess then begin
                Stream.Clear;
                Stream.WriteInt(aeSuccess);
                Stream.WriteStr(fnGetAttributeGroupList(StreamNew,fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'tablename')));
              end else begin
                setErrorCommand(StreamNew,Stream);
              end;
           end

           else if (curUserInfo.strOther.Values['act']='newuser') then begin
            nmProc := 'prGetListAttrGroupNames'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'ful'));
            StreamNew.WriteStr(trim(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'newlogin')));
            prWebCreateUserOrd(StreamNew,ThreadData);
              if StreamNew.ReadInt=aeSuccess then begin
                Stream.Clear;
                Stream.WriteInt(aeSuccess);
                Stream.WriteStr(fnCreateNewUser(StreamNew,curUserInfo));
              end else begin
                setErrorCommand(StreamNew,Stream);
              end;
           end

           else if (curUserInfo.strOther.Values['act']='getattributegrouplist') then begin
            nmProc := 'prGetListAttrGroupNames'; // имя процедуры/функции
            StreamNew.Clear;
            StreamNew.WriteInt(StrToInt(curUserInfo.FirmID));
            StreamNew.WriteInt(StrToInt(curUserInfo.UserID));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'forfirmid'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'contract'), 0));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'model'), -1));
            StreamNew.WriteInt(StrToIntDef(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'node'), -1));
            StreamNew.WriteStr(fnGetFieldStrList(curUserInfo.strPost,curUserInfo.strGet,'warecodes'));
            prCommonGetRestsOfWares(StreamNew,ThreadData);
              if StreamNew.ReadInt=aeSuccess then begin
                s:='';
                i:=Stream.ReadInt;
                for i:=1 to i do begin
                 j:=Stream.ReadInt; //Code
                 v:=Stream.ReadInt; //Qty
                 s:=s+'$(''.rm'+IntToStr(j)+''').css(''background-image'', ''url(/images/restmark'+IntToStr(v)+'.png)'');'#13#10;
                 s:=s+'$(''.rm'+IntToStr(j)+'[title=""]'').attr(''title'', '''+fnIfStr(v=0, 'Нет в наличии', 'Есть в наличии')+''');'#13#10;
               end;
                Stream.Clear;
                Stream.WriteInt(aeSuccess);
                Stream.WriteStr(s);
              end else begin
                setErrorCommand(StreamNew,Stream);
              end;
           end


      end else begin
        if (curUserInfo.strOther.Values['kindofrequest']='page') then   begin
          curUserInfo.OnReadyScript:='';
          Stream.Clear;
          Stream.WriteInt(aeCommonError);
          s:=fnHeaderRedisign(curUserInfo,false);
          Stream.WriteLongStr(s);
          s:=' jqswMessageError("Отсутствует логин или пароль.");';
          Stream.WriteStr(fnDefaultPageRedisign(curUserInfo, s));
        end
        else if (curUserInfo.strOther.Values['kindofrequest']='command') then begin
          if (curUserInfo.strOther.Values['act']='quit') then begin //
            Stream.Clear;
            Stream.WriteInt(aeSuccess);
            s:=s+'setCookie_("sid", "", getExpDate_(0,0,0),"/",0,0);'#13#10;
            s:=s+'s=document.location.href;'#13#10;
            s:=s+'s=(s.substr(s.length-1)==''#'')?s.substr(0, s.length-1):s;'#13#10;
            s:=s+'document.location.href=s;';
            Stream.WriteStr(s);
         end
         else
           setOnlineErrorStrs(curUserInfo,StreamNew,Stream); //надо добавитьь свой fnHeader и fnFooter !!!!!!!!!!
         end;
        end;
    end else begin
      if (curUserInfo.strOther.Values['kindofrequest']='page') then   begin
        curUserInfo.OnReadyScript:='';
        Stream.Clear;
        Stream.WriteInt(aeCommonError);
        s:=fnHeaderRedisign(curUserInfo,false);
        Stream.WriteLongStr(s);
        s:=' jqswMessageError("Отсутствует логин или пароль.");';
        Stream.WriteStr(fnDefaultPageRedisign(curUserInfo, s));
        //Stream.WriteStr(fnFooterRedisign(curUserInfo));
        //Stream.WriteStr(curUserInfo.UserID);
        //Stream.WriteStr(curUserInfo.FirmID);
        //Stream.WriteStr(IntToStr(curUserInfo.ContractId));
     end
     else if (curUserInfo.strOther.Values['kindofrequest']='command') then begin
        Stream.Clear;
        Stream.WriteInt(aeCommonError);
        Stream.WriteStr(' jqswMessageError(''Отсутствует логин или пароль.'');');
      end;
    end;


  except
    on E: EBOBError do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', True);
    on E: Exception do prSaveCommonError(Stream, ThreadData, nmProc, E.Message, '', False);
  end;
  StreamNew.Free;
  curUserInfo.strPost.Free;
  curUserInfo.strGet.Free;
  curUserInfo.strCookie.Free;
  curUserInfo.strOther.Free;
  Stream.Position:= 0;
  end;



end.

