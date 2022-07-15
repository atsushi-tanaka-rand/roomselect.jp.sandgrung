/**
 * 業者プラン一括変更画面
 */
public with sharing class GD101002Modal2Controller {

    /** パラメータクラス */
    public GD101002Modal2ParameterClass parameter { get; set; }

    /** 内部クラス */
    public  ScreenSupplierPlanBulkChg screenSupplierPlanBulkChg { get; set; } // 業者プラン一括変更画面

    /** フラグ */
    public Boolean isOpenError     { get; set; } // 画面起動時のエラーフラグ
    public Boolean hasErrorMessage { get; set; } // エラーメッセージ保有フラグ

    /** JS用メッセージ */
    public String MSG_CONFIRM_SAVE { get; private set; } // 保存確認メッセージ
    public String MSG_SELECTION_OR_MORE_BUILDING {
        get{ return CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE, '建物', '1'); }
        private set; } // 建物は1個以上選択してください。
    public String MSG_COMPLETE_SAVE {
        get{ return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_EMAIL_AFTER_PROCESSING, '一括変更'); }
        private set; } // 一括変更を実施中です。<br/>完了後にメールが送信されます。

    /** 定数 */
    public final String OBJ_NAME_INSURANCE_GUARANTEE = String.valueOf(InsuranceGuarantee__c.getSObjectType()); // 取引先保険保証_API名

    /**
     * 画面描画時処理
     */
    public Boolean init {
        get {
            if (this.parameter.isDrawing) {
 
                // 画面初期化
                this.initScreen();
 
                // 画面描画時処理の停止
                this.parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }

    /**
     * 画面初期化
     */
    private void initScreen() {

        try {
            // フラグの初期化
            this.isOpenError     = false;
            this.hasErrorMessage = false;

            // 業者プラン一括変更画面情報の設定
            this.setScreenBulkChange();

            // 保存確認メッセージの設定
            this.MSG_CONFIRM_SAVE = CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_PROPERTY_BULK_CHG
                                                                 , this.screenSupplierPlanBulkChg.saveConfirmDispKindMsg);

        } catch(Exception e) {
            this.isOpenError = true;
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 一括変更画面情報の設定
     */
    private void setScreenBulkChange() {
        
        // 変更先リストの取得
        List<ScreenChangeDestination> scdList = this.getChangeDestinationList();

        // 変更対象の建物の取得
        List<Building__c> buildingList = this.selectChgTargetBuilding();
        
        // 業者プラン一括変更画面情報の設定
        this.screenSupplierPlanBulkChg = new ScreenSupplierPlanBulkChg(parameter, buildingList, scdList);
    }

    /**
     * 変更対象の建物の取得
     * @return List<Building__c> 変更対象の建物
     */
    private List<Building__c> selectChgTargetBuilding() {

        // 物件の取得
        List<Property__c> propertyList = this.selectProperty(this.parameter);

        // 建物Idの取得
        Set<Id> buildingIdSet = new Set<Id>();
        for (Property__c property : propertyList) {
            buildingIdSet.add(property.Building__c);
        }

        // 建物の取得
        return this.selectBuilding(buildingIdSet);
    }

    /**
     * 変更先リストの取得
     * @return List<ScreenChangeDestination> 変更先
     */
    private List<ScreenChangeDestination> getChangeDestinationList() {

        List<ScreenChangeDestination> scdList = new List<ScreenChangeDestination>();

        // 画面種別に応じたリストの取得
        switch on this.parameter.openDispKind {
            when guaranteeidCorp {
                scdList = getScreenChangeDestinationListPlan(CommonConst.INSURANCE_RECTYPE_GUARANTEE_GUARANTEE);
            }
            when fireInsuranceCorp {
                scdList = getScreenChangeDestinationListPlan(CommonConst.INSURANCE_RECTYPE_GUARANTEE_FIREINSURANCE);
            }
            when manaCorpItem {
                scdList = getScreenChangeDestinationListItem();
            }
        }

        return scdList;
    }

    /**
     * 変更先（プラン情報）の取得
     * @param insuranceGuaranteeRecordTypeApi 取引先保険保証_レコードタイプAPI名
     * @return List<ScreenChangeDestination> 変更先（プラン情報）
     */
    private List<ScreenChangeDestination> getScreenChangeDestinationListPlan(String insuranceGuaranteeRecordTypeApi) {

        // 初期化 + 空行追加
        List<ScreenChangeDestination> scdList = new List<ScreenChangeDestination>();
        scdList.add(new ScreenChangeDestination());

        // 取引先保険保証取得条件
        String condAccountId  = this.parameter.accountId;                                    // 取引先Id
        Id     condRecordType = CommonUtil.getRecordTypeId(OBJ_NAME_INSURANCE_GUARANTEE      // レコードタイプ
                                                           , insuranceGuaranteeRecordTypeApi);

        // 取引先保険保証の取得
        List<InsuranceGuarantee__c> insuranceGuaranteeList;
        insuranceGuaranteeList = this.selectInsuranceGuarantee(condAccountId, condRecordType);

        // 変更先の設定
        for (InsuranceGuarantee__c insuranceGuarantee : insuranceGuaranteeList) {

            // 変更元チェック
            if (insuranceGuarantee.Item__r.Id == this.parameter.chgOriginalId) {
                continue;
            }

            scdList.add(new ScreenChangeDestination(insuranceGuarantee));
        }

        return scdList;
    }

    /**
     * 物件の取得
     * @param GD101002Modal2ParameterClass paramCls 業者プラン一括変更画面のパラメータクラス
     * @return List<Property__c> 物件
     */
    private List<Property__c> selectProperty(GD101002Modal2ParameterClass paramCls) {

        // 物件取得クエリの作成
        String sql = CommonConst.STRING_EMPTY;
        sql = 'SELECT Building__c '
            + 'FROM Property__c '
            + 'WHERE FormerSupplier__c = \'' + CommonUtil.escapeSingleQuotesEx(paramCls.accountId) + '\' ';

        // 画面種別に応じた物件の取得
        switch on paramCls.openDispKind {
            when guaranteeidCorp {
                sql += ' AND Guaranteeid__c = \'' + CommonUtil.escapeSingleQuotesEx(paramCls.chgOriginalId) + '\' ';
            }
            when fireInsuranceCorp {
                sql += ' AND FireInsurancePlan__c = \'' + CommonUtil.escapeSingleQuotesEx(paramCls.chgOriginalId) + '\' ';
            }
            when manaCorpItem {
                sql += ' AND Id IN (SELECT Property__c '
                     + '            FROM PropertyManageCompayItem__c '
                     + '            WHERE Item__c = \'' + CommonUtil.escapeSingleQuotesEx(paramCls.chgOriginalId) + '\' '
                     + '                  AND Account__c = \'' + CommonUtil.escapeSingleQuotesEx(paramCls.accountId) + '\' '
                     + '           ) ';
            }
        }

        // 物件の取得
        List<Property__c> propertyList = Database.query(sql);

        // 初期化処理
        if (propertyList.isEmpty()) {
            propertyList = new List<Property__c>();
        }

        return propertyList;
    }

    /**
     * 建物の取得
     * @param Set<Id> condBuildingIdSet 建物Id
     * @return List<Building__c> 建物
     */
    private List<Building__c> selectBuilding(Set<Id> condBuildingIdSet) {

        // 建物の取得
        List<Building__c> buildingList;
        buildingList = [SELECT Id
                               , Name                      // 建物名
                               , Address__c                // 住所
                               , Structure__c              // 建物構造
                               , BuildingYMFormat__c       // 築年月
                               , Station1__r.Name          // 駅１.駅名
                               , StationWalkTimeFormat1__c // 駅までの時間（分）１
                        FROM Building__c
                        WHERE ID = :condBuildingIdSet
                        ORDER BY Name 
                       ];

        // 初期化処理
        if (buildingList.isEmpty()) {
            buildingList = new List<Building__c>();
        }

        return buildingList;
    }

    /**
     * 取引先保険保証の取得
     * @param Id condAccountId  取引先Id
     * @param Id condRecordType レコードタイプ
     * @return List<InsuranceGuarantee__c> 取引先保険保証
     */
    private List<InsuranceGuarantee__c> selectInsuranceGuarantee(Id condAccountId, Id condRecordType) {

        // 取引先保険保証の取得
        List<InsuranceGuarantee__c> insuranceGuaranteeList;
        insuranceGuaranteeList = [SELECT Item__r.Id
                                         , Item__r.Account__c
                                         , Item__r.Account__r.Name 
                                         , Item__r.ItemName__c
                                  FROM InsuranceGuarantee__c
                                  WHERE Account__c = :condAccountId
                                        AND RecordTypeId = :condRecordType
                                  ORDER BY Item__r.Account__r.Name
                                 ];

        // 初期化処理
        if (insuranceGuaranteeList.isEmpty()) {
            insuranceGuaranteeList = new List<InsuranceGuarantee__c>();
        }

        return insuranceGuaranteeList;
    } 

    /**
     * 変更先（商品情報）の取得
     * @return List<ScreenChangeDestination> 変更先（商品情報）
     */
    private List<ScreenChangeDestination> getScreenChangeDestinationListItem() {

        // 初期化 + 空行追加
        List<ScreenChangeDestination> scdList = new List<ScreenChangeDestination>();
        scdList.add(new ScreenChangeDestination());

        // 管理会社指定商品の取得
        List<ManagementCompanyItem__c> manaCorpItemList;
        manaCorpItemList = this.selectManaCorpItem(this.parameter.accountId);

        // 変更先リストの設定
        for (ManagementCompanyItem__c manaCorpItem : manaCorpItemList) {

            // 変更元チェック
            if (manaCorpItem.id == this.parameter.chgOriginalId) {
                continue;
            }

            scdList.add(new ScreenChangeDestination(manaCorpItem));
        }

        return scdList;
    }

    /**
     * 管理会社指定商品の取得
     * @param Id condAccountId 取引先Id
     * @return List<ManagementCompanyItem__c> 管理会社指定商品
     */
    private List<ManagementCompanyItem__c> selectManaCorpItem(Id condAccountId) {

        // 管理会社指定商品の取得
        List<ManagementCompanyItem__c> manaCorpItemList;
        manaCorpItemList = [SELECT id
                                   , ItemName__c
                            FROM ManagementCompanyItem__c
                            WHERE Account__c = :condAccountId
                            ORDER BY ItemName__c];

        // 初期化処理
        if (manaCorpItemList.isEmpty()) {
            manaCorpItemList = new List<ManagementCompanyItem__c>();
        }
    
        return manaCorpItemList;
    }

    /**
     * 保存処理
     */
    public void saveProcess() {

        try {
            this.hasErrorMessage = false;

            // 入力エラーメッセージの取得
            BusinessLogicException ex = this.getValidateErrMsg();
            if (ex.hasMessage()) { 
                throw ex;
            }

            // 変更先の削除済みレコードチェック
            if(this.isDeleteRecord(this.screenSupplierPlanBulkChg)) {
                throw new OptimisticLockException();
            }

            // 選択行の建物Idの取得
            Set<Id> buildingIdSet = new Set<Id>();
            for (ScreenDetailBuilding detailRow : screenSupplierPlanBulkChg.screenDetailBuildingList) {
                if (detailRow.selected) {
                    buildingIdSet.add(detailRow.buildingId);
                }
            }

            // 選択値の変更先情報の取得
            ScreenChangeDestination screenChgDestination = this.screenSupplierPlanBulkChg.getSelectedChgDestination();

            // バッチの起動
            GD102001Batch batch = new GD102001Batch(buildingIdSet                                         // 建物ID
                                                    , screenSupplierPlanBulkChg.formerSupplier            // 元付業者
                                                    , screenSupplierPlanBulkChg.formerSupplierName        // 元付業者名
                                                    , screenChgDestination.chgDestinationAccountId        // 変更先取引先ID
                                                    , screenSupplierPlanBulkChg.chgOriginalObjId          // 変更元オブジェクトID
                                                    , screenSupplierPlanBulkChg.changeDestinationSelected // 変更先オブジェクトID
                                                    , screenSupplierPlanBulkChg.chgOriginalName           // 変更元名称
                                                    , screenChgDestination.chgDestinationName             // 変更先名称
                                                    , this.parameter.openDispKind.name());                // 画面種別
            Database.executeBatch(batch, 50);

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 入力エラーメッセージの取得
     * @return BusinessLogicException 例外情報
     */
    private BusinessLogicException getValidateErrMsg() {

        BusinessLogicException ex = new BusinessLogicException();

        // 変更先チェック
        if (String.isBlank(screenSupplierPlanBulkChg.changeDestinationSelected)){
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '変更先'));
        }

        return ex;
    }

    /**
     * 削除済みレコードチェック
     * @param ScreenSupplierPlanBulkChg bulkChange 業者プラン一括変更画面
     * @return Boolean true:削除済み、false:未削除
     */
    private Boolean isDeleteRecord(ScreenSupplierPlanBulkChg bulkChange) {
        
        // クエリの作成
        String sql = CommonConst.STRING_EMPTY;
        sql += ' SELECT Id';
        sql += ' FROM ' + bulkChange.targetObjName;
        sql += ' WHERE Id = \'' + CommonUtil.escapeSingleQuotesEx(bulkChange.changeDestinationSelected) + '\'';

        // レコードの取得
        List<SObject> currentRecordList = Database.query(sql);

        // 削除済みチェック
        if (currentRecordList.isEmpty()) {
            return true;
        }
        
        return false;
    }

    /**
     * 業者プラン一括変更画面
     */
    public class ScreenSupplierPlanBulkChg {

        /** 画面項目 */
        public Boolean allSelected                     { get; set; } // 明細全選択
        public String  changeDestinationSelected       { get; set; } // 変更先選択値
        public String  chgOriginalName                 { get; set; } // 変更元名

        public List<SelectOption>            changeDestinationList       { get; set; } // 変更先（画面表示用）
        public List<ScreenChangeDestination> screenChangeDestinationList { get; set; } // 変更先情報
        public List<ScreenDetailBuilding>    screenDetailBuildingList    { get; set; } // 建物明細

        /** その他項目 */
        public Id      formerSupplier                  { get; set; } // 元付業者
        public String  formerSupplierName              { get; set; } // 元付業者名
        public Id      chgDestinationAccountId         { get; set; } // 変更先取引先Id
        public Id      chgOriginalObjId                { get; set; } // 変更元オブジェクトId
        public String  targetObjName                   { get; set; } // 取得対象オブジェクト名
        public String  saveConfirmDispKindMsg          { get; set; } // 保存確認時の画面種別メッセージ

        /**
         * コンストラクタ
         * @param GD101002Modal2ParameterClass  paramCls                    業者プラン一括変更画面のパラメータクラス
         * @param List<Building__c>             buildingList                建物
         * @param List<ScreenChangeDestination> screenChangeDestinationList 変更先情報
         */
        public screenSupplierPlanBulkChg (GD101002Modal2ParameterClass paramCls
                                          , List<Building__c> buildingList
                                          , List<ScreenChangeDestination> screenChangeDestinationList) {
            
            // 項目の設定
            this.formerSupplier              = paramCls.accountId;          // 元付業者
            this.formerSupplierName          = paramCls.accountName;        // 元付業者名
            this.chgOriginalObjId            = paramCls.chgOriginalId;      // 変更元オブジェクトId
            this.chgOriginalName             = paramCls.chgOriginalName;    // 変更元名
            this.changeDestinationSelected   = CommonConst.STRING_EMPTY;    // 変更先選択値
            this.allSelected                 = false;                       // 明細全選択
            this.screenChangeDestinationList = screenChangeDestinationList; // 変更先情報

            // 画面種別に応じた項目の設定
            switch on paramCls.openDispKind {
                // 保証会社プラン
                when guaranteeidCorp  {
                    this.targetObjName = String.valueOf(Item__c.getSObjectType());         // 取得対象オブジェクト名
                    this.saveConfirmDispKindMsg = CommonConst.SUPPLIER_PLAN_BULK_CHG_PLAN; // 保存確認時の画面種別メッセージ
                }
                // 火災保険会社プラン
                when fireInsuranceCorp {
                    this.targetObjName = String.valueOf(Item__c.getSObjectType());         // 取得対象オブジェクト名
                    this.saveConfirmDispKindMsg = CommonConst.SUPPLIER_PLAN_BULK_CHG_PLAN; // 保存確認時の画面種別メッセージ
                }
                // 管理会社指定商品
                when manaCorpItem {
                    this.targetObjName = String.valueOf(ManagementCompanyItem__c.getSObjectType()); // 取得対象オブジェクト名
                    this.saveConfirmDispKindMsg = CommonConst.SUPPLIER_PLAN_BULK_CHG_ITEM;          // 保存確認時の画面種別メッセージ
                }
            }

            // 建物明細の設定（エラー時に明細の最終行のレイアウトが崩れる為、空行を追加）
            this.changeDestinationList = new List<SelectOption>();
            this.screenDetailBuildingList = new List<ScreenDetailBuilding>();
            for (Building__c building : buildingList) {
                this.screenDetailBuildingList.add(new ScreenDetailBuilding(building));
            }
            this.screenDetailBuildingList.add(new ScreenDetailBuilding());

            // 変更先（画面表示用）の設定
            for (ScreenChangeDestination scd : screenChangeDestinationList) {
                this.changeDestinationList.add(scd.selectOption);
            }
        }

        /**
         * 選択値の変更先情報の取得
         * @return ScreenChangeDestination 変更先情報
         */
        public ScreenChangeDestination getSelectedChgDestination() {

            ScreenChangeDestination selectedScreenChgDestination = new ScreenChangeDestination();
            
            // 選択情報の取得
            for (ScreenChangeDestination screenChgDestination : this.screenChangeDestinationList) {
                if (screenChgDestination.selectOption.getValue() == this.changeDestinationSelected) {
                    selectedScreenChgDestination = screenChgDestination;
                    break;
                }
            }

            return selectedScreenChgDestination;
        }
    }

    /**
     * 建物明細
     */
    public class ScreenDetailBuilding {

        /** 項目 */
        public Boolean selected              { get; set; } // 選択値
        public Id      buildingId            { get; set; } // 建物Id
        public String  buildingName          { get; set; } // 建物情報
        public String  address               { get; set; } // 住所
        public String  structure             { get; set; } // 構造
        public String  buildingYMFormat      { get; set; } // 築年
        public String  stationName           { get; set; } // 最寄駅
        public String  stationWalkTimeFormat { get; set; } // 駅徒歩
        public String  blankRowClass         { get; set; } // 空行クラス

        /** 定数 */
        public final String CSS_BLANK_ROW = 'blank-row';

        /**
         * コンストラクタ
         */
        public screenDetailBuilding() {

            // 項目の設定
            this.selected              = false;                    // 選択値
            this.buildingId            = null;                     // 建物Id
            this.buildingName          = CommonConst.STRING_EMPTY; // 建物情報
            this.address               = CommonConst.STRING_EMPTY; // 住所
            this.structure             = CommonConst.STRING_EMPTY; // 構造
            this.buildingYMFormat      = CommonConst.STRING_EMPTY; // 築年
            this.stationName           = CommonConst.STRING_EMPTY; // 最寄駅
            this.stationWalkTimeFormat = CommonConst.STRING_EMPTY; // 駅徒歩
            this.blankRowClass         = CSS_BLANK_ROW;            // 空行クラス
        }

        /**
         * コンストラクタ
         * @param Building__c building 建物
         */
        public screenDetailBuilding(Building__c building) {

            // 項目の設定
            this.selected              = false;                              // 選択値
            this.buildingId            = building.Id;                        // 建物Id
            this.buildingName          = building.Name;                      // 建物情報
            this.address               = building.Address__c;                // 住所
            this.structure             = building.Structure__c;              // 構造
            this.buildingYMFormat      = building.BuildingYMFormat__c;       // 築年
            this.stationName           = building.Station1__r.Name;          // 最寄駅
            this.stationWalkTimeFormat = building.StationWalkTimeFormat1__c; // 駅徒歩
            this.blankRowClass         = CommonConst.STRING_EMPTY;           // 空行クラス
        }
    }

    /**
     * 変更先情報
     */
    public class ScreenChangeDestination {

        /** 項目 */
        public Id           chgDestinationAccountId { get; set; } // 変更先取引先ID
        public Id           chgDestinationObjId     { get; set; } // 変更先オブジェクトID
        public String       chgDestinationName      { get; set; } // 変更先名称
        public SelectOption selectOption            { get; set; } // リスト値

        /**
         * コンストラクタ
         */
        public screenChangeDestination() {

            // 項目の設定
            this.chgDestinationAccountId = null; // 変更先取引先ID
            this.chgDestinationObjId     = null; // 変更先オブジェクトID
            this.chgDestinationName      = null; // 変更先名称

            // リスト値
            this.selectOption = new SelectOption(CommonConst.STRING_EMPTY
                                                 , CommonConst.SELECTION_LIST_NULL);
        }

        /**
         * コンストラクタ
         * @param InsuranceGuarantee__c insuranceGuarantee 取引先保険保証
         */
        public screenChangeDestination(InsuranceGuarantee__c insuranceGuarantee) {

            // 変更先名称の取得
            String chgDestinationName = insuranceGuarantee.Item__r.Account__r.Name + ' ' + insuranceGuarantee.Item__r.ItemName__c;  

            // 項目の設定
            this.chgDestinationAccountId = insuranceGuarantee.Item__r.Account__c; // 変更先取引先ID
            this.chgDestinationObjId     = insuranceGuarantee.Item__r.Id;         // 変更先オブジェクトID
            this.chgDestinationName      = chgDestinationName;                    // 変更先名称

            // リスト値
            this.selectOption = new SelectOption(this.chgDestinationObjId
                                                 , this.chgDestinationName);
        }

        /**
         * コンストラクタ
         * @param ManagementCompanyItem__c manaCorpItem 管理会社指定商品
         */
        public screenChangeDestination(ManagementCompanyItem__c manaCorpItem) {

            // 項目の設定
            this.chgDestinationAccountId = null;                     // 変更先取引先ID
            this.chgDestinationObjId     = manaCorpItem.Id;          // 変更先オブジェクトID
            this.chgDestinationName      = manaCorpItem.ItemName__c; // 変更先名称
            
            // リスト値
            this.selectOption = new SelectOption(this.chgDestinationObjId
                                                 , this.chgDestinationName);
        }
    }
}