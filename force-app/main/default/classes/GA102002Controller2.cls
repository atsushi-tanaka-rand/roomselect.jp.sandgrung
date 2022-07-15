/**
 * 仮見積（帳票）
 */
public with sharing class GA102002Controller2 {
    // 定数
    private static final Integer ETCETERA_AUXILIARY_ITEM_LIST_COUNT = 10;
    private static final Integer LINE_FEED_BYTE_UCHIWAKE_2 = 60;                // 内訳項目２の改行幅（バイト数）

    public Boolean isOpenError { get; set; }                    //エラーフラグ
    public Boolean hasErrorMessage { get; set; }                //エラーメッセージ保有フラグ

    public screenProvisionalQuote screenProvisionalQuoteRecord { get;set; }              // 仮見積
    public List<screeenProvisionalQuoteManageCompayItem> screenProvisionalQuoteManageCompayItemList { get;set; } // 仮見積管理会社指定
    public List<screeenProvisionalQuoteManageCompayItem> screenProvisionalQuoteManageCompayItemFirstList{ get;set; } // 仮見積管理会社指定_初回_表示用
    public List<screeenProvisionalQuoteManageCompayItem> screenProvisionalQuoteManageCompayItemMonthList{ get;set; } // 仮見積管理会社指定_月額_表示用
    public List<screeenProvisionalQuoteManageCompayItem> screenProvisionalQuoteManageCompayItemYearList { get;set; } // 仮見積管理会社指定_年額_表示用

    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}   // 登録確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}   // 登録完了メッセ―じ

    /** 商品(火災保険)　更新期間 */
    public String ITEM_PAYMENTTYPE_MONTH {get{return CommonUtil.callMessageCreate(CommonConst.ITEM_PAYMENTTYPE_MONTH);} private set;}   // 月型
    public String ITEM_PAYMENTTYPE_YEAR {get{return CommonUtil.callMessageCreate(CommonConst.ITEM_PAYMENTTYPE_YEAR);} private set;}     // 年型

    /** 管理会社指定商品　支払区分 */
    public String MANAGEMENTCOMPANYITEM_PAYMENTTYPE_FIRST {get{return CommonUtil.callMessageCreate(CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_FIRST);} private set;} // 初回
    public String MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH {get{return CommonUtil.callMessageCreate(CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH);} private set;} // 月額
    public String MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR {get{return CommonUtil.callMessageCreate(CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR);} private set;}   // 年額

    /** 物件　各種支払区分 */
    public String PROPERTY_PAYMENTTYPE_YEAR {get{return CommonUtil.callMessageCreate(CommonConst.PROPERTY_PAYMENTTYPE_YEAR);} private set;}   // 年額


    public parameter parameter { get;set; }                 // 元画面からのパラメータ
    public Boolean changeFlag { get; set; }                 // 変更フラグ
    public Boolean saveFlg  { get;set; }                    // 既に仮見積が存在している場合に更新とするためのフラグ    

    public String auxiliaryDepositPlan {get;set;}               // 保証プラン
    public String auxiliaryFireInsurance { get;set;}            // 火災保険

    // URL
    public String formLogoUrl { get{ return SystemConfig__c.getInstance().FormLogoPath__c; } }      // 帳票ロゴパス
    public Boolean formLogoIsAlive { get; set; }                                                    // 帳票ロゴの存在フラグ（VF起動時に状態取得、PDF側で使用）

    public List<string> screenNullDate{ get;set; }              // 帳票要空列出力処理
    public List<string> screenNullDateAfterFirst{ get;set; }    // 帳票要空列出力処理（初回以降）

    private static final Integer outputPrintAfterFirstMaxCount = 18;       // 出力最大件数（初回以降）
    private Integer outputPrintAfterFirstCount;                 // 出力件数（初回以降）
    private static final Integer outputPrintMaxCount = 24;       // 出力最大件数
    private Integer outputPrintCount;                // 出力件数
    private itemDate Item;      // 付帯保証、火災、管理会社指定商品の情報を保持
    private Decimal TaxRate;    // 消費税
    private decimal Fee;        // 口座振替手数料
    //▼問合せNo0496で追加
    private Integer kaigyoByte = 60; // 改行バイト数
    private Integer kaigyoByteFreeItemName = 90; // 改行バイト数（自由項目名）
    //▲問合せNo0496で追加
    
    public CommonUtil.screenSelectList selectFreeItemFeePaymentType1List    { get; set; }      // 項目1支払区分
    public CommonUtil.screenSelectList selectFreeItemFeePaymentType2List    { get; set; }      // 項目2支払区分
    public CommonUtil.screenSelectList selectFreeItemFeePaymentType3List    { get; set; }      // 項目3支払区分
    public CommonUtil.screenSelectList selectFreeItemFeePaymentType4List    { get; set; }      // 項目4支払区分
    public CommonUtil.screenSelectList selectFreeItemFeePaymentType5List    { get; set; }      // 項目5支払区分
    public CommonUtil.screenSelectList selectFreeItemFeeTaxType1List        { get; set; }      // 項目1税区分
    public CommonUtil.screenSelectList selectFreeItemFeeTaxType2List        { get; set; }      // 項目2税区分
    public CommonUtil.screenSelectList selectFreeItemFeeTaxType3List        { get; set; }      // 項目3税区分
    public CommonUtil.screenSelectList selectFreeItemFeeTaxType4List        { get; set; }      // 項目4税区分
    public CommonUtil.screenSelectList selectFreeItemFeeTaxType5List        { get; set; }      // 項目5税区分
    public CommonUtil.screenSelectList selectNextFreeItemFeeTaxType1List    { get; set; }      // 項目1税区分（初回以降）
    public CommonUtil.screenSelectList selectNextFreeItemFeeTaxType2List    { get; set; }      // 項目2税区分（初回以降）
    public CommonUtil.screenSelectList selectNextFreeItemFeeTaxType3List    { get; set; }      // 項目3税区分（初回以降）
    public CommonUtil.screenSelectList selectNextFreeItemFeeTaxType4List    { get; set; }      // 項目4税区分（初回以降）
    public CommonUtil.screenSelectList selectNextFreeItemFeeTaxType5List    { get; set; }      // 項目5税区分（初回以降）
    //▲問合せNo0496で追加


    public GA102002Controller2() {
        isOpenError = false;
        saveFlg = false;
        try{
            // パラメータ取得
            paramAndIsNewSetting();
            getDate();
            
        }catch(Exception e){
            // エラーを設定
            System.debug('e='+e);
            CommonUtil.setErrorMessage(e);  
            isOpenError = true;
        }
    }

    private void getDate(){
        List<ProvisionalQuote__c> ProvisionalQuoteList = new List<ProvisionalQuote__c>();
        List<Property__c> PropertyList = new List<Property__c>();
        List<PropertyManageCompayItem__c> PropertyManageCompayItemList = new List<PropertyManageCompayItem__c>();
        List<ProvisionalQuoteManageCompayItem__c> ProvisionalQuoteManageCompayItemList = new List<ProvisionalQuoteManageCompayItem__c>();
        Shop__c ShopDate = new Shop__c();
        List<Account> AccountList = new List<Account>();

        itemDate item = new itemdate();
        String accountName = CommonConst.STRING_EMPTY;
        TaxRate = 0;
        this.outputPrintCount = 0;
        this.outputPrintAfterFirstCount = 0;
        //▼問合せNo0496で追加
        // 選択リスト設定
        setSelectList();
        //▲問合せNo0496で追加


        // 税率取得
        TaxRate = SystemConfig__c.getInstance().TaxRate__c;
        // ログインユーザによる店舗の情報を取得
        ShopDate = setShop();

        // 仮見積の情報を取得（仮見積が存在するタイミングで仮見積書出力ボタンを押下したら更新の動作にするため）
        ProvisionalQuoteList = selectProvisionalQuote(this.parameter.propertyId,this.parameter.accountId,this.parameter.Id);

        // 保存フラグの内容によってデータの取得元を変える。
        if(this.parameter.SavedOutputFlag){
            saveFlg = true;     // 更新
            if(ProvisionalQuoteList.size() > 0 ){
            
                // 付帯商品や火災、保証の金額を取得
                item = getItemProvisionalQuote(ProvisionalQuoteList[0]);
                
                // 仮見積の項目から設定
                setProvisionalQuote(ProvisionalQuoteList[0],ShopDate, item);
            
                ProvisionalQuoteManageCompayItemList = getPropertyManageCompayItemProvisionalQuote(this.screenProvisionalQuoteRecord.Id);
                setProvisionalQuoteManageCompayItem(ProvisionalQuoteManageCompayItemList);

            }
            

            // その他付帯商品リストに行番号を登録し、その分を加算
            Integer row = screenProvisionalQuoteRecord.setRowCountToEtceteraAuxiliaryItemList(this.outputPrintCount + 1);
            this.outputPrintCount = row;

            // 初回分の空行作成
            screenNullDate = new List<string>();
            Integer NullDateset = 0 ;
            Integer lastPageCount = Math.mod(this.outputPrintCount, outputPrintMaxCount);
            NullDateset = (lastPageCount == 0)? 0: outputPrintMaxCount - lastPageCount;
            for (Integer i = 0; i < NullDateset; i++) {
                screenNullDate.add('');
            }


            // 初回以降の空行の作成
            screenNullDateAfterFirst = new List<string>();
            NullDateset = 0;
            NullDateset = outputPrintAfterFirstMaxCount - this.outputPrintAfterFirstCount;
            for (Integer i = 0; i < NullDateset; i++) {
                screenNullDateAfterFirst.add('');
            }


        }else{
            // 取引先の取得
            AccountList = selectAccountInfo(this.parameter.accountId);
            if (AccountList.size() > 0){
                accountName = AccountList[0].Name;
            }

            // 付帯商品や火災、保証の金額を取得
            item = getItem(this.parameter);

            // 物件情報から取得
            PropertyList =  selectProperty(this.parameter.propertyId);
            setProvisionalQuotePropertyList(PropertyList,ShopDate,parameter,item,accountName);


            if (ProvisionalQuoteList.size() > 0){
                // 仮見積を既に登録していれば更新とする。
                saveFlg = true;
                this.screenProvisionalQuoteRecord.Id = ProvisionalQuoteList[0].id;

                ProvisionalQuoteManageCompayItemList = getPropertyManageCompayItemProvisionalQuote(this.screenProvisionalQuoteRecord.Id);
            }
            // 物件管理会社指定商品から取得
            PropertyManageCompayItemList = getPropertyManageCompayItem(this.parameter.propertyId);
            setProvisionalQuoteManageCompayItem(PropertyManageCompayItemList,this.parameter,ProvisionalQuoteManageCompayItemList);

            // 月額保証料計算用の総賃料を求める
            Decimal AllRentFee = setProvisionalEstimateTotalRent();

            // 月額保証料の設定
            Decimal AllRentFeeMonthlyFeeDeposit = setMonthlyFeeDeposit(item,this.parameter,AllRentFee);

            // 初回保証料の設定
            setFirstFeeDeposit(item,this.parameter,AllRentFeeMonthlyFeeDeposit);

            // 当てはめた項目からそれぞれ計算する（初回）。
            AmountCalculationFirst();
            // 当てはめた項目からそれぞれ計算する（初回以降）。
            AmountCalculation();
        }            
    }

    /**
    * パラメータの取得
    */
    private void paramAndIsNewSetting(){

        this.parameter = new parameter();
        this.formLogoIsAlive = String.isEmpty(formLogoUrl)? false: this.parameter.formLogoIsAlive;
    }

    /**
     * ログインユーザから店舗の情報を取得する
     * 戻り値　：  店舗データ1件  
     */
    private Shop__c setShop(){
        //ログインユーザから店舗を取得する
        // 店舗情報の取得
        Shop__c shop = new Shop__c();
        shop = CommonUtil.getStaffCurrentShop();
        return shop;

    }

    /**
     * 取得したデータを一覧にセットする。　
     * 引数　　：  PropertyList List<Property__c> 物件List
     * 　　    ：  ShopDate Shop__c 店舗
     * 　　    ：  param parameter 元画面のパラメータ
     * 　　    ：  item itemdate 商品（火災、保証、付帯のデータ）
     * 　　    ：  accountName string 取引先名
     * 戻り値  ：  
     */
    private void setProvisionalQuotePropertyList(List<Property__c> PropertyList,Shop__c ShopDate,parameter param,itemdate item,string accountName){

        //内部クラスに値をセットする。
        for(Property__c candidate :PropertyList) {
            //出力用に合わせて変換する。
            screenProvisionalQuote screenProvisionalQuote = new screenProvisionalQuote(candidate,ShopDate,param,item,accountName);
            //配列に入れ込む
            this.screenProvisionalQuoteRecord = screenProvisionalQuote;
        }
    }

    /**
     * 取得したデータを一覧にセットする。　（仮見積のデータから）
     * 引数　　：  ProvisionalQuote ProvisionalQuote__c 仮見積
     * 　　    ：  ShopDate Shop__c 店舗
     * 　　    ：  item itemdate 商品（火災、保証、付帯のデータ）
     * 戻り値  ：  
     */
    private void setProvisionalQuote(ProvisionalQuote__c ProvisionalQuote,Shop__c ShopDate,itemdate item){
        //出力用に合わせて変換する。
        screenProvisionalQuote screenProvisionalQuote = new screenProvisionalQuote(ProvisionalQuote,ShopDate,item);
        //配列に入れ込む
        this.screenProvisionalQuoteRecord = screenProvisionalQuote;

        // 出力件数のカウントアップ
        if(this.screenProvisionalQuoteRecord.RentFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.ManagementFeeFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.TownMembershipFeeFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.WaterBillFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.CATVFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.GarbageDisposalCostsFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.BicycleparkingFeeFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.ParkingFeeFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.ParkingDepositFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.BikeStorageSeeDmallFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.BikeStorageFeeMediumSizeFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.BikeStorageFeeLargeFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.SecurityDepositFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.DepositFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.KeyMoneyFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.FixedrateRepairExpensesFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.EntranceFeeFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.KeyExchangeCostsFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.BrokerageFeeFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.FireInsurancePremiumsFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.FirstWarrantyFlg){this.outputPrintCount += 1;}                 // 初回保証料の行カウント
        if(this.screenProvisionalQuoteRecord.MonthlyFeeDepositFlg){this.outputPrintCount += 1;}             // 保証料の行カウント
        if(this.screenProvisionalQuoteRecord.AmountGoodsSpecifiedManagementCompanyFlg){this.outputPrintCount += 1;}
        if(this.screenProvisionalQuoteRecord.ParkingBrokerageFeeFlg){outputPrintCount += 1;}
        //▼問合せNo0496で追加        
        if(string.isNotEmpty(this.screenProvisionalQuoteRecord.FreeItemFeeDeposit1)){this.outputPrintCount += 1;}   // 自由項目1
        if(string.isNotEmpty(this.screenProvisionalQuoteRecord.FreeItemFeeDeposit2)){this.outputPrintCount += 1;}   // 自由項目2
        if(string.isNotEmpty(this.screenProvisionalQuoteRecord.FreeItemFeeDeposit3)){this.outputPrintCount += 1;}   // 自由項目3
        if(string.isNotEmpty(this.screenProvisionalQuoteRecord.FreeItemFeeDeposit4)){this.outputPrintCount += 1;}   // 自由項目4
        if(string.isNotEmpty(this.screenProvisionalQuoteRecord.FreeItemFeeDeposit5)){this.outputPrintCount += 1;}   // 自由項目5
        //▲問合せNo0496で追加

        // 初回以降
        if(this.screenProvisionalQuoteRecord.NextRentFeeFlg){this.outputPrintAfterFirstCount += 1;}  //家賃（初回以降）_表示フラグ
        if(this.screenProvisionalQuoteRecord.NextManagementFeeFlg ){this.outputPrintAfterFirstCount += 1;}  //管理費（初回以降）_表示フラグ
        if(this.screenProvisionalQuoteRecord.NextParkingFeeFlg  ){this.outputPrintAfterFirstCount += 1;}  //駐車場代（初回以降）_表示フラグ
        if(this.screenProvisionalQuoteRecord.NextWaterFeeFlg ){this.outputPrintAfterFirstCount += 1;}  //水道代（初回以降）_表示フラグ
        if(this.screenProvisionalQuoteRecord.NextTownshipFeeFlg ){this.outputPrintAfterFirstCount += 1;}  //町会費（初回以降）_表示フラグ
        if(this.screenProvisionalQuoteRecord.NextCatvFeeFlg ){this.outputPrintAfterFirstCount += 1;} //CATV（初回以降）_表示フラグ
        if(this.screenProvisionalQuoteRecord.NextGarbageDisposalFeeFlg ){this.outputPrintAfterFirstCount += 1;}  //ゴミ処理費（初回以降）_表示フラグ
        if(this.screenProvisionalQuoteRecord.NextBicycleParkingFeeFlg ){this.outputPrintAfterFirstCount += 1;}  //駐輪場代（初回以降）_表示フラグ
        if(this.screenProvisionalQuoteRecord.NextBikeStorageSmallFeeFlg ){this.outputPrintAfterFirstCount += 1;}  //バイク置き場代（小型）（初回以降）_表示フラグ
        if(this.screenProvisionalQuoteRecord.NextBikeStorageMediumFeeFlg ){this.outputPrintAfterFirstCount += 1;}  //バイク置き場代（中型）（初回以降）_表示フラグ
        if(this.screenProvisionalQuoteRecord.NextBikeStorageLargeFeeFlg ){this.outputPrintAfterFirstCount += 1;}  //バイク置き場代（大型）（初回以降）_表示フラグ
        if(this.screenProvisionalQuoteRecord.NextFireInsuranceFeeFlg ){this.outputPrintAfterFirstCount += 1;} //保険料（火災）（初回以降）_表示フラグ
        if(this.screenProvisionalQuoteRecord.NextFeeDepositFlg ){this.outputPrintAfterFirstCount += 1;} //保証料（初回以降）_表示フラグ
        //▼問合せNo0496で追加
        if(string.isNotEmpty(this.screenProvisionalQuoteRecord.NextFreeItemFeeDeposit1)){this.outputPrintAfterFirstCount += 1;}   // 自由項目1（初回以降）
        if(string.isNotEmpty(this.screenProvisionalQuoteRecord.NextFreeItemFeeDeposit2)){this.outputPrintAfterFirstCount += 1;}   // 自由項目2（初回以降）
        if(string.isNotEmpty(this.screenProvisionalQuoteRecord.NextFreeItemFeeDeposit3)){this.outputPrintAfterFirstCount += 1;}   // 自由項目3（初回以降）
        if(string.isNotEmpty(this.screenProvisionalQuoteRecord.NextFreeItemFeeDeposit4)){this.outputPrintAfterFirstCount += 1;}   // 自由項目4（初回以降）
        if(string.isNotEmpty(this.screenProvisionalQuoteRecord.NextFreeItemFeeDeposit5)){this.outputPrintAfterFirstCount += 1;}   // 自由項目5（初回以降）
        //▲問合せNo0496で追加

        //▼問合せNo0496で追加
        // 登録内容によってチェックボックスを設定する。
        this.selectFreeItemFeePaymentType1List.setCheckValue(this.screenProvisionalQuoteRecord.FreeItemFeePaymentType1);   // 項目1支払区分
        this.selectFreeItemFeePaymentType2List.setCheckValue(this.screenProvisionalQuoteRecord.FreeItemFeePaymentType2);   // 項目2支払区分
        this.selectFreeItemFeePaymentType3List.setCheckValue(this.screenProvisionalQuoteRecord.FreeItemFeePaymentType3);   // 項目3支払区分
        this.selectFreeItemFeePaymentType4List.setCheckValue(this.screenProvisionalQuoteRecord.FreeItemFeePaymentType4);   // 項目4支払区分
        this.selectFreeItemFeePaymentType5List.setCheckValue(this.screenProvisionalQuoteRecord.FreeItemFeePaymentType5);   // 項目5支払区分
        this.selectFreeItemFeeTaxType1List.setCheckValue(this.screenProvisionalQuoteRecord.FreeItemFeeTaxType1);            // 項目1税区分
        this.selectFreeItemFeeTaxType2List.setCheckValue(this.screenProvisionalQuoteRecord.FreeItemFeeTaxType2);            // 項目2税区分
        this.selectFreeItemFeeTaxType3List.setCheckValue(this.screenProvisionalQuoteRecord.FreeItemFeeTaxType3);            // 項目3税区分
        this.selectFreeItemFeeTaxType4List.setCheckValue(this.screenProvisionalQuoteRecord.FreeItemFeeTaxType4);            // 項目4税区分
        this.selectFreeItemFeeTaxType5List.setCheckValue(this.screenProvisionalQuoteRecord.FreeItemFeeTaxType5);            // 項目5税区分
        this.selectNextFreeItemFeeTaxType1List.setCheckValue(this.screenProvisionalQuoteRecord.NextFreeItemFeeTaxType1);   // 項目1税区分（初回以降）
        this.selectNextFreeItemFeeTaxType2List.setCheckValue(this.screenProvisionalQuoteRecord.NextFreeItemFeeTaxType2);   // 項目2税区分（初回以降）
        this.selectNextFreeItemFeeTaxType3List.setCheckValue(this.screenProvisionalQuoteRecord.NextFreeItemFeeTaxType3);   // 項目3税区分（初回以降）
        this.selectNextFreeItemFeeTaxType4List.setCheckValue(this.screenProvisionalQuoteRecord.NextFreeItemFeeTaxType4);   // 項目4税区分（初回以降）
        this.selectNextFreeItemFeeTaxType5List.setCheckValue(this.screenProvisionalQuoteRecord.NextFreeItemFeeTaxType5);   // 項目5税区分（初回以降）

        // byte数で改行位置を判断する
        this.screenProvisionalQuoteRecord.RentNextMonthTextPdf               = autoKaigyo(this.screenProvisionalQuoteRecord.RentNextMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);                //  PDF出力用家賃日割時月額項目
        this.screenProvisionalQuoteRecord.ManagementNextMonthTextPdf         = autoKaigyo(this.screenProvisionalQuoteRecord.ManagementNextMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);          //  PDF出力用管理費日割時月額項目
        this.screenProvisionalQuoteRecord.ParkingNextMonthTextPdf            = autoKaigyo(this.screenProvisionalQuoteRecord.ParkingNextMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);             //  PDF出力用駐車場代_契約次月テキスト
        this.screenProvisionalQuoteRecord.WaterNextMonthTextPdf              = autoKaigyo(this.screenProvisionalQuoteRecord.WaterNextMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);               //  PDF出力用水道代_契約次月テキスト
        this.screenProvisionalQuoteRecord.TownshipNextMonthTextPdf           = autoKaigyo(this.screenProvisionalQuoteRecord.TownshipNextMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);            //  PDF出力用町会費_契約次月テキスト
        this.screenProvisionalQuoteRecord.CatvNextMonthTextPdf               = autoKaigyo(this.screenProvisionalQuoteRecord.CatvNextMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);                //  PDF出力用CATV_契約次月テキスト
        this.screenProvisionalQuoteRecord.GarbageDisposalNextMonthTextPdf    = autoKaigyo(this.screenProvisionalQuoteRecord.GarbageDisposalNextMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);     //  PDF出力用ゴミ処理費_契約次月テキスト
        this.screenProvisionalQuoteRecord.BicycleParkingNextMonthTextPdf     = autoKaigyo(this.screenProvisionalQuoteRecord.BicycleParkingNextMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);      //  PDF出力用駐輪場代_契約次月テキスト
        this.screenProvisionalQuoteRecord.BikeStorageSmallNextMonthTextPdf   = autoKaigyo(this.screenProvisionalQuoteRecord.BikeStorageSmallNextMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);    //  PDF出力用バイク置き場代（小型）_契約次月テキスト
        this.screenProvisionalQuoteRecord.BikeStorageMediumNextMonthTextPdf  = autoKaigyo(this.screenProvisionalQuoteRecord.BikeStorageMediumNextMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);   //  PDF出力用バイク置き場代（中型）_契約次月テキスト
        this.screenProvisionalQuoteRecord.BikeStorageLargeNextMonthTextPdf   = autoKaigyo(this.screenProvisionalQuoteRecord.BikeStorageLargeNextMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);    //  PDF出力用バイク置き場代（大型）日割時月額項目
        this.screenProvisionalQuoteRecord.FireInsuranceNextMonthTextPdf      = autoKaigyo(this.screenProvisionalQuoteRecord.FireInsuranceNextMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);       //  PDF出力用保険料（火災）_契約次月テキスト
        this.screenProvisionalQuoteRecord.DepositNextMonthTextPdf            = autoKaigyo(this.screenProvisionalQuoteRecord.DepositNextMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);             //  PDF出力用月額保証料（初回）_契約次月テキスト        
        this.screenProvisionalQuoteRecord.FreeItemName1Pdf                   = autoKaigyo(this.screenProvisionalQuoteRecord.FreeItemName1Pdf,this.kaigyoByteFreeItemName,CommonConst.WORD_BREAK);        //  PDF出力用自由項目1名称
        this.screenProvisionalQuoteRecord.FreeItemName2Pdf                   = autoKaigyo(this.screenProvisionalQuoteRecord.FreeItemName2Pdf,this.kaigyoByteFreeItemName,CommonConst.WORD_BREAK);        //  PDF出力用自由項目2名称
        this.screenProvisionalQuoteRecord.FreeItemName3Pdf                   = autoKaigyo(this.screenProvisionalQuoteRecord.FreeItemName3Pdf,this.kaigyoByteFreeItemName,CommonConst.WORD_BREAK);        //  PDF出力用自由項目3名称
        this.screenProvisionalQuoteRecord.FreeItemName4Pdf                   = autoKaigyo(this.screenProvisionalQuoteRecord.FreeItemName4Pdf,this.kaigyoByteFreeItemName,CommonConst.WORD_BREAK);        //  PDF出力用自由項目4名称
        this.screenProvisionalQuoteRecord.FreeItemName5Pdf                   = autoKaigyo(this.screenProvisionalQuoteRecord.FreeItemName5Pdf,this.kaigyoByteFreeItemName,CommonConst.WORD_BREAK);        //  PDF出力用自由項目5名称
        this.screenProvisionalQuoteRecord.NextFreeItemName1Pdf               = autoKaigyo(this.screenProvisionalQuoteRecord.NextFreeItemName1Pdf,this.kaigyoByteFreeItemName,CommonConst.WORD_BREAK);    //  PDF出力用自由項目1名称（初回以降）
        this.screenProvisionalQuoteRecord.NextFreeItemName2Pdf               = autoKaigyo(this.screenProvisionalQuoteRecord.NextFreeItemName2Pdf,this.kaigyoByteFreeItemName,CommonConst.WORD_BREAK);    //  PDF出力用自由項目2名称（初回以降）
        this.screenProvisionalQuoteRecord.NextFreeItemName3Pdf               = autoKaigyo(this.screenProvisionalQuoteRecord.NextFreeItemName3Pdf,this.kaigyoByteFreeItemName,CommonConst.WORD_BREAK);    //  PDF出力用自由項目3名称（初回以降）
        this.screenProvisionalQuoteRecord.NextFreeItemName4Pdf               = autoKaigyo(this.screenProvisionalQuoteRecord.NextFreeItemName4Pdf,this.kaigyoByteFreeItemName,CommonConst.WORD_BREAK);    //  PDF出力用自由項目4名称（初回以降）
        this.screenProvisionalQuoteRecord.NextFreeItemName5Pdf               = autoKaigyo(this.screenProvisionalQuoteRecord.NextFreeItemName5Pdf,this.kaigyoByteFreeItemName,CommonConst.WORD_BREAK);    //  PDF出力用自由項目5名称（初回以降）
        //▲問合せNo0496で追加
        // ▼問合せ556で追加
        this.screenProvisionalQuoteRecord.rentThisMonthTextPdf               = autoKaigyo(this.screenProvisionalQuoteRecord.rentThisMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);                //  PDF出力用家賃日割時月額項目
        this.screenProvisionalQuoteRecord.managementThisMonthTextPdf         = autoKaigyo(this.screenProvisionalQuoteRecord.managementThisMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);          //  PDF出力用管理費日割時月額項目
        this.screenProvisionalQuoteRecord.parkingThisMonthTextPdf            = autoKaigyo(this.screenProvisionalQuoteRecord.parkingThisMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);             //  PDF出力用駐車場代_契約次月テキスト
        this.screenProvisionalQuoteRecord.waterThisMonthTextPdf              = autoKaigyo(this.screenProvisionalQuoteRecord.waterThisMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);               //  PDF出力用水道代_契約次月テキスト
        this.screenProvisionalQuoteRecord.townshipThisMonthTextPdf           = autoKaigyo(this.screenProvisionalQuoteRecord.townshipThisMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);            //  PDF出力用町会費_契約次月テキスト
        this.screenProvisionalQuoteRecord.catvThisMonthTextPdf               = autoKaigyo(this.screenProvisionalQuoteRecord.catvThisMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);                //  PDF出力用CATV_契約次月テキスト
        this.screenProvisionalQuoteRecord.garbageDisposalThisMonthTextPdf    = autoKaigyo(this.screenProvisionalQuoteRecord.garbageDisposalThisMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);     //  PDF出力用ゴミ処理費_契約次月テキスト
        this.screenProvisionalQuoteRecord.bicycleParkingThisMonthTextPdf     = autoKaigyo(this.screenProvisionalQuoteRecord.bicycleParkingThisMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);      //  PDF出力用駐輪場代_契約次月テキスト
        this.screenProvisionalQuoteRecord.bikeStorageSmallThisMonthTextPdf   = autoKaigyo(this.screenProvisionalQuoteRecord.bikeStorageSmallThisMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);    //  PDF出力用バイク置き場代（小型）_契約次月テキスト
        this.screenProvisionalQuoteRecord.bikeStorageMediumThisMonthTextPdf  = autoKaigyo(this.screenProvisionalQuoteRecord.bikeStorageMediumThisMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);   //  PDF出力用バイク置き場代（中型）_契約次月テキスト
        this.screenProvisionalQuoteRecord.bikeStorageLargeThisMonthTextPdf   = autoKaigyo(this.screenProvisionalQuoteRecord.bikeStorageLargeThisMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);    //  PDF出力用バイク置き場代（大型）日割時月額項目
        this.screenProvisionalQuoteRecord.fireInsuranceThisMonthTextPdf      = autoKaigyo(this.screenProvisionalQuoteRecord.fireInsuranceThisMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);       //  PDF出力用保険料（火災）_契約次月テキスト
        this.screenProvisionalQuoteRecord.depositThisMonthTextPdf            = autoKaigyo(this.screenProvisionalQuoteRecord.depositThisMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);             //  PDF出力用月額保証料（初回）_契約次月テキスト   
        
        this.screenProvisionalQuoteRecord.rentFullMonthTextPdf               = autoKaigyo(this.screenProvisionalQuoteRecord.rentFullMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);                //  PDF出力用家賃契約月テキスト(日割り無し)
        this.screenProvisionalQuoteRecord.managementFullMonthTextPdf         = autoKaigyo(this.screenProvisionalQuoteRecord.managementFullMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);          //  PDF出力用管理費契約月テキスト(日割り無し)
        this.screenProvisionalQuoteRecord.parkingFullMonthTextPdf            = autoKaigyo(this.screenProvisionalQuoteRecord.parkingFullMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);             //  PDF出力用駐車場代_契約月テキスト(日割り無し)
        this.screenProvisionalQuoteRecord.waterFullMonthTextPdf              = autoKaigyo(this.screenProvisionalQuoteRecord.waterFullMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);               //  PDF出力用水道代_契約月テキスト(日割り無し)
        this.screenProvisionalQuoteRecord.townshipFullMonthTextPdf           = autoKaigyo(this.screenProvisionalQuoteRecord.townshipFullMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);            //  PDF出力用町会費_契約月テキスト(日割り無し)
        this.screenProvisionalQuoteRecord.catvFullMonthTextPdf               = autoKaigyo(this.screenProvisionalQuoteRecord.catvFullMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);                //  PDF出力用CATV_契約月テキスト(日割り無し)
        this.screenProvisionalQuoteRecord.garbageDisposalFullMonthTextPdf    = autoKaigyo(this.screenProvisionalQuoteRecord.garbageDisposalFullMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);     //  PDF出力用ゴミ処理費_契約月テキスト(日割り無し)
        this.screenProvisionalQuoteRecord.bicycleParkingFullMonthTextPdf     = autoKaigyo(this.screenProvisionalQuoteRecord.bicycleParkingFullMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);      //  PDF出力用駐輪場代_契約月テキスト(日割り無し)
        this.screenProvisionalQuoteRecord.bikeStorageSmallFullMonthTextPdf   = autoKaigyo(this.screenProvisionalQuoteRecord.bikeStorageSmallFullMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);    //  PDF出力用バイク置き場代（小型）_契約月テキスト(日割り無し)
        this.screenProvisionalQuoteRecord.bikeStorageMediumFullMonthTextPdf  = autoKaigyo(this.screenProvisionalQuoteRecord.bikeStorageMediumFullMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);   //  PDF出力用バイク置き場代（中型）_契約月テキスト(日割り無し)
        this.screenProvisionalQuoteRecord.bikeStorageLargeFullMonthTextPdf   = autoKaigyo(this.screenProvisionalQuoteRecord.bikeStorageLargeFullMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);    //  PDF出力用バイク置き場代（大型）契約月テキスト(日割り無し)
        this.screenProvisionalQuoteRecord.fireInsuranceFullMonthTextPdf      = autoKaigyo(this.screenProvisionalQuoteRecord.fireInsuranceFullMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);       //  PDF出力用保険料（火災）_契約月テキスト(日割り無し)
        this.screenProvisionalQuoteRecord.depositFullMonthTextPdf            = autoKaigyo(this.screenProvisionalQuoteRecord.depositFullMonthTextPdf,this.kaigyoByte,CommonConst.BREAK_TAG);             //  PDF出力用月額保証料（初回）_契約月テキスト(日割り無し)
        // ▲問合せ556で追加

    }

    /**
     * 取得したデータを一覧にセットする。（付帯管理会社）　
     * 引数　　：  PropertyManageCompayItemList List<PropertyManageCompayItem__c> 物件管理会社指定
     * 　　    ：  param parameter 元画面のパラメータ
     * 　　    ：  ProvisionalQuoteManageCompayItemList List<ProvisionalQuoteManageCompayItem__c> 仮見積指定商品
     * 戻り値  ：  
     */
    private void setProvisionalQuoteManageCompayItem(List<PropertyManageCompayItem__c> PropertyManageCompayItemList,parameter param,List<ProvisionalQuoteManageCompayItem__c> ProvisionalQuoteManageCompayItemList){
        this.screenProvisionalQuoteManageCompayItemList = new List<screeenProvisionalQuoteManageCompayItem>(); // 仮見積管理会社指定
        this.screenProvisionalQuoteManageCompayItemFirstList = new List<screeenProvisionalQuoteManageCompayItem>(); // 仮見積管理会社指定_初回
        this.screenProvisionalQuoteManageCompayItemMonthList = new List<screeenProvisionalQuoteManageCompayItem>(); // 仮見積管理会社指定_月額
        this.screenProvisionalQuoteManageCompayItemYearList  = new List<screeenProvisionalQuoteManageCompayItem>(); // 仮見積管理会社指定_年額

        //内部クラスに値をセットする。
        for(PropertyManageCompayItem__c candidate :PropertyManageCompayItemList) {

            // 既に登録されている仮見積指定商品の管理会社指定商品は更新のためIDを紐づかせる。
            string ProvisionalQuoteManageCompayItemId = CommonConst.STRING_EMPTY;
            Datetime ProvisionalQuoteManageCompayItemDate;
            for(ProvisionalQuoteManageCompayItem__c ProvisionalQuoteManageCompayItem :ProvisionalQuoteManageCompayItemList){
                if(candidate.Item__c == ProvisionalQuoteManageCompayItem.ManagementCompanyItem__c){
                    ProvisionalQuoteManageCompayItemId = ProvisionalQuoteManageCompayItem.id;
                    ProvisionalQuoteManageCompayItemDate = ProvisionalQuoteManageCompayItem.systemmodstamp;
                }
            }

            //出力用に合わせて変換する。
            screeenProvisionalQuoteManageCompayItem screenProvisionalQuoteManageCompayItem = new screeenProvisionalQuoteManageCompayItem(candidate,param,ProvisionalQuoteManageCompayItemId,ProvisionalQuoteManageCompayItemDate);
            //配列に入れ込む
            this.screenProvisionalQuoteManageCompayItemList.add(screenProvisionalQuoteManageCompayItem);

            //支払区分によってそれぞれの配列に入れ込む
            if(screenProvisionalQuoteManageCompayItem.IssueDate == MANAGEMENTCOMPANYITEM_PAYMENTTYPE_FIRST){
                // 初回
                this.screenProvisionalQuoteManageCompayItemFirstList.add(screenProvisionalQuoteManageCompayItem);
            }else if(screenProvisionalQuoteManageCompayItem.IssueDate == MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH){
                // 月額
                this.screenProvisionalQuoteManageCompayItemMonthList.add(screenProvisionalQuoteManageCompayItem);
            }else if(screenProvisionalQuoteManageCompayItem.IssueDate == MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR){
                // 年額
                this.screenProvisionalQuoteManageCompayItemYearList.add(screenProvisionalQuoteManageCompayItem);
            }
            
        }  
    }

    /**
     * 取得したデータを一覧にセットする。（仮見積指定商品）　
     * 引数　　：  PropertyManageCompayItemList List<ProvisionalQuoteManageCompayItem__c> 仮見積指定商品
     * 戻り値  ：   
     */
    private void setProvisionalQuoteManageCompayItem(List<ProvisionalQuoteManageCompayItem__c> ProvisionalQuoteManageCompayItemList){
        this.screenProvisionalQuoteManageCompayItemList = new List<screeenProvisionalQuoteManageCompayItem>(); // 仮見積管理会社指定
        this.screenProvisionalQuoteManageCompayItemFirstList = new List<screeenProvisionalQuoteManageCompayItem>(); // 仮見積管理会社指定_初回
        this.screenProvisionalQuoteManageCompayItemMonthList = new List<screeenProvisionalQuoteManageCompayItem>(); // 仮見積管理会社指定_月額
        this.screenProvisionalQuoteManageCompayItemYearList  = new List<screeenProvisionalQuoteManageCompayItem>(); // 仮見積管理会社指定_年額
        //内部クラスに値をセットする。
        for(ProvisionalQuoteManageCompayItem__c candidate :ProvisionalQuoteManageCompayItemList) {
            //出力用に合わせて変換する。
            screeenProvisionalQuoteManageCompayItem screenProvisionalQuoteManageCompayItem = new screeenProvisionalQuoteManageCompayItem(candidate);

            if(screenProvisionalQuoteManageCompayItem.displayFlg){
                // 出力件数のカウントアップ
                this.outputPrintCount += 1;
            }
            // 初回以降の仮見積指定商品のカウント
            if (screenProvisionalQuoteManageCompayItem.nextDisplayFlg){
                this.outputPrintAfterFirstCount += 1;
            }

            //配列に入れ込む
            this.screenProvisionalQuoteManageCompayItemList.add(screenProvisionalQuoteManageCompayItem);

            //支払区分によってそれぞれの配列に入れ込む
            if(screenProvisionalQuoteManageCompayItem.IssueDate == MANAGEMENTCOMPANYITEM_PAYMENTTYPE_FIRST){
                // 初回
                this.screenProvisionalQuoteManageCompayItemFirstList.add(screenProvisionalQuoteManageCompayItem);
            }else if(screenProvisionalQuoteManageCompayItem.IssueDate == MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH){
                // 月額
                this.screenProvisionalQuoteManageCompayItemMonthList.add(screenProvisionalQuoteManageCompayItem);
            }else if(screenProvisionalQuoteManageCompayItem.IssueDate == MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR){
                // 年額
                this.screenProvisionalQuoteManageCompayItemYearList.add(screenProvisionalQuoteManageCompayItem);
            }
        }  
    }

    /**
     * 各商品の必要な項目を入れる
     * 引数　　：  param parameter 前画面からのパラメータ
     * 戻り値　：  itemDate 商品の必要な項目
     */
    private itemDate getItem(parameter param){
        itemDate item = new itemdate();
        List<Item__c> itemRecord = new List<item__c>();
        List<ItemDetail__c> itemDetailRecord = new List<ItemDetail__c>();


        // 保証料
        itemDetailRecord = ItemDetailSetting(param.auxiliaryDepositPlan);
        if(itemDetailRecord.size() > 0){
            item.DepositPlan = itemDetailRecord[0].Item__r.ItemName__c;
            item.DepositPlanAmount = itemDetailRecord[0].FirstFeeDepositYen__c;
            item.FirstFeeDepositYen = itemDetailRecord[0].FirstFeeDepositYen__c;
            item.IsRentFeeType = itemDetailRecord[0].IsRentFeeType__c;  // 賃料区分
            item.FirstFeeDepositRate = itemDetailRecord[0].FirstFeeDepositRate__c;       // 初回保証料(割合)
            item.DepositRate = itemDetailRecord[0].DepositRate__c;               // 保証料(割合)
            item.DepositYen = itemDetailRecord[0].DepositYen__c;             // 保証料(金額)
            item.IsAllRentFeeType = itemDetailRecord[0].Item__r.Account__r.IsAllRentFeeType__c;   //総賃料区分
            Item.DirectDebitFeeTaxType = itemDetailRecord[0].Item__r.DirectDebitFeeTaxType__c; // 手数料税区分
            item.DirectDebitFee = itemDetailRecord[0].Item__r.DirectDebitFee__c; // 手数料
            item.DirectDebitFeeTax = itemDetailRecord[0].Item__r.DirectDebitFeeTax__c; // 手数料税込み

        }

        // 火災保険
        itemRecord = new List<item__c>();
        itemRecord = ItemSetting(param.auxiliaryFireInsurance);
        if(itemRecord.size() > 0){
            item.FireInsurance = itemRecord[0].PaymentType__c;
            if(itemRecord[0].PaymentType__c == CommonConst.ITEM_PAYMENTTYPE_MONTH){
                // 月
                item.FireInsuranceAmount = itemRecord[0].FireInsuranceMonth__c;
            }else {
                // 年
                item.FireInsuranceAmount = itemRecord[0].FireInsuranceYear__c;
            }
        }

        return item;
        
    }

    /**
     * 仮見積から各商品の必要な項目を入れる
     * 引数　　：  param parameter 前画面からのパラメータ
     * 戻り値　：  itemDate 商品の必要な項目
     */
    private itemDate getItemProvisionalQuote(ProvisionalQuote__c ProvisionalQuote){
        itemDate item = new itemdate();
        List<Item__c> itemRecord = new List<item__c>();
        List<ItemDetail__c> itemDetailRecord = new List<ItemDetail__c>();


        // 保証料
        itemDetailRecord = ItemDetailSetting(ProvisionalQuote.DepositItem__c);
        if(itemDetailRecord.size() > 0){
            item.DepositPlan = itemDetailRecord[0].Item__r.ItemName__c;
            item.DepositPlanAmount = itemDetailRecord[0].FirstFeeDepositYen__c;
            parameter.auxiliaryDepositPlan = ProvisionalQuote.DepositItem__c;
        }

        // 火災保険
        itemRecord = new List<item__c>();
        itemRecord = ItemSetting(ProvisionalQuote.FireInsuranceItem__c);
        if(itemRecord.size() > 0){
            item.FireInsurance = itemRecord[0].PaymentType__c;
            if(itemRecord[0].PaymentType__c == CommonConst.ITEM_PAYMENTTYPE_MONTH){
                // 月
                item.FireInsuranceAmount = itemRecord[0].FireInsuranceMonth__c;
            }else {
                // 年
                item.FireInsuranceAmount = itemRecord[0].FireInsuranceYear__c;
            }
            parameter.auxiliaryFireInsurance = ProvisionalQuote.FireInsuranceItem__c;
        }

        return item;
        
    }

    /**
     * 仮見積の保存
     * 引数　　：  ProvisionalQuote screenProvisionalQuote 更新時の仮見積データ
     * 戻り値　：  String 仮見積のID
     */
    private string saveProvisionalQuote(screenProvisionalQuote ProvisionalQuote){
        // 保存処理
        ProvisionalQuote__c saveDate = new ProvisionalQuote__c();
        if( saveFlg){
            // 更新
            saveDate.id = ProvisionalQuote.Id;
            // 仮見積書出力でデータを更新させた場合入力項目を書き換える。
            if(!this.parameter.SavedOutputFlag){ 
                saveDate.Account__c = parameter.accountId;   // 取引先
                saveDate.Property__c = parameter.propertyId;   // 物件
                saveDate.ContractStartDate__c = parameter.HomeMovingDate;   // 契約開始日
                saveDate.IsProrated__c = parameter.Proratedflag;   // 日割り計算
                saveDate.ProratedMonthDays__c = parameter.ProratedCalculationDay;   // 日割り計算月日数
                saveDate.IsParkingUse__c = parameter.Parkingflag;   // 駐車場利用
                saveDate.ParkingRequiredNumber__c = parameter.ParkingNumberRequired;   // 駐車場必要数
                saveDate.ParkingRequiredNumberFee__c = parameter.ParkingFee;   // 駐車場金額
                saveDate.IsBicycleParkingUse__c = parameter.BicycleParkingFlag;   // 駐輪場利用
                saveDate.BicycleParkingRequiredNumber__c = parameter.BicycleParkingNumberRequired;   // 駐輪場必要数
                saveDate.BicycleParkingRequiredNumberFee__c = parameter.BicycleParkingFee;   // 駐輪場金額
                saveDate.IsBikeStorageSmallUse__c = parameter.BikeParkingSmallFlag;   // バイク置き場（小型）利用
                saveDate.BikeStorageSmallRequiredNumber__c = parameter.BikeParkingSmallNumberRequired;   // バイク置き場（小型）必要数
                saveDate.BikeStorageSmallRequiredNumberFee__c = parameter.BikeParkingSmallFee;   // バイク置き場（小型）金額
                saveDate.IsBikeStorageMediumUse__c = parameter.BikeParkingMediumFlag;   // バイク置き場（中型）利用
                saveDate.BikeStorageMediumRequiredNumber__c = parameter.BikeParkingMediumNumberRequired;   // バイク置き場（中型）必要数
                saveDate.BikeStorageMediumRequiredNumberFee__c = parameter.BikeParkingMediumFee;   // バイク置き場（中型）金額
                saveDate.IsBikeStorageLargeUse__c= parameter.BikeParkinLargeFlag;   // バイク置き場（大型）利用
                saveDate.BikeStorageLargeRequiredNumber__c = parameter.BikeParkinLargeNumberRequired;   // バイク置き場（大型）必要数
                saveDate.BikeStorageLargeRequiredNumberFee__c = parameter.BikeParkinLargeFee;   // バイク置き場（大型）金額

                if(!string.isBlank(parameter.RenewalFeeShow) && parameter.RenewalFeeShow != 'null'){
                    saveDate.RenewalFeeShow__c = parameter.RenewalFeeShow;   // 更新料表記     
                }else{
                    saveDate.RenewalFeeShow__c = null;
                }
            }
            
        }else{
            // 新規     
            saveDate.Account__c = parameter.accountId;   // 取引先
            saveDate.Property__c = parameter.propertyId;   // 物件
            saveDate.ContractStartDate__c = parameter.HomeMovingDate;   // 契約開始日
            saveDate.IsProrated__c = parameter.Proratedflag;   // 日割り計算
            saveDate.ProratedMonthDays__c = parameter.ProratedCalculationDay;   // 日割り計算月日数
            saveDate.IsParkingUse__c = parameter.Parkingflag;   // 駐車場利用
            saveDate.ParkingRequiredNumber__c = parameter.ParkingNumberRequired;   // 駐車場必要数
            saveDate.ParkingRequiredNumberFee__c = parameter.ParkingFee;   // 駐車場金額
            saveDate.IsBicycleParkingUse__c = parameter.BicycleParkingFlag;   // 駐輪場利用
            saveDate.BicycleParkingRequiredNumber__c = parameter.BicycleParkingNumberRequired;   // 駐輪場必要数
            saveDate.BicycleParkingRequiredNumberFee__c = parameter.BicycleParkingFee;   // 駐輪場金額
            saveDate.IsBikeStorageSmallUse__c = parameter.BikeParkingSmallFlag;   // バイク置き場（小型）利用
            saveDate.BikeStorageSmallRequiredNumber__c = parameter.BikeParkingSmallNumberRequired;   // バイク置き場（小型）必要数
            saveDate.BikeStorageSmallRequiredNumberFee__c = parameter.BikeParkingSmallFee;   // バイク置き場（小型）金額
            saveDate.IsBikeStorageMediumUse__c = parameter.BikeParkingMediumFlag;   // バイク置き場（中型）利用
            saveDate.BikeStorageMediumRequiredNumber__c = parameter.BikeParkingMediumNumberRequired;   // バイク置き場（中型）必要数
            saveDate.BikeStorageMediumRequiredNumberFee__c = parameter.BikeParkingMediumFee;   // バイク置き場（中型）金額
            saveDate.IsBikeStorageLargeUse__c= parameter.BikeParkinLargeFlag;   // バイク置き場（大型）利用
            saveDate.BikeStorageLargeRequiredNumber__c = parameter.BikeParkinLargeNumberRequired;   // バイク置き場（大型）必要数
            saveDate.BikeStorageLargeRequiredNumberFee__c = parameter.BikeParkinLargeFee;   // バイク置き場（大型）金額

            if(!string.isBlank(parameter.RenewalFeeShow) && parameter.RenewalFeeShow != 'null'){
                saveDate.RenewalFeeShow__c = parameter.RenewalFeeShow;   // 更新料表記     
            }else{
                saveDate.RenewalFeeShow__c = null;
            }
            
        }


        if(!String.isBlank(parameter.auxiliaryDepositPlan) && parameter.auxiliaryDepositPlan != 'null' ){
            saveDate.DepositItem__c = parameter.auxiliaryDepositPlan;   // 保証プラン
        }else {
            saveDate.DepositItem__c = null; 
        }

        if(!String.isBlank(parameter.auxiliaryFireInsurance) && parameter.auxiliaryFireInsurance != 'null' ){
            saveDate.FireInsuranceItem__c = parameter.auxiliaryFireInsurance;   // 火災保険
        }else {
            saveDate.FireInsuranceItem__c = null; 
        }
        saveDate.CleaningFeeShow__c = ProvisionalQuote.CleaningFeeShow;   // 定額修繕費表記

        saveDate.RentProratedFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.DailyRent);   // 家賃日割額
        saveDate.RentFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.Rent);   // 家賃
        saveDate.ManagementProratedFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.ManagementProratedFee);   // 管理費日割額
        saveDate.ManagementFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.ManagementFee);   // 管理費
        saveDate.TownshipProratedFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.DailyAmountTownMembershipFee);   // 町会費日割額
        saveDate.TownshipFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.TownMembershipFee);   // 町会費
        saveDate.WaterProratedFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.DailyWaterBill);   // 水道代日割額
        saveDate.WaterFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.WaterBill);   // 水道代
        saveDate.CatvProratedFee__c =CommonUtil.stringToDecimal( ProvisionalQuote.CATVDaily);   // CATV日割額
        saveDate.CatvFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.CATV);   // CATV
        saveDate.GarbageDisposalProratedFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.DailyGarbageDisposalExpenses);   // ゴミ処理費日割額
        saveDate.GarbageDisposalFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.GarbageDisposalCosts);   // ゴミ処理費
        saveDate.BicycleParkingProratedFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.DailyBicycleParkingFee);   // 駐輪場代日割額
        saveDate.BicycleParkingFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.BicycleparkingFee);   // 駐輪場代
        saveDate.ParkingProratedFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.DailyDiscountParkingLot);   // 駐車場代日割額
        saveDate.ParkingFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.ParkingFee);   // 駐車場代
        saveDate.ParkingDeposit__c = CommonUtil.stringToDecimal(ProvisionalQuote.ParkingDeposit);   // 駐車場保証金
        saveDate.BikeStorageSmallProratedFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.BikeStorageFeeSmallDailyDiscount);   // バイク置き場代（小型）日割額
        saveDate.BikeStorageSmallFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.BikeStorageSeeDmall);   // バイク置き場代（小型）
        saveDate.BikeStorageMediumProratedFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.BikeStorageFeeMediumDaily);   // バイク置き場代（中型）日割額
        saveDate.BikeStorageMediumFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.BikeStorageFeeMediumSize);   // バイク置き場代（中型）
        saveDate.BikeStorageLargeProratedFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.BikeStorageFeeLargeDailyDiscount);   // バイク置き場代（大型）日割額
        saveDate.BikeStorageLargeFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.BikeStorageFeeLarge);   // バイク置き場代（大型）
        //▼問合せNo0496で追加
        saveDate.RentNextMonthText__c               = ProvisionalQuote.RentNextMonthText;               //家賃_契約次月テキスト
        saveDate.ManagementNextMonthText__c         = ProvisionalQuote.ManagementNextMonthText;         //管理費_契約次月テキスト
        saveDate.ParkingNextMonthText__c            = ProvisionalQuote.ParkingNextMonthText;            //駐車場代_契約次月テキスト
        saveDate.WaterNextMonthText__c              = ProvisionalQuote.WaterNextMonthText;              //水道代_契約次月テキスト
        saveDate.TownshipNextMonthText__c           = ProvisionalQuote.TownshipNextMonthText;           //町会費_契約次月テキスト
        saveDate.CatvNextMonthText__c               = ProvisionalQuote.CatvNextMonthText;               //CATV_契約次月テキスト
        saveDate.GarbageDisposalNextMonthText__c    = ProvisionalQuote.GarbageDisposalNextMonthText;    //ゴミ処理費_契約次月テキスト
        saveDate.BicycleParkingNextMonthText__c     = ProvisionalQuote.BicycleParkingNextMonthText;     //駐輪場代_契約次月テキスト
        saveDate.BikeStorageSmallNextMonthText__c   = ProvisionalQuote.BikeStorageSmallNextMonthText;   //バイク置き場代（小型）_契約次月テキスト
        saveDate.BikeStorageMediumNextMonthText__c  = ProvisionalQuote.BikeStorageMediumNextMonthText;  //バイク置き場代（中型）_契約次月テキスト
        saveDate.BikeStorageLargeNextMonthText__c   = ProvisionalQuote.BikeStorageLargeNextMonthText;   //バイク置き場代（大型）_契約次月テキスト
        saveDate.FireInsuranceNextMonthText__c      = ProvisionalQuote.FireInsuranceNextMonthText;      //保険料（火災）_契約次月テキスト
        saveDate.DepositNextMonthText__c            = ProvisionalQuote.DepositNextMonthText;            //月額保証料（初回）_契約次月テキスト
        //▲問合せNo0496で追加

        // ▼問合せ556で追加
        saveDate.rentThisMonthText__c               = ProvisionalQuote.rentThisMonthText;                          // 家賃_契約当月テキスト
        saveDate.managementThisMonthText__c         = ProvisionalQuote.managementThisMonthText;              // 管理費_契約当月テキスト
        saveDate.townshipThisMonthText__c           = ProvisionalQuote.townshipThisMonthText;                  // 町会費_契約当月テキスト
        saveDate.waterThisMonthText__c              = ProvisionalQuote.waterThisMonthText;                        // 水道代_契約当月テキスト
        saveDate.catvThisMonthText__c               = ProvisionalQuote.catvThisMonthText;                          // CATV_契約当月テキスト
        saveDate.garbageDisposalThisMonthText__c    = ProvisionalQuote.garbageDisposalThisMonthText;    // ゴミ処理費_契約当月テキスト
        saveDate.bicycleParkingThisMonthText__c     = ProvisionalQuote.bicycleParkingThisMonthText;      // 駐輪場代_契約当月テキスト
        saveDate.parkingThisMonthText__c            = ProvisionalQuote.parkingThisMonthText;                    // 駐車場代_契約当月テキスト
        saveDate.bikeStorageSmallThisMonthText__c   = ProvisionalQuote.bikeStorageSmallThisMonthText;  // バイク置き場代（小型）_契約当月テキスト
        saveDate.bikeStorageMediumThisMonthText__c  = ProvisionalQuote.bikeStorageMediumThisMonthText;// バイク置き場代（中型）_契約当月テキスト
        saveDate.bikeStorageLargeThisMonthText__c   = ProvisionalQuote.bikeStorageLargeThisMonthText;  // バイク置き場代（大型）_契約当月テキスト
        saveDate.depositThisMonthText__c            = ProvisionalQuote.depositThisMonthText;                    // 月額保証料（初回）_契約当月テキスト
        saveDate.fireInsuranceThisMonthText__c      = ProvisionalQuote.fireInsuranceThisMonthText;        // 保険料（火災）_契約当月テキスト

        saveDate.rentFullMonthText__c               = ProvisionalQuote.rentFullMonthText;                          // 家賃_契約月テキスト(日割り無し)
        saveDate.managementFullMonthText__c         = ProvisionalQuote.managementFullMonthText;              // 管理費_契約月テキスト(日割り無し)
        saveDate.townshipFullMonthText__c           = ProvisionalQuote.townshipFullMonthText;                  // 町会費_契約月テキスト(日割り無し)
        saveDate.waterFullMonthText__c              = ProvisionalQuote.waterFullMonthText;                        // 水道代_契約月テキスト(日割り無し)
        saveDate.catvFullMonthText__c               = ProvisionalQuote.catvFullMonthText;                          // CATV_契約月テキスト(日割り無し)
        saveDate.garbageDisposalFullMonthText__c    = ProvisionalQuote.garbageDisposalFullMonthText;    // ゴミ処理費_契約月テキスト(日割り無し)
        saveDate.bicycleParkingFullMonthText__c     = ProvisionalQuote.bicycleParkingFullMonthText;      // 駐輪場代_契約月テキスト(日割り無し)
        saveDate.parkingFullMonthText__c            = ProvisionalQuote.parkingFullMonthText;                    // 駐車場代_契約月テキスト(日割り無し)
        saveDate.bikeStorageSmallFullMonthText__c   = ProvisionalQuote.bikeStorageSmallFullMonthText;  // バイク置き場代（小型）_契約月テキスト(日割り無し)
        saveDate.bikeStorageMediumFullMonthText__c  = ProvisionalQuote.bikeStorageMediumFullMonthText;// バイク置き場代（中型）_契約月テキスト(日割り無し)
        saveDate.bikeStorageLargeFullMonthText__c   = ProvisionalQuote.bikeStorageLargeFullMonthText;  // バイク置き場代（大型）_契約月テキスト(日割り無し)
        saveDate.depositFullMonthText__c            = ProvisionalQuote.depositFullMonthText;                    // 月額保証料（初回）_契約月テキスト(日割り無し)
        saveDate.fireInsuranceFullMonthText__c      = ProvisionalQuote.fireInsuranceFullMonthText;        // 保険料（火災）_契約月テキスト(日割り無し)
        // ▲問合せ556で追加

        saveDate.SecurityDeposit__c = CommonUtil.stringToDecimal(ProvisionalQuote.SecurityDeposit);   // 敷金
        saveDate.Deposit__c = CommonUtil.stringToDecimal(ProvisionalQuote.Deposit);   // 保証金
        saveDate.KeyMoney__c = CommonUtil.stringToDecimal(ProvisionalQuote.KeyMoney);   // 礼金
        saveDate.CleaningFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.FixedrateRepairExpenses);   // 定額修繕費
        saveDate.TownshipInitialFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.EntranceFee);   // 入町費
        saveDate.KeyExchangeFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.KeyExchangeCosts);   // 鍵交換費
        saveDate.BrokerageFee__c =CommonUtil.stringToDecimal( ProvisionalQuote.BrokerageFee);   // 仲介手数料
        saveDate.ParkingBrokerageFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.ParkingBrokerageFee);   // 駐車場紹介料
        saveDate.FireInsuranceProratedFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.FireInsurancePremiumDaily);   // 保険料（火災）日割額
        saveDate.FireInsuranceFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.FireInsurancePremiums);   // 保険料（火災）
        saveDate.FirstFeeDeposit__c = CommonUtil.stringToDecimal(ProvisionalQuote.FirstWarrantyFee);   // 初回保証料
        saveDate.MonthlyFeeDeposit__c = CommonUtil.stringToDecimal(ProvisionalQuote.MonthlyFeeDeposit); // 月額保証料（初回）
        saveDate.MonthlyFeeDepositNextMonth__c = CommonUtil.stringToDecimal(ProvisionalQuote.MonthlyFeeDepositNextMonth); // 月額保証料（初回）次月額
        //▼問合せNo0496で追加
        // 画面 料金情報取得
        getTabInput(ProvisionalQuote);
        saveDate.FreeItemName1__c = ProvisionalQuote.FreeItemName1; // 項目1名称
        saveDate.FreeItemFeeTaxType1__c = ProvisionalQuote.FreeItemFeeTaxType1; // 項目1税区分
        saveDate.FreeItemFeePaymentType1__c = ProvisionalQuote.FreeItemFeePaymentType1; // 項目1支払区分
        saveDate.FreeItemFeeDeposit1__c = CommonUtil.stringToDecimal(ProvisionalQuote.FreeItemFeeDeposit1); // 項目1料金
        saveDate.FreeItemName2__c = ProvisionalQuote.FreeItemName2; // 項目2名称
        saveDate.FreeItemFeeTaxType2__c = ProvisionalQuote.FreeItemFeeTaxType2; // 項目2税区分
        saveDate.FreeItemFeePaymentType2__c = ProvisionalQuote.FreeItemFeePaymentType2; // 項目2支払区分
        saveDate.FreeItemFeeDeposit2__c = CommonUtil.stringToDecimal(ProvisionalQuote.FreeItemFeeDeposit2); // 項目2料金
        saveDate.FreeItemName3__c = ProvisionalQuote.FreeItemName3; // 項目3名称
        saveDate.FreeItemFeeTaxType3__c = ProvisionalQuote.FreeItemFeeTaxType3; // 項目3税区分
        saveDate.FreeItemFeePaymentType3__c = ProvisionalQuote.FreeItemFeePaymentType3; // 項目3支払区分
        saveDate.FreeItemFeeDeposit3__c = CommonUtil.stringToDecimal(ProvisionalQuote.FreeItemFeeDeposit3 ); // 項目3料金
        saveDate.FreeItemName4__c = ProvisionalQuote.FreeItemName4; // 項目4名称
        saveDate.FreeItemFeeTaxType4__c = ProvisionalQuote.FreeItemFeeTaxType4; // 項目4税区分
        saveDate.FreeItemFeePaymentType4__c = ProvisionalQuote.FreeItemFeePaymentType4; // 項目4支払区分
        saveDate.FreeItemFeeDeposit4__c = CommonUtil.stringToDecimal(ProvisionalQuote.FreeItemFeeDeposit4 ); // 項目4料金
        saveDate.FreeItemName5__c = ProvisionalQuote.FreeItemName5; // 項目5名称
        saveDate.FreeItemFeeTaxType5__c = ProvisionalQuote.FreeItemFeeTaxType5; // 項目5税区分
        saveDate.FreeItemFeePaymentType5__c = ProvisionalQuote.FreeItemFeePaymentType5; // 項目5支払区分
        saveDate.FreeItemFeeDeposit5__c = CommonUtil.stringToDecimal(ProvisionalQuote.FreeItemFeeDeposit5 ); // 項目5料金
        //▲問合せNo0496で追加


        saveDate.SubTotal__c = CommonUtil.stringToDecimal(ProvisionalQuote.SubtotalAmount);   // 小計（初回）
        saveDate.Tax__c = CommonUtil.stringToDecimal(ProvisionalQuote.ConsumptionTax);   // 消費税（初回）
        saveDate.TaxationTarget__c = CommonUtil.stringToDecimal(ProvisionalQuote.Taxable);   // 課税対象（初回）
        saveDate.Total__c =CommonUtil.stringToDecimal( ProvisionalQuote.TotalAmount);   // 合計金額（初回）
        saveDate.RemarksRenewalFee__c = ProvisionalQuote.Remarks1;   // 備考（更新料）
        saveDate.RemarksShortTermPenaltyFee__c = ProvisionalQuote.Remarks2;   // 備考（短期解約違約金）

        saveDate.NextRentFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextRentFee);   // 家賃（初回以降）
        saveDate.NextManagementFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextManagementFee);   // 管理費（初回以降）
        saveDate.NextParkingFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextParkingFee);   // 駐車場代（初回以降）
        saveDate.NextWaterFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextWaterFee);   // 水道代（初回以降）
        saveDate.NextTownshipFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextTownshipFee);   // 町会費（初回以降）
        saveDate.NextCatvFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextCatvFee);   // CATV（初回以降）
        saveDate.NextGarbageDisposalFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextGarbageDisposalFee);   // ゴミ処理費（初回以降）
        saveDate.NextBicycleParkingFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextBicycleParkingFee);   // 駐輪場代（初回以降）
        saveDate.NextBikeStorageSmallFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextBikeStorageSmallFee);   // バイク置き場代（小型）（初回以降）
        saveDate.NextBikeStorageMediumFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextBikeStorageMediumFee);   // バイク置き場代（中型）（初回以降）
        saveDate.NextBikeStorageLargeFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextBikeStorageLargeFee);   // バイク置き場代（大型）（初回以降）
        saveDate.NextFireInsuranceFee__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextFireInsuranceFee);   // 保険料（火災）（初回以降）
        saveDate.NextFeeDeposit__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextFeeDeposit);   // 保証料（初回以降）
        //▼問合せNo0496で追加
        saveDate.NextFreeItemName1__c = ProvisionalQuote.NextFreeItemName1 ; // 項目1名称（初回以降）
        saveDate.NextFreeItemFeeTaxType1__c = ProvisionalQuote.NextFreeItemFeeTaxType1 ; // 項目1税区分（初回以降）
        saveDate.NextFreeItemFeeDeposit1__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextFreeItemFeeDeposit1) ; // 項目1料金（初回以降）
        saveDate.NextFreeItemName2__c = ProvisionalQuote.NextFreeItemName2 ; // 項目2名称（初回以降）
        saveDate.NextFreeItemFeeTaxType2__c = ProvisionalQuote.NextFreeItemFeeTaxType2 ; // 項目2税区分（初回以降）
        saveDate.NextFreeItemFeeDeposit2__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextFreeItemFeeDeposit2) ; // 項目2料金（初回以降）
        saveDate.NextFreeItemName3__c = ProvisionalQuote.NextFreeItemName3 ; // 項目3名称（初回以降）
        saveDate.NextFreeItemFeeTaxType3__c = ProvisionalQuote.NextFreeItemFeeTaxType3 ; // 項目3税区分（初回以降）
        saveDate.NextFreeItemFeeDeposit3__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextFreeItemFeeDeposit3) ; // 項目3料金（初回以降）
        saveDate.NextFreeItemName4__c = ProvisionalQuote.NextFreeItemName4 ; // 項目4名称（初回以降）
        saveDate.NextFreeItemFeeTaxType4__c = ProvisionalQuote.NextFreeItemFeeTaxType4 ; // 項目4税区分（初回以降）
        saveDate.NextFreeItemFeeDeposit4__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextFreeItemFeeDeposit4) ; // 項目4料金（初回以降）
        saveDate.NextFreeItemName5__c = ProvisionalQuote.NextFreeItemName5 ; // 項目5名称（初回以降）
        saveDate.NextFreeItemFeeTaxType5__c = ProvisionalQuote.NextFreeItemFeeTaxType5 ; // 項目5税区分（初回以降）
        saveDate.NextFreeItemFeeDeposit5__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextFreeItemFeeDeposit5) ; // 項目5料金（初回以降）
        //▲問合せNo0496で追加

        saveDate.NextSubTotal__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextSubTotal);   // 小計（初回以降）
        saveDate.NextTax__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextTax);   // 消費税（初回以降）
        saveDate.NextTaxationTarget__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextTaxationTarget);   // 課税対象（初回以降）
        saveDate.NextTotal__c = CommonUtil.stringToDecimal(ProvisionalQuote.NextTotal);   // 合計金額（初回以降）

        // その他付帯商品
        for (Integer i = 0; i < ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            if (i < screenProvisionalQuoteRecord.etceteraAuxiliaryItemList.size()) {
                ProvisionalQuoteBreakdown item = screenProvisionalQuoteRecord.etceteraAuxiliaryItemList[i];
                saveDate.put('AuxiliaryItem' + String.valueOf(i+1) + '__c', item.itemId);
                saveDate.put('AuxiliaryItemFee' + String.valueOf(i+1) + '__c', item.feeDec);

            } else {
                saveDate.put('AuxiliaryItem' + String.valueOf(i+1) + '__c', null);
                saveDate.put('AuxiliaryItemFee' + String.valueOf(i+1) + '__c', null);
            }

        }

        saveDate.NextRemarksRenewalFee__c = ProvisionalQuote.NextRemarksRenewalFee;   // 備考（更新料）（初回以降）
        saveDate.NextRemarksShortTermPenaltyFee__c = ProvisionalQuote.NextRemarksShortTermPenaltyFee;   // 備考（短期解約違約金）（初回以降）

        SecureDML.secureUpsert(savedate);
        return saveDate.id;
    }

    /**
     * 仮見積付帯商品の保存
     * 引数　　：  ProvisionalQuoteManageCompayItem screeenProvisionalQuoteManageCompayItem 仮見積指定商品入力データ
     * 　　　　：  ProvisionalQuote screenProvisionalQuote 仮見積データ
     * 　　　　：  ProvisionalQuoteId string 仮見積ID
     */
    private void saveProvisionalQuoteManageCompayItem(screeenProvisionalQuoteManageCompayItem ProvisionalQuoteManageCompayItem,screenProvisionalQuote ProvisionalQuote,String ProvisionalQuoteId){
        // 保存処理
        ProvisionalQuoteManageCompayItem__c saveDate = new ProvisionalQuoteManageCompayItem__c();
    
        if(!String.isBlank(ProvisionalQuoteManageCompayItem.Id)){
            // 更新
            saveDate.id = ProvisionalQuoteManageCompayItem.Id;
        }else{
            // 新規
            saveDate.ProvisionalQuote__c = ProvisionalQuoteId; // 仮見積
        }

        saveDate.ManagementCompanyItem__c = ProvisionalQuoteManageCompayItem.ManagementCompanyItem; // 管理会社指定
        if(ProvisionalQuote.Proratedflag){
            saveDate.DailyFee__c = CommonUtil.stringToDecimal(ProvisionalQuoteManageCompayItem.DailyFee); // 日割額
            saveDate.ProvisionalQuoteItemNextMonthText__c = ProvisionalQuoteManageCompayItem.ProvisionalQuoteItemNextMonthText; // 仮見積指定商品_契約次月テキスト
            saveDate.ProvisionalQuoteItemThisMonthText__c = ProvisionalQuoteManageCompayItem.ProvisionalQuoteItemThisMonthText; // 仮見積指定商品_契約当月テキスト
            saveDate.ProvisionalQuoteItemFullMonthText__c = ''; // 仮見積指定商品_契約当月テキスト(日割り無し)
        }else{
            saveDate.DailyFee__c =0; // 日割額
            saveDate.ProvisionalQuoteItemNextMonthText__c = ''; // 仮見積指定商品_契約次月テキスト
            saveDate.ProvisionalQuoteItemThisMonthText__c = ''; // 仮見積指定商品_契約当月テキスト
            saveDate.ProvisionalQuoteItemFullMonthText__c = ProvisionalQuoteManageCompayItem.ProvisionalQuoteItemFullMonthText; // 仮見積指定商品_契約当月テキスト(日割り無し)
        }
        
        saveDate.Fee__c = CommonUtil.stringToDecimal(ProvisionalQuoteManageCompayItem.Fee); // 金額
        saveDate.NextFee__c = CommonUtil.stringToDecimal(ProvisionalQuoteManageCompayItem.NextFee); // 金額（初回以降）
        
        SecureDML.secureUpsert(savedate);
    }


    /**
     * 消費税額算出
     * 引数　　：   String OriginalAmount 元の金額
     * 　　　　：   string TaxClassification 課税対象区分
     * 戻り値  ：  Decimal 税額
     */
    private Decimal consumptionTax(String OriginalAmount,string TaxClassification){
        decimal Tax = 0;
        // 課税かどうかを調べる
        if(TaxClassification == CommonConst.PROPERTY_TAXTYPE_TAXABLE ){
            // 課税
            Decimal decOriginalAmount = CommonUtil.stringToDecimal(OriginalAmount);
            if(decOriginalAmount == null){
                decOriginalAmount = 0;
            }
            // 税込み金額を算出
            Tax = decOriginalAmount * (0.01 * this.TaxRate );
        }
        return Tax;
    }

    /**
     * 課税対象判断
     * 引数　　：   String OriginalAmount 元の金額
     * 　　　　：   string TaxClassification 課税対象区分
     * 戻り値  ：  Decimal 課税対象の金額
     */
    private Decimal Taxable(String OriginalAmount,string TaxClassification){
        decimal Taxable = 0;
        // 課税かどうかを調べる
        if(TaxClassification == CommonConst.PROPERTY_TAXTYPE_TAXABLE ){
            // 課税
            Decimal decOriginalAmount = CommonUtil.stringToDecimal(OriginalAmount);
            if(decOriginalAmount == null){
                decOriginalAmount = 0;
            }
            // 税込み金額を算出
            Taxable = decOriginalAmount;
        }
        return Taxable;
    }

    /**
     * 文字列から数値型に変換するメソッド(空白やnullは0で返す。)
     * 引数　　：   String changeSring 変更する文字列
     * 戻り値  ：  Decimal 変更された数値型
     */   
    private Decimal stringToDecimal0(String changeSring){ 
        Decimal returnDec;
        if (String.isEmpty(changeSring)){
            returnDec = 0;
        }else{
            returnDec = Decimal.valueOf(changeSring.remove(','));
        }
	    return returnDec;
    }

    /**
     * 保証料の総賃料を求める
     * 引数　　：  
     * 戻り値  ：  Decimal 総賃料
     */   
    private Decimal setProvisionalEstimateTotalRent(){
        decimal ProvisionalQuoteManageCompayItemAmount = 0;     // 管理会社の金額
        decimal ProvisionalQuoteManageCompayItemTax = 0;        // 管理会社の税額
        for(screeenProvisionalQuoteManageCompayItem ProvisionalQuoteManageCompayItem :screenProvisionalQuoteManageCompayItemList){
            if(ProvisionalQuoteManageCompayItem.IssueDate == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH){
                // 月額のみ
                ProvisionalQuoteManageCompayItemAmount += stringToDecimal0(ProvisionalQuoteManageCompayItem.NextFee);   // 金額（初回以降）
                ProvisionalQuoteManageCompayItemTax    += consumptionTax(ProvisionalQuoteManageCompayItem.NextFee,ProvisionalQuoteManageCompayItem.TaxType);  // 金額（初回以降）税額
            }

        }
    
        
        // 小計金額
        decimal AllRentFee = stringToDecimal0(screenProvisionalQuoteRecord.NextRentFee)                 //家賃（初回以降）
                           + stringToDecimal0(screenProvisionalQuoteRecord.NextManagementFee)          //管理費（初回以降）
                           + stringToDecimal0(screenProvisionalQuoteRecord.NextParkingFee)             //駐車場代（初回以降）
                           + stringToDecimal0(screenProvisionalQuoteRecord.NextWaterFee)               //水道代（初回以降）
                           + stringToDecimal0(screenProvisionalQuoteRecord.NextTownshipFee)            //町会費（初回以降）
                           + stringToDecimal0(screenProvisionalQuoteRecord.NextCatvFee)                //CATV（初回以降）
                           + stringToDecimal0(screenProvisionalQuoteRecord.NextGarbageDisposalFee)     //ゴミ処理費（初回以降）
                           + stringToDecimal0(screenProvisionalQuoteRecord.NextBicycleParkingFee)      //駐輪場代（初回以降）
                           + stringToDecimal0(screenProvisionalQuoteRecord.NextBikeStorageSmallFee)    //バイク置き場代（小型）（初回以降）
                           + stringToDecimal0(screenProvisionalQuoteRecord.NextBikeStorageMediumFee)   //バイク置き場代（中型）（初回以降）
                           + stringToDecimal0(screenProvisionalQuoteRecord.NextBikeStorageLargeFee)    //バイク置き場代（大型）（初回以降）
                           + stringToDecimal0(screenProvisionalQuoteRecord.NextFireInsuranceFee)       //保険料（火災）（初回以降）
                           + ProvisionalQuoteManageCompayItemAmount;                                   //管理会社指定商品
        
                        
        // 消費税
        AllRentFee += Integer.valueOf(consumptionTax(screenProvisionalQuoteRecord.NextManagementFee,screenProvisionalQuoteRecord.ManagementFeeTaxType)      //管理費（初回以降）
                   + consumptionTax(screenProvisionalQuoteRecord.NextParkingFee,screenProvisionalQuoteRecord.ParkingFeeTaxType)                             //駐車場代（初回以降）
                   + consumptionTax(screenProvisionalQuoteRecord.NextWaterFee,screenProvisionalQuoteRecord.WortFeeTaxType)                                  //水道代（初回以降）
                   + consumptionTax(screenProvisionalQuoteRecord.NextTownshipFee,screenProvisionalQuoteRecord.TownshipFeeTaxType)                           //町会費（初回以降）
                   + consumptionTax(screenProvisionalQuoteRecord.NextCatvFee,screenProvisionalQuoteRecord.CATVTaxType)                                      //CATV（初回以降）
                   + consumptionTax(screenProvisionalQuoteRecord.NextGarbageDisposalFee,screenProvisionalQuoteRecord.GarbageDisposalFeeTaxType)             //ゴミ処理費（初回以降）
                   + consumptionTax(screenProvisionalQuoteRecord.NextBicycleParkingFee,screenProvisionalQuoteRecord.BicycleParkingFeeTaxType)               //駐輪場代（初回以降）
                   + consumptionTax(screenProvisionalQuoteRecord.NextBikeStorageSmallFee,screenProvisionalQuoteRecord.BikeParkingSmallFeeTaxType)           //バイク置き場代（小型）（初回以降）
                   + consumptionTax(screenProvisionalQuoteRecord.NextBikeStorageMediumFee,screenProvisionalQuoteRecord.BikeParkingMediumFeeTaxType)         //バイク置き場代（中型）（初回以降）
                   + consumptionTax(screenProvisionalQuoteRecord.NextBikeStorageLargeFee,screenProvisionalQuoteRecord.BikeParkinLargeFeeTaxType)            //バイク置き場代（大型）（初回以降）
                   + ProvisionalQuoteManageCompayItemTax
        );   

        // 合計金額
        return AllRentFee;

    }

    /**
     * 月額保証料を設定する
     * 引数　　：  itemdate item 保証料
     * 　　　　：  parameter param パラメータ
     * 　　　　：  Decimal AllRentFee 総賃料
     * 戻り値  ：  Decimal 月額保証料を含めた総賃料
     */   
    private Decimal setMonthlyFeeDeposit(itemdate item,parameter param,Decimal AllRentFee){
        Decimal FeeDeposit = 0;
        this.Fee = 0;
        // 保証料
        if(item.DepositYen == null || item.DepositYen == 0){
            // 保証料(金額)の金額が入っていない
            if(item.DepositRate != null && item.DepositRate != 0){
                // 保証料(割合)が入っている
                // 計算
                FeeDeposit = DepositRateFee(item.IsRentFeeType,item.IsAllRentFeeType,item.DirectDebitFeeTaxType,
                                                            item.DepositRate,item.DirectDebitFee,item.DirectDebitFeeTax,
                                                            AllRentFee,stringToDecimal0(this.screenProvisionalQuoteRecord.Rent)
                                                            );
            }
            
        }else{
            // 保証料(金額)の金額が入っている
            // そのまま金額をセット
            FeeDeposit = item.DepositYen;
        }

        // 保証料の金額により表示フラグを設定する。
        if(FeeDeposit > 0){
            this.screenProvisionalQuoteRecord.MonthlyFeeDeposit = commonUtil.decimalToString(FeeDeposit);//保証料（初回以降）    
            this.screenProvisionalQuoteRecord.MonthlyFeeDepositFlg = true; // 月額保証料（初回）表示フラグ
            if(param.HomeMovingDate.day() == 1 || !param.Proratedflag){
                this.screenProvisionalQuoteRecord.MonthlyFeeDepositNextMonth = '0';           //月額保証料（初回）次月額
                this.screenProvisionalQuoteRecord.MonthlyFeeDepositNextMonthFlg = false; // 月額保証料（初回）次月額表示フラグ
            }else if(param.Proratedflag){
                this.screenProvisionalQuoteRecord.MonthlyFeeDepositNextMonth = commonUtil.decimalToString(FeeDeposit);           //月額保証料（初回）次月額
                this.screenProvisionalQuoteRecord.MonthlyFeeDepositNextMonthFlg = true; // 月額保証料（初回）次月額表示フラグ
            }
            this.screenProvisionalQuoteRecord.NextFeeDeposit = commonUtil.decimalToString(FeeDeposit);  // 保証料（初回以降）
            this.screenProvisionalQuoteRecord.NextFeeDepositFlg = true;//保証料（初回以降）    
        }else{
            this.screenProvisionalQuoteRecord.MonthlyFeeDeposit = '0';//保証料（初回以降）    
            this.screenProvisionalQuoteRecord.MonthlyFeeDepositFlg = false; // 月額保証料（初回）表示フラグ
            this.screenProvisionalQuoteRecord.MonthlyFeeDepositNextMonth = '0';           //月額保証料（初回）次月額
            this.screenProvisionalQuoteRecord.MonthlyFeeDepositNextMonthFlg = false; // 月額保証料（初回）次月額表示フラグ
            this.screenProvisionalQuoteRecord.NextFeeDeposit = '0';  // 保証料（初回以降）
            this.screenProvisionalQuoteRecord.NextFeeDepositFlg = false;//保証料（初回以降）    
        }
    
        // 月額保証料を含めた総賃料を返す。
        return AllRentFee + this.Fee + FeeDeposit;
    }

    /**
     * 初回保証料を設定する
     * 引数　　：  itemdate item 保証料
     * 　　　　：  parameter param パラメータ
     * 　　　　：  Decimal AllRentFee 月額保証料を含めた総賃料
     * 戻り値  ：  
     */   
    private void setFirstFeeDeposit(itemdate item,parameter param,Decimal AllRentFeeMonthlyFeeDeposit){
        Decimal FirstWarrantyFee = 0;
        // 初回保証料
        if(item.FirstFeeDepositYen == null || item.FirstFeeDepositYen == 0){
            // 初回保証料(金額)の金額が入っていない
            if(item.FirstFeeDepositRate != null && item.FirstFeeDepositRate != 0){
                // 初回保証料(割合)が入っている
                // 計算(手数料を含まない)
                FirstWarrantyFee = DepositRateFee(item.IsRentFeeType,false,'',
                                                            item.FirstFeeDepositRate,0,0,
                                                            AllRentFeeMonthlyFeeDeposit,stringToDecimal0(this.screenProvisionalQuoteRecord.Rent)
                                                            );
            }
            
        }else{
            // 初回保証料(金額)の金額が入っている
            // そのまま金額をセット
            FirstWarrantyFee = item.FirstFeeDepositYen;
        }

        // 初回保証料の金額により表示フラグを設定する。
        if(FirstWarrantyFee > 0){
            this.screenProvisionalQuoteRecord.FirstWarrantyFee = commonUtil.decimalToString(FirstWarrantyFee);   //     初回保証料
            this.screenProvisionalQuoteRecord.FirstWarrantyFlg = true;  // 初回保証料表示フラグ

        }else{
            this.screenProvisionalQuoteRecord.FirstWarrantyFee = '0';   //     初回保証料
            this.screenProvisionalQuoteRecord.FirstWarrantyFlg = false;  // 初回保証料表示フラグ
        }

    }

    /**
     * 保証の割合計算
     * IsRentFeeType：商品明細.賃料区分
     * IsAllRentFeeType：取引先：総賃料区分
     * DirectDebitFeeTaxType：商品.手数料税区分
     * DepositRate：商品明細.初回保証料(割合)or保証料(割合)
     * DirectDebitFee：商品.手数料
     * DirectDebitFeeTax：商品.手数料(税込)
     * AllRentFee：物件.総賃料
     * RentFee：物件.賃料
     */
    private decimal DepositRateFee(Boolean IsRentFeeType,Boolean IsAllRentFeeType,String DirectDebitFeeTaxType,
                                            Decimal DepositRate ,Decimal DirectDebitFee,Decimal DirectDebitFeeTax,
                                            Decimal AllRentFee ,Decimal RentFee ){
        Decimal Calculated = 0;     //金額
        Decimal Fee = 0 ;           //手数料

        // 金額商品明細．賃料区分の内容（True：総賃料/False：賃料）に伴って、総賃料＋手数料もしくは賃料の割合の金額とする。
        if (IsRentFeeType){
            // 総賃料
            // ※総賃料に＋する手数料は、商品明細．商品．取引先．総賃料区分が含む（True）の場合のみ、
            if(IsAllRentFeeType){
                //▼問合せNo0496で変更
                // 税込みも税抜きも 商品.手数料(税込)で設定されているのでそのままセットする。
                Fee =DirectDebitFeeTax;
                //▲問合せNo0496で変更
                this.Fee = Fee;
            }
            // 計算式：[保証料（割合） or 初回保証料（割合）] ÷ 100 × ｛ [物件．総賃料＋商品．手数料 or 手数料（税込）]｝　※計算後少数以下切り上げ
            Calculated = (DepositRate / 100) * (AllRentFee + Fee);
        }else{
            // 賃料
            // 計算式：[保証料（割合） or 初回保証料（割合）] ÷ 100 × ｛ [物件．賃料] ｝　※計算後少数以下切り上げ
            Calculated = (DepositRate / 100) * RentFee;
        }

        return Calculated.setScale(0, RoundingMode.UP);

    }

// -----------------------------------------------------------------------------------------------
// 画面の制御
// -----------------------------------------------------------------------------------------------
    /**
     * 入力内容を保存押下
     */
    public void saveDate(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        hasErrorMessage = false;

        try{

            //金額の再計算
            AmountCalculationFirst();
            AmountCalculation();
                        
            String provisionalQuoteId = CommonConst.STRING_EMPTY;
            if(this.parameter.SavedOutputFlag){
                // 楽観ロックチェックExceptionを発行(仮見積)
                List<ProvisionalQuote__c> checkOptimisticLockExceptionProvisionalQuote = new List<ProvisionalQuote__c>();
                            
                checkOptimisticLockExceptionProvisionalQuote = [ SELECT id
                                                            FROM ProvisionalQuote__c
                                                            WHERE id = :screenProvisionalQuoteRecord.Id
                                                            AND SystemModStamp = :screenProvisionalQuoteRecord.SystemModstamp];                //楽観ロックチェック
                if (checkOptimisticLockExceptionProvisionalQuote.isEmpty()){
                    // エラーあり
                    OptimisticLockException ex = new OptimisticLockException();
                    throw ex;
                }
            }

            //▼問合せNo0496で追加
            // 入力チェック
            BusinessLogicException inputCheckex = inputCheck();

            // エラーあり
            if(inputCheckex.hasMessage()){
                throw inputCheckex;
            }
            //▲問合せNo0496で追加

            // 仮見積
            provisionalQuoteId =  saveProvisionalQuote(screenProvisionalQuoteRecord);
            for(screeenProvisionalQuoteManageCompayItem ProvisionalQuoteManageCompayItem :screenProvisionalQuoteManageCompayItemList){
                if(!String.isBlank(ProvisionalQuoteManageCompayItem.Id)){
                    // 楽観ロックチェックExceptionを発行(仮見積)
                    List<ProvisionalQuoteManageCompayItem__c> checkOptimisticLockExceptionProvisionalQuote = new List<ProvisionalQuoteManageCompayItem__c>();
                    // 仮見積付帯商品
                    checkOptimisticLockExceptionProvisionalQuote = [ SELECT id
                                                                FROM ProvisionalQuoteManageCompayItem__c
                                                                WHERE id = :ProvisionalQuoteManageCompayItem.Id
                                                                AND SystemModStamp = :ProvisionalQuoteManageCompayItem.systemmodstamp];                //楽観ロックチェック
                    if (checkOptimisticLockExceptionProvisionalQuote.isEmpty()){
                        // エラーあり
                        OptimisticLockException ex = new OptimisticLockException();
                        throw ex;
                    }
                }

                // 登録
                saveProvisionalQuoteManageCompayItem(ProvisionalQuoteManageCompayItem,screenProvisionalQuoteRecord,provisionalQuoteId);
            }

            // 保存後はIDのみセット
            parameter.Id                              = provisionalQuoteId;
            // 保存済みの仮見積の更新後は再取得
            getDate();           

        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 計算処理（初回）
     */
    public void AmountCalculationFirst(){          
        decimal ProvisionalQuoteManageCompayItemAmount = 0;     // 管理会社の金額
        decimal ProvisionalQuoteManageCompayItemTax = 0;        // 管理会社の税額
        Decimal ProvisionalQuoteManageCompayItemTaxable = 0;    // 課税対象額
        Decimal etceteraAuxiliaryItemSubtotalAmount     = 0;    // その他付帯商品合計金額
        Decimal etceteraAuxiliaryItemConsumptionTax     = 0;    // その他付帯商品消費税
        Decimal etceteraAuxiliaryItemTaxable            = 0;    // その他付帯商品課税対象
        for(screeenProvisionalQuoteManageCompayItem ProvisionalQuoteManageCompayItem :screenProvisionalQuoteManageCompayItemList){

            if(ProvisionalQuoteManageCompayItem.IssueDate == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH){
                // 日割り額が月額の場合のみ日割りの金額を含める。
                ProvisionalQuoteManageCompayItemAmount += stringToDecimal0(ProvisionalQuoteManageCompayItem.DailyFee);  // 日割額
                ProvisionalQuoteManageCompayItemTax += consumptionTax(ProvisionalQuoteManageCompayItem.DailyFee,ProvisionalQuoteManageCompayItem.TaxType);  // 日割（税額）
                ProvisionalQuoteManageCompayItemTaxable += Taxable(ProvisionalQuoteManageCompayItem.DailyFee,ProvisionalQuoteManageCompayItem.TaxType);  // 日割（課税対象）
            }

            ProvisionalQuoteManageCompayItemAmount += stringToDecimal0(ProvisionalQuoteManageCompayItem.Fee);       // 金額
            // 課税対象の税額計算
            ProvisionalQuoteManageCompayItemTax += consumptionTax(ProvisionalQuoteManageCompayItem.Fee,ProvisionalQuoteManageCompayItem.TaxType);       // 金額

            ProvisionalQuoteManageCompayItemTaxable += Taxable(ProvisionalQuoteManageCompayItem.Fee,ProvisionalQuoteManageCompayItem.TaxType);  // 金額（課税対象）

        }
        // その他付帯商品リスト分の加算
        for (ProvisionalQuoteBreakdown pqb: screenProvisionalQuoteRecord.etceteraAuxiliaryItemList) {
            etceteraAuxiliaryItemSubtotalAmount += pqb.feeDec0;                                  // 小計金額
            etceteraAuxiliaryItemConsumptionTax += consumptionTax(pqb.fee, pqb.taxType);         // 消費税
            etceteraAuxiliaryItemTaxable        += Taxable(pqb.fee, pqb.taxType);                // 課税対象
        }
        
        // 小計金額
        screenProvisionalQuoteRecord.SubtotalAmount = CommonUtil.decimalToString(stringToDecimal0(screenProvisionalQuoteRecord.DailyRent) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.Rent) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.ManagementProratedFee) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.ManagementFee) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.DailyAmountTownMembershipFee) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.TownMembershipFee) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.DailyWaterBill) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.WaterBill) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.CATVDaily) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.CATV) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.DailyGarbageDisposalExpenses) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.GarbageDisposalCosts) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.DailyBicycleParkingFee) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.BicycleparkingFee) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.DailyDiscountParkingLot) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.ParkingFee) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.ParkingDeposit) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.BikeStorageFeeSmallDailyDiscount)
                        + stringToDecimal0(screenProvisionalQuoteRecord.BikeStorageSeeDmall) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.BikeStorageFeeMediumDaily) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.BikeStorageFeeMediumSize) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.BikeStorageFeeLargeDailyDiscount) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.BikeStorageFeeLarge) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.SecurityDeposit) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.Deposit) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.KeyMoney) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.FixedrateRepairExpenses) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.EntranceFee) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.KeyExchangeCosts) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.BrokerageFee) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.ParkingBrokerageFee) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.FireInsurancePremiumDaily) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.FireInsurancePremiums) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.FirstWarrantyFee) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.MonthlyFeeDeposit)
                        + stringToDecimal0(screenProvisionalQuoteRecord.MonthlyFeeDepositNextMonth)
                        + stringToDecimal0(screenProvisionalQuoteRecord.DailyAmountProductsDesignatedManagementCompany) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.AmountGoodsSpecifiedManagementCompany) 
                        //▼問合せNo0496で追加
                        + stringToDecimal0(screenProvisionalQuoteRecord.FreeItemFeeDeposit1) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.FreeItemFeeDeposit2) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.FreeItemFeeDeposit3) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.FreeItemFeeDeposit4) 
                        + stringToDecimal0(screenProvisionalQuoteRecord.FreeItemFeeDeposit5) 
                        //▲問合せNo0496で追加
                        + ProvisionalQuoteManageCompayItemAmount
                        + etceteraAuxiliaryItemSubtotalAmount
        );

                       
        // 消費税
        screenProvisionalQuoteRecord.ConsumptionTax = CommonUtil.decimalToString((
            consumptionTax(screenProvisionalQuoteRecord.ManagementProratedFee,screenProvisionalQuoteRecord.ManagementFeeTaxType )   //     管理費日割額
            +consumptionTax(screenProvisionalQuoteRecord.ManagementFee ,screenProvisionalQuoteRecord.ManagementFeeTaxType)   //     管理費
            +consumptionTax(screenProvisionalQuoteRecord.DailyAmountTownMembershipFee ,screenProvisionalQuoteRecord.TownshipFeeTaxType)   //     町会費日割額
            +consumptionTax(screenProvisionalQuoteRecord.TownMembershipFee ,screenProvisionalQuoteRecord.TownshipFeeTaxType)   //     町会費
            +consumptionTax(screenProvisionalQuoteRecord.DailyWaterBill,screenProvisionalQuoteRecord.WortFeeTaxType )   //     水道代日割額
            +consumptionTax(screenProvisionalQuoteRecord.WaterBill,screenProvisionalQuoteRecord.WortFeeTaxType )   //     水道代
            +consumptionTax(screenProvisionalQuoteRecord.CATVDaily ,screenProvisionalQuoteRecord.CATVTaxType)   //     CATV日割額
            +consumptionTax(screenProvisionalQuoteRecord.CATV,screenProvisionalQuoteRecord.CATVTaxType )   //     CATV
            +consumptionTax(screenProvisionalQuoteRecord.DailyGarbageDisposalExpenses,screenProvisionalQuoteRecord.GarbageDisposalFeeTaxType )   //     ゴミ処理費日割額
            +consumptionTax(screenProvisionalQuoteRecord.GarbageDisposalCosts,screenProvisionalQuoteRecord.GarbageDisposalFeeTaxType )   //     ゴミ処理費
            +consumptionTax(screenProvisionalQuoteRecord.DailyBicycleParkingFee,screenProvisionalQuoteRecord.BicycleParkingFeeTaxType )   //     駐輪場代日割額
            +consumptionTax(screenProvisionalQuoteRecord.BicycleparkingFee,screenProvisionalQuoteRecord.BicycleParkingFeeTaxType )   //     駐輪場代
            +consumptionTax(screenProvisionalQuoteRecord.DailyDiscountParkingLot,screenProvisionalQuoteRecord.ParkingFeeTaxType )   //     駐車場代日割額
            +consumptionTax(screenProvisionalQuoteRecord.ParkingFee,screenProvisionalQuoteRecord.ParkingFeeTaxType )   //     駐車場代
            +consumptionTax(screenProvisionalQuoteRecord.ParkingDeposit ,screenProvisionalQuoteRecord.ParkingDepositTaxType)   //     駐車場保証金
            +consumptionTax(screenProvisionalQuoteRecord.BikeStorageFeeSmallDailyDiscount,screenProvisionalQuoteRecord.BikeParkingSmallFeeTaxType )   //     バイク置き場代（小型）日割額
            +consumptionTax(screenProvisionalQuoteRecord.BikeStorageSeeDmall,screenProvisionalQuoteRecord.BikeParkingSmallFeeTaxType )   //     バイク置き場代（小型）
            +consumptionTax(screenProvisionalQuoteRecord.BikeStorageFeeMediumDaily,screenProvisionalQuoteRecord.BikeParkingMediumFeeTaxType )   //     バイク置き場代（中型）日割額
            +consumptionTax(screenProvisionalQuoteRecord.BikeStorageFeeMediumSize,screenProvisionalQuoteRecord.BikeParkingMediumFeeTaxType )   //     バイク置き場代（中型）
            +consumptionTax(screenProvisionalQuoteRecord.BikeStorageFeeLargeDailyDiscount,screenProvisionalQuoteRecord.BikeParkinLargeFeeTaxType )   //     バイク置き場代（大型）日割額
            +consumptionTax(screenProvisionalQuoteRecord.BikeStorageFeeLarge,screenProvisionalQuoteRecord.BikeParkinLargeFeeTaxType )   //     バイク置き場代（大型）
            +consumptionTax(screenProvisionalQuoteRecord.FixedrateRepairExpenses,screenProvisionalQuoteRecord.CleaningFeeTaxType )   //     定額修繕費
            +consumptionTax(screenProvisionalQuoteRecord.EntranceFee,screenProvisionalQuoteRecord.TownshipInitialFeeTaxType )   //     入町費
            +consumptionTax(screenProvisionalQuoteRecord.KeyExchangeCosts,screenProvisionalQuoteRecord.KeyExchangeFeeTaxType )   //     鍵交換費
            +(stringToDecimal0(screenProvisionalQuoteRecord.BrokerageFee) * (0.01 * this.TaxRate ))     // 仲介手数料
            +(stringToDecimal0(screenProvisionalQuoteRecord.ParkingBrokerageFee) * (0.01 * this.TaxRate ))     // 駐車場紹介料
            //▼問合せNo0496で追加
            +consumptionTax(screenProvisionalQuoteRecord.FreeItemFeeDeposit1,this.selectFreeItemFeeTaxType1List.getCheckValue()) // 項目1
            +consumptionTax(screenProvisionalQuoteRecord.FreeItemFeeDeposit2,this.selectFreeItemFeeTaxType2List.getCheckValue()) // 項目2
            +consumptionTax(screenProvisionalQuoteRecord.FreeItemFeeDeposit3,this.selectFreeItemFeeTaxType3List.getCheckValue()) // 項目3
            +consumptionTax(screenProvisionalQuoteRecord.FreeItemFeeDeposit4,this.selectFreeItemFeeTaxType4List.getCheckValue()) // 項目4
            +consumptionTax(screenProvisionalQuoteRecord.FreeItemFeeDeposit5,this.selectFreeItemFeeTaxType5List.getCheckValue()) // 項目5
            //▲問合せNo0496で追加
            +ProvisionalQuoteManageCompayItemTax
            + etceteraAuxiliaryItemConsumptionTax
        ).setScale(0, RoundingMode.DOWN));   

        // 課税対象
        screenProvisionalQuoteRecord.Taxable = CommonUtil.decimalToString(
            Taxable(screenProvisionalQuoteRecord.ManagementProratedFee,screenProvisionalQuoteRecord.ManagementFeeTaxType )   //     管理費日割額
            +Taxable(screenProvisionalQuoteRecord.ManagementFee ,screenProvisionalQuoteRecord.ManagementFeeTaxType)   //     管理費
            +Taxable(screenProvisionalQuoteRecord.DailyAmountTownMembershipFee ,screenProvisionalQuoteRecord.TownshipFeeTaxType)   //     町会費日割額
            +Taxable(screenProvisionalQuoteRecord.TownMembershipFee ,screenProvisionalQuoteRecord.TownshipFeeTaxType)   //     町会費
            +Taxable(screenProvisionalQuoteRecord.DailyWaterBill,screenProvisionalQuoteRecord.WortFeeTaxType )   //     水道代日割額
            +Taxable(screenProvisionalQuoteRecord.WaterBill,screenProvisionalQuoteRecord.WortFeeTaxType )   //     水道代
            +Taxable(screenProvisionalQuoteRecord.CATVDaily ,screenProvisionalQuoteRecord.CATVTaxType)   //     CATV日割額
            +Taxable(screenProvisionalQuoteRecord.CATV,screenProvisionalQuoteRecord.CATVTaxType )   //     CATV
            +Taxable(screenProvisionalQuoteRecord.DailyGarbageDisposalExpenses,screenProvisionalQuoteRecord.GarbageDisposalFeeTaxType )   //     ゴミ処理費日割額
            +Taxable(screenProvisionalQuoteRecord.GarbageDisposalCosts,screenProvisionalQuoteRecord.GarbageDisposalFeeTaxType )   //     ゴミ処理費
            +Taxable(screenProvisionalQuoteRecord.DailyBicycleParkingFee,screenProvisionalQuoteRecord.BicycleParkingFeeTaxType )   //     駐輪場代日割額
            +Taxable(screenProvisionalQuoteRecord.BicycleparkingFee,screenProvisionalQuoteRecord.BicycleParkingFeeTaxType )   //     駐輪場代
            +Taxable(screenProvisionalQuoteRecord.DailyDiscountParkingLot,screenProvisionalQuoteRecord.ParkingFeeTaxType )   //     駐車場代日割額
            +Taxable(screenProvisionalQuoteRecord.ParkingFee,screenProvisionalQuoteRecord.ParkingFeeTaxType )   //     駐車場代
            +Taxable(screenProvisionalQuoteRecord.ParkingDeposit ,screenProvisionalQuoteRecord.ParkingDepositTaxType)   //     駐車場保証金
            +Taxable(screenProvisionalQuoteRecord.BikeStorageFeeSmallDailyDiscount,screenProvisionalQuoteRecord.BikeParkingSmallFeeTaxType )   //     バイク置き場代（小型）日割額
            +Taxable(screenProvisionalQuoteRecord.BikeStorageSeeDmall,screenProvisionalQuoteRecord.BikeParkingSmallFeeTaxType )   //     バイク置き場代（小型）
            +Taxable(screenProvisionalQuoteRecord.BikeStorageFeeMediumDaily,screenProvisionalQuoteRecord.BikeParkingMediumFeeTaxType )   //     バイク置き場代（中型）日割額
            +Taxable(screenProvisionalQuoteRecord.BikeStorageFeeMediumSize,screenProvisionalQuoteRecord.BikeParkingMediumFeeTaxType )   //     バイク置き場代（中型）
            +Taxable(screenProvisionalQuoteRecord.BikeStorageFeeLargeDailyDiscount,screenProvisionalQuoteRecord.BikeParkinLargeFeeTaxType )   //     バイク置き場代（大型）日割額
            +Taxable(screenProvisionalQuoteRecord.BikeStorageFeeLarge,screenProvisionalQuoteRecord.BikeParkinLargeFeeTaxType )   //     バイク置き場代（大型）
            +Taxable(screenProvisionalQuoteRecord.FixedrateRepairExpenses,screenProvisionalQuoteRecord.CleaningFeeTaxType )   //     定額修繕費
            +Taxable(screenProvisionalQuoteRecord.EntranceFee,screenProvisionalQuoteRecord.TownshipInitialFeeTaxType )   //     入町費
            +Taxable(screenProvisionalQuoteRecord.KeyExchangeCosts,screenProvisionalQuoteRecord.KeyExchangeFeeTaxType )   //     鍵交換費
            +stringToDecimal0(screenProvisionalQuoteRecord.BrokerageFee)     // 仲介手数料
            +stringToDecimal0(screenProvisionalQuoteRecord.ParkingBrokerageFee) //     駐車場紹介料
            //▼問合せNo0496で追加
            +Taxable(screenProvisionalQuoteRecord.FreeItemFeeDeposit1,this.selectFreeItemFeeTaxType1List.getCheckValue()) // 項目1
            +Taxable(screenProvisionalQuoteRecord.FreeItemFeeDeposit2,this.selectFreeItemFeeTaxType2List.getCheckValue()) // 項目2
            +Taxable(screenProvisionalQuoteRecord.FreeItemFeeDeposit3,this.selectFreeItemFeeTaxType3List.getCheckValue()) // 項目3
            +Taxable(screenProvisionalQuoteRecord.FreeItemFeeDeposit4,this.selectFreeItemFeeTaxType4List.getCheckValue()) // 項目4
            +Taxable(screenProvisionalQuoteRecord.FreeItemFeeDeposit5,this.selectFreeItemFeeTaxType5List.getCheckValue()) // 項目5
            //▲問合せNo0496で追加 
            +ProvisionalQuoteManageCompayItemTaxable
            + etceteraAuxiliaryItemTaxable
        ); 
        // 合計金額
        screenProvisionalQuoteRecord.TotalAmount = CommonUtil.decimalToString(stringToDecimal0(screenProvisionalQuoteRecord.SubtotalAmount) + stringToDecimal0(screenProvisionalQuoteRecord.ConsumptionTax));
    }

    /**
     * 計算処理（初回以降）
     */
    public void AmountCalculation(){      
        decimal ProvisionalQuoteManageCompayItemAmount = 0;     // 管理会社の金額
        decimal ProvisionalQuoteManageCompayItemTax = 0;        // 管理会社の税額
        decimal ProvisionalQuoteManageCompayItemTaxable = 0;    // 管理会社の課税対象
        for(screeenProvisionalQuoteManageCompayItem ProvisionalQuoteManageCompayItem :screenProvisionalQuoteManageCompayItemList){
            if(ProvisionalQuoteManageCompayItem.IssueDate == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH){
                // 月額のみ
                ProvisionalQuoteManageCompayItemAmount += stringToDecimal0(ProvisionalQuoteManageCompayItem.NextFee);   // 金額（初回以降）
                ProvisionalQuoteManageCompayItemTax    += consumptionTax(ProvisionalQuoteManageCompayItem.NextFee,ProvisionalQuoteManageCompayItem.TaxType);  // 金額（初回以降）税額
                ProvisionalQuoteManageCompayItemTaxable+= Taxable(ProvisionalQuoteManageCompayItem.NextFee,ProvisionalQuoteManageCompayItem.TaxType);  // 金額（初回以降）税額
            }

        }

        // 小計金額
        screenProvisionalQuoteRecord.NextSubTotal = CommonUtil.decimalToString(
                        stringToDecimal0(screenProvisionalQuoteRecord.NextRentFee) +                //家賃（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextManagementFee) +          //管理費（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextParkingFee) +             //駐車場代（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextWaterFee) +               //水道代（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextTownshipFee) +            //町会費（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextCatvFee) +                //CATV（初回以降）

                        stringToDecimal0(screenProvisionalQuoteRecord.NextGarbageDisposalFee) +     //ゴミ処理費（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextBicycleParkingFee) +      //駐輪場代（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextBikeStorageSmallFee) +    //バイク置き場代（小型）（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextBikeStorageMediumFee) +   //バイク置き場代（中型）（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextBikeStorageLargeFee) +    //バイク置き場代（大型）（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextFireInsuranceFee) +       //保険料（火災）（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextFeeDeposit) +             //保証料（初回以降）
                        //▼問合せNo0496で追加
                        stringToDecimal0(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit1) +    //項目1（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit2) +    //項目2（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit3) +    //項目3（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit4) +    //項目4（初回以降）
                        stringToDecimal0(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit5) +    //項目5（初回以降）
                        //▲問合せNo0496で追加
                        ProvisionalQuoteManageCompayItemAmount                                      //管理会社指定商品
        );
                        
        // 消費税
        screenProvisionalQuoteRecord.NextTax = CommonUtil.decimalToString((
            consumptionTax(screenProvisionalQuoteRecord.NextManagementFee,screenProvisionalQuoteRecord.ManagementFeeTaxType) +          //管理費（初回以降）
            consumptionTax(screenProvisionalQuoteRecord.NextParkingFee,screenProvisionalQuoteRecord.ParkingFeeTaxType) +             //駐車場代（初回以降）
            consumptionTax(screenProvisionalQuoteRecord.NextWaterFee,screenProvisionalQuoteRecord.WortFeeTaxType) +               //水道代（初回以降）
            consumptionTax(screenProvisionalQuoteRecord.NextTownshipFee,screenProvisionalQuoteRecord.TownshipFeeTaxType) +            //町会費（初回以降）
            consumptionTax(screenProvisionalQuoteRecord.NextCatvFee,screenProvisionalQuoteRecord.CATVTaxType) +                //CATV（初回以降）
            consumptionTax(screenProvisionalQuoteRecord.NextGarbageDisposalFee,screenProvisionalQuoteRecord.GarbageDisposalFeeTaxType) +     //ゴミ処理費（初回以降）
            consumptionTax(screenProvisionalQuoteRecord.NextBicycleParkingFee,screenProvisionalQuoteRecord.BicycleParkingFeeTaxType) +      //駐輪場代（初回以降）
            consumptionTax(screenProvisionalQuoteRecord.NextBikeStorageSmallFee,screenProvisionalQuoteRecord.BikeParkingSmallFeeTaxType) +    //バイク置き場代（小型）（初回以降）
            consumptionTax(screenProvisionalQuoteRecord.NextBikeStorageMediumFee,screenProvisionalQuoteRecord.BikeParkingMediumFeeTaxType) +   //バイク置き場代（中型）（初回以降）
            consumptionTax(screenProvisionalQuoteRecord.NextBikeStorageLargeFee,screenProvisionalQuoteRecord.BikeParkinLargeFeeTaxType) +    //バイク置き場代（大型）（初回以降）
            //▼問合せNo0496で追加
            consumptionTax(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit1,this.selectNextFreeItemFeeTaxType1List.getCheckValue()) +    //項目1（初回以降）
            consumptionTax(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit2,this.selectNextFreeItemFeeTaxType2List.getCheckValue()) +    //項目2（初回以降）
            consumptionTax(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit3,this.selectNextFreeItemFeeTaxType3List.getCheckValue()) +    //項目3（初回以降）
            consumptionTax(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit4,this.selectNextFreeItemFeeTaxType4List.getCheckValue()) +    //項目4（初回以降）
            consumptionTax(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit5,this.selectNextFreeItemFeeTaxType5List.getCheckValue()) +    //項目5（初回以降）
            //▲問合せNo0496で追加
            ProvisionalQuoteManageCompayItemTax
        ).setScale(0, RoundingMode.DOWN));   

        // 課税対象
        screenProvisionalQuoteRecord.NextTaxationTarget = CommonUtil.decimalToString(
            Taxable(screenProvisionalQuoteRecord.NextManagementFee,screenProvisionalQuoteRecord.ManagementFeeTaxType) +          //管理費（初回以降）
            Taxable(screenProvisionalQuoteRecord.NextParkingFee,screenProvisionalQuoteRecord.ParkingFeeTaxType) +             //駐車場代（初回以降）
            Taxable(screenProvisionalQuoteRecord.NextWaterFee,screenProvisionalQuoteRecord.WortFeeTaxType) +               //水道代（初回以降）
            Taxable(screenProvisionalQuoteRecord.NextTownshipFee,screenProvisionalQuoteRecord.TownshipFeeTaxType) +            //町会費（初回以降）
            Taxable(screenProvisionalQuoteRecord.NextCatvFee,screenProvisionalQuoteRecord.CATVTaxType) +                //CATV（初回以降）
            Taxable(screenProvisionalQuoteRecord.NextGarbageDisposalFee,screenProvisionalQuoteRecord.GarbageDisposalFeeTaxType) +     //ゴミ処理費（初回以降）
            Taxable(screenProvisionalQuoteRecord.NextBicycleParkingFee,screenProvisionalQuoteRecord.BicycleParkingFeeTaxType) +      //駐輪場代（初回以降）
            Taxable(screenProvisionalQuoteRecord.NextBikeStorageSmallFee,screenProvisionalQuoteRecord.BikeParkingSmallFeeTaxType) +    //バイク置き場代（小型）（初回以降）
            Taxable(screenProvisionalQuoteRecord.NextBikeStorageMediumFee,screenProvisionalQuoteRecord.BikeParkingMediumFeeTaxType) +   //バイク置き場代（中型）（初回以降）
            Taxable(screenProvisionalQuoteRecord.NextBikeStorageLargeFee,screenProvisionalQuoteRecord.BikeParkinLargeFeeTaxType) +    //バイク置き場代（大型）（初回以降）
            //▼問合せNo0496で追加
            Taxable(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit1,this.selectNextFreeItemFeeTaxType1List.getCheckValue()) +    //項目1（初回以降）
            Taxable(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit2,this.selectNextFreeItemFeeTaxType2List.getCheckValue()) +    //項目2（初回以降）
            Taxable(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit3,this.selectNextFreeItemFeeTaxType3List.getCheckValue()) +    //項目3（初回以降）
            Taxable(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit4,this.selectNextFreeItemFeeTaxType4List.getCheckValue()) +    //項目4（初回以降）
            Taxable(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit5,this.selectNextFreeItemFeeTaxType5List.getCheckValue()) +    //項目5（初回以降）
            //▲問合せNo0496で追加
            ProvisionalQuoteManageCompayItemTaxable
        ); 

        // 合計金額
        screenProvisionalQuoteRecord.NextTotal = CommonUtil.decimalToString(stringToDecimal0(screenProvisionalQuoteRecord.NextSubTotal) + stringToDecimal0(screenProvisionalQuoteRecord.NextTax));   
    }



//▼問合せNo0496で追加
// -----------------------------------------------------------------------------------------------
// 制御
// -----------------------------------------------------------------------------------------------
    /**
     * 選択リストの設定
     * @param 　
     * @return 
     */
    private void setSelectList(){
        this.selectFreeItemFeePaymentType1List =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'FreeItemFeePaymentType1__c', false));
        this.selectFreeItemFeePaymentType2List =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'FreeItemFeePaymentType2__c', false));
        this.selectFreeItemFeePaymentType3List =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'FreeItemFeePaymentType3__c', false));
        this.selectFreeItemFeePaymentType4List =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'FreeItemFeePaymentType4__c', false));
        this.selectFreeItemFeePaymentType5List =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'FreeItemFeePaymentType5__c', false));
        this.selectFreeItemFeeTaxType1List     =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'FreeItemFeeTaxType1__c', false));
        this.selectFreeItemFeeTaxType2List     =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'FreeItemFeeTaxType2__c', false));
        this.selectFreeItemFeeTaxType3List     =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'FreeItemFeeTaxType3__c', false));
        this.selectFreeItemFeeTaxType4List     =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'FreeItemFeeTaxType4__c', false));
        this.selectFreeItemFeeTaxType5List     =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'FreeItemFeeTaxType5__c', false));
        this.selectNextFreeItemFeeTaxType1List =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'NextFreeItemFeeTaxType1__c', false));
        this.selectNextFreeItemFeeTaxType2List =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'NextFreeItemFeeTaxType2__c', false));
        this.selectNextFreeItemFeeTaxType3List =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'NextFreeItemFeeTaxType3__c', false));
        this.selectNextFreeItemFeeTaxType4List =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'NextFreeItemFeeTaxType4__c', false));
        this.selectNextFreeItemFeeTaxType5List =  new CommonUtil.screenSelectList(CommonUtil.getSelectOptionFromObject('ProvisionalQuote__c', 'NextFreeItemFeeTaxType5__c', false));
    }

    /**
     * 入力チェック
     * @param 　
     * @return BusinessLogicException 例外
     */
    private BusinessLogicException inputCheck(){
        BusinessLogicException inputCheckex = new BusinessLogicException();
        String requiredItemFreeName = CommonConst.STRING_EMPTY;
        String requiredItemFeeDeposit = CommonConst.STRING_EMPTY;
        
        // 自由項目の項目名のみ入力があり、金額が空
        if((String.isNotBlank(screenProvisionalQuoteRecord.FreeItemName1) && String.isBlank(screenProvisionalQuoteRecord.FreeItemFeeDeposit1)) 
        || (String.isNotBlank(screenProvisionalQuoteRecord.FreeItemName2) && String.isBlank(screenProvisionalQuoteRecord.FreeItemFeeDeposit2)) 
        || (String.isNotBlank(screenProvisionalQuoteRecord.FreeItemName3) && String.isBlank(screenProvisionalQuoteRecord.FreeItemFeeDeposit3)) 
        || (String.isNotBlank(screenProvisionalQuoteRecord.FreeItemName4) && String.isBlank(screenProvisionalQuoteRecord.FreeItemFeeDeposit4)) 
        || (String.isNotBlank(screenProvisionalQuoteRecord.FreeItemName5) && String.isBlank(screenProvisionalQuoteRecord.FreeItemFeeDeposit5)) 
        ){
            requiredItemFreeName = '自由入力行（初回）';
        }
        if((String.isNotBlank(screenProvisionalQuoteRecord.NextFreeItemName1) && String.isBlank(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit1))
        || (String.isNotBlank(screenProvisionalQuoteRecord.NextFreeItemName2) && String.isBlank(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit2))
        || (String.isNotBlank(screenProvisionalQuoteRecord.NextFreeItemName3) && String.isBlank(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit3))
        || (String.isNotBlank(screenProvisionalQuoteRecord.NextFreeItemName4) && String.isBlank(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit4))
        || (String.isNotBlank(screenProvisionalQuoteRecord.NextFreeItemName5) && String.isBlank(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit5))){
            if(String.isNotEmpty(requiredItemFreeName)){
                requiredItemFreeName = requiredItemFreeName.replace('）', '・初回以降）');
            }else{
                requiredItemFreeName = '自由入力行（初回以降）';
            }
            
        }

        // 自由項目の金額のみ入力で項目名が空
        if((String.isBlank(screenProvisionalQuoteRecord.FreeItemName1) && String.isNotBlank(screenProvisionalQuoteRecord.FreeItemFeeDeposit1))
        || (String.isBlank(screenProvisionalQuoteRecord.FreeItemName2) && String.isNotBlank(screenProvisionalQuoteRecord.FreeItemFeeDeposit2))
        || (String.isBlank(screenProvisionalQuoteRecord.FreeItemName3) && String.isNotBlank(screenProvisionalQuoteRecord.FreeItemFeeDeposit3))
        || (String.isBlank(screenProvisionalQuoteRecord.FreeItemName4) && String.isNotBlank(screenProvisionalQuoteRecord.FreeItemFeeDeposit4))
        || (String.isBlank(screenProvisionalQuoteRecord.FreeItemName5) && String.isNotBlank(screenProvisionalQuoteRecord.FreeItemFeeDeposit5))
        ){
            requiredItemFeeDeposit = '自由入力行（初回）';
        }

        if((String.isBlank(screenProvisionalQuoteRecord.NextFreeItemName1) && String.isNotBlank(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit1))
        || (String.isBlank(screenProvisionalQuoteRecord.NextFreeItemName2) && String.isNotBlank(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit2))
        || (String.isBlank(screenProvisionalQuoteRecord.NextFreeItemName3) && String.isNotBlank(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit3))
        || (String.isBlank(screenProvisionalQuoteRecord.NextFreeItemName4) && String.isNotBlank(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit4))
        || (String.isBlank(screenProvisionalQuoteRecord.NextFreeItemName5) && String.isNotBlank(screenProvisionalQuoteRecord.NextFreeItemFeeDeposit5))
        ){
            if(String.isNotEmpty(requiredItemFeeDeposit)){
                requiredItemFeeDeposit = requiredItemFeeDeposit.replace('）', '・初回以降）');
            }else{
                requiredItemFeeDeposit = '自由入力行（初回以降）';
            }
        }

        // 自由項目の項目名のみ入力があり、金額が空場合、ビジネスロジックException発行
        if (string.isNotEmpty(requiredItemFreeName)){
            List<String> replacementStringList = new List<String>();
            replacementStringList.add(requiredItemFreeName);
            replacementStringList.add('内訳');
            replacementStringList.add('金額');
            inputCheckex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_CUST_I_PROVISIONALQUOTE_FREE_NOT_INPUT, replacementStringList));
        }
        // 自由項目の金額のみ入力で項目名が空場合、ビジネスロジックException発行
        if (string.isNotEmpty(requiredItemFeeDeposit)){
            List<String> replacementStringList = new List<String>();
            replacementStringList.add(requiredItemFeeDeposit);
            replacementStringList.add('金額');
            replacementStringList.add('内訳');
            inputCheckex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_CUST_I_PROVISIONALQUOTE_FREE_NOT_INPUT,replacementStringList));
        }
        return inputCheckex;
    }

    /**
     * 自由項目の区分の設定
     * @param String freeItemName　自由項目名
     * @param String freeItemFeeDeposit　自由項目金額
     * @param String checkValue　チェックした項目
     * @return String 設定項目
     */
    private String setFreeType(String freeItemName,String freeItemFeeDeposit,String checkValue){
        // 両方の入力項目が無ければチェックを外す
        if(String.isBlank(freeItemName) && String.isBlank(freeItemFeeDeposit)){
            return CommonConst.STRING_EMPTY;
        }
        return checkValue;
    }

    /**
     * 入力タブの設定
     * @param screenProvisionalQuote provisionalQuote 入力内容
     * @return 
     */
    private void getTabInput(screenProvisionalQuote provisionalQuote) {
        // 自由項目支払区分
        provisionalQuote.FreeItemFeePaymentType1 = setFreeType(screenProvisionalQuoteRecord.FreeItemName1,screenProvisionalQuoteRecord.FreeItemFeeDeposit1, this.selectFreeItemFeePaymentType1List.getCheckValue());  //自由項目1支払区分
        provisionalQuote.FreeItemFeePaymentType2 = setFreeType(screenProvisionalQuoteRecord.FreeItemName2,screenProvisionalQuoteRecord.FreeItemFeeDeposit2, this.selectFreeItemFeePaymentType2List.getCheckValue());  //自由項目2支払区分
        provisionalQuote.FreeItemFeePaymentType3 = setFreeType(screenProvisionalQuoteRecord.FreeItemName3,screenProvisionalQuoteRecord.FreeItemFeeDeposit3, this.selectFreeItemFeePaymentType3List.getCheckValue());  //自由項目3支払区分
        provisionalQuote.FreeItemFeePaymentType4 = setFreeType(screenProvisionalQuoteRecord.FreeItemName4,screenProvisionalQuoteRecord.FreeItemFeeDeposit4, this.selectFreeItemFeePaymentType4List.getCheckValue());  //自由項目4支払区分
        provisionalQuote.FreeItemFeePaymentType5 = setFreeType(screenProvisionalQuoteRecord.FreeItemName5,screenProvisionalQuoteRecord.FreeItemFeeDeposit5, this.selectFreeItemFeePaymentType5List.getCheckValue());  //自由項目5支払区分
        //自由項目税区分
        provisionalQuote.FreeItemFeeTaxType1 = setFreeType(screenProvisionalQuoteRecord.FreeItemName1,screenProvisionalQuoteRecord.FreeItemFeeDeposit1,  this.selectFreeItemFeeTaxType1List.getCheckValue());  //自由項目1税区分
        provisionalQuote.FreeItemFeeTaxType2 = setFreeType(screenProvisionalQuoteRecord.FreeItemName2,screenProvisionalQuoteRecord.FreeItemFeeDeposit2,  this.selectFreeItemFeeTaxType2List.getCheckValue());  //自由項目2税区分
        provisionalQuote.FreeItemFeeTaxType3 = setFreeType(screenProvisionalQuoteRecord.FreeItemName3,screenProvisionalQuoteRecord.FreeItemFeeDeposit3,  this.selectFreeItemFeeTaxType3List.getCheckValue());  //自由項目3税区分
        provisionalQuote.FreeItemFeeTaxType4 = setFreeType(screenProvisionalQuoteRecord.FreeItemName4,screenProvisionalQuoteRecord.FreeItemFeeDeposit4,  this.selectFreeItemFeeTaxType4List.getCheckValue());  //自由項目4税区分
        provisionalQuote.FreeItemFeeTaxType5 = setFreeType(screenProvisionalQuoteRecord.FreeItemName5,screenProvisionalQuoteRecord.FreeItemFeeDeposit5,  this.selectFreeItemFeeTaxType5List.getCheckValue());  //自由項目5税区分
        //自由項目税区分（初回以降）
        provisionalQuote.NextFreeItemFeeTaxType1 = setFreeType(screenProvisionalQuoteRecord.NextFreeItemName1,screenProvisionalQuoteRecord.NextFreeItemFeeDeposit1,   this.selectNextFreeItemFeeTaxType1List.getCheckValue());  //自由項目1税区分（初回以降）
        provisionalQuote.NextFreeItemFeeTaxType2 = setFreeType(screenProvisionalQuoteRecord.NextFreeItemName2,screenProvisionalQuoteRecord.NextFreeItemFeeDeposit2,   this.selectNextFreeItemFeeTaxType2List.getCheckValue());  //自由項目2税区分（初回以降）
        provisionalQuote.NextFreeItemFeeTaxType3 = setFreeType(screenProvisionalQuoteRecord.NextFreeItemName3,screenProvisionalQuoteRecord.NextFreeItemFeeDeposit3,   this.selectNextFreeItemFeeTaxType3List.getCheckValue());  //自由項目3税区分（初回以降）
        provisionalQuote.NextFreeItemFeeTaxType4 = setFreeType(screenProvisionalQuoteRecord.NextFreeItemName4,screenProvisionalQuoteRecord.NextFreeItemFeeDeposit4,   this.selectNextFreeItemFeeTaxType4List.getCheckValue());  //自由項目4税区分（初回以降）
        provisionalQuote.NextFreeItemFeeTaxType5 = setFreeType(screenProvisionalQuoteRecord.NextFreeItemName5,screenProvisionalQuoteRecord.NextFreeItemFeeDeposit5,   this.selectNextFreeItemFeeTaxType5List.getCheckValue());  //自由項目5税区分（初回以降）
    }

    /**
     * 改行メソッド（帳票出力用）
     *  PDF化時に文字が改行されなくなる為、改行コードを埋め込む
     * @param String provisionalQuote 変換対象の文字列
     * @param Integer kaigyoByte 改行バイト位置
     * @param Stgring breakTag 改行タグ
     * @return String 改行タグをセットした文字列
     */
    private static String autoKaigyo(String replaceText, Integer kaigyoByte ,String breakTag){

        String rtnSt = '';
        
        // null対応
        if (String.isBlank(replaceText)) {
            return rtnSt;
        }
        
        Integer stLength = replaceText.length();

        // 文字列のbyte数カウント
        Integer blen = 0;           // バイト数
        Integer lengthCount = 0;    // 文字抽出の開始位置
        integer iCount = 0;         // 処理件数
        for (Integer i = 0; i < replaceText.length(); i++) {
            String letter = replaceText.substring(i, i + 1);
        
            // Apexの文字列はUTF-8で扱われるため、全角３バイト扱いになるので無理やり２バイトとする
            if (Blob.valueOf(letter).size() > 1) {
                // 全角は２バイト
                blen += 2;
            } else {
                // 半角は１バイト
                blen += 1;
            }

            // 対象の文字をオーバーする（最後に全角を判定した）
            if(blen > kaigyoByte){
                // 現在の文字の前に改行を挟む
                // 後ろに改行をセットする
                rtnSt += replaceText.substring(lengthCount, i).escapeHtml4() + breakTag;
                lengthCount += iCount;
                blen = 2;
                iCount = 1;

            }
            //最後まで処理したがバイト数を超えない場合、改行をセットしない。
            if(i == (replaceText.length()-1)){    
                rtnSt += replaceText.substring(lengthCount, replaceText.length()).escapeHtml4();
                break;
            }
            // 対象の文字位置まで
            if(blen == kaigyoByte){
                // 後ろに改行をセットする
                rtnSt += replaceText.substring(lengthCount, i+1).escapeHtml4() + breakTag;
                lengthCount += iCount+1;
                blen = 0;
                iCount = 0;
                continue;
            }
            iCount += 1;
        }
        system.debug(rtnSt);
        return rtnSt;
    }
    //▲問合せNo0496で追加

// -----------------------------------------------------------------------------------------------
// SQL取得
// -----------------------------------------------------------------------------------------------
    

    /**
     * 検索処理（取引先）
     * 引数によって内容を絞り込んだデータを取得する。
     * 引数　　：　id String 取引先ID
     * 戻り値　：　List<Account> 取引先データ
     */
    private List<Account> selectAccountInfo(String id){


        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                            // 取引先.Id（非表示）
        sql += '      ,SystemModstamp ';                // SystemModstamp
        sql += '      ,Name ';                          // 取引先.取引先名    
        sql += ' FROM  Account         ';

        sql += ' WHERE ID = \'' + id + '\'' ;

       
        // 検索実行＆結果返却
        return Database.query(sql);
    }

    /**
     * 検索処理（物件）
     * 引数によって内容を絞り込んだデータを取得する。
     * 引数　　：　id String 物件ID
     * 戻り値　：　List<Property__c>　物件のデータ
     */
    private List<Property__c> selectProperty(String id){
        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                            // 物件.Id（非表示）
        sql += '      ,SystemModstamp ';                // SystemModstamp
        sql += '      ,Name ';                          // 物件．部屋番号
        sql += '      ,Building__r.name ';              // 物件．建物．建物名
        
        sql += '      , Building__r.Address__c';// 物件．住所
        sql += '      , ManagementFeeTaxType__c'; // 管理費税区分
        sql += '      , WortFeeTaxType__c'; // 水道料金税区分
        sql += '      , TownshipFeeTaxType__c'; // 町会費税区分
        sql += '      , RenewalFeeTaxType__c'; // 更新料税区分
        sql += '      , ParkingFeeTaxType__c'; // 駐車場料金税区分
        sql += '      , ParkingDepositTaxType__c'; // 駐車場保証料金税区分
        sql += '      , ParkingCompoundingFeeTaxType__c'; // 駐車場手数料税区分
        sql += '      , KeyExchangeFeeTaxType__c'; // 鍵交換費税区分
        sql += '      , ADFeeTaxType__c'; // 広告料税区分
        sql += '      , CATVTaxType__c'; // CATV税区分
        sql += '      , GarbageDisposalFeeTaxType__c'; // ゴミ処理費税区分
        sql += '      , BicycleParkingFeeTaxType__c'; // 駐輪場代税区分
        sql += '      , BikeParkingSmallFeeTaxType__c'; // 小型バイク置場料金税区分
        sql += '      , BikeParkingMediumFeeTaxType__c'; // 中型バイク置場料金税区分
        sql += '      , BikeParkinLargeFeeTaxType__c'; // 大型バイク置場料金税区分
        sql += '      , TownshipInitialFeeTaxType__c'; // 入町費税区分
        sql += '      , CleaningFeeTaxType__c'; // 定額修繕費税区分
        sql += '      , CleaningFeePaymentType__c '; // 定額修繕費支払区分
        sql += '      , TownshipFeePaymentType__c '; // 町会費支払区分
        sql += '      , GarbageDisposalFeePaymentType__c '; // ゴミ処理費支払区分
        sql += '      , RentFee__c';// 物件．賃料
        sql += '      , AllRentFee__c';// 物件．総賃料
        sql += '      , ManagementFee__c';// 物件．管理費
        sql += '      , TownshipFee__c';// 物件．町会費
        sql += '      , WortFee__c';// 物件．水道料金
        sql += '      , CATVFee__c';// 物件．CATV
        sql += '      , GarbageDisposalFee__c';// 物件．ゴミ処理費
        sql += '      , ParkingDepositYen__c';// 物件．駐車場保証料金
        sql += '      , SecurityDepositYen__c';// 物件．敷金
        sql += '      , DepositYen__c';// 物件．保証料金
        sql += '      , KeyMoneyYen__c';// 物件．礼金
        sql += '      , CleaningFeeYen__c';// 物件．定額修繕費
        sql += '      , TownshipInitialFee__c';// 物件．入町費
        sql += '      , KeyExchangeFee__c';// 物件．鍵交換費
        sql += '      , ParkingCompoundingFeeYen__c';// 物件．駐車場手数料
        sql += '      , RenewalFee__c';// 物件．更新料
        sql += '      , IsShortTermPenalty__c';// 物件．短期解約違約金有無
        sql += '      , ShortTermPenaltyFee__c';// 物件．短期解約違約金
        sql += '      , ShortTermPenaltyLessYear__c';// 物件．短期解約違約金未満(年)
        sql += '      , ShortTermPenaltyFee2__c';// 物件．短期解約違約金2
        sql += '      , ShortTermPenaltyLessYear2__c';// 物件．短期解約違約金未満(年)2
  
        sql += ' FROM  Property__c         ';

        sql += ' WHERE ID = \'' + id + '\'' ;

        // 検索実行＆結果返却
        return Database.query(sql);
    }

    /**
     * 検索処理（仮見積）
     * 引数によって内容を絞り込んだデータを取得する。
     * 引数　　：  propertyId String 物件ID
     * 　　　　：  accountId String 取引先ID
     * 　　　　：  Id String 仮見積ID
     * 戻り値　：　仮見積のデータ
     */
    private List<ProvisionalQuote__c> selectProvisionalQuote(String propertyId,String accountId,String Id){


        // 検索SQL作成
        String sql = CommonConst.STRING_EMPTY;
        sql += 'SELECT Id ';                            // 物件.Id（非表示）
        sql += '      ,SystemModstamp ';                // SystemModstamp

        sql += '      ,Account__c ';// 取引先ID
        sql += '      ,Account__r.Name ';// 取引先名

        sql += '      ,Property__r.Building__r.Address__c ';// 物件．住所
        sql += '      ,Property__r.name ';// 仮見積．物件．部屋番号
        sql += '      ,Property__r.Building__r.name ';// 仮見積．物件．部屋番号
        sql += '      , Property__r.ManagementFeeTaxType__c'; // 管理費税区分
        sql += '      , Property__r.WortFeeTaxType__c'; // 水道料金税区分
        sql += '      , Property__r.TownshipFeeTaxType__c'; // 町会費税区分
        sql += '      , Property__r.RenewalFeeTaxType__c'; // 更新料税区分
        sql += '      , Property__r.ParkingFeeTaxType__c'; // 駐車場料金税区分
        sql += '      , Property__r.ParkingDepositTaxType__c'; // 駐車場保証料金税区分
        sql += '      , Property__r.ParkingCompoundingFeeTaxType__c'; // 駐車場手数料税区分
        sql += '      , Property__r.KeyExchangeFeeTaxType__c'; // 鍵交換費税区分
        sql += '      , Property__r.ADFeeTaxType__c'; // 広告料税区分
        sql += '      , Property__r.CATVTaxType__c'; // CATV税区分
        sql += '      , Property__r.GarbageDisposalFeeTaxType__c'; // ゴミ処理費税区分
        sql += '      , Property__r.BicycleParkingFeeTaxType__c'; // 駐輪場代税区分
        sql += '      , Property__r.BikeParkingSmallFeeTaxType__c'; // 小型バイク置場料金税区分
        sql += '      , Property__r.BikeParkingMediumFeeTaxType__c'; // 中型バイク置場料金税区分
        sql += '      , Property__r.BikeParkinLargeFeeTaxType__c'; // 大型バイク置場料金税区分
        sql += '      , Property__r.TownshipInitialFeeTaxType__c'; // 入町費税区分
        sql += '      , Property__r.CleaningFeeTaxType__c'; // 定額修繕費税区分
        sql += '      , Property__r.TownshipFeePaymentType__c '; // 町会費支払区分
        sql += '      , Property__r.GarbageDisposalFeePaymentType__c '; // ゴミ処理費支払区分

        sql += '      , ContractStartDate__c '; //パラメータ．引越時期
        sql += '      , IsProrated__c '; // 日割り計算
        sql += '      , ProratedMonthDays__c '; // 日割り計算月日数
        sql += '      , IsParkingUse__c '; // 駐車場利用
        sql += '      , ParkingRequiredNumber__c '; // 駐車場必要数
        sql += '      , ParkingRequiredNumberFee__c '; // 駐車場金額
        sql += '      , IsBicycleParkingUse__c '; // 駐輪場利用
        sql += '      , BicycleParkingRequiredNumber__c '; // 駐輪場必要数
        sql += '      , BicycleParkingRequiredNumberFee__c '; // 駐輪場金額
        sql += '      , IsBikeStorageSmallUse__c '; // バイク置き場（小型）利用
        sql += '      , BikeStorageSmallRequiredNumber__c '; // バイク置き場（小型）必要数
        sql += '      , BikeStorageSmallRequiredNumberFee__c '; // バイク置き場（小型）金額
        sql += '      , IsBikeStorageMediumUse__c '; // バイク置き場（中型）利用
        sql += '      , BikeStorageMediumRequiredNumber__c '; // バイク置き場（中型）必要数
        sql += '      , BikeStorageMediumRequiredNumberFee__c '; // バイク置き場（中型）金額
        sql += '      , IsBikeStorageLargeUse__c '; // バイク置き場（大型）利用
        sql += '      , BikeStorageLargeRequiredNumber__c '; // バイク置き場（大型）必要数
        sql += '      , BikeStorageLargeRequiredNumberFee__c '; // バイク置き場（大型）金額

        //▼問合せNo0496で追加
        sql += '      , RentNextMonthText__c ';             // 家賃_契約次月テキスト
        sql += '      , ManagementNextMonthText__c ';       // 管理費_契約次月テキスト
        sql += '      , ParkingNextMonthText__c ';          // 駐車場代_契約次月テキスト
        sql += '      , WaterNextMonthText__c ';            // 水道代_契約次月テキスト
        sql += '      , TownshipNextMonthText__c ';         // 町会費_契約次月テキスト
        sql += '      , CatvNextMonthText__c ';             // CATV_契約次月テキスト
        sql += '      , GarbageDisposalNextMonthText__c ';  // ゴミ処理費_契約次月テキスト
        sql += '      , BicycleParkingNextMonthText__c ';   // 駐輪場代_契約次月テキスト
        sql += '      , BikeStorageSmallNextMonthText__c '; // バイク置き場代（小型）_契約次月テキスト
        sql += '      , BikeStorageMediumNextMonthText__c ';// バイク置き場代（中型）_契約次月テキスト
        sql += '      , BikeStorageLargeNextMonthText__c '; // バイク置き場代（大型）_契約次月テキスト
        sql += '      , FireInsuranceNextMonthText__c ';    // 保険料（火災）_契約次月テキスト
        sql += '      , DepositNextMonthText__c ';          // 月額保証料（初回）_契約次月テキスト
        //▲問合せNo0496で追加
        // ▼問合せ556で追加
        sql += '      , RentThisMonthText__c ';              // 家賃_契約当月テキスト
        sql += '      , ManagementThisMonthText__c ';        // 管理費_契約当月テキスト
        sql += '      , TownshipThisMonthText__c ';          // 町会費_契約当月テキスト
        sql += '      , WaterThisMonthText__c ';             // 水道代_契約当月テキスト
        sql += '      , CatvThisMonthText__c ';              // CATV_契約当月テキスト
        sql += '      , GarbageDisposalThisMonthText__c ';   // ゴミ処理費_契約当月テキスト
        sql += '      , BicycleParkingThisMonthText__c ';    // 駐輪場代_契約当月テキスト
        sql += '      , ParkingThisMonthText__c ';           // 駐車場代_契約当月テキスト
        sql += '      , BikeStorageSmallThisMonthText__c ';  // バイク置き場代（小型）_契約当月テキスト
        sql += '      , BikeStorageMediumThisMonthText__c '; // バイク置き場代（中型）_契約当月テキスト
        sql += '      , BikeStorageLargeThisMonthText__c ';  // バイク置き場代（大型）_契約当月テキスト
        sql += '      , DepositThisMonthText__c ';           // 月額保証料（初回）_契約当月テキスト
        sql += '      , FireInsuranceThisMonthText__c ';     // 保険料（火災）_契約当月テキスト

        sql += '      , RentFullMonthText__c ';              // 家賃_契約月テキスト(日割り無し)
        sql += '      , ManagementFullMonthText__c ';        // 管理費_契約月テキスト(日割り無し)
        sql += '      , TownshipFullMonthText__c ';          // 町会費_契約月テキスト(日割り無し)
        sql += '      , WaterFullMonthText__c ';             // 水道代_契約月テキスト(日割り無し)
        sql += '      , CatvFullMonthText__c ';              // CATV_契約月テキスト(日割り無し)
        sql += '      , GarbageDisposalFullMonthText__c ';   // ゴミ処理費_契約月テキスト(日割り無し)
        sql += '      , BicycleParkingFullMonthText__c ';    // 駐輪場代_契約月テキスト(日割り無し)
        sql += '      , ParkingFullMonthText__c ';           // 駐車場代_契約月テキスト(日割り無し)
        sql += '      , BikeStorageSmallFullMonthText__c ';  // バイク置き場代（小型）_契約月テキスト(日割り無し)
        sql += '      , BikeStorageMediumFullMonthText__c '; // バイク置き場代（中型）_契約月テキスト(日割り無し)
        sql += '      , BikeStorageLargeFullMonthText__c ';  // バイク置き場代（大型）_契約月テキスト(日割り無し)
        sql += '      , DepositFullMonthText__c ';           // 月額保証料（初回）_契約月テキスト(日割り無し)
        sql += '      , FireInsuranceFullMonthText__c ';     // 保険料（火災）_契約月テキスト(日割り無し)
        // ▲問合せ556で追加

        sql += '      , DepositItem__r.Name '; // 保証プラン名
        sql += '      , DepositItem__r.DepositPaymentType__c '; // 仮見積．保証プラン．保証料支払方法
        sql += '      , FireInsuranceItem__r.ItemName__c '; // 火災保険名
        sql += '      , FireInsuranceItem__r.PaymentType__c '; // 火災保険
        sql += '      , FireInsuranceItem__r.FireInsuranceYear__c '; // 火災保険年
        sql += '      , FireInsuranceItem__r.FireInsuranceMonth__c '; // 火災保険月
        sql += '      , FireInsuranceItem__r.AuxiliaryItemFeeTaxType__c '; // 火災保険

        sql += '      ,CleaningFeeShow__c '; // 仮見積．定額修繕費表記
       
        sql += '      ,RentProratedFee__c '; // 仮見積．家賃日割額
        sql += '      ,RentFee__c '; // 仮見積．家賃
        sql += '      ,ManagementProratedFee__c '; // 仮見積．管理費日割額
        sql += '      ,ManagementFee__c '; // 仮見積．管理費
        sql += '      ,TownshipProratedFee__c '; // 仮見積．町会費日割額
        sql += '      ,TownshipFee__c '; // 仮見積．町会費
        sql += '      ,WaterProratedFee__c '; // 仮見積．水道代日割額
        sql += '      ,WaterFee__c '; // 仮見積．水道代
        sql += '      ,CatvProratedFee__c '; // 仮見積．CATV日割額
        sql += '      ,CatvFee__c '; // 仮見積．CATV
        sql += '      ,GarbageDisposalProratedFee__c '; // 仮見積．ゴミ処理費日割額
        sql += '      ,GarbageDisposalFee__c '; // 仮見積．ゴミ処理費
        sql += '      ,BicycleParkingProratedFee__c '; // 仮見積．駐輪場代日割額
        sql += '      ,BicycleParkingFee__c '; // 仮見積．駐輪場代
        sql += '      ,ParkingProratedFee__c '; // 仮見積．駐車場代日割額
        sql += '      ,ParkingFee__c '; // 仮見積．駐車場代
        sql += '      ,ParkingDeposit__c '; // 仮見積．駐車場保証金
        sql += '      ,BikeStorageSmallProratedFee__c '; // 仮見積．バイク置き場代（小型）日割額
        sql += '      ,BikeStorageSmallFee__c '; // 仮見積．バイク置き場代（小型）
        sql += '      ,BikeStorageMediumProratedFee__c '; // 仮見積．バイク置き場代（中型）日割額
        sql += '      ,BikeStorageMediumFee__c '; // 仮見積．バイク置き場代（中型）
        sql += '      ,BikeStorageLargeProratedFee__c '; // 仮見積．バイク置き場代（大型）日割額
        sql += '      ,BikeStorageLargeFee__c '; // 仮見積．バイク置き場代（大型）
        sql += '      ,SecurityDeposit__c '; // 仮見積．敷金
        sql += '      ,Deposit__c '; // 仮見積．保証金
        sql += '      ,KeyMoney__c '; // 仮見積．礼金
        sql += '      ,CleaningFee__c '; // 仮見積．定額修繕費
        sql += '      ,TownshipInitialFee__c '; // 仮見積．入町費
        sql += '      ,KeyExchangeFee__c '; // 仮見積．鍵交換費
        sql += '      ,BrokerageFee__c '; // 仮見積．仲介手数料
        sql += '      ,ParkingBrokerageFee__c '; // 仮見積．駐車場紹介料
        sql += '      ,FireInsuranceProratedFee__c '; // 仮見積．保険料（火災）日割額
        sql += '      ,FireInsuranceFee__c '; // 仮見積．保険料（火災）
        sql += '      ,FirstFeeDeposit__c '; // 仮見積．初回保証料
        sql += '      ,MonthlyFeeDeposit__c '; // 仮見積．月額保証料（初回）
        sql += '      ,MonthlyFeeDepositNextMonth__c '; //仮見積．月額保証料（初回）次月額

        //▼問合せNo0496で追加
        sql += '      ,FreeItemName1__c '; // 項目1名称
        sql += '      ,FreeItemFeeTaxType1__c '; // 項目1税区分
        sql += '      ,FreeItemFeePaymentType1__c '; // 項目1支払区分
        sql += '      ,FreeItemFeeDeposit1__c '; // 項目1料金
        sql += '      ,FreeItemName2__c '; // 項目2名称
        sql += '      ,FreeItemFeeTaxType2__c '; // 項目2税区分
        sql += '      ,FreeItemFeePaymentType2__c '; // 項目2支払区分
        sql += '      ,FreeItemFeeDeposit2__c '; // 項目2料金
        sql += '      ,FreeItemName3__c '; // 項目3名称
        sql += '      ,FreeItemFeeTaxType3__c '; // 項目3税区分
        sql += '      ,FreeItemFeePaymentType3__c '; // 項目3支払区分
        sql += '      ,FreeItemFeeDeposit3__c '; // 項目3料金
        sql += '      ,FreeItemName4__c '; // 項目4名称
        sql += '      ,FreeItemFeeTaxType4__c '; // 項目4税区分
        sql += '      ,FreeItemFeePaymentType4__c '; // 項目4支払区分
        sql += '      ,FreeItemFeeDeposit4__c '; // 項目4料金
        sql += '      ,FreeItemName5__c '; // 項目5名称
        sql += '      ,FreeItemFeeTaxType5__c '; // 項目5税区分
        sql += '      ,FreeItemFeePaymentType5__c '; // 項目5支払区分
        sql += '      ,FreeItemFeeDeposit5__c '; // 項目5料金
        //▲問合せNo0496で追加

        sql += '      ,SubTotal__c '; // 仮見積．小計
        sql += '      ,Tax__c '; // 仮見積．消費税
        sql += '      ,TaxationTarget__c '; // 仮見積．課税対象
        sql += '      ,Total__c '; // 仮見積．合計金額
        sql += '      ,RemarksRenewalFee__c '; // 仮見積．備考（更新料）
        sql += '      ,RemarksShortTermPenaltyFee__c '; // 仮見積．備考（短期解約違約金）
        sql += '      ,NextRentFee__c '; // 仮見積．家賃（初回以降）
        sql += '      ,NextManagementFee__c '; // 仮見積．管理費（初回以降）
        sql += '      ,NextTownshipFee__c '; // 仮見積．町会費（初回以降）
        sql += '      ,NextWaterFee__c '; // 仮見積．水道代（初回以降）
        sql += '      ,NextCatvFee__c '; // 仮見積．CATV（初回以降）
        sql += '      ,NextGarbageDisposalFee__c '; // 仮見積．ゴミ処理費（初回以降）
        sql += '      ,NextBicycleParkingFee__c '; // 仮見積．駐輪場金額（初回以降）
        sql += '      ,NextParkingFee__c '; // 仮見積．駐車場金額（初回以降）
        sql += '      ,NextBikeStorageSmallFee__c '; // 仮見積．バイク置き場（小型）金額（初回以降）
        sql += '      ,NextBikeStorageMediumFee__c '; // 仮見積．バイク置き場（中型）金額（初回以降）
        sql += '      ,NextBikeStorageLargeFee__c '; // 仮見積．バイク置き場（大型）金額（初回以降）
        sql += '      ,NextFireInsuranceFee__c '; // 仮見積．保険料（火災）（初回以降）
        sql += '      ,NextFeeDeposit__c '; // 仮見積．保証料（初回以降）
        //▼問合せNo0496で追加
        sql += '      ,NextFreeItemName1__c '; // 項目1名称（初回以降）
        sql += '      ,NextFreeItemFeeTaxType1__c '; // 項目1税区分（初回以降）
        sql += '      ,NextFreeItemFeeDeposit1__c '; // 項目1料金（初回以降）
        sql += '      ,NextFreeItemName2__c '; // 項目2名称（初回以降）
        sql += '      ,NextFreeItemFeeTaxType2__c '; // 項目2税区分（初回以降）
        sql += '      ,NextFreeItemFeeDeposit2__c '; // 項目2料金（初回以降）
        sql += '      ,NextFreeItemName3__c '; // 項目3名称（初回以降）
        sql += '      ,NextFreeItemFeeTaxType3__c '; // 項目3税区分（初回以降）
        sql += '      ,NextFreeItemFeeDeposit3__c '; // 項目3料金（初回以降）
        sql += '      ,NextFreeItemName4__c '; // 項目4名称（初回以降）
        sql += '      ,NextFreeItemFeeTaxType4__c '; // 項目4税区分（初回以降）
        sql += '      ,NextFreeItemFeeDeposit4__c '; // 項目4料金（初回以降）
        sql += '      ,NextFreeItemName5__c '; // 項目5名称（初回以降）
        sql += '      ,NextFreeItemFeeTaxType5__c '; // 項目5税区分（初回以降）
        sql += '      ,NextFreeItemFeeDeposit5__c '; // 項目5料金（初回以降）
        //▲問合せNo0496で追加
        sql += '      ,NextSubTotal__c '; // 仮見積．小計金額（初回以降）
        sql += '      ,NextTax__c '; // 仮見積．消費税（初回以降）
        sql += '      ,NextTaxationTarget__c '; // 仮見積．課税対象（初回以降）
        sql += '      ,NextTotal__c '; // 仮見積．合計金額（初回以降）
        sql += '      ,NextRemarksRenewalFee__c '; // 仮見積．備考（更新料）（初回以降）
        sql += '      ,NextRemarksShortTermPenaltyFee__c '; // 仮見積．備考（短期解約違約金）（初回以降）
        for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            sql += '      , AuxiliaryItem' + String.valueOf(i) + '__c';         // 付帯商品
            sql += '      , auxiliaryItemFee' + String.valueOf(i) + '__c';      // 付帯商品料（販売価格）
        }
        sql += ' FROM  ProvisionalQuote__c         ';

        if (!string.isBlank(Id)){
            sql += ' WHERE Id  = \'' + Id + '\'' ;
        }else{
            sql += ' WHERE Account__c  = \'' + accountId + '\'' ;
            sql += ' AND   Property__c = \'' + propertyId + '\'' ;
        }
        // 検索実行＆結果返却
        return Database.query(sql);
    }

    /**
    * 各商品の金額を取得
    * 引数　　：  id String のid
    * 戻り値　：  List<Item__c>　商品のデータ
    */
    private List<Item__c> ItemSetting(String id ){
        List<Item__c> itemList =[SELECT id,
                                ItemName__c,
                                AuxiliaryItemFee__c,
                                PaymentType__c,
                                AuxiliaryItemFeeTaxType__c,
                                FireInsuranceMonth__c,
                                FireInsuranceYear__c
                                FROM Item__c
                                WHERE id = :id];
        // 値を返す。
        return itemList;
    }

    /**
    * 商品明細の金額を取得
    * 引数　　：  id String のid
    * 戻り値　： List<ItemDetail__c>　商品明細のデータ 
    */
    private List<ItemDetail__c> ItemDetailSetting(String id ){
        List<ItemDetail__c> ItemDetailList = [SELECT id,
                                Item__r.ItemName__c,
                                FirstFeeDepositRate__c,
                                FirstFeeDepositYen__c,
                                DepositRate__c,
                                DepositYen__c,
                                DepositPaymentType__c,
                                IsRentFeeType__c,
                                Item__r.Account__r.IsAllRentFeeType__c,
                                Item__r.DirectDebitFeeTaxType__c,
                                Item__r.DirectDebitFee__c,
                                Item__r.DirectDebitFeeTax__c
                                FROM ItemDetail__c
                                WHERE id = :id];
        return ItemDetailList;
    }

    /**
    * 物件管理会社指定を取得
    * 引数　　：  PropertyId String 物件のid
    * 戻り値　：  List<PropertyManageCompayItem__c>　物件管理会社指定商品のデータ
    */
    private List<PropertyManageCompayItem__c> getPropertyManageCompayItem(String PropertyId){
        List<PropertyManageCompayItem__c> ItemDetailList = [SELECT id,
                Item__r.ItemName__c,
                Item__r.PaymentType__c,
                Item__r.Amount__c,
                Item__r.TaxType__c,
                Item__c
                FROM PropertyManageCompayItem__c
                WHERE Property__c = :PropertyId];
        return ItemDetailList;

    }

    /**
    * 仮見積管理会社指定を取得
    * 引数　　：  ProvisionalQuoteId String 仮見積のid
    * 戻り値　： List<ProvisionalQuoteManageCompayItem__c> 仮見積管理会社指定のデータ
    */
    private List<ProvisionalQuoteManageCompayItem__c> getPropertyManageCompayItemProvisionalQuote(String ProvisionalQuoteId){
        List<ProvisionalQuoteManageCompayItem__c> ItemDetailList = [SELECT id,
                SystemModstamp,
                ManagementCompanyItem__r.ItemName__c,
                ManagementCompanyItem__r.PaymentType__c,
                ManagementCompanyItem__r.TaxType__c,
                DailyFee__c,
                ProvisionalQuoteItemNextMonthText__c,
                ProvisionalQuoteItemThisMonthText__c, // 問合せ556で追加
                ProvisionalQuoteItemFullMonthText__c, // 問合せ556で追加
                Fee__c,
                NextFee__c,
                ManagementCompanyItem__c
                FROM ProvisionalQuoteManageCompayItem__c
                WHERE ProvisionalQuote__c = :ProvisionalQuoteId];
        return ItemDetailList;

    }

// -----------------------------------------------------------------------------------------------
// 画面出力系クラス
// -----------------------------------------------------------------------------------------------
    /**
     * 前画面からのパラメータクラス
     */
    public class parameter {
        public String accountId { get;set; }                        // 取引先ID
        public String propertyId { get;set; }                       // 物件ID
        public Date HomeMovingDate { get;set;}                      // 引越時期
        public Integer ProratedCalculationDay { get;set;}           // 日割り計算月日数
        public Boolean SavedOutputFlag {get;set;}                   // 保存内容出力フラグ
        public Boolean Proratedflag {get;set;}                      // 日割り計算フラグ
        public Boolean Parkingflag {get;set;}                       // 駐車場フラグ
        public Integer ParkingNumberRequired {get;set;}             // 駐車場必要数
        public Boolean BicycleParkingFlag {get;set;}                // 駐輪場フラグ
        public Integer BicycleParkingNumberRequired {get;set;}      // 駐輪場必要数    
        public Decimal ParkingFee { get;set;}                       // 物件．駐車場料金
        public Decimal BicycleParkingFee { get;set;}                // 物件．駐輪場代
        public Boolean BikeParkingSmallFlag {get;set;}              // バイク置き場（小型）フラグ
        public Integer BikeParkingSmallNumberRequired {get;set;}    // バイク置き場（小型）必要数
        public Decimal BikeParkingSmallFee { get;set;}              // 物件．小型バイク置場料金
        public Boolean BikeParkingMediumFlag {get;set;}             // バイク置き場（中型）フラグ
        public Integer BikeParkingMediumNumberRequired {get;set;}   // バイク置き場（中型）必要数
        public Decimal BikeParkingMediumFee { get;set;}             // 物件．中型バイク置場料金
        public Boolean BikeParkinLargeFlag {get;set;}               // バイク置き場（大型）フラグ
        public Integer BikeParkinLargeNumberRequired {get;set;}     // バイク置き場（大型）必要数
        public Decimal BikeParkinLargeFee { get;set;}               // 物件．大型バイク置場料金
        public String auxiliaryDepositPlan {get;set;}               // 保証プラン
        public String auxiliaryFireInsurance { get;set;}            // 火災保険
        public String RenewalFeeShow { get;set; }                   //更新料表記
        public String CleaningFeeShow { get;set; }                  //定額修繕費表記

        public String Id { get;set;}                                // 仮見積Id

        public List<String> etceteraAuxiliaryItemList { get;set; }  // その他付帯商品リスト
        public Boolean formLogoIsAlive { get; set; }                // 帳票ロゴの存在フラグ（VF起動時に状態取得、PDF側で使用）

        //コンストラクタ（入力項目から）
        public parameter(){
            // PDF出力時に設定されるIDを取得
            this.Id                              = Apexpages.currentPage().getParameters().get('Id');
            if(string.isBlank(this.id)){
                // 保存されていない場合
                this.SavedOutputFlag                 = Boolean.valueOf(ApexPages.currentPage().getParameters().get('SavedOutputFlag'));          //  保存内容出力フラグ
                this.accountId                       = ApexPages.currentPage().getParameters().get('AccountId');          // 取引先ID
                this.propertyId                      = ApexPages.currentPage().getParameters().get('PropertyId');        // 物件ID
                this.HomeMovingDate                  = String.isEmpty(ApexPages.currentPage().getParameters().get('HomeMovingDate'))? null :  Date.parse(ApexPages.currentPage().getParameters().get('HomeMovingDate')) ;          //  引越時期
                this.ProratedCalculationDay          = String.isEmpty(ApexPages.currentPage().getParameters().get('ProratedCalculationDay'))? 0 : Integer.valueOf(ApexPages.currentPage().getParameters().get('ProratedCalculationDay'))    ;          // 日割り計算月日数
                this.Proratedflag                    = Boolean.valueOf(ApexPages.currentPage().getParameters().get('Proratedflag'));          //  日割り計算フラグ
                this.Parkingflag                     = Boolean.valueOf(ApexPages.currentPage().getParameters().get('Parkingflag'));          //  駐車場フラグ
                this.ParkingNumberRequired           = String.isEmpty(ApexPages.currentPage().getParameters().get('ParkingNumberRequired'))? 0 : Integer.valueOf(ApexPages.currentPage().getParameters().get('ParkingNumberRequired'))    ;          //  駐車場必要数
                this.BicycleParkingFlag              = Boolean.valueOf(ApexPages.currentPage().getParameters().get('BicycleParkingFlag'));          //  駐輪場フラグ
                this.BicycleParkingNumberRequired    = String.isEmpty(ApexPages.currentPage().getParameters().get('BicycleParkingNumberRequired'))? 0 : Integer.valueOf(ApexPages.currentPage().getParameters().get('BicycleParkingNumberRequired'))    ;          // 駐輪場必要数
                this.ParkingFee                      = nullTo0(ApexPages.currentPage().getParameters().get('ParkingFee'));          //  物件．駐車場料金
                this.BicycleParkingFee               = nullTo0(ApexPages.currentPage().getParameters().get('BicycleParkingFee'));          //  物件．駐輪場代
                this.BikeParkingSmallFlag            = Boolean.valueOf(ApexPages.currentPage().getParameters().get('BikeParkingSmallFlag'));          //  バイク置き場（小型）フラグ
                this.BikeParkingSmallNumberRequired  = String.isEmpty(ApexPages.currentPage().getParameters().get('BikeParkingSmallNumberRequired'))? 0 : Integer.valueOf(ApexPages.currentPage().getParameters().get('BikeParkingSmallNumberRequired'))    ;          //  バイク置き場（小型）必要数
                this.BikeParkingSmallFee             = nullTo0(ApexPages.currentPage().getParameters().get('BikeParkingSmallFee'));          //  物件．小型バイク置場料金
                this.BikeParkingMediumFlag           = Boolean.valueOf(ApexPages.currentPage().getParameters().get('BikeParkingMediumFlag'));          //  バイク置き場（中型）フラグ
                this.BikeParkingMediumNumberRequired = String.isEmpty(ApexPages.currentPage().getParameters().get('BikeParkingMediumNumberRequired'))? 0 : Integer.valueOf(ApexPages.currentPage().getParameters().get('BikeParkingMediumNumberRequired'))    ;   //  バイク置き場（中型）必要数
                this.BikeParkingMediumFee            = nullTo0(ApexPages.currentPage().getParameters().get('BikeParkingMediumFee'));          //  物件．中型バイク置場料金
                this.BikeParkinLargeFlag             = Boolean.valueOf(ApexPages.currentPage().getParameters().get('BikeParkinLargeFlag'));          //  バイク置き場（大型）フラグ
                this.BikeParkinLargeNumberRequired   = String.isEmpty(ApexPages.currentPage().getParameters().get('BikeParkinLargeNumberRequired'))? 0 : Integer.valueOf(ApexPages.currentPage().getParameters().get('BikeParkinLargeNumberRequired'))    ;          //  バイク置き場（大型）必要数
                this.BikeParkinLargeFee              = nullTo0(ApexPages.currentPage().getParameters().get('BikeParkinLargeFee'));          //  物件．大型バイク置場料金
                this.auxiliaryDepositPlan            = ApexPages.currentPage().getParameters().get('auxiliaryDepositPlan');          //  保証プラン
                this.auxiliaryFireInsurance          = ApexPages.currentPage().getParameters().get('auxiliaryFireInsurance');          //  火災保険
                this.RenewalFeeShow                  = ApexPages.currentPage().getParameters().get('RenewalFeeShow');          //  更新料表記
                this.CleaningFeeShow                 = ApexPages.currentPage().getParameters().get('CleaningFeeShow');          //  定額修繕費表記   

                // その他付帯商品リスト
                this.etceteraAuxiliaryItemList = new List<String>();
                for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
                    String etceteraAuxliaryItem = getStringParam('AuxiliaryItem' + String.valueOf(i));
                    if (String.isNotEmpty(etceteraAuxliaryItem)) {
                        this.etceteraAuxiliaryItemList.add(etceteraAuxliaryItem);
                    }
                }

                // 帳票ロゴの存在フラグを初期設定
                this.formLogoIsAlive = true;

            }else{
                // 仮見積が保存されている。
                this.SavedOutputFlag                 = true;          //  保存内容出力フラグ
                this.accountId                       = CommonConst.STRING_EMPTY;          // 取引先ID
                this.propertyId                      = CommonConst.STRING_EMPTY;        // 物件ID

                // 帳票ロゴの存在フラグを取得
                String buf    =  ApexPages.currentPage().getParameters().get('formLogoIsAlive');
                this.formLogoIsAlive = (String.isEmpty(buf) || buf.equals('true'))? true: false;
            }
        }

        
        /**
        * nullもしくは取れない場合に0で返す（パラメータは文字列となるための考慮）。
        * 引数　　：  changeSring String 変更する文字列
        * 戻り値　：  decimal 変更された数値型
        */
        public Decimal nullTo0(String changeSring){
            Decimal returnDec;
            if(changeSring == 'null'){
                returnDec = 0;
            }else if (String.isEmpty(changeSring)){
                returnDec = 0;
            }else{
                returnDec = Decimal.valueOf(changeSring.remove(','));
            }
            return returnDec;
        } 

        private String getStringParam(String paramName) {
            String ret = ApexPages.currentPage().getParameters().get(paramName);
            ret = (String.isNotEmpty(ret) && ret.equals('null'))? null: ret;
            return ret;
        }
    }

    /**
     * 商品の金額と名称
     */
    public class itemDate{
        public String DepositPlan {get;set;}                // 保証プラン
        public Decimal DepositPlanAmount {get;set;}          // 保証プラン金額
        public decimal FirstFeeDepositYen {get;set;}        // 初回保証料(金額)
        public Decimal FirstFeeDepositRate {get;set;}       // 初回保証料(割合)
        public Decimal DepositRate {get;set;}               // 保証料(割合)
        public Decimal DepositYen {get;set;}                // 保証料(金額)
        public String FireInsurance { get;set;}             // 火災保険
        public Decimal FireInsuranceAmount { get;set;}       // 火災保険金額
        
        public boolean IsRentFeeType {get;set;}             // 賃料区分
        public boolean IsAllRentFeeType {get;set;}          // 総賃料区分
        public String DirectDebitFeeTaxType {get;set;}      // 手数料税区分
        public Decimal DirectDebitFee {get;set;}            // 手数料
        public Decimal DirectDebitFeeTax {get;set;}         // 手数料税込み
    }

    /**
     * 画面表示用内部クラス
     */
    public class screenProvisionalQuote {

        // 内部項目
        public String Id { get; set; }   // 仮見積ID
        public Datetime SystemModstamp { get;set;} // SystemModstamp
        
        // 　（ページタイトル）
        public String Title { get; set; }   // 　　タイトル

        // 　（ヘッダ）
        public String AccountName { get; set; }   //     取引先名
        public String IssueDate { get; set; }   //     発行日
        public String CompanyName { get; set; }             // 会社名
        public String InvoiceRegistNumber { get; set; }   //     登録番号
        public String PostalCode { get; set; }   //     〒
        public String Address { get; set; }   //     住所

        public String Phone { get; set; }   //     TEL
        public String Fax { get; set; }   //     FAX
        public String UserName { get; set; }   //     担当

        public String PropertyName { get; set; }   //     物件名
        public String PropertyAddress { get; set; }   //     住居表示
        public String ContractStartDate { get; set; }   //     契約開始日
        
        // 　（明細情報 内訳列）
        //    課税表示
        public String ManagementFeeTaxType { get; set; }   // 管理費税区分
        public String WortFeeTaxType { get; set; }   // 水道料金税区分
        public String TownshipFeeTaxType { get; set; }   // 町会費税区分
        public String RenewalFeeTaxType { get; set; }   // 更新料税区分
        public String ParkingFeeTaxType { get; set; }   // 駐車場料金税区分
        public String ParkingDepositTaxType { get; set; }   // 駐車場保証料金税区分
        public String ParkingCompoundingFeeTaxType { get; set; }   // 駐車場手数料税区分
        public String KeyExchangeFeeTaxType { get; set; }   // 鍵交換費税区分
        public String ADFeeTaxType { get; set; }   // 広告料税区分
        public String CATVTaxType { get; set; }   // CATV税区分
        public String GarbageDisposalFeeTaxType { get; set; }   // ゴミ処理費税区分
        public String BicycleParkingFeeTaxType { get; set; }   // 駐輪場代税区分
        public String BikeParkingSmallFeeTaxType { get; set; }   // 小型バイク置場料金税区分
        public String BikeParkingMediumFeeTaxType { get; set; }   // 中型バイク置場料金税区分
        public String BikeParkinLargeFeeTaxType { get; set; }   // 大型バイク置場料金税区分
        public String TownshipInitialFeeTaxType { get; set; }   // 入町費税区分
        public String CleaningFeeTaxType { get; set; }   // 定額修繕費税区分

        
        // 名前
        public String ContractMonth { get; set; }   //     契約当月
        public String ContractPerMonthDailyDays { get; set; }   //     契約当月日割日数
        public String ContractNextMonth { get; set; }   //     契約次月（契約当月）
        public String CleaningFeeShow { get; set; }   //     定額修繕費名
        public String FireInsuranceType { get; set; }   //     火災保険料金区分
        public String FireInsuranceTypeName { get; set; }   //     火災保険料金区分名（月額、年額）
        public String ProductNameDesignatedManagementCompany { get; set; }   //     管理会社指定商品名

        // 　（明細情報 金額列）
        public Boolean RentFlg { get; set; }             //     家賃全体表示フラグ
        public String DailyRent { get; set; }           //     家賃日割額
        public Boolean DailyRentFlg { get; set; }       //     家賃日割額_表示フラグ
        public String Rent { get; set; }                //     家賃
        
        public Boolean ManagementFeeFlg { get; set; }            //     管理費表示フラグ
        public String ManagementProratedFee { get; set; }       //     管理費日割額
        public Boolean ManagementProratedFeeFlg { get; set; }   //     管理費日割額_表示フラグ
        public String ManagementFee { get; set; }               //     管理費
        
        public Boolean TownMembershipFeeFlg { get; set; }               //     町会費表示フラグ
        public String DailyAmountTownMembershipFee { get; set; }        //     町会費日割額
        public Boolean DailyAmountTownMembershipFeeFlg { get; set; }    //     町会費日割額_表示フラグ
        public String TownMembershipFee { get; set; }                   //     町会費
        public String TownshipFeePaymentType { get; set; }              //     町会費支払区分
        
        public Boolean WaterBillFlg { get; set; }   //     水道代表示フラグ
        public String DailyWaterBill { get; set; }   //     水道代日割額
        public Boolean DailyWaterBillFlg { get; set; }   //     水道代日割額_表示フラグ
        public String WaterBill { get; set; }   //     水道代

        public Boolean CATVFlg { get; set; }   //     CATV_表示フラグ
        public String CATVDaily { get; set; }   //     CATV日割額
        public Boolean CATVDailyFlg { get; set; }   //     CATV日割額_表示フラグ
        public String CATV { get; set; }   //     CATV
        
        public Boolean GarbageDisposalCostsFlg { get; set; }            //     ゴミ処理費_表示フラグ
        public String DailyGarbageDisposalExpenses { get; set; }        //     ゴミ処理費日割額
        public Boolean DailyGarbageDisposalExpensesFlg { get; set; }    //     ゴミ処理費日割額_表示フラグ
        public String GarbageDisposalCosts { get; set; }                //     ゴミ処理費
        public String GarbageDisposalFeePaymentType { get; set; }       //     ゴミ処理費支払区分
        
        public Boolean BicycleparkingFeeFlg { get; set; }   //     駐輪場代表示フラグ
        public String DailyBicycleParkingFee { get; set; }   //     駐輪場代日割額
        public Boolean DailyBicycleParkingFeeFlg { get; set; }   //     駐輪場代日割額_表示フラグ
        public String BicycleparkingFee { get; set; }   //     駐輪場代
        
        public Boolean ParkingFeeFlg { get; set; }   //     駐車場代表示フラグ
        public String DailyDiscountParkingLot { get; set; }   //     駐車場代日割額
        public Boolean DailyDiscountParkingLotFlg { get; set; }   //     駐車場代日割額_表示フラグ
        public String ParkingFee { get; set; }   //     駐車場代

        public Boolean ParkingDepositFlg { get; set; } // 駐車場保証金表示フラグ
        public String ParkingDeposit { get; set; }   //     駐車場保証金

        public Boolean BikeStorageSeeDmallFlg { get; set; }   //     バイク置き場代（小型）表示フラグ
        public String BikeStorageFeeSmallDailyDiscount { get; set; }   //     バイク置き場代（小型）日割額
        public Boolean BikeStorageFeeSmallDailyDiscountFlg { get; set; }   //     バイク置き場代（小型）日割額_表示フラグ
        public String BikeStorageSeeDmall { get; set; }   //     バイク置き場代（小型）

        public Boolean BikeStorageFeeMediumSizeFlg { get; set; }   //     バイク置き場代（中型）表示フラグ
        public String BikeStorageFeeMediumDaily { get; set; }   //     バイク置き場代（中型）日割額
        public Boolean BikeStorageFeeMediumDailyFlg { get; set; }   //     バイク置き場代（中型）日割額_表示フラグ
        public String BikeStorageFeeMediumSize { get; set; }   //     バイク置き場代（中型）

        public Boolean BikeStorageFeeLargeFlg { get; set; }   //     バイク置き場代（大型）表示フラグ
        public String BikeStorageFeeLargeDailyDiscount { get; set; }   //     バイク置き場代（大型）日割額
        public Boolean BikeStorageFeeLargeDailyDiscountFlg { get; set; }   //     バイク置き場代（大型）日割額_表示フラグ
        public String BikeStorageFeeLarge { get; set; }   //     バイク置き場代（大型）

        public String SecurityDeposit { get; set; }   //     敷金
        public Boolean SecurityDepositFlg { get; set; }   //     敷金_表示フラグ

        public String Deposit { get; set; }   //     保証金
        public Boolean DepositFlg { get; set; }   //     保証金_表示フラグ

        public String KeyMoney { get; set; }   //     礼金
        public Boolean KeyMoneyFlg { get; set; }   //     礼金_表示フラグ

        public String FixedrateRepairExpenses { get; set; }   //     定額修繕費
        public Boolean FixedrateRepairExpensesFlg { get; set; }   //     定額修繕費_表示フラグ

        public String EntranceFee { get; set; }   //     入町費
        public Boolean EntranceFeeFlg { get; set; }   //     入町費_表示フラグ

        public String KeyExchangeCosts { get; set; }   //     鍵交換費
        public Boolean KeyExchangeCostsFlg { get; set; }   //     鍵交換費_表示フラグ

        public String BrokerageFee { get; set; }   //     仲介手数料
        public Boolean BrokerageFeeFlg { get; set; }   //     仲介手数料_表示フラグ

        public boolean ParkingBrokerageFeeFlg {get;set;}       //   駐車場紹介料表示フラグ
        public String ParkingBrokerageFee { get; set; }   //     駐車場紹介料

        public String FireInsurancePremiumDaily { get; set; }   //     火災保険料日割額
        public Boolean FireInsurancePremiumDailyFlg { get; set; }   //     火災保険料日割額_表示フラグ
        public String FireInsurancePremiums { get; set; }   //     火災保険料
        public Boolean FireInsurancePremiumsFlg { get; set; }   //     火災保険料_表示フラグ

        public String FirstWarrantyFee { get; set; }   //     初回保証料
        public Boolean FirstWarrantyFlg { get; set; }   //     初回保証料_表示フラグ

        public String MonthlyFeeDeposit { get;set; } // 月額保証料（初回）
        public Boolean MonthlyFeeDepositFlg { get; set; }   //     月額保証料（初回）_表示フラグ

        public String MonthlyFeeDepositNextMonth { get;set; } // 月額保証料（初回）次月
        public Boolean MonthlyFeeDepositNextMonthFlg { get;set; } // 月額保証料（初回）次月_表示フラグ

        public Boolean AmountGoodsSpecifiedManagementCompanyFlg { get; set; }   //     管理会社指定商品金額表示フラグ
        public String DailyAmountProductsDesignatedManagementCompany { get; set; }   //     管理会社指定商品日割額
        public Boolean DailyAmountProductsDesignatedManagementCompanyFlg { get; set; }   //     管理会社指定商品日割額フラグ
        public String AmountGoodsSpecifiedManagementCompany { get; set; }   //     管理会社指定商品金額

        //▼問合せNo0496で追加
        public String RentNextMonthText                { get; set; }   //  家賃_契約次月テキスト
        public String ManagementNextMonthText          { get; set; }   //  管理費_契約次月テキスト
        public String ParkingNextMonthText             { get; set; }   //  駐車場代_契約次月テキスト
        public String WaterNextMonthText               { get; set; }   //  水道代_契約次月テキスト
        public String TownshipNextMonthText            { get; set; }   //  町会費_契約次月テキスト
        public String CatvNextMonthText                { get; set; }   //  CATV_契約次月テキスト
        public String GarbageDisposalNextMonthText     { get; set; }   //  ゴミ処理費_契約次月テキスト
        public String BicycleParkingNextMonthText      { get; set; }   //  駐輪場代_契約次月テキスト
        public String BikeStorageSmallNextMonthText    { get; set; }   //  バイク置き場代（小型）_契約次月テキスト
        public String BikeStorageMediumNextMonthText   { get; set; }   //  バイク置き場代（中型）_契約次月テキスト
        public String BikeStorageLargeNextMonthText    { get; set; }   //  バイク置き場代（大型）日割時月額項目
        public String FireInsuranceNextMonthText       { get; set; }   //  保険料（火災）_契約次月テキスト
        public String DepositNextMonthText             { get; set; }   //  月額保証料（初回）_契約次月テキスト
        // PDF用改行設定項目
        public String RentNextMonthTextPdf                { get; set; }   //  PDF出力用家賃_契約次月テキスト
        public String ManagementNextMonthTextPdf          { get; set; }   //  PDF出力用管理費_契約次月テキスト
        public String ParkingNextMonthTextPdf             { get; set; }   //  PDF出力用駐車場代_契約次月テキスト
        public String WaterNextMonthTextPdf               { get; set; }   //  PDF出力用水道代_契約次月テキスト
        public String TownshipNextMonthTextPdf            { get; set; }   //  PDF出力用町会費_契約次月テキスト
        public String CatvNextMonthTextPdf                { get; set; }   //  PDF出力用CATV_契約次月テキスト
        public String GarbageDisposalNextMonthTextPdf     { get; set; }   //  PDF出力用ゴミ処理費_契約次月テキスト
        public String BicycleParkingNextMonthTextPdf      { get; set; }   //  PDF出力用駐輪場代_契約次月テキスト
        public String BikeStorageSmallNextMonthTextPdf    { get; set; }   //  PDF出力用バイク置き場代（小型）_契約次月テキスト
        public String BikeStorageMediumNextMonthTextPdf   { get; set; }   //  PDF出力用バイク置き場代（中型）_契約次月テキスト
        public String BikeStorageLargeNextMonthTextPdf    { get; set; }   //  PDF出力用バイク置き場代（大型）日割時月額項目
        public String FireInsuranceNextMonthTextPdf       { get; set; }   //  PDF出力用保険料（火災）_契約次月テキスト
        public String DepositNextMonthTextPdf             { get; set; }   //  PDF出力用月額保証料（初回）_契約次月テキスト
        // 自由項目
        public String FreeItemName1             { get; set; }      //  自由項目1名称
        public String FreeItemFeePaymentType1   { get; set; }      //  自由項目1支払区分
        public String FreeItemFeeTaxType1       { get; set; }      //  自由項目1税区分
        public String FreeItemFeeDeposit1       { get; set; }      //  自由項目1料金
        public String FreeItemName2             { get; set; }      //  自由項目2名称
        public String FreeItemFeePaymentType2   { get; set; }      //  自由項目2支払区分
        public String FreeItemFeeTaxType2       { get; set; }      //  自由項目2税区分
        public String FreeItemFeeDeposit2       { get; set; }      //  自由項目2料金
        public String FreeItemName3             { get; set; }      //  自由項目3名称
        public String FreeItemFeePaymentType3   { get; set; }      //  自由項目3支払区分
        public String FreeItemFeeTaxType3       { get; set; }      //  自由項目3税区分
        public String FreeItemFeeDeposit3       { get; set; }      //  自由項目3料金
        public String FreeItemName4             { get; set; }      //  自由項目4名称
        public String FreeItemFeePaymentType4   { get; set; }      //  自由項目4支払区分
        public String FreeItemFeeTaxType4       { get; set; }      //  自由項目4税区分
        public String FreeItemFeeDeposit4       { get; set; }      //  自由項目4料金
        public String FreeItemName5             { get; set; }      //  自由項目5名称
        public String FreeItemFeePaymentType5   { get; set; }      //  自由項目5支払区分
        public String FreeItemFeeTaxType5       { get; set; }      //  自由項目5税区分
        public String FreeItemFeeDeposit5       { get; set; }      //  自由項目5料金
        // PDF用改行設定項目
        public String FreeItemName1Pdf          { get; set; }      //  PDF出力用自由項目1名称
        public String FreeItemName2Pdf          { get; set; }      //  PDF出力用自由項目2名称
        public String FreeItemName3Pdf          { get; set; }      //  PDF出力用自由項目3名称
        public String FreeItemName4Pdf          { get; set; }      //  PDF出力用自由項目4名称
        public String FreeItemName5Pdf          { get; set; }      //  PDF出力用自由項目5名称
        //▲問合せNo0496で追加

        // ▼問合せ556で追加
        public String rentThisMonthText { get; set; }                // 家賃_契約当月テキスト
        public string managementThisMonthText { get; set;}           // 管理費_契約当月テキスト
        public String townshipThisMonthText { get; set;}             // 町会費_契約当月テキスト
        public String waterThisMonthText { get; set;}                // 水道代_契約当月テキスト
        public String catvThisMonthText { get; set;}                 // CATV_契約当月テキスト
        public String garbageDisposalThisMonthText { get; set;}      // ゴミ処理費_契約当月テキスト
        public String bicycleParkingThisMonthText { get; set;}       // 駐輪場代_契約当月テキスト
        public String parkingThisMonthText { get; set;}              // 駐車場代_契約当月テキスト
        public String bikeStorageSmallThisMonthText { get; set;}     // バイク置き場代（小型）_契約当月テキスト
        public String bikeStorageMediumThisMonthText { get; set;}    // バイク置き場代（中型）_契約当月テキスト
        public String bikeStorageLargeThisMonthText { get; set;}     // バイク置き場代（大型）_契約当月テキスト
        public String depositThisMonthText { get; set;}              // 月額保証料（初回）_契約当月テキスト
        public String fireInsuranceThisMonthText { get; set;}        // 保険料（火災）_契約当月テキスト
        public String rentFullMonthText { get; set; }                // 家賃_契約月テキスト(日割り無し)
        public string managementFullMonthText { get; set;}           // 管理費_契約月テキスト(日割り無し)
        public String townshipFullMonthText { get; set;}             // 町会費_契約月テキスト(日割り無し)
        public String waterFullMonthText { get; set;}                // 水道代_契約月テキスト(日割り無し)
        public String catvFullMonthText { get; set;}                 // CATV_契約月テキスト(日割り無し)
        public String garbageDisposalFullMonthText { get; set;}      // ゴミ処理費_契約月テキスト(日割り無し)
        public String bicycleParkingFullMonthText { get; set;}       // 駐輪場代_契約月テキスト(日割り無し)
        public String parkingFullMonthText { get; set;}              // 駐車場代_契約月テキスト(日割り無し)
        public String bikeStorageSmallFullMonthText { get; set;}     // バイク置き場代（小型）_契約月テキスト(日割り無し)
        public String bikeStorageMediumFullMonthText { get; set;}    // バイク置き場代（中型）_契約月テキスト(日割り無し)
        public String bikeStorageLargeFullMonthText { get; set;}     // バイク置き場代（大型）_契約月テキスト(日割り無し)
        public String depositFullMonthText { get; set;}              // 月額保証料（初回）_契約月テキスト(日割り無し)
        public String fireInsuranceFullMonthText { get; set;}        // 保険料（火災）_契約月テキスト(日割り無し)
        // PDF用改行設定項目
        public String rentThisMonthTextPdf { get; set; }                // 家賃_契約当月テキスト
        public string managementThisMonthTextPdf { get; set;}           // 管理費_契約当月テキスト
        public String townshipThisMonthTextPdf { get; set;}             // 町会費_契約当月テキスト
        public String waterThisMonthTextPdf { get; set;}                // 水道代_契約当月テキスト
        public String catvThisMonthTextPdf { get; set;}                 // CATV_契約当月テキスト
        public String garbageDisposalThisMonthTextPdf { get; set;}      // ゴミ処理費_契約当月テキスト
        public String bicycleParkingThisMonthTextPdf { get; set;}       // 駐輪場代_契約当月テキスト
        public String parkingThisMonthTextPdf { get; set;}              // 駐車場代_契約当月テキスト
        public String bikeStorageSmallThisMonthTextPdf { get; set;}     // バイク置き場代（小型）_契約当月テキスト
        public String bikeStorageMediumThisMonthTextPdf { get; set;}    // バイク置き場代（中型）_契約当月テキスト
        public String bikeStorageLargeThisMonthTextPdf { get; set;}     // バイク置き場代（大型）_契約当月テキスト
        public String depositThisMonthTextPdf { get; set;}              // 月額保証料（初回）_契約当月テキスト
        public String fireInsuranceThisMonthTextPdf { get; set;}        // 保険料（火災）_契約当月テキスト
        public String rentFullMonthTextPdf { get; set; }                // 家賃_契約月テキスト(日割り無し)
        public string managementFullMonthTextPdf { get; set;}           // 管理費_契約月テキスト(日割り無し)
        public String townshipFullMonthTextPdf { get; set;}             // 町会費_契約月テキスト(日割り無し)
        public String waterFullMonthTextPdf { get; set;}                // 水道代_契約月テキスト(日割り無し)
        public String catvFullMonthTextPdf { get; set;}                 // CATV_契約月テキスト(日割り無し)
        public String garbageDisposalFullMonthTextPdf { get; set;}      // ゴミ処理費_契約月テキスト(日割り無し)
        public String bicycleParkingFullMonthTextPdf { get; set;}       // 駐輪場代_契約月テキスト(日割り無し)
        public String parkingFullMonthTextPdf { get; set;}              // 駐車場代_契約月テキスト(日割り無し)
        public String bikeStorageSmallFullMonthTextPdf { get; set;}     // バイク置き場代（小型）_契約月テキスト(日割り無し)
        public String bikeStorageMediumFullMonthTextPdf { get; set;}    // バイク置き場代（中型）_契約月テキスト(日割り無し)
        public String bikeStorageLargeFullMonthTextPdf { get; set;}     // バイク置き場代（大型）_契約月テキスト(日割り無し)
        public String depositFullMonthTextPdf { get; set;}              // 月額保証料（初回）_契約月テキスト(日割り無し)
        public String fireInsuranceFullMonthTextPdf { get; set;}        // 保険料（火災）_契約月テキスト(日割り無し)
        // ▲問合せ556で追加

        public String SubtotalAmount { get; set; }   //     小計金額
        public String ConsumptionTax { get; set; }   //     消費税
        public String Taxable { get; set; }   //     課税対象
        public String TotalAmount { get; set; }   //     合計金額

        // 内訳
        public List<ProvisionalQuoteBreakdown> etceteraAuxiliaryItemList { get; set; }          // その他付帯商品

        // 　【備考】
        public String Remarks1 { get; set; }   //     備考内容（１行目）
        public String Remarks2 { get; set; }   //     備考内容（２行目）

        // 初回以降
        public String NextRentFee  { get; set; }  //家賃（初回以降）
        public Boolean NextRentFeeFlg  { get; set; }  //家賃（初回以降）_表示フラグ
        public String NextManagementFee  { get; set; }  //管理費（初回以降）
        public Boolean NextManagementFeeFlg  { get; set; }  //管理費（初回以降）_表示フラグ
        public String NextParkingFee  { get; set; }  //駐車場代（初回以降）
        public Boolean NextParkingFeeFlg  { get; set; }  //駐車場代（初回以降）_表示フラグ
        public String NextWaterFee  { get; set; }  //水道代（初回以降）
        public Boolean NextWaterFeeFlg  { get; set; }  //水道代（初回以降）_表示フラグ
        public String NextTownshipFee  { get; set; }  //町会費（初回以降）
        public Boolean NextTownshipFeeFlg  { get; set; }  //町会費（初回以降）_表示フラグ
        public String NextCatvFee  { get; set; }  //CATV（初回以降）
        public Boolean NextCatvFeeFlg  { get; set; }  //CATV（初回以降）_表示フラグ
        public String NextGarbageDisposalFee  { get; set; }  //ゴミ処理費（初回以降）
        public Boolean NextGarbageDisposalFeeFlg  { get; set; }  //ゴミ処理費（初回以降）_表示フラグ
        public String NextBicycleParkingFee  { get; set; }  //駐輪場代（初回以降）
        public Boolean NextBicycleParkingFeeFlg  { get; set; }  //駐輪場代（初回以降）_表示フラグ
        public String NextBikeStorageSmallFee  { get; set; }  //バイク置き場代（小型）（初回以降）
        public Boolean NextBikeStorageSmallFeeFlg  { get; set; }  //バイク置き場代（小型）（初回以降）_表示フラグ
        public String NextBikeStorageMediumFee  { get; set; }  //バイク置き場代（中型）（初回以降）
        public Boolean NextBikeStorageMediumFeeFlg  { get; set; }  //バイク置き場代（中型）（初回以降）_表示フラグ
        public String NextBikeStorageLargeFee  { get; set; }  //バイク置き場代（大型）（初回以降）
        public Boolean NextBikeStorageLargeFeeFlg  { get; set; }  //バイク置き場代（大型）（初回以降）_表示フラグ
        public String NextFireInsuranceFee  { get; set; }  //保険料（火災）（初回以降）
        public Boolean NextFireInsuranceFeeFlg  { get; set; }  //保険料（火災）（初回以降）_表示フラグ
        public String NextFeeDeposit  { get; set; }  //保証料（初回以降）
        public Boolean NextFeeDepositFlg  { get; set; }  //保証料（初回以降）_表示フラグ
        //▼問合せNo0496で追加
        public String NextFreeItemName1         { get; set; }      // 自由項目1名称（初回以降）
        public String NextFreeItemFeeTaxType1   { get; set; }      // 自由項目1税区分（初回以降）
        public String NextFreeItemFeeDeposit1   { get; set; }      // 自由項目1料金（初回以降）
        public String NextFreeItemName2         { get; set; }      // 自由項目2名称（初回以降）
        public String NextFreeItemFeeTaxType2   { get; set; }      // 自由項目2税区分（初回以降）
        public String NextFreeItemFeeDeposit2   { get; set; }      // 自由項目2料金（初回以降）
        public String NextFreeItemName3         { get; set; }      // 自由項目3名称（初回以降）
        public String NextFreeItemFeeTaxType3   { get; set; }      // 自由項目3税区分（初回以降）
        public String NextFreeItemFeeDeposit3   { get; set; }      // 自由項目3料金（初回以降）
        public String NextFreeItemName4         { get; set; }      // 自由項目4名称（初回以降）
        public String NextFreeItemFeeTaxType4   { get; set; }      // 自由項目4税区分（初回以降）
        public String NextFreeItemFeeDeposit4   { get; set; }      // 自由項目4料金（初回以降）
        public String NextFreeItemName5         { get; set; }      // 自由項目5名称（初回以降）
        public String NextFreeItemFeeTaxType5   { get; set; }      // 自由項目5税区分（初回以降）
        public String NextFreeItemFeeDeposit5   { get; set; }      // 自由項目5料金（初回以降）
        // PDF用改行設定項目
        public String NextFreeItemName1Pdf      { get; set; }      // PDF出力用自由項目1名称（初回以降）
        public String NextFreeItemName2Pdf      { get; set; }      // PDF出力用自由項目2名称（初回以降）
        public String NextFreeItemName3Pdf      { get; set; }      // PDF出力用自由項目3名称（初回以降）
        public String NextFreeItemName4Pdf      { get; set; }      // PDF出力用自由項目4名称（初回以降）
        public String NextFreeItemName5Pdf      { get; set; }      // PDF出力用自由項目5名称（初回以降）
        //▲問合せNo0496で追加
        public String NextSubTotal  { get; set; }  //小計（初回以降）
        public String NextTax  { get; set; }  //消費税（初回以降）
        public String NextTaxationTarget  { get; set; }  //課税対象（初回以降）
        public String NextTotal  { get; set; }  //合計金額（初回以降）
        public String NextRemarksRenewalFee  { get; set; }  //備考（更新料）（初回以降）
        public String NextRemarksShortTermPenaltyFee  { get; set; }  //備考（短期解約違約金）（初回以降）
        
        // パラメータ
        public Date HomeMovingDate { get;set;}                      // 引越時期
        public Decimal ProratedCalculationDay { get;set;}           // 日割り計算月日数
        public Boolean SavedOutputFlag {get;set;}                   // 保存内容出力フラグ
        public Boolean Proratedflag {get;set;}                      // 日割り計算フラグ
        public Boolean Parkingflag {get;set;}                       // 駐車場フラグ
        public Decimal ParkingNumberRequired {get;set;}             // 駐車場必要数
        public Boolean BicycleParkingFlag {get;set;}                // 駐輪場フラグ
        public Decimal BicycleParkingNumberRequired {get;set;}      // 駐輪場必要数    
        public Boolean BikeParkingSmallFlag {get;set;}              // バイク置き場（小型）フラグ
        public Decimal BikeParkingSmallNumberRequired {get;set;}    // バイク置き場（小型）必要数
        public Decimal BikeParkingSmallFee { get;set;}              // 物件．小型バイク置場料金
        public Boolean BikeParkingMediumFlag {get;set;}             // バイク置き場（中型）フラグ
        public Decimal BikeParkingMediumNumberRequired {get;set;}   // バイク置き場（中型）必要数
        public Decimal BikeParkingMediumFee { get;set;}             // 物件．中型バイク置場料金
        public Boolean BikeParkinLargeFlag {get;set;}               // バイク置き場（大型）フラグ
        public Decimal BikeParkinLargeNumberRequired {get;set;}     // バイク置き場（大型）必要数
        public Decimal BikeParkinLargeFee { get;set;}               // 物件．大型バイク置場料金

        // プライベート変数
        private Map<Id, Item__c> etceteraAuxiliaryItemMap;        // その他付帯商品のマップ

        // 固定表示用
        public String brandName { get{ return SystemConfig__c.getInstance().BrandName__c; } }       // ブランド名

        //コンストラクタ（入力項目から）
        public screenProvisionalQuote(Property__c targetPropertyRecord,Shop__c ShopDate,parameter param,itemdate item,String name){
            init();

            // 　（ヘッダ）
            AccountName = name;       //     取引先名
            Date dtnow = CommonUtil.getToday();
            IssueDate = Datetime.newInstance(dtnow.year(), dtnow.month(), dtnow.day()).format('yyyy年MM月dd日');
            this.CompanyName = ShopDate.CompanyName__c;                 // 会社名
            InvoiceRegistNumber = ShopDate.InvoiceRegistNumber__c;       //     登録番号
            PostalCode = ShopDate.PostalCode__c;       //     〒
            Address = ShopDate.Address__c;       //     住所
            Phone = ShopDate.Phone__c;       //     TEL
            Fax = ShopDate.Fax__c;       //     FAX
            UserName = UserInfo.getName();        //     担当

            PropertyName =   targetPropertyRecord.Building__r.name + '  ' + targetPropertyRecord.name;       //     物件名
            PropertyAddress = targetPropertyRecord.Building__r.Address__c;       //     住居表示
            Datetime dt = Datetime.newInstance(param.HomeMovingDate.year(), param.HomeMovingDate.month(), param.HomeMovingDate.day());
            this.ContractStartDate =  dt.format('yyyy年MM月dd日');      //     契約開始日

            // 課税区分
            this.ManagementFeeTaxType  = targetPropertyRecord.ManagementFeeTaxType__c;   // 管理費税区分
            this.WortFeeTaxType  = targetPropertyRecord.WortFeeTaxType__c;   // 水道料金税区分
            this.TownshipFeeTaxType  = targetPropertyRecord.TownshipFeeTaxType__c;   // 町会費税区分
            this.RenewalFeeTaxType  = targetPropertyRecord.RenewalFeeTaxType__c;   // 更新料税区分
            this.ParkingFeeTaxType  = targetPropertyRecord.ParkingFeeTaxType__c;   // 駐車場料金税区分
            this.ParkingDepositTaxType  = targetPropertyRecord.ParkingDepositTaxType__c;   // 駐車場保証料金税区分
            this.ParkingCompoundingFeeTaxType  = targetPropertyRecord.ParkingCompoundingFeeTaxType__c;   // 駐車場手数料税区分
            this.KeyExchangeFeeTaxType  = targetPropertyRecord.KeyExchangeFeeTaxType__c;   // 鍵交換費税区分
            this.ADFeeTaxType  = targetPropertyRecord.ADFeeTaxType__c;   // 広告料税区分
            this.CATVTaxType  = targetPropertyRecord.CATVTaxType__c;   // CATV税区分
            this.GarbageDisposalFeeTaxType  = targetPropertyRecord.GarbageDisposalFeeTaxType__c;   // ゴミ処理費税区分
            this.BicycleParkingFeeTaxType  = targetPropertyRecord.BicycleParkingFeeTaxType__c;   // 駐輪場代税区分
            this.BikeParkingSmallFeeTaxType  = targetPropertyRecord.BikeParkingSmallFeeTaxType__c;   // 小型バイク置場料金税区分
            this.BikeParkingMediumFeeTaxType  = targetPropertyRecord.BikeParkingMediumFeeTaxType__c;   // 中型バイク置場料金税区分
            this.BikeParkinLargeFeeTaxType  = targetPropertyRecord.BikeParkinLargeFeeTaxType__c;   // 大型バイク置場料金税区分
            this.TownshipInitialFeeTaxType  = targetPropertyRecord.TownshipInitialFeeTaxType__c;   // 入町費税区分
            this.CleaningFeeTaxType  = targetPropertyRecord.CleaningFeeTaxType__c;   // 定額修繕費税区分

            // 支払区分
            this.GarbageDisposalFeePaymentType = targetPropertyRecord.GarbageDisposalFeePaymentType__c; // ゴミ処理支払区分
            this.TownshipFeePaymentType = targetPropertyRecord.TownshipFeePaymentType__c;               // 町会費支払区分

            this.CATVFlg = false;
            this.GarbageDisposalCostsFlg = false;
            this.SecurityDepositFlg = false;
            this.DailyRentFlg = false;
            this.ManagementProratedFeeFlg = false;
            this.DailyAmountTownMembershipFeeFlg = false;
            this.DailyWaterBillFlg = false;
            this.CATVDailyFlg = false;
            this.DailyGarbageDisposalExpensesFlg = false;
            this.DailyBicycleParkingFeeFlg = false;
            this.DailyDiscountParkingLotFlg = false;
            this.BikeStorageFeeSmallDailyDiscountFlg = false;
            this.BikeStorageFeeMediumDailyFlg = false;
            this.BikeStorageFeeLargeDailyDiscountFlg = false;
            this.FireInsurancePremiumDailyFlg = false;
            this.FirstWarrantyFlg = false;
            this.MonthlyFeeDepositflg = false;
            this.MonthlyFeeDepositNextMonthFlg = false;
            this.KeyMoneyFlg = false;            
            this.FixedrateRepairExpensesFlg = false;
            this.EntranceFeeFlg = false;
            this.KeyExchangeCostsFlg = false;
            this.BrokerageFeeFlg = false;

            this.NextFireInsuranceFeeFlg = false;
            this.NextFeeDepositFlg = false; 

            if(param.HomeMovingDate.day() == 1 || !param.Proratedflag){
                // 月初か日割り計算にフラグが立っていない
                ContractNextMonth = param.HomeMovingDate.month().format() +' 月分';   //     契約次月（契約当月）
                // ▼問合せ556で追加
                this.rentFullMonthText = ContractNextMonth;               // 家賃_契約月テキスト(日割り無し)
                this.managementFullMonthText = ContractNextMonth;         // 管理費_契約月テキスト(日割り無し)
                this.townshipFullMonthText = ContractNextMonth;           // 町会費_契約月テキスト(日割り無し)
                this.waterFullMonthText = ContractNextMonth;              // 水道代_契約月テキスト(日割り無し)
                this.catvFullMonthText = ContractNextMonth;               // CATV_契約月テキスト(日割り無し)
                this.garbageDisposalFullMonthText = ContractNextMonth;    // ゴミ処理費_契約月テキスト(日割り無し)
                this.bicycleParkingFullMonthText = ContractNextMonth;     // 駐輪場代_契約月テキスト(日割り無し)
                this.parkingFullMonthText = ContractNextMonth;            // 駐車場代_契約月テキスト(日割り無し)
                this.bikeStorageSmallFullMonthText = ContractNextMonth;   // バイク置き場代（小型）_契約月テキスト(日割り無し)
                this.bikeStorageMediumFullMonthText = ContractNextMonth;  // バイク置き場代（中型）_契約月テキスト(日割り無し)
                this.bikeStorageLargeFullMonthText = ContractNextMonth;   // バイク置き場代（大型）_契約月テキスト(日割り無し)
                this.depositFullMonthText = ContractNextMonth;            // 月額保証料（初回）_契約月テキスト(日割り無し)
                this.fireInsuranceFullMonthText = ContractNextMonth;      // 保険料（火災）_契約月テキスト(日割り無し)
                // ▲問合せ556で追加
            }else if(param.Proratedflag){
                // 日割り分の計算と結果を出力する。

                date Months1 = param.HomeMovingDate.addMonths(1);
                date yestday = Months1.toStartOfMonth().addDays(-1);
                Integer DaysToEnd = (yestday.day() -param.HomeMovingDate.day() + 1);    // [パラメータ．契約開始日 から月末までの日数]

                ContractMonth = param.HomeMovingDate.month().format() +' 月分';   //     契約当月
                ContractPerMonthDailyDays = String.valueOf(DaysToEnd) + ' 日分';
                 
                //▼問合せNo0496で変更
                // ContractNextMonth = String.valueOf(Months1.month()) + ' 月分';  //     契約次月（契約当月） 
                this.RentNextMonthText              = String.valueOf(Months1.month()) + ' 月分';  //  家賃日割時月額項目
                this.ManagementNextMonthText        = String.valueOf(Months1.month()) + ' 月分';  //  管理費日割時月額項目
                this.ParkingNextMonthText           = String.valueOf(Months1.month()) + ' 月分';  //  駐車場代_契約次月テキスト
                this.WaterNextMonthText             = String.valueOf(Months1.month()) + ' 月分';  //  水道代_契約次月テキスト
                this.TownshipNextMonthText          = String.valueOf(Months1.month()) + ' 月分';  //  町会費_契約次月テキスト
                this.CatvNextMonthText              = String.valueOf(Months1.month()) + ' 月分';  //  CATV_契約次月テキスト
                this.GarbageDisposalNextMonthText   = String.valueOf(Months1.month()) + ' 月分';  //  ゴミ処理費_契約次月テキスト
                this.BicycleParkingNextMonthText    = String.valueOf(Months1.month()) + ' 月分';  //  駐輪場代_契約次月テキスト
                this.BikeStorageSmallNextMonthText  = String.valueOf(Months1.month()) + ' 月分';  //  バイク置き場代（小型）_契約次月テキスト
                this.BikeStorageMediumNextMonthText = String.valueOf(Months1.month()) + ' 月分';  //  バイク置き場代（中型）_契約次月テキスト
                this.BikeStorageLargeNextMonthText  = String.valueOf(Months1.month()) + ' 月分';  //  バイク置き場代（大型）日割時月額項目
                this.FireInsuranceNextMonthText     = String.valueOf(Months1.month()) + ' 月分';  //  保険料（火災）_契約次月テキスト
                this.DepositNextMonthText          = String.valueOf(Months1.month()) + ' 月分';  //  月額保証料（初回）_契約次月テキスト
                //▲問合せNo0496で変更
                // ▼問合せ556で追加
                this.rentThisMonthText = ContractMonth + '　　' + ContractPerMonthDailyDays;        // 家賃_契約当月テキスト
                this.managementThisMonthText = ContractMonth + '　　' + ContractPerMonthDailyDays;     // 管理費_契約当月テキスト
                this.townshipThisMonthText = ContractMonth;      // 町会費_契約当月テキスト
                this.waterThisMonthText = ContractMonth;       // 水道代_契約当月テキスト
                this.catvThisMonthText = ContractMonth;       // CATV_契約当月テキスト
                this.garbageDisposalThisMonthText = ContractMonth;    // ゴミ処理費_契約当月テキスト
                this.bicycleParkingThisMonthText = ContractMonth;    // 駐輪場代_契約当月テキスト
                this.parkingThisMonthText = ContractMonth + '　　' + ContractPerMonthDailyDays;    // 駐車場代_契約当月テキスト
                this.bikeStorageSmallThisMonthText = ContractMonth + '　　' + ContractPerMonthDailyDays;    // バイク置き場代（小型）_契約当月テキスト
                this.bikeStorageMediumThisMonthText = ContractMonth + '　　' + ContractPerMonthDailyDays;    // バイク置き場代（中型）_契約当月テキスト
                this.bikeStorageLargeThisMonthText = ContractMonth + '　　' + ContractPerMonthDailyDays;    // バイク置き場代（大型）_契約当月テキスト
                this.depositThisMonthText = ContractMonth;    // 月額保証料（初回）_契約当月テキスト
                this.fireInsuranceThisMonthText = ContractMonth;    // 保険料（火災）_契約当月テキスト
                // ▲問合せ556で追加

                DailyRent = commonUtil.decimalToString(ProratedCalculation(targetPropertyRecord.RentFee__c,param.ProratedCalculationDay,DaysToEnd));   //     家賃日割額
                if(!string.isBlank(DailyRent)){
                    DailyRentFlg = true;
                }
                ManagementProratedFee = commonUtil.decimalToString(ProratedCalculation(targetPropertyRecord.ManagementFee__c,param.ProratedCalculationDay,DaysToEnd));  //     管理費日割額
                if(!string.isBlank(ManagementProratedFee)){
                    ManagementProratedFeeFlg = true;
                }
                
                if(param.BicycleParkingFlag){
                    // 駐輪場代日割額は駐輪場代の金額を日割りせずに表示する。
                    DailyBicycleParkingFee = commonUtil.decimalToString(param.BicycleParkingFee);   //     駐輪場代日割額
                    if(!string.isBlank(DailyBicycleParkingFee)){
                        DailyBicycleParkingFeeFlg = true;
                    }
                }else{
                    DailyBicycleParkingFee = '0';
                    DailyBicycleParkingFeeFlg = false;
                }
                
                if(param.Parkingflag){
                    DailyDiscountParkingLot = commonUtil.decimalToString(ProratedCalculation(param.ParkingFee,param.ProratedCalculationDay,DaysToEnd));   //     駐車場代日割額
                    if(!string.isBlank(DailyDiscountParkingLot)){
                        DailyDiscountParkingLotFlg = true;
                    }    
                }else{
                    DailyDiscountParkingLot = '0';
                    DailyDiscountParkingLotFlg = false;
                }
                
                if(param.BikeParkingSmallFlag){
                    BikeStorageFeeSmallDailyDiscount = commonUtil.decimalToString(ProratedCalculation(param.BikeParkingSmallFee,param.ProratedCalculationDay,DaysToEnd));   //     バイク置き場代（小型）日割額
                    if(!string.isBlank(BikeStorageFeeSmallDailyDiscount)){
                        BikeStorageFeeSmallDailyDiscountFlg = true;
                    }
                }else{
                    BikeStorageFeeSmallDailyDiscount = '0';
                    BikeStorageFeeSmallDailyDiscountFlg = false;
                }

                if(param.BikeParkingMediumFlag){
                    BikeStorageFeeMediumDaily = commonUtil.decimalToString(ProratedCalculation(param.BikeParkingMediumFee,param.ProratedCalculationDay,DaysToEnd));   //     バイク置き場代（中型）日割額
                    if(!string.isBlank(BikeStorageFeeMediumDaily)){
                        BikeStorageFeeMediumDailyFlg = true;
                    }
                }else{
                    BikeStorageFeeMediumDaily = '0';
                    BikeStorageFeeMediumDailyFlg = false;
                }

                if(param.BikeParkinLargeFlag){
                    BikeStorageFeeLargeDailyDiscount = commonUtil.decimalToString(ProratedCalculation(param.BikeParkinLargeFee,param.ProratedCalculationDay,DaysToEnd));   //     バイク置き場代（大型）日割額    
                    if(!string.isBlank(BikeStorageFeeLargeDailyDiscount)){
                        BikeStorageFeeLargeDailyDiscountFlg = true;
                    }
                }else{
                    BikeStorageFeeLargeDailyDiscount = '0';
                    BikeStorageFeeLargeDailyDiscountFlg = false;
                }
                // 本来日割りであった町会費日割額、水道代日割額、CATV日割額、ゴミ処理費日割額、火災保険料日割額を日割りではない通常の項目でセットする
                
                // 月額である場合のみ
                if(this.TownshipFeePaymentType == CommonConst.PROPERTY_PAYMENTTYPE_MONTH ){
                    this.DailyAmountTownMembershipFee = commonUtil.decimalToString(targetPropertyRecord.TownshipFee__c);   //     町会費日割額
                }
                this.DailyWaterBill = commonUtil.decimalToString(targetPropertyRecord.WortFee__c);   //     水道代日割額
                this.CATVDaily = commonUtil.decimalToString(targetPropertyRecord.CATVFee__c);   //     CATV日割額
                
                // 月額である場合のみ
                if(this.GarbageDisposalFeePaymentType == CommonConst.PROPERTY_PAYMENTTYPE_MONTH ){
                    this.DailyGarbageDisposalExpenses = commonUtil.decimalToString(targetPropertyRecord.GarbageDisposalFee__c);   //     ゴミ処理費日割額
                }
                // 火災保険日割は月型のみ金額を設定する。
                if(item.FireInsurance == CommonConst.ITEM_PAYMENTTYPE_MONTH){
                    FireInsurancePremiumDaily = commonUtil.decimalToString(item.FireInsuranceAmount);    //     火災保険料日割額
                }
            
            }

            if(param.CleaningFeeShow != 'null'){
                CleaningFeeShow =  param.CleaningFeeShow; //     定額修繕費名
            }
            
            this.FireInsuranceType = item.FireInsurance;   //     火災保険料金年月区分
            if(this.FireInsuranceType == CommonConst.ITEM_PAYMENTTYPE_MONTH){
                this.FireInsuranceTypeName = CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH;
            }else if(this.FireInsuranceType == CommonConst.ITEM_PAYMENTTYPE_YEAR){
                this.FireInsuranceTypeName = CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR;
            }
            
            // 　（明細情報 金額列）
            Rent = commonUtil.decimalToString(targetPropertyRecord.RentFee__c) ;   //     家賃
            ManagementFee = commonUtil.decimalToString(targetPropertyRecord.ManagementFee__c);   //     管理費
            TownMembershipFee = commonUtil.decimalToString(targetPropertyRecord.TownshipFee__c);   //     町会費
            WaterBill = commonUtil.decimalToString(targetPropertyRecord.WortFee__c);   //     水道代
            CATV = commonUtil.decimalToString(targetPropertyRecord.CATVFee__c);   //     CATV
            GarbageDisposalCosts = commonUtil.decimalToString(targetPropertyRecord.GarbageDisposalFee__c);   //     ゴミ処理費
            if(param.BicycleParkingFlag){
                BicycleparkingFee = commonUtil.decimalToString(param.BicycleParkingFee);   //     駐輪場代
            }else{
                BicycleparkingFee = '0';
            }
            if(param.Parkingflag){
                ParkingFee = commonUtil.decimalToString(param.ParkingFee);   //     駐車場代       
                ParkingBrokerageFee = commonUtil.decimalToString(param.ParkingFee);   //     駐車場紹介料     
                ParkingDeposit = commonUtil.decimalToString(targetPropertyRecord.ParkingDepositYen__c);   //     駐車場保証金
            }else{
                ParkingFee = '0';
                ParkingBrokerageFee = '0';   
                ParkingDeposit = '0';
            }
            

            if(param.BikeParkingSmallFlag){
                BikeStorageSeeDmall = commonUtil.decimalToString(param.BikeParkingSmallFee);   //     バイク置き場代（小型）        
            }else{
                BikeStorageSeeDmall = '0';
            }
            if(param.BikeParkingMediumFlag){
                BikeStorageFeeMediumSize = commonUtil.decimalToString(param.BikeParkingMediumFee);   //     バイク置き場代（中型）        
            }else{
                BikeStorageFeeMediumSize = '0';
            }
            if(param.BikeParkinLargeFlag){
                BikeStorageFeeLarge =  commonUtil.decimalToString(param.BikeParkinLargeFee);   //     バイク置き場代（大型）        
            }else{
                BikeStorageFeeLarge = '0';
            }
            

            SecurityDeposit = commonUtil.decimalToString(targetPropertyRecord.SecurityDepositYen__c);   //     敷金
            Deposit = commonUtil.decimalToString(targetPropertyRecord.DepositYen__c);   //     保証金
            KeyMoney = commonUtil.decimalToString(targetPropertyRecord.KeyMoneyYen__c);   //     礼金
            // 定額修繕費支払区分が入居後ではない場合、金額を設定する。
            if(targetPropertyRecord.CleaningFeePaymentType__c != CommonConst.PROPERTY_PAYMENTTYPE_AFTER_OCCUPANCY){
                FixedrateRepairExpenses = commonUtil.decimalToString(targetPropertyRecord.CleaningFeeYen__c);   //     定額修繕費
            }
            EntranceFee = commonUtil.decimalToString(targetPropertyRecord.TownshipInitialFee__c);   //     入町費
            KeyExchangeCosts = commonUtil.decimalToString(targetPropertyRecord.KeyExchangeFee__c);   //     鍵交換費
            BrokerageFee = commonUtil.decimalToString(targetPropertyRecord.RentFee__c);   //     仲介手数料            
            FireInsurancePremiums = commonUtil.decimalToString(item.FireInsuranceAmount);   //     火災保険料

            //▼問合せNo0496で追加
            // 自由項目
            this.FreeItemName1            ='';  //  項目1名称
            this.FreeItemFeePaymentType1  ='';  //  項目1支払区分
            this.FreeItemFeeTaxType1      ='';  //  項目1税区分
            this.FreeItemFeeDeposit1      ='';  //  項目1料金
            this.FreeItemName2            ='';  //  項目2名称
            this.FreeItemFeePaymentType2  ='';  //  項目2支払区分
            this.FreeItemFeeTaxType2      ='';  //  項目2税区分
            this.FreeItemFeeDeposit2      ='';  //  項目2料金
            this.FreeItemName3            ='';  //  項目3名称
            this.FreeItemFeePaymentType3  ='';  //  項目3支払区分
            this.FreeItemFeeTaxType3      ='';  //  項目3税区分
            this.FreeItemFeeDeposit3      ='';  //  項目3料金
            this.FreeItemName4            ='';  //  項目4名称
            this.FreeItemFeePaymentType4  ='';  //  項目4支払区分
            this.FreeItemFeeTaxType4      ='';  //  項目4税区分
            this.FreeItemFeeDeposit4      ='';  //  項目4料金
            this.FreeItemName5            ='';  //  項目5名称
            this.FreeItemFeePaymentType5  ='';  //  項目5支払区分
            this.FreeItemFeeTaxType5      ='';  //  項目5税区分
            this.FreeItemFeeDeposit5      ='';  //  項目5料金
            //▲問合せNo0496で追加            

            // 集計項目は別で計算する。
            SubtotalAmount = '0';   // 小計金額        
            ConsumptionTax = '0';   // 消費税
            Taxable = '0';  // 課税対象 
            TotalAmount = '0';  // 合計金額

            // 金額が入っているのであれば
            Remarks1 = CommonConst.STRING_EMPTY;
            if(targetPropertyRecord.RenewalFee__c > 0){
                if(param.RenewalFeeShow != 'null'){
                    Remarks1 =  param.RenewalFeeShow ;
                    Remarks1 += commonUtil.decimalToString(targetPropertyRecord.RenewalFee__c)+ '円';
                }                
            }

            // 口座振替手数料の備考設定
            Decimal DirectDebitFee = 0;
            // 手数料税区分により税込み金額を設定するか判断する
            if (item.DirectDebitFeeTaxType == CommonConst.PROPERTY_TAXTYPE_TAXABLE){
                DirectDebitFee = item.DirectDebitFeeTax;
            }else if(item.DirectDebitFeeTaxType == CommonConst.PROPERTY_TAXTYPE_NOTAXABLE) {
                DirectDebitFee = item.DirectDebitFee;
            }
            // 金額が取得できれば口座振替手数料を備考に設定する
            if(DirectDebitFee > 0){
                if(String.isNotBlank(Remarks1)){
                    Remarks1 += '　';
                }
                Remarks1 += '口座振替手数料';
                Remarks1 +=commonUtil.decimalToString(DirectDebitFee)+'円';
            }
            
        
            Remarks2 = CommonConst.STRING_EMPTY;
            if (targetPropertyRecord.IsShortTermPenalty__c == CommonConst.PROPERTY_ISSHORTTERMPENALTY_EXISTS){
                // "短期解約違約金　家賃等の"
                // &短期解約違約金&"ヵ月分"
                // &"("&短期解約違約金未満（年）
                // &"年未満解約)"
                Remarks2 ='短期解約違約金';

                if((targetPropertyRecord.ShortTermPenaltyFee__c != null && targetPropertyRecord.ShortTermPenaltyFee__c != 0 ) &&
                   (targetPropertyRecord.ShortTermPenaltyLessYear__c != null && targetPropertyRecord.ShortTermPenaltyLessYear__c != 0 )){
                    Remarks2 +='　家賃等の';
                    Remarks2 += targetPropertyRecord.ShortTermPenaltyFee__c + 'ヵ月分'
                             + '(' +  targetPropertyRecord.ShortTermPenaltyLessYear__c + '年未満解約)';
                }
                if((targetPropertyRecord.ShortTermPenaltyFee2__c != null && targetPropertyRecord.ShortTermPenaltyFee2__c != 0 ) &&
                   (targetPropertyRecord.ShortTermPenaltyLessYear2__c != null && targetPropertyRecord.ShortTermPenaltyLessYear2__c != 0 )){
                    Remarks2 +='　家賃等の';
                    Remarks2 += targetPropertyRecord.ShortTermPenaltyFee2__c + 'ヵ月分'
                             + '(' +  targetPropertyRecord.ShortTermPenaltyLessYear2__c + '年未満解約)';
                }
            }
             
            // 初回以降の設定
            this.NextRentFee  = commonUtil.decimalToString(targetPropertyRecord.RentFee__c);  //家賃（初回以降）
            this.NextManagementFee  = commonUtil.decimalToString(targetPropertyRecord.ManagementFee__c);  //管理費（初回以降）
            this.NextWaterFee  = commonUtil.decimalToString(targetPropertyRecord.WortFee__c);  //水道代（初回以降）               
            // 月額である場合のみ
            if(this.TownshipFeePaymentType == CommonConst.PROPERTY_PAYMENTTYPE_MONTH ){
                this.NextTownshipFee  = commonUtil.decimalToString(targetPropertyRecord.TownshipFee__c);  //町会費（初回以降）
            }
            this.NextCatvFee  = commonUtil.decimalToString(targetPropertyRecord.CATVFee__c);  //CATV（初回以降）
            // 月額である場合のみ
            if(this.GarbageDisposalFeePaymentType == CommonConst.PROPERTY_PAYMENTTYPE_MONTH ){
                this.NextGarbageDisposalFee  = commonUtil.decimalToString(targetPropertyRecord.GarbageDisposalFee__c);  //ゴミ処理費（初回以降）
            }
            if(param.BicycleParkingFlag){
                NextBicycleParkingFee = commonUtil.decimalToString(param.BicycleParkingFee);   //     駐輪場代
            }else{
                NextBicycleParkingFee = '0';
            }
            if(param.Parkingflag){
                NextParkingFee = commonUtil.decimalToString(param.ParkingFee);   //     駐車場代            
            }else{
                NextParkingFee = '0';
            }

            if(param.BikeParkingSmallFlag){
                NextBikeStorageSmallFee = commonUtil.decimalToString(param.BikeParkingSmallFee);   //バイク置き場代（小型）（初回以降）
            }else{
                NextBikeStorageSmallFee = '0';
            }
            if(param.BikeParkingMediumFlag){
                NextBikeStorageMediumFee = commonUtil.decimalToString(param.BikeParkingMediumFee);   //バイク置き場代（中型）（初回以降）
            }else{
                NextBikeStorageMediumFee = '0';
            }
            if(param.BikeParkinLargeFlag){
                NextBikeStorageLargeFee =  commonUtil.decimalToString(param.BikeParkinLargeFee);   //     バイク置き場代（大型）        
            }else{
                NextBikeStorageLargeFee = '0';
            }

            if(item.FireInsurance == CommonConst.ITEM_PAYMENTTYPE_MONTH){
                // 火災保険が月型のみ金額をセットする。
                this.NextFireInsuranceFee  = commonUtil.decimalToString(item.FireInsuranceAmount);  //保険料（火災）（初回以降）
            }

            this.NextSubTotal  = '0';  //小計（初回以降）
            this.NextTax  = '0';  //消費税（初回以降）
            this.NextTaxationTarget  = '0';  //課税対象（初回以降）
            this.NextTotal  = '';  //合計金額（初回以降）

            // 金額が入っているのであれば
            NextRemarksRenewalFee = CommonConst.STRING_EMPTY;
            if(targetPropertyRecord.RenewalFee__c > 0){
                if( param.RenewalFeeShow != 'null'){
                    NextRemarksRenewalFee = param.RenewalFeeShow;
                    NextRemarksRenewalFee += commonUtil.decimalToString(targetPropertyRecord.RenewalFee__c)+ '円';
                }                
                
            }
            // 金額が取得できれば口座振替手数料を備考に設定する
            if(DirectDebitFee > 0){
                if(String.isNotBlank(NextRemarksRenewalFee)){
                    NextRemarksRenewalFee += '　';
                }
                NextRemarksRenewalFee += '口座振替手数料';
                NextRemarksRenewalFee +=commonUtil.decimalToString(DirectDebitFee)+'円';
            }

            NextRemarksShortTermPenaltyFee = CommonConst.STRING_EMPTY;            
            if (targetPropertyRecord.IsShortTermPenalty__c == CommonConst.PROPERTY_ISSHORTTERMPENALTY_EXISTS){
                // "短期解約違約金　家賃等の"
                // &短期解約違約金&"ヵ月分"
                // &"("&短期解約違約金未満（年）
                // &"年未満解約)"
                // NextRemarksShortTermPenaltyFee ='短期解約違約金　家賃等の'
                //          + targetPropertyRecord.ShortTermPenaltyFee__c + 'ヵ月分'
                //          + '(' +  targetPropertyRecord.ShortTermPenaltyLessYear__c + '年未満解約)';
                NextRemarksShortTermPenaltyFee ='短期解約違約金';
                
                if((targetPropertyRecord.ShortTermPenaltyFee__c != null && targetPropertyRecord.ShortTermPenaltyFee__c != 0 ) &&
                   (targetPropertyRecord.ShortTermPenaltyLessYear__c != null && targetPropertyRecord.ShortTermPenaltyLessYear__c != 0 )){
                    NextRemarksShortTermPenaltyFee +='　家賃等の';
                    NextRemarksShortTermPenaltyFee += targetPropertyRecord.ShortTermPenaltyFee__c + 'ヵ月分'
                             + '(' +  targetPropertyRecord.ShortTermPenaltyLessYear__c + '年未満解約)';
                }
                if((targetPropertyRecord.ShortTermPenaltyFee2__c != null && targetPropertyRecord.ShortTermPenaltyFee2__c != 0 ) &&
                   (targetPropertyRecord.ShortTermPenaltyLessYear2__c != null && targetPropertyRecord.ShortTermPenaltyLessYear2__c != 0 )){
                    NextRemarksShortTermPenaltyFee +='　家賃等の';
                    NextRemarksShortTermPenaltyFee += targetPropertyRecord.ShortTermPenaltyFee2__c + 'ヵ月分'
                             + '(' +  targetPropertyRecord.ShortTermPenaltyLessYear2__c + '年未満解約)';
                }
            }

            this.HomeMovingDate = param.HomeMovingDate;                      // 引越時期
            this.ProratedCalculationDay = param.ProratedCalculationDay;           // 日割り計算月日数
            this.Proratedflag = param.Proratedflag;                      // 日割り計算フラグ
            this.Parkingflag = param.Parkingflag;                       // 駐車場フラグ
            this.ParkingNumberRequired = param.ParkingNumberRequired;             // 駐車場必要数
            this.BicycleParkingFlag = param.BicycleParkingFlag;                // 駐輪場フラグ
            this.BicycleParkingNumberRequired = param.BicycleParkingNumberRequired;      // 駐輪場必要数    
            this.BikeParkingSmallFlag = param.BikeParkingSmallFlag;              // バイク置き場（小型）フラグ
            this.BikeParkingSmallNumberRequired = param.BikeParkingSmallNumberRequired;    // バイク置き場（小型）必要数
            this.BikeParkingSmallFee = param.BikeParkingSmallFee;              // 物件．小型バイク置場料金
            this.BikeParkingMediumFlag = param.BikeParkingMediumFlag;             // バイク置き場（中型）フラグ
            this.BikeParkingMediumNumberRequired = param.BikeParkingMediumNumberRequired;   // バイク置き場（中型）必要数
            this.BikeParkingMediumFee = param.BikeParkingMediumFee;             // 物件．中型バイク置場料金
            this.BikeParkinLargeFlag = param.BikeParkinLargeFlag;               // バイク置き場（大型）フラグ
            this.BikeParkinLargeNumberRequired = param.BikeParkinLargeNumberRequired;     // バイク置き場（大型）必要数
            this.BikeParkinLargeFee = param.BikeParkinLargeFee;               // 物件．大型バイク置場料金
            //▼問合せNo0496で追加
            this.NextFreeItemName1        = '';    // 項目1名称（初回以降）
            this.NextFreeItemFeeTaxType1  = '';    // 項目1税区分（初回以降）
            this.NextFreeItemFeeDeposit1  = '';    // 項目1料金（初回以降）
            this.NextFreeItemName2        = '';    // 項目2名称（初回以降）
            this.NextFreeItemFeeTaxType2  = '';    // 項目2税区分（初回以降）
            this.NextFreeItemFeeDeposit2  = '';    // 項目2料金（初回以降）
            this.NextFreeItemName3        = '';    // 項目3名称（初回以降）
            this.NextFreeItemFeeTaxType3  = '';    // 項目3税区分（初回以降）
            this.NextFreeItemFeeDeposit3  = '';    // 項目3料金（初回以降）
            this.NextFreeItemName4        = '';    // 項目4名称（初回以降）
            this.NextFreeItemFeeTaxType4  = '';    // 項目4税区分（初回以降）
            this.NextFreeItemFeeDeposit4  = '';    // 項目4料金（初回以降）
            this.NextFreeItemName5        = '';    // 項目5名称（初回以降）
            this.NextFreeItemFeeTaxType5  = '';    // 項目5税区分（初回以降）
            this.NextFreeItemFeeDeposit5  = '';    // 項目5料金（初回以降）
            //▲問合せNo0496で追加

            this.RentFlg = displayFlg(this.Rent,this.DailyRent);
            this.ManagementFeeFlg = displayFlg(this.ManagementFee,this.ManagementProratedFee);
            this.TownMembershipFeeFlg = displayFlg(this.TownMembershipFee,this.DailyAmountTownMembershipFee);   // 町会費表示フラグ
            this.DailyAmountTownMembershipFeeFlg = displayFlg(this.DailyAmountTownMembershipFee,'');    // 町会費日割り表示フラグ
            this.WaterBillFlg = displayFlg(this.WaterBill,this.DailyWaterBill); // 水道代表示フラグ
            this.DailyWaterBillFlg = displayFlg(this.DailyWaterBill,'');           // 水道代日割り表示フラグ

            this.CATVFlg = displayFlg(this.CATV,this.CATVDaily);    // CATV表示フラグ 
            this.CATVDailyFlg = displayFlg(this.CATVDaily,'');    // CATV日割り表示フラグ
            this.GarbageDisposalCostsFlg = displayFlg(this.GarbageDisposalCosts,this.DailyGarbageDisposalExpenses);     //ゴミ処理費表示フラグ
            this.DailyGarbageDisposalExpensesFlg = displayFlg(this.DailyGarbageDisposalExpenses,'');                    //ゴミ処理費日割額表示フラグ
            this.SecurityDepositFlg = displayFlg(this.SecurityDeposit,'');
            this.DepositFlg = displayFlg(this.Deposit,'');//     保証金
            this.KeyMoneyFlg = displayFlg(this.KeyMoney,'');//     礼金.
            this.FixedrateRepairExpensesFlg = displayFlg(this.FixedrateRepairExpenses,'');//     定額修繕費
            this.EntranceFeeFlg = displayFlg(this.EntranceFee,'');//     入町費
            this.KeyExchangeCostsFlg = displayFlg(this.KeyExchangeCosts,'');//     鍵交換費
            this.BrokerageFeeFlg = displayFlg(this.BrokerageFee,'');//     仲介手数料
            this.FireInsurancePremiumsFlg = displayFlg(this.FireInsurancePremiums,this.FireInsurancePremiumDaily);//     火災保険料表示フラグ
            this.FireInsurancePremiumDailyFlg = displayFlg(this.FireInsurancePremiumDaily,'');//     火災保険料日割り表示フラグ


            
            this.ParkingBrokerageFeeFlg = displayFlg(this.ParkingBrokerageFee,'');//駐車場紹介料表示フラグ

            
            this.BicycleparkingFeeFlg = displayFlg(this.BicycleparkingFee,this.DailyBicycleParkingFee);
            this.ParkingFeeFlg = displayFlg(this.ParkingFee,this.DailyDiscountParkingLot);
            this.BikeStorageSeeDmallFlg = displayFlg(this.BikeStorageSeeDmall,this.BikeStorageFeeSmallDailyDiscount);
            this.BikeStorageFeeMediumSizeFlg = displayFlg(this.BikeStorageFeeMediumSize,this.BikeStorageFeeMediumDaily);
            this.BikeStorageFeeLargeFlg = displayFlg(this.BikeStorageFeeLarge,this.BikeStorageFeeLargeDailyDiscount);
            this.AmountGoodsSpecifiedManagementCompanyFlg = displayFlg(this.AmountGoodsSpecifiedManagementCompany,this.DailyAmountProductsDesignatedManagementCompany);
            this.ParkingDepositFlg = displayFlg(this.ParkingDeposit,'');

            // 初回以降
            this.NextRentFeeFlg = displayFlg(this.NextRentFee,'');  //家賃（初回以降）_表示フラグ
            this.NextManagementFeeFlg =  displayFlg(this.NextManagementFee,'');  //管理費（初回以降）_表示フラグ
            this.NextParkingFeeFlg =  displayFlg(this.NextParkingFee,'');  //駐車場代（初回以降）_表示フラグ
            this.NextWaterFeeFlg =  displayFlg(this.NextWaterFee,'');  //水道代（初回以降）_表示フラグ
            this.NextTownshipFeeFlg =  displayFlg(this.NextTownshipFee,'');  //町会費（初回以降）_表示フラグ
            this.NextCatvFeeFlg =  displayFlg(this.NextCatvFee,'');  //CATV（初回以降）_表示フラグ
            this.NextGarbageDisposalFeeFlg =  displayFlg(this.NextGarbageDisposalFee,'');  //ゴミ処理費（初回以降）_表示フラグ
            this.NextBicycleParkingFeeFlg =  displayFlg(this.NextBicycleParkingFee,'');  //駐輪場代（初回以降）_表示フラグ
            this.NextBikeStorageSmallFeeFlg =  displayFlg(this.NextBikeStorageSmallFee,'');  //バイク置き場代（小型）（初回以降）_表示フラグ
            this.NextBikeStorageMediumFeeFlg =  displayFlg(this.NextBikeStorageMediumFee,'');  //バイク置き場代（中型）（初回以降）_表示フラグ
            this.NextBikeStorageLargeFeeFlg =  displayFlg(this.NextBikeStorageLargeFee,'');  //バイク置き場代（大型）（初回以降）_表示フラグ
            if(item.FireInsurance == CommonConst.ITEM_PAYMENTTYPE_MONTH){
                // 火災保険が月型のみフラグを変える
                this.NextFireInsuranceFeeFlg = displayFlg(this.NextFireInsuranceFee,'');//保険料（火災）（初回以降）
            }

            // その他付帯商品
            setEtceteraAuxiliaryItemList(param.etceteraAuxiliaryItemList);
        }

        // 仮見積から
        public screenProvisionalQuote(ProvisionalQuote__c targetProvisionalQuoteRecord,Shop__c ShopDate,itemdate item){
            init();

            Id = targetProvisionalQuoteRecord.id;
            SystemModstamp = targetProvisionalQuoteRecord.SystemModstamp;
            // 　（ヘッダ）
            AccountName = targetProvisionalQuoteRecord.Account__r.Name;       //     取引先名
            Date dtnow = CommonUtil.getToday();
            IssueDate = Datetime.newInstance(dtnow.year(), dtnow.month(), dtnow.day()).format('yyyy年MM月dd日');
            this.CompanyName = ShopDate.CompanyName__c;                 // 会社名
            InvoiceRegistNumber = ShopDate.InvoiceRegistNumber__c;       //     登録番号
            PostalCode = ShopDate.PostalCode__c;       //     〒
            Address =  ShopDate.Address__c;       //     住所
            Phone = ShopDate.Phone__c;       //     TEL
            Fax = ShopDate.Fax__c;       //     FAX
            UserName = UserInfo.getName();        //     担当
            PropertyName =   targetProvisionalQuoteRecord.Property__r.Building__r.name + '  ' + targetProvisionalQuoteRecord.Property__r.name;       //     物件名
            PropertyAddress = targetProvisionalQuoteRecord.Property__r.Building__r.Address__c;       //     住居表示
            Datetime dt = targetProvisionalQuoteRecord.ContractStartDate__c;
            ContractStartDate =  dt.format('yyyy年MM月dd日');      //     契約開始日
            // 課税区分
            ManagementFeeTaxType  = targetProvisionalQuoteRecord.Property__r.ManagementFeeTaxType__c;   // 管理費税区分
            WortFeeTaxType  = targetProvisionalQuoteRecord.Property__r.WortFeeTaxType__c;   // 水道料金税区分
            TownshipFeeTaxType  = targetProvisionalQuoteRecord.Property__r.TownshipFeeTaxType__c;   // 町会費税区分
            RenewalFeeTaxType  = targetProvisionalQuoteRecord.Property__r.RenewalFeeTaxType__c;   // 更新料税区分
            ParkingFeeTaxType  = targetProvisionalQuoteRecord.Property__r.ParkingFeeTaxType__c;   // 駐車場料金税区分
            ParkingDepositTaxType  = targetProvisionalQuoteRecord.Property__r.ParkingDepositTaxType__c;   // 駐車場保証料金税区分
            ParkingCompoundingFeeTaxType  = targetProvisionalQuoteRecord.Property__r.ParkingCompoundingFeeTaxType__c;   // 駐車場手数料税区分
            KeyExchangeFeeTaxType  = targetProvisionalQuoteRecord.Property__r.KeyExchangeFeeTaxType__c;   // 鍵交換費税区分
            ADFeeTaxType  = targetProvisionalQuoteRecord.Property__r.ADFeeTaxType__c;   // 広告料税区分
            CATVTaxType  = targetProvisionalQuoteRecord.Property__r.CATVTaxType__c;   // CATV税区分
            GarbageDisposalFeeTaxType  = targetProvisionalQuoteRecord.Property__r.GarbageDisposalFeeTaxType__c;   // ゴミ処理費税区分
            BicycleParkingFeeTaxType  = targetProvisionalQuoteRecord.Property__r.BicycleParkingFeeTaxType__c;   // 駐輪場代税区分
            BikeParkingSmallFeeTaxType  = targetProvisionalQuoteRecord.Property__r.BikeParkingSmallFeeTaxType__c;   // 小型バイク置場料金税区分
            BikeParkingMediumFeeTaxType  = targetProvisionalQuoteRecord.Property__r.BikeParkingMediumFeeTaxType__c;   // 中型バイク置場料金税区分
            BikeParkinLargeFeeTaxType  = targetProvisionalQuoteRecord.Property__r.BikeParkinLargeFeeTaxType__c;   // 大型バイク置場料金税区分
            TownshipInitialFeeTaxType  = targetProvisionalQuoteRecord.Property__r.TownshipInitialFeeTaxType__c;   // 入町費税区分
            CleaningFeeTaxType  = targetProvisionalQuoteRecord.Property__r.CleaningFeeTaxType__c;   // 定額修繕費税区分

            // 支払区分
            this.GarbageDisposalFeePaymentType = targetProvisionalQuoteRecord.Property__r.GarbageDisposalFeePaymentType__c; // ゴミ処理支払区分
            this.TownshipFeePaymentType = targetProvisionalQuoteRecord.Property__r.TownshipFeePaymentType__c;               // 町会費支払区分

            this.CATVFlg = false;
            this.GarbageDisposalCostsFlg = false;
            this.SecurityDepositFlg = false;
            this.DailyRentFlg = false;
            this.DepositFlg = false;
            this.FireInsurancePremiumsFlg = false;
            this.ManagementProratedFeeFlg = false;
            this.DailyAmountTownMembershipFeeFlg = false;
            this.DailyWaterBillFlg = false;
            this.CATVDailyFlg = false;
            this.DailyGarbageDisposalExpensesFlg = false;
            this.DailyBicycleParkingFeeFlg = false;
            this.DailyDiscountParkingLotFlg = false;
            this.BikeStorageFeeSmallDailyDiscountFlg = false;
            this.BikeStorageFeeMediumDailyFlg = false;
            this.BikeStorageFeeLargeDailyDiscountFlg = false;
            this.FireInsurancePremiumDailyFlg = false;
            this.FirstWarrantyFlg = false;
            this.MonthlyFeeDepositflg = false;
            this.MonthlyFeeDepositNextMonthFlg = false;
            this.KeyMoneyFlg = false;
            this.FixedrateRepairExpensesFlg = false;
            this.EntranceFeeFlg = false;
            this.KeyExchangeCostsFlg = false;
            this.BrokerageFeeFlg = false;

            this.NextFireInsuranceFeeFlg = false;
            this.NextFeeDepositFlg = false; 

            if(targetProvisionalQuoteRecord.ContractStartDate__c.day() == 1 || !targetProvisionalQuoteRecord.IsProrated__c){
                // 月初か日割り計算にフラグが経っている場合日割りを表示させない
                ContractNextMonth = targetProvisionalQuoteRecord.ContractStartDate__c.month().format() +' 月分';   //     契約次月（契約当月）

            }else if(targetProvisionalQuoteRecord.IsProrated__c){
                // 日割り分の計算と結果を出力する。

                date Months1 = targetProvisionalQuoteRecord.ContractStartDate__c.addMonths(1);
                date yestday = Months1.toStartOfMonth().addDays(-1);
                Integer DaysToEnd = (yestday.day() -targetProvisionalQuoteRecord.ContractStartDate__c.day()) + 1;    // [パラメータ．契約開始日 から月末までの日数]

                ContractMonth = targetProvisionalQuoteRecord.ContractStartDate__c.month().format() +' 月分';   //     契約当月
                ContractPerMonthDailyDays = String.valueOf(DaysToEnd) + ' 日分';
                ContractNextMonth = String.valueOf(Months1.month()) + ' 月分';  //     契約次月（契約当月）  
                DailyRent = commonUtil.decimalToString(targetProvisionalQuoteRecord.RentProratedFee__c);   //     家賃日割額
                //▼問合せNo0496で変更
                this.RentNextMonthText              = targetProvisionalQuoteRecord.RentNextMonthText__c;                //  家賃_契約次月テキスト
                this.ManagementNextMonthText        = targetProvisionalQuoteRecord.ManagementNextMonthText__c;          //  管理費_契約次月テキスト
                this.ParkingNextMonthText           = targetProvisionalQuoteRecord.ParkingNextMonthText__c;             //  駐車場代_契約次月テキスト
                this.WaterNextMonthText             = targetProvisionalQuoteRecord.WaterNextMonthText__c;               //  水道代_契約次月テキスト
                this.TownshipNextMonthText          = targetProvisionalQuoteRecord.TownshipNextMonthText__c;            //  町会費_契約次月テキスト
                this.CatvNextMonthText              = targetProvisionalQuoteRecord.CatvNextMonthText__c;                //  CATV_契約次月テキスト
                this.GarbageDisposalNextMonthText   = targetProvisionalQuoteRecord.GarbageDisposalNextMonthText__c;     //  ゴミ処理費_契約次月テキスト
                this.BicycleParkingNextMonthText    = targetProvisionalQuoteRecord.BicycleParkingNextMonthText__c;      //  駐輪場代_契約次月テキスト
                this.BikeStorageSmallNextMonthText  = targetProvisionalQuoteRecord.BikeStorageSmallNextMonthText__c;    //  バイク置き場代（小型）_契約次月テキスト
                this.BikeStorageMediumNextMonthText = targetProvisionalQuoteRecord.BikeStorageMediumNextMonthText__c;   //  バイク置き場代（中型）_契約次月テキスト
                this.BikeStorageLargeNextMonthText  = targetProvisionalQuoteRecord.BikeStorageLargeNextMonthText__c;    //  バイク置き場代（大型）日割時月額項目
                this.FireInsuranceNextMonthText     = targetProvisionalQuoteRecord.FireInsuranceNextMonthText__c;       //  保険料（火災）_契約次月テキスト
                this.DepositNextMonthText           = targetProvisionalQuoteRecord.DepositNextMonthText__c;             // 月額保証料（初回）_契約次月テキスト

                this.RentNextMonthTextPdf              = targetProvisionalQuoteRecord.RentNextMonthText__c;    //  PDF出力用家賃_契約次月テキスト
                this.ManagementNextMonthTextPdf        = targetProvisionalQuoteRecord.ManagementNextMonthText__c;    //  PDF出力用管理費_契約次月テキスト
                this.ParkingNextMonthTextPdf           = targetProvisionalQuoteRecord.ParkingNextMonthText__c;    //  PDF出力用駐車場代_契約次月テキスト
                this.WaterNextMonthTextPdf             = targetProvisionalQuoteRecord.WaterNextMonthText__c;    //  PDF出力用水道代_契約次月テキスト
                this.TownshipNextMonthTextPdf          = targetProvisionalQuoteRecord.TownshipNextMonthText__c;    //  PDF出力用町会費_契約次月テキスト
                this.CatvNextMonthTextPdf              = targetProvisionalQuoteRecord.CatvNextMonthText__c;    //  PDF出力用CATV_契約次月テキスト
                this.GarbageDisposalNextMonthTextPdf   = targetProvisionalQuoteRecord.GarbageDisposalNextMonthText__c;    //  PDF出力用ゴミ処理費_契約次月テキスト
                this.BicycleParkingNextMonthTextPdf    = targetProvisionalQuoteRecord.BicycleParkingNextMonthText__c;    //  PDF出力用駐輪場代_契約次月テキスト
                this.BikeStorageSmallNextMonthTextPdf  = targetProvisionalQuoteRecord.BikeStorageSmallNextMonthText__c;    //  PDF出力用バイク置き場代（小型）_契約次月テキスト
                this.BikeStorageMediumNextMonthTextPdf = targetProvisionalQuoteRecord.BikeStorageMediumNextMonthText__c;    //  PDF出力用バイク置き場代（中型）_契約次月テキスト
                this.BikeStorageLargeNextMonthTextPdf  = targetProvisionalQuoteRecord.BikeStorageLargeNextMonthText__c;    //  PDF出力用バイク置き場代（大型）日割時月額項目
                this.FireInsuranceNextMonthTextPdf     = targetProvisionalQuoteRecord.FireInsuranceNextMonthText__c;    //  PDF出力用保険料（火災）_契約次月テキスト
                this.DepositNextMonthTextPdf           = targetProvisionalQuoteRecord.DepositNextMonthText__c;    //  PDF出力用月額保証料（初回）_契約次月テキスト

                //▲問合せNo0496で変更

                if(!string.isBlank(DailyRent)){
                    DailyRentFlg = true;
                }
                ManagementProratedFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.ManagementProratedFee__c);  //     管理費日割額
                if(!string.isBlank(ManagementProratedFee)){
                    ManagementProratedFeeFlg = true;
                }

                DailyBicycleParkingFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.BicycleParkingProratedFee__c);   //     駐輪場代日割額
                if(!string.isBlank(DailyBicycleParkingFee)){
                    DailyBicycleParkingFeeFlg = true;
                }
                DailyDiscountParkingLot = commonUtil.decimalToString(targetProvisionalQuoteRecord.ParkingProratedFee__c);   //     駐車場代日割額   
                if(!string.isBlank(DailyDiscountParkingLot)){
                    DailyDiscountParkingLotFlg = true;
                }     
                BikeStorageFeeSmallDailyDiscount = commonUtil.decimalToString(targetProvisionalQuoteRecord.BikeStorageSmallProratedFee__c);   //     バイク置き場代（小型）日割額
                if(!string.isBlank(BikeStorageFeeSmallDailyDiscount)){
                    BikeStorageFeeSmallDailyDiscountFlg = true;
                }
                BikeStorageFeeMediumDaily = commonUtil.decimalToString(targetProvisionalQuoteRecord.BikeStorageMediumProratedFee__c);   //     バイク置き場代（中型）日割額
                if(!string.isBlank(BikeStorageFeeMediumDaily)){
                    BikeStorageFeeMediumDailyFlg = true;
                }
                BikeStorageFeeLargeDailyDiscount = commonUtil.decimalToString(targetProvisionalQuoteRecord.BikeStorageLargeProratedFee__c);   //     バイク置き場代（大型）日割額    
                if(!string.isBlank(BikeStorageFeeLargeDailyDiscount)){
                    BikeStorageFeeLargeDailyDiscountFlg = true;
                }
                // 本来日割りであった町会費日割額、水道代日割額、CATV日割額、ゴミ処理費日割額、火災保険料日割額を通常と同様に設定する。
                // 月額である場合のみ
                if(this.TownshipFeePaymentType == CommonConst.PROPERTY_PAYMENTTYPE_MONTH ){
                    DailyAmountTownMembershipFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.TownshipProratedFee__c);   //     町会費日割額
                }
                DailyWaterBill = commonUtil.decimalToString(targetProvisionalQuoteRecord.WaterProratedFee__c);   //     水道代日割額
                CATVDaily = commonUtil.decimalToString(targetProvisionalQuoteRecord.CatvProratedFee__c);   //     CATV日割額
                                
                // 月額である場合のみ
                if(this.GarbageDisposalFeePaymentType == CommonConst.PROPERTY_PAYMENTTYPE_MONTH ){
                    DailyGarbageDisposalExpenses = commonUtil.decimalToString(targetProvisionalQuoteRecord.GarbageDisposalProratedFee__c);   //     ゴミ処理費日割額
                }
                if(targetProvisionalQuoteRecord.FireInsuranceItem__r.PaymentType__c == CommonConst.ITEM_PAYMENTTYPE_MONTH){
                    FireInsurancePremiumDaily = commonUtil.decimalToString(targetProvisionalQuoteRecord.FireInsuranceProratedFee__c);   //     火災保険料日割額
                }
            }

            // ▼問合せ556で追加
            this.rentThisMonthText              = targetProvisionalQuoteRecord.RentThisMonthText__c;                //  家賃_契約当月テキスト
            this.managementThisMonthText        = targetProvisionalQuoteRecord.ManagementThisMonthText__c;          //  管理費_契約当月テキスト
            this.parkingThisMonthText           = targetProvisionalQuoteRecord.ParkingThisMonthText__c;             //  駐車場代_契約当月テキスト
            this.waterThisMonthText             = targetProvisionalQuoteRecord.WaterThisMonthText__c;               //  水道代_契約当月テキスト
            this.townshipThisMonthText          = targetProvisionalQuoteRecord.TownshipThisMonthText__c;            //  町会費_契約当月テキスト
            this.catvThisMonthText              = targetProvisionalQuoteRecord.CatvThisMonthText__c;                //  CATV_契約当月テキスト
            this.garbageDisposalThisMonthText   = targetProvisionalQuoteRecord.GarbageDisposalThisMonthText__c;     //  ゴミ処理費_契約当月テキスト
            this.bicycleParkingThisMonthText    = targetProvisionalQuoteRecord.BicycleParkingThisMonthText__c;      //  駐輪場代_契約当月テキスト
            this.bikeStorageSmallThisMonthText  = targetProvisionalQuoteRecord.BikeStorageSmallThisMonthText__c;    //  バイク置き場代（小型）_契約当月テキスト
            this.bikeStorageMediumThisMonthText = targetProvisionalQuoteRecord.BikeStorageMediumThisMonthText__c;   //  バイク置き場代（中型）_契約当月テキスト
            this.bikeStorageLargeThisMonthText  = targetProvisionalQuoteRecord.BikeStorageLargeThisMonthText__c;    //  バイク置き場代（大型）_契約当月テキスト
            this.fireInsuranceThisMonthText     = targetProvisionalQuoteRecord.FireInsuranceThisMonthText__c;       //  保険料（火災）_契約当月テキスト
            this.depositThisMonthText           = targetProvisionalQuoteRecord.DepositThisMonthText__c;             //  月額保証料（初回）_契約当月テキスト

            this.rentFullMonthText              = targetProvisionalQuoteRecord.RentFullMonthText__c;               // 家賃_契約月テキスト(日割り無し)
            this.managementFullMonthText        = targetProvisionalQuoteRecord.ManagementFullMonthText__c;         // 管理費_契約月テキスト(日割り無し)
            this.townshipFullMonthText          = targetProvisionalQuoteRecord.TownshipFullMonthText__c;           // 町会費_契約月テキスト(日割り無し)
            this.waterFullMonthText             = targetProvisionalQuoteRecord.WaterFullMonthText__c;              // 水道代_契約月テキスト(日割り無し)
            this.catvFullMonthText              = targetProvisionalQuoteRecord.CatvFullMonthText__c;               // CATV_契約月テキスト(日割り無し)
            this.garbageDisposalFullMonthText   = targetProvisionalQuoteRecord.GarbageDisposalFullMonthText__c;    // ゴミ処理費_契約月テキスト(日割り無し)
            this.bicycleParkingFullMonthText    = targetProvisionalQuoteRecord.BicycleParkingFullMonthText__c;     // 駐輪場代_契約月テキスト(日割り無し)
            this.parkingFullMonthText           = targetProvisionalQuoteRecord.ParkingFullMonthText__c;            // 駐車場代_契約月テキスト(日割り無し)
            this.bikeStorageSmallFullMonthText  = targetProvisionalQuoteRecord.BikeStorageSmallFullMonthText__c;   // バイク置き場代（小型）_契約月テキスト(日割り無し)
            this.bikeStorageMediumFullMonthText = targetProvisionalQuoteRecord.BikeStorageMediumFullMonthText__c;  // バイク置き場代（中型）_契約月テキスト(日割り無し)
            this.bikeStorageLargeFullMonthText  = targetProvisionalQuoteRecord.BikeStorageLargeFullMonthText__c;   // バイク置き場代（大型）_契約月テキスト(日割り無し)
            this.depositFullMonthText           = targetProvisionalQuoteRecord.DepositFullMonthText__c;            // 月額保証料（初回）_契約月テキスト(日割り無し)
            this.fireInsuranceFullMonthText     = targetProvisionalQuoteRecord.FireInsuranceFullMonthText__c;      // 保険料（火災）_契約月テキスト(日割り無し)

            this.rentThisMonthTextPdf              = targetProvisionalQuoteRecord.RentThisMonthText__c;                //  PDF出力用家賃_契約当月テキスト
            this.managementThisMonthTextPdf        = targetProvisionalQuoteRecord.ManagementThisMonthText__c;          //  PDF出力用管理費_契約当月テキスト
            this.parkingThisMonthTextPdf           = targetProvisionalQuoteRecord.ParkingThisMonthText__c;             //  PDF出力用駐車場代_契約当月テキスト
            this.waterThisMonthTextPdf             = targetProvisionalQuoteRecord.WaterThisMonthText__c;               //  PDF出力用水道代_契約当月テキスト
            this.townshipThisMonthTextPdf          = targetProvisionalQuoteRecord.TownshipThisMonthText__c;            //  PDF出力用町会費_契約当月テキスト
            this.catvThisMonthTextPdf              = targetProvisionalQuoteRecord.CatvThisMonthText__c;                //  PDF出力用CATV_契約当月テキスト
            this.garbageDisposalThisMonthTextPdf   = targetProvisionalQuoteRecord.GarbageDisposalThisMonthText__c;     //  PDF出力用ゴミ処理費_契約当月テキスト
            this.bicycleParkingThisMonthTextPdf    = targetProvisionalQuoteRecord.BicycleParkingThisMonthText__c;      //  PDF出力用駐輪場代_契約当月テキスト
            this.bikeStorageSmallThisMonthTextPdf  = targetProvisionalQuoteRecord.BikeStorageSmallThisMonthText__c;    //  PDF出力用バイク置き場代（小型）_契約当月テキスト
            this.bikeStorageMediumThisMonthTextPdf = targetProvisionalQuoteRecord.BikeStorageMediumThisMonthText__c;   //  PDF出力用バイク置き場代（中型）_契約当月テキスト
            this.bikeStorageLargeThisMonthTextPdf  = targetProvisionalQuoteRecord.BikeStorageLargeThisMonthText__c;    //  PDF出力用バイク置き場代（大型）_契約当月テキスト
            this.fireInsuranceThisMonthTextPdf     = targetProvisionalQuoteRecord.FireInsuranceThisMonthText__c;       //  PDF出力用保険料（火災）_契約当月テキスト
            this.depositThisMonthTextPdf           = targetProvisionalQuoteRecord.DepositThisMonthText__c;             //  PDF出力用月額保証料（初回）_契約当月テキスト
            
            this.rentFullMonthTextPdf              = targetProvisionalQuoteRecord.RentFullMonthText__c;                //  PDF出力用家賃_契約当月テキスト
            this.managementFullMonthTextPdf        = targetProvisionalQuoteRecord.ManagementFullMonthText__c;          //  PDF出力用管理費_契約当月テキスト
            this.parkingFullMonthTextPdf           = targetProvisionalQuoteRecord.ParkingFullMonthText__c;             //  PDF出力用駐車場代_契約当月テキスト
            this.waterFullMonthTextPdf             = targetProvisionalQuoteRecord.WaterFullMonthText__c;               //  PDF出力用水道代_契約当月テキスト
            this.townshipFullMonthTextPdf          = targetProvisionalQuoteRecord.TownshipFullMonthText__c;            //  PDF出力用町会費_契約当月テキスト
            this.catvFullMonthTextPdf              = targetProvisionalQuoteRecord.CatvFullMonthText__c;                //  PDF出力用CATV_契約当月テキスト
            this.garbageDisposalFullMonthTextPdf   = targetProvisionalQuoteRecord.GarbageDisposalFullMonthText__c;     //  PDF出力用ゴミ処理費_契約当月テキスト
            this.bicycleParkingFullMonthTextPdf    = targetProvisionalQuoteRecord.BicycleParkingFullMonthText__c;      //  PDF出力用駐輪場代_契約当月テキスト
            this.bikeStorageSmallFullMonthTextPdf  = targetProvisionalQuoteRecord.BikeStorageSmallFullMonthText__c;    //  PDF出力用バイク置き場代（小型）_契約当月テキスト
            this.bikeStorageMediumFullMonthTextPdf = targetProvisionalQuoteRecord.BikeStorageMediumFullMonthText__c;   //  PDF出力用バイク置き場代（中型）_契約当月テキスト
            this.bikeStorageLargeFullMonthTextPdf  = targetProvisionalQuoteRecord.BikeStorageLargeFullMonthText__c;    //  PDF出力用バイク置き場代（大型）_契約当月テキスト
            this.fireInsuranceFullMonthTextPdf     = targetProvisionalQuoteRecord.FireInsuranceFullMonthText__c;       //  PDF出力用保険料（火災）_契約当月テキスト
            this.depositFullMonthTextPdf           = targetProvisionalQuoteRecord.DepositFullMonthText__c;             //  PDF出力用月額保証料（初回）_契約当月テキスト
            // ▲問合せ556で追加


            CleaningFeeShow =  targetProvisionalQuoteRecord.CleaningFeeShow__c; //     定額修繕費名
            
            // 支払い区分によって商品名のけつに文言を追加する。
            this.FireInsuranceType = targetProvisionalQuoteRecord.FireInsuranceItem__r.PaymentType__c;
            if(this.FireInsuranceType == CommonConst.ITEM_PAYMENTTYPE_MONTH){
                this.FireInsuranceTypeName = CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH;
            }else if(this.FireInsuranceType == CommonConst.ITEM_PAYMENTTYPE_YEAR){
                this.FireInsuranceTypeName = CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR;
            }

            // 　（明細情報 金額列）
            Rent = commonUtil.decimalToString(targetProvisionalQuoteRecord.RentFee__c) ;   //     家賃
            ManagementFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.ManagementFee__c);   //     管理費
            TownMembershipFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.TownshipFee__c);   //     町会費
            WaterBill = commonUtil.decimalToString(targetProvisionalQuoteRecord.WaterFee__c);   //     水道代
            CATV = commonUtil.decimalToString(targetProvisionalQuoteRecord.CATVFee__c);   //     CATV
            GarbageDisposalCosts = commonUtil.decimalToString(targetProvisionalQuoteRecord.GarbageDisposalFee__c);   //     ゴミ処理費
            BicycleparkingFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.BicycleParkingFee__c);   //     駐輪場代
            ParkingFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.ParkingFee__c);   //     駐車場代       
            ParkingBrokerageFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.ParkingBrokerageFee__c);   //     駐車場紹介料     
            ParkingDeposit = commonUtil.decimalToString(targetProvisionalQuoteRecord.ParkingDeposit__c);   //     駐車場保証金
            BikeStorageSeeDmall = commonUtil.decimalToString(targetProvisionalQuoteRecord.BikeStorageSmallFee__c);   //     バイク置き場代（小型）        
            BikeStorageFeeMediumSize = commonUtil.decimalToString(targetProvisionalQuoteRecord.BikeStorageMediumFee__c);   //     バイク置き場代（中型）        
            BikeStorageFeeLarge =  commonUtil.decimalToString(targetProvisionalQuoteRecord.BikeStorageLargeFee__c);   //     バイク置き場代（大型）        
            SecurityDeposit = commonUtil.decimalToString(targetProvisionalQuoteRecord.SecurityDeposit__c);   //     敷金
            Deposit = commonUtil.decimalToString(targetProvisionalQuoteRecord.Deposit__c);   //     保証金
            KeyMoney = commonUtil.decimalToString(targetProvisionalQuoteRecord.KeyMoney__c);   //     礼金.
            FixedrateRepairExpenses = commonUtil.decimalToString(targetProvisionalQuoteRecord.CleaningFee__c);   //     定額修繕費
            EntranceFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.TownshipInitialFee__c);   //     入町費
            KeyExchangeCosts = commonUtil.decimalToString(targetProvisionalQuoteRecord.KeyExchangeFee__c);   //     鍵交換費
            BrokerageFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.BrokerageFee__c);   //     仲介手数料

            this.FireInsurancePremiums = commonUtil.decimalToString(targetProvisionalQuoteRecord.FireInsuranceFee__c);   //     火災保険料
            this.FirstWarrantyFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.FirstFeeDeposit__c);   //     初回保証料
            this.MonthlyFeeDeposit = commonUtil.decimalToString(targetProvisionalQuoteRecord.MonthlyFeeDeposit__c);   //     月額保証料（初回）
            this.MonthlyFeeDepositNextMonth = CommonUtil.decimalToString(targetProvisionalQuoteRecord.MonthlyFeeDepositNextMonth__c); //月額保証料（初回）次月

            //▼問合せNo0496で追加
            // 自由項目
            this.FreeItemName1            =targetProvisionalQuoteRecord.FreeItemName1__c;                                   //  自由項目1名称
            this.FreeItemFeePaymentType1  =targetProvisionalQuoteRecord.FreeItemFeePaymentType1__c;                         //  自由項目1支払区分
            this.FreeItemFeeTaxType1      =targetProvisionalQuoteRecord.FreeItemFeeTaxType1__c;                             //  自由項目1税区分
            this.FreeItemFeeDeposit1      =commonUtil.decimalToString(targetProvisionalQuoteRecord.FreeItemFeeDeposit1__c); //  自由項目1料金
            this.FreeItemName2            =targetProvisionalQuoteRecord.FreeItemName2__c;                                   //  自由項目2名称
            this.FreeItemFeePaymentType2  =targetProvisionalQuoteRecord.FreeItemFeePaymentType2__c;                         //  自由項目2支払区分
            this.FreeItemFeeTaxType2      =targetProvisionalQuoteRecord.FreeItemFeeTaxType2__c;                             //  自由項目2税区分
            this.FreeItemFeeDeposit2      =commonUtil.decimalToString(targetProvisionalQuoteRecord.FreeItemFeeDeposit2__c); //  自由項目2料金
            this.FreeItemName3            =targetProvisionalQuoteRecord.FreeItemName3__c;                                   //  自由項目3名称
            this.FreeItemFeePaymentType3  =targetProvisionalQuoteRecord.FreeItemFeePaymentType3__c;                         //  自由項目3支払区分
            this.FreeItemFeeTaxType3      =targetProvisionalQuoteRecord.FreeItemFeeTaxType3__c;                             //  自由項目3税区分
            this.FreeItemFeeDeposit3      =commonUtil.decimalToString(targetProvisionalQuoteRecord.FreeItemFeeDeposit3__c); //  自由項目3料金
            this.FreeItemName4            =targetProvisionalQuoteRecord.FreeItemName4__c;                                   //  自由項目4名称
            this.FreeItemFeePaymentType4  =targetProvisionalQuoteRecord.FreeItemFeePaymentType4__c;                         //  自由項目4支払区分
            this.FreeItemFeeTaxType4      =targetProvisionalQuoteRecord.FreeItemFeeTaxType4__c;                             //  自由項目4税区分
            this.FreeItemFeeDeposit4      =commonUtil.decimalToString(targetProvisionalQuoteRecord.FreeItemFeeDeposit4__c); //  自由項目4料金
            this.FreeItemName5            =targetProvisionalQuoteRecord.FreeItemName5__c;                                   //  自由項目5名称
            this.FreeItemFeePaymentType5  =targetProvisionalQuoteRecord.FreeItemFeePaymentType5__c;                         //  自由項目5支払区分
            this.FreeItemFeeTaxType5      =targetProvisionalQuoteRecord.FreeItemFeeTaxType5__c;                             //  自由項目5税区分
            this.FreeItemFeeDeposit5      =commonUtil.decimalToString(targetProvisionalQuoteRecord.FreeItemFeeDeposit5__c); //  自由項目5料金
            this.FreeItemName1Pdf         =targetProvisionalQuoteRecord.FreeItemName1__c + setTypeName(this.FreeItemFeePaymentType1) + setTypeName(this.FreeItemFeeTaxType1);  //  PDF出力用事由項目1名称
            this.FreeItemName2Pdf         =targetProvisionalQuoteRecord.FreeItemName2__c + setTypeName(this.FreeItemFeePaymentType2) + setTypeName(this.FreeItemFeeTaxType2);  //  PDF出力用事由項目2名称
            this.FreeItemName3Pdf         =targetProvisionalQuoteRecord.FreeItemName3__c + setTypeName(this.FreeItemFeePaymentType3) + setTypeName(this.FreeItemFeeTaxType3);  //  PDF出力用事由項目3名称
            this.FreeItemName4Pdf         =targetProvisionalQuoteRecord.FreeItemName4__c + setTypeName(this.FreeItemFeePaymentType4) + setTypeName(this.FreeItemFeeTaxType4);  //  PDF出力用事由項目4名称
            this.FreeItemName5Pdf         =targetProvisionalQuoteRecord.FreeItemName5__c + setTypeName(this.FreeItemFeePaymentType5) + setTypeName(this.FreeItemFeeTaxType5);  //  PDF出力用事由項目5名称
            //▲問合せNo0496で追加  

            // 集計項目は別で計算する。
            this.SubtotalAmount = commonUtil.decimalToString(targetProvisionalQuoteRecord.SubTotal__c);   // 小計金額        
            this.ConsumptionTax =commonUtil.decimalToString(targetProvisionalQuoteRecord.Tax__c);   // 消費税
            this.Taxable = commonUtil.decimalToString(targetProvisionalQuoteRecord.TaxationTarget__c);  // 課税対象 
            this.TotalAmount = commonUtil.decimalToString(targetProvisionalQuoteRecord.Total__c);  // 合計金額


            this.Remarks1 = String.valueOf(targetProvisionalQuoteRecord.RemarksRenewalFee__c);
            this.Remarks2 =string.valueOf(targetProvisionalQuoteRecord.RemarksShortTermPenaltyFee__c);

            // 初回以降の設定
            this.NextRentFee  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextRentFee__c);  //家賃（初回以降）
            this.NextManagementFee  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextManagementFee__c);  //管理費（初回以降）
            this.NextParkingFee  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextParkingFee__c);  //駐車場代（初回以降）
            this.NextWaterFee  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextWaterFee__c);  //水道代（初回以降）
            // 月額である場合のみ
            if(this.TownshipFeePaymentType == CommonConst.PROPERTY_PAYMENTTYPE_MONTH ){
                this.NextTownshipFee  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextTownshipFee__c);  //町会費（初回以降）
            }
            this.NextCatvFee  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextCatvFee__c);  //CATV（初回以降）
            // 月額である場合のみ
            if(this.GarbageDisposalFeePaymentType == CommonConst.PROPERTY_PAYMENTTYPE_MONTH ){
                this.NextGarbageDisposalFee  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextGarbageDisposalFee__c);  //ゴミ処理費（初回以降）
            }
            this.NextBicycleParkingFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextBicycleParkingFee__c);   //     駐輪場代
            this.NextParkingFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextParkingFee__c);   //     駐車場代            
            this.NextBikeStorageSmallFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextBikeStorageSmallFee__c);   //バイク置き場代（小型）（初回以降）
            this.NextBikeStorageMediumFee = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextBikeStorageMediumFee__c);   //バイク置き場代（中型）（初回以降）
            this.NextBikeStorageLargeFee =  commonUtil.decimalToString(targetProvisionalQuoteRecord.NextBikeStorageLargeFee__c);   //     バイク置き場代（大型）        
            this.NextFireInsuranceFee  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextFireInsuranceFee__c);  //保険料（火災）（初回以降）
            this.NextFeeDeposit  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextFeeDeposit__c);  //保証料（初回以降）
            this.NextSubTotal  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextSubTotal__c); //小計（初回以降）
            this.NextTax  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextTax__c);  //消費税（初回以降）
            this.NextTaxationTarget  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextTaxationTarget__c);  //課税対象（初回以降）
            this.NextTotal  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextTotal__c);  //合計金額（初回以降）          

            this.NextRemarksRenewalFee = String.valueOf(targetProvisionalQuoteRecord.NextRemarksRenewalFee__c);
            this.NextRemarksShortTermPenaltyFee =targetProvisionalQuoteRecord.NextRemarksShortTermPenaltyFee__c;

            this.HomeMovingDate = targetProvisionalQuoteRecord.ContractStartDate__c;                      // 引越時期
            this.ProratedCalculationDay = targetProvisionalQuoteRecord.ProratedMonthDays__c;           // 日割り計算月日数
            this.Proratedflag = targetProvisionalQuoteRecord.IsProrated__c;                      // 日割り計算フラグ
            this.Parkingflag = targetProvisionalQuoteRecord.IsParkingUse__c;                       // 駐車場フラグ
            this.ParkingNumberRequired = targetProvisionalQuoteRecord.ParkingRequiredNumber__c;             // 駐車場必要数
            this.BicycleParkingFlag = targetProvisionalQuoteRecord.IsBicycleParkingUse__c;                // 駐輪場フラグ
            this.BicycleParkingNumberRequired = targetProvisionalQuoteRecord.BicycleParkingRequiredNumber__c;      // 駐輪場必要数    
            this.BikeParkingSmallFlag = targetProvisionalQuoteRecord.IsBikeStorageSmallUse__c;              // バイク置き場（小型）フラグ
            this.BikeParkingSmallNumberRequired = targetProvisionalQuoteRecord.BikeStorageSmallRequiredNumber__c;    // バイク置き場（小型）必要数
            this.BikeParkingSmallFee = targetProvisionalQuoteRecord.BikeStorageSmallRequiredNumberFee__c;              // 物件．小型バイク置場料金
            this.BikeParkingMediumFlag = targetProvisionalQuoteRecord.IsBikeStorageMediumUse__c;             // バイク置き場（中型）フラグ
            this.BikeParkingMediumNumberRequired = targetProvisionalQuoteRecord.BikeStorageMediumRequiredNumber__c;   // バイク置き場（中型）必要数
            this.BikeParkingMediumFee = targetProvisionalQuoteRecord.BikeStorageMediumRequiredNumberFee__c;             // 物件．中型バイク置場料金
            this.BikeParkinLargeFlag = targetProvisionalQuoteRecord.IsBikeStorageLargeUse__c;               // バイク置き場（大型）フラグ
            this.BikeParkinLargeNumberRequired = targetProvisionalQuoteRecord.BikeStorageLargeRequiredNumber__c;     // バイク置き場（大型）必要数
            this.BikeParkinLargeFee = targetProvisionalQuoteRecord.BikeStorageLargeRequiredNumberFee__c;               // 物件．大型バイク置場料金
            //▼問合せNo0496で追加
            this.NextFreeItemName1        = targetProvisionalQuoteRecord.NextFreeItemName1__c;                                  // 自由項目1名称（初回以降）
            this.NextFreeItemFeeTaxType1  = targetProvisionalQuoteRecord.NextFreeItemFeeTaxType1__c;                            // 自由項目1税区分（初回以降）
            this.NextFreeItemFeeDeposit1  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextFreeItemFeeDeposit1__c);// 自由項目1料金（初回以降）
            this.NextFreeItemName2        = targetProvisionalQuoteRecord.NextFreeItemName2__c;                                  // 自由項目2名称（初回以降）
            this.NextFreeItemFeeTaxType2  = targetProvisionalQuoteRecord.NextFreeItemFeeTaxType2__c;                            // 自由項目2税区分（初回以降）
            this.NextFreeItemFeeDeposit2  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextFreeItemFeeDeposit2__c);// 自由項目2料金（初回以降）
            this.NextFreeItemName3        = targetProvisionalQuoteRecord.NextFreeItemName3__c;                                  // 自由項目3名称（初回以降）
            this.NextFreeItemFeeTaxType3  = targetProvisionalQuoteRecord.NextFreeItemFeeTaxType3__c;                            // 自由項目3税区分（初回以降）
            this.NextFreeItemFeeDeposit3  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextFreeItemFeeDeposit3__c);// 自由項目3料金（初回以降）
            this.NextFreeItemName4        = targetProvisionalQuoteRecord.NextFreeItemName4__c;                                  // 自由項目4名称（初回以降）
            this.NextFreeItemFeeTaxType4  = targetProvisionalQuoteRecord.NextFreeItemFeeTaxType4__c;                            // 自由項目4税区分（初回以降）
            this.NextFreeItemFeeDeposit4  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextFreeItemFeeDeposit4__c);// 自由項目4料金（初回以降）
            this.NextFreeItemName5        = targetProvisionalQuoteRecord.NextFreeItemName5__c;                                  // 自由項目5名称（初回以降）
            this.NextFreeItemFeeTaxType5  = targetProvisionalQuoteRecord.NextFreeItemFeeTaxType5__c;                            // 自由項目5税区分（初回以降）
            this.NextFreeItemFeeDeposit5  = commonUtil.decimalToString(targetProvisionalQuoteRecord.NextFreeItemFeeDeposit5__c);// 自由項目5料金（初回以降）
            this.NextFreeItemName1Pdf     = targetProvisionalQuoteRecord.NextFreeItemName1__c + setTypeName(this.NextFreeItemFeeTaxType1);  //  PDF出力用事由項目1名称（初回以降）
            this.NextFreeItemName2Pdf     = targetProvisionalQuoteRecord.NextFreeItemName2__c + setTypeName(this.NextFreeItemFeeTaxType2);  //  PDF出力用事由項目2名称（初回以降）
            this.NextFreeItemName3Pdf     = targetProvisionalQuoteRecord.NextFreeItemName3__c + setTypeName(this.NextFreeItemFeeTaxType3);  //  PDF出力用事由項目3名称（初回以降）
            this.NextFreeItemName4Pdf     = targetProvisionalQuoteRecord.NextFreeItemName4__c + setTypeName(this.NextFreeItemFeeTaxType4);  //  PDF出力用事由項目4名称（初回以降）
            this.NextFreeItemName5Pdf     = targetProvisionalQuoteRecord.NextFreeItemName5__c + setTypeName(this.NextFreeItemFeeTaxType5);  //  PDF出力用事由項目5名称（初回以降）
            //▲問合せNo0496で追加


            this.RentFlg = displayFlg(this.Rent,this.DailyRent);
            this.ManagementFeeFlg = displayFlg(this.ManagementFee,this.ManagementProratedFee);
            this.TownMembershipFeeFlg = displayFlg(this.TownMembershipFee,this.DailyAmountTownMembershipFee);   // 町会費表示フラグ
            this.DailyAmountTownMembershipFeeFlg = displayFlg(this.DailyAmountTownMembershipFee,''); // 町会費日割り表示フラグ
            
            this.WaterBillFlg = displayFlg(this.WaterBill,this.DailyWaterBill);
            this.DailyWaterBillFlg = displayFlg(this.DailyWaterBill,'');    // 水道代日割り表示フラグ

            this.CATVFlg = displayFlg(this.CATV,this.CATVDaily); // CATV表示フラグ
            this.CATVDailyFlg = displayFlg(this.CATVDaily,'');   // CATV日割り表示フラグ
            
            this.GarbageDisposalCostsFlg = displayFlg(this.GarbageDisposalCosts,this.DailyGarbageDisposalExpenses); //ゴミ処理費表示フラグ
            this.DailyGarbageDisposalExpensesFlg = displayFlg(this.DailyGarbageDisposalExpenses,''); //ゴミ処理費日割り表示フラグ
            
            this.SecurityDepositFlg = displayFlg(this.SecurityDeposit,'');
            this.DepositFlg = displayFlg(this.Deposit,'');//     保証金
            this.KeyMoneyFlg = displayFlg(this.KeyMoney,'');//     礼金.
            this.FixedrateRepairExpensesFlg = displayFlg(this.FixedrateRepairExpenses,'');//     定額修繕費
            this.EntranceFeeFlg = displayFlg(this.EntranceFee,'');//     入町費
            this.KeyExchangeCostsFlg = displayFlg(this.KeyExchangeCosts,'');//     鍵交換費
            this.BrokerageFeeFlg = displayFlg(this.BrokerageFee,'');//     仲介手数料
            this.FireInsurancePremiumsFlg = displayFlg(this.FireInsurancePremiums,this.FireInsurancePremiumDaily);//     火災保険料表示フラグ
            this.FireInsurancePremiumDailyFlg = displayFlg(this.FireInsurancePremiumDaily,'');//     火災保険料日割表示フラグ

            this.FirstWarrantyFlg = displayFlg(this.FirstWarrantyFee,'');  // 初回保証料表示フラグ
            this.MonthlyFeeDepositFlg = displayFlg(this.MonthlyFeeDeposit,this.MonthlyFeeDepositNextMonth);// 月額保証料（初回）表示フラグ
            this.MonthlyFeeDepositNextMonthFlg = displayFlg(this.MonthlyFeeDepositNextMonth,''); // 月額保証料（初回）次月分表示フラグ
            this.ParkingBrokerageFeeFlg = displayFlg(this.ParkingBrokerageFee,'');//駐車場紹介料表示フラグ

            
            this.BicycleparkingFeeFlg = displayFlg(this.BicycleparkingFee,this.DailyBicycleParkingFee);
            this.ParkingFeeFlg = displayFlg(this.ParkingFee,this.DailyDiscountParkingLot);
            this.BikeStorageSeeDmallFlg = displayFlg(this.BikeStorageSeeDmall,this.BikeStorageFeeSmallDailyDiscount);
            this.BikeStorageFeeMediumSizeFlg = displayFlg(this.BikeStorageFeeMediumSize,this.BikeStorageFeeMediumDaily);
            this.BikeStorageFeeLargeFlg = displayFlg(this.BikeStorageFeeLarge,this.BikeStorageFeeLargeDailyDiscount);
            this.AmountGoodsSpecifiedManagementCompanyFlg = displayFlg(this.AmountGoodsSpecifiedManagementCompany,this.DailyAmountProductsDesignatedManagementCompany);
            this.ParkingDepositFlg = displayFlg(this.ParkingDeposit,'');

            // 初回以降
            this.NextRentFeeFlg = displayFlg(this.NextRentFee,'');  //家賃（初回以降）_表示フラグ
            this.NextManagementFeeFlg =  displayFlg(this.NextManagementFee,'');  //管理費（初回以降）_表示フラグ
            this.NextParkingFeeFlg =  displayFlg(this.NextParkingFee,'');  //駐車場代（初回以降）_表示フラグ
            this.NextWaterFeeFlg =  displayFlg(this.NextWaterFee,'');  //水道代（初回以降）_表示フラグ
            this.NextTownshipFeeFlg =  displayFlg(this.NextTownshipFee,'');  //町会費（初回以降）_表示フラグ
            this.NextCatvFeeFlg =  displayFlg(this.NextCatvFee,'');  //CATV（初回以降）_表示フラグ
            this.NextGarbageDisposalFeeFlg =  displayFlg(this.NextGarbageDisposalFee,'');  //ゴミ処理費（初回以降）_表示フラグ
            this.NextBicycleParkingFeeFlg =  displayFlg(this.NextBicycleParkingFee,'');  //駐輪場代（初回以降）_表示フラグ
            this.NextBikeStorageSmallFeeFlg =  displayFlg(this.NextBikeStorageSmallFee,'');  //バイク置き場代（小型）（初回以降）_表示フラグ
            this.NextBikeStorageMediumFeeFlg =  displayFlg(this.NextBikeStorageMediumFee,'');  //バイク置き場代（中型）（初回以降）_表示フラグ
            this.NextBikeStorageLargeFeeFlg =  displayFlg(this.NextBikeStorageLargeFee,'');  //バイク置き場代（大型）（初回以降）_表示フラグ
            if(item.FireInsurance == CommonConst.ITEM_PAYMENTTYPE_MONTH){
                this.NextFireInsuranceFeeFlg = displayFlg(this.NextFireInsuranceFee,'');//保険料（火災）（初回以降）
            }
            this.NextFeeDepositFlg = displayFlg(this.NextFeeDeposit,'');//保証料（初回以降）

            // その他付帯商品
            setEtceteraAuxiliaryItemList(targetProvisionalQuoteRecord);
        }
    

        /**
         * 日割り計算
         */
        private Decimal ProratedCalculation(Decimal Amount, Decimal DailyDays,Decimal OneMonth){
            //値が入っていなければ計算せずに0にする。
            if (Amount == null || DailyDays == null || OneMonth == null){
                return 0 ;
            }

            // 計算式：各種金額 ÷ [パラメータ．日割り計算月日数] × [パラメータ．契約開始日 から月末までの日数]　　※計算後少数点以下四捨五入
            // （日割計算はパラメータ．日割り計算がTrueで、パラメータ．保存内容出力フラグがFalseの場合に行う。）
            Decimal ResultCalculation  = Math.round(Amount / DailyDays * OneMonth);
            
            return ResultCalculation.setScale(0,RoundingMode.HALF_UP) ;
        }

        /**
         * 表示判定フラグ（金額があればTrue）
         */
        private  Boolean displayFlg(String AmountMoney, String DailyRate){
            Boolean flg = false;
            if((AmountMoney != '0' && !String.isBlank(AmountMoney)) ||
               (DailyRate != '0' && !String.isBlank(DailyRate))){
                flg = true;
            }
            return flg;
        }

        /**
         * その他付帯商品リストに行番号をセットする
         */
        public Integer setRowCountToEtceteraAuxiliaryItemList(Integer startRow) {
            Integer row = startRow;
            for (ProvisionalQuoteBreakdown item: this.etceteraAuxiliaryItemList) {
                if (item.isDisplay) {
                    item.rowCount = row;
                    row++;
                }
            }

            // 最後に登録した行番号を返す
            row--;
            return row;
        }

        // 初期化
        private void init() {
            // 付帯商品Map初期化
            this.etceteraAuxiliaryItemMap = searchEtceteraAuxiaryItemRecode();
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
    
        // その他付帯商品リストの登録（商品カスタムIdのリストから）
        private void setEtceteraAuxiliaryItemList(List<String> itemIdList) {
            this.etceteraAuxiliaryItemList = new List<ProvisionalQuoteBreakdown>();
            for (String itemId: itemIdList) {
                Item__c itemObj = this.etceteraAuxiliaryItemMap.get(itemId);
                this.etceteraAuxiliaryItemList.add(new ProvisionalQuoteBreakdown(itemObj));
            }
        }

        // その他付帯商品リストの登録（仮見積オブジェクトから）
        private void setEtceteraAuxiliaryItemList(ProvisionalQuote__c record) {
            this.etceteraAuxiliaryItemList = new List<ProvisionalQuoteBreakdown>();
            for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
                Id itemId = (Id) record.get('AuxiliaryItem' + String.valueOf(i) + '__c');
                if (String.isNotEmpty(itemId)) {
                    Item__c itemObj = this.etceteraAuxiliaryItemMap.get(itemId);
                    ProvisionalQuoteBreakdown item = new ProvisionalQuoteBreakdown(itemObj);
                    item.fee = CommonUtil.decimalToString((Decimal) record.get('AuxiliaryItemFee' + String.valueOf(i) + '__c'));
                    this.etceteraAuxiliaryItemList.add(item);
                }
            }
        }

        //▼問合せNo0496で追加
        /**
        * 項目出力用に区分の形を作成する
        * @param  String pdfSetTypeName 変換対象の区分
        * @return String                変換後の区分
        */
        private String setTypeName(String pdfSetTypeName) {
            // 無ければ空で返す
            if (string.isEmpty(pdfSetTypeName)){
                return CommonConst.STRING_EMPTY;
            }
            // あれば（）で囲って返す
            return ' ( ' + pdfSetTypeName + ' ) ';  //問合せNo0555で変更
        }   
        //▲問合せNo0496で追加
    }

    /**
     * 画面表示用内部クラス（仮見積指定商品）
     */
    public class screeenProvisionalQuoteManageCompayItem{
        public String Id { get;set; }               
        public Datetime SystemModstamp { get; set; }        // SystemModstamp
        public String ItemName { get; set; }                // 物件管理会社指定．管理会社指定プラン．商品名
        public String IssueDate { get; set; }               // 物件管理会社指定．管理会社指定プラン．支払区分
        public String ManagementCompanyItem { get; set; }   // 管理会社指定商品
        public String DailyFee { get; set; }                // 日割額
        public String Fee { get; set; }                     // 金額
        public String NextFee { get; set; }                 // 金額（初回以降）
        public String TaxType { get; set; }                 // 管理会社指定商品.税区分
        public String ProvisionalQuoteItemNextMonthText { get; set; } // 仮見積指定商品_契約次月テキスト
        public String ProvisionalQuoteItemNextMonthTextPdf { get; set; } // PDF出力用仮見積指定商品_契約次月テキスト
        // ▼問合せ556で追加
        public String provisionalQuoteItemThisMonthText { get; set; } // 仮見積指定商品_契約当月テキスト
        public String provisionalQuoteItemThisMonthTextPdf { get; set; } // PDF出力用仮見積指定商品_契約当月テキスト
        public String provisionalQuoteItemFullMonthText { get; set; } // 仮見積指定商品_契約当月テキスト(日割り無し)
        public String provisionalQuoteItemFullMonthTextPdf { get; set; } // PDF出力用仮見積指定商品_契約当月テキスト(日割り無し)
        // ▲問合せ556で追加
        public Boolean displayFlg {get;set;}                // 表示フラグ
        public Boolean displaDydailyFlg { get; set; }       // 日割表示フラグ
        public Boolean nextDisplayFlg {get;set;}            // 表示フラグ（初回以降）
        private Integer kaigyoByte = 60; // 改行バイト数

        // 物件管理会社指定から
        public screeenProvisionalQuoteManageCompayItem(PropertyManageCompayItem__c PropertyManageCompayItemRecord,parameter param,String ProvisionalQuoteManageCompayItemId,Datetime ProvisionalQuoteManageCompayItemDate){
            if(!String.isBlank(ProvisionalQuoteManageCompayItemId)){
                Id = ProvisionalQuoteManageCompayItemId;
                SystemModstamp = ProvisionalQuoteManageCompayItemDate;
            }
            
            IssueDate = PropertyManageCompayItemRecord.Item__r.PaymentType__c;  //支払区分
            this.ProvisionalQuoteItemNextMonthText = CommonConst.STRING_EMPTY;  // 仮見積指定商品_契約次月テキスト初期化
            this.ProvisionalQuoteItemNextMonthTextPdf = CommonConst.STRING_EMPTY; // PDF出力用仮見積指定商品_契約次月テキスト初期化
            this.ProvisionalQuoteItemThisMonthText = CommonConst.STRING_EMPTY;  // 仮見積指定商品_契約当月テキスト初期化
            this.ProvisionalQuoteItemThisMonthTextPdf = CommonConst.STRING_EMPTY; // PDF出力用仮見積指定商品_契約当月テキスト初期化
            this.ProvisionalQuoteItemFullMonthText = CommonConst.STRING_EMPTY;  // 仮見積指定商品_契約当月テキスト(日割り無し)初期化
            this.ProvisionalQuoteItemFullMonthTextPdf = CommonConst.STRING_EMPTY; // PDF出力用仮見積指定商品_契約当月テキスト(日割り無し)初期化

            // 支払い区分によって商品名のけつに文言を追加する。
            String FireInsuranceType = CommonConst.STRING_EMPTY;
            if(PropertyManageCompayItemRecord.Item__r.PaymentType__c == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH){
                // 月額は入れる。
                FireInsuranceType = '（'+CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH+'）';

                // 月額のみ日割り額を計算する。
                date Months1 = param.HomeMovingDate.addMonths(1);
                // 問合せ556で追加　当月
                String thisMonth = param.HomeMovingDate.month().format();
                date yestday = Months1.toStartOfMonth().addDays(-1);
                Integer DaysToEnd = yestday.day() -param.HomeMovingDate.day();    // [パラメータ．契約開始日 から月末までの日数
                Integer daysToEndViewParam = DaysToEnd + 1;
                DailyFee = commonUtil.decimalToString(ProratedCalculation(PropertyManageCompayItemRecord.Item__r.Amount__c,param.ProratedCalculationDay,DaysToEnd));   //     家賃日割額

                this.ProvisionalQuoteItemNextMonthText = String.valueOf(Months1.month()) + ' 月分';  // 仮見積指定商品_契約次月テキスト
                // ▼問合せ556で追加
                this.provisionalQuoteItemFullMonthText = thisMonth + ' 月分';  // 仮見積指定商品_契約当月テキスト(日割り無し)
                this.provisionalQuoteItemThisMonthText = thisMonth + ' 月分' + '　　' + String.valueOf(daysToEndViewParam) + ' 日分';  // 仮見積指定商品_契約当月テキスト
                // ▲問合せ556で追加
                
            }else if(PropertyManageCompayItemRecord.Item__r.PaymentType__c == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR){
                // 年額を入れる
                FireInsuranceType = '（'+CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR+'）';
            }else{
                // 上記以外は空
                FireInsuranceType = CommonConst.STRING_EMPTY;
            }
            ItemName = PropertyManageCompayItemRecord.Item__r.ItemName__c + FireInsuranceType;
            
            Fee = CommonUtil.decimalToString(PropertyManageCompayItemRecord.Item__r.Amount__c);
            NextFee = CommonUtil.decimalToString(PropertyManageCompayItemRecord.Item__r.Amount__c);

            TaxType = PropertyManageCompayItemRecord.Item__r.TaxType__c;

            ManagementCompanyItem = PropertyManageCompayItemRecord.Item__c;        // 管理会社指定商品

            displayFlg = displayFlg(this.Fee,this.DailyFee);                    //表示フラグ
            displaDydailyFlg = displayFlg(this.DailyFee,'');                    //日割り表示フラグ

            if(PropertyManageCompayItemRecord.Item__r.PaymentType__c == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH){
                nextDisplayFlg = displayFlg(this.NextFee,'');                    //表示フラグ
            }else{
                nextDisplayFlg = false;
            }
        }

        // 仮見積指定商品
        public screeenProvisionalQuoteManageCompayItem(ProvisionalQuoteManageCompayItem__c ProvisionalQuoteManageCompayItemRecord){
            Id = ProvisionalQuoteManageCompayItemRecord.id;
            SystemModstamp = ProvisionalQuoteManageCompayItemRecord.SystemModstamp;
            IssueDate = ProvisionalQuoteManageCompayItemRecord.ManagementCompanyItem__r.PaymentType__c;  //支払区分
            
            TaxType = ProvisionalQuoteManageCompayItemRecord.ManagementCompanyItem__r.TaxType__c;                        //税区分

            DailyFee = CommonUtil.decimalToString(ProvisionalQuoteManageCompayItemRecord.DailyFee__c);   //     日割額
            Fee = CommonUtil.decimalToString(ProvisionalQuoteManageCompayItemRecord.Fee__c);
            NextFee = CommonUtil.decimalToString(ProvisionalQuoteManageCompayItemRecord.NextFee__c);
            this.ProvisionalQuoteItemNextMonthText = CommonConst.STRING_EMPTY;      // 日割時月額項目初期化
            this.ProvisionalQuoteItemNextMonthTextPdf = CommonConst.STRING_EMPTY; // PDF出力用仮見積指定商品_契約次月テキスト初期化
            this.ProvisionalQuoteItemThisMonthText = CommonConst.STRING_EMPTY;  // 仮見積指定商品_契約当月テキスト初期化
            this.ProvisionalQuoteItemThisMonthTextPdf = CommonConst.STRING_EMPTY; // PDF出力用仮見積指定商品_契約当月テキスト初期化
            this.ProvisionalQuoteItemFullMonthText = CommonConst.STRING_EMPTY;  // 仮見積指定商品_契約当月テキスト(日割り無し)初期化
            this.ProvisionalQuoteItemFullMonthTextPdf = CommonConst.STRING_EMPTY; // PDF出力用仮見積指定商品_契約当月テキスト(日割り無し)初期化

            // 支払い区分によって商品名のけつに文言を追加する。
            String FireInsuranceType = CommonConst.STRING_EMPTY;
            if(ProvisionalQuoteManageCompayItemRecord.ManagementCompanyItem__r.PaymentType__c == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH){
                // 月額は入れる。
                FireInsuranceType = '（'+CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH+'）';
                this.ProvisionalQuoteItemNextMonthText = ProvisionalQuoteManageCompayItemRecord.ProvisionalQuoteItemNextMonthText__c;       // 仮見積指定商品_契約次月テキスト
                this.ProvisionalQuoteItemNextMonthTextPdf = autoKaigyo(ProvisionalQuoteManageCompayItemRecord.ProvisionalQuoteItemNextMonthText__c,this.kaigyoByte,CommonConst.BREAK_TAG);                // PDF出力用仮見積指定商品_契約次月テキスト
                this.ProvisionalQuoteItemThisMonthText = ProvisionalQuoteManageCompayItemRecord.ProvisionalQuoteItemThisMonthText__c;  // 仮見積指定商品_契約当月テキスト
                this.ProvisionalQuoteItemThisMonthTextPdf = autoKaigyo(ProvisionalQuoteManageCompayItemRecord.ProvisionalQuoteItemThisMonthText__c,this.kaigyoByte,CommonConst.BREAK_TAG);                // PDF出力用仮見積指定商品_契約当月テキスト
                this.ProvisionalQuoteItemFullMonthText = ProvisionalQuoteManageCompayItemRecord.ProvisionalQuoteItemFullMonthText__c;  // 仮見積指定商品_契約当月テキスト(日割り無し)
                this.ProvisionalQuoteItemFullMonthTextPdf = autoKaigyo(ProvisionalQuoteManageCompayItemRecord.ProvisionalQuoteItemFullMonthText__c,this.kaigyoByte,CommonConst.BREAK_TAG);                // PDF出力用仮見積指定商品_契約当月テキスト(日割り無し)
                
            }else if(ProvisionalQuoteManageCompayItemRecord.ManagementCompanyItem__r.PaymentType__c == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR){
                // 年額を入れる
                FireInsuranceType = '（'+CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR+'）';
            }else{
                // 上記以外は空
                FireInsuranceType = CommonConst.STRING_EMPTY;
            }   
            ItemName = ProvisionalQuoteManageCompayItemRecord.ManagementCompanyItem__r.ItemName__c + FireInsuranceType;  //商品名           

            ManagementCompanyItem = ProvisionalQuoteManageCompayItemRecord.ManagementCompanyItem__c;        //管理会社指定商品

            displayFlg = displayFlg(this.Fee,this.DailyFee);                    //表示フラグ
            displaDydailyFlg = displayFlg(this.DailyFee,'');                    //日割り表示フラグ

            if(ProvisionalQuoteManageCompayItemRecord.ManagementCompanyItem__r.PaymentType__c == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH){
                nextDisplayFlg = displayFlg(this.NextFee,'');                    //表示フラグ
            }else{
                nextDisplayFlg = false;
            }
            
        }

        /**
         * 表示判定フラグ
         */
        private  Boolean displayFlg(String AmountMoney, String DailyRate){
            Boolean flg = false;
            if((AmountMoney != '0' && !String.isBlank(AmountMoney)) ||
               (DailyRate != '0' && !String.isBlank(DailyRate))){
                flg = true;
            }
            return flg;
        }

        /**
         * 日割り計算
         */
        private Decimal ProratedCalculation(Decimal Amount, Decimal DailyDays,Decimal OneMonth){
            //値が入っていなければ計算せずに0にする。
            if (Amount == null || DailyDays == null || OneMonth == null || DailyDays == 0){
                return 0 ;
            }

            // 計算式：各種金額 ÷ [パラメータ．日割り計算月日数] × [パラメータ．契約開始日 から月末までの日数]　　※計算後少数点以下四捨五入
            // （日割計算はパラメータ．日割り計算がTrueで、パラメータ．保存内容出力フラグがFalseの場合に行う。）
            Decimal ResultCalculation  = Math.round(Amount / DailyDays * OneMonth);
            
            return ResultCalculation.setScale(0,RoundingMode.HALF_UP) ;
        }
    }

    // 仮見積もり内訳クラス
    public class ProvisionalQuoteBreakdown {
        // プロパティ
        public Id           itemId      { get; set; }       // 商品（カスタム）のId
        public String       title       { get; set; }       // タイトル
        public List<String> splitTitle  { get; set; }       // タイトル（分割）
        public String       name        { get; set; }       // 名前
        public String       taxType     { get; set; }       // 税種別
        public String       fee         { get; set; }       // 金額
        public Integer      rowCount    { get; set; }       // 行番号

        // プロパティ（編集）
        public Decimal      feeDec      { get { return CommonUtil.stringToDecimal(this.fee); } }        // 金額（カンマ区切り文字列）
        public Decimal      feeDec0     { get { return ((String.isEmpty(this.fee))? 0: feeDec);} }      // 金額（カンマ区切り文字列、null⇒0変換）
        public String       pdfTitle    { get { return changePdfStyle(this.title); } }                  // PDF出力用タイトル
        public Boolean      isDisplay   { get { return getDisplayFlag(this.fee); } }                    // 表示フラグ
        public Integer      pageRow     { get { return calcRowInPage(); } }                             // ページ内の行番号
        public String       pdfName     {                                                               // 名前（自動改行）
            get { return GA102002Controller2.autoKaigyo(this.name, LINE_FEED_BYTE_UCHIWAKE_2,CommonConst.BREAK_TAG); }
        }

        // コンストラクタ（商品カスタムから）
        public ProvisionalQuoteBreakdown(Item__c itemObj) {
            this.itemId = itemObj.Id;
            this.title = itemObj.AuxiliaryItemType__c;
            this.splitTitle = this.title.split('');
            this.name = itemObj.ItemName__c;
            this.taxType = itemObj.auxiliaryItemFeeTaxType__c;
            this.fee = CommonUtil.decimalToString(itemObj.auxiliaryItemFee__c);
            this.rowCount = -1;
        }

        // PDF出力用に変換
        private String changePdfStyle(String str) {
            Integer MAX_SIZE = 26;

            // 文字列のサイズを取得
            List<String> charList = str.split('');
            Integer size = charList.size();

            // 文字サイズが１文字以下の場合は、ここで処理を抜ける
            if (size <= 1) {
                return str + createSpace(MAX_SIZE - size * 2);
            }

            // 間に挿むスペースの数を計算
            Integer delimSize = (MAX_SIZE - size * 2) / (size - 1);
            Integer addCount = Math.mod((MAX_SIZE - size * 2), (size - 1));
            delimSize = (delimSize < 0)? 0: delimSize;
            addCount = (delimSize == 0)? 0: addCount;

            // スペースの差し込み
            String ret = '';
            for (Integer i = 0; i < size; i++) {
                ret += (i==0)? '': createSpace((i <= addCount)? delimSize + 1: delimSize);
                ret += charList[i];
            }
            return ret;
        }

        // 指定した幅のスペースを作成
        private String createSpace(Integer size) {
            Integer doubleSize = size / 2;
            Integer halfSize = Math.mod(size, 2);
            return '　'.repeat(doubleSize) + ' '.repeat(halfSize);
        }

        /**
         * 表示判定フラグ（金額があればTrue）
         */
        private Boolean getDisplayFlag(String fee){
            Boolean flg = false;
            if (fee != '0' && !String.isBlank(fee)) {
                flg = true;
            }
            return flg;
        }

        /**
         * ページ内の行数を計算する
         */
        private Integer calcRowInPage() {
            Integer rowInPage = Math.mod(rowCount, GA102002Controller2.outputPrintMaxCount);
            if (rowInPage == 0) {
                rowInPage = GA102002Controller2.outputPrintMaxCount;
            }
            return rowInPage;
        }

    }

}