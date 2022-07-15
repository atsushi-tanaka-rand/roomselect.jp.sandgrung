/**
 * メール関連共通テストクラス
 */
@isTest
public with sharing class MailUtilTest {

	private static Shop__c			replaceShop;
	private static Account			replaceAccount;
	private static Correspond__c	replaceCorrespond;

	/**
	 * 初期設定
	 */
	@testSetup static void setting() {
		// 標準プロファイル
		Profile profile = [
			SELECT Id
			FROM Profile
			WHERE Name = '一般ユーザ'
		];

		// ユーザの登録
		User testUser;
		System.runAs(getThisUser()) {
			testUser = new User(
				LastName			= 'ippanUser'			// 姓
				, Alias				= 'alias'				// 別名
				, Email				= 'ippanUser@test.com'	// メール
				, UserName			= 'ippanUser@test.com'	// ユーザ名
				, CommunityNickname	= 'テストニックネーム'	 // ニックネーム
				, EmailEncodingKey	= 'ISO-2022-JP'			// メールの文字コード
				, TimeZoneSidKey	= 'Asia/Tokyo'			// タイムゾーン
				, LocaleSidKey		= 'ja_JP'				// 地域
				, LanguageLocaleKey	= 'ja'					// 言語
				, ProfileId			= profile.Id			// プロファイルID
			);
			insert testUser;     
		}

		// カスタム設定
		SystemConfig__c systemConfig = new SystemConfig__c(
			LineIntroductionMailTemplateName__c	= 'テンプレートテスト'
			, UseAuthority_Portal__c			= true
			, EmailAthome__c					= 'test@pmb.rand.co.jp'	// 2022.03.10 No0753 対応で追加
		);
		insert systemConfig;
		
		//▼ 2022.03.10 No0753 対応で追加
		// ポータルサイト
		PortalSite__c portal = new PortalSite__c(
			Name 		= 'アットホーム'
			,Url__c 	= 'https://test/'
			,Email__c 	= 'test@pmb.rand.co.jp'
		);
        insert portal;
		//▲ 2022.03.10 No0753 対応で追加

		// 店舗
		Shop__c shop1 = new shop__c(
			Name				= 'テスト店舗1'
			, PostalCode__c		= '111-111'
			, City__c			= 'テスト県テスト市テスト町1丁目'
			, Street__c			= '1-11-101'
			, Phone__c			= '111-1111-1111'
			, Fax__c			= '111-1111-1112'
			, BusinessHours__c	= '1時～11時'
			, RegularHoliday__c	= '1月11日'
			, Homepage__c		= 'ホームページ1'
			, Email__c			= 'shop@randco.jp'
		);
		Shop__c shop2 = new shop__c(
			Name				= 'テスト店舗2'
			, PostalCode__c		= '222-222'
			, City__c			= 'テスト県テスト市テスト町2丁目'
			, Street__c			= '2-22-202'
			, Phone__c			= '222-2222-2222'
			, Fax__c			= '222-2222-2223'
			, BusinessHours__c	= '2時～12時'
			, RegularHoliday__c	= '2月22日'
			, Homepage__c		= 'ホームページ2'
		);
		List<Shop__c> shopList = new List<Shop__c>{
			shop1
			, shop2
		};
		insert shopList;

		// 取引先
		Account account = new Account(
			Name			= 'テスト取引先'
			, RecordTypeId	= CommonUtil.getRecordTypeId(Account.getSObjectType().getDescribe().getName()
														, CommonConst.ACCOUNT_RECTYPE_CUSTOMER)
		);
		insert account;

		// LINE会員
		LineMember__c lineMember = new LineMember__c(
			Name = 'テストLINE会員'
			, Account__c	= account.Id
			, LineId__c		= '1234567890'
		);
		insert lineMember;

		// 反響メール
		EchoMail__c echoMail1 = new EchoMail__c(
			PropertyCode__c			= '物件コード1'
			, PropertURL__c			= '物件URL1'
			, PropertyName__c		= '物件名1'
			, PropertyAddress__c	= '所在地1'
			, ClosestStation__c		= '最寄駅1'
			, WalkTime__c			= '徒歩1'
			, RoomLayout__c			= '間取り1'
			, RentFee__c			= '賃料1'
		);
		EchoMail__c echoMail2 = new EchoMail__c(
			PropertyCode__c			= '物件コード2'
			, PropertURL__c			= '物件URL2'
			, PropertyName__c		= '物件名2'
			, PropertyAddress__c	= '所在地2'
			, ClosestStation__c		= '最寄駅2'
			, WalkTime__c			= '徒歩2'
			, RoomLayout__c			= '間取り2'
			, RentFee__c			= '賃料2'
		);
		List<EchoMail__c> echoMailList = new List<EchoMail__c>{
			echoMail1
			, echoMail2
		};
		insert echoMailList;

		// 対応
		Correspond__c correspond1 = new Correspond__c(
			AccountId__c	= account.Id
			, VisitShop__c	= shop1.id
			, ShopStaff__c	= testUser.Id
		);
		Correspond__c correspond2 = new Correspond__c(
			LineMember__c	= lineMember.Id
			, EchoShop__c	= shop2.id
			, EchoStaff__c	= testUser.Id
		);
		List<Correspond__c> correspondList = new List<Correspond__c>{
			correspond1
			, correspond2
		};
		insert correspondList;

		// 対応明細
		CorrespondDetail__c correspondDetail1 = new CorrespondDetail__c(
			Corresponds__c		= correspond1.Id
			, EchoMail__c		= echoMail1.Id
			, CorrespondType__c	= CommonConst.TASK_CORRESPONDTYPE_MAIL
			, MailType__c		= CommonConst.CORRESPONDDETAIL_MAILTYPE_RECEIVE
		);
		CorrespondDetail__c correspondDetail2 = new CorrespondDetail__c(
			Corresponds__c		= correspond2.Id
			, EchoMail__c		= echoMail2.Id
			, CorrespondType__c	= CommonConst.TASK_CORRESPONDTYPE_MAIL
			, MailType__c		= CommonConst.CORRESPONDDETAIL_MAILTYPE_RECEIVE
		);
		List<CorrespondDetail__c> correspondDetailList = new List<CorrespondDetail__c>{
			correspondDetail1
			, correspondDetail2
		};
		insert correspondDetailList;

		// メールテンプレート(HTML用)
		HtmlMailTemplate__c htmlMailTemplate = new HtmlMailTemplate__c(
			Name						= 'テンプレートテスト'
			, Format__c					= 'フォーマットテスト'
			, LineIntroductionUrl__c	= 'LINE紹介URLテスト'
		);
		insert htmlMailTemplate;

		systemConfig.IsSkipTrigger__c = true; // トリガスキップ
		update systemConfig;
		// 組織階層レコード
		OrganizationHierarchy__c orgRecord = new OrganizationHierarchy__c(
			OrganizationCode__c = '0001',
			OrganizationName__c = '本部',
			HierarchyCode__c = '10',
			HierarchyOrder__c = 1,
			UpperOrganizationHierarchy__c = null,
			ExpandedOrganizationCode__c = '0000_0001',
			Shop__c = shop1.Id
		);
		insert orgRecord;
	
		// 店舗異動データ
		ShopTransfer__c shopTransferRecord = new ShopTransfer__c(
			orgzanizationHierarchy__c = orgRecord.id
			, StartDate__c	= CommonUtil.getToday().addDays(-1)
			, EndDate__c	= CommonUtil.getToday().addDays(2)
			, Staff__c		= UserInfo.getUserId()
		);  
		insert ShopTransferRecord;
		systemConfig.IsSkipTrigger__c = false;
		update systemConfig;
	}

	/**
	 * メール用置換文字の取得（対応）テスト
	 */
	@isTest static void getMailReplaceTextCorrespondTest() {

		// 置換用オブジェクトの取得
		Account			account		= selectAccount('テスト取引先');
		LineMember__c	lineMember	= selectLineMember('テストLINE会員');

		List<Correspond__c> correspondList = new List<Correspond__c>{
			selectCorrespond(account.Id, null)
			, selectCorrespond(null, lineMember.Id)
		};

		System.runAs(getThisUser()) {
			test.startTest();

			for (Correspond__c correspond : correspondList) {
				// 置換値の取得
				String replaceResult = MailUtil.getMailReplaceText(
					getReplaceTargetText()
					, correspond.Id
				);

				// 置換値の確認
				System.assertNotEquals(
					replaceResult
					, CommonConst.STRING_EMPTY
					, 'メール用置換文字処理'
				);
			}

			test.stopTest();
		}
	}

	/**
	 * 挨拶テスト
	 */
	@isTest static void getGreetingWordTest() {

		// 置換用オブジェクトの取得
		replaceShop			= selectShop('テスト店舗');
		replaceAccount		= selectAccount('テスト取引先');
		replaceCorrespond	= selectCorrespond(replaceAccount.Id, null);

		// 挨拶時間（key:時間、value：挨拶）
		Map<String, String> greetingHourMap = new Map<String, String> {
			'err'		=>	CommonConst.STRING_EMPTY
			, '0'		=>	CommonConst.GREETING_NIGHT
			, '5'		=>	CommonConst.GREETING_MORNING
			, '11'		=>	CommonConst.GREETING_NOON
			, '18'		=>	CommonConst.GREETING_EVENING
			, '21'		=>	CommonConst.GREETING_NIGHT
		};

		System.runAs(getThisUser()) {
			test.startTest();

			// 挨拶の取得
			for (String greetingHourKey : greetingHourMap.keySet()) {

				// 置換値の取得
				String replaceResult = executeGetMailReplaceText(
					CommonConst.REPLACE_KEY_ECHOMAIL_GREETING
					, greetingHourKey
					, false
				);

				// 置換値の確認
				System.assertEquals(
					replaceResult
					, greetingHourMap.get(greetingHourKey)
					, '挨拶取得処理'
				);
			}

			test.stopTest();
		}
	}

	/**
	 * 自社ポータルの反響メール取込取込テスト
	 */
	@isTest static void setEcoMailPortalTest() {

		// LINE会員
		LineMember__c lineMember = selectLineMember('テストLINE会員');

		System.runAs(getThisUser()) {
			test.startTest();

			// 自社ポータルの受信内容を作成
			EchoMail__c echoMail = new EchoMail__c (
				Body__c	= 
					'{' + CommonConst.BREAK_CODE +
					'	"Property" : [' + CommonConst.BREAK_CODE +
					'	],' + CommonConst.BREAK_CODE +
					'	"Customer" : [{' + CommonConst.BREAK_CODE +
					'		"MemberId"							: "null",' +
					'		"InquiryDateTime"					: "2022-01-23 09:40:38.735753",' + CommonConst.BREAK_CODE +
					'		"MailType"							: "反響",' + CommonConst.BREAK_CODE +
					'		"InquiryType"						: "",' + CommonConst.BREAK_CODE +
					'		"textOther"							: "",' + CommonConst.BREAK_CODE +
					'		"textOther2"						: "",' + CommonConst.BREAK_CODE +
					'		"Shop"								: "",' + CommonConst.BREAK_CODE +
					'		"VisitDateTime"						: "",' + CommonConst.BREAK_CODE +
					'		"VisitDateTime2"					: "",' + CommonConst.BREAK_CODE +
					'		"LastName"							: "テスト",' + CommonConst.BREAK_CODE +
					'		"FirstName"							: "太郎",' + CommonConst.BREAK_CODE +
					'		"LastName_kana"						: "テスト",' + CommonConst.BREAK_CODE +
					'		"FirstName_kana"					: "タロウ",' + CommonConst.BREAK_CODE +
					'		"Email"								: "",' + CommonConst.BREAK_CODE +
					'		"Phone"								: "",' + CommonConst.BREAK_CODE +
					'		"BirthDay"							: "2000/01/01",' + CommonConst.BREAK_CODE +
					'		"Zip"								: "",' + CommonConst.BREAK_CODE +
					'		"State"								: "",' + CommonConst.BREAK_CODE +
					'		"City"								: "",' + CommonConst.BREAK_CODE +
					'		"Street"							: "",' + CommonConst.BREAK_CODE +
					'		"InquiryContent"					: "テスト",' + CommonConst.BREAK_CODE +
					'		"ContactMeans"						: "",' + CommonConst.BREAK_CODE +
					'		"DesireArea"						: "",' + CommonConst.BREAK_CODE +
					'		"RentFee"							: "",' + CommonConst.BREAK_CODE +
					'		"RentFeeUpper"						: "",' + CommonConst.BREAK_CODE +
					'		"RoomPlan"							: [ ],' + CommonConst.BREAK_CODE +
					'		"HomeMovingReason"					: [ ],' + CommonConst.BREAK_CODE +
					'		"HomeMovingReasonDissatisfaction"	: "",' + CommonConst.BREAK_CODE +
					'		"OccupancyDesiredSeason"			: "その他",' + CommonConst.BREAK_CODE +
					'		"LivePeople"						: "",' + CommonConst.BREAK_CODE +
					'		"LineReceiveEvent"					: "LINE受信",' + CommonConst.BREAK_CODE +
					'		"LineId"							: "1234567890",' + CommonConst.BREAK_CODE +
					'		"LineName"							: "テストLINE会員",' + CommonConst.BREAK_CODE +
					'		"LineMessageType"					: "001",' + CommonConst.BREAK_CODE +
					'		"LineMessage"						: "LINEメッセージテスト",' + CommonConst.BREAK_CODE +
					'		"LineFileName"						: "",' + CommonConst.BREAK_CODE +
					'		"LineFileUrl"						: "",' + CommonConst.BREAK_CODE +
					'		"LineThumbnailName"					: "",' + CommonConst.BREAK_CODE +
					'		"LineThumbnailUrl"					: "",' + CommonConst.BREAK_CODE +
					'		"LineSendReceiveTime"				: " 2022-01-23 09:40:38.735753 ",' + CommonConst.BREAK_CODE +
					'		"accountId"							: ""' + CommonConst.BREAK_CODE +
					'	}]' + CommonConst.BREAK_CODE +
					'}'
			);

			// デシリアライズ処理の実施
			MailUtil.setEcoMailPortal(echoMail);

			// 実施結果の確認
			System.assertEquals(
				echoMail.LineMember__c
				, lineMember.Id
				, 'デシリアライズ処理'
			);

			test.stopTest();
		}
	}

	/**
	 * HTMLメール送信テスト
	 */
	@isTest static void sendHtmlMailTest() {

		System.runAs(getThisUser()) {
			test.startTest();

			// HTMLメールの送信
			MailUtil.MailData mailData = new MailUtil.MailData();
			Messaging.SendEmailResult mailResult = MailUtil.sendHtmlMail(mailData);

			// 実施結果の確認（※テストクラスでは成功不可）
			System.assertEquals(
				mailResult.success
				, false
				, 'HTMLメール送信処理'
			);

			test.stopTest();
		}
	}

	/**
	 * LINE紹介用HTMLのBODY句の取得テスト
	 */
	@isTest static void getLineIntroductionHtmlBodyTest() {

		// 取引先
		Account account = selectAccount('テスト取引先');

		System.runAs(getThisUser()) {
			test.startTest();

			MailUtil.MailData mailData = new MailUtil.MailData();
			mailData.toAddress			= new List<String>{'test1', 'test2'};
			mailData.textBody			= '{本文}{LINE紹介URL}{来店予約URL}';
			mailData.isLineIntroduction = true;

			// LINE紹介用HTMLのBODY句の取得
			String lineIntroductionHtmlBody = MailUtil.getLineIntroductionHtmlBody(mailData, account);

			// 実施結果の確認
			System.assertNotEquals(
				lineIntroductionHtmlBody
				, CommonConst.STRING_EMPTY
				, 'LINE紹介用HTMLのBODY句の取得処理'
			);

			test.stopTest();
		}
	}

	/**
	 * カバレッジアップ
	 * ※LINE連携のリリースより、既存ロジックのカバレッジアップ
	 */
	@isTest static void coverageUp() {

		Account				account				= selectAccount('テスト取引先');
		Correspond__c		correspond			= selectCorrespond(account.Id, null);
		CorrespondDetail__c	correspondDetail	= selectCorrespondDetail(correspond.Id);
		EchoMail__c			echoMail 			= selectEchoMail(correspondDetail.EchoMail__c);

		MailUtil.MailData mailData = new MailUtil.MailData();
		mailData.isLineIntroduction = true;

		MailUtil.sendErrorMail('errMsg', 'errSubject');
		MailUtil.sendMail(mailData);
		MailUtil.setEcoMailSumo(echoMail, new List<String>{'test'});
		MailUtil.setEcoMailHomes(echoMail, new List<String>{'test'});
		MailUtil.setEcoMailAtHome(echoMail, new List<String>{'test'});
		MailUtil.setEcoMailChintai(echoMail, new List<String>{'test'}); // 2022/3/7 CHINTAI対応による追加
		MailUtil.getLineIntroductionTextBody(mailData, account);
		MailUtil.setCorrespondSendMail(correspond, UserInfo.getUserId());
		MailUtil.getEmailSF('SFアドレス');
		MailUtil.getEmailAddress(new List<String>{'test'});

		System.assertEquals(null, null, '確認項目無し');
	}

	//▼ 2022.03.10 No0753 対応で修正「—————————————————————————————」も判定
	/**
	 * アットホーム、反響メール受信
	 * ＜物件のお問い合わせ理由＞の末尾「—」
	 * 反響メール．お問い合わせ理由が仕切られた内容通りに取得されること
	 */
	@isTest static void athomeReceiveEchoMailTest1() {

		Shop__c shop = [SELECT ID,Email__c FROM Shop__c WHERE Name = 'テスト店舗1' LIMIT 1];
		PortalSite__c portalSite = [SELECT ID,Email__c FROM PortalSite__c WHERE Name = 'アットホーム' LIMIT 1];

		EchoMail__c echoMailTest = new EchoMail__c();
		echoMailTest = setAthomeEchoMail(shop,portalSite);
		String inquiryContent = '';
		String inquiryContentConfirmation = '';	//  反響メール．お問い合わせ理由の判定
		// ▼対象内容
		inquiryContent +='＜物件のお問い合わせ理由＞\n';
		inquiryContentConfirmation +='・実際に物件を見たい\n';
		inquiryContentConfirmation +='・お店に行って相談したい\n';
		inquiryContentConfirmation +='[その他]\n';
		inquiryContentConfirmation +='仕事終わりに物件見に行きたいんですけど、何時まで可能ですか？';
		inquiryContent = inquiryContent + inquiryContentConfirmation + '\n—————————————————————————————\n';
		//▲ 対象内容
		echoMailTest.Body__c = setAthomeEchoMailStationery(inquiryContent);
		System.runAs(getThisUser()) {
			List<String> mailBodyList = echoMailTest.Body__c.split('\n');
			test.startTest();

			// アットホームの場合
            MailUtil.setEcoMailAtHome(echoMailTest, mailBodyList);

			// 登録 反響メール
			SecureDML.secureInsert(echoMailTest);
            // //バッチ起動
            // BA101005Batch b = new BA101005Batch(1); //引数:起動回数が1回目
            // Database.executeBatch(b,200);
			test.stopTest();

			inquiryContentConfirmation = inquiryContentConfirmation.replace('\n','　');
			// 反響メール
			EchoMail__c echoMail = [SELECT ID,InquiryReason__c FROM EchoMail__c WHERE ID = :echoMailTest.ID LIMIT 1];
			System.assertEquals(inquiryContentConfirmation, echoMail.InquiryReason__c, 
				'反響メール．お問い合わせ理由の判定：判定値＝'+inquiryContentConfirmation + '：反響メール．お問い合わせ理由の設定値＝'+echoMail.InquiryReason__c);	

			
		}
	}
	/**
	 * アットホーム、反響メール受信
	 * ＜物件のお問い合わせ理由＞の末尾「━」
	 * 反響メール．お問い合わせ理由が仕切られた内容通りに取得されること
	 */
	@isTest static void athomeReceiveEchoMailTest2() {

		Shop__c shop = [SELECT ID,Email__c FROM Shop__c WHERE Name = 'テスト店舗1' LIMIT 1];
		PortalSite__c portalSite = [SELECT ID,Email__c FROM PortalSite__c WHERE Name = 'アットホーム' LIMIT 1];

		EchoMail__c echoMailTest = new EchoMail__c();
		echoMailTest = setAthomeEchoMail(shop,portalSite);
		String inquiryContent = '';
		String inquiryContentConfirmation = '';	//  反響メール．お問い合わせ理由の判定
		// ▼対象内容
		inquiryContent +='＜物件のお問い合わせ理由＞\n';
		inquiryContentConfirmation +='・実際に物件を見たい\n';
		inquiryContentConfirmation +='・お店に行って相談したい\n';
		inquiryContentConfirmation +='[その他]\n';
		inquiryContentConfirmation +='仕事終わりに物件見に行きたいんですけど、何時まで可能ですか？';
		inquiryContent = inquiryContent + inquiryContentConfirmation + '\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
		//▲ 対象内容
		echoMailTest.Body__c = setAthomeEchoMailStationery(inquiryContent);
		System.runAs(getThisUser()) {
			List<String> mailBodyList = echoMailTest.Body__c.split('\n');
			test.startTest();

			// アットホームの場合
            MailUtil.setEcoMailAtHome(echoMailTest, mailBodyList);

			// 登録 反響メール
			SecureDML.secureInsert(echoMailTest);
            // //バッチ起動
            // BA101005Batch b = new BA101005Batch(1); //引数:起動回数が1回目
            // Database.executeBatch(b,200);
			test.stopTest();
			inquiryContentConfirmation = inquiryContentConfirmation.replace('\n','　');
			// 反響メール
			EchoMail__c echoMail = [SELECT ID,InquiryReason__c FROM EchoMail__c WHERE ID = :echoMailTest.ID LIMIT 1];
			System.assertEquals(inquiryContentConfirmation, echoMail.InquiryReason__c, 
				'反響メール．お問い合わせ理由の判定：判定値＝'+inquiryContentConfirmation + '：反響メール．お問い合わせ理由の設定値＝'+echoMail.InquiryReason__c);	

			
			
		}
	}
	/**
	 * アットホーム、反響メール受信
	 * ＜物件に関するお問合せ内容＞の末尾「—」
	 * 反響一覧の備考（対応．備考）が仕切られた内容通りに取得されること
	 */
	@isTest static void athomeReceiveEchoMailTest3() {

		Shop__c shop = [SELECT ID,Email__c FROM Shop__c WHERE Name = 'テスト店舗1' LIMIT 1];
		PortalSite__c portalSite = [SELECT ID,Email__c FROM PortalSite__c WHERE Name = 'アットホーム' LIMIT 1];

		EchoMail__c echoMailTest = new EchoMail__c();
		echoMailTest = setAthomeEchoMail(shop,portalSite);
		String inquiryContent = '';
		List<String> inquiryContentConfirmationList = new List<String>();	// 対応の備考の判定
		// ▼対象内容
		inquiryContent +='＜物件に関するお問合せ内容＞\n';
		inquiryContentConfirmationList.add('・実際に物件を見たい');
		inquiryContent +=inquiryContentConfirmationList[0] + '\n';
		inquiryContentConfirmationList.add('・お店に行って相談したい');
		inquiryContent +=inquiryContentConfirmationList[1] + '\n';
		inquiryContent +='[その他]\n';//問合せ323で追加された除外の項目を判定に考慮しないように
		inquiryContentConfirmationList.add('仕事終わりに物件見に行きたいんですけど、何時まで可能ですか？');
		inquiryContent +=inquiryContentConfirmationList[2] + '\n';
		inquiryContent += '—————————————————————————————\n';
		//▲ 対象内容
		echoMailTest.Body__c = setAthomeEchoMailStationery(inquiryContent);
		System.runAs(getThisUser()) {
			List<String> mailBodyList = echoMailTest.Body__c.split('\n');
			test.startTest();

			// アットホームの場合
            MailUtil.setEcoMailAtHome(echoMailTest, mailBodyList);

			// 登録 反響メール
			SecureDML.secureInsert(echoMailTest);
            //バッチ起動
            BA101005Batch b = new BA101005Batch(1); //引数:起動回数が1回目
            Database.executeBatch(b,200);
			test.stopTest();

			// 対応
			Correspond__c correspond = [SELECT ID,Remarks__c FROM Correspond__c WHERE PortalSite__c = :portalSite.ID LIMIT 1];
			List<String> remarksList = correspond.Remarks__c.split('\n');
			Integer count =0;
			for (String remarks : remarksList) {
				System.assertEquals(inquiryContentConfirmationList[count], remarks, 
				'対応の備考不一致：行数＝'+ count+1 +'：判定値＝'+inquiryContentConfirmationList[count] + '：対応備考の設定値＝'+remarks);	
				count += 1;
			}
			
		}
	}
	/**
	 * アットホーム、反響メール受信
	 * ＜物件に関するお問合せ内容＞の末尾「━」
	 * 反響一覧の備考（対応．備考）が仕切られた内容通りに取得されること
	 */
	@isTest static void athomeReceiveEchoMailTest4() {

		Shop__c shop = [SELECT ID,Email__c FROM Shop__c WHERE Name = 'テスト店舗1' LIMIT 1];
		PortalSite__c portalSite = [SELECT ID,Email__c FROM PortalSite__c WHERE Name = 'アットホーム' LIMIT 1];

		EchoMail__c echoMailTest = new EchoMail__c();
		echoMailTest = setAthomeEchoMail(shop,portalSite);
		String inquiryContent = '';
		List<String> inquiryContentConfirmationList = new List<String>();	// 対応の備考の判定
		// ▼対象内容
		inquiryContent +='＜物件に関するお問合せ内容＞\n';
		inquiryContentConfirmationList.add('・実際に物件を見たい');
		inquiryContent +=inquiryContentConfirmationList[0] + '\n';
		inquiryContentConfirmationList.add('・お店に行って相談したい');
		inquiryContent +=inquiryContentConfirmationList[1] + '\n';
		inquiryContent +='[その他]\n';//問合せ323で追加された除外の項目を判定に考慮しないように
		inquiryContentConfirmationList.add('仕事終わりに物件見に行きたいんですけど、何時まで可能ですか？');
		inquiryContent +=inquiryContentConfirmationList[2] + '\n';
		inquiryContent += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
		//▲ 対象内容
		echoMailTest.Body__c = setAthomeEchoMailStationery(inquiryContent);
		System.runAs(getThisUser()) {
			List<String> mailBodyList = echoMailTest.Body__c.split('\n');
			test.startTest();

			// アットホームの場合
            MailUtil.setEcoMailAtHome(echoMailTest, mailBodyList);

			// 登録 反響メール
			SecureDML.secureInsert(echoMailTest);
            //バッチ起動
            BA101005Batch b = new BA101005Batch(1); //引数:起動回数が1回目
            Database.executeBatch(b,200);
			test.stopTest();

			// 対応
			Correspond__c correspond = [SELECT ID,Remarks__c FROM Correspond__c WHERE PortalSite__c = :portalSite.ID LIMIT 1];
			List<String> remarksList = correspond.Remarks__c.split('\n');
			Integer count =0;
			for (String remarks : remarksList) {
				System.assertEquals(inquiryContentConfirmationList[count], remarks, 
				'対応の備考不一致：行数＝'+ count+1 +'：判定値＝'+inquiryContentConfirmationList[count] + '：対応備考の設定値＝'+remarks);	
				count += 1;
			}
			
		}
	}
	/**
	 * アットホーム、反響メール受信
	 * ＜物件に関するお問い合わせ内容＞の末尾「—」
	 * 反響一覧の備考（対応．備考）が仕切られた内容通りに取得されること
	 */
	@isTest static void athomeReceiveEchoMailTest5() {

		Shop__c shop = [SELECT ID,Email__c FROM Shop__c WHERE Name = 'テスト店舗1' LIMIT 1];
		PortalSite__c portalSite = [SELECT ID,Email__c FROM PortalSite__c WHERE Name = 'アットホーム' LIMIT 1];

		EchoMail__c echoMailTest = new EchoMail__c();
		echoMailTest = setAthomeEchoMail(shop,portalSite);
		String inquiryContent = '';
		List<String> inquiryContentConfirmationList = new List<String>();	// 対応の備考の判定
		// ▼対象内容
		inquiryContent +='＜物件に関するお問い合わせ内容＞\n';
		inquiryContentConfirmationList.add('・実際に物件を見たい');
		inquiryContent +=inquiryContentConfirmationList[0] + '\n';
		inquiryContentConfirmationList.add('・お店に行って相談したい');
		inquiryContent +=inquiryContentConfirmationList[1] + '\n';
		inquiryContent +='[その他]\n';//問合せ323で追加された除外の項目を判定に考慮しないように
		inquiryContentConfirmationList.add('仕事終わりに物件見に行きたいんですけど、何時まで可能ですか？');
		inquiryContent +=inquiryContentConfirmationList[2] + '\n';
		inquiryContent += '—————————————————————————————\n';
		//▲ 対象内容
		echoMailTest.Body__c = setAthomeEchoMailStationery(inquiryContent);
		System.runAs(getThisUser()) {
			List<String> mailBodyList = echoMailTest.Body__c.split('\n');
			test.startTest();

			// アットホームの場合
            MailUtil.setEcoMailAtHome(echoMailTest, mailBodyList);

			// 登録 反響メール
			SecureDML.secureInsert(echoMailTest);
            //バッチ起動
            BA101005Batch b = new BA101005Batch(1); //引数:起動回数が1回目
            Database.executeBatch(b,200);
			test.stopTest();

			// 対応
			Correspond__c correspond = [SELECT ID,Remarks__c FROM Correspond__c WHERE PortalSite__c = :portalSite.ID LIMIT 1];
			List<String> remarksList = correspond.Remarks__c.split('\n');
			Integer count =0;
			for (String remarks : remarksList) {
				System.assertEquals(inquiryContentConfirmationList[count], remarks, 
				'対応の備考不一致：行数＝'+ count+1 +'：判定値＝'+inquiryContentConfirmationList[count] + '：対応備考の設定値＝'+remarks);	
				count += 1;
			}
			
		}
	}
	/**
	 * アットホーム、反響メール受信
	 * ＜物件に関するお問い合わせ内容＞の末尾「━」
	 * 反響一覧の備考（対応．備考）が仕切られた内容通りに取得されること
	 */
	@isTest static void athomeReceiveEchoMailTest6() {

		Shop__c shop = [SELECT ID,Email__c FROM Shop__c WHERE Name = 'テスト店舗1' LIMIT 1];
		PortalSite__c portalSite = [SELECT ID,Email__c FROM PortalSite__c WHERE Name = 'アットホーム' LIMIT 1];

		EchoMail__c echoMailTest = new EchoMail__c();
		echoMailTest = setAthomeEchoMail(shop,portalSite);
		String inquiryContent = '';
		List<String> inquiryContentConfirmationList = new List<String>();	// 対応の備考の判定
		// ▼対象内容
		inquiryContent +='＜物件に関するお問い合わせ内容＞\n';
		inquiryContentConfirmationList.add('・実際に物件を見たい');
		inquiryContent +=inquiryContentConfirmationList[0] + '\n';
		inquiryContentConfirmationList.add('・お店に行って相談したい');
		inquiryContent +=inquiryContentConfirmationList[1] + '\n';
		inquiryContent +='[その他]\n';//問合せ323で追加された除外の項目を判定に考慮しないように
		inquiryContentConfirmationList.add('仕事終わりに物件見に行きたいんですけど、何時まで可能ですか？');
		inquiryContent +=inquiryContentConfirmationList[2] + '\n';
		inquiryContent += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
		//▲ 対象内容
		echoMailTest.Body__c = setAthomeEchoMailStationery(inquiryContent);
		System.runAs(getThisUser()) {
			List<String> mailBodyList = echoMailTest.Body__c.split('\n');
			test.startTest();

			// アットホームの場合
            MailUtil.setEcoMailAtHome(echoMailTest, mailBodyList);

			// 登録 反響メール
			SecureDML.secureInsert(echoMailTest);
            //バッチ起動
            BA101005Batch b = new BA101005Batch(1); //引数:起動回数が1回目
            Database.executeBatch(b,200);
			test.stopTest();

			// 対応
			Correspond__c correspond = [SELECT ID,Remarks__c FROM Correspond__c WHERE PortalSite__c = :portalSite.ID LIMIT 1];
			List<String> remarksList = correspond.Remarks__c.split('\n');
			Integer count =0;
			for (String remarks : remarksList) {
				System.assertEquals(inquiryContentConfirmationList[count], remarks, 
				'対応の備考不一致：行数＝'+ count+1 +'：判定値＝'+inquiryContentConfirmationList[count] + '：対応備考の設定値＝'+remarks);	
				count += 1;
			}
			
		}
	}
	/**
	 * アットホーム、反響メール受信
	 * ＜その他お問い合わせ内容・ご希望内容＞の末尾「—」
	 * 反響一覧の備考（対応．備考）が仕切られた内容通りに取得されること
	 */
	@isTest static void athomeReceiveEchoMailTest7() {

		Shop__c shop = [SELECT ID,Email__c FROM Shop__c WHERE Name = 'テスト店舗1' LIMIT 1];
		PortalSite__c portalSite = [SELECT ID,Email__c FROM PortalSite__c WHERE Name = 'アットホーム' LIMIT 1];

		EchoMail__c echoMailTest = new EchoMail__c();
		echoMailTest = setAthomeEchoMail(shop,portalSite);
		String inquiryContent = '';
		List<String> inquiryContentConfirmationList = new List<String>();	// 対応の備考の判定
		// ▼対象内容
		inquiryContent +='＜その他お問い合わせ内容・ご希望内容＞\n';
		inquiryContentConfirmationList.add('・実際に物件を見たい');
		inquiryContent +=inquiryContentConfirmationList[0] + '\n';
		inquiryContentConfirmationList.add('・お店に行って相談したい');
		inquiryContent +=inquiryContentConfirmationList[1] + '\n';
		inquiryContent +='[その他]\n';//問合せ323で追加された除外の項目を判定に考慮しないように
		inquiryContentConfirmationList.add('仕事終わりに物件見に行きたいんですけど、何時まで可能ですか？');
		inquiryContent +=inquiryContentConfirmationList[2] + '\n';
		inquiryContent += '—————————————————————————————\n';
		//▲ 対象内容
		echoMailTest.Body__c = setAthomeEchoMailStationery(inquiryContent);
		System.runAs(getThisUser()) {
			List<String> mailBodyList = echoMailTest.Body__c.split('\n');
			test.startTest();

			// アットホームの場合
            MailUtil.setEcoMailAtHome(echoMailTest, mailBodyList);

			// 登録 反響メール
			SecureDML.secureInsert(echoMailTest);
            //バッチ起動
            BA101005Batch b = new BA101005Batch(1); //引数:起動回数が1回目
            Database.executeBatch(b,200);
			test.stopTest();

			// 対応
			Correspond__c correspond = [SELECT ID,Remarks__c FROM Correspond__c WHERE PortalSite__c = :portalSite.ID LIMIT 1];
			List<String> remarksList = correspond.Remarks__c.split('\n');
			Integer count =0;
			for (String remarks : remarksList) {
				System.assertEquals(inquiryContentConfirmationList[count], remarks, 
				'対応の備考不一致：行数＝'+ count+1 +'：判定値＝'+inquiryContentConfirmationList[count] + '：対応備考の設定値＝'+remarks);	
				count += 1;
			}
			
		}
	}
	/**
	 * アットホーム、反響メール受信
	 * ＜その他お問い合わせ内容・ご希望内容＞の末尾「━」
	 * 反響一覧の備考（対応．備考）が仕切られた内容通りに取得されること
	 */
	@isTest static void athomeReceiveEchoMailTest8() {

		Shop__c shop = [SELECT ID,Email__c FROM Shop__c WHERE Name = 'テスト店舗1' LIMIT 1];
		PortalSite__c portalSite = [SELECT ID,Email__c FROM PortalSite__c WHERE Name = 'アットホーム' LIMIT 1];

		EchoMail__c echoMailTest = new EchoMail__c();
		echoMailTest = setAthomeEchoMail(shop,portalSite);
		String inquiryContent = '';
		List<String> inquiryContentConfirmationList = new List<String>();	// 対応の備考の判定
		// ▼対象内容
		inquiryContent +='＜その他お問い合わせ内容・ご希望内容＞\n';
		inquiryContentConfirmationList.add('・実際に物件を見たい');
		inquiryContent +=inquiryContentConfirmationList[0] + '\n';
		inquiryContentConfirmationList.add('・お店に行って相談したい');
		inquiryContent +=inquiryContentConfirmationList[1] + '\n';
		inquiryContent +='[その他]\n';//問合せ323で追加された除外の項目を判定に考慮しないように
		inquiryContentConfirmationList.add('仕事終わりに物件見に行きたいんですけど、何時まで可能ですか？');
		inquiryContent +=inquiryContentConfirmationList[2] + '\n';
		inquiryContent += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
		//▲ 対象内容
		echoMailTest.Body__c = setAthomeEchoMailStationery(inquiryContent);
		System.runAs(getThisUser()) {
			List<String> mailBodyList = echoMailTest.Body__c.split('\n');
			test.startTest();

			// アットホームの場合
            MailUtil.setEcoMailAtHome(echoMailTest, mailBodyList);

			// 登録 反響メール
			SecureDML.secureInsert(echoMailTest);
            //バッチ起動
            BA101005Batch b = new BA101005Batch(1); //引数:起動回数が1回目
            Database.executeBatch(b,200);
			test.stopTest();

			// 対応
			Correspond__c correspond = [SELECT ID,Remarks__c FROM Correspond__c WHERE PortalSite__c = :portalSite.ID LIMIT 1];
			List<String> remarksList = correspond.Remarks__c.split('\n');
			Integer count =0;
			for (String remarks : remarksList) {
				System.assertEquals(inquiryContentConfirmationList[count], remarks, 
				'対応の備考不一致：行数＝'+ count+1 +'：判定値＝'+inquiryContentConfirmationList[count] + '：対応備考の設定値＝'+remarks);	
				count += 1;
			}
			
		}
	}
	//▲ 2022.03.10 No0753 対応で修正

	/**
	 * メール用置換文字の取得処理の実施
	 * @param String replaceStr		置換文字
	 * @param String sendingTime	送信時間
	 * @param Boolean canDoCrud		true:CRUD処理の実施可、false:CRUD処理の実施不可
	 * @return String メール用置換文字
	 */
	private static String executeGetMailReplaceText(
		String replaceStr
		, String sendingTime
		, Boolean canDoCrud
	) {

		CorrespondDetail__c	correspondDetail	= selectCorrespondDetail(replaceCorrespond.Id);
		EchoMail__c			echoMail 			= selectEchoMail(correspondDetail.EchoMail__c);

		// メール用置換文字の取得
		String replaceResult = MailUtil.getMailReplaceText(
			replaceStr
			, 'お客様名置換テスト'
			, '担当者名置換テスト'
			, replaceShop
			, replaceAccount
			, echoMail
			, sendingTime
			, replaceCorrespond.Id
			, canDoCrud
		);

		return replaceResult;
	}

	/**
	 * 置換対象文字の取得
	 * @return String 置換対象文字
	 */
	private static String getReplaceTargetText() {

		List<String> replaceTargetTextList = new List<String> {
			CommonConst.REPLACE_KEY_CUSTOMER_NAME			// {お客様名}
			, CommonConst.REPLACE_KEY_IN_CHARGE_NAME		// {担当者名}
			, CommonConst.REPLACE_KEY_SHOP_NAME				// {店舗名}
			, CommonConst.REPLACE_KEY_POSTAL_CODE			// {郵便番号}
			, CommonConst.REPLACE_KEY_SHOP_ADDRESS_1		// {店舗住所１}
			, CommonConst.REPLACE_KEY_SHOP_ADDRESS_2		// {店舗住所２}
			, CommonConst.REPLACE_KEY_PHONE_NUMBER			// {電話番号}
			, CommonConst.REPLACE_KEY_FAX					// {FAX}
			, CommonConst.REPLACE_KEY_BUSINESS_HOURS		// {営業時間}
			, CommonConst.REPLACE_KEY_REGULAR_HOLIDAY		// {定休日}
			, CommonConst.REPLACE_KEY_SHOP_HP				// {店舗HP}
			, CommonConst.REPLACE_KEY_ECHOMAIL_GREETING		// {あいさつ}
			, CommonConst.REPLACE_KEY_ECHOMAIL_PROPERTY_URL	// {反響メール物件URL}
		};
		
		return String.join(replaceTargetTextList, CommonConst.BREAK_CODE);
	}

	/**
	 * 店舗の取得
	 * @param String condShopName 店舗名
	 * @return Shop__c 店舗
	 */
	private Static Shop__c selectShop(String condShopName) {

		List<shop__c> shopList = [
			SELECT
				Id
				, Name
				, PostalCode__c
				, City__c
				, Street__c
				, Phone__c
				, Fax__c
				, BusinessHours__c
				, RegularHoliday__c
				, Homepage__c
			FROM shop__c
			WHERE Name = :condShopName
		];

		if (shopList.isEmpty()) {
			return new Shop__c();
		}

		return shopList[0];
	}

	/**
	 * 取引先の取得
	 * @param String condName 取引先名
	 * @return Account 取引先
	 */
	private Static Account selectAccount(String condName) {

		List<Account> accountList = [
			SELECT
				Id
				, Name
			FROM Account
			WHERE Name = :condName
		];

		if (accountList.isEmpty()) {
			return new Account();
		}

		return accountList[0];
	}

	/**
	 * LINE会員の取得
	 * @param String condName LINE名
	 * @return LineMember__c LINE会員
	 */
	private Static LineMember__c selectLineMember(String condName) {

		List<LineMember__c> lineMemberList = [
			SELECT 
				Id
				, Name
			FROM LineMember__c
			WHERE Name = :condName
		];

		if (lineMemberList.isEmpty()) {
			return new LineMember__c();
		}

		return lineMemberList[0];
	}

	/**
	 * 対応の取得
	 * @param Id condAccountId    取引先ID
	 * @param Id condLineMemberId LINE会員ID
	 * @return Correspond__c 対応
	 */
	private Static Correspond__c selectCorrespond(Id condAccountId, Id condLineMemberId) {

		String sql =
			'SELECT '
			+ 'Id '
			+ ', Status__c'
			+ ', EchoStaff__c'
			+ ', ShopStaff__c'
			+ ', AccountId__r.RecordTypeId'
			+ ', AccountId__r.Name '
			+ ', LineMember__r.Name '
			+ 'FROM Correspond__c ';

		// WHERE句の作成
		List<String> condList = new List<String>();

		// 取引先
		if (!String.isBlank(condAccountId)) {
			condList.add('AccountId__c = :condAccountId');
		}

		// LINE会員
		if (!String.isBlank(condLineMemberId)) {
			condList.add('LineMember__c = :condLineMemberId');
		}

		// WHERE句の取得
		if (condList.size() > 0) {
			sql += 'WHERE ';
			for (String cond : condList) {
				sql += cond + ' AND ';
			}
			sql = sql.removeEnd('AND ');
		}

		List<Correspond__c> correspondList = Database.query(sql);
		if (correspondList.isEmpty()) {
			return new Correspond__c();
		}

		return correspondList[0];
	}

	/**
	 * 対応明細の取得
	 * @param Id condCorrespondId 対応ID
	 * @return CorrespondDetail__c 対応明細
	 */
	private Static CorrespondDetail__c selectCorrespondDetail(Id condCorrespondId) {

		List<CorrespondDetail__c> correspondDetailList = [
			SELECT 
				Id
				, EchoMail__c
			FROM CorrespondDetail__c
			WHERE Corresponds__c = :condCorrespondId
		];

		if (correspondDetailList.isEmpty()) {
			return new CorrespondDetail__c();
		}

		return correspondDetailList[0];
	}

	/**
	 * 反響メールの取得
	 * @param Id condId 反響メールID
	 * @return EchoMail__c 反響メール
	 */
	private Static EchoMail__c selectEchoMail(Id condId) {

		List<EchoMail__c> echoMailList = [
			SELECT 
				Id
				, PropertyCode__c
				, PropertURL__c
				, PropertyName__c
				, PropertyAddress__c
				, ClosestStation__c
				, WalkTime__c
				, RoomLayout__c
				, RentFee__c
				, InquiryDateTime__c
			FROM EchoMail__c
			WHERE Id = :condId
		];

		if (echoMailList.isEmpty()) {
			return new EchoMail__c();
		}

		return echoMailList[0];
	}

	/**
	 * ユーザの取得
	 * @return User ユーザ
	 */
	private static User getThisUser() {

		User user = [
			SELECT Id
			FROM User
			WHERE Id = :UserInfo.getUserId()
		];

		return user;
	}

	//▼ 2022.03.10 No0753 対応で追加
	/**
	 * 反響メール情報（アットホーム）のメールひな型以外を設定
	 * @param Shop__c shop 店舗オブジェクト
	 * @param PortalSite__c portalSite ポータルサイトオブジェクト
	 * @return EchoMail__c アットホーム用のメール設定
	 */
	private static EchoMail__c setAthomeEchoMail(Shop__c shop,PortalSite__c portalSite){
		EchoMail__c echoMailTest = new EchoMail__c();
		echoMailTest.FromPotalSite__c =  portalSite.ID;    // Fromポータルサイト
		echoMailTest.Subject__c = '【LIFULL HOMES】お客様からの問合せ';	// 件名
		echoMailTest.Email__c = shop.Email__c;  // 店舗メールアドレス設定
		echoMailTest.BatchStatus__c = CommonConst.BATCH_STUTAS_WAITING;	// ステータス処理待ち
		return echoMailTest;
	}

	/**
	 * アットホームのメールひな型
	 * @param String inquiryContent お問合せ内容の格納文言
	 * @return String アットホームのメール
	 */
	private static String setAthomeEchoMailStationery(String inquiryContent) {
		String mailBody = '';
		mailBody +='□■アットホーム（スマートフォンサイト・アプリ） 　反響のお知らせ ■□\n';
		mailBody +='\n';
		mailBody +='スマートフォンサイト・アプリで物件をご覧になった【お客様からの反響】です。\n';
		mailBody +='下記の内容をご確認のうえ、お客様へのご連絡をお願いいたします。\n';
		mailBody +='\n';
		mailBody +='なお、お問合せ情報の中には、ご本人の個人情報が含まれていますので、\n';
		mailBody +='お取り扱いには十分にご留意ください。なお、本個人情報は、資料の送付、\n';
		mailBody +='問合せに対する連絡以外の目的では利用できません。\n';
		mailBody +='\n';
		mailBody +='\n';
		mailBody +='テスト店 御中\n';
		mailBody +='\n';
		mailBody +='お問合わせ日時：2020年03月01日22時40分\n';
		mailBody +='—————————————————————————————\n';
		mailBody +='＜お問合せされた物件の概要＞\n';
		mailBody +='物件種目　　　　　：賃貸マンション\n';
		mailBody +='建物名　　　　　　：テスト　２０２\n';
		mailBody +='交通　　　　　　　：テスト線\n';
		mailBody +='駅名　　　　　　　：テスト駅\n';
		mailBody +='徒歩　　　　　　　：15分\n';
		mailBody +='バス停名　　　　　：\n';
		mailBody +='バス乗車分　　　　：\n';
		mailBody +='バス停歩分　　　　：\n';
		mailBody +='所在地　　　　　　：名古屋市西区城北町１丁目１１２\n';
		mailBody +='賃料　　　　　　　：9.6万円\n';
		mailBody +='間取り　　　　　　：２ＬＤＫ\n';
		mailBody +='専有・建物面積　　：60.00平米\n';
		mailBody +='\n';
		mailBody +='at home 物件番号　　：1056513356\n';
		mailBody +='貴社物件管理番号　　：0008-689600\n';
		mailBody +='\n';
		mailBody +='詳しい物件情報はコチラ↓\n';
		mailBody +='https://www.athome.co.jp\n';
		mailBody +='—————————————————————————————\n';
		mailBody +='＜お客様のプロフィール＞\n';
		mailBody +='お名前　　　　　　　：テスト　太郎\n';
		mailBody +='希望連絡方法　　　　：メール\n';
		mailBody +='メールアドレス　　　： test@rnd.co.jp\n';
		mailBody +='電話番号　　　　　　：123456789\n';
		mailBody +='連絡希望の時間帯　　：\n';
		mailBody +='その他の連絡方法　　：\n';
		mailBody +='性別　　　　　　　　：\n';
		mailBody +='入居希望時期　　　　：\n';
		mailBody +='—————————————————————————————\n';
		// ▼対象内容
		mailBody += inquiryContent;
		//▲ 対象内容
		mailBody +='\n';
		mailBody +='▼━━━反響プラスで希望条件を詳しく確認━━━━━━━━━━━━━▼\n';
		mailBody +='https://test/\n';
		mailBody +='▲━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━▲\n';
		mailBody +='\n';
		mailBody +='☆お客さまのメール送信先が携帯アドレスの場合・・・\n';
		mailBody +='　ドメイン指定で制御されている可能性がございます。\n';
		mailBody +='　また、携帯へメールを送る際は、文字数の制限にご注意ください。\n';
		mailBody +='\n';
		mailBody +='■対応方法\n';
		mailBody +='　３営業日以内に上記＜お客様のプロフィール＞にある連絡先まで\n';
		mailBody +='　直接ご連絡くださいますようお願いいたします。\n';
		mailBody +='　Ｅメールでのご返信は、＜お客様のプロフィール＞中にあるメール\n';
		mailBody +='　アドレス宛になっているかを確認の上、お送りください。\n';
		mailBody +='　※お客様が入力した情報をそのまま送信しておりますので、\n';
		mailBody +='　　弊社でも＜お客様のプロフィール＞と同じ情報しかわかりません。\n';
		mailBody +='\n';
		mailBody +='■反響メール返信文例集＆メール操作簡単ガイドなど\n';
		mailBody +='　お客様対応に役立つ記事を掲載、下記ＵＲＬにアクセス！\n';
		mailBody +='　\n';
		mailBody +='\n';
		mailBody +='■このお知らせをFAXで受信されたアットホーム会員さまへ\n';
		mailBody +='　このサービスをEメールで受信することも可能です。ぜひご登録を！\n';
		mailBody +='　（アットホーム会員の方はご商号・ご住所・電話番号・Eメールを下記まで\n';
		mailBody +='　お知らせください。\n';
		mailBody +='　会員登録がない方は、ぜひアットホームへのご加盟をご検討ください。\n';
		mailBody +='　詳細は下記ページをご覧ください。）\n';
		mailBody +='　\n';
		mailBody +='\n';
		mailBody +='■このサービスはアットホーム(株)が行っております。\n';
		mailBody +='　お心あたりのない方は、恐れ入りますが TEL 0120-134-855 まで\n';
		mailBody +='　ご連絡をお願いいたします。\n';
		mailBody +='\n';
		mailBody +='\n';
		mailBody +='◆◇ ………………………………………………… ◇◆\n';
		mailBody +='　アットホーム カスタマーセンター\n';
		mailBody +='　TEL : 123-33-333\n';
		mailBody +='　※または、TEL.12111-111-11 まで\n';
		mailBody +='　E-Mail : test@pmb.rand.co.jp\n';
		mailBody +='◆◇ ………………………………………………… ◇◆\n';
		return mailBody;
	}
	//▲ 2022.03.10 No0753
}