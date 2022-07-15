public with sharing class BE101001TriggerHandler3 {
/** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;
    
    /** コンストラクタ */
    public BE101001TriggerHandler3(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    /** 登録前処理 */
    public void onBeforeInsert(Application__c[] newObjs){
    }
    
    /** 登録後処理 */
    public void onAfterInsert(Application__c[] newObjs, Map<ID, Application__c> newObjMap){

        // 反響累計登録処理（共通クラス）
        DailyReportUtil.upsertEchoTotal_Application(newObjs, newObjs);
    }
    
    /** 更新前処理 */
    public void onBeforeUpdate(Application__c[] oldObjs, Map<ID, Application__c> oldObjMap, Application__c[] newObjs, Map<ID, Application__c> newObjMap){
    }
    
    /** 更新後処理 */
    public void onAfterUpdate(Application__c[] oldObjs, Map<ID, Application__c> oldObjMap, Application__c[] newObjs, Map<ID, Application__c> newObjMap){
    
            // 反響累計登録処理（共通クラス）
        DailyReportUtil.upsertEchoTotal_Application(newObjs, oldObjs);
    }
    
    /** 削除前処理 */
    public void onBeforeDelete(Application__c[] oldObjs, Map<ID, Application__c> oldObjMap){
    }
    
    /** 削除後処理 */
    public void onAfterDelete(Application__c[] oldObjs, Map<ID, Application__c> oldObjMap){
    }
    
    /** 復元後処理 */
    public void onUndelete(Application__c[] newObjs){
    }
}