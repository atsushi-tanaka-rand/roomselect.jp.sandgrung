//退去予定更新
global with sharing class BD301001Batch implements Database.Batchable<sObject>{
    
    //コンストラクタ
    global BD301001Batch(){
    }
    
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        String today = String.valueOf(CommonUtil.getToday());
        today = today.replace(' 00:00:00','');
        String soql ='';
        soql += 'SELECT Id, OwnCompanyManageModDate__c, WebPublishing__c';
        soql += ' FROM Property__c'; //物件が対象
        soql += ' WHERE ( LiveStatus__c = \''+ commonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE +'\''; //現況 = 退去予定
        soql += ' OR LiveStatus__c = \''+ commonConst.PROPERTY_LIVESTATUS_VACANCY +'\' ) '; //現況 = 空室
        soql += ' AND DeliveryType__c = \'' + CommonConst.PROPERTY_DELIVERYTYPE_DUEDATE +'\'';       //引渡種別 = 期日指定
        soql += ' AND DeliveryDateSort__c <=' + today;//引渡日（順序用）<= システム日付
        
        return Database.getQueryLocator(soql);   
    }
    
    //開始
    global void execute(Database.BatchableContext BC, List<Property__c> targetList){
        
        if (targetList.size() > 0) {
            
            //変数を用意
            Date     systemToday = CommonUtil.getToday();
            DateTime systemNow   = CommonUtil.getNow(); 
            Set<ID> idSet = new Set<ID>();  //更新するIdを追加する用
            
            
            //1．↑のSOQL文で取得した物件レコードの更新
            for (Property__c property : targetList) {
                
                //建物物件差分 作成判定
                if (property.OwnCompanyManageModDate__c != null && property.OwnCompanyManageModDate__c.date() != systemToday
                    && property.WebPublishing__c == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS) {
                    idSet.add(property.id);//自社管理修正日が変更される場合(Web公開するに限る)、建物物件差分を作成する
                }
                
                property.LiveStatus__c   = CommonConst.PROPERTY_LIVESTATUS_VACANCY;     //現況　　を「退去予定」→「空室」
                property.DeliveryType__c = CommonConst.PROPERTY_DELIVERYTYPE_IMMEDIATE; //引渡種別を「期日指定」→「即時」
                
                
                //引渡　年/月/旬/日　をnullに
                property.DeliveryYear__c   = null;
                property.DeliveryMonth__c  = null;
                property.DeliveryTiming__c = null;
                property.DeliveryDay__c    = null;
                
                property.IsBulkConfirmation__c      = false;       //一括確認チェック
                property.BulkConfirmationDate__c    = null;        //一括確認日
                property.OwnCompanyManageModDate__c = systemNow;   //自社管理修正日 = システム日付
                property.TemporarySaveDate__c       = null;        //一時保存日
                property.MaintenanceType__c         = CommonConst.MAINTENANCETYPE_AUTOCHG;//メンテナンス区分 = 自動変更
                property.MaintenanceCommentArea__c  = '退去予定更新バッチにより引渡種別を”期日指定”から”即時”に変更しました';//メンテナンスコメント
                
            }
            SecureDML.secureUpdate(targetList);
            
            //2.建物物件差分の作成
            BuildingPropertyUtil.createBuildingPropertyDifference(idSet);
        }
        
    }
    
    /*
* バッチ処理の終了時に呼び出される
* 終了処理を実装する
*/
    global void finish(Database.BatchableContext BC) {
        //なし
    }
}