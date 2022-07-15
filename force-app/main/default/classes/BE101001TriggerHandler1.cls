// 日報集計部品（物件メンテナンス履歴トリガー）
public with sharing class BE101001TriggerHandler1 {
    
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;
    
    /** コンストラクタ */
    public BE101001TriggerHandler1(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    /** 登録前処理 */
    public void onBeforeInsert(PropertyMaintenanceHistory__c[] newObjs){
    }
    
    /** 登録後処理 */
    public void onAfterInsert(PropertyMaintenanceHistory__c[] newObjs, Map<ID, PropertyMaintenanceHistory__c> newObjMap){
    }
    
    /** 更新前処理 */
    public void onBeforeUpdate(PropertyMaintenanceHistory__c[] oldObjs, Map<ID, PropertyMaintenanceHistory__c> oldObjMap, PropertyMaintenanceHistory__c[] newObjs, Map<ID, PropertyMaintenanceHistory__c> newObjMap){
    }
    
    /** 更新後処理 */
    public void onAfterUpdate(PropertyMaintenanceHistory__c[] oldObjs, Map<ID, PropertyMaintenanceHistory__c> oldObjMap, PropertyMaintenanceHistory__c[] newObjs, Map<ID, PropertyMaintenanceHistory__c> newObjMap){
    }
    
    /** 削除前処理 */
    public void onBeforeDelete(PropertyMaintenanceHistory__c[] oldObjs, Map<ID, PropertyMaintenanceHistory__c> oldObjMap){
    }
    
    /** 削除後処理 */
    public void onAfterDelete(PropertyMaintenanceHistory__c[] oldObjs, Map<ID, PropertyMaintenanceHistory__c> oldObjMap){
    }
    
    /** 復元後処理 */
    public void onUndelete(PropertyMaintenanceHistory__c[] newObjs){
    }
}