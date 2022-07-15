// 物件コード履歴トリガハンドラ
public with sharing class BD301007TriggerHandler {

    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;

    /** コンストラクタ */
    public BD301007TriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    /** 登録前処理 */
    public void onBeforeInsert(PropertyCodeHistory__c[] newObjs){
 
    }
        
    /** 登録後処理 */
    public void onAfterInsert(PropertyCodeHistory__c[] newObjs, Map<ID, PropertyCodeHistory__c> newObjMap){

        // 物件コード履歴差分の登録
        this.insertPropertyCodeHistDiff(newObjs);
    }
        
    /** 更新前処理 */
    public void onBeforeUpdate(PropertyCodeHistory__c[] oldObjs, Map<ID, PropertyCodeHistory__c> oldObjMap, PropertyCodeHistory__c[] newObjs, Map<ID, PropertyCodeHistory__c> newObjMap){

    }
        
    /** 更新後処理 */
    public void onAfterUpdate(PropertyCodeHistory__c[] oldObjs, Map<ID, PropertyCodeHistory__c> oldObjMap, PropertyCodeHistory__c[] newObjs, Map<ID, PropertyCodeHistory__c> newObjMap){

        // 物件コード履歴差分の登録
        this.insertPropertyCodeHistDiff(newObjs);
    }
        
    /** 削除前処理 */
    public void onBeforeDelete(PropertyCodeHistory__c[] oldObjs, Map<ID, PropertyCodeHistory__c> oldObjMap){
            
    }
        
    /** 削除後処理 */
    public void onAfterDelete(PropertyCodeHistory__c[] oldObjs, Map<ID, PropertyCodeHistory__c> oldObjMap){

        // 物件コード履歴差分の登録
        this.insertPropertyCodeHistDiff(oldObjs);
    }
        
    /** 復元後処理 */
    public void onUndelete(PropertyCodeHistory__c[] newObjs){
            
    }

    /**
    * 物件コード履歴差分の登録
    * @param PropertyCodeHistory__c[] propertyCodeHistAry 物件コード履歴差分
    */
    private void insertPropertyCodeHistDiff(PropertyCodeHistory__c[] propertyCodeHistAry) {

        // オブジェクト登録値
        PropertyCodeHistoryDifference__c insertPropertyCodeHistDiff;
        List<PropertyCodeHistoryDifference__c> insertPropertyCodeHistDiffList = new List<PropertyCodeHistoryDifference__c>();

        // 物件コード履歴差分の登録値を取得
        for (PropertyCodeHistory__c propertyCodeHist : propertyCodeHistAry) {

            insertPropertyCodeHistDiff = new PropertyCodeHistoryDifference__c(
                PropertyCodeHistId__c                 = PropertyCodeHist.Id                                // 物件コード履歴 ID
                , PropertyCodeHistIsDeleted__c        = PropertyCodeHist.IsDeleted                         // 物件コード履歴 削除
                , PropertyCodeHistName__c             = PropertyCodeHist.Name                              // 物件コード履歴 物件コード履歴番号
                , PropertyCodeHistCreatedDate__c      = PropertyCodeHist.CreatedDate                       // 物件コード履歴 作成日
                , PropertyCodeHistCreatedById__c      = PropertyCodeHist.CreatedById                       // 物件コード履歴 作成者 ID
                , PropertyCodeHistLastModifiedDate__c = PropertyCodeHist.LastModifiedDate                  // 物件コード履歴 最終更新日
                , PropertyCodeHistLastModifiedById__c = PropertyCodeHist.LastModifiedById                  // 物件コード履歴 最終更新者 ID
                , PropertyCodeHistSystemModstamp__c   = PropertyCodeHist.SystemModstamp                    // 物件コード履歴 System Modstamp 
                , Property__c                         = propertyCodeHist.Property__c                       // 物件
                , MaintenancePropertyCode__c          = propertyCodeHist.MaintenancePropertyCode__c        // メンテナンス物件コード
                , PropertyCode__c                     = propertyCodeHist.PropertyCode__c                   // 物件コード
                , HistoryProperty__c                  = propertyCodeHist.HistoryProperty__c                // 履歴物件
                , HistoryMaintenancePropertyCode__c   = propertyCodeHist.HistoryMaintenancePropertyCode__c // 履歴メンテナンス物件コード
                , HistoryPropertyCode__c              = propertyCodeHist.HistoryPropertyCode__c            // 履歴物件コード
                , HistoryImportDestination__c         = propertyCodeHist.HistoryImportDestination__c       // 履歴取込先
                , HistoryPropertyForeignID__c         = propertyCodeHist.HistoryPropertyForeignID__c       // 履歴物件外部ID
                , InformationUpdateDate__c            = propertyCodeHist.InformationUpdateDate__c          // 情報更新日
                , CrudCd__c                           = this.getCrudCd()                                   // クラッドコード
            );

            insertPropertyCodeHistDiffList.add(insertPropertyCodeHistDiff);
        }

        // 物件コード履歴差分の登録
        if (insertPropertyCodeHistDiffList.size() > 0) {
            SecureDML.secureInsert(insertPropertyCodeHistDiffList);
        }
    }

    /** 
    * クラッドコードの取得
    * @return クラッドコード（登録、更新："U"、削除："D"、その他：空文字）
    */
    private String getCrudCd() {

        String crudCd = CommonConst.STRING_EMPTY;

        if (Trigger.isInsert || Trigger.isUpdate) {
            crudCd = CommonConst.CRUD_CD_UPDATE;
        } else if (Trigger.isDelete) {
            crudCd = CommonConst.CRUD_CD_DELETE;
        }

        return crudCd;
    }
}