/**
 * SUMMOスコア自動更新バッチ
 **/
global with sharing class BuildingPropertySumoScoreBatch implements Database.Batchable<sObject>{
    
    //コンストラクタ
    global BuildingPropertySumoScoreBatch(){
    }
    
    //データ取得
    global Database.QueryLocator start(Database.BatchableContext BC){
        String PROPERTY_LIVESTATUS_VACANCY= CommonConst.PROPERTY_LIVESTATUS_VACANCY;//空室
        String PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE= CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE;//退去予定
        //物件取得
        String soql ='';
        soql += 'SELECT Id,';
        soql += ' Building__c,';//建物
        soql += ' SuumoNetCatch__c,';//SUMMOネットキャッチ
        soql += ' SuumoNetCatchComment__c';//SUMMOネットキャッチ用コメント

        soql += ' FROM Property__c'; //物件が対象
        soql += ' WHERE LiveStatus__c = :PROPERTY_LIVESTATUS_VACANCY';//現況が空室、または退去予定
        soql += ' OR LiveStatus__c = :PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE';
        return Database.getQueryLocator(soql);   
    }
    
    //開始
    global void execute(Database.BatchableContext BC, List<Property__c> targetList){
        if (targetList.size() > 0) {
            //WHERE句用List作成
            List<Id> builIdList=new List<id>();
            List<Id> proIdList=new List<id>();
            
            for (Property__c property : targetList){
                builIdList.add(property.Building__c);
                proIdList.add(property.id);
            }

             //1．↑のSOQL文で取得した物件から建物を取得
            List<Building__c> builList = [SELECT id,
                    Supermarket__r.PhotoFileName__c,//スーパーマーケット
                    ConvenienceStore__r.PhotoFileName__c,//コンビニ
                    GeneralHospital__r.PhotoFileName__c,//総合病院
                    PrimarySchool1__r.PhotoFileName__c,//小学校1
                    PrimarySchool2__r.PhotoFileName__c,//小学校2
                    PrimarySchool3__r.PhotoFileName__c,//小学校3
                    JuniorHighSchool1__r.PhotoFileName__c,//中学校1
                    JuniorHighSchool2__r.PhotoFileName__c,//中学校2
                    JuniorHighSchool3__r.PhotoFileName__c,//中学校3
                    HighSchool__r.PhotoFileName__c,//高校
                    University__r.PhotoFileName__c//大学
            FROM Building__c
            WHERE id IN :builIdList];
           
            //建物Map作成
            Map<Id, Building__c> builMap = new Map<Id, Building__c>(builList);

            //2．↑のSOQL文で取得した物件から物件写真をを取得
            String sql = '';

            sql += 'SELECT Id ';
            sql += ' ,Property__c ';
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) { //物件写真
                sql += '      ,PropertyPhotoFileName' + i + '__c ';//物件ファイル名
                sql += '      ,PropertyPhotoTag' + i + '__c '; //物件タグ
            }
            for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) { //パノラマ写真
                sql += '      ,PanoramaFileName' + i + '__c ';//パノラマファイル名
                sql += '      ,PanoramaTag' + i + '__c ';//パノラマタグ
            }
            sql += '          ,RoomLayoutFileName__c ';//間取り図
            sql += '  FROM PropertyPhoto__c ';
            sql += ' WHERE Property__c   IN :proIdList ';

            List<PropertyPhoto__c> proPhotoList = Database.query(sql);
                
            //物件写真Map作成
            Map<Id, PropertyPhoto__c> proPhotoMap = new Map<Id, PropertyPhoto__c>();
            for (PropertyPhoto__c proPhoto :proPhotoList){
                //物件Id,物件写真レコード
                proPhotoMap.put(proPhoto.Property__c, proPhoto);
            }

            //3．1で取得した建物から建物写真を取得
            List<BuildingPhoto__c> builPhotoList = [SELECT id,
                         Building__c,
                         AppearanceFileName__c,//建物外観ファイル名
                         AppearanceParseFileName__c,//外観バースファイル名
                         EntranceFileName__c,//エントランスファイル名
                         LobbyFileName__c,//ロビーファイル名
                         ParkingFileName__c,//駐車場ファイル名
                         OtherSharingFileName__c,//その他共有ファイル名
                         MapFileName__c,//地図ファイル名
                         OtherFileName__c,//その他ファイル名
                         SurroundingFileName1__c,//周辺写真ファイル名
                         SurroundingFileName2__c,
                         SurroundingFileName3__c,
                         SurroundingFileName4__c,
                         SurroundingFileName5__c
                FROM BuildingPhoto__c
                WHERE Building__c IN :builIdList];
            
            //建物写真Map作成
            Map<Id, BuildingPhoto__c> builPhotoMap = new Map<Id, BuildingPhoto__c>();
            for (BuildingPhoto__c builPhoto :builPhotoList){
                //建物Id,建物写真レコード
                builPhotoMap.put(builPhoto.Building__c, builPhoto);
            }
            
            //4.物件でループさせ、点数を取得
            List<Property__c> upsertProList = new List<Property__c>(); 
            for (Property__c pro : targetList){
                pro.Score__c = BuildingPropertyUtil.getSuumoScore(builMap.get(pro.Building__c), builPhotoMap.get(pro.Building__c), pro, proPhotoMap.get(pro.id), true);
                upsertProList.add(pro);
            }
            SecureDML.secureUpsert(upsertProList);
        }
    }
    
    /*
* バッチ処理の終了時に呼び出される
* 終了処理を実装する
*/
    global void finish(Database.BatchableContext BC) {

    }
}