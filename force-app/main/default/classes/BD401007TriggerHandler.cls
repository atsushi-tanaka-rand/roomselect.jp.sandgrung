// ポータルサイト閲覧差分トリガーハンドラー
public with sharing class BD401007TriggerHandler {
    
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;

    
    /** コンストラクタ */
    public BD401007TriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
        /** 登録前処理 */
    public void onBeforeInsert(PortalSiteBrowseDifference__c[] newObjs){
        
    }
    
    /** 登録後処理 */
    public void onAfterInsert(PortalSiteBrowseDifference__c[] newObjs, Map<ID, PortalSiteBrowseDifference__c> newObjMap){
            
        // 対応OBJ更新
        CorrespondUpdate(newObjs,newObjMap);

        // 対応明細への登録
        CorrespondDetailInsert(newObjs,newObjMap);

        // ポータルサイト閲覧差分OBJの削除処理 
        PortalBrowseDiffDelete(newObjs,newObjMap);
}
        
        
    
    
    /** 更新前処理 */
    public void onBeforeUpdate(PortalSiteBrowseDifference__c[] oldObjs, Map<ID, PortalSiteBrowseDifference__c> oldObjMap, PortalSiteBrowseDifference__c[] newObjs, Map<ID, PortalSiteBrowseDifference__c> newObjMap){
    }
    
    
    /** 更新後処理 */
    public void onAfterUpdate(PortalSiteBrowseDifference__c[] oldObjs, Map<ID, PortalSiteBrowseDifference__c> oldObjMap, PortalSiteBrowseDifference__c[] newObjs, Map<ID, PortalSiteBrowseDifference__c> newObjMap){
    }
        
    /** 削除前処理 */
    public void onBeforeDelete(PortalSiteBrowseDifference__c[] oldObjs, Map<ID, PortalSiteBrowseDifference__c> oldObjMap){
    }
           
    /** 削除後処理 */
    public void onAfterDelete(PortalSiteBrowseDifference__c[] oldObjs, Map<ID, PortalSiteBrowseDifference__c> oldObjMap){
    }
    
    /** 復元後処理 */
    public void onUndelete(PortalSiteBrowseDifference__c[] newObjs){
    }
    
    
    
    // ********************************
    // privateメソッド
    // ******************************** 

    // 対応OBJ更新
    private void CorrespondUpdate(PortalSiteBrowseDifference__c[] oldObjs, Map<ID, PortalSiteBrowseDifference__c> newObjMap){
        
        
        //変数設定
        DateTime now = CommonUtil.getNow();
        Map<Id,Correspond__c> correspondUpdateMap = new Map<Id,Correspond__c>();// Update用のMapを用意する。
        
        // List作成
        for(PortalSiteBrowseDifference__c oldObj : oldObjs){

            // 対応ID無しチェック
            if (newObjMap.get(oldObj.Id).CorrespondId__c == null) {
                continue;
            }

            Correspond__c addCorrespond = new Correspond__c(
                    Id                     = newObjMap.get(oldObj.Id).CorrespondId__c //Id
                
                ,   AccountId__c           = newObjMap.get(oldObj.Id).AccountId__c    //取引先Id
                ,   EventDateTime__c       = now                                      //イベント時刻
                ,   IsBrowseFlg__c         = true                                     //閲覧フラグ
                ,   ListViewDate__c        = now                                      //一覧表示日時
                ,   BrowseDate__c          = now                                      //閲覧日時
                );
            
            
            //同対応が既にあるか調べる
            if(!correspondUpdateMap.containsKey(newObjMap.get(oldObj.Id).CorrespondId__c)){
                correspondUpdateMap.put(addCorrespond.Id,addCorrespond);
            }
        }
        
        //更新
        if(!correspondUpdateMap.values().isEmpty()){ // もし、Listが空ではなかったら
            SecureDML.secureUpdate(correspondUpdateMap.values()); // update
        }
    }

    
    
    // 対応明細登録処理
    private void CorrespondDetailInsert(PortalSiteBrowseDifference__c[] oldObjs, Map<ID, PortalSiteBrowseDifference__c> newObjMap){
        
        //既存対応Map作成
        Map<Id, Correspond__c> correspondDataMap = createCorrespondDataMap(oldObjs, newObjMap);
        
        
        //変数設定
        DateTime now = CommonUtil.getNow();
        List<CorrespondDetail__c> correspondDetailList = new List<CorrespondDetail__c>();

        for(PortalSiteBrowseDifference__c oldObj : oldObjs){
            
            // 対応ID無しチェック
            if (newObjMap.get(oldObj.Id).CorrespondId__c == null) {
                continue;
            }

            //新規　対応明細　作成
            CorrespondDetail__c addData = new CorrespondDetail__c(
                
                    SupportedDateTime__c = now                                       //対応日時
                ,   SupportedTitle__c    = '物件を閲覧しました。'                     //対応表題
                ,   SupportedContent__c  = newObjMap.get(oldObj.Id).PortalSiteUrl__c //対応内容
                                         + '\n' + newObjMap.get(oldObj.Id).PropertyDetail__c
                ,   Corresponds__c       = newObjMap.get(oldObj.Id).CorrespondId__c  //対応番号
                ,   PortalSiteUrl__c     = newObjMap.get(oldObj.Id).PortalSiteUrl__c //ポータルサイトUrl
                ,   CorrespondType__c    = CommonConst.CORRESPOND_EVENT_VIEWED       //対応種別
            );
            
            //店舗・担当者項目の設定
            if (correspondDataMap.containsKey(addData.Corresponds__c)) { //対応データが存在する場合
                
                Correspond__c c = correspondDataMap.get(addData.Corresponds__c); //既存 対応データ
                
                //来店担当店舗があれば来店担当店舗。なければ反響担当店舗を設定する
                addData.Shop__c = (c.VisitShop__c != null ) ? c.VisitShop__c : c.EchoShop__c;

                //2020/6/30追加：担当者（来店）があれば担当者（来店）、なければ担当者（反響）を設定する
                addData.staff__c = (c.ShopStaff__c != null ) ? c.ShopStaff__c : c.EchoStaff__c;

            }
            
            //同対応Idがあるか調べる
            Boolean isAdd = true;
            for (CorrespondDetail__c data: correspondDetailList) {
                if (newObjMap.get(oldObj.Id).CorrespondId__c == data.Corresponds__c) {
                    isAdd = false;
                    break;
                }
            }
            
            //リストに追加
            if (isAdd) {
                correspondDetailList.add(addData);
            }
        }
        
        //データ作成
        if (!correspondDetailList.isEmpty()) {
            SecureDML.secureInsert(correspondDetailList); // insert  
        } 
    }

    
    // 既存対応Map作成
    private Map<Id, Correspond__c> createCorrespondDataMap(PortalSiteBrowseDifference__c[] oldObjs, Map<ID, PortalSiteBrowseDifference__c> newObjMap) {

        //返却する変数設定
        Map<Id, Correspond__c> correspondDataMap = new Map<Id, Correspond__c>();
        
        //データ取得用IdSetを作成
        Set<String> idSet = new Set<String>();
        for (PortalSiteBrowseDifference__c oldData: oldObjs) {
            idSet.add(newObjMap.get(oldData.Id).CorrespondId__c);
        }
        
        //データ取得後、そのままMap変換
        //2020/6/30追加：担当者（反響）と担当者（来店）を追加
        correspondDataMap = new Map<Id, Correspond__c>([SELECT id, VisitShop__c, EchoShop__c , ShopStaff__c , EchoStaff__c FROM Correspond__c WHERE Id IN :idSet]);
        
        return correspondDataMap;
    }


    
    // ポータルサイト閲覧差分の非同期削除処理 
    private void PortalBrowseDiffDelete(PortalSiteBrowseDifference__c[] oldObjs, Map<ID, PortalSiteBrowseDifference__c> newObjMap){
        Set<Id> deleteIdSet = new Set<Id>();// Id型のSetを用意
        
        for(PortalSiteBrowseDifference__c oldObj : oldObjs){// oldを回す
            deleteIdSet.add(oldObj.Id);
        }
        // 非同期処理をよび出す。
        AsynchronousDeleteDifference(deleteIdSet);
        
    }
        
    // 非同期削除処理
    @future
    public static void AsynchronousDeleteDifference(Set<Id> deleteIdSet) {

        

        // 削除対処となるListを作成し、削除する。  
        List <PortalSiteBrowseDifference__c> deleteList= [SELECT Id FROM PortalSiteBrowseDifference__c 
                                                          WHERE Id IN :deleteIdSet
                                                         ];
        
        if(!deleteList.isEmpty()){// Listが空でなければ
            SecureDML.secureDelete(deleteList); // Delteを実施。
        }
    }
}