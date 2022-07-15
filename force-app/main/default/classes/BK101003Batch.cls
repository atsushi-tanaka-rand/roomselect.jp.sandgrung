//来店受付メンテナンスバッチ
global with sharing class BK101003Batch implements Database.Batchable<sObject>{

    global BK101003Batch() {
    }


    //データ取得（有効店舗取得）
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date today = CommonUtil.getToday();                      //本日日付
        Date nextYearEndOfMonth = getNextYearEndOfMonth(today);  //来年月末

        //取得した日付を文字列に変換
        String soqlToday = String.valueOf(today).replace(' 00:00:00','');//文字列で検索するため要らない表記を削除
        String soqlNextYearEndOfMonth = String.valueOf(nextYearEndOfMonth).replace(' 00:00:00','');
    
        String soql ='';

        soql += 'SELECT Id,';
        soql += ' SystemUseStartDate__c,';  //システム使用開始日
        soql += ' SystemUseEndDate__c';     //システム使用終了日
        soql += ' FROM Shop__c';            //店舗
        soql += ' WHERE SystemUseStartDate__c <=' + soqlNextYearEndOfMonth; //システム使用開始日 <= 来年月末
        soql += ' AND SystemUseEndDate__c >= ' + soqlToday;                 //システム使用終了日 >= 　本日日付
        soql += ' AND IsShopType__c = true ';                               //店舗区分 = treu
        return Database.getQueryLocator(soql);   
    }


    //開始
    global void execute(Database.BatchableContext BC, List<Shop__c> shopList){
        Date today = CommonUtil.getToday();                      //本日日付
        Date nextYearEndOfMonth = getNextYearEndOfMonth(today);  //来年月末

        //★既存の来店受付_店舗種別マップ作成
        Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> oldARSDMap = createOldARSDMap(shopList, today, nextYearEndOfMonth);

        //★新しい来店受付_店舗種別のマップ作成
        Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> newARSDMap = createNewARSDMap(ShopList, today, nextYearEndOfMonth);
        
        //★既存の来店受付_店舗日別　と　新しい来店受付_店舗日別　を比較し、上限人数が違うもの、既存のレコードがないものをupsert
        upsertARSD(shopList, oldARSDMap, newARSDMap, today, nextYearEndOfMonth);
    }

    /*
    * バッチ処理の終了時に呼び出される
    * 終了処理を実装する
    */
    global void finish(Database.BatchableContext BC) {

        final Integer BATCH_SIZE = SystemConfig__c.getInstance().AppointmentReceiptBatchSize__c.intValue(); //バッチサイズ
    
        //バッチ実行
        if (!Test.isRunningTest()){
            BK101003Batch2 b = new BK101003Batch2();
            Database.executeBatch(b, BATCH_SIZE);
        }
        

    }

    //--------------------------------------privateメソッド----------------------------------------------------------------------------
    //**********既存マップ関連******************************************************************************
    
    //★既存の来店受付_店舗種別のマップ作成
    private Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> createOldARSDMap(List<Shop__c> shopList,Date today, Date nextYearEndOfMonth){
        
        //既存の有効店舗の来店受付_店舗日別を取得する
        List<AppointmentReceiptStoreDate__c> arsdList = getAppointmentReceiptStoreDate(shopList, today, nextYearEndOfMonth);

        //親Map<日付, Map<Id（店舗の）, 来店受付_店舗日別>>
        Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> oldARSDMap = new Map<Date, Map<Id, AppointmentReceiptStoreDate__c>>();

            //リストのループを回す
            for (AppointmentReceiptStoreDate__c arsd : arsdList){

                //子Map<Id（店舗の）, 来店受付_店舗日別>
                Map<Id, AppointmentReceiptStoreDate__c> shopARSDMap;
    
                //oldARSDリストに対象の来店受付_店舗日別．対象日付をキーとする子Mapがある？
                if (oldARSDMap.ContainsKey(arsd.TargetDate__c)){
                    //既存の子Mapがある場合、↑で作成した子Mapを既存の子Mapに
                    shopARSDMap = oldARSDMap.get(arsd.TargetDate__c);
                }else{
                    shopARSDMap = new Map<Id, AppointmentReceiptStoreDate__c>();
                }

                //子Mapに店舗Id,　来店受付_店舗日別　をput
                shopARSDMap.put(arsd.Shop__c, arsd);
    
                //親Mapに日付、子Map　をput
                oldARSDMap.put(arsd.TargetDate__c, shopARSDMap);
            }

        return oldARSDMap;
    }

    //**********新規マップ関連******************************************************************************
    
    //★新しい来店受付_店舗種別のマップ作成
    private Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> createNewARSDMap(List<Shop__c> shopList, Date today, Date nextYearEndOfMonth){
        
        //新しい来店受付_店舗種別のマップ作成(初期化)
        Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> newARSDMap = initializeNewARSDMap(shopList, today, nextYearEndOfMonth);

        //新しい来店受付_店舗種別のマップの中身作成
        setNewARSDMap(shopList, newARSDMap, today, nextYearEndOfMonth);
        
        //定休日設定（対象日付が定休日の来店受付_店舗日別の上限人数を0に変更する）
        setRegularHolidayMap(shopList, newARSDMap, today, nextYearEndOfMonth);

        return newARSDMap;
    }

    //新しく来店受付_店舗種別のマップ作成
    private Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> initializeNewARSDMap(List<Shop__c> shopList, Date today, Date nextYearEndOfMonth){
        
        Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> newARSDMap = new Map<Date, Map<Id, AppointmentReceiptStoreDate__c>>();
        
        Date targetDate = today;    //対象日付

        //日付ごとにループを回す
        while (targetDate <= nextYearEndOfMonth){  //対象日付が来年月末になるまでループ
            Map<Id, AppointmentReceiptStoreDate__c> shopARSDMap = new Map<Id, AppointmentReceiptStoreDate__c>();

            //有効店舗ごとにループ
            for (Shop__c shop : shopList){
                
                //店舗がその対象日付に営業してる場合のみ、レコードを作成
                if (shop.SystemUseStartDate__c <= targetDate && shop.SystemUseEndDate__c >= targetDate){
                    //紐づける来店受付_店舗種別を初期化
                    AppointmentReceiptStoreDate__c arsd = new AppointmentReceiptStoreDate__c(
                        PeopleLimit__c = 0,
                        Shop__c = shop.Id,
                        TargetDate__c = targetDate
                    );
                    //店舗と初期化した新規来店受付_店舗種別を紐づけ
                    shopARSDMap.put(shop.Id, arsd);
                }
            }

            //店舗とマップ<日付,来店受付_店舗種別> を紐づけ
            newARSDMap.put(targetDate, shopARSDMap);

            targetDate = targetDate.addDays(1);
        }
        return newARSDMap;
    }    

    //新しい来店受付_店舗種別のマップ設定
    private void setNewARSDMap(List<Shop__c> shopList, Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> arsdMap, Date today, Date nextYearEndOfMonth){
        
        //有効なユーザを店舗異動から取得する
        List<ShopTransfer__c> shopTransferList = getShopTransfer(shopList, today, nextYearEndOfMonth);
        
        Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> reARSDMap = arsdMap;//返却用Map

        //店舗異動でループ
        for(ShopTransfer__c shopTarnsfer : shopTransferList){
            
            
            //対象日付の開始日付 = 対象の店舗異動の開始日　と　本日日付　で　より遅い方
            Date targetDate = shopTarnsfer.StartDate__c >= today ? shopTarnsfer.StartDate__c : today;
            
            //終了日付 = 対象の店舗異動の終了日　と　来年月末　で　より早い方
            Date EndDate = shopTarnsfer.EndDate__c <= nextYearEndOfMonth ? shopTarnsfer.EndDate__c : nextYearEndOfMonth;

            while (targetDate <= EndDate){//開始日付　から　終了日付までループ

               //対象マップがある場合のみ
                if (reARSDMap.containsKey(targetDate) && reARSDMap.get(targetDate).containsKey(shopTarnsfer.OrgzanizationHierarchy__r.Shop__c)){
                    //targetDateと店舗をキーにして、対象の来店受付_店舗日別の上限人数を+1する
                    reARSDMap.get(targetDate).get(shopTarnsfer.OrgzanizationHierarchy__r.Shop__c).PeopleLimit__c++;
                }               

                targetDate = targetDate.addDays(1);
            }

        }
    }

    //定休日設定
    private void setRegularHolidayMap(List<Shop__c> shopList, Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> newARSDMap, Date today, Date nextYearEndOfMonth){

        Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> reARSDMap= newARSDMap;
        
        //定休日を行動から取得する
        List<Date> regularHolidayList = getRegularHoliday(today, nextYearEndOfMonth);

        //定休日リストをループ
        for (Date holiday : regularHolidayList){

            //定休日の開始日時がキーの全来店受付_店舗日別．上限人数を0にする
            for (Shop__c shop : shopList){
                if (reARSDMap.containsKey(holiday) && reARSDMap.get(holiday).containsKey(shop.Id)){
                    reARSDMap.get(holiday).get(shop.Id).PeopleLimit__c = 0; 
                }
                
            }
        }

    }
    
    //**********新旧比較関連******************************************************************************

    //★既存の来店受付_店舗日別と、新しい来店受付_店舗日別　を比較
    private void upsertARSD(List<Shop__c> shopList, Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> oldARSDMap, Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> newARSDMap, Date today, Date nextYearEndOfMonth){
        
        List<AppointmentReceiptStoreDate__c> upsertARSDList = new List<AppointmentReceiptStoreDate__c>();//upsert用来店受付_店舗日別List

        Date targetDate = today;    //対象日付

        //対象日付が来年月末になるまでループ
        while (targetDate <= nextYearEndOfMonth){  

            //店舗ごとにループし、比較し、変更があるものをリストに追加
            compareARSD(shopList, upsertARSDList, targetDate, oldARSDMap, newARSDMap);

            targetDate = targetDate.addDays(1);
        }
        system.debug('upsertする来店受付_店舗日別'+upsertARSDList.size());
        //空でなければ、変更があったレコードリストをupsertする
        if (! upsertARSDList.isEmpty()){
            SecureDML.secureUpsert(upsertARSDList);
        }
    }

    //既存と新規Mapの比較
    private void compareARSD(List<Shop__c> shopList,List<AppointmentReceiptStoreDate__c> upserARSDList, Date targetDate, Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> oldARSDMap, Map<Date, Map<Id, AppointmentReceiptStoreDate__c>> newARSDMap){
        
        List<AppointmentReceiptStoreDate__c> reUpsertARSDList = upserARSDList;
        
        for (Shop__c shop : shopList){

            //対象の日付と店舗の新規レコードが存在する時のみ処理を行う
            if (newARSDMap.containsKey(targetDate) && newARSDMap.get(targetDate).containsKey(shop.Id)){
                
                if (oldARSDMap.containsKey(targetDate) && oldARSDMap.get(targetDate).containsKey(shop.Id)){

                    //既存と新規で上限人数の値が違う時のみレコード作成
                    if (oldARSDMap.get(targetDate).get(shop.Id).PeopleLimit__c != newARSDMap.get(targetDate).get(shop.Id).PeopleLimit__c){
                        //upsert用のレコード作成
                        AppointmentReceiptStoreDate__c arsd = newARSDMap.get(targetDate).get(shop.Id);
                        arsd.Id             = oldARSDMap.get(targetDate).get(shop.Id).Id;   //既存のId
                        arsd.ProcessingFlg__c = true;                                       //処理フラグ
                        //reUpsertARSDListに追加
                        reUpsertARSDList.add(arsd);
                    }

                //対象の日付と店舗の既存レコードが存在しない
                }else{
                    //upsert用のレコード作成
                    AppointmentReceiptStoreDate__c arsd = newARSDMap.get(targetDate).get(shop.Id);
                    arsd.ProcessingFlg__c = true;    //処理フラグ
                    //reUpsertARSDListに追加
                    reUpsertARSDList.add(arsd);                                   
                }
            }
        }
    }


    //**********他メソッド******************************************************************************

    //来年年末取得
    private Date getNextYearEndOfMonth(Date today){
        return Date.newInstance(today.addYears(1).year(), today.month() + 1 ,0);  //来年月末
    }

    //**********SOQL取得系******************************************************************************

    //有効店舗の来店受付_店舗日別を取得
    private List<AppointmentReceiptStoreDate__c> getAppointmentReceiptStoreDate(List<Shop__c> shopList,Date today, Date nextYearEndOfMonth){
        
        List<AppointmentReceiptStoreDate__c> appReceipStoreDateList = [SELECT id,
                                    TargetDate__c,  //対象日付
                                    PeopleLimit__c, //上限人数
                                    Shop__c         //店舗
                                FROM AppointmentReceiptStoreDate__c //来店受付_店舗日別
                                WHERE Shop__c IN :shopList  //店舗　IN  有効店舗リスト
                                AND  TargetDate__c <= :nextYearEndOfMonth   //対象日付 <= 来年月末
                                AND  TargetDate__c >= :today];              //対象日付 >= 本日日付
        return appReceipStoreDateList;
    }

    //有効なユーザ（店舗異動）取得
    private List<ShopTransfer__c> getShopTransfer(List<Shop__c> shopList,Date today,Date nextYearEndOfMonth){
        List<ShopTransfer__c> shopTransferList = [SELECT id,
                                    StartDate__c,  //開始日
                                    EndDate__c,    //終了日
                                    OrgzanizationHierarchy__r.Shop__c//店舗
                            FROM ShopTransfer__c
                            WHERE OrgzanizationHierarchy__r.Shop__c IN :shopList         //店舗 IN 有効店舗リスト
                            AND   OrgzanizationHierarchy__r.Shop__r.IsShopType__c = true //店舗区分 = true
                            AND   StartDate__c <= :nextYearEndOfMonth   //開始日 <= 来年月末
                            AND   EndDate__c   >= :today];              //本日日付

        return shopTransferList;
    }

    //定休日取得
    private List<Date> getRegularHoliday(Date today, Date nextYearEndOfMonth){
        // システム設定からカレンダー名を取得
        String calendarName = SystemConfig__c.getInstance().PortalManagementCalendar__c;

        //HP来店予約管理カレンダーのIdを取得
        List<Calendar> calenderList = [SELECT id
                             FROM Calendar WHERE Name = :calendarName];
        
        if (calenderList.isEmpty()){
            return new List<Date>();
        }

        List<Event> eventList = [SELECT id,
                            StartDateTime  //開始日
                    FROM  Event
                    WHERE Subject = '定休日'
                    AND   OwnerId = :calenderList[0].Id//HP来店予約管理カレンダーのId
                    AND   StartDateTime >= :today               //開始日 >= 本日日付
                    AND   EndDateTime   < :nextYearEndOfMonth.addDays(1)  //終了日 < 来年月末+1日
                    ];

        //Datetime型をDate型に変換し、定休日リストを作成する
        List<Date> regularHolidayDateList = new List<Date>();
        for (Event ev : eventList){
            regularHolidayDateList.add(ev.StartDateTime.date());
        }
        return regularHolidayDateList;
    }


}