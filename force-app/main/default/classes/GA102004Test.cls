/**
 * メール送信画面テスト
 */
@isTest
public class GA102004Test {

    public static final String USER_NAME = 'GA103001@horaguchi.com'; 

    //テストに使用するレコードを作成
    @testSetup static void Setting(){

        //店舗レコード
        Shop__c testShop = new shop__c(
            Name                = 'テスト店舗'
            ,PortalSitePostingDistrict__c = '港区'
            ,Email__c           = 'qqq@www.com'
            ,PostalCode__c      = '1234567'
            ,City__c            = 'テスト住所１'
            ,Street__c          = 'テスト住所２'
            ,Phone__c           = '01234567890'
            ,Fax__c             = '12345678901'
            ,BusinessHours__c   = 'テスト営業時間'
            ,RegularHoliday__c  = 'テスト定休日'
            ,Homepage__c        = 'テストHOMEPAGE'
        );
        insert testShop;
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
            Shop__c = testShop.Id
        );
        insert orgRecord2;
        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('システム管理者')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User testUser = new User(
            UserName = USER_NAME,
            Email = 'test@example.com',
            LastName = 'testGA102004',
            Alias = 'test',
            TimeZoneSidKey = 'Asia/Tokyo',
            LocaleSidKey = 'ja_JP',
            EmailEncodingKey = 'ISO-2022-JP',
            LanguageLocaleKey = 'ja',
            ProfileId = profiles.get(0).Id
        );
        System.runAs(thisUser) {
            insert testUser;
        }
        //店舗異動レコード
        // User testUser =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        ShopTransfer__c testShopTransfer = new ShopTransfer__c(
            OrgzanizationHierarchy__c = orgRecord2.id,
            Staff__c = testUser.id,
            StartDate__c = Date.newInstance(2000, 12, 1),
            EndDate__c = Date.newInstance(2999, 12, 1)
        );
        insert testShopTransfer;

        // カスタム設定
        SystemConfig__c testSystemConfig = new SystemConfig__c();
        testSystemConfig.RedirectURL__c = 'redirectUrlxxxxx';
        testSystemConfig.HerokuSecretAccessKey__c = 'SUqM4AmMbn8GNiVzfhTwHXZAM4uWGVrN';
        testSystemConfig.UseAuthority_Portal__c = true;   // ポータルサイト構築 追加 権限
        insert testSystemConfig;

        // 取引先
        Account testAccount = new Account(
            Name = 'テスト取引先GA102004'
            ,RecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER)
            ,Email__c = 'aaa@bbb.com'
            ,Email2__c = 'ccc@ddd.com'
            ,Email3__c = 'error'    // 不正なメールアドレスも設定しておく
        );
        insert testAccount;

        // 対応
        Correspond__c testCorrespond1 = new Correspond__c(
            AccountId__c = testAccount.Id
            ,Status__c = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED
            ,EchoStaff__c = testUser.Id
            ,ShopStaff__c = null
        );
        Correspond__c testCorrespond2 = new Correspond__c(
            AccountId__c = testAccount.Id
            ,Status__c = CommonConst.CORRESPOND_STATUS_APOCANCEL
            ,EchoStaff__c = null
            ,ShopStaff__c = testUser.Id
        );
        Correspond__c testCorrespond3 = new Correspond__c(
            AccountId__c = testAccount.Id
            ,Status__c = CommonConst.CORRESPOND_STATUS_CONSIDERVISITING
            ,EchoStaff__c = null
            ,ShopStaff__c = null
        );
        Correspond__c testCorrespond4 = new Correspond__c(
            AccountId__c = testAccount.Id
            ,Status__c = CommonConst.CORRESPOND_STATUS_APPLCANCEL
            ,EchoStaff__c = null
            ,ShopStaff__c = null
        );
        Correspond__c testCorrespond5 = new Correspond__c(
            AccountId__c = testAccount.Id
            ,Status__c = CommonConst.CORRESPOND_STATUS_PURSUITHOLD
            ,EchoStaff__c = null
            ,ShopStaff__c = null
        );
        List<Correspond__c> testCorrespond = new List<Correspond__c> {
            testCorrespond1
            ,testCorrespond2
            ,testCorrespond3
            ,testCorrespond4
            ,testCorrespond5
        };
        insert testCorrespond;

        // ポータルサイト
        PortalSite__c testPortalSite0 = new PortalSite__c(
            Name = 'テストポータルサイト'
        );
        PortalSite__c testPortalSite1 = new PortalSite__c(
            Name = 'テストポータルサイトSuumo'
            ,Email__c = CommonConst.EMAIL_SUMO
        );
        PortalSite__c testPortalSite2 = new PortalSite__c(
            Name = 'テストポータルサイトhomes'
            ,Email__c = CommonConst.EMAIL_HOMES
        );
        PortalSite__c testPortalSite3 = new PortalSite__c(
            Name = 'テストポータルサイトathome'
            ,Email__c = CommonConst.EMAIL_ATHOME
        );
        List<PortalSite__c> testPortalSite = new List<PortalSite__c> {
            testPortalSite0
            ,testPortalSite1
            ,testPortalSite2
            ,testPortalSite3
        };
        insert testPortalSite;

        // 反響メール
        EchoMail__c testEchoMail1 = new EchoMail__c(
            FromPotalSite__c    = testPortalSite1.Id
            ,CustomerName__c    = 'テスト取引先GA102004'
            ,FromEmail__c       = 'aaa@bbb.com'
            ,PropertyAddress__c = 'テスト所在地'
            ,ClosestStation__c  = 'テスト最寄駅'
            ,WalkTime__c        = 'テスト徒歩'
            ,RoomLayout__c      = 'テスト間取り'
            ,RentFee__c         = 'テスト賃料'
            ,PropertURL__c      = 'テスト物件URL'
            ,Subject__c         = 'テスト反響メール件名１'
            ,Body__c            = 'テスト反響メール本文１'
            ,MessageId__c       = 'testMessageId1'
            ,References__c      = 'testReferences1'
        );
        EchoMail__c testEchoMail2 = new EchoMail__c(
            FromPotalSite__c    = null
            ,CustomerName__c    = 'テスト取引先GA102004'
            ,FromEmail__c       = 'aaa@bbb.com'
            ,PropertyAddress__c = 'テスト所在地'
            ,ClosestStation__c  = 'テスト最寄駅'
            ,WalkTime__c        = 'テスト徒歩'
            ,RoomLayout__c      = 'テスト間取り'
            ,RentFee__c         = 'テスト賃料'
            ,PropertURL__c      = 'テスト物件URL'
            ,Subject__c         = 'テスト反響メール件名２'
            ,Body__c            = 'テスト反響メール本文２'
            ,MessageId__c       = 'testMessageId2'
            ,References__c      = 'testReferences2'
        );
        List<EchoMail__c> testEchoMail = new List<EchoMail__c> {
            testEchoMail1
            ,testEchoMail2
        };
        insert testEchoMail;

        // 対応明細
        CorrespondDetail__c testCorrespondDetail1 = new CorrespondDetail__c(
            Corresponds__c = testCorrespond1.Id
            ,Shop__c = testShop.Id
            ,SupportedTitle__c = 'テスト対応明細１'
            ,EchoMail__c = testEchoMail1.Id
        );
        CorrespondDetail__c testCorrespondDetail2 = new CorrespondDetail__c(
            Corresponds__c = testCorrespond2.Id
            ,Shop__c = testShop.Id
            ,SupportedTitle__c = 'テスト対応明細２'
            ,EchoMail__c = testEchoMail2.Id
        );
        List<CorrespondDetail__c> testCorrespondDetail = new List<CorrespondDetail__c> {
            testCorrespondDetail1
            ,testCorrespondDetail2
        };
        insert testCorrespondDetail;

        // 定型文
        String repTestStr = 'お客様名：{お客様名}';
        repTestStr += '担当者名：{担当者名}';
        repTestStr += '店舗名：{店舗名}';
        repTestStr += '郵便番号：{郵便番号}';
        repTestStr += '店舗住所１：{店舗住所１}';
        repTestStr += '店舗住所２：{店舗住所２}';
        repTestStr += '電話番号：{電話番号}';
        repTestStr += 'FAX：{FAX}';
        repTestStr += '営業時間：{営業時間}';
        repTestStr += '定休日：{定休日}';
        repTestStr += '店舗HP：{店舗HP}';
        repTestStr += '反響メール物件URL：{反響メール物件URL}';
        repTestStr += 'あいさつ：{あいさつ}';
        FixedPhrase__c testFixedPhrase1 = new FixedPhrase__c(
            Name        = 'テスト定型文１'
            ,Folder__c  = 'テストフォルダ１'
            ,Subject__c = 'テスト件名１'
            ,Text__c    = 'テスト本文１' + repTestStr
        );
        FixedPhrase__c testFixedPhrase2 = new FixedPhrase__c(
            Name        = 'テスト定型文２'
            ,Folder__c  = 'テストフォルダ１'
            ,Subject__c = 'テスト件名２' + repTestStr
            ,Text__c    = 'テスト本文２'
        );
        FixedPhrase__c testFixedPhrase3 = new FixedPhrase__c(
            Name        = 'テスト定型文３'
            ,Folder__c  = 'テストフォルダ２'
            ,Subject__c = 'テスト件名３' + repTestStr
            ,Text__c    = 'テスト本文３' + repTestStr
        );
        List<FixedPhrase__c> testFixedPhrase = new List<FixedPhrase__c> {
            testFixedPhrase1
            ,testFixedPhrase2
            ,testFixedPhrase3
        };
        insert testFixedPhrase;

        //文例
        String usageScreen = CommonConst.EXAMPLESENTENCE_USAGESCREEN_SENDMAIL; //使用画面
        ExampleSentence__c testExampleSentence1 = new ExampleSentence__c(
            Name = 'テスト文例１'
            ,Folder__c = 'テスト文例フォルダ１'
            ,ExampleSentence__c = 'テスト文例内容１\nテスト文例内容２行目'
            ,UsageScreen__c = usageScreen
        );
        for (Integer i; i < 26; i++) {
            testExampleSentence1.ExampleSentence__c += '1234567890';
        }
        ExampleSentence__c testExampleSentence2 = new ExampleSentence__c(
            Name = 'テスト文例２'
            ,Folder__c = 'テスト文例フォルダ１'
            ,ExampleSentence__c = 'テスト文例内容２\nテスト文例内容２行目'
            ,UsageScreen__c = usageScreen
        );
        ExampleSentence__c testExampleSentence3 = new ExampleSentence__c(
            Name = 'テスト文例３'
            ,Folder__c = 'テスト文例フォルダ２'
            ,ExampleSentence__c = 'テスト文例内容３\nテスト文例内容２行目'
            ,UsageScreen__c = usageScreen
        );
        List<ExampleSentence__c> testExampleSentence = new List<ExampleSentence__c> {
            testExampleSentence1
            ,testExampleSentence2
            ,testExampleSentence3
        };
        insert testExampleSentence;

        // メール下書き
        MailDraft__c testMailDraft = new MailDraft__c(
            Name                    = 'テスト下書き１'
            ,From__c                = testShop.Email__c
            ,To__c                  = testAccount.Email__c + ';' + testAccount.Email2__c
            ,Cc__c                  = testAccount.Email2__c
            ,Subject__c             = 'テスト件名'  // 件名
            ,Body__c                = 'テスト本文'  // メール内容
            ,Shop__c                = testShop.Id
            ,Account__c             = testAccount.Id
            ,SendingDateTime__c     = DateTime.newInstance(2020,4,11,13,30,12)
            ,Correspond__c          = testCorrespondDetail2.Corresponds__c
            ,CorrespondDetail__c    = testCorrespondDetail2.Id
            ,IsReply__c             = true
        );
        insert testMailDraft;

        // メール時間指定送信
        MailTimeSpecificationSending__c testMailTimeSpecificationSending = new MailTimeSpecificationSending__c(
            Name                    = 'テスト時間指定送信１'
            ,From__c                = testShop.Email__c
            ,To__c                  = testAccount.Email__c + ';' + testAccount.Email2__c
            ,Cc__c                  = testAccount.Email2__c
            ,Subject__c             = 'テスト件名'  // 件名
            ,Body__c                = 'テスト本文'  // メール内容
            ,Shop__c                = testShop.Id
            ,Account__c             = testAccount.Id
            ,SendingDateTime__c     = DateTime.newInstance(2020,4,11,13,30,12)
            ,Correspond__c          = testCorrespondDetail2.Corresponds__c
            ,CorrespondDetail__c    = testCorrespondDetail2.Id
            ,IsReply__c             = true
        );
        insert testMailTimeSpecificationSending;

        // 添付ファイル
        Attachment testAttachment1 = new Attachment(
            ParentId = testMailDraft.Id
            ,Name = 'テスト添付ファイル１'
            ,Body = Blob.valueOf('0000000000000000')
        );
        Attachment testAttachment2 = new Attachment(
            ParentId = testMailTimeSpecificationSending.Id
            ,Name = 'テスト添付ファイル２'
            ,Body = Blob.valueOf('0000000000000000')
        );
        List<Attachment> testAttachment = new List<Attachment> {
            testAttachment1
            ,testAttachment2
        };
        insert testAttachment;

        // ポータルサイト構築 追加 Start
        // 建物テストデータ作成
        Building__c building = new Building__c(
            Name = 'テスト建物',
            District__c ='北区',
            State__c = '愛知県',
            City__c = '名古屋市退去予定町',
            Street__c = '1-1');    
        insert building;
        
        // 物件テストデータ作成
        Property__c property = new Property__c(
                    Name = 'テスト物件',
                    Building__c = building.Id,
                    LiveStatus__c = '退去予定',
                    DeliveryType__c = '期日指定',
                    DeliveryYear__c = '2020',
                    DeliveryMonth__c = '1月',
                    DeliveryDay__c = '1');
        insert property;
        // お気に入り物件
        // お気に入り物件登録
        FavoriteProperty__c favPro = new FavoriteProperty__c(Account__c = testAccount.Id,
                                                             Property__c = property.Id);
        insert favPro;
        // ポータルサイト構築 追加 End
    }

    // 初期表示テスト(新規)
    @isTest static void newInitializeTest(){
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();
            System.assertNotEquals(true, testController.isOpenError);
        }
    }

    // 初期表示テスト(下書き)
    @isTest static void mailDraftInitializeTest(){
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailDraft__c testMailDraft = [
                SELECT Id, Name
                FROM MailDraft__c
                WHERE Name = 'テスト下書き１'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailDraftId', testMailDraft.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();
            System.assertNotEquals(true, testController.isOpenError);
        }
    }

    // 初期表示テスト(時間指定送信)
    @isTest static void mailTimeSpecificationSendingInitializeTest(){
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailTimeSpecificationSending__c testMailTimeSpecificationSending = [
                SELECT Id, Name
                FROM MailTimeSpecificationSending__c
                WHERE Name = 'テスト時間指定送信１'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailTimeSpecificationSendingId', testMailTimeSpecificationSending.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();
            System.assertNotEquals(true, testController.isOpenError);
        }
    }

    // 初期表示テスト(反響返信)
    @isTest static void replyInitializeTest(){
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailTimeSpecificationSending__c testMailTimeSpecificationSending = [
                SELECT Id, Name
                FROM MailTimeSpecificationSending__c
                WHERE Name = 'テスト時間指定送信１'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailTimeSpecificationSendingId', testMailTimeSpecificationSending.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();
            System.assertNotEquals(true, testController.isOpenError);
        }
    }

    // 初期表示テスト(宛先指定選択)
    @isTest static void selectSubjectInitializeTest(){
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('email', testAccount.Email2__c);
            pageRef.getParameters().put('isReply', 'true');
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();
            System.assertNotEquals(true, testController.isOpenError);
        }
    }

    // 初期表示テスト(パラメータエラー)
    @isTest static void paramErrorInitializeTest(){
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('isReply', 'False');
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();
            System.assertEquals(true, testController.isOpenError);
        }
    }


    // 発行ボタン押下処理テスト
    @isTest static void clickIssueTest() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();
            testController.screenMailInfo.propertyURL = 'testURLxxxxx';
            testController.screenMailInfo.propertyDetail = '物件の詳細';
            testController.clickIssue();
            System.assertNotEquals(true, testController.hasErrorMessage);

            testController.screenMailInfo.propertyURL = '';
            testController.clickIssue();
            System.assertEquals(true, testController.hasErrorMessage);

        }
    }

    // 発行ボタン押下処理テスト
    @isTest static void clickFixedPhraseTest() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();
            //testController.selectFixedPhraseFolderIndex = 0;
            testController.selectFixedPhraseIndex = 0;
            testController.clickFixedPhrase();
            //System.assertNotEquals(true, testController.hasErrorMessage);

            //testController.selectFixedPhraseFolderIndex = -1;
            testController.clickFixedPhrase();
            //System.assertEquals(true, testController.hasErrorMessage);

        }
    }

    // 削除ボタン押下処理テスト(下書き)
    @isTest static void clickDeleteMailDraftTest() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailDraft__c testMailDraft = [
                SELECT Id, Name
                FROM MailDraft__c
                WHERE Name = 'テスト下書き１'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailDraftId', testMailDraft.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();
            testController.clickDelete();
            System.assertNotEquals(true, testController.hasErrorMessage);

            testController.attachmentList = null;
            testController.clickDelete();
            System.assertEquals(true, testController.hasErrorMessage);

        }
    }

    // 削除ボタン押下処理テスト(時間指定送信)
    @isTest static void clickDeleteMailTimeSpecificationSendingTest() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailTimeSpecificationSending__c testMailTimeSpecificationSending = [
                SELECT Id, Name
                FROM MailTimeSpecificationSending__c
                WHERE Name = 'テスト時間指定送信１'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailTimeSpecificationSendingId', testMailTimeSpecificationSending.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();
            testController.clickDelete();
            System.assertNotEquals(true, testController.hasErrorMessage);

            // testController.attachmentList = null;
            // testController.clickDelete();
            // System.assertEquals(true, testController.hasErrorMessage);

        }
    }

    // 添付削除ボタン押下処理テスト
    @isTest static void clickAttachmentDeleteTest() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailDraft__c testMailDraft = [
                SELECT Id, Name
                FROM MailDraft__c
                WHERE Name = 'テスト下書き１'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailDraftId', testMailDraft.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();
            testController.deleteAttachmentIndex = 0;
            testController.clickAttachmentDelete();
            System.assertNotEquals(true, testController.hasErrorMessage);

            testController.deleteAttachmentIndex = -1;
            testController.clickAttachmentDelete();
            System.assertEquals(true, testController.hasErrorMessage);

        }
    }

    // 確認ボタン押下処理テスト
    @isTest static void clickConfirmTest() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailDraft__c testMailDraft = [
                SELECT Id, Name
                FROM MailDraft__c
                WHERE Name = 'テスト下書き１'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailDraftId', testMailDraft.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();
            testController.screenMailInfo.sendTo[0].isCheck = true;
            testController.screenMailInfo.sendTo[1].isCheck = true;
            testController.clickConfirm();
            //System.assertNotEquals(true, testController.hasErrorMessage);

            testController.screenMailInfo.sendTo[0].isCheck = false;
            testController.screenMailInfo.sendTo[1].isCheck = false;
            testController.screenMailInfo.subject = '';
            testController.screenMailInfo.body = '';
            testController.clickConfirm();
            //System.assertEquals(true, testController.hasErrorMessage);

        }
    }

    // 下書き保存ボタン押下処理テスト
    @isTest static void clickDraftSaveTest() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailTimeSpecificationSending__c testMailTimeSpecificationSending = [
                SELECT Id, Name
                FROM MailTimeSpecificationSending__c
                WHERE Name = 'テスト時間指定送信１'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailTimeSpecificationSendingId', testMailTimeSpecificationSending.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成

            //添付ファイル追加
            GA102004Controller testController = new GA102004Controller();
            MailDraft__c tempMailDraft = new MailDraft__c(
                Name    = 'Temporary of Attachment'
            );
            insert tempMailDraft;
            Attachment tempAttachment = new Attachment(
                ParentId = tempMailDraft.Id
                ,Name = 'テスト追加添付ファイル'
                ,Body = Blob.valueOf('0000000000000000')
            );
            insert tempAttachment;
            testController.tempAttachmentParentId = tempMailDraft.Id;

            testController.clickDraftSave();
            System.assertNotEquals(true, testController.hasErrorMessage);

            testController.screenMailInfo.subject = '';
            testController.clickDraftSave();
            System.assertEquals(true, testController.hasErrorMessage);

        }
    }

    // 確認ボタン⇒モーダル時間指定送信保存 処理テスト(下書き⇒モーダル表示＋時間指定送信)
    @isTest static void clickConfirmAndSaveMailTimeSpecificationSendingTest() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailDraft__c testMailDraft = [
                SELECT Id, Name
                FROM MailDraft__c
                WHERE Name = 'テスト下書き１'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailDraftId', testMailDraft.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();

            //添付ファイル追加
            MailDraft__c tempMailDraft = new MailDraft__c(
                Name    = 'Temporary of Attachment'
            );
            insert tempMailDraft;
            Attachment tempAttachment = new Attachment(
                ParentId = tempMailDraft.Id
                ,Name = 'テスト追加添付ファイル'
                ,Body = Blob.valueOf('0000000000000000')
            );
            insert tempAttachment;
            testController.tempAttachmentParentId = tempMailDraft.Id;

            //確認押下処理
            testController.screenMailInfo.sendTo[0].isCheck = true;
            testController.screenMailInfo.sendTo[1].isCheck = true;
            testController.clickConfirm();
            //System.assertNotEquals(true, testController.hasErrorMessage);

            //モーダル起動準備
            GA102004Modal1Controller testModalController = new GA102004Modal1Controller();
            testModalController.parameter = testController.GA102004Modal1Parameter;
            testModalController.tempAttachmentParentId = tempMailDraft.Id;

            //モーダル初期表示処理
            testModalController.initAction();

            //送信（時間指定送信登録）
            testModalController.clickSend();

            //System.assertNotEquals(true, testModalController.hasErrorMessage);

        }
    }

    // 確認ボタン⇒モーダルメール送信 処理テスト(下書き⇒モーダル表示＋メール送信)
    @isTest static void clickConfirmAndSendMailTest2() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account acc = [SELECT Id
                         FROM Account
                         WHERE Name = 'テスト取引先GA102004'];

            Correspond__c obj = [SELECT Id
                                FROM Correspond__c   
                                WHERE AccountId__c = :acc.Id limit 1		               
            ];

            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', acc.Id);
            pageRef.getParameters().put('corrspondId', obj.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();

            //送信予定日時クリア
            testController.screenMailInfo.sendingDate = null;
            testController.screenMailInfo.sendingTime = '';

            //確認押下処理
            testController.screenMailInfo.sendTo[0].isCheck = true;
            testController.screenMailInfo.sendTo[1].isCheck = true;
            testController.clickConfirm();
            
            //モーダル起動準備
            GA102004Modal1Controller testModalController = new GA102004Modal1Controller();
            system.debug(testController.GA102004Modal1Parameter.compareToTime);
            testModalController.parameter = testController.GA102004Modal1Parameter;
            testModalController.parameter.isReply = false;

            //モーダル初期表示処理
            testModalController.initAction();

            //メール送信
            testModalController.clickSend();
        }
    }


    // 確認ボタン⇒モーダルメール送信 処理テスト(通常送信⇒モーダル表示＋メール送信⇒楽観ロックのエラー)
    @isTest static void clickConfirmAndSendMailTest() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailDraft__c testMailDraft = [
                SELECT Id, Name
                FROM MailDraft__c
                WHERE Name = 'テスト下書き１'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailDraftId', testMailDraft.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();

            //添付ファイル追加
            MailDraft__c tempMailDraft = new MailDraft__c(
                Name    = 'Temporary of Attachment'
            );
            insert tempMailDraft;
            Attachment tempAttachment = new Attachment(
                ParentId = tempMailDraft.Id
                ,Name = 'テスト追加添付ファイル'
                ,Body = Blob.valueOf('0000000000000000')
            );
            insert tempAttachment;
            testController.tempAttachmentParentId = tempMailDraft.Id;

            //送信予定日時クリア
            testController.screenMailInfo.sendingDate = null;
            testController.screenMailInfo.sendingTime = '';

            //確認押下処理
            testController.screenMailInfo.sendTo[0].isCheck = true;
            testController.screenMailInfo.sendTo[1].isCheck = true;
            testController.clickConfirm();
            System.assertNotEquals(true, testController.hasErrorMessage);

            //モーダル起動準備
            GA102004Modal1Controller testModalController = new GA102004Modal1Controller();
            testModalController.parameter = testController.GA102004Modal1Parameter;
            testModalController.tempAttachmentParentId = tempMailDraft.Id;
            testModalController.parameter.isReply = false;

            //モーダル初期表示処理
            testModalController.initAction();

            //メール送信
            testModalController.clickSend();

            System.assertNotEquals(true, testModalController.hasErrorMessage);

        }
    }

    // 確認ボタン⇒モーダルメール送信 処理テスト(時間指定送信⇒モーダル表示＋メール送信⇒エラー)
    @isTest static void clickConfirmAndSendMailErrorsTest() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailTimeSpecificationSending__c testMailTimeSpecificationSending = [
                SELECT Id, Name
                FROM MailTimeSpecificationSending__c
                WHERE Name = 'テスト時間指定送信１'
            ];
            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailTimeSpecificationSendingId', testMailTimeSpecificationSending.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();

            //送信予定日時クリア
            testController.screenMailInfo.sendingDate = null;
            testController.screenMailInfo.sendingTime = '';

            //確認押下処理
            testController.screenMailInfo.sendTo[2].isCheck = true; // 不正なアドレスを選択
            testController.clickConfirm();
            System.assertNotEquals(true, testController.hasErrorMessage);

            //モーダル起動準備
            GA102004Modal1Controller testModalController = new GA102004Modal1Controller();
            testModalController.parameter = testController.GA102004Modal1Parameter;

            //モーダル初期表示処理
            testModalController.initAction();

            //送信日時を過去日に無理矢理変える
            testModalController.parameter.mailInfo.sendingDate = Date.newInstance(2020, 3, 1);
            testModalController.parameter.mailInfo.sendingTime = '12';
            testModalController.screenMailInfo.sendingDateTime = Datetime.newInstance(2020, 3, 1, 12, 0, 0).format('yyyy/MM/dd HH:00');
            //送信（時間指定送信登録）
            testModalController.clickSend();
            System.assertEquals(true, testModalController.hasErrorMessage); // 送信予定過去日エラー確認

            //送信予定日時クリア
            testModalController.parameter.mailInfo.sendingDate = null;
            testModalController.parameter.mailInfo.sendingTime = '';
            testModalController.screenMailInfo.sendingDateTime = null;
            //メール送信
            testModalController.clickSend();
            System.assertEquals(true, testModalController.hasErrorMessage); // 不正アドレスエラー確認

        }
    }

    // 確認ボタン⇒モーダルメール返信 処理テスト(対応明細⇒モーダル表示＋メール送信)
    @isTest static void clickConfirmAndSendMailReplyTest() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailDraft__c testMailDraft = [
                SELECT Id, Name
                FROM MailDraft__c
                WHERE Name = 'テスト下書き１'
            ];
            CorrespondDetail__c testCorrespondDetail = [
                SELECT Id, Corresponds__c, EchoMail__c
                    , EchoMail__r.MessageId__c, EchoMail__r.References__c
                FROM CorrespondDetail__c
                WHERE SupportedTitle__c = 'テスト対応明細１'
            ];

            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailDraftId', testMailDraft.Id);
            pageRef.getParameters().put('correspondDetailId', testCorrespondDetail.Id);
            pageRef.getParameters().put('isReply', 'true');
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();

            //送信予定日時クリア
            testController.screenMailInfo.sendingDate = null;
            testController.screenMailInfo.sendingTime = '';

            //確認押下処理
            testController.screenMailInfo.sendTo[0].isCheck = true;
            testController.screenMailInfo.sendTo[1].isCheck = true;
            testController.clickConfirm();
            System.assertNotEquals(true, testController.hasErrorMessage);

            //モーダル起動準備
            GA102004Modal1Controller testModalController = new GA102004Modal1Controller();
            testModalController.parameter = testController.GA102004Modal1Parameter;

            //モーダル初期表示処理
            testModalController.initAction();

            //メール送信
            testModalController.clickSend();

            System.assertEquals(true, testModalController.parameter.isReply);
            System.assertEquals(
                testCorrespondDetail.EchoMail__r.MessageId__c
                ,testModalController.parameter.messageId
            );
            System.assertEquals(
                testCorrespondDetail.EchoMail__r.References__c + testCorrespondDetail.EchoMail__r.MessageId__c
                ,testModalController.parameter.references + testModalController.parameter.messageId
            );

        }
    }
    // カバレッジあげ
    @isTest static void coverageUp() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailDraft__c testMailDraft = [
                SELECT Id, Name
                FROM MailDraft__c
                WHERE Name = 'テスト下書き１'
            ];
            CorrespondDetail__c testCorrespondDetail = [
                SELECT Id, Corresponds__c, EchoMail__c
                    , EchoMail__r.MessageId__c, EchoMail__r.References__c
                FROM CorrespondDetail__c
                WHERE SupportedTitle__c = 'テスト対応明細２'
            ];

            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailDraftId', testMailDraft.Id);
            pageRef.getParameters().put('correspondDetailId', testCorrespondDetail.Id);
            pageRef.getParameters().put('isReply', 'true');
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();

            //送信予定日時クリア
            testController.screenMailInfo.sendingDate = null;
            testController.screenMailInfo.sendingTime = '';

            //確認押下処理
            testController.screenMailInfo.sendTo[0].isCheck = true;
            testController.screenMailInfo.sendTo[1].isCheck = true;
            testController.clickConfirm();
            System.assertNotEquals(true, testController.hasErrorMessage);

            //モーダル起動準備
            GA102004Modal1Controller testModalController = new GA102004Modal1Controller();
            testModalController.parameter = testController.GA102004Modal1Parameter;

            //モーダル初期表示処理
            testModalController.initAction();
            
            String a = testModalController.MSG_COM_V_SENDMAIL;
            a = testModalController.MSG_COM_V_SENDMAIL_SCHEDULE;
            a = testModalController.MSG_COM_I_SENDMAIL;
            a = testModalController.MSG_COM_I_SAVE;
            
            //メール送信
            testModalController.clickSend();

            testModalController.parameter.mailInfo.sendingDate = Date.newInstance(2099, 3, 1);
            testModalController.parameter.mailInfo.sendingTime = '12';
            testModalController.screenMailInfo.sendingDateTime = Datetime.newInstance(2099, 3, 1, 12, 0, 0).format('yyyy/MM/dd HH:00');
            
            //メール送信
            testModalController.clickSend();

            //定型文モーダル起動準備
            GA102004Modal2Controller fixModalController = new GA102004Modal2Controller();
            fixModalController.parameter = testController.GA102004Modal2Parameter;

            //定型文モーダル初期表示処理
            testController.openFixedPhraseSelect();
            fixModalController.parameter.isDrawing = true;
            Boolean flg1 =  fixModalController.init;
            fixModalController.parameter.isDrawing = false;
            flg1 =  fixModalController.init;
            fixModalController.initAction();
            
            //定型文選択
            fixModalController.clickFixedPhrase();

            //定型文モーダルクローズ処理
            testController.closeFixedPhraseSelect();

            //文例集モーダル起動準備
            GA102004Modal3Controller exaModalController = new GA102004Modal3Controller();
            exaModalController.parameter = testController.GA102004Modal3Parameter;

            //文例集モーダル初期表示処理
            testController.openExampleSentenceSelect();
            exaModalController.parameter.isDrawing = true;
            Boolean flg2 =  exaModalController.init;
            exaModalController.parameter.isDrawing = false;
            flg2 =  exaModalController.init;
            exaModalController.selectExampleSentenceText = 'aaa';
            exaModalController.initAction();

        }
    }

    // ポータルサイト構築 追加 Start
    // 自社ポータル権限有
    @isTest static void portalMail() {
        User user =  [SELECT Id FROM User WHERE UserName = :USER_NAME];
        System.runAs(user){
            Account testAccount = [
                SELECT Id, Name, Email2__c
                FROM Account
                WHERE Name = 'テスト取引先GA102004'
            ];
            MailDraft__c testMailDraft = [
                SELECT Id, Name
                FROM MailDraft__c
                WHERE Name = 'テスト下書き１'
            ];
            CorrespondDetail__c testCorrespondDetail = [
                SELECT Id, Corresponds__c, EchoMail__c
                    , EchoMail__r.MessageId__c, EchoMail__r.References__c
                FROM CorrespondDetail__c
                WHERE SupportedTitle__c = 'テスト対応明細２'
            ];

            //パラメータ設定
            PageReference pageRef = Page.GA102004View;
            pageRef.getParameters().put('accountId', testAccount.Id);
            pageRef.getParameters().put('mailDraftId', testMailDraft.Id);
            pageRef.getParameters().put('correspondDetailId', testCorrespondDetail.Id);
            pageRef.getParameters().put('isReply', 'true');
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GA102004Controller testController = new GA102004Controller();

            // 物件詳細の初期表示
            testController.initPropertyDetail();

            // 発行ボタン押下処理（お気に入り物件）
            testController.clickIssueFavoriteProperty();

        }
    }
    // ポータルサイト構築 追加 End

}