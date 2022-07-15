/**
* @File Name          : GD401001Controller.cls
* @Description        : ポータル連携一覧画面のコントローラ
**/
public inherited sharing class GD401001Controller {
    
    /** パブリック変数 */
    
    /** メッセージ系 */
    public String MSG_COM_V_SAVE {get {return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get {return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_BULKREGISTRATION {get {return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_BULKREGISTRATION);} private set;}    //js用一括確認メッセージ
    public String MSG_COM_I_BULKREGISTRATION {get {return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_BULKREGISTRATION);} private set;}    //js用一括確認完了メッセージ
    public String MSG_COM_BULKREGISTRATION { get; set; } //一括確認完了メッセージ(判定用)
    public String unlistedSiteMsgOfShop { get; set; } //店舗の未掲載サイトメッセージ
    
    /** 選択リスト値 */
    public String shopsName { get; set; }                                    // 店舗（リスト選択時）
    public list<SelectOption> selectShopList { get; set; }                   // 店舗のリスト設定
    public String targetShopsName { get; set; }                            	 // 店舗（検索時点）
    public String portalSite {get; set;}                                     // ポータルサイト（リスト選択時）
    public list<SelectOption> selectPortalSiteList { get; set; }             // ポータルサイトのリスト設定
    public String propertyDistrict { get; set; }                             // 検索用地区（リスト選択時）
    public List<SelectOption> selectPropertyDistrictList { get; set; }       // 検索用地区のリスト設定
    
    /** 必須のラジオボタン */
    public String propertyType { get; set; }
    
    /** 物件ID */
    public String propertyId { get; set; }
    
    /** 金額下限 */
    public Decimal amountLowerLimit { get; set; }
    
    /** 金額上限 */
    public Decimal amountUpperLimit { get; set; }

	// ▼ 2022.03.30 CHINTAI本対応 全店舗マップの項目を追加
	/** 全店舗 */
	public Map<Id, shop__c> shopMap { get; set; }
	// ▲ 2022.03.30 CHINTAI本対応
    
    /** 物件名 */
    public String propertyName { get; set; }
    
    /** 住所(丁目まで) */
    public String propertyAddress { get; set; }
    
    /** 元付業者名 */
    public String formerSupplier { get; set; }
    
    /** 点数 */
    public String propertyScore { get; set; }
    
    /** パノラマ掲載物件 */
    public Boolean panoramaPostingProperty { get; set; }
    
    /** 検索時店舗ID */
    public String searchShopId { get; set; }
    
    /** 検索結果の総件数 */
    public integer allPropertyCount { get; set; }
    public integer allSuumoPropertyCount { get; set; }
    public integer allHomesPropertyCount { get; set; }
    public integer allAtHomePropertyCount { get; set; }
	public integer allChintaiPropertyCount { get; set; } // 2022.03.22 CHINTAI本対応 変数追加
    
    /** 検索結果のパノラマ登録件数 */ // 2022.03.22 CHINTAI本対応 名称変更
    public integer allPropertyPanoramaCount { get; set; }
    public integer allSuumoPropertyPanoramaCount { get; set; }
    public integer allHomesPropertyPanoramaCount { get; set; }
    public integer allAtHomePropertyPanoramaCount { get; set; }
	public integer allChintaiPropertyPanoramaCount { get; set; } // 2022.03.22 CHINTAI本対応 変数追加
    
    /** 検索結果のパノラマ掲載件数 */ // 2022.03.22 CHINTAI本対応 名称変更
    public integer propertyPanoramaCount { get; set; }
    public integer suumoPropertyPanoramaCount { get; set; }
    public integer homesPropertyPanoramaCount { get; set; }
    public integer atHomePropertyPanoramaCount { get; set; }
	public integer chintaiPropertyPanoramaCount { get; set; } // 2022.03.22 CHINTAI本対応 変数追加
    
    /** 検索件数 */
    public integer searchedPropertyCount { get; set; }
    public integer searchedSuumoPropertyCount { get; set; }
    public integer searchedHomesPropertyCount { get; set; }
    public integer searchedAtHomePropertyCount { get; set; }
	public integer searchedChintaiPropertyCount { get; set; } // 2022.03.22 CHINTAI本対応 変数追加
    
    /** 濃いグレーの物件はあと1日で掲載が落ちます。 */
    public integer lastPropertyCount { get; set; }
    
    /** グレーの物件はあと2、3日で掲載が落ちます。 */
    public integer latestPropertyCount { get; set; }
    
    /** 物件とポータルサイト掲載物件の明細リスト */
    public List<screenProperty> propertyAndPortalRecordList { get; set; }
    /** 物件とポータルサイト掲載物件の明細リスト(画面ページング表示用のn件毎2階層List) */
    private List<Id> searchResultPropertyId { get; set; }
    
    /** 物件とポータルサイト掲載物件の明細リストの全体件数 */
    public Integer propertyAndPortalRecordListCount { get; set; }
    
    /** エラーフラグ(初回のみ) */
    public Boolean isOpenError { get; set; }
    
    /** エラーメッセージ保有フラグ */
    public Boolean hasErrorMessage { get; set; }
    
    /** 更新可能上限設定用 */
    public Integer CHECKBOXWEIGHT_MAX               { get{return Integer.valueOf(SystemConfig__c.getInstance().PotalSiteCheckboxWeight_Max__c);}            private set; }
    public Integer CHECKBOXWEIGHT_PORTALPROPERTY    { get{return Integer.valueOf(SystemConfig__c.getInstance().PotalSiteCheckboxWeight_PortalProperty__c);} private set; }
    public Integer CHECKBOXWEIGHT_PROPERTY          { get{return Integer.valueOf(SystemConfig__c.getInstance().PotalSiteCheckboxWeight_Property__c);}       private set; }
    
    /** プライベート変数 */
    
    /** ポータルサイトの選択リスト値 */
    private final String SUUMO_STRING = 'SUUMO'; 
    private final String HOMES_STRING = 'HOMES';
    private final String ATHOME_STRING = 'At home';
	private final String CHINTAI_STRING = CommonCONST.PORTALSITE_NAME_CHINTAI; // 2022.04.07 CHINTAI本対応 変数追加と定数化
    
    /** 検索クエリ用文字列 */
    private String propertyNameText;
    private String propertyAddressText;
    private String formerSupplierText;
    
    /** 明細の背景色 */
    private static final String COLOR_W = '#FFFFFF';       //白色
    private static final String COLOR_G = '#d8d8d8';       //灰色
    private static final String COLOR_DG = '#AEAEAE';      //濃い灰色
    
    // システム設定
    private Integer searchLimit;
    private Integer selectLimit;
    private Date systemToday;
    private DateTime systemNow;
    
    // ページング関連
    private Integer pageDisplayNumber;                  // 1ページへの物件表示数
    public List<SelectOption> pageingList { get; set; } // ページ選択用のリスト
    public Integer pageCount { get; set; }
    public String selectPageIndex { get; set; }
    private Integer currentPageIndex { get; set; }


    public GD401001Controller() {
        try {
            //初期化
            init();
            
            //地区変更処理
            changeDistrict();

			// ▼ 2022.04.04 CHINTAI本対応 全店舗取得処理を追加
			//全店舗取得処理
			getAllShops();
			// ▲ 2022.04.04 CHINTAI本対応 

            
        } catch (Exception e) {
            isOpenError = true; //エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //====================================================================以下publicメソッド=================================================================
    // @description 物件種別ラジオボタン（VFオプション）
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/1/24
    // @return List<SelectOption>
    public List<SelectOption> getIsPropertyTypeRadioButton(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('ポータル連携物件', 'ポータル連携物件'));
        options.add(new SelectOption('パノラマ掲載物件', 'パノラマ掲載物件'));
        options.add(new SelectOption('全物件(空室・退去予定)', '全物件(空室・退去予定)'));
        return options;
    }
    
    // @description 地区変更処理
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/1/24
    // @return void
    public void changeDistrict(){
        try {
            hasErrorMessage = false;
            //金額下限、金額上限にnullを設定
            
            /** 金額下限 */
            amountLowerLimit = null;
            
            /** 金額上限 */
            amountUpperLimit = null;
            
            if(propertyDistrict != '') {
                //検索用地区を使用して地区別メンテナンス条件から金額下限と金額上限を取得
                List<AreaMaintenanceCondition__c> areaMaintenanceCondition = [SELECT PropertyAmountLowerLimit__c//取扱い物件 金額(下限)
                                                                              ,PropertyAmountUpperLimit__c//取扱い物件 金額(上限)
                                                                              FROM AreaMaintenanceCondition__c
                                                                              WHERE District__c = :propertyDistrict];
                
                if(areaMaintenanceCondition.size() > 0) {
                    
                    /** 金額下限 */
                    amountLowerLimit = areaMaintenanceCondition[0].PropertyAmountLowerLimit__c;
                    
                    /** 金額上限 */
                    amountUpperLimit = areaMaintenanceCondition[0].PropertyAmountUpperLimit__c;
                }
            }
            
            system.debug('地区;' + propertyDistrict);
            
        }catch(Exception e) {
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

	// ▼ 2022.04.04 CHINTAI本対応 全店舗取得処理を追加
	// @description 全店舗取得処理
	// @author ChangeMeIn@UserSettingsUnder.SFDoc | 2022/3/30
	// @return void
	public void getAllShops(){
		//全店舗データの取得
		shopMap = new Map<Id, Shop__c>([SELECT id,IsChintaiPanoramaContract__c FROM Shop__c]);
	}
	// ▲ 2022.04.04 CHINTAI本対応 
    
    
    // @description 点数ラジオボタン（VFオプション）
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/1/24
    // @return List<SelectOption>
    public List<SelectOption> getIsPropertyScoreRadioButton(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('34点未満', '34点未満'));
        options.add(new SelectOption('34~35点', '34~35点'));
        options.add(new SelectOption('36点以上', '36点以上'));
        options.add(new SelectOption('全て', '全て'));
        return options;
    }
    
    
    // @description 検索ボタン処理
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/1/24
    // @return void
    public void search() {
        try{
            hasErrorMessage = false;
            
            //件数確認  
            String sql = '';
            sql += 'SELECT Id ';
            sql += 'FROM Property__c '; 
            sql +=  maintenanceSearch();
            sql += ' LIMIT ' + this.searchLimit + ' ';
            
            List<Property__c> propertyRecordCount = Database.query(sql);
            
            System.debug('件数確認;' + propertyRecordCount.size());
            
            System.debug('エラー1;' + hasErrorMessage);
            
            // 検索結果件数チェック
            if (propertyRecordCount.size() == 0) {
                // ビジネスロジックException発行
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
                throw ex;
            }
            
            //上限越えチェック
            if (propertyRecordCount.size() > this.searchLimit) {
                // ビジネスロジックException発行
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_RESULT_LIMIT_OVER));
                throw ex;
            }
            
            System.debug('エラー2;' + hasErrorMessage);
            
            //検索処理
            searchProperty();
            
            System.debug('件数確認2;' + propertyRecordCount.size());
            
            System.debug('エラー3;' + hasErrorMessage);
            
        }catch(Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    

    // @description 検索条件管理
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/1/24
    // @return string
    public string maintenanceSearch(){
        
        //検索
        system.debug('検索');
        String sql = '';
        
        //検索時の店舗(パラメータ)を保存
        targetShopsName = shopsName;
        
        //クエリ用テキストを作成
        this.propertyNameText    = '%' + CommonUtil.convertDisableWildcard(this.propertyName)    + '%';
        this.propertyAddressText = '%' + CommonUtil.convertDisableWildcard(this.propertyAddress) + '%';
        this.formerSupplierText  = '%' + CommonUtil.convertDisableWildcard(this.formerSupplier)  + '%';
        
        //web公開＝'する' 
        sql += '  WHERE WebPublishing__c = \'' + CommonConst.PROPERTY_WEBPUBLISHING_EXISTS + '\'';
        
        //物件をポータルサイト掲載物件で絞る
        if(this.propertyType == 'ポータル連携物件') {
            sql += '   AND 	Id IN (SELECT Property__c';
            sql += '				FROM PortalSitePostingProperty__c';
            sql += '				WHERE Shop__c = \''+ String.escapeSingleQuotes(this.targetShopsName) + '\'';
            sql += '      			)';
        }
        
        //パノラマ掲載物件ラジオボタン選択時 　
        if(this.propertyType == 'パノラマ掲載物件' && this.portalSite == 'SUUMO_STRING') {       //SUUMO
            sql += '   AND 	SuumoPanoramaShop__c = \'' + String.escapeSingleQuotes(this.targetShopsName) + '\'';
        }
        
        if(this.propertyType == 'パノラマ掲載物件' && this.portalSite == 'HOMES_STRING') {      //HOME'S
            sql += '   AND 	HomesPanoramaShop__c = \'' + String.escapeSingleQuotes(this.targetShopsName) + '\'';
        }
        
        if(this.propertyType == 'パノラマ掲載物件' && this.portalSite == 'ATHOME_STRING') {    //At home
            sql += '   AND 	AtHomePanoramaShop__c = \'' + String.escapeSingleQuotes(this.targetShopsName) + '\'';
        }

		// ▼ 2022.04.04 CHINTAI本対応 パノラマ掲載物件ラジオボタン選択時処理にCHINTAIを追加  
		if(this.propertyType == 'パノラマ掲載物件' && this.portalSite == CHINTAI_STRING) {    //CHINTAI
            sql += '   AND 	Id IN (SELECT Property__c';
            sql += '				 FROM PortalSitePostingProperty__c';
            sql += '				WHERE IsChintaiPanoramaPosting__c = true';
			sql += '				  AND Shop__r.IsChintaiPanoramaContract__c = true';
			sql += '				  AND Shop__c = \''+ String.escapeSingleQuotes(this.targetShopsName) + '\'';
            sql += '      			)';
		}
		// ▲ 2022.04.04 CHINTAI本対応
        
        //全物件(空室・退去予定)ラジオボタン選択時
        if(this.propertyType == '全物件(空室・退去予定)') {
            // sql += '   AND 	(LiveStatus__c = \'空室\'';
            // sql += '   	OR 	LiveStatus__c = \'退去予定\'';
            sql += '   AND 	(LiveStatus__c =\'' + CommonConst.PROPERTY_LIVESTATUS_VACANCY + '\'';
            sql += '   	OR 	LiveStatus__c = \'' + CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE + '\'';
            sql += '      	)';
        }
        
        /** 任意条件 */
        //物件Idが空白でなければ追加 (あればここで検索処理終了)
        if(String.isNotBlank(this.propertyId)) {
            sql += '   AND 	PropertyCode__c = \'' + String.escapeSingleQuotes(this.propertyId) + '\'';
        }else{
            
            // 検索用地区が空白でなければ追加
            system.debug('検索用地区が空白でなければ追加');
            if(String.isNotBlank(this.propertyDistrict)) {
                //建物の地区 ＝ 検索用検索地区
                system.debug('建物の地区 ＝ 検索用検索地区');
                sql += '   AND Building__r.District__c = \'' + String.escapeSingleQuotes(this.propertyDistrict) + '\'';
            }
            
            // 検索用金額下限がisNotBlankなら追加
            system.debug('検索用金額下限がisNotBlankなら追加');
            if(String.isNotBlank(String.valueOf(this.amountLowerLimit))) {
                //物件の賃料 ≧ 検索用金額下限
                system.debug('物件の賃料 ≧ 検索用金額下限');
                sql += '   AND RentFee__c   >= ' + this.amountLowerLimit;
            }
            
            // 検索用金額上限がisNotBlankなら追加
            system.debug('検索用金額上限がisNotBlankなら追加');
            if(String.isNotBlank(String.valueOf(this.amountUpperLimit))) {
                //物件の賃料 ≦ 検索用金額上限
                system.debug('物件の賃料 ≦ 検索用金額上限');
                sql += '   AND RentFee__c   <= ' + this.amountUpperLimit;
            }
            
            //物件名が空白でなければ追加
            if(String.isNotBlank(this.propertyName)) {
                sql += '   AND 	(Building__r.BuildingNameSearch__c LIKE :propertyNameText ';
                sql += '   	OR 	Name LIKE :propertyNameText ';
                sql += '      	)';
            }
            
            //住所(丁目まで)が空白でなければ追加
            if(String.isNotBlank(this.propertyAddress)) {
                sql += '   AND 	Building__r.Address__c LIKE :propertyAddressText ';
            }
            
            //元付業者名が空白でなければ追加
            if(String.isNotBlank(this.formerSupplier)) {
                sql += '   AND 	FormerSupplier__r.Name LIKE :formerSupplierText ';
            }
            
            //点数(３４点未満)がTRUE
            if(this.propertyScore == '34点未満') {
                sql += '   AND 	Score__c < ' + 34;
            }
            
            //点数(３４～３５点)がTRUE
            if(this.propertyScore == '34~35点') {
                sql += '   AND 	Score__c >= ' + 34;
                sql += '   AND 	Score__c <= ' + 35;
            }
            
            //点数(３６点以上)がTRUE
            if(this.propertyScore == '36点以上') {
                sql += '   AND 	Score__c >= ' + 36;
            }
            
            //パノラマ掲載物件がTRUE
            if(this.panoramaPostingProperty == true) {
                sql += '   AND 	PropertyPanoramaCount__c > ' + 0;
            }
        }
        return sql;
    }
    
 
    // @description 登録処理
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/1/30
    // @return void
    public void registerProperty() {
        
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        
        try{
            hasErrorMessage = false;
            
            registerErrorCheck();
            
            registerPropertyUpdate();
            
            System.debug('登録エラー;' + hasErrorMessage);
            
            // 現在ページ再取得
            selectPage();
            
        }catch(Exception e) {
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    
    // @description 登録時エラーチェック
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/2/3
    // @return void
    public void registerErrorCheck(){
        
        BusinessLogicException ex = new BusinessLogicException();
        
        
        for(integer i = 0; i < propertyAndPortalRecordList.size(); i++) {
            
            //SUUMOパノラマ掲載先＝true かつ 掲載先(SUUMO)＝false
            if((propertyAndPortalRecordList[i].portalPropertyRecord.IsSuumo__c == false) && (propertyAndPortalRecordList[i].isSuumoPanoramaPropertyCheck == true)) {
                ex.addMessage(CommonUtil.callMessageCreate(i+1 + '行目 ' + CommonConst.MSG_PROP_E_PANORAMA_POSTING));
            }
            //HOME'Sパノラマ掲載先＝true かつ 掲載先(HOME'S)＝false
            else if((propertyAndPortalRecordList[i].portalPropertyRecord.IsHomes__c == false) && (propertyAndPortalRecordList[i].isHomesPanoramaPropertyCheck == true)) {
                ex.addMessage(CommonUtil.callMessageCreate(i+1 + '行目 ' + CommonConst.MSG_PROP_E_PANORAMA_POSTING));
            }
            //At homeパノラマ掲載先＝true かつ 掲載先(At home)＝false
            else if((propertyAndPortalRecordList[i].portalPropertyRecord.IsAtHome__c == false) && (propertyAndPortalRecordList[i].isAtHomePanoramaPropertyCheck == true)) {
                ex.addMessage(CommonUtil.callMessageCreate(i+1 + '行目 ' + CommonConst.MSG_PROP_E_PANORAMA_POSTING));
            }

			// ▼ 2022.03.29 CHINTAI本対応 登録時エラーチェック処理にCHINTAIを追加
			//CHINTAIパノラマ掲載先＝true かつ 掲載先(CHINTAI)＝false
			else if((propertyAndPortalRecordList[i].portalPropertyRecord.IsChintaiNet__c == false) && (propertyAndPortalRecordList[i].isChintaiPanoramaPropertyCheck == true)) {
				ex.addMessage(CommonUtil.callMessageCreate(i+1 + '行目 ' + CommonConst.MSG_PROP_E_PANORAMA_POSTING));
			}
			// ▲ 2022.03.29 CHINTAI本対応 
        }
        
        //ビジネスロジックException発行
        if(ex.hasMessage()) {
            throw ex;
        }
    }
    

    // @description 更新処理
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/2/3
    // @return void
    public void registerPropertyUpdate(){
        
        //新規作成・更新用のポータル掲載物件リスト
        List<PortalSitePostingProperty__c> upsertPortalPropertyList = new List<PortalSitePostingProperty__c>();
        //削除用のポータル掲載物件リスト
        List<PortalSitePostingProperty__c> deletePortalPropertyList = new List<PortalSitePostingProperty__c>();
        //更新用の物件リスト
        List<Property__c> updatePropertyList = new List<Property__c>();
        
        //ポータル掲載物件の楽観ロックチェック
        Set<Id> portalPropertyCheckedSet = new Set<Id>();
        Map<Id, PortalSitePostingProperty__c> portalPropertyCheckedMap = new Map<Id, PortalSitePostingProperty__c>();
        
        //物件の楽観ロックチェック 
        Set<Id> propertyCheckedSet = new Set<Id>();
        Map<Id, Property__c> propertyCheckedMap = new Map<Id, Property__c>();
        
        for(screenProperty s : propertyAndPortalRecordList) {
            
            Boolean isAddPortal = false;    //ポータル掲載物件更新フラグ
            Boolean isAddProperty = false;  //物件更新フラグ
            
            //更新用のポータル掲載物件
            PortalSitePostingProperty__c portalPropertyData = new PortalSitePostingProperty__c();
            //更新用の物件
            Property__c propertyData = new Property__c();
            
            /** ポータルサイト掲載物件オブジェクト */
            
            //新規の場合、新規作成用リストに対象のポータル掲載物件データを追加
            if(s.portalPropertyRecord.Id == null){
                if(s.portalPropertyRecord.IsSuumo__c||s.portalPropertyRecord.IsHomes__c||s.portalPropertyRecord.IsAtHome__c ||s.portalPropertyRecord.IsChintaiNet__c || s.portalPropertyRecord.IsPortal__c){ // 2022.03.29 CHINTAI本対応 ポータル掲載物件データにCHINTAIを追加
                    upsertPortalPropertyList.add(s.portalPropertyRecord);
                } else {
                    system.debug('新規の処理なし');
                }
                //更新の場合
            } else {
                system.debug('ポータル連携物件あるよ');
                //掲載先が一つでも選択されている場合
                if(s.portalPropertyRecord.IsSuumo__c||s.portalPropertyRecord.IsHomes__c||s.portalPropertyRecord.IsAtHome__c ||s.portalPropertyRecord.IsChintaiNet__c || s.portalPropertyRecord.IsPortal__c){// 2022.03.29 CHINTAI本対応 ポータル掲載物件データにCHINTAIを追加
                    system.debug('更新の確認するよ');
                    //掲載先(SUUMO)
                    if(s.portalPropertyRecord.IsSuumo__c != s.propertyRecord.PortalSitePostingPropertyProperty__r[0].IsSuumo__c) {
                        isAddPortal = true;
                        portalPropertyData.IsSuumo__c = s.portalPropertyRecord.IsSuumo__c;
                    }
                    //掲載先(HOME'S)
                    if(s.portalPropertyRecord.IsHomes__c != s.propertyRecord.PortalSitePostingPropertyProperty__r[0].IsHomes__c) {
                        isAddPortal = true;
                        portalPropertyData.IsHomes__c = s.portalPropertyRecord.IsHomes__c;
                    }
                    //掲載先(At home)
                    if(s.portalPropertyRecord.IsAtHome__c != s.propertyRecord.PortalSitePostingPropertyProperty__r[0].IsAtHome__c) {
                        isAddPortal = true;
                        portalPropertyData.IsAtHome__c = s.portalPropertyRecord.IsAtHome__c;
                    }

					// ▼ 2022.04.05 CHINTAI本対応 掲載先にCHINTAIを追加
					//掲載先(CHINTAI)
					if(s.portalPropertyRecord.IsChintaiNet__c != s.propertyRecord.PortalSitePostingPropertyProperty__r[0].IsChintaiNet__c) {
						isAddPortal = true;
						portalPropertyData.IsChintaiNet__c = s.portalPropertyRecord.IsChintaiNet__c;
					}
					//パノラマ掲載先(CHINTAI)
					if(s.isChintaiPanoramaPropertyCheck != s.propertyRecord.PortalSitePostingPropertyProperty__r[0].IsChintaiPanoramaPosting__c) {
						isAddPortal = true;
						portalPropertyData.IsChintaiPanoramaPosting__c = s.isChintaiPanoramaPropertyCheck;
					}
					// ▲ 2022.04.05 CHINTAI本対応 

                    //更新フラグがtrueの時、更新用リストに対象のポータル掲載物件データを追加
                    if(isAddPortal) {
                        portalPropertyData.Id = s.propertyRecord.PortalSitePostingPropertyProperty__r[0].Id;
                        upsertPortalPropertyList.add(portalPropertyData);
                        portalPropertyCheckedSet.add(s.propertyRecord.PortalSitePostingPropertyProperty__r[0].Id);
                        portalPropertyCheckedMap.put(s.propertyRecord.PortalSitePostingPropertyProperty__r[0].Id,
                                                     s.propertyRecord.PortalSitePostingPropertyProperty__r[0]);
                    }
                    //掲載先が全てfalseの場合、削除用リストに対象のポータル掲載物件データを追加
                } else{
                    system.debug('削除するよ');
                    deletePortalPropertyList.add(s.portalPropertyRecord);
                }
            }
            system.debug('更新フラグ(ポータル掲載物件)；' + isAddPortal);
            system.debug('削除用リスト；' + deletePortalPropertyList);
            
            /** 物件オブジェクト */
            //パノラマ掲載先(SUUMO) チェックなし→あり
            if((s.isSuumoPanoramaPropertyCheck == true) && (s.propertyRecord.SuumoPanoramaShop__c == null)) {
                isAddProperty = true;
                propertyData.SuumoPanoramaShop__c = targetShopsName;
            }
            //パノラマ掲載先(SUUMO) チェックあり→なし
            if((s.isSuumoPanoramaPropertyCheck == false) && (s.propertyRecord.SuumoPanoramaShop__c == targetShopsName)) {
                isAddProperty = true;
                propertyData.SuumoPanoramaShop__c = null;
            }
            //パノラマ掲載先(HOME'S) チェックなし→あり
            if((s.isHomesPanoramaPropertyCheck == true) && (s.propertyRecord.HomesPanoramaShop__c == null)) {
                isAddProperty = true;
                propertyData.HomesPanoramaShop__c = targetShopsName;
            }
            //パノラマ掲載先(HOME'S) チェックあり→なし
            if((s.isHomesPanoramaPropertyCheck == false) && (s.propertyRecord.HomesPanoramaShop__c == targetShopsName)) {
                isAddProperty = true;
                propertyData.HomesPanoramaShop__c = null;
            }
            //パノラマ掲載先(At home) チェックあり→なし
            if((s.isAtHomePanoramaPropertyCheck == false) && (s.propertyRecord.AtHomePanoramaShop__c == targetShopsName)) {
                isAddProperty = true;
                propertyData.AtHomePanoramaShop__c = null;
            }
            //更新フラグがtrueの時、更新用リストに対象の物件データを追加
            if(isAddProperty) {
                propertyData.Id = s.propertyRecord.Id;
                updatePropertyList.add(propertyData);
                propertyCheckedSet.add(s.propertyRecord.Id);
                propertyCheckedMap.put(s.propertyRecord.Id, s.propertyRecord);
            }
        }
        
        //更新用のポータル掲載物件リストが空でなければ、リストを更新(+ 楽観ロックチェック)
        if (!upsertPortalPropertyList.isEmpty()) {	
            
            List<PortalSitePostingProperty__c> checkPortalPropertyData =[SELECT Id, SystemModstamp
                                                                         FROM PortalSitePostingProperty__c
                                                                         WHERE Id IN :portalPropertyCheckedSet];
            
            for(PortalSitePostingProperty__c p: checkPortalPropertyData){
                if(p.SystemModstamp != portalPropertyCheckedMap.get(p.Id).SystemModstamp){
                    OptimisticLockException ex = new OptimisticLockException();
                    throw ex;
                }
            }
            SecureDML.secureUpsert(upsertPortalPropertyList);
        }
        
        //削除用のポータル掲載物件リストが空でなければ、リストを削除
        if (!deletePortalPropertyList.isEmpty()) {
            SecureDML.secureDelete(deletePortalPropertyList);
        }
        
        //更新用の物件リストが空でなければ、リストを更新(+ 楽観ロックチェック)
        if (!updatePropertyList.isEmpty()) {
            
            List<Property__c> checkPropertyData =[SELECT Id, SystemModstamp
                                                  FROM Property__c
                                                  WHERE Id IN :propertyCheckedSet];
            
            for(Property__c p: checkPropertyData){
                if(p.SystemModstamp != propertyCheckedMap.get(p.Id).SystemModstamp){
                    OptimisticLockException ex = new OptimisticLockException();
                    throw ex;
                }
            }
            
            BD301002TriggerHandler.isOnlyCreateDifference = true;
            SecureDML.secureUpdate(updatePropertyList);
            
            //建物物件差分の作成
            Set<Id> IdSet = new Set<Id>();
            
            for(Property__c p : updatePropertyList){
                IdSet.add(p.Id);
            }
            
            
            BuildingPropertyUtil.createBuildingPropertyDifference( IdSet );
        }
    }
    
    // @description 一括確認処理
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/1/30
    // @return void
    public void temporaryCheckedProperty() {
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        
        try{
            hasErrorMessage = false;

            //一括確認対象物件リスト取得
            String sql = '';
            sql += 'SELECT Id ';
            sql += '      ,IsBulkConfirmation__c ';      //一括確認チェック 
            sql += '      ,OwnCompanyManageModDate__c';  //自社管理修正日
            sql += '		FROM Property__c ';
            sql += '		WHERE WebPublishing__c = \'' + CommonConst.PROPERTY_WEBPUBLISHING_EXISTS + '\'';
            sql += '   		AND 	(   IsPostingEndDayBefore__c = true ';
            sql += '   		         OR IsPostingEndRecent__c    = true ';
            sql += '      	         )';
            sql += '   		AND 	Id IN (SELECT Property__c ';
            sql += '				FROM PortalSitePostingProperty__c ';
            sql += '				WHERE Shop__c = \''+ String.escapeSingleQuotes(this.targetShopsName) + '\'';
            sql += '      			)';
            sql += '       	LIMIT ' + (selectLimit + 1);
            List<Property__c> temporaryCheckedPropertyList = Database.query(sql); 

            //一括確認完了メッセージの設定
            if(temporaryCheckedPropertyList.size() <= selectLimit){
                MSG_COM_BULKREGISTRATION = CommonUtil.callMessageCreate(MSG_COM_I_SAVE);
            }else{
                MSG_COM_BULKREGISTRATION = CommonUtil.callMessageCreate(MSG_COM_I_BULKREGISTRATION, String.valueOf(selectLimit));
                temporaryCheckedPropertyList.remove(selectLimit); //最後の一つをついでに除去(removeの引数はindexなのでselectLimit+1番目が除去される)
            }
            
            
            //物件の更新
            List<Property__c> updateTemporaryCheckedPropertyList = new List<Property__c>();
            Set<Id> IdSet = new Set<Id>();
            
            for(Property__c p : temporaryCheckedPropertyList) {
                
                //建物物件差分作成 判定
                if (p.OwnCompanyManageModDate__c != null && p.OwnCompanyManageModDate__c.date() != systemToday) { //自社管理修正日が変更になるものが対象
                    IdSet.add(p.Id);
                }
                
                
                //一括確認対象の物件
                Property__c targetProperty = new Property__c();
                targetProperty.Id = p.Id;
                targetProperty.IsBulkConfirmation__c = true;              //一括確認チェック＝true
                targetProperty.OwnCompanyManageModDate__c = systemNow;    //自社管理修正日＝システム日付
                targetProperty.TemporarySaveDate__c = null;	              //一時保存日＝空白

                //一括確認日＝システム日付(一括確認チェックが false→ true に変更された場合のみ)
                if(p.IsBulkConfirmation__c == false) {
                    targetProperty.BulkConfirmationDate__c = p.OwnCompanyManageModDate__c;
                }

                updateTemporaryCheckedPropertyList.add(targetProperty);
            }
            
            
            //更新実行
            if (!updateTemporaryCheckedPropertyList.isEmpty()) {
                SecureDML.secureUpdate(updateTemporaryCheckedPropertyList);
                
                //建物物件差分 作成
                BuildingPropertyUtil.createBuildingPropertyDifference( IdSet );
            }
            
            searchProperty();
            
            
        }catch(Exception e) {
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 表示ページ選択処理
    public void selectPage() {
        try {
            this.hasErrorMessage = false;

            // 選択ページのインデックス取得
            Integer selectIndex = Integer.valueOf(this.selectPageIndex);
            // 選択ページのデータ開始位置インデックス取得
            Integer startIndex = selectIndex * this.pageDisplayNumber;
            // 選択ページのIdを取得
            List<Id> searchIdList = new List<Id>();
            for(Integer i = 0; i < this.pageDisplayNumber; i++) {
                if (this.searchResultPropertyId.size() == startIndex + i) {
                    break;
                }
                searchIdList.add(this.searchResultPropertyId[startIndex + i]);
            }

            // 対象ページのIdから物件データ取得
            List<Property__c> propertyRecordList = [
                SELECT
                    Id                                      //物件ID
                    ,PropertyCode__c                        //物件コード
                    ,Building__r.Id                         //建物ID
                    ,Building__r.Name                       //建物名
                    ,Building__r.BuildName2__c              //建物名2
                    ,Building__r.BuildName3__c              //建物名3
                    ,Name                                   //物件名
                    ,Building__r.Address__c                 //住所
                    ,LiveStatus__c                          //現況
                    ,DeliveryDateView__c                    //引渡年月
                    ,PhotoCount__c                          //写真枚数
                    ,PhotoTagNonSettingCount__c             //写真タグ未設定数
                    ,PropertyPanoramaCount__c               //物件パノラマ写真
                    ,MaintenanceLastModifiedDate__c         //最終メンテナンス日付
                    ,OwnCompanyManageModDate__c             //自社管理修正日
                    ,Score__c                               //点数
                    ,SuumoPanoramaShop__c                   //SUUMOパノラマ掲載店舗
                    ,HomesPanoramaShop__c                   //HOME'Sパノラマ掲載店舗
                    ,AtHomePanoramaShop__c                  //at homeパノラマ掲載店舗
                    ,IsPostingEndDayBefore__c               //掲載終了前日
                    ,IsPostingEndRecent__c                  //掲載終了直近
                    ,IsBulkConfirmation__c                  //一括確認チェック
                    ,WebPublishing__c                       //web公開
                    ,SystemModstamp                         //SystemModstamp
                    ,(
                    SELECT Id, IsSuumo__c, IsHomes__c, IsAtHome__c, IsChintaiNet__c, IsPortal__c, IsChintaiPanoramaPosting__c, SystemModstamp, Shop__r.IsChintaiPanoramaContract__c // 2022.04.05 CHINTAI本対応 取得項目を追加
                    FROM PortalSitePostingPropertyProperty__r
                    WHERE Shop__c = :this.targetShopsName
                    LIMIT 1
                    )
                    ,FormerSupplier_at_home_press_ban__c    //元付業者at home掲載不可フラグ
                    ,FormerSupplier_HOME_S_press_ban__c     //元付業者HOME'S 掲載不可フラグ
                    ,FormerSupplier_SUUMO_press_ban__c      //元付業者SUUMO掲載不可フラグ
					,FormerSupplier_Chintai_press_ban__c    //元付業者CHINTAI掲載不可フラグ // 2022.03.30 CHINTAI本対応 項目を追加
                FROM Property__c
                WHERE
                    Id IN :searchIdList
                ORDER BY
                    MaintenanceLastModifiedDate__c DESC
            ];

            // 対象ページのデータで明細表示用の内部クラス更新
            this.propertyAndPortalRecordList = new List<screenProperty>();
            Integer i = 1;
            for(Property__c p : propertyRecordList) {
                this.propertyAndPortalRecordList.add(new screenProperty(p, this.targetShopsName, i));
                i++;
            }

            // 背景色設定
            this.searchedPropertyColor(this.propertyAndPortalRecordList);

            // 現在表示ページの更新
            this.currentPageIndex = selectIndex;

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
            throw e;
        }
    }
    
    //--------------------------------------------------------------以下privateメソッド-----------------------------------------------------------------

    // @description 初期化メソッド
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/1/24
    // @return void
    private void init(){
        try {
            //初期化
            isOpenError = FALSE;
            hasErrorMessage = FALSE;
            
            //店舗の選択肢を作成・セット
            selectShopList = new List<SelectOption>();
            
            selectShopList = CommonUtil.getShopSelectedOptionFromStaffId(null, false, true, false); //IS不要
            
            //システム設定
            searchLimit = Integer.valueOf(SystemConfig__c.getInstance().PotalSearchMaxCount__c);
            selectLimit = Integer.valueOf(SystemConfig__c.getInstance().PortalProcessNumForVerification__c);
            systemToday = CommonUtil.getToday();
            systemNow   = CommonUtil.getNow();
            
            //必須のラジオボタン
            propertyType = 'ポータル連携物件';
            
            //ポータルサイトの選択肢を作成・セット
            selectPortalSiteList = new List<SelectOption>();
            
            selectPortalSiteList.add(new SelectOption('SUUMO_STRING', 'SUUMO'));
            selectPortalSiteList.add(new SelectOption('HOMES_STRING', 'HOMES'));
            selectPortalSiteList.add(new SelectOption('ATHOME_STRING', 'at home'));
			selectPortalSiteList.add(new SelectOption( CHINTAI_STRING, 'CHINTAI')); // ▲ 2022.03.22 CHINTAI本対応 項目追加
            
            //地区の選択肢を作成・セット
            selectPropertyDistrictList = new List<SelectOption>();
            selectPropertyDistrictList = CommonUtil.getSelectOptionFromObject('Building__c', 'District__c');
            
            propertyId = '';        //物件ID
            propertyDistrict = ''; //地区
            amountLowerLimit = null;        //金額下限
            amountUpperLimit = null;        //金額上限
            propertyName = '';      //物件名
            propertyAddress = '';   //住所(丁目まで)
            formerSupplier = '';    //元付業者名
            propertyScore = '全て';   //点数(ラジオボタン)
            panoramaPostingProperty = false;        //パノラマ掲載物件
            
            //検索結果の総件数
            allPropertyCount = null;
            allSuumoPropertyCount = null;
            allHomesPropertyCount = null;
            allAtHomePropertyCount = null;
			allChintaiPropertyCount = null; // 2022.03.22 CHINTAI本対応 項目追加
            
            //検索結果のパノラマ登録件数 // 2022.03.22 CHINTAI本対応 名称変更
            allPropertyPanoramaCount = null;
            allSuumoPropertyPanoramaCount = null;
            allHomesPropertyPanoramaCount = null;
            allAtHomePropertyPanoramaCount = null;
			allChintaiPropertyPanoramaCount = null; // 2022.03.22 CHINTAI本対応 項目追加
            
            //検索結果のパノラマ掲載件数 // 2022.03.22 CHINTAI本対応 名称変更
            propertyPanoramaCount = null;
            suumoPropertyPanoramaCount = null;
            homesPropertyPanoramaCount = null;
            atHomePropertyPanoramaCount = null;
			chintaiPropertyPanoramaCount = null; // 2022.03.22 CHINTAI本対応 項目追加
            
            //検索件数
            searchedPropertyCount = null;
            searchedSuumoPropertyCount = null;
            searchedHomesPropertyCount = null;
            searchedAtHomePropertyCount = null;
			searchedChintaiPropertyCount = null; // 2022.03.22 CHINTAI本対応 項目追加
            
            //濃いグレーの物件はあと1日で掲載が落ちます。
            lastPropertyCount = null;
            
            //グレーの物件はあと2、3日で掲載が落ちます。
            latestPropertyCount = null;
            
            //内部クラスのリストを作成
            this.propertyAndPortalRecordList = new List<screenProperty>();
            this.propertyAndPortalRecordListCount = 0;
            
            //店舗選択肢の初期値セット
            shopsName = CommonUtil.getStaffCurrentShop().Id;
            
            //ページング関連初期化
            this.pageingList = new List<SelectOption>();
            this.selectPageIndex = '0';
            this.currentPageIndex = 0;
            this.pageCount = 0;
            this.pageDisplayNumber = Integer.valueOf(SystemConfig__c.getInstance().PotalDisplayMaxCount__c);
            this.searchResultPropertyId = new List<Id>();
            
        } catch(Exception e) {
            isOpenError = true;//エラーを設定
            throw e;
        }
    }
    

    // @description 検索処理
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/1/24
    // @return void
    private void searchProperty() {
        try{
            hasErrorMessage = false;
            
            //検索結果の総件数
            allPropertyCount = 0;
            allSuumoPropertyCount = 0;
            allHomesPropertyCount = 0;
            allAtHomePropertyCount = 0;
			allChintaiPropertyCount = 0; // 2022.03.22 CHINTAI本対応 項目を追加
            
            //検索結果のパノラマ登録件数 // 2022.03.22 CHINTAI本対応 名称変更
            allPropertyPanoramaCount = 0;
            allSuumoPropertyPanoramaCount = 0;
            allHomesPropertyPanoramaCount = 0;
            allAtHomePropertyPanoramaCount = 0;
			allChintaiPropertyPanoramaCount = 0; // 2022.03.22 CHINTAI本対応 項目を追加
            
            //検索結果のパノラマ掲載件数 // 2022.03.22 CHINTAI本対応 名称変更
            propertyPanoramaCount = 0;
            suumoPropertyPanoramaCount = 0;
            homesPropertyPanoramaCount = 0;
            atHomePropertyPanoramaCount = 0;
			chintaiPropertyPanoramaCount = 0; // 2022.03.22 CHINTAI本対応 項目を追加
            
            //濃いグレーの物件はあと1日で掲載が落ちます。
            lastPropertyCount = 0;
            
            //グレーの物件はあと2、3日で掲載が落ちます。
            latestPropertyCount = 0;
            
            //検索時の店舗(パラメータ)を保存
            targetShopsName = shopsName;
            
            system.debug('検索時の店舗；' + targetShopsName);

            //店舗の未掲載サイトメッセージ変更
            changeUnlistedSiteMsgOfShop(targetShopsName);
            
            
            /** 総件数取得 */
            //物件数
            allPropertyCount = [SELECT COUNT()
                                FROM PortalSitePostingProperty__c
                                WHERE Shop__r.Id= :targetShopsName
                                AND Property__r.WebPublishing__c= :CommonConst.PROPERTY_WEBPUBLISHING_EXISTS];
            
            System.debug('店舗;' + targetShopsName);
            
            //SUUMO
            allSuumoPropertyCount = [SELECT COUNT()
                                     FROM PortalSitePostingProperty__c
                                     WHERE Shop__r.Id= :targetShopsName
                                     AND IsSuumo__c= true
                                     AND Property__r.WebPublishing__c= :CommonConst.PROPERTY_WEBPUBLISHING_EXISTS];
            //HOME’S
            allHomesPropertyCount = [SELECT COUNT()
                                     FROM PortalSitePostingProperty__c
                                     WHERE Shop__r.Id= :targetShopsName
                                     AND IsHomes__c= true
                                     AND Property__r.WebPublishing__c= :CommonConst.PROPERTY_WEBPUBLISHING_EXISTS];
            //at home
            allAtHomePropertyCount = [SELECT COUNT()
                                      FROM PortalSitePostingProperty__c
                                      WHERE Shop__r.Id= :targetShopsName
                                      AND IsAtHome__c= true
                                      AND Property__r.WebPublishing__c= :CommonConst.PROPERTY_WEBPUBLISHING_EXISTS];

			// ▼ 2022.03.22 CHINTAI本対応 総件数取得処理にCHINTAIを追加
			//CHINTAI
			allChintaiPropertyCount = [SELECT COUNT()
									  FROM PortalSitePostingProperty__c
									  WHERE Shop__r.Id= :targetShopsName
									  AND IsChintaiNet__c= true
									  AND Property__r.WebPublishing__c= :CommonConst.PROPERTY_WEBPUBLISHING_EXISTS];
			// ▲ 2022.03.22 CHINTAI本対応 
            
            /** パノラマ登録件数 */ // 2022.03.22 CHINTAI本対応 名称変更
            
            //物件数
            List<PortalSitePostingProperty__c> portalList = [SELECT Id, IsSuumo__c, IsHomes__c, IsAtHome__c, IsChintaiNet__c // 2022.03.22 CHINTAI本対応 項目を追加
                                                             FROM PortalSitePostingProperty__c
                                                             WHERE Shop__r.Id= :targetShopsName
                                                             AND   Property__r.PropertyPanoramaCount__c> 0
                                                             AND Property__r.WebPublishing__c= :CommonConst.PROPERTY_WEBPUBLISHING_EXISTS
                                                             AND (IsSuumo__c= true
                                                                  OR  IsHomes__c= true
                                                                  OR  IsAtHome__c= true
																  OR  IsChintaiNet__c = true)]; // 2022.03.22 CHINTAI本対応 項目を追加
            
            allPropertyPanoramaCount = portalList.size();		
            
            System.debug('パノラマ総数の物件数;' + portalList.size());
            
            for(PortalSitePostingProperty__c p: portalList)	{ 
                if(p.IsSuumo__c == true){ //SUUMO
                    allSuumoPropertyPanoramaCount += 1;
                }
                if(p.IsHomes__c == true){ //HOME’S
                    allHomesPropertyPanoramaCount += 1;
                }
                if(p.IsAtHome__c == true){ //at home
                    allAtHomePropertyPanoramaCount += 1;
                }

				// ▼ 2022.03.22 CHINTAI本対応 パノラマ掲載数処理に追加
				if(p.IsChintaiNet__c == true){ //CHINTAI
					++allChintaiPropertyPanoramaCount;
				}
				// ▲ 2022.03.22 CHINTAI本対応 

            }  
            
            
            /** パノラマ掲載件数 */ // 2022.03.22 CHINTAI本対応 名称変更
            
			// ▼ 2022.04.05 CHINTAI本対応 物件数にCHINTAI処理を追加
			//物件数
            List<PortalSitePostingProperty__c> portalSitePostingPropertyList = [
				select Property__c 
				from PortalSitePostingProperty__c
                where IsChintaiPanoramaPosting__c = true 
                	AND Shop__r.IsChintaiPanoramaContract__c = true
                 	AND Shop__c = :targetShopsName
				];

			set<Id> portalSitePostingPropertySet = new set<Id>();
			for(PortalSitePostingProperty__c p : portalSitePostingPropertyList){
				portalSitePostingPropertySet.add(p.Property__c);
			}

			List<Property__c> propertyList =[
				SELECT	Id
						, SuumoPanoramaShop__c
						, HomesPanoramaShop__c
						, AtHomePanoramaShop__c
						, ( select	  IsChintaiPanoramaPosting__c
									, Shop__r.IsChintaiPanoramaContract__c 
							from PortalSitePostingPropertyProperty__r
							where IsChintaiPanoramaPosting__c = true 
								AND Shop__r.IsChintaiPanoramaContract__c = true
                                AND Shop__c = :targetShopsName
						  ) 
				FROM Property__c
				WHERE PropertyPanoramaCount__c> 0
					AND WebPublishing__c= :CommonConst.PROPERTY_WEBPUBLISHING_EXISTS
					AND (SuumoPanoramaShop__c= :targetShopsName
						OR  HomesPanoramaShop__c= :targetShopsName
						OR  AtHomePanoramaShop__c= :targetShopsName
                        OR  Id in :portalSitePostingPropertySet)
			];
			// ▲ 2022.04.05 CHINTAI本対応 

            
            propertyPanoramaCount = propertyList.size();
            
            for(Property__c p : propertyList){
                if(p.SuumoPanoramaShop__c == targetShopsName){
                    suumoPropertyPanoramaCount += 1;
                }
                if(p.HomesPanoramaShop__c == targetShopsName){
                    homesPropertyPanoramaCount += 1;
                }
                if(p.AtHomePanoramaShop__c == targetShopsName){
                    atHomePropertyPanoramaCount += 1;
                }

				// ▼ 2022.04.01 CHINTAI本対応 更新処理を追加
				for(PortalSitePostingProperty__c portalSitePostingProperty : p.PortalSitePostingPropertyProperty__r){
					++this.chintaiPropertyPanoramaCount;
				}
				// ▲ 2022.04.01 CHINTAI本対応 

            }
            
            
            /** 濃いグレーの物件はあと1日で掲載が落ちます。 */
            //物件数
            lastPropertyCount = [SELECT COUNT()
                                 FROM PortalSitePostingProperty__c
                                 WHERE Shop__r.Id= :targetShopsName
                                 AND Property__r.WebPublishing__c = :CommonConst.PROPERTY_WEBPUBLISHING_EXISTS
                                 AND Property__r.IsPostingEndDayBefore__c= true];
            
            /** グレーの物件はあと2、3日で掲載が落ちます。 */
            //物件数
            latestPropertyCount = [SELECT COUNT()
                                   FROM PortalSitePostingProperty__c
                                   WHERE Shop__r.Id= :targetShopsName
                                   AND Property__r.WebPublishing__c = :CommonConst.PROPERTY_WEBPUBLISHING_EXISTS
                                   AND Property__r.IsPostingEndRecent__c= true];
            
            // 検索SQL作成
            String sql = '';
            sql += 'SELECT Id';                                     //物件ID
            sql += '      ,PropertyCode__c';                        //物件コード
            sql += '      ,Building__r.Id';                         //建物ID
            sql += '      ,Building__r.Name';                       //建物名
            sql += '      ,Building__r.BuildName2__c';              //建物名2
            sql += '      ,Building__r.BuildName3__c';              //建物名3
            sql += '      ,Name';                                   //物件名
            sql += '      ,Building__r.Address__c';                 //住所
            sql += '      ,LiveStatus__c';                          //現況
            sql += '      ,DeliveryDateView__c';                    //引渡年月
            sql += '      ,PhotoCount__c';                          //写真枚数
            sql += '      ,PhotoTagNonSettingCount__c';             //写真タグ未設定数
            sql += '      ,PropertyPanoramaCount__c';               //物件パノラマ写真
            sql += '      ,MaintenanceLastModifiedDate__c';         //最終メンテナンス日付
            sql += '      ,OwnCompanyManageModDate__c';             //自社管理修正日
            sql += '      ,Score__c';                               //点数
            sql += '      ,SuumoPanoramaShop__c';                   //SUUMOパノラマ掲載店舗
            sql += '      ,HomesPanoramaShop__c';                   //HOME'Sパノラマ掲載店舗
            sql += '      ,AtHomePanoramaShop__c';                  //at homeパノラマ掲載店舗
            sql += '      ,IsPostingEndDayBefore__c';               //掲載終了前日
            sql += '      ,IsPostingEndRecent__c';                  //掲載終了直近
            sql += '      ,IsBulkConfirmation__c';                  //一括確認チェック
            sql += '      ,WebPublishing__c';                       //web公開
            sql += '      ,SystemModstamp';                         //SystemModstamp
            sql += '      ,(';
            sql += '      SELECT Id, IsSuumo__c, IsHomes__c, IsAtHome__c, IsChintaiNet__c, IsPortal__c, IsChintaiPanoramaPosting__c, SystemModstamp, Shop__r.IsChintaiPanoramaContract__c '; // 2022.04.05 CHINTAI本対応 検索SQL作成にCHINTAIを追加
            sql += '        FROM PortalSitePostingPropertyProperty__r';
            sql += '         WHERE Shop__c = \'' + String.escapeSingleQuotes(this.targetShopsName) + '\'';
            sql += '       LIMIT 1';
            sql += '      	)';
            sql += '      ,FormerSupplier_at_home_press_ban__c';    //元付業者at home掲載不可フラグ
            sql += '      ,FormerSupplier_HOME_S_press_ban__c';     //元付業者HOME'S 掲載不可フラグ
            sql += '      ,FormerSupplier_SUUMO_press_ban__c';      //元付業者SUUMO掲載不可フラグ
			sql += '      ,FormerSupplier_Chintai_press_ban__c';    //元付業者CHINTAI掲載不可フラグ // 2022.03.22 CHINTAI本対応 検索SQL作成にCHINTAIを追加
            sql += '  FROM Property__c';
            
            system.debug('ポータル連携物件2;' + this.targetShopsName);
            
            //取得条件
            sql +=    maintenanceSearch();
            
            System.Debug(maintenanceSearch());

            //並びかえ
            sql += '  ORDER BY';
            sql += '        MaintenanceLastModifiedDate__c DESC';
            sql += ' LIMIT ' + this.searchLimit + ' ';
            
            System.debug(sql);
            
            // 検索実行＆結果返却
            List<Property__c> propertyRecordList = Database.query(sql);
            
            System.debug('エラー4;' + hasErrorMessage);
            
            //内部クラスのリストを作成
            this.propertyAndPortalRecordList = new List<screenProperty>();
            this.propertyAndPortalRecordListCount = propertyRecordList.size();
            
            //検索結果からIdのリストと明細表示用の内部クラス（1ページ分）を作成する
            this.propertyAndPortalRecordList = new List<screenProperty>();
            this.searchResultPropertyId = new List<Id>();
            Integer i = 1;
            for(Property__c p : propertyRecordList) {
                if (i <= this.pageDisplayNumber) {      // 1ページ上限まで内部クラス作成
                    this.propertyAndPortalRecordList.add(new screenProperty(p, this.targetShopsName, i));
                }
                this.searchResultPropertyId.add(p.Id);  // Id保存
                i++;
            }

			// ▼ 2022.04.05 CHINTAI本対応 パノラマ未掲載時、変更処理
			//パノラマ掲載契約=falseの店舗の場合、パノラマ掲載先を押下不可に変更
			if(shopMap.containsKey(targetShopsName) && shopMap.get(targetShopsName).IsChintaiPanoramaContract__c == false){
				for(screenProperty screenProperty : this.propertyAndPortalRecordList){
					screenProperty.IsDisableChintaiPanoramaPosting = true;
				}
			}
			// ▲ 2022.04.05 CHINTAI本対応 
            
            //検索件数計算と色設定
            searchedPropertyCount(propertyRecordList);
            searchedPropertyColor(this.propertyAndPortalRecordList);

            // ページ数設定
            this.pageCount = 0;
            if (this.pageDisplayNumber > 0) {
                this.pageCount = Integer.valueOf(Math.ceil(Double.valueOf(this.propertyAndPortalRecordListCount) / Double.valueOf(this.pageDisplayNumber)));
            }

            // ページ選択用のリストを作成
            this.pageingList = new List<SelectOption>();
            for (i = 0; i < this.pageCount; i++) {
                String label = '';
                label += (i * this.pageDisplayNumber + 1) + '～';
                label += this.propertyAndPortalRecordListCount < (i + 1) * this.pageDisplayNumber
                       ? this.propertyAndPortalRecordListCount : (i + 1) * this.pageDisplayNumber;
                label += '件目';
                SelectOption item = new SelectOption(String.valueOf(i), label);
                this.pageingList.add(item);
            }
            // ページ選択初期化
            this.selectPageIndex = '0';
            // 現在ページ初期化
            this.currentPageIndex = 0;
            
        }catch(Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
            throw e;
        }
    }
    
    /**
     * 店舗の未掲載サイトメッセージ変更
     * @param  String shopId 店舗Id
     * @return なし
     */
    private void changeUnlistedSiteMsgOfShop(String shopId){
        //選択されている店舗のFTPサーバアドレス(SUUMO,at home,HOME's,CHINTAI)取得 // 2022.03.22 CHINTAI本対応 項目追加
        List<Shop__c> ftpServerAdressRecord = [SELECT Id
                                                     ,SuumoFtpServerAdress__c
                                                     ,HomesFtpServerAdress__c
                                                     ,AtHomeFtpServerAdress__c
													 ,ChintaiWebApiAdress__c // 2022.03.22 CHINTAI本対応 項目追加
                                               FROM   Shop__c
                                               WHERE  Id = :shopId
                                              ];                 

        //店舗の未掲載サイトメッセージ
        unlistedSiteMsgOfShop = '';  
        
        String msg = '';       
        //FTPサーバアドレス(SUUMO,at home,HOME's)がNULLまたは半角全角スペースの場合メッセージを表示
        if(ftpServerAdressRecord.size() > 0){

            if(String.isBlank(ftpServerAdressRecord[0].SuumoFtpServerAdress__c)){
                msg = 'SUUMO';
            }
            if(String.isBlank(ftpServerAdressRecord[0].HomesFtpServerAdress__c)){
                if(String.isNotBlank(msg)){
                    msg += '・';
                }
                msg += 'HOME\'S ';
            }
            if(String.isBlank(ftpServerAdressRecord[0].AtHomeFtpServerAdress__c)){
                if(String.isNotBlank(msg)){
                    msg += '・';
                }
                msg += 'at home';
            }
			
			// ▼ 2022.03.22 CHINTAI本対応 店舗の未掲載サイトメッセージ処理を追加
			if(String.isBlank(ftpServerAdressRecord[0].ChintaiWebApiAdress__c)){
				if(String.isNotBlank(msg)){
					msg += '・';
				}
				msg += 'CHINTAI';
			}
			// ▲ 2022.03.22 CHINTAI本対応

            if(String.isNotBlank(msg)){
                unlistedSiteMsgOfShop = CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_UNLISTED_SITE_MSG_OF_SHOP, msg);
            }
        }
    }

    // @description 検索件数計算
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/1/29
    // @return void
    private void searchedPropertyCount(List<Property__c> screenPropList) {
        try{
            hasErrorMessage = false;
            
            //検索件数
            searchedPropertyCount = screenPropList.size();
            searchedSuumoPropertyCount = 0;
            searchedHomesPropertyCount = 0;
            searchedAtHomePropertyCount = 0;
			searchedChintaiPropertyCount = 0; // 2022.03.22 CHINTAI本対応 検索件数にCHINTAIを追加
            
            /** 検索件数取得 */
            for(Property__c s : screenPropList) {
                PortalSitePostingProperty__c portalPropertyRecord = new PortalSitePostingProperty__c();
                if (s.PortalSitePostingPropertyProperty__r.size() > 0) {
                    portalPropertyRecord = s.PortalSitePostingPropertyProperty__r[0];
                }
                if(portalPropertyRecord.IsSuumo__c == true) { //SUUMO
                    searchedSuumoPropertyCount += 1;
                }
                if(portalPropertyRecord.IsHomes__c == true) { //HOME'S
                    searchedHomesPropertyCount += 1;
                }
                if(portalPropertyRecord.IsAtHome__c == true) { //At home
                    searchedAtHomePropertyCount += 1;
                }
				// ▼ 2022.03.22 CHINTAI本対応 検索件数取得処理にCHINTAIを追加  
				if(portalPropertyRecord.IsChintaiNet__c == true) { //CHINTAI
					searchedChintaiPropertyCount += 1;
				}
				// ▲ 2022.03.22 CHINTAI本対応 

            }
            
            system.debug('検索件数1；'+ searchedSuumoPropertyCount);
            system.debug('検索件数2；'+ searchedHomesPropertyCount);
            system.debug('検索件数3；'+ searchedAtHomePropertyCount);
			system.debug('検索件数4；'+ searchedChintaiPropertyCount); // 2022.03.22 CHINTAI本対応 CHINTAIを追加
            
        }catch(Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
            throw e;
        }
    }

    // @description 色設定
    // @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/1/29
    // @return void
    private void searchedPropertyColor(List<screenProperty> screenPropList) {
        try{
            hasErrorMessage = false;
            
            for (screenProperty s : screenPropList) {
                System.debug(s.propertyRecord.IsPostingEndDayBefore__c);
                System.debug(s.propertyRecord.IsPostingEndRecent__c);
                System.debug(s.propertyRecord.WebPublishing__c);
                /** 濃いグレーの物件はあと1日で掲載が落ちます。物件数取得 + 色設定*/
                if (s.propertyRecord.IsPostingEndDayBefore__c == true
                    && s.propertyRecord.WebPublishing__c == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS
                    ) {
                    s.bkColor = COLOR_DG;
                    
                /** グレーの物件はあと2、3日で掲載が落ちます。物件数取得 + 色設定 */
                }else if(s.propertyRecord.IsPostingEndRecent__c == true
                    && s.propertyRecord.WebPublishing__c == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS
                    ) {
                    s.bkColor = COLOR_G;
                }
            }
            
        }catch(Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
            throw e;
        }
    }
    
    //↓↓↓↓↓以下内部クラス↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    
    //物件+ポータルサイト掲載物件用内部クラス
    public class screenProperty {
        
        //明細の背景色(変数)
        public String bkColor { get; set; }
        //明細の物件
        public Property__c propertyRecord { get; set; }
        //明細のポータルサイト掲載物件
        public PortalSitePostingProperty__c portalPropertyRecord { get; set; }
        //SUUMOパノラマ掲載店舗
        public Boolean isSuumoPanoramaPropertyCheck { get; set; }
        //HOME'Sパノラマ掲載店舗
        public Boolean isHomesPanoramaPropertyCheck { get; set; }
        //at homeパノラマ掲載店舗
        public Boolean isAtHomePanoramaPropertyCheck { get; set; }

		// ▼ 2022.03.24 CHINTAI本対応 項目を追加
		//CHINTAIパノラマ掲載店舗
		public Boolean isChintaiPanoramaPropertyCheck { get; set; }
		// ▲ 2022.03.24 CHINTAI本対応 

        //SUUMO非活性フラグ
        public Boolean IsDisableSuumo { get; set; }
        //HOME'S非活性フラグ
        public Boolean IsDisableHomes { get; set; }
        //at home非活性フラグ
        public Boolean IsDisableAtHome { get; set; }

		// ▼ 2022.03.22 CHINTAI本対応 項目を追加
		//CHINTAI非活性フラグ
		public Boolean IsDisableChintai { get; set; }

		//CHINTAIパノラマ掲載先非活性フラグ
		public Boolean IsDisableChintaiPanoramaPosting { get; set; }
		// ▲ 2022.03.22 CHINTAI本対応
        
        //表示行
        public Integer showIndex { get; set; }
        
        //コンストラクタ（引数：物件, 店舗）
        public screenProperty(Property__c targetPropertyRecord, Id shopId, Integer index){
            
            //明細の背景色を白に設定
            bkColor = COLOR_W;
            
            //表示行の初期化
            this.showIndex = index;
            
            //パノラマ掲載店舗のチェックボックスを初期化
            isSuumoPanoramaPropertyCheck = false;
            isHomesPanoramaPropertyCheck = false;
            isAtHomePanoramaPropertyCheck = false;
			isChintaiPanoramaPropertyCheck = false; // 2022.03.22 CHINTAI本対応 チェックボックス初期化処理にCHINTAIを追加

			// ▼ 2022.03.22 CHINTAI本対応 CHINTAIパノラマ掲載先非活性フラグの初期化処理
			//CHINTAIパノラマ掲載先非活性フラグを初期化
			IsDisableChintaiPanoramaPosting = false;
			// ▲ 2022.03.22 CHINTAI本対応 
            
            //変数の物件に、引数の物件を設定
            propertyRecord = targetPropertyRecord;
            
            //変数のポータルサイト掲載物件に、引数のポータルサイト掲載物件を設定
            if(targetPropertyRecord.PortalSitePostingPropertyProperty__r.size()>0) {   
                //ポータル有
                portalPropertyRecord = targetPropertyRecord.PortalSitePostingPropertyProperty__r[0].clone(true, true);
            } else {
                //ポータル無
                portalPropertyRecord = new PortalSitePostingProperty__c();
                portalPropertyRecord.Shop__c = shopId;
                portalPropertyRecord.Property__c = targetPropertyRecord.Id;
            }
            
            //パノラマ掲載店舗のチェックボックス化
            if(propertyRecord.SuumoPanoramaShop__c == shopId) {
                isSuumoPanoramaPropertyCheck = true;
            }
            else{
                isSuumoPanoramaPropertyCheck = false;
            }
            
            if(propertyRecord.HomesPanoramaShop__c == shopId) {
                isHomesPanoramaPropertyCheck = true;
            }
            else{
                isHomesPanoramaPropertyCheck = false;
            }
            
			system.debug('確認2'+isAtHomePanoramaPropertyCheck);

            if(propertyRecord.AtHomePanoramaShop__c == shopId) {
                isAtHomePanoramaPropertyCheck = true;
            }
            else{
                isAtHomePanoramaPropertyCheck= false;
            }

			// ▼ 2022.03.22 CHINTAI本対応 チェックボックス化処理にCHINTAIを追加  
			if(portalPropertyRecord.IsChintaiPanoramaPosting__c == true && portalPropertyRecord.Shop__r.IsChintaiPanoramaContract__c == true) {
				isChintaiPanoramaPropertyCheck = true;
			}
			else{
				isChintaiPanoramaPropertyCheck= false;
			}
			// ▲ 2022.03.22 CHINTAI本対応 

            system.debug('確認' + targetPropertyRecord.FormerSupplier_at_home_press_ban__c);
            
            //掲載先の非表示情報を取得
            this.IsDisableSuumo = targetPropertyRecord.FormerSupplier_SUUMO_press_ban__c;     //SUUMO
            this.IsDisableAtHome = targetPropertyRecord.FormerSupplier_at_home_press_ban__c;  //at home
            this.IsDisableHomes = targetPropertyRecord.FormerSupplier_HOME_S_press_ban__c;    //HOME'S
			this.IsDisableChintai = targetPropertyRecord.FormerSupplier_Chintai_press_ban__c; //CHINTAI 2022.04.06 CHINTAI本対応 掲載先の非表示情報取得にCHINTAIを追加
        }
    }
}