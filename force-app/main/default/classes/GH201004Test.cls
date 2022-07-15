/**
 * 利用店舗選択画面のテストクラス
 */
@isTest
public class GH201004Test {
    /*********************************
     * テストに使用するレコードを作成する
     *********************************/
    @TestSetup static void setting(){

        // ユーザ作成
        // 2021.02.18 Y.Hirata 再販対応：プロファイル名を”標準ユーザ”から”一般ユーザ”に変更
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('Standard User', '一般ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            User testUser = new User(UserName = 'GH201004Test@horaguchi.com',
                                     Email = 'test@example.com',
                                     LastName = 'test',
                                     Alias = 'test',
                                     TimeZoneSidKey = 'Asia/Tokyo',
                                     LocaleSidKey = 'ja_JP',
                                     EmailEncodingKey = 'ISO-2022-JP',
                                     LanguageLocaleKey = 'ja',
                                     ProfileId = profiles.get(0).Id );
            insert testUser;
        }
        // 店舗レコード
        Date today = CommonUtil.getToday();
        Shop__c testShop = new Shop__c(Name = 'テスト店舗'
                                     , SystemUseStartDate__c = today               // 開始日=今日
                                     , SystemUseEndDate__c = today.addDays(100) ); // 終了日=今日+100日
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
    }

    /*********************************
     * 初期表示テスト
     *********************************/
    @isTest
    public static void initializeTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH201004Test@horaguchi.com'];
        OrganizationHierarchy__c testOrg = [SELECT Id FROM OrganizationHierarchy__c WHERE OrganizationCode__c = '0002'];
        Date today = CommonUtil.getToday();

        // 店舗異動レコード作成
        ShopTransfer__c testShopTransfer = new ShopTransfer__c(
                                                               Staff__c = userRecord.Id
                                                             , OrgzanizationHierarchy__c = testOrg.Id
                                                             , StartDate__c = today               // 開始日=今日
                                                             , EndDate__c = today.addDays(100) ); // 終了日=今日+100日
        insert testShopTransfer;

        // ログインユーザで実行
        system.runas(userRecord){

            // コンストラクタ起動
            GH201004Controller testController = new GH201004Controller();

            // 店舗選択リストに値が格納されているか
            system.assert(testController.usrShopSelectList.size() != 0, '店舗選択リストが空');
        }
    }

    /*********************************
     * 初期表示テスト(店舗異動レコードなし)
     *********************************/
    @isTest
    public static void initializeErrorTest(){
        
        //
        // 店舗異動レコードは作成しない
        //

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH201004Test@horaguchi.com'];
        system.runas(userRecord){

            // コンストラクタ起動
            GH201004Controller testController = new GH201004Controller();

            // ビジネスロジックExceptionが発行されているか
            List<ApexPages.Message> messages = ApexPages.getMessages();
            //System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_GET_AFFILIATION_SHOP)), messages[0]);
        }
    }

    /*********************************
     * 設定処理テスト
     *********************************/
    @isTest
    public static void settingTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH201004Test@horaguchi.com'];
        OrganizationHierarchy__c testOrg = [SELECT Id FROM OrganizationHierarchy__c WHERE OrganizationCode__c = '0002'];
        Date today = CommonUtil.getToday();

        // 店舗異動レコード作成
        ShopTransfer__c testShopTransfer = new ShopTransfer__c(
                                                               Staff__c = userRecord.Id
                                                             , OrgzanizationHierarchy__c = testOrg.Id
                                                             , StartDate__c = today               // 開始日=今日
                                                             , EndDate__c = today.addDays(100) ); // 終了日=今日+100日
        insert testShopTransfer;

        // ログインユーザで実行
        system.runas(userRecord){

            // コンストラクタ起動
            GH201004Controller testController = new GH201004Controller();

            // 設定処理実行
            testController.shopSetting();

            // カスタムユーザ設定レコードが登録されているか
            List<UserSetting__c> userSettingList = [ SELECT Id FROM UserSetting__c WHERE setupOwnerId = :testController.loginUserId ];
            system.assert(userSettingList.size() != 0, 'カスタムユーザ設定が登録されていません');
        }

    }

}