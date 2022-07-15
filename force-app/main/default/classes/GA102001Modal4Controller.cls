// 入金画面
public with sharing class GA102001Modal4Controller {
    // 定数
    private static final Integer ETCETERA_AUXILIARY_ITEM_LIST_COUNT = 10;

    /** 共通クラス */    
    public GA102001Modal4ParameterClass Parameter { get; set; }

    /** エラーフラグ */ 
    public Boolean isOpenError { get; set; }
    
    /** エラーメッセージ保有フラグ */ 
    public Boolean hasErrorMessage { get; set; }
     
    //パブリック変数
    public Boolean isNew { get; set; }                 //新規登録フラグ
    public ScreenItem screenTargetRecord {set;get;}    //画面表示用の内部クラスレコード
    //選択リスト
    public List<SelectOption> SelectAuxiliaryDepositPlanList{ get; set; }        //付帯保証プラン
    public List<SelectOption> SelectAuxiliaryFireInsuranceList{ get; set; }      //付帯火災保険
    public List<SelectOption> SelectEtceteraAuxiliaryItemTypeList { get; set; }         // 付帯商品種別
    public List<SelectOption> SelectEtceteraAuxiliaryItemNameList { get; set; }         // 付帯商品名（業者／商品名／料金）
    //Map
    public Map<Id, Decimal> auxiliaryMap;
    //合計

    //メッセージ
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    // js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    // js用削除完了メッセージ


    //プライベート変数
    private String applicationId;                   //パラメータ申込ID
    private String CorrespondId;                    //パラメータ対応ID
    private String checkCorrespondId;               //申込ID
    private Application__c applicationRecord;       //申込レコード
    private Map<Id, Item__c> etceteraAuxiliaryItemMap;        // 付帯商品レコードのマップ

    private Datetime CorrespondSystemModstamp;      //対応の更新日付  

    public String loginStaff { get;set; }       // ログインユーザ(登録用)
    public String loginShop { get;set; }        // ログインユーザ店舗
    
    //コンストラクタ
    public Boolean init{
        get{
            if (Parameter.isDrawing) {
                getSelectDeposit();
                Parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }

    //●publicメソッド
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
            BusinessLogicException inputCheckex = new BusinessLogicException();
            //楽観ロックチェック（申込）
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

            //楽観ロックチェック（対応）
            List<Correspond__c> checkOptimisticLockExceptionCorrespondRecord = new List<Correspond__c>();
            checkOptimisticLockExceptionCorrespondRecord = [ SELECT id
                                                        FROM Correspond__c
                                                        WHERE id = :this.CorrespondId
                                                        AND SystemModStamp = :this.CorrespondSystemModstamp ];
            //データ取得できない場合、楽観ロックチェックExceptionを発行
            if (checkOptimisticLockExceptionCorrespondRecord.isEmpty()){
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }

            // 入力チェック（入金日）
            if (screenTargetRecord.PaymentDate == null) {
                inputCheckex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'入金日'));
                throw inputCheckex;
            }
            
            //保存処理実行
            Application__c updateRecord = new Application__c(
                Id             = this.applicationRecord.Id,
                PaymentDate__c                  = screenTargetRecord.PaymentDate,// 入金日
                BrokerageFirstFee__c            = commonUtil.stringToDecimal(screenTargetRecord.brokerageFirstFee),//仲介手数料
                ParkingBrokerageFirstFee__c     = commonUtil.stringToDecimal(screenTargetRecord.ParkingBrokerageFirstFee),//駐車場紹介料
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


            // 対応の更新
            saveCorrespond(this.CorrespondId);

            // 対応明細の登録
            saveCorrespondDetail(this.CorrespondId,applicationRecord.Account__c);
            
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    //初期化
    public void getSelectDeposit(){
        try{
            //パラメータ取得
            this.applicationId = Parameter.ApplicationId;
            this.CorrespondId = Parameter.CorrespondId;
            this.screenTargetRecord = new ScreenItem();

            // 店舗情報の取得
            Shop__c shop = CommonUtil.getStaffCurrentShop();
            loginShop = shop.id;                            // 店舗名
            loginStaff = UserInfo.getUserId();
            List<Correspond__c> CorrespondRecord = new List<Correspond__c>();
            CorrespondRecord = [ SELECT Id 
                                    ,SystemModstamp 
                                FROM  Correspond__c 
                                WHERE Id =:this.CorrespondId];  
            if (CorrespondRecord.size() > 0){
                this.CorrespondSystemModstamp = CorrespondRecord[0].SystemModstamp ;
            }
            
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
        }catch(Exception e){
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

    //---------------------------------------------------------------------------------------------
    //●privateメソッド
    //申込レコード取得
    private Application__c selectApplicatinInfo(String applicationId){
        List<Application__c> targetRecordList = [SELECT id,
                                                        PaymentDate__c,//入金日
                                                        BrokerageFirstFee__c,//仲介手数料
                                                        ParkingBrokerageFirstFee__c,//駐車場紹介料
                                                        ADFee__c,//広告料
                                                        RentFee__c,//賃料
                                                        AllRentFee__c,//総賃料
                                                        AuxiliaryDepositPlan__c,//付帯保証プラン
                                                        AuxiliaryDepositPlanFee__c,//付帯保証料金
                                                        AuxiliaryFireInsurance__c,//付帯火災保険
                                                        AuxiliaryFireInsuranceFee__c,//付帯火災保険料
                                                        SystemModStamp,
                                                        Account__c    
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
            OptimisticLockException ex = new OptimisticLockException();
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
			//Map 選択された保険料×紹介料の割合(%) ▼ 2022.02.15 No0727 金額計算変更
			auxiliaryMap.put(item.id, ((item.FireInsuranceContent__c ==null ? 0 : item.FireInsuranceContent__c) * (item.InsuranceFeeRate__c==null ? 0 : item.InsuranceFeeRate__c /100)).intValue());
        }
    }

    /**
     * 更新処理(対応)
     * 引数　　：　Id String 対応ID
     * 戻り値　：  
     */
    private Boolean saveCorrespond(String Id){
        // 保存処理
        Correspond__c saveDate = new Correspond__c();

        String ShopStaff = '';
        // 対応IDから来店担当者を取得
        List<Correspond__c> CorrespondList = [
                        SELECT Id
                        ,      ShopStaff__c
                        FROM Correspond__c
                        WHERE Id = :Id
                       ];
        if (CorrespondList.size() > 0){
            ShopStaff = CorrespondList[0].ShopStaff__c;
        }

        // 更新によりIDをセット
        saveDate.Id = Id;
        // 保存項目
        
        // ステータス	
        saveDate.EventDateTime__c = CommonUtil.getNow();// イベント時刻															
        saveDate.IsSupportedListShow__c = false;// 対応確認															
        saveDate.Status__c = CommonConst.CORRESPOND_STATUS_DEPOSIT; //入金済

        // ログインユーザーと来店担当者とが一致しなければ：False、以外はTreu スタッフ対応フラグ
        if (this.loginStaff ==  ShopStaff){
            saveDate.StaffSupportedFlg__c = true;
        }else {
            saveDate.StaffSupportedFlg__c = false;
        }
        SecureDML.secureUpsert(saveDate);
        return True;
    }

    /**
     * 登録処理(対応明細)
     * 引数　　：　CorrespondId String 対応Id
     *        ：  AccountId String 取引先
     * 戻り値　：  
     */
    private Boolean saveCorrespondDetail(String CorrespondId,String AccountId){
        // 保存処理
        CorrespondDetail__c saveDate = new CorrespondDetail__c();

        // 保存項目
        saveDate.CorrespondType__c      = CommonConst.TASK_CORRESPONDTYPE_DEPOSIT;    // 対応種別
        saveDate.SupportedDateTime__c   = CommonUtil.getNow();          // 対応日時
        saveDate.SupportedTitle__c      = '入金を実施しました。';    // 対応表題
        
        saveDate.SupportedContent__c    = CommonConst.CORRESPOND_STATUS_DEPOSIT + CommonConst.BREAK_CODE;  // 対応内容
        List<Correspond__c> CorrespondRecord = new List<Correspond__c>();
        CorrespondRecord = [ SELECT Id 
                                ,Property__c
                                ,Property__r.Building__r.Name 
                                ,Property__r.Name
                                ,SystemModstamp 
                            FROM  Correspond__c 
                            WHERE Id =:CorrespondId];  
        if (CorrespondRecord.size() > 0){
            saveDate.SupportedContent__c   += '物件：'+ CorrespondRecord[0].Property__r.Building__r.Name + ' ' 
                                            + CorrespondRecord[0].Property__r.Name + CommonConst.BREAK_CODE;  // 対応内容
        }
        saveDate.SupportedContent__c   += '仲介手数料：'+ screenTargetRecord.brokerageFirstFee + CommonConst.BREAK_CODE; // 対応内容（仲介手数料)
        saveDate.SupportedContent__c   += '駐車場紹介料' + screenTargetRecord.ParkingBrokerageFirstFee +  CommonConst.BREAK_CODE; // 対応内容（駐車場紹介料）
        saveDate.SupportedContent__c   += '広告宣伝費：'+screenTargetRecord.adFee + CommonConst.BREAK_CODE; // 対応内容（広告宣伝費）
        saveDate.SupportedContent__c   += '合計：'+screenTargetRecord.sum; // 対応内容（合計）
        saveDate.Shop__c                = loginShop;                    // 店舗
        saveDate.Staff__c               = loginStaff;                   // 担当者
        saveDate.Corresponds__c         = CorrespondId;                 // 対応ID

        SecureDML.secureInsert(saveDate);

        return True;
    }

    //----------------------------------------------------------------------------------------------------------------------------------
    //●内部クラス

    //表示用の内部クラス
    public class ScreenItem{
       
        //以下、画面用の項目
        public Date PaymentDate { get; set; }                    //入金日
        public String brokerageFirstFee{ get; set; }           //仲介手数料
        public String ParkingBrokerageFirstFee{ get; set; }    //駐車場紹介料
        public String adFee{ get; set; }                       //広告料
        public String auxiliaryDepositPlan { get; set; }        //付帯保証プラン
        public String auxiliaryDepositPlanFee{get; set;}        //付帯保証プラン料
        public String auxiliaryFireInsurance{get; set;}         //付帯火災保険
        public String auxiliaryFireInsuranceFee{get; set;}      //付帯火災保険料
        public String etceteraAuxiliaryItemType {get; set;}     // その他付帯商品種別
        public String etceteraAuxiliaryItemName {get; set;}     // その他付帯商品名（業者／商品名／料金）
        public String etceteraAuxiliaryItemFee {get; set;}      // その他付帯商品販売価格
        public String sum {get; set;} //合計

        // リスト
        public List<CustomerUtil.AuxiliaryItem> etceteraAuxiliaryItemList { get; set; }              // その他付帯商品リスト

        //コンストラクタ
        public ScreenItem(Application__c targetRecord){
            this.PaymentDate                     = targetRecord.PaymentDate__c;//入金日            
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

        //コンストラクタ(初期化)
        public ScreenItem(){
            this.PaymentDate                     = null;//入金日
            this.brokerageFirstFee               = CommonConst.STRING_EMPTY;//仲介手数料
            this.ParkingBrokerageFirstFee        = CommonConst.STRING_EMPTY;//駐車場紹介料
            this.adFee                           = CommonConst.STRING_EMPTY;//広告料
            //保証プラン
            this.auxiliaryDepositPlan            = CommonConst.STRING_EMPTY;
            this.auxiliaryDepositPlanFee         = CommonConst.STRING_EMPTY;
            //火災保険
            this.auxiliaryFireInsurance          = CommonConst.STRING_EMPTY;           
            this.auxiliaryFireInsuranceFee       = CommonConst.STRING_EMPTY;           

            // その他付帯商品リスト
            this.etceteraAuxiliaryItemList = new List<CustomerUtil.AuxiliaryItem>();
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