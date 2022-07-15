/* *
 * 保証会社登録画面のコントローラ
 */
public inherited sharing class GF101002Controller {
    /** パブリック変数 */
    public screenAccount screenTargetRecord { get; set; }      //画面表示用の内部クラスレコード
    public List<Item__c> targetItemRecordList { get; set; }    //商品レコードリスト
    
    public Boolean isNew { get; set; }              //新規登録フラグ
    public Boolean isOpenError { get; set; }        //エラーフラグ
    public Boolean hasErrorMessage { get; set; }    //エラーメッセージ保有フラグ
    
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    //js用削除完了メッセージ

    public Integer itemIndex { get; set; }    //明細行のindex
    public ID targetId{ get; set; }    //対象ID
    
    //選択リスト
    public List<SelectOption> SelectStateList{ get; set; }    //都道府県
    public List<SelectOption> SelectGuarantorAgencyCompanyTypeList{ get; set; }//保証人代行会社区分
    
    /** 共通クラス */    
    public GA102006ParameterClass GA102006Parameter{get; set;}
    public List<screenItem> screenTargetItemRecordList { get; set; }//内部クラス商品レコードリスト
    

    
    /** プライベート変数 */
    @TestVisible private ID targetAccountRecordTypeId;            //対象レコードタイプ(取引先用)
    @TestVisible private Correspond__c targetCorrespondRecord;    //対応レコード
    private screenAccount initRecord;    //初期表示時のレコード

    //コンストラクタ
    public GF101002Controller(){
        
        try{
            //初期化
            init();
            
            //対象IDを取得
            targetId = ApexPages.currentPage().getParameters().get('Id');


            //レコードタイプID取得
            targetAccountRecordTypeId    = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_GUARANTEE);
            
            
            //対象IDが取得できない場合は新規登録フラグにTRUEを設定する
            if(this.targetId == null){
                this.isNew = true;
                this.screenTargetRecord = new screenAccount(new Account());
            
            //対象IDが取得できた場合は新規登録フラグにFALSEを設定する
            } else {
                this.isNew = false;
                this.screenTargetRecord = new screenAccount(SelectAccountRecordInfo(this.targetId));
                this.initRecord = this.screenTargetRecord.clone();
                this.targetItemRecordList = SelectItemRecordListInfo(this.targetId);

                this.screenTargetItemRecordList = new List<screenItem>();
                for(Item__c it:targetItemRecordList){
                    screenTargetItemRecordList.add(new screenItem(it));
                }
                
                this.targetCorrespondRecord = SelectCorrespondRecordInfo(this.targetId); 
            }
            //保証人代行会社区分
            this.SelectGuarantorAgencyCompanyTypeList = CommonUtil.getSelectOptionFromObject('Account', 'GuarantorAgencyCompanyType__c');//保証人代行会社区分                

                
        } catch(Exception e) {
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    //総賃料区分ラジオボタン（VFオプション）
    public List<SelectOption> getIsAllRentFeeTypeRadioButton(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('true', '含む'));
        options.add(new SelectOption('false', '含まない'));
        return options;
    }
    
    //郵便番号検索モーダルopen処理
    public void openModal() {
        GA102006Parameter.isDrawing = true;
        GA102006Parameter.noFirst = true;


        GA102006Parameter.isAddressMoster = TRUE;  /** 住所マスタフラグ */
        GA102006Parameter.postalCode = this.screenTargetRecord.postalCode;  /** 郵便番号 */     
        GA102006Parameter.state = this.screenTargetRecord.state;    /** 都道府県 */       
        GA102006Parameter.city = this.screenTargetRecord.city;    /** 市区町村 */  
        GA102006Parameter.street = null;    /** 町域 */    
        
    }
    
    //郵便番号検索モーダルclose処理
    public void closeModal() {
        System.debug('モーダル終了。ここでパラメータから画面を設定します');
        this.screenTargetRecord.postalCode = GA102006Parameter.postalCode;  /** 郵便番号 */   
        this.screenTargetRecord.state = GA102006Parameter.state;    /** 都道府県 */    
        this.screenTargetRecord.city = GA102006Parameter.city + GA102006Parameter.street;    /** 市区町村 */  
        this.screenTargetRecord.street = null;    /** 町域 */  
    }

    //新規ボタン押下処理
    public void NewItemCreate(){

        try{

            hasErrorMessage = false;

            screenTargetRecord.convertNull();
            initRecord.convertNull();

            if( this.initRecord.name != this.screenTargetRecord.name 
             || this.initRecord.postalCode != this.screenTargetRecord.postalCode 
             || this.initRecord.state != this.screenTargetRecord.state
             || this.initRecord.city != this.screenTargetRecord.city
             || this.initRecord.street != this.screenTargetRecord.street 
             || this.initRecord.phone != this.screenTargetRecord.phone
             || this.initRecord.fax != this.screenTargetRecord.fax
             || this.initRecord.email != this.screenTargetRecord.email 
             || this.initRecord.isAllRentFeeType != this.screenTargetRecord.isAllRentFeeType 
             || this.initRecord.remarksPublic != this.screenTargetRecord.remarksPublic )
            {

                //ビジネスロジックExeceptionを発行する
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_NOTICE_SAVE, '保存'));
                throw ex;

            }

        }catch(Exception e){

            hasErrorMessage = true;    //エラーを設定
            CommonUtil.setErrorMessage(e);

        }
        
    }

    //保存ボタン押下処理
    public void TargetRecordSave(){

        Savepoint sp = Database.setSavepoint();      //セーブポイント作成

        try{
            hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();

            //入力チェック
            List<String> requiredItem = new List<String>();
            if (String.isBlank(screenTargetRecord.name)){
                requiredItem.add('保証会社名');
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
            if (String.isBlank(screenTargetRecord.isAllRentFeeType)){
                requiredItem.add('総賃料区分');
            }

            //入力チェック用リストが空ではない場合、ビジネスロジックException発行
            if (!requiredItem.isEmpty()){
                hasErrorMessage = true;
                
                //項目名をカンマで区切って、ビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
            }

            //メールアドレス入力チェック
            if(CommonUtil.isWrongMailString(screenTargetRecord.email)){
                hasErrorMessage = true;

                //ビジネスロジックException発行
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_MAILADDRESS_VALIDATION, 'メールアドレス'));
            }

            //Exceptionがあればthrow
            if(ex.hasMessage()){
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
                    OptimisticLockException oex = new OptimisticLockException();
                    throw oex;
                }
            }

            //総賃料区分のBoolean変換
            Boolean booleanIsAllRentFeeType = Boolean.valueOf(this.screenTargetRecord.isAllRentFeeType);

            //保存処理実行
            Account upsertRecord = new Account(
                 Id                      = this.screenTargetRecord.targetAccountRecord.Id
                ,Name                    = this.screenTargetRecord.name    //保証会社名
                ,PostalCode__c           = this.screenTargetRecord.postalCode    //郵便番号
                ,State__c                = this.screenTargetRecord.state    //都道府県
                ,City__c                 = this.screenTargetRecord.city    //市区町村
                ,Street__c               = this.screenTargetRecord.street    //丁目・番地
                ,Phone                   = this.screenTargetRecord.phone    //電話番号
                ,Fax                     = this.screenTargetRecord.fax    //FAX
                ,Email__c                = this.screenTargetRecord.email    //メールアドレス
                ,isAllRentFeeType__c     = booleanIsAllRentFeeType    //総賃料区分
                ,RemarksPublic__c        = this.screenTargetRecord.remarksPublic    //備考（公開）
                ,RecordTypeID            = targetAccountRecordTypeId    //レコードタイプID
                ,GuarantorAgencyCompanyType__c = this.screenTargetRecord.guarantorAgencyCompanyType //保証人代行会社区分コード
                ,IsGuaranteeidCompany__c = true
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

            //登録更新後処理
            this.initRecord = screenTargetRecord.clone();
            this.isNew = false;

        }catch(Exception e){

            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);

        }
    }
    
    //削除ボタン押下処理
    public void TargetRecordDelete(){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
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

    //初期化メソッド
    private void init(){
        isNew = false;
        isOpenError = false;
        hasErrorMessage = false;

        //店舗異動が取得できなければエラー
        CommonUtil.getStaffCurrentShop();

        SelectStateList = CommonUtil.getSelectOptionFromObject('Account', 'State__c');    //都道府県選択リスト取得
        
        //モーダル初期化
        GA102006Parameter = new GA102006ParameterClass();
    }
    
    //取引先レコード情報取得
    private Account SelectAccountRecordInfo(Id targetId){
        
        List<Account> targetAccountList = [ SELECT Id,
                                                   Name,
                                                   PlanCount__c,
                                                   PostalCode__c,
                                                   State__c,
                                                   City__c,
                                                   Street__c,
                                                   Phone,
                                                   Fax,
                                                   Email__c,
                                                   IsAllRentFeeType__c,
                                                   RemarksPublic__c,
                                                   GuarantorAgencyCompanyType__c,
                                                   SystemModStamp
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
    
    //商品リスト情報取得
    private List<Item__c> SelectItemRecordListInfo(Id targetId){
        
        List<Item__c> targetItemList = [ SELECT Account__c,
                                                AssuranceContent__c,
                                                Remarks__c,
                                                ItemName__c,
                                                DirectDebitFeeTax__c,
                                                DirectDebitFeeTaxType__c,
                                                SystemModStamp
                                           FROM Item__c
                                          WHERE Account__c = :this.targetId
                                       ];
        
        //レコードが取得できない場合はビジネスロジックExceptionを発行する
        if(targetItemList.isEmpty()){

            targetItemList = new List<Item__c>();
        }
        
        return targetItemList;
    }
    
    //対応レコード情報取得
    private Correspond__c SelectCorrespondRecordInfo(Id targetId){
        
        List<Correspond__c> targetCorrespondList = [ SELECT Id,
                                                            SystemModStamp
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
    
    //画面表示用内部クラス
    public class screenAccount {
        public Account targetAccountRecord { get; set; }    //レコード本体(取引先)
        
        //以下、画面用の項目
        public String name { get; set; }    //取引先名
        public String titleName { get; set; }    //ヘッダー表示用取引先名
        public Decimal planCount { get; set; }    //プラン数
        public String postalCode { get; set; }    //郵便番号
        public String state { get; set; }    //都道府県
        public String city { get; set; }    //市区町村
        public String street { get; set; }    //番地
        public String phone { get; set; }    //電話番号
        public String fax { get; set; }    //取引先FAX
        public String email { get; set; }    //メールアドレス
        public String isAllRentFeeType { get; set; }    //総賃料区分
        public String remarksPublic { get; set; }    //備考（公開）
        public String guarantorAgencyCompanyType { get; set; }    //保証人代行会社区分
        
        //コンストラクタ
        public screenAccount(Account targetAccountRecord){

            //総賃料区分のString変換
            String stringIsAllRentFeeType = String.valueOf(targetAccountRecord.isAllRentFeeType__c);
            
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
            this.isAllRentFeeType = stringIsAllRentFeeType;
            this.remarksPublic = targetAccountRecord.RemarksPublic__c;
            this.guarantorAgencyCompanyType = targetAccountRecord.GuarantorAgencyCompanyType__c;//保証人代行会社区分

        }

        //空白をnullに変更する
        public void convertNull() {
            this.name                = String.isBlank(this.Name)             ? null : this.name;
            this.postalCode          = String.isBlank(this.postalCode)       ? null : this.postalCode;
            this.state               = String.isBlank(this.state)            ? null : this.state;
            this.city                = String.isBlank(this.city)             ? null : this.city;
            this.street              = String.isBlank(this.street)           ? null : this.street;
            this.phone               = String.isBlank(this.phone)            ? null : this.phone;
            this.fax                 = String.isBlank(this.fax)              ? null : this.fax;
            this.email               = String.isBlank(this.email)            ? null : this.email;
            this.IsAllRentFeeType    = String.isBlank(this.isAllRentFeeType) ? null : this.isAllRentFeeType;
            this.remarksPublic       = String.isBlank(this.remarksPublic)    ? null : this.remarksPublic;
        }
    }

    //商品のリスト★★★
    public class screenItem {
        public Item__c item{get; set;}      //商品
        public String assuranceContentPlus{get; set;}//保証内容

        //コンストラクタ
        public screenItem(Item__c targetItem) {
            this.item     = targetItem;   
            
            //内容の設定
            this.assuranceContentPlus = '';

            //口座振替手数料の表示（値があるなら改行、口座振替手数料を表示）
            if (item.DirectDebitFeeTax__c != null && item.DirectDebitFeeTax__c != 0 ){
                
                //保証内容がなければ改行コードをプラス
                if (String.isNotBlank(item.AssuranceContent__c)) {
                this.assuranceContentPlus += '<br/>';
                }
                
                this.assuranceContentPlus += '口座振替手数料　' + commonUtil.decimalToString(item.DirectDebitFeeTax__c) + '円';
                //手数料税区分なら（税込）を追加
                if(item.DirectDebitFeeTaxType__c == '課税'){
                    this.assuranceContentPlus +=  '（税込）';
                }
            }
        }
    }
    
}