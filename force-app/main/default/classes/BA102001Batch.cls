//時間指定メール送信バッチ
//
global with sharing class BA102001Batch implements Database.Batchable<sObject>, Database.Stateful
{
	//エラー通知メールのMap（送信者、メール本文）←Statefulで使えるのは簡単な構造のみ。メール自体は渡せなかったので、本文を渡している。
	global Map<String, String> errorMailMap;

	private HtmlMailTemplate__c htmlMailTemplate; // 2021.12.3 LINE連携対応より、メールテンプレート(HTML用)を追加
	private textMailTemplate__c textMailTemplate; // 2022.2.2 LINE連携対応より、メールテンプレート(テキスト用)を追加
	
	//コンストラクタ
	global BA102001Batch(){
		// ▼ 2021.12.3 LINE連携対応より、メールテンプレート(HTML用)の取得処理を修正
		this.htmlMailTemplate = MailUtil.selectHtmlMailTemplate(
			SystemConfig__c.getInstance().LineIntroductionMailTemplateName__c
		);
		// ▲ 2021.12.3

		// ▼ 2021.2.2 LINE連携対応より、メールテンプレート(テキスト用)の取得処理を修正
		this.textMailTemplate = MailUtil.selectTextMailTemplate(
			SystemConfig__c.getInstance().LineIntroductionMailTemplateName__c
		);
		// ▲ 2021.2.2
	}
	
	//データ取得
	global Database.QueryLocator start(Database.BatchableContext BC){
		
		//初期設定
		errorMailMap = new Map<String, String>();
		
		//クエリ作成
		DateTime nowTime = CommonUtil.getNow();
		
		String soql = '';
		soql += 'SELECT From__c';
		soql += ', To__c';
		soql += ', Cc__c';
		soql += ', Bcc__c';
		soql += ', Subject__c';
		soql += ', Body__c';
		soql += ', Shop__c';
		soql += ', Account__c';
		// ▼ 2021.12.3 LINE連携対応より、取引先.メール、LINE紹介フラグを追加
		soql += ', Account__r.Email__c';
		soql += ', IsLineIntroduction__c';
		// ▲ 2021.12.3
		soql += ', Correspond__c';
		soql += ', Correspond__r.Status__c';
		soql += ', Correspond__r.AccountId__r.RecordType.DeveloperName';
		soql += ', IsReply__c';
		soql += ', CorrespondDetail__r.EchoMail__r.MessageId__c';
		soql += ', CorrespondDetail__r.EchoMail__r.References__c';
		soql += ', CreatedById ';						//2020/6/30追加：作成者Id
		soql += ', Correspond__r.StatusBeforePursuitHold__c '; //2020/7/13追加：保留前ステータス（以下項目送信時の対応更新メソッドでレコードを使用）
		soql += ', Correspond__r.AppointmentStartDate__c ';	//アポイント開始日0時
		soql += ', Correspond__r.PursuitDissolveDate__c ';	 //追客解除設定日時（保存用）
		soql += ', Correspond__r.ShopStaff__c ';				 //来店担当者
		soql += ', Correspond__r.EchoStaff__c ';				 //反響担当者
		soql += ', Correspond__r.AccountId__r.Id ';			//取引先.Id
		soql += ', Correspond__r.AccountId__r.RecordTypeId ';	//取引先.レコードタイプId
		soql += ' FROM MailTimeSpecificationSending__c';
		soql += ' WHERE SendingDateTime__c <= :nowTime'; //送信予定時間が、現在時間 以前のデータに限る
		
		return Database.getQueryLocator(soql);
	}
	
	//開始
	global void execute(Database.BatchableContext BC, List<MailTimeSpecificationSending__c> targetList){
		
		//ファイル取得→Mapに格納
		Map<Id, List<Attachment>> attachmentMap = getAttachmentMap(targetList);
		
		//メール送信用のリストを作成
		List<MailUtil.MailData> mailList = new List<MailUtil.MailData>();
		for (MailTimeSpecificationSending__c targetData: targetList) {
			
			MailUtil.MailData mailData = new MailUtil.MailData();
			mailData.toAddress		= String.isBlank(targetData.To__c) ? null : targetData.To__c.split(';');
			mailData.ccAddress		= String.isBlank(targetData.Cc__c) ? null : targetData.Cc__c.split(';');
			mailData.fromAddress	= targetData.From__c;
			mailData.subject		= targetData.Subject__c;
			mailData.textBody		= targetData.Body__c;
			if (targetData.IsReply__c == true) {
				mailData.inReplyTo		= targetData.CorrespondDetail__r.EchoMail__r.MessageId__c;
				mailData.references	 = String.isBlank(targetData.CorrespondDetail__r.EchoMail__r.References__c) ? '' : targetData.CorrespondDetail__r.EchoMail__r.References__c;
				mailData.references	+= String.isBlank(targetData.CorrespondDetail__r.EchoMail__r.MessageId__c ) ? '' : targetData.CorrespondDetail__r.EchoMail__r.MessageId__c;
			}
			// ▼ 2021.12.3 LINE連携対応より、HTML本文の取得処理を追加
			mailData.htmlBody = this.getHtmlMailBody(targetData, mailData, this.htmlMailTemplate);
			// ▲ 2021.12.3

			// ▼ 2022.2.2 LINE連携より、メールテンプレート（テキスト用）の追加
			mailData.textBody = this.getTextMailBody(this.textMailTemplate, targetData, mailData);
			// ▼ 2022.2.2

			//ファイルのリストからメール添付ファイルのリストを設定する
			mailData.mailAttachment = getMailAttachmentList(attachmentMap.get(targetData.Id));
			mailList.add(mailData);
		}

		// ▼ 2021.12.3 LINE連携対応より、HTMLメールの送信に修正
		//メールを一括で送信し、結果を返却
		List<Messaging.SendEmailResult> resultList = MailUtil.sendHtmlMail(mailList);
		// ▲ 2021.12.3
		
		//結果の保存先
		List<Correspond__c> updateCorrespondList			 = new List<Correspond__c>();					 //更新する対応リスト
		List<CorrespondDetail__c> insertCorrespondDetailList = new List<CorrespondDetail__c>();			 //登録する対応明細のリスト
		List<MailTimeSpecificationSending__c> deleteList	 = new List<MailTimeSpecificationSending__c>(); //成功した削除予定のリスト
		Map<Id, CorrespondDetail__c> correspondDetailMap = new Map<Id, CorrespondDetail__c>();				//時間指定と対応明細を紐づけるマップ（キー:時間指定id）


		//結果を調べる
		for (Integer index = 0; index < resultList.size(); index++) {
			
			//成功の場合
			if (resultList[index].isSuccess()) {
				addCorrespondList(updateCorrespondList, targetList[index]);			 //更新する対応を追加
				addCorrespondDetailList(insertCorrespondDetailList, targetList[index], attachmentMap, correspondDetailMap ); //更新する対応明細を追加
				deleteList.add(targetList[index]); //成功した削除予定のリスト
				
			//失敗の場合
			} else {
				
				//From__cが空ならエラーメールの通知先がないので、何も行わない。
				if (String.isBlank(targetList[index].From__c)) {
					continue;
				}
				
				//Mapに無ければ追加
				if (!errorMailMap.containsKey(targetList[index].From__c)) {
					errorMailMap.put(targetList[index].From__c, '');
				}
				
				//本文を追加
				String errorMailString = errorMailMap.get(targetList[index].From__c);
				errorMailString += '-----以下のメール送信に失敗しました-----\n';
				errorMailString += 'to:'	 + convertToBlank(targetList[index].To__c)		 + '\n';
				errorMailString += 'cc:'	 + convertToBlank(targetList[index].Cc__c)		 + '\n';
				errorMailString += 'from:'	 + convertToBlank(targetList[index].From__c)	 + '\n';
				errorMailString += 'subject:'+ convertToBlank(targetList[index].Subject__c)	 + '\n';
				errorMailString += 'body:'   + convertToBlank(targetList[index].Body__c)	 + '\n\n';
				errorMailMap.put(targetList[index].From__c, errorMailString);

			}
		}
		
		//成功したデータの対応を更新
		if (!updateCorrespondList.isEmpty()) {
			SecureDML.secureUpdate(updateCorrespondList);
		}
		
		//成功したデータを参照先に持つ対応明細を更新
		if (!insertCorrespondDetailList.isEmpty()) {
			SecureDML.secureInsert(insertCorrespondDetailList);
			List<Attachment> attachmentList = setAttachmentList(attachmentMap, correspondDetailMap);
			if(!attachmentList.isEmpty()){
				SecureDML.secureInsert(attachmentList);
			}
		}
		
		//成功したデータのみ削除
		if (!deleteList.isEmpty()) {
			SecureDML.secureDelete(deleteList);
		}
		
		
	}
	
	//完了
	global void finish(Database.BatchableContext BC)
	{
		//失敗通知メール送信
		sendErrorMail();
	}
	
	
	
	//******************************************************privateメソッド*******************************************************

	
	//nullならblankにする
	private String convertToBlank(String s) {
		return s == null ? '' : s;
	}
	
	
	//ファイルのマップ返却(キー：メール送信保留レコードId)
	private Map<Id, List<Attachment>> getAttachmentMap(List<MailTimeSpecificationSending__c> targetList) {
		//SELECT対象を作成
		List<Id> idList = new List<Id>();
		for (MailTimeSpecificationSending__c m: targetList) {
			idList.add(m.Id);
		}
		
		//SELECT実行
		List<Attachment> attachmentList = [SELECT ParentId, Name, Body, ContentType FROM Attachment WHERE ParentId IN :idList];
		
		//Map作成
		Map<Id, List<Attachment>> retMap = new Map<Id, List<Attachment>>();
		for (Attachment a: attachmentList) {
			//マップが空なら、Listを作成
			if (!retMap.containsKey(a.ParentId)) {
				retMap.put(a.ParentId, new List<Attachment>());
			}
			//マップのリストにファイルを追加
			retMap.get(a.ParentId).add(a);
		}
		
		return retMap;
	}
	
	
	//ファイルのリストを元に、添付ファイルのリスト作成
	private List<Messaging.EmailFileAttachment> getMailAttachmentList(List<Attachment> attachmentList) {
		//null対応
		if (attachmentList == null) {
			return null;
		}
		List<Messaging.EmailFileAttachment> retList = new List<Messaging.EmailFileAttachment> ();
		
		for (Attachment attachmentData: attachmentList) {
			Messaging.EmailFileAttachment retData = new Messaging.EmailFileAttachment();
			retData.setFileName(attachmentData.Name);
			retData.setBody(attachmentData.Body);
			retData.setContentType(attachmentData.ContentType);
			retList.add(retData);
		}
		
		return retList;
	}
	
	
	//対応を追加
	private void addCorrespondList(List<Correspond__c> updateCorrespondList, MailTimeSpecificationSending__c target) {
			 
		
		//null対応
		if (target.Correspond__c == null) {
			return;
		}

		Correspond__c addCorrespond = new Correspond__c();
		//2020/7/13追加：ステータス・一覧表示日時以外の変更　（引数1：対応、時間指定メール送信レコード作成者Id）
		addCorrespond = MailUtil.setCorrespondSendMail(target.Correspond__r, target.CreatedById); 
		//2020/7/13追加：ステータスの変更 （引数1：ステータス、引数2：追客保留前ステータス,引数3：レコードタイプId）
		addCorrespond.Status__c = CustomerUtil.changeSpecificStatus(target.Correspond__r.Status__c, target.Correspond__r.StatusBeforePursuitHold__c, target.Correspond__r.AccountId__r.RecordTypeId); 
		//2020/7/13変更：対応確認を兼ねた一覧表示日時取得　（引数1：更新後ステータス、引数2：対応）
		addCorrespond.ListViewDate__c = CustomerUtil.setListViewDateWhenCorrespondCheck(addCorrespond.Status__c, target.Correspond__r);

		
		//同対応Idがあるか調べる
		Boolean isAdd = true;
		for (Correspond__c data: updateCorrespondList) {
			if (data.Id == addCorrespond.Id) {
				isAdd = false;
				break;
			}
		}
		
		//追加
		if (isAdd) {
			updateCorrespondList.add(addCorrespond);
		}
	   
	}
	
	
	//対応明細を追加
	private void addCorrespondDetailList(List<CorrespondDetail__c> insertCorrespondDetailList, MailTimeSpecificationSending__c target, Map<Id, List<Attachment>> attachmentMap, Map<Id, CorrespondDetail__c> correspondDetailMap) {
		
		//null対応
		if (target.Correspond__c == null) {
			return;
		}
		
		DateTime now = CommonUtil.getNow();
		
		//対応内容作成
		String correspondContents = createCorrespondContents(target); 

		//追加するレコードを作成
		CorrespondDetail__c addCorrespondDetail = new CorrespondDetail__c(
			  SupportedDateTime__c	= now				  //対応日時
			, SupportedTitle__c		= CommonUtil.subStringLeft(target.Subject__c, 255)   // 対応表題
			, SupportedContent__c	= correspondContents   //対応内容
			, Shop__c				= target.Shop__c	   //店舗
			, Corresponds__c		= target.Correspond__c //対応番号
			, MailType__c			= CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND   // メール種別
			, Email__c				= target.From__c	   //メール
			, CorrespondType__c		= CommonConst.TASK_CORRESPONDTYPE_MAIL		 // 対応種別
			, Staff__c				= target.CreatedById   //2020/6/30追加：担当者
		);
		// 新規追加
		insertCorrespondDetailList.add(addCorrespondDetail);
		correspondDetailMap.put(target.Id,addCorrespondDetail);
	}



	//対応内容に宛先、cc、本文追加
	private String createCorrespondContents(MailTimeSpecificationSending__c target){
		String correspondContents; 
		correspondContents = 'TO:' + target.To__c.replace(';','、');

		if(target.Cc__c != null){
			correspondContents += '\n' + 'CC:' + target.Cc__c.replace(';','、');
		}
		if(target.Body__c != null){
			correspondContents		+= '\n\n' + target.Body__c;
		}
		return correspondContents;
	}





	//添付ファイルを追加
	private List<Attachment> setAttachmentList(Map<Id, List<Attachment>> attachmentMap, Map<Id, CorrespondDetail__c> correspondDetailMap){

		//newAttachmentListを作成 
		List<Attachment> newAttachmentList =  new  List<Attachment>();

		//時間指定送信セットのidを取りだし回す
		for(Id id : attachmentMap.KeySet()){
			//attachmentMapの時間指定メールのidから値を取り出しattachmentListに入れる
			List<Attachment> attachmentList = attachmentMap.get(id);

			//attachmentリストが空、または、corrspondDetailMapに値を含まない なら次へ
			if(attachmentList.isEmpty() || !correspondDetailMap.containsKey(id)){
			continue;
			} 

			//attachmentリストからattachment（添付）を取り出し回す
			for(Attachment attachment : attachmentList){
				//attachmentをコピーし、newAttachmentDataを作成
				Attachment newAttachmentData = attachment.clone(false);
				//時間指定送信のidから対応明細を取り出し、その対応明細のidをparentIdに紐づける
				newAttachmentData.parentId = correspondDetailMap.get(id).id;
				//newAttachmentDataをnewAttachmentListに追加する
				newAttachmentList.add(newAttachmentData);
			}
		} 
		return newAttachmentList;
	}  

	//エラーメールの一括送信
	private void sendErrorMail() {
		
		//エラーメールを作成
		List<MailUtil.MailData> errorMailList = new List<MailUtil.MailData>();
		
		//本文からメール自体を作成
		for (String sKey : errorMailMap.keySet()) {
			MailUtil.MailData errorMail = new MailUtil.MailData();
			errorMail.toAddress   = new List<String>{ sKey }; //送信者に対してメールを送信する
			errorMail.fromAddress = null;					 //fromを設定しないことで、組織のメールアドレスが使われなく、代表者の送信となる
			errorMail.subject	 = '時間指定メール送信エラー';
			errorMail.textBody	= errorMailMap.get(sKey);
			errorMailList.add(errorMail);
		}
		
		//エラーメールの送信
		MailUtil.sendMail(errorMailList);
	}

	// 2021.12.3 LINE連携対応より、追加
	/**
	 * HTMLメールのBODY句の取得
	 * @param MailTimeSpecificationSending__c	mtss				メール時間指定送信
	 * @param MailUtil.MailData					mailData			メール送信用
	 * @param HtmlMailTemplate__c				htmlMailTemplate	メールテンプレート(HTML用)
	 * @return String HTMLメールのBODY句
	 */
	private String getHtmlMailBody(
		MailTimeSpecificationSending__c mtss
		, MailUtil.MailData mailData
		, HtmlMailTemplate__c htmlMailTemplate
	) {

		// 取引先の作成
		Account account = new Account(
			Id			= mtss.account__c
			, Email__C	= mtss.account__r.Email__c
		);

		// HTMLメールのBODY句の取得
		String htmlMailBody = MailUtil.getMailBody(
			mtss.IsLineIntroduction__c ? htmlMailTemplate: new HtmlMailTemplate__c()
			, mailData
			, account
			, true
		);

		return htmlMailBody;
	}
	// 2021.12.3

	// ▼ 2022.2.2 LINE連携より、メールテンプレート（テキスト用）の修正
	/**
	 * HTMLメールのBODY句の取得
	 * @param TextMailTemplate__c				textMailTemplate	メールテンプレート(テキスト用)
	 * @param MailTimeSpecificationSending__c	mtss				メール時間指定送信
	 * @param MailUtil.MailData					mailData			メール送信用
	 * @return String テキストメールのBODY句
	 */
	private String getTextMailBody(
		TextMailTemplate__c textMailTemplate
		, MailTimeSpecificationSending__c mtss
		, MailUtil.MailData mailData
	) {

		// 取引先の作成
		Account account = new Account(
			Id			=	mtss.account__c
			, Email__C	=	mtss.account__r.Email__c
		);

		// テキストメールのBODY句の取得
		String textMailBody = MailUtil.getMailBody(
			mtss.IsLineIntroduction__c ? textMailTemplate: new TextMailTemplate__c()
			, mailData
			, account
			, false
		);

		return textMailBody;
	}
	// ▲ 2022.2.2
}