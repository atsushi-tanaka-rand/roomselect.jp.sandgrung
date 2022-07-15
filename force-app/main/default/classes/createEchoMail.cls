// メール受信
global class createEchoMail implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

        // 変数宣言
        result.success = true;
        EchoMail__c insEchoMail = new EchoMail__c();

        try {
            
            // メール項目設定 本文
            setBody(insEchoMail, email);
            
            // メール項目設定 Fromポータルサイト
            setFromPortalsite(insEchoMail, email);
            
            // メール項目設定 反響メール固有項目
            setEchoMailItem(insEchoMail, email);

            // メール項目設定 その他
            setOtherMailItem(insEchoMail, email);

            // メール項目設定 エラーメール項目
            setErrorMailItem(insEchoMail, email);

            // メール項目設定 指定メール項目
            setSpecifiedMailDetail(insEchoMail);

            // 登録 反響メール
            SecureDML.secureInsert(insEchoMail);

            // 登録 添付ファイル
            insertAttachment(insEchoMail, email);            
            
            // バッチ起動 反響メールバッチ
            callEchoMailBatch(insEchoMail);

            
        }catch(Exception e){
            //何かしら例外発生時の通知文面
            //▼問合せNo0449で変更
            String errorMessage = '';
            errorMessage = CommonConst.MSG_ACC_E_RECEIVE_MAIL_ERROR +'\n';
            errorMessage += '\n';
            errorMessage += '【元メール】\n';
            errorMessage += email.plainTextBody ;
            errorMessage += '\n';
            errorMessage += '【エラーメッセージ】\n';
            errorMessage += e.getMessage();
            sendIncomingMailErrors(errorMessage);
            //▲問合せNo0449で変更
        }
        return result;
    }
    



    //************************************************************************************************ privateメソッド**************************************************************************

    //●本文の設定
    private void setBody(Echomail__c insEchoMail, Messaging.InboundEmail email) {
        
        String theBody = '';
        // 受信メールがテキスト形式
        if (String.isNotBlank(email.plainTextBody)){
            // メール本文を格納
            theBody = email.plainTextBody;
            // 受信メールがテキスト形式ではない(HTML形式)
        }else if (String.isNotBlank(email.htmlBody)) {
            // HTML形式の本文を格納
            theBody = email.htmlBody;
        }else{
            // 上記以外は空でセットする。
            theBody = '';
        }
        insEchoMail.Body__c = theBody;
    }
    
    
    //●ポータルサイトの設定
    private void setFromPortalsite(Echomail__c insEchoMail, Messaging.InboundEmail email) {
        // ポータルサイト情報の取得
        List <PortalSite__c> portalSiteList = new List<portalsite__c>();
        if (email.fromAddress != null) {
            portalSiteList = [SELECT Id, Email__c, Name FROM PortalSite__c WHERE Email__c = :email.fromAddress];
            if (!portalSiteList.isEmpty()) {
				// ▼ 2022/3/7 CHINTAI対応による追加
				if (email.fromAddress == CommonConst.EMAIL_CHINTAI) {
					Map<String, Id> portalSiteMap = new Map<String, Id>();
					for (PortalSite__c portalSite : portalSiteList) {
						portalSiteMap.put(portalSite.Name, portalSite.Id);
					}
					if (email.subject.containsIgnoreCase('Woman')) { // Woman.CHINTAIからのメールの場合
						insEchoMail.FromPotalSite__c = portalSiteMap.get(CommonConst.PORTALSITE_NAME_WOMANCHINTAI);
					} else { // CHINTAIからのメールの場合		
						insEchoMail.FromPotalSite__c = portalSiteMap.get(CommonConst.PORTALSITE_NAME_CHINTAI);
					}
                // ▲ 2022/3/7 CHINTAI対応による追加
				} else {
					// その他のポータルサイトの場合
					insEchoMail.FromPotalSite__c = portalSiteList[0].Id;
				}
            }
        }
    }
    
    
    //●反響メール固有項目の設定
    private void setEchoMailItem(Echomail__c insEchoMail, Messaging.InboundEmail email) {
        List<String> mailBodyList = insEchoMail.Body__c.split('\n');
        
        // 送信元によって編集方法を変える
        if (email.fromAddress == CommonConst.EMAIL_SUMO) {
            // スーモの場合
            MailUtil.setEcoMailSumo(insEchoMail, mailBodyList);
            insEchoMail.BatchStatus__c = CommonConst.BATCH_STUTAS_WAITING;
        } else if (email.fromAddress == CommonConst.EMAIL_HOMES ) {
            // ホームズの場合
            MailUtil.setEcoMailHomes(insEchoMail, mailBodyList);
            insEchoMail.BatchStatus__c = CommonConst.BATCH_STUTAS_WAITING;
        } else if (email.fromAddress == CommonConst.EMAIL_ATHOME) {
            // アットホームの場合
            MailUtil.setEcoMailAtHome(insEchoMail, mailBodyList);
            insEchoMail.BatchStatus__c = CommonConst.BATCH_STUTAS_WAITING;

        // ポータルサイト構築 追加 Start
        } else if (email.fromAddress == CommonConst_ptl.EMAIL_PORTAL){
            //自社ポータルの場合
            MailUtil.setEcoMailPortal(insEchoMail);
            insEchoMail.BatchStatus__c = CommonConst.BATCH_STUTAS_WAITING;
        // ポータルサイト構築 追加 End
        // ▼ 2022/3/7 CHINTAI対応による追加
		} else if (email.fromAddress == CommonConst.EMAIL_CHINTAI){
			MailUtil.setEcoMailChintai(insEchoMail, mailBodyList);
			insEchoMail.BatchStatus__c = CommonConst.BATCH_STUTAS_WAITING;
        // ▲ 2022/3/7 CHINTAI対応による追加
        } else {
            // その他のアドレスの場合
            insEchoMail.ResponseDate__c    = CommonUtil.getNow();    // 反響日
            insEchoMail.InquiryDateTime__c = CommonUtil.getNow();    // お問合せ日時
            insEchoMail.FromEmail__c       = email.fromAddress;      // Fromアドレス
        }
        
        
        // fromEmailが空の場合（反響メールの文面から取得できない場合）
        if (String.isBlank(insEchoMail.FromEmail__c)) {
            if (String.isBlank(insEchoMail.CustomerName__c)) { //名前もなければ反響メールの文面ではないと判断
                insEchoMail.FromEmail__c = email.fromAddress; //メールの送信元をそのまま入れる
            }
            //反響メールの文面で、顧客のメアドが記載されていなければfromEmailは空白になる
        }
        
        // お問い合わせ日時が空の場合（反響メールの文面から取得できない場合）
        if (insEchoMail.InquiryDateTime__c == null) {
            insEchoMail.InquiryDateTime__c = CommonUtil.getNow();
        }
    }
    
    
    //●その他のメール項目の設定
    private void setOtherMailItem(Echomail__c insEchoMail, Messaging.InboundEmail email) {
        
        // 件名
        insEchoMail.Subject__c = email.subject;
        
        // メールアドレスの設定
        setEmailAddress(insEchoMail, email);
 
        // メッセージId
        insEchoMail.MessageId__c = email.messageId;
        
        // References
        for (String ref : new List<String>(email.References)) {
            if (insEchoMail.References__c != null) {
                insEchoMail.References__c += ' ' + ref;
            } else {
                insEchoMail.References__c = ref;
            }
        }
    }
    
    //●メールアドレスの設定(転送元から設定する←そうしないと1件目ではないto指定や、cc,bccで届いたものが登録されない)
    private void setEmailAddress(Echomail__c insEchoMail, Messaging.InboundEmail email) {
        
        String emailSF = ''; // X-SFDC-Original-RCPTのメールアドレス取得用
        // X-SFDC-Original-RCPTのメールアドレスを取得
        List<Messaging.InboundEmail.Header> emailHeaderLiist = email.headers;
        for (Messaging.InboundEmail.Header emailHeader: emailHeaderLiist) {
            if(emailHeader.name == 'X-SFDC-Original-RCPT'){  // 転送のメールアドレスを取得
                // 一致有
                emailSF =  emailHeader.value;
                break;
            }
        }
        
        
        String ecoEmail = '';   // メールアドレス設定用
        if(String.isNotBlank(emailSF)){
            // 取得したSFのメールアドレスを元に店舗を取得
            List<Shop__c> shopList = MailUtil.getEmailSF(emailSF);
            if(shopList.size() >= 1){
                // 店舗が取得できれば店舗のメールアドレスを設定する。
                ecoEmail = shopList[0].Email__c;  // 店舗のメールアドレス
            }else{
                ecoEmail = MailUtil.getEmailAddress(email.toAddresses);    //問合せNo0595で変更
            }
        }else{
            ecoEmail = MailUtil.getEmailAddress(email.toAddresses);        //問合せNo0595で変更
        }
        
        insEchoMail.Email__c = ecoEmail;  // メールアドレス設定
        
    }
    
    
    //●エラーメールの処理
    private void setErrorMailItem(Echomail__c insEchoMail, Messaging.InboundEmail email) {
        
        // 変数設定
        List<Messaging.Inboundemail.Binaryattachment> batts = email.binaryAttachments;
        
        // salesforceからのメール以外は対象外
        if (email.fromAddress != CommonConst.EMAIL_ERROR) {
            return;
        }
       
        // 添付ファイルがない場合も対象外
        if (batts == null || batts.size() == 0){
            return;
        }
        
        // 添付ファイルを一つずつ見る
        for (Messaging.Inboundemail.Binaryattachment batt: batts){
            
            // 対象となる添付ファイルを指定（宛名なしエラーは2つの添付が紐づくようです）
            if (batt.fileName.contains('ForwardedAttachment')) {
                
                List<String> errBodyList = batt.body.toString().split('\n');
                // 添付ファイルの中から送信先アドレスを抽出
                for (String errBody : errBodyList) {
                    //▼問合せ381で変更
                    // if (errBody.contains('To: "')) {
                    //     Integer num = errBody.indexOf('<');
                    //     String val = errBody.remove(errBody.left(num)).remove('<').remove('>');
                        
                    //     insEchoMail.Body__c = insEchoMail.Body__c + '\n' + '宛先不明のメールアドレス：' + val;
                    // }

                    if(errBody.contains('>>> ')) {
                        Integer MailAddressFirst = errBody.IndexOf('>');
                        Integer MailAddressLast = errBody.IndexOf('(');
                        String targetMailAddress = errBody.substring(MailAddressFirst+3, MailAddressLast).deleteWhitespace();
                        insEchoMail.Body__c = insEchoMail.Body__c + '\n' + '宛先不明のメールアドレス：' + targetMailAddress;
                    }
                    //▲問合せ381で変更
                }
                break;
            }
        }
    }
    
    //●添付ファイルの挿入
    private void insertAttachment(Echomail__c insEchoMail, Messaging.InboundEmail email) {
        
        // 宛名なしでエラーでなければ、添付ファイルを格納
        List<Attachment> insAttachmentList = new List<Attachment>();
        
        if (email.fromAddress == CommonConst.EMAIL_ERROR) {
            return;
        }
        
        // 添付ファイルが存在する場合
        if (email.binaryAttachments != null && email.binaryAttachments.size() > 0){
            for (Messaging.Inboundemail.Binaryattachment batt: email.binaryAttachments){
                Attachment insAttachment = new Attachment();
                // ファイル名を設定
                insAttachment.Name = batt.fileName;
                // ファイルの内容を設定
                insAttachment.Body = batt.body;
                // 紐付け先を設定
                insAttachment.ParentId = insEchoMail.Id;
                insAttachmentList.add(insAttachment);
            }     
            SecureDML.secureInsert(insAttachmentList);
        }
    }
    
    
    //●指定メール項目の設定
    private void setSpecifiedMailDetail(Echomail__c e) {
        
        // 指定メール設定を取得
        SpecifiedMailSetting__c s = getSpecifiedMailSetting(e);
        
        // 指定メール設定があるなら
        if (s != null) {
            
            // 指定メールに関する項目を設定
            e.isSpecifiedMail__c     = true;         // 指定メール設定フラグ
            e.SpecifiedMailFolder__c = s.Folder__c;  // フォルダを指定
            e.BatchStatus__c         = null;         // バッチ処理ステータスを初期化(指定メールは反響メールとして処理しない)
            
        }
        
    }
    
    
    //●指定メール設定レコードの取得
    private SpecifiedMailSetting__c getSpecifiedMailSetting(Echomail__c e) {
        
        // 指定メールの対象レコードを取得
        List<SpecifiedMailSetting__c> specifiedMailSettingList =
            [SELECT Folder__c
             FROM SpecifiedMailSetting__c
             WHERE (FromAddress__c = :e.FromEmail__c AND ToAddress__c = ''          AND Subject__c = ''           )
            OR (FromAddress__c = ''              AND ToAddress__c = :e.Email__c AND Subject__c = ''           )
            OR (FromAddress__c = ''              AND ToAddress__c = ''          AND Subject__c = :e.Subject__c)
            OR (FromAddress__c = :e.FromEmail__c AND ToAddress__c = :e.Email__c AND Subject__c = ''           )
            OR (FromAddress__c = :e.FromEmail__c AND ToAddress__c = ''          AND Subject__c = :e.Subject__c)
            OR (FromAddress__c = ''              AND ToAddress__c = :e.Email__c AND Subject__c = :e.Subject__c)
            OR (FromAddress__c = :e.FromEmail__c AND ToAddress__c = :e.Email__c AND Subject__c = :e.Subject__c)
         ORDER BY CreatedDate
         LIMIT 1];

         // 取得できたら返却
         if ( !specifiedMailSettingList.isEmpty() ) {
             return specifiedMailSettingList[0];
         } else {
             return null;
         }
    }
    
    //●反響メールバッチ呼び出し
    private void callEchoMailBatch(Echomail__c insEchoMail) {
        
        // 処理待ちはバッチ起動対象
        if (insEchoMail.BatchStatus__c != '処理待ち'){
            return;
        }
        
        // システム設定の値を参照(FOR UPDATE)
        List<SystemVariables__c> slist = [SELECT Id, BooleanValue__c FROM SystemVariables__c WHERE VariablesName__c = :CommonConst.IS_ECHOMAIL_BATCHPROCESSING LIMIT 1 FOR UPDATE];

        // システム設定が読み込めなければ終了
        if ( slist.isEmpty() ) {
            return;
        }

        // システム設定の値を更新
        if (!slist[0].BooleanValue__c) { //値１(バッチ起動中)でなければ
            
            //値１(バッチ起動中) を更新
            SystemVariables__c updateSystemVariables = new SystemVariables__c(Id = slist[0].Id, BooleanValue__c = true);
            SecureDML.secureUpdate(updateSystemVariables);
            
            //バッチ起動
            BA101005Batch b = new BA101005Batch(1); //引数:起動回数が1回目
            Database.executeBatch(b,200);
        } else {
  
            //値２(バッチ2:追加起動あり) を更新
            SystemVariables__c updateSystemVariables = new SystemVariables__c(Id = slist[0].Id, BooleanValue2__c = true);
            SecureDML.secureUpdate(updateSystemVariables);
        }
    }

    //▼問合せNo0449で追加
    /**
     * 反響メール取込エラー送信
     * @param  string errorMessage エラーメッセージ
     * @return 
     */   
    private void sendIncomingMailErrors(string errorMessage){
        // カスタム設定「エラーメール送信先」取得
        String errorEmailDestination = SystemConfig__c.getInstance().ErrorEmailDestination__c;
        // システム管理者のメールアドレスを取得
        List<String> systemEmailList = CommonUtil.getAdministratorMailList();
        if(String.isNotEmpty(errorEmailDestination)){
            // カスタム設定「エラーメール送信先」があればリストに含める。
            systemEmailList.add(errorEmailDestination);
        }
                    
        // エラーメール送信
        MailUtil.MailData errorMailData = new MailUtil.MailData();
        errorMailData.toAddress = systemEmailList;
        errorMailData.ccAddress = null;
        errorMailData.fromAddress = null;
        errorMailData.subject = CommonConst.MSG_ACC_E_RECEIVE_MAIL_ERROR;
        errorMailData.textBody = errorMessage;

        MailUtil.sendMail(new List<MailUtil.MailData> {errorMailData});
            
    }
    //▲問合せNo0449で追加
}