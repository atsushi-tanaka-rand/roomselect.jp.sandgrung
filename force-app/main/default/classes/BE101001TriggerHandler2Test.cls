//日報集計部品（物件メンテナンス履歴トリガー）のテストクラス
@ isTest
private class BE101001TriggerHandler2Test {

    @TestSetup
    // テストに利用するListを用意する。
    static void Setting(){
        // カスタム設定
        //システム設定を作成（暗号化に使用）
        SystemConfig__c s = new SystemConfig__c(
            HerokuSecretAccessKey__c = 'zF2SKTCj5CnR5TEhXhCLYBKE9x6a6xHN',
            UseAuthority_Portal__c = true,
            ExampleIv__c = '4f63e8b490579073'
            );
        insert s;     
        
        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = 'テスト店舗',
                                         PortalSitePostingDistrict__c = '港区;北区');
		// ▼ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
		Shop__c shopRecord2 = new shop__c(Name = 'テスト店舗2',
                                         PortalSitePostingDistrict__c = '北区');
		// ▲ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
        insert shopRecord;
		insert shopRecord2;

        // 組織階層レコード
        OrganizationHierarchy__c orgRecord1 = new OrganizationHierarchy__c(
            OrganizationCode__c = '0001',
            OrganizationName__c = '本部',
            HierarchyCode__c = '10',
            HierarchyOrder__c = 1,
            UpperOrganizationHierarchy__c = null,
            ExpandedOrganizationCode__c = '0000_0001',
            Shop__c = null
        );
        insert orgRecord1;
		OrganizationHierarchy__c orgRecord2 = new OrganizationHierarchy__c(
			OrganizationCode__c = '0002',
			OrganizationName__c = 'テスト店舗',
			HierarchyCode__c = '20',
			HierarchyOrder__c = 1,
			UpperOrganizationHierarchy__c = orgRecord1.Id,
			ExpandedOrganizationCode__c = '0000_0001_0002',
			Shop__c = shopRecord.Id
		);
		insert orgRecord2;
		// ▼ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
		OrganizationHierarchy__c orgRecord3 = new OrganizationHierarchy__c(
            OrganizationCode__c = '0003',
            OrganizationName__c = 'テスト店舗2',
            HierarchyCode__c = '20',
            HierarchyOrder__c = 1,
            UpperOrganizationHierarchy__c = orgRecord1.Id,
            ExpandedOrganizationCode__c = '0000_0001_0003',
            Shop__c = shopRecord.Id
        );
        insert orgRecord3;
		// ▲ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('システム管理者')];
        System.assert(profiles.size() > 0);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            insert new User(
                UserName = 'BE101001Test1_1@horaguchi.com',
                Email = 'test@example.com',
                LastName = 'test',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
            insert new User(
                UserName = 'BE101001Test1_2@horaguchi.com',
                Email = 'test@example.com',
                LastName = 'test',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
        }
        
		// トリガスキップ（動作軽量化）
		s.IsSkipPropCompareProcess__c = true;
		update s;
        //店舗異動レコード
        List<ShopTransfer__c> ShopTransferList = new List<ShopTransfer__c>();
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'BE101001Test1_1@horaguchi.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = userRecord.id,
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
        ShopTransferList.add(ShopTransferRecord);

        userRecord =  [SELECT Id FROM User WHERE UserName = 'BE101001Test1_2@horaguchi.com'];
        ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = userRecord.id,
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
        ShopTransferList.add(ShopTransferRecord);
        
        
        insert ShopTransferList;

        //2020/9/18追加　取引先
        Account acc = new Account(Name = '取引先',
                                RecordTypeId = CommonUtil.getRecordTypeId('Account',CommonConst.ACCOUNT_RECTYPE_CUSTOMER),
                                IntroMailInfoStatus__c = CommonConst_ptl.INTRODUCTION_SEND);//配信

        insert acc;
        Correspond__c corr = new Correspond__c(AccountId__c = acc.Id ,Status__c = '未対応');
        insert corr;

		// ▼ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
		//建物
		Building__c newBuildingRecord = new Building__c( Name = '新規テスト建物'
			,State__c = '愛知県'
			,City__c = '名古屋市テスト区'
			,Street__c = '5-5');
		insert newBuildingRecord;
		// 物件
        Property__c newPropertyRecord = new Property__c(
            Name = '501',
            Building__c = newBuildingRecord.id,
            RentFee__c = 55000
        );
		insert newPropertyRecord;
		// ポータルサイト
		PortalSite__c portal = new PortalSite__c(
			Name = 'テスぽ',
			Url__c = 'test@co.jp',
			Email__c = 'test@r.co.jp'
		);
        insert portal;
		// ▲ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
        // 空室予約物件
        VacancyReservationProperty__c vacancyReservationProp = new VacancyReservationProperty__c(
            Account__c = acc.Id
        );
        insert vacancyReservationProp;
		// トリガスキップ戻す
		s.IsSkipPropCompareProcess__c = false;
		update s;
    }


    // insertUpdateTest_EchoTotal
    // 反響累計登録と更新の対象となる全パターンテスト
    // ※最初に登録し、同じデータで再度登録を行うことで更新を促す
    @isTest static void insertUpdateTest_EchoTotal(){

        // 対応のListを用意する。
        List<Correspond__c> addCorrespondList = new List<Correspond__c>();
        List<Correspond__c> updCorrespondList = new List<Correspond__c>();

        User userRecord1 =  [SELECT Id FROM User WHERE UserName = 'BE101001Test1_1@horaguchi.com'];
        User userRecord2 =  [SELECT Id FROM User WHERE UserName = 'BE101001Test1_2@horaguchi.com'];
        Correspond__c addCorrespond = new Correspond__c();
        Correspond__c updCorrespond = new Correspond__c();



        // ＜登録用処理＞
        // 1 対応ステータスが反響集約
        addCorrespond = new Correspond__c(
                Status__c = CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION
                ,Memo__c = '反響集約'
        );
        // Listに入れる。
        addCorrespondList.add(addCorrespond);

        // ２ 対応ステータスが来店済
        addCorrespond = new Correspond__c(
                Status__c = CommonConst.CORRESPOND_STATUS_VISITED
                ,Memo__c = '来店済'
        );
        // Listに入れる。
        addCorrespondList.add(addCorrespond);

        // ３ 対応ステータスが入金済
        addCorrespond = new Correspond__c(
                Status__c = CommonConst.CORRESPOND_STATUS_DEPOSIT
                ,Memo__c = '入金済'
        );
        // Listに入れる。
        addCorrespondList.add(addCorrespond);

        // ４ 対応ステータスが未対応
        for (Integer i = 0; i < 7; i++){ 
            addCorrespond = new Correspond__c(
                    Status__c = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED
                    ,Memo__c = '未対応' + i
            );
            // Listに入れる。
            addCorrespondList.add(addCorrespond);
        }

        // ＜登録対象外用処理＞
        // ５　対応ステータスが反響集約　かつ　レコードタイプIDが保証会社
        // 
        addCorrespond = new Correspond__c(
                Status__c = CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION
                ,Memo__c = 'レコードタイプID：保証会社'
        );
        // Listに入れる。
        addCorrespondList.add(addCorrespond);

        // ６　対応ステータスが終了
        // 
        addCorrespond = new Correspond__c(
                Status__c = CommonConst.CORRESPOND_STATUS_CLOSE
                ,Memo__c = 'ステータス：終了'
        );
        // Listに入れる。
        addCorrespondList.add(addCorrespond);

        // insertを実施。
        insert addCorrespondList;

        // OUTPUTが正しく登録されていることを確認する。
        List<EchoTotal__c> outputList = [
                                            SELECT Id
                                            FROM  EchoTotal__c
                                            ];

        // ＜更新用処理＞
       // 対応データを取得
        List<Correspond__c> inputList = [
                                        SELECT Id
                                            , Name
                                            , Memo__c
                                        FROM  Correspond__c
                                        ];
        //20202/9/18 testsetupに対応を1つ追加したため数を12から13に変更してます
        System.assertEquals(12 + 1, inputList.size());

        for (Correspond__c dt : inputList) {
            // 更新確認１
            // 対応ステータスが反響集約で登録されているデータを、
            // 対応ステータスが反響集約のままで更新した場合
            if (dt.Memo__c == '反響集約') {
                updCorrespond = new Correspond__c(
                        Id = dt.Id
                );
                updCorrespondList.add(updCorrespond);
                continue;
            }

            // 更新確認２
            // 対応ステータスが来店済で登録されているデータを、
            // 対応ステータスが来店済のままで更新した場合
            if (dt.Memo__c == '来店済') {
                updCorrespond = new Correspond__c(
                        Id = dt.Id
                );
                updCorrespondList.add(updCorrespond);
                continue;
            }

            // 更新確認３
            // 対応ステータスが来店済で登録されているデータを、
            // 対応ステータスが来店済のままで更新した場合
            if (dt.Memo__c == '入金済') {
                updCorrespond = new Correspond__c(
                        Id = dt.Id
                );
                updCorrespondList.add(updCorrespond);
                continue;
            }

            // 更新確認４
            // 対応ステータスが未対応で登録されているデータを、
            // 対応ステータスを反響集約に変更して更新した場合
            if (dt.Memo__c == '未対応0') {
                updCorrespond = new Correspond__c(
                        Id = dt.Id
                        ,Status__c = CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION
                );
                updCorrespondList.add(updCorrespond);
                continue;
            }

            // 更新確認５
            // 対応ステータスが未対応で登録されているデータを、
            // 対応ステータスを来店済に変更して更新した場合
            if (dt.Memo__c == '未対応1') {
                updCorrespond = new Correspond__c(
                        Id = dt.Id
                        ,Status__c = CommonConst.CORRESPOND_STATUS_VISITED
                );
                updCorrespondList.add(updCorrespond);
                continue;
            }

            // 更新確認６
            // 対応ステータスが未対応で登録されているデータを、
            // 対応ステータスを入金済に変更して更新した場合
            if (dt.Memo__c == '未対応2') {
                updCorrespond = new Correspond__c(
                        Id = dt.Id
                        ,Status__c = CommonConst.CORRESPOND_STATUS_DEPOSIT
                );
                updCorrespondList.add(updCorrespond);
                continue;
            }

            // 更新確認７（残り全部）
            // 対応ステータスが未対応で登録されているデータを、
            // 何も変更せずそのまま更新
            updCorrespond = new Correspond__c(
                    Id = dt.Id
            );
            updCorrespondList.add(updCorrespond);
        }
        // updateを実施。
        update updCorrespondList;
    }

    //対応登録時　対応差分登録テスト　2020/9/18　追加
    @isTest static void insertTest_CorrespondDefference(){
		// ▼ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
		Datetime getNow = CommonUtil.getNow();
		Date getToday = CommonUtil.getToday();
        Account acc = [SELECT id,Name FROM Account WHERE Name = '取引先' LIMIT 1];
		Shop__c Shop = [SELECT id,Name FROM Shop__c WHERE Name = 'テスト店舗' LIMIT 1];
		Shop__c Shop2 = [SELECT id,Name FROM Shop__c WHERE Name = 'テスト店舗2' LIMIT 1];
		User userRecord1 =  [SELECT Id FROM User WHERE UserName = 'BE101001Test1_1@horaguchi.com' LIMIT 1];
        User userRecord2 =  [SELECT Id FROM User WHERE UserName = 'BE101001Test1_2@horaguchi.com' LIMIT 1];
		Property__c testPropertyRecord = [SELECT Id,Name FROM Property__c WHERE Name = '501' LIMIT 1];
		PortalSite__c portalSite = [SELECT Id,Url__c,Name FROM PortalSite__c WHERE Name = 'テスぽ' LIMIT 1];
		// ▲ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない

        Correspond__c insCorr = new Correspond__c(
			AccountId__c = acc.Id ,Status__c = commonconst.CORRESPOND_STATUS_PURSUIT,
			// ▼ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
			Application__c= null, //申込
			AppointmentStartDate__c= getToday, //アポイント開始日0時
			BrowseDate__c= getNow, //閲覧日時
			District__c= '港区', //地区
			EchoShop__c= Shop.id, //反響担当店舗
			EchoStaff__c= userRecord1.id, //担当者（反響）
			VisitShop__c= Shop2.id, //来店担当店舗
			ShopStaff__c= userRecord2.id, //担当者（来店）
			EventDateTime__c= getNow, //イベント時刻
			FirstInquiryMeans__c= commonconst.FIRSTINQUIRYMEANS_MAIL, //初回問合せ方法
			FirstInquiryProperty__c= testPropertyRecord.id, //初回問合せ物件
			FirstVisitReservationCancelFlg__c= false, //初回来店予約キャンセルフラグ
			FirstVisitReservationDate__c= getToday, //初回来店予約日
			IsBrowseFlg__c= false, //閲覧フラグ
			IsEchoNotCalculation__c= false, //反響数非計算フラグ
			IsSupportedListShow__c= true, //対応確認
			IsVisitNotCalculation__c= true, //来店数非計算フラグ
			ListViewDate__c= getNow, //一覧表示日時
			Memo__c= 'めも', //メモ
			PhoneAbsenceDate__c= getNow, //電話不在日時
			PhoneIncomingDate__c= getNow, //電話着信日時
			PhoneOutgoingDate__c= getNow, //電話発信日時
			PortalSiteUrl__c= portalSite.Url__c, //ポータルサイトURL
			PortalSite__c= portalSite.id, //ポータルサイト
			Property__c= testPropertyRecord.id, //物件
			PursuitDissolveDate__c= getNow, //追客解除設定日時（保存用）
			PursuitDissolveSettingDate__c= getNow, //追客解除設定日時
			ReceiveMailDateOther__c= getNow, //メール受信日時（その他）
			ReceiveMailDatePortal__c= getNow, //メール受信日時（ポータル）
			SendMailDate__c= getNow, //メール送信日時
			StaffSupportedFlg__c= true, //スタッフ対応フラグ
			StatusBeforePursuitHold__c= commonconst.CORRESPOND_STATUS_PURSUIT, //追客保留前ステータス
			VisitDate__c= getToday, //来店日（初回）
			VisitReason__c= '紹介', //来店理由（スタッフ欄）
			VisitReservationCancelDate__c= getToday, //来店予約キャンセル日
			VisitReservationFlag__c= true //来店予約フラグ
			// ▲ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
		);
		Test.startTest();
        insert insCorr;
		Test.stopTest();
		// ▼ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
		Correspond__c corr= [
			SELECT id,Name,Status__c
				,AccountId__c,AccountRecordType__c,Application__c,AppointmentStartDate__c,BrowseDate__c,District__c,EchoShopName__c,EchoShop__c,EchoStaffName__c,EchoStaff__c,EventDateTime__c,Event__c,FirstInquiryMeans__c,FirstInquiryProperty__c,FirstVisitReservationCancelFlg__c,FirstVisitReservationDate__c,IsBrowseFlg__c,IsEchoNotCalculation__c,IsSupportedListShow__c,IsVisitNotCalculation__c,ListViewDate__c,Memo__c,PhoneAbsenceDate__c,PhoneIncomingDate__c,PhoneOutgoingDate__c,PortalSiteUrl__c,PortalSite__c,Property__c,PursuitDissolveDate__c,PursuitDissolveSettingDate__c,ReceiveMailDateOther__c,ReceiveMailDatePortal__c,SendMailDate__c,ShopStaffName__c,ShopStaff__c,StaffSupportedFlg__c,StatusBeforePursuitHold__c,VisitDate__c,VisitReason__c,VisitReservationCancelDate__c,VisitReservationFlag__c,VisitShopName__c,VisitShop__c
        	FROM Correspond__c
            WHERE id = :insCorr.id 
			LIMIT 1];
		// ▲ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
		
        List<CorrespondDifference__c> corrDiffList= [
			SELECT id,Name,Status__c,CrudCd__c
				,CorrespondId__c,AccountId__c,AccountRecordType__c,Application__c,AppointmentStartDate__c,BrowseDate__c,District__c,EchoShopName__c,EchoShop__c,EchoStaffName__c,EchoStaff__c,EventDateTime__c,Event__c,FirstInquiryMeans__c,FirstInquiryProperty__c,FirstVisitReservationCancelFlg__c,FirstVisitReservationDate__c,IsBrowseFlg__c,IsEchoNotCalculation__c,IsSupportedListShow__c,IsVisitNotCalculation__c,ListViewDate__c,Memo__c,PhoneAbsenceDate__c,PhoneIncomingDate__c,PhoneOutgoingDate__c,PortalSiteUrl__c,PortalSite__c,Property__c,PursuitDissolveDate__c,PursuitDissolveSettingDate__c,ReceiveMailDateOther__c,ReceiveMailDatePortal__c,SendMailDate__c,ShopStaffName__c,ShopStaff__c,StaffSupportedFlg__c,StatusBeforePursuitHold__c,VisitDate__c,VisitReason__c,VisitReservationCancelDate__c,VisitReservationFlag__c,VisitShopName__c,VisitShop__c
        	FROM CorrespondDifference__c
            WHERE Status__c = :commonconst.CORRESPOND_STATUS_PURSUIT];

        //対応を登録したらクラッドコードCの対応差分が作成されている？
        system.assertEquals('C', corrDiffList[0].CrudCd__c);
		// ▼ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
		// 対応差分の項目が対応を元にセットされていること
		system.assertEquals(corr.iD       , corrDiffList[0].CorrespondId__c);                    //対応Id
		system.assertEquals(corr.AccountId__c          , corrDiffList[0].AccountId__c);          //取引先 
		system.assertEquals(corr.Status__c             , corrDiffList[0].Status__c);             //ステータス
		system.assertEquals(corr.AccountRecordType__c,corrDiffList[0].AccountRecordType__c); //取引先レコードタイプ
		system.assertEquals(corr.Application__c,corrDiffList[0].Application__c); //申込
		system.assertEquals(corr.AppointmentStartDate__c,corrDiffList[0].AppointmentStartDate__c); //アポイント開始日0時
		system.assertEquals(corr.BrowseDate__c,corrDiffList[0].BrowseDate__c); //閲覧日時
		system.assertEquals(corr.District__c,corrDiffList[0].District__c); //地区
		system.assertEquals(corr.EchoShopName__c,corrDiffList[0].EchoShopName__c); //反響担当店舗名
		system.assertEquals(corr.EchoShop__c,corrDiffList[0].EchoShop__c); //反響担当店舗
		system.assertEquals(corr.EchoStaffName__c,corrDiffList[0].EchoStaffName__c); //反響担当者名
		system.assertEquals(corr.EchoStaff__c,corrDiffList[0].EchoStaff__c); //担当者（反響）
		system.assertEquals(corr.EventDateTime__c,corrDiffList[0].EventDateTime__c); //イベント時刻
		system.assertEquals(corr.Event__c,corrDiffList[0].Event__c); //イベント
		system.assertEquals(corr.FirstInquiryMeans__c,corrDiffList[0].FirstInquiryMeans__c); //初回問合せ方法
		system.assertEquals(corr.FirstInquiryProperty__c,corrDiffList[0].FirstInquiryProperty__c); //初回問合せ物件
		system.assertEquals(corr.FirstVisitReservationCancelFlg__c,corrDiffList[0].FirstVisitReservationCancelFlg__c); //初回来店予約キャンセルフラグ
		system.assertEquals(corr.FirstVisitReservationDate__c,corrDiffList[0].FirstVisitReservationDate__c); //初回来店予約日
		system.assertEquals(corr.IsBrowseFlg__c,corrDiffList[0].IsBrowseFlg__c); //閲覧フラグ
		system.assertEquals(corr.IsEchoNotCalculation__c,corrDiffList[0].IsEchoNotCalculation__c); //反響数非計算フラグ
		system.assertEquals(corr.IsSupportedListShow__c,corrDiffList[0].IsSupportedListShow__c); //対応確認
		system.assertEquals(corr.IsVisitNotCalculation__c,corrDiffList[0].IsVisitNotCalculation__c); //来店数非計算フラグ
		system.assertEquals(corr.ListViewDate__c,corrDiffList[0].ListViewDate__c); //一覧表示日時
		system.assertEquals(corr.Memo__c,corrDiffList[0].Memo__c); //メモ
		system.assertEquals(corr.PhoneAbsenceDate__c,corrDiffList[0].PhoneAbsenceDate__c); //電話不在日時
		system.assertEquals(corr.PhoneIncomingDate__c,corrDiffList[0].PhoneIncomingDate__c); //電話着信日時
		system.assertEquals(corr.PhoneOutgoingDate__c,corrDiffList[0].PhoneOutgoingDate__c); //電話発信日時
		system.assertEquals(corr.PortalSiteUrl__c,corrDiffList[0].PortalSiteUrl__c); //ポータルサイトURL
		system.assertEquals(corr.PortalSite__c,corrDiffList[0].PortalSite__c); //ポータルサイト
		system.assertEquals(corr.Property__c,corrDiffList[0].Property__c); //物件
		system.assertEquals(corr.PursuitDissolveDate__c,corrDiffList[0].PursuitDissolveDate__c); //追客解除設定日時（保存用）
		system.assertEquals(corr.PursuitDissolveSettingDate__c,corrDiffList[0].PursuitDissolveSettingDate__c); //追客解除設定日時
		system.assertEquals(corr.ReceiveMailDateOther__c,corrDiffList[0].ReceiveMailDateOther__c); //メール受信日時（その他）
		system.assertEquals(corr.ReceiveMailDatePortal__c,corrDiffList[0].ReceiveMailDatePortal__c); //メール受信日時（ポータル）
		system.assertEquals(corr.SendMailDate__c,corrDiffList[0].SendMailDate__c); //メール送信日時
		system.assertEquals(corr.ShopStaffName__c,corrDiffList[0].ShopStaffName__c); //来店担当者名
		system.assertEquals(corr.ShopStaff__c,corrDiffList[0].ShopStaff__c); //担当者（来店）
		system.assertEquals(corr.StaffSupportedFlg__c,corrDiffList[0].StaffSupportedFlg__c); //スタッフ対応フラグ
		system.assertEquals(corr.StatusBeforePursuitHold__c,corrDiffList[0].StatusBeforePursuitHold__c); //追客保留前ステータス
		system.assertEquals(corr.VisitDate__c,corrDiffList[0].VisitDate__c); //来店日（初回）
		system.assertEquals(corr.VisitReason__c,corrDiffList[0].VisitReason__c); //来店理由（スタッフ欄）
		system.assertEquals(corr.VisitReservationCancelDate__c,corrDiffList[0].VisitReservationCancelDate__c); //来店予約キャンセル日
		system.assertEquals(corr.VisitReservationFlag__c,corrDiffList[0].VisitReservationFlag__c); //来店予約フラグ
		system.assertEquals(corr.VisitShopName__c,corrDiffList[0].VisitShopName__c); //来店担当店舗名
		system.assertEquals(corr.VisitShop__c,corrDiffList[0].VisitShop__c); //来店担当店舗
		// ▲ 2022.03.03 未連携項目追加 No0748_LINE通知が上手く機能していない
    }

    //対応更新時　対応差分登録テスト　2020/9/18　追加
    @isTest static void updateTest_CorrespondDefference(){
        Correspond__c corr = [SELECT id,Name,Status__c FROM Correspond__c WHERE Status__c = '未対応'];
        //ステータスを変更
        corr.Status__c = '追客中';
        update corr;
        CommonUtil.sleep(100);

        List<CorrespondDifference__c> corrDiffList= [SELECT id,Name,Status__c,CrudCd__c
                                            FROM CorrespondDifference__c
                                            WHERE Status__c = '追客中'];

        //対応を登録したらクラッドコードUの追客中の対応差分が作成されている？
        system.assertEquals('U', corrDiffList[0].CrudCd__c);
    }
 
    //対応更新時　対応差分削除テスト　2020/9/18　追加
    @isTest static void deleteTest_CorrespondDefference(){
        Correspond__c corr = [SELECT id,Name,Status__c FROM Correspond__c WHERE Status__c = '未対応'];
        //ステータスを変更
        delete corr;
        CommonUtil.sleep(100);

        List<CorrespondDifference__c> corrDiffList= [SELECT id,Name,Status__c,CrudCd__c
                                            FROM CorrespondDifference__c
                                            WHERE Status__c = '未対応'
                                            AND CrudCd__c = 'D'];

        //対応を登録したらクラッドコードDの対応差分が作成されている？
        system.assertEquals('D', corrDiffList[0].CrudCd__c);
    }   

    // イベント登録処理
    @isTest static void insertTest_CorrespondEvent(){

        List<Correspond__c> corrList = new List<Correspond__c>();

        Account acc = [SELECT id,Name FROM Account WHERE Name = '取引先'];
        Correspond__c corr = new Correspond__c(
            AccountId__c = acc.Id
            , Status__c = '追客中'
            , SendMailDate__c = CommonUtil.getNow()
        );
        corrList.add(corr);

        corr = new Correspond__c(
            AccountId__c = acc.Id
            , Status__c = '追客中'
            , StaffSupportedFlg__c = false
        );
        corrList.add(corr);

        /* 最新日付が対応．閲覧日時、
        次点最新日付が対応．メール受信日時（来店予約）の場合、"来店予約"を表示
        */
        corr = new Correspond__c(
            AccountId__c = acc.Id
            , BrowseDate__c = CommonUtil.getNow().addDays(1)
            , ReceiveMailDateVisitReservation__c = CommonUtil.getNow()
        );
        corrList.add(corr);

        /* 最新日付が対応．物件紹介可能時刻、
        次点最新日付が対応．メール受信日時の場合、"メール受信"を表示
        */
        corr = new Correspond__c(
            AccountId__c = acc.Id
            , PropertyIntroductionPossibleTime__c = CommonUtil.getNow().addDays(1)
            , ReceiveMailDatePortal__c = CommonUtil.getNow()
        );
        corrList.add(corr);
        
        /* 最新日付が対応．閲覧日時、
        次点最新日付が対応．物件紹介可能時刻の場合、"物件紹介可能"を表示
        */
        corr = new Correspond__c(
            AccountId__c = acc.Id
            , BrowseDate__c = CommonUtil.getNow().addDays(1)
            , PropertyIntroductionPossibleTime__c = CommonUtil.getNow()
        );
        corrList.add(corr);

        insert corrList;
    }

    //追加要望 追加 Start
    //紹介メール情報が更新される
    @isTest static void updateIntroMailTest(){
        List<Correspond__c> corrList = new List<Correspond__c>();

        Account acc = [SELECT id,Name FROM Account WHERE Name = '取引先'];
        Correspond__c corr = new Correspond__c(
            AccountId__c = acc.Id
            , Status__c = '追客中'
        );
        insert corr;

        insert new IntroductionMailInformation__c(Account__c = acc.id,Correspond__c = corr.id);

        //対応を更新
        corr.SendMailDate__c = Datetime.newInstance(2020, 1, 1, 10, 0, 0);
        update corr;

        CommonUtil.sleep(10);
        
        List<IntroductionMailInformation__c> checkIm = [SELECT id ,SendMailDate__c FROM IntroductionMailInformation__c WHERE Account__c = :acc.id];
        //対応の更新内容が反映されている？
        system.assertEquals(Datetime.newInstance(2020, 1, 1, 10, 0, 0), checkIm[0].SendMailDate__c);

    }

    //削除紹介メール情報
    @isTest static void deleteIntroMailTest(){
        List<Correspond__c> corrList = new List<Correspond__c>();

        Account acc = [SELECT id,Name FROM Account WHERE Name = '取引先'];
        Correspond__c corr = new Correspond__c(
            AccountId__c = acc.Id
            , Status__c = '追客中'
        );
        insert corr;

        insert new IntroductionMailInformation__c(Account__c = acc.id,Correspond__c = corr.id);

        //対応を更新
        corr.Status__c = '終了';
        update corr;

        CommonUtil.sleep(10);
        
        List<IntroductionMailInformation__c> checkIm = [SELECT id ,SendMailDate__c FROM IntroductionMailInformation__c WHERE Account__c = :acc.id];
        //対応の更新内容が反映されている？
        system.assertEquals(true, checkIm.isEmpty());

    }
    //追加要望 追加 End

    // ▼ 2021.11.24 LINE連携対応による追加
    /**
     * LINE受信（イベント）テスト
     */
    @isTest static void eventLineReceiveTest() {

        // システム日付
        DateTime sysDate = CommonUtil.getNow();

        // 対応の登録
        Correspond__c correspond = new Correspond__c(
            LineReceiveDate__c         = sysDate
            , ReceiveMailDatePortal__c = sysDate
        );
        insert correspond;

        // 結果確認
        System.assertEquals([SELECT Event__c FROM Correspond__c WHERE Id = :correspond.Id].Event__c
                            , CommonConst.CORRESPOND_EVENT_LINE_RECEIVE
                            , 'イベント_LINE受信');
    }

    /**
     * LINE追加（イベント）テスト
     */
    @isTest static void eventLineAddTest() {

        // システム日付
        DateTime sysDate = CommonUtil.getNow();

        // 対応の登録
        Correspond__c correspond = new Correspond__c(
            LineFriendAddDate__c                  = sysDate
            , PropertyIntroductionPossibleTime__c = sysDate
        );
        insert correspond;

        // 結果確認
        System.assertEquals([SELECT Event__c FROM Correspond__c WHERE Id = :correspond.Id].Event__c
                            , CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD
                            , 'イベント_LINE追加');
    }
    // ▲ 2021.11.24

	//▼ 2022.04.12 No0766 対応で追加
	/**
	 * イベント名：LINE追加
	 * LINEお友達登録日時が最も大きい場合
	 * イベント名が「LINE追加」となること
	 */
	@isTest static void setEventExceptionLine1() {

		// システム日付
		DateTime sysDatetime = CommonUtil.getNow();
		// 対応の設定
		Correspond__c correspond =setCorrespondDateTime(sysDatetime);
		correspond.LineFriendAddDate__c = sysDatetime.addSeconds(1);	// LINEお友達登録日時（現在日付＋１秒）
		Test.startTest();
		// 登録
		insert correspond;
		Test.stopTest();

		// 結果確認
		System.assertEquals([SELECT Event__c FROM Correspond__c ORDER BY Createddate DESC LIMIT 1].Event__c
							, CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD
							, 'LINEお友達登録日時が最も大きい場合：イベント_LINE追加');
	}
	/**
	 * イベント名：LINE追加
	 * 閲覧日時が最新で次点がLINEお友達登録日時の場合
	 * イベント名が「LINE追加」となること
	 */
	@isTest static void setEventExceptionLine2() {

		// システム日付
		DateTime sysDatetime = CommonUtil.getNow();
		// 対応の設定
		Correspond__c correspond =setCorrespondDateTime(sysDatetime);
		correspond.BrowseDate__c = sysDatetime.addSeconds(2);  			// 閲覧日時（現在日付＋２秒）
		correspond.LineFriendAddDate__c = sysDatetime.addSeconds(1);	// LINEお友達登録日時（現在日付＋１秒）
		Test.startTest();
		// 登録
		insert correspond;
		Test.stopTest();

		// 結果確認
		System.assertEquals([SELECT Event__c FROM Correspond__c ORDER BY Createddate DESC LIMIT 1].Event__c
							, CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD
							, '閲覧日時が最新で次点がLINEお友達登録日時の場合：イベント_LINE追加');
	}

	/**
	 * イベント名：LINE追加
	 * 物件紹介可能が最新で次点がLINEお友達登録日時の場合
	 * イベント名が「LINE追加」となること
	 */
	@isTest static void setEventExceptionLine3() {

		// システム日付
		DateTime sysDatetime = CommonUtil.getNow();
		// 対応の設定
		Correspond__c correspond =setCorrespondDateTime(sysDatetime);
		correspond.PropertyIntroductionPossibleTime__c = sysDatetime.addSeconds(2);	// 物件紹介可能時刻（現在日付＋２秒）
		correspond.LineFriendAddDate__c = sysDatetime.addSeconds(1);				// LINEお友達登録日時（現在日付＋１秒）
		Test.startTest();
		// 登録
		insert correspond;
		Test.stopTest();

		// 結果確認
		System.assertEquals([SELECT Event__c FROM Correspond__c ORDER BY Createddate DESC LIMIT 1].Event__c
							, CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD
							, '物件紹介可能が最新で次点がLINEお友達登録日時の場合：イベント_LINE追加');
	}

	/**
	 * イベント名：LINE受信
	 * LINE受信日時が最も大きい場合
	 * イベント名が「LINE受信」となること
	 */
	@isTest static void setEventExceptionLine4() {

		// システム日付
		DateTime sysDatetime = CommonUtil.getNow();
		// 対応の設定
		Correspond__c correspond =setCorrespondDateTime(sysDatetime);
		correspond.LineReceiveDate__c = sysDatetime.addSeconds(1);	// LINE受信日時（現在日付＋１秒）
		Test.startTest();
		// 登録
		insert correspond;
		Test.stopTest();

		// 結果確認
		System.assertEquals([SELECT Event__c FROM Correspond__c ORDER BY Createddate DESC LIMIT 1].Event__c
							, CommonConst.CORRESPOND_EVENT_LINE_RECEIVE
							, 'LINE受信日時が最も大きい場合：イベント_LINE受信');
	}

	/**
	 * イベント名：LINE受信
	 * 閲覧日時が最新で次点がLINE受信日時の場合
	 * イベント名が「LINE受信」となること
	 */
	@isTest static void setEventExceptionLine5() {

		// システム日付
		DateTime sysDatetime = CommonUtil.getNow();
		// 対応の設定
		Correspond__c correspond =setCorrespondDateTime(sysDatetime);
		correspond.BrowseDate__c = sysDatetime.addSeconds(2);		// 閲覧日時（現在日付＋２秒）
		correspond.LineReceiveDate__c = sysDatetime.addSeconds(1);	// LINE受信日時（現在日付＋１秒）
		Test.startTest();
		// 登録
		insert correspond;
		Test.stopTest();

		// 結果確認
		System.assertEquals([SELECT Event__c FROM Correspond__c ORDER BY Createddate DESC LIMIT 1].Event__c
							, CommonConst.CORRESPOND_EVENT_LINE_RECEIVE
							, '閲覧日時が最新で次点がLINE受信日時の場合：イベント_LINE受信');
	}

	/**
	 * イベント名：LINE受信
	 * 物件紹介可能が最新で次点がLINE受信日時の場合
	 * イベント名が「LINE受信」となること
	 */
	@isTest static void setEventExceptionLine6() {

		// システム日付
		DateTime sysDatetime = CommonUtil.getNow();
		// 対応の設定
		Correspond__c correspond =setCorrespondDateTime(sysDatetime);
		correspond.PropertyIntroductionPossibleTime__c = sysDatetime.addSeconds(2);	// 物件紹介可能時刻（現在日付＋２秒）
		correspond.LineReceiveDate__c = sysDatetime.addSeconds(1);					// LINE受信日時（現在日付＋１秒）
		Test.startTest();
		// 登録
		insert correspond;
		Test.stopTest();

		// 結果確認
		System.assertEquals([SELECT Event__c FROM Correspond__c ORDER BY Createddate DESC LIMIT 1].Event__c
							, CommonConst.CORRESPOND_EVENT_LINE_RECEIVE
							, '物件紹介可能が最新で次点がLINE受信日時の場合：イベント_LINE受信');
	}

	/**
	 * 優先順位：LINE追加
	 * 各日付が全て同じ場合
	 * イベント名が「LINE追加」となること
	 */
	@isTest static void setEventExceptionLine7() {

		// システム日付
		DateTime sysDatetime = CommonUtil.getNow();
		// 対応の設定
		Correspond__c correspond =setCorrespondDateTime(sysDatetime);
		Test.startTest();
		// 登録
		insert correspond;
		Test.stopTest();

		// 結果確認
		System.assertEquals([SELECT Event__c FROM Correspond__c ORDER BY Createddate DESC LIMIT 1].Event__c
							, CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD
							, '各日付が全て同じ場合：イベント_LINE追加');
	}

	/**
	 * 優先順位：LINE受信
	 * LINEお友達登録日時以外の日付が全て同じ場合
	 * イベント名が「LINE受信」となること
	 */
	@isTest static void setEventExceptionLine8() {

		// システム日付
		DateTime sysDatetime = CommonUtil.getNow();
		// 対応の設定
		Correspond__c correspond =setCorrespondDateTime(sysDatetime);
		correspond.LineFriendAddDate__c = sysDatetime.addSeconds(-1);	// LINEお友達登録日時（現在日付ー１秒）
		Test.startTest();
		// 登録
		insert correspond;
		Test.stopTest();

		// 結果確認
		System.assertEquals([SELECT Event__c FROM Correspond__c ORDER BY Createddate DESC LIMIT 1].Event__c
							, CommonConst.CORRESPOND_EVENT_LINE_RECEIVE
							, 'LINEお友達登録日時以外の日付が全て同じ場合：イベント_LINE受信');
	}

	/**
	 * 優先順位：メール受信
	 * LINEお友達登録日時、LINE受信日時以外の日付が全て同じ場合
	 * イベント名が「メール受信」となること
	 */
	@isTest static void setEventExceptionLine9() {

		// システム日付
		DateTime sysDatetime = CommonUtil.getNow();
		// 対応の設定
		Correspond__c correspond =setCorrespondDateTime(sysDatetime);
		correspond.LineFriendAddDate__c = sysDatetime.addSeconds(-1);	//LINEお友達登録日時（現在日付ー１秒）
		correspond.LineReceiveDate__c = sysDatetime.addSeconds(-1);		//LINE受信日時（現在日付ー１秒）
		Test.startTest();
		// 登録
		insert correspond;
		Test.stopTest();

		// 結果確認
		System.assertEquals([SELECT Event__c FROM Correspond__c ORDER BY Createddate DESC LIMIT 1].Event__c
							, CommonConst.CORRESPOND_EVENT_EMAIL
							, 'LINEお友達登録日時、LINE受信日時以外の日付が全て同じ場合：イベント_メール受信');
	}

//--------------------------------------------------------------
//--------- Privateメソッド ------------------------------------
//--------------------------------------------------------------
	/**
     * 対応の日付データを入れる
	 * @param DateTime uniformityDateTime 均一に設定する日時
	 * @return Correspond__c 対応1件
     */
	private static Correspond__c setCorrespondDateTime(DateTime uniformityDateTime) {
		Correspond__c correspond = new Correspond__c();
		String objname = CommonUtil.getNamespace('Correspond__c');
		Schema.SObjectType sot2 = Schema.getGlobalDescribe().get(objname);// SObjectType型で物件差分オブジェクトを取得する
		Schema.DescribeSObjectResult dsr2 = sot2.getDescribe();// DescribeSObjectResult型に変換
		Map<String, Schema.SObjectField> fsMap2 = dsr2.fields.getMap();// Map型でオブジェクトの情報を取得する
		for (Schema.SObjectField sof : fsMap2.values()) {
			Boolean isCustom = sof.getDescribe().isCustom();// 項目の型を取得(カスタム項目か確認)
			Schema.DisplayType type = sof.getDescribe().getType();  // データ型
			// カスタム項目でない、データ型が日付／時間型でない項目はスルー
			if (!isCustom || type != Schema.DisplayType.DATETIME) {
				continue;
			}
			correspond.put(sof.getDescribe().getName(), uniformityDateTime); // 日付			
		}
		return correspond;
	}
	//▲ 2022.04.12 No0766 対応で追加
}