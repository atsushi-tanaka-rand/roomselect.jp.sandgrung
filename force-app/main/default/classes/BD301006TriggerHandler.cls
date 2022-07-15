// 建物コード履歴トリガハンドラ
public with sharing class BD301006TriggerHandler {

    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;

    /** コンストラクタ */
    public BD301006TriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    /** 登録前処理 */
    public void onBeforeInsert(BuildingCodeHistory__c[] newObjs){
 
    }
        
    /** 登録後処理 */
    public void onAfterInsert(BuildingCodeHistory__c[] newObjs, Map<ID, BuildingCodeHistory__c> newObjMap){

        // 建物コード履歴差分の登録
        this.insertBuildingCodeHistDiff(newObjs);
    }
        
    /** 更新前処理 */
    public void onBeforeUpdate(BuildingCodeHistory__c[] oldObjs, Map<ID, BuildingCodeHistory__c> oldObjMap, BuildingCodeHistory__c[] newObjs, Map<ID, BuildingCodeHistory__c> newObjMap){

    }
        
    /** 更新後処理 */
    public void onAfterUpdate(BuildingCodeHistory__c[] oldObjs, Map<ID, BuildingCodeHistory__c> oldObjMap, BuildingCodeHistory__c[] newObjs, Map<ID, BuildingCodeHistory__c> newObjMap){

        // 建物コード履歴差分の登録
        this.insertBuildingCodeHistDiff(newObjs);  
    }
        
    /** 削除前処理 */
    public void onBeforeDelete(BuildingCodeHistory__c[] oldObjs, Map<ID, BuildingCodeHistory__c> oldObjMap){
            
    }
        
    /** 削除後処理 */
    public void onAfterDelete(BuildingCodeHistory__c[] oldObjs, Map<ID, BuildingCodeHistory__c> oldObjMap){

        // 建物コード履歴差分の登録
        this.insertBuildingCodeHistDiff(oldObjs);
    }
        
    /** 復元後処理 */
    public void onUndelete(BuildingCodeHistory__c[] newObjs){
            
    }

    /**
    * 建物コード履歴差分の登録
    * @param BuildingCodeHistory__c[] buildingCodeHistAry 建物コード履歴
    */
    private void insertBuildingCodeHistDiff(BuildingCodeHistory__c[] buildingCodeHistAry) {

        // オブジェクト登録値
        BuildingCodeHistoryDifference__c insertBuildingCodeHistDiff;
        List<BuildingCodeHistoryDifference__c> insertBuildingCodeHistDiffList = new List<BuildingCodeHistoryDifference__c>();

        // 建物コード履歴差分の登録値を取得
        for (BuildingCodeHistory__c buildingCodeHist : buildingCodeHistAry) {

            insertBuildingCodeHistDiff = new BuildingCodeHistoryDifference__c(
                BuildingCodeHistId__c                 = buildingCodeHist.Id                                // 建物コード履歴 ID
                , BuildingCodeHistIsDeleted__c        = buildingCodeHist.IsDeleted                         // 建物コード履歴 削除
                , BuildingCodeHistName__c             = buildingCodeHist.Name                              // 建物コード履歴 建物コード履歴番号
                , BuildingCodeHistCreatedDate__c      = buildingCodeHist.CreatedDate                       // 建物コード履歴 作成日
                , BuildingCodeHistCreatedById__c      = buildingCodeHist.CreatedById                       // 建物コード履歴 作成者 ID
                , BuildingCodeHistLastModifiedDate__c = buildingCodeHist.LastModifiedDate                  // 建物コード履歴 最終更新日
                , BuildingCodeHistLastModifiedById__c = buildingCodeHist.LastModifiedById                  // 建物コード履歴 最終更新者 ID
                , BuildingCodeHistSystemModstamp__c   = buildingCodeHist.SystemModstamp                    // 建物コード履歴 System Modstamp 
                , Building__c                         = buildingCodeHist.Building__c                       // 建物
                , MaintenanceBuildingCode__c          = buildingCodeHist.MaintenanceBuildingCode__c        // メンテナンス建物コード
                , HistoryBuilding__c                  = buildingCodeHist.HistoryBuilding__c                // 履歴建物
                , HistoryMaintenanceBuildingCode__c   = buildingCodeHist.HistoryMaintenanceBuildingCode__c // 履歴メンテナンス建物コード
                , HistoryImportDestination__c         = buildingCodeHist.HistoryImportDestination__c       // 履歴取込先
                , HistoryBuildingForeignID__c         = buildingCodeHist.HistoryBuildingForeignID__c       // 履歴建物外部ID
                , InformationUpdateDate__c            = buildingCodeHist.InformationUpdateDate__c          // 情報更新日
                , CrudCd__c                           = this.getCrudCd()                                   // クラッドコード
            );

            insertBuildingCodeHistDiffList.add(insertBuildingCodeHistDiff);
        }

        // 建物コード履歴差分の登録
        if (insertBuildingCodeHistDiffList.size() > 0) {
            SecureDML.secureInsert(insertBuildingCodeHistDiffList);
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