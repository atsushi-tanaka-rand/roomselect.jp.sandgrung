/* *
 * 保証プラン登録画面のコントローラ
 */
public inherited sharing class GF101004Controller {
    /** パブリック変数 */
    public screenItem screenTargetRecord { get; set; }    //表示用内部クラス
    public List<screenItemDetail> screenItemDetailList { get; set; }    //表示用商品明細クラスリスト
    public Account targetAccountRecord { get; set; }    //対象取引先レコード
    public Boolean isNew { get; set; }    //新規登録フラグ
    public Boolean isOpenError { get; set; }    //初期表示エラーフラグ
    public Boolean hasErrorMessage { get; set; }    //Excepttionエラーフラグ
    public Boolean allCheckItemDetail { get; set; }    //商品明細チェックボックス(全選択)
    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}    //js用保存確認メッセージ
    public String MSG_COM_I_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);} private set;}    //js用保存完了メッセージ
    public String MSG_COM_V_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_DELETE);} private set;}    //js用削除確認メッセージ
    public String MSG_COM_I_DELETE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_DELETE);} private set;}    //js用削除完了メッセージ

    public Integer selectedIndex { get; set; } // 保証プラン明細選択リンクインデックス

    /** 共通クラス */
    public GF101004Modal1ParameterClass GF101004Modal1Parameter { get; set; }    //モーダル用

    /** プライベート変数 */
    @TestVisible private ID targetItemId;    //商品ID
    @TestVisible private ID targetAccountId;    //取引先ID
    @TestVisible private ID targetItemRecordTypeId;    //対象レコードタイプ(商品用)
    private List<ItemDetail__c> deleteItemDetailList;    //削除用商品明細リスト
    private List<ItemDetail__c> upsertItemDetailList;    //登録・更新用商品明細リスト
    private Boolean isOpenModalCreate;    //新規モーダルフラグ

    //コンストラクタ
    public GF101004Controller() {
        try{
            //初期化
            init();

            //対象商品ID、対象取引先IDを取得
            targetItemId = ApexPages.currentPage().getParameters().get('Id');
            targetAccountId = ApexPages.currentPage().getParameters().get('AccountId');

            //レコードタイプID取得
            targetItemRecordTypeId = CommonUtil.getRecordTypeId('Item__c', CommonConst.ITEM_RECTYPE_GUARANTEE_PLAN);

            //対象商品IDが取得できない場合は新規登録フラグにTRUEに設定する
            if(targetItemId == null){
                isNew = true;
                this.screenTargetRecord = new screenItem(new Item__c(Account__c = this.targetAccountId));

                //取引先の情報は取得する
                this.targetAccountRecord = selectAccountlInfo(this.targetAccountId);

            //対象IDが取得できた場合は新規登録フラグにFALSEを設定する
            }else{
                isNew = false;
                this.screenTargetRecord = new screenItem(selectItemInfo(this.targetItemId));

                //商品明細リスト分、商品明細クラスのインスタンスをnew
                for(ItemDetail__c item : selectItemDetailInfo(this.targetItemId)){
                    this.screenItemDetailList.add(new screenItemDetail(item));
                }

                //取引先情報取得する
                this.targetAccountRecord = selectAccountlInfo(this.targetAccountId);
            }
        }catch(Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //(プラン明細)削除ボタン押下処理
    public void targetItemDetailRecordDelete(){

        //コピーリスト
        List<screenItemDetail> copyList = new List<screenItemDetail>();

        for(screenItemDetail item : this.screenItemDetailList){

            //チェック付きレコード の場合 
            if(item.isItemDetailCheck){

                //新規作成ではないレコードは削除リストに追加
                if(!String.isEmpty(item.itemDetailRecord.id)){
                    this.deleteItemDetailList.add(item.itemDetailRecord);
                }

            //未チェックレコードの場合
            }else{
                //商品明細をコピーリストに待避
                copyList.add(item);
            }
        }

        //内部クラスリストに削除対象ではないレコードをコピーする
        this.screenItemDetailList = copyList.clone();
    }

    //保存ボタン押下処理
    public void targetRecordSave(){

        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            hasErrorMessage = false;

            //入力チェック
            List<String> requiredItem = new List<String>();
            if (String.isBlank(screenTargetRecord.itemName)){
                requiredItem.add('保証プラン名');
            }
            if (String.isBlank(screenTargetRecord.isAuxiliary)){
                requiredItem.add('付帯商品区分');
            }
            if (screenTargetRecord.isAuxiliary == 'true' && String.isBlank(screenTargetRecord.rentFeeRate)){
                requiredItem.add('紹介料の割合(賃料に対する割合)');
            }
            if (String.isBlank(screenTargetRecord.assuranceContent)){
                requiredItem.add('プラン内容');
            }
            if (String.isNotBlank(screenTargetRecord.directDebitFee) && String.isBlank(screenTargetRecord.directDebitFeeTaxType)){
                requiredItem.add('手数料に対する課税区分');
            }


            //入力チェック用リストが空ではない場合、ビジネスロジックException発行
            if (!requiredItem.isEmpty()){
                hasErrorMessage = true;
                
                //項目名をカンマで区切って、ビジネスロジックException発行
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
                throw ex;
            }



            //新規でない場合、データ取得処理を実施
            if (!isNew){
                List<Item__c> checkOptimisticLockExceptionRecord = new List<Item__c>();
                checkOptimisticLockExceptionRecord = [ SELECT id
                                                         FROM Item__c
                                                        WHERE id = :this.screenTargetRecord.targetItemRecord.Id
                                                          AND SystemModStamp = :this.screenTargetRecord.targetItemRecord.systemModStamp
                                                     ];
                
                //データ取得できない場合、楽観ロックチェックExceptionを発行
                if (checkOptimisticLockExceptionRecord.isEmpty()){
                    OptimisticLockException ex = new OptimisticLockException();
                    throw ex;
                }
            }

            //付帯商品区分のBoolean変換
            Boolean booleanIsAuxiliary = Boolean.valueOf(this.screenTargetRecord.isAuxiliary);

            //賃料割合（保証会社）と手数料をStringへ変換
            Decimal decimalRentFeeRate = CommonUtil.stringToDecimal(screenTargetRecord.rentFeeRate);    //Decimal変換後　賃料割合（保証会社）
            Decimal decimalDirectDebitFee = CommonUtil.stringToDecimal(screenTargetRecord.directDebitFee);    //Decimal変換後　手数料

            //賃料割合の更新項目(付帯商品区分がtrueの場合のみ値格納。それ以外はnull)
            Decimal upsertRentFeeRate = null;
            if(booleanIsAuxiliary){
                upsertRentFeeRate = decimalRentFeeRate;
            }

            //保存処理実行
            //商品レコード保存
            Item__c upsertItemRecord = new Item__c(
                 Id                       = this.screenTargetRecord.targetItemRecord.Id    //対象ID
                ,Account__c               = this.screenTargetRecord.targetItemRecord.Account__c    //取引先ID
                ,ItemName__c              = this.screenTargetRecord.itemName    //保証プラン名
                ,IsAuxiliary__c           = booleanIsAuxiliary    //付帯商品区分
                ,RentFeeRate__c           = upsertRentFeeRate    //賃料割合（保証会社）
                ,AssuranceContent__c      = this.screenTargetRecord.assuranceContent    //保証内容
                ,DirectDebitFee__c        = decimalDirectDebitFee    //手数料
                ,DirectDebitFeeTaxType__c = this.screenTargetRecord.directDebitFeeTaxType    //手数料税区分
                ,Remarks__c               = this.screenTargetRecord.remarks    //保証内容備考
                ,RecordTypeID             = targetItemRecordTypeId    //レコードタイプID
            );

            SecureDML.secureUpsert(upsertItemRecord);
            this.targetItemId = upsertItemRecord.Id;
            screenTargetRecord = new screenItem(selectItemInfo(upsertItemRecord.Id));

            //商品明細保存
            //登録・更新用商品明細リストにレコードが入っている場合、その商品明細を登録・更新
            this.upsertItemDetailList = new List<ItemDetail__c>();
            for(screenItemDetail item : this.screenItemDetailList){
                if(String.isEmpty(item.itemDetailRecord.Item__c)){
                    item.itemDetailRecord.Item__c = this.targetItemId;    
                }
                this.upsertItemDetailList.add(item.itemDetailRecord);
            }
            
            if(!this.upsertItemDetailList.isEmpty()){
                SecureDML.secureUpsert(upsertItemDetailList);
            }

            //商品明細削除
            //削除用商品明細リストにが入っている場合、その商品明細を削除
            if (!this.deleteItemDetailList.isEmpty()){
                SecureDML.secureDelete(deleteItemDetailList);
            }

     

        }catch(Exception e){
            Database.rollback(sp);    //処理をロールバック
            hasErrorMessage = true;    //エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    //(保証プラン)削除ボタン押下処理
    public void targetItemRecordDelete(){

        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            hasErrorMessage = false;

            SecureDML.secureDelete(this.screenTargetRecord.targetItemRecord);
            
            //取引先保険保証を取得し、Itemがないレコードを削除する
            List<InsuranceGuarantee__c> insGuar = [SELECT id FROM InsuranceGuarantee__c WHERE Item__c = null];
            if (insGuar.size() != 0){
                SecureDML.secureDelete(insGuar);
            }
            

        }catch(Exception e){

            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);

        }
    }

    //保証プラン明細(新規)モーダル起動
    public void openModalCreateItemDetail() {

        this.isOpenModalCreate = true;

        this.GF101004Modal1Parameter = new GF101004Modal1ParameterClass();
        GF101004Modal1Parameter.isDrawing = true;
        GF101004Modal1Parameter.noFirst = true;

        //商品明細レコードを新規作成
        GF101004Modal1Parameter.targetItemDetail = new ItemDetail__c(Item__c = this.targetItemId, DepositPaymentType__c = CommonConst.ITEMDETAIL_DEPOSITPAYMENTTYPE_MONTH, IsRentFeeType__c = true);

    }

    //保証プラン明細(編集)モーダル起動
    public void openModalUpdateItemDetail() {

        this.isOpenModalCreate = false;
        this.GF101004Modal1Parameter = new GF101004Modal1ParameterClass();
        GF101004Modal1Parameter.isDrawing = true;
        GF101004Modal1Parameter.noFirst = true;
        
        // selectedIndexの添え字が対象のレコード
        GF101004Modal1Parameter.targetItemDetail = screenItemDetailList[selectedIndex].itemDetailRecord;
    }

    //保証プラン明細モーダル終了
    public void closeModal() {
        if(isOpenModalCreate){

            //isOpenModalCreateがTRUEなら行追加
            this.screenItemDetailList.add(new screenItemDetail(GF101004Modal1Parameter.targetItemDetail));

        }
    }

    //付帯商品区分ラジオボタン（VFオプション）
    public List<SelectOption> getIsAuxiliaryRadioButton(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('true', '付帯商品'));
        options.add(new SelectOption('false', '付帯商品以外'));
        return options;
    }

    //手数料税区分ラジオボタン（VFオプション）
    public List<SelectOption> getDirectDebitFeeTaxTypeRadioButton(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('課税', '課税'));
        options.add(new SelectOption('非課税', '非課税'));
        return options;
    }



    //初期化メソッド
    private void init(){
        this.isNew = false;
        this.isOpenError = false;
        this.hasErrorMessage = false;
        //店舗異動が取得できなければエラー
        CommonUtil.getStaffCurrentShop();

        //商品明細クラスリスト初期化
        this.screenItemDetailList = new List<screenItemDetail>();

        //削除用商品明細リスト初期化
        this.deleteItemDetailList = new List<ItemDetail__c>();

        //商品明細全選択チェックボックス初期化
        this.allCheckItemDetail = false;
 
        //モーダル初期化
        this.GF101004Modal1Parameter = new GF101004Modal1ParameterClass();
    }

    //レコード情報取得（商品）
    private Item__c selectItemInfo(ID targetItemId){
        List<Item__c> retItem = [ SELECT Id    //ID
                                        ,ItemName__c    //商品名
                                        ,Account__c    //取引先
                                        ,IsAuxiliary__c    //付帯商品区分
                                        ,RentFeeRate__c    //賃料割合（保証会社）
                                        ,AssuranceContent__c    //保証内容
                                        ,DirectDebitFee__c    //手数料
                                        ,DirectDebitFeeTaxType__c    //手数料税区分
                                        ,Remarks__c    //備考
                                        ,SystemModstamp
                                  FROM Item__c 
                                  WHERE id = :targetItemId
        ];

        //レコードが取得できない場合はビジネスロジックExceptionを発行する
        if(retItem.isEmpty()){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }

        return retItem[0];
    }

    //レコード情報取得（商品明細）
    private List<ItemDetail__c> selectItemDetailInfo(ID targetItemId){
        List<ItemDetail__c> retItemDeteal = [ SELECT Id    //ID
                                                    ,Item__c    //商品ID
                                                    ,PlanDetail__c    //プラン詳細
                                                    ,IsRentFeeType__c    //賃料区分
                                                    ,FirstFeeDepositRate__c    //初回保証料（割合）
                                                    ,FirstFeeDepositYen__c    //初回保証料（金額）
                                                    ,DepositRate__c    //保証料（割合）
                                                    ,DepositYen__c    //保証料（金額）
                                                    ,DepositRemarks__c    //備考
                                                    ,SystemModstamp
                                              FROM ItemDetail__c
                                              WHERE Item__c = :targetItemId
        ];

        return retItemDeteal;
    }

    //レコード情報取得（取引先）
    private Account selectAccountlInfo(ID targetAccountId){
        List<Account> retAccount = [SELECT Id    //ID
                                          ,Name    //取引先名
                                          ,SystemModstamp
                                    FROM Account 
                                    WHERE Id = :targetAccountId];

        //レコードが取得できない場合はビジネスロジックExceptionを発行する
        if(retAccount.isEmpty()){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }

        return retAccount[0];
    }

    //画面表示用内部クラス
    public class screenItem{
        public Item__c targetItemRecord { get; set; }    //対象商品レコード

        /** 以下、画面表示用の項目 */
        public String itemName { get; set; }    //商品名
        public String isAuxiliary { get; set; }    //付帯商品区分
        public String rentFeeRate { get; set; }    //賃料割合（保証会社）
        public String assuranceContent { get; set; }    //保証内容
        public String directDebitFee { get; set; }    //手数料
        public String directDebitFeeTaxType { get; set; }    //手数料税区分
        public String remarks { get; set; }    //備考

        public String stringIsAuxiliary { get; set; }    //String変換後　付帯商品区分
        public String stringRentFeeRate { get; set; }    //String変換後　賃料割合（保証会社）
        public String stringDirectDebitFee { get; set; }    //String変換後　手数料

        //コンストラクタ
        public screenItem(Item__c targetItemRecord){

            //賃料割合（保証会社）と手数料をStringへ変換
            this.stringRentFeeRate = CommonUtil.decimalToString(targetItemRecord.RentFeeRate__c);
            this.stringDirectDebitFee = CommonUtil.decimalToString(targetItemRecord.DirectDebitFee__c);

            //付帯商品区分のString変換
            this.stringIsAuxiliary = String.valueOf(targetItemRecord.IsAuxiliary__c);
            
            //商品レコードの連動
            this.targetItemRecord = targetItemRecord;
            this.itemName = targetItemRecord.ItemName__c;
            this.isAuxiliary = stringIsAuxiliary;
            this.rentFeeRate = stringRentFeeRate;
            this.assuranceContent = targetItemRecord.AssuranceContent__c;
            this.directDebitFee = stringDirectDebitFee;
            this.directDebitFeeTaxType = targetItemRecord.DirectDebitFeeTaxType__c;
            this.remarks = targetItemRecord.Remarks__c;
        }
    }

    //商品明細チェックボックス用内部クラス
    public class screenItemDetail{

        //チェックボックス
        public Boolean isItemDetailCheck { get; set; }
        //商品明細
        public ItemDetail__c itemDetailRecord { get; set; }

        //コンストラクタ
        public screenItemDetail(ItemDetail__c itemDetailRecord){

            //チェックボックスを初期化
            this.isItemDetailCheck = false;
            //内部クラスに引数の商品明細を連動
            this.itemDetailRecord = itemDetailRecord;

        }
    }
}