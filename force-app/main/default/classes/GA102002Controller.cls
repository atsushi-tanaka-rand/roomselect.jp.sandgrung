/**
 * 仮見積
 */ 
public with sharing class GA102002Controller {
    // 定数
    private static final Integer ETCETERA_AUXILIARY_ITEM_LIST_COUNT = 10;

    // プロパティ
    public Boolean isOpenError { get; set; }                    //エラーフラグ
    public Boolean hasErrorMessage { get; set; }                //エラーメッセージ保有フラグ

    public String accountId { get;set; }                        // 取引先ID
    public String propertyId { get;set; }                       // 物件ID

    public Boolean ProvisionalQuoteDataOutputFlg {get;set; }     // 保存済みの内容で出力ボタンの表示有無

    public String openParam {get;set; }                         // 画面出力用のパラメータの設定

    public Date HomeMovingDate { get;set;}                      // 引越時期
    public Integer ProratedCalculationDay { get;set;}           // 日割り計算月日数
    public Boolean SavedOutputFlag {get;set;}                   // 保存内容出力フラグ
    public Boolean Proratedflag {get;set;}                      // 日割り計算フラグ
    public Boolean Parkingflag {get;set;}                       // 駐車場フラグ
    public String ParkingNumberRequired {get;set;}             // 駐車場必要数
    public Boolean BicycleParkingFlag {get;set;}                // 駐輪場フラグ
    public String BicycleParkingNumberRequired {get;set;}      // 駐輪場必要数    
    public String  ParkingFee { get;set;}                       // 物件．駐車場料金
    public String  BicycleParkingFee { get;set;}                // 物件．駐輪場代
    public Boolean BikeParkingSmallFlag {get;set;}              // バイク置き場（小型）フラグ
    public String BikeParkingSmallNumberRequired {get;set;}    // バイク置き場（小型）必要数
    public String  BikeParkingSmallFee { get;set;}              // 物件．小型バイク置場料金
    public Boolean BikeParkingMediumFlag {get;set;}             // バイク置き場（中型）フラグ
    public String BikeParkingMediumNumberRequired {get;set;}   // バイク置き場（中型）必要数
    public String  BikeParkingMediumFee { get;set;}             // 物件．中型バイク置場料金
    public Boolean BikeParkinLargeFlag {get;set;}               // バイク置き場（大型）フラグ
    public String BikeParkinLargeNumberRequired {get;set;}     // バイク置き場（大型）必要数
    public String BikeParkinLargeFee { get;set;}               // 物件．大型バイク置場料金
    public String auxiliaryDepositPlan {get;set;}               // 保証プラン
    public String auxiliaryFireInsurance { get;set;}            //火災保険
    public String RenewalFeeShow { get;set; }                   //更新料表記
    public String CleaningFeeShow { get;set; }                  //定額修繕費表記
    public String GuaranteeidCompanyType { get;set; }           //保証会社（利用区分）
    public String FireInsuranceUseType { get;set; }             //火災保険(加入義務)
    public String FormerSupplier { get;set; }                   // 元付業者

    public ScreenItem screen {set;get;}                         // 画面表示用の内部クラスレコード

    // 選択リスト
    public List<SelectOption> SelectAuxiliaryDepositPlanList{ get; set; }        //付帯保証プラン
    public List<SelectOption> SelectAuxiliaryFireInsuranceList{ get; set; }      //付帯火災保険
    public List<SelectOption> SelectRenewalFeeShowList{ get; set; }             //更新料表記
    public List<SelectOption> SelectCleaningFeeShowList{ get; set; }            //定額修繕費表記
    public List<SelectOption> SelectEtceteraAuxiliaryItemTypeList { get; set; }         // その他付帯商品種別
    public List<SelectOption> SelectEtceteraAuxiliaryItemNameList { get; set; }         // その他付帯商品名（業者／商品名／料金）

    private List<Property__c> PropertyList;                                     // 物件情報
    public ProvisionalQuote__c ProvisionalQuoteRecord{get;set;}                 // 仮見積

    // メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    // js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    // js用削除完了メッセージ
    
    // プライベート変数
    private Map<Id, Item__c> etceteraAuxiliaryItemMap;        // その他付帯商品のマップ


    /**
    * 初期表示処理
    */
    public GA102002Controller() {
        isOpenError = false;

        try{
            screen = new ScreenItem();
            PropertyList = new List<Property__c> ();//物件情報
            ProvisionalQuoteRecord = new ProvisionalQuote__c();//仮見積
            SelectAuxiliaryDepositPlanList = new List<SelectOption>();//付帯保証プラン
            SelectAuxiliaryFireInsuranceList = new List<SelectOption>();//火災保険
            // パラメータの取得
            paramAndIsNewSetting();    
            // 仮見積の取得
            setProvisionalQuote(this.accountId,this.propertyId);
            // 日付系の初期表示設定
            SetHomeMovingDate(this.accountId);
            // 物件の情報から金額をセットする。
            PropertyList = getProperty(this.propertyId);
            if(PropertyList.size() > 0){
                // リストボックスに設定する用の値を取得
                ParkingFee = CommonUtil.decimalToString(PropertyList[0].ParkingFee__c);// 物件．駐車場料金
                BicycleParkingFee =CommonUtil.decimalToString(PropertyList[0].BicycleParkingFee__c) ;// 物件．駐輪場代
                BikeParkingSmallFee = CommonUtil.decimalToString(PropertyList[0].BikeParkingSmallFee__c);// 物件．小型バイク置場料金
                BikeParkingMediumFee = CommonUtil.decimalToString(PropertyList[0].BikeParkingMediumFee__c);// 物件．中型バイク置場料金
                BikeParkinLargeFee = CommonUtil.decimalToString(PropertyList[0].BikeParkinLargeFee__c);// 物件．大型バイク置場料金
                RenewalFeeShow = PropertyList[0].FormerSupplier__r.RenewalFeeShow__c;// 物件．元付業者．更新料表記
                CleaningFeeShow = PropertyList[0].FormerSupplier__r.CleaningFeeShow__c;// 物件．元付業者．定額修繕費表記
                GuaranteeidCompanyType = PropertyList[0].GuaranteeidCompanyType__c;// 物件．保証会社（利用区分）
                FireInsuranceUseType = PropertyList[0].FireInsuranceUseType__c;// 物件．火災保険(加入義務)
                FormerSupplier = PropertyList[0].FormerSupplier__c;// 物件。元付業者
            }
            
            // リストボックスの設定
            this.selectRenewalFeeShowList = CommonUtil.getSelectOptionFromObject('Account', 'RenewalFeeShow__c',true);//更新料表記
            this.selectCleaningFeeShowList = CommonUtil.getSelectOptionFromObject('Account', 'CleaningFeeShow__c',true);//定額修繕費表記
            DepositPlanListSetting(this.FormerSupplier);//保証プラン
            fireInsuranceListSetting(this.FormerSupplier);//火災保険

            // 保証プランが物件で設定されている場合、リストを絞り込んで対象を選択した状態にする。
            if(String.isNotBlank(PropertyList[0].Guaranteeid__c)){
                List<ItemDetail__c> DepositItemDetailList = getDepositItemList(PropertyList[0].Guaranteeid__c);
                if(DepositItemDetailList.size() == 1){
                    // 件数が1件であった場合、初期表示を設定する。
                    this.auxiliaryDepositPlan = DepositItemDetailList[0].id;
                }
                for (Integer i=this.SelectAuxiliaryDepositPlanList.size()-1; i > 0; i--){
                    Boolean RemovalFlg = true; // 除去フラグ
                    for(ItemDetail__c  DepositItemDetail:DepositItemDetailList){
                        if(this.SelectAuxiliaryDepositPlanList[i].getValue() ==  DepositItemDetail.id){
                            // 選択リストと対象のプラン明細が一致していれば除外しない状態にする。
                            Removalflg = false;      
                            break;  
                        }
                    }
                    if(Removalflg){
                        // 除去フラグが立っていれば一覧から除外する。
                        this.SelectAuxiliaryDepositPlanList.remove(i);
                    }
                }
            }
            
            // 火災保険が物件で設定されている場合、リストを絞り込んで対象を選択した状態にする。
            if(String.isNotBlank(PropertyList[0].FireInsurancePlan__c)){
                this.auxiliaryFireInsurance = PropertyList[0].FireInsurancePlan__c;     // 火災保険の対象
                for (Integer i=this.SelectAuxiliaryFireInsuranceList.size()-1; i > 0; i--){
                    if (this.SelectAuxiliaryFireInsuranceList[i].getValue() != PropertyList[0].FireInsurancePlan__c){
                        //選択されていない火災プランをリストから削除
                        this.SelectAuxiliaryFireInsuranceList.remove(i);
                    }
                }
            }

            // 付帯商品Map初期化
            etceteraAuxiliaryItemMap = searchEtceteraAuxiaryItemRecode();
            // 付帯商品種別
            this.SelectEtceteraAuxiliaryItemTypeList = CommonUtil.getSelectOptionFromObject('Item__c', 'AuxiliaryItemType__c');
            // 付帯商品名（業者／商品名／料金）
            this.SelectEtceteraAuxiliaryItemNameList = getEtceteraAuxiliaryItemNameListFromType(screen.etceteraAuxiliaryItemName);

        }catch(Exception e){
            // エラーを設定
            CommonUtil.setErrorMessage(e);  
            isOpenError = true;
        }
    }

// -----------------------------------------------------------------------------------------------
// privateメソッド
// -----------------------------------------------------------------------------------------------
    /**
    * パラメータの取得
    */
    private void paramAndIsNewSetting(){
        // 取引先ID
        this.accountId = ApexPages.currentPage().getParameters().get('AccountId');
        // 物件ID
        this.propertyId = ApexPages.currentPage().getParameters().get('PropertyId');
    }

    /**
    * 仮見積の情報取得
    * 引数　　：  AccountId String 取引先ID
    * 　　　　： PropertyId String 物件ID
    * 戻り値　：　
    */
    private void setProvisionalQuote(String AccountId,String PropertyId){
        ProvisionalQuoteDataOutputFlg = false;
        List<ProvisionalQuote__c> ProvisionalQuoteList = [SELECT ID
                                                        ,ContractStartDate__c
                                                        ,IsProrated__c
                                                        ,ProratedMonthDays__c
                                                        ,IsParkingUse__c
                                                        ,ParkingRequiredNumber__c
                                                        ,ParkingRequiredNumberFee__c
                                                        ,IsBicycleParkingUse__c
                                                        ,BicycleParkingRequiredNumber__c
                                                        ,BicycleParkingRequiredNumberFee__c
                                                        ,IsBikeStorageSmallUse__c
                                                        ,BikeStorageSmallRequiredNumber__c
                                                        ,BikeStorageSmallRequiredNumberFee__c
                                                        ,IsBikeStorageMediumUse__c
                                                        ,BikeStorageMediumRequiredNumber__c
                                                        ,BikeStorageMediumRequiredNumberFee__c
                                                        ,IsBikeStorageLargeUse__c
                                                        ,BikeStorageLargeRequiredNumber__c
                                                        ,BikeStorageLargeRequiredNumberFee__c
                                                        ,DepositItem__c
                                                        ,FireInsuranceItem__c
                                                        ,RenewalFeeShow__c
                                                        ,CleaningFeeShow__c
                                                        , AuxiliaryItem1__c                             // 付帯商品１．付帯商品Id
                                                        , AuxiliaryItem2__c                             // 付帯商品２．付帯商品Id
                                                        , AuxiliaryItem3__c                             // 付帯商品３．付帯商品Id
                                                        , AuxiliaryItem4__c                             // 付帯商品４．付帯商品Id
                                                        , AuxiliaryItem5__c                             // 付帯商品５．付帯商品Id
                                                        , AuxiliaryItem6__c                             // 付帯商品６．付帯商品Id
                                                        , AuxiliaryItem7__c                             // 付帯商品７．付帯商品Id
                                                        , AuxiliaryItem8__c                             // 付帯商品８．付帯商品Id
                                                        , AuxiliaryItem9__c                             // 付帯商品９．付帯商品Id
                                                        , AuxiliaryItem10__c                            // 付帯商品１０．付帯商品Id
                                                       FROM ProvisionalQuote__c
                                                       WHERE Account__c = :AccountId
                                                       AND   Property__c= :PropertyId];
        if(ProvisionalQuoteList.size() > 0){
            // データがあればセットする。
            ProvisionalQuoteRecord = ProvisionalQuoteList[0];
            ProvisionalQuoteDataOutputFlg = true;
        }
    }

    /**
    * 取引先での計算（日付系）
    * 引数　　：　id String 取引先id
    * 戻り値　：　Boolean 件数の取得有無
    */
    private void SetHomeMovingDate(string id){
        // 取引先の取得（引越時期の設定）
        List<Account> AccountList = [SELECT Id,HomeMovingSeason__c , HomeMovingDate__c FROM Account WHERE Id = :id];
        if(AccountList.size() > 0){
            if(AccountList[0].HomeMovingSeason__c != 'その他'){
                // 取引先．引越時期≠"その他"の場合
                // 取引先．引越時期（日付）までに
                HomeMovingDate = AccountList[0].HomeMovingDate__c;
            }else{
                // 取引先．引越時期＝"その他"の場合
                // 現在日付の次月1日
                HomeMovingDate = CommonUtil.getToday().addMonths(1).toStartOfMonth();

            }
        }
        // 日割り計算日数設定
        if(HomeMovingDate != null){
            date oneMonths = HomeMovingDate.addMonths(1);
            date Month = oneMonths.toStartOfMonth().addDays(-1);
            ProratedCalculationDay = Month.day();
        }
    }

    /**
    * 物件情報取得
    * 引数　　：　Id String 物件id
    * 戻り値　：　Boolean 件数の取得有無
    */
    private List<Property__c> getProperty(string Id){
        List<Property__c> PropertyList = [SELECT Id
                                        , ParkingFee__c
                                        , BicycleParkingFee__c
                                        , BikeParkingSmallFee__c
                                        , BikeParkingMediumFee__c
                                        , BikeParkinLargeFee__c
                                        , FormerSupplier__r.RenewalFeeShow__c
                                        , FormerSupplier__r.CleaningFeeShow__c
                                        , GuaranteeidCompanyType__c
                                        , FireInsuranceUseType__c
                                        , FormerSupplier__c
                                        , FireInsurancePlan__c
                                        , Guaranteeid__c
                                        , RenewalFee__c
                                        FROM Property__c 
                                        WHERE Id = :Id];
        return PropertyList;
    }

    /**
    * 保証プランの商品明細の一覧取得
    * 引数　　：  selectList List<SelectOption> 商品List
    * 戻り値　：  List<ItemDetail__c> 保証プラン明細
    */
    private List<ItemDetail__c> getDepositItemList(id DepositItemId){
        List<ItemDetail__c> depositItemDetailList =[SELECT id,
                                Item__c
                                FROM ItemDetail__c
                                WHERE Item__c = :DepositItemId];
        return depositItemDetailList;
    }


    /**
    * 付帯保証プラン選択リスト生成
    * 引数　　：  FormerSupplier String 元付業者ID
    * 戻り値　：  
    */
    private void DepositPlanListSetting(String FormerSupplier){

        //vfの選択肢を作成        
        SelectAuxiliaryDepositPlanList.add(new SelectOption('', commonConst.SELECTION_LIST_NULL));//なし

        //取引先保険保証から対象の付帯保証プランを引っ張り出す。
        List<Account> itemDetailList =[ select id
                                            ,name
                                            ,IsGuaranteeidCompany__c
                                            ,IsInsuranceCompany__c
                                            ,(SELECT id,
                                                    Item__c,
                                                    RecordTypeId
                                                FROM InsuranceGuaranteeAccount__r
                                                WHERE RecordTypeId = :commonUtil.getRecordTypeId('InsuranceGuarantee__c', CommonConst.INSURANCE_RECTYPE_GUARANTEE_GUARANTEE)
                                                )
                                            FROM Account
                                            WHERE Id =  :FormerSupplier];
        if(itemDetailList.size() > 0){
            for(InsuranceGuarantee__c g :itemDetailList[0].InsuranceGuaranteeAccount__r){

                // さらに商品明細で取得
                List<ItemDetail__c> itemDetail2List =[SELECT id,
                        InsurancePlanDetailName__c
                        FROM ItemDetail__c
                        WHERE Item__c = :g.Item__c
                        AND   Item__r.RecordType.DeveloperName = :CommonConst.ITEM_RECTYPE_GUARANTEE_PLAN
                        ];
                for (ItemDetail__c itemDetail : itemDetail2List) {
                    // 付帯保証プラン名が無ければ表示させない
                    if(itemDetail.InsurancePlanDetailName__c != null){
                        //選択肢
                        SelectAuxiliaryDepositPlanList.add(new SelectOption(itemDetail.id, itemDetail.InsurancePlanDetailName__c));
                    }
                }
            }
        }
    }

    /**
    * 付帯火災保険選択リスト生成
    * 引数　　：  FormerSupplier String 元付業者ID
    * 戻り値　：  
    */
    private void fireInsuranceListSetting(String FormerSupplier){
        //vfの選択肢を作成        
        SelectAuxiliaryFireInsuranceList.add(new SelectOption('', commonConst.SELECTION_LIST_NULL));//なし

        List<Account> itemDetailList =[ select id
                                        ,name
                                        ,IsGuaranteeidCompany__c
                                        ,IsInsuranceCompany__c
                                        ,(SELECT id,
                                                Item__c,
                                                Item__r.ItemName__c,
                                                RecordTypeId
                                            FROM InsuranceGuaranteeAccount__r
                                            WHERE RecordTypeId = :commonUtil.getRecordTypeId('InsuranceGuarantee__c', CommonConst.INSURANCE_RECTYPE_GUARANTEE_FIREINSURANCE)
                                            )
                                        FROM Account
                                        WHERE Id =  :FormerSupplier];

        if(itemDetailList.size() >0){
            for(InsuranceGuarantee__c g :itemDetailList[0].InsuranceGuaranteeAccount__r){
                // 火災保険プラン名が無ければ表示させない
                if (g.Item__r.ItemName__c != null ){
                    SelectAuxiliaryFireInsuranceList.add(new SelectOption(g.Item__c, g.Item__r.ItemName__c));
                }
            }
        }
        
    }

    /**
     * その他付帯商品の一覧を検索
     */
    private Map<Id, Item__c> searchEtceteraAuxiaryItemRecode() {
        // 検索実行
        Map<Id, Item__c> records = new Map<Id, Item__c>([
            SELECT Id
            , AuxiliaryItemType__c              // 付帯商品種別
            , Account__r.Name                   // 付帯業者名
            , ItemName__c                       // 商品名
            , auxiliaryItemFeeTaxType__c        // 付帯料金税区分
            , auxiliaryItemFeeTax__c            // 付帯料金(税込)
            , auxiliaryItemFee__c               // 付帯料金
            FROM Item__c
            WHERE RecordTypeId = :CommonUtil.getRecordTypeId('Item__c', CommonConst.ITEM_RECTYPE_AUXILIARY_ITEM)
            ORDER BY  AuxiliaryItemType__c, Account__r.Name, ItemName__c
        ]);
        return records;
    }

    /**
     * その他付帯商品名の選択リストを作成
     */
    private List<SelectOption> getEtceteraAuxiliaryItemNameListFromType(String auxiliaryItemType) {
        List<SelectOption> selectOptionList = new List<SelectOption>();

        // --なし--の追加
        selectOptionList.add(new SelectOption('', commonConst.SELECTION_LIST_NULL));

        // 種別が一致する付帯商品を選択リストに追加
        for (Id key: this.etceteraAuxiliaryItemMap.keySet()) {
            Item__c item = etceteraAuxiliaryItemMap.get(key);
            if (String.isEmpty(auxiliaryItemType) || item.AuxiliaryItemType__c.equals(auxiliaryItemType)) {
                selectOptionList.add(new SelectOption(item.Id, getEtceteraAuxiliaryItemName(item)));
            }
        }

        return selectOptionList;
    }

    /**
     * 商品（カスタム）オブジェクトからその他付帯商品名を作成
     */
    private String getEtceteraAuxiliaryItemName(Item__c item) {
        String ret = '';
        ret += item.Account__r.Name + '/';      // 付帯業者名
        ret += item.ItemName__c + '/\\';        // 商品名
        // 付帯料金
        if (item.auxiliaryItemFeeTax__c != null) {
            ret += CommonUtil.decimalToString(item.auxiliaryItemFeeTax__c);
        }
        return ret;
    }

// -----------------------------------------------------------------------------------------------
// 画面の動作
// -----------------------------------------------------------------------------------------------
    /**
     * 入力内容をチェック
     */
    public void checkInput(){
        hasErrorMessage = false;
        BusinessLogicException ex = new BusinessLogicException();
        try{
            openParam = CommonConst.STRING_EMPTY;
            // 画面項目定義に従い必須入力チェックを行う。
            // 契約開始日
            if(HomeMovingDate == null){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'契約開始日'));
            }
            
            // "日割り計算がチェックされている場合
            // 日割り計算日数が未入力であればエラー"
            if(Proratedflag && ProratedCalculationDay == 0){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'日割り計算がチェックされている場合、日割り計算日数'));
            }
            

            // "駐車場がチェックされている場合
            // 駐車場必要数、駐車場金額が未入力であればエラー"
            if(Parkingflag && (String.isBlank(ParkingNumberRequired) || String.isBlank(ParkingFee))){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'駐車場がチェックされている場合、駐車場必要数、駐車場金額'));
            }

            // "駐輪場がチェックされている場合
            // 駐輪場必要数、駐輪場金額が未入力であればエラー"
            if(BicycleParkingFlag && (String.isBlank(BicycleParkingNumberRequired) || String.isBlank(BicycleParkingFee))){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'駐輪場がチェックされている場合、駐輪場必要数、駐輪場金額'));
            }

            // "バイク置き場（小型）がチェックされている場合
            // バイク置き場（小型）必要数、バイク置き場（小型）金額が未入力であればエラー"
            if(BikeParkingSmallFlag && (String.isBlank(BikeParkingSmallNumberRequired) || String.isBlank(BikeParkingSmallFee))){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'バイク置き場（小型）がチェックされている場合、バイク置き場（小型）必要数、バイク置き場（小型）金額'));
            }

            // "バイク置き場（中型）がチェックされている場合
            // バイク置き場（中型）必要数、バイク置き場（中型）金額が未入力であればエラー"
            if(BikeParkingMediumFlag && (String.isBlank(BikeParkingMediumNumberRequired) || String.isBlank(BikeParkingMediumFee))){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'バイク置き場（中型）がチェックされている場合、バイク置き場（中型）必要数、バイク置き場（中型）金額'));
            }

            // "バイク置き場（大型）がチェックされている場合
            // バイク置き場（大型）必要数、バイク置き場（大型）金額が未入力であればエラー"
            if(BikeParkinLargeFlag && (String.isBlank(BikeParkinLargeNumberRequired) || String.isBlank(BikeParkinLargeFee))){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'バイク置き場（大型）がチェックされている場合、バイク置き場（大型）必要数、バイク置き場（大型）金額'));
            }

            // 保証会社（利用区分）が"利用必須"の場合、保証プランが未選択であればエラー
            if(GuaranteeidCompanyType == CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_REQUIRED && string.isBlank(auxiliaryDepositPlan)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'保証プラン'));
            }

            // 火災保険料タイトルがセットされている場合、火災保険が未選択であればエラー
            if (String.isNotBlank(PropertyList[0].FireInsurancePlan__c) && string.isBlank(auxiliaryFireInsurance)){
                List<Object> parameters = new List<Object> {'物件', '火災保険', '火災保険' };
                ex.addMessage(CommonUtil.callMessageCreate(String.format(CommonConst.MSG_COM_W_PROPERTYSETTING_REQUIRED, parameters)));

            }

            // 更新料がある場合、更新料表記を選択していないとエラー
            system.debug(PropertyList[0].RenewalFee__c);
            if((PropertyList[0].RenewalFee__c > 0) && String.isBlank(this.RenewalFeeShow)){
                List<Object> parameters = new List<Object> {'物件', '更新料', '更新料表記' };
                ex.addMessage(CommonUtil.callMessageCreate(String.format(CommonConst.MSG_COM_W_PROPERTYSETTING_REQUIRED, parameters)));
            }

            // エラーあり
            if(ex.hasMessage()){
                throw ex;
            }
            
            // エラーがなければパスを設定する。
            openParam = 'accountId=' + this.accountId
                      + '&PropertyId=' + this.propertyId
                      + '&SavedOutputFlag=' + false
                      + '&HomeMovingDate=' + this.HomeMovingDate.format()
                      + '&Proratedflag=' + this.Proratedflag
                      + '&ProratedCalculationDay=' + this.ProratedCalculationDay
                      + '&Parkingflag=' + this.Parkingflag
                      + '&ParkingNumberRequired=' + this.ParkingNumberRequired
                      + '&ParkingFee=' + CommonUtil.stringToDecimal(this.ParkingFee) 
                      + '&BicycleParkingFlag=' + this.BicycleParkingFlag
                      + '&BicycleParkingNumberRequired=' + this.BicycleParkingNumberRequired
                      + '&BicycleParkingFee=' + CommonUtil.stringToDecimal(this.BicycleParkingFee)
                      + '&BikeParkingSmallFlag=' + this.BikeParkingSmallFlag
                      + '&BikeParkingSmallNumberRequired=' + this.BikeParkingSmallNumberRequired
                      + '&BikeParkingSmallFee=' + CommonUtil.stringToDecimal(this.BikeParkingSmallFee)
                      + '&BikeParkingMediumFlag=' + this.BikeParkingMediumFlag
                      + '&BikeParkingMediumNumberRequired=' + this.BikeParkingMediumNumberRequired
                      + '&BikeParkingMediumFee=' + CommonUtil.stringToDecimal(this.BikeParkingMediumFee)
                      + '&BikeParkinLargeFlag=' + this.BikeParkinLargeFlag
                      + '&BikeParkinLargeNumberRequired=' + this.BikeParkinLargeNumberRequired
                      + '&BikeParkinLargeFee=' +CommonUtil.stringToDecimal( this.BikeParkinLargeFee)
                      + '&auxiliaryDepositPlan=' + this.auxiliaryDepositPlan
                      + '&auxiliaryFireInsurance=' + this.auxiliaryFireInsurance
                      + '&RenewalFeeShow=' + this.RenewalFeeShow
                      + '&CleaningFeeShow=' + this.CleaningFeeShow ;
            for (Integer i = 0; i < ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
                openParam += '&AuxiliaryItem' + (i + 1) + '=' + this.screen.safeGetEtceteraAuxiliaryItemList(i).auxiliaryItemId;
            }
        }catch(Exception e){
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }

    }

    // 選択リスト変更：その他付帯商品種別
    public void etceteraAuxiliaryItemTypeListChange() {
        try{
            // 選択リスト：付帯商品名のリストを入れ替え
            this.SelectEtceteraAuxiliaryItemNameList = getEtceteraAuxiliaryItemNameListFromType(screen.etceteraAuxiliaryItemType);
        }catch(Exception e){
            // エラーを設定
            CommonUtil.setErrorMessage(e);  
            isOpenError = true;
        }
    }

    /**
     * その他付帯商品リストの追加
     */
    public void addEtceteraAuxiliaryItemList() {
        try {
            // エラー状態の解除
            hasErrorMessage = false;

            // 入力値の取得
            Id selectItemId = screen.etceteraAuxiliaryItemName;
            Integer listSize = screen.etceteraAuxiliaryItemList.size();

            // 入力チェック
            if (String.isEmpty(selectItemId)) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '付帯商品'));
                throw ex;
            }

            // 明細件数の最大登録チェック
            if (listSize >= ETCETERA_AUXILIARY_ITEM_LIST_COUNT) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_LESS, '付帯商品', String.valueOf(ETCETERA_AUXILIARY_ITEM_LIST_COUNT)));
                throw ex;
            }

            // １件追加
            AuxiliaryItem item = new AuxiliaryItem(etceteraAuxiliaryItemMap.get(selectItemId), null);
            screen.etceteraAuxiliaryItemList.add(item);

        } catch(Exception e) {
            hasErrorMessage = true;             // エラーを設定
            CommonUtil.setErrorMessage(e);      // エラーメッセージを登録
        }
    }

    /**
     * その他付帯商品リスト削除ボタン
     */
    public void removeEtceteraAuxiliaryItemList() {
        try {
            // エラー状態の解除
            hasErrorMessage = false;

            // パラメータの取得
            String listIndex = Apexpages.currentPage().getParameters().get('ListIndex');
            if (String.isEmpty(listIndex)) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                throw ex;
            }

            // 削除処理
            Integer idx = Integer.valueOf(listIndex);
            screen.etceteraAuxiliaryItemList.remove(idx);

        } catch(Exception e) {
            hasErrorMessage = true;             // エラーを設定
            CommonUtil.setErrorMessage(e);      // エラーメッセージを登録
        }
    }

// -----------------------------------------------------------------------------------------------
// 内部クラス
// -----------------------------------------------------------------------------------------------
    //表示用の内部クラス
    public class ScreenItem{
        public String etceteraAuxiliaryItemType {get; set;}     // その他付帯商品種別
        public String etceteraAuxiliaryItemName {get; set;}     // その他付帯商品名（業者／商品名／料金）

        // リスト
        public List<AuxiliaryItem> etceteraAuxiliaryItemList { get; set; }              // その他付帯商品リスト

        //　コンストラクタ
        public ScreenItem(){
            // その他付帯商品リスト
            this.etceteraAuxiliaryItemList = new List<AuxiliaryItem>();
        }

        // 値取得用メソッド
        public AuxiliaryItem safeGetEtceteraAuxiliaryItemList(Integer idx) {
            if (idx < etceteraAuxiliaryItemList.size()) {
                return etceteraAuxiliaryItemList.get(idx);
            } else {
                return new AuxiliaryItem();
            }
        }
    }

    /**
     * 付帯商品クラス
     */
    public class AuxiliaryItem {
        // プロパティ
        public Id      auxiliaryItemId      { get; set; }   // 付帯商品Id
        public String  auxiliaryItemType    { get; set; }   // 付帯商品種別
        public String  auxiliaryItemAccount { get; set; }   // 付帯業者
        public String  auxiliaryItemName    { get; set; }   // 付帯商品
        public String  auxiliaryItemFee     { get; set; }   // 販売価格

        // コンストラクタ１
        public AuxiliaryItem() {}

        // コンストラクタ２．商品（カスタム）オブジェクトから
        public AuxiliaryItem(Item__c item, String auxiliaryItemFee) {
            this.auxiliaryItemId        = item.Id;                      // 付帯商品Id
            this.auxiliaryItemType      = item.AuxiliaryItemType__c;    // 付帯商品種別
            this.auxiliaryItemAccount   = item.Account__r.Name;         // 付帯業者
            this.auxiliaryItemName      = item.ItemName__c;             // 付帯商品
            this.auxiliaryItemFee       = auxiliaryItemFee;             // 販売価格
        }
    }
}