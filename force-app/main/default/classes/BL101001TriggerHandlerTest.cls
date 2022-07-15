// LINE会員トリガテストクラス
@isTest 
private class BL101001TriggerHandlerTest {

	// テスト日付
	private static Date setDate =  Date.newInstance(2022, 4, 1);

    // テストに使用するレコードを作成する
    @TestSetup static void Setting(){
        //標準プロファイルを取得
		Id profileId = [SELECT Id FROM Profile WHERE Name = 'システム管理者'].Id;

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

		// カスタム設定
		SystemConfig__c testSystemConfig = new SystemConfig__c();
		testSystemConfig.IsSkipTrigger__c = true;
		testSystemConfig.TestDate__c = setDate;
		insert testSystemConfig;

		System.runAs(thisUser) {
			//ユーザの登録
		   User testUser = new User(LastName = 'testuser'	//姓
									,Alias =  'alias'	//別名
									,Email = 'BL101001TriggerHandlerTest@test.com'	//メール
									,UserName =  'BL101001TriggerHandlerTest@test.com'	//ユーザ名
									,CommunityNickname ='テストニックネーム'	//ニックネーム
									,EmailEncodingKey = 'ISO-2022-JP'	//メールの文字コード
									,TimeZoneSidKey = 'Asia/Tokyo'	//タイムゾーン
									,LocaleSidKey = 'ja_JP'	//地域
									,LanguageLocaleKey= 'ja'	//言語
									,ProfileId = profileId	//プロファイルID
			);
			insert testUser;
		}

		// LINE会員登録
		LineMember__c lineMember = new LineMember__c(Name = '既存LINE会員' , LineId__c= 'Uf124585fafd38f4337a2434830d55000'); 
		insert lineMember;

		// スキップフラグを戻す
		testSystemConfig.IsSkipTrigger__c = false;
		update testSystemConfig;
    }

	/**
	* LINE会員
	* 新規登録
	* LINE会員に紐づいた、対応が新規登録されること
	*/
	@istest static void insertLineMember(){
		// 管理者
		User testuser = [SELECT Id FROM User WHERE LastName = 'testuser'];
		System.runAs(testuser) {
			// LINE会員の新規登録
			LineMember__c lineMember = new LineMember__c(Name = '新規登録LINE会員' , LineId__c= 'Uf124585fafd38f4337a2434830d55001'); 
			Test.startTest();
			insert lineMember;
			Test.stopTest();

			// LINE会員に紐づいた、対応が新規登録されること
			Correspond__c correspond = [SELECT Id,EventDateTime__c,Event__c,FirstInquiryMeans__c,IsBrowseFlg__c,IsSupportedListShow__c,ListViewDate__c,Status__c,StaffSupportedFlg__c,IsEchoNotCalculation__c,IsVisitNotCalculation__c,FirstVisitReservationCancelFlg__c,VisitReservationFlag__c,ExactConditionMatch__c,AppointmentReceiptNoMaintenance__c,eventStatus__c,AutomaticReplyAfterPursuitFlg__c,IsUnnecessaryEchoAggregation__c,LineFriendAddDate__c,LineMember__c,FirstLineAddFlg__c
				FROM Correspond__c
				WHERE LineMember__c = :lineMember.id 
			];
			System.assertNotEquals(correspond.Id , null,'新規登録：対応登録有無');	// 対応ID
			System.assertEquals(correspond.EventDateTime__c.date() , setDate,'	新規登録：イベント時刻');	// イベント時刻
			System.assertEquals(correspond.Event__c	,CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD,'	新規登録：イベント');	// イベント（LINE追加）
			System.assertEquals(correspond.FirstInquiryMeans__c	,null,'	新規登録：初回問合せ方法');	// 初回問合せ方法
			System.assertEquals(correspond.IsBrowseFlg__c,true,'新規登録：閲覧フラグ');	// 閲覧フラグ
			System.assertEquals(correspond.IsSupportedListShow__c,true,'新規登録：対応確認');	// 対応確認
			System.assertEquals(correspond.ListViewDate__c.date() , CommonConst.LAST_DATE.date(),'新規登録：一覧表示日時');	// 一覧表示日時
			System.assertEquals(correspond.Status__c,CommonConst.CORRESPOND_STATUS_NOTSUPPORTED,'	新規登録：ステータス');	// ステータス
			System.assertEquals(correspond.StaffSupportedFlg__c	,true,'	新規登録：スタッフ対応フラグ');	// スタッフ対応フラグ
			System.assertEquals(correspond.IsEchoNotCalculation__c	,false,'新規登録：反響数非計算フラグ');	// 反響数非計算フラグ
			System.assertEquals(correspond.IsVisitNotCalculation__c	,false,'新規登録：来店数非計算フラグ');	// 来店数非計算フラグ
			System.assertEquals(correspond.FirstVisitReservationCancelFlg__c,false,'新規登録：初回来店予約キャンセルフラグ');	// 初回来店予約キャンセルフラグ
			System.assertEquals(correspond.VisitReservationFlag__c	,false,'新規登録：来店予約フラグ');	// 来店予約フラグ
			System.assertEquals(correspond.ExactConditionMatch__c	,CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_NO,'	新規登録：条件完全一致');	// 条件完全一致
			System.assertEquals(correspond.AppointmentReceiptNoMaintenance__c,false,'新規登録：来店受付メンテ不要');	// 来店受付メンテ不要
			System.assertEquals(correspond.eventStatus__c	,CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD,'	新規登録：イベント（ステータス）');	// イベント（ステータス）
			System.assertEquals(correspond.AutomaticReplyAfterPursuitFlg__c	,false,'新規登録：自動返信後追客フラグ');	// 自動返信後追客フラグ
			System.assertEquals(correspond.IsUnnecessaryEchoAggregation__c	,false,'新規登録：反響集約不要フラグ');	// 反響集約不要フラグ
			System.assertEquals(correspond.LineFriendAddDate__c.date() , setDate,'新規登録：LINEお友達登録日時');// LINEお友達登録日時	
			System.assertEquals(correspond.LineMember__c,lineMember.Id,'新規登録：LINE会員ID');	// LINE会員ID
			System.assertEquals(correspond.FirstLineAddFlg__c,true,'	新規登録：初回LINE追加フラグ');	// 初回LINE追加フラグ
			
		}
	}

	/**
	* LINE会員
	* 更新
	* LINE会員に紐づいた、対応が作成されないこと
	*/
	@istest static void updateLineMember(){
		// 管理者
		User testuser = [SELECT Id FROM User WHERE LastName = 'testuser'];
		System.runAs(testuser) {
			// LINE会員の更新
			LineMember__c lineMember = [SELECT ID,Status__c FROM LineMember__c WHERE LineId__c= 'Uf124585fafd38f4337a2434830d55000' LIMIT 1]; 
			lineMember.Status__c = CommonConst.LINE_MEMBER_STATUS_DONE_REPLIED;	// ステータスを設定
			Test.startTest();
			update lineMember;
			Test.stopTest();

			// LINE会員に紐づいた、対応が作成されないこと
			List<Correspond__c> correspondList = [SELECT Id 
				FROM Correspond__c
				WHERE LineMember__c = :lineMember.id 
			];

			System.assertEquals(correspondList.size() , 0,'更新：対応登録有無');	// 対応ID
			
		}
	}

	/**
	* LINE会員
	* 削除
	* 対応が作成されないこと
	*/
	@istest static void deleteLineMember(){
		// 管理者
		User testuser = [SELECT Id FROM User WHERE LastName = 'testuser'];
		System.runAs(testuser) {
			
			LineMember__c lineMember = [SELECT ID,Status__c FROM LineMember__c WHERE LineId__c= 'Uf124585fafd38f4337a2434830d55000' LIMIT 1]; 
			Test.startTest();
			// 削除
			delete lineMember;
			Test.stopTest();

			// 対応が作成されないこと
			List<Correspond__c> correspondList = [SELECT Id 
				FROM Correspond__c
				WHERE LineMember__c = :lineMember.id 
			];

			System.assertEquals(correspondList.size() , 0,'削除：対応登録有無');// 対応
			
		}
	}

	/**
	* LINE会員
	* 新規登録（複数）
	* LINE会員に紐づいた、対応が各LINE会員に新規登録されること
	*/
	@istest static void pluralInsertLineMember(){
		// 管理者
		User testuser = [SELECT Id FROM User WHERE LastName = 'testuser'];
		System.runAs(testuser) {
			// LINE会員の新規登録
			LineMember__c lineMember1 = new LineMember__c(Name = '新規登録LINE会員１' , LineId__c= 'Uf124585fafd38f4337a2434830d55001'); 
			LineMember__c lineMember2 = new LineMember__c(Name = '新規登録LINE会員２' , LineId__c= 'Uf124585fafd38f4337a2434830d55002'); 
			LineMember__c lineMember3 = new LineMember__c(Name = '新規登録LINE会員３' , LineId__c= 'Uf124585fafd38f4337a2434830d55003'); 
			LineMember__c lineMember4 = new LineMember__c(Name = '新規登録LINE会員４' , LineId__c= 'Uf124585fafd38f4337a2434830d55004'); 
			List<LineMember__c> lineMemberList = new List<LineMember__c>{lineMember1,lineMember2,lineMember3,lineMember4};
			Test.startTest();
			insert lineMemberList;
			Test.stopTest();

			// LINE会員に紐づいた、対応が新規登録されること
			List<Correspond__c> correspondList = [SELECT Id,EventDateTime__c,Event__c,FirstInquiryMeans__c,IsBrowseFlg__c,IsSupportedListShow__c,ListViewDate__c,Status__c,StaffSupportedFlg__c,IsEchoNotCalculation__c,IsVisitNotCalculation__c,FirstVisitReservationCancelFlg__c,VisitReservationFlag__c,ExactConditionMatch__c,AppointmentReceiptNoMaintenance__c,eventStatus__c,AutomaticReplyAfterPursuitFlg__c,IsUnnecessaryEchoAggregation__c,LineFriendAddDate__c,LineMember__c,FirstLineAddFlg__c
				FROM Correspond__c
			];

			for(Correspond__c correspond : correspondList){
				Boolean isMatchflag = false;
				for (LineMember__c lineMember : lineMemberList) {
					if (correspond.LineMember__c != lineMember.Id) {
						continue;
					}
					System.assertNotEquals(correspond.Id , null,'新規登録：対応登録有無');	// 対応ID
					System.assertEquals(correspond.EventDateTime__c.date() , setDate,'	新規登録：イベント時刻');	// イベント時刻
					System.assertEquals(correspond.Event__c	,CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD,'	新規登録：イベント');	// イベント（LINE追加）
					System.assertEquals(correspond.FirstInquiryMeans__c	,null,'	新規登録：初回問合せ方法');	// 初回問合せ方法
					System.assertEquals(correspond.IsBrowseFlg__c,true,'新規登録：閲覧フラグ');	// 閲覧フラグ
					System.assertEquals(correspond.IsSupportedListShow__c,true,'新規登録：対応確認');	// 対応確認
					System.assertEquals(correspond.ListViewDate__c.date() , CommonConst.LAST_DATE.date(),'新規登録：一覧表示日時');	// 一覧表示日時
					System.assertEquals(correspond.Status__c,CommonConst.CORRESPOND_STATUS_NOTSUPPORTED,'	新規登録：ステータス');	// ステータス
					System.assertEquals(correspond.StaffSupportedFlg__c	,true,'	新規登録：スタッフ対応フラグ');	// スタッフ対応フラグ
					System.assertEquals(correspond.IsEchoNotCalculation__c	,false,'新規登録：反響数非計算フラグ');	// 反響数非計算フラグ
					System.assertEquals(correspond.IsVisitNotCalculation__c	,false,'新規登録：来店数非計算フラグ');	// 来店数非計算フラグ
					System.assertEquals(correspond.FirstVisitReservationCancelFlg__c,false,'新規登録：初回来店予約キャンセルフラグ');	// 初回来店予約キャンセルフラグ
					System.assertEquals(correspond.VisitReservationFlag__c	,false,'新規登録：来店予約フラグ');	// 来店予約フラグ
					System.assertEquals(correspond.ExactConditionMatch__c	,CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_NO,'	新規登録：条件完全一致');	// 条件完全一致
					System.assertEquals(correspond.AppointmentReceiptNoMaintenance__c,false,'新規登録：来店受付メンテ不要');	// 来店受付メンテ不要
					System.assertEquals(correspond.eventStatus__c	,CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD,'	新規登録：イベント（ステータス）');	// イベント（ステータス）
					System.assertEquals(correspond.AutomaticReplyAfterPursuitFlg__c	,false,'新規登録：自動返信後追客フラグ');	// 自動返信後追客フラグ
					System.assertEquals(correspond.IsUnnecessaryEchoAggregation__c	,false,'新規登録：反響集約不要フラグ');	// 反響集約不要フラグ
					System.assertEquals(correspond.LineFriendAddDate__c.date() , setDate,'新規登録：LINEお友達登録日時');// LINEお友達登録日時	
					System.assertEquals(correspond.LineMember__c,lineMember.Id,'新規登録：LINE会員ID');	// LINE会員ID
					System.assertEquals(correspond.FirstLineAddFlg__c,true,'	新規登録：初回LINE追加フラグ');	// 初回LINE追加フラグ
					isMatchflag = true;
				}
				if (!isMatchflag) {
					// 登録で対応が作成されないことがあり得ないので無理やりエラーにする。
					System.assertEquals(isMatchflag , true,'新規登録（複数）：対応作成エラー');
				}
			}
			System.assertEquals(correspondList.size() , lineMemberList.size(),'新規登録（複数）：件数');	// 件数

		}
	}
}