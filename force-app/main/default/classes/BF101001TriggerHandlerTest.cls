/**
 * 自動追客メールテンプレートトリガーハンドラ_テストクラス　
 **/
@isTest 
public with sharing class BF101001TriggerHandlerTest {

	/** レコードタイプ／自動追客メールテンプレート */
	private static final Id RECORDTYPE_ID_LINE = CommonUtil.getRecordTypeId(CommonUtil.getNamespace('AutoPursuitMailTemplate__c'), CommonConst.AUTO_PURSUIT_MAIL_TEMPLATE_LINE);
	private static final Id RECORDTYPE_ID_MAIL = CommonUtil.getRecordTypeId(CommonUtil.getNamespace('AutoPursuitMailTemplate__c'), CommonConst.AUTO_PURSUIT_MAIL_TEMPLATE_MAIL);

    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //データ作成　システム設定 バッチサイズ
        SystemConfig__c sysconf = new SystemConfig__c(
            UseAuthority_Portal__c = true,
            TestDate__c =  Date.newInstance(2021, 7, 1),
			PropMenteHistoryPostingEndDelBatchFlg__c = false,
			IsSkipTrigger__c = true // スキップ
        );
        insert sysconf;

		//標準プロファイルを取得
		Id profileId = [SELECT Id FROM Profile WHERE Name = '一般ユーザ'].id;
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		User testUser = new User(LastName = 'ippanUser'	//姓
				,Alias =  'alias'                           //別名
				,Email = 'ippanUser@test.com'               //メール
				,UserName =  'ippanUser@test.com'           //ユーザ名
				,CommunityNickname ='テストニックネーム'     //ニックネーム
				,EmailEncodingKey = 'ISO-2022-JP'           //メールの文字コード
				,TimeZoneSidKey = 'Asia/Tokyo'              //タイムゾーン
				,LocaleSidKey = 'ja_JP'                     //地域
				,LanguageLocaleKey= 'ja'                    //言語
				,ProfileId = profileId                      //プロファイルID
		);
		System.runAs(thisUser){
			insert testUser;      
		}
		//店舗レコード
		Shop__c shopRecord = new shop__c(Name = 'テスト店舗１',
			PortalSitePostingDistrict__c = '港区;北区');
		Shop__c shopRecord2 = new shop__c(Name = 'テスト店舗２',
			PortalSitePostingDistrict__c = '北区');
		insert shopRecord;
		insert shopRecord2;
		// 組織階層レコード
		OrganizationHierarchy__c orgRecord1 = new OrganizationHierarchy__c(
			OrganizationCode__c = '0001',OrganizationName__c = '本部',
			HierarchyCode__c = '10',HierarchyOrder__c = 1,
			UpperOrganizationHierarchy__c = null,ExpandedOrganizationCode__c = '0000_0001',
			Shop__c = null
		);
		insert orgRecord1;
		OrganizationHierarchy__c orgRecord2 = new OrganizationHierarchy__c(
			OrganizationCode__c = '0002',OrganizationName__c = 'テスト店舗１',
			HierarchyCode__c = '20',HierarchyOrder__c = 1,
			UpperOrganizationHierarchy__c = orgRecord1.Id,ExpandedOrganizationCode__c = '0000_0001_0002',
			Shop__c = shopRecord.Id
		);
		insert orgRecord2;
		OrganizationHierarchy__c orgRecord3 = new OrganizationHierarchy__c(
			OrganizationCode__c = '0003',OrganizationName__c = 'テスト店舗２',
			HierarchyCode__c = '20',HierarchyOrder__c = 1,
			UpperOrganizationHierarchy__c = orgRecord1.Id,ExpandedOrganizationCode__c = '0000_0001_0003',
			Shop__c = shopRecord.Id
		);
		insert orgRecord3;
		//店舗異動レコード
		List<ShopTransfer__c> ShopTransferList = new List<ShopTransfer__c>();
		User userRecord =  [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = userRecord.id,
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
		insert ShopTransferRecord;
		// トリガスキップ戻す
		sysconf.IsSkipTrigger__c = false;
		update sysconf;

	}
		
	/**
	* １、新規登録、作成成功
	*     重複していない状態で自動追客メールテンプレートの作成が行えること（1件のみ）
	*/
	@isTest static void insertSuccessTest1(){

		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		System.runAs(thisUser) {
			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストA',
				Start__c	='1', // 開始
				End__c		='2', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			insert autoPursuitMailTemplate;

			Test.stopTest();

			// ★実行結果確認★
			// 重複していない状態で自動追客メールテンプレートの作成が行えること（1件のみ）
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストA'];
			System.assertEquals(1, autoPursuitMailTemplateList.size(), '新規登録１エラー');
		}
	}
	
	/**
	* ２、新規登録、作成成功
	*     重複していない状態で自動追客メールテンプレートの作成が行えること（既に数件ある状態）
	*	  開始と終了の回数が同じでも問題無く登録されること
	*/
	@isTest static void insertSuccessTest2(){

		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='9', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {
			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストB',
				Start__c	='1', // 開始
				End__c		='9', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			insert autoPursuitMailTemplate;

			Test.stopTest();

			// ★実行結果確認★
			// 重複していない状態で自動追客メールテンプレートの作成が行えること（1件のみ）
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストB'];
			System.assertEquals(1, autoPursuitMailTemplateList.size(), '新規登録２エラー');
		}
	}

	/**
	* ３、新規登録、作成成功
	*     重複していない状態で自動追客メールテンプレートの作成が行えること（既に数件ある状態）
	*	  他の内容が重複して、開始と終了の回数が被っていても登録されること
	*/
	@isTest static void insertSuccessTest3(){

		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='9', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {
			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストB',
				Start__c	='4', // 開始
				End__c		='6', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			insert autoPursuitMailTemplate;

			Test.stopTest();

			// ★実行結果確認★
			// 重複していない状態で自動追客メールテンプレートの作成が行えること（1件のみ）
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストB'];
			System.assertEquals(1, autoPursuitMailTemplateList.size(), '新規登録３エラー');
		}
	}
	/**
	* ４、新規登録、作成成功
	*     重複していない状態で自動追客メールテンプレートの作成が行えること（既に数件ある状態）
	*	  レコードタイプが別で他の内容が同じ
	*/
	@isTest static void insertSuccessTest4(){

		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='9', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {
			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_LINE, // レコードタイプ
				name		='テストB',
				Start__c	='1', // 開始
				End__c		='9', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			insert autoPursuitMailTemplate;

			Test.stopTest();

			// ★実行結果確認★
			// 重複していない状態で自動追客メールテンプレートの作成が行えること（1件のみ）
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストB'];
			System.assertEquals(1, autoPursuitMailTemplateList.size(), '新規登録４エラー');
		}
	}
	/**
	* ５、新規登録、作成成功
	*     重複していない状態で自動追客メールテンプレートの作成が行えること（既に数件ある状態）
	*	  店舗が別で、他の内容が同じ
	*/
	@isTest static void insertSuccessTest5(){

		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord1 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		Shop__c shopRecord2 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗２' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='9', // 終了
			Shop__c		=shopRecord1.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {
			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストB',
				Start__c	='1', // 開始
				End__c		='9', // 終了
				Shop__c		=shopRecord2.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			insert autoPursuitMailTemplate;

			Test.stopTest();

			// ★実行結果確認★
			// 重複していない状態で自動追客メールテンプレートの作成が行えること（1件のみ）
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストB'];
			System.assertEquals(1, autoPursuitMailTemplateList.size(), '新規登録５エラー');
		}
	}
	/**
	* ６、新規登録、作成成功
	*     重複していない状態で自動追客メールテンプレートの作成が行えること（既に数件ある状態）
	*	  開始終了の回数が重複せず他は同じ
	*/
	@isTest static void insertSuccessTest6(){

		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='9', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {
			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストB',
				Start__c	='10', // 開始
				End__c		='19', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			insert autoPursuitMailTemplate;

			Test.stopTest();

			// ★実行結果確認★
			// 重複していない状態で自動追客メールテンプレートの作成が行えること（1件のみ）
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストB'];
			System.assertEquals(1, autoPursuitMailTemplateList.size(), '新規登録６エラー');
		}
	}

	/**
	* １、新規登録、エラー：入力チェック
	*     送信対象が「全社共通」で店舗に入力がある場合、エラーとなり登録されないこと
	*/
	@isTest static void insertErrorTest1(){

		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		System.runAs(thisUser) {
			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_LINE, // レコードタイプ
				name		='テストA',
				Start__c	='1', // 開始
				End__c		='19', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			Exception ex;
			try {
				insert autoPursuitMailTemplate;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// 送信対象が「全社共通」で店舗に入力がある場合、エラーとなり登録されないこと
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストA'];
			System.assertNotEquals(1, autoPursuitMailTemplateList.size(), '新規登録エラーチェック１エラー'+ex);
		}
	}
	
	/**
	* ２、新規登録、エラー：入力チェック
	*     送信対象が「店舗」で店舗に入力が無い場合、エラーとなり登録されないこと
	*/
	@isTest static void insertErrorTest2(){

		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_LINE, // レコードタイプ
				name		='テストA',
				Start__c	='1', // 開始
				End__c		='19', // 終了
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			Exception ex;
			try {
				insert autoPursuitMailTemplate;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// 送信対象が「店舗」で店舗に入力が無い場合、エラーとなり登録されないこと
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストA'];
			System.assertNotEquals(1, autoPursuitMailTemplateList.size(), '新規登録エラーチェック２エラー'+ex);
		}
	}
	
	/**
	* ３、新規登録、エラー：入力チェック
	*     開始が終了の回数を上回る場合、エラーとなり登録されないこと
	*/
	@isTest static void insertErrorTest3(){

		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_LINE, // レコードタイプ
				name		='テストA',
				Start__c	='3', // 開始
				End__c		='1', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			Exception ex;
			try {
				insert autoPursuitMailTemplate;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// 開始が終了の回数を上回る場合、エラーとなり登録されないこと
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストA'];
			System.assertNotEquals(1, autoPursuitMailTemplateList.size(), '新規登録エラーチェック３エラー'+ex);
		}
	}

	/**
	* １、新規登録、エラー：追客メールの回数
	*     新規作成時に回数が飛んでいる場合、登録されないこと
	*     例＝新規作成：５～６回目
	*/
	@isTest static void insertErrorStartEndnumber1(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_LINE, // レコードタイプ
				name		='テストA',
				Start__c	='5', // 開始
				End__c		='6', // 終了
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			Exception ex;
			try {
				insert autoPursuitMailTemplate;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// 新規作成時に回数が飛んでいる場合、登録されないこと
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストA'];
			System.assertNotEquals(1, autoPursuitMailTemplateList.size(), '新規登録エラー追客メールの回数１エラー'+ex);
		}
	}

	/**
	* ２、新規登録、エラー：追客メールの回数
	*     同レコードタイプ、同店舗がある状態で新規作成時に回数が飛んでいる場合、登録されないこと
	*     例＝既存データ：１～２回目、新規作成：５～６回目
	*/
	@isTest static void insertErrorStartEndnumber2(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		
		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_LINE, // レコードタイプ
				name		='テストB',
				Start__c	='5', // 開始
				End__c		='6', // 終了
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			Exception ex;
			try {
				insert autoPursuitMailTemplate;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// 新規作成時に回数が飛んでいる場合、登録されないこと
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストB'];
			System.assertNotEquals(1, autoPursuitMailTemplateList.size(), '新規登録エラー追客メールの回数２エラー'+ex);
		}
	}

	/**
	* １、更新、更新成功
	*     重複していない状態で自動追客メールテンプレートの更新が行えること（1件のみ）
	*/
	@isTest static void updateSuccessTest1(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		AutoPursuitMailTemplate__c boforeUpdateAutoPursuitMailTemplate = [SELECT id,name,RecordTypeId,Shop__c,SendTarget__c,Start__c,End__c,Header__c,Body__c,Footer__c,RemoveConsideration__c,RentFeeFromMinus__c,RentFeeToPlus__c,SendInterval__c FROM AutoPursuitMailTemplate__c LIMIT 1];
		System.runAs(thisUser) {
			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート更新
			AutoPursuitMailTemplate__c updatePursuitMailTemplate =new AutoPursuitMailTemplate__c(
				id			= duplicationAutoPursuitMailTemplate.id,
				name		='テストB',
				End__c		='6', // 終了

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='2'// 配信間隔
			);
			update updatePursuitMailTemplate;
			
			Test.stopTest();
			AutoPursuitMailTemplate__c selectUpdateAutoPursuitMailTemplate = [SELECT id,name,RecordTypeId,Shop__c,SendTarget__c,Start__c,End__c,Header__c,Body__c,Footer__c,RemoveConsideration__c,RentFeeFromMinus__c,RentFeeToPlus__c,SendInterval__c FROM AutoPursuitMailTemplate__c LIMIT 1];
			// ★実行結果確認★
			// 重複していない状態で自動追客メールテンプレートの更新が行えること（1件のみ）
			// 更新無
			System.assertEquals(boforeUpdateAutoPursuitMailTemplate.id, selectUpdateAutoPursuitMailTemplate.id, '更新１エラー');
			System.assertEquals(boforeUpdateAutoPursuitMailTemplate.Start__c, selectUpdateAutoPursuitMailTemplate.Start__c, '更新１エラー');
			System.assertEquals(boforeUpdateAutoPursuitMailTemplate.Shop__c, selectUpdateAutoPursuitMailTemplate.Shop__c, '更新１エラー');
			System.assertEquals(boforeUpdateAutoPursuitMailTemplate.SendTarget__c, selectUpdateAutoPursuitMailTemplate.SendTarget__c, '更新１エラー');

			// 更新項目
			System.assertNotEquals(boforeUpdateAutoPursuitMailTemplate.name, selectUpdateAutoPursuitMailTemplate.name, '更新１エラー');
			System.assertNotEquals(boforeUpdateAutoPursuitMailTemplate.End__c, selectUpdateAutoPursuitMailTemplate.End__c, '更新１エラー');
			System.assertNotEquals(boforeUpdateAutoPursuitMailTemplate.Header__c, selectUpdateAutoPursuitMailTemplate.Header__c, '更新１エラー');
			System.assertNotEquals(boforeUpdateAutoPursuitMailTemplate.Body__c, selectUpdateAutoPursuitMailTemplate.Body__c, '更新１エラー');
			System.assertNotEquals(boforeUpdateAutoPursuitMailTemplate.Footer__c, selectUpdateAutoPursuitMailTemplate.Footer__c, '更新１エラー');
			System.assertNotEquals(boforeUpdateAutoPursuitMailTemplate.RentFeeFromMinus__c, selectUpdateAutoPursuitMailTemplate.RentFeeFromMinus__c, '更新１エラー');
			System.assertNotEquals(boforeUpdateAutoPursuitMailTemplate.RentFeeToPlus__c, selectUpdateAutoPursuitMailTemplate.RentFeeToPlus__c, '更新１エラー');
			System.assertNotEquals(boforeUpdateAutoPursuitMailTemplate.SendInterval__c, selectUpdateAutoPursuitMailTemplate.SendInterval__c, '更新１エラー');
		}
	}

	/**
	* ２、更新、更新成功
	*     重複していない状態で自動追客メールテンプレートの更新が行えること（既に数件ある状態）
	*     開始と終了の回数が同じでも問題無く更新されること
	*/
	@isTest static void updateSuccessTest2(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord1 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		Shop__c shopRecord2 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗２' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord1.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		// 自動追客メールテンプレート既存データ（更新）
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストB',
			Start__c	='1', // 開始
			End__c		='9', // 終了
			Shop__c		=shopRecord2.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate2;
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート更新（テストB）
			AutoPursuitMailTemplate__c updatePursuitMailTemplate =new AutoPursuitMailTemplate__c(
				id			= duplicationAutoPursuitMailTemplate2.id,
				Start__c	='1', // 開始
				End__c		='2', // 終了
				Shop__c		=shopRecord1.id,//	店舗

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='2'// 配信間隔
			);
			update updatePursuitMailTemplate;
			
			Test.stopTest();
			AutoPursuitMailTemplate__c selectUpdateAutoPursuitMailTemplate = [SELECT id,name,RecordTypeId,Shop__c,SendTarget__c,Start__c,End__c,Header__c,Body__c,Footer__c,RemoveConsideration__c,RentFeeFromMinus__c,RentFeeToPlus__c,SendInterval__c FROM AutoPursuitMailTemplate__c WHERE name='テストB' LIMIT 1];
			// ★実行結果確認★
			// 重複していない状態で自動追客メールテンプレートの更新が行えること（既に数件ある状態）
			// 開始と終了の回数が同じでも問題無く更新されること
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.End__c, selectUpdateAutoPursuitMailTemplate.End__c, '更新２エラー：終了＝'+duplicationAutoPursuitMailTemplate2.End__c+'='+selectUpdateAutoPursuitMailTemplate.End__c);
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.Shop__c, selectUpdateAutoPursuitMailTemplate.Shop__c, '更新２エラー：店舗＝'+duplicationAutoPursuitMailTemplate2.Shop__c+'='+selectUpdateAutoPursuitMailTemplate.shop__c);
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.Header__c, selectUpdateAutoPursuitMailTemplate.Header__c, '更新２エラー：ヘッダ＝'+duplicationAutoPursuitMailTemplate2.Header__c+'='+selectUpdateAutoPursuitMailTemplate.Header__c);
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.Body__c, selectUpdateAutoPursuitMailTemplate.Body__c, '更新２エラー：本文＝'+duplicationAutoPursuitMailTemplate2.Body__c+'='+selectUpdateAutoPursuitMailTemplate.Body__c);
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.Footer__c, selectUpdateAutoPursuitMailTemplate.Footer__c, '更新２エラー：フッタ＝'+duplicationAutoPursuitMailTemplate2.Footer__c+'='+selectUpdateAutoPursuitMailTemplate.Footer__c);
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.RentFeeFromMinus__c, selectUpdateAutoPursuitMailTemplate.RentFeeFromMinus__c, '更新２エラー：賃料下限のマイナス金額＝'+duplicationAutoPursuitMailTemplate2.RentFeeFromMinus__c+'='+selectUpdateAutoPursuitMailTemplate.RentFeeFromMinus__c);
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.RentFeeToPlus__c, selectUpdateAutoPursuitMailTemplate.RentFeeToPlus__c, '更新２エラー：賃料上限のプラス金額＝'+duplicationAutoPursuitMailTemplate2.RentFeeToPlus__c+'='+selectUpdateAutoPursuitMailTemplate.RentFeeToPlus__c);
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.SendInterval__c, selectUpdateAutoPursuitMailTemplate.SendInterval__c, '更新２エラー：配信間隔＝'+duplicationAutoPursuitMailTemplate2.SendInterval__c+'='+selectUpdateAutoPursuitMailTemplate.SendInterval__c);
		}
	}

	/**
	* ３、更新、更新成功
	*     重複していない状態で自動追客メールテンプレートの更新が行えること（既に数件ある状態）
	*     他の内容が重複して、開始と終了の回数が被っていても更新されること
	*/
	@isTest static void updateSuccessTest3(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストB',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate1;
		insert duplicationAutoPursuitMailTemplate2;
		System.runAs(thisUser) {
			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート更新
			AutoPursuitMailTemplate__c updatePursuitMailTemplate =new AutoPursuitMailTemplate__c(
				id			= duplicationAutoPursuitMailTemplate2.id,
				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='2'// 配信間隔
			);
			update updatePursuitMailTemplate;
			
			Test.stopTest();

			AutoPursuitMailTemplate__c selectUpdateAutoPursuitMailTemplate = [SELECT id,name,RecordTypeId,Shop__c,SendTarget__c,Start__c,End__c,Header__c,Body__c,Footer__c,RemoveConsideration__c,RentFeeFromMinus__c,RentFeeToPlus__c,SendInterval__c FROM AutoPursuitMailTemplate__c WHERE name='テストB' LIMIT 1];

			// ★実行結果確認★
			// 重複していない状態で自動追客メールテンプレートの更新が行えること（1件のみ）
			// 更新項目
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.Header__c, selectUpdateAutoPursuitMailTemplate.Header__c, '更新３エラー');
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.Body__c, selectUpdateAutoPursuitMailTemplate.Body__c, '更新３エラー');
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.Footer__c, selectUpdateAutoPursuitMailTemplate.Footer__c, '更新３エラー');
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.RentFeeFromMinus__c, selectUpdateAutoPursuitMailTemplate.RentFeeFromMinus__c, '更新３エラー');
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.RentFeeToPlus__c, selectUpdateAutoPursuitMailTemplate.RentFeeToPlus__c, '更新３エラー');
			System.assertNotEquals(duplicationAutoPursuitMailTemplate2.SendInterval__c, selectUpdateAutoPursuitMailTemplate.SendInterval__c, '更新３エラー');
		}
	}

	/**
	* ４、更新、更新成功
	*     重複していない状態で自動追客メールテンプレートの更新が行えること（既に数件ある状態）
	*     レコードタイプが別で他の内容が同じ
	*/
	@isTest static void updateSuccessTest4(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストB',
			Start__c	='3', // 開始
			End__c		='4', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate1;
		insert duplicationAutoPursuitMailTemplate2;
		String duplicationAutoPursuitMailTemplateRecordTypeId = duplicationAutoPursuitMailTemplate2.RecordTypeId;
		System.runAs(thisUser) {
			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート更新
			AutoPursuitMailTemplate__c updatePursuitMailTemplate =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_LINE, // レコードタイプ
				id			= duplicationAutoPursuitMailTemplate2.id,
				Start__c	='1', // 開始
				End__c		='2', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='2'// 配信間隔
			);
			update updatePursuitMailTemplate;
			
			Test.stopTest();

			AutoPursuitMailTemplate__c selectUpdateAutoPursuitMailTemplate = [SELECT id,name,RecordTypeId,Shop__c,SendTarget__c,Start__c,End__c,Header__c,Body__c,Footer__c,RemoveConsideration__c,RentFeeFromMinus__c,RentFeeToPlus__c,SendInterval__c FROM AutoPursuitMailTemplate__c WHERE name='テストB' LIMIT 1];

			// ★実行結果確認★
			// 重複していない状態で自動追客メールテンプレートの更新が行えること（1件のみ）
			System.assertNotEquals(duplicationAutoPursuitMailTemplateRecordTypeId, selectUpdateAutoPursuitMailTemplate.RecordTypeId, '更新４エラー');
		}
	}

	/**
	* ５、更新、更新成功
	*     重複していない状態で自動追客メールテンプレートの更新が行えること（既に数件ある状態）
	*     店舗が別で、他の内容が同じ
	*/
	@isTest static void updateSuccessTest5(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord1 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		Shop__c shopRecord2 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗２' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord1.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストB',
			Start__c	='3', // 開始
			End__c		='3', // 終了
			Shop__c		=shopRecord1.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate1;
		insert duplicationAutoPursuitMailTemplate2;
		String duplicationAutoPursuitMailTemplateShop = duplicationAutoPursuitMailTemplate2.Shop__c;
		System.runAs(thisUser) {
			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート更新
			AutoPursuitMailTemplate__c updatePursuitMailTemplate =new AutoPursuitMailTemplate__c(
				id			= duplicationAutoPursuitMailTemplate2.id,
				name		='テストB',
				Start__c	='1', // 開始
				End__c		='2', // 終了
				Shop__c		=shopRecord2.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='2'// 配信間隔
			);
			update updatePursuitMailTemplate;
			
			Test.stopTest();
			AutoPursuitMailTemplate__c selectUpdateAutoPursuitMailTemplate = [SELECT id,name,RecordTypeId,Shop__c,SendTarget__c,Start__c,End__c,Header__c,Body__c,Footer__c,RemoveConsideration__c,RentFeeFromMinus__c,RentFeeToPlus__c,SendInterval__c FROM AutoPursuitMailTemplate__c WHERE name='テストB' LIMIT 1];

			// ★実行結果確認★
			// 重複していない状態で自動追客メールテンプレートの更新が行えること（1件のみ）
			System.assertNotEquals(duplicationAutoPursuitMailTemplateShop, selectUpdateAutoPursuitMailTemplate.Shop__c, '更新５エラー');
		}
	}

	/**
	* ６、更新、更新成功
	*     重複していない状態で自動追客メールテンプレートの更新が行えること（既に数件ある状態）
	*     開始終了の回数が重複せず他は同じ
	*/
	@isTest static void updateSuccessTest6(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストB',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate1;
		insert duplicationAutoPursuitMailTemplate2;
		String duplicationAutoPursuitMailTemplateEnd = duplicationAutoPursuitMailTemplate2.End__c;
		System.runAs(thisUser) {
			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート更新
			AutoPursuitMailTemplate__c updatePursuitMailTemplate =new AutoPursuitMailTemplate__c(
				id			= duplicationAutoPursuitMailTemplate2.id,
				name		='テストB',
				Start__c	='3', // 開始
				End__c		='10', // 終了

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='2'// 配信間隔
			);
			update updatePursuitMailTemplate;
			
			Test.stopTest();
			AutoPursuitMailTemplate__c selectUpdateAutoPursuitMailTemplate = [SELECT id,name,RecordTypeId,Shop__c,SendTarget__c,Start__c,End__c,Header__c,Body__c,Footer__c,RemoveConsideration__c,RentFeeFromMinus__c,RentFeeToPlus__c,SendInterval__c FROM AutoPursuitMailTemplate__c WHERE name='テストB' LIMIT 1];

			// ★実行結果確認★
			// 重複していない状態で自動追客メールテンプレートの更新が行えること（既に数件ある状態）
			// 開始終了の回数が重複せず他は同じ
			System.assertNotEquals(duplicationAutoPursuitMailTemplateEnd, selectUpdateAutoPursuitMailTemplate.End__c, '更新６エラー');
		}
	}

	/**
	* １、更新、エラー：入力チェック
	*     送信対象が「全社共通」で店舗に入力がある場合、エラーとなり更新されないこと
	*/
	@isTest static void updateErrorTest1(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			Exception ex;
			try {
				update autoPursuitMailTemplate;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// 送信対象が「全社共通」で店舗に入力がある場合、エラーとなり更新されないこと
			AutoPursuitMailTemplate__c errorAutoPursuitMailTemplate = [SELECT Id,Body__c FROM AutoPursuitMailTemplate__c WHERE name = 'テストA' LIMIT 1];
			System.assertNotEquals('', errorAutoPursuitMailTemplate.Body__c, '更新エラーチェック１エラー'+ex);
		}
	}

	/**
	* ２、更新、エラー：入力チェック
	*     送信対象が「店舗」で店舗に入力が無い場合、エラーとなり更新されないこと
	*/
	@isTest static void updateErrorTest2(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				Shop__c		=null,//	店舗

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			Exception ex;
			try {
				update autoPursuitMailTemplate;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// 送信対象が「店舗」で店舗に入力が無い場合、エラーとなり更新されないこと
			AutoPursuitMailTemplate__c errorAutoPursuitMailTemplate = [SELECT Id,Body__c FROM AutoPursuitMailTemplate__c WHERE name = 'テストA' LIMIT 1];
			System.assertNotEquals('', errorAutoPursuitMailTemplate.Body__c, '更新エラーチェック２エラー'+ex);
		}
	}
	// 
	/**
	* ３、更新、エラー：入力チェック
	*     開始が終了の回数を上回る場合、エラーとなり更新されないこと
	*/
	@isTest static void updateErrorTest3(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート登録
			AutoPursuitMailTemplate__c autoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				Start__c	='3', // 開始

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			Exception ex;
			try {
				update autoPursuitMailTemplate;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// 開始が終了の回数を上回る場合、エラーとなり更新されないこと
			AutoPursuitMailTemplate__c errorAutoPursuitMailTemplate = [SELECT Id,Body__c FROM AutoPursuitMailTemplate__c WHERE name = 'テストA' LIMIT 1];
			System.assertNotEquals('', errorAutoPursuitMailTemplate.Body__c, '更新エラーチェック３エラー'+ex);
		}
	}

	/**
	* １、更新、エラー：追客メールの回数
	*     同レコードタイプ、同店舗がある状態で更新時に回数が飛んでいる場合、更新されないこと
	*     例＝既存データ：１～２回目→更新：５～６回目
	*/
	@isTest static void updateErrorStartEndnumber1(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート更新
			AutoPursuitMailTemplate__c errorAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				id 			= duplicationAutoPursuitMailTemplate.id,
				Start__c	='5', // 開始
				End__c		='6', // 終了

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			Exception ex;
			try {
				update errorAutoPursuitMailTemplate;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// 新規作成時に回数が飛んでいる場合、登録されないこと
			AutoPursuitMailTemplate__c autoPursuitMailTemplate = [SELECT Id,Start__c,End__c FROM AutoPursuitMailTemplate__c WHERE name = 'テストA' LIMIT 1];
			System.assertEquals('1', autoPursuitMailTemplate.Start__c, '更新エラー追客メールの回数１エラー：開始='+autoPursuitMailTemplate.Start__c + '：エラーメッセージ='+ ex);
			System.assertEquals('2', autoPursuitMailTemplate.End__c, '更新エラー追客メールの回数１エラー：終了='+autoPursuitMailTemplate.End__c + '：エラーメッセージ='+ ex);
		}
	}

	/**
	* ２、更新、エラー：追客メールの回数
	*     同レコードタイプ、同店舗がある状態で店舗変更で回数が飛んでいる場合、更新されないこと
    *     例＝既存データ１：店舗１（１～２回目）　既存データ１：店舗１（１～２回目）
　　*         既存データ２：店舗１（３～６回目）→既存データ２：店舗２（３～６回目）
　　*         既存データ３：店舗１（７～９回目）　既存データ３：店舗１（７～９回目）
	*/
	@isTest static void updateErrorStartEndnumber2(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord1 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		Shop__c shopRecord2 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗２' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ１
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord1.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		// 自動追客メールテンプレート既存データ２
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストB',
			Start__c	='3', // 開始
			End__c		='6', // 終了
			Shop__c		=shopRecord1.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		// 自動追客メールテンプレート既存データ３
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate3 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストC',
			Start__c	='7', // 開始
			End__c		='9', // 終了
			Shop__c		=shopRecord1.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate1;
		insert duplicationAutoPursuitMailTemplate2;
		insert duplicationAutoPursuitMailTemplate3;
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート更新
			AutoPursuitMailTemplate__c errorAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				id 			= duplicationAutoPursuitMailTemplate2.id,
				Shop__c		=shopRecord2.id,//	店舗

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			Exception ex;
			try {
				update errorAutoPursuitMailTemplate;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// 同レコードタイプ、同店舗がある状態で店舗変更で回数が飛んでいる場合、更新されないこと
			AutoPursuitMailTemplate__c autoPursuitMailTemplate = [SELECT Id,Shop__c FROM AutoPursuitMailTemplate__c WHERE name = 'テストB' LIMIT 1];
			System.assertEquals(shopRecord1.Id, autoPursuitMailTemplate.Shop__c, '更新エラー追客メールの回数２エラー：店舗='+autoPursuitMailTemplate.Shop__c + '：エラーメッセージ='+ ex);
		}
	}
	/**
	* ３、更新、エラー：追客メールの回数
    *     同レコードタイプ、同店舗がある状態で店舗変更で回数が飛んでいる場合、更新されないこと
    *     例＝既存データ１：店舗１（１～２回目）　既存データ１：店舗１（１～２回目）
    *     　　既存データ２：店舗１（３～６回目）　既存データ２：店舗１（３～６回目）
    *     　　既存データ３：店舗１（７～９回目）→既存データ３：店舗２（７～９回目）
	*/
	@isTest static void updateErrorStartEndnumber3(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord1 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		Shop__c shopRecord2 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗２' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ１
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord1.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		// 自動追客メールテンプレート既存データ２
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストB',
			Start__c	='3', // 開始
			End__c		='6', // 終了
			Shop__c		=shopRecord1.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		// 自動追客メールテンプレート既存データ３
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate3 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストC',
			Start__c	='7', // 開始
			End__c		='9', // 終了
			Shop__c		=shopRecord1.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate1;
		insert duplicationAutoPursuitMailTemplate2;
		insert duplicationAutoPursuitMailTemplate3;
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート更新
			AutoPursuitMailTemplate__c errorAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				id 			= duplicationAutoPursuitMailTemplate3.id,
				Shop__c		=shopRecord2.id,//	店舗

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			Exception ex;
			try {
				update errorAutoPursuitMailTemplate;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// 同レコードタイプ、同店舗がある状態で店舗変更で回数が飛んでいる場合、更新されないこと
			AutoPursuitMailTemplate__c autoPursuitMailTemplate = [SELECT Id,Shop__c FROM AutoPursuitMailTemplate__c WHERE name = 'テストC' LIMIT 1];
			System.assertEquals(shopRecord1.Id, autoPursuitMailTemplate.Shop__c, '更新エラー追客メールの回数３エラー：店舗='+autoPursuitMailTemplate.Shop__c + '：エラーメッセージ='+ ex);
		}
	}

	/**
	* １、削除、削除成功
	*     重複していない状態で自動追客メールテンプレートの削除が行えること（1件のみ）
	*/
	@isTest static void deleteSuccessTest1(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			delete duplicationAutoPursuitMailTemplate;
			
			Test.stopTest();

			// ★実行結果確認★
			// 重複していない状態で自動追客メールテンプレートの削除が行えること（1件のみ）
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストA'];
			System.assertEquals(0, autoPursuitMailTemplateList.size(), '削除１エラー');
		}
	}

	/**
	* ２、削除、削除成功
	*     重複していない状態で自動追客メールテンプレートの削除が行えること（既に数件ある状態）
	*     他の内容が同一で開始と終了の回数が被っている状態で削除が行えること
	*/
	@isTest static void deleteSuccessTest2(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='5', // 終了
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		// 自動追客メールテンプレート既存データ
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストB',
			Start__c	='3', // 開始
			End__c		='4', // 終了
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate1;
		insert duplicationAutoPursuitMailTemplate2;
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			delete duplicationAutoPursuitMailTemplate2;
			
			Test.stopTest();

			// ★実行結果確認★
			// 他の内容が同一で開始と終了の回数が被っている状態で削除が行えること
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c];
			System.assertEquals(1, autoPursuitMailTemplateList.size(), '削除２エラー='+autoPursuitMailTemplateList.size());
		}
	}

	/**
	* ３、削除、削除成功：入力チェック
	*     送信対象が「全社共通」で店舗に入力がある状態で、エラーとならず削除されること
	*/
	@isTest static void deleteSuccessTest3(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート変更
			AutoPursuitMailTemplate__c deleteAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				id 			= duplicationAutoPursuitMailTemplate.id,
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			delete deleteAutoPursuitMailTemplate;
			
			Test.stopTest();

			// ★実行結果確認★
			// 送信対象が「全社共通」で店舗に入力がある状態で、エラーとならず削除されること
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストA'];
			System.assertEquals(0, autoPursuitMailTemplateList.size(), '削除３エラー');
		}
	}

	/**
	* ４、削除、削除成功：入力チェック
	*     送信対象が「店舗」で店舗に入力が無い状態で、エラーとならず削除されること
	*/
	@isTest static void deleteSuccessTest4(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {
			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート変更
			AutoPursuitMailTemplate__c deleteAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				id 			= duplicationAutoPursuitMailTemplate.id,
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY,// 送信対象

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			delete deleteAutoPursuitMailTemplate;
			
			Test.stopTest();

			// ★実行結果確認★
			// 送信対象が「店舗」で店舗に入力が無い状態で、エラーとならず削除されること
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストA'];
			System.assertEquals(0, autoPursuitMailTemplateList.size(), '削除４エラー');
		}
	}

	/**
	* ５、削除、削除成功：入力チェック
	*     開始が終了の回数を上回る状態で、エラーとならず削除されること
	*/
	@isTest static void deleteSuccessTest5(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate;
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート変更
			AutoPursuitMailTemplate__c deleteAutoPursuitMailTemplate =new AutoPursuitMailTemplate__c(
				id 			= duplicationAutoPursuitMailTemplate.id,
				Start__c	='9', // 開始

				Header__c	= 'へっだ',//	ヘッダ
				Body__c		= 'test', // 本文
				Footer__c	= 'ふった',//	フッタ
				RemoveConsideration__c	=false,//	過去に紹介した物件をおすすめから外す
				RentFeeFromMinus__c	=1000,//	賃料下限のマイナス金額
				RentFeeToPlus__c	=2000,//	賃料上限のプラス金額
				SendInterval__c		='1'// 配信間隔
			);
			delete deleteAutoPursuitMailTemplate;
			
			Test.stopTest();

			// ★実行結果確認★
			// 開始が終了の回数を上回る状態で、エラーとならず削除されること
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストA'];
			System.assertEquals(0, autoPursuitMailTemplateList.size(), '削除５エラー');
		}
	}

	/**
	* １、削除、エラー：追客メールの回数
	*     同レコードタイプ、同店舗がある状態で新規作成時に回数が飛んでいる場合、削除されないこと
    *     例＝既存データA：１～２回目
　　*         既存データB：３～６回目	→既存データ２削除
　　*         既存データC：６～１０回目
	*/
	@isTest static void deleteErrorStartEndnumber1(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ１
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		// 自動追客メールテンプレート既存データ２
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストB',
			Start__c	='3', // 開始
			End__c		='6', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		// 自動追客メールテンプレート既存データ３
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate3 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストC',
			Start__c	='7', // 開始
			End__c		='9', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate1;
		insert duplicationAutoPursuitMailTemplate2;
		insert duplicationAutoPursuitMailTemplate3;
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			Exception ex;
			try {
				// 削除
				delete duplicationAutoPursuitMailTemplate2;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// 同レコードタイプ、同店舗がある状態で新規作成時に回数が飛んでいる場合、削除されないこと
			AutoPursuitMailTemplate__c deleteAutoPursuitMailTemplate = [SELECT Id,RecordTypeId,name,Start__c,End__c,Shop__c,SendTarget__c,SendInterval__c FROM AutoPursuitMailTemplate__c WHERE name = 'テストB' LIMIT 1];
			System.assertEquals(duplicationAutoPursuitMailTemplate2, deleteAutoPursuitMailTemplate, '削除エラー追客メールの回数１エラー：データ='+deleteAutoPursuitMailTemplate + '：エラーメッセージ='+ ex);
		}
	}

	/**
	* ２、削除、エラー：追客メールの回数
	*     同レコードタイプ、同店舗がある状態で新規作成時に回数が飛んでいる場合、削除されないこと
    *     例＝既存データA：１～２回目　→既存データ１削除
　　*         既存データB：３～６回目
　　*         既存データC：６～１０回目
	*/
	@isTest static void deleteErrorStartEndnumber2(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];

		// ★事前データ登録★
		// 自動追客メールテンプレート既存データ１
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストA',
			Start__c	='1', // 開始
			End__c		='2', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		// 自動追客メールテンプレート既存データ２
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストB',
			Start__c	='3', // 開始
			End__c		='6', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		// 自動追客メールテンプレート既存データ３
		AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate3 =new AutoPursuitMailTemplate__c(
			RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
			name		='テストC',
			Start__c	='7', // 開始
			End__c		='9', // 終了
			Shop__c		=shopRecord.id,//	店舗
			SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
			SendInterval__c		='1'// 配信間隔
		);
		insert duplicationAutoPursuitMailTemplate1;
		insert duplicationAutoPursuitMailTemplate2;
		insert duplicationAutoPursuitMailTemplate3;
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			Exception ex;
			try {
				// 削除
				delete duplicationAutoPursuitMailTemplate1;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// 同レコードタイプ、同店舗がある状態で新規作成時に回数が飛んでいる場合、削除されないこと
			AutoPursuitMailTemplate__c deleteAutoPursuitMailTemplate = [SELECT Id,RecordTypeId,name,Start__c,End__c,Shop__c,SendTarget__c,SendInterval__c FROM AutoPursuitMailTemplate__c WHERE name = 'テストA' LIMIT 1];
			System.assertEquals(duplicationAutoPursuitMailTemplate1, deleteAutoPursuitMailTemplate, '削除エラー追客メールの回数１エラー：データ='+deleteAutoPursuitMailTemplate + '：エラーメッセージ='+ ex);
		}
	}

	
	/**
	* １、複数処理
	*     新規作成（複数）：成功
	*     新規＝データA：３～５回目
　　*      　   データB：１～２回目
　　*      　   データC：６～８回目
	*/
	@isTest static void pluralInsertSuccessTest(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート既存データ１
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストA',
				Start__c	='3', // 開始
				End__c		='5', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ２
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストB',
				Start__c	='1', // 開始
				End__c		='2', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ３
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate3 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストC',
				Start__c	='6', // 開始
				End__c		='8', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 一括登録
			List<AutoPursuitMailTemplate__c> insertAutoPursuitMailTemplateList = new List<AutoPursuitMailTemplate__c>{
				duplicationAutoPursuitMailTemplate1,duplicationAutoPursuitMailTemplate2,duplicationAutoPursuitMailTemplate3
			};
			insert insertAutoPursuitMailTemplateList;
			Test.stopTest();

			// ★実行結果確認★
			// 登録されたデータがあること
			Map<Id,AutoPursuitMailTemplate__c> autoPursuitMailTemplateMap = new Map<Id,AutoPursuitMailTemplate__c>([SELECT Id,RecordTypeId,name,Start__c,End__c,Shop__c,SendTarget__c,SendInterval__c FROM AutoPursuitMailTemplate__c ORDER BY name]);
			for (AutoPursuitMailTemplate__c insertAutoPursuitMailTemplate : insertAutoPursuitMailTemplateList) {
				System.assertEquals(insertAutoPursuitMailTemplate, autoPursuitMailTemplateMap.get(insertAutoPursuitMailTemplate.id), '新規作成（複数）：成功エラー='+autoPursuitMailTemplateMap.get(insertAutoPursuitMailTemplate.id));	
			}
			
		}
	}
	/**
	* ２、複数処理
	*     新規作成（複数）：エラー
	*     エラーとなり、データが作成されないこと
	*/
	@isTest static void pluralInsertErrorTest(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		System.runAs(thisUser) {

			// ★本実行★
			Test.startTest();
			// 自動追客メールテンプレート既存データ１
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストA',
				Start__c	='1', // 開始
				End__c		='2', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ２
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストB',
				Start__c	='3', // 開始
				End__c		='5', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ３
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate3 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストC',
				Start__c	='9', // 開始
				End__c		='5', // 終了
				Shop__c		=shopRecord.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 一括登録
			List<AutoPursuitMailTemplate__c> errorInsertAutoPursuitMailTemplateList = new List<AutoPursuitMailTemplate__c>{
				duplicationAutoPursuitMailTemplate1,duplicationAutoPursuitMailTemplate2,duplicationAutoPursuitMailTemplate3
			};
			Exception ex;
			try {
				insert errorInsertAutoPursuitMailTemplateList;
			} catch (Exception e) {
				ex = e;
			}
			Test.stopTest();

			// ★実行結果確認★
			// エラーとなり、データが作成されないこと
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c];
			System.assertEquals(0, autoPursuitMailTemplateList.size(), '新規作成（複数）：エラー='+autoPursuitMailTemplateList.size());	
			
		}
	}

	/**
	* ３、複数処理
	*     更新（複数）：成功
	*     エラー無くデータが更新されること
	*	  例＝データA：店舗２（１～５回目）　データA：店舗２（１～５回目）
	*		  データB：店舗１（１～２回目）　データB：店舗１（１～２回目）
	*		  データC：店舗１（３～５回目）→ データC：店舗２（６～８回目）
	*		  データD：店舗２（６～８回目）→ データD：店舗１（３～５回目）
	*		  データE：店舗１（６～８回目）　データE：店舗１（６～８回目）
	*/
	@isTest static void pluralUpdateSuccessTest(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord1 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		Shop__c shopRecord2 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗２' LIMIT 1];
		System.runAs(thisUser) {
			// ★事前データ登録★
			// 自動追客メールテンプレート既存データ１
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストA',
				Start__c	='1', // 開始
				End__c		='5', // 終了
				Shop__c		=shopRecord2.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ２
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストB',
				Start__c	='1', // 開始
				End__c		='2', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ３
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate3 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストC',
				Start__c	='3', // 開始
				End__c		='5', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ３
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate4 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストD',
				Start__c	='6', // 開始
				End__c		='8', // 終了
				Shop__c		=shopRecord2.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ３
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate5 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストE',
				Start__c	='6', // 開始
				End__c		='8', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 登録
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = new List<AutoPursuitMailTemplate__c>{
				duplicationAutoPursuitMailTemplate1,duplicationAutoPursuitMailTemplate2,duplicationAutoPursuitMailTemplate3,
				duplicationAutoPursuitMailTemplate4,duplicationAutoPursuitMailTemplate5
			};
			insert autoPursuitMailTemplateList;
			List<AutoPursuitMailTemplate__c> beforeautoPursuitMailTemplateList= [SELECT Id,RecordTypeId,name,Start__c,End__c,Shop__c,SendTarget__c,SendInterval__c FROM AutoPursuitMailTemplate__c ORDER BY name];

			// ★本実行★
			Test.startTest();
			// 更新データ
			for (AutoPursuitMailTemplate__c autoPursuitMailTemplate : autoPursuitMailTemplateList) {
				if(autoPursuitMailTemplate.name =='テストC'){
					// データC：店舗１（３～５回目）→ データC：店舗２（６～８回目）
					autoPursuitMailTemplate.shop__c = shopRecord2.id;
					autoPursuitMailTemplate.Start__c= '6';
					autoPursuitMailTemplate.End__c	= '8';
				}else if(autoPursuitMailTemplate.name =='テストD'){
					// データD：店舗２（６～８回目）→ データD：店舗１（３～５回目）
					autoPursuitMailTemplate.shop__c = shopRecord1.id;
					autoPursuitMailTemplate.Start__c= '3';
					autoPursuitMailTemplate.End__c	= '5';
				}
			}

			update autoPursuitMailTemplateList;
			Test.stopTest();

			// ★実行結果確認★
			// エラー無くデータが更新されること
			Map<Id,AutoPursuitMailTemplate__c> autoPursuitMailTemplateMap = new Map<Id,AutoPursuitMailTemplate__c>([SELECT Id,RecordTypeId,name,Start__c,End__c,Shop__c,SendTarget__c,SendInterval__c FROM AutoPursuitMailTemplate__c ORDER BY name]);
			for (AutoPursuitMailTemplate__c autoPursuitMailTemplate : beforeautoPursuitMailTemplateList) {
				if(autoPursuitMailTemplate.name =='テストC' || autoPursuitMailTemplate.name =='テストD'){
					System.assertNotEquals(autoPursuitMailTemplate.shop__c, autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id).shop__c, '更新（複数）：成功エラー店舗='+autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id).shop__c + '：件名＝' + autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id).name);
					System.assertNotEquals(autoPursuitMailTemplate.Start__c, autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id).Start__c, '更新（複数）：成功エラー開始='+autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id).Start__c + '：件名＝' + autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id).name);
					System.assertNotEquals(autoPursuitMailTemplate.End__c, autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id).End__c, '更新（複数）：成功エラー終了='+autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id).End__c + '：件名＝' + autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id).name);
				}else{
					System.assertEquals(autoPursuitMailTemplate, autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id), '更新（複数）：成功エラー内容更新外='+autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id) + '：件名＝' + autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id).name);
				}
				
			}
			
		}
	}

	/**
	* ４、複数処理
	*     更新（複数）：エラー
	*     エラーが発生して更新されないこと
	*     例＝データA：店舗２（１～５回目）　データA：店舗２（１～５回目）
	*         データB：店舗１（１～２回目）　データB：店舗１（１～２回目）
	*         データC：店舗１（３～５回目）→ データC：店舗２（８～９回目）（エラー）
	*         データD：店舗２（６～８回目）→ データD：店舗１（４～５回目）（エラー）
	*         データE：店舗１（６～８回目）　データE：店舗１（６～８回目）
	*/
	@isTest static void pluralUpdateErrorTest(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord1 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		Shop__c shopRecord2 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗２' LIMIT 1];
		System.runAs(thisUser) {
			// ★事前データ登録★
			// 自動追客メールテンプレート既存データ１
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストA',
				Start__c	='1', // 開始
				End__c		='5', // 終了
				Shop__c		=shopRecord2.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ２
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストB',
				Start__c	='1', // 開始
				End__c		='2', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ３
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate3 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストC',
				Start__c	='3', // 開始
				End__c		='5', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ３
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate4 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストD',
				Start__c	='6', // 開始
				End__c		='8', // 終了
				Shop__c		=shopRecord2.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ３
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate5 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストE',
				Start__c	='6', // 開始
				End__c		='8', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 登録
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = new List<AutoPursuitMailTemplate__c>{
				duplicationAutoPursuitMailTemplate1,duplicationAutoPursuitMailTemplate2,duplicationAutoPursuitMailTemplate3,
				duplicationAutoPursuitMailTemplate4,duplicationAutoPursuitMailTemplate5
			};
			insert autoPursuitMailTemplateList;
			List<AutoPursuitMailTemplate__c> beforeautoPursuitMailTemplateList= [SELECT Id,RecordTypeId,name,Start__c,End__c,Shop__c,SendTarget__c,SendInterval__c FROM AutoPursuitMailTemplate__c ORDER BY name];

			// ★本実行★
			Test.startTest();
			// 更新データ
			for (AutoPursuitMailTemplate__c autoPursuitMailTemplate : autoPursuitMailTemplateList) {
				if(autoPursuitMailTemplate.name =='テストC'){
					// データC：店舗１（３～５回目）→ データC：店舗２（８～９回目）（エラー）
					autoPursuitMailTemplate.shop__c = shopRecord2.id;
					autoPursuitMailTemplate.Start__c= '8';
					autoPursuitMailTemplate.End__c	= '9';
				}else if(autoPursuitMailTemplate.name =='テストD'){
					// データD：店舗２（６～８回目）→ データD：店舗１（４～５回目）（エラー）
					autoPursuitMailTemplate.shop__c = shopRecord1.id;
					autoPursuitMailTemplate.Start__c= '4';
					autoPursuitMailTemplate.End__c	= '5';
				}
			}
			Exception ex;
			try {
				update autoPursuitMailTemplateList;
			} catch (Exception e) {
				ex = e;
			}
			
			Test.stopTest();

			// ★実行結果確認★
			// エラーが発生して更新されないこと
			Map<Id,AutoPursuitMailTemplate__c> autoPursuitMailTemplateMap = new Map<Id,AutoPursuitMailTemplate__c>([SELECT Id,RecordTypeId,name,Start__c,End__c,Shop__c,SendTarget__c,SendInterval__c FROM AutoPursuitMailTemplate__c ORDER BY name]);
			for (AutoPursuitMailTemplate__c autoPursuitMailTemplate : beforeautoPursuitMailTemplateList) {
				System.assertEquals(autoPursuitMailTemplate, autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id), '更新（複数）：成功エラー内容更新外='+autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id) + '：件名＝' + autoPursuitMailTemplateMap.get(autoPursuitMailTemplate.id).name);
			}
			
		}
	}

	/**
	* ５、複数処理
	*     削除（複数）：成功
	*	  例＝データA：店舗２（１～５回目）→削除
	*		  データB：店舗１（１～２回目）→削除
	*		  データC：店舗１（３～５回目）→削除
	*		  データD：店舗２（６～８回目）→削除
	*		  データE：店舗１（６～８回目）→削除
	*/
	@isTest static void pluralDeleteSuccessTest(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord1 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		Shop__c shopRecord2 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗２' LIMIT 1];
		System.runAs(thisUser) {
			// ★事前データ登録★
			// 自動追客メールテンプレート既存データ１
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストA',
				Start__c	='1', // 開始
				End__c		='5', // 終了
				Shop__c		=shopRecord2.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ２
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストB',
				Start__c	='1', // 開始
				End__c		='2', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ３
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate3 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストC',
				Start__c	='3', // 開始
				End__c		='5', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ３
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate4 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストD',
				Start__c	='6', // 開始
				End__c		='8', // 終了
				Shop__c		=shopRecord2.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 自動追客メールテンプレート既存データ３
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate5 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストE',
				Start__c	='6', // 開始
				End__c		='8', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 登録
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = new List<AutoPursuitMailTemplate__c>{
				duplicationAutoPursuitMailTemplate1,duplicationAutoPursuitMailTemplate2,duplicationAutoPursuitMailTemplate3,
				duplicationAutoPursuitMailTemplate4,duplicationAutoPursuitMailTemplate5
			};
			insert autoPursuitMailTemplateList;

			// ★本実行★
			Test.startTest();

			delete autoPursuitMailTemplateList;
			Test.stopTest();

			// ★実行結果確認★
			// 削除（複数）：成功
			List<AutoPursuitMailTemplate__c> afterAutoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c];
			System.assertEquals(0, afterAutoPursuitMailTemplateList.size(), '削除（複数）：成功エラー');
		}
	}

	/**
	* ６、複数処理
	*     削除（複数）：エラー
	*     エラーとなり、データが削除されないこと
	*	  例＝データA：店舗２（１～５回目）→削除（エラー）
	*		  データB：店舗１（６～８回目）→削除
	*		  データC：店舗１（１～２回目）→削除
	*		  データD：店舗２（６～８回目）
	*		  データE：店舗１（３～５回目）→削除（エラー）
	*/
	@isTest static void pluralDeleteErrorTest(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord1 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		Shop__c shopRecord2 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗２' LIMIT 1];
		System.runAs(thisUser) {
			// ★事前データ登録★
			// データA：店舗２（１～５回目）→削除（エラー）
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストA',
				Start__c	='1', // 開始
				End__c		='5', // 終了
				Shop__c		=shopRecord2.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// データB：店舗１（６～８回目）→削除
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストB',
				Start__c	='6', // 開始
				End__c		='8', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// データC：店舗１（１～２回目）→削除
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate3 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストC',
				Start__c	='1', // 開始
				End__c		='2', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// データD：店舗２（６～８回目）
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate4 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストD',
				Start__c	='6', // 開始
				End__c		='8', // 終了
				Shop__c		=shopRecord2.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// データE：店舗１（３～５回目）→削除（エラー）
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate5 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストE',
				Start__c	='3', // 開始
				End__c		='5', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// 登録
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = new List<AutoPursuitMailTemplate__c>{
				duplicationAutoPursuitMailTemplate1,duplicationAutoPursuitMailTemplate2,duplicationAutoPursuitMailTemplate3,
				duplicationAutoPursuitMailTemplate4,duplicationAutoPursuitMailTemplate5
			};
			insert autoPursuitMailTemplateList;
			List<AutoPursuitMailTemplate__c> deletePursuitMailTemplateList= [SELECT Id,RecordTypeId,name,Start__c,End__c,Shop__c,SendTarget__c,SendInterval__c FROM AutoPursuitMailTemplate__c WHERE name != 'テストD' ORDER BY name];

			// ★本実行★
			Test.startTest();
			Exception ex;
			try {
				delete deletePursuitMailTemplateList;
			} catch (Exception e) {
				ex = e;
			}

			Test.stopTest();

			// ★実行結果確認★
			// エラーとなり、データが削除されないこと
			List<AutoPursuitMailTemplate__c> selectAutoPursuitMailTemplateList = [SELECT Id,RecordTypeId,name,Start__c,End__c,Shop__c,SendTarget__c,SendInterval__c FROM AutoPursuitMailTemplate__c ORDER BY name];

			// 件数
			System.assertEquals(5, selectAutoPursuitMailTemplateList.size(), '削除（複数）：エラー件数＝' + selectAutoPursuitMailTemplateList.size());
			for (AutoPursuitMailTemplate__c deleteAutoPursuitMailTemplate : deletePursuitMailTemplateList) {
				for (AutoPursuitMailTemplate__c selectAutoPursuitMailTemplate : selectAutoPursuitMailTemplateList) {
					if (selectAutoPursuitMailTemplate.name =='テストA' && deleteAutoPursuitMailTemplate.name == 'テストA') {
						System.assertEquals(deleteAutoPursuitMailTemplate, selectAutoPursuitMailTemplate, '削除（複数）：エラー='+selectAutoPursuitMailTemplate.id + '：件名＝' + selectAutoPursuitMailTemplate.name);
					}else if(selectAutoPursuitMailTemplate.name =='テストD' && deleteAutoPursuitMailTemplate.name == 'テストD'){
						System.assertEquals(deleteAutoPursuitMailTemplate, selectAutoPursuitMailTemplate, '削除（複数）：エラー='+selectAutoPursuitMailTemplate.id + '：件名＝' + selectAutoPursuitMailTemplate.name);
					}else if(selectAutoPursuitMailTemplate.name =='テストE' && deleteAutoPursuitMailTemplate.name == 'テストE'){
						System.assertEquals(deleteAutoPursuitMailTemplate, selectAutoPursuitMailTemplate, '削除（複数）：エラー='+selectAutoPursuitMailTemplate.id + '：件名＝' + selectAutoPursuitMailTemplate.name);	
					}
				}
			}
			
		}
	}

	/**
	* １、複数処理
	*     新規、更新、削除：成功
	*     エラーとならず処理が完了すること
	*       データA：店舗２（１～５回目）　→削除
	*       データB：店舗１（６～８回目）　→更新：店舗１（１～２回目）
	*       データC：店舗１（１～８回目）　→更新：全社共通（１～４回目）
	*       データD：店舗２（１～１５回目）→新規登録
	*       データE：店舗１（３～５回目）　→新規登録
	*/
	@isTest static void compoundingSuccessTest(){
		User thisUser = [SELECT Id FROM User WHERE UserName = 'ippanUser@test.com'];
		Shop__c shopRecord1 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗１' LIMIT 1];
		Shop__c shopRecord2 =[SELECT Id FROM Shop__c WHERE Name = 'テスト店舗２' LIMIT 1];
		System.runAs(thisUser) {
			// ★本実行★
			// データA：店舗２（１～５回目）
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate1 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストA',
				Start__c	='1', // 開始
				End__c		='5', // 終了
				Shop__c		=shopRecord2.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// データB：店舗１（６～８回目）
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate2 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストB',
				Start__c	='6', // 開始
				End__c		='8', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// データC：店舗１（１～８回目）
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate3 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストC',
				Start__c	='1', // 開始
				End__c		='8', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);

			// 登録
			List<AutoPursuitMailTemplate__c> autoPursuitMailTemplateList = new List<AutoPursuitMailTemplate__c>{
				duplicationAutoPursuitMailTemplate1,duplicationAutoPursuitMailTemplate2,duplicationAutoPursuitMailTemplate3
			};
			insert autoPursuitMailTemplateList;
			List<AutoPursuitMailTemplate__c> beforePursuitMailTemplateList= [SELECT Id,RecordTypeId,name,Start__c,End__c,Shop__c,SendTarget__c,SendInterval__c FROM AutoPursuitMailTemplate__c ORDER BY name];

			// ★本実行★
			Test.startTest();

			// 更新データ
			for (AutoPursuitMailTemplate__c autoPursuitMailTemplate : autoPursuitMailTemplateList) {
				if (autoPursuitMailTemplate.name =='テストB'){
					// データB：店舗１（６～８回目）→店舗１（１～２回目）
					autoPursuitMailTemplate.Start__c = '1';
					autoPursuitMailTemplate.End__c = '2';
				}else if (autoPursuitMailTemplate.name =='テストC') {
					// データC：店舗１（１～８回目）→全社共通（１～４回目）
					autoPursuitMailTemplate.End__c = '4';
					autoPursuitMailTemplate.Shop__c = null;
					autoPursuitMailTemplate.SendTarget__c = CommonConst.PURSUIT_SEND_TARGET_WHOLE_COMPANY;
				}
			}

			// 登録データ
			// データD：店舗２（１～１５回目）
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate4 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストD',
				Start__c	='1', // 開始
				End__c		='15', // 終了
				Shop__c		=shopRecord2.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			// データE：店舗１（３～５回目）
			AutoPursuitMailTemplate__c duplicationAutoPursuitMailTemplate5 =new AutoPursuitMailTemplate__c(
				RecordTypeId=RECORDTYPE_ID_MAIL, // レコードタイプ
				name		='テストE',
				Start__c	='3', // 開始
				End__c		='5', // 終了
				Shop__c		=shopRecord1.id,//	店舗
				SendTarget__c	=CommonConst.PURSUIT_SEND_TARGET_SHOP,// 送信対象
				SendInterval__c		='1'// 配信間隔
			);
			autoPursuitMailTemplateList.add(duplicationAutoPursuitMailTemplate4);
			autoPursuitMailTemplateList.add(duplicationAutoPursuitMailTemplate5);

			// 登録、更新
			upsert autoPursuitMailTemplateList;

			// 削除
			delete duplicationAutoPursuitMailTemplate1;

			Test.stopTest();


			// ★実行結果確認★
			// 処理後取得
			List<AutoPursuitMailTemplate__c> selectDeleteAutoPursuitMailTemplateList = [SELECT Id FROM AutoPursuitMailTemplate__c WHERE name = 'テストA'];
			List<AutoPursuitMailTemplate__c> selectInsertAutoPursuitMailTemplateList = [SELECT Id,RecordTypeId,name,Start__c,End__c,Shop__c,SendTarget__c,SendInterval__c FROM AutoPursuitMailTemplate__c WHERE name IN('テストD','テストE') ORDER BY name];
			Map<Id,AutoPursuitMailTemplate__c> selectUpdateAutoPursuitMailTemplateMap = new Map<Id,AutoPursuitMailTemplate__c>([SELECT Id,RecordTypeId,name,Start__c,End__c,Shop__c,SendTarget__c,SendInterval__c FROM AutoPursuitMailTemplate__c WHERE name IN('テストB','テストC') ORDER BY name]);

			// エラーとならず処理が完了すること
			System.assertEquals(0, selectDeleteAutoPursuitMailTemplateList.size(), '複数処理（削除）：エラー');

			System.assertEquals(2, selectInsertAutoPursuitMailTemplateList.size(), '複数処理（登録）：エラー='+selectInsertAutoPursuitMailTemplateList.size());

			for (AutoPursuitMailTemplate__c beforePursuitMailTemplate : beforePursuitMailTemplateList) {
				if (beforePursuitMailTemplate.name == 'テストB') {
					System.assertNotEquals(beforePursuitMailTemplate.Start__c, selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).Start__c, '複数処理（更新）：エラー開始='+selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).Start__c + '：件名＝' + selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).name);	
					System.assertNotEquals(beforePursuitMailTemplate.End__c, selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).End__c, '複数処理（更新）：エラー終了='+selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).End__c + '：件名＝' + selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).name);
				}else if(beforePursuitMailTemplate.name == 'テストC') {
					System.assertNotEquals(beforePursuitMailTemplate.End__c, selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).End__c, '複数処理（更新）：エラー終了='+selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).End__c + '：件名＝' + selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).name);
					System.assertNotEquals(beforePursuitMailTemplate.shop__c, selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).shop__c, '複数処理（更新）：エラー店舗='+selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).shop__c + '：件名＝' + selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).name);	
					System.assertNotEquals(beforePursuitMailTemplate.SendTarget__c, selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).SendTarget__c, '複数処理（更新）：エラー送信対象='+selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).SendTarget__c + '：件名＝' + selectUpdateAutoPursuitMailTemplateMap.get(beforePursuitMailTemplate.id).name);	
				}
			}
			
		}
	}
}