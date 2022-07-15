//メール送信画面 の 確認モーダル
public inherited sharing class GA102004Modal1Controller {

    // パラメータ
    public GA102004Modal1ParameterClass parameter { get; set; }

    // エラー処理関連
    public Boolean isOpenError { get; set; }
    public Boolean hasErrorMessage { get; set; }

    // 表示用メール情報
    public ScreenMailInfo screenMailInfo { get; set; }

    // 添付ファイル一時保存用ParentId
    public Id tempAttachmentParentId { get; set; }

    // ページの初期表示処理実行用
    public Boolean init {
        get {
            if (this.parameter.isDrawing) {
                initAction();
                this.parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }

    // メッセージ定数
    public String MSG_COM_V_SENDMAIL            { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SENDMAIL);}             private set; }  // js用送信確認メッセージ
    public String MSG_COM_V_SENDMAIL_SCHEDULE   { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_SENDMAIL_SCHEDULE);}    private set; }  // js用時間指定送信確認メッセージ
    public String MSG_COM_I_SENDMAIL            { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SENDMAIL);}             private set; }  // js用送信完了メッセージ
    public String MSG_COM_I_SAVE                { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);}                 private set; }  // js用保存完了メッセージ

    // コンストラクタ
    public GA102004Modal1Controller() {
    }

    // ページの初期表示の具体的な処理
    public void initAction(){
        try{
            // 初期化
            this.isOpenError = false;
            this.hasErrorMessage = false;

            // パラメータから画面項目を設定
            this.screenMailInfo = new ScreenMailInfo(this.parameter.mailInfo);

        } catch (Exception e) {
            this.isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 送信ボタン押下時処理
    public void clickSend() {
        Savepoint sp = Database.setSavepoint();
        try{
            this.hasErrorMessage = false;
            //楽観ロックの有無判定
            throwOptimisticLockOfCorrespond();

            if (String.isNotEmpty(this.screenMailInfo.sendingDateTime)) {
                // 時間指定あり

                // 過去日時チェック
                DateTime tempDateTime = Datetime.newInstance(
                    this.parameter.mailInfo.sendingDate.year()
                    ,this.parameter.mailInfo.sendingDate.month()
                    ,this.parameter.mailInfo.sendingDate.day()
                    ,Integer.valueOf(this.parameter.mailInfo.sendingTime)
                    ,0
                    ,0
                );
                if (tempDateTime < CommonUtil.getNow()) {
                    BusinessLogicException ex = new BusinessLogicException();
                    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SENDPALNDATETIME_OLD));
                    throw ex;
                }

                // メール時間指定送信を登録
                saveMailTimeSpecificationSending();

            } else {
                // 時間指定なし

                // メール送信
                sendMail();

            }

            // 添付ファイル一時レコード削除（不要なレコードが残ってしまっていた場合の念のための削除）
            GA102004Controller.deleteTempMailDraft();


        } catch (Exception e) {
            Database.rollback(sp);//処理をロールバック
            this.hasErrorMessage = true; //エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    //対応の更新日付から楽観ロックの有無判定
    private void throwOptimisticLockOfCorrespond(){
        system.debug('あ'+ parameter.compareToTime);

        //最新の対応の更新日付を取得
        List<Correspond__c> latestRecord = new List<Correspond__c>();
        latestRecord = [ SELECT systemModStamp
                         FROM Correspond__c
                         WHERE id = :parameter.correspondId
                       ];

        DateTime systemModstamp = null;                  
        if(latestRecord.size() > 0){
            systemModstamp = latestRecord[0].systemModstamp;
        }
            //楽観ロックチェックExceptionを発行(対応)
            if (systemModstamp != parameter.compareToTime){
                OptimisticLockException ex = new OptimisticLockException();
                throw ex;
        }
    }

    // メール送信
    public void sendMail() {

        // 現在日時取得
        DateTime nowDateTime = CommonUtil.getNow();

        // 添付ファイルの取得
        List<Messaging.EmailFileAttachment> mailAttachment = new List<Messaging.EmailFileAttachment>();
        List<Attachment> attachment = new List<Attachment>();
        List<attachment> attachmentList = new List<attachment>();//対応明細に紐づける添付ファイル
        Id parentId = null;
        if (String.isNotEmpty(this.parameter.mailDraftId)) {
            parentId = this.parameter.mailDraftId;
        } else if (String.isNotEmpty(this.parameter.mailTimeSpecificationSendingId)) {
            parentId = this.parameter.mailTimeSpecificationSendingId;
        }
        if (parentId != null) {
            // 下書き/時間指定送信に紐付く添付ファイルの取得
            attachment = [
                SELECT
                    Id
                    ,ParentId
                    ,Name           // ファイル名
                    ,Body           // 本体
                    ,ContentType    // コンテンツタイプ
                FROM Attachment
                WHERE ParentId = :parentId
            ];
            // 送信メールの添付ファイルへと追加
            if (attachment.size() > 0) {
                for (Attachment record : attachment) {
                    Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
                    att.filename    = record.Name;
                    att.body        = record.Body;
                    att.contenttype = record.ContentType;
                    mailAttachment.add(att);

                    //対応明細に紐づけるためにコピー
                    Attachment newAttachmentData = record.clone(false);
                    attachmentList.add(newAttachmentData); 
                }
            }
        }
        // 添付ファイル一時保存情報の取得
        List<MailDraft__c> delMailDraft = new List<MailDraft__c>();
        if (String.isNotEmpty(this.tempAttachmentParentId)) {
            attachment = new List<Attachment>();
            attachment = [
                SELECT
                    Id
                    ,ParentId
                    ,Name           // ファイル名
                    ,Body           // 本体
                    ,ContentType    // コンテンツタイプ
                FROM Attachment
                WHERE
                    ParentId = :this.tempAttachmentParentId
            ];
            for (Attachment record : attachment) {
                Messaging.EmailFileAttachment tempAtt = new Messaging.EmailFileAttachment();
                tempAtt.filename    = record.Name;
                tempAtt.body        = record.Body;
                tempAtt.contenttype = record.ContentType;
                mailAttachment.add(tempAtt);

                //対応明細に紐づけるためにコピー
                Attachment newAttachmentData = record.clone(false);
                attachmentList.add(newAttachmentData);
            }
            delMailDraft = [
                SELECT
                    Id
                FROM MailDraft__c
                WHERE
                    Id = :this.tempAttachmentParentId
            ];
        }


        // 対応の更新
        if (String.isNotEmpty(this.parameter.correspondId)) {
            Correspond__c correspond = new Correspond__c();

            //2020/7/13追加：ステータス・一覧表示日時以外の変更　（引数1：対応、引数2：ログインユーザId）
            correspond = MailUtil.setCorrespondSendMail(this.parameter.correspond, UserInfo.getUserId());
            //2020/7/13追加：ステータスの変更　（引数1：ステータス、引数2：追客保留前ステータス、レコードタイプId）
            correspond.Status__c = CustomerUtil.changeSpecificStatus(this.parameter.correspond.Status__c, this.parameter.correspond.StatusBeforePursuitHold__c ,this.parameter.account.RecordTypeId); 
            //2020/7/13変更：対応確認を兼ねた一覧表示日時取得　（引数1：更新後ステータス、引数2：対応）
            correspond.ListViewDate__c = CustomerUtil.setListViewDateWhenCorrespondCheck(correspond.Status__c, this.parameter.correspond);
            SecureDML.secureUpdate(correspond);
    
            //対応内容作成
            String correspondContents = createCorrespondContents();

            // 対応明細の作成
            CorrespondDetail__c correspondDetail = new CorrespondDetail__c();
            correspondDetail.CorrespondType__c      = CommonConst.TASK_CORRESPONDTYPE_MAIL;         // 対応種別
            correspondDetail.SupportedDateTime__c   = nowDateTime;                                  // 対応日時
            correspondDetail.SupportedTitle__c      = CommonUtil.subStringLeft(this.parameter.mailInfo.subject, 255);   // 対応表題
            correspondDetail.SupportedContent__c    = correspondContents;                           // 対応内容
            correspondDetail.Shop__c                = this.parameter.shopId;                        // 店舗
            correspondDetail.Staff__c               = UserInfo.getUserId();                         // 担当者
            correspondDetail.Corresponds__c         = this.parameter.correspondId;                  // 対応番号
            correspondDetail.MailType__c            = CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND;   // メール種別
            correspondDetail.Email__c               = this.parameter.mailInfo.sendFromMail;         // 送信者メールアドレス

            SecureDML.secureInsert(correspondDetail);
        
            //添付ファイルを対応明細に紐づける
            if (attachment.size() > 0) {
                for(Attachment attachmentData : attachmentList){
                    attachmentData.ParentId = correspondDetail.id;
                }                       
                SecureDML.secureInsert(attachmentList);    
                // 下書き/時間指定送信に紐付く添付ファイルの削除                                       
                //添付ファイル一時保存情報の削除
                SecureDML.secureDelete(attachment);
            }


        // メール下書き 削除
        if (String.isNotEmpty(this.parameter.mailDraftId)) {
            List<MailDraft__c> mailDraft = [
                SELECT
                    Id
                FROM MailDraft__c
                WHERE Id = :this.parameter.mailDraftId
            ];
            SecureDML.secureDelete(mailDraft);
        }
        // メール時間指定送信 削除
        if (String.isNotEmpty(this.parameter.mailTimeSpecificationSendingId)) {
            List<MailTimeSpecificationSending__c> mailTimeSpecificationSending = [
                SELECT
                    Id
                FROM MailTimeSpecificationSending__c
                WHERE Id = :this.parameter.mailTimeSpecificationSendingId
            ];
            SecureDML.secureDelete(mailTimeSpecificationSending);
        }
        if (delMailDraft.size() > 0) {
            SecureDML.secureDelete(delMailDraft);
        }


        }
        // メール送信
        MailUtil.MailData mailData = new MailUtil.MailData();
        mailData.fromAddress    = this.parameter.mailInfo.sendFromMail;
        mailData.toAddress      = new List<String>();
        for (GA102004Controller.CheckText mail : this.parameter.mailInfo.sendTo) {
            if (mail.isCheck) {
                mailData.toAddress.add(mail.value);
            }
        }
        mailData.ccAddress      = new List<String>();
        for (GA102004Controller.CheckText mail : this.parameter.mailInfo.cc) {
            if (mail.isCheck) {
                mailData.toAddress.add(mail.value);
            }
        }
        mailData.subject        = this.parameter.mailInfo.subject;
        mailData.textBody       = this.parameter.mailInfo.body;
        mailData.mailAttachment = mailAttachment;
        if (this.parameter.isReply) {
            mailData.inReplyTo  = this.parameter.messageId;
            mailData.references = this.parameter.references + this.parameter.messageId;
        }
		// ▼ 2021.12.3 LINE連携対応より、HTMLメールの送信処理の追加・修正
		mailData.isLineIntroduction	= this.parameter.mailInfo.isLineFriendIntroduction;
		mailData.htmlBody = MailUtil.getLineIntroductionHtmlBody(mailData, this.parameter.account);
        
        mailData.textBody = MailUtil.getLineIntroductionTextBody(mailData, this.parameter.account);

		Messaging.SendEmailResult sendEmailResult = MailUtil.sendHtmlMail(mailData);
		// ▲ 2021.12.3

        // 結果判断
        if (!sendEmailResult.isSuccess()) {
            // 送信エラーの場合、Exception発行
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SENDMAIL));
            for (Messaging.SendEmailError error : sendEmailResult.getErrors()) {
                ex.addMessage(CommonUtil.callMessageCreate(error.getMessage()));
            }
            throw ex;
        }

    }   

    //対応内容に宛先、cc、本文追加
    private String createCorrespondContents(){
        String correspondContents;
        boolean firstToFlag = true;
        for (GA102004Controller.CheckText mail : this.parameter.mailInfo.sendTo) {            
            if (mail.isCheck) {
                if(firstToFlag == true){
                    correspondContents        = 'TO:' + mail.value;
                    firstToFlag = false;
                }else{
                    correspondContents += '、' + mail.value;
                }
            }
        }
        boolean firstCcFlag = true;
        for (GA102004Controller.CheckText mail : this.parameter.mailInfo.cc) {   
            if (mail.isCheck) {
                if(firstCcFlag == true){
                    correspondContents        += '\n' + 'CC:' + mail.value;
                    firstCcFlag = false;
                }else{
                    correspondContents       += '、' + mail.value;
                }
            }
        }
        if(this.parameter.mailInfo.body != null){
            correspondContents        += '\n\n' + this.parameter.mailInfo.body;           
        }
        return correspondContents;
    }
    

    // メール時間指定送信 作成
    private void saveMailTimeSpecificationSending() {

        // メール時間指定送信 情報作成（画面⇒時間指定送信）
        MailTimeSpecificationSending__c mailTimeSpecificationSending = new MailTimeSpecificationSending__c();
        mailTimeSpecificationSending.Id                     = this.parameter.mailTimeSpecificationSendingId;
        mailTimeSpecificationSending.Name                   = CommonUtil.subStringLeft(this.parameter.mailInfo.subject, 80); // 名称　※件名をセット（最大80文字）
        mailTimeSpecificationSending.From__c                = this.parameter.mailInfo.sendFromMail; // 送信者
        String temp = '';
        for (GA102004Controller.CheckText mail : this.parameter.mailInfo.sendTo) {
            if (mail.isCheck) {
                temp += String.isEmpty(temp) ? '' : ';';
                temp += mail.value;
            }
        }
        mailTimeSpecificationSending.To__c                  = temp;                                 // 宛先
        temp = '';
        for (GA102004Controller.CheckText mail : this.parameter.mailInfo.cc) {
            if (mail.isCheck) {
                temp += String.isEmpty(temp) ? '' : ';';
                temp += mail.value;
            }
        }
        mailTimeSpecificationSending.Cc__c                  = temp;                                 // CC
        mailTimeSpecificationSending.Subject__c             = this.parameter.mailInfo.subject;      // 件名
        mailTimeSpecificationSending.Body__c                = this.parameter.mailInfo.body;         // メール内容
        mailTimeSpecificationSending.Shop__c                = this.parameter.shopId;                // 店舗
        mailTimeSpecificationSending.Account__c             = this.parameter.accountId;             // 取引先
        Datetime tempDateTime = null;
        if (this.parameter.mailInfo.sendingDate != null && String.isNotEmpty(this.parameter.mailInfo.sendingTime)) {
            Date tempDate = this.parameter.mailInfo.sendingDate;
            tempDateTime = Datetime.newInstance(tempDate.year(), tempDate.month(), tempDate.day(), Integer.valueOf(this.parameter.mailInfo.sendingTime), 0, 0);
        }
        mailTimeSpecificationSending.SendingDateTime__c     = tempDateTime;                         // 送信予定日時
        mailTimeSpecificationSending.Correspond__c          = this.parameter.correspondId;          // 対応
        mailTimeSpecificationSending.CorrespondDetail__c    = this.parameter.correspondDetailId;    // 対応明細
        mailTimeSpecificationSending.IsReply__c             = this.parameter.isReply;               // 返信フラグ
		mailTimeSpecificationSending.IsLineIntroduction__c	= this.parameter.mailInfo.isLineFriendIntroduction; // 2021.12.3 LINE連携対応より、LINE紹介フラグを追加

        SecureDML.secureUpsert(mailTimeSpecificationSending);

        // 添付ファイル一時保存情報の取得
        if (String.isNotEmpty(this.tempAttachmentParentId)) {
            List<Attachment> attachment = [
                SELECT
                    Name
                    ,Body
                    ,OwnerId
                FROM Attachment
                WHERE
                    ParentId = :this.tempAttachmentParentId
            ];
            List<Attachment> newAttachmentList = new List<Attachment>();
            for (Attachment record : attachment) {
                Attachment tempAtt = new Attachment();
                tempAtt.Name       = record.Name;
                tempAtt.Body       = record.Body;
                tempAtt.ParentId   = mailTimeSpecificationSending.Id;
                newAttachmentList.add(tempAtt);
            }
            SecureDML.secureInsert(newAttachmentList);
            // 添付ファイル一時保存情報の削除
            SecureDML.secureDelete(attachment);

            List<MailDraft__c> delMailDraft = [
                SELECT
                    Id
                FROM MailDraft__c
                WHERE
                    Id = :this.tempAttachmentParentId
            ];
            SecureDML.secureDelete(delMailDraft);
        }

        if (String.isNotEmpty(this.parameter.mailDraftId)) {
            // 元がメール下書きの場合

            // 添付ファイル 移行（時間指定送信⇒下書き）
            List<Attachment> attachment = [
                SELECT
                    Id
                    ,Name
                    ,Body
                    ,OwnerId
                FROM Attachment
                WHERE
                    ParentId = :this.parameter.mailDraftId
            ];
            if (attachment.size() > 0) {
                List<Attachment> newAttachmentList = new List<Attachment>();
                for (Attachment record : attachment) {
                    Attachment tempAtt = new Attachment();
                    tempAtt.Name       = record.Name;
                    tempAtt.Body       = record.Body;
                    tempAtt.ParentId   = mailTimeSpecificationSending.Id;
                    newAttachmentList.add(tempAtt);
                }
                SecureDML.secureInsert(newAttachmentList);
                SecureDML.secureDelete(attachment);
            }

            // メール下書き 削除
            List<MailDraft__c> mailDraft = [
                SELECT
                    Id
                FROM MailDraft__c
                WHERE Id = :this.parameter.mailDraftId
            ];
            SecureDML.secureDelete(mailDraft);
        }

    }

    // 画面表示用クラス
    public class ScreenMailInfo {

		// ▼ 2021.12.3 LINE連携対応より、LINEともだち登録紹介の定数を追加
		private final String LINE_FRIEND_INTRODUCTION_DO	= 'する';
		private final String LINE_FRIEND_INTRODUCTION_NOT	= 'しない';
		// ▲ 2021.12.3

        public String sendingDateTime       { get; set; }   // 送信予定日時
        public String sendFrom              { get; set; }   // 送信者
        public String sendTo                { get; set; }   // 宛先
        public String cc                    { get; set; }   // CC
        public String attachmentFileNames   { get; set; }   // 添付ファイル
		public String lineFriendIntroduction{ get; set; }	// 2021.12.3 LINE連携対応より、LINEともだち紹介を追加
        public String subject               { get; set; }   // 件名
        public String body                  { get; set; }   // 本文
        // コンストラクタ
        public ScreenMailInfo(GA102004Controller.ScreenMailInfo param) {
            if (String.isNotEmpty(String.valueOf(param.sendingDate)) && String.isNotEmpty(param.sendingTime)) {
                DateTime tempDateTime = Datetime.newInstance(param.sendingDate.year(), param.sendingDate.month(), param.sendingDate.day(), Integer.valueOf(param.sendingTime), 0, 0);
                this.sendingDateTime = tempDateTime.format('yyyy/MM/dd HH:00');
            }
            this.sendFrom = param.sendFrom;
            this.sendTo = param.sendToName + ' ';
            for (GA102004Controller.CheckText mail : param.sendTo) {
                if (mail.isCheck) {
                    this.sendTo += '<' + mail.value + '>';
                }
            }
            this.cc = '';
            for (GA102004Controller.CheckText mail : param.cc) {
                if (mail.isCheck) {
                    this.cc += '<' + mail.value + '>';
                }
            }
            this.attachmentFileNames = param.attachmentFileNames;
            this.subject = param.subject;
            this.body = param.body;

			// ▼ 2021.12.3 LINE連携対応より、LINEともだち紹介を追加
			this.lineFriendIntroduction = this.LINE_FRIEND_INTRODUCTION_NOT;
			if (param.isLineFriendIntroduction) { 
				this.lineFriendIntroduction = this.LINE_FRIEND_INTRODUCTION_DO;
			}
			// ▲ 2021.12.3
        }
    }

}