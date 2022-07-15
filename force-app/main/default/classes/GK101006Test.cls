/* *
 *  HPニュース詳細とプレビュー　テストクラス
 */
@isTest 
public with sharing class GK101006Test {
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('一般ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert new User(
                UserName = 'GK101006@horaguchi.com',
                Email = 'test@example.com',
                LastName = 'test',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
        }

        // カスタム設定を登録 
        SystemConfig__c sysconf = new SystemConfig__c(
            UseAuthority_Portal__c = true
            ,PortalCSSPath__c = 'https://roomnew.herokuapp.com/'
        );
        insert sysconf;


        // ニュースリリース登録
        insert new NewsRelease__c[]{
            new NewsRelease__c(
                FixedDisplayFlag__c = true,   // 固定表示フラグ
                Name = 'test',                  // タイトル
                ReleaseStartDate__c = Date.newInstance(2020,09,01),   // 掲載開始日
                ReleaseEndDate__c = Date.newInstance(2020,09,30),                       // 掲載終了日
                ReleaseStatus__c = CommonConst_ptl.NEWSRELEASE_RELEASESTATUS_PUBLIC,     // 公開状況
                Template__c = CommonConst_ptl.NEWSRELEASE_TEMPLATE_1,
                Body1__c = 'てすと'
            ),
            new NewsRelease__c(
                FixedDisplayFlag__c = false,   // 固定表示フラグ
                Name = 'test2',                  // タイトル
                ReleaseStartDate__c = Date.newInstance(2020,09,01),   // 掲載開始日
                ReleaseEndDate__c = Date.newInstance(2020,09,30),                       // 掲載終了日
                ReleaseStatus__c = CommonConst_ptl.NEWSRELEASE_RELEASESTATUS_PUBLIC     // 公開状況
            ),
            // ▼ 2022.04.04 問合せNo754追加 
            new NewsRelease__c(
                FixedDisplayFlag__c = false,   // 固定表示フラグ
                Name = 'test_category',                  // タイトル
                ReleaseStartDate__c = Date.newInstance(2020,09,01),   // 掲載開始日
                ReleaseEndDate__c = Date.newInstance(2020,09,30),                       // 掲載終了日
                ReleaseStatus__c = CommonConst_ptl.NEWSRELEASE_RELEASESTATUS_PUBLIC,     // 公開状況
                Template__c = CommonConst_ptl.NEWSRELEASE_TEMPLATE_1,
                Category__c = CommonConst_ptl.NEWSRELEASE_NOTICE, //    カテゴリあり
                Body1__c = 'てすと'
            ),
            // ▲ 2022.04.04 問合せNo754追加 

            // ▼ 2022.05.27 問合せNo0833追加
			new NewsRelease__c(
                FixedDisplayFlag__c = false,                                            //固定表示フラグ
                Name = 'test_description_update',                                       //タイトル
                Description__c = '値あり',                                      		//デスクリプション
                ReleaseStartDate__c = Date.newInstance(2020,09,01),                     // 掲載開始日
                ReleaseEndDate__c = Date.newInstance(2020,09,30),                       // 掲載終了日
                ReleaseStatus__c = CommonConst_ptl.NEWSRELEASE_RELEASESTATUS_PUBLIC,    // 公開状況
                Template__c = CommonConst_ptl.NEWSRELEASE_TEMPLATE_1,
                Category__c = CommonConst_ptl.NEWSRELEASE_NOTICE,                       //    カテゴリあり
                Body1__c = 'てすと'
            )
            // ▲ 2022.05.27 問合せNo0833追加
        };

        // ニュースリリースプレビュー用パラメータ登録
        insert new NewsReleasePreviewParameter__c[]{
            new NewsReleasePreviewParameter__c(
                Title__c = 'test',                  // タイトル
                ReleaseStartDate__c = Date.newInstance(2020,09,01),   // 掲載開始日
                Template__c = CommonConst_ptl.NEWSRELEASE_TEMPLATE_1,
                Body1__c = 'てすと'
            )
        };
        // 定型文登録
        FixedPhrase__c testFixedPhrase = new FixedPhrase__c(
            Name        = 'テスト定型文１'
            ,Folder__c  = 'テストフォルダ１'
            ,Subject__c = 'テスト件名１'
            ,Text__c    = 'テスト本文１' 
            ,UsageScreen__c = CommonConst_ptl.FIXEDPHRASE_USAGESCREEN_NEWSRELEASE
        );
        insert testFixedPhrase;
    }

    //保存処理テスト（新規登録）
    @isTest static void save_Test_New(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
        system.runas(userRecord){

            //コントローラ作成
            GK101006Controller testController = new GK101006Controller();

            // 保存処理
            testController.clickSaveButton();

        }
    }

    //保存処理テスト（更新）	
    @isTest static void save_Test_Update(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            newsRelease__c news = [SELECT Id FROM newsRelease__c WHERE Name = 'test'];

            pageReference pageRef = Page.Gk101006View;
            pageRef.getParameters().put('id', news.Id);
            Test.setCurrentPage(pageRef);

            //コントローラ作成
            GK101006Controller testController = new GK101006Controller();
            
            testController.clickSaveButton();
        }
    }

    // 定型文の選択
    @istest static void fixedPhraseSelect_Test(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
        system.runas(userRecord){

            //テストデータ取得
            newsRelease__c news = [SELECT Id FROM newsRelease__c WHERE Name = 'test'];

            pageReference pageRef = Page.Gk101006View;
            pageRef.getParameters().put('id', news.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GK101006Controller testController = new GK101006Controller();

            testController.selectFixedPhraseIndex = 0;

            // 定型文押下
            testController.clickFixedPhrase();

        }
    }

    // 削除ボタン押下
    @istest static void del_Test_Button(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            newsRelease__c news = [SELECT Id FROM newsRelease__c WHERE Name = 'test'];

            pageReference pageRef = Page.Gk101006View;
            pageRef.getParameters().put('id', news.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GK101006Controller testController = new GK101006Controller();


            // 削除ボタン押下
            testController.clickDeleteButton();
        }
    }

    // プレビューボタン押下
    @istest static void preview_Test_Button(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            newsRelease__c news = [SELECT Id FROM newsRelease__c WHERE Name = 'test'];

            pageReference pageRef = Page.Gk101006View;
            pageRef.getParameters().put('id', news.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GK101006Controller testController = new GK101006Controller();
            
            testController.previewButton();

        }
    }
    @istest static void preview_Test_Button2(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
        system.runas(userRecord){
            

            NewsReleasePreviewParameter__c newsPreview = [SELECT Id FROM NewsReleasePreviewParameter__c WHERE Title__c = 'test'];
            pageReference pageRef2 = Page.Gk101006View2;
            pageRef2.getParameters().put('previewParameterId', newsPreview.Id);
            Test.setCurrentPage(pageRef2);
        
            GK101006Controller2 testController2 = new GK101006Controller2();

            testController2.deleteNewsReleasePreviewParameter();
        }
    }
    // 写真操作処理
    @istest static void photo_Test_Operation(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            newsRelease__c news = [SELECT Id FROM newsRelease__c WHERE Name = 'test'];

            pageReference pageRef = Page.Gk101006View;
            pageRef.getParameters().put('id', news.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GK101006Controller testController = new GK101006Controller();

            // アップロード後処理
            testController.updateReleasePhoto();

            // 写真削除
            testController.deleteNewsReleasePhotoPhoto();
        }
    }
    // ▼ 2022.04.04 問合せNo754追加 
    //新規作成時のデフォルト値初期表示
    @isTest static void categorytest001(){

        //ユーザ設定
        User thisUser =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
        //コントローラ作成
        GK101006Controller testController = new GK101006Controller();

        //★結果確認★
        //新規作成時、カテゴリのデフォルト値がnullであること
        System.runAs(thisUser) {
            Test.startTest();
                system.assertEquals(testController.screenNewsRelease.category,'');
            Test.stopTest();
        }
    }

    //新規作成時のデフォルト入力チェック
    @isTest static void categorytest002(){

        User thisUser =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
        //コントローラ作成
        GK101006Controller testController = new GK101006Controller();

        //ニュース新規作成・カテゴリ以外の必須項目をセット
        testController.screenNewsRelease.Name = 'test_category_t002';             // タイトル
        testController.screenNewsRelease.ReleaseStartDate = Date.newInstance(2020,09,01);   // 掲載開始日
        testController.screenNewsRelease.ReleaseEndDate = Date.newInstance(2020,09,30);                      // 掲載終了日
        testController.screenNewsRelease.ReleaseStatus = CommonConst_ptl.NEWSRELEASE_RELEASESTATUS_PUBLIC;     // 公開状況
        testController.screenNewsRelease.Template = CommonConst_ptl.NEWSRELEASE_TEMPLATE_1;
        testController.screenNewsRelease.Body1 = 'てすと';
        
        //★結果確認★
        System.runAs(thisUser) {
            Test.startTest();
                testController.clickSaveButton();
                //エラーメッセージを取得
                List<ApexPages.Message> messages = ApexPages.getMessages();
                //エラーメッセージの内容を照合
                system.assertEquals(true,messages[0].getDetail().equals('カテゴリは入力必須です。'));
            Test.stopTest();
        }
    }
    //新規作成時カテゴリの保存
    @isTest static void categorytest003(){

        User thisUser =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
        //コントローラ作成
        GK101006Controller testController = new GK101006Controller();

        //ニュース新規作成
        testController.screenNewsRelease.Name = 'test_category_t003';             // タイトル
        testController.screenNewsRelease.ReleaseStartDate = Date.newInstance(2020,09,01);   // 掲載開始日
        testController.screenNewsRelease.ReleaseEndDate = Date.newInstance(2020,09,30);                      // 掲載終了日
        testController.screenNewsRelease.ReleaseStatus = CommonConst_ptl.NEWSRELEASE_RELEASESTATUS_PUBLIC;     // 公開状況
        testController.screenNewsRelease.Template = CommonConst_ptl.NEWSRELEASE_TEMPLATE_1;
        testController.screenNewsRelease.Category = CommonConst_ptl.NEWSRELEASE_NOTICE; //    カテゴリあり
        testController.screenNewsRelease.Body1 = 'てすと';
        
        //★結果確認★
        System.runAs(thisUser) {
            Test.startTest();
                //保存ボタン押下
                testController.clickSaveButton();
            Test.stopTest();
            //保存されたニュースを取得
            NewsRelease__c af_news =[SELECT ID,name,Category__c from NewsRelease__c where name ='test_category_t003'];
            //カテゴリの値が正しく保存されたこと
            system.assertEquals(af_news.Category__c,CommonConst_ptl.NEWSRELEASE_NOTICE);

        }
    }
        //既存データの初期表示値を確認
        @isTest static void categorytest004(){

            //ユーザセット
            User thisUser =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];

            //ニュースセット
            newsRelease__c news = [SELECT Id,name,Category__c FROM newsRelease__c WHERE Name = 'test_category'];
            system.debug('news:'+news);
            pageReference pageRef = Page.Gk101006View;
            pageRef.getParameters().put('id', news.Id);
            Test.setCurrentPage(pageRef);

            //コントローラ作成
            GK101006Controller testController = new GK101006Controller();
            //★結果確認★
            System.runAs(thisUser) {
                Test.startTest();
                //画面上のカテゴリの値を確認
                system.assertEquals(testController.screenNewsRelease.category,CommonConst_ptl.NEWSRELEASE_NOTICE);
                Test.stopTest();
            }
        }
        //既存ニュースの入力チェック
        @isTest static void categorytest005(){
            //ユーザセット
            User thisUser =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
            //ニュース取得
            newsRelease__c news = [SELECT Id,name,Category__c FROM newsRelease__c WHERE Name = 'test_category'];
            system.debug('news:'+news);
            pageReference pageRef = Page.Gk101006View;
            pageRef.getParameters().put('id', news.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GK101006Controller testController = new GK101006Controller();
            
            //★結果確認★
            System.runAs(thisUser) {
                Test.startTest();
                //画面上カテゴリの選択リスト「--なし--」を選択し、保存ボタンを押下する
                testController.screenNewsRelease.category = null;
                testController.clickSaveButton();
                //エラーメッセージを取得
                List<ApexPages.Message> messages = ApexPages.getMessages();
                //エラーメッセージの内容を照合
                system.assertEquals(true,messages[0].getDetail().equals('カテゴリは入力必須です。'));
                Test.stopTest();
            }
        }

        //既存ニュースのカテゴリが変更された時、値が保存されるテストケース
        @isTest static void categorytest006(){

            User thisUser =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
            //ニュース取得
            newsRelease__c news = [SELECT Id,name,Category__c FROM newsRelease__c WHERE Name = 'test_category'];
            system.debug('news:'+news);
            pageReference pageRef = Page.Gk101006View;
            pageRef.getParameters().put('id', news.Id);
            Test.setCurrentPage(pageRef);
            //コントローラ作成
            GK101006Controller testController = new GK101006Controller();
                    
            //★結果確認★
            System.runAs(thisUser) {
                Test.startTest();
                //画面上カテゴリの選択リスト「不動産コラム」を選択し、保存ボタンを押下する
                testController.screenNewsRelease.category = CommonConst_ptl.NEWSRELEASE_REALESTTECOLUMN;
                testController.clickSaveButton();
                //保存されたニュースを取得
                NewsRelease__c afnews =[SELECT id,name,Category__c FROM newsRelease__c WHERE Name = 'test_category'];
                //カテゴリの値が保存されること
                system.assertEquals(afnews.category__c,CommonConst_ptl.NEWSRELEASE_REALESTTECOLUMN);
                Test.stopTest();
            }
        }
    // ▲ 2022.04.04 問合せNo754追加 

    // ▼ 2022.05.27 問合せNo0833対応
	//1.新規の時、項目が表示されること(値はNULL)
    @isTest static void Test_description_new(){
		//ユーザ設定
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
		//コントローラ作成
		GK101006Controller testController = new GK101006Controller();

        system.runas(userRecord){
            Test.startTest();
			    //デスクリプション表示の確認、項目が表示されること(値はNULL)
				system.assertEquals(null,testController.screenNewsRelease.description);
			Test.stopTest();
        }
    }

	//2.更新の時、項目と既存の値が表示されること
    @isTest static void Test_description_update(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
    
        system.runas(userRecord){
            
            //テストデータ取得
            newsRelease__c news = [SELECT Id,Name,Description__c FROM newsRelease__c WHERE Name = 'test_description_update'];
            
            pageReference pageRef = Page.Gk101006View;
            pageRef.getParameters().put('id', news.Id);
            Test.setCurrentPage(pageRef);
            Test.startTest();
            //コントローラ作成
            GK101006Controller testController = new GK101006Controller();
            Test.stopTest();

            //デスクリプション表示の確認、項目と既存の値が表示されること
            System.assertEquals(news.Description__c,testController.screenNewsRelease.description);
        }
        
    }

	//4.入力された値を保存できること
	@isTest static void Test_description_confirm(){
        User thisUser =  [SELECT Id FROM User WHERE UserName = 'GK101006@horaguchi.com'];
        //ニュース取得
        newsRelease__c news = [SELECT Id,name,Description__c FROM newsRelease__c WHERE Name = 'test_description_update'];
        pageReference pageRef = Page.Gk101006View;
        pageRef.getParameters().put('id', news.Id);
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GK101006Controller testController = new GK101006Controller();
                
        //★結果確認★
        System.runAs(thisUser) {
            Test.startTest();
            //画面上デスクリプションの値を変更し、保存ボタンを押下する
            testController.screenNewsRelease.description = 'デスクリプションを更新しました';
            testController.clickSaveButton();
            Test.stopTest();
            //保存されたニュースを取得
            NewsRelease__c afnews =[SELECT id,name,Description__c FROM newsRelease__c WHERE Name = 'test_description_update'];
            //デスクリプションの値が保存されること
            system.assertEquals('デスクリプションを更新しました',afnews.Description__c);

        }
    }
    // ▲ 2022.05.27 問合せNo0833対応
}