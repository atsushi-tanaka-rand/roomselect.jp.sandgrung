// 物件トリガハンドラ
public with sharing class BD301002TriggerHandler {
    
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;
    /** 重複更新フラグ */
    public Static boolean isDuplicateUpdate = false;
    
    /** 差分作成以外スキップフラグ  */
    public Static boolean isOnlyCreateDifference = false; //処理を軽くしたい場合、更新時、差分作成以外をスキップさせる
    
    
    /** コンストラクタ */
    public BD301002TriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    
    
    
    /** 登録前処理 */
    public void onBeforeInsert(Property__c[] newObjs){
        
        // 物件項目変更
        changePropertyItem(newObjs);
    }
    
    
    
    
    /** 登録後処理 */
    public void onAfterInsert(Property__c[] newObjs, Map<ID, Property__c> newObjMap){
        
        // 物件差分登録
        PropertyDifferenceInsert(newObjs, newObjMap);
        
        // 物件メンテナンス履歴登録
        PropertyMaintenanceHistoryInsert(newObjs, newObjMap);
        
        // ポータルサイト掲載物件追加
        PortalSitePostingPropertyInsert(newObjs, newObjMap);
        
        // 物件更新
        PropertyUpdateProccesing(newObjs, newObjMap);

        // 条件完全一致物件を連絡
        this.contactCondMatchProp(new Map<ID, Property__c>(), newObjs);
        
        // 空室予約物件を連絡
        this.contactVacancyReservationProp(new Map<Id, Property__c>(), newObjs);

        // 最新データの取得（※外部ID、物件コードの為）
        Map<ID, Property__c> latestObjMap = this.selectPropertyAllItem(newObjMap.keySet());

        // 物件コード履歴の登録
        this.insertPropertyCdHist(latestObjMap.values());
    }
    
    
    
    /** 更新前処理 */
    public void onBeforeUpdate(Property__c[] oldObjs, Map<ID, Property__c> oldObjMap, Property__c[] newObjs, Map<ID, Property__c> newObjMap){
        
        // 重複更新対応
        if (isDuplicateUpdate) {
            return;
        }
        
        // 差分作成以外の処理
        if ( !isOnlyCreateDifference ) {
            
            // 物件メンテナンス履歴登録
            PropertyMaintenanceHistoryInsert(oldObjs,newObjMap);
            
            // 物件項目変更
            changePropertyItem(newObjs);
            
        }
    }
    
    
    /** 更新後処理 */
    public void onAfterUpdate(Property__c[] oldObjs, Map<ID, Property__c> oldObjMap, Property__c[] newObjs, Map<ID, Property__c> newObjMap){

        //重複更新対応
        if (isDuplicateUpdate) {
            return;
        }
        
        // 物件差分登録
        PropertyDifferenceInsert(oldObjs,newObjMap);

        // 差分作成以外の処理
        if ( !isOnlyCreateDifference ) {
            
            // ポータルサイト掲載物件追加
            PortalSitePostingPropertyInsert(oldObjs, newObjMap);
            
            // ポータルサイト掲載物件削除
            PortalSitePostingPropertyDelete(oldObjs,newObjMap); 
            
        }

        // 空室予約物件を連絡
        this.contactVacancyReservationProp(oldObjMap, newObjs);

        // 空き物件無しに更新
        this.updNoExistsFreeFloorPlan(oldObjMap, newObjs);

        // 条件完全一致物件を連絡
        this.contactCondMatchProp(oldObjMap, newObjs);

        // 物件コード履歴の更新
        this.updPropertyCdHist(oldObjMap, newObjs);
    }
    
    
    
    /** 削除前処理 */
    public void onBeforeDelete(Property__c[] oldObjs, Map<ID, Property__c> oldObjMap){
        
        // ポータルサイト掲載物件削除
        PortalSitePostingPropertyDelete(oldObjs,oldObjMap);
        
        // 物件写真削除
        DeletePhoto(oldObjs,oldObjMap);

        // 物件差分登録
        PropertyDifferenceInsert(oldObjs,oldObjMap);

        // 物件コード履歴差分の登録
        // ※カスケード削除により物件コード履歴トリガーが起動しない為、明示的に作成
        this.insertPropertyCdHistDiff(oldObjMap.keySet());
    }
    
    
    /** 削除後処理 */
    public void onAfterDelete(Property__c[] oldObjs, Map<ID, Property__c> oldObjMap){
        
        // 空室予約物件を空室ありに更新
        this.updExistsFreeFloorPlanToDelete(oldObjs);
    }
    
    
    /** 復元後処理 */
    public void onUndelete(Property__c[] newObjs){
        
    }
    
    
    
    // *******************************************************************************************************************************************
    // privateメソッド
    // *******************************************************************************************************************************************
    
    // 物件項目変更
    private void changePropertyItem(Property__c[] newObjs) {

        //※before処理で更新できるものはこちら
        
        for (Property__c newObj : newObjs) {
            
            //居住中なら
            if (newObj.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_RESIDENT) {
                
                //Web公開を"しない"に設定する
                newObj.WebPublishing__c = CommonConst.PROPERTY_WEBPUBLISHING_NO;
                
                //パノラマ掲載店舗をnullに設定する
                newObj.AtHomePanoramaShop__c = null;
                newObj.HomesPanoramaShop__c  = null;
                newObj.SuumoPanoramaShop__c  = null;
            }
            
            // 更新時 かつ メンテナンス区分がnullでない場合(新規時はメンテナンス履歴作成はafter処理で行う)
            if (Trigger.isUpdate && newObj.MaintenanceType__c != null) {
                newObj.MaintenanceStartDateTime__c = null;
                newObj.MaintenanceEndDateTime__c   = null;
                newObj.MaintenanceAction__c        = null;
                newObj.MaintenanceStaff__c         = null;
                newObj.MaintenanceType__c          = null;
                newObj.MaintenanceCommentArea__c   = null;
            }
        }
    }
    
    
    
    
    // 物件更新処理
    private void PropertyUpdateProccesing(Property__c[] oldObjs, Map<ID, Property__c> newObjMap){
        
        //※after処理でないとIdなどがありません　その情報を利用する更新処理はこちらに記載しています
        
        
        List<Property__c> updateList = new List<Property__c>();
        
        for(Property__c oldObj : oldObjs){
            
            // 変数宣言
            Boolean isAdd = false;//追加フラグ
            Property__c addProperty = new Property__c(Id = oldObj.Id);//更新する物件
            
            // 新規時、外部Idを設定するために更新対象とする(★★プロセスビルダーで行うと差分が作られてしまうためトリガに寄せました★★)
            if(Trigger.isInsert){
                isAdd = true;
                addProperty.ForeignID__c  = newObjMap.get(oldObj.Id).ForeignIDAutoNumber__c;
            }
            
            
            // 新規時、メンテナンス区分がnullでない場合(更新時はメンテナンス履歴作成はbefore処理で行う)
            if (Trigger.isInsert && newObjMap.get(oldObj.Id).MaintenanceType__c != null) {
                isAdd = true;
                addProperty.MaintenanceStartDateTime__c = null;
                addProperty.MaintenanceEndDateTime__c   = null;
                addProperty.MaintenanceAction__c        = null;
                addProperty.MaintenanceStaff__c         = null;
                addProperty.MaintenanceType__c          = null;
                addProperty.MaintenanceCommentArea__c   = null;
            }
            
            //追加する
            if (isAdd) {
                updateList.add(addProperty);
            }
        }
        
        // 空でなければ更新する
        if (!updateList.isEmpty()) {
            isDuplicateUpdate = true;  //重複更新フラグをTrueにする
            SecureDML.secureUpdate(updateList);
            isDuplicateUpdate = false; //重複更新フラグをFalseにする
        }
        
    }
    
    
    
    
    // 物件メンテナンス履歴登録処理
    private void PropertyMaintenanceHistoryInsert(Property__c[] oldObjs, Map<ID, Property__c> newObjMap){
        // insert時: 物件Idが必要なので、after処理で行い、物件はupdateする
        // update時: 物件Idはあるので、　before処理で行い、物件はupdateしない
        
        
        
        // 物件メンテナンス履歴 のリストをnewする。
        List<PropertyMaintenanceHistory__c> MaintenanceHistoryList = new List<PropertyMaintenanceHistory__c>();
        
        // oldを回す
        for(Property__c oldObj : oldObjs){
            
            //メンテナンス区分がnullではない場合
            if(newObjMap.get(oldObj.Id).MaintenanceType__c != null){
                
                PropertyMaintenanceHistory__c AddMaintenceHistory = new PropertyMaintenanceHistory__c (
                    Property__c                 = newObjMap.get(oldObj.Id).Id
                    , MaintenanceType__c          = newObjMap.get(oldObj.Id).MaintenanceType__c
                    , MaintenanceCommentArea__c   = newObjMap.get(oldObj.Id).MaintenanceCommentArea__c
                    , MaintenanceStartDateTime__c = newObjMap.get(oldObj.Id).MaintenanceStartDateTime__c
                    , MaintenanceEndDateTime__c   = newObjMap.get(oldObj.Id).MaintenanceEndDateTime__c
                    , MaintenanceStaff__c         = newObjMap.get(oldObj.Id).MaintenanceStaff__c
                    , MaintenanceAction__c        = newObjMap.get(oldObj.Id).MaintenanceAction__c
                );
                // 物件メンテナンス履歴のリストにaddを行う。
                MaintenanceHistoryList.add(AddMaintenceHistory);
            }
            
        }
        
        // 物理メンテナンス履歴オブジェクトにinsertを行う。
        if(!MaintenanceHistoryList.isEmpty()){
            SecureDML.secureInsert(MaintenanceHistoryList);
        }
    }
    
    
    
    
    
    // 物件差分登録
    private void PropertyDifferenceInsert(Property__c[] oldObjs, Map<ID, Property__c> newObjMap){
        
        // 項目APIの取得
        // 物件オブジェクトの全項目を取得する
        Schema.SObjectType sot1 = Schema.getGlobalDescribe().get('Property__c');  // SObjectType型で物件オブジェクトを取得
        Schema.DescribeSObjectResult dsr1 = sot1.getDescribe();  // DescribeSObjectResult型に変換
        Map<String, Schema.SObjectField> fsMap1 = dsr1.fields.getMap();  // Map型で物件オブジェクトの情報を取得する
        
        // 物件オブジェクトの全項目setを作成する
        Set<String> propertyFieldApiSet = new Set<String>();
        for (Schema.SObjectField sof : fsMap1.values()) {
            propertyFieldApiSet.add(sof.getDescribe().getName());
        }
        
        // 物件差分オブジェクトの全項目を取得する
        Schema.SObjectType sot2 = Schema.getGlobalDescribe().get('PropertyDifference__c');// SObjectType型で物件差分オブジェクトを取得する
        Schema.DescribeSObjectResult dsr2 = sot2.getDescribe();// DescribeSObjectResult型に変換
        Map<String, Schema.SObjectField> fsMap2 = dsr2.fields.getMap();// Map型で物件差分オブジェクトの情報を取得する
        
        // 物件差分オブジェクトの全項目Listを作成する
        List<PropertyDifference__c> propertyDifferenceList = new List<PropertyDifference__c>();
        
        // oldを回す
        for(Property__c oldObj : oldObjs){
            
            // ①の処理のために、物件差分をnewする。
            PropertyDifference__c addPropertyDifference = new PropertyDifference__c();
            
            // ①物件と同じAPIを設定する。
            for (Schema.SObjectField sof : fsMap2.values()) {
                String fieldApi = sof.getDescribe().getName();// 項目Api名の取得
                Boolean isCustom = sof.getDescribe().isCustom();// 項目の型を取得(カスタム項目か確認)
                
                
                // 特定の項目の場合処理を実施しない。
                if(fieldApi == 'ForeignIDAutoNumber__c' || // 外部Id自動採番
                   fieldApi == 'ForeignID__c'              //外部id
                  ){
                      continue;
                  }
                
                // もし、物件オブジェクトのMapに項目APIが含まれており、カスタム項目であれば
                if(propertyFieldApiSet.contains(fieldApi) && isCustom)  {
                    addPropertyDifference.put(fieldApi, newObjMap.get(oldObj.Id).get(fieldApi)); // 物件差分に項目を設定する。
                }
            }
            // 標準項目を設定する。
            addPropertyDifference.PropertyId__c               = newObjMap.get(oldObj.Id).Id;
            addPropertyDifference.PropertyIsDeleted__c        = newObjMap.get(oldObj.Id).IsDeleted;
            addPropertyDifference.PropertyName__c             = newObjMap.get(oldObj.Id).Name;
            addPropertyDifference.PropertyCreatedDate__c      = newObjMap.get(oldObj.Id).CreatedDate;
            addPropertyDifference.PropertyCreatedById__c      = newObjMap.get(oldObj.Id).CreatedById;
            addPropertyDifference.PropertySystemModstamp__c   = newObjMap.get(oldObj.Id).SystemModstamp;
            addPropertyDifference.PropertyLastModifiedById__c = newObjMap.get(oldObj.Id).LastModifiedById;
            addPropertyDifference.PropertyLastModifiedDate__c = newObjMap.get(oldObj.Id).LastModifiedDate;
            

            // トリガが挿入イベント時、クラッドコードをCに変更する。
            if(Trigger.isInsert) {
                addPropertyDifference.CrudCd__c = 'C';
                
                // トリガ更新イベント時、クラッドコードをUに変更する。  
            } else if (Trigger.isUpdate) {
                addPropertyDifference.CrudCd__c = 'U';
                // トリガ削除イベント時、クラッドコードをDに変更する。
                
            } else if (Trigger.isDelete) {
                addPropertyDifference.CrudCd__c = 'D';
            }
            // add用の変数を物件差分リストへ追加
            propertyDifferenceList.add(addPropertyDifference);
        }
        // propertyDifferenceListが空でなければ、オブジェクトに入れる。
        if(!propertyDifferenceList.isEmpty()){
            SecureDML.secureInsert(propertyDifferenceList);
        }  
    }
    
    
    
    // 物件写真削除
    private void DeletePhoto(Property__c[] oldObjs, Map<ID, Property__c> newObjMap){
        
        // IdのListを用意する。
        List<Id> IdList = new List<Id>();
        
        // oldを回す。
        for(Property__c oldObj : oldObjs){
            // Idを追加。
            IdList.add(oldObj.Id);
        }
        
        //AmazonS3UtilのcallPhotoDeleteを呼び出す。
        AmazonS3Util.callPropertyPhotoDeleteAll(IdList);
    }
    
    
    
    
    // ポータルサイト掲載物件登録
    private void PortalSitePostingPropertyInsert (Property__c[] oldObjs, Map<ID, Property__c> newObjMap){
        
        
        // 対象の洗い出し
        List<Property__c> targetList = new List<Property__c>();

        //再販対応 追加 Start
        Boolean isOpetionPortal = SystemConfig__c.getInstance().UseAuthority_Portal__c;//ポータル権限取得
        //再販対応 追加 End
        for (Property__c oldObj : oldObjs) {

            if (Trigger.isInsert){         //作成時
                
                // Web公開が"する"なら対象
                if(newObjMap.get(oldObj.Id).WebPublishing__c == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS ){
                    targetList.add(oldObj);
                }
                
            } else if(Trigger.isUpdate) {  //更新時
                
                // Web公開が"しない"またはnull→"する"なら対象
                if((oldObj.WebPublishing__c                   == CommonConst.PROPERTY_WEBPUBLISHING_NO ||
                    oldObj.WebPublishing__c                   == null )                                &&
                   newObjMap.get(oldObj.Id).WebPublishing__c == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS){

                    targetList.add(oldObj);
                }
            }
        }
        if (targetList.isEmpty()) {
            return;
        }
        
        
        // 物件_地区Mapの作成
        Set<Id> IdSet = new Set<Id>();// 物件IdのSetを用意する
        for(Property__c target : targetList){
            IdSet.add(target.Id);
        }
        Map<Id,Property__c> properyMap = new Map<Id,Property__c>([SELECT Id, Building__r.District__c FROM property__c // idと地区を取得し、Mapに入れる
                                                                  WHERE Id IN :IdSet
                                                                 ]);
        
        
        // 地区別_メンテナンス条件Mapの作成
        List<AreaMaintenanceCondition__c> areaMaintenanceList = [SELECT  PropertyAmountLowerLimit__c //取扱い物件 金額(下限)
                                                                       , PropertyAmountUpperLimit__c //取扱い物件 金額(上限)
                                                                       , District__c
                                                                 FROM  AreaMaintenanceCondition__c];
        
        Map<String, AreaMaintenanceCondition__c> areaMaintenanceMap = new Map<String, AreaMaintenanceCondition__c>();
        for (AreaMaintenanceCondition__c area: areaMaintenanceList) {
            areaMaintenanceMap.put(area.District__c, area);
        }
        
        
        // 対象の洗い出し sono2　（地区別メンテナンス条件に当てはまっていなければ除外）
        List<Property__c> targetList2 = new List<Property__c>();
        for(Property__c target : targetList){
            
            String district = properyMap.get(target.Id).Building__r.District__c; //物件の地区
            
            if (String.isBlank(district)) {
                continue; //地区がなければ対象外
            }
            
            AreaMaintenanceCondition__c amc = areaMaintenanceMap.get(district); //地区別メンテナンス条件
            
            if (amc != null && //地区別メンテナンス条件があり、
                ( (amc.PropertyAmountLowerLimit__c != null && newObjMap.get(target.Id).RentFee__c < amc.PropertyAmountLowerLimit__c) || 
                  (amc.PropertyAmountUpperLimit__c != null && newObjMap.get(target.Id).RentFee__c > amc.PropertyAmountUpperLimit__c)
                 )
               ) {
                   continue; //上限や下限を超えていれば対象外 
               }
            
            targetList2.add(target); //対象に追加
        }
        
        
        
        // 物件_店舗Map作成
        List<Shop__c> shopList = [SELECT Id, PortalSitePostingDistrict__c
                                  FROM Shop__c
                                  LIMIT :CommonConst.GOVERNOR_SELECT_LIMIT]; // 全店舗を取得する
        Map<Id, List<Id>> properyShopMap = new Map<Id, List<Id>>(); // 物件店舗Mapをnewする
        
        for(Property__c target : targetList2){
            properyShopMap.put(target.Id, new List<Id>()); // Mapを初期化
            
            for(Shop__c shop : shopList){ // 全店舗
                if(shop.PortalSitePostingDistrict__c != null ){
                       if(shop.PortalSitePostingDistrict__c // 店舗のポータル掲載地区の中に、
                          .split(';').contains(properyMap.get(target.Id).Building__r.District__c) // 物件の地区（物件_店舗Map）があるなら
                         ){
                             properyShopMap.get(target.Id).add(shop.Id); // 物件_店舗Mapに店舗のIdを追加する。
                         }
                   }
            }
        }
        
        //既存のポータル連携物件を取得する
        List<PortalSitePostingProperty__c> portalSitePropertyList = [SELECT Shop__c, Property__c FROM PortalSitePostingProperty__c 
                                                                     WHERE  Property__c IN :IdSet];
        
        
        //物件_店舗Map から、既存のポータル連携物件に存在しているものを削除する
        for (PortalSitePostingProperty__c p: portalSitePropertyList) { //ポータルサイトごと
            
            List<Id> shopIdList = properyShopMap.get(p.Property__c);
            
            //店舗にポータル連携物件がすでに存在していれば、追加するリストから除去
            if ( shopIdList.contains(p.Shop__c) ) {
                Integer index = shopIdList.indexOf(p.Shop__c);
                shopIdList.remove(index);
            }
        }
        

        // insertするポータルサイト掲載物件 を作成する
        List<PortalSitePostingProperty__c> portalSiteList = new List<PortalSitePostingProperty__c>();
        
        for(Property__c target : targetList2){ //物件ごと
            //掲載情報を取得
            Boolean isDispSuumo = (target.FormerSupplier_SUUMO_press_ban__c == true) ? false: true;
            Boolean isDispHomes = (target.FormerSupplier_HOME_S_press_ban__c == true) ? false: true;
            Boolean isDispAtHome = (target.FormerSupplier_at_home_press_ban__c == true) ? false: true;
            Boolean isDispChintai = (target.FormerSupplier_Chintai_press_ban__c == true) ? false: true; // 2022/03/28 CHINTAI対応追加 
            //再販対応 追加 Start
            Boolean isDispOurHp;
            //ポータルサイト権限がなければ無条件にfalse
            if (isOpetionPortal){
                isDispOurHp = (target.FormerSupplier_Our_HP_press_ban__c == true) ? false: true;
            }else{
                isDispOurHp = false;
            }
            //再販対応 追加 End

            // 掲載サイト存在チェック
            if (!isDispSuumo && !isDispHomes && !isDispAtHome && !isDispOurHp && !isDispChintai) { // 2022/03/28 isDispChintaiをCHINTAI対応にて追加
                continue;
            }

            for(Id shopId : properyShopMap.get(target.Id)){ //追加予定の店舗ごと
                
                // ポータルサイト掲載物件登録のリストにaddする
                PortalSitePostingProperty__c addPortalSite = new PortalSitePostingProperty__c (
                    Shop__c     = shopId
                    , Property__c = newObjMap.get(target.Id).Id
                    , IsSuumo__c  = isDispSuumo
                    , IsHomes__c  = isDispHomes
                    , IsAtHome__c  = isDispAtHome
					, IsChintaiNet__c = isDispChintai // 2022/03/28 CHINTAI対応追加
                    , IsChintaiPanoramaPosting__c = false // 2022/03/28 CHINTAI対応追加
                    , IsPortal__c = isDispOurHp
                ); 
                portalSiteList.add(addPortalSite);
            }
            
        }
        
        //insertする
        if (!portalSiteList.isEmpty()) {
            SecureDML.secureInsert(portalSiteList);
        }
    }
    
    
    
    
    // ポータルサイト掲載物件削除
    private void PortalSitePostingPropertyDelete(Property__c[] oldObjs, Map<ID, Property__c> newObjMap){
        
        
        //IdSetの作成
        Set<Id> IdSet = new Set <Id>();
        
        for(Property__c oldObj : oldObjs){
            
            //更新時
            if(Trigger.isUpdate) {
                
                // Web公開が"しない"　もしくはnullなら削除
                if(newObjMap.get(oldObj.Id).WebPublishing__c == CommonConst.PROPERTY_WEBPUBLISHING_NO || newObjMap.get(oldObj.Id).WebPublishing__c == null){
                    IdSet.add(oldObj.Id);
                }
                
            // 削除時
            }else if (Trigger.isDelete){
                IdSet.add(oldObj.Id);
            }
        }
        if (IdSet.isEmpty()) {
            return;
        }
        
        // IdSetを利用してポータルサイト掲載物件からSELECTする
        List<PortalSitePostingProperty__c> deleteList = [SELECT Id FROM PortalSitePostingProperty__c 
                                                         WHERE Property__c IN :IdSet];
        // SELECTしたものを削除する
        if(!deleteList.isEmpty()){
            SecureDML.secureDelete(deleteList);
        }
    }
    
    /**
    * 空き物件無しに更新
    * @param  Map<ID, Property__c> oldObjMap 物件更新前
    * @param  Property__c[]        newObjs   物件更新後
    */
    private void updNoExistsFreeFloorPlan(Map<ID, Property__c> oldObjMap, Property__c[] newObjs) {

        Savepoint sp = Database.setSavepoint();
        try {
            // 空き以外に更新された物件を取得（key:建物ID、value:物件間取り）
            Map<Id, Set<String>> updBuildingsPropMap = this.getNotChgFreeProp(oldObjMap, newObjs);
            if (updBuildingsPropMap.size() == 0) {
                return;
            }

            // 建物の空き間取りを取得
            Map<Id, Set<String>> buildingsFloorPlanMap = this.selectBuildingsFreeFloorPlan(updBuildingsPropMap.keySet());

            // 更新対象の建物、間取りを取得
            Map<Id, Set<String>> updTargetBuildingMap = new Map<Id, Set<String>>(); // key:建物ID、value:物件間取り
            Set<String> tmpFloorPlanSet;                                            // 間取り

            for (Id buildingId : updBuildingsPropMap.keySet()) {

                // 建物キーが存在しない場合は更新対象
                if (!buildingsFloorPlanMap.containsKey(buildingId)) {

                    // 建物キー毎のvalue値を初期化
                    updTargetBuildingMap.put(buildingId, new Set<String>());

                    // valueを設定
                    for (String floorPlan : updBuildingsPropMap.get(buildingId)) {
                        tmpFloorPlanSet = updTargetBuildingMap.get(buildingId);
                        tmpFloorPlanSet.add(floorPlan);
                        updTargetBuildingMap.put(buildingId, tmpFloorPlanSet);
                    }
                    continue;
                }

                // 空き間取り存在チェック
                for (String floorPlan : updBuildingsPropMap.get(buildingId)) {

                    // 空き間取りが存在する場合は更新対象外
                    tmpFloorPlanSet = buildingsFloorPlanMap.get(buildingId);
                    if (tmpFloorPlanSet.contains(floorPlan)) {
                        continue;
                    }

                    // 建物キー毎のvalue値を初期化
                    if (!updTargetBuildingMap.containsKey(buildingId)) {
                        updTargetBuildingMap.put(buildingId, new Set<String>());
                    }

                    // valueを設定
                    tmpFloorPlanSet = updTargetBuildingMap.get(buildingId);
                    tmpFloorPlanSet.add(floorPlan);
                    updTargetBuildingMap.put(buildingId, tmpFloorPlanSet);
                }
            }

            if (updTargetBuildingMap.size() == 0) {
                return;
            }

            // 空室ありの空室予約物件を取得
            List<VacancyReservationProperty__c> vacancyReservationPropList;
            vacancyReservationPropList = this.selectVacancyReservationProperty(updTargetBuildingMap.keyset(), CommonConst.VACANCY_STATUS_EXIST);                        

            // 空室予約物件の更新値の取得
            VacancyReservationProperty__c updEntity;                                                       // 登録エンティティ
            List<VacancyReservationProperty__c> updEntityList = new List<VacancyReservationProperty__c>(); // 登録リスト

            for (VacancyReservationProperty__c vrp : vacancyReservationPropList) {

                // 間取りチェック
                if (!updTargetBuildingMap.get(vrp.Building__c).contains(vrp.PropertyFloorPlan__c)) {
                    continue;
                }

                // 空室予約物件の更新値
                updEntity = new VacancyReservationProperty__c();
                updEntity.Id = vrp.Id;
                updEntity.VacancyStatus__c = CommonConst.VACANCY_STATUS_NONE;

                updEntityList.add(updEntity);
            }

            // 空室予約物件を更新
            if (updEntityList.size() > 0) {
                SecureDML.secureUpdate(updEntityList);
            }
            
        } catch (Exception e) {
            System.debug('例外メッセージ:' + e.getMessage());
            System.debug('例外スタックトレース:' + e.getStackTraceString());
            Database.rollback(sp);
        }
    }

    /**
    * 空き以外に更新された物件を取得
    * @param Map<ID, Property__c> oldPropMap 物件更新前
    * @param Property__c[]        newProps   物件更新後
    * @return Map<Id, Set<String> key:建物ID、value:物件間取り
    */
    private Map<Id, Set<String>> getNotChgFreeProp(Map<ID, Property__c> oldPropMap, Property__c[] newProps) {

        // 空き以外に更新された物件
        Map<Id, Set<String>> updBuildingsPropMap = new Map<Id, Set<String>>();  // key:建物ID、value:物件間取り
        Set<String> tmpValueSet;

        // 空き以外に更新された物件を取得
        Property__c oldProp;
        for (Property__c newProp : newProps) {

            // 更新前値を取得
            oldProp = new Property__c();
            if (oldPropMap.containskey(newProp.Id)) {
                oldProp = oldPropMap.get(newProp.Id);
            }

            // 現況（更新前）チェック
            if (oldProp.LiveStatus__c != CommonConst.PROPERTY_LIVESTATUS_VACANCY
                && oldProp.LiveStatus__c != CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE) {
                continue;
            }
            
            // 現況（更新後）チェック
            if (newProp.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_VACANCY
                || newProp.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE) {
                continue;  
            }
                
            // 建物キー毎のvalue値を初期化
            if (!updBuildingsPropMap.containsKey(newProp.Building__c)) {
                updBuildingsPropMap.put(newProp.Building__c, new Set<String>());
            }

            // 空き以外に更新された物件マップを設定
            tmpValueSet = updBuildingsPropMap.get(newProp.Building__c);
            tmpValueSet.add(newProp.FloorPlan__c);
            updBuildingsPropMap.put(newProp.Building__c, tmpValueSet);
        }

        return updBuildingsPropMap;
    }

    /**
    * 空室予約物件を連絡
    * @param  Map<ID, Property__c> oldObjMap 物件更新前
    * @param  Property__c[]        newObjs   物件更新後
    */
    private void contactVacancyReservationProp(Map<ID, Property__c> oldObjMap, Property__c[] newObjs) {

        Savepoint sp = Database.setSavepoint();
        try {
            // 空きに更新された物件を取得（key:建物ID、value:物件）
            Map<Id, List<property__c>> updBuildingsPropMap = this.getChgFreeProp(oldObjMap, newObjs);
            if (updBuildingsPropMap.size() == 0) {
                return;
            }
            
            // 空室状況を"空室あり"に更新
            this.updFreeVacancyReservationProp(updBuildingsPropMap);
            
            // 取引先に紐づく空室予約物件を取得（key:取引先.ID、value:空室予約物件）
            Map<Id, List<VacancyReservationProperty__c>> accountsVacancyReservationPropMap;
            accountsVacancyReservationPropMap = this.selectAccountsVacancyReservationProperty(updBuildingsPropMap);
            if (accountsVacancyReservationPropMap.size() == 0) {
                return;
            }

            // 取引先に紐づく空室予約対象の対応を取得（key:取引先.ID、value:対応）
            Map<Id, Correspond__c> accountsCorrespondMap = this.selectVacancyReservationCorrespond(accountsVacancyReservationPropMap.keySet());
            
            // 空室予約物件を紹介
            this.introduceVacancyReservationProps(accountsCorrespondMap, accountsVacancyReservationPropMap);

        } catch (Exception e) {
            System.debug('例外メッセージ:' + e.getMessage());
            System.debug('例外スタックトレース:' + e.getStackTraceString());
            Database.rollback(sp);
        }
    }
    
    /**
    * 空室時の空室予約物件を更新
    * @param Map<Id, List<property__c>> updBuildingsPropMap 建物に紐づく物件（key:建物ID、value:物件）
    */
    private void updFreeVacancyReservationProp(Map<Id, List<property__c>> updBuildingsPropMap) {

        // 更新対象の建物を取得
        Map<Id, Set<String>> updTargetBuildingMap = new Map<Id, Set<String>>();  // key:建物ID、value:間取り
        Set<String> tmpFloorPlanSet;

        for (Id buildingId : updBuildingsPropMap.keySet()) {
            for (property__c prop : updBuildingsPropMap.get(buildingId)) {

                // 建物キー毎のvalue値を初期化
                if (!updTargetBuildingMap.containsKey(prop.Building__c)) {
                    updTargetBuildingMap.put(prop.Building__c, new Set<String>());
                }
                
                // valueを設定
                tmpFloorPlanSet = updTargetBuildingMap.get(prop.Building__c);
                tmpFloorPlanSet.add(prop.FloorPlan__c);
                updTargetBuildingMap.put(prop.Building__c, tmpFloorPlanSet);
            }
        }

        // 空室状況の条件値
        String condVacancyStatus = (Trigger.isDelete) ? CommonConst.VACANCY_STATUS_EXIST:
                                                        CommonConst.VACANCY_STATUS_NONE;

        // 空室なしの空室予約物件を取得
        List<VacancyReservationProperty__c> vacancyReservationPropList;
        vacancyReservationPropList = this.selectVacancyReservationProperty(updTargetBuildingMap.keyset(), condVacancyStatus);

        // 空室予約物件の更新値の取得
        VacancyReservationProperty__c updEntity;                                                       // 登録エンティティ
        List<VacancyReservationProperty__c> updEntityList = new List<VacancyReservationProperty__c>(); // 登録リスト
                   
        for (VacancyReservationProperty__c vrp : vacancyReservationPropList) {
                
            // レコードの存在チェック
            if (!updTargetBuildingMap.containsKey(vrp.Building__c)) {
                continue;
            }

            // 間取りチェック
            if (!updTargetBuildingMap.get(vrp.Building__c).contains(vrp.PropertyFloorPlan__c)) {
                continue;
            }

            // 更新値を設定
            updEntity = new VacancyReservationProperty__c();
            updEntity.Id = vrp.Id;
            updEntity.VacancyStatus__c = (Trigger.isDelete) ? CommonConst.VACANCY_STATUS_NONE:
                                                              CommonConst.VACANCY_STATUS_EXIST;

            updEntityList.add(updEntity);
        }

        // 空室予約物件を更新
        if (updEntityList.size() > 0) {
            SecureDML.secureUpdate(updEntityList);
        }
    }

    /**
    * 空室予約物件の取得
    * @param  Set<Id> condBuidingIdSet 建物ID
    * @param  String condVacancyStatus 空室状況
    * @return List<VacancyReservationProperty__c> 空室予約物件
    */
    private List<VacancyReservationProperty__c> selectVacancyReservationProperty(Set<Id> condBuidingIdSet
                                                                                 , String condVacancyStatus) {

        // 空室予約物件を取得
        List<VacancyReservationProperty__c> vacancyReservationPropList;
        vacancyReservationPropList = [SELECT Id
                                             , Building__c
                                             , PropertyFloorPlan__c
                                      FROM VacancyReservationProperty__c
                                      WHERE Building__c = :condBuidingIdSet
                                            AND VacancyStatus__c = :condVacancyStatus];

        if (vacancyReservationPropList.isEmpty()) {
            vacancyReservationPropList = new List<VacancyReservationProperty__c>();
        }

        return vacancyReservationPropList;
    }

    /**
    * 空きに更新された物件を取得
    * @param  Map<ID, Property__c> oldObjMap 物件更新前
    * @param  Property__c[]        newObjs   物件更新後
    * @return Map<Id, List<Property__c>> 空きに更新された物件（key:建物ID、value:物件）
    */
    private Map<Id, List<Property__c>> getChgFreeProp(Map<ID, Property__c> oldObjMap, Property__c[] newObjs) {

        // 空きに更新された物件（key:建物ID、value:物件）
        Map<Id, List<Property__c>> updBuildingsPropMap = new Map<Id, List<Property__c>>();
        List<Property__c> tmpPropList;
        
        // 空室に変更された物件を取得
        Property__c oldProp;
        for (Property__c newProp : newObjs) {

            // 更新前値を取得
            oldProp = new Property__c();
            if (oldObjMap.containskey(newProp.Id)) {
                oldProp = oldObjMap.get(newProp.Id);
            }

            // 現況（更新前）チェック
            if (oldProp.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_VACANCY
                || oldProp.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE) {
                continue;
            }
            
            // 現況（更新後）チェック
            if (newProp.LiveStatus__c != CommonConst.PROPERTY_LIVESTATUS_VACANCY
                && newProp.LiveStatus__c != CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE) {
                continue;  
            }
            
            // 建物キー毎のvalue値を初期化
            if (!updBuildingsPropMap.containsKey(newProp.Building__c)) {
                updBuildingsPropMap.put(newProp.Building__c, new List<Property__c>());
            }

            // valueを設定
            tmpPropList = updBuildingsPropMap.get(newProp.Building__c);
            tmpPropList.add(newProp);
            updBuildingsPropMap.put(newProp.Building__c, tmpPropList);
        }
        
        return updBuildingsPropMap;
    }

    /**
    * 建物の空き間取りを取得
    * @param Set<ID> condBuildingIdSet 建物ID
    * @return Map<Id, Set<String>> 建物の空き間取り（key:建物ID、value:物件間取り）
    */
    private Map<Id, Set<String>> selectBuildingsFreeFloorPlan(Set<ID> condBuildingIdSet) {

        // 空き間取りを取得
        List<Property__c> propList = [SELECT Building__c
                                             , FloorPlan__c
                                      FROM Property__c
                                      WHERE Building__c = :condBuildingIdSet
                                            AND LiveStatus__c IN (:CommonConst.PROPERTY_LIVESTATUS_VACANCY
                                                                  , :CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE)
                                     ];
        
        // 建物の空き間取り（key:建物ID、value:物件間取り）
        Map<Id, Set<String>> buildingsFloorPlanMap = new Map<Id, Set<String>>();
        Set<String> tmpValue;

        // 建物の空き間取りを取得
        for (Property__c prop : propList) {

            // 建物キー毎のvalue値を初期化
            if (!buildingsFloorPlanMap.containsKey(prop.Building__c)) {
                buildingsFloorPlanMap.put(prop.Building__c, new Set<String>());
            }

            // valueを設定
            tmpValue = buildingsFloorPlanMap.get(prop.Building__c);
            tmpValue.add(prop.FloorPlan__c);
            buildingsFloorPlanMap.put(prop.Building__c, tmpValue);
        }

        return buildingsFloorPlanMap;
    }
    
    /**
    * 取引先に紐づく空室予約対象の対応を取得
    * @param Set<Id> accountIdSet 取引先ID
    * @return Map<Id, Correspond__c> 空室予約物件対象の対応（key:取引先.ID、value:対応）
    */
    private Map<Id, Correspond__c> selectVacancyReservationCorrespond(Set<Id> accountIdSet) {
        
        // ステータスの条件値
        Set<String> condStatusSet = new Set<String> {
            CommonConst.CORRESPOND_STATUS_PURSUIT               // 追客中
            , CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT   // アポキャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT     // 来店後追客中
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT  // 申込キャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_PURSUITHOLD         // 追客保留中
            , CommonConst.CORRESPOND_STATUS_CONSIDERVISITING    // 来店後検討
        };
            
        // 空室予約物件の対応を取得
        List<Correspond__c> correspondList = [SELECT Id 
                                                     , AccountId__c
                                                     , Status__c
                                              FROM Correspond__c
                                              WHERE AccountId__c = :accountIdSet
                                                    AND Status__c IN :condStatusSet];
        
        // 対応に紐づく取引先を取得（key:取引先.ID、value:対応）
        Map<Id, Correspond__c> accountsCorrespondMap = new Map<Id, Correspond__c>();
        for (Correspond__c correspond : correspondList) {
            accountsCorrespondMap.put(correspond.AccountId__c, correspond);
        }
        
        return accountsCorrespondMap;
    }
    
    /**
    * 取引先に紐づく空室予約物件を取得
    * @param Map<Id, List<property__c>> buildingsPropMap 建物に紐づく物件（key:建物ID、value:物件）
    * @return Map<Id, List<VacancyReservationProperty__c>> 取引先に紐づく空室予約物件（key:取引先.ID、value:空室予約物件）
    */
    private Map<Id, List<VacancyReservationProperty__c>> selectAccountsVacancyReservationProperty(Map<Id, List<property__c>> buildingsPropMap) {

        // 建物に紐づく間取りを取得（key:建物.ID、value:間取り）
        List<property__c> tmpPropList = new List<property__c>();
        for (Id buildingId : buildingsPropMap.keySet()) {
            tmpPropList.addAll(buildingsPropMap.get(buildingId));
        }
        Map<String, Set<String>> buildingsFloorPlan = CommonUtil.getKeysSetVal(tmpPropList, 'Building__c', 'FloorPlan__c');

        // ステータスの条件値
        Set<String> condStatusSet = new Set<String> {
            CommonConst.CORRESPOND_STATUS_PURSUIT               // 追客中
            , CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT   // アポキャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT     // 来店後追客中
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT  // 申込キャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_PURSUITHOLD         // 追客保留中
            , CommonConst.CORRESPOND_STATUS_CONSIDERVISITING    // 来店後検討
        };

        // 空室予約物件を取得
        List<VacancyReservationProperty__c> vacancyReservationPropList;
        vacancyReservationPropList = [SELECT Id
                                             , Account__c
                                             , Building__c
                                             , Building__r.Name
                                             , VacancyStatus__c
                                             , PropertyFloorPlan__c
                                      FROM VacancyReservationProperty__c
                                      WHERE Building__c IN :buildingsFloorPlan.keySet()
                                            AND Account__c IN (SELECT AccountId__c
                                                               FROM Correspond__c
                                                               WHERE Status__c = :condStatusSet
                                                              )];

        // 取引先に紐づく建物を取得（key:取引先.ID、value:建物．ID）
        List<VacancyReservationProperty__c> tmpVacancyReservationPropList = new List<VacancyReservationProperty__c>();
        Map<Id, List<VacancyReservationProperty__c>> accountsBuildingMap = new Map<Id, List<VacancyReservationProperty__c>>();
        for (VacancyReservationProperty__c vrp : vacancyReservationPropList) {

            // 間取りの存在チェック
            if (!buildingsFloorPlan.get(vrp.Building__c).contains(vrp.PropertyFloorPlan__c)) {
                continue;
            }

            // キー設定
            if (!accountsBuildingMap.containsKey(vrp.Account__c)) {
                accountsBuildingMap.put(vrp.Account__c, new List<VacancyReservationProperty__c>());
            }
            
            // 値設定
            tmpVacancyReservationPropList = accountsBuildingMap.get(vrp.Account__c);
            tmpVacancyReservationPropList.add(vrp);
            accountsBuildingMap.put(vrp.Account__c, tmpVacancyReservationPropList);
        }
        
        return accountsBuildingMap;
    }
    
    /**
    * 空室予約物件を紹介
    * @param Map<Id, Correspond__c>                       空室予約物件対象の対応（key:取引先.ID、value:空室予約物件）
    * @param Map<Id, List<VacancyReservationProperty__c>> 空室予約物件（key:取引先.ID、value:空室予約物件）
    */
    private void  introduceVacancyReservationProps(Map<Id, Correspond__c> accountsCorrespondMap
                                                   , Map<Id, List<VacancyReservationProperty__c>> accountsVacancyReservationPropMap) {
        // Entity
        Correspond__c correspond;             // 対応
        CorrespondDetail__c correspondDetail; // 対応明細
            
        // Entityリスト
        List<Correspond__c> updCorrespondList = new List<Correspond__c>();                      // 対応
        List<CorrespondDetail__c> registCorrespondDetailList = new List<CorrespondDetail__c>(); // 対応明細

        // 更新値
        Datetime currentDate = CommonUtil.getNow(); // システム日付
                                                       
        // ID
        Set<Id> duplicateCorrespondIdSet = new Set<Id>();   // 重複対応ID
        Id tmpCorrespondId;                                 // 対応ID

        // 取引先単位で物件紹介を作成
        for (Id accountId : accountsCorrespondMap.keySet()) {
            // 建物・間取り単位で物件紹介を作成
            for (VacancyReservationProperty__c accsVacancyReservationProp : accountsVacancyReservationPropMap.get(accountId)) {
                // 重複更新チェック
                tmpCorrespondId = accountsCorrespondMap.get(accountId).Id;
                if (!duplicateCorrespondIdSet.contains(tmpCorrespondId)) {
                    duplicateCorrespondIdSet.add(tmpCorrespondId);
                    
                    // 対応更新値
                    correspond = new Correspond__c();
                    correspond.Id                                  = tmpCorrespondId; // 更新ID
                    correspond.PropertyIntroductionPossibleTime__c = currentDate;     // 物件紹介可能時刻
                    correspond.EventDateTime__c                    = currentDate;     // イベント時刻
                    correspond.ListViewDate__c                     = currentDate;     // 一覧表示日時
                    correspond.IsSupportedListShow__c              = false;           // 対応確認

                    // 追客保留日時を初期化
                    if (accountsCorrespondMap.get(accountId).Status__c == CommonConst.CORRESPOND_STATUS_PURSUITHOLD) {
                        correspond.PursuitDissolveSettingDate__c = null;
                    }

                    updCorrespondList.add(correspond);
                }

                // 対応明細登録値
                correspondDetail = new CorrespondDetail__c();
                correspondDetail.Corresponds__c       = tmpCorrespondId;                                     // 対応番号
                correspondDetail.CorrespondType__c    = CommonConst.TASK_CORRESPONDTYPE_PROP_CAN_INTRODUCE;  // 対応種別
                correspondDetail.SupportedTitle__c    = CommonConst.TASK_CORRESPONDTYPE_PROP_CAN_INTRODUCE;  // 対応表題
                correspondDetail.SupportedDateTime__c = currentDate;                                         // 対応日時
                // 対応内容
                correspondDetail.SupportedContent__c  = CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_PROP_CAN_INTRODUCE
                                                                                     , accsVacancyReservationProp.Building__r.Name
                                                                                     , CommonConst.STRING_EMPTY);    
                registCorrespondDetailList.add(correspondDetail);
            }
        }
            
        // 対応更新
        SecureDML.secureUpdate(updCorrespondList);
            
        // 対応明細登録
        SecureDML.secureInsert(registCorrespondDetailList);
    }

    /**
    * 削除時に空室予約物件を空室ありに更新
    * @param Property__c[] oldProps 物件削除前
    */
    private void updExistsFreeFloorPlanToDelete(Property__c[] oldProps) {

        Savepoint sp = Database.setSavepoint();
        try {
            
            // 空きに更新された物件を取得（key:建物ID、value:物件）
            Map<Id, List<Property__c>> updBuildingsPropMap = this.getChgFreeProp(new Map<ID, Property__c>(), oldProps);
            if (updBuildingsPropMap.size() == 0) {
                return;
            }

            // 建物の空き間取りを取得
            Map<Id, Set<String>> buildingsFloorPlanMap = this.selectBuildingsFreeFloorPlan(updBuildingsPropMap.keySet());

            // 更新対象の建物、間取りを取得
            Map<Id, List<Property__c>> updTargetBuildingMap = new Map<Id, List<Property__c>>(); // key:建物ID、value:物件
            List<Property__c> tmpValue;

            // 空き間取り存在チェック
            for (Id buildingId : updBuildingsPropMap.keySet()) {
                for (Property__c prop : updBuildingsPropMap.get(buildingId)) {

                    // 建物、間取りが存在する場合は対象外
                    if (buildingsFloorPlanMap.containsKey(buildingId)
                        && buildingsFloorPlanMap.get(buildingId).contains(prop.FloorPlan__c)) {
                        continue;
                    }

                    // 建物キー毎のvalue値を初期化
                    if (!updTargetBuildingMap.containsKey(buildingId)) {
                        updTargetBuildingMap.put(buildingId, new List<Property__c>());
                    }

                    // valueを設定
                    tmpValue = updTargetBuildingMap.get(buildingId);
                    tmpValue.add(prop);
                    updTargetBuildingMap.put(buildingId, tmpValue);
                }
            }

            if (updTargetBuildingMap.size() == 0) {
                return;
            }
                        
            // 空室状況を"空室なし"に更新
            this.updFreeVacancyReservationProp(updTargetBuildingMap);

        } catch (Exception e) {
            System.debug('例外メッセージ:' + e.getMessage());
            System.debug('例外スタックトレース:' + e.getStackTraceString());
            Database.rollback(sp);
        }
    }
    
    /**
    * 条件完全一致物件を連絡
    * @param  Map<ID, Property__c> oldObjMap 物件更新前
    * @param  Property__c[]        newObjs   物件更新後
    */
    private void contactCondMatchProp(Map<ID, Property__c> oldObjMap, Property__c[] newObjs) {

        // 実施チェック
        if (SystemConfig__c.getInstance().IsSkipPropCompareProcess__c) {
            return;
        }

        // 条件完全一致バッチ実行
        Set<Id> delEcmbePropIdSet = new Set<Id>();                  // 削除物件ID
        ExactConditionMatchBatchExecution__c ecmbeEntity;           // エンティティ
        List<ExactConditionMatchBatchExecution__c> registEcmbeList; // 登録リスト

        registEcmbeList = new List<ExactConditionMatchBatchExecution__c>();

        // 対象物件チェック
        Property__c oldProp;
        for(Property__c newObj : newObjs) {

            // 更新前値を取得
            oldProp = new Property__c();
            if (oldObjMap.containskey(newObj.Id)) {
                oldProp = oldObjMap.get(newObj.Id);
            }

            // 条件完全一致チェック
            if (this.isExecuteCondMatchProp(oldProp, newObj)) {
                // 条件完全一致バッチ実行の登録値の取得
                ecmbeEntity = new ExactConditionMatchBatchExecution__c(
                    PropertyId__c = newObj.Id
                    , Property__c = newObj.Id
                );
                registEcmbeList.add(ecmbeEntity);
            } else {

                // 空室、退去予定以外に変更された場合は未実施に更新
                if (oldProp.LiveStatus__c ==  newObj.LiveStatus__c) {
                    continue;
                }

                // 条件完全一致バッチ実行の削除IDの取得
                delEcmbePropIdSet.add(newObj.Id);
            }
        }

        // 条件完全一致実行の登録
        if (registEcmbeList.size() > 0) {
            SecureDML.secureInsert(registEcmbeList, false);
        }

        // 削除処理
        if (delEcmbePropIdSet.size() > 0) {
            
            // 削除対象の条件完全一致バッチ実行の取得
            List<ExactConditionMatchBatchExecution__c> delEcmbeList;
            delEcmbeList = this.selectExactCondMatchBatExe(delEcmbePropIdSet);

            // 条件完全一致実行の削除
            if (delEcmbeList.size() > 0) {
                SecureDML.secureDelete(delEcmbeList);
            }
        }
    }

    /**
    * 条件完全一致物件の連絡実施チェック
    * @param  Property__c oldProp 物件更新前
    * @param  Property__c newProp 物件更新後
    * @return Boolean     true:実施する、false:実施しない
    */
    private Boolean isExecuteCondMatchProp(Property__c oldProp, Property__c newProp) {

        // 現況
        // 居住不可チェック
        if (newProp.LiveStatus__c != CommonConst.PROPERTY_LIVESTATUS_VACANCY
            && newProp.LiveStatus__c != CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE) {
            return false;
        }

        // 居住可への変更チェック
        if (oldProp.LiveStatus__c !=  newProp.LiveStatus__c
            && (newProp.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_VACANCY
                || newProp.LiveStatus__c == CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE)
            ) {
            return true;
        }

        // 占有面積（下限、上限）
        if (oldProp.RoomArea__c != newProp.RoomArea__c
            && newProp.RoomArea__c != null) {
            return true;
        }
        
        // 間取り（ワンルーム、1K、1DK、1LDK/SLDK、2K/DK、2LDK/SLDK、3K/DK、3LDK/SLDK、4K/DK/LDK~
        if ((oldProp.RoomCount__c != newProp.RoomCount__c && newProp.RoomCount__c != null)
            || (oldProp.RoomLayout__c != newProp.RoomLayout__c && newProp.RoomLayout__c != null)) {
            return true;
        }
        
        // バルコニー方向（北、北東、東、南東、南、南西、西、北西）
        if (oldProp.BalconyDirection__c != newProp.BalconyDirection__c
            && newProp.BalconyDirection__c != null) {
            return true;
        }

        // 賃料、賃料 + 管理費、賃料 + 駐車場、賃料 + 管理費 + 駐車場
        if ((oldProp.RentFeeSearch__c != newProp.RentFeeSearch__c && newProp.RentFeeSearch__c != null)
            || (oldProp.RentFeeSearchManagement__c != newProp.RentFeeSearchManagement__c && newProp.RentFeeSearchManagement__c != null)
            || (oldProp.RentFeeSearchParking__c != newProp.RentFeeSearchParking__c && newProp.RentFeeSearchParking__c != null)
            || (oldProp.RentFeeSearchManagementParking__c != newProp.RentFeeSearchManagementParking__c && newProp.RentFeeSearchManagementParking__c != null)
           ) {
            return true;
        }

        // 敷金/保証金なし
        if ((oldProp.SecurityDepositYenSearch__c != newProp.SecurityDepositYenSearch__c && newProp.SecurityDepositYenSearch__c == 0)
            || (oldProp.SecurityDepositMonthSearch__c != newProp.SecurityDepositMonthSearch__c && newProp.SecurityDepositMonthSearch__c == 0)
            || (oldProp.DepositYenSearch__c != newProp.DepositYenSearch__c && newProp.DepositYenSearch__c == 0)
            || (oldProp.DepositMonthSearch__c != newProp.DepositMonthSearch__c && newProp.DepositMonthSearch__c == 0)) {
            return true;
        }
        
        // 礼金なし
        if ((oldProp.KeyMoneyYenSearch__c != newProp.KeyMoneyYenSearch__c && newProp.KeyMoneyYenSearch__c == 0)
            || (oldProp.KeyMoneyMonthSearch__c != newProp.KeyMoneyMonthSearch__c && newProp.KeyMoneyMonthSearch__c == 0)) {
            return true;
        }
        
        // 定額修繕費なし
        if ((oldProp.CleaningFeeYenSearch__c != newProp.CleaningFeeYenSearch__c && newProp.CleaningFeeYenSearch__c == 0)
            || (oldProp.CleaningFeeMonthSearch__c != newProp.CleaningFeeMonthSearch__c && newProp.CleaningFeeMonthSearch__c == 0)) {
            return true;
        }
        
        // 更新料なし
        if ((oldProp.RenewalFeeYenSearch__c != newProp.RenewalFeeYenSearch__c && newProp.RenewalFeeYenSearch__c == 0)
            || (oldProp.RenewalFeeMonthSearch__c != newProp.RenewalFeeMonthSearch__c && newProp.RenewalFeeMonthSearch__c == 0)) {
            return true;
        }

        // 保証会社不要
        if (oldProp.GuaranteeidCompanyType__c != newProp.GuaranteeidCompanyType__c
            && newProp.GuaranteeidCompanyType__c == CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_POSSIBLE) {
            return true;
        }

        return false;
    }

    /**
    * 条件完全一致バッチ実行の取得
    * @param Set<Id> propertyIdSet 物件ID
    * @return List<ExactConditionMatchBatchExecution__c> 条件完全一致バッチ実行
    */
    private List<ExactConditionMatchBatchExecution__c> selectExactCondMatchBatExe(Set<Id> propertyIdSet) {

        // 条件完全一致バッチ実行の取得
        List<ExactConditionMatchBatchExecution__c> ecmbeList =
            [SELECT Id
             FROM ExactConditionMatchBatchExecution__c
             WHERE PropertyId__c = :propertyIdSet];

        // 取得件数チェック
        if (ecmbeList.isEmpty()) {
            ecmbeList = new List<ExactConditionMatchBatchExecution__c>();
        }

        return ecmbeList;
    }

    /**
    * 物件コード履歴の登録
    * @param Property__c[] propertyAry 物件
    */
    private void insertPropertyCdHist(Property__c[] propertyAry) {

        // オブジェクト登録値
        PropertyCodeHistory__c insertPropertyCdHist;
        List<PropertyCodeHistory__c> insertPropertyCdHistList = new List<PropertyCodeHistory__c>();

        // 物件コード履歴の登録値を取得
        for (Property__c property : propertyAry) {

            insertPropertyCdHist = new PropertyCodeHistory__c (
                Property__c                         = property.Id                         // 物件
                , HistoryProperty__c                = property.Id                         // 履歴物件
                , HistoryMaintenancePropertyCode__c = property.MaintenancePropertyCode__c // メンテナンス物件コード
                , HistoryPropertyCode__c            = property.PropertyCode__c            // 履歴物件コード
                , HistoryImportDestination__c       = property.ImportType__c              // 履歴取込先
                , HistoryPropertyForeignID__c       = property.ForeignID__c               // 履歴物件外部ID
                , HistoryPropertyDetailUrl__c       = property.PropertyDetailUrl__c       // 履歴物件詳細画面URL
                , InformationUpdateDate__c          = CommonUtil.getNow()                 // 情報更新日
            );
            
            insertPropertyCdHistList.add(insertPropertyCdHist);
        }

        // 物件コード履歴の登録
        if (insertPropertyCdHistList.size() > 0) {
            SecureDML.secureInsert(insertPropertyCdHistList);
        }
    }

    /**
    * 物件コード履歴の更新
    * @param Map<ID, Property__c> oldObjMap 物件更新前
    * @param Property__c[]        newObjs   物件更新後
    */
    private void updPropertyCdHist(Map<ID, Property__c> oldObjMap, Property__c[] newObjs) {

        // 更新対象の物件IDの取得
        Set<Id> updPropertyIdSet = new Set<Id>();
        for (Property__c newObj : newObjs) {

            // 更新対象チェック
            if (!isUpdPropertyCdHistsProperty(oldObjMap.get(newObj.Id), newObj)) {
                continue;
            }

            updPropertyIdSet.add(newObj.Id);
        }

        // 物件コード履歴の取得と更新
        // ※差分テーブルを作成する為、親に紐づく全レコードを更新する
        List<PropertyCodeHistory__c> propertyCdHistList = this.selectPropertyCdHist(updPropertyIdSet);
        for (PropertyCodeHistory__c propertyCdHist : propertyCdHistList) {

            // 親レコードは履歴情報を更新
            if (propertyCdHist.Property__c == propertyCdHist.HistoryProperty__c) {
                propertyCdHist.HistoryMaintenancePropertyCode__c = null;
                propertyCdHist.HistoryImportDestination__c       = CommonConst.PROPERTY_IMPORTTYPE_MANUAL;
                propertyCdHist.HistoryPropertyDetailUrl__c       = CommonConst.STRING_EMPTY;
            }
        }

        // 物件コード履歴の更新
        if (propertyCdHistList.size() > 0) {
            SecureDML.secureUpdate(propertyCdHistList);
        }
    }

    /**
    * 物件コード履歴の更新対象物件チェック
    * @param Property__c oldObj 物件更新前
    * @param Property__c newObj 物件更新後
    * @return Boolean true:更新対象、false:更新対象外
    */
    private Boolean isUpdPropertyCdHistsProperty(Property__c oldObj, Property__c newObj) {

        // 物件登録画面で取込先が"手動"に変更された場合
        if ((oldObj.ImportType__c != newObj.ImportType__c && newObj.ImportType__c == CommonConst.PROPERTY_IMPORTTYPE_MANUAL)
            && (oldObj.MaintenancePropertyCode__c != newObj.MaintenancePropertyCode__c && newObj.MaintenancePropertyCode__c == null)
           ) {
            return true;
        }

        return false;
    }

    /**
    * 物件コード履歴差分の登録
    * @param Set<Id> propertyIdSet 物件ID
    */
    private void insertPropertyCdHistDiff(Set<Id> propertyIdSet) {

        // オブジェクト登録値
        PropertyCodeHistoryDifference__c insertPropertyCdHistDiff;
        List<PropertyCodeHistoryDifference__c> insertPropertyCdHistDiffList = new List<PropertyCodeHistoryDifference__c>();

        // 物件コード履歴の取得
        List<PropertyCodeHistory__c> propertyCdHistList = this.selectPropertyCdHist(propertyIdSet);

        // 物件コード履歴差分の登録値を取得
        for (PropertyCodeHistory__c propertyCdHist : propertyCdHistList) {

            insertPropertyCdHistDiff = new PropertyCodeHistoryDifference__c(
                PropertyCodeHistId__c                 = propertyCdHist.Id                                // 物件コード履歴 ID
                , PropertyCodeHistIsDeleted__c        = propertyCdHist.IsDeleted                         // 物件コード履歴 削除
                , PropertyCodeHistName__c             = propertyCdHist.Name                              // 物件コード履歴 物件コード履歴番号
                , PropertyCodeHistCreatedDate__c      = propertyCdHist.CreatedDate                       // 物件コード履歴 作成日
                , PropertyCodeHistCreatedById__c      = propertyCdHist.CreatedById                       // 物件コード履歴 作成者 ID
                , PropertyCodeHistLastModifiedDate__c = propertyCdHist.LastModifiedDate                  // 物件コード履歴 最終更新日
                , PropertyCodeHistLastModifiedById__c = propertyCdHist.LastModifiedById                  // 物件コード履歴 最終更新者 ID
                , PropertyCodeHistSystemModstamp__c   = propertyCdHist.SystemModstamp                    // 物件コード履歴 System Modstamp 
                , Property__c                         = propertyCdHist.Property__c                       // 物件
                , MaintenancePropertyCode__c          = propertyCdHist.MaintenancePropertyCode__c        // メンテナンス物件コード
                , PropertyCode__c                     = propertyCdHist.PropertyCode__c                   // 物件コード
                , HistoryProperty__c                  = propertyCdHist.HistoryProperty__c                // 履歴物件
                , HistoryMaintenancePropertyCode__c   = propertyCdHist.HistoryMaintenancePropertyCode__c // 履歴メンテナンス物件コード
                , HistoryPropertyCode__c              = propertyCdHist.HistoryPropertyCode__c            // 履歴物件コード
                , HistoryImportDestination__c         = propertyCdHist.HistoryImportDestination__c       // 履歴取込先
                , HistoryPropertyForeignID__c         = propertyCdHist.HistoryPropertyForeignID__c       // 履歴物件外部ID
                , InformationUpdateDate__c            = propertyCdHist.InformationUpdateDate__c          // 情報更新日
                , CrudCd__c                           = CommonConst.CRUD_CD_DELETE                       // クラッドコード
            );

            insertPropertyCdHistDiffList.add(insertPropertyCdHistDiff);
        }

        // 物件コード履歴差分の登録
        if (insertPropertyCdHistDiffList.size() > 0) {
            SecureDML.secureInsert(insertPropertyCdHistDiffList);
        }
    }

    /**
    * 物件コード履歴の取得
    * @param Set<Id> propertyIdSet 物件ID
    * @return List<PropertyCodeHistory__c> 物件コード履歴
    */
    private List<PropertyCodeHistory__c> selectPropertyCdHist(Set<Id> propertyIdSet) {

        // 物件コード履歴の取得
        List<PropertyCodeHistory__c> propertyCdHistList = 
            [SELECT Id                                  // ID
                    , IsDeleted                         // 削除
                    , Name                              // 物件コード履歴番号
                    , CreatedDate                       // 作成日
                    , CreatedById                       // 作成者 ID
                    , LastModifiedDate                  // 最終更新日
                    , LastModifiedById                  // 最終更新者 ID
                    , SystemModstamp                    // System Modstamp 
                    , Property__c                       // 物件
                    , MaintenancePropertyCode__c        // メンテナンス物件コード
                    , PropertyCode__c                   // 物件コード
                    , HistoryProperty__c                // 履歴物件
                    , HistoryMaintenancePropertyCode__c // 履歴メンテナンス物件コード
                    , HistoryPropertyCode__c            // 履歴物件コード
                    , HistoryImportDestination__c       // 履歴取込先
                    , HistoryPropertyForeignID__c       // 履歴物件外部ID
                    , InformationUpdateDate__c          // 情報更新日
             FROM PropertyCodeHistory__c
             WHERE Property__c = :propertyIdSet];
        
        // 初期化処理
        if (propertyCdHistList.isEmpty()) {
            propertyCdHistList = new List<PropertyCodeHistory__c>();
        }

        return propertyCdHistList;
    }

    /**
     * 物件の全項目の取得
     * @param Set<Id> condIdSet 物件.Id
     * @return Map<ID, Property__c> 物件（key:物件.Id、value:物件）
     */
    private Map<ID, Property__c> selectPropertyAllItem(Set<Id> condIdSet) {

        // 物件の項目名の取得
        List<String> itemList = New List<String>();
        Map<String, Schema.sObjectField> fieldMap = Property__c.SObjectType.getDescribe().fields.getMap();
        for (String field: fieldMap.keySet()) {
            itemList.add(field);
        }
        String items =  String.join(itemList, ',');

        // クエリの作成
        String sql = ' SELECT ' + items
                   + ' FROM Property__c'
                   + ' WHERE Id = :condIdSet';

        // クエリの実行
        List<Property__c> propertyList = Database.query(sql);
        
        // 実行結果の取得
        Map<ID, Property__c> propertyMap = new Map<ID, Property__c>();
        if (!propertyList.isEmpty()) {
            propertyMap = new Map<ID, Property__c>(propertyList);
        }

        return propertyMap;
    }
}