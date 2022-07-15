/* *
 * ニュースリリース一覧　テストクラス
 */
@isTest 
public with sharing class GK101005Test {
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        // カスタム設定
        SystemConfig__c testSystemConfig = new SystemConfig__c();
        testSystemConfig.UseAuthority_Portal__c = true;
        insert testSystemConfig;
        

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('一般ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert new User(
                UserName = 'Test@horaguchi.com',
                Email = 'test@example.com',
                LastName = 'test',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
        }


        // ニュースリリース登録
        insert new NewsRelease__c[]{new NewsRelease__c(
            FixedDisplayFlag__c = true,   // 固定表示フラグ
            Name = 'test',                  // タイトル
            ReleaseStartDate__c = Date.newInstance(2020,09,01),   // 掲載開始日
            ReleaseEndDate__c = Date.newInstance(2020,09,30),                       // 掲載終了日
            ReleaseStatus__c = CommonConst_ptl.NEWSRELEASE_RELEASESTATUS_PUBLIC     // 公開状況
        )};
    }

    //初期表示テスト	
    @isTest static void search_1_Test(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101005Controller testController = new GK101005Controller();

            testController.getpostedPeriodRadioButtonSetting();

            // 条件指定
            testController.postedPeriodRadioButton = testController.PeriodRadioButton_ALL;    // 掲載期間ラジオボタン
            testController.searchSpecifiedDate = null;  // 指定日
            testController.searchReleaseStatus = CommonConst_ptl.NEWSRELEASE_RELEASESTATUS_PUBLIC;  // 公開状況（選択リスト）
            testController.searchTitle         = 'test';  // タイトル

            //検索
            testController.search();

            //検索結果が1件ある？
            system.assertEquals(1, testController.getNewsReleaseList.size());
        }
    }

    //初期表示テスト	
    @isTest static void search_0_Test(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101005Controller testController = new GK101005Controller();
            
            // 条件指定
            testController.postedPeriodRadioButton = testController.PeriodRadioButton_Specified;    // 掲載期間ラジオボタン
            testController.searchSpecifiedDate = Date.newInstance(2020,09,01);  // 指定日
            testController.searchReleaseStatus = CommonConst_ptl.NEWSRELEASE_RELEASESTATUS_PUBLIC;  // 公開状況（選択リスト）
            testController.searchTitle         = 'test';  // タイトル
            testController.searchCreatedName   = 'test';  // 作成者名

            testController.getpostedPeriodRadioButtonSetting();

            //検索
            testController.search();

            //0エラー出てる？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA)));
        }
    }


}