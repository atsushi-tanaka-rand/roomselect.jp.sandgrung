/**
 * メール関係のメソッドを集めた、Utilクラス
 **/
public class MailUtil {

	// ▼ 2021.12.27 LINE連携対応より、追加
    /** 定数 */
    final private static Boolean AUTHORITY_OPTION_PORTAL_FLG = AuthorityCheckUtil.getAuthorityOptionPortal(false); // 自社ポータルの権限フラグ
    final private static String  PORTAL_SITE_URL_DETAIL      = CommonConst.PORTAL_SITE_URL_DETAIL;                 // ポータルサイトURL
	// ▲ 2021.12.27
	//▼ 2022.03.10 No0753 対応で修正「—————————————————————————————」も判定
	final private static String  EMAIL_END_LINE1			 = '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';	// 取得終了線１
	final private static String  EMAIL_END_LINE2			 = '—————————————————————————————';	// 取得終了線２
	//▲ 2022.03.10 No0753

    //**************************************************************publicメソッド**********************************************************

    // リダイレクトURLパラメータ
    private static List<RedirectUrlParameter__c> urlParamList = new List<RedirectUrlParameter__c>();

    // リダイレクトURL番号履歴
    private static List<RedirectUrlNoHistory__c> urlNoHistList = new List<RedirectUrlNoHistory__c>();
    
    // URL番号履歴
    private static Set<String> redirectUrlNoHistorySet = new Set<String>();
    
    //●メール送信メソッド(リスト)
    public static List<Messaging.SendEmailResult> sendMail(List<MailData> mailDataList) {

        //メールテンプレート情報取得
        Id templateId = SystemConfig__c.getInstance().MailTemplateId__c;//システム設定より取得

        //組織のメールアドレスMap作成
        Map<String, Id> orgMailMap = getOrgMailMap(mailDataList);

        //送信メールリストの宣言
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        //各メールの情報を設定
        for (MailData m: mailDataList) {

            //メールの宣言
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            //項目の設定
            email.setTemplateId(templateId);              //テンプレート
            email.setToAddresses(m.toAddress);            //宛先　リスト
            email.setCcAddresses(m.ccAddress);            //cc　　リスト
            email.setSubject(m.subject);                  //件名
            email.setPlainTextBody(m.textBody);           //本文

            email.setReplyTo(m.fromAddress);              //返信先
            email.setOrgWideEmailAddressId(orgMailMap.get(m.fromAddress)); //送信者、送信先を組織のメールアドレスで設定

            email.setUseSignature(false);                 //署名不要
            email.setSaveAsActivity(true);                //活動記録
            
            email.setFileAttachments(m.mailAttachment);   //添付　リスト
            
            email.setInReplyTo(m.inReplyTo);              //返信元メールのMessageId
            email.setReferences(m.references);            //返信元メールのReferences＋MessageId

            email.setCharset('UTF-8');                    //文字コード指定

            //送信リストに追加
            emailList.add(email);
        }

        //メール送信(同時に結果返却)
        return Messaging.sendEmail(emailList, false); //falseにすることでエラー以外はメール送信される
    }


	/**
	 * エラーメール送信成型
	 * @param  string errorMessage エラーメッセージ
	 * @param  string subject 件名
	 * @return なし
	 */   
	public static void sendErrorMail(string errorMessage,string subject){
		// カスタム設定「エラーメール送信先」取得
		String errorEmailDestination = SystemConfig__c.getInstance().ErrorEmailDestination__c;
		// システム管理者のメールアドレスを取得
		List<String> systemEmailList = CommonUtil.getAdministratorMailList();
		if(String.isNotEmpty(errorEmailDestination)){
			// カスタム設定「エラーメール送信先」があればリストに含める。
			systemEmailList.add(errorEmailDestination);
		}
					
		// エラーメール送信
		MailData errorMailData = new MailData();
		errorMailData.toAddress = systemEmailList;
		errorMailData.ccAddress = null;
		errorMailData.fromAddress = null;
		errorMailData.subject = subject;
		errorMailData.textBody = errorMessage;

		sendMail(new List<MailData> {errorMailData});
	}

    //●メール送信メソッド(単一)
    public static Messaging.SendEmailResult sendMail(Maildata m) {
        List<MailData> mailDataList = new List<MailData>();
        mailDataList.add(m);
        
        //メール送信
        List<Messaging.SendEmailResult> resultList =  SendMail(mailDataList);

        //結果返却(単一)
        return resultList[0];
    }

	// ▼ 2021.12.27 LINE連携対応より、HTMLメールの送信処理を追加
	/**
	 * HTMLメールの送信
	 * @param Maildata mailData メール送信用クラス
	 * @return Messaging.SendEmailResult メールメッセージの送信結果 // 2022.2.18 LINE連携対応より、コメントを修正
	 */
	public static Messaging.SendEmailResult sendHtmlMail(MailData mailData) {

		List<MailData> mailDataList = new List<MailData>{mailData};

		// メール送信と結果の取得
		return sendHtmlMail(mailDataList)[0];
	}

	/**
	 * HTMLメールの送信
	 * @param List<Maildata> mailData メール送信用クラス
	 * @return List<Messaging.SendEmailResult> メールメッセージの送信結果
	 */
	public static List<Messaging.SendEmailResult> sendHtmlMail(List<MailData> mailDataList) {
			
		//組織のメールアドレスMap作成
		Map<String, Id> orgMailMap = getOrgMailMap(mailDataList);

		// 送信メール用
		Messaging.SingleEmailMessage		email;
		List<Messaging.SingleEmailMessage>	emailList = new List<Messaging.SingleEmailMessage>();

		// 送信メール情報の取得
		for (MailData mailData: mailDataList) {

			email = new Messaging.SingleEmailMessage();

			// メール設定
			email.setSaveAsActivity(true);	// 活動の記録
			email.setCharset('UTF-8');		// 文字コード指定
			email.setUseSignature(false);	// 署名

			// 送信メールに関連する組織の共有アドレスID
			email.setOrgWideEmailAddressId(orgMailMap.get(mailData.fromAddress));

			// メールヘッダ
			email.setInReplyTo(mailData.inReplyTo);		// In-Reply-To
			email.setReferences(mailData.references);	// 親メールのReferences項目

			// メール宛先
			email.setToAddresses(mailData.toAddress);	// TO
			email.setCcAddresses(mailData.ccAddress);	// CC
			email.setReplyTo(mailData.fromAddress);		// 返信先

			// メール内容
			email.setSubject(mailData.subject);					// 件名
			email.setFileAttachments(mailData.mailAttachment);	// 添付ファイル
			email.setPlainTextBody(mailData.textBody);			// 本文（テキスト）
			email.setHtmlBody(mailData.htmlBody);				// 本文（HTML） ※HTMLタグが無い値はメーラーで表示されない為、要注意

			emailList.add(email);
		}

		// メールの送信
		return Messaging.sendEmail(emailList, false);
	}

	/**
	 * LINE紹介用HTMLのBODY句の取得
	 * @param MailData	mailData	メール送信用クラス // 2022.2.18 LINE連携対応より、コメントを修正
	 * @param Account	account		取引先
	 * @return String LINE紹介用HTMLのBODY句
	 */
	public static String getLineIntroductionHtmlBody(MailUtil.MailData mailData, Account account) {

		// メールテンプレートの取得
		HtmlMailTemplate__c htmlMailTemplate = new HtmlMailTemplate__c();
		if (mailData.isLineIntroduction) {
			htmlMailTemplate = selectHtmlMailTemplate(
                SystemConfig__c.getInstance().LineIntroductionMailTemplateName__c
            );
		}

		// HTMLボディ句の取得
		return MailUtil.getMailBody(htmlMailTemplate, mailData, account, true);
	}

	// ▼ 2022.2.2 LINE連携より、メールテンプレート（テキスト用）の追加
	/**
	 * LINE紹介用テキストのBODY句の取得
	 * @param MailData	mailData	メール送信用クラス // 2022.2.18 LINE連携対応より、コメントを修正
	 * @param Account	account		取引先
	 * @return String LINE紹介用HTMLのBODY句
	 */
	public static String getLineIntroductionTextBody(MailUtil.MailData mailData, Account account) {

		// メールテンプレートの取得
		TextMailTemplate__c textMailTemplate = new TextMailTemplate__c();
		if (mailData.isLineIntroduction) {
			textMailTemplate = selectTextMailTemplate(
				SystemConfig__c.getInstance().LineIntroductionMailTemplateName__c
			);
		}

		// テキストボディ句の取得
		return MailUtil.getMailBody(textMailTemplate, mailData, account, false);
	}
	// ▲ 2022.2.2

	// ▼ 2022.2.18 LINE連携対応より、コメントを修正
	/**
	 * メールのBODY句の取得
	 * @param SObject	mailTemplate	メールテンプレート
	 * @param MailData	mailData		メール送信用クラス
	 * @param Account	account			取引先
	 * @param Boolean	htmlFlg			HTMLフラグ（true:htmlメール、false:テキストメール）
	 * @return String メールのBODY句
	 */
	// ▲ 2022.2.18
	// ▼ 2022.2.2 LINE連携より、メールテンプレート（テキスト用）の追加
	public static String getMailBody(
		SObject mailTemplate
		, MailData mailData
		, Account account  
		, Boolean htmlFlg  
	) {

		String body = mailData.textBody;
		// 本文の取得
		if (htmlFlg) {
			body = mailData.textBody.replace(
				CommonConst.LINE_FEED
				, CommonConst.HTML_MAIL_BREAK_TAG
			);
		}

		// テンプレートが存在しない場合、HTML形式に変換した本文のみを返却
		if (mailTemplate.Id == null || String.isEmpty((String)mailTemplate.get(HtmlMailTemplate__c.Format__c.getDescribe().getName()))) {
			if (htmlFlg) {
				return CommonUtil.callMessageCreate(CommonConst.BASIC_HTML_MAIL_BODY, body);
			} else {
				return body;
			}
		}

		// ▼ 2022.1.29 LINE連携対応より、宛先を設定するよう修正
		// LINE紹介URLの取得
		String lineIntroductionUrl = getLineIntroductionUrl(
			mailTemplate
			, account
			, mailData.toAddress
		);

		// 置換文字（key:置換キーワード、value:置換文字）
		// {本文}
		// {LINE紹介URL}
		// {来店予約URL}
		Map<String, String> replaceWordMap = new Map<String, String> {
			CommonConst.REPLACE_KEY_HTML_BODY				=> body
			, CommonConst.REPLACE_KEY_LINE_INTRODUCTION_URL	=> lineIntroductionUrl
			, CommonConst.REPLACE_KEY_VISIT_RESERVATION_URL => (String)mailTemplate.get(HtmlMailTemplate__c.VisitReservationUrl__c.getDescribe().getName())
		};
		// ▲ 2022.1.29

		return getReplaceText((String)mailTemplate.get(HtmlMailTemplate__c.Format__c.getDescribe().getName()), replaceWordMap);
		// ▲ 2022.2.2
	}

	/**
	 * メールテンプレート(HTML用)の取得
	 * @param String condName テンプレート名
	 * @return HtmlMailTemplate__c メールテンプレート(HTML用)
	 */
	public static HtmlMailTemplate__c selectHtmlMailTemplate(String condName) {

		List<HtmlMailTemplate__c> htmlMailTemplateList = [
			SELECT
				Format__c
				, LineIntroductionUrl__c
                , VisitReservationUrl__c
			FROM HtmlMailTemplate__c
			WHERE Name = :condName
		];

		if (htmlMailTemplateList.isEmpty()) {
			return new HtmlMailTemplate__c();
		}

		return htmlMailTemplateList[0];
	}

	// ▼ 2022.2.2 LINE連携より、メールテンプレート（テキスト用）の追加
	/**
	 * メールテンプレート(テキスト用)の取得
	 * @param String condName テンプレート名
	 * @return TextMailTemplate__c メールテンプレート(テキスト用)
	 */
	public static TextMailTemplate__c selectTextMailTemplate(String condName) {

		List<TextMailTemplate__c> textMailTemplateList = [
			SELECT
				Format__c
				, LineIntroductionUrl__c
				, VisitReservationUrl__c
			FROM TextMailTemplate__c
			WHERE Name = :condName
		];

		if (textMailTemplateList.isEmpty()) {
			return new TextMailTemplate__c();
		}

		return textMailTemplateList[0];
	}
	// ▲ 2022.2.2

	// ▼ 2022.2.18 LINE連携対応より、コメントを修正
	// ▼ 2022.2.2 LINE連携対応より、メールテンプレート（テキスト用）を追加
	// ▼ 2022.1.29 LINE連携対応より、宛先を設定するよう修正
	/**
	 * LINE紹介URLの取得
	 * @param SObject       mailTemplate	メールテンプレート
	 * @param Account		account			取引先
	 * @param List<String>	toAddressList	宛先
	 * @return String LINE紹介URL
	 */
	// ▲ 2022.2.18
	private static String getLineIntroductionUrl(
		SObject mailTemplate
		, Account account
		, List<String> toAddressList
	) {

		// LINE紹介URLの存在チェック
		if (String.isBlank((String)mailTemplate.get(HtmlMailTemplate__c.LineIntroductionUrl__c.getDescribe().getName()))) {
			return CommonConst.STRING_EMPTY;
		}

		// LINE紹介URL（バッチ起動用のURL + 取引先ID + メールアドレス）
		String lineIntroductionUrl = mailTemplate.get(HtmlMailTemplate__c.LineIntroductionUrl__c.getDescribe().getName()) + '?ac={0}&ma={1}';

		// パラメータ.取引先ID
		String paramAccountId = CommonConst.STRING_EMPTY;
		if (String.isNotBlank(account.Id)) {
			paramAccountId = account.Id;
		}

		// パラメータ.メールアドレス
		String paramEmail = String.join(toAddressList, ',');

		return CommonUtil.callMessageCreate(lineIntroductionUrl, paramAccountId, paramEmail);
	}
	// ▲ 2022.1.29
	// ▲ 2021.12.27
	// ▲ 2022.2.2

    //●メール送信時の対応変更メソッド（ステータス・一覧表示日時以外）
    /*ステータス・一覧表示日時の変更メソッドはCutomoerUtilのメソッドにある。この2つは項目を返却するため、使う際は対応を返却するこのメソッドの後に動かす。
    *
    引数1：更新元の対応
    引数2：スタッフ対応フラグ変更の判断用のユーザ（メール送信時はログインユーザ、時間指定送信バッチでは時間指定メールレコードの作成者）
    */
    public static Correspond__c setCorrespondSendMail(Correspond__c corr, Id userId){
        Correspond__c reCorr = new Correspond__c();
        datetime nowDateTime =CommonUtil.getNow();
        
        reCorr.Id = corr.Id;                            //Id
        reCorr.SendMailDate__c          = nowDateTime;  // メール送信日時
        reCorr.EventDateTime__c         = nowDateTime;  // イベント時刻
        reCorr.IsSupportedListShow__c   = true;         // 対応確認フラグ
        reCorr.IsBrowseFlg__c           = true;         // 閲覧フラグ
        
        // レコードタイプが「顧客」の場合
        if (corr.AccountId__r.RecordTypeId == CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER)) {

            //2020/6/15追加：追客保留関連の項目をnullに（更新元のステータスが追客保留中だった場合、必ずステータスが追客系に変わるため）
            if (corr.Status__c == CommonConst.CORRESPOND_STATUS_PURSUITHOLD) {       
                reCorr.PursuitDissolveSettingDate__c = null;          //追客解除設定日時
                reCorr.PursuitDissolveDate__c = null;                 //追客解除設定日時（保存用）
                reCorr.StatusBeforePursuitHold__c = null;             //追客保留前ステータス
            }

            // スタッフ対応フラグ
            if (corr.EchoStaff__c == userId || corr.ShopStaff__c == userId) {
                // 反響担当者/来店担当者＝パラメータのユーザであればtrue
                reCorr.StaffSupportedFlg__c = true;
            } else {
                reCorr.StaffSupportedFlg__c = false;
            }
        }
        return reCorr;
    }


    // ●反響メール   取込　スーモ用
    public static void setEcoMailSumo(EchoMail__c ecoMail, List<String> mailBodyList){

        for (String mailBody : mailBodyList) {
            if (mailBody.contains('反響到着日時')) { 
                // 反響日
                //▼問合せNo0449で変更
                try {
                    // 反響日
                    ecoMail.ResponseDate__c = Datetime.valueOf(remSp(mailBody.remove('反響到着日時')).replace('/','-'));
                } catch(Exception e) {
                    // 空文字、異常値はセットしない。
                }
                //▲問合せNo0449で変更
            } else if (mailBody.contains('ＩＤ：')) { 
                // SUUMOID
                ecoMail.SuumoId__c = remSp(mailBody.remove('ＩＤ：'));
            } else if (mailBody.contains('お問合せ日時：')) { 
                // お問合せ日時
                //▼問合せNo0449で変更
                try {
                    ecoMail.InquiryDateTime__c = Datetime.valueOf(remSp(mailBody.remove('お問合せ日時：')).replace('/','-'));
                } catch(Exception e) {
                    // 空文字、異常値でのシステム日付をセットする。
                    ecoMail.InquiryDateTime__c = CommonUtil.getNow();
                }
                //▲問合せNo0449で変更
               
            } else if (mailBody.contains('連番：')) { 
                // ポータルサイト番号
                ecoMail.PortalSiteNo__c = remSp(mailBody.remove('連番：'));
            } else if (mailBody.contains('お問合せ企画：')) { 
                // お問合せ企画
                ecoMail.InquiryPlan__c = remSp(mailBody.remove('お問合せ企画：'));
            } else if (mailBody.contains('反響送付先区分：')) { 
                // 反響送付先区分
                ecoMail.ResponseSendType__c = remSp(mailBody.remove('反響送付先区分：'));
            } else if (mailBody.contains('反響送付先コード：')) { 
                // 反響送付先コード
                ecoMail.ResponseSendCode__c = remSp(mailBody.remove('反響送付先コード：'));
            } else if (mailBody.contains('会社名：')) { 
                // 会社名
                ecoMail.CompanyName__c = remSp(mailBody.remove('会社名：'));
            } else if (mailBody.contains('物件種別：')) { 
                // 物件種別
                ecoMail.PropertyType__c = remSp(mailBody.remove('物件種別：'));
            } else if (mailBody.contains('貴社物件コード：')) { 
                // 物件コード
                ecoMail.PropertyCode__c = remSp(mailBody.remove('貴社物件コード：'));
                ecoMail.Response__c = getPropertyId(ecoMail.PropertyCode__c);
            } else if (mailBody.contains('物件コード：')) { 
                // ポータルサイト物件コード
                ecoMail.PortalSitePropertyCode__c = remSp(mailBody.remove('物件コード：'));
            } else if (mailBody.contains('物件名：')) { 
                // 物件名
                ecoMail.PropertyName__c = remSp(mailBody.remove('物件名：'));
            } else if (mailBody.contains('最寄り駅：')) { 
                // 最寄駅
                ecoMail.ClosestStation__c = remSp(mailBody.remove('最寄り駅：'));
            } else if (mailBody.contains('バス／歩：')) { 
                // バス／歩
                String busWalk = mailBody.remove('バス／歩：');
                ecoMail.BusTime__c = remSp(busWalk.substringBefore('／'));
                ecoMail.WalkTime__c = remSp(busWalk.substringAfter('／'));
            } else if (mailBody.contains('所在地：')) { 
                // 所在地
                ecoMail.PropertyAddress__c = remSp(mailBody.remove('所在地：'));
            } else if (mailBody.contains('賃料：')) { 
                // 賃料
                ecoMail.RentFee__c = remSp(mailBody.remove('賃料：'));
            } else if (mailBody.contains('間取り：')) { 
                // 間取り
                ecoMail.RoomLayout__c = remSp(mailBody.remove('間取り：'));
            } else if (mailBody.contains('専有面積：')) { 
                // 面積
                ecoMail.PropertyArea__c = remSp(mailBody.remove('専有面積：'));
            } else if (mailBody.contains('物件詳細画面：')) { 
                // 物件URL
                ecoMail.PropertURL__c = remSp(mailBody.remove('物件詳細画面：'));
            } else if (mailBody.contains('名前（漢字）：')) { 
                // お客様名
                ecoMail.CustomerName__c = remSp(mailBody.remove('名前（漢字）：'));
            } else if (mailBody.contains('名前（カナ）：')) { 
                // お客様名（カナ）
                ecoMail.CustomerNameKana__c = remSp(mailBody.remove('名前（カナ）：'));
            } else if (mailBody.contains('メールアドレス：')) { 
                // Fromメールアドレス
                ecoMail.FromEmail__c = remSp(mailBody.remove('メールアドレス：'));
            } else if (mailBody.contains('ＴＥＬ：')) { 
                // 電話番号
                ecoMail.Phone__c = remSp(mailBody.remove('ＴＥＬ：'));
            } else if (mailBody.contains('FAX：')) { 
                // FAX
                ecoMail.Fax__c = remSp(mailBody.remove('FAX：'));
            } else if (mailBody.contains('連絡方法：')) { 
                // 連絡方法
                ecoMail.ContactMeans__c = remSp(mailBody.remove('連絡方法：'));
            } else if (mailBody.contains('お問合せ内容：')) { 
                // お問合せ内容
                ecoMail.InquiryContent__c = remSp(mailBody.remove('お問合せ内容：'));
            //}
            // ▼問合せ323で追加
            } else if (mailBody.contains('お問合せ内容コメント：')) {
                if (ecoMail.InquiryContent__c != null) {
                    ecoMail.InquiryContent__c += '\n' + remSp(mailBody.remove('お問合せ内容コメント：'));
                } else {
                    ecoMail.InquiryContent__c = remSp(mailBody.remove('お問合せ内容コメント：'));
                }
            }
            // ▲問合せ323で追加
        }

    }

    // ●反響メール取込　ホームズ用
    public static void setEcoMailHomes(EchoMail__c ecoMail, List<String> mailBodyList){

        Boolean inquiryDateTimeFlg = false;
        Boolean propertUrlFlg = false;
        // 問合せ323で追加
        Boolean inquiryContentFlg = false;

        for (String mailBody : mailBodyList) {

            if (mailBody.contains('ご確認の上、ご連絡をお願いいたします。')) { 
                inquiryDateTimeFlg = true;
            } else if (inquiryDateTimeFlg) {
                try {
                    // お問合せ日時
                    ecoMail.InquiryDateTime__c = Datetime.valueOf(remSp(mailBody).replace('/','-'));
                } catch(Exception e) {
                    // 空文字、異常値での例外を握り潰す（値の設定は後続処理で実施）
                }
                inquiryDateTimeFlg = false;
            } else if (mailBody.contains('下記URLをクリックすると問合せ物件の詳細を見ることができます。')
                       || mailBody.contains('＜物件情報＞')) { 
                propertUrlFlg = true;
            } else if (propertUrlFlg) {

                // 新フォーマット対応（キー行の次が空行）
                if (String.isBlank(mailBody)) {
                    continue;
                }

                // 物件URL
                ecoMail.PropertURL__c = remSp(mailBody);
                propertUrlFlg = false;
            } else if (mailBody.contains('物件種別：')) { 
                // 物件種別
                ecoMail.PropertyType__c = remSp(mailBody.remove('物件種別：'));
            } else if (mailBody.contains('物件名：')) { 
                // 物件名
                ecoMail.PropertyName__c = remSp(mailBody.remove('物件名：'));
            } else if (mailBody.contains('賃料：')) { 
                // 賃料
                ecoMail.RentFee__c = remSp(mailBody.remove('賃料：'));
            } else if (mailBody.contains('所在地：')) { 
                // 所在地
                ecoMail.PropertyAddress__c = remSp(mailBody.remove('所在地：'));
            } else if (mailBody.contains('交通：')) { 
                // 最寄駅
                ecoMail.ClosestStation__c = remSp(mailBody.remove('交通：'));
            } else if (mailBody.contains('面積：')) { 
                // 面積
                ecoMail.PropertyArea__c = remSp(mailBody.remove('面積：'));
            } else if (mailBody.contains('間取：')) { 
                // 間取り
                ecoMail.RoomLayout__c = remSp(mailBody.remove('間取：'));
            } else if (mailBody.contains('物件番号：')) { 
                // ポータルサイト物件コード
                ecoMail.PortalSitePropertyCode__c = remSp(mailBody.remove('物件番号：'));
            } else if (mailBody.contains('自社管理番号：')) { 
                // 物件コード
                ecoMail.PropertyCode__c = remSp(mailBody.remove('自社管理番号：'));
                ecoMail.Response__c = getPropertyId(ecoMail.PropertyCode__c);
            } else if (mailBody.contains('問合せ番号：')) { 
                // ポータルサイト番号
                ecoMail.PortalSiteNo__c = remSp(mailBody.remove('問合せ番号：'));
            } else if (mailBody.contains('名前：')) { 
                // お客様名
                ecoMail.CustomerName__c = remSp(mailBody.remove('名前：'));
            } else if (mailBody.contains('メールアドレス：')) { 
                // Fromメールアドレス
                ecoMail.FromEmail__c = remSp(mailBody.remove('メールアドレス：'));
            } else if (remSp(mailBody).indexOf('電話番号：') == 0) {
                // 電話番号
                ecoMail.Phone__c = remSp(mailBody.remove('電話番号：'));
            } else if (mailBody.contains('お問合せ内容：')) { 
                // お問合せ内容
                ecoMail.InquiryContent__c = remSp(mailBody.remove('お問合せ内容：'));
            //}
            // ▼問合せ323で追加
            } else if (mailBody.contains('備考：')) { 
                // 備考
                if (ecoMail.InquiryContent__c != null) {
                    ecoMail.InquiryContent__c += '\n' + remSp(mailBody.remove('備考：'));
                } else {
                    ecoMail.InquiryContent__c = remSp(mailBody.remove('備考：'));
                }
            } else if (mailBody.contains('【見学予約問合せ】')) {
                // 見学予約問合せから━━━━━━━━━━━━━━━━━━━━━━━━までをInquiryContent__cに追加する。
                inquiryContentFlg = true;
                if (ecoMail.InquiryContent__c != null) {
                    ecoMail.InquiryContent__c += '\n' + remSp(mailBody);
                } else {
                    ecoMail.InquiryContent__c = remSp(mailBody);
                }
            } else if (mailBody.contains('━━━━━━━━━━━━━━━━━━━━━━━━')) {
                inquiryContentFlg = false;
            } else if (inquiryContentFlg) {
                // お問合せ内容
                ecoMail.InquiryContent__c += '\n' + remSp(mailBody);

            }
            // ▲問合せ323で追加
        }

        // "ご確認の上、ご連絡をお願いいたします。"の文言がない場合
        // または問合せ日時設定時に例外が発生した場合
        if (ecoMail.InquiryDateTime__c == null) {
            ecoMail.InquiryDateTime__c = CommonUtil.getNow();
        }
    }

    // 反響メール取込　アットホーム用
    public static void setEcoMailAtHome(EchoMail__c ecoMail, List<String> mailBodyList){
        Boolean attbUrlFlg = false;
        Boolean inquiryReasonFlg = false;
        Boolean inquiryContent1Flg = false;
        Boolean inquiryContent2Flg = false;
        Boolean inquiryContent3Flg = false;
        Boolean propertMobileUrlFlg = false;
        Boolean propertUrlFlg = false;
        // 問合せ323で追加
        final String OTHER = '[その他]';

        for (String mailBody : mailBodyList) {

            if (mailBody.contains('<ＡＴＢＢのアドレス>')) { 
                attbUrlFlg = true;
            } else if (attbUrlFlg) {
                // ＡＴＢＢのアドレス
                ecoMail.ATBBURL__c = mailBody;
                attbUrlFlg = false;
            } else if (mailBody.contains('ＦＡＸ　　　　　　　：')) { 
                // Fax
                ecoMail.Fax__c = remSp(mailBody.remove('ＦＡＸ　　　　　　　：'));
            } else if (mailBody.contains('LINE＠ID　：')) { 
                // LINE＠ID
                ecoMail.LineId__c = remSp(mailBody.remove('LINE＠ID　：'));
            } else if (mailBody.contains('LINEプロフィール名　：')) { 
                // LINEプロフィール名
                ecoMail.LineName__c = remSp(mailBody.remove('LINEプロフィール名　：'));
            } else if (mailBody.contains('お名前(カナ)　　　　：')) { 
                // お客様名（カナ）
                ecoMail.CustomerNameKana__c = remSp(mailBody.remove('お名前(カナ)　　　　：'));
            } else if (mailBody.contains('お名前　　　　　　　：')) { 
                // お客様名　※下記のどちらかが設定される
                ecoMail.CustomerName__c = remSp(mailBody.remove('お名前　　　　　　　：'));
            } else if (mailBody.contains('お名前(漢字)　　　　：')) { 
                // お客様名　※下記のどちらかが設定される
                ecoMail.CustomerName__c = remSp(mailBody.remove('お名前(漢字)　　　　：'));
            } else if (mailBody.contains('お名前・ご担当者様名：')) { 
                // お客様名　※上記のどちらかが設定される
                ecoMail.CustomerName__c = remSp(mailBody.remove('お名前・ご担当者様名：'));
            } else if (mailBody.contains('＜物件のお問い合わせ理由＞')) { 
                inquiryReasonFlg = true;
				//▼ 2022.03.10 No0753 対応で修正「—————————————————————————————」も判定
			} else if (inquiryReasonFlg && (mailBody.contains(EMAIL_END_LINE1)
				|| mailBody.contains(EMAIL_END_LINE2))) { 
				//▲ 2022.03.10 No0753 対応で修正
				inquiryReasonFlg = false;
            } else if (inquiryReasonFlg && String.isNotBlank(mailBody)) {
                // お問い合わせ理由
                if (ecoMail.InquiryReason__c != null) {
                    ecoMail.InquiryReason__c += '　' + remSp(mailBody);
                } else {
                    ecoMail.InquiryReason__c = remSp(mailBody);
                }
            } else if (mailBody.contains('＜その他お問い合わせ内容・ご希望内容＞')) { 
                inquiryContent1Flg = true;
				//▼ 2022.03.10 No0753 対応で修正「—————————————————————————————」も判定
            } else if (inquiryContent1Flg && (mailBody.contains(EMAIL_END_LINE1) 
				|| mailBody.contains(EMAIL_END_LINE2))) { 
				//▲ 2022.03.10 No0753 対応で修正
                inquiryContent1Flg = false;
            // ▼問合せ323で追加
            } else if (inquiryContent1Flg && String.isNotBlank(mailBody)) {
                // お問合せ内容　※下記のどちらかが設定される
                if (ecoMail.InquiryContent__c != null) {
                    if(!mailBody.contains(OTHER)) {
                        ecoMail.InquiryContent__c += '\n' + remSp(mailBody);
                    }
                } else {
                    if(!mailBody.contains(OTHER)) {
                        ecoMail.InquiryContent__c = remSp(mailBody);
                    }
                }
            } else if (mailBody.contains('＜物件に関するお問合せ内容＞')) { 
                inquiryContent2Flg = true;
				//▼ 2022.03.10 No0753 対応で修正「—————————————————————————————」も判定
            } else if (inquiryContent2Flg && (mailBody.contains(EMAIL_END_LINE1)
				|| mailBody.contains(EMAIL_END_LINE2))) { 
				//▲ 2022.03.10 No0753 対応で修正
                inquiryContent2Flg = false;
            } else if (inquiryContent2Flg && String.isNotBlank(mailBody)) {
                // お問合せ内容　※上記のどちらかが設定される
                if (ecoMail.InquiryContent__c != null) {
                    if(!mailBody.contains(OTHER)) {
                        ecoMail.InquiryContent__c += '\n' + remSp(mailBody);
                    }
                } else {
                    if(!mailBody.contains(OTHER)) {
                        ecoMail.InquiryContent__c = remSp(mailBody);
                    }
                }
            } else if (mailBody.contains('＜物件に関するお問い合わせ内容＞')) { 
                inquiryContent3Flg = true;
				//▼ 2022.03.10 No0753 対応で修正「—————————————————————————————」も判定
            } else if (inquiryContent3Flg && (mailBody.contains(EMAIL_END_LINE1)
				|| mailBody.contains(EMAIL_END_LINE2))) { 
				//▲ 2022.03.10 No0753 対応で修正
                inquiryContent3Flg = false;
            } else if (inquiryContent3Flg && String.isNotBlank(mailBody)) {
                // お問合せ内容　※上記のどちらかが設定される
                if (ecoMail.InquiryContent__c != null) {
                    if(!mailBody.contains(OTHER)) {
                        ecoMail.InquiryContent__c += '\n' + remSp(mailBody);
                    }
                } else {
                    if(!mailBody.contains(OTHER)) {
                        ecoMail.InquiryContent__c = remSp(mailBody);
                    }
                }
            // ▲問合せ323で変更
            } else if (mailBody.contains('お問合わせ日時：')) { 
                // お問合せ日時
                ecoMail.InquiryDateTime__c = CommonUtil.getNow();
            } else if (mailBody.contains('会社名　　　　　　　：')) { 
                // 会社名
                ecoMail.CompanyName__c = remSp(mailBody.remove('会社名　　　　　　　：'));
            } else if (mailBody.contains('ケータイサイト用はコチラ↓')) { 
                propertMobileUrlFlg = true;
            } else if (propertMobileUrlFlg) {
                // ケータイサイト用_物件URL
                ecoMail.PropertMobileURL__c = remSp(mailBody);
                propertMobileUrlFlg = false;
            } else if (mailBody.contains('交通　　　　　　　：')) { 
                // 交通
                ecoMail.Transportation__c = remSp(mailBody.remove('交通　　　　　　　：'));
            } else if (mailBody.contains('ご希望時間帯　　　　：')) { 
                // ご希望時間帯　※下記のどちらかが設定される
                ecoMail.DesiredTime__c = remSp(mailBody.remove('ご希望時間帯　　　　：'));
            } else if (mailBody.contains('連絡希望の時間帯　　：')) { 
                // ご希望時間帯　※上記のどちらかが設定される
                ecoMail.DesiredTime__c = remSp(mailBody.remove('連絡希望の時間帯　　：'));
            } else if (mailBody.contains('住所　　　　　　　　：')) { 
                // 住所
                ecoMail.Address__c = remSp(mailBody.remove('住所　　　　　　　　：'));
            } else if (mailBody.contains('性別　　　　　　　　：')) { 
                // 性別
                ecoMail.Sex__c = remSp(mailBody.remove('性別　　　　　　　　：'));
            } else if (mailBody.contains('担当スタッフ　　　　：')) { 
                // 担当スタッフ
                ecoMail.Staff__c = remSp(mailBody.remove('担当スタッフ　　　　：'));
            } else if (mailBody.contains('価格　　　　　　　：')) { 
                // 賃料　※下記とどちらかが設定される
                ecoMail.RentFee__c = remSp(mailBody.remove('価格　　　　　　　：'));
            } else if (mailBody.contains('賃料　　　　　　　：')) { 
                // 賃料　※上記とどちらかが設定される
                ecoMail.RentFee__c = remSp(mailBody.remove('賃料　　　　　　　：'));
            } else if (mailBody.contains('電話番号　　　　　　：')) { 
                // 電話番号
                ecoMail.Phone__c = remSp(mailBody.remove('電話番号　　　　　　：'));
            } else if (mailBody.contains('土地面積　　　　　：')) { 
                // 土地面積
                ecoMail.GroundArea__c = remSp(mailBody.remove('土地面積　　　　　：'));
            } else if (mailBody.contains('入居希望時期　　　　：')) { 
                // 入居希望時期　※下記とどちらかが設定される
                ecoMail.OccupancyDesiredSeason__c = remSp(mailBody.remove('入居希望時期　　　　：'));
            } else if (mailBody.contains('入居予定時期　　　　：')) { 
                // 入居希望時期　※上記とどちらかが設定される
                ecoMail.OccupancyDesiredSeason__c = remSp(mailBody.remove('入居予定時期　　　　：'));
            } else if (mailBody.contains('年齢　　　　　　　　：')) { 
                // 年齢
                ecoMail.Age__c = remSp(mailBody.remove('年齢　　　　　　　　：'));
            } else if (mailBody.contains('バス停歩分　　　　：')) { 
                // バス
                ecoMail.BusTime__c = remSp(mailBody.remove('バス停歩分　　　　：'));
            } else if (mailBody.contains('バス停名　　　　　：')) { 
                // バス停名
                ecoMail.BusStop__c = remSp(mailBody.remove('バス停名　　　　　：'));
            } else if (mailBody.contains('バス乗車分　　　　：')) { 
                // バス乗車分
                ecoMail.BusRideTime__c = remSp(mailBody.remove('バス乗車分　　　　：'));
            } else if (mailBody.contains('貴社物件管理番号　　：')) { 
                // 物件コード
                String PropertyCode = remSp(mailBody.remove('貴社物件管理番号　　：'));
                if(PropertyCode.contains('-')){
                    // ハイフンありの場合後ろの文字を抽出
                    PropertyCode = PropertyCode.substringAfter('-');
                }
                ecoMail.PropertyCode__c = PropertyCode;
                ecoMail.Response__c = getPropertyId(ecoMail.PropertyCode__c);
                
            } else if (mailBody.contains('at home 物件番号　　：')) { 
                // ポータルサイト物件
                ecoMail.PortalSitePropertyCode__c = remSp(mailBody.remove('at home 物件番号　　：'));
            } else if (mailBody.contains('メールアドレス　　　：')) { 
                // メール
                ecoMail.FromEmail__c = remSp(mailBody.remove('メールアドレス　　　：'));
            } else if (mailBody.contains('メールアドレス（元付）：')) { 
                // メールアドレス（元付）
                ecoMail.FormerSupplierEmail__c = remSp(mailBody.remove('メールアドレス（元付）：'));
            } else if (mailBody.contains('使用部分面積　　　：')) { 
                // 面積　※いずれかが設定される
                ecoMail.PropertyArea__c = remSp(mailBody.remove('使用部分面積　　　：'));
            } else if (mailBody.contains('専有・建物面積　　：')) { 
                // 面積　※いずれかが設定される
                ecoMail.PropertyArea__c = remSp(mailBody.remove('専有・建物面積　　：'));
            } else if (mailBody.contains('専有面積　　　　　：')) { 
                // 面積　※いずれかが設定される
                ecoMail.PropertyArea__c = remSp(mailBody.remove('専有面積　　　　　：'));
            } else if (mailBody.contains('郵便番号　　　　　　：')) { 
                // 郵便番号
                ecoMail.PostalCode__c = remSp(mailBody.remove('郵便番号　　　　　　：'));
            } else if (mailBody.contains('その他の連絡方法　　：')) { 
                // その他の連絡方法
                ecoMail.OtherContact__c = remSp(mailBody.remove('その他の連絡方法　　：'));
            } else if (mailBody.contains('希望連絡方法　　　　：')) { 
                // 連絡方法
                ecoMail.ContactMeans__c = remSp(mailBody.remove('希望連絡方法　　　　：'));
            } else if (mailBody.contains('間取り　　　　　　：')) { 
                // 間取り
                ecoMail.RoomLayout__c = remSp(mailBody.remove('間取り　　　　　　：'));
            } else if (mailBody.contains('見学希望日時　　　　：')) { 
                // 見学希望日時
                ecoMail.VisitDesiredDateTime__c = remSp(mailBody.remove('見学希望日時　　　　：'));
            } else if (mailBody.contains('駅名　　　　　　　：')) { 
                // 最寄駅
                ecoMail.ClosestStation__c = remSp(mailBody.remove('駅名　　　　　　　：'));
            } else if (mailBody.contains('所在地　　　　　　：')) { 
                // 所在地
                ecoMail.PropertyAddress__c = remSp(mailBody.remove('所在地　　　　　　：'));
            } else if (mailBody.contains('電話番号（元付）　　　：')) { 
                // 電話番号（元付）
                ecoMail.FormerSupplierPhone__c = remSp(mailBody.remove('電話番号（元付）　　　：'));
            } else if (mailBody.contains('徒歩　　　　　　　：')) { 
                // 徒歩	
                ecoMail.WalkTime__c = remSp(mailBody.remove('徒歩　　　　　　　：'));
            } else if (mailBody.contains('不動産会社名（元付）　：')) { 
                // 不動産会社名（元付）
                ecoMail.FormerSupplier__c = remSp(mailBody.remove('不動産会社名（元付）　：'));
            } else if (mailBody.contains('詳しい物件情報はコチラ↓')) { 
                propertUrlFlg = true;
            } else if (mailBody.contains('エンジンレンタルに公開されている物件情報はコチラ↓')) { 
                propertUrlFlg = true;
            } else if(propertUrlFlg) {
                // 物件URL
                ecoMail.PropertURL__c = remSp(mailBody);
                propertUrlFlg = false;
            } else if (mailBody.contains('物件種目　　　　　：')) { 
                // 物件種別
                ecoMail.PropertyType__c = remSp(mailBody.remove('物件種目　　　　　：'));
            } else if (mailBody.contains('建物名　　　　　　：')) { 
                // 物件名
                ecoMail.PropertyName__c = remSp(mailBody.remove('建物名　　　　　　：'));
            } else if (mailBody.contains('御中')) { 
                // 物件名
                ecoMail.PropertyName__c = remSp(mailBody.remove('御中'));
            }
        }

    }
    // ポータルサイト構築 追加
    // ●反響メール取込　自社ポータル用
    public static void setEcoMailPortal(EchoMail__c ecoMail){
        //項目を設定
        setPortalItem(ecoMail);

        //本文のjsonの項目名を日本語に置換
        replacePortalBody(ecoMail);
    }

	// ▼ 2022/3/7 CHINTAI対応による追加
	public static void setEcoMailChintai(EchoMail__c ecoMail, List<String> mailBodyList){
		Boolean inquiryContentFlg = false;
		for (String mailBody : mailBodyList) {
			if (mailBody.contains('お問合せ時刻')) { //2022/5/31 CHINTAI本対応後の対応(反響メール)
				try {
					ecoMail.InquiryDateTime__c = Datetime.valueOf(remSp(CommonUtil.getcharacterString(mailBody)).replace('/','-')); //2022/5/31 CHINTAI本対応後の対応(反響メール)
				} catch(Exception e) {
					// 空文字、異常値での例外を握り潰す（値の設定は後続処理で実施）
				}
			} else if (mailBody.contains('＜見学希望日＞')) {
				ecoMail.VisitDesiredDateTime__c = remSp(mailBody) + ':';
			} else if (mailBody.contains('＜来店希望日＞')) {
				inquiryContentFlg = false;
				ecoMail.VisitDesiredDateTime__c = remSp(mailBody) + ':';
			} else if (mailBody.contains('＜オンライン相談希望日＞')) {
				inquiryContentFlg = false;
				ecoMail.VisitDesiredDateTime__c = remSp(mailBody) + ':';
			} else if (mailBody.contains('[第１希望日]')) {
				ecoMail.VisitDesiredDateTime__c += remSp(mailBody);
			} else if (mailBody.contains('[第２希望日]')) {
				ecoMail.VisitDesiredDateTime__c += '　' + remSp(mailBody);
			} else if (mailBody.contains('[第３希望日]')) {
				ecoMail.VisitDesiredDateTime__c += '　' + remSp(mailBody);
			// ▼ 2022/5/31 CHINTAI本対応後の対応(反響メール)
			} else if (mailBody.contains('最寄り駅')) {
				ecoMail.ClosestStation__c = remSp(CommonUtil.getcharacterString(mailBody));
			} else if (mailBody.contains('所在地')) {
				ecoMail.PropertyAddress__c = remSp(CommonUtil.getcharacterString(mailBody));
			} else if (mailBody.contains('賃料')) {
				ecoMail.RentFee__c = remSp(CommonUtil.getcharacterString(mailBody));
			} else if (mailBody.contains('間取り')) {
				ecoMail.RoomLayout__c = remSp(CommonUtil.getcharacterString(mailBody));
			} else if (mailBody.contains('専有面積')) {
				ecoMail.PropertyArea__c = remSp(CommonUtil.getcharacterString(mailBody));
			} else if (mailBody.contains('物件番号')) {
				String propertyNumber = remSp(CommonUtil.getcharacterString(mailBody));
			// ▲ 2022/5/31 CHINTAI本対応後の対応(反響メール)
				List<String> propertyNumberStrList = propertyNumber.split(''); 
				for (String proNumber : propertyNumberStrList) {
					if (proNumber == '0') {
						propertyNumber = propertyNumber.removeStart('0');
					} else {
						break;
					}
				}
				ecoMail.PropertyCode__c = propertyNumber;
				ecoMail.Response__c = getPropertyId(ecoMail.PropertyCode__c);
			// ▼ 2022/5/31 CHINTAI本対応後の対応(反響メール)
			} else if (mailBody.contains('物件名称')) {
				ecoMail.PropertyName__c = remSp(CommonUtil.getcharacterString(mailBody));
			} else if (mailBody.contains('部屋号室')) {
				ecoMail.PropertyName__c +=  ' ' + remSp(CommonUtil.getcharacterString(mailBody));
			} else if (mailBody.contains('掲載物件ＵＲＬ')) {
				ecoMail.PropertURL__c = remSp(CommonUtil.getcharacterString(mailBody));
			} else if (mailBody.contains('名前（カナ）')) {
				ecoMail.CustomerNameKana__c = remSp(CommonUtil.getcharacterString(mailBody));
			} else if (mailBody.contains('名前')) {
				ecoMail.CustomerName__c = remSp(CommonUtil.getcharacterString(mailBody));
			} else if (mailBody.contains('希望連絡方法')) {
				ecoMail.ContactMeans__c = remSp(CommonUtil.getcharacterString(mailBody));
			} else if (mailBody.contains('メール')) {
				if(mailBody.contains(':')){
					String mail = remSp(CommonUtil.getcharacterString(mailBody)); 
					if(Pattern.matches('^[A-Z0-9._%+-/!#$%&\'*=?^_`{|}~]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$', mail.toUpperCase())){
						ecoMail.FromEmail__c = mail;
					}
				}
			} else if (mailBody.contains('電話番号')) {
				ecoMail.Phone__c = remSp(CommonUtil.getcharacterString(mailBody));
			} else if (mailBody.contains('ＦＡＸ番号')) {
				ecoMail.Fax__c = remSp(CommonUtil.getcharacterString(mailBody));
			} else if (mailBody.contains('内容') || mailBody.contains('お問合せ内容')) {
				if(mailBody.contains(':')){
			// ▲ 2022/5/31 CHINTAI本対応後の対応(反響メール)
					ecoMail.InquiryContent__c = remSp(mailBody);
				}
			// ▼ 2022/5/31 CHINTAI本対応後の対応(反響メール)
			} else if (mailBody.contains('コメント')) {
				if(mailBody.contains(':')){
					inquiryContentFlg = true;
					if (ecoMail.InquiryContent__c != null) {
						ecoMail.InquiryContent__c += '\n' + remSp(mailBody);
					} else {
						ecoMail.InquiryContent__c = remSp(mailBody);
					}
				}
			// ▲ 2022/5/31 CHINTAI本対応後の対応(反響メール)
			} else if (mailBody.contains('======================================================================')) {
				inquiryContentFlg = false;
			} else if (inquiryContentFlg) {
				ecoMail.InquiryContent__c += '\n' + remSp(mailBody);
			}
		}
	}
	// ▲ 2022/3/7 CHINTAI対応による追加

    /**
    * 店舗情報をSFアドレスから取得する
     * @param   String EmailSF   対象メール
     * @return  List<Shop__c>   店舗情報
    */
    public static List<Shop__c> getEmailSF(String EmailSF){
        List<Shop__c> shopList = 
           [SELECT Id,EmailSF__c,Email__c
            FROM   Shop__c
            WHERE  EmailSF__c = :EmailSF
           ];
        return shopList;
    }

    //▼問合せNo0595で追加 
    /**
    * 店舗情報をアドレスから取得する
    * @param   List<String> emailList   対象メールリスト
    * @return  String   メールアドレス
    */
    public static String getEmailAddress(List<String> emailList){
        if (!emailList.isEmpty()){
            List<Shop__c> shopList = 
                [SELECT Id,EmailSF__c,Email__c
                    FROM   Shop__c
                    WHERE  Email__c IN :emailList
                ];

            // 複数の店舗一致の場合メールアドレスで始めに一致したアドレスの店舗をセットする
            for(Shop__c shop : shopList){
                for(String Email : emailList){
                    if(shop.Email__c == Email){
                        return shop.Email__c;
                    }
                }
            }
            // 一致が無ければToのアドレスをセット
            return emailList[0];
        }
        // 無ければ空
        return CommonConst.STRING_EMPTY;
        
    }
    //▲問合せNo0595で追加

	// ▼ 2021.12.27 LINE連携対応より、メール置換処理の追加、コードの見直し
	/**
	 * メール用置換文字の取得（対応に紐づく置換値の取得）
	 * @param String replaceTarget 置換対象
	 * @param Id     correspondId  対応ID
	 * @return String 置換結果
	 */
	public static String getMailReplaceText(String replaceTarget, Id correspondId) {

		// 対応の取得（※レコードが存在しない場合は例外をスロー）
		Correspond__c correspond = selectReplaceTextCorrespond(correspondId);
		if (String.isBlank(correspond.Id)) {
			throw new OptimisticLockException();
		}

		// 取引先の取得
		Account account = new Account();
		if (String.isNotBlank(correspond.AccountId__c)) {
			account.Id		= correspond.AccountId__c;
			account.Name	= correspond.AccountId__r.Name;
		}

		// 店舗担当者の取得
		String shopUserName = CommonConst.STRING_EMPTY;
		if (String.isNotEmpty(correspond.ShopStaffName__c)) { 
			// 対応.来店担当者名
			shopUserName = correspond.ShopStaffName__c;
		} else if (String.isNotEmpty(correspond.EchoStaffName__c)) {
			// 対応.反響担当者名
			shopUserName = correspond.EchoStaffName__c;
		}

		// 対象店舗IDの取得
		Id shopId = CommonUtil.getStaffCurrentShop().Id;
		if (shopId != correspond.EchoShop__c) {
			if (String.isNotBlank(correspond.VisitShop__c)) {
				// 対応.来店担当店舗
				shopId = correspond.VisitShop__c;
			} else if (String.isNotBlank(correspond.EchoShop__c)) {
				// 対応.反響担当店舗
				shopId = correspond.EchoShop__c;
			}
		}

		// 店舗の取得
		Shop__c shop = selectReplaceTextShop(shopId);

		// 対応に紐づく対応明細の取得
		CorrespondDetail__c correspondDetail = selectReplaceTextCorrespondDetail(correspondId);

		// 対応明細に紐づく反響メールの取得
		EchoMail__c echoMail = selectReplaceTextEchoMail(correspondDetail.EchoMail__c);

		// お客様名の取得
		String customerName = String.isBlank(correspond.AccountId__c) ? 
			correspond.LineMember__r.Name: correspond.AccountId__r.Name;

		// 置換結果の取得
		return getMailReplaceText(
			replaceTarget
			, customerName
			, shopUserName
			, shop
			, account
			, echoMail
			, CommonConst.STRING_EMPTY
			, correspond.Id
			, true
		);
	}

	/**
	 * メール用置換文字の取得（複数置換）
	 * @param List<String> replaceTargetList 置換対象
	 * @param String       customerName      お客様名
	 * @param String       chargeName        担当者名
	 * @param Shop__c      shop              店舗
	 * @param Account      account           取引先
	 * @param EchoMail__c  echoMail          反響メール
	 * @param String       sendingTime       送信時間
	 * @param Id           correspondId      対応ID
	 * @param Boolean      canDoCrud         true:CRUD処理の実施可、false:CRUD処理の実施不可
	 * @return List<String> 置換結果
	 */
	public static List<String> getMailReplaceText(
		List<String> replaceTargetList
		, String customerName
		, String chargeName
		, Shop__c shop
		, Account account
		, EchoMail__c echoMail
		, String sendingTime
		, Id correspondId
		, Boolean canDoCrud
	) {

		// 置換文字の取得（key:置換キーワード、value:置換文字）
		Map<String, String> replaceWordMap = getMailReplaceWord(
			customerName
			, chargeName
			, shop
			, account
			, echoMail
			, sendingTime
			, correspondId
			, canDoCrud
		);

		// 置換処理
		List<String> replaceResultList = new List<String>();
		for (String replaceTarget : replaceTargetList) {
			replaceResultList.add(getReplaceText(replaceTarget, replaceWordMap));
		}

		return replaceResultList;
	}

	/**
	 * メール用置換文字の取得（文字置換）
	 * @param String       replaceTarget 置換対象文字
	 * @param String       customerName  お客様名
	 * @param String       chargeName    担当者名
	 * @param Shop__c      shop          店舗
	 * @param Account      account       取引先
	 * @param EchoMail__c  echoMail      反響メール
	 * @param String       sendingTime   送信時間
	 * @param Id           correspondId  対応ID
	 * @param Boolean      canDoCrud     true:CRUD処理の実施可、false:CRUD処理の実施不可
	 * @return String 置換結果
	 */
	public static String getMailReplaceText(
		String replaceTarget
		, String customerName
		, String chargeName
		, Shop__c shop
		, Account account
		, EchoMail__c echoMail
		, String sendingTime
		, Id correspondId
		, Boolean canDoCrud
	) {
	
		// 置換結果の取得
		List<String> replaceResultList = getMailReplaceText(
			new List<String> {replaceTarget}
			, customerName
			, chargeName
			, shop
			, account
			, echoMail
			, sendingTime
			, correspondId
			, canDoCrud
		);

		return replaceResultList[0];
	}
	// ▲ 2021.12.27

    //******************************************************privateメソッド************************************************
    // ポータルサイト構築 追加 Start
    //------------------------------------------自社ポータル関連----------------------------------------------------
    //反響メール取込　自社ポータル　項目設定
    private static void setPortalItem(EchoMail__c ecoMail){
        //json形式の本文をクラスに変換
        JsonForPortalMail json = JsonForPortalMail.parse(ecoMail.Body__c);

        //jsonクラス型のCustomer内部クラス
        JsonForPortalMail.Customer c = json.Customer[0];

        //自社ポータル用_メール種別
        ecoMail.MailType__c = c.MailType;
        //自社ポータル用_来店予約日
        ecoMail.VisitReservationDate__c = createDatetimeItem(c.VisitDateTime);
        //自社ポータル用_会員Id
        ecoMail.MemberID__c = c.MemberId;

        //自社ポータル用_物件Idリスト、物件、物件コード
        createPropertyItem(ecoMail, json.Property);
        //お問合せ日時   
        ecoMail.InquiryDateTime__c = createDatetimeItem(c.InquiryDateTime);
        //お客様名
        if (String.isNotBlank(c.LastName) || String.isNotBlank(c.FirstName)){
            ecoMail.CustomerName__c = c.LastName + '　' + c.FirstName;
        }
        //お客様名カナ
        if (String.isNotBlank(c.LastName_kana) || String.isNotBlank(c.FirstName_kana)){
            ecoMail.CustomerNameKana__c = c.LastName_kana + '　' + c.FirstName_kana;
        }
        //メールアドレス
        ecoMail.FromEmail__c = c.Email;
        //電話番号
        ecoMail.Phone__c = c.Phone;
        //▼問合せNo0536で追加（取引先登録用項目）
        // 生年月日
        if (CommonUtil.isDate(c.BirthDay,false)){
            ecoMail.Birthdate__c = Date.parse(c.BirthDay);
        }
        // 希望地域
        ecoMail.DesiredArea__c = c.DesireArea;
        // 引越し時期
        if(c.OccupancyDesiredSeason.indexOf(CommonConst.HOME_MOVING_SEASON_TURNKEY) >= 0){
            // 即入居
            ecoMail.HomeMovingSeason__c = CommonConst.HOME_MOVING_SEASON_TURNKEY;
        }else if(c.OccupancyDesiredSeason.indexOf(CommonConst.HOME_MOVING_SEASON_OTHER) >= 0 ){
            // その他
            ecoMail.HomeMovingSeason__c = CommonConst.HOME_MOVING_SEASON_OTHER;
            // 引越時期（日付）までに
            Integer HhmeMovingDateLocation = c.OccupancyDesiredSeason.indexOf('(');
            if(HhmeMovingDateLocation < 0 || c.OccupancyDesiredSeason.indexOf('（') >= 0 ){
                HhmeMovingDateLocation = c.OccupancyDesiredSeason.indexOf('（');
            }
            if(HhmeMovingDateLocation >= 0){ 
                String homeMovingDate = c.OccupancyDesiredSeason.substring(HhmeMovingDateLocation+1,HhmeMovingDateLocation+11);
                if (CommonUtil.isDate(homeMovingDate,false)){
                    ecoMail.HomeMovingDate__c = Date.parse(homeMovingDate);
                }
            }
        }
        
        // 入居人数
        ecoMail.TenantCount__c = c.LivePeople;
        // 郵便番号
        ecoMail.PostalCode__c = c.Zip;
        // 都道府県
        ecoMail.State__c = c.State;
        // 住所１（市区町村）
        ecoMail.City__c = c.City;
        // 住所２（番地）
        ecoMail.Street__c = c.Street;

        //▲問合せNo0536で追加
        //お問い合わせ方法
        ecoMail.InquiryContent__c = c.InquiryContent;   
        // 物件URL
        if (String.isNotBlank(ecoMail.PropertyCode__c)){
            ecoMail.PropertURL__c = SystemConfig__c.getInstance().PortalSiteURL__c + 'detail?propertyCd=' + ecoMail.PropertyCode__c;
        }

		// ▼ 2021.12.27 LINE連携対応より、LINE受信時処理の追加
		if (String.isNotBlank(c.lineReceiveEvent)) {

			// LINE会員の取得
			LineMember__c lineMember = selectLineMember(c.lineId);

			// LINE受信情報の設定
			ecoMail.LineMember__c			= lineMember.Id;
			ecoMail.IsLineReceive__c		= true;
			ecoMail.LineReceiveType__c		= c.lineReceiveEvent;
			ecoMail.LineId__c				= c.lineId;
			ecoMail.LineName__c				= c.lineName;
			ecoMail.LineMessage__c			= c.lineMessage;
			ecoMail.LineFileName__c			= c.lineFileName;
			ecoMail.LineFileUrl__c			= c.lineFileUrl;
			ecoMail.LineThumbnailName__c	= c.lineThumbnailName;
			ecoMail.LineThumbnailUrl__c		= c.lineThumbnailUrl;
			ecoMail.LineReceiveTime__c		= createDatetimeItem(c.lineSendReceiveTime);

			// 取引先情報の設定
			if (String.isNotEmpty(lineMember.Account__c)) {
				// ▼ 2022.02.02 LINE連携より、ブランクチェックの追加
				ecoMail.CustomerName__c 	= CommonUtil.changeNullToEmpty(lineMember.Account__r.LastName__c)
											+ '  ' + CommonUtil.changeNullToEmpty(lineMember.Account__r.FirstName__c);

				ecoMail.CustomerNameKana__c	= CommonUtil.changeNullToEmpty(lineMember.Account__r.LastNameKana__c)
											+ '  ' + CommonUtil.changeNullToEmpty(lineMember.Account__r.FirstNameKana__c);
				// ▲ 2022.02.02
				ecoMail.FromEmail__c		= lineMember.Account__r.Email__c;
				ecoMail.Phone__c			= lineMember.Account__r.Phone;
			}
		}
		// ▲ 2021.12.27
    }

    //ポータル項目作成の物件関連項目作成　（物件、物件コード、物件リスト）
    private static void createPropertyItem(EchoMail__c ecoMail ,List<JsonForPortalMail.Property> proCodeList){
        //物件コードをSetにまとめてSELECTの条件に設定
        Set<String> proCodeSet = new Set<String>();
        for (JsonForPortalMail.Property pro : proCodeList){
            proCodeSet.add(pro.PropertyCode);
        }
        //物件コードを元にId取得
        List<Property__c> proList = [SELECT Id,PropertyCode__c 
                                     ,      name
                                     ,      Building__r.name
                                     ,      Building__r.Address__c
                                     ,      Building__r.TrainRoute1__r.Name
                                     ,      Building__r.Station1__r.Name
                                     ,      Building__r.StationWalkTimeFormat1__c
                                     ,      RoomLayout__c
                                     ,      RentFee__c 
                                     FROM   Property__c WHERE PropertyCode__c IN :proCodeSet];
        //取得したIdをリストに入れて,で区切って返却
        List<String> returnStList = new List<String>();
        Boolean notFirstPro = false;
        for (Property__c pro : proList){
            returnStList.add(pro.Id);
            if (!notFirstPro){
                ecoMail.Response__c = pro.Id;                   //最初の物件を物件に格納
                ecoMail.PropertyCode__c = pro.PropertyCode__c;  //最初の物件コードを物件コードに格納
                ecoMail.PropertyName__c = pro.Building__r.name +  pro.name;         // 最初の物件名
                ecoMail.PropertyAddress__c = pro.Building__r.Address__c ;           // 最初の所在地
                ecoMail.ClosestStation__c = pro.Building__r.TrainRoute1__r.Name + ' ' + pro.Building__r.Station1__r.Name; // 最初の最寄駅
                ecoMail.WalkTime__c = pro.Building__r.StationWalkTimeFormat1__c ;   // 最初の徒歩
                ecoMail.RoomLayout__c = pro.RoomLayout__c ;                         // 最初の間取り
                ecoMail.RentFee__c = CommonUtil.decimalToString(pro.RentFee__c) ;   // 最初の賃料
            }
            notFirstPro = true;
        }
        ecoMail.PropertyList__c = String.join(returnStList, ',');//物件リスト
    }

    //日付日時型の項目作成
    private static Datetime createDatetimeItem(String prDatetime){
        //値なしの場合、nullで返却
        if (String.isBlank(prDatetime)){
            return null;
        }
        //空白除去
        String stDatetime = prDatetime.replace(' ','');
        Integer year = Integer.valueOf(stDatetime.left(4));
        Integer month = Integer.valueOf(stDatetime.mid(5,2));
        Integer day = Integer.valueOf(stDatetime.mid(8,2));
        Integer hour = 0 ;
        Integer minute = 0;
        Integer second = 0;
        if(stDatetime.length() > 10){
            // 日付の項目が時分秒まで設定されて入れば抜き出す
            hour = Integer.valueOf(stDatetime.mid(10,2));
            minute = Integer.valueOf(stDatetime.mid(13,2));
            if(stDatetime.length() > 15){
                second = Integer.valueOf(stDatetime.mid(16,2));
            }
            
        }


        return Datetime.newInstance(year, month, day, hour, minute, second);
    }

    //ポータルの本文のjsonの項目名を日本語に置換
    private static void replacePortalBody(EchoMail__c ecoMail){
        //▼ポータル問合せNo0032で変更
        ecoMail.Body__c = ecoMail.Body__c.replace('"PropertyCode"','物件コード');
        ecoMail.Body__c = ecoMail.Body__c.replace('"Property"','問合せ物件');
        ecoMail.Body__c = ecoMail.Body__c.replace('"Customer"','お客様情報');
        ecoMail.Body__c = ecoMail.Body__c.replace('"MemberId"','会員ID');
        ecoMail.Body__c = ecoMail.Body__c.replace('"InquiryDateTime"','お問合せ日時');
        ecoMail.Body__c = ecoMail.Body__c.replace('"MailType"','メール種別');
        ecoMail.Body__c = ecoMail.Body__c.replace('"Shop"','来店店舗');
        ecoMail.Body__c = ecoMail.Body__c.replace('"VisitDateTime"','来店希望日時第１希望');
        ecoMail.Body__c = ecoMail.Body__c.replace('"VisitDateTime2"','来店希望日時第２希望');
        ecoMail.Body__c = ecoMail.Body__c.replace('"LastName"','姓');
        ecoMail.Body__c = ecoMail.Body__c.replace('"FirstName"','名');
        ecoMail.Body__c = ecoMail.Body__c.replace('"LastName_kana"','セイ');
        ecoMail.Body__c = ecoMail.Body__c.replace('"FirstName_kana"','メイ');
        ecoMail.Body__c = ecoMail.Body__c.replace('"Email"','メールアドレス');
        ecoMail.Body__c = ecoMail.Body__c.replace('"Phone"','電話番号');    
        ecoMail.Body__c = ecoMail.Body__c.replace('"BirthDay"','生年月日');    //問合せNo0536で追加
        ecoMail.Body__c = ecoMail.Body__c.replace('"Zip"','郵便番号');
        ecoMail.Body__c = ecoMail.Body__c.replace('"State"','都道府県');
        ecoMail.Body__c = ecoMail.Body__c.replace('"City"','市区町村');
        ecoMail.Body__c = ecoMail.Body__c.replace('"Street"','番地・建物');
        ecoMail.Body__c = ecoMail.Body__c.replace('"ContactMeans"','希望の連絡方法');
        ecoMail.Body__c = ecoMail.Body__c.replace('"InquiryContent"','お問合せ内容');
        ecoMail.Body__c = ecoMail.Body__c.replace('"DesireArea"','エリア');
        ecoMail.Body__c = ecoMail.Body__c.replace('"RentFee"','希望賃料下限');
        ecoMail.Body__c = ecoMail.Body__c.replace('"RentFeeUpper"','希望賃料上限');
        ecoMail.Body__c = ecoMail.Body__c.replace('"RoomPlan"','間取り');
        ecoMail.Body__c = ecoMail.Body__c.replace('"HomeMovingReason"','引越し理由');
        ecoMail.Body__c = ecoMail.Body__c.replace('"OccupancyDesiredSeason"','引越し時期');
        ecoMail.Body__c = ecoMail.Body__c.replace('"LivePeople"','入居人数');
        ecoMail.Body__c = ecoMail.Body__c.replace('"InquiryType"','お問合せ区分');
        ecoMail.Body__c = ecoMail.Body__c.replace('"textOther"','その他の問合せ内容');        
        ecoMail.Body__c = ecoMail.Body__c.replace('"textOther2"','その他、お問い合わせ');        
        ecoMail.Body__c = ecoMail.Body__c.replace('"HomeMovingReasonDissatisfaction"','現状不満理由');
		// ▼ 2022.1.29 LINE連携対応より、追加
		ecoMail.Body__c = ecoMail.Body__c.replace('"LineReceiveEvent"','LINE受信イベント');
		ecoMail.Body__c = ecoMail.Body__c.replace('"LineId"','LINE ID');
		ecoMail.Body__c = ecoMail.Body__c.replace('"LineName"','LINE名');
		ecoMail.Body__c = ecoMail.Body__c.replace('"LineMessageType"','LINEメッセージタイプ');
		ecoMail.Body__c = ecoMail.Body__c.replace('"LineMessage"','LINEメッセージ');
		ecoMail.Body__c = ecoMail.Body__c.replace('"LineFileName"','LINEファイル名');
		ecoMail.Body__c = ecoMail.Body__c.replace('"LineFileUrl"','LINEファイルURL');
		ecoMail.Body__c = ecoMail.Body__c.replace('"LineThumbnailName"','LINEサムネイル名');
		ecoMail.Body__c = ecoMail.Body__c.replace('"LineThumbnailUrl"','LINEサムネイルURL');
		ecoMail.Body__c = ecoMail.Body__c.replace('"LineSendReceiveTime"','LINE送受信時間');
		ecoMail.Body__c = ecoMail.Body__c.replace('"accountId"','取引先ID');
		// ▲ 2022.1.29

        // ポータルの本文を見やすく成型
        ecoMail.Body__c = ecoMail.Body__c.replace('"','').replaceFirst('],\\n','');
        ecoMail.Body__c = ecoMail.Body__c.replace(',\n',commonConst.BREAK_CODE).replace('[','').replace(']','').replace('{','').replace('}','');
        
        
        // メール内容を見やすく区切り線を追加
        ecoMail.Body__c = replaceSeparatorLine(ecoMail.Body__c,'お客様情報',true);
        ecoMail.Body__c = replaceSeparatorLine(ecoMail.Body__c,'お問合せ区分',true);
        ecoMail.Body__c = replaceSeparatorLine(ecoMail.Body__c,'来店店舗',true);
        ecoMail.Body__c = replaceSeparatorLine(ecoMail.Body__c,'姓',true);
        ecoMail.Body__c = replaceSeparatorLine(ecoMail.Body__c,'お問合せ内容',true);


        //▲ポータル問合せNo0032で変更
    }

    //▼ポータル問合せNo0032で追加
    // メール内容を見やすく区分け線を追加
    // String ecoMailBody             ：メール本文
    // String replaceTargetCharacter  ：区切り線設定対象文字列
    // Boolean aroundFlg              ：区切り線の設定位置（true：文字列の前、false：文字列の後ろ）
    private static String replaceSeparatorLine(String ecoMailBody,String replaceTargetCharacter,Boolean aroundFlg){
        if(String.isEmpty(ecoMailBody)) {
            return ecoMailBody;
        }
        if(ecoMailBody.indexOf(replaceTargetCharacter) < 0){
            return ecoMailBody;
        }


        if(aroundFlg){
            // 前文に区切り文字
            return ecoMailBody.replace(replaceTargetCharacter, '------------------------------------------------'+ commonConst.BREAK_CODE + replaceTargetCharacter);
            
        }else{
            // 後文に区切り文字
            return ecoMailBody.replace(replaceTargetCharacter,replaceTargetCharacter + commonConst.BREAK_CODE + '------------------------------------------------' );
        }
    }
    //▲ポータル問合せNo0032で変更
    //------------------------------------------自社ポータル関連----------------------------------------------------
    // ポータルサイト構築 追加 End

    //組織情報のMap作成
    private static Map<String, Id> getOrgMailMap(List<MailData> mailDataList) {

        //アドレスのList作成
        List<String> emailList = new List<String>();
        for (MailData m: mailDataList) {
            emailList.add(m.fromAddress);
        }

        //組織のメールアドレスを取得（同一メールアドレスの組織のメールアドレスがあることが前提）
        List <OrgWideEmailAddress> orgAddressList = 
           [SELECT Address, Id
            FROM   OrgWideEmailAddress
            WHERE  Address IN :emailList
           ];

        //Mapを作成して返却
        Map<String, Id> orgMailMap = new MAp<String, Id>();
        for (OrgWideEmailAddress o: orgAddressList) {
            orgMailMap.put(o.Address, o.Id);
        }

        return orgMailMap;
    }

    // 引数の前後の半角空白、全角空白を除去
    private static string remSp(String value) {
        // 以下の理由により、空白削除メソッドを作成
        // ・trimでは、全角空白が対象外
        // ・normalizeSpaceでは、前後の半角全角空白が共に消えるが、
        //   　残すべき文字間の全角空白が強制的に半角空白に置換されてしまう

        // trimで前後の半角空白を除去
        value = value.trim();

        // 前方の全角空白を除去
        while (value.startsWithIgnoreCase('　')) {
            value = value.removeStart('　');
        }

        // 後方の全角空白を除去
        while (value.endsWithIgnoreCase('　')) {
            value = value.removeEnd('　');
        }

        return value;
    }

    // 物件Idを取得
    private static Id getPropertyId(String propertyCode) {
    
        Id propertyId = null;
        List<Property__c> propertyList = new List<Property__c>();

        propertyList = [SELECT Id 
                    FROM Property__c
                    WHERE PropertyCode__c = :propertyCode];

        if (!propertyList.isEmpty()) {
            propertyId = propertyList[0].Id;
        }

        return propertyId;
    }

	// ▼ 2021.12.27 LINE連携対応より、メール送信画面で追加された内容とCRUD処理の追加、コードの見直し
	/**
	 * 物件URLの取得
	 * @param EchoMail__c echoMail	   反響メール
	 * @param Id		  accountId	   取引先ID
	 * @param Id		  correspondId 対応ID	
	 * @param Boolean     canDoCrud    true:CRUD処理の実施可、false:CRUD処理の実施不可
	 * @return String 物件URL
	 */
	private static String getPropertyUrl(
		EchoMail__c echoMail
		, Id accountId
		, Id correspondId
		, Boolean canDoCrud
	) {

		// 物件URL
		String propertyUrl = CommonConst.STRING_EMPTY;

		// 実施チェック
		if (String.isEmpty(echoMail.PropertURL__c)) {
			return propertyUrl;
		}

		// ポータルサイトURLの取得
		String potalSiteURL = echoMail.PropertURL__c;
		if(AUTHORITY_OPTION_PORTAL_FLG){
			potalSiteURL = PORTAL_SITE_URL_DETAIL + '?propertyCd=' + echoMail.PropertyCode__c;
		}

		// リダイレクトURLの取得
		String redirectUrl = getRedirectUrl(
			potalSiteURL
			, String.isBlank(echoMail.PropertyName__c) ? CommonConst.STRING_EMPTY: echoMail.PropertyName__c
			, accountId
			, correspondId
			, true
			, canDoCrud
		);

		// 物件詳細項目
		String[] propertyDetailItemAry = new String[] {
			echoMail.PropertyAddress__c
			, echoMail.ClosestStation__c
			, echoMail.WalkTime__c
			, echoMail.RoomLayout__c
			, echoMail.RentFee__c
		};

		// 物件URLに物件詳細情報を設定
		for (String propertyDetailItem : propertyDetailItemAry) {
			if (String.isBlank(propertyDetailItem)) {
				continue;
			}

			propertyUrl += propertyDetailItem + '/';
		}

		// 物件URLにリダイレクトURLを設定（※物件詳細情報が存在する場合、改行処理を行う）
		if (!String.isBlank(propertyUrl)) {
			propertyUrl = propertyUrl.removeEnd('/') + CommonConst.LINE_FEED;
		} 
		propertyUrl += redirectUrl;

		return propertyUrl;
	}

	/**
	 * メール用置換文字の取得
	 * @param String      customerName お客様名
	 * @param String      chargeName   担当者名
	 * @param Shop__c     shop         店舗
	 * @param Account	  account      取引先
	 * @param EchoMail__c echoMail     反響メール
	 * @param String      sendingTime  送信時間
	 * @param Id          correspondId 対応ID
	 * @param Boolean     canDoCrud    true:CRUD処理の実施可、false:CRUD処理の実施不可
	 * @return Map<String, String> key:置換キーワード、value:置換文字
	 */
	private static Map<String, String> getMailReplaceWord(
		String customerName
		, String chargeName
		, Shop__c shop
		, Account account
		, EchoMail__c echoMail
		, String sendingTime
		, Id correspondId
		, Boolean canDoCrud
	) {
	
		// 物件URLの取得
		String propertyUrl = getPropertyUrl(
			echoMail
			, account.Id
			, correspondId
			, canDoCrud
		);

		// 置換文字の設定（key:置換キーワード、value:置換文字）
		Map<String, String> replaceTextMap = new Map<String, String>{
			CommonConst.REPLACE_KEY_CUSTOMER_NAME			=>	customerName				// {お客様名}
			, CommonConst.REPLACE_KEY_IN_CHARGE_NAME		=>	chargeName					// {担当者名}
			, CommonConst.REPLACE_KEY_SHOP_NAME				=>	shop.Name					// {店舗名}
			, CommonConst.REPLACE_KEY_POSTAL_CODE			=>	shop.PostalCode__c			// {郵便番号}
			, CommonConst.REPLACE_KEY_SHOP_ADDRESS_1		=>	shop.City__c				// {店舗住所１}
			, CommonConst.REPLACE_KEY_SHOP_ADDRESS_2		=>	shop.Street__c				// {店舗住所２}
			, CommonConst.REPLACE_KEY_PHONE_NUMBER			=>	shop.Phone__c				// {電話番号}
			, CommonConst.REPLACE_KEY_FAX					=>	shop.Fax__c					// {FAX}
			, CommonConst.REPLACE_KEY_BUSINESS_HOURS		=>	shop.BusinessHours__c		// {営業時間}
			, CommonConst.REPLACE_KEY_REGULAR_HOLIDAY		=>	shop.RegularHoliday__c		// {定休日}
			, CommonConst.REPLACE_KEY_SHOP_HP				=>	shop.Homepage__c			// {店舗HP}
			, CommonConst.REPLACE_KEY_ECHOMAIL_GREETING		=>	getGreetingWord(sendingTime)// {挨拶}
			, CommonConst.REPLACE_KEY_ECHOMAIL_PROPERTY_URL	=>	propertyUrl					// {反響メール物件URL}
		};

		return replaceTextMap;
	}

	/**
	 * 置換文字の取得
	 * @param String 				replaceTarget	置換対象
	 * @param Map<String, String>	replaceWordMap	置換文字（key:置換キーワード、value:置換文字）
     * @return String 置換文字 // 2022.2.18 LINE連携対応より、コメントを修正
	 */
	private static String getReplaceText(String replaceTarget, Map<String, String> replaceWordMap) {

		// 実施チェック
		if (String.isBlank(replaceTarget)) {
			return CommonConst.STRING_EMPTY;
		}
        
		// 置換結果の取得用
		String replaceWord;
		String replaceResult;

		// 置換処理
		replaceResult = replaceTarget;
		for (String key : replaceWordMap.keySet()) {

			// 置換文字のnull値チェック
			replaceWord = replaceWordMap.get(key);
			if (String.isEmpty(replaceWord)) {
				replaceWord = CommonConst.STRING_EMPTY;
			}

			replaceResult = replaceResult.replace(key, replaceWord);
		}

		return replaceResult;
	}

	/**
	 * 挨拶の取得（文字列）
	 * @param String hour 時間
	 * @return String 挨拶
	 */
	private static String getGreetingWord(String hour) {

		// 未設定の場合はシステム日付を取得
		if(string.isBlank(hour)){
			hour = CommonUtil.getNow().format('H'); 
		}

		// 挨拶の取得
		String greetingWord;
		try {
			greetingWord = getGreetingWord(Integer.valueOf(hour));
		} catch (Exception e) {
			// 数値型への変換失敗時は変換値無しを返却
			return CommonConst.STRING_EMPTY;
		}

		return greetingWord;
	}

	/**
	 * 挨拶の取得（数値）
	 * @param Integer hour 時間
	 * @return String 挨拶
	 */
	private static String getGreetingWord(Integer hour) {

		String greetingWord = CommonConst.STRING_EMPTY;
		if (hour >= 0 && hour < 5) {
			// 夜
			greetingWord = CommonConst.GREETING_NIGHT;
		} else if (hour < 11) {
			// 朝
			greetingWord = CommonConst.GREETING_MORNING;
		} else if (hour < 18) {
			// 昼
			greetingWord = CommonConst.GREETING_NOON;
		} else if (hour < 21) {
			// 夕方
			greetingWord = CommonConst.GREETING_EVENING;
		} else if (hour < 24) {
			// 夜
			greetingWord = CommonConst.GREETING_NIGHT;
		}

		return greetingWord;
	}

	/**
	 * リダイレクトURLの取得
	 * ※呼び出し元では繰り返し処理が行われている為、ガバナ制限を考慮してCRUD処理は別途行う
	 * @param String  potalSiteURL   ポータルサイトの物件URL
	 * @param String  propertyDetail 物件情報
	 * @param Id      accountId      取引先ID
	 * @param Id      correspondId   対応ID
	 * @param Boolean hasOurPortal   自社ポータル保有フラグ（true:保有、false:未保有）
	 * @param Boolean canDoCrud      true:CRUD処理の実施可、false:CRUD処理の実施不可
	 * @return String リダイレクトURL
	 */
	public static String getRedirectUrl(
		String potalSiteURL
		, String propertyDetail
		, Id accountId
		, Id correspondId
		, Boolean hasOurPortal
		, Boolean canDoCrud
	) {

		// 自社ポータル情報よりURLを作成する場合、追加パラメータを設定
		String addParam = CommonConst.STRING_EMPTY;
		if (AUTHORITY_OPTION_PORTAL_FLG && hasOurPortal) {
			addParam = '&utm_source=mail&utm_medium=email&utm_campaign=' + CommonUtil.getNow().format('yyyyMMdd');
		}

		// リダイレクトURL用詳細パラメータの取得
		String redirectUrlDetailParam = 
			'portalsite=' + potalSiteURL
			+ addParam
			+ '&account=' + (String.isBlank(accountId) ? CommonConst.STRING_EMPTY: accountId)
			+ '&property=' + propertyDetail
			+ '&correspond=' + correspondId;

		// URL番号採番と採番履歴の保持
		String urlNo = getNumberingRedirectUrl(redirectUrlNoHistorySet);
		redirectUrlNoHistorySet.add(urlNo);

		// リダイレクトURLパラメータの取得
		RedirectUrlParameter__c urlParam = new RedirectUrlParameter__c(
			Name = urlNo
			, Parameter__c = redirectUrlDetailParam
		);
		urlParamList.add(urlParam);

		// リダイレクトURL番号履歴の取得
		RedirectUrlNoHistory__c urlNoHist = new RedirectUrlNoHistory__c(
			Name = urlNo
		);
		urlNoHistList.add(urlNoHist);

		// リダイレクトURLオブジェクトの一括処理
		if (canDoCrud) {
			redirectUrlBulkDml();
		}

		// リダイレクトURLの取得
		return SystemConfig__c.getInstance().RedirectURL__c + '?rs=' + urlNo;
	}

	/**
	 * リダイレクトURL番号の採番値の取得
	 * @param Set<String> numberedUrlNoSet 採番済みリダイレクトURL番号
	 * @return String リダイレクトURL番号
	 */
	private static String getNumberingRedirectUrl(Set<String> numberedUrlNoSet) {

		// 採番値の取得用
		String urlNo;
		RedirectUrlNoHistory__c redirectUrlNoHistory;

		// URL番号の採番（重複しない番号が生成できるまでループ）
		Boolean isExistsUrlNo = true;
		while (isExistsUrlNo) {

			// URL番号の採番
			urlNo = CommonUtil.getRandomString(10);

			// 重複値チェック
			// ※ガバナ制限回避として全レコードを取得した場合はヒープエラーになった為、採番毎にレコードを取得している
			redirectUrlNoHistory = selectRedirectUrlNoHistory(urlNo);
			if(String.isBlank(redirectUrlNoHistory.Id) && !numberedUrlNoSet.contains(urlNo)) {
				isExistsUrlNo = false;
			}
		}
			
		return urlNo;
	}

	/**
	 * リダイレクトURLオブジェクトの一括処理
	 */
	public static void redirectUrlBulkDml() {

		// URL番号採番値保持値を初期化
		redirectUrlNoHistorySet.clear();

		// リダイレクトURLパラメータの登録
		SecureDML.secureInsert(urlParamList);
		urlParamList.clear();

		// リダイレクトURL番号履歴の登録
		SecureDML.secureInsert(urlNoHistList);
		urlNoHistList.clear();

		// 前日以前に作成されたリダイレクトURLパラメータの削除
		delOldRedirectUrlParameter(CommonUtil.getNow().addDays(-1));
	}

	/**
	 * リダイレクトURL番号履歴の取得
	 * @param String condName URL番号
	 * @return RedirectUrlNoHistory__c リダイレクトURL番号履歴 // 2022.2.18 LINE連携対応より、コメントを修正
	 */
	private static RedirectUrlNoHistory__c selectRedirectUrlNoHistory(String condName) {

		List<RedirectUrlNoHistory__c> redirectUrlNoHistoryList = [
			SELECT Id
			FROM RedirectUrlNoHistory__c
			WHERE Name = :condName
		];

		if (redirectUrlNoHistoryList.isEmpty()) {
			return new RedirectUrlNoHistory__c();
		}

		return redirectUrlNoHistoryList[0];
	}

	/**
	 * 古いリダイレクトURLパラメータの削除
	 * @param DateTime condCreatedDate 作成日 
	 */
	private static void delOldRedirectUrlParameter(DateTime condCreatedDate) {

		List<RedirectUrlParameter__c> redirectUrlParameterList = [
			SELECT
				Id
			FROM RedirectUrlParameter__c
			WHERE
				CreatedDate < :condCreatedDate
		];

		SecureDML.secureDelete(redirectUrlParameterList);
	}

	/**
	 * 文字列置換用対応の取得
	 * @param Id condCorrespondId 対応ID
	 * @return Correspond__c 対応
	 */
	private static Correspond__c selectReplaceTextCorrespond(Id condCorrespondId) {

		List<Correspond__c> correspondList = [
			SELECT
				Id
				, AccountId__c
				, AccountId__r.Name
				, EchoStaff__c
				, ShopStaff__c
				, EchoShop__c
				, VisitShop__c
                , EchoStaffName__c
				, ShopStaffName__c
				, LineMember__r.Name
			FROM Correspond__c
			WHERE Id = :condCorrespondId
		];

		if (correspondList.isEmpty()) {
			return new Correspond__c();
		}

		return correspondList[0];
	}

	/**
	 * 文字列置換用店舗の取得
	 * @param Id condShopId 店舗ID
	 * @return Shop__c 店舗
	 */
	private static Shop__c selectReplaceTextShop(Id condShopId) {

		List<Shop__c> shopList = [
			SELECT
				Name
				, PostalCode__c
				, City__c
				, Street__c
				, Phone__c
				, Fax__c
				, BusinessHours__c
				, RegularHoliday__c
				, Homepage__c
			FROM Shop__c
			WHERE Id = :condShopId
		];

		if (shopList.isEmpty()) {
			return new Shop__c();
		}

		return shopList[0];
	}

	/**
	 * 文字列置換用対応明細の取得
	 * @param Id condCorrespondId 対応ID
	 * @return CorrespondDetail__c 対応明細
	 */
	private static CorrespondDetail__c selectReplaceTextCorrespondDetail(Id condCorrespondId) {

		List<CorrespondDetail__c> correspondDetailList = [
			SELECT EchoMail__c
			FROM CorrespondDetail__c
			WHERE
				Corresponds__c = :condCorrespondId
				AND CorrespondType__c = :CommonConst.TASK_CORRESPONDTYPE_MAIL
				AND MailType__c = :CommonConst.CORRESPONDDETAIL_MAILTYPE_RECEIVE
				AND (Not EchoMail__r.FromEmail__c like 'mailer-daemon%')
			ORDER BY SupportedDateTime__c DESC
			LIMIT 1
		];

		if (correspondDetailList.isEmpty()) {
			return new CorrespondDetail__c();
		}

		return correspondDetailList[0];
	}

	/**
	 * 文字列置換用反響メールの取得
	 * @param Id condEchoMailId 反響メールID
	 * @return EchoMail__c 反響メール
	 */
	private static EchoMail__c selectReplaceTextEchoMail(Id condEchoMailId) {

		List<EchoMail__c> echoMailList = [
			SELECT
				PropertyName__c
				, PropertyAddress__c
				, ClosestStation__c
				, WalkTime__c
                , RentFee__c
				, RoomLayout__c
				, PropertyCode__c
                , PropertURL__c
			FROM EchoMail__c
			WHERE Id = :condEchoMailId
		];

		if (echoMailList.isEmpty()) {
			return new EchoMail__c();
		}

		return echoMailList[0];
	}

	/**
	 * LINE会員の取得
	 * @param String condLineId LINE ID
	 * @return LineMember__c LINE会員
	 */
	private static LineMember__c selectLineMember(String condLineId) {

		List<LineMember__c> lineMemberList = [
			SELECT
				Id
				, Account__c
				, Account__r.FirstName__c
				, Account__r.FirstNameKana__c
				, Account__r.LastName__c
				, Account__r.LastNameKana__c
				, Account__r.Email__c
				, Account__r.Phone
			FROM LineMember__c
			WHERE LineId__c = :condLineId
		];

		if (lineMemberList.isEmpty()) {
			return new LineMember__c();
		}

		return lineMemberList[0];
	}
	// ▲ 2021.12.27

    //***************************************************************内部クラス************************************************************

    //メール送信用の内部クラス(全て値を入れてくれていることを前提とする)
    public class MailData{
        public List<String> toAddress;   //宛先先アドレス　リスト
        public List<String> ccAddress;   //ccアドレス　　　リスト
        public String fromAddress;       //送信元アドレス(店舗のメールアドレスと一致している必要あり)
        public String subject;           //件名
        public String textBody;          //本文
        public List<Messaging.EmailFileAttachment> mailAttachment; //添付ファイル　リスト(Blob値とコンテンツタイプは指定してあること)
        public String inReplyTo;         //In-Reply-To（返信元となるメールの MessageId）
        public String references;        //メールスレッド（返信元となるメールの References＋MessageId）
		// ▼ 2021.12.27 LINE連携対応より、"本文(HTML)"、"LINE紹介フラグ"を追加
		public String htmlBody;
		public Boolean isLineIntroduction;
		// ▲ 2021.12.27

        //コンストラクタ
        public MailData(){
            this.toAddress = new List<String>();
            this.ccAddress = new List<String>();
            this.fromAddress = '';
            this.subject = '';
            this.textBody = '';
            this.mailAttachment = new List<Messaging.EmailFileAttachment>();
            this.inReplyTo = '';
            this.references = '';
			// ▼ 2021.12.27 LINE連携対応より、"本文(HTML)"、"LINE紹介フラグ"を追加
			this.htmlBody = CommonConst.STRING_EMPTY;
			this.isLineIntroduction = false;
			// ▲ 2021.12.27
        }
    }

}