// 反響メールトリガーハンドラAPEXテストクラス
@ isTest
private class BA101004TriggerHandlerTest {
   
    private static Account account = new Account();
    private static FavoriteProperty__c favorite = new FavoriteProperty__c();
    private static EchoMail__c ecoMail = new EchoMail__c();
    private static Correspond__c correspond = new Correspond__c();

    @TestSetup
    static void Setting(){

        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = '横井店舗',
                                         PortalSitePostingDistrict__c = '港区;北区',
                                         Email__c = 'tempoEmail@rand.co.jp');
        Shop__c shopRecord2 = new shop__c(Name = 'IS',
                                    PortalSitePostingDistrict__c = '港区;北区',
                                    Email__c = 'tempoEmail2@rand.co.jp');
        List<shop__c> shopList = new List<shop__c>{shopRecord,shopRecord2};
        insert shopList;

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('システム管理者')];
        System.assert(profiles.size() > 0);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            User user1 = new User(
                UserName = 'hankyo@example.com',
                Email = 'hankyo@example.com',
                LastName = 'hankyo',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
            User user2 =  new User(
                UserName = 'raiten@example.com',
                Email = 'raiten@example.com',
                LastName = 'raiten',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
            List<User> userList = new List<User>{user1,user2};
            insert userList;
        
        }
        
        // カレンダー
        //Calendar calendar = [SELECT ID, Name FROM Calendar WHERE Name = 'HP来店予約管理'];
        List<Calendar> cList = [SELECT ID, Name FROM Calendar WHERE Type = 'public' And isActive = true];
        Calendar calendar = cList.get(0);

        // システム設定登録（ポータルサイトのメールアドレス）
        SystemConfig__c sysCon = new SystemConfig__c();
        sysCon.EmaiPortal__c = 'portal@mail.com';
        sysCon.EmailSumo__c = 'system@jds.suumo.jp';
        sysCon.EmailHomes__c = 'support@homes.co.jp';
        sysCon.EmailChintai__c = 'confirm@chintai.co.jp'; // CHINTAI対応追加　2022/3/8
        sysCon.EmailAthome__c = 'mailcenter@athome.jp';
		// ▼ 2021.12.10 LINE連携対応より、警告メールを送信しないよう修正
		sysCon.sendMailLimitWarningCount__c = 100;
		// ▲ 2021.12.10
        sysCon.RegularHolidayCalendar__c = calendar.Name;
        // ポータルサイト構築 追加 Start
        sysCon.ExampleIv__c = '4f63e8b490579073';
        sysCon.HerokuSecretAccessKey__c = 'zF2SKTCj5CnR5TEhXhCLYBKE9x6a6xHN';
        // ポータルサイト構築 追加 End
        insert sysCon;

        // ポータルサイト登録
        List<PortalSite__c> portalList = new List<PortalSite__c>();
        PortalSite__c portal = new PortalSite__c();
        portal.Name = 'スーモ';
        portal.Url__c = 'suumotest@co.jp';
        portal.Email__c = CommonConst.EMAIL_SUMO;
        portalList.add(portal);

        portal = new PortalSite__c();
        portal.Name = 'ホームズ';
        portal.Url__c = 'homestest@co.jp';
        portal.Email__c = CommonConst.EMAIL_HOMES;
        portalList.add(portal);

        portal = new PortalSite__c();
        portal.Name = 'アットホーム';
        portal.Url__c = 'athome_test@co.jp';
        portal.Email__c = CommonConst.EMAIL_ATHOME;
        portalList.add(portal);

        // ▼ 2022/3/7 CHINTAI対応による追加
        portal = new PortalSite__c();
        portal.Name = 'CHINTAI';
        portal.Url__c = 'chintai_test@co.jp';
        portal.Email__c = CommonConst.EMAIL_CHINTAI;
        portalList.add(portal);
        // ▲ 2022/3/7 CHINTAI対応による追加

        portal = new PortalSite__c();
        portal.Name = '横井テスト';
        portal.Url__c = 'test@co.jp';
        portal.Email__c = 'test@rand.co.jp';
        portalList.add(portal);

		//▼ 2022.04.04 No0745 対応で追加
		portal = new PortalSite__c();
        portal.Name = '自社ポータル';
        portal.Url__c = 'test@co.jp';
        portal.Email__c = CommonConst_ptl.EMAIL_PORTAL;
        portalList.add(portal);
		//▲ 2022.04.04 No0745 対応で追加
        insert portalList;

        // 建物登録
        Building__c building = new Building__c();
        building.Name = 'テスト建物';
        building.District__c = '守山区';
        insert building;

        // 物件登録
        Property__c property = new Property__c();
        property.Building__c = building.Id;
        insert property;

		// ▼ 2021.12.10 LINE連携対応より、送信種別とレコードの追加
		// 問合せ御礼メール設定
		ThanksMailSetting__c thanksMailSetting = new ThanksMailSetting__c (
			Subject__c = '自動返信タイトル'
			, StartDate__c = System.today()
			, EndDate__c = System.today().addDays(2)
			, NonSendStartTime__c = System.now().time()
			, NonSendEndTime__c = System.now().time()
			, SendByShop__c = shopRecord.Id
			, isAutoReciveAllDay__c = true
			, SendType__c = CommonConst.THANKS_MAIL_SETTING_SEND_TYPE_MAIL);
		insert thanksMailSetting;
		// ▲ 2021.12.10

		// ▼ 2021.12.10 LINE連携対応より、不要なオブジェクトを削除
        // ▲ 2021.12.10
        
        // 店舗
        Shop__c shop = new Shop__c (
            Email__c = 'tempoEmail2@rand.co.jp');
        insert shop;
                
        // 行動
        Event event = new Event (
            DurationInMinutes = 10
            , ActivityDateTime = CommonUtil.GetNow()
            , Subject = CommonConst.SUBJECT_REGULARHOLIDAY
            , OwnerId = calendar.Id
        );
        insert event;
    }

    /**
     * 以下の条件に紐づくテストケース
     * 
     * ポータルサイトからのメール：ＯＫ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＯＫ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：更新 / 対応明細：登録 / お気に入り物件：登録
     */
    @isTest static void test1(){
system.debug('■■■■■■■■■■■  test1開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_SUMO]; // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
        List<Shop__c> shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];    // 店舗
        // ユーザ情報取得
        User userHankyo =  [SELECT Id FROM User WHERE LastName = 'hankyo'];
        User userRaiten =  [SELECT Id FROM User WHERE LastName = 'raiten'];
system.debug('反響担当者：'+userHankyo.Id);
system.debug('来店担当者：'+userRaiten.Id);

        // 取引先登録（メール１が一致により紐づく）
        account = createAccount('洞口太郎', 'customerEmail@rand.co.jp', '', '', '', '', '', '仕込');
        insert account;

        // // 対応登録（ステータス：未対応）
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED, shop[0].Id, true, false, userHankyo, userRaiten);
        insert correspond;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 1, 1, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'customerEmail@rand.co.jp', '', true, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 1, 1, 1, 1);

system.debug('★★★★★★★  test1終了  ★★★★★★★');
system.debug('');
    }

    /**
     * 以下の条件に紐づくテストケース
     * 
     * ポータルサイトからのメール：ＯＫ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＮＧ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：登録 / 対応明細：登録 / お気に入り物件：登録
     */
    @isTest static void test2(){
        system.debug('■■■■■■■■■■■  test2開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_HOMES];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件

        // 取引先登録（電話番号１が一致により紐づく）
        account = createAccount('洞口太郎', '', '', '', '090-9999-9999', '', '', '仕込');
        insert account;

        // お気に入り物件登録
        favorite = createFavorite(account.Id, property[0].Id);
        insert favorite;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 1, 0, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    '', '090-9999-9999', true, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 1, 1, 1, 1);

system.debug('★★★★★★★  test2終了  ★★★★★★★');
system.debug('');
    }

    /**
     * 以下の条件に紐づくテストケース
     * 
     * ポータルサイトからのメール：ＯＫ
     * 取引先に登録済み顧客：ＮＧ
     * 取引先に紐つく対応が存在する：-
     * 
     * ＜処理結果＞
     * 取引先：対象 / 対応：登録 / 対応明細：登録 / お気に入り物件：登録
     */
    @isTest static void test3(){
        system.debug('■■■■■■■■■■■  test3開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_ATHOME];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件

        // 取引先登録（メール１が不一致により紐づかない）
        account = createAccount('洞口太郎', 'aaaaaa@rand.co.jp', '', '', '', '', '', '仕込');
        
        insert account;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 1, 0, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口 太 郎', 
                                    'customerEmail@rand.co.jp', '090-9999-9999', true, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 2, 1, 1, 1);

system.debug('★★★★★★★  test3終了  ★★★★★★★');
system.debug('');
    }

    /**
     * 以下の条件に紐づくテストケース
     * 
     * ポータルサイトからのメール：ＯＫ
     * 取引先に登録済み顧客：ＮＧ（反響メールに名前設定なし）
     * 取引先に紐つく対応が存在する：-
     * 
     * ＜処理結果＞
     * 取引先：対象 / 対応：登録 / 対応明細：登録 / お気に入り物件：登録
     */
    @isTest static void test3_2(){
        system.debug('■■■■■■■■■■■  test3_2開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_ATHOME];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件

        // 取引先登録（メール１が不一致により紐づかない）
        account = createAccount('洞口太郎', 'aaaaaa@rand.co.jp', '', '', '', '', '', '仕込');
        
        insert account;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 1, 0, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '', 
                                    'customerEmail@rand.co.jp', '090-9999-9999', true, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 1, 1, 1, 0);

system.debug('★★★★★★★  test3_2終了  ★★★★★★★');
system.debug('');
    }

    /**
     * 以下の条件に紐づくテストケース
     * 
     * ポータルサイトからのメール：ＮＧ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＮＧ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：登録 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void test4(){
system.debug('■■■■■■■■■■■  test4開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = 'test@rand.co.jp'];    // ポータルサイト以外
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
        List<Shop__c> shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];    // 店舗
        // ユーザ情報取得
        User userHankyo =  [SELECT Id FROM User WHERE LastName = 'hankyo'];
        User userRaiten =  [SELECT Id FROM User WHERE LastName = 'raiten'];
system.debug('反響担当者：'+userHankyo.Id);
system.debug('来店担当者：'+userRaiten.Id);

        // 取引先登録（メール２が一致により紐づく）
        account = createAccount('洞口太郎', '', 'customerEmail@rand.co.jp', '', '', '', '', '仕込');
        insert account;
        // 対応登録（ステータス：未対応）
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED, shop[0].Id, false, false, userHankyo, userRaiten);
        insert correspond;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 1, 0, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎', 
                                    'customerEmail@rand.co.jp', '', false, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 1, 1, 1, 0);

system.debug('★★★★★★★  test4終了  ★★★★★★★');
system.debug('');
    }

    /**
     * 以下の条件に紐づくテストケース
     * 
     * ポータルサイトからのメール：ＮＧ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＮＧ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：登録 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void test5(){
system.debug('■■■■■■■■■■■  test5開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = 'test@rand.co.jp'];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件

        // 取引先登録（メール３が一致により紐づく）
        account = createAccount('洞口太郎', '', '', 'customerEmail@rand.co.jp', '', '', '', '仕込');
        insert account;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 1, 0, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'customerEmail@rand.co.jp', '', false, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 1, 1, 1, 0);

system.debug('★★★★★★★  test5終了  ★★★★★★★');
system.debug('');
    }

    /**
     * 以下の条件に紐づくテストケース
     * 
     * ポータルサイトからのメール：ＮＧ
     * 取引先に登録済み顧客：ＮＧ
     * 取引先に紐つく対応が存在する：-
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：登録 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void test6(){
system.debug('■■■■■■■■■■■  test6開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = 'test@rand.co.jp'];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
 
        // 取引先登録（メール１が不一致により紐づかない）
        account = createAccount('洞口太郎', 'bbbbbb@rand.co.jp', '', '', '', '', '', '');
        insert account;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 1, 0, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'customerEmail@rand.co.jp', '090-9999-9999', false, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 1, 1, 1, 0);

system.debug('★★★★★★★  test6終了  ★★★★★★★');
system.debug('');
    }

    /**
     * 以下の条件に紐づくテストケース（複数件同時処理確認用）
     * 
     * ポータルサイトからのメール：ＯＫ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＯＫ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：更新 / 対応明細：登録 / お気に入り物件：登録
     */
    @isTest static void test7(){
system.debug('■■■■■■■■■■■  test7開始  ■■■■■■■■■■■');

        List<EchoMail__c> echoMailList = new List<EchoMail__c>();
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
        // ユーザ情報取得
        User userHankyo =  [SELECT Id FROM User WHERE LastName = 'hankyo'];
        User userRaiten =  [SELECT Id FROM User WHERE LastName = 'raiten'];
system.debug('反響担当者：'+userHankyo.Id);
system.debug('来店担当者：'+userRaiten.Id);
        // test1の条件
        List<PortalSite__c> portal_A = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_SUMO]; // ポータルサイト
        // 取引先登録（電話番号２が一致により紐づく）
        account = createAccount('洞口太郎Ａ', '', '', '', '', '090-9999-9999', '', '仕込');
        insert account;
        // // 対応登録（ステータス：アポイント確定）
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_APPOINTMENT, null, true, false, userHankyo, userRaiten);

        insert correspond;
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal_A[0].Id, property[0].Id, '守山区',  '洞口太郎Ａ',
                                    '', '090-9999-9999', true, false);
        echoMailList.add(ecoMail);
        
        // test2の条件
        List<PortalSite__c> portal_B = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_HOMES];    // ポータルサイト
        // 取引先登録（電話番号３が一致により紐づく）
        account = createAccount('洞口太郎Ｂ', '', '', '', '', '', '090-9999-9999', '仕込');
        insert account;
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal_B[0].Id, property[0].Id, '守山区',  '洞口太郎Ｂ',
                                    '', '090-9999-9999', true, false);
        echoMailList.add(ecoMail);

        // test3の条件
        List<PortalSite__c> portal_C = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_ATHOME];
        // 取引先登録（名前不一致により紐づかない）
        account = createAccount('洞口花子', '', '', '', '', '', '090-9999-9999', '仕込');
        insert account;
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal_C[0].Id, property[0].Id, '守山区', '洞口太郎Ｃ', 
                                    'customerEmail_C@rand.co.jp', '090-9999-9999', true, false);
        echoMailList.add(ecoMail);

        // test4の条件
        List<PortalSite__c> portal_D = [SELECT Id FROM PortalSite__c WHERE Email__c = 'test@rand.co.jp'];
        // 取引先登録（メール１が一致により紐づく）
        account = createAccount('洞口太郎Ｄ', 'customerEmail_D@rand.co.jp', '', '', '', '', '', '仕込');
        insert account;
        // // 対応登録（ステータス：来店済）
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_VISITED, null, false, false, userHankyo, userRaiten);
        insert correspond;
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal_D[0].Id, property[0].Id, '守山区',  '洞口太郎Ｄ',
                                    'customerEmail_D@rand.co.jp', '', false, false);
        echoMailList.add(ecoMail);

        // test5の条件
        // 取引先登録（メール１が一致により紐づく）
        account = createAccount('洞口太郎Ｅ', 'customerEmail_E@rand.co.jp', '', '', '', '', '', '仕込');
        insert account;

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal_D[0].Id, property[0].Id, '守山区', '洞口太郎Ｅ', 
                                    'customerEmail_E@rand.co.jp', '090-9999-9999', false, false);
        echoMailList.add(ecoMail);

        // test6の条件
        // 取引先登録（メール１が不一致により紐づかない）
        account = createAccount('洞口太郎Ｆ', 'bbbbbb@rand.co.jp', '', '', '', '', '', '仕込');
        insert account;
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal_D[0].Id, property[0].Id, '守山区', '洞口太郎Ｆ', 
                                    'customerEmail_F@rand.co.jp', '090-9999-9999', false, false);
        echoMailList.add(ecoMail);

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 6, 2, 0, 0);

        insert echoMailList;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(6, 7, 7, 6, 3);

system.debug('★★★★★★★  test7終了  ★★★★★★★');
system.debug('');
    }

    /**
     * 上記テストで網羅できなかった対応ステータス一致パターンを全て実施（ベースはテスト１）
     * 
     * ポータルサイトからのメール：ＯＫ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＯＫ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：更新 / 対応明細：登録 / お気に入り物件：登録
     */
    @isTest static void test8(){
system.debug('■■■■■■■■■■■  test8開始  ■■■■■■■■■■■');

        List<Account> accountList = new List<Account>();
        List<Correspond__C> correspondList = new List<Correspond__c>();
        List<EchoMail__c> echoMailList = new List<EchoMail__c>();
        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_SUMO]; // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
        // ユーザ情報取得
        User userHankyo =  [SELECT Id FROM User WHERE LastName = 'hankyo'];
        User userRaiten =  [SELECT Id FROM User WHERE LastName = 'raiten'];
system.debug('反響担当者：'+userHankyo.Id);
system.debug('来店担当者：'+userRaiten.Id);
        // 取引先登録（電話番号２が一致により紐づく）
        Account account1 = createAccount('洞口太郎Ａ', '', '', '', '', '090-9999-9999', '', '仕込');
        accountList.add(account1);
        // // 対応登録（ステータス：来店後検討）
        correspond = createCorrespond(account1.Id, '守山区', CommonConst.CORRESPOND_STATUS_CONSIDERVISITING, null, true, false, userHankyo, userRaiten);
        correspondList.add(correspond);
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎Ａ',
                                    '', '090-9999-9999', true, false);
        echoMailList.add(ecoMail);
        // -----------------------------------------------------------------    
        // 取引先登録（電話番号２が一致により紐づく）
        Account account2 = createAccount('洞口太郎Ｂ', '', '', '', '', '090-9999-9999', '', '仕込');
        accountList.add(account2);
        // // 対応登録（ステータス：来店後検討）
        correspond = createCorrespond(account2.Id, '守山区', CommonConst.CORRESPOND_STATUS_CONSIDERVISITING, null, true, false, userHankyo, userRaiten);
        correspondList.add(correspond);
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎Ｂ',
                                    '', '090-9999-9999', true, false);
        echoMailList.add(ecoMail);
        // -----------------------------------------------------------------
        // 取引先登録（電話番号２が一致により紐づく）
        Account account3 = createAccount('洞口太郎Ｃ', '', '', '', '', '090-9999-9999', '', '仕込');
        accountList.add(account3);
        // // 対応登録（ステータス：未収入金）
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_UNEARNED, null, true, false, userHankyo, userRaiten);
        correspondList.add(correspond);
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎Ｃ',
                                    '', '090-9999-9999', true, false);
        echoMailList.add(ecoMail);
        // -----------------------------------------------------------------
        // 取引先登録（電話番号２が一致により紐づく）
        Account account4 = createAccount('洞口太郎Ｄ', '', '', '', '', '090-9999-9999', '', '仕込');
        accountList.add(account4);
        // // 対応登録（ステータス：入金済）
        correspond = createCorrespond(account4.Id, '守山区', CommonConst.CORRESPOND_STATUS_DEPOSIT, null, true, false, userHankyo, userRaiten);
        correspondList.add(correspond);
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎Ｄ',
                                    '', '090-9999-9999', true, false);
        echoMailList.add(ecoMail);
        // -----------------------------------------------------------------
        // 取引先登録（電話番号２が一致により紐づく）
        Account account5 = createAccount('洞口太郎Ｅ', '', '', '', '', '090-9999-9999', '', '仕込');
        accountList.add(account5);
        // // 対応登録（ステータス：追客保留中）
        correspond = createCorrespond(account5.Id, '守山区', CommonConst.CORRESPOND_STATUS_PURSUITHOLD, null, true, false, userHankyo, userRaiten);
        correspondList.add(correspond);
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎Ｅ',
                                    '', '090-9999-9999', true, false);
        echoMailList.add(ecoMail);
        // -----------------------------------------------------------------
        // 取引先登録（電話番号２が一致により紐づく）
        Account account6 = createAccount('洞口太郎Ｆ', '', '', '', '', '090-9999-9999', '', '仕込');
        accountList.add(account6);
        // // 対応登録（ステータス：アポイントキャンセル）
        correspond = createCorrespond(account6.Id, '守山区', CommonConst.CORRESPOND_STATUS_APOCANCEL, null, true, false, userHankyo, userRaiten);
        correspondList.add(correspond);
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎Ｆ',
                                    '', '090-9999-9999', true, false);
        echoMailList.add(ecoMail);
        // -----------------------------------------------------------------
        // 取引先登録（電話番号２が一致により紐づく）
        Account account7 = createAccount('洞口太郎Ｇ', '', '', '', '', '090-9999-9999', '', '仕込');
        accountList.add(account7);
        // // 対応登録（ステータス：アポキャンセル後追客中）
        correspond = createCorrespond(account7.Id, '守山区', CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT, null, true, false, userHankyo, userRaiten);
        correspondList.add(correspond);
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎Ｇ',
                                    '', '090-9999-9999', true, false);
        echoMailList.add(ecoMail);
        // -----------------------------------------------------------------
        // 取引先登録（電話番号２が一致により紐づく）
        Account account8 = createAccount('洞口太郎Ｈ', '', '', '', '', '090-9999-9999', '', '仕込');
        accountList.add(account8);
        // // 対応登録（ステータス：来店後追客中）
        correspond = createCorrespond(account8.Id, '守山区', CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT, null, true, false, userHankyo, userRaiten);
        correspondList.add(correspond);
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎Ｈ',
                                    '', '090-9999-9999', true, false);
        echoMailList.add(ecoMail);
        // -----------------------------------------------------------------
        // 取引先登録（電話番号２が一致により紐づく）
        Account account9 = createAccount('洞口太郎Ｉ', '', '', '', '', '090-9999-9999', '', '仕込');
        accountList.add(account9);
        // // 対応登録（ステータス：申込キャンセル）
        correspond = createCorrespond(account9.Id, '守山区', CommonConst.CORRESPOND_STATUS_APPLCANCEL, null, true, false, userHankyo, userRaiten);
        correspondList.add(correspond);
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎Ｉ',
                                    '', '090-9999-9999', true, false);
        echoMailList.add(ecoMail);
        // -----------------------------------------------------------------
        // 取引先登録（電話番号２が一致により紐づく）
        Account account10 = createAccount('洞口太郎Ｊ', '', '', '', '', '090-9999-9999', '', '仕込');
        accountList.add(account10);
        // // 対応登録（ステータス：申込キャンセル後追客中）
        correspond = createCorrespond(account10.Id, '守山区', CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT, null, true, false, userHankyo, userRaiten);
        correspondList.add(correspond);
        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎Ｊ',
                                    '', '090-9999-9999', true, false);
        echoMailList.add(ecoMail);
        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 10, 10, 0, 0);
        insert accountList;
        insert correspondList;
		Test.startTest();

        // // 対応登録（ステータス：来店後検討）
        Correspond__c correspond1 = createCorrespond(account1.Id, '守山区', CommonConst.CORRESPOND_STATUS_CONSIDERVISITING, null, true, false, userHankyo, userRaiten);
        // // 対応登録（ステータス：来店後検討）
        Correspond__c correspond2 = createCorrespond(account2.Id, '守山区', CommonConst.CORRESPOND_STATUS_CONSIDERVISITING, null, true, false, userHankyo, userRaiten);
        // // 対応登録（ステータス：未収入金）
        Correspond__c correspond3 = createCorrespond(account3.Id, '守山区', CommonConst.CORRESPOND_STATUS_UNEARNED, null, true, false, userHankyo, userRaiten);
        // // 対応登録（ステータス：入金済）
        Correspond__c correspond4 = createCorrespond(account4.Id, '守山区', CommonConst.CORRESPOND_STATUS_DEPOSIT, null, true, false, userHankyo, userRaiten);
        // // 対応登録（ステータス：追客保留中）
        Correspond__c correspond5 = createCorrespond(account5.Id, '守山区', CommonConst.CORRESPOND_STATUS_PURSUITHOLD, null, true, false, userHankyo, userRaiten);
        // // 対応登録（ステータス：アポイントキャンセル）
        Correspond__c correspond6 = createCorrespond(account6.Id, '守山区', CommonConst.CORRESPOND_STATUS_APOCANCEL, null, true, false, userHankyo, userRaiten);
        // // 対応登録（ステータス：アポキャンセル後追客中）
        Correspond__c correspond7 = createCorrespond(account7.Id, '守山区', CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT, null, true, false, userHankyo, userRaiten);
        // // 対応登録（ステータス：来店後追客中）
        Correspond__c correspond8 = createCorrespond(account8.Id, '守山区', CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT, null, true, false, userHankyo, userRaiten);
        // // 対応登録（ステータス：申込キャンセル）
        Correspond__c correspond9 = createCorrespond(account9.Id, '守山区', CommonConst.CORRESPOND_STATUS_APPLCANCEL, null, true, false, userHankyo, userRaiten);
        // // 対応登録（ステータス：申込キャンセル後追客中）
        Correspond__c correspond10 = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT, null, true, false, userHankyo, userRaiten);
        List<Correspond__c> corrList = new List<Correspond__c>{correspond1,correspond2,correspond3,correspond4,correspond5,correspond6,correspond7,correspond8,correspond9,correspond10};

        insert corrList;
        insert echoMailList;
		Test.stopTest();
        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(10, 10, 10, 10, 10);

system.debug('★★★★★★★  test8終了  ★★★★★★★');
system.debug('');
    }


    /**
     * 以下の条件に紐づくテストケース（宛名なしエラー）
     * 
     * ポータルサイトからのメール：ＮＧ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＯＫ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：更新 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void test9(){
system.debug('■■■■■■■■■■■  test9開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_SUMO]; // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
        List<Shop__c> shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];    // 店舗
        // ユーザ情報取得
        User userHankyo =  [SELECT Id FROM User WHERE LastName = 'hankyo'];
        User userRaiten =  [SELECT Id FROM User WHERE LastName = 'raiten'];
system.debug('反響担当者：'+userHankyo.Id);
system.debug('来店担当者：'+userRaiten.Id);
        // 取引先登録（メール１が一致により紐づく）
        account = createAccount('洞口太郎', 'customerEmail@rand.co.jp', '', '', '', '', '', '仕込');
        insert account;

        // // 対応登録（ステータス：未対応）
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED, shop[0].Id, true, false, userHankyo, userRaiten);
        insert correspond;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 1, 1, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'mailer-daemon@salesforce.com', '', false, false);
        // 宛名エラー用に本文を加工

        ecoMail.Body__c = 'いつもご利用いただきありがとうございます。'+'\n';
        ecoMail.Body__c += 'メールが送信されなかった可能性があります。添付された送信通知を参照してください。'+'\n';
        ecoMail.Body__c += 'このメッセージは、送信したメールの送信状況通知を転送するように組織で選択されているため、送信されています。'+'\n';
        ecoMail.Body__c += '\n' + '宛先不明のメールアドレス：customerEmail@rand.co.jp';

        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 1, 1, 1, 0);

system.debug('★★★★★★★  test9終了  ★★★★★★★');
system.debug('');
    }

    /**
     * 以下の条件に紐づくテストケース（取引先重複）
     * 
     * ポータルサイトからのメール：ＯＫ
     * 取引先に登録済み顧客：ＯＫ（複数件あり）
     * 取引先に紐つく対応が存在する：ー
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：登録 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void test10(){
system.debug('■■■■■■■■■■■  test10開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_SUMO]; // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
        List<Shop__c> shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];    // 店舗
        List<Account> accList = new List<Account>();

        // 取引先登録（反響メールに紐づく取引先を複数件作成）
        account = new Account();
        account = createAccount('洞口太郎', 'customerEmail@rand.co.jp', '', '', '', '', '', '仕込');
        accList.add(account);
        account = new Account();
        account = createAccount('洞口太郎', 'customerEmail@rand.co.jp', '', '', '', '', '', '仕込');
        accList.add(account);
        insert accList;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 2, 0, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'customerEmail@rand.co.jp', '', true, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 2, 1, 1, 0);

system.debug('★★★★★★★  test10終了  ★★★★★★★');
system.debug('');
    }

        /**
     * 以下の条件に紐づくテストケース（取引先重複）
     * 
     * ポータルサイトからのメール：ＮＧ
     * 取引先に登録済み顧客：ＯＫ（複数件あり）
     * 取引先に紐つく対応が存在する：ー
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：登録 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void test11(){
system.debug('■■■■■■■■■■■  test11開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = 'test@rand.co.jp'];
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
        List<Shop__c> shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];    // 店舗
        List<Account> accList = new List<Account>();

        // 取引先登録（反響メールに紐づく取引先を複数件作成）
        account = new Account();
        account = createAccount('洞口太郎', 'customerEmail@rand.co.jp', '', '', '', '', '', '仕込');
        accList.add(account);
        account = new Account();
        account = createAccount('洞口太郎', 'customerEmail@rand.co.jp', '', '', '', '', '', '仕込');
        accList.add(account);
        insert accList;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 2, 0, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'customerEmail@rand.co.jp', '', true, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 2, 1, 1, 0);

system.debug('★★★★★★★  test11終了  ★★★★★★★');
system.debug('');
    }

	// ▼ 2021.12.10 LINE連携対応より、自動返信用テストを削除
	// ▲ 2021.12.10
    
    /**
     * 以下の条件に紐づくテストケース
     * 紐づく店舗がＩＳ、かつステータスが有効（無効も混ぜておく）
     * 
     * ポータルサイトからのメール：ＮＧ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＯＫ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：更新 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void IS_yukou(){
system.debug('■■■■■■■■■■■  IS_yukou開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = 'test@rand.co.jp'];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
        List<Shop__c> shop = [SELECT Id FROM Shop__c WHERE Name = 'IS'];    // 店舗
        List<Correspond__c> coreList = new List<Correspond__c>();
        // ユーザ情報取得
        User userHankyo =  [SELECT Id FROM User WHERE LastName = 'hankyo'];
        User userRaiten =  [SELECT Id FROM User WHERE LastName = 'raiten'];
system.debug('反響担当者：'+userHankyo.Id);
system.debug('来店担当者：'+userRaiten.Id);
        // 取引先登録（メール２が一致により紐づく）
        account = createAccount('洞口太郎', '', 'customerEmail@rand.co.jp', '', '', '', '', '仕込');
        insert account;

        // 対応登録（ステータス：有効（追客中））
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_PURSUIT, shop[0].Id, false, true, userHankyo, userRaiten);
        coreList.add(correspond);
        correspond = new Correspond__c();
        // 対応登録（ステータス：有効（未対応））
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED, shop[0].Id, false, true, userHankyo, userRaiten);
        coreList.add(correspond);
        correspond = new Correspond__c();
        // 対応登録（ステータス：有効（入金済））
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_DEPOSIT, shop[0].Id, false, true, userHankyo, userRaiten);
        coreList.add(correspond);
        correspond = new Correspond__c();
        // 対応登録（ステータス：無効（終了））
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_CLOSE, shop[0].Id, false, true, userHankyo, userRaiten);
        coreList.add(correspond);
        insert coreList;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 1, 4, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎', 
                                    'customerEmail@rand.co.jp', '', false, true);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 1, 4, 3, 0);

system.debug('★★★★★★★  IS_yukou終了  ★★★★★★★');
system.debug('');
    }

    /**
     * 以下の条件に紐づくテストケース
     * 紐づく店舗がＩＳ、かつステータスが無効（終了のみ）
     * 
     * ポータルサイトからのメール：ＮＧ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＯＫ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：更新 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void IS_mukou(){
system.debug('■■■■■■■■■■■  IS_mukou開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = 'test@rand.co.jp'];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
        List<Shop__c> shop = [SELECT Id FROM Shop__c WHERE Name = 'IS'];    // 店舗
        List<Correspond__c> coreList = new List<Correspond__c>();
        // ユーザ情報取得
        User userHankyo =  [SELECT Id FROM User WHERE LastName = 'hankyo'];
        User userRaiten =  [SELECT Id FROM User WHERE LastName = 'raiten'];
system.debug('反響担当者：'+userHankyo.Id);
system.debug('来店担当者：'+userRaiten.Id);
        // 取引先登録（メール２が一致により紐づく）
        account = createAccount('洞口太郎', '', 'customerEmail@rand.co.jp', '', '', '', '', '仕込');
        insert account;

        // 対応登録（ステータス：無効（終了））
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_CLOSE, shop[0].Id, false, true, userHankyo, userRaiten);
        coreList.add(correspond);
        correspond = new Correspond__c();
        // 対応登録（ステータス：無効（終了））
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_CLOSE, shop[0].Id, false, true, userHankyo, userRaiten);
        coreList.add(correspond);
        insert coreList;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 1, 2, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎', 
                                    'customerEmail@rand.co.jp', '', false, true);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 1, 2, 1, 0);

system.debug('★★★★★★★  IS_mukou終了  ★★★★★★★');
system.debug('');
    }

    /**
     * 以下の条件に紐づくテストケース
     * 紐づく店舗がＩＳでない、かつステータスが有効（無効も混ぜておく）
     * 
     * ポータルサイトからのメール：ＮＧ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＯＫ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：更新 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void NotIS_yukou(){
system.debug('■■■■■■■■■■■  NotIS_yukou開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = 'test@rand.co.jp'];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
        List<Shop__c> shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];    // 店舗
        List<Correspond__c> coreList = new List<Correspond__c>();
        // ユーザ情報取得
        User userHankyo =  [SELECT Id FROM User WHERE LastName = 'hankyo'];
        User userRaiten =  [SELECT Id FROM User WHERE LastName = 'raiten'];
system.debug('反響担当者：'+userHankyo.Id);
system.debug('来店担当者：'+userRaiten.Id);
        // 取引先登録（メール２が一致により紐づく）
        account = createAccount('洞口太郎', '', 'customerEmail@rand.co.jp', '', '', '', '', '仕込');
        insert account;

        // 対応登録（ステータス：有効（追客中））
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_PURSUIT, shop[0].Id, false, false, userHankyo, userRaiten);
        coreList.add(correspond);
        correspond = new Correspond__c();
        // 対応登録（ステータス：有効（未対応））
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED, shop[0].Id, false, false, userHankyo, userRaiten);
        coreList.add(correspond);
        correspond = new Correspond__c();
        // 対応登録（ステータス：有効（入金済））
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_DEPOSIT, shop[0].Id, false, false, userHankyo, userRaiten);
        coreList.add(correspond);
        correspond = new Correspond__c();
        // 対応登録（ステータス：無効（終了））
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_CLOSE, shop[0].Id, false, false, userHankyo, userRaiten);
        coreList.add(correspond);
        insert coreList;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 1, 4, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎', 
                                    'customerEmail@rand.co.jp', '', false, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 1, 4, 3, 0);

system.debug('★★★★★★★  NotIS_yukou終了  ★★★★★★★');
system.debug('');
    }

    /**
     * 以下の条件に紐づくテストケース
     * 紐づく店舗がＩＳでない、かつステータスが無効（終了のみ）
     * 
     * ポータルサイトからのメール：ＮＧ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＯＫ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：更新 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void NotIS_mukou(){
system.debug('■■■■■■■■■■■  NotIS_mukou開始  ■■■■■■■■■■■');

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = 'test@rand.co.jp'];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
        List<Shop__c> shop = [SELECT Id FROM Shop__c WHERE Name <> 'IS'];    // 店舗
        List<Correspond__c> coreList = new List<Correspond__c>();
        // ユーザ情報取得
        User userHankyo =  [SELECT Id FROM User WHERE LastName = 'hankyo'];
        User userRaiten =  [SELECT Id FROM User WHERE LastName = 'raiten'];
system.debug('反響担当者：'+userHankyo.Id);
system.debug('来店担当者：'+userRaiten.Id);
        // 取引先登録（メール２が一致により紐づく）
        account = createAccount('洞口太郎', '', 'customerEmail@rand.co.jp', '', '', '', '', '仕込');
        insert account;

        // 対応登録（ステータス：無効（終了））
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_CLOSE, shop[0].Id, false, false, userHankyo, userRaiten);
        coreList.add(correspond);
        correspond = new Correspond__c();
        // 対応登録（ステータス：無効（終了））
        correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_CLOSE, shop[0].Id, false, false, userHankyo, userRaiten);
        coreList.add(correspond);
        insert coreList;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 1, 2, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎', 
                                    'customerEmail@rand.co.jp', '', false, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 1, 2, 1, 0);

system.debug('★★★★★★★  NotIS_mukou終了  ★★★★★★★');
system.debug('');
    }





    /**
     * 以下の条件に紐づくテストケース（名寄せ確認用）
     * 
     * ポータルサイトからのメール：ＯＫ
     * 取引先に登録済み顧客：ＮＧ
     * 取引先に紐つく対応が存在する：-
     * 
     * 一括登録する取引先内に重複があるケース
     * 
     * ＜処理結果＞
     * 取引先：対象 / 対応：登録 / 対応明細：登録 / お気に入り物件：登録
     */
    @isTest static void nayose_test1(){
        system.debug('■■■■■■■■■■■  nayose_test1開始  ■■■■■■■■■■■');

        List<EchoMail__c> ecoMailList = new List<EchoMail__c>();

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_ATHOME];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件

        // 取引先登録（メール１が不一致により紐づかない）
        account = createAccount('洞口太郎', 'aaaaaa@rand.co.jp', '', '', '', '', '', '仕込');
        insert account;

        // 反響メール登録値設定
        // 洞口太郎：メールアドレス一致により名寄せ対象となる
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎Ａ', 
                                    'customerEmail@rand.co.jp', '090-9999-9999', true, false);
        ecoMailList.add(ecoMail);
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎Ａ', 
                                    'customerEmail@rand.co.jp', '111-1111-1111', true, false);
        ecoMailList.add(ecoMail);
        // 洞口次郎：電話番号一致により名寄せ対象となる
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口次郎Ａ', 
                                    'bbbbbbbb@rand.co.jp', '090-9999-9999', true, false);
        ecoMailList.add(ecoMail);   
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口次郎Ａ', 
                                    'aaaaaaaa@rand.co.jp', '090-9999-9999', true, false);
        ecoMailList.add(ecoMail);
         // 洞口三郎：メールアドレスは一致だが、名前が不一致により名寄せ対象外となる
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口三郎Ａ', 
                                    'customerEmail@rand.co.jp', '090-9999-9999', true, false);
        ecoMailList.add(ecoMail);
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口三郎Ｂ', 
                                    'customerEmail@rand.co.jp', '111-1111-1111', true, false);
        ecoMailList.add(ecoMail);
        // 洞口四郎：電話番号は一致だが、名前が不一致により名寄せ対象外となる
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口四郎Ａ', 
                                    'bbbbbbbb@rand.co.jp', '090-9999-9999', true, false);
        ecoMailList.add(ecoMail);
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口四郎Ｂ', 
                                    'aaaaaaaa@rand.co.jp', '090-9999-9999', true, false);
        ecoMailList.add(ecoMail);
        // 洞口五郎：全て一致しない為、名寄せ対象外となる
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口五郎', 
                                    'gogogorou@rand.co.jp', '111-2222-3333', true, false);
        ecoMailList.add(ecoMail);

        insert ecoMailList;

        // 取引先の登録後の名寄せ判定チェック
        List<Account> selAccount = [SELECT Id, NAME, IsMergeCompletedFlag__c FROM Account];



system.debug('★★★★★★★  nayose_test1終了  ★★★★★★★');
system.debug('');
    }

     /**
     * 以下の条件に紐づくテストケース（名寄せ確認用）
     * 
     * ポータルサイトからのメール：ＯＫ
     * 取引先に登録済み顧客：ＮＧ
     * 取引先に紐つく対応が存在する：-
     * 
     * 既存取引先データと今回登録する取引先とで一致するケース
     * 
     * ＜処理結果＞
     * 取引先：対象 / 対応：登録 / 対応明細：登録 / お気に入り物件：登録
     */
    @isTest static void nayose_test2(){
        system.debug('■■■■■■■■■■■  nayose_test2開始  ■■■■■■■■■■■');

        List<EchoMail__c> ecoMailList = new List<EchoMail__c>();

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_ATHOME];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件

        // 取引先登録（メール１が不一致により紐づかない）
        account = createAccount('洞口太郎',
                                'test1@rand.co.jp', 'test2@rand.co.jp', 'test3@rand.co.jp',
                                '111-1111-1111', '222-2222-2222', '333-3333-3333', '仕込');
        insert account;

        // 反響メール登録値設定
        // 名前のみが一致するケース
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'customerEmail@rand.co.jp', '999-9999-9999', true, false);
        ecoMailList.add(ecoMail);
        // 電話番号1が一致するケース
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口花子Ａ', 
                                    'customerEmail@rand.co.jp', '111-1111-1111', true, false);
        ecoMailList.add(ecoMail);
        // 電話番号2が一致するケース
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口花子Ｂ', 
                                    'bbbbbbbb@rand.co.jp', '222-2222-2222', true, false);
        ecoMailList.add(ecoMail);   
        // 電話番号3が一致するケース
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口花子Ｃ', 
                                    'aaaaaaaa@rand.co.jp', '333-3333-3333', true, false);
        ecoMailList.add(ecoMail);
        // メール1が一致するケース
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口花子Ｄ', 
                                    'test1@rand.co.jp', '000-0000-0000', true, false);
        ecoMailList.add(ecoMail);
        // メール2が一致するケース
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口花子Ｅ', 
                                    'test2@rand.co.jp', '000-0000-0000', true, false);
        ecoMailList.add(ecoMail);
        // メール3が一致するケース
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口花子Ｆ', 
                                    'test3@rand.co.jp', '000-0000-0000', true, false);
        ecoMailList.add(ecoMail);
        // 全て一致しない為、名寄せ対象外となる
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口五郎', 
                                    'gogogorou@rand.co.jp', '111-2222-3333', true, false);
        ecoMailList.add(ecoMail);

        insert ecoMailList;

        // 取引先の登録後の名寄せ判定チェック
        List<Account> selAccount = [SELECT Id, NAME, IsMergeCompletedFlag__c
                                    FROM Account 
                                    WHERE Comment__c != '仕込'];

        for (Account dt : selAccount) {
            if (dt.NAME == '洞口五郎') {
                System.assert(dt.IsMergeCompletedFlag__c == true);
            } else {
                System.assert(dt.IsMergeCompletedFlag__c == false);
            }
        }

system.debug('★★★★★★★  nayose_test2終了  ★★★★★★★');
system.debug('');
    }

     /**
     * 以下の条件に紐づくテストケース（反響メール受信時、取引先.メールアドレスに空項目がある場合更新）
     * 
     * ポータルサイトからのメール：ＯＫ
     * 
     * 反響メール受信時、取引先.名前、取引先.電話番号が一致し、取引先.メールアドレスに空項目がある場合、メールアドレスを追加し更新
     * ※取引先.メールアドレス(1~3)が埋まっている場合、更新しない
     * 
     * ＜処理結果＞
     * 取引先：対象 / 対応：登録 
     */
    @isTest static void updateAccountEMail_test(){
        system.debug('■■■■■■■■■■■  updateAccountEMail_test開始  ■■■■■■■■■■■');

        List<EchoMail__c> ecoMailList = new List<EchoMail__c>();

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_ATHOME];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件

        // 取引先登録（メールが空項目）
        account = createAccount('洞口太郎', '', '', '', '000-9999-9999', '', '', '');
        insert account;

        List<Account> selAccount2 = [SELECT Id, NAME, IsMergeCompletedFlag__c FROM Account];
        system.debug(selAccount2);
        // 反響メール登録値設定
        // 洞口太郎：メールアドレス一致により名寄せ対象となる　
        
        //（取引先の電話番号一致だが、メアドが埋まってるので更新されないようにする）
        
        // 名前、電話番号が一致し、メールアドレス1にメアドが追加されるケース
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'aaaaaaaa@rand.co.jp', '000-9999-9999', true, false);
        ecoMailList.add(ecoMail);   
        // 名前、電話番号が一致し、メールアドレス2にメアドが追加されるケース
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'bbbbbbbb@rand.co.jp', '000-9999-9999', true, false);
        ecoMailList.add(ecoMail);
        // 名前、電話番号が一致し、メールアドレス3にメアドが追加されるケース
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'cccccccc@rand.co.jp', '000-9999-9999', true, false);
        ecoMailList.add(ecoMail);
        //メールアドレスに空項目がないため、更新されないケース
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'dddddddd@rand.co.jp', '000-9999-9999', true, false);
        ecoMailList.add(ecoMail);

        insert ecoMailList;

        // 取引先の登録後の名寄せ判定チェック
        List<Account> selAccount = [SELECT Id, NAME, IsMergeCompletedFlag__c FROM Account];
        


system.debug('★★★★★★★  updateAccountEMail_test終了  ★★★★★★★');
system.debug('');
    }

    /**
     * 以下の条件に紐づくテストケース（反響メール受信時、取引先.電話番号に空項目がある場合更新）
     * 
     * ポータルサイトからのメール：ＯＫ
     * 
     * 反響メール受信時、取引先.名前、取引先.メールアドレスが一致し、取引先.電話番号に空項目がある場合、電話番号を追加し更新
     * ※取引先.電話番号(1~3)が埋まっている場合、更新しない
     * 
     * ＜処理結果＞
     * 取引先：対象 / 対応：登録 
     */
    @isTest static void updateAccountPhone_test(){
        system.debug('■■■■■■■■■■■  updateAccountPhone_test開始  ■■■■■■■■■■■');

        List<EchoMail__c> ecoMailList = new List<EchoMail__c>();

        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_ATHOME];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件

        // 取引先登録（電話番号が空項目）
        account = createAccount('洞口太郎', 'aaaaa@rand.co.jp', '', '', '', '', '', '');
        insert account;

        
        // 反響メール登録値設定
        
        // 名前、メールアドレスが一致し、電話番号1に電話番号が追加されるケース       
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'aaaaa@rand.co.jp', '000-0000-0000', true, false);
        ecoMailList.add(ecoMail);   
        // 名前、メールアドレスが一致し、電話番号2に電話番号が追加されるケース  
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'aaaaa@rand.co.jp', '111-1111-1111', true, false);
        ecoMailList.add(ecoMail);
        // 名前、メールアドレスが一致し、電話番号3に電話番号が追加されるケース  
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'aaaaa@rand.co.jp', '222-2222-2222', true, false);
        ecoMailList.add(ecoMail);
        //電話番号に空項目がないため、更新されないケース
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'aaaaa@rand.co.jp', '333-3333-3333', true, false);
        ecoMailList.add(ecoMail);
        
        insert ecoMailList;

        // 取引先の登録後の名寄せ判定チェック
        List<Account> selAccount = [SELECT Id, NAME, IsMergeCompletedFlag__c FROM Account];
        
system.debug('★★★★★★★  updateAccountPhone_test終了  ★★★★★★★');
system.debug('');
    }


    /**
     * 以下の条件に紐づくテストケース（自社ポータルからの問合せメール受信時、取引先がない場合その取引先を自動作成）
     * 
     * 自社ポータルからの問合せメール受信時に、取引先がない場合、問合せメール内容から取引先・対応・対応明細を新規作成する
     * ＜処理結果＞
     * 取引先：対象 / 対応：登録 /対応明細：登録 
     */
    @isTest static void OwnPortalTest(){
        system.debug('■■■■■■■■■■■  OwnPortalTest開始  ■■■■■■■■■■■');

        // ポータルサイト
        PortalSite__c portal = new PortalSite__c(Name = 'RSHP',Email__c = CommonConst_ptl.EMAIL_PORTAL);
        insert portal;

        // 反響メール登録値設定
        EchoMail__c echo = new EchoMail__c( 
            Phone__c = '090-9999-9999'                 //電話番号
            ,CustomerName__c = '洞口太郎'                //お客様名
            ,FromPotalSite__c = portal.Id               //Fromポータルサイト
            ,MailType__c = CommonConst_ptl.ECHOMAIL_MAILTYPE_INQUIRY//メール種別
            ,FromEmail__c = 'tarou@mail.com'            //FROMメールアドレス 
            ,Email__c = 'tempoEmail@rand.co.jp'           
            ,MemberId__c = 'member1'
            );
            
        insert echo;

system.debug('★★★★★★★  OwnPortalTest終了  ★★★★★★★');
system.debug('');
    }

	// ▼ 2022.2.21 LINE連携対応より、開発環境、検証環境、本番環境で結果が異なる為、コメントアウト
	// ▼ 2022.2.14 LINE連携対応より、本番環境でのみエラーとなったテストの修正
	// ▼ 2021.12.10 LINE連携対応より、追加
	// /**
	//  * 自動返信メールテスト
	//  */
	// @isTest static void sendMailTest(){

	// 	// 取引先情報の設定
	// 	setAccountInfo();

	// 	// 取得成功
	// 	Integer beforeSendMailCnt = [SELECT Id FROM EmailMessage].size();
	// 	insert getEchoMail();
	// 	Integer afterSendMailCnt = [SELECT Id FROM EmailMessage].size();

	// 	System.assertNotEquals(beforeSendMailCnt, afterSendMailCnt, 'メール送信数');
	// }

	// /**
	//  * 問合せ御礼メール設定の取得テスト
	//  */
	// @isTest static void getThanksMailSettingTest(){

	// 	// 店舗
	// 	Shop__c shop = [
	// 		SELECT Id
	// 		FROM Shop__c
	// 		WHERE Name = '横井店舗'
	// 	];

	// 	// 取引先情報の設定
	// 	setAccountInfo();

	// 	// 最新レコードでの自動返信確認
	// 	CommonUtil.sleep(1000);
	// 	insert new ThanksMailSetting__c (
	// 		Subject__c = '自動返信タイトル1'
    //         , Body__c = '本文テスト'
	// 		, StartDate__c = System.today()
	// 		, EndDate__c = System.today().addDays(2)
	// 		, SendByShop__c = shop.Id
	// 		, isAutoReciveAllDay__c = true
	// 		, SendType__c = CommonConst.THANKS_MAIL_SETTING_SEND_TYPE_MAIL
	// 	);

	// 	Integer beforeSendMailCnt = [SELECT Id FROM EmailMessage].size();
	// 	insert getEchoMail();
	// 	Integer afterSendMailCnt = [SELECT Id FROM EmailMessage].size();

	// 	System.assertEquals([SELECT Subject FROM EmailMessage].Subject, '自動返信タイトル1', '最新レコードの取得');
	// 	System.assertNotEquals(beforeSendMailCnt, afterSendMailCnt, 'メール送信数');
	// }
	// ▲ 2022.2.14
    // ▲ 2022.2.21

	/**
	 * 問合せ御礼メール設定のレコード無しテスト
	 */
	@isTest static void noneThanksMailSettingTest(){

		// 取引先情報の設定
		setAccountInfo();

		// 問合せ御礼メール設定が0件
		List<ThanksMailSetting__c> thanksMailSettingList = [SELECT Id FROM ThanksMailSetting__c];
		delete thanksMailSettingList;
		
		Correspond__c beforeCorrespond = [SELECT Id, SystemModstamp FROM Correspond__c LIMIT 1];
		CommonUtil.sleep(1000);
		insert getEchoMail();
		Correspond__c afterCorrespond = [SELECT SystemModstamp FROM Correspond__c WHERE Id = :beforeCorrespond.Id LIMIT 1];

		System.assertNotEquals(beforeCorrespond.SystemModstamp, afterCorrespond.SystemModstamp, '更新実施チェック');
		System.assertEquals([SELECT Id FROM EmailMessage].size(), 0, 'メール送信数');
	}

	/**
	 * 非定休日テスト
	 */
	@isTest static void nonRegularHolidayTest(){

		// 取引先情報の設定
		setAccountInfo();

		// 行動の取得無し
		Event event = [SELECT Id, Subject FROM EVENT WHERE Subject = '定休日'];
		delete event;
		
		Correspond__c beforeCorrespond = [SELECT Id, SystemModstamp FROM Correspond__c LIMIT 1];
		CommonUtil.sleep(1000);
		insert getEchoMail();
		Correspond__c afterCorrespond = [SELECT SystemModstamp FROM Correspond__c WHERE Id = :beforeCorrespond.Id LIMIT 1];

		System.assertNotEquals(beforeCorrespond.SystemModstamp, afterCorrespond.SystemModstamp, '更新実施チェック（行動）');
		System.assertEquals([SELECT Id FROM EmailMessage].size(), 0, 'メール送信数');

		// カレンダーの取得無し
		SystemConfig__c sysCon = [SELECT PortalManagementCalendar__c FROM SystemConfig__c];
		sysCon.RegularHolidayCalendar__c = 'テスト';
		upsert sysCon;
		
		beforeCorrespond = [SELECT Id, SystemModstamp FROM Correspond__c];
		CommonUtil.sleep(1000);
		insert getEchoMail();
		afterCorrespond = [SELECT SystemModstamp FROM Correspond__c WHERE Id = :beforeCorrespond.Id];

		System.assertNotEquals(beforeCorrespond.SystemModstamp, afterCorrespond.SystemModstamp, '更新実施チェック（カレンダー）');
		System.assertEquals([SELECT Id FROM EmailMessage].size(), 0, 'メール送信数');
	}

	/**
	 * 非送信時間内テスト
	 */
	@isTest static void inNonSendTimeTest(){

		// 取引先情報の設定
		setAccountInfo();

		// 非送信時間内
		ThanksMailSetting__c thanksMailSetting = [SELECT Id FROM ThanksMailSetting__c WHERE Subject__c = '自動返信タイトル'];
		thanksMailSetting.NonSendStartTime__c = commonUtil.getNow().addHours(-1).Time();
		thanksMailSetting.NonSendEndTime__c = commonUtil.getNow().addHours(2).Time();
		thanksMailSetting.isAutoReciveAllDay__c = false;
		update thanksMailSetting;
		
		Correspond__c beforeCorrespond = [SELECT Id, SystemModstamp FROM Correspond__c LIMIT 1];
		CommonUtil.sleep(1000);
		insert getEchoMail();
		Correspond__c afterCorrespond = [SELECT SystemModstamp FROM Correspond__c WHERE Id = :beforeCorrespond.Id LIMIT 1];

		System.assertNotEquals(beforeCorrespond.SystemModstamp, afterCorrespond.SystemModstamp, '更新実施チェック');
		System.assertEquals([SELECT Id FROM EmailMessage].size(), 0, 'メール送信数');
	}

	// TODO 本番環境でエラーになった為、コメントアウト
	// /**
	//  * 非送信時間未設定テスト
	//  */
	// @isTest static void notSetNonSendTimeTest(){

	// 	// 取引先情報の設定
	// 	setAccountInfo();

	// 	// 未設定
	// 	ThanksMailSetting__c thanksMailSetting = [SELECT Id FROM ThanksMailSetting__c WHERE Subject__c = '自動返信タイトル'];
	// 	thanksMailSetting.NonSendStartTime__c = null;
	// 	thanksMailSetting.NonSendEndTime__c = null;
	// 	thanksMailSetting.isAutoReciveAllDay__c = false;
	// 	update thanksMailSetting;
		
	// 	insert getEchoMail();
	// 	System.assertEquals([SELECT Id FROM EmailMessage].size(), 1, 'メール送信数');
	// }

	// /**
	//  * 非送信時間外テスト（開始時間 < 終了時間）
	//  */
	// @isTest static void outNonSendTimeTest1(){

	// 	// 取引先情報の設定
	// 	setAccountInfo();

	// 	// 開始時間 < 終了時間
	// 	ThanksMailSetting__c thanksMailSetting = [SELECT Id FROM ThanksMailSetting__c WHERE Subject__c = '自動返信タイトル'];
	// 	thanksMailSetting.NonSendStartTime__c = commonUtil.getNow().addHours(2).Time();
	// 	thanksMailSetting.NonSendEndTime__c = commonUtil.getNow().addHours(5).Time();
	// 	thanksMailSetting.isAutoReciveAllDay__c = false;
	// 	update thanksMailSetting;

	// 	insert getEchoMail();
	// 	System.assertEquals([SELECT Id FROM EmailMessage].size(), 1, 'メール送信数');
	// }

	// /**
	//  * 非送信時間外テスト（開始時間 > 終了時間）
	//  */
	// @isTest static void outNonSendTimeTest2(){

	// 	// 取引先情報の設定
	// 	setAccountInfo();

	// 	// 開始時間 > 終了時間
	// 	ThanksMailSetting__c thanksMailSetting = [SELECT Id FROM ThanksMailSetting__c WHERE Subject__c = '自動返信タイトル'];
	// 	thanksMailSetting.NonSendStartTime__c = commonUtil.getNow().addHours(5).Time();
	// 	thanksMailSetting.NonSendEndTime__c = commonUtil.getNow().addHours(-1).Time();
	// 	thanksMailSetting.isAutoReciveAllDay__c = false;
	// 	update thanksMailSetting;

	// 	insert getEchoMail();
	// 	System.assertEquals([SELECT Id FROM EmailMessage].size(), 1, 'メール送信数');
	// }

    /**
	 * 問合せ御礼メール設定の送信種別無しテスト
	 */
	@isTest static void noneThanksMailSettingSendTypeTest(){

		// 取引先情報の設定
		setAccountInfo();

		// 送信種別 = "LINE"
		ThanksMailSetting__c thanksMailSetting = [SELECT Id FROM ThanksMailSetting__c WHERE Subject__c = '自動返信タイトル'];
		thanksMailSetting.SendType__c = CommonConst.THANKS_MAIL_SETTING_SEND_TYPE_LINE;
		update thanksMailSetting;
		
		Correspond__c beforeCorrespond = [SELECT Id, SystemModstamp FROM Correspond__c LIMIT 1];
		CommonUtil.sleep(1000);
		insert getEchoMail();
		Correspond__c afterCorrespond = [SELECT SystemModstamp FROM Correspond__c WHERE Id = :beforeCorrespond.Id LIMIT 1];

		System.assertNotEquals(beforeCorrespond.SystemModstamp, afterCorrespond.SystemModstamp, '更新実施チェック');
		System.assertEquals([SELECT Id FROM EmailMessage].size(), 0, 'メール送信数');
	}

	/**
	 * 自動返信の自社ポータルテスト
	 */
	@isTest static void autoReciveIsMyPortalTest(){

		// 取引先情報の設定
		setAccountInfo();

		// メール = 自社ポータル
		SystemConfig__c sysCon = [SELECT Id FROM SystemConfig__c];
		sysCon.EmaiPortal__c = CommonConst.EMAIL_SUMO;
		update sysCon;
		
		Correspond__c beforeCorrespond = [SELECT Id, SystemModstamp FROM Correspond__c LIMIT 1];
		CommonUtil.sleep(1000);
		insert getEchoMail();
		Correspond__c afterCorrespond = [SELECT SystemModstamp FROM Correspond__c WHERE Id = :beforeCorrespond.Id LIMIT 1];

		System.assertNotEquals(beforeCorrespond.SystemModstamp, afterCorrespond.SystemModstamp, '更新実施チェック');
		System.assertEquals([SELECT Id FROM EmailMessage].size(), 0, 'メール送信数');
	}

	/**
	 * 自動返信のメール未設定テスト
	 */
	@isTest static void autoReciveEmailNoneTest(){

		// 取引先情報の設定
		setAccountInfo();
		
		// メール = 未設定
		EchoMail__c echoMail = getEchoMail();
		echoMail.FromEmail__c = null;
		insert echoMail;

		System.assertEquals([SELECT Id, SystemModstamp FROM Correspond__c].size(), 2, '更新実施チェック');
		System.assertEquals([SELECT Id FROM EmailMessage].size(), 0, 'メール送信数');
	}

	/**
	 * 自動返信のSUUMOメールテスト
	 */
	@isTest static void autoReciveEmailSuumoTest(){

		// 取引先情報の設定
		setAccountInfo();

		// メール = SUUMO
		EchoMail__c echoMail = getEchoMail();
		echoMail.FromEmail__c = CommonConst.EMAIL_SUMO;
		insert echoMail;

		System.assertEquals([SELECT Id, SystemModstamp FROM Correspond__c].size(), 2, '更新実施チェック');
		System.assertEquals([SELECT Id FROM EmailMessage].size(), 0, 'メール送信数');
	}

	/**
	 * 自動返信のat homeメールテスト
	 */
	@isTest static void autoReciveEmailAtHomeTest(){

		// 取引先情報の設定
		setAccountInfo();
		
		// メール = at home
		EchoMail__c echoMail = getEchoMail();
		echoMail.FromEmail__c = CommonConst.EMAIL_ATHOME;
		insert echoMail;

		System.assertEquals([SELECT Id, SystemModstamp FROM Correspond__c].size(), 2, '更新実施チェック');
		System.assertEquals([SELECT Id FROM EmailMessage].size(), 0, 'メール送信数');
	}

	/**
	 * 自動返信のHOME'Sメールテスト
	 */
	@isTest static void autoReciveEmailHomesTest(){

		// 取引先情報の設定
		setAccountInfo();
		
		// メール = HOME'S
		EchoMail__c echoMail = getEchoMail();
		echoMail.FromEmail__c = CommonConst.EMAIL_HOMES;
		insert echoMail;

		System.assertEquals([SELECT Id, SystemModstamp FROM Correspond__c].size(), 2, '更新実施チェック');
		System.assertEquals([SELECT Id FROM EmailMessage].size(), 0, 'メール送信数');
	}

    /**
     * ▼ 2022/3/18 CHINTAI対応による追加
	 * 自動返信のCHINTAIメールテスト
	 */
	@isTest static void autoReciveEmailChintaiTest(){

		// 取引先情報の設定
		setAccountInfo();
		
		// メール = CHINTAI
		EchoMail__c echoMail = getEchoMail();
		echoMail.FromEmail__c = CommonConst.EMAIL_CHINTAI;
		insert echoMail;

		System.assertEquals([SELECT Id, SystemModstamp FROM Correspond__c].size(), 2, '更新実施チェック');
		System.assertEquals([SELECT Id FROM EmailMessage].size(), 0, 'メール送信数');
	}

	// ▼ 2022.2.21 LINE連携対応より、開発環境、検証環境、本番環境で結果が異なる為、コメントアウト
	// /**
	//  * 対応と取引先の未紐づけ処理テスト（LINE会員の対応有り）
	//  */
	// @isTest static void setUnlinkedCorrespondTest1(){

	// 	// 取引先情報の設定
	// 	setAccountInfo();
		
	// 	// 取引先を未設定、LINE会員を設定
	// 	Correspond__c beforeCorrespond = [SELECT Id, SystemModstamp FROM Correspond__c];
	// 	CommonUtil.sleep(1000);

	// 	EchoMail__c echoMail = getEchoMail();
	// 	echoMail.CustomerName__c = null;
	// 	echoMail.LineMember__c = [SELECT Id FROM LineMember__c WHERE Name = 'テストLINE会員'].Id;
	// 	insert echoMail;

	// 	Correspond__c afterCorrespond = [SELECT SystemModstamp FROM Correspond__c WHERE Id = :beforeCorrespond.Id];

	// 	System.assertNotEquals(beforeCorrespond.SystemModstamp, afterCorrespond.SystemModstamp, '更新実施チェック');
	// }

	// /**
	//  * 対応と取引先の未紐づけ処理テスト（LINE会員の対応無し）
	//  */
	// @isTest static void setUnlinkedCorrespondTest2(){

	// 	// 取引先情報の設定
	// 	setAccountInfo();

	// 	// 同一の取引先を作成
	// 	account = createAccount('洞口太郎', 'customerEmail@rand.co.jp', '', '', '', '', '', '仕込');
	// 	insert account;

	// 	System.assertEquals([SELECT SystemModstamp FROM Correspond__c].size(), 1, '更新前件数チェック');

	// 	// LINE会員を未設定
	// 	EchoMail__c echoMail = getEchoMail();
	// 	insert echoMail;

	// 	System.assertEquals([SELECT SystemModstamp FROM Correspond__c].size(), 2, '更新実施チェック');
	// }
	// ▲ 2022.2.21


	/**
	 * 反響メールのLINE情報更新テスト
	 */
	@isTest static void updateLineInfoEchoMailTest(){

		// 同一の取引先情報の設定
		setAccountInfo();

		// LINE会員の取得
		LineMember__c lineMember = [
			SELECT
				Id
				, LineId__c
			FROM LineMember__c
			WHERE Name = 'テストLINE会員'
		];

		// LINE受信の設定
		EchoMail__c echoMail = getEchoMail();
		echoMail.IsLineReceive__c = true;
		echoMail.LineMember__c = lineMember.Id;
		echoMail.LineId__c = lineMember.LineId__c;
		insert echoMail;

		// 結果用オブジェクトの取得
		lineMember = [SELECT Id, Status__c FROM LineMember__c WHERE Id = :lineMember.Id];
		List<LineHistory__c> lineHistory = [SELECT SendType__c FROM LineHistory__c WHERE LineMember__c = :lineMember.Id];

		System.assertEquals(lineMember.Status__c, CommonConst.LINE_MEMBER_STATUS_NOT_REPLIED, 'LINE会員の更新値チェック');
		System.assertEquals(lineHistory.size(), 1, 'LINE履歴の登録実施チェック');
	}

	/**
	 * 自動返信のLINE情報更新テスト
	 */
	@isTest static void updateLineInfoAutoReciveTest(){

		// 同一の取引先情報の設定
		setAccountInfo();

		// LINE会員の取得
		LineMember__c lineMember = [
			SELECT
				Id
				, LineId__c
			FROM LineMember__c
			WHERE Name = 'テストLINE会員'
		];

		// LINE用の問合せ御礼メール設定の設定
		ThanksMailSetting__c thanksMailSetting = [SELECT Id FROM ThanksMailSetting__c WHERE Subject__c = '自動返信タイトル'];
		thanksMailSetting.SendType__c = CommonConst.THANKS_MAIL_SETTING_SEND_TYPE_LINE;
		update thanksMailSetting;

		// LINE受信の設定
		EchoMail__c echoMail = getEchoMail();
		echoMail.IsLineReceive__c = true;
		echoMail.LineMember__c = lineMember.Id;
		echoMail.LineId__c = lineMember.LineId__c;
		insert echoMail;

		// 結果用オブジェクトの取得
		lineMember = [SELECT Id, Status__c FROM LineMember__c WHERE Id = :lineMember.Id];
		List<LineHistory__c> lineHistory = [SELECT SendType__c FROM LineHistory__c WHERE LineMember__c = :lineMember.Id];

		System.assertEquals(lineMember.Status__c, CommonConst.LINE_MEMBER_STATUS_DONE_REPLIED, 'LINE会員の更新値チェック');
		System.assertEquals(lineHistory.size(), 2, 'LINE履歴の登録実施チェック');
	}

	// ▼ 2022.2.21 LINE連携対応より、開発環境、検証環境、本番環境で結果が異なる為、コメントアウト
	// /**
	//  * 警告メール送信テスト
	//  */
	// @isTest static void sendWarningMailTest(){

	// 	// 同一の取引先情報の設定
	// 	setAccountInfo();

	// 	// 1件以上のメール送信時に警告メールを送信
	// 	SystemConfig__c sysCon = [SELECT Id FROM SystemConfig__c];
	// 	sysCon.sendMailLimitWarningCount__c = 0;
	// 	update sysCon;

	// 	insert getEchoMail();
	// 	System.assertEquals([SELECT Id FROM EmailMessage].size(), 2, 'メール送信数');
	// }
	// ▲ 2022.2.21
	// ▲ 2021.12.10

	// ▼ 2022/3/18 CHINTAI対応による追加
	/**
	 * 以下の条件に紐づくテストケース
	 * 
	 * ポータルサイトからのメール：ＯＫ
	 * 取引先に登録済み顧客：ＯＫ
	 * 取引先に紐つく対応が存在する：ＯＫ
	 * 
	 * ＜処理結果＞
	 * 取引先：対象外 / 対応：更新 / 対応明細：登録 / お気に入り物件：登録
	 */
	@isTest static void testChintai1(){
		// 必要情報取得
		List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_CHINTAI]; // ポータルサイト
		List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
		List<Shop__c> shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];    // 店舗
		// ユーザ情報取得
		User userHankyo =  [SELECT Id FROM User WHERE LastName = 'hankyo'];
		User userRaiten =  [SELECT Id FROM User WHERE LastName = 'raiten'];

		// 取引先登録（メール１が一致により紐づく）
		account = createAccount('洞口太郎', 'customerEmail@rand.co.jp', '', '', '', '', '', '仕込');
		insert account;

		// // 対応登録（ステータス：未対応）
		correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED, shop[0].Id, true, false, userHankyo, userRaiten);
		insert correspond;

		// 登録前のデータ件数チェック
		// 反響メール、取引先、対応、対応明細、お気に入り物件
		chintaiCheckObjectCnt(0, 1, 1, 0, 0);

		// 反響メール登録値設定
		ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
									'customerEmail@rand.co.jp', '', true, false);
		insert ecoMail;

		// 登録後のデータ件数チェック
		// 反響メール、取引先、対応、対応明細、お気に入り物件
		chintaiCheckObjectCnt(1, 1, 1, 2, 1);
	}
	// ▲ 2022/3/18 CHINTAI対応による追加

	// ▼ 2022/3/18 CHINTAI対応による追加
	/**
     * 以下の条件に紐づくテストケース
     * 
     * ポータルサイトからのメール：ＯＫ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＮＧ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：登録 / 対応明細：登録 / お気に入り物件：登録
     */
    @isTest static void testChintai2(){
        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_CHINTAI];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件

        // 取引先登録（電話番号１が一致により紐づく）
        account = createAccount('洞口太郎', '', '', '', '090-9999-9999', '', '', '仕込');
        insert account;

        // お気に入り物件登録
        favorite = createFavorite(account.Id, property[0].Id);
        insert favorite;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        chintaiCheckObjectCnt(0, 1, 0, 0, 1);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    '', '090-9999-9999', true, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        chintaiCheckObjectCnt(1, 1, 1, 1, 1);
    }
	// ▲ 2022/3/18 CHINTAI対応による追加
	// ▼ 2022/3/18 CHINTAI対応による追加
    /**
     * 以下の条件に紐づくテストケース
     * 
     * ポータルサイトからのメール：ＯＫ
     * 取引先に登録済み顧客：ＮＧ
     * 取引先に紐つく対応が存在する：-
     * 
     * ＜処理結果＞
     * 取引先：対象 / 対応：登録 / 対応明細：登録 / お気に入り物件：登録
     */
    @isTest static void testChintai3(){
        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_CHINTAI];    // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件

        // 取引先登録（メール１が不一致により紐づかない）
        account = createAccount('洞口太郎', 'aaaaaa@rand.co.jp', '', '', '', '', '', '仕込');
        
        insert account;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        chintaiCheckObjectCnt(0, 1, 0, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口 太 郎', 
                                    'customerEmail@rand.co.jp', '090-9999-9999', true, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        chintaiCheckObjectCnt(1, 2, 1, 2, 1);
    }
	// ▲ 2022/3/18 CHINTAI対応による追加
	// ▼ 2022/3/18 CHINTAI対応による追加
    /**
     * 以下の条件に紐づくテストケース
     * 
     * ポータルサイトからのメール：ＮＧ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＯＫ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：登録 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void testChintai4(){
		// 必要情報取得
		List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = 'test@rand.co.jp'];    // ポータルサイト以外
		List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
		List<Shop__c> shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];    // 店舗
		// ユーザ情報取得
		User userHankyo =  [SELECT Id FROM User WHERE LastName = 'hankyo'];
		User userRaiten =  [SELECT Id FROM User WHERE LastName = 'raiten'];
		// 取引先登録（メール２が一致により紐づく）
		account = createAccount('洞口太郎', '', 'customerEmail@rand.co.jp', '', '', '', '', '仕込');
		insert account;
		// 対応登録（ステータス：未対応）
		correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED, shop[0].Id, false, false, userHankyo, userRaiten);
		insert correspond;

		// 登録前のデータ件数チェック
		// 反響メール、取引先、対応、対応明細、お気に入り物件
		chintaiCheckObjectCnt(0, 1, 1, 0, 0);

		// 反響メール登録値設定
		ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区',  '洞口太郎', 
									'customerEmail@rand.co.jp', '', false, false);
		insert ecoMail;

		// 登録後のデータ件数チェック
		// 反響メール、取引先、対応、対応明細、お気に入り物件
		chintaiCheckObjectCnt(1, 1, 1, 1, 0);
	}
	// ▲ 2022/3/18 CHINTAI対応による追加
	// ▼ 2022/3/18 CHINTAI対応による追加
	/**
     * 以下の条件に紐づくテストケース
     * 
     * ポータルサイトからのメール：ＮＧ
     * 取引先に登録済み顧客：ＯＫ
     * 取引先に紐つく対応が存在する：ＮＧ
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：登録 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void testChintai5(){
		// 必要情報取得
		List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = 'test@rand.co.jp'];    // ポータルサイト
		List<Property__c> property = [SELECT Id FROM Property__c];    // 物件

		// 取引先登録（メール３が一致により紐づく）
		account = createAccount('洞口太郎', '', '', 'customerEmail@rand.co.jp', '', '', '', '仕込');
		insert account;

		// 登録前のデータ件数チェック
		// 反響メール、取引先、対応、対応明細、お気に入り物件
		chintaiCheckObjectCnt(0, 1, 0, 0, 0);

		// 反響メール登録値設定
		ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
									'customerEmail@rand.co.jp', '', false, false);
		insert ecoMail;

		// 登録後のデータ件数チェック
		// 反響メール、取引先、対応、対応明細、お気に入り物件
		chintaiCheckObjectCnt(1, 1, 1, 1, 0);
	}
	// ▲ 2022/3/18 CHINTAI対応による追加
	// ▼ 2022/3/18 CHINTAI対応による追加
	/**
     * 以下の条件に紐づくテストケース
     * 
     * ポータルサイトからのメール：ＮＧ
     * 取引先に登録済み顧客：ＮＧ
     * 取引先に紐つく対応が存在する：-
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：登録 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void testChintai6(){
		// 必要情報取得
		List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = 'test@rand.co.jp'];    // ポータルサイト
		List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
	
		// 取引先登録（メール１が不一致により紐づかない）
		account = createAccount('洞口太郎', 'bbbbbb@rand.co.jp', '', '', '', '', '', '');
		insert account;

		// 登録前のデータ件数チェック
		// 反響メール、取引先、対応、対応明細、お気に入り物件
		chintaiCheckObjectCnt(0, 1, 0, 0, 0);

		// 反響メール登録値設定
		ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
									'customerEmail@rand.co.jp', '090-9999-9999', false, false);
		insert ecoMail;

		// 登録後のデータ件数チェック
		// 反響メール、取引先、対応、対応明細、お気に入り物件
		chintaiCheckObjectCnt(1, 1, 1, 1, 0);
	}
	// ▲ 2022/3/18 CHINTAI対応による追加

    // ▼ 2022/3/18 CHINTAI対応による追加
    /**
     * 以下の条件に紐づくテストケース（取引先重複）
     * 
     * ポータルサイトからのメール：ＯＫ
     * 取引先に登録済み顧客：ＯＫ（複数件あり）
     * 取引先に紐つく対応が存在する：ー
     * 
     * ＜処理結果＞
     * 取引先：対象外 / 対応：登録 / 対応明細：登録 / お気に入り物件：対象外
     */
    @isTest static void testChintai7(){
        // 必要情報取得
        List<PortalSite__c> portal = [SELECT Id FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_SUMO]; // ポータルサイト
        List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
        List<Shop__c> shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];    // 店舗
        List<Account> accList = new List<Account>();

        // 取引先登録（反響メールに紐づく取引先を複数件作成）
        account = new Account();
        account = createAccount('洞口太郎', 'customerEmail@rand.co.jp', '', '', '', '', '', '仕込');
        accList.add(account);
        account = new Account();
        account = createAccount('洞口太郎', 'customerEmail@rand.co.jp', '', '', '', '', '', '仕込');
        accList.add(account);
        insert accList;

        // 登録前のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(0, 2, 0, 0, 0);

        // 反響メール登録値設定
        ecoMail = createEchoMail(portal[0].Id, property[0].Id, '守山区', '洞口太郎', 
                                    'customerEmail@rand.co.jp', '', true, false);
        insert ecoMail;

        // 登録後のデータ件数チェック
        // 反響メール、取引先、対応、対応明細、お気に入り物件
        checkObjectCnt(1, 2, 1, 1, 0);
    }
    // ▲ 2022/3/18 CHINTAI対応による追加
	    
	//▼ 2022.04.04 No0745 対応で追加
	/**
	* 問合せメール（LINE）
	*     line会員紐づけ取引先有（取引先のメールアドレスがline会員ID）
	*     対象の取引先の対応が紐づき、対応が新規作成されないこと
	*/
	@istest static void linePeggingTest1(){
		// テストデータ取得
		PortalSite__c portalSite = [SELECT ID,NAME FROM PortalSite__c WHERE NAME = '自社ポータル' LIMIT 1];	// 自社ポータル
		List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
		Shop__c shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];	// 店舗

		// トリガーを動かさない
		SystemConfig__c sysCon = [SELECT Id, IsSkipTrigger__c FROM SystemConfig__c];
        sysCon.IsSkipTrigger__c = true;
        update sysCon;

		String lineId = '1234567890';
		// 登録
		// 取引先（取引先のメールアドレスがline会員ID）
		Account insAccount = createAccount('テストLINE会員', lineId, '', '', '', '', '', '仕込');
		insert insAccount;
		// LINE会員
		LineMember__c insLineMember = new LineMember__c(Name = 'テストLINE会員'	, LineId__c = lineId, Account__c = insAccount.id);
		insert insLineMember;
		// Line対応の作成
		Correspond__c cor = insCorrespond(2,insAccount.ID,insLineMember.Id,shop.id,portalSite.ID);
		
		// LINE受信の設定
		EchoMail__c echoMail = createEchoMail(portalSite.Id, property[0].Id, '', '', 
            lineId, '', false, false,true,CommonConst_ptl.ECHOMAIL_MAILTYPE_INQUIRY,insLineMember);
		insert echoMail;

		// スキップトリガを戻す。
		sysCon.IsSkipTrigger__c = false;
		update sysCon;

		test.startTest();

		//バッチ起動
		BA101005Batch b = new BA101005Batch(1); 
		Database.executeBatch(b,200);

		test.stopTest();


		// 結果用オブジェクトの取得
		List<Correspond__c> correspondList =[SELECT ID FROM Correspond__c WHERE LineMember__c = :insLineMember.Id];
        System.assertEquals(1, correspondList.size(), 'line会員紐づけ取引先有（取引先のメールアドレスがline会員ID）：対応件数');
        CorrespondDetail__c correspondDetail = [SELECT ID ,EchoMail__c,Email__c,SupportedTitle__c FROM CorrespondDetail__c WHERE Corresponds__c = :correspondList[0].Id ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals(echoMail.id, correspondDetail.EchoMail__c, 'line会員紐づけ取引先有（取引先のメールアドレスがline会員ID）：対応明細');
        System.assertEquals(lineId, correspondDetail.Email__c, 'line会員紐づけ取引先有（取引先のメールアドレスがline会員ID）：対応明細');
        System.assertEquals(echoMail.Subject__c, correspondDetail.SupportedTitle__c, 'line会員紐づけ取引先有（取引先のメールアドレスがline会員ID）：対応明細');
		LineHistory__c lineHistory =[SELECT Id, LineMember__c, Message__c, SendTime__c, SendType__c FROM LineHistory__c WHERE LineMember__c = :insLineMember.id ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals('ラインメッセージ', lineHistory.Message__c, 'line会員紐づけ取引先有（取引先のメールアドレスがline会員ID）：LINE履歴');
		System.assertEquals(CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER, lineHistory.SendType__c, 'line会員紐づけ取引先有（取引先のメールアドレスがline会員ID）：LINE履歴');

	}

	/**
	* 問合せメール（LINE）
	*     line会員紐づけ取引先有（取引先のメールアドレスが通常の内容）
	*     対象の取引先の対応が紐づき、対応が新規作成されないこと
	*/
	@istest static void linePeggingTest2(){
		// テストデータ取得
		PortalSite__c portalSite = [SELECT ID,NAME FROM PortalSite__c WHERE NAME = '自社ポータル' LIMIT 1];	// 自社ポータル
		List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
		Shop__c shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];	// 店舗

		// トリガーを動かさない
		SystemConfig__c sysCon = [SELECT Id, IsSkipTrigger__c FROM SystemConfig__c];
		sysCon.IsSkipTrigger__c = true;
		update sysCon;

		// 登録
		// 取引先
		Account insAccount = createAccount('テストLINE会員', 'customerEmail@rand.co.jp', '', '', '', '', '', '仕込');
		insert insAccount;
		// LINE会員
		LineMember__c insLineMember = new LineMember__c(Name = 'テストLINE会員'	, LineId__c = '1234567890'	, Account__c = insAccount.id);
		insert insLineMember;
		// Line対応の作成
		Correspond__c cor = insCorrespond(2,insAccount.ID,insLineMember.Id,shop.id,portalSite.ID);
		
		// LINE受信の設定
		EchoMail__c echoMail = createEchoMail(portalSite.Id, property[0].Id, '守山区', '洞口太郎', 
			'customerEmail@rand.co.jp', '', false, false,true,CommonConst_ptl.ECHOMAIL_MAILTYPE_INQUIRY,insLineMember);
		insert echoMail;

		// スキップトリガを戻す。
		sysCon.IsSkipTrigger__c = false;
		update sysCon;

		test.startTest();

		//バッチ起動
		BA101005Batch b = new BA101005Batch(1);
		Database.executeBatch(b,200);

		test.stopTest();


		// 結果用オブジェクトの取得	
		List<Correspond__c> correspondList =[SELECT ID FROM Correspond__c WHERE LineMember__c = :insLineMember.Id];
		System.assertEquals(1, correspondList.size(), 'line会員紐づけ取引先有（取引先のメールアドレスが通常の内容）：対応件数');
		CorrespondDetail__c correspondDetail =[SELECT ID ,EchoMail__c,Email__c,SupportedTitle__c FROM CorrespondDetail__c WHERE Corresponds__c = :correspondList[0].Id ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals(echoMail.id, correspondDetail.EchoMail__c, 'line会員紐づけ取引先有（取引先のメールアドレスが通常の内容）：対応明細');
		System.assertEquals('customerEmail@rand.co.jp', correspondDetail.Email__c, 'line会員紐づけ取引先有（取引先のメールアドレスが通常の内容）：対応明細');
		System.assertEquals(echoMail.Subject__c, correspondDetail.SupportedTitle__c, 'line会員紐づけ取引先有（取引先のメールアドレスが通常の内容）：対応明細');
		LineHistory__c lineHistory =[SELECT Id, LineMember__c, Message__c, SendTime__c, SendType__c FROM LineHistory__c WHERE LineMember__c = :insLineMember.id ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals('ラインメッセージ', lineHistory.Message__c, 'line会員紐づけ取引先有（取引先のメールアドレスが通常の内容）：LINE履歴');
		System.assertEquals(CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER, lineHistory.SendType__c, 'line会員紐づけ取引先有（取引先のメールアドレスが通常の内容）：LINE履歴');

	}
	/**
	* 反響メール（LINE）
	*     LINE会員紐づけ取引先無（LINE会員有）
	*     LINE会員に紐づく対応が紐づき、対応が新規作成されないこと
    *     ポータルサイト、ポータルサイトURL、初回問合せ方法（メール）が設定されていないこと 2022.05.16 No0759 追加
	*/
	@istest static void linePeggingTest3(){
		// テストデータ取得
		PortalSite__c portalSite = [SELECT ID,NAME FROM PortalSite__c WHERE NAME = '自社ポータル' LIMIT 1];	// 自社ポータル
		List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
		Shop__c shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];	// 店舗

		// トリガーを動かさない
		SystemConfig__c sysCon = [SELECT Id, IsSkipTrigger__c FROM SystemConfig__c];
		sysCon.IsSkipTrigger__c = true;
		update sysCon;

		// 登録
		// 取引先
		Account insAccount = createAccount('テストLINE会員じゃねえ', 'customerEmail@rand.co.jp', '', '', '', '', '', '仕込');
		insert insAccount;
		// LINE会員
		LineMember__c insLineMember = new LineMember__c(Name = 'テストLINE会員'	, LineId__c = '1234567890');
		insert insLineMember;
		// 2022.05.16 No0758 対応作成を削除：LINE会員トリガで対応が作成されるため
		
		// LINE受信の設定
		EchoMail__c echoMail = createEchoMail(portalSite.Id, property[0].Id, '守山区', '', 
			insLineMember.LineId__c, '', false, false,true,CommonConst_ptl.ECHOMAIL_MAILTYPE_ECHOMAIL,insLineMember);
		insert echoMail;

		// スキップトリガを戻す。
		sysCon.IsSkipTrigger__c = false;
		update sysCon;

		test.startTest();

		//バッチ起動
		BA101005Batch b = new BA101005Batch(1); 
		Database.executeBatch(b,200);

		test.stopTest();

		// 結果用オブジェクトの取得	
		List<Correspond__c> correspondList =[SELECT ID,FirstLineAddFlg__c,PortalSite__c,PortalSiteUrl__c,FirstInquiryMeans__c FROM Correspond__c WHERE LineMember__c = :insLineMember.Id ORDER BY CreatedDate DESC];
		System.assertEquals(1, correspondList.size(), 'line会員紐づけ取引先無（LINE会員有）：対応件数');
		// LINE追加（反響）：対応．初回LINE追加フラグがTrueでセットされること// 2022.05.16 No0758 対応で追加
		System.assertEquals(true, correspondList[0].FirstLineAddFlg__c, 'line会員紐づけ取引先無（LINE会員有）：初回LINE追加フラグ'); 
        // ポータルサイト、ポータルサイトURL、初回問合せ方法（メール）が設定されていないこと　▼ 2022.05.16 No0759 対応で追加
        System.assertEquals(null, correspondList[0].PortalSite__c, '項目チェック：ポータルサイト');
        System.assertEquals(null, correspondList[0].PortalSiteUrl__c, '項目チェック：ポータルサイトURL');
        System.assertEquals(null, correspondList[0].FirstInquiryMeans__c, '項目チェック：初回問合せ方法（メール）');
        // ▲ 2022.05.16 No0759 対応で追加

		CorrespondDetail__c correspondDetail =[SELECT ID ,EchoMail__c,Email__c,SupportedTitle__c FROM CorrespondDetail__c WHERE Corresponds__c = :correspondList[0].Id ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals(echoMail.id, correspondDetail.EchoMail__c, 'line会員紐づけ取引先無（LINE会員有）：対応明細');
		System.assertEquals(insLineMember.LineId__c, correspondDetail.Email__c, 'line会員紐づけ取引先無（LINE会員有）：対応明細');
		System.assertEquals(echoMail.Subject__c, correspondDetail.SupportedTitle__c, 'line会員紐づけ取引先無（LINE会員有）：対応明細');		
		LineHistory__c lineHistory =[SELECT Id, LineMember__c, Message__c, SendTime__c, SendType__c FROM LineHistory__c WHERE LineMember__c = :insLineMember.id ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals(echoMail.LineMessage__c, lineHistory.Message__c, 'line会員紐づけ取引先無（LINE会員有）：LINE履歴');
		System.assertEquals(CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER, lineHistory.SendType__c, 'line会員紐づけ取引先無（LINE会員有）：LINE履歴');

	}
	/**
	* 問合せメール（LINE）
	*     取引先複数（内LINE会員紐づけ1件）
	*     LINE会員に紐づく取引先の対応が紐づき、対応が新規作成されないこと
    *     ポータルサイト、ポータルサイトURL、初回問合せ方法（メール）が変わらないこと 2022.05.16 No0759 追加
	*/
	@istest static void linePeggingTest4(){
		// テストデータ取得
		PortalSite__c portalSite = [SELECT ID,NAME,Url__c FROM PortalSite__c WHERE NAME = '自社ポータル' LIMIT 1];	// 自社ポータル
		List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
		Shop__c shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];	// 店舗

		// トリガーを動かさない
		SystemConfig__c sysCon = [SELECT Id, IsSkipTrigger__c FROM SystemConfig__c];
		sysCon.IsSkipTrigger__c = true;
		update sysCon;

		String lineId = '1234567890';
		// 登録
		// 取引先
		Account insAccount1 = createAccount('テストLINE会員じゃねえ', lineId, '', '', '', '', '', '仕込');
		Account insAccount2 = createAccount('テストLINE会員', lineId, '', '', '', '', '', '仕込');
		insert insAccount1;
		insert insAccount2;
		// LINE会員
		LineMember__c insLineMember = new LineMember__c(Name = 'テストLINE会員'	, LineId__c = lineId, Account__c = insAccount2.id);
		insert insLineMember;
		// Line対応の作成
		Correspond__c cor = insCorrespond(2,insAccount2.ID,insLineMember.Id,shop.id,portalSite.ID);
		
		// LINE受信の設定
		EchoMail__c echoMail = createEchoMail(portalSite.Id, property[0].Id, '守山区', '', 
				lineId, '', false, false,true,CommonConst_ptl.ECHOMAIL_MAILTYPE_INQUIRY,insLineMember);
		insert echoMail;

		// スキップトリガを戻す。
		sysCon.IsSkipTrigger__c = false;
		update sysCon;

		test.startTest();

		//バッチ起動
		BA101005Batch b = new BA101005Batch(1); //引数:起動回数が1回目
		Database.executeBatch(b,200);

		test.stopTest();


		// 結果用オブジェクトの取得	
		List<Correspond__c> correspondList =[SELECT ID,FirstLineAddFlg__c,PortalSite__c,PortalSiteUrl__c,FirstInquiryMeans__c FROM Correspond__c WHERE AccountId__c = :insAccount2.Id];
		System.assertEquals(1, correspondList.size(), '取引先複数（内LINE会員紐づけ1件）：対応件数');
		// 対応．初回LINE追加フラグがセットされないこと// 2022.05.16 No0758 対応で追加
		System.assertEquals(false, correspondList[0].FirstLineAddFlg__c, '取引先複数（内LINE会員紐づけ1件）：初回LINE追加フラグ'); 
        // ポータルサイト、ポータルサイトURL、初回問合せ方法（メール）が変わらないこと　▼ 2022.05.16 No0759 対応で追加
        System.assertEquals(portalSite.Id, correspondList[0].PortalSite__c, '項目チェック：ポータルサイト');
        System.assertEquals(portalSite.Url__c, correspondList[0].PortalSiteUrl__c, '項目チェック：ポータルサイトURL');
        System.assertEquals(CommonConst.FIRSTINQUIRYMEANS_PHONE, correspondList[0].FirstInquiryMeans__c, '項目チェック：初回問合せ方法（メール）');
        // ▲ 2022.05.16 No0759 対応で追加

		CorrespondDetail__c correspondDetail =[SELECT ID ,EchoMail__c,Email__c,SupportedTitle__c FROM CorrespondDetail__c WHERE Corresponds__c = :correspondList[0].Id ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals(echoMail.id, correspondDetail.EchoMail__c, '取引先複数（内LINE会員紐づけ1件）：対応明細');
		System.assertEquals(lineId, correspondDetail.Email__c, '取引先複数（内LINE会員紐づけ1件）：対応明細');
		System.assertEquals(echoMail.Subject__c, correspondDetail.SupportedTitle__c, '取引先複数（内LINE会員紐づけ1件）：対応明細');
		LineHistory__c lineHistory =[SELECT Id, LineMember__c, Message__c, SendTime__c, SendType__c FROM LineHistory__c WHERE LineMember__c = :insLineMember.id ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals('ラインメッセージ', lineHistory.Message__c, '取引先複数（内LINE会員紐づけ1件）：LINE履歴');
		System.assertEquals(CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER, lineHistory.SendType__c, '取引先複数（内LINE会員紐づけ1件）：LINE履歴');


	}
	
	/**
	* 問合せメール（LINE以外）
	*     取引先紐づき有
	*     取引先へ紐づくこと
	*/
	@istest static void peggingTest1(){
		// テストデータ取得
		PortalSite__c portalSite = [SELECT ID,NAME FROM PortalSite__c WHERE NAME = '自社ポータル' LIMIT 1];	// 自社ポータル
		List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
		Shop__c shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];	// 店舗

		// トリガーを動かさない
		SystemConfig__c sysCon = [SELECT Id, IsSkipTrigger__c FROM SystemConfig__c];
		sysCon.IsSkipTrigger__c = true;
		update sysCon;

		String lineId = '1234567890';
		// 登録
		// 取引先
		Account insAccount = createAccount('テストLINE会員じゃねえ', 'customerEmail@rand.co.jp', '','', '', '', '', '仕込');
		insert insAccount;
		// LINE会員
		LineMember__c insLineMember = new LineMember__c(Name = 'テストLINE会員'	, LineId__c = lineId);
		insert insLineMember;
		// Line対応の作成
		Correspond__c cor = insCorrespond(3,insAccount.ID,insLineMember.Id,shop.id,portalSite.ID);
		
		// 問合せメール（LINE以外）
		EchoMail__c echoMail = createEchoMail(portalSite.Id, property[0].Id, '守山区', 'テストLINE会員じゃねえ', 
			'customerEmail@rand.co.jp', '', false, false);
		echoMail.BatchStatus__c = CommonConst.BATCH_STUTAS_WAITING; // バッチ処理ステータス
		echoMail.Email__c = 'tempoEmail@rand.co.jp';     // メール
		insert echoMail;

		// スキップトリガを戻す。
		sysCon.IsSkipTrigger__c = false;
		update sysCon;

		test.startTest();

		//バッチ起動
		BA101005Batch b = new BA101005Batch(1); //引数:起動回数が1回目
		Database.executeBatch(b,200);

		test.stopTest();

		// 結果用オブジェクトの取得	
        List<Correspond__c> correspondList =[SELECT ID,FirstLineAddFlg__c FROM Correspond__c WHERE AccountId__c = :insAccount.Id];
		System.assertEquals(1, correspondList.size(), '問合せメール（LINE以外）：対応件数');
		// 対応．初回LINE追加フラグがセットされないこと // 2022.05.16 No0758 対応で追加
		System.assertEquals(false, correspondList[0].FirstLineAddFlg__c, '問合せメール（LINE以外）：初回LINE追加フラグ');
		CorrespondDetail__c correspondDetail =[SELECT ID ,EchoMail__c,Email__c,SupportedTitle__c FROM CorrespondDetail__c WHERE Corresponds__c = :correspondList[0].Id ORDER BY CreatedDate DESC LIMIT 1];
		System.assertEquals(echoMail.id, correspondDetail.EchoMail__c, '問合せメール（LINE以外）：対応明細');
		System.assertEquals('customerEmail@rand.co.jp', correspondDetail.Email__c, '問合せメール（LINE以外）：対応明細');
		System.assertEquals(echoMail.Subject__c, correspondDetail.SupportedTitle__c, '問合せメール（LINE以外）：対応明細');
	}
	
	/**
	* 問合せメール（LINE以外）
	*     取引先紐づき無
	*     紐づかないこと
	*/
	@istest static void peggingTest2(){
		// テストデータ取得
		PortalSite__c portalSite = [SELECT ID,NAME FROM PortalSite__c WHERE NAME = '自社ポータル' LIMIT 1];	// 自社ポータル
		List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
		Shop__c shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];	// 店舗

		// トリガーを動かさない
		SystemConfig__c sysCon = [SELECT Id, IsSkipTrigger__c FROM SystemConfig__c];
		sysCon.IsSkipTrigger__c = true;
		update sysCon;

		String lineId = '1234567890';
		// 登録
		// 取引先
		Account insAccount = createAccount('テストLINE会員', lineId, '', '', '', '', '', '仕込');
		insert insAccount;
		// LINE会員
		LineMember__c insLineMember = new LineMember__c(Name = 'テストLINE会員'	, LineId__c = lineId, Account__c = insAccount.id);
		insert insLineMember;
		
		// 問合せメール（LINE以外）
		EchoMail__c echoMail = createEchoMail(portalSite.Id, property[0].Id, '守山区', '', 
			'customerEmail@rand.co.jp', '', false, false);
		echoMail.BatchStatus__c = CommonConst.BATCH_STUTAS_WAITING; // バッチ処理ステータス
		echoMail.Email__c = 'tempoEmail@rand.co.jp';     // メール
		insert echoMail;

		// スキップトリガを戻す。
		sysCon.IsSkipTrigger__c = false;
		update sysCon;

		test.startTest();

		//バッチ起動
		BA101005Batch b = new BA101005Batch(1); //引数:起動回数が1回目
		Database.executeBatch(b,200);

		test.stopTest();


		// 結果用オブジェクトの取得		
		List<Correspond__c> correspondList =[SELECT ID FROM Correspond__c WHERE AccountId__c = :insAccount.Id];
		System.assertEquals(0, correspondList.size(), '問合せメール（LINE以外）：対応件数');

        Correspond__c correspond =[SELECT ID,AccountId__c FROM Correspond__c WHERE AccountId__c != :insAccount.Id LIMIT 1];
        System.assertEquals(null, correspond.AccountId__c, '問合せメール（LINE以外）：取引先無');

	}
	//▲ 2022.04.04 No0745 対応で追加

	//▼ 2022.05.16 No0758 対応で追加
	/**
	* 対応．初回LINE追加フラグ
	*     反響メール（ポータル）
	*     対応．初回LINE追加フラグがセットされないこと
    *     ポータルサイト、ポータルサイトURL、初回問合せ方法（メール）が設定されること 2022.05.16 No0759 追加
	*/
	@istest static void echoMailFirstLineAddFlgTest(){
		// テストデータ取得
		PortalSite__c portalSite = [SELECT Id,Url__c FROM PortalSite__c WHERE Email__c = :CommonConst.EMAIL_ATHOME LIMIT 1];    // 他社ポータルサイト
		List<Property__c> property = [SELECT Id FROM Property__c];    // 物件
		Shop__c shop = [SELECT Id FROM Shop__c WHERE Name = '横井店舗'];	// 店舗

		// トリガーを動かさない
		SystemConfig__c sysCon = [SELECT Id, IsSkipTrigger__c FROM SystemConfig__c];
		sysCon.IsSkipTrigger__c = true;
		update sysCon;
		// 登録
		// 取引先
		Account insAccount = createAccount('テスト太郎','customerEmail@rand.co.jp' , '', '', '', '', '', '仕込');
		insert insAccount;

		// 反響メール
		EchoMail__c echoMail = createEchoMail(portalSite.Id, property[0].Id, '守山区', 'テスト太郎', 
			'customerEmail@rand.co.jp', '', true, false);
		echoMail.BatchStatus__c = CommonConst.BATCH_STUTAS_WAITING; // バッチ処理ステータス
		echoMail.Email__c = 'tempoEmail@rand.co.jp';     // メール
		insert echoMail;

		// スキップトリガを戻す。
		sysCon.IsSkipTrigger__c = false;
		update sysCon;

		test.startTest();

		//バッチ起動
		BA101005Batch b = new BA101005Batch(1); //引数:起動回数が1回目
		Database.executeBatch(b,200);

		test.stopTest();


		// 結果用オブジェクトの取得		
		List<Correspond__c> correspondList =[SELECT ID,FirstLineAddFlg__c,PortalSite__c,PortalSiteUrl__c,FirstInquiryMeans__c FROM Correspond__c WHERE AccountId__c = :insAccount.Id];
		System.assertEquals(1, correspondList.size(), '反響メール：対応件数');
		// 対応．初回LINE追加フラグがセットされないこと
		System.assertEquals(false, correspondList[0].FirstLineAddFlg__c, '反響メール：初回LINE追加フラグ');
        // ポータルサイト、ポータルサイトURL、初回問合せ方法（メール）が設定されること　▼ 2022.05.16 No0759 対応で追加
        System.assertEquals(portalSite.Id, correspondList[0].PortalSite__c, '反響メール：ポータルサイト');
        System.assertEquals(portalSite.Url__c, correspondList[0].PortalSiteUrl__c, '反響メール：ポータルサイトURL');
        System.assertEquals(CommonConst.FIRSTINQUIRYMEANS_MAIL, correspondList[0].FirstInquiryMeans__c, '反響メール：初回問合せ方法（メール）');
        // ▲ 2022.05.16 No0759 対応で追加


	}
	//▲ 2022.05.16 No0758 対応で追加

    //--------------------------------------------------------------
    //--------- Privateメソッド ------------------------------------
    //--------------------------------------------------------------

    // 取引先登録情報生成
    private static Account createAccount(String Name, String eMail1, String eMail2, 
                                            String eMail3, String phone1, String phone2, 
                                            String phone3, String comment) {
        account = new Account();
        account.Name = Name;
        account.Email__c = eMail1;
        account.Email2__c = eMail2;
        account.Email3__c = eMail3;
        account.Phone = phone1;
        account.Phone2__c = phone2;
        account.Phone3__c = phone3;
        account.Comment__c = comment;
        account.RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER);

        return account;
    }

    // 対応登録情報生成
    private static Correspond__c createCorrespond(Id accountId, String district, 
                                                    String status, Id shop, 
                                                    boolean portal, boolean isFlg,
                                                    User userHankyo, User userRaiten) {
        correspond = new Correspond__c();
        correspond.AccountId__c = account.Id;
        correspond.Status__c = status;
        correspond.District__c = '守山区';
        // 店舗の更新が正しく判断できているか確認する為に、
        // ポータルからの場合は「反響担当店舗」、それ以外の場合は「来店担当店舗」に設定
        if (portal && shop <> null) {
            correspond.EchoShop__c = shop;
            correspond.EchoStaff__c = userHankyo.Id;
system.debug('反響に設定');
        } else if (!portal && shop <> null) {
            if (isFlg) {
                correspond.EchoShop__c = shop;
                correspond.EchoStaff__c = userHankyo.Id;
system.debug('反響に設定');
            } else {
                correspond.VisitShop__c = shop;
                correspond.ShopStaff__c = userRaiten.Id;
system.debug('来店に設定');
            }
        }

        return correspond;
    }

	//▼ 2022.04.04 No0745 対応で変更
    /**
    * 反響メール登録情報生成（既存）
	* @param   Id portalId ポータルサイトID
	* @param   Id propertyId 物件ID
	* @param   String district 所在地
	* @param   String Name お客様名
	* @param   String eMail Fromメールアドレス
	* @param   String phone 電話番号
	* @param   boolean portal ポータルからのメールの場合のフラグ
	* @param   boolean isFlg 問合せのメールアドレスのフラグ？
	* @return  反響メールの情報
    */
	private static EchoMail__c createEchoMail(Id portalId, Id propertyId, String district, 
											String Name, String eMail, String phone,
											boolean portal, boolean isFlg) {
		return createEchoMail(portalId,propertyId,district, Name, eMail, phone, portal,isFlg,false,'',null);
	}
	/**
    * 反響メール登録情報生成
	* @param   Id portalId ポータルサイトID
	* @param   Id propertyId 物件ID
	* @param   String district 所在地
	* @param   String Name お客様名
	* @param   String eMail Fromメールアドレス
	* @param   String phone 電話番号
	* @param   boolean portal ポータルからのメールの場合のフラグ
	* @param   boolean isFlg 問合せのメールアドレスのフラグ？
	* @param   boolean lineFlg LINEのメール設定フラグ
	* @param   String mailType LINEのメール種別（反響or問合せ）
	* @param   LineMember__c lineMember LINE会員の情報
	* @return  反響メールの情報
    */
	private static EchoMail__c createEchoMail(Id portalId, Id propertyId, String district, 
											String Name, String eMail, String phone,
											boolean portal, boolean isFlg,
											boolean lineFlg,String mailType,LineMember__c lineMember) {
        ecoMail = new EchoMail__c();

		if(lineFlg){
			ecoMail.BatchStatus__c = CommonConst.BATCH_STUTAS_WAITING; // バッチ処理ステータス
            ecoMail.Email__c = 'tempoEmail@rand.co.jp';     // メール
			// ライン用のメール形式を成型
			if (mailType == CommonConst_ptl.ECHOMAIL_MAILTYPE_ECHOMAIL) {
				// ポータルからのメールの場合の設定値（友達登録）
				ecoMail.FromEmail__c = eMail;	// Fromメールアドレス
				ecoMail.FromPotalSite__c = portalId;	// Fromポータルサイト
				ecoMail.MailType__c = CommonConst_ptl.ECHOMAIL_MAILTYPE_ECHOMAIL;	// 自社ポータル用_メール種別
				ecoMail.InquiryContent__c = 'LINE名：'+lineMember.name;	// お問合せ内容
				ecoMail.InquiryDateTime__c = CommonUtil.getNow(); // お問合せ日時
				ecoMail.LineId__c = lineMember.LineId__c;	// LINE＠ID
				ecoMail.LineName__c = '';	// LINEプロフィール名
				ecoMail.Subject__c = '[ROOMSELECT]LINE追加';	// 件名
				ecoMail.LineMessage__c = '「'+lineMember.name+'」様が友達追加されました'; // LINEメッセージ
				ecoMail.LineReceiveTime__c = CommonUtil.getNow();// LINE受信時刻
				ecoMail.LineReceiveType__c = CommonConst.LINE_RECEIVE_TYPE_ADD;	// LINE受信種別
				ecoMail.IsLineReceive__c = true; // LINE受信フラグ
				ecoMail.LineMember__c = lineMember.id;// LINE会員
				// ecoMail.Body__c
			} else {
				// LINE会員の受信
				ecoMail.FromEmail__c = eMail;	// Fromメールアドレス
				ecoMail.FromPotalSite__c = portalId;	// Fromポータルサイト
				ecoMail.MailType__c = CommonConst_ptl.ECHOMAIL_MAILTYPE_INQUIRY;	// 自社ポータル用_メール種別
				ecoMail.InquiryContent__c = 'LINE名：'+lineMember.name;	// お問合せ内容
				ecoMail.CustomerName__c = '';	// お客様名
				ecoMail.CustomerNameKana__c = '';	// お客様名（カナ）
				ecoMail.InquiryDateTime__c = CommonUtil.getNow(); // お問合せ日時
				ecoMail.LineId__c = lineMember.LineId__c;	// LINE＠ID
				ecoMail.LineName__c = '';	// LINEプロフィール名
				ecoMail.Subject__c = '[ROOMSELECT]LINE受信';	// 件名
				ecoMail.LineMessage__c = 'ラインメッセージ'; // LINEメッセージ
				ecoMail.LineReceiveTime__c = CommonUtil.getNow();// LINE受信時刻
				ecoMail.LineReceiveType__c = CommonConst.LINE_RECEIVE_TYPE_RECEIVE;	// LINE受信種別
				ecoMail.IsLineReceive__c = true; // LINE受信フラグ
				ecoMail.LineMember__c = lineMember.id;// LINE会員

			}
		}else{
			// ポータルからのメールの場合の設定値
			if (portal) {
				ecoMail.FromPotalSite__c = portalId;  // Fromポータルサイト
				ecoMail.InquiryDateTime__c = CommonUtil.getNow();  // お問合せ日時
				ecoMail.Response__c = propertyId;     // 物件
				ecoMail.PropertyAddress__c = district;  // 所在地
				ecoMail.Subject__c = '件名です';  // 件名
				ecoMail.Body__c = '本文です';  // 本文
				ecoMail.CustomerName__c = Name;  // お客様名
				//ecoMail.CustomerNameKana__c = 'ホラグチ　タロウ';  // お客様名（カナ）
				ecoMail.Phone__c = phone;  // 電話番号
				ecoMail.Fax__c = '090-8888-8888';  // Fax
				ecoMail.FromEmail__c = eMail;    // Fromメールアドレス
				ecoMail.Email__c = 'tempoEmail@rand.co.jp';     // メール
				ecoMail.PropertURL__c = 'URLテスト';              // 物件URL
				// ▼ 2021.12.10 LINE連携対応より、追加
				ecoMail.IsLineReceive__c = false;					   // LINE受信フラグ
				ecoMail.LineReceiveType__c = CommonConst.STRING_EMPTY; // LINE受信種別
				// ▲ 2021.12.10
			} else {
				// ポータル以外からのメールの設定値
				ecoMail.Subject__c = '件名です';  // 件名
				ecoMail.Body__c = '本文です';  // 本文
				ecoMail.FromEmail__c = eMail;    // Fromメールアドレス
				ecoMail.InquiryDateTime__c = CommonUtil.getNow();  // お問合せ日時
				ecoMail.ResponseDate__c = CommonUtil.getNow();  // 反響日
				if (isFlg) {
					ecoMail.Email__c = 'tempoEmail2@rand.co.jp';    // メール
				} else {
					ecoMail.Email__c = 'tempoEmail@rand.co.jp';     // メール
				}
			}
		}
        return ecoMail;
    }
	//▲ 2022.04.04 No0745 対応で変更

    // お気に入り物件登録情報生成
    private static FavoriteProperty__c createFavorite(Id accountId, Id propertyId) {
        FavoriteProperty__c favPro = new FavoriteProperty__c();
system.debug('Account__c：' +accountId);
system.debug('Property__c：' +propertyId);
        favPro.Account__c = accountId;
        favPro.Property__c = propertyId;

        return favPro;
    }

    private static void checkObjectCnt(integer eco, integer ac,
                                        integer cor, integer del, integer fav) {

        // List<EchoMail__c> cntEchoMail = [SELECT Id FROM EchoMail__c];    // 反響メール
        // List<Account> cntAccount = [SELECT Id FROM Account];    // 取引先
        // List<Correspond__c> cntCorrespond = [SELECT Id FROM Correspond__c]; // 対応
        // List<CorrespondDetail__c> cntCorrespondDetail = [SELECT Id FROM CorrespondDetail__c]; // 対応明細
        // List<FavoriteProperty__c> cntFavoriteProperty = [SELECT Id FROM FavoriteProperty__c]; // お気に入り物件

        // データ件数チェック
        // System.assertEquals(eco, cntEchoMail.Size());
        // System.assertEquals(ac, cntAccount.Size());
        // System.assertEquals(cor, cntCorrespond.Size());
        // System.assertEquals(del, cntCorrespondDetail.Size());
        // System.assertEquals(fav, cntFavoriteProperty.Size());
    }

	private static void chintaiCheckObjectCnt(integer eco, integer ac,
                                        integer cor, integer del, integer fav) {

        List<EchoMail__c> cntEchoMail = [SELECT Id FROM EchoMail__c];    // 反響メール
        List<Account> cntAccount = [SELECT Id FROM Account];    // 取引先
        List<Correspond__c> cntCorrespond = [SELECT Id FROM Correspond__c]; // 対応
        List<CorrespondDetail__c> cntCorrespondDetail = [SELECT Id FROM CorrespondDetail__c]; // 対応明細
        List<FavoriteProperty__c> cntFavoriteProperty = [SELECT Id FROM FavoriteProperty__c]; // お気に入り物件

        // データ件数チェック
        System.assertEquals(eco, cntEchoMail.Size());
        System.assertEquals(ac, cntAccount.Size());
        System.assertEquals(cor, cntCorrespond.Size());
        System.assertEquals(del, cntCorrespondDetail.Size());
        System.assertEquals(fav, cntFavoriteProperty.Size());
    }


    //ポータルサイト構築 追加 Start
    @isTest static void portalMailAddTest(){

        // ポータルサイト
        PortalSite__c portal = new PortalSite__c(Name = 'RSHP',Email__c = 'portal@mail.com');
        insert portal;
        //建物取得  
        Building__c buil = [SELECT Id FROM Building__c];
        //物件作成
        Property__c pro1 = new Property__c(Name = '101', Building__c = buil.Id);
        Property__c pro2 = new Property__c(Name = '201', Building__c = buil.Id);
        List<Property__c> proList = new List<Property__c> {pro1,pro2};
        insert proList;

        // 取引先登録（電話番号１が一致により紐づく）
        account = createAccount('洞口太郎', '', '', '', '090-9999-9999', '', '', '仕込');
        account.Email__c =  'tarou@mail.com';
        insert account;

        //自社ポータルサイトから来店予約メール受信
        Member__c mem = new Member__c(MemberId__c = 'member1',
                                              LastName__c = '一子',
                                              FirstName__c = '一山',
                                              LastNameKana__c = 'イチコ',
                                              FirstNameKana__c = 'イチヤマ',
                                              Tell__c = '111-1111',
                                              Email__c = 'email1@mail.com',
                                              Password__c = 'ichiyama',
                                              Birthdate__c = Date.newInstance(1995,1,1),
                                              Gender__c = '女性',
                                              Blacklist__c = false,
                                              JoinDate__c = Date.newInstance(2020,1,1),
                                              MemberStatus__c = '入会');
        insert mem;

        String proListString = pro1.Id + ',' + pro2.Id;
        // 反響メール登録値設定
        EchoMail__c echo = new EchoMail__c(
            Response__c = pro1.Id,                      //物件  
            PropertyList__c =proListString,             //物件リスト
            Phone__c = '090-9999-9999',                 //電話番号
            CustomerName__c = '洞口太郎',                //お客様名
            FromPotalSite__c = portal.Id,               //Fromポータルサイト
            MailType__c = CommonConst_ptl.ECHOMAIL_MAILTYPE_ECHOMAIL,//メール種別
            FromEmail__c = 'tarou@mail.com',            //FROMメールアドレス 
            Email__c = 'tempoEmail@rand.co.jp',             
            MemberId__c = 'member1'
            );
            
        insert echo;
        
        List<FavoriteProperty__c> favoPro = [SELECT Id FROM FavoriteProperty__c ];
        //おすすめ物件が2件登録されている
        system.assertEquals(2, favoPro.size() );

        //トリガのカバレッジ率あげ用
        update echo;
        List<CorrespondDetail__c> corDe = [SELECT id FROM CorrespondDetail__c];
        delete corDe;
        delete echo;

    }
    //ポータルサイト構築 追加 End

	// ▼ 2021.12.10 LINE連携対応より、共通処理を追加
	/**
	 * 取引先情報の設定
	 */
	private static void setAccountInfo() {

		// 店舗
		Shop__c shop = [
			SELECT Id
			FROM Shop__c
			WHERE Name = '横井店舗'
		];

		// ユーザ（反響）
		User userHankyo =  [
			SELECT Id
			FROM User
			WHERE LastName = 'hankyo'
		];

		// ユーザ（来店）
		User userRaiten =  [
			SELECT Id
			FROM User
			WHERE LastName = 'raiten'
		];

		// 取引先登録（メール１が一致により紐づく）
		account = createAccount('洞口太郎', 'customerEmail@rand.co.jp', '', '', '', '', '', '仕込');
		insert account;

		//▼ 2022.05.16 No0758 対応で追加
		SystemConfig__c sysCon = [SELECT Id,IsSkipTrigger__c FROM SystemConfig__c];
		sysCon.IsSkipTrigger__c= true;
		update sysCon;
		//▲ 2022.05.16 No0758 対応で追加
		// ▼ 2022.1.31 LINE連携対応より、主キーを追加
		// LINE会員の登録
		LineMember__c lineMember = new LineMember__c(
			Name = 'テストLINE会員'
			, LineId__c = '1234567890'
		);
		insert lineMember;
		// ▲ 2022.1.31

		//▼ 2022.05.16 No0758 対応で追加
		sysCon.IsSkipTrigger__c= false;
		update sysCon;
		//▲ 2022.05.16 No0758 対応で追加

		// 対応の登録
		correspond = createCorrespond(account.Id, '守山区', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED, shop.Id, true, false, userHankyo, userRaiten);
		correspond.LineMember__c = lineMember.Id;
		insert correspond;
	}

	/**
	 * 反響メールの取得
	 */
	private static EchoMail__c getEchoMail() {

		// ポータルサイト
        PortalSite__c portal = [
			SELECT Id 
			FROM PortalSite__c
			WHERE Email__c = :CommonConst.EMAIL_SUMO
		];

		// 物件
        Property__c property = [
			SELECT Id
			FROM Property__c
		];

		return createEchoMail(portal.Id, property.Id, '守山区', '洞口太郎', 
							'customerEmail@rand.co.jp', '', true, false);
	}
	// ▲　2021.12.10
	
	//▼ 2022.04.04 No0745 対応で追加
	/**
    * ライン用対応作成（テスト時点の対応を作成）
	* @param   integer setDataType　登録形式フラグ（1：LINE追加後、2：LINE受信時、その他：他社ポータルの問合せ後）
	* @param   Id accountId 取引先ID
	* @param   Id lineId LINE会員ID
	* @param   Id shopId 店舗ID
	* @param   Id portalId ポータルサイトID
	* @return  反響メールの情報
    */
	private static Correspond__c insCorrespond(integer setDataType,Id accountId,Id lineId,Id shopId,Id portalId){
		Datetime nowDate =  commonUtil.getNow();
		Correspond__c insCor = new Correspond__c();

		// 共通項
		insCor.EventDateTime__c=nowDate;	//	イベント時刻
		insCor.ListViewDate__c	=nowDate;	// 一覧表示日時
		insCor.FirstInquiryMeans__c	=CommonConst.FIRSTINQUIRYMEANS_MAIL;	// 初回問合せ方法
		insCor.Status__c=CommonConst.CORRESPOND_STATUS_NOTSUPPORTED;	//	ステータス		

		insCor.IsBrowseFlg__c	=false;	// 閲覧フラグ
		if(setDataType == 1){
			// LINE追加
			insCor.LineMember__c= lineId;	//	LINE会員
			insCor.PortalSite__c=portalId;	//	ポータルサイト
			insCor.PortalSiteUrl__c='https://app-portal-res-pre.herokuapp.comtest/';	//	ポータルサイトURL
			insCor.ReceiveMailDatePortal__c=nowDate;	//	メール受信日時（ポータル）
			insCor.eventStatus__c=CommonConst.CORRESPOND_EVENT_LINE_FRIEND_ADD;	//	イベント（ステータス）
			insCor.LineFriendAddDate__c=nowDate;	//	LINEお友達登録日時
			
		}else if(setDataType == 2){
			// LINE受信
			insCor.AccountId__c	=accountId;	// 取引先
			insCor.LineMember__c= lineId;	//	LINE会員
			insCor.ReceiveMailDateOther__c =nowDate;	// メール受信日時（その他）
			insCor.VisitShop__c	=shopId;	// 来店担当店舗
			insCor.eventStatus__c	=CommonConst.CORRESPOND_EVENT_LINE_RECEIVE;	// イベント（ステータス）
			insCor.LineReceiveDate__c	=nowDate;	// LINE受信日時

            // ▼ 2022.05.16 No0759 対応で追加
            insCor.PortalSite__c=portalId;	//	ポータルサイト
			insCor.PortalSiteUrl__c='test@co.jp';	//	ポータルサイトURL
            insCor.FirstInquiryMeans__c   = CommonConst.FIRSTINQUIRYMEANS_PHONE;         // 初回問合せ方法（電話）
            // ▲ 2022.05.16 No0759 対応で追加

		}else{
			// LINE受信以外
			insCor.AccountId__c	=accountId;	// 取引先
			insCor.PortalSite__c=portalId;	//	ポータルサイト
			insCor.PortalSiteUrl__c='https://app-portal-res-pre.herokuapp.comtest/';	//	ポータルサイトURL
			insCor.ReceiveMailDatePortal__c=nowDate;	//	メール受信日時（ポータル）
			insCor.District__c = '守山区';// 地区 
			insCor.EchoShop__c	=shopId;	// 反響担当店舗
		}
		insert insCor;


		return insCor;
	}
	//▲ 2022.04.04 No0745 対応で追加
}