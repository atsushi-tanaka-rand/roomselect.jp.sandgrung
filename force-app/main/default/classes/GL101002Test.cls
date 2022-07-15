/**
 * LINEユーザ一覧画面テスト
 */
@isTest

// -----------------------------------------------------------------------------------------------
// データの作成
// -----------------------------------------------------------------------------------------------
public with sharing class GL101002Test {
	public static final String USER_NAME = 'ippanUseGL101002Testr@test.com';	// ユーザ名を一意にする 2022.05.25 No0827 対応で変更
	// ▼ 2022.05.25 No0827 対応で追加
	public static Datetime nowDateTime = CommonUtil.getNow();	// テスト用共通日付 
	static Map<Integer, LineMember__c> shopLneMap; // 検索時の一覧
	// ▲ 2022.05.25 No0827 対応で追加

	/**
	 * テストに使用するレコードの作成
	 */
	@TestSetup static void setting(){
		//標準プロファイルを取得
		Id profileId = [SELECT Id FROM Profile WHERE Name = '一般ユーザ'].Id;

		// ▼ 2022.05.25 No0827 対応で追加
		// カスタム設定
		SystemConfig__c systemConfig = new SystemConfig__c(
			IsSkipTrigger__c = true // トリガスキップ
			, TestDate__c 	 = Date.newInstance(2022, 4, 1)	// テスト日付設定
		);
		insert systemConfig;
		// ▲ 2022.05.25 No0827 対応で追加

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		
		System.runAs(thisUser) {
			//ユーザの登録
		   User testUser = new User(LastName = 'ippanUser'					 //姓
									,Alias =  'alias'						   //別名
									,Email = 'ippanUseGL101002Testr@test.com'	//メール
									,UserName =  USER_NAME					  //ユーザ名
									,CommunityNickname ='テストニックネーム'	 //ニックネーム
									,EmailEncodingKey = 'ISO-2022-JP'		   //メールの文字コード
									,TimeZoneSidKey = 'Asia/Tokyo'			  //タイムゾーン
									,LocaleSidKey = 'ja_JP'					 //地域
									,LanguageLocaleKey= 'ja'					//言語
									,ProfileId = profileId					  //プロファイルID
			);
			insert testUser;
		}
		User testUser =  [SELECT Id FROM User WHERE UserName = :USER_NAME];

		// 取引先
		Account accountRecord = new Account(Name = 'テスト太郎'					 //取引先名
		);
		insert AccountRecord;

		// LINE会員
		LineMember__c lineMember = new LineMember__c(Name = 'テスト太郎'				 // LINE名
													 , Account__c   = AccountRecord.Id	   // 取引先
													 , Status__c	= CommonConst.LINE_MEMBER_STATUS_NOT_REPLIED	// ステータス
													 , LineId__c	= '000111222'   // LINE ID
		);
		insert LineMember;

		//▼ 2022.04.25 No0804 対応で追加 ▼ 2022.05.25 No0827 対応で変更_ともだち追加時刻を設定
		// 対応１＿ともだち追加時刻：2022/ 4/ 1  0:00
		// 対応２＿ともだち追加時刻：2022/ 3/31  1:01
		// 対応３＿ともだち追加時刻：2022/ 3/31  1:00
		// 対応４＿ともだち追加時刻：2022/ 3/31 22:00
		// 対応５＿ともだち追加時刻：無
		// 対応６＿ともだち追加時刻：2022/ 3/ 1  0:00
		// 対応７＿ともだち追加時刻：2022/ 3/ 1  1:00
		// 対応８＿ともだち追加時刻：2022/ 3/31 23:00
		// 対応９＿ともだち追加時刻：2022/ 4/ 1  0:00
		LineMember__c lineMember1 = new LineMember__c(Name = '対応１' , LineId__c= 'Uf124585fafd38f4337a2434830d55001' , AddFriendTime__c = nowDateTime); 
		LineMember__c lineMember2 = new LineMember__c(Name = '対応２' , LineId__c= 'Uf124585fafd38f4337a2434830d55002' , AddFriendTime__c = DateTime.newInstance(2022, 3,31, 1, 1, 0) ); 
		LineMember__c lineMember3 = new LineMember__c(Name = '対応３' , LineId__c= 'Uf124585fafd38f4337a2434830d55003' , AddFriendTime__c = DateTime.newInstance(2022, 3,31, 1, 0, 0) ); 
		LineMember__c lineMember4 = new LineMember__c(Name = '対応４' , LineId__c= 'Uf124585fafd38f4337a2434830d55004' , AddFriendTime__c = DateTime.newInstance(2022, 3,31,22, 0, 0) ); 
		LineMember__c lineMember5 = new LineMember__c(Name = '対応５' , LineId__c= 'Uf124585fafd38f4337a2434830d55005' ); 
		LineMember__c lineMember6 = new LineMember__c(Name = '対応６' , LineId__c= 'Uf124585fafd38f4337a2434830d55006' , AddFriendTime__c = DateTime.newInstance(2022, 3, 1, 0, 0, 0) ); 
		LineMember__c lineMember7 = new LineMember__c(Name = '対応７' , LineId__c= 'Uf124585fafd38f4337a2434830d55007' , AddFriendTime__c = DateTime.newInstance(2022, 3, 1, 1, 0, 0) ); 
		LineMember__c lineMember8 = new LineMember__c(Name = '対応８' , LineId__c= 'Uf124585fafd38f4337a2434830d55008' , AddFriendTime__c = DateTime.newInstance(2022, 3,31,23, 0, 0) ); 
		LineMember__c lineMember9 = new LineMember__c(Name = '対応９' , LineId__c= 'Uf124585fafd38f4337a2434830d55009' , AddFriendTime__c = nowDateTime); 
		insert new List<LineMember__c>{lineMember1,lineMember2,lineMember3,lineMember4,lineMember5,lineMember6,lineMember7,lineMember8,lineMember9}; 
		//▲ 2022.04.25 No0804 対応で追加 ▲ 2022.05.25 No0827 

		 // 店舗データ
		 Shop__c shopRecord = new Shop__c(Name	 = '店舗ユーザテスト_港区'	 // 店舗名
		);
		insert ShopRecord;
		//▼ 2022.04.25 No0804 対応で追加
		Shop__c shopRecordA = new Shop__c(Name	 = '店舗A'	 // 店舗名
		);
		Shop__c shopRecordB = new Shop__c(Name	 = '店舗B'	 // 店舗名
		);
		insert ShopRecordA;
		insert ShopRecordB;
		//▲ 2022.04.25 No0804 対応で追加

		 // 組織階層レコード
		 OrganizationHierarchy__c orgRecord = new OrganizationHierarchy__c(
			OrganizationCode__c = '0001',
			OrganizationName__c = '本部',
			HierarchyCode__c = '10',
			HierarchyOrder__c = 1,
			UpperOrganizationHierarchy__c = null,
			ExpandedOrganizationCode__c = '0000_0001',
			Shop__c = ShopRecord.Id
		);
		insert orgRecord;
		//▼ 2022.04.25 No0804 対応で追加
		OrganizationHierarchy__c orgRecord2 = new OrganizationHierarchy__c(
			OrganizationCode__c = '0002',
			OrganizationName__c = '店舗A',
			HierarchyCode__c = '20',
			HierarchyOrder__c = 1,
			UpperOrganizationHierarchy__c = null,
			ExpandedOrganizationCode__c = '0000_0002',
			Shop__c = ShopRecordA.Id
		);
		insert orgRecord2;
		OrganizationHierarchy__c orgRecord3 = new OrganizationHierarchy__c(
			OrganizationCode__c = '0003',
			OrganizationName__c = '店舗B',
			HierarchyCode__c = '30',
			HierarchyOrder__c = 1,
			UpperOrganizationHierarchy__c = null,
			ExpandedOrganizationCode__c = '0000_0003',
			Shop__c = ShopRecordB.Id
		);
		insert orgRecord3;
		//▲ 2022.04.25 No0804 対応で追加
		// 店舗異動データ（ユーザと店舗の紐づけ）
		ShopTransfer__c shopTransferRecord = new ShopTransfer__c(orgzanizationHierarchy__c = orgRecord.id  //組織階層
													,StartDate__c =	Date.valueOf('2020-1-5')			 //開始日
													,EndDate__c   =	Date.valueOf('2999-1-5')			 //終了日
													,Staff__c	 =   testUser.Id						  //ユーザ
													);  
													insert ShopTransferRecord;				   

		// 対応
		Correspond__c correspond = new Correspond__c( AccountId__c	= AccountRecord.Id	  // 取引先
													,EchoShop__c	  = ShopRecord.Id		 // 反響担当店舗
													, LineMember__c   = LineMember.Id		 // LINE会員
		);
		insert Correspond;

		//▼ 2022.04.25 No0804 対応で追加
		// 対応１（反響担当店舗：無   、来店担当店舗：無）
		Correspond__c correspond1 = new Correspond__c( LineMember__c   = LineMember1.Id	,
			Memo__c = '対応１',
			Status__c = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED	// ステータス：未対応 No0768 対応で追加
		);
		// 対応２（反響担当店舗：A店舗、来店担当店舗：無）
		Correspond__c correspond2 = new Correspond__c( LineMember__c   = LineMember2.Id	,
			Memo__c = '対応２' ,
			Status__c = CommonConst.CORRESPOND_STATUS_VISITED,	// ステータス：来店済 No0768 対応で追加
			EchoShop__c = ShopRecordA.Id // 反響担当店舗
		);
		// 対応３（反響担当店舗：無、来店担当店舗：A店舗）
		Correspond__c correspond3 = new Correspond__c(  LineMember__c   = LineMember3.Id,
			Memo__c = '対応３' ,
			Status__c = CommonConst.CORRESPOND_STATUS_PURSUIT,	// ステータス：追客中 No0768 対応で追加
			VisitShop__c = ShopRecordA.Id // 来店担当店舗
		);
		// 対応４（反響担当店舗：A店舗、来店担当店舗：A店舗）
		Correspond__c correspond4 = new Correspond__c( LineMember__c   = LineMember4.Id,
			Memo__c = '対応４' ,
			Status__c = CommonConst.CORRESPOND_STATUS_DEPOSIT,	// ステータス：入金済 No0768 対応で追加
			EchoShop__c  = ShopRecordA.Id, // 反響担当店舗
			VisitShop__c = ShopRecordA.Id  // 来店担当店舗
		);
		// 対応５（反響担当店舗：B店舗、来店担当店舗：無）
		Correspond__c correspond5 = new Correspond__c( LineMember__c   = LineMember5.Id,
			Memo__c = '対応５' ,
			Status__c = CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT,	// ステータス：申込キャンセル後追客中 No0768 対応で追加
			EchoShop__c = ShopRecordB.Id // 反響担当店舗
		);
		// 対応６（反響担当店舗：無、来店担当店舗：B店舗）
		Correspond__c correspond6 = new Correspond__c( LineMember__c   = LineMember6.Id,
			Memo__c = '対応６' ,
			Status__c = CommonConst.CORRESPOND_STATUS_PURSUITHOLD,	// ステータス：追客保留中 No0768 対応で追加
			VisitShop__c = ShopRecordB.Id // 来店担当店舗
		);
		// 対応７（反響担当店舗：B店舗、来店担当店舗：B店舗）
		Correspond__c correspond7 = new Correspond__c( LineMember__c   = LineMember7.Id,
			Memo__c = '対応７' ,
			Status__c = CommonConst.CORRESPOND_STATUS_AGREEMENT,	// ステータス：契約完了 No0768 対応で追加
			EchoShop__c  = ShopRecordB.Id, // 反響担当店舗
			VisitShop__c = ShopRecordB.Id  // 来店担当店舗
		);
		// 対応８（反響担当店舗：A店舗、来店担当店舗：B店舗）
		Correspond__c correspond8 = new Correspond__c( LineMember__c   = LineMember8.Id,
			Memo__c = '対応８' ,
			Status__c = CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION,	// ステータス：反響集約 No0768 対応で追加
			EchoShop__c  = ShopRecordA.Id, // 反響担当店舗
			VisitShop__c = ShopRecordB.Id  // 来店担当店舗
		);
		// 対応９（反響担当店舗：B店舗、来店担当店舗：A店舗）
		Correspond__c correspond9 = new Correspond__c( LineMember__c   = LineMember9.Id,
			Memo__c = '対応９' ,
			Status__c = CommonConst.CORRESPOND_STATUS_CLOSE,	// ステータス：終了 No0768 対応で追加
			EchoShop__c  = ShopRecordB.Id, // 反響担当店舗
			VisitShop__c = ShopRecordA.Id  // 来店担当店舗
		);
		insert new List<Correspond__c>{correspond1, correspond2,correspond3,correspond4,correspond5,correspond6,correspond7,correspond8,correspond9}; 
		//▲ 2022.04.25 No0804 対応で追加

		// LINE履歴
		// レコードの作成と処理の実行を同様のユーザで行うため
		System.runAs(testUser){
			LineHistory__c lineHistory = new LineHistory__c(SendType__c  = CommonConst.LINE_HISTORY_SEND_TYPE_MANAGER			 // 送信区分
														, LineMember__c = LineMember.Id	   // Line会員
			);
			insert LineHistory;
			// ▼ 2022.05.25 No0827 対応で追加_最終受信時刻を設定用
			// 集計する項目：LINE履歴: 送信時刻
			// 検索条件：送信区分 = "顧客"
			// 対応１＿送信時刻（最終受信時刻）：無し
			// 対応２＿送信時刻（最終受信時刻）：2022/3/31   1:00
			// 対応３＿送信時刻（最終受信時刻）：2022/3/31   1:01
			// 対応４＿送信時刻（最終受信時刻）：2022/3/31  23:00
			// 対応５＿送信時刻（最終受信時刻）：2022/4/ 1   0:00
			// 対応６＿送信時刻（最終受信時刻）：2022/3/ 1   1:00
			// 対応７＿送信時刻（最終受信時刻）：2022/3/ 1   0:00
			// 対応８＿送信時刻（最終受信時刻）：2022/3/31  22:00
			// 対応９＿送信時刻（最終受信時刻）：2022/4/ 1   0:00
			LineHistory__c lineHistory1 = new LineHistory__c(LineMember__c = LineMember1.Id ,SendType__c  = CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER);
			LineHistory__c lineHistory2 = new LineHistory__c(LineMember__c = LineMember2.Id ,SendTime__c = DateTime.newInstance(2022, 3,31, 1, 0, 0) ,  SendType__c  = CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER);
			LineHistory__c lineHistory3 = new LineHistory__c(LineMember__c = LineMember3.Id ,SendTime__c = DateTime.newInstance(2022, 3,31, 1, 1, 0) ,  SendType__c  = CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER);
			LineHistory__c lineHistory4 = new LineHistory__c(LineMember__c = LineMember4.Id ,SendTime__c = DateTime.newInstance(2022, 3,31,23, 0, 0) ,  SendType__c  = CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER);
			LineHistory__c lineHistory5 = new LineHistory__c(LineMember__c = LineMember5.Id ,SendTime__c = nowDateTime ,  SendType__c  = CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER);
			LineHistory__c lineHistory6 = new LineHistory__c(LineMember__c = LineMember6.Id ,SendTime__c = DateTime.newInstance(2022, 3, 1, 1, 0, 0) ,  SendType__c  = CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER);
			LineHistory__c lineHistory7 = new LineHistory__c(LineMember__c = LineMember7.Id ,SendTime__c = DateTime.newInstance(2022, 3, 1, 0, 0, 0) ,  SendType__c  = CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER);
			LineHistory__c lineHistory8 = new LineHistory__c(LineMember__c = LineMember8.Id ,SendTime__c = DateTime.newInstance(2022, 3,31,22, 0, 0) ,  SendType__c  = CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER);
			LineHistory__c lineHistory9 = new LineHistory__c(LineMember__c = LineMember9.Id ,SendTime__c = nowDateTime ,  SendType__c  = CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER);
			insert new List<LineHistory__c>{lineHistory1,lineHistory2,lineHistory3,lineHistory4,lineHistory5,lineHistory6,lineHistory7,lineHistory8,lineHistory9}; 
			// ▲ 2022.05.25 No0827 対応で追加
		}

	}

// -----------------------------------------------------------------------------------------------
// メインの画面
// -----------------------------------------------------------------------------------------------
	/**
	 * 検索結果表示
	 */	
	@isTest static void setSearchResultTest() {
		// 検索結果の設定テスト
		//一般ユーザで実行
	   User ippanUser = [SELECT Id 
						   FROM User
						   WHERE LastName = 'ippanUser' 
			   ];

		System.runAs(ippanUser){
			Test.startTest();
			// 初期表示
			PageReference pageRef = Page.GL101002View;
			Test.setCurrentPage(pageRef);

			// 検索条件部の値を変更して検索（検索条件不一致）
			GL101002Controller testController = new GL101002Controller();
			testController.screenLineUser.condUserName = 'Name01';							  // お客様名
			testController.screenLineUser.condPhone	= 'Phone01';							 // 電話番号
			testController.screenLineUser.condLineId	= 'LineId01';						   // LINE ID
			testController.screenLineUser.selectCondStatus	= 'Status01';					 // ステータス
			testController.screenLineUser.selectCondCorrespondShop	= 'CorrespondShop01';	 // 対応店舗
			testController.screenLineUser.selectCondLastReplyer   = 'LastReplayer01';		   // 最終返信者
			testController.searchLineUser();
			Test.stopTest();
		}
	}

	/**
	 * 対応店舗変更処理
	 */
	@isTest static void chgShopTest() {
		 //一般ユーザで実行
	   User ippanUser = [SELECT Id 
							FROM User
							WHERE LastName = 'ippanUser' 
					];

		System.runAs(ippanUser) {
			Test.startTest();
			GL101002Controller testController = new GL101002Controller();
			testController.chgShop();
			Test.stopTest();
		}
	}

	//▼ 2022.04.25 No0804 対応で追加 
	/**
	* 検索押下時、初期表示時
	*     A店舗での検索
	*     規定の対応のみが表示されること
	* No0768 対応の結果に使用
	*/
	@isTest static void searchCorrespondTest1() {
		Shop__c shop =[SELECT ID,Name FROM Shop__c WHERE Name = '店舗A' LIMIT 1]; 
		OrganizationHierarchy__c  organizationHierarchy = [SELECT Id, OrganizationName__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = '店舗A' LIMIT 1 ];
		//一般ユーザで実行
		User ippanUser = [SELECT Id 
			FROM User
			WHERE LastName = 'ippanUser' 
		];

		// ▼ 2022.05.25 No0827 対応で追加
		// 一覧（並びの設定）店舗A
		// １．最終受信日降順、null first
		// ２．ともだち追加時刻降順の順
		shopLneMap = new Map<Integer ,LineMember__c>(); // 店舗Aの検索時の一覧
		List<LineMember__c> lineMemberList = [SELECT Id ,name FROM LineMember__c];
		for (LineMember__c lineMember : lineMemberList) {
			if (lineMember.name == '対応１') {
				shopLneMap.put(1,lineMember);
			}else if (lineMember.name == '対応９') {
				shopLneMap.put(2,lineMember);
			}else if (lineMember.name == '対応４') {
				shopLneMap.put(3,lineMember);
			}else if (lineMember.name == '対応３') {
				shopLneMap.put(4,lineMember);
			}else if (lineMember.name == '対応２') {
				shopLneMap.put(5,lineMember);
			}	
		}
		// ▲ 2022.05.25 No0827 対応で追加

		// 店舗異動を変更する
		ShopTransfer__c shopTransfer = [SELECT ID FROM ShopTransfer__c WHERE Staff__c = :ippanUser.id LIMIT 1 ];
		shopTransfer.OrgzanizationHierarchy__c = organizationHierarchy.id;
		update shopTransfer;
		System.runAs(ippanUser) {
			Test.startTest();
			GL101002Controller testController = new GL101002Controller();
	
			// 初期表示時	// ▼ 2022.05.25 No0827 対応で変更検索件数追加
			checkSearchResultList(testController.screenLineUser,5,shop.Name,'','初期表示');

			testController.screenLineUser.selectCondCorrespondShop = shop.id;
			testController.searchLineUser();
			// 検索ボタン押下	// ▼ 2022.05.25 No0827 対応で変更検索件数追加
			checkSearchResultList(testController.screenLineUser,5,shop.Name,'','検索ボタン押下');
			Test.stopTest();

		}

	}

	/**
	* 検索押下時、初期表示時
	*     B店舗での検索
	*     規定の対応のみが表示されること
	*/
	@isTest static void searchCorrespondTest2() {
		Shop__c shop =[SELECT ID,Name FROM Shop__c WHERE Name = '店舗B' LIMIT 1]; 
		OrganizationHierarchy__c  organizationHierarchy = [SELECT Id, OrganizationName__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = '店舗B' LIMIT 1 ];
		//一般ユーザで実行
		User ippanUser = [SELECT Id 
			FROM User
			WHERE LastName = 'ippanUser' 
		];
		// ▼ 2022.05.25 No0827 対応で追加
		// 一覧（並びの設定）店舗B
		// １．最終受信日降順、null first
		// ２．ともだち追加時刻降順の順
		shopLneMap = new Map<Integer ,LineMember__c>(); // 店舗Aの検索時の一覧
		List<LineMember__c> lineMemberList = [SELECT Id ,name FROM LineMember__c];
		for (LineMember__c lineMember : lineMemberList) {
			if (lineMember.name == '対応１') {
				shopLneMap.put(1,lineMember);
			}else if (lineMember.name == '対応５') {
				shopLneMap.put(2,lineMember);
			}else if (lineMember.name == '対応８') {
				shopLneMap.put(3,lineMember);
			}else if (lineMember.name == '対応６') {
				shopLneMap.put(4,lineMember);
			}else if (lineMember.name == '対応７') {
				shopLneMap.put(5,lineMember);
			}	
		}
		// ▲ 2022.05.25 No0827 対応で追加

		// 店舗異動を変更する
		ShopTransfer__c shopTransfer = [SELECT ID FROM ShopTransfer__c WHERE Staff__c = :ippanUser.id LIMIT 1 ];
		shopTransfer.OrgzanizationHierarchy__c = organizationHierarchy.id;
		update shopTransfer;

		System.runAs(ippanUser) {
			Test.startTest();
			GL101002Controller testController = new GL101002Controller();
	
			// 初期表示時	// ▼ 2022.05.25 No0827 対応で変更検索件数追加
			checkSearchResultList(testController.screenLineUser,5,'',shop.Name,'初期表示');

			testController.screenLineUser.selectCondCorrespondShop = shop.id;
			testController.searchLineUser();

			// 検索ボタン押下	// ▼ 2022.05.25 No0827 対応で変更検索件数追加
			checkSearchResultList(testController.screenLineUser,5,'',shop.Name,'検索ボタン押下');
			Test.stopTest();
		}

	}

	/**
	* 検索押下時
	*     店舗条件無し
	*     全ての対応とLINE会員が表示されること
	* No0768 対応の結果に使用
	*/
	@isTest static void searchCorrespondShopNullTest() {
		Shop__c shopA =[SELECT ID,Name FROM Shop__c WHERE Name = '店舗A' LIMIT 1]; 
		Shop__c shopB =[SELECT ID,Name FROM Shop__c WHERE Name = '店舗B' LIMIT 1]; 
		OrganizationHierarchy__c  organizationHierarchy = [SELECT Id, OrganizationName__c FROM OrganizationHierarchy__c WHERE OrganizationName__c = '店舗B' LIMIT 1 ];
		//一般ユーザで実行
		User ippanUser = [SELECT Id 
			FROM User
			WHERE LastName = 'ippanUser' 
		];
		// ▼ 2022.05.25 No0827 対応で追加
		// 一覧（並びの設定）店舗なし
		// １．最終受信日降順、null first
		// ２．ともだち追加時刻降順の順
		shopLneMap = new Map<Integer ,LineMember__c>(); // 店舗Aの検索時の一覧
		List<LineMember__c> lineMemberList = [SELECT Id ,name FROM LineMember__c];
		for (LineMember__c lineMember : lineMemberList) {
			if (lineMember.name == 'テスト太郎') {
				shopLneMap.put(1,lineMember);
			}else if (lineMember.name == '対応１') {
				shopLneMap.put(2,lineMember);
			}else if (lineMember.name == '対応５') {
				shopLneMap.put(3,lineMember);
			}else if (lineMember.name == '対応９') {
				shopLneMap.put(4,lineMember);
			}else if (lineMember.name == '対応４') {
				shopLneMap.put(5,lineMember);
			}else if (lineMember.name == '対応８') {
				shopLneMap.put(6,lineMember);
			}else if (lineMember.name == '対応３') {
				shopLneMap.put(7,lineMember);
			}else if (lineMember.name == '対応２') {
				shopLneMap.put(8,lineMember);
			}else if (lineMember.name == '対応６') {
				shopLneMap.put(9,lineMember);
			}else if (lineMember.name == '対応７') {
				shopLneMap.put(10,lineMember);
			}	
		}
		// ▲ 2022.05.25 No0827 対応で追加

		
		System.runAs(ippanUser) {
			Test.startTest();
			GL101002Controller testController = new GL101002Controller();
	
			testController.screenLineUser.selectCondCorrespondShop = '';
			testController.searchLineUser();
			// 検索ボタン押下
			checkSearchResultList(testController.screenLineUser,10,shopA.Name,shopB.Name,'検索ボタン押下');
			Test.stopTest();
			
		}
	}

	//-----------------------------------------------------------------以下privateメソッド-----------------------------------------------------------------
	/**
    * LINE会員一覧のリストをチェック（件数比較有）
	* 一覧の表示で、対象の店舗で絞り込まれているかを比較する用
	* @param   List<GL101002Controller.screenLineUser> screenLineUser LINEユーザ一覧
	* @param   Integer count 想定件数
	* @param   String shopNameA 店舗A名
	* @param   String shopNameB 店舗B名
	* @param   String errMsg エラー時のメッセージ
	* @return  無し
    */
    private static void checkSearchResultList(GL101002Controller.ScreenLineUserList screenLineUser,Integer count,String shopNameA,String ShopNameB,String errMsg){
		Integer sortNo = 1;
		for (GL101002Controller.LineUserDetail searchResult : screenLineUser.searchResultList){
			// ▼ 2022.05.25 No0827 対応で追加
			// 順番と対象のデータを比較
			System.assertEquals(shopLneMap.get(sortNo).Name,searchResult.lineName,errMsg+'：表示順=' +sortNo);
			sortNo += 1;
			// ▲ 2022.05.25 No0827 対応で追加
			if(searchResult.lineName == '対応１'){
				// 店舗無の対応が表示されること
				System.assertEquals(null,searchResult.correspondShop,errMsg+'：店舗無='+searchResult.lineName);
			}else if(searchResult.lineName == '対応２' || searchResult.lineName == '対応３' || searchResult.lineName == '対応４' || searchResult.lineName == '対応９'){
				// 表示店舗が来店担当店舗（A店舗）で表示されること
				System.assertEquals(shopNameA,searchResult.correspondShop,errMsg+'：' + shopnameA + '='+searchResult.lineName);
			}else if(searchResult.lineName == '対応５' || searchResult.lineName == '対応６' || searchResult.lineName == '対応７' || searchResult.lineName == '対応８'){
				// 表示店舗が来店担当店舗（B店舗）で表示されること
				System.assertEquals(shopNameB,searchResult.correspondShop,errMsg+'：'+ ShopNameB + '='+searchResult.lineName);
			}
		}
		System.assertEquals(count, screenLineUser.searchResultList.size(),errMsg+'：件数');
	}
	//▲ 2022.04.25 No0804 対応で追加 
}