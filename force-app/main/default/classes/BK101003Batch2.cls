//来店受付メンテナンスバッチ2
global with sharing class BK101003Batch2 implements Database.Batchable<sObject>{

    global BK101003Batch2() {
    }


    //データ取得（来店受付_店舗日別取得）
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date today = CommonUtil.getToday();                 //本日日付
        Date nextYearEndOfMonth = getNextYearEndOfMonth(today);  //来年月末
    
        //取得した日付を文字列に変換
        String soqlToday = String.valueOf(today).replace(' 00:00:00','');//文字列で検索するため要らない表記を削除
        String soqlNextYearEndOfMonth = String.valueOf(nextYearEndOfMonth).replace(' 00:00:00','');
    
        String soql ='';

        soql += 'SELECT Id,';
        soql += ' TargetDate__c,';      //対象日付
        soql += ' PeopleLimit__c,';     //上限人数
        soql += ' Shop__c,';            //店舗
        soql += ' (SELECT id,';
        soql += '  ReserveCanCount__c,';     //来店受付．予約可能数
        soql += '  ReserveStartTime__c,';    //来店受付．予約開始時刻
        soql += '  ReserveEndTime__c,';      //来店受付．予約終了時刻
        soql += '  ReserveResultCount__c,';  //来店受付．予約実績数
        soql += '  ReserveCanNotCount__c';   //来店受付．予約不能数
        soql += '  FROM  AppointmentReceiptARSD__r'; 
        soql += '  ORDER BY ReserveStartTime__c )'; 
        soql += ' FROM AppointmentReceiptStoreDate__c';             //来店受付_店舗日別
        soql += ' WHERE TargetDate__c <=' + soqlNextYearEndOfMonth; //対象日付 <= 来年月末
        soql += ' AND TargetDate__c >= ' + soqlToday;               //対象日付 >= 本日日付
        soql += ' AND ProcessingFlg__c = true';                     //処理フラグ= true
        return Database.getQueryLocator(soql);   

    }

    //開始
    global void execute(Database.BatchableContext BC, List<AppointmentReceiptStoreDate__c> arsdList){
        //★upsert用来店受付を変更しupsert
        upsertAppointmentReceipt(arsdList);
    
        //★親の来店受付_店舗日別の処理フラグをfalseに変更しupdate
        updateARSD(arsdList);
    }

    //終了
    global void finish(Database.BatchableContext BC) {
        //なし
    }
    

    //----------------------------privateメソッド-------------------------------------------------------------------------
    
    //★upsert用来店受付作成
    private void upsertAppointmentReceipt(List<AppointmentReceiptStoreDate__c> arsdList){
        List<AppointmentReceipt__c> upsertAppointmentReceiptList = new List<AppointmentReceipt__c>();//upsert用来店受付
        //upsert用来店受付リスト作成
        cretaeAppointmentReceiptList(arsdList, upsertAppointmentReceiptList);

        //upsert用来店受付リストが空でなければupsert
        if (! upsertAppointmentReceiptList.isEmpty()){
            SecureDML.secureUpsert(upsertAppointmentReceiptList);
        }
    }

    //upsert用の来店受付リスト作成
    private void cretaeAppointmentReceiptList(List<AppointmentReceiptStoreDate__c> arsdList ,List<AppointmentReceipt__c> upsertAppointmentReceiptList){
        //再販対応 追加 Start
        //開始時間設定
        String st = SystemConfig__c.getInstance().AppointmentReceiptStartTime__c;
        String et = SystemConfig__c.getInstance().AppointmentReceiptEndTime30minAgo__c;

        Time startTime = Time.newInstance(Integer.valueOf(st.left(2)), Integer.valueOf(st.right(2)), 0, 0);
            
        //終了時間設定（設定した時間 + 1時間半（ポータルサイトに反映に必要））
        Time endTime = Time.newInstance(Integer.valueOf(et.left(2)), Integer.valueOf(et.right(2)), 0, 0);
        endTime = endTime.addHours(1);
        endTime = endTime.addMinutes(30);
        //再販対応 追加 End

        //親をループ
        for (AppointmentReceiptStoreDate__c arsd : arsdList){
                    
            //子の来店受付Map <String（予約開始時刻）,来店受付> 作成
            Map<Time, AppointmentReceipt__c> appointmentReceiptMap = new Map<Time, AppointmentReceipt__c>();
            for (AppointmentReceipt__c ar :arsd.AppointmentReceiptARSD__r){            
                appointmentReceiptMap.put(ar.ReserveStartTime__c, ar);
            }
            
            Time targetTime = startTime;
            //対象時間が終了時刻になるまでループ
            ////再販対応 変更　　対象時間　が　開始時間より小さいくなる場合はループ終了する処理を追加（時間が0時に繰り上がる場合を防ぐ）
            while (targetTime <= endTime && targetTime >= startTime){

                //予約開始時刻（対象時間の値を入れる）
                Time stStartTime = targetTime;

                //予約終了時刻（予約開始時刻+30を文字列に）の作成
                Time stEndTime = targetTime.addMinutes(30);
                
                //upsert用の来店受付レコードを新規作成  
                AppointmentReceipt__c ar =createAppointmentReceipt(arsd, stStartTime, stEndTime);

                //子の来店受付マップにループ時間の開始日ある場合、Id等を追加
                if (appointmentReceiptMap.containsKey(stStartTime)){
                    ar.Id = appointmentReceiptMap.get(stStartTime).Id;  //Id =　既存のId
                    ar.ReserveResultCount__c = appointmentReceiptMap.get(stStartTime).ReserveResultCount__c;//予約実績数 = 既存の値
                    ar.ReserveCanNotCount__c = appointmentReceiptMap.get(stStartTime).ReserveCanNotCount__c;//予約不能数 = 既存の値
                }
                
                //upsertListに追加
                upsertAppointmentReceiptList.add(ar);

                //対象時間を+30分
                targetTime = targetTime.addMinutes(30);
            }
        }
    }

    //upsert用新規来店受付作成
    private AppointmentReceipt__c createAppointmentReceipt (AppointmentReceiptStoreDate__c arsd, Time stStartTime, Time stEndTime){
        AppointmentReceipt__c ar = new AppointmentReceipt__c();
                
        ar.ReserveStartTime__c = stStartTime;          //予約開始時刻   = 対象時間
        ar.ReserveEndTime__c = stEndTime;              //予約終了時刻   = 対象時間+30分
        ar.ReceiptDate__c = arsd.TargetDate__c;        //受付日         = 来店受付_店舗日別．対象日付
        ar.ReserveCanCount__c = arsd.PeopleLimit__c;   //予約可能数     = 来店受付_店舗日別．上限人数
        ar.Shop__c = arsd.Shop__c;                     //店舗           = 来店受付_店舗日別．店舗
        ar.AppointmentReceiptStoreDate__c = arsd.Id;   //来店受付_店舗日別= 来店受付_店舗日別．Id
        return ar;
    }

    //★親の来店受付_店舗日別の処理フラグをfalseにする
    private void updateARSD(List<AppointmentReceiptStoreDate__c> arsdList){
    
        for (AppointmentReceiptStoreDate__c arsd : arsdList){
            arsd.ProcessingFlg__c = false;
        }
        SecureDML.secureUpdate(arsdList);
    }

    //来年年末取得
    private Date getNextYearEndOfMonth(Date today){
        return Date.newInstance(today.addYears(1).year(), today.month() + 1 ,0);  //来年月末
    }
    
    
}