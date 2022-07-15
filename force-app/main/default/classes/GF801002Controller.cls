/* *
 * 火災保険会社登録画面のコントローラ
 */
public inherited sharing class GF801002Controller {
    /** パブリック変数 */
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    //js用削除完了メッセージ
    
    public Boolean isNew { get; set; }    //新規登録フラグ
    public Boolean isOpenError { get; set; }    //初期表示エラーフラグ
    public Boolean hasErrorMessage { get; set; }    //Excepttionエラーフラグ

    public ID targetId{ get; set; }    //対象ID

    public screenAccount screenTargetRecord { get; set; }     //画面表示用の内部クラスレコード
    public List<SelectOption> SelectStateList{ get; set; }    //都道府県選択リスト

    //商品明細リスト用
    public List<screenItem> screenItemList { get; set; }            //表示用商品＋チェックボックスリスト
    public Integer selectedIndex { get; set; }                      //商品リストの商品名選択リンクインデックス
    public Boolean allCheckItem { get; set; }                       //商品リストチェックボックス(全選択)    

    /** 共通クラス **/    
    public GA102006ParameterClass GA102006Parameter{get; set;}      //郵便番号検索モーダル
    public GF801004ParameterClass GF801004Parameter { get; set; }    //モーダル用

    /** プライベート変数 */
    private Boolean isOpenModalCreate;    //新規モーダルフラグ

    @TestVisible private ID targetAccountRecordTypeId;        //対象レコードタイプ(取引先)
    @TestVisible private Correspond__c targetCorrespondRecord;//対応レコード

    private List<Item__c> deleteItemList;                   //商品削除用リスト
    private List<Item__c> upsertItemList;                   //商品登録・更新用リスト

    //コンストラクタ
    public GF801002Controller(){      
        try{
            //初期化
            init();
            //対象IDを取得
            targetId = ApexPages.currentPage().getParameters().get('Id');
            //レコードタイプID取得
            targetAccountRecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_FIRE_INSURANCE);

            //対象IDが取得できない場合は新規登録フラグにTRUEを設定する
            if(this.targetId == null){
                this.isNew = true;
                this.screenTargetRecord = new screenAccount(new Account());
            
            //対象IDが取得できた場合は新規登録フラグにFALSEを設定する
            } else {
                this.isNew = false;
                this.screenTargetRecord = new screenAccount(SelectAccountRecordInfo(this.targetId));
                this.targetCorrespondRecord = SelectCorrespondRecordInfo(this.targetId);

                //関連する火災保険プランリストを作成
                for(Item__c item : selectItemInfo(this.targetId)){
                    this.screenItemList.add(new screenItem(item));
                }
            }    

        } catch (Exception e) {
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    //◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇publicメソッド◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇

    //保存ボタン押下処理
    public void TargetRecordSave(){
        Savepoint sp = Database.setSavepoint();      //トランザクションのセーブポイント作成
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();

            //入力チェック
            List<String> requiredItem = new List<String>();
            if (String.isBlank(screenTargetRecord.name)){
                requiredItem.add('火災保険会社');
            }
            if (String.isBlank(screenTargetRecord.postalCode)){
                requiredItem.add('郵便番号');
            }
            if (String.isBlank(screenTargetRecord.state)){
                requiredItem.add('都道府県');
            }
            if (String.isBlank(screenTargetRecord.city)){
                requiredItem.add('住所１（市区町村）');
            }
            if (String.isBlank(screenTargetRecord.phone)){
                requiredItem.add('電話番号');
            }

            //入力チェック用リストが空ではない場合、ビジネスロジックException発行
            if (!requiredItem.isEmpty()){
                hasErrorMessage = true;
                
                //項目名をカンマで区切って、ビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
            }

            // メールアドレス:メールアドレスの入力規則をチェックし、間違っていればエラー
            if(CommonUtil.isWrongMailString(screenTargetRecord.email)){
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_MAILADDRESS_VALIDATION, 'メールアドレス'));
            }
            
            //ビジネスロジックExceptionにメッセージが1つ以上ある場合、ビジネスロジックException発行
            if (ex.hasMessage()){ 
                throw ex;
            }
            //新規でない場合、データ取得処理を実施
            if (!isNew){
                List<Account> checkOptimisticLockExceptionRecord = new List<Account>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                         FROM Account
                                                        WHERE id = :this.screenTargetRecord.targetAccountRecord.Id
                                                          AND SystemModStamp = :this.screenTargetRecord.targetAccountRecord.systemModStamp
                                                     ];

                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException ex2 = new OptimisticLockException();
                    throw ex2;
                }
            }

            //保存処理実行
            Account upsertRecord = new Account(
                 Id                      = this.screenTargetRecord.targetAccountRecord.Id
                ,Name                    = this.screenTargetRecord.name         //火災保険会社
                ,PostalCode__c           = this.screenTargetRecord.postalCode   //郵便番号
                ,State__c                = this.screenTargetRecord.state        //都道府県
                ,City__c                 = this.screenTargetRecord.city         //市区町村
                ,Street__c               = this.screenTargetRecord.street       //丁目・番地
                ,Phone                   = this.screenTargetRecord.phone        //電話番号
                ,Fax                     = this.screenTargetRecord.fax          //FAX
                ,Email__c                = this.screenTargetRecord.email        //メールアドレス
                ,RemarksPublic__c        = this.screenTargetRecord.remarksPublic//備考（公開）
                ,RecordTypeID            = targetAccountRecordTypeId            //レコードタイプID
            );
            SecureDML.secureUpsert(upsertRecord);

            this.targetId = upsertRecord.Id;
            screenTargetRecord = new screenAccount(SelectAccountRecordInfo(upsertRecord.Id));

            //新規の場合は対応レコードを作成する
            if(isNew){
                Datetime eventDateTime = CommonUtil.getNow();
                DateTime listViewDate = Datetime.newInstance(2999, 12, 31, 12, 59, 0);
                this.targetCorrespondRecord = new Correspond__c(
                    AccountId__c           = this.screenTargetRecord.targetAccountRecord.Id
                   ,Status__c              = CommonConst.CORRESPOND_STATUS_CLOSE
                   ,EventDateTime__c       = eventDateTime
                   ,IsSupportedListShow__c = True
                   ,District__c            = CommonConst.STRING_EMPTY
                   ,StaffSupportedFlg__c   = True
                   ,IsBrowseFlg__c         = True
                   ,ListViewDate__c        = listViewDate
                );
                SecureDML.secureInsert(targetCorrespondRecord);
            }
        
            //商品保存
            //商品登録・更新用にレコードが入っている場合、その火災保険プランを登録・更新
            this.upsertItemList = new List<Item__c>();
            
            //取引先が空(新規商品)の場合、設定する
            for(screenItem item : this.screenItemList){
                if(String.isEmpty(item.itemRecord.Account__c)){
                    item.itemRecord.Account__c = this.targetId;    
                }
                this.upsertItemList.add(item.itemRecord);
            }
            
            //空でなければupsert
            if(!this.upsertItemList.isEmpty()){
                SecureDML.secureUpsert(upsertItemList);
            }

            //商品削除
            //商品削除用に商品が入っている場合、その商品を削除
            if (!this.deleteItemList.isEmpty()){
                SecureDML.secureDelete(deleteItemList);
            }

            //取引先保険保証を取得し、Itemがないレコードを削除する
            List<InsuranceGuarantee__c> insGuar = [SELECT id FROM InsuranceGuarantee__c WHERE Item__c = null];
            if (insGuar.size() != 0){
                SecureDML.secureDelete(insGuar);
            }
        }catch(Exception e){

            Database.rollback(sp);    //処理をロールバック
            hasErrorMessage = true;    //エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    //削除ボタン押下処理
    public void TargetRecordDelete(){
        Savepoint sp = Database.setSavepoint();      //トランザクションのセーブポイント作成
        try{
            hasErrorMessage = false;

            //対応明細取得
            List<CorrespondDetail__c> targetList = [ SELECT Id
                                        FROM CorrespondDetail__c
                                       WHERE Corresponds__c = :this.targetCorrespondRecord.Id
                                       LIMIT 1
                                    ];
            
            //対応明細が取得できた場合はビジネスロジックExceptionを発行する
            if (targetList.size() > 0){

                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_NOTICE_USED));
                throw ex;

            }else{

                //取引先レコード削除
                SecureDML.secureDelete(screenTargetRecord.targetAccountRecord);

                //取引先保険保証を取得し、Itemがないレコードを削除する
                List<InsuranceGuarantee__c> insGuar = [SELECT id FROM InsuranceGuarantee__c WHERE Item__c = null];
                if (insGuar.size() != 0){
                    SecureDML.secureDelete(insGuar);
                }

                //対応レコードがあれば対応レコード削除
                if (targetCorrespondRecord != null){
                    SecureDML.secureDelete(targetCorrespondRecord);
                }
                

            }

        }catch(Exception e){
            
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
            
        }
    }

    //郵便番号検索モーダルopen処理
    public void openModal() {
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;

        GA102006Parameter.isAddressMoster = TRUE;                             /** 住所マスタフラグ */
        GA102006Parameter.postalCode = this.screenTargetRecord.postalCode;    /** 郵便番号 */     
        GA102006Parameter.state = this.screenTargetRecord.state;              /** 都道府県 */       
        GA102006Parameter.city = this.screenTargetRecord.city;                /** 市区町村 */  
        GA102006Parameter.street = null;                                      /** 町域 */    
    }

    //郵便番号検索モーダルclose処理
    public void closeModal() {
        this.screenTargetRecord.postalCode = GA102006Parameter.postalCode;     /** 郵便番号 */   
        this.screenTargetRecord.state = GA102006Parameter.state;               /** 都道府県 */    
        this.screenTargetRecord.city = GA102006Parameter.city + GA102006Parameter.street;    /** 市区町村 */  
        this.screenTargetRecord.street = null;                                  /** 町域 */  
    }

    //火災保険プラン登録画面(新規)モーダル起動
    public void openModalCreateItem() {
        this.isOpenModalCreate = true;

        this.GF801004Parameter = new GF801004ParameterClass();
        GF801004Parameter.isDrawing = true;
        GF801004Parameter.noFirst = true;

        //火災保険名をモーダルに渡す
        GF801004Parameter.companyName = screenTargetRecord.name;
        //商品レコードを新規作成
        GF801004Parameter.targetItem = new Item__c();

    }

    //火災保険プラン登録画面(編集)モーダル起動
    public void openModalUpdateItem() {
        this.isOpenModalCreate = false;//商品名リンクをクリックして編集として開いた
        
        GF801004Parameter = new GF801004ParameterClass();
        GF801004Parameter.isDrawing = true;
        GF801004Parameter.noFirst = true;

        //火災保険名をモーダルに渡す
        GF801004Parameter.companyName = screenTargetRecord.name;
        //選択した行のレコードをモーダルに渡す
        GF801004Parameter.targetItem = screenItemList[selectedIndex].itemRecord;

    }

    //火災保険プラン登録画面モーダル終了
    public void closeNewModal() {
        if(isOpenModalCreate){
            //isOpenModalCreateがTRUEなら行追加
            this.screenItemList.add(new screenItem(GF801004Parameter.targetItem));
        }else{
            //編集の場合、料金だけレコード表示でなく個別表記なので再設定
            if (this.screenItemList[selectedIndex].itemRecord.PaymentType__c == CommonConst.ITEM_PAYMENTTYPE_YEAR) {
                this.screenItemList[selectedIndex].insuranceFee = CommonUtil.decimalToString(this.screenItemList[selectedIndex].itemRecord.FireInsuranceYear__c);
                this.screenItemList[selectedIndex].paymentType = this.screenItemList[selectedIndex].itemRecord.PaymentYear__c + '年更新';
            } else if (this.screenItemList[selectedIndex].itemRecord.PaymentType__c == CommonConst.ITEM_PAYMENTTYPE_MONTH) {
                this.screenItemList[selectedIndex].insuranceFee = CommonUtil.decimalToString(this.screenItemList[selectedIndex].itemRecord.FireInsuranceMonth__c);
                this.screenItemList[selectedIndex].paymentType = '月更新';
            }

            if (this.screenItemList[selectedIndex].itemRecord.IsAuxiliary__c == true) {
                this.screenItemList[selectedIndex].isAuxiliary = '付帯商品';
            } else if (this.screenItemList[selectedIndex].itemRecord.IsAuxiliary__c == false) {
                this.screenItemList[selectedIndex].isAuxiliary = '付帯商品以外';
            }

            this.screenItemList[selectedIndex].tenantCompensation = CommonUtil.decimalToString(this.screenItemList[selectedIndex].itemRecord.TenantCompensation__c);
            this.screenItemList[selectedIndex].houseGoodsDeposit = CommonUtil.decimalToString(this.screenItemList[selectedIndex].itemRecord.HouseGoodsDeposit__c);
        }

        //商品数カウントを更新
        screenTargetRecord.planCount = this.screenItemList.size();
    }

    //商品削除ボタン押下処理
    public void targetItemRecordDelete(){

        //コピーリスト
        List<screenItem> copyList = new List<screenItem>();

        for(screenItem item : this.screenItemList){

            //チェック付きレコード の場合 
            if(item.isItemCheck){

                //新規作成ではないレコードは削除リストに追加
                if(!String.isEmpty(item.itemRecord.id)){
                    this.deleteItemList.add(item.itemRecord);
                }

            //未チェックレコードの場合
            }else{
                //商品をコピーリストに待避
                copyList.add(item);
            }
        }
        
        //内部クラスリストに削除対象ではないレコードをコピーする
        this.screenItemList = copyList.clone();
        //商品数カウントを更新
        screenTargetRecord.planCount = this.screenItemList.size();
    }

    //◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇privateメソッド◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇
     //初期化メソッド
    private void init(){
        isNew = false;
        isOpenError = false;
        hasErrorMessage = false;
        //店舗異動が取得できなければエラー
        CommonUtil.getStaffCurrentShop();

        //都道府県選択リスト取得
        SelectStateList = CommonUtil.getSelectOptionFromObject('Account', 'State__c');
        
        //郵便番号モーダル初期化
        GA102006Parameter = new GA102006ParameterClass(); 

        //登録画面モーダル初期化
        this.GF801004Parameter = new GF801004ParameterClass();

        //商品クラス初期化
        this.screenItemList = new List<screenItem>();

        //商品削除用初期化
        this.deleteItemList = new List<Item__c>();

        //商品リスト全選択チェックボックス初期化
        this.allCheckItem = false;
    }

    //取引先レコード情報取得（入力項目）
    private Account SelectAccountRecordInfo(Id targetId){

        List<Account> targetAccountList = [ SELECT Id,  //レコードID
                                                   Name,  //火災保険会社
                                                   PlanCount__c,  //プラン数
                                                   PostalCode__c,  //郵便番号
                                                   State__c,  //都道府県
                                                   City__c,  //住所１
                                                   Street__c,  //住所２
                                                   Phone,  //電話番号
                                                   Fax,  //FAX
                                                   Email__c,  //メールアドレス
                                                   RemarksPublic__c,  //備考（公開）
                                                   SystemModStamp  //マッドスタンプ
                                              FROM Account
                                             WHERE Id = :this.targetId
                                               AND RecordTypeID = :this.targetAccountRecordTypeId
                                          ];
        
        //レコードが取得できない場合はビジネスロジックExceptionを発行する
        if(targetAccountList.isEmpty()){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        
        return targetAccountList[0];

    }

    //商品情報取得
    private List<Item__c> selectItemInfo(Id targetId){
        List<Item__c> targetItemList = [ SELECT Id,
                                                Account__c,   //取引先ID
                                                ItemName__c,   //商品名
                                                FireInsuranceYear__c,   //火災保険料(年額)
                                                FireInsuranceMonth__c,   //火災保険料(月額)
                                                TenantCompensation__c,   //借家人賠償額
                                                HouseGoodsDeposit__c,   //家財保証額
                                                PaymentType__c,   //更新期間
                                                PaymentYear__c,   //更新年数
                                                IsAuxiliary__c,   //付帯商品区分
                                                InsuranceFeeRate__c,   //保険料割合（火災保険）
                                                FireInsurance__c,   //保険内容
                                                RecordTypeId
                                           FROM Item__c
                                          WHERE Account__c = :this.targetId
                                          AND   RecordTypeId = :commonUtil.getRecordTypeId('Item__c',commonConst.ITEM_RECTYPE_FIRE_INSURANCE)
                                       ];
        
        //リストが0件の場合表示しない、リストが存在する場合すべて表示する
        if(targetItemList.isEmpty()){
            targetItemList = new List<Item__c>();
        }
        return targetItemList;
    }

    //対応レコード情報取得
    private Correspond__c SelectCorrespondRecordInfo(Id targetId){
        
        List<Correspond__c> targetCorrespondList = [ SELECT Id
                                                       FROM Correspond__c
                                                      WHERE AccountId__c = :this.targetId
                                                   ];
        
        //レコードが取得できない場合はビジネスロジックExceptionを発行する
        if(targetCorrespondList.isEmpty()){
            
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
            
        }
        return targetCorrespondList[0];
    }

    //*****************************************内部クラス******************************************
    //画面表示用内部クラス
    public class screenAccount {
        public Account targetAccountRecord { get; set; }    //レコード本体(取引先)
        
        //以下、画面用の項目
        public String name { get; set; }                //取引先名
        public String titleName { get; set; }           //ヘッダー表示用取引先名
        public Decimal planCount { get; set; }          //プラン数
        public String postalCode { get; set; }          //郵便番号
        public String state { get; set; }               //都道府県
        public String city { get; set; }                //住所１（市区町村）
        public String street { get; set; }              //住所２（丁目・番地）
        public String phone { get; set; }               //電話番号
        public String fax { get; set; }                 //FAX
        public String email { get; set; }               //メールアドレス
        public String remarksPublic { get; set; }       //備考（公開）

        //コンストラクタ
        public screenAccount(Account targetAccountRecord){

            //取引先レコードの連動
            this.targetAccountRecord = targetAccountRecord;
            this.name = targetAccountRecord.Name;
            this.titleName = targetAccountRecord.Name;
            this.planCount = targetAccountRecord.PlanCount__c;
            this.postalCode = targetAccountRecord.PostalCode__c;
            this.state = targetAccountRecord.State__c;
            this.city = targetAccountRecord.City__c;
            this.street = targetAccountRecord.Street__c;
            this.phone = targetAccountRecord.Phone;
            this.fax = targetAccountRecord.Fax;
            this.email = targetAccountRecord.Email__c;
            this.remarksPublic = targetAccountRecord.RemarksPublic__c;

        }
    }

    //商品+チェックボックス用内部クラス
    public class screenItem{

        public Item__c itemRecord { get; set; }//商品レコード

        //画面用の項目
        public Boolean isItemCheck { get; set; }//チェックボックス
        public String insuranceFee { get; set; }//保険料
        public String tenantCompensation { get; set; }//借家人賠償額
        public String houseGoodsDeposit { get; set; }//家財保証額
        public String paymentType { get; set; }//更新期間
        public String isAuxiliary { get; set; }//付帯商品区分

        //コンストラクタ
        public screenItem(Item__c item){

            //チェックボックスを初期化
            this.isItemCheck = false;

            //内部クラスに引数の商品を連動
            this.itemRecord = item;

            if (this.itemRecord.PaymentType__c == CommonConst.ITEM_PAYMENTTYPE_YEAR){
                //年更新の場合
                this.insuranceFee = commonUtil.decimalToString(this.itemRecord.FireInsuranceYear__c);
                this.paymentType = this.itemRecord.PaymentYear__c + '年更新';
            } else if (this.itemRecord.PaymentType__c == CommonConst.ITEM_PAYMENTTYPE_MONTH) {
                //月更新の場合
                this.insuranceFee = commonUtil.decimalToString(this.itemRecord.FireInsuranceMonth__c);
                this.paymentType = '月更新';
            }

            if (this.itemRecord.IsAuxiliary__c == true) {
                //付帯商品区分がTrueの場合
                this.isAuxiliary = '付帯商品';
            } else if (this.itemRecord.IsAuxiliary__c == false) {
                //付帯商品区分がFalseの場合
                this.isAuxiliary = '付帯商品以外';
            }

            this.tenantCompensation = CommonUtil.decimalToString(this.itemRecord.TenantCompensation__c);
            this.houseGoodsDeposit = CommonUtil.decimalToString(this.itemRecord.HouseGoodsDeposit__c);
        }
    }
}