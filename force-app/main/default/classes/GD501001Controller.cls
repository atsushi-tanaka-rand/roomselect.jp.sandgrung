/**
* @File Name          : GD501001Controller.cls
* @Description        : ポータル連携物件登録画面のコントローラ
**/
public with sharing class GD501001Controller {
    
    
    /** メッセージ系 */
    public String MSG_COM_V_SAVE {get {return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}        //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get {return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}        //js用保存完了メッセージ
    public String MSG_FINISH {get; set;} //js用特殊完了メッセージ
    
    /** ポータルサイト掲載方法の明細リスト */
    public List<screenPostingMeans> postingMeansRecordList { get; set; }
    
    /** 地区リスト */
    public List<String>  districtStringList { get; private set; }
    private static List<String>  staticDistrictStringList;
    public List<Integer> districtIndexList { get; set;}
    
    /** 地区の選択リスト */
    public List<SelectOption> selectDistrictList { get; set; }
    
    /** ポータルサイト掲載地区の明細リスト */
    public List<screenPostingDistricts> postingDistrictsRecordList { get; set; }
    
    /** エラー関係 */
    public Boolean isOpenError { get; set; }
    public Boolean hasErrorMessage { get; set; }
    
    // チェックボックス変更状況
    public Boolean isChangeDistrict{get; set;}      //地区のチェックボックスが変更されたかどうか
    public Boolean isProcessing{get; set;}          //ガバナ制限対策により、処理中かどうか
    public Integer changeShopIndex {get; set;}      //変更された店舗index
    public Integer changeDistrictIndex {get; set;}  //変更された地区index
    
    // システム設定
    private SystemConfig__c  systemConfigData; //システム設定そのもの
    private Integer deleteLimit; //一度に削除できるレコード数(ガバナ対策)
    private Integer insertLimit; //一度に登録できるレコード数(ガバナ対策)
    private SystemVariables__c portalProcessCheckboxDistrict;   // ポータル連携処理中チェックボックス_地区情報
    private SystemVariables__c portalProcessCheckboxShop;       // ポータル連携処理中チェックボックス_店舗情報

    /** 定数 */
    private static final String PORTALPROCESSCHECKBOX_DISTRICT = CommonConst.PORTALPROCESSCHECKBOX_DISTRICT; //システム変数　ポータル連携処理中チェックボックス_地区情報
    private static final String PORTALPROCESSCHECKBOX_SHOP = CommonConst.PORTALPROCESSCHECKBOX_SHOP;         //システム変数　ポータル連携処理中チェックボックス_店舗情報
    
    
    public GD501001Controller() {
        try {
            //初期化
            init();
            
            //掲載方法明細List設定
            getScreenPostingMeansList();
            
            //掲載地区明細List設定
            getScreenPostingDistricsList();
            
            //チェックボックス変更状況設定
            setCheckBoxVariable();

            
        } catch (Exception e) {
            isOpenError = true; //エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //============================================================以下publicメソッド=================================================================
    // @description 掲載方法登録処理
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/2/18
    // @return void
    public void registerPostingMeans(){
        
        Savepoint sp = Database.setSavepoint();  //セーブポイント作成
        
        try{
            hasErrorMessage = false;
            
            //掲載方法登録エラーチェック
            registerPostingMeansErrorCheck();
            
            //掲載方法更新処理
            postingMeansUpdate();
            
            //掲載方法明細List設定
            getScreenPostingMeansList();
            
            //掲載地区明細List設定
            staticDistrictStringList = new List<String>(districtStringList); //地区StringList再設定
            getScreenPostingDistricsList();
            
        }catch(Exception e) {
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    
    // @description 掲載方法登録エラーチェック
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/2/18
    // @return void
    public void registerPostingMeansErrorCheck(){
        
        
        BusinessLogicException ex = new BusinessLogicException();
        
        for(integer i = 0; i < postingMeansRecordList.size(); i++) {
            
            //SUUMO物件名表示・非表示が両方trueの時
            if((postingMeansRecordList[i].isSuumoPropertyShow == true) && (postingMeansRecordList[i].isNotSuumoPropertyShow == true)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_ANYONE));
            }
            //SUUMO物件名表示・非表示が両方falseの時
            else if((postingMeansRecordList[i].isSuumoPropertyShow == false) && (postingMeansRecordList[i].isNotSuumoPropertyShow == false)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_CHOOSE));
            }
            //HOME'S物件名表示・非表示が両方trueの時
            if((postingMeansRecordList[i].isHomesPropertyShow == true) && (postingMeansRecordList[i].isNotHomesPropertyShow == true)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_ANYONE));
            }
            //HOME'S物件名表示・非表示が両方falseの時
            else if((postingMeansRecordList[i].isHomesPropertyShow == false) && (postingMeansRecordList[i].isNotHomesPropertyShow == false)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_CHOOSE));
            }
            //at home物件名表示・非表示が両方trueの時
            if((postingMeansRecordList[i].isAtHomePropertyShow == true) && (postingMeansRecordList[i].isNotAtHomePropertyShow == true)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_ANYONE));
            }
            //at home物件名表示・非表示が両方falseの時
            else if((postingMeansRecordList[i].isAtHomePropertyShow == false) && (postingMeansRecordList[i].isNotAtHomePropertyShow == false)) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_CHOOSE));
            }

            // ▼ 2022.03.16 CHINTAI本対応 掲載方法登録エラーチェック処理を追加
			//CHINTAI物件名表示・非表示が両方trueの時
			if((postingMeansRecordList[i].isChintaiPropertyShow == true) && (postingMeansRecordList[i].isNotChintaiPropertyShow == true)) {
				ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_ANYONE));
			}
			//CHINTAI物件名表示・非表示が両方falseの時
			else if((postingMeansRecordList[i].isChintaiPropertyShow == false) && (postingMeansRecordList[i].isNotChintaiPropertyShow == false)) {
				ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_CHOOSE));
			}
            // ▲ 2022.03.16 CHINTAI本対応
        }
        
        //ビジネスロジックException発行
        if(ex.hasMessage()) {
            throw ex;
        }
    }
    
    
    
    // @description 掲載方法更新処理
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/2/18
    // @return void
    public void postingMeansUpdate(){
        
        //更新用の掲載方法(店舗)リスト
        List<Shop__c> updatePostingMeansList = new List<Shop__c>();
        
        //掲載方法(店舗)の楽観ロックチェック
        Set<Id> postingMeansCheckedSet = new Set<Id>();
        Map<Id, Shop__c> postingMeansCheckedMap = new Map<Id, Shop__c>();
        
        for(screenPostingMeans s : postingMeansRecordList) {
            
            Boolean isAddPostingMeans = false; //掲載方法(店舗)更新フラグ
            
            //更新用の店舗
            Shop__c shopData = new Shop__c();
            
            //SUUMO物件名表示
            if((s.shopsRecord.IsSuumoPropertyShow__c == false) && (s.isSuumoPropertyShow == true)){
                isAddPostingMeans = true;
                shopData.IsSuumoPropertyShow__c = true;
            }
            //SUUMO非表示
            if((s.shopsRecord.IsSuumoPropertyShow__c == true) && (s.isNotSuumoPropertyShow == true)){
                isAddPostingMeans = true;
                shopData.IsSuumoPropertyShow__c = false;
            }
            //HOME'S物件名表示
            if((s.shopsRecord.IsHomesPropertyShow__c == false) && (s.isHomesPropertyShow == true)){
                isAddPostingMeans = true;
                shopData.IsHomesPropertyShow__c = true;
            }
            //HOME'S非表示
            if((s.shopsRecord.IsHomesPropertyShow__c == true) && (s.isNotHomesPropertyShow == true)){
                isAddPostingMeans = true;
                shopData.IsHomesPropertyShow__c = false;
            }
            //at home物件名表示
            if((s.shopsRecord.IsAtHomePropertyShow__c == false) && (s.isAtHomePropertyShow == true)){
                isAddPostingMeans = true;
                shopData.IsAtHomePropertyShow__c = true;
            }
            //at home非表示
            if((s.shopsRecord.IsAtHomePropertyShow__c == true) && (s.isNotAtHomePropertyShow == true)){
                isAddPostingMeans = true;
                shopData.IsAtHomePropertyShow__c = false;
            }
			
			// ▼ 2022.03.16 CHINTAI本対応 物件名更新処理を追加
			//CHINTAI物件名表示
			if((s.shopsRecord.IsChintaiPropertyShow__c == false) && (s.isChintaiPropertyShow == true)){
				isAddPostingMeans = true;
				shopData.IsChintaiPropertyShow__c = true;
			}
			//CHINTAI非表示
			if((s.shopsRecord.IsChintaiPropertyShow__c == true) && (s.isNotChintaiPropertyShow == true)){
				isAddPostingMeans = true;
				shopData.IsChintaiPropertyShow__c = false;
			}
            // ▲ 2022.03.16 CHINTAI本対応

            //更新フラグがtrueの時、更新用リストに対象の店舗データを追加
            if(isAddPostingMeans) {
                shopData.Id = s.shopsRecord.Id;
                updatePostingMeansList.add(shopData);
                postingMeansCheckedSet.add(s.shopsRecord.Id);
                postingMeansCheckedMap.put(s.shopsRecord.Id, s.shopsRecord);
            }
        }
        
        //更新用の掲載方法(店舗)リストが空でなければ、リストを更新(+ 楽観ロックチェック)
        if (!updatePostingMeansList.isEmpty()) {
            
            List<Shop__c> checkShopsData =[SELECT Id, SystemModstamp
                                           FROM Shop__c
                                           WHERE Id IN :postingMeansCheckedSet];
            
            for(Shop__c s: checkShopsData) {
                if(s.SystemModstamp != postingMeansCheckedMap.get(s.Id).SystemModstamp) {
                    OptimisticLockException ex = new OptimisticLockException();
                    throw ex;
                }
            }
            SecureDML.secureUpdate(updatePostingMeansList);
        }
    }
    
    
    
    // @description 掲載地区リスト取得
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/2/19
    // @return List<String>
    public void getDistrictStringList(){
        try{
            hasErrorMessage = false;
            
            //地区リストの初期化
            districtStringList = new List<String>();
            staticDistrictStringList = new List<String>();
            districtIndexList  = new List<Integer>();
            
            //地区の選択リスト値取得
            selectDistrictList = CommonUtil.getSelectOptionFromObject('Building__c', 'District__c', false);
            
            for(Integer i=0; i < selectDistrictList.size(); i++) {
                districtStringList.add(selectDistrictList[i].getValue());
                staticDistrictStringList.add(selectDistrictList[i].getValue());
                districtIndexList.add(i);
            }
            
        }catch(Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
            throw e;
        }
    }
   
    
    
    // @description 掲載地区登録処理
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/2/19
    // @return void
    public void registerPostingDistricts(){
        
        Savepoint sp = Database.setSavepoint();  //セーブポイント作成
        
        try{
            hasErrorMessage = false;
            
            //対象地区・店舗情報の宣言
            String  serchDistrict      = districtStringList[changeDistrictIndex];
            Integer serchDistrictIndex = changeDistrictIndex;
            Shop__c serchShop          = postingDistrictsrecordList[changeShopIndex].shopsRecordForDistrict;
            Integer serchShopIndex     = changeShopIndex;
            
            //対象のチェックボックスの値によって、登録or削除を実行
            if( postingDistrictsrecordList[changeShopIndex].checkBoxList[changeDistrictIndex].check) {
                portalPropertyUpdate(serchDistrict, serchDistrictIndex, serchShop, serchShopIndex); //ポータルサイト掲載物件登録処理
            } else {
                portalPropertyReset(serchDistrict, serchDistrictIndex, serchShop, serchShopIndex);  //ポータルサイト掲載物件初期化処理
            }
            
            //掲載地区(店舗)更新処理
            postingDistrictsUpdate();
            
            //地区StringList再設定
            staticDistrictStringList = new List<String>(districtStringList);
            
            //掲載地区明細List設定
            getScreenPostingDistricsList();
            
            //掲載方法明細List設定
            getScreenPostingMeansList();
            
        }catch(Exception e) {
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    
    
 
    
    
    
    // @description 掲載地区(店舗)更新処理
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/2/19
    // @return void
    public void postingDistrictsUpdate(){
        
        //更新用の掲載地区(店舗)リスト
        List<Shop__c> updatePostingDistrictsList = new List<Shop__c>();
        
        //掲載地区(店舗)の楽観ロックチェック
        Set<Id> postingDistrictsCheckedSet = new Set<Id>();
        Map<Id, Shop__c> postingDistrictsCheckedMap = new Map<Id, Shop__c>();
        
        for(screenPostingDistricts s : postingDistrictsRecordList) {
            
            Boolean isChange = false; //掲載地区(店舗)更新フラグ
            
            Shop__c updateShop = new Shop__c();
            
            for(integer i = 0; i < s.checkBoxList.size(); i++) {
                if(s.checkBoxList[i].check != s.oldCheckBoxList[i].check) {
                    isChange = true;
                    break;
                }
            }
            
            
            //更新フラグがtrueの場合
            if(isChange) {
                
                //対象店舗のIdを設定
                updateShop.Id = s.shopsRecordForDistrict.Id;
                
                //対象店舗のポータルサイト掲載地区に地区を追加
                updateShop.PortalSitePostingDistrict__c = String.join(getDistrictStringList(s.checkBoxList), ';');
                
                //更新用リストに対象の店舗データを追加
                updatePostingDistrictsList.add(updateShop);
                postingDistrictsCheckedSet.add(s.shopsRecordForDistrict.Id);
                postingDistrictsCheckedMap.put(s.shopsRecordForDistrict.Id, s.shopsRecordForDistrict);
            }
        }
        
        //更新用の掲載地区(店舗)リストが空でなければ、リストを更新(+ 楽観ロックチェック)
        if (!updatePostingDistrictsList.isEmpty()) {
            
            List<Shop__c> checkShopsData =[SELECT Id, SystemModstamp
                                           FROM Shop__c
                                           WHERE Id IN :postingDistrictsCheckedSet];
            
            for(Shop__c s: checkShopsData) {
                if(s.SystemModstamp != postingDistrictsCheckedMap.get(s.Id).SystemModstamp) {
                    OptimisticLockException ex = new OptimisticLockException();
                    throw ex;
                }
            }
            SecureDML.secureUpdate(updatePostingDistrictsList);
        }
    }
    
    
    
    // @description ポータルサイト掲載物件登録処理
    // @return void
    public void portalPropertyUpdate(String  serchDistrict , Integer serchDistrictIndex, Shop__c serchShop, Integer serchShopIndex){
        
        //対象地区を使用して地区別メンテナンス条件から金額下限と金額上限を取得
        List<AreaMaintenanceCondition__c> areaMaintenanceCondition = [SELECT PropertyAmountLowerLimit__c//取扱い物件 金額(下限)
                                                                      ,PropertyAmountUpperLimit__c//取扱い物件 金額(上限)
                                                                      FROM AreaMaintenanceCondition__c
                                                                      WHERE District__c = :serchDistrict];
        
        //金額下限と金額上限の設定
        Decimal amountLowerLimit = null;
        Decimal amountUpperLimit = null;
        if ( !areaMaintenanceCondition.isEmpty() ) {
            amountLowerLimit = areaMaintenanceCondition[0].PropertyAmountLowerLimit__c;            /** 金額下限 */
            amountUpperLimit = areaMaintenanceCondition[0].PropertyAmountUpperLimit__c;            /** 金額上限 */
        }
        
        //queryに使用する変数宣言
        String PROPERTY_WEBPUBLISHING_EXISTS         = CommonConst.PROPERTY_WEBPUBLISHING_EXISTS;
        String PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE  = CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE;
        String PROPERTY_LIVESTATUS_VACANCY           = CommonConst.PROPERTY_LIVESTATUS_VACANCY;
        String searchShopId = serchShop.Id;
        
        //query作成
        String query = '';
        query +=    ' SELECT Id';
        query +=    '        ,FormerSupplier__r.SUUMO_press_ban__c';
        query +=    '        ,FormerSupplier__r.HOME_S_press_ban__c';
        query +=    '        ,FormerSupplier__r.at_home_press_ban__c';
		query +=    '        ,FormerSupplier__r.Chintai_press_ban__c'; // 2022.03.16 CHINTAI本対応 querry作成処理を追加
        query +=    '        ,FormerSupplier_Our_HP_press_ban__c';
        query +=    ' FROM Property__c';
        query +=    ' WHERE Building__r.District__c = :serchDistrict';
        query +=    ' AND WebPublishing__c = :PROPERTY_WEBPUBLISHING_EXISTS';
        query +=    ' AND (LiveStatus__c = :PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE  OR  LiveStatus__c = :PROPERTY_LIVESTATUS_VACANCY)';
        query +=    ' AND Id NOT IN (SELECT Property__c FROM PortalSitePostingProperty__c WHERE Shop__c = :searchShopId)';
        if (amountLowerLimit != null) {
            query+= ' AND RentFee__c >= :amountLowerLimit';
        }
        if (amountUpperLimit != null) {
            query+= ' AND RentFee__c <= :amountUpperLimit';
        }
        query +=    ' LIMIT ' + (insertLimit + 1);
        List<Property__c> targetPortalProperty = Database.query(query);
        system.debug('何？'+targetPortalProperty);
        system.debug('1'+serchDistrict);
        
        
        //完了メッセージ設定
        if (targetPortalProperty.size() <= insertLimit) {
            
            MSG_FINISH = CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);
            isChangeDistrict = false; //変更状態を解除する
            isProcessing     = false; //継続処理を解除する
            updateSystemConfig(null, null); //システム設定更新
            
        } else {
            
            MSG_FINISH = CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_PORTALINSERT, String.valueOf(insertLimit));
            targetPortalProperty.remove(insertLimit); //+1分を削除する
            postingDistrictsrecordList[serchShopIndex].checkBoxList[serchDistrictIndex].check = false; //チェックボックスをもとに戻す
            isChangeDistrict = false; //変更状態を解除する
            isProcessing     = true;  //継続処理を設定する
            updateSystemConfig(serchDistrict, serchShop.Name); //システム設定更新
            
        }
        
        //登録用リストに設定
        List<PortalSitePostingProperty__c> insertPortalPropertyList = new List<PortalSitePostingProperty__c>();
        for(Property__c p : targetPortalProperty) {
            //掲載情報を取得
            Boolean isDispSuumo = (p.FormerSupplier__r.SUUMO_press_ban__c == true) ? false: true;
            Boolean isDispHomes = (p.FormerSupplier__r.HOME_S_press_ban__c == true) ? false: true;
            Boolean isDispAtHome = (p.FormerSupplier__r.at_home_press_ban__c == true) ? false: true;
			Boolean isDispChintai = (p.FormerSupplier__r.Chintai_press_ban__c == true) ? false: true; // 2022.03.16 CHINTAI本対応 掲載情報取得処理を追加
            Boolean isDispOurHp = (p.FormerSupplier_Our_HP_press_ban__c == true) ? false: true;

            // 掲載サイト存在チェック
            if (!isDispSuumo && !isDispHomes && !isDispAtHome  && !isDispChintai && !isDispOurHp) { // 2022.03.16 CHINTAI本対応 掲載サイト存在チェックの更新処理を追加
                continue;
            }

            insertPortalPropertyList.add(new PortalSitePostingProperty__c(Property__c       = p.Id
                                                                          , Shop__c         = serchShop.Id
                                                                          , IsSuumo__c      = isDispSuumo
                                                                          , IsHomes__c      = isDispHomes
                                                                          , IsAtHome__c     = isDispAtHome
																		  , IsChintaiNet__c = isDispChintai // 2022.03.16 CHINTAI本対応 ポータルサイト掲載物件.CHINTAIの更新処理を追加
                                                                          , IsPortal__c     = isDispOurHp));
        }
        
        //登録
        if(!insertPortalPropertyList.isEmpty()) {
            SecureDML.secureInsert(insertPortalPropertyList);
        }
        
    }
    
    
    
    // @description ポータルサイト掲載物件削除処理
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/2/19
    // @return void
    public void portalPropertyReset(String  serchDistrict, Integer serchDistrictIndex, Shop__c serchShop, Integer serchShopIndex){
        
        
        //削除対象のポータル掲載物件を取得
        List<PortalSitePostingProperty__c> targetPortalProperty = [SELECT Id FROM PortalSitePostingProperty__c
                                                                   WHERE Shop__c = :serchShop.Id
                                                                   AND PropertyDistrict__c IN (:serchDistrict)
                                                                   LIMIT :deleteLimit + 1 ];
        //完了メッセージ設定
        if (targetPortalProperty.size() <= deleteLimit) {
            
            MSG_FINISH = CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);
            isChangeDistrict = false; //変更状態を解除する
            isProcessing     = false; //継続処理を解除する
            updateSystemConfig(null, null); //システム設定更新
            
        } else {
            
            MSG_FINISH = CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_PORTALDELETE, String.valueOf(deleteLimit));
            targetPortalProperty.remove(deleteLimit); //+1分を削除する
            postingDistrictsrecordList[serchShopIndex].checkBoxList[serchDistrictIndex].check = true; //チェックボックスをもとに戻す
            isChangeDistrict = false; //変更状態を解除する
            isProcessing     = true;  //継続処理を設定する
            updateSystemConfig(serchDistrict, serchShop.Name); //システム設定更新
            
        }
        
        //削除
        if(!targetPortalProperty.isEmpty()) {
            SecureDML.secureDelete(targetPortalProperty);
        }
        
    }
    
    
    //チェックボックス変更処理
    public void decideCheckbox() {
        
        //変更フラグ更新
        isChangeDistrict = !isChangeDistrict;
           
    }
    
    
    
    
  
    
    
    
    
    //-----------------------------------------------------------------以下privateメソッド-----------------------------------------------------------------
    
    // @description 初期化メソッド
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/2/18
    // @return void
    private void init(){
        
            //初期化
            isOpenError = false;
            hasErrorMessage = false;
            
            //システム設定 取得
            this.systemConfigData =  [ SELECT Id FROM SystemConfig__c ORDER BY CreatedDate Limit 1]; //組織のデフォルト値が1つある
            this.deleteLimit      = Integer.valueOf(SystemConfig__c.getInstance().PortalProcessNumForDelete__c);
            this.insertLimit      = Integer.valueOf(SystemConfig__c.getInstance().PortalProcessNumForInsert__c);
            
            //店舗異動が取得できなければエラー
            CommonUtil.getStaffCurrentShop();

            //掲載地区リスト取得
            getDistrictStringList();
            
    }
    
    
    //チェックボックス変更状況設定
    private void setCheckBoxVariable(){

        //システム設定取得
        portalProcessCheckboxDistrict = [SELECT Id ,StringValue__c FROM SystemVariables__c  WHERE VariablesName__c = :PORTALPROCESSCHECKBOX_DISTRICT]; //処理中地区
        portalProcessCheckboxShop = [SELECT Id ,StringValue__c FROM SystemVariables__c  WHERE VariablesName__c = :PORTALPROCESSCHECKBOX_SHOP];     //処理中店舗

        
        //チェックボックス変更状況　初期化
        this.isChangeDistrict    = false; //地区のチェックボックスが変更されたかどうか
        this.isProcessing        = false; //ガバナ制限対策により、処理中かどうか
        this.changeShopIndex     = null;  //変更された店舗index
        this.changeDistrictIndex = null;  //変更された地区index
        
        //二つの変数が指し示すチェックボックスがあるか調査
        for(integer j = 0; j < postingDistrictsRecordList.size(); j++) {
            for(integer i = 0; i < postingDistrictsRecordList[j].checkBoxList.size(); i++) {
                
                //店舗と地区が システム設定の値と一致するなら
                if(postingDistrictsRecordList[j].shopsRecordForDistrict.Name == portalProcessCheckboxShop.StringValue__c &&
                   districtStringList[i] == portalProcessCheckboxDistrict.StringValue__c) {
                       //チェックボックス変更状況　設定
                       this.isChangeDistrict    = false; 
                       this.isProcessing        = true; 
                       this.changeShopIndex     = j;  
                       this.changeDistrictIndex = i;  
                       break;
                }
            }
            if(isProcessing) {
                break;
            }
        }
    }
    
    
    // @description 掲載方法明細List設定
    // @return void
    private void getScreenPostingMeansList(){
        try{
            hasErrorMessage = false;
            
            
            //内部クラスのリストを作成
            this.postingMeansRecordList = new List<screenPostingMeans>();
            
            //システム日付の取得
            Date getToday = CommonUtil.getToday();
            
            // データ取得SQL作成
            String sql = '';
            sql += 'SELECT Id';
            sql += '      ,Name';                       //店舗名
            sql += '      ,District__c';                //所在地区
            sql += '      ,IsSuumoPropertyShow__c';     //SUUMO物件名表示
            sql += '      ,IsHomesPropertyShow__c';     //HOME'S物件名表示
            sql += '      ,IsAtHomePropertyShow__c';    //at home物件名表示
			sql += '	  ,IsChintaiPropertyShow__c';   //CHINTAI物件名表示 // 2022.03.16 CHINTAI本対応 データ取得SQL作成に項目追加
            sql += '      ,SystemModstamp';             //SystemModstamp
            sql += '       FROM Shop__c';
            sql += '       WHERE (SystemUseStartDate__c <= :getToday ';
            sql += '            AND SystemUseEndDate__c   >= :getToday ';
            sql += '      	      )';
            sql += '       AND IsShopType__c    = TRUE ';
            sql += '       ORDER BY SortOrder__c';
            
            // データ取得
            List<Shop__c> shopsRecordList = Database.query(sql);
            
            
            //取得したデータの明細を回す
            for(shop__c s : shopsRecordList) {
                this.postingMeansRecordList.add(new screenPostingMeans(s));
            }
            
        }catch(Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
            throw e;
        }
    }
    
    
    
    // @description 掲載地区明細List設定
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/2/19
    // @return void
    private void getScreenPostingDistricsList(){
        try{
            hasErrorMessage = false;
            
            
            //内部クラスのリストを作成
            this.postingDistrictsRecordList = new List<screenPostingDistricts>();
            
            //システム日付の取得
            Date getToday = CommonUtil.getToday();
            
            // データ取得SQL作成
            String sql = '';
            sql += 'SELECT Id';
            sql += '      ,Name';                       //店舗名
            sql += '      ,District__c';                //所在地区
            sql += '      ,PortalSitePostingDistrict__c'; //ポータル掲載地区		
            sql += '      ,SystemModstamp';             //SystemModstamp
            sql += '       FROM Shop__c';
            sql += '       WHERE (SystemUseStartDate__c   <= :getToday ';
            sql += '            AND SystemUseEndDate__c   >= :getToday ';
            sql += '      	      )';
            sql += '       AND IsShopType__c    = TRUE ';
            sql += '       ORDER BY SortOrder__c';
            
            // データ取得
            List<Shop__c> portalRecordList = Database.query(sql);
            
            
            //取得したデータの明細を回す
            for(Shop__c s : portalRecordList) {
                this.postingDistrictsRecordList.add(new screenPostingDistricts(s));
            }
            
            
        }catch(Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
            throw e;
        }
    }
    
    
    // @description 明細地区List取得
    // @param List<Boolean> checkBoxList
    // @return List<String>
    private List<String> getDistrictStringList(List<checkBox> checkBoxList){
        
        List<String>  getDistrictStringList = new List<String>();
        
        for(integer i = 0; i < checkBoxList.size(); i++) {
            if(checkBoxList[i].check == true) {
                getDistrictStringList.add(districtStringList[i]);
            }
        }
        return getDistrictStringList;
    }
    
    
    //システム設定更新
    private void updateSystemConfig(String serchDistrict, String serchShop){
        this.portalProcessCheckboxDistrict.StringValue__c = serchDistrict;
        SecureDML.secureUpdate(portalProcessCheckboxDistrict);
        this.portalProcessCheckboxShop.StringValue__c     = serchShop;
        SecureDML.secureUpdate(portalProcessCheckboxShop);


    }
    
    //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓以下内部クラス↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    
    //掲載方法明細の内部クラス
    public class screenPostingMeans {
        
        //明細の店舗
        public Shop__c shopsRecord { get; set; }
        //SUUMO物件名表示
        public Boolean isSuumoPropertyShow { get; set; }
        //SUUMO非表示
        public Boolean isNotSuumoPropertyShow { get; set; }
        //HOME'S物件名表示
        public Boolean isHomesPropertyShow { get; set; }
        //HOME'S非表示
        public Boolean isNotHomesPropertyShow { get; set; }
        //at home物件名表示
        public Boolean isAtHomePropertyShow { get; set; }
        //at home非表示
        public Boolean isNotAtHomePropertyShow { get; set; }

		// ▼ 2022.03.16 CHINTAI本対応 内部クラスに項目を追加
		//CHINTAI物件名表示
		public Boolean isChintaiPropertyShow { get; set; }
		//CHINTAI非表示
		public Boolean isNotChintaiPropertyShow { get; set; }
		// ▲ 2022.03.16 CHINTAI本対応
        
        //コンストラクタ（引数：店舗）
        public screenPostingMeans(Shop__c targetShopsRecord){
            
            //物件名表示・非表示のチェックボックスを初期化
            isSuumoPropertyShow = false;
            isNotSuumoPropertyShow = false;
            isHomesPropertyShow = false;
            isNotHomesPropertyShow = false;
            isAtHomePropertyShow = false;
            isNotAtHomePropertyShow = false;

			// ▼ 2022.03.16 CHINTAI本対応 チェックボックス初期化処理に項目を追加
			isChintaiPropertyShow = false; 
			isNotChintaiPropertyShow = false;
			// ▲ 2022.03.16 CHINTAI本対応
            
            //変数の店舗に、引数の店舗を設定
            shopsRecord = targetShopsRecord;
            
            //物件名表示・非表示のチェックボックス化
            if(shopsRecord.IsSuumoPropertyShow__c == true) {
                //SUUMO(物件名表示)
                isSuumoPropertyShow = true;
                isNotSuumoPropertyShow = false;
            }else{
                //SUUMO(非表示)
                isSuumoPropertyShow = false;
                isNotSuumoPropertyShow = true;
            }
            
            if(shopsRecord.IsHomesPropertyShow__c == true) {
                //HOME'S(物件名表示)
                isHomesPropertyShow = true;
                isNotHomesPropertyShow = false;
            }else{
                //HOME'S(非表示)
                isHomesPropertyShow = false;
                isNotHomesPropertyShow = true;
            }
            
            if(shopsRecord.IsAtHomePropertyShow__c == true) {
                //at home(物件名表示)
                isAtHomePropertyShow = true;
                isNotAtHomePropertyShow = false;
            }else{
                //at home(非表示)
                isAtHomePropertyShow = false;
                isNotAtHomePropertyShow = true;
            }

			// ▼ 2022.03.16 CHINTAI本対応 物件名表示・非表示のチェックボックス化処理を追加
			if(shopsRecord.IsChintaiPropertyShow__c == true) {
				//CHINTAI(物件名表示)
				isChintaiPropertyShow = true;
				isNotChintaiPropertyShow = false;
			}else{
				//CHINTAI(非表示)
				isChintaiPropertyShow = false;
				isNotChintaiPropertyShow = true;
			}
			// ▲ 2022.03.16 CHINTAI本対応
        }
    }
    
    //掲載地区明細の内部クラス
    public class screenPostingDistricts {
        //明細の店舗
        public Shop__c shopsRecordForDistrict { get; set; }
        //【新】掲載地区リスト
        public List<checkBox> checkBoxList { get; set; }
        //【旧】掲載地区リスト
        public List<checkBox> oldCheckBoxList { get; set; }
        
        //コンストラクタ（引数：店舗）
        public screenPostingDistricts(Shop__c targetShopsRecordForDistrict){
            
            //変数の店舗に、引数の店舗を設定
            shopsRecordForDistrict = targetShopsRecordForDistrict;
            
            //【新】掲載地区リスト作成
            checkBoxList = new List<checkBox>();
            
            //【旧】掲載地区リスト作成
            oldCheckBoxList = new List<checkBox>();
            
            //地区の数だけチェックボックスを作成・初期化
            for(String s : staticDistrictStringList) {
                checkBoxList.add(new checkBox(false));
                oldCheckBoxList.add(new checkBox(false));
            }
            
            //店舗のポータルサイト掲載地区がnullでない場合、該当の地区にチェックをつける
            if(shopsRecordForDistrict.PortalSitePostingDistrict__c != null) {
                List<String> postingDistrictList = shopsRecordForDistrict.PortalSitePostingDistrict__c.split(';');
                for(integer i = 0; i < checkBoxList.size(); i++) {
                    if( postingDistrictList.contains(staticDistrictStringList[i]) ) {
                        checkBoxList[i].check = true;
                    }
                }
                for(integer i = 0; i < oldCheckBoxList.size(); i++) {
                    if( postingDistrictList.contains(staticDistrictStringList[i]) ) {
                        oldCheckBoxList[i].check = true;
                    }
                }
            }
        }
    }
    
    //内部クラス　チェックボックス単体(List<Boolean>が使えないためやむなし)
    public class checkBox {
        public Boolean check {get; set;}
        
        public checkBox(Boolean check) {
            this.check = check;
        }
    }
    
}