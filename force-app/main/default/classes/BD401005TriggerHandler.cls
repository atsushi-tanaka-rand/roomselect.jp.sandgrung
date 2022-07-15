// ポータルサイト掲載物件トリガー
public with sharing class BD401005TriggerHandler {
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;
    /** 重複更新フラグ */
    public Static boolean isDuplicateUpdate = false;
    
    /** コンストラクタ */
    public BD401005TriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    /** 登録前処理 */
    public void onBeforeInsert(PortalSitePostingProperty__c[] newObjs){
        
    }
    
    /** 登録後処理 */
    public void onAfterInsert(PortalSitePostingProperty__c[] newObjs, Map<ID, PortalSitePostingProperty__c> newObjMap){
        
        // ポータルサイト掲載物件差分登録
        PortalDifferenceInsert(newObjs, newObjMap);
    }
        
    /** 更新前処理 */
    public void onBeforeUpdate(PortalSitePostingProperty__c[] oldObjs, Map<ID, PortalSitePostingProperty__c> oldObjMap, PortalSitePostingProperty__c[] newObjs, Map<ID, PortalSitePostingProperty__c> newObjMap){
        
        //重複更新対応
        if (isDuplicateUpdate) {
            return;
        }
        
    }
    
    
    /** 更新後処理 */
    public void onAfterUpdate(PortalSitePostingProperty__c[] oldObjs, Map<ID, PortalSitePostingProperty__c> oldObjMap, PortalSitePostingProperty__c[] newObjs, Map<ID, PortalSitePostingProperty__c> newObjMap){
        
        //重複更新対応
        if (isDuplicateUpdate) {
            return;
        }
        
        // ポータルサイト掲載物件差分登録
        PortalDifferenceInsert(oldObjs,newObjMap);
    }
        
    /** 削除前処理 */
    public void onBeforeDelete(PortalSitePostingProperty__c[] oldObjs, Map<ID, PortalSitePostingProperty__c> oldObjMap){
        
        // ポータルサイト掲載物件差分登録
        PortalDifferenceInsert(oldObjs,oldObjMap);
    }
        
    /** 削除後処理 */
    public void onAfterDelete(PortalSitePostingProperty__c[] oldObjs, Map<ID, PortalSitePostingProperty__c> oldObjMap){
        
    }
    
    /** 復元後処理 */
    public void onUndelete(PortalSitePostingProperty__c[] newObjs){
        
    }
    
    
    // ********************************
    // privateメソッド
    // ********************************
    
    // ポータルサイト掲載物件差分登録
    private void PortalDifferenceInsert(PortalSitePostingProperty__c[] oldObjs, Map<ID, PortalSitePostingProperty__c> newObjMap){
        
        // 項目APIの取得
        // ポータルサイト掲載物件OBJの全項目を取得する。
        Schema.SObjectType sot1 = Schema.getGlobalDescribe().get('PortalSitePostingProperty__c');  // SObjectType型でポータルサイト掲載物件OBJを取得
        Schema.DescribeSObjectResult dsr1 = sot1.getDescribe();  // DescribeSObjectResult型に変換
        Map<String, Schema.SObjectField> fsMap1 = dsr1.fields.getMap();  // Map型でポータルサイト掲載物件オブジェクトの情報を取得する

        // ポータルサイト掲載物件オブジェクトの全項目setを作成する
        Set<String> portalFieldApiSet = new Set<String>();
        for (Schema.SObjectField sof : fsMap1.values()) {
            portalFieldApiSet.add(sof.getDescribe().getName());
        }

        // ポータルサイト掲載物件差分オブジェクトの全項目を取得する。
        Schema.SObjectType sot2 = Schema.getGlobalDescribe().get('PortalSitePostingPropertyDifference__c');// SObjectType型でポータルサイト掲載物件差分オブジェクトを取得する
        Schema.DescribeSObjectResult dsr2 = sot2.getDescribe();// DescribeSObjectResult型に変換
        Map<String, Schema.SObjectField> fsMap2 = dsr2.fields.getMap();// Map型でポータルサイト掲載物件差分オブジェクトの情報を取得する

        // ポータルサイト掲載物件差分オブジェクトのListを作成(Inset用)
        List<PortalSitePostingPropertyDifference__c> portalDifferenceList = new List<PortalSitePostingPropertyDifference__c>();

        // oldを回す。
        for(PortalSitePostingProperty__c oldObj : oldObjs){
            
            // ①の処理のために、ポータルサイト掲載物件差分をnewする。
            PortalSitePostingPropertyDifference__c addPortalDifference = new PortalSitePostingPropertyDifference__c();

            // ①ポータルサイト掲載物件と同じAPI項目を設定する。
            for(Schema.SObjectField sof : fsMap2.values()){
                String fieldApi = sof.getDescribe().getName();// 項目Api名の取得
                Boolean isCustom = sof.getDescribe().isCustom();// 項目の型を取得(カスタム項目か確認)
            
                // 特定の項目の場合処理を実施しない。
                if(fieldApi == 'ForeignIDAutoNumber__c' || // 外部Id自動採番
                   fieldApi == 'ForeignID__c'              //外部id
                  ){
                      continue;
                  }
                
                // もし、ポータルサイト掲載物件OBJに項目名が存在し、カスタム項目ならば
                if(portalFieldApiSet.contains(fieldApi) && isCustom)  {
                    addPortalDifference.put(fieldApi, newObjMap.get(oldObj.Id).get(fieldApi)); // ポータルサイト掲載物件差分に項目を設定する。
                }
            }

            
            // 標準項目を設定する
            addPortalDifference.PortalSitePostingPropertyId__c = newObjMap.get(oldObj.Id).Id;
            addPortalDifference.PortalSitePostingPropertyOwnerId__c = newObjMap.get(oldObj.Id).OwnerId;
            addPortalDifference.PortalSitePostingPropertyIsDeleted__c = newObjMap.get(oldObj.Id).IsDeleted;
            addPortalDifference.PortalSitePostingPropertyName__c = newObjMap.get(oldObj.Id).Name;
            addPortalDifference.PortalSitePostingPropertyCreatedDate__c = newObjMap.get(oldObj.Id).CreatedDate;
            addPortalDifference.PortalSitePostingPropertyCreatedById__c =newObjMap.get(oldObj.Id).CreatedById;
            addPortalDifference.PortalSitePostingPropertyLastModDate__c =newObjMap.get(oldObj.Id).LastModifiedDate;
            addPortalDifference.PortalSitePostingPropertyLastModById__c =newObjMap.get(oldObj.Id).LastModifiedById;
            addPortalDifference.PortalSitePostingPropertySystemModstamp__c =newObjMap.get(oldObj.Id).SystemModstamp;



            
            
            // トリガが挿入イベント時、クラッドコードをCに変更する。
            if(Trigger.isInsert) {
                addPortalDifference.CrudCd__c = 'C';
                
            // トリガ更新イベント時、クラッドコードをUに変更する。  
            } else if (Trigger.isUpdate) {
                addPortalDifference.CrudCd__c = 'U';
            // トリガ削除イベント時、クラッドコードをDに変更する。
                
            } else if (Trigger.isDelete) {
                addPortalDifference.CrudCd__c = 'D';
            }
            // add用の変数を物件差分リストへ追加
            portalDifferenceList.add(addPortalDifference);
        }
        
        // propertyDifferenceListが空でなければ、オブジェクトに入れる。
        if(!portalDifferenceList.isEmpty()){
            SecureDML.secureInsert(portalDifferenceList);
        }  
    }
}