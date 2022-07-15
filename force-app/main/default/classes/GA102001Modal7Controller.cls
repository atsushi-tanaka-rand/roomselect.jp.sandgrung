//自動追客一覧
public with sharing class GA102001Modal7Controller {

    /** 共通クラス */    
    public GA102001Modal7ParameterClass parameter { get; set; }    
    
    /** 保存用データ */ 
    public seveSetParameterClass seveSetParameterData;

    /** エラーフラグ */ 
    public Boolean isOpenError { get; set; }
    
    /** エラーメッセージ保有フラグ */ 
    public Boolean hasErrorMessage { get; set; } 

    public String MSG_COM_V_SAVE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SAVE);} private set;}   // 登録確認メッセージ
 
    public date introMailInfoFirstSendDate { get; set; }    //追客開始日
    public String introMailInfoFirstSendTime { get; set; }  //追客開始時間 
    // 選択リスト
    public List<SelectOption> sendingTimeList { get; set; } // 送信時刻（00:00～23:30）
	// ▼ 2021.11.30 LINE連携対応より、LINE送信フラグを追加
	public Boolean isSendLine {get; set;}
	// ▲ 2021.11.30

    //初期表示  
    public Boolean init{
        get{         
            if (parameter.isDrawing) {
                getSelectOption();
                parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }

    //紹介メール追客開始日時、ボタン設定
    public void getSelectOption() {

        try{
            // 初期化
            this.isOpenError = false;
            this.hasErrorMessage = false;
            this.seveSetParameterData = new seveSetParameterClass();
            List<Account> accountList = new List<Account>(); 
            accountList = selectAccount(parameter.accountId);
            this.seveSetParameterData = new seveSetParameterClass(parameter,accountList);

            // 送信時刻用のリスト作成
            this.sendingTimeList = new List<SelectOption>();
            this.sendingTimeList.add(new SelectOption('', ''));
            for (Integer i = 0; i < 24; i++) {
                //0分　（例：12:00)
                this.sendingTimeList.add(
                    new SelectOption(
                         String.valueOf(i).leftPad(2, '0') + ':00'
                        ,String.valueOf(i).leftPad(2, '0') + ':00'
                    )
                );
                //30分　（例：12:30)
                this.sendingTimeList.add(
                    new SelectOption(
                         String.valueOf(i).leftPad(2, '0') + ':30'
                        ,String.valueOf(i).leftPad(2, '0') + ':30'
                    )
                );
            }
            //紹介メール追客開始日時に値がある
            if (seveSetParameterData.introMailInfoFirstSendDatetime != null){
                //日と時間に分けて値を入れる
                setintroMailInfoFirstSendDateTime();

				// ▼ 2021.11.30 LINE連携対応より、LINE送信フラグを追加
				this.isSendLine = seveSetParameterData.isSendLine;
				// ▲ 2021.11.30

            }else {
                this.introMailInfoFirstSendDate = null;
                this.introMailInfoFirstSendTime = null; 
				this.isSendLine = false; // 2021.11.30 LINE連携対応より、LINE送信フラグを追加
            }
        } catch (Exception e) {
            // エラーを設定 
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //保存ボタン
    public void clickSave() {
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        this.hasErrorMessage = false;        
        try{
            
            //入力規則チェック
            inputCheck();

            //楽観ロックチェック（紹介メール情報、取引先）
            checkOptimisticLockException();

            //追客開始日時取得
            time tm = time.newInstance(Integer.ValueOf(introMailInfoFirstSendTime.left(2)), Integer.ValueOf(introMailInfoFirstSendTime.right(2)), 0, 0);
            Datetime introMailInfoFirstSendDatetime = Datetime.newInstance(this.introMailInfoFirstSendDate , tm);

            //取引先変更
            Account acc = new Account();
            acc.id = seveSetParameterData.accountId;
            acc.IntroMailInfoStatus__c = CommonConst_ptl.INTRODUCTION_SEND;          //紹介メール配信状況
            if (String.isBlank(seveSetParameterData.introMailInfoId)){ //紹介メール情報Idがないときのみ
                acc.IntroMailInfoPursuitCount__c = 0;                                //紹介メール追客回数
                acc.IntroMailIManualDeliveryChangeDatetime__c = CommonUtil.getNow(); //紹介メール手動配信変更日時
            }
            acc.IntroMailInfoFirstSendDatetime__c = introMailInfoFirstSendDatetime;  //紹介メール追客開始日時
            SecureDML.secureUpdate(acc);

            //紹介メール情報を登録・更新
            IntroductionMailInformation__c introMail = new IntroductionMailInformation__c();
            if (String.isNotBlank(seveSetParameterData.introMailInfoId)){//紹介メール情報Idがあるときのみ
                introMail.Id = seveSetParameterData.introMailInfoId;
            }else{                                            //紹介メール情報Idがないときのみ
                introMail.Account__c = seveSetParameterData.accountId;                                  //取引先        
            }
            introMail.Correspond__c = seveSetParameterData.correspond.Id;                               //対応
            introMail.Email__c = seveSetParameterData.mail;                                             //メール
            introMail.SendMailDate__c = seveSetParameterData.correspond.SendMailDate__c;                //メール送信日時
            introMail.ReceiveMailDateOther__c = seveSetParameterData.correspond.ReceiveMailDateOther__c;//メール受信日時（その他）
			// ▼ 2021.11.30 LINE連携対応より、LINE送信フラグを追加
			introMail.IsSendLINE__c = this.isSendLine;
			// ▲ 2021.11.30
            SecureDML.secureUpsert(introMail);

        } catch (Exception e) {
            Database.rollback(sp);//処理をロールバック
            hasErrorMessage = true;//エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }
    //----------------------------------privateメソッド-----------------------------------------------------------------
    //追客開始日時を0分or30分の文字列に変更し取得
    private void setintroMailInfoFirstSendDateTime(){
        String retrunTimeSt = '';
        Time targetTime = seveSetParameterData.introMailInfoFirstSendDatetime.time();
        Date targetDate = seveSetParameterData.introMailInfoFirstSendDatetime.date();
        Integer targetMinute = Integer.valueOf(targetTime.minute());


        //16分から44分までの間は30分
        if (15 < targetMinute && targetMinute < 45){
            retrunTimeSt = String.valueOf(targetTime.hour()).leftPad(2, '0') + ':30';

        //15分以下　0分（時間を繰り越さない）
        }else if (targetMinute <= 15){
            retrunTimeSt = String.valueOf(targetTime.hour()).leftPad(2, '0') + ':00';
        
        //45分以上　0分（時間を繰り越す）
        }else{
            
            Integer mnthEnd = Date.newInstance(targetDate.year(), targetDate.month() + 1 ,0).day();//月末取得
            
            if (targetTime.hour() < 23){
                //22時まで　+1時間
                retrunTimeSt = String.valueOf(targetTime.hour() + 1).leftPad(2, '0') + ':00';
            
            }else{
                //23時の場合
                targetDate = targetDate.addDays(1); //1日加算
                retrunTimeSt = '00:00';
            }
        }
        this.introMailInfoFirstSendDate = targetDate;
        this.introMailInfoFirstSendTime = retrunTimeSt;


    }

    //入力規則チェック
    private void inputCheck(){
        BusinessLogicException inputCheckException = new BusinessLogicException();

        //●自動追客開始日、自動追客開始時間に値が入っていない場合、メッセージ表示
        List<String> requiredItem = new List<String>();
        if (introMailInfoFirstSendDate == null){
            requiredItem.add('自動追客開始日');
        }
        if (introMailInfoFirstSendTime == null){
            requiredItem.add('自動追客開始時間');
        }
        if (!requiredItem.isEmpty()){
            //項目名をカンマで区切って、エラーを追加
            inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));
            throw inputCheckException;
        }
        

        //追客開始日時取得
        time tm = time.newInstance(Integer.ValueOf(introMailInfoFirstSendTime.left(2)), Integer.ValueOf(introMailInfoFirstSendTime.right(2)), 0, 0);
        Datetime introMailInfoFirstSendDatetime = Datetime.newInstance(this.introMailInfoFirstSendDate , tm);

        //●過去日時チェック
        if (introMailInfoFirstSendDatetime < CommonUtil.getNow()) {
            inputCheckException.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT,'自動追客開始日、自動追客開始時間に' ,'未来の日時' ));
            throw inputCheckException;

        }
    }
    
    //楽観ロックチェック  
    private void checkOptimisticLockException(){
        //楽観ロックチェックExceptionを発行(取引先)
        List<account> checkOptimisticLockExceptionAccount = new List<Account>();
        checkOptimisticLockExceptionAccount = [ SELECT id
                                                FROM Account
                                                WHERE id = :seveSetParameterData.accountId
                                                AND SystemModStamp > :seveSetParameterData.accountSystemModStamp ];                //楽観ロックチェック
        if (!checkOptimisticLockExceptionAccount.isEmpty()){
            OptimisticLockException ex = new OptimisticLockException();
            throw ex;
        }

        //紹介メール情報レコードがあるとき
        if (String.isNotBlank(seveSetParameterData.introMailInfoId)) {

            //楽観ロックチェックExceptionを発行(紹介メール配信状況)
            List<IntroductionMailInformation__c> checkOptimisticLockExceptionIntroMail = new List<IntroductionMailInformation__c>();
            checkOptimisticLockExceptionIntroMail = [ SELECT id
                                                        FROM IntroductionMailInformation__c
                                                        WHERE id = :seveSetParameterData.introMailInfoId
                                                        AND SystemModStamp > :seveSetParameterData.introMailInfoSystemModStamp ];                //楽観ロックチェック
            if (!checkOptimisticLockExceptionIntroMail.isEmpty()){
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
            }
        }
    }
    
    /**
     * 取引先情報取得
     * 引数に取引先の情報を取得する。
     * 引数　　：　accountId Id 取引先Id
     * 戻り値　：　List<Account>
     */
    private List<Account> selectAccount(Id accountId){
        // 検索SQL作成
        return [ SELECT id                              // ID
                    ,SystemModStamp                     //SystemModStamp
                    ,IntroMailInfoLastSendDatetime__c   //紹介メール最終配信日時
                    ,Email__c                           //メール
                    ,IntroMailInfoPursuitCount__c       //紹介メール追客回数
                FROM Account        
                WHERE Id = :accountId
                LIMIT 1];			                     // 表示上限を設定
    }

    /**
     * 保存時用パラメータ保持クラス
     */
    public class seveSetParameterClass {
        //取引先
        public Id accountId { get;set; }                            /** 取引先ID */
        public String introMailStatus { get;set; }                  /** 紹介メール配信状況 */
        public Datetime introMailInfoFirstSendDatetime{ get;set; }  /** 紹介メール追客開始日時 */
        public String mail{ get;set; }                              /** メールアドレス */
        public Datetime accountSystemModStamp{ get;set; }           /** SystemModStamp */

        //対応
        public Correspond__c correspond { get;set; }

        //紹介メール情報
        public Id introMailInfoId { get;set; }                      /** Id */
        public Datetime introMailInfoSystemModStamp { get;set; }    /** SystemModStamp */
		// ▼ 2021.11.30 LINE連携対応より、LINE送信フラグを追加
		public Boolean isSendLine {get; set;}
		// ▲ 2021.11.30
        
        //コンストラクタ
        public seveSetParameterClass(GA102001Modal7ParameterClass ParameterDate,List<Account> accountList){
            //レコードの連動
            if(accountList.size() > 0){
                this.accountId = accountList[0].Id;
                
                this.mail = accountList[0].Email__c;
                this.accountSystemModStamp = accountList[0].SystemModStamp;   
            }
            this.introMailInfoFirstSendDatetime = ParameterDate.introMailInfoFirstSendDatetime;

            this.correspond = ParameterDate.correspond;

            this.introMailInfoId = ParameterDate.introMailInfoId;
            this.introMailInfoSystemModStamp = ParameterDate.introMailInfoSystemModStamp;
			// ▼ 2021.11.30 LINE連携対応より、LINE送信フラグを追加
			this.isSendLine = ParameterDate.isSendLine;
			// ▲ 2021.11.30
        }

        // 初期化
        public seveSetParameterClass(){
            this.accountId = null;
            this.correspond = null;
            this.introMailStatus = null;
            this.introMailInfoFirstSendDatetime = null;
            this.mail = null;
            this.accountSystemModStamp = null;
            this.introMailInfoId = null;
            this.introMailInfoSystemModStamp = null;
        }
    }
}