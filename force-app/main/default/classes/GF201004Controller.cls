/* *
 * 付帯商品業者登録画面のコントローラ
 */

public inherited sharing class GF201004Controller {
        
    /** 共通クラス **/    
    public GA102006ParameterClass GA102006Parameter{get; set;}      //郵便番号検索モーダル
    public GF201002ParameterClass GF201002Parameter { get; set; }   //付帯商品登録モーダル用

    /** パブリック変数 */
    public Boolean isNew { get; set; }                              //新規登録フラグ
    public Boolean isOpenError { get; set; }                        //初期表示エラーフラグ
    public Boolean hasErrorMessage { get; set; }                    //Excepttionエラーフラグ
    public ID targetId{ get; set; }                                 //対象（取引先）ID

    public screenAccount screenTargetRecord { get; set; }           //画面表示用の内部クラスレコード
    public List<SelectOption> SelectStateList{ get; set; }          //都道府県選択リスト

    //商品明細リスト用
    public List<screenItem> screenItemList { get; set; }            //表示用商品＋チェックボックスリスト
    public Integer selectedIndex { get; set; }                      //商品リストの商品名選択リンクインデックス
    public Boolean allCheckItem { get; set; }                       //商品リストチェックボックス(全選択)

    //メッセージ表示用
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    //js用削除完了メッセージ
    
    /** プライベート変数 */
    @TestVisible private ID targetAccountRecordTypeId;        //対象レコードタイプ(取引先)
    @TestVisible private Correspond__c targetCorrespondRecord;//対応レコード

    private List<Item__c> deleteItemList;                   //商品削除用リスト
    private List<Item__c> upsertItemList;                   //商品登録・更新用リスト
    private Boolean isOpenModalCreate;                      //新規モーダルフラグ

    //コンストラクタ
    public GF201004Controller(){       
        try{
            //初期化
            init();
            
            //対象IDを取得
            targetId = ApexPages.currentPage().getParameters().get('Id');
            //レコードタイプID取得
            targetAccountRecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_AUXILIARY);
            
            //対象IDが取得できない場合は新規登録フラグにTRUEを設定する
            if(this.targetId == null){
                this.isNew = true;
                this.screenTargetRecord = new screenAccount(new Account());
            
            //対象IDが取得できた場合は新規登録フラグにFALSEを設定する
            } else {
                this.isNew = false;
                this.screenTargetRecord = new screenAccount(SelectAccountRecordInfo(this.targetId));
                this.targetCorrespondRecord = SelectCorrespondRecordInfo(this.targetId);

                //関連する付帯商品リストを作成
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
  
    //*****************************************publicメソッド******************************************   

    //保存ボタン押下処理
    public void TargetRecordSave(){
        Savepoint sp = Database.setSavepoint();      //トランザクションのセーブポイント作成
        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();

            //入力チェック
            List<String> requiredItem = new List<String>();
            if (String.isBlank(screenTargetRecord.name)){
                requiredItem.add('付帯業者');
            }
            if (String.isBlank(screenTargetRecord.postalCode)){
                requiredItem.add('郵便番号');
            }
            if (String.isBlank(screenTargetRecord.state)){
                requiredItem.add('都道府県');
            }
            if (String.isBlank(screenTargetRecord.city)){
                requiredItem.add('住所1(丁目まで)');
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
                ,Name                    = this.screenTargetRecord.name         //付帯業者
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
                Date listViewDate = date.newInstance(2999, 12, 31);
                this.targetCorrespondRecord = new Correspond__c(
                    AccountId__c           = this.screenTargetRecord.targetAccountRecord.Id
                   ,Status__c              = CommonConst.CORRESPOND_STATUS_CLOSE
                   ,EventDateTime__c       = eventDateTime
                   ,IsSupportedListShow__c = True
                   ,District__c            = CommonConst.STRING_EMPTY
                   ,IsBrowseFlg__c         = True
                   ,ListViewDate__c        = listViewDate
                );
                SecureDML.secureInsert(targetCorrespondRecord);
            }
        
            //商品保存
            //商品登録・更新用にレコードが入っている場合、その付帯商品を登録・更新
            this.upsertItemList = new List<Item__c>();
            
            //取引先が空(新規商品)の場合、設定する
            for(screenItem item : this.screenItemList){
                if(String.isEmpty(item.itemRecord.Account__c)){
                    item.itemRecord.Account__c = this.targetId;    
                }
                item.itemRecord.IsAuxiliary__c = true;
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

        }catch(Exception e){

            Database.rollback(sp);    //処理をロールバック
            hasErrorMessage = true;    //エラーを設定
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

    //付帯商品登録画面(新規)モーダル起動
    public void openModalCreateItem() {
        this.isOpenModalCreate = true;//付帯商品を新規ボタンで開いた

        GF201002Parameter = new GF201002ParameterClass();
        GF201002Parameter.isDrawing = true;
        GF201002Parameter.noFirst = true;
    
        GF201002Parameter.auxiliaryCompanyName = screenTargetRecord.name;//業者名をモーダルに渡す
        //商品レコードを新規作成
        GF201002Parameter.targetItem = new Item__c();
    }

    //付帯商品登録画面(編集)モーダル起動
    public void openModalUpdateItem() {
        this.isOpenModalCreate = false;//商品名リンクをクリックして編集として開いた
        
        GF201002Parameter = new GF201002ParameterClass();
        GF201002Parameter.isDrawing = true;
        GF201002Parameter.noFirst = true;

        GF201002Parameter.auxiliaryCompanyName = screenTargetRecord.name;//業者名をモーダルに渡す
        //選択した行のレコードをモーダルに渡す
        GF201002Parameter.targetItem = screenItemList[selectedIndex].itemRecord;
    }

    //付帯商品登録画面モーダル終了
    public void closeNewModal() {
        if(isOpenModalCreate){
            //isOpenModalCreateがTRUEなら行追加
            this.screenItemList.add(new screenItem(GF201002Parameter.targetItem));
        }else{
            //編集の場合、料金だけレコード表示でなく個別表記なので再設定
            this.screenItemList[selectedIndex].itemRecord.recalculateFormulas();
            this.screenItemList[selectedIndex].itemFee = CommonUtil.decimalToString(this.screenItemList[selectedIndex].itemRecord.AuxiliaryItemFeeTax__c);
        }
        //商品数カウントを更新
        screenTargetRecord.auxiliaryItemCount = this.screenItemList.size();
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
        screenTargetRecord.auxiliaryItemCount = this.screenItemList.size();
    }

    //*****************************************privateメソッド******************************************
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
        this.GF201002Parameter = new GF201002ParameterClass();

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
                                                   Name,  //付帯業者名
                                                   AuxiliaryItemCount__c,  //付帯商品数
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
                                                Account__c,
                                                ItemName__c,   //付帯商品
                                                AuxiliaryItemType__c,    //付帯商品種別
                                                AuxiliaryItemFeeTax__c,    //付帯料金（税込）
                                                AuxiliaryItemFee__c,//付帯料金
                                                AuxiliaryItemFeeTaxType__c,//課税区分
                                                AuxiliaryItemFeeCost__c,//原価
                                                Remarks__c,     //備考
                                                RecordTypeId 
                                                //SystemModStamp
                                           FROM Item__c
                                          WHERE Account__c = :this.targetId
                                          AND   RecordTypeId = :commonUtil.getRecordTypeId('Item__c',commonConst.ITEM_RECTYPE_AUXILIARY_ITEM)
                                          AND   IsAuxiliary__c = true
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
                                                            //SystemModStamp
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
        public Decimal auxiliaryItemCount { get; set; } //付帯商品数
        public String postalCode { get; set; }          //郵便番号
        public String state { get; set; }               //都道府県
        public String city { get; set; }                //市区町村
        public String street { get; set; }              //番地
        public String phone { get; set; }               //電話番号
        public String fax { get; set; }                 //取引先FAX
        public String email { get; set; }               //メールアドレス
        public String remarksPublic { get; set; }       //備考（公開）
        
        //コンストラクタ
        public screenAccount(Account targetAccountRecord){

            //取引先レコードの連動
            this.targetAccountRecord = targetAccountRecord;
            this.name = targetAccountRecord.Name;
            this.titleName = targetAccountRecord.Name;
            this.auxiliaryItemCount = targetAccountRecord.AuxiliaryItemCount__c;
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

        //チェックボックス
        public Boolean isItemCheck { get; set; }
        public Item__c itemRecord { get; set; }//商品
        public String itemFee { get; set; }//料金（3桁ごとに,を出すため個別で用意）
        //コンストラクタ
        public screenItem(Item__c item){

            //チェックボックスを初期化
            this.isItemCheck = false;
            
            item.recalculateFormulas();//料金（税込）を表示するため再計算（新規作成時に際に必要）
            //内部クラスに引数の商品を連動
            this.itemRecord = item;
            itemFee = commonUtil.decimalToString(this.itemRecord.AuxiliaryItemFeeTax__c);

        }
    }    
}