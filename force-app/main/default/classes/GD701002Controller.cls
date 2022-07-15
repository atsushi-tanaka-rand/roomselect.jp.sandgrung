/* *
 * 元付物件詳細画面のコントローラ
 */
public inherited sharing class GD701002Controller {
    /** public変数 */
    public Account targetAccountRecord { get; set; }                       //対象取引先レコード
    public List<DisplayBuilding> targetDisplayBuildingList { get; set; }   //対象建物リスト
    public Integer buildingIndex { get; set; }                  //建物明細表示用インデックス
    public Map<String, String> itemLabelMap { get; set; }       //<項目のAPI名, ラベル> ←履歴オブジェクトからはapiしか取得できないため
    public List<ScreenPropertyList> displayPropertyList { get; set; }  //物件表示用リスト
    public List<displayHistory> targetDisplayHistoryList { get; set; }    //表示用取引先履歴クラスリスト
    public Shop__c userShop { get; set; }                       //ユーザー店舗 
    public Boolean isOpenError { get; set; }                    //エラーフラグ
    public Boolean isSelectedAll { get; set; }                  // 物件登録．全選択


    public Boolean hasErrorMessage { get; set; }
    public Id selectBuildingId { get; set; }                    //「表示」押下建物のId

    private List<String> vacancyLiveStatusList; //空室or退去予定が入るステータスList
    private static final String COLOR_PINK = '#f2dede'; //色設定_ピンク
    private static final String COLOR_GRAY = '#d8d8d8'; //色設定_灰

    /** private変数 */
    private String targetId;                                    //パラメータ(取引先ID)
    private String targetDistricts;                             //パラメータ(地区)
    private List<String> districtsList;                         //対象地区のリスト

    // ページング関連
    private Integer buildingSelectLimit = Integer.valueOf(SystemConfig__c.getInstance().SupplierPropertyBuildingSearchMaxCount__c);         // 建物の表示上限（全体）
    private Integer buildingPageDisplayNumber = Integer.valueOf(SystemConfig__c.getInstance().SupplierPropertyBuildingDisplayMaxCount__c);  // 建物の表示上限（１ページ）
    private List<Id> buildingIdList { get; set; }               // 建物に紐付く物件の全IdList
    public List<SelectOption> buildingPageingList { get; set; } // 建物のページ選択用リスト
    public Integer buildingPageCount { get; set; }              // 建物のページ数
    public String selectBuildingPageIndex { get; set; }         // 建物のリスト選択中ページ番号
    private Integer currentBuildingPageIndex { get; set; }      // 建物の表示中ページ番号
    private List<Id> targetBuildingIdList ;                     // 選択ページのIdリスト

    // 物件登録値
    private DateTime maintenanceStartDateTime = null;           // メンテナンス開始時刻

    // 画面メッセージ
    public String MSG_CONFIRM_SAVE_BULK_PROP     { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_UPDATE, CommonConst.SAVE_BULK_PROPERTY_UPDATE);} }
    public String MSG_CONFIRM_SAVE_BULK_RESIDENT { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_UPDATE, CommonConst.SAVE_BULK_RESIDENT_UPDATE);} }
    public String MSG_SAVE                       { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} }
    public String MSG_ERR_NO_SELECTED            { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTED, CommonConst.ITEM_PROPERTY);} }
    public String MSG_ERR_UPD_LIMIT_OVER         { get{return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_W_UPD_LIMIT_OVER);} }

    //コンストラクタ
    public GD701002Controller() {
        try{
            //初期化
            init();

            //パラメータ取得
            parameterGet();

            //元付業者情報取得
            this.targetAccountRecord = selectFormerSupplier();

            //建物情報取得
            setDisplayBuilding();

            //取引先履歴取得
            historySet();

        }catch(Exception e){

            //エラー設定
            this.isOpenError = true;
            //ビジネスロジックException発行
            CommonUtil.setErrorMessage(e);
        }
    }

    //（物件）表示ボタン押下処理
    public void displayProperty() {
        try {
            this.hasErrorMessage = false;
            this.isSelectedAll = false;

            // 物件情報取得
            List<Property__c> propertyList = selectProperty(this.selectBuildingId);

            // ポータルサイト掲載物件取得
            Map<Id, PortalSitePostingProperty__c> portalSitePostingPropMap;
            portalSitePostingPropMap = portalSitePostingPropertyMapSet(propertyList);

            // 物件一覧の明細を設定
            this.displayPropertyList = new List<ScreenPropertyList>();
            PortalSitePostingProperty__c portalSitePostingProp = new PortalSitePostingProperty__c();
            for (Property__c property : propertyList) {

                portalSitePostingProp = new PortalSitePostingProperty__c();
                if (portalSitePostingPropMap.containsKey(property.Id)) {
                    portalSitePostingProp = portalSitePostingPropMap.get(property.Id);
                }

                // 明細を追加
                this.displayPropertyList.add(new ScreenPropertyList(property, portalSitePostingProp));
            }

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
            throw e;
        }
    }

    // 表示ページ選択処理
    public void selectBuildingPage() {
        
        // 選択ページのインデックス取得
        Integer selectIndex = Integer.valueOf(this.selectBuildingPageIndex);
        
        // ページ更新
        setPageData(selectIndex);
    }

    // 色更新ボタンにて色を更新する。
    public void setColor(){
        
        //現在ページを更新
        setPageData(this.currentBuildingPageIndex);
    }

    /**
     * 一括で居住中に変更ボタン押下
     */
    public void clickBulkUpdateResident() {
        this.updProperty(false);
    }

    /**
     * 一括物件更新ボタン押下
     */
    public void clickBulkUpdateProperty() {
        this.updProperty(true);
    }
    
    //**************************************************************************privateメソッド****************************************************:

    //初期化メソッド
    private void init(){

        //パラメータを空白で初期化
        this.targetId = '';
        this.targetDistricts = '';

        //表示用取引先履歴クラスリスト
        this.targetDisplayHistoryList = new List<displayHistory>();

        //対象取引先レコード
        this.targetAccountRecord = new Account();

        //対象建物リスト
        this.targetDisplayBuildingList = new List<DisplayBuilding>();

        //色更新用IDリスト
        this.targetBuildingIdList = new List<Id>();

        //itemLabelMap設定のために、項目取得
        Schema.SObjectType sot1 = Schema.getGlobalDescribe().get('Account');  // SObjectType型でオブジェクトを取得
        Schema.DescribeSObjectResult dsr1 = sot1.getDescribe();  // DescribeSObjectResult型に変換
        Map<String, Schema.SObjectField> fsMap1 = dsr1.fields.getMap();  // Map型でオブジェクトの情報を取得する
        
        //itemLabelMap設定
        itemLabelMap = new Map<String, String>();
        for (Schema.SObjectField sof : fsMap1.values()) {
            itemLabelMap.put(sof.getDescribe().getName(), sof.getDescribe().getLabel());
        }
        itemLabelMap.put('created', '作成'); //新規作成時の表記を追加

        //ユーザー店舗取得
        this.userShop = CommonUtil.getStaffCurrentShop();

        //エラーフラグ
        this.isOpenError = false;

        //物件表示用リスト
        this.displayPropertyList = new List<ScreenPropertyList>();

        //ページング関連初期化
        this.buildingPageCount = 0;
        this.buildingPageingList = new List<SelectOption>();
        this.selectBuildingPageIndex = '0';
        this.currentBuildingPageIndex = 0;
        this.buildingPageCount = 0;
        this.buildingIdList = new List<Id>();
        this.isSelectedAll = false;

        //現況のリスト設定
        this.vacancyLiveStatusList = new List<String>();
        this.vacancyLiveStatusList.add(CommonConst.PROPERTY_LIVESTATUS_VACANCY);          //空室
        this.vacancyLiveStatusList.add(CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE); //退去予定

        // 物件の登録値を設定
        this.maintenanceStartDateTime = CommonUtil.getNow(); // メンテナンス開始時刻
    }

    //パラメータ取得
    private void parameterGet(){

        //取引先ID
        this.targetId = ApexPages.currentPage().getParameters().get('Id');

        //ID取得できなければ空白を入れる
        if(String.isEmpty(this.targetId)){
            this.targetId = '';
        }

        //地区
        this.targetDistricts = ApexPages.currentPage().getParameters().get('Districts');
        this.districtsList = new List<String>();
        //地区が取得できない場合全ての地区を格納
        if(String.isEmpty(this.targetDistricts)){
            List<SelectOption> so = CommonUtil.getSelectOptionFromObject('Building__c', 'District__c', false);
            for(SelectOption item : so){
                this.districtsList.add(item.getValue());
            }
            this.targetDistricts = String.join(districtsList,'_');
        } else {
            this.districtsList = this.targetDistricts.split('_');
        }
    }
    
    
    // ページ情報更新
    private void setPageData(Integer selectIndex) {
        try {
            this.hasErrorMessage = false;
            
            // 選択ページのデータ開始位置インデックス取得
            Integer startIndex = selectIndex * this.buildingPageDisplayNumber;
            // 選択ページのIdを取得
            this.targetBuildingIdList = new List<Id>();
            for(Integer i = 0; i < this.buildingPageDisplayNumber; i++) {
                if (this.buildingIdList.size() == startIndex + i) {
                    break;
                }
                this.targetBuildingIdList.add(this.buildingIdList[startIndex + i]);
                
            }
            
            // 対象ページのIdから建物データ取得
            
            // ピンクorグレー
            List<Building__c> targetBuildingList = selectBuilding(true, this.targetBuildingIdList,this.buildingPageDisplayNumber,true);   
            //内部クラスを作成
            this.targetDisplayBuildingList = new List<DisplayBuilding>();
            for (Building__c targetBuilding: targetBuildingList) {
                this.targetDisplayBuildingList.add(new DisplayBuilding(targetBuilding, true));
            }
            
            // 白
            integer othersSelectLimit = this.buildingPageDisplayNumber - targetBuildingList.size() ; //上限の計算
            targetBuildingList = selectBuilding(true, this.targetBuildingIdList,othersSelectLimit,false); //ピンク、グレーのあとに白が並ぶようにしている
            //内部クラスを作成
            for (Building__c targetBuilding: targetBuildingList) {
                this.targetDisplayBuildingList.add(new DisplayBuilding(targetBuilding, false));
            }
            
            // ページが変わる場合、物件一覧をクリア
            if (selectIndex != this.currentBuildingPageIndex) {
                this.displayPropertyList = new List<ScreenPropertyList>();
            }
            
            // 現在表示ページの更新
            this.currentBuildingPageIndex = selectIndex;

            // チェックボックスを初期化
            this.isSelectedAll = false;
            for (ScreenPropertyList detail : this.displayPropertyList) {
                detail.IsSelected = false;
            }
            
        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
            throw e;
        }
    }
    
    
    // 建物表示情報の設定
    private void setDisplayBuilding() {
        // 建物情報取得
        List<Building__c> buildingList = selectBuilding(false, null,this.buildingSelectLimit,true); //ピンクorグレー
        Integer pinkGrayListSize = buildingList.size();                      //ピンクorグレーのsize
        Integer othersSelectLimit = buildingSelectLimit - pinkGrayListSize;  //白のsize
        buildingList.addall(selectBuilding(false, null,othersSelectLimit,false));  //白


        
        //内部クラス作成
        this.targetDisplayBuildingList = new List<DisplayBuilding>();
        Integer i = 0;
        for (Building__c build : buildingList) {
            buildingIdList.add(build.Id);
            
            //１ページ以内か
            if (i < buildingPageDisplayNumber) {
                
                //背景色をつけるか否か
                if (i < pinkGrayListSize) {
                    targetDisplayBuildingList.add(new DisplayBuilding(build, true));
                } else {
                    targetDisplayBuildingList.add(new DisplayBuilding(build, false));
                }
            }
            i++;
        }
        
        
        // ページ数設定
        this.buildingPageCount = 0;
        if (this.buildingPageDisplayNumber > 0) {
            this.buildingPageCount = Integer.valueOf(Math.ceil(Double.valueOf(this.buildingIdList.size()) / Double.valueOf(this.buildingPageDisplayNumber)));
        }
        
        // ページ選択用のリストを作成
        this.buildingPageingList = new List<SelectOption>();
        for (i = 0; i < this.buildingPageCount; i++) {
            String label = '';
            label += (i * this.buildingPageDisplayNumber + 1) + '～';
            label += this.buildingIdList.size() < (i + 1) * this.buildingPageDisplayNumber
                   ? this.buildingIdList.size() : (i + 1) * this.buildingPageDisplayNumber;
            label += '件目';
            SelectOption item = new SelectOption(String.valueOf(i), label);
            this.buildingPageingList.add(item);
        }
        
        // ページ選択初期化
        this.selectBuildingPageIndex = '0';
        // 現在ページ初期化
        this.currentBuildingPageIndex = 0;
    }



    //ポータルサイト掲載物件Map設定
    private Map<Id, PortalSitePostingProperty__c> portalSitePostingPropertyMapSet(List<Property__c> propertyList){
        //変数宣言、初期化
        Map<Id, PortalSitePostingProperty__c> result = new Map<Id, PortalSitePostingProperty__c>();
        Set<Id> propertyIdSet = new Set<Id>();    //SELECT用

        //Map初期化
        for (Property__c property : propertyList) {
            propertyIdSet.add(property.Id);
        }
        
        //ポータル掲載物件取得
        List<PortalSitePostingProperty__c> portalSitePostingProperty = [ SELECT Property__c
                                                                              , IsAtHome__c
                                                                              , IsHomes__c
                                                                              , IsSuumo__c
                                                                           FROM PortalSitePostingProperty__c
                                                                          WHERE Shop__c = :this.userShop.Id
                                                                            AND Property__c = :propertyIdSet ];
        
        //Mapの完成
        for( PortalSitePostingProperty__c portal : portalSitePostingProperty){
            result.put(portal.Property__c, portal);
        }

        return result;
    }
    
    //元付業者情報取得
    private Account selectFormerSupplier(){
        List<Account> accountList = [ SELECT  Id
                                            , FixedTermSend__c		    //定期送信	
                                            , Email__c				    //メール
                                            , Name					    //取引先名
                                            , Phone                     //電話番号
                                            , Fax					    //取引先FAX
                                            , RepresentativePhone__c    //取引先担当者電話番号
                                            , IppamGyobutsu__c		    //一般／業物
                                            , Representative__c		    //取引先担当者
                                            , DembutsuDate__c		    //電物日
                                        FROM Account
                                       WHERE Id = :targetId ];

        if(accountList.size() == 0){

            //ビジネスロジックException発行
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_INPUT_ACCOUNT_NOTHING, targetId));
            throw ex;

        }

        return accountList[0];

    }

    //建物情報取得（空室のみ、本日手動更新された物件）
    // byIdListFlg：ページングか初期出力の判定
    // buildingIdList：ページングの対象物件IDリスト
    // 
    // othersSelectLimit：出力上限件数
    private List<Building__c> selectBuilding(Boolean byIdListFlg, List<Id> buildingIdList,Integer othersSelectLimit,Boolean emptyRoomTodayManualMaintenanceFlg) {
        // 色判定対象を取得
        String sql = '';
        sql += ' SELECT ';
        sql += '     Id ';
        sql += '     ,Name ';                   //建物名
        sql += '     ,BuildingYMFormat__c ';    //築年数
        sql += '     ,Address__c ';             //住所
        sql += '     ,District__c ';            //地区
        
        if(emptyRoomTodayManualMaintenanceFlg){
            // ピンクorグレーの場合のみ
            sql += '     ,(SELECT id FROM PropertyBuilding__r WHERE '; //ピンク対象の物件（色の判定に用いる）
            sql += '       FormerSupplier__c = :targetId AND LiveStatus__c IN :vacancyLiveStatusList AND ManualMaintenanceDate__c != TODAY LIMIT 1) ';
        }
                
        sql += ' FROM Building__c ';
        if (byIdListFlg) {
            sql += ' WHERE Id IN :buildingIdList ';
        } else {
            sql += ' WHERE District__c IN :districtsList '; //地区
        }

        if(emptyRoomTodayManualMaintenanceFlg){
            // ピンクorグレー
            sql += ' AND Id IN ( ';
            sql += '             SELECT Building__c  ';
            sql += '             FROM   Property__c ';
            sql += '             WHERE  FormerSupplier__c = :targetId ';           //業者
            sql += '             AND   (LiveStatus__c IN :vacancyLiveStatusList '; //空室or退去予定
            sql += '                    OR   (LiveStatus__c NOT IN :vacancyLiveStatusList ';  //空室or退去予定以外
            sql += '                          AND   ManualMaintenanceDate__c = TODAY ';       //手動最終メンテナンス日
            sql += '                         ) ';
            sql += '                   ) ';
            sql += '           ) ';

        }else{
            // 白
            sql += ' AND Id IN ( ';
            sql += '             SELECT Building__c  ';
            sql += '             FROM   Property__c ';
            sql += '             WHERE  FormerSupplier__c = :targetId '; //業者
            sql += '             ) '; 
            
            sql += ' AND Id NOT IN ( ';
            sql += '                 SELECT Building__c  ';
            sql += '                 FROM   Property__c ';
            sql += '                 WHERE  FormerSupplier__c = :targetId '; //業者
            sql += '                 AND   (LiveStatus__c IN :vacancyLiveStatusList '; //空室
            sql += '                 OR     ManualMaintenanceDate__c = TODAY ';        //手動最終メンテナンス日
            sql += '                       ) '; 
            sql += '               ) '; 
        }

        sql += ' ORDER BY Name ';
        sql += ' LIMIT :othersSelectLimit ';

        List<Building__c> buildingList = Database.query(sql);

        if (buildingList.size() == 0) {
            buildingList = new List<Building__c>();
        }

        return buildingList;
    }
    


    //物件情報取得
    private List<Property__c> selectProperty(Id buildingId) {

        List<Property__c> propertyList = [
            SELECT
                Id
                ,Name                       //部屋番号
                //,LastModifiedDate           //更新日 2022.4.18 No0760で不要になったため、削除
                ,LiveStatus__c              //現況
                ,DeliveryDateView__c        //引渡日(表示用)
                ,PropertyPhotoCount__c      //写真枚数
                ,Score__c                   //点数
                ,RoomCount__c               //部屋数
                ,RoomLayout__c              //間取り
                ,RentFee__c                 //賃料
                ,ManagementFeeTax__c        //管理費(税込)
                ,SecurityDepositYen__c      //敷金
                ,KeyMoneyYen__c             //礼金
                ,DepositYen__c              //保証料金
                //,ManualMaintenanceDate__c   //手動最終メンテナンス日 2022.4.18 No0760で不要になったため、削除
                ,WebPublishing__c           //web公開
                ,OwnCompanyManageModDate__c //自社管理修正日 2022.4.18 No0760 元付物件詳細画面に「自社管理修正日」を表示
            FROM Property__c
            WHERE
                Building__c = :buildingId
            AND FormerSupplier__c = :targetId
            ORDER BY Name
        ];

        if (propertyList.size() == 0) {
            propertyList = new List<Property__c>();
        }

        return propertyList;

    }

    //取引先履歴取得
    private void historySet() {
        
        //取引先履歴取得
        List<AccountHistory> histories = [SELECT
                                            CreatedDate
                                          , Field
                                          , CreatedBy.Name
                                          , OldValue
                                          , NewValue
                                          FROM AccountHistory
                                          WHERE Field IN ('DembutsuStatus__c','DembutsuStaff__c','DembutsuDate__c','DembutsuEventMemo__c')//電物に関する履歴のみ表示
                                          AND AccountId = :targetId
                                          ORDER BY CreatedDate DESC
                                          ];
        
        //表示用取引先内部クラスリストにレコードを詰める
        for(AccountHistory history : histories){
            this.targetDisplayHistoryList.add(new displayHistory(history));
        }
    }
    
    /**
     * 物件の更新
     * @param Boolean isBulkUpdateProperty true:一括物件更新、false:一括で居住中に変更
     */
    private void updProperty(Boolean isBulkUpdateProperty) {

        Savepoint sp = Database.setSavepoint();
        try{
            this.hasErrorMessage = false;

            // 更新対象のレコードを取得
            Set<Id> propIdSet = new Set<Id>();
            List<ScreenPropertyList> targetList = new List<ScreenPropertyList>();
            for (ScreenPropertyList targetRecord : this.displayPropertyList) {
                if (!targetRecord.IsSelected) {
                    continue;
                }
                propIdSet.add(targetRecord.Id);
                targetList.add(targetRecord);
            }

            DateTime sysDate = CommonUtil.getNow();

            // 更新値の取得
            List<Property__c> updPropList = new List<Property__c>();
            Set<Id> BuildingPropDiffIdSet = new Set<Id>();
            Property__c updProp = new Property__c();
            for (ScreenPropertyList target : targetList) {

                updProp = new Property__c();

                // 共通処理
                updProp.Id                          = target.Id;                             // ID
                updProp.MaintenanceType__c          = CommonConst.MAINTENANCETYPE_MANUALCHG; // メンテナンス区分
                updProp.MaintenanceStartDateTime__c = this.maintenanceStartDateTime;         // メンテナンス開始時刻
                updProp.MaintenanceEndDateTime__c   = sysDate;                               // メンテナンス終了時刻
                updProp.MaintenanceStaff__c         = UserInfo.getUserId();                  // メンテナンススタッフ（ログインユーザ）
                updProp.IsBulkConfirmation__c       = false;                                 // 一括確認チェック
                updProp.BulkConfirmationDate__c     = null;                                  // 一括確認日
                updProp.OwnCompanyManageModDate__c  = sysDate;                               // 自社管理修正日
                updProp.ManualMaintenanceDate__c    = sysDate;                               // 手動最終メンテナンス日
                updProp.TemporarySaveDate__c        = null;                                  // 一時保存日
                // メンテナンスコメント
                updProp.MaintenanceCommentArea__c   = CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_UPD, CommonConst.ITEM_PROPERTY);
                // メンテナンスアクション元画面（元付物件詳細）
                updProp.MaintenanceAction__c        = CommonConst.PROPERTY_MAINTENANCEACTION_ORIGINALPROPERTYDETAILS;

                // 一括で居住中に変更処理
                if (!isBulkUpdateProperty) {
                    updProp.WebPublishing__c = CommonConst.PROPERTY_WEBPUBLISHING_NO;    // web公開
                    updProp.LiveStatus__c    = CommonConst.PROPERTY_LIVESTATUS_RESIDENT; // 現況
                }

                // 一括物件更新処理
                if (isBulkUpdateProperty) {
                    // 建物物件差分用の物件IDを取得
                    if (target.WebPublishing == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS) {
                        BuildingPropDiffIdSet.add(updProp.Id);
                    }
                }

                updPropList.add(updProp);
            }

			 // ▼2022.01.18 No.0699 対応で変更：建物物件差分に一括で変更した内容が反映されないため、処理順を変更
			// 手動メンテ数の加算
			this.addManualMaintenanceCnt(propIdSet);    

			// 物件の更新
			SecureDML.secureUpdate(updPropList);

            // 建物物件差分を登録
            if (BuildingPropDiffIdSet.size() > 0) {
                BuildingPropertyUtil.createBuildingPropertyDifference(BuildingPropDiffIdSet);
            }

            // 明細を再取得
            this.displayProperty();

        } catch(Exception e) {
            this.hasErrorMessage = true;
            Database.rollback(sp);
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 手動メンテ数の加算
     * @param Set<Id>  propIdSet 物件．ID
     */
    private void addManualMaintenanceCnt(Set<Id> propIdSet) {

        // 日報の加算未処理チェック
        List<PropertyMaintenanceHistory__c> propMaintenanceHistList = this.getPropMaintenanceHistForDailyReport(propIdSet);
        if (propMaintenanceHistList.size() == 0) {
            DailyReportUtil.upsertDailyReportManualMaintenance(); 
        }
    }

    /**
     * 日報用の物件メンテナンス履歴を取得
     * @param  Set<Id> propIdSet                   物件．ID
     * @return List<PropertyMaintenanceHistory__c> 物件メンテナンス履歴
     */
    private List<PropertyMaintenanceHistory__c> getPropMaintenanceHistForDailyReport(Set<Id> propIdSet) {

        DateTime condDate = DateTime.newInstance(CommonUtil.getToday(), Time.newInstance(0, 0, 0, 0));

        List<PropertyMaintenanceHistory__c> result;
        result = [SELECT CreatedDate
                  FROM PropertyMaintenanceHistory__c
                  WHERE Property__c IN :propIdSet
                        AND MaintenanceAction__c = :CommonConst.PROPERTY_MAINTENANCEACTION_ORIGINALPROPERTYDETAILS
                        AND MaintenanceStaff__c = :UserInfo.getUserId()
                        AND CreatedDate >= :condDate
                 ];

        if (result.isEmpty()){
            result = new List<PropertyMaintenanceHistory__c>();
        }
        
        return result;
    }
    
    //*****************************************************************内部クラス***************************************************************
    
    //画面用建物
    public class DisplayBuilding{
        public Building__c buildingItem {get; set;} //建物そのもの
        public String colorData {get; set;}         //背景色
        
        //コンストラクタ
        public displayBuilding(Building__c buildingItem, Boolean emptyRoomTodayManualMaintenanceFlg){
            this.buildingItem = buildingItem;
            
            setColorData(emptyRoomTodayManualMaintenanceFlg);
        }

        //色付け
        private void setColorData(Boolean emptyRoomTodayManualMaintenanceFlg){
            
            if (emptyRoomTodayManualMaintenanceFlg) {
                //ピンクorグレー
                if (this.buildingItem.PropertyBuilding__r.size() > 0) { //ピンクの物件があれば
                    this.colorData = COLOR_PINK;
                } else {
                    this.colorData = COLOR_GRAY;
                }
            } else {
                //白
                this.colorData = '';
            }
        }
    }
    
    
    
    //画面用取引先履歴
    public class displayHistory{
        public AccountHistory targetAccountHistory { get; set; }

        //表示用項目
        public String createdDate { get; set; }
        public String field { get; set; }
        public String createdByName { get; set; }
        public String oldValue { get; set; }
        public String newValue { get; set; }

        //コンストラクタ
        public displayHistory(AccountHistory targetAccountHistory){

            //取引先履歴レコードの連動
            this.targetAccountHistory = targetAccountHistory;
            this.createdDate          = targetAccountHistory.createdDate.format('yyyy/MM/dd HH:mm', 'JST');
            this.field = targetAccountHistory.Field;
            this.createdByName = targetAccountHistory.CreatedBy.Name;
            this.oldValue = String.valueOf(targetAccountHistory.OldValue);
            this.newValue = String.valueOf(targetAccountHistory.NewValue); 
            if(this.field == 'DembutsuDate__c'){
                if(!String.isBlank(oldValue)){
                    this.oldValue  = this.oldValue.replace(' 00:00:00','');
                    this.oldValue  = this.oldValue.replace('-','/');
                }
                if(!String.isBlank(newValue)){
                    this.newValue  = this.newValue.replace(' 00:00:00','');
                    this.newValue  = this.newValue.replace('-','/');
                }

            }

        }
    }

    /**
     * 画面表示用内部クラス（物件一覧）
     */
    public class ScreenPropertyList {
        public Id       Id { get; set; }                    // 物件．ID
        public Boolean  IsSelected { get; set; }            // 選択値
        public String   Name { get; set; }                  // 物件．部屋番号
        // ▼ 2022.4.18 要望No0760で不要となったため、削除 
        // public DateTime LastModifiedDate { get; set; }      // 物件．最終更新日
        // public DateTime ManualMaintenanceDate { get; set; } // 物件．手動最終メンテナンス日
        // ▲ 2022.4.18 要望No0760で不要となったため、削除 
        public String   LiveStatus { get; set; }            // 物件．現況
        public String   DeliveryDateView { get; set; }      // 物件．引渡日(表示用）
        public Decimal  PropertyPhotoCount  { get; set; }   // 物件．物件写真枚数
        public Decimal  Score { get; set; }                 // 物件．点数
        public Decimal  RoomCount { get; set; }             // 物件．部屋数
        public String   RoomLayout { get; set; }            // 物件．間取り（レイアウト）
        public Decimal  RentFee { get; set; }               // 物件．賃料
        public Decimal  ManagementFeeTax { get; set; }      // 物件．管理費(税込)
        public Decimal  SecurityDepositYen { get; set; }    // 物件．敷金(円)
        public Decimal  DepositYen { get; set; }            // 物件．保証料金(円)
        public Decimal  KeyMoneyYen { get; set; }           // 物件．礼金(円)
        public Boolean  IsSuumo  { get; set; }              // ポータルサイト掲載物件．SUUMO
        public Boolean  IsHomes  { get; set; }              // ポータルサイト掲載物件．HOME'S
        public Boolean  IsAtHome { get; set; }              // ポータルサイト掲載物件．at home
        public String   WebPublishing { get; set; }         // 物件．web公開
        public DateTime OwnCompanyManageModDate { get; set; }// 物件．自社管理修正日 2022.4.18 No0760 元付物件詳細画面に「自社管理修正日」を表示

        /**
         * コンストラクタ
         * @param Property__c                  property                  物件
         * @param PortalSitePostingProperty__c portalSitePostingProperty ポータルサイト掲載地区
         */
        public ScreenPropertyList(Property__c property, PortalSitePostingProperty__c portalSitePostingProperty) {
            this.Id                    = property.Id;
            this.IsSelected            = false;
            this.Name                  = property.Name;
            // ▼ 2022.4.18 要望No0760で不要となったため、削除 
            //this.LastModifiedDate      = property.LastModifiedDate;
            //this.ManualMaintenanceDate = property.ManualMaintenanceDate__c;
            // ▲ 2022.4.18 要望No0760で不要となったため、削除 
            this.LiveStatus            = property.LiveStatus__c;
            this.DeliveryDateView      = property.DeliveryDateView__c;
            this.PropertyPhotoCount    = property.PropertyPhotoCount__c;
            this.Score                 = property.Score__c;
            this.RoomCount             = property.RoomCount__c;
            this.RoomLayout            = property.RoomLayout__c;
            this.RentFee               = property.RentFee__c;
            this.ManagementFeeTax      = property.ManagementFeeTax__c;
            this.SecurityDepositYen    = property.SecurityDepositYen__c;
            this.DepositYen            = property.DepositYen__c;
            this.KeyMoneyYen           = property.KeyMoneyYen__c;
            this.IsSuumo               = portalSitePostingProperty.IsSuumo__c;
            this.IsHomes               = portalSitePostingProperty.IsHomes__c;
            this.IsAtHome              = portalSitePostingProperty.IsAtHome__c;
            this.WebPublishing         = property.WebPublishing__c;
            this.OwnCompanyManageModDate = property.OwnCompanyManageModDate__c; //自社管理修正日 2022.4.18 No0760 元付物件詳細画面に「自社管理修正日」を表示
        }
    }
}