// QR画面
public with sharing class GA102001Modal5Controller {
    public Boolean hasErrorMessage { get; set; }        //エラーメッセージ保有フラグ
    public Boolean isOpenError { get; set; }            //

    public String CorrespondId { get; set; }    //対応ID
    public Datetime SystemModStamp;             //SystemModStamp
    private String AccountId;                   // 取引先ID
    private String EchoStaff;                   // 反響担当者
    private String ShopStaff;                   // 来店担当者
    private String Status;                      // ステータス
    private String loginStaff;                  // ログインユーザ
    private String loginShop;                   // ログインユーザ店舗
    private Correspond__c targetCorrespond;     // 対象の対応レコード
    

    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}   // 登録確認メッセージ


    public Boolean init{
        get{
            getCorrespondDatte();
            return false;
        }
    }

    /**
    * 初期表示処理
    */
    public void getCorrespondDatte() {
        isOpenError = false;
        try{
            // ログインユーザの情報取得
            Shop__c shop = CommonUtil.getStaffCurrentShop();
            loginStaff = UserInfo.getUserId();     // ログインユーザ
            loginShop  = shop.id;                  // ログインユーザ店舗
            this.targetCorrespond = new Correspond__c(); //対応を初期化

            //対応を取得する
            List<Correspond__c> CorrespondList = [SELECT id
                        ,SystemModStamp
                        ,AccountId__c
                        ,EchoStaff__c
                        ,ShopStaff__c
                        ,Status__c
                        ,VisitDate__c
                        FROM Correspond__c
                        WHERE Id =  :CorrespondId];

            if(CorrespondList.size() > 0){
                // 
                this.SystemModStamp = CorrespondList[0].SystemModStamp;
                this.AccountId = CorrespondList[0].AccountId__c;
                this.EchoStaff = CorrespondList[0].EchoStaff__c;
                this.ShopStaff = CorrespondList[0].ShopStaff__c;
                this.Status    = CorrespondList[0].Status__c;
                this.targetCorrespond = CorrespondList[0];
            }

        }catch (Exception e){
            // エラーを設定
            System.debug('e='+e);
            CommonUtil.setErrorMessage(e);  
            isOpenError = true;
        }
    }

    /**
     * 登録処理
     * 引数　　：　
     * 戻り値　：
     */
    public void saveDate(){
        
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        hasErrorMessage = false;
        BusinessLogicException inputCheckex = new BusinessLogicException();
        try{


            //楽観ロックチェックExceptionを発行(対応)
            List<Correspond__c> checkOptimisticLockExceptionRecord = new List<Correspond__c>();
            checkOptimisticLockExceptionRecord = [ SELECT id
                                                        FROM Correspond__c
                                                        WHERE id = :CorrespondId
                                                        AND SystemModStamp = :SystemModStamp ];                //楽観ロックチェック
            if (checkOptimisticLockExceptionRecord.isEmpty()){
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }

            // 対応の更新
            String saveId = saveCorrespond(this.CorrespondId,this.AccountId,this.EchoStaff,this.ShopStaff,this.loginStaff,this.Status);
            // 対応明細の登録
            saveCorrespondDetail(saveId,this.AccountId,this.loginStaff,this.loginShop);

        }catch(Exception e){

            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 登録処理(対応)
     * 引数　　：  Id String 対応ID
     * 　　　　：  Account String 取引先ID
     * 　　　　：  EchoStaff String 反響担当者
     * 　　　　：  ShopStaff String 来店担当者
     * 　　　　：  Status String ステータス
     * 戻り値　：  String 登録時の対応ID 
     */
    private String saveCorrespond(String Id,String AccountId,String EchoStaff,String ShopStaff,String loginStaff,String Status){
        // 保存処理
        Correspond__c saveDate = new Correspond__c();

        // 保存項目
        // 更新は引数のIDをセット
        saveDate.Id = Id;

        if(loginStaff == EchoStaff || loginStaff == ShopStaff){ 
            saveDate.StaffSupportedFlg__c = true; // スタッフ対応フラグ
        }else{
            saveDate.StaffSupportedFlg__c = false; // スタッフ対応フラグ
        }
        saveDate.AccountId__c     = AccountId; // 取引先ID
        saveDate.Status__c        = CommonConst.CORRESPOND_STATUS_VISITED; // 来店済み
        saveDate.EventDateTime__c = CommonUtil.getNow(); // イベント時刻

        //来店日(初回)
        if (targetCorrespond.VisitDate__c == null) {
            saveDate.VisitDate__c = CommonUtil.getToday();
        }
        
        saveDate.IsSupportedListShow__c = false;    // 対応確認フラグ

        SecureDML.secureUpsert(saveDate);
        return saveDate.id;
    }


    /**
     * 登録処理(対応明細)
     * 引数　　：　CorrespondId String 対応Id
     *        ：  AccountId String 取引先
     *        ：  loginStaff String ログインスタッフ
     *        ：  loginShop String ログイン店舗
     * 戻り値　：  
     */
    private void saveCorrespondDetail(String CorrespondId,String AccountId,String loginStaff,String loginShop){
        // 保存処理
        CorrespondDetail__c saveDate = new CorrespondDetail__c();

        // 保存項目
    
        // 登録時
        saveDate.SupportedDateTime__c   = CommonUtil.getNow();  // 対応日時
        saveDate.SupportedTitle__c      = '見ず決め';           // 対応表題
        saveDate.SupportedContent__c    = '見ず決めとして手続きを進めました。';     // 対応内容
        saveDate.Shop__c                = loginShop;            // 店舗
        saveDate.Staff__c               = loginStaff;           // 担当者
        saveDate.Corresponds__c         = CorrespondId;         // 対応番号
        saveDate.CorrespondType__c      = CommonConst.CORRESPOND_STATUS_VISITED; // 対応種別
        SecureDML.secureInsert(saveDate);
    }

}