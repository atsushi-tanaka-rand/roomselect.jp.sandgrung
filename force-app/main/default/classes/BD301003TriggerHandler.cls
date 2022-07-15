// 建物トリガハンドラ
public with sharing class BD301003TriggerHandler {
    
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;
    /** 重複更新フラグ */
    public Static boolean isDuplicateUpdate = false;
    
    /** コンストラクタ */
    public BD301003TriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    /** 登録前処理 */
    public void onBeforeInsert(Building__c[] newObjs){
        
    }
    
    /** 登録後処理 */
    public void onAfterInsert(Building__c[] newObjs, Map<ID, Building__c> newObjMap){

        // 建物差分登録処理
        BuildingDifferenceInsert(newObjs, newObjMap);
        
        // 建物メンテナンス履歴
        MaintenanceHistoryInsert(newObjs, newObjMap);
        
        // 建物更新処理
        BuildingUpdate(newObjs, newObjMap);

        // 最新データの取得（※外部ID）
        Map<ID, Building__c> latestObjMap = this.selectBuildingAllItem(newObjMap.keySet());

        // 建物コード履歴の登録
        this.insertBuildingCdHist(latestObjMap.values());
    }
    
    /** 更新前処理 */
    public void onBeforeUpdate(Building__c[] oldObjs, Map<ID, Building__c> oldObjMap, Building__c[] newObjs, Map<ID, Building__c> newObjMap){
       
        //重複更新対応
        if (isDuplicateUpdate) {
            return;
        }
        
        // 建物メンテナンス履歴
        MaintenanceHistoryInsert(oldObjs, newObjMap);
        
        // 建物項目変更
        changeBuildingItem(newObjs);
    }
    
    /** 更新後処理 */
    public void onAfterUpdate(Building__c[] oldObjs, Map<ID, Building__c> oldObjMap, Building__c[] newObjs, Map<ID, Building__c> newObjMap){
       
        //重複更新対応
        if (isDuplicateUpdate) {
            return;
        }
        
        // 建物差分登録処理
        BuildingDifferenceInsert(oldObjs, newObjMap);
        
        // 条件完全一致物件を連絡
        this.ContactCondMatchProp(oldObjMap, newObjs);

        // 建物コード履歴の更新
        this.updBuildingCdHist(oldObjMap, newObjs);
    }
    
    /** 削除前処理 */
    public void onBeforeDelete(Building__c[] oldObjs, Map<ID, Building__c> oldObjMap){
          
        // 建物写真削除
        DeletePhoto(oldObjs, oldObjMap);

        // 建物差分登録処理
        BuildingDifferenceInsert(oldObjs, oldObjMap);

        // 建物コード履歴差分の登録
        // ※カスケード削除により建物コード履歴トリガーが起動しない為、明示的に作成
        this.insertBuildingCdHistDiff(oldObjMap.keySet());
    }
    
    /** 削除後処理 */
    public void onAfterDelete(Building__c[] oldObjs, Map<ID, Building__c> oldObjMap){
        
    }
    
    /** 復元後処理 */
    public void onUndelete(Building__c[] newObjs){
    }



    
    // *************************************************************************************************************************************
    // privateメソッド
    // *************************************************************************************************************************************

        
    // 建物項目変更
    private void changeBuildingItem(Building__c[] newObjs) {

        //※before処理で更新できるものはこちら
        
        for (Building__c newObj : newObjs) {
            
            // 更新時 かつ メンテナンス区分がnullでない場合(新規時はメンテナンス履歴作成はafter処理で行う)
            if (Trigger.isUpdate && newObj.MaintenanceType__c != null) {
                newObj.MaintenanceStaff__c         = null;
                newObj.MaintenanceType__c          = null;
                newObj.MaintenanceComment__c       = null;
            }
        }
    }
   
    
    // 建物更新処理
    private void BuildingUpdate(Building__c[] oldObjs, Map<ID, Building__c> newObjMap){
        
        //※after処理で更新するものはこちら
        
        List<Building__c> updateList = new List<Building__c>();
        
        for(Building__c oldObj : oldObjs){
            
            // 変数設定
            Boolean isAdd = false; //更新リスト追加フラグ
            building__c addBuilding = new Building__c(Id = oldObj.Id); //更新レコード
            
            // 新規登録かつ、建物オブジェクトのメンテナンス区分がnullではない場合更新対象とする
            if(Trigger.isInsert && newObjMap.get(oldObj.Id).MaintenanceType__c != null){
                isAdd = true;
                addBuilding.Maintenancetype__c    = null;
                addBuilding.MaintenanceComment__c = null;
                addBuilding.MaintenanceStaff__c   = null;
            }
            
            // 新規登録の場合、外部Idを設定するために更新対象とする(★★プロセスビルダーで行うと差分が作られてしまうためトリガに寄せました★★)
            if(Trigger.isInsert){
                isAdd = true;
                addBuilding.ForeignID__c  = newObjMap.get(oldObj.Id).ForeignIDAutoNumber__c;
            }
            
            // フラグが立っていれば更新対象に追加する
            if (isAdd) {
                updateList.add(addBuilding);
            }
        }
        
        // 空でなければ更新する
        if (!updateList.isEmpty()) {
            isDuplicateUpdate = true;  //重複更新フラグをTrueにする
            SecureDML.secureUpdate(updateList);
            isDuplicateUpdate = false; //重複更新フラグをFalseにする
        }
    }
    
        
    // 建物差分レコード追加(新バージョン)
    private void BuildingDifferenceInsert(Building__c[] oldObjs, Map<ID, Building__c> newObjMap){
        
        // 項目APIの取得
        // 建物オブジェクトの全項目を取得する。
        Schema.SObjectType sot1 = Schema.getGlobalDescribe().get('Building__c');  // SObjectType型で建物オブジェクトを取得
        Schema.DescribeSObjectResult dsr1 = sot1.getDescribe();  // DescribeSObjectResult型に変換
        Map<String, Schema.SObjectField> fsMap1 = dsr1.fields.getMap();  // Map型で建物オブジェクトの情報を取得する
        
        // 建物オブジェクトの全項目setを作成する
        Set<String> buildingFieldApiSet = new Set<String>();
        for (Schema.SObjectField sof : fsMap1.values()) {
            buildingFieldApiSet.add(sof.getDescribe().getName());
        }
        
        // 建物差分の全項目を取得する
        Schema.SObjectType sot2 = Schema.getGlobalDescribe().get('BuildingDifference__c');// SObjectType型で建物差分オブジェクトを取得する
        Schema.DescribeSObjectResult dsr2 = sot2.getDescribe();// DescribeSObjectResult型に変換
        Map<String, Schema.SObjectField> fsMap2 = dsr2.fields.getMap();// Map型で建物差分オブジェクトの情報を取得する
        
        
        // 建物差分レコードのListを作成。
        List<BuildingDifference__c> buildingDifferenceList = new List<BuildingDifference__c>();
        
        // oldを回す。
        for(Building__c oldObj : oldObjs){
            
            // ①の処理のために、建物差分をnewする。
            BuildingDifference__c addBuildingDifference = new BuildingDifference__c();
            
            // ① 建物と同じAPIを設定する。
            // 建物差分を回す。
            for (Schema.SObjectField sof : fsMap2.values()) {
                String fieldApi = sof.getDescribe().getName(); // 項目API名の取得
                Boolean isCustom =sof.getDescribe().isCustom();// 項目の型を取得(カスタム項目かどうか)
                
                //特定の項目の場合、処理を行わない
                if (fieldApi == 'ForeignIDAutoNumber__c' || //外部Id自動採番
                    fieldApi == 'ForeignID__c'                 //外部Id
                   ) {
                       continue;
                   }
                
                // もし建物オブジェクトのマップ型に項目APIが含まれており、カスタム項目であれば
                if(buildingFieldApiSet.contains(fieldApi) && isCustom){
                    addBuildingDifference.put (fieldApi, newObjMap.get(oldObj.Id).get(fieldApi)); // 建物差分に項目を設定する。
                }
            }
            // 標準項目系を設定する。
            addBuildingDifference.BuildingId__c               = newObjMap.get(oldObj.Id).Id;
            addBuildingDifference.BuildingOwnerId__c          = newObjMap.get(oldObj.Id).OwnerId;
            addBuildingDifference.BuildingIsDeleted__c        = newObjMap.get(oldObj.Id).IsDeleted;
            addBuildingDifference.BuildingName__c             = newObjMap.get(oldObj.Id).Name;
            addBuildingDifference.BuildingCreatedDate__c      = newObjMap.get(oldObj.Id).CreatedDate;
            addBuildingDifference.BuildingCreatedById__c      = newObjMap.get(oldObj.Id).CreatedById;
            addBuildingDifference.BuildingLastModifiedDate__c = newObjMap.get(oldObj.Id).LastModifiedDate;
            addBuildingDifference.BuildingSystemModstamp__c   = newObjMap.get(oldObj.Id).SystemModstamp;
            addBuildingDifference.BuildingLastModifiedById__c = newObjMap.get(oldObj.Id).LastModifiedById;
            
            // トリガが挿入イベント時、クラッドコードをCに変更する。
            if(Trigger.isInsert) {
                addBuildingDifference.CrudCd__c = 'C';
                
                // トリガ更新イベント時、クラッドコードをUに変更する。  
            } else if (Trigger.isUpdate) {
                addBuildingDifference.CrudCd__c = 'U';
                // トリガ削除イベント時、クラッドコードをDに変更する。
                
            } else if (Trigger.isDelete) {
                addBuildingDifference.CrudCd__c = 'D';
            }
            
            // add用の変数を建物差分リストへ追加
            buildingDifferenceList.add(addBuildingDifference);
            
        }
        // propertyDifferenceListが空でなければ、オブジェクトに入れる。
        if(!buildingDifferenceList.isEmpty()){
            SecureDML.secureInsert(buildingDifferenceList);
        }
    }
    
    
    
    // 建物メンテナンス履歴追加
    private void MaintenanceHistoryInsert(Building__c[] oldObjs, Map<ID, Building__c> newObjMap){
        
        // 建物メンテナンス履歴のリストを作成する。
        List<BuildingMaintenanceHistory__c> maintenanceHistoryList = new List<BuildingMaintenanceHistory__c>();
        
        // 建物oldを回す。
        for(Building__c oldObj : oldObjs){
    
            // 建物オブジェクトのメンテナンス区分がnullではない場合       
            if(newObjMap.get(oldObj.Id).MaintenanceType__c != null){
                
                // 建物メンテナンス履歴のadd用の関数
                BuildingMaintenanceHistory__c addMaintenanceHistory = new BuildingMaintenanceHistory__c(
                      Building__c           = newObjMap.get(oldObj.Id).Id
                    , MaintenanceType__c    = newObjMap.get(oldObj.Id).MaintenanceType__c
                    , MaintenanceComment__c = newObjMap.get(oldObj.Id).MaintenanceComment__c
                    , MaintenanceStaff__c   = newObjMap.get(oldObj.Id).MaintenanceStaff__c
                );
                // add用の関数をListに入れる。
                maintenanceHistoryList.add(addMaintenanceHistory);
            }
        }

        // maintenanceHistoryListが空でなければ、オブジェクトに入れる。
        if(!maintenanceHistoryList.isEmpty()){
            SecureDML.secureInsert(maintenanceHistoryList);
        }            

    }
    
 
    
    
    // 建物写真削除
    private void DeletePhoto(Building__c[] oldObjs, Map<ID, Building__c> newObjMap){
        
        // IdのListを用意する。
        List<Id> IdList = new List<Id>();
        
        // oldを回す。
        for(Building__c oldObj : oldObjs){
            // Idを追加。
            IdList.add(oldObj.Id);
        }
        
        //AmazonS3UtilのcallPhotoDeleteを呼び出す。
        AmazonS3Util.callOnlyBuildingPhotoDeleteAll(IdList);
    } 

    /**
    * 条件完全一致物件を連絡
    * @param  Map<ID, Building__c> oldObjMap 建物更新前
    * @param  Building__c[]        newObjs   建物更新後
    */
    private void contactCondMatchProp(Map<ID, Building__c> oldObjMap, Building__c[] newObjs) {

        // 実施チェック
        if (SystemConfig__c.getInstance().IsSkipBuildingCompareProcess__c) {
            return;
        }

        // 対象建物チェック
        Building__c oldBulding;
        Set<Id> chgBuldingIds = new Set<Id>();
        for(Building__c newObj : newObjs) {

            // 更新前値を取得
            oldBulding = new Building__c();
            if (oldObjMap.containskey(newObj.Id)) {
                oldBulding = oldObjMap.get(newObj.Id);
            }

            if (!this.isExecuteCondMatchProp(oldBulding, newObj)) {
                continue;
            }
            chgBuldingIds.add(newObj.Id);
        }

        // 条件完全一致バッチ実行処理
        this.registExactCondMatchBatExeProcess(chgBuldingIds);
    }

    /**
    * 条件完全一致バッチ実行処理
    * @param Set<Id> buldingIdSet 条件完全一致対象の建物ID
    */
    private void registExactCondMatchBatExeProcess(Set<Id> buldingIdSet) {

        // 処理対象の物件の取得
        List<Property__c> chgMatchPropList = this.selectMatchProperty(buldingIdSet);  
        if (chgMatchPropList.size() == 0) {
            return;
        }

        // 条件完全一致バッチ実行
        ExactConditionMatchBatchExecution__c ecmbeEntity;           // エンティティ
        List<ExactConditionMatchBatchExecution__c> registEcmbeList; // 登録リスト

        registEcmbeList = new List<ExactConditionMatchBatchExecution__c>();

        // 条件完全一致バッチ実行の登録値の取得
        for (Property__c chgMatchProp : chgMatchPropList) {
            ecmbeEntity = new ExactConditionMatchBatchExecution__c(
                Property__c     = chgMatchProp.Id
                , PropertyId__c = chgMatchProp.Id
            );
            registEcmbeList.add(ecmbeEntity);
        }

        // 条件完全一致物件実行の登録
        SecureDML.secureInsert(registEcmbeList, false);
    }

    /**
    * 条件完全一致物件の連絡実施チェック
    * @param  Building__c oldBuilding   建物更新前
    * @param  Building__c newBuilding 建物更新後
    * @return Boolean     true:実施する、false:実施しない
    */
    private Boolean isExecuteCondMatchProp(Building__c oldBuilding, Building__c newBuilding) {

        // 駅１
        if (oldBuilding.Station1__c != newBuilding.Station1__c
            && newBuilding.Station1__c != null) {
            return true;
        }

        // 駅２
        if (oldBuilding.Station2__c != newBuilding.Station2__c
            && newBuilding.Station2__c != null) {
            return true;
        }

        // 駅３
        if (oldBuilding.Station3__c != newBuilding.Station3__c
            && newBuilding.Station3__c != null) {
            return true;
        }

        // 中学校１
        if (oldBuilding.JuniorHighSchool1__c != newBuilding.JuniorHighSchool1__c
            && newBuilding.JuniorHighSchool1__c != null) {
            return true;
        }

        // 中学校２
        if (oldBuilding.JuniorHighSchool2__c != newBuilding.JuniorHighSchool2__c
            && newBuilding.JuniorHighSchool2__c != null) {
            return true;
        }

        // 中学校３
        if (oldBuilding.JuniorHighSchool3__c != newBuilding.JuniorHighSchool3__c
            && newBuilding.JuniorHighSchool3__c != null) {
            return true;
        }

        // 小学校１
        if (oldBuilding.PrimarySchool1__c != newBuilding.PrimarySchool1__c
            && newBuilding.PrimarySchool1__c != null) {
            return true;
        }

        // 小学校２
        if (oldBuilding.PrimarySchool2__c != newBuilding.PrimarySchool2__c
            && newBuilding.PrimarySchool2__c != null) {
            return true;
        }

        // 小学校３
        if (oldBuilding.PrimarySchool3__c != newBuilding.PrimarySchool3__c
            && newBuilding.PrimarySchool3__c != null) {
            return true;
        }
        
        // 徒歩１
        if (oldBuilding.StationWalkTime1__c != newBuilding.StationWalkTime1__c
            && newBuilding.StationWalkTime1__c != null) {
            return true;
        }

        // 徒歩２
        if (oldBuilding.StationWalkTime2__c != newBuilding.StationWalkTime2__c
            && newBuilding.StationWalkTime2__c != null) {
            return true;
        }

        // 徒歩３
        if (oldBuilding.StationWalkTime3__c != newBuilding.StationWalkTime3__c
            && newBuilding.StationWalkTime3__c != null) {
            return true;
        }

        // 地区
        if (oldBuilding.District__c != newBuilding.District__c
            && newBuilding.District__c != null) {
            return true;
        }

        // 築年数
        if (oldBuilding.BuildingAge__c != newBuilding.BuildingAge__c
            && newBuilding.BuildingAge__c != null) {
            return true;
        }
         
        // 木造、軽量鉄骨、鉄骨造、RC、SRC
        if (oldBuilding.Structure__c != newBuilding.Structure__c
            && (newBuilding.Structure__c == CommonConst.BUILDING_STRUCTURE_WOODEN
                || newBuilding.Structure__c == CommonConst.BUILDING_STRUCTURE_LIGHTWEIGHTSTEEL
                || newBuilding.Structure__c == CommonConst.BUILDING_STRUCTURE_STEEL
                || newBuilding.Structure__c == CommonConst.BUILDING_STRUCTURE_RC
                || newBuilding.Structure__c == CommonConst.BUILDING_STRUCTURE_SRC
               )
           ) {
            return true;
        }

        // 戸建て
        if (oldBuilding.PropertyType__c != newBuilding.PropertyType__c
            && newBuilding.PropertyType__c == CommonConst.BUILDING_PROPERTYTYPE_DETACHEDHOUSE) {
            return true;
        }

        return false;
    }

    /**
    * 条件完全一致対象の物件を取得
    * @param  set<Id> chgBuldingIdSet 更新建物ID
    * @return List<Property__c> 条件完全一致対象対象物件
    */
    private List<Property__c> selectMatchProperty(set<Id> chgBuldingIdSet) {

        // 物件の取得
        List<Property__c> chgMatchPropList = 
            [SELECT Id
             FROM Property__c
             WHERE Building__c IN :chgBuldingIdSet
                   AND LiveStatus__c IN (:CommonConst.PROPERTY_LIVESTATUS_VACANCY
                                         , :CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE)
            ];

        // 初期化チェック
        if (chgMatchPropList.isEmpty()) {
            chgMatchPropList = new List<Property__c>();
        }

        return chgMatchPropList;
    }

    /**
    * 建物コード履歴の登録
    * @param Building__c[] buildingAry 建物
    */
    private void insertBuildingCdHist(Building__c[] buildingAry) {

        // オブジェクト登録値
        BuildingCodeHistory__c insertBuildingCdHist;
        List<BuildingCodeHistory__c> insertBuildingCdHistList = new List<BuildingCodeHistory__c>();

        // 建物コード履歴の登録値を取得
        for (Building__c building : buildingAry) {

            insertBuildingCdHist = new BuildingCodeHistory__c (
                Building__c                         = building.Id                         // 建物
                , HistoryBuilding__c                = building.Id                         // 履歴建物
                , HistoryMaintenanceBuildingCode__c = building.MaintenanceBuildingCode__c // 履歴メンテナンス建物コード
                , HistoryImportDestination__c       = building.ImportType__c              // 履歴取込先
                , HistoryBuildingForeignID__c       = building.ForeignID__c               // 履歴建物外部ID
                , InformationUpdateDate__c          = CommonUtil.getNow()                 // 情報更新日
            );
            
            insertBuildingCdHistList.add(insertBuildingCdHist);
        }

        // 建物コード履歴の登録
        if (insertBuildingCdHistList.size() > 0) {
            SecureDML.secureInsert(insertBuildingCdHistList);
        }
    }

    
    /**
    * 建物コード履歴の更新
    * @param Map<ID, Building__c> oldObjMap 建物更新前
    * @param Building__c[]        newObjs   建物更新後
    */
    private void updBuildingCdHist(Map<ID, Building__c> oldObjMap, Building__c[] newObjs) {

        // 更新対象の建物IDの取得
        Set<Id> updBuildingIdSet = new Set<Id>();
        for (Building__c newObj : newObjs) {

            // 更新対象チェック
            if (!isUpdBuildingCdHistsBuilding(oldObjMap.get(newObj.Id), newObj)) {
                continue;
            }

            updBuildingIdSet.add(newObj.Id);
        }

        // 建物コード履歴の取得と更新
        // ※差分テーブルを作成する為、親に紐づく全レコードを更新する
        List<BuildingCodeHistory__c> buildingCdHistList = this.selectBuildingCdHist(updBuildingIdSet);
        for (BuildingCodeHistory__c buildingCdHist : buildingCdHistList) {

            // 親レコードは履歴情報を更新
            if (buildingCdHist.Building__c == buildingCdHist.HistoryBuilding__c) {
                buildingCdHist.HistoryMaintenanceBuildingCode__c = null;
                buildingCdHist.HistoryImportDestination__c       = CommonConst.PROPERTY_IMPORTTYPE_MANUAL;
            }
        }

        // 建物コード履歴の更新
        if (buildingCdHistList.size() > 0) {
            SecureDML.secureUpdate(buildingCdHistList);
        }
    }

    /**
    * 建物コード履歴の更新対象物件チェック
    * @param Building__c oldObj 建物更新前
    * @param Building__c newObj 建物更新後
    * @return Boolean true:更新対象、false:更新対象外
    */
    private Boolean isUpdBuildingCdHistsBuilding(Building__c oldObj, Building__c newObj) {

        // 建物登録画面で取込先が"手動"に変更された場合
        if ((oldObj.ImportType__c != newObj.ImportType__c && newObj.ImportType__c == CommonConst.PROPERTY_IMPORTTYPE_MANUAL)
            && (oldObj.MaintenanceBuildingCode__c != newObj.MaintenanceBuildingCode__c && newObj.MaintenanceBuildingCode__c == null)
           ) {
            return true;
        }

        return false;
    }
    
    /**
    * 建物コード履歴差分の登録
    * @param Set<Id> buildingIdSet 建物ID
    */
    private void insertBuildingCdHistDiff(Set<Id> buildingIdSet) {

        // オブジェクト登録値
        BuildingCodeHistoryDifference__c insertBuildingCdHistDiff;
        List<BuildingCodeHistoryDifference__c> insertBuildingCdHistDiffList = new List<BuildingCodeHistoryDifference__c>();

        // 建物コード履歴の取得
        List<BuildingCodeHistory__c> buildingCdHistList = this.selectBuildingCdHist(buildingIdSet);

        // 建物コード履歴差分の登録値を取得
        for (BuildingCodeHistory__c buildingCdHist : buildingCdHistList) {

            insertBuildingCdHistDiff = new BuildingCodeHistoryDifference__c(
                BuildingCodeHistId__c                 = buildingCdHist.Id                                // 建物コード履歴 ID
                , BuildingCodeHistIsDeleted__c        = buildingCdHist.IsDeleted                         // 建物コード履歴 削除
                , BuildingCodeHistName__c             = buildingCdHist.Name                              // 建物コード履歴 建物コード履歴番号
                , BuildingCodeHistCreatedDate__c      = buildingCdHist.CreatedDate                       // 建物コード履歴 作成日
                , BuildingCodeHistCreatedById__c      = buildingCdHist.CreatedById                       // 建物コード履歴 作成者 ID
                , BuildingCodeHistLastModifiedDate__c = buildingCdHist.LastModifiedDate                  // 建物コード履歴 最終更新日
                , BuildingCodeHistLastModifiedById__c = buildingCdHist.LastModifiedById                  // 建物コード履歴 最終更新者 ID
                , BuildingCodeHistSystemModstamp__c   = buildingCdHist.SystemModstamp                    // 建物コード履歴 System Modstamp 
                , Building__c                         = buildingCdHist.Building__c                       // 建物
                , MaintenanceBuildingCode__c          = buildingCdHist.MaintenanceBuildingCode__c        // メンテナンス建物コード
                , HistoryBuilding__c                  = buildingCdHist.HistoryBuilding__c                // 履歴建物
                , HistoryMaintenanceBuildingCode__c   = buildingCdHist.HistoryMaintenanceBuildingCode__c // 履歴メンテナンス建物コード
                , HistoryImportDestination__c         = buildingCdHist.HistoryImportDestination__c       // 履歴取込先
                , HistoryBuildingForeignID__c         = buildingCdHist.HistoryBuildingForeignID__c       // 履歴建物外部ID
                , InformationUpdateDate__c            = buildingCdHist.InformationUpdateDate__c          // 情報更新日
                , CrudCd__c                           = CommonConst.CRUD_CD_DELETE                       // クラッドコード
            );

            insertBuildingCdHistDiffList.add(insertBuildingCdHistDiff);
        }

        // 建物コード履歴差分の登録
        if (insertBuildingCdHistDiffList.size() > 0) {
            SecureDML.secureInsert(insertBuildingCdHistDiffList);
        }
    }

    /**
    * 建物コード履歴の取得
    * @param Set<Id> buildingIdSet 建物ID
    * @return List<BuildingCodeHistory__c> 建物コード履歴
    */
    private List<BuildingCodeHistory__c> selectBuildingCdHist(Set<Id> buildingIdSet) {

        // 建物コード履歴の取得
        List<BuildingCodeHistory__c> buildingCdHistList = 
            [SELECT Id                                  // ID
                    , IsDeleted                         // 削除
                    , Name                              // 番号
                    , CreatedDate                       // 作成日
                    , CreatedById                       // 作成者 ID
                    , LastModifiedDate                  // 最終更新日
                    , LastModifiedById                  // 最終更新者 ID
                    , SystemModstamp                    // System Modstamp 
                    , Building__c                       // 建物
                    , MaintenanceBuildingCode__c        // メンテナンス建物コード
                    , HistoryBuilding__c                // 履歴建物
                    , HistoryMaintenanceBuildingCode__c // 履歴メンテナンス建物コード
                    , HistoryImportDestination__c       // 履歴取込先
                    , HistoryBuildingForeignID__c       // 履歴建物外部ID
                    , InformationUpdateDate__c          // 情報更新日
             FROM BuildingCodeHistory__c
             WHERE Building__c = :buildingIdSet];
        
        // 初期化処理
        if (buildingCdHistList.isEmpty()) {
            buildingCdHistList = new List<BuildingCodeHistory__c>();
        }

        return buildingCdHistList;
    }
    
    /**
     * 建物の全項目の取得
     * @param Set<Id> condIdSet 建物.Id
     * @return Map<ID, Property__c> 建物（key:建物.Id、value:建物）
     */
    private Map<ID, Building__c> selectBuildingAllItem(Set<Id> condIdSet) {

        // 建物の項目名の取得
        List<String> itemList = New List<String>();
        Map<String, Schema.sObjectField> fieldMap = Building__c.SObjectType.getDescribe().fields.getMap();
        for (String field: fieldMap.keySet()) {
            itemList.add(field);
        }
        String items =  String.join(itemList, ',');

        // クエリの作成
        String sql = ' SELECT ' + items
                   + ' FROM Building__c'
                   + ' WHERE Id = :condIdSet';

        // クエリの実行
        List<Building__c> buildingList = Database.query(sql);
        
        // 実行結果の取得
        Map<ID, Building__c> buildingMap = new Map<ID, Building__c>();
        if (!buildingList.isEmpty()) {
            buildingMap = new Map<ID, Building__c>(buildingList);
        }

        return buildingMap;
    }
}