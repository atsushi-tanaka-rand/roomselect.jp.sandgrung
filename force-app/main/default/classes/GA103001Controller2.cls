/**
 *申込登録（ipad）口コミ画面のコントローラ
 */
public inherited sharing class GA103001Controller2 {
    // 定数
    private static final Integer ETCETERA_AUXILIARY_ITEM_LIST_COUNT = 10;
    
    //パブリック変数
    public Boolean isNew { get; set; }                 //新規登録フラグ
    public Boolean isOpenError { get; set; }           //エラーフラグ
    public Boolean hasErrorMessage { get; set; }       //エラーメッセージ保有フラグ
    
    public Boolean isKutikomi {set;get;}               //口コミ画面フラグ
    public Boolean isApp { get; set; }                 //アプリで表示してるフラグ
    
    public ScreenItem screenTargetRecord {set;get;}    //画面表示用の内部クラスレコード
    public String formLogoUrl { get{ return SystemConfig__c.getInstance().FormLogoPath__c; } }      // 帳票ロゴパス
    
    //選択リスト
    public List<SelectOption> SelectAuxiliaryDepositPlanList{ get; set; }        //付帯保証プラン
    public List<SelectOption> SelectAuxiliaryFireInsuranceList{ get; set; }      //付帯火災保険
    public List<SelectOption> SelectEtceteraAuxiliaryItemTypeList { get; set; }         // その他付帯商品種別
    public List<SelectOption> SelectEtceteraAuxiliaryItemNameList { get; set; }         // その他付帯商品名（業者／商品名／料金）

    //Map
    public Map<Id, Decimal> auxiliaryMap;
    //合計

    //メッセージ
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    // js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    // js用削除完了メッセージ

    //プライベート変数
    private String applicationId;                   //申込パラメータ
    private String comeFrom;                        //遷移元区分パラメータ
    private Application__c applicationRecord;       //申込レコード
    private Map<Id, Item__c> etceteraAuxiliaryItemMap;        // その他付帯商品のマップ
    
    //コンストラクタ
    public GA103001Controller2() {
        try{
            //初期化   
            init();
        }catch(Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //●publicメソッド
    //口コミ売上修正画面に変更
    public void clickNext(){
        isKutikomi =true;
    }
    //選択リスト変更
    public void depositPlanListChange(){
        //保証プラン//▼2022.02.15 No0727 対応にて変更
		screenTargetRecord.auxiliaryDepositPlanFee = CustomerUtil.returnScreenMoney(auxiliaryMap,screenTargetRecord.auxiliaryDepositPlan);
    }

    public void fireInsuranceListChange(){
		//付帯火災保険//▼2022.02.15 No0727 対応にて変更
		screenTargetRecord.auxiliaryFireInsuranceFee = CustomerUtil.returnScreenMoney(auxiliaryMap,screenTargetRecord.auxiliaryFireInsurance);
    }
    // 選択リスト変更：その他付帯商品種別
    public void etceteraAuxiliaryItemTypeListChange() {
        // 選択リスト：付帯商品名のリストを入れ替え//▼2022.02.15 No0727 対応にて変更
        this.SelectEtceteraAuxiliaryItemNameList = CustomerUtil.getEtceteraAuxiliaryItemNameListFromType(screenTargetRecord.etceteraAuxiliaryItemType,etceteraAuxiliaryItemMap);
    }
    // 選択リスト変更：その他付帯商品名
    public void etceteraAuxiliaryItemNameListChange() {
        // 販売価格に商品の価格を登録
        Id itemId = screenTargetRecord.etceteraAuxiliaryItemName;
        if (String.isNotEmpty(itemId)) {
            Item__c item = etceteraAuxiliaryItemMap.get(itemId);
            screenTargetRecord.etceteraAuxiliaryItemFee = CustomerUtil.decimalToStringEx(item.auxiliaryItemFeeTax__c);
        }
    }
    //チェックボックス
    public void  checkBox(){
        if(screenTargetRecord.isReviewEntry){
            screenTargetRecord.isReviewEntry = false;
            screenTargetRecord.isReviewRequestProhibited= true;   
        }else{
            screenTargetRecord.isReviewEntry = true;
            screenTargetRecord.isReviewRequestProhibited= false;
        }
    }


    //再計算ボタン
    public void Recalculation(){
        try{
            Decimal s =0;
            if(!String.isBlank(screenTargetRecord.brokerageFirstFee)){
                s += commonUtil.stringToDecimal(screenTargetRecord.brokerageFirstFee);
            }
            if(!String.isBlank(screenTargetRecord.ParkingBrokerageFirstFee)){
                s += commonUtil.stringToDecimal(screenTargetRecord.ParkingBrokerageFirstFee);
            }
            if(!String.isBlank(screenTargetRecord.adFee )){
                s += commonUtil.stringToDecimal(screenTargetRecord.adFee);
            }

            if(!String.isBlank(screenTargetRecord.auxiliaryDepositPlanFee)){
                s += commonUtil.stringToDecimal(screenTargetRecord.auxiliaryDepositPlanFee);
            }
            if(!String.isBlank(screenTargetRecord.auxiliaryFireInsuranceFee )){
                s += commonUtil.stringToDecimal(screenTargetRecord.auxiliaryFireInsuranceFee);
            }
            for (CustomerUtil.AuxiliaryItem item: screenTargetRecord.etceteraAuxiliaryItemList) {
                s += item.auxiliaryItemFeeDec;
            }
            screenTargetRecord.sum = commonUtil.decimalToString(s);
        }catch(Exception e){
            CommonUtil.setErrorMessage(e);
        }
    }
    //保存
    public void save(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            hasErrorMessage = false;
            //楽観ロックチェック
            List<Application__c> checkOptimisticLockExceptionRecord = new List<Application__c>();
            checkOptimisticLockExceptionRecord = [ SELECT id
                                                     FROM Application__c
                                                    WHERE id = :applicationRecord.Id
                                                      AND SystemModStamp = :applicationRecord.systemModStamp ];
            //データ取得できない場合、楽観ロックチェックExceptionを発行
            if (checkOptimisticLockExceptionRecord.isEmpty()){
                OptimisticLockException ex = new OptimisticLockException();
                throw ex; 
            }
            //保存処理実行
            Application__c updateRecord = new Application__c(
                Id             = this.applicationRecord.Id,
                IsReviewEntry__c                = screenTargetRecord.isReviewEntry,//口コミ記入
                IsReviewRequestProhibited__c    = screenTargetRecord.isReviewRequestProhibited,//口コミ依頼お断わり
                BrokerageFirstFee__c            = commonUtil.stringToDecimal(screenTargetRecord.brokerageFirstFee),//仲介手数料
                ParkingBrokerageFirstFee__c     = commonUtil.stringToDecimal(screenTargetRecord.ParkingBrokerageFirstFee),//駐車場手数料
                ADFee__c                        = commonUtil.stringToDecimal(screenTargetRecord.adFee),//広告料
                AuxiliaryDepositPlan__c         = screenTargetRecord.auxiliaryDepositPlan,//付帯保証プラン
                AuxiliaryDepositPlanFee__c      = commonUtil.stringToDecimal(screenTargetRecord.auxiliaryDepositPlanFee),//付帯保証料金
                AuxiliaryFireInsurance__c       = screenTargetRecord.auxiliaryFireInsurance,//付帯火災保険
                AuxiliaryFireInsuranceFee__c    = commonUtil.stringToDecimal(screenTargetRecord.auxiliaryFireInsuranceFee),//付帯火災保険料
                  AuxiliaryItem1__c             = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(0).auxiliaryItemId        // 付帯商品１
                , auxiliaryItemFee1__c          = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(0).auxiliaryItemFeeDec    // 付帯商品料１
                , AuxiliaryItem2__c             = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(1).auxiliaryItemId        // 付帯商品２
                , auxiliaryItemFee2__c          = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(1).auxiliaryItemFeeDec    // 付帯商品料２
                , AuxiliaryItem3__c             = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(2).auxiliaryItemId        // 付帯商品３
                , auxiliaryItemFee3__c          = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(2).auxiliaryItemFeeDec    // 付帯商品料３
                , AuxiliaryItem4__c             = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(3).auxiliaryItemId        // 付帯商品４
                , auxiliaryItemFee4__c          = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(3).auxiliaryItemFeeDec    // 付帯商品料４
                , AuxiliaryItem5__c             = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(4).auxiliaryItemId        // 付帯商品５
                , auxiliaryItemFee5__c          = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(4).auxiliaryItemFeeDec    // 付帯商品料５
                , AuxiliaryItem6__c             = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(5).auxiliaryItemId        // 付帯商品６
                , auxiliaryItemFee6__c          = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(5).auxiliaryItemFeeDec    // 付帯商品料６
                , AuxiliaryItem7__c             = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(6).auxiliaryItemId        // 付帯商品７
                , auxiliaryItemFee7__c          = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(6).auxiliaryItemFeeDec    // 付帯商品料７
                , AuxiliaryItem8__c             = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(7).auxiliaryItemId        // 付帯商品８
                , auxiliaryItemFee8__c          = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(7).auxiliaryItemFeeDec    // 付帯商品料８
                , AuxiliaryItem9__c             = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(8).auxiliaryItemId        // 付帯商品９
                , auxiliaryItemFee9__c          = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(8).auxiliaryItemFeeDec    // 付帯商品料９
                , AuxiliaryItem10__c            = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(9).auxiliaryItemId        // 付帯商品１０
                , auxiliaryItemFee10__c         = screenTargetRecord.safeGetEtceteraAuxiliaryItemList(9).auxiliaryItemFeeDec    // 付帯商品料１０
            );
            SecureDML.secureUpdate(updateRecord);
            //画面の再取得
            this.screenTargetRecord = new ScreenItem(selectApplicatinInfo(this.applicationId));        
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
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
            Id selectItemId = screenTargetRecord.etceteraAuxiliaryItemName;
            String itemFee = screenTargetRecord.etceteraAuxiliaryItemFee;
            Integer listSize = screenTargetRecord.etceteraAuxiliaryItemList.size();

            // 入力チェック
            if (String.isEmpty(selectItemId) || String.isEmpty(itemFee)) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '付帯商品並びに、販売価格'));
                throw ex;
            }

            // 明細件数の最大登録チェック
            if (listSize >= ETCETERA_AUXILIARY_ITEM_LIST_COUNT) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_LESS, '付帯商品', String.valueOf(ETCETERA_AUXILIARY_ITEM_LIST_COUNT)));
                throw ex;
            }

            // １件追加
            CustomerUtil.AuxiliaryItem item = new CustomerUtil.AuxiliaryItem(etceteraAuxiliaryItemMap.get(selectItemId), itemFee);
            screenTargetRecord.etceteraAuxiliaryItemList.add(item);

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
            screenTargetRecord.etceteraAuxiliaryItemList.remove(idx);

        } catch(Exception e) {
            hasErrorMessage = true;             // エラーを設定
            CommonUtil.setErrorMessage(e);      // エラーメッセージを登録
        }
    }

    //----------------------------------------------------------------------------------------------------------------------------------
    //●privateメソッド
    //初期化
    private void init(){
        
        //パラメータ取得
        this.applicationId = ApexPages.currentPage().getParameters().get('applicationId'); //申込
        if(ApexPages.currentPage().getParameters().get('comeFrom') == 'App'){              //アプリ判定
            this.isApp = true;
        }else{
            this.isApp = false;
        }
        
        if(ApexPages.currentPage().getParameters().get('isKutikomi')=='true'){             //口コミ画面判定
            this.isKutikomi = true;
        }else{
            this.isKutikomi = false;
        }
        //店舗異動が取得できなければエラー
        CommonUtil.getStaffCurrentShop();
        //選択リスト初期化
        SelectAuxiliaryDepositPlanList = new List<SelectOption>();//付帯保証プラン
        SelectAuxiliaryFireInsuranceList = new List<SelectOption>();//付帯火災保険

        //Map初期化
        auxiliaryMap = new Map<Id, Decimal>();

        //画面表示変数の設定
         this.screenTargetRecord = new ScreenItem(selectApplicatinInfo(this.applicationId));        
        //
        //★選択リスト設定
        DepositPlanListSetting();//保証プラン
        fireInsuranceListSetting();//火災保険

        // 付帯商品Map初期化 ▼ 2022.02.15 No0727 共通化
		etceteraAuxiliaryItemMap = CustomerUtil.searchEtceteraAuxiaryItemRecode();
        // 付帯商品種別 ▼ 2022.02.15 No0727 パッケージ対応考慮
		this.SelectEtceteraAuxiliaryItemTypeList = CommonUtil.getSelectOptionFromObject(CommonUtil.getNamespace('Item__c'), CommonUtil.getNamespace('AuxiliaryItemType__c'));
        // 付帯商品名（業者／商品名／料金） ▼ 2022.02.15 No0727 共通化
        this.SelectEtceteraAuxiliaryItemNameList = CustomerUtil.getEtceteraAuxiliaryItemNameListFromType(screenTargetRecord.etceteraAuxiliaryItemName,etceteraAuxiliaryItemMap);


        //合計
        Recalculation();
    }
    
    //申込レコード取得
    private Application__c selectApplicatinInfo(String applicationId){
		List<Application__c> targetRecordList = [
			SELECT id,
				IsReviewEntry__c,//口コミ記入
				IsReviewRequestProhibited__c,//口コミ依頼お断わり
				BrokerageFirstFee__c,//仲介手数料
				ParkingBrokerageFirstFee__c,//駐車場紹介料
				ADFee__c,//広告料
				RentFee__c,//賃料
				AllRentFee__c,//総賃料
				AuxiliaryDepositPlan__c,//付帯保証プラン
				AuxiliaryDepositPlanFee__c,//付帯保証料金
				AuxiliaryFireInsurance__c,//付帯火災保険
				AuxiliaryFireInsuranceFee__c,//付帯火災保険料
				SystemModStamp
				, AuxiliaryItem1__c                             // 付帯商品１．付帯商品Id
				, AuxiliaryItem1__r.AuxiliaryItemType__c        // 付帯商品１．付帯商品種別
				, AuxiliaryItem1__r.Account__r.Name             // 付帯商品１．付帯業者
				, AuxiliaryItem1__r.ItemName__c                 // 付帯商品１．付帯商品
				, auxiliaryItemFee1__c                          // 付帯商品料１（販売価格１）
				, AuxiliaryItem2__c                             // 付帯商品２．付帯商品Id
				, AuxiliaryItem2__r.AuxiliaryItemType__c        // 付帯商品２．付帯商品種別
				, AuxiliaryItem2__r.Account__r.Name             // 付帯商品２．付帯業者
				, AuxiliaryItem2__r.ItemName__c                 // 付帯商品２．付帯商品
				, auxiliaryItemFee2__c                          // 付帯商品料２（販売価格２）
				, AuxiliaryItem3__c                             // 付帯商品３．付帯商品Id
				, AuxiliaryItem3__r.AuxiliaryItemType__c        // 付帯商品３．付帯商品種別
				, AuxiliaryItem3__r.Account__r.Name             // 付帯商品３．付帯業者
				, AuxiliaryItem3__r.ItemName__c                 // 付帯商品３．付帯商品
				, auxiliaryItemFee3__c                          // 付帯商品料３（販売価格３）
				, AuxiliaryItem4__c                             // 付帯商品４．付帯商品Id
				, AuxiliaryItem4__r.AuxiliaryItemType__c        // 付帯商品４．付帯商品種別
				, AuxiliaryItem4__r.Account__r.Name             // 付帯商品４．付帯業者
				, AuxiliaryItem4__r.ItemName__c                 // 付帯商品４．付帯商品
				, auxiliaryItemFee4__c                          // 付帯商品料４（販売価格４）
				, AuxiliaryItem5__c                             // 付帯商品５．付帯商品Id
				, AuxiliaryItem5__r.AuxiliaryItemType__c        // 付帯商品５．付帯商品種別
				, AuxiliaryItem5__r.Account__r.Name             // 付帯商品５．付帯業者
				, AuxiliaryItem5__r.ItemName__c                 // 付帯商品５．付帯商品
				, auxiliaryItemFee5__c                          // 付帯商品料５（販売価格５）
				, AuxiliaryItem6__c                             // 付帯商品６．付帯商品Id
				, AuxiliaryItem6__r.AuxiliaryItemType__c        // 付帯商品６．付帯商品種別
				, AuxiliaryItem6__r.Account__r.Name             // 付帯商品６．付帯業者
				, AuxiliaryItem6__r.ItemName__c                 // 付帯商品６．付帯商品
				, auxiliaryItemFee6__c                          // 付帯商品料６（販売価格６）
				, AuxiliaryItem7__c                             // 付帯商品７．付帯商品Id
				, AuxiliaryItem7__r.AuxiliaryItemType__c        // 付帯商品７．付帯商品種別
				, AuxiliaryItem7__r.Account__r.Name             // 付帯商品７．付帯業者
				, AuxiliaryItem7__r.ItemName__c                 // 付帯商品７．付帯商品
				, auxiliaryItemFee7__c                          // 付帯商品料７（販売価格７）
				, AuxiliaryItem8__c                             // 付帯商品８．付帯商品Id
				, AuxiliaryItem8__r.AuxiliaryItemType__c        // 付帯商品８．付帯商品種別
				, AuxiliaryItem8__r.Account__r.Name             // 付帯商品８．付帯業者
				, AuxiliaryItem8__r.ItemName__c                 // 付帯商品８．付帯商品
				, auxiliaryItemFee8__c                          // 付帯商品料８（販売価格８）
				, AuxiliaryItem9__c                             // 付帯商品９．付帯商品Id
				, AuxiliaryItem9__r.AuxiliaryItemType__c        // 付帯商品９．付帯商品種別
				, AuxiliaryItem9__r.Account__r.Name             // 付帯商品９．付帯業者
				, AuxiliaryItem9__r.ItemName__c                 // 付帯商品９．付帯商品
				, auxiliaryItemFee9__c                          // 付帯商品料９（販売価格９）
				, AuxiliaryItem10__c                            // 付帯商品１０．付帯商品Id
				, AuxiliaryItem10__r.AuxiliaryItemType__c       // 付帯商品１０．付帯商品種別
				, AuxiliaryItem10__r.Account__r.Name            // 付帯商品１０．付帯業者
				, AuxiliaryItem10__r.ItemName__c                // 付帯商品１０．付帯商品
				, auxiliaryItemFee10__c                         // 付帯商品料１０（販売価格１０）
			FROM Application__c 
			WHERE id = :this.applicationId ];
        
        //レコード情報が取得できなければビジネスロジックException発行
        if( targetRecordList.isEmpty() ){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        applicationRecord = targetRecordList[0];
        return targetRecordList[0];
    }


    //付帯保証プラン選択リスト
    private void DepositPlanListSetting(){
		List<ItemDetail__c> itemDetailList = CustomerUtil.getDepositPlan(); //2022.02.15 No0727 共通化 
        //vfの選択肢を作成        
        SelectAuxiliaryDepositPlanList.add(new SelectOption('', commonConst.SELECTION_LIST_NULL));//なし
        System.debug(itemDetailList.size());
        for (ItemDetail__c itemDetail : itemDetailList) {
            
            //選択肢
            SelectAuxiliaryDepositPlanList.add(new SelectOption(itemDetail.id, itemDetail.AuxiliaryDepositPlanName__c));
            //Map ▼ 2022.02.15 No0727 金額計算変更
            auxiliaryMap.put(itemDetail.id,CustomerUtil.depositPlanCalculation(itemDetail,applicationRecord.RentFee__c,applicationRecord.AllRentFee__c));
        }
    }

    //付帯火災保険選択リスト
    private void fireInsuranceListSetting(){
        List<Item__c> itemList = CustomerUtil.getFireInsuranceList(); // 2022.02.15 No0727 共通化
        //vfの選択肢を作成        
        SelectAuxiliaryFireInsuranceList.add(new SelectOption('', commonConst.SELECTION_LIST_NULL));//なし
        for (Item__c item : itemList) {
            //選択肢
            SelectAuxiliaryFireInsuranceList.add(new SelectOption(item.id, item.ItemName__c));
			//Map 選択された保険料×紹介料の割合(%) ▼ 2022.02.15 No0727 金額計算
			auxiliaryMap.put(item.id, ((item.FireInsuranceContent__c ==null ? 0 : item.FireInsuranceContent__c) * (item.InsuranceFeeRate__c==null ? 0 : item.InsuranceFeeRate__c /100)).intValue());
        }
    }

    //----------------------------------------------------------------------------------------------------------------------------------
    //●内部クラス

    //表示用の内部クラス
    public class ScreenItem{        
        //以下、画面用の項目
        public Boolean isReviewEntry{ get; set; }                //口コミ記入
        public Boolean isReviewRequestProhibited{ get; set; }    //口コミ依頼お断り
        public String brokerageFirstFee{ get; set; }           //仲介手数料
        public String ParkingBrokerageFirstFee{ get; set; }    //駐車場紹介料
        public String adFee{ get; set; }                       //広告料
        public Id auxiliaryDepositPlan { get; set; }        //付帯保証プラン
        public String auxiliaryDepositPlanFee{get; set;}        //付帯保証プラン料
        public Id auxiliaryFireInsurance{get; set;}         //付帯火災保険
        public String auxiliaryFireInsuranceFee{get; set;}      //付帯火災保険料
        public String etceteraAuxiliaryItemType {get; set;}     // その他付帯商品種別
        public String etceteraAuxiliaryItemName {get; set;}     // その他付帯商品名（業者／商品名／料金）
        public String etceteraAuxiliaryItemFee {get; set;}      // その他付帯商品販売価格
        public String sum {get; set;} //合計

        // リスト
        public List<CustomerUtil.AuxiliaryItem> etceteraAuxiliaryItemList { get; set; }              // その他付帯商品リスト

        //コンストラクタ
        public ScreenItem(Application__c targetRecord){
            this.isReviewEntry                  = targetRecord.IsReviewEntry__c;//口コミ記入チェックボックス
            this.isReviewRequestProhibited      = targetRecord.IsReviewRequestProhibited__c; //口コミ拒否
            this.brokerageFirstFee               = CommonUtil.decimalToString(targetRecord.BrokerageFirstFee__c ==0 ? null:targetRecord.BrokerageFirstFee__c);//仲介手数料
            this.ParkingBrokerageFirstFee        = CommonUtil.decimalToString(targetRecord.ParkingBrokerageFirstFee__c ==0 ? null:targetRecord.ParkingBrokerageFirstFee__c);//駐車場紹介料
            this.adFee                           = CommonUtil.decimalToString(targetRecord.ADFee__c ==0 ? null:targetRecord.ADFee__c);//広告料
            //保証プラン
            this.auxiliaryDepositPlan            = targetRecord.AuxiliaryDepositPlan__c;
            this.auxiliaryDepositPlanFee         = CommonUtil.decimalToString(targetRecord.AuxiliaryDepositPlanFee__c==0 ? null:targetRecord.AuxiliaryDepositPlanFee__c);
            //火災保険
            this.auxiliaryFireInsurance          = targetRecord.AuxiliaryFireInsurance__c;           
            this.auxiliaryFireInsuranceFee       = CommonUtil.decimalToString(targetRecord.AuxiliaryFireInsuranceFee__c ==0 ? null:targetRecord.AuxiliaryFireInsuranceFee__c);

            // その他付帯商品リスト
            this.etceteraAuxiliaryItemList = new List<CustomerUtil.AuxiliaryItem>();
            for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
                CustomerUtil.AuxiliaryItem item = new CustomerUtil.AuxiliaryItem(targetRecord, i);
                if (!String.isempty(item.auxiliaryItemId)) {
                    this.etceteraAuxiliaryItemList.add(item);
                }
            }
        }

        // 値取得用メソッド
        public CustomerUtil.AuxiliaryItem safeGetEtceteraAuxiliaryItemList(Integer idx) {
            if (idx < etceteraAuxiliaryItemList.size()) {
                return etceteraAuxiliaryItemList.get(idx);
            } else {
                return new CustomerUtil.AuxiliaryItem();
            }
        }
    }

}