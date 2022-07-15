// 物件詳細画面のテストクラス
@ isTest
private class GA104004Test {

    @TestSetup

    // テストに利用するデータを用意する。
    static void Setting(){

        // システム設定登録
        SystemConfig__c sysCon = new SystemConfig__c();
        sysCon.FormLogoPath__c= '/sfc/servlet.shepherd/version/download/0685h000001AAYMAA4';
        insert sysCon;

        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = '横井店舗',
                                         PortalSitePostingDistrict__c = '港区;北区');
        insert shopRecord;
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
        //店舗異動レコード
        List<ShopTransfer__c> ShopTransferList = new List<ShopTransfer__c>();
        // ログインユーザ用にデータ格納
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = UserInfo.getUserId(),
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
        ShopTransferList.add(ShopTransferRecord);
        insert ShopTransferList;

        // 建物レコード
        Building__c building = new Building__c(
                Name = 'test建物名');
        insert building;

        // 物件レコード
        Property__c property = new Property__c(
                Name = 'test部屋番号',
                Building__c = building.Id);
        insert property;

        // 物件写真レコード
        PropertyPhoto__c photo = new PropertyPhoto__c(Property__c = property.Id,
                                                        PropertyPhotoFileName1__c = 'ファイル名１');
        insert photo;

        // 物件条件レコード
        PropertyConditions__c proCon = new PropertyConditions__c(Property__c = property.Id,
                                                                    IsElevator__c = true,
                                                                    IsDesigners__c = true);
        insert proCon;

        // 取引先レコード
        List<Account> accountList = new List<Account>();
        Account account1 = new Account(Name = 'お気に入り用');
        accountList.add(account1);
        Account account2 = new Account(Name = '火災保険用');
        accountList.add(account2);
        Account account3 = new Account(Name = '保証会社用');
        accountList.add(account3);
        insert accountList;

        // 管理会社指定商品
        ManagementCompanyItem__c manaCom = new ManagementCompanyItem__c(
                                            ItemName__c = '物件指定商品',
                                            Account__c = account1.Id);
        insert manaCom;

        // 物件指定商品
        PropertyManageCompayItem__c proMana = new PropertyManageCompayItem__c(Property__c = property.Id,
                                                                    Account__c = account1.Id,
                                                                    Item__c = manaCom.Id);
        insert proMana;
    }

    // 物件詳細の呼び出し
    // ・物件ID：設定あり
    // ・取引先ID：設定なし
    // ・お客様用フラグ：設定なし
    @isTest static void showPropertyView_ptn1(){
        List<Property__c> getProperty = [SELECT Id FROM Property__c WHERE Name IN ('test部屋番号')];

        //パラメータ設定
        PageReference pageRef = Page.GA104004View;
        pageRef.getParameters().put('Id',getProperty.get(0).Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104004Controller GA104004Controller = new GA104004Controller();

        // ★★ 実行後の処理確認 ★★
        // true：取得できる  false：取得できない
        // 物件、物件写真、お気に入りフラグ、設備条件、設備備考、物件管理会社指定商品
        //2020/04/27:物件管理会社指定の取得条件を変更したため、falseからtrueに変更しています。
        checkAfterInsert(GA104004Controller, true, true, false, true, true, true);
    }

    // 物件詳細の呼び出し
    // ・物件ID：設定あり
    // ・取引先ID：設定あり
    // ・お客様用フラグ：設定なし
    // ・お気に入り物件：あり
    @isTest static void showPropertyView_ptn2(){

        List<Property__c> getProperty = [SELECT Id FROM Property__c WHERE Name IN ('test部屋番号')];
        List<Account> getAccount = [SELECT Id FROM Account WHERE Name IN ('お気に入り用')];

        // お気に入り物件登録
        FavoriteProperty__c favPro = new FavoriteProperty__c(Account__c = getAccount.get(0).Id,
                                                             Property__c = getProperty.get(0).Id);
        insert favPro;

        //パラメータ設定
        PageReference pageRef = Page.GA104004View;
        pageRef.getParameters().put('Id',getProperty.get(0).Id );
        pageRef.getParameters().put('accountId',getAccount.get(0).Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104004Controller GA104004Controller = new GA104004Controller();

        // ★★ 実行後の処理確認 ★★
        // true：取得できる  false：取得できない
        // 物件、物件写真、お気に入りフラグ、設備条件、設備備考、物件管理会社指定商品
        checkAfterInsert(GA104004Controller, true, true, true, true, true, true);
    }

    // 物件詳細の呼び出し
    // ・物件ID：設定あり
    // ・取引先ID：設定あり
    // ・お客様用フラグ：設定なし
    // ・お気に入り物件：なし
    @isTest static void showPropertyView_ptn3(){

        List<Property__c> getProperty = [SELECT Id FROM Property__c WHERE Name IN ('test部屋番号')];
        List<Account> getAccount = [SELECT Id FROM Account WHERE Name IN ('お気に入り用')];

        //パラメータ設定
        PageReference pageRef = Page.GA104004View;
        pageRef.getParameters().put('Id',getProperty.get(0).Id );
        pageRef.getParameters().put('accountId',getAccount.get(0).Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104004Controller GA104004Controller = new GA104004Controller();

        // ★★ 実行後の処理確認 ★★
        // true：取得できる  false：取得できない
        // 物件、物件写真、お気に入りフラグ、設備条件、設備備考、物件管理会社指定商品
        checkAfterInsert(GA104004Controller, true, true, false, true, true, true);
    }

    // 物件詳細の呼び出し
    // ・物件ID：設定あり
    // ・取引先ID：設定あり
    // ・お客様用フラグ：設定あり
    @isTest static void showPropertyView_ptn4(){

        List<Property__c> getProperty = [SELECT Id FROM Property__c WHERE Name IN ('test部屋番号')];
        List<Account> getAccount = [SELECT Id FROM Account WHERE Name IN ('お気に入り用')];

        //パラメータ設定
        PageReference pageRef = Page.GA104004View;
        pageRef.getParameters().put('Id',getProperty.get(0).Id );
        pageRef.getParameters().put('accountId',getAccount.get(0).Id );
        pageRef.getParameters().put('customerFlg', 'true');
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104004Controller GA104004Controller = new GA104004Controller();

        // ★★ 実行後の処理確認 ★★
        // true：取得できる  false：取得できない
        // 物件、物件写真、お気に入りフラグ、設備条件、設備備考、物件管理会社指定商品
        checkAfterInsert(GA104004Controller, true, true, false, true, true, true);
    }

    // 物件詳細の呼び出し
    // ・物件ID：設定あり
    // ・取引先ID：設定なし
    // ・お客様用フラグ：設定あり
    @isTest static void showPropertyView_ptn5(){

        List<Property__c> getProperty = [SELECT Id FROM Property__c WHERE Name IN ('test部屋番号')];
        List<Account> getAccount = [SELECT Id FROM Account WHERE Name IN ('お気に入り用')];

        //パラメータ設定
        PageReference pageRef = Page.GA104004View;
        pageRef.getParameters().put('Id',getProperty.get(0).Id );
        // pageRef.getParameters().put('accountId',getAccount.get(0).Id );
        pageRef.getParameters().put('customerFlg', 'true');
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104004Controller GA104004Controller = new GA104004Controller();

        // ★★ 実行後の処理確認 ★★
        // true：取得できる  false：取得できない
        // 物件、物件写真、お気に入りフラグ、設備条件、設備備考、物件管理会社指定商品
        //2020/04/27:物件管理会社指定の取得条件を変更したため、falseからtrueに変更しています。
        checkAfterInsert(GA104004Controller, true, true, false, true, true, true);
    }

    // 物件詳細の呼び出し
    // ・物件ID：設定なし
    // ・取引先ID：設定なし
    // ・お客様用フラグ：設定なし
    @isTest static void showPropertyView_ptn6(){

        List<Property__c> getProperty = [SELECT Id FROM Property__c WHERE Name IN ('test部屋番号')];
        List<Account> getAccount = [SELECT Id FROM Account WHERE Name IN ('お気に入り用')];

        //パラメータ設定
        PageReference pageRef = Page.GA104004View;
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104004Controller GA104004Controller = new GA104004Controller();

        // ★★ 実行後の処理確認 ★★
        // true：取得できる  false：取得できない
        // 物件、物件写真、お気に入りフラグ、設備条件、設備備考、物件管理会社指定商品
        checkAfterInsert(GA104004Controller, false, false, false, false, false, false);
    }
    
    // カバレッジ率アップ
    @isTest static void forCoverage() {
        
        List<Property__c> getProperty = [SELECT Id FROM Property__c WHERE Name IN ('test部屋番号')];
        List<Account> getAccount = [SELECT Id FROM Account WHERE Name IN ('お気に入り用')];

        //パラメータ設定
        PageReference pageRef = Page.GA104004View;
        pageRef.getParameters().put('Id',getProperty.get(0).Id );
        pageRef.getParameters().put('accountId',getAccount.get(0).Id );
        pageRef.getParameters().put('customerFlg', 'true');
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104004Controller testController = new GA104004Controller();
        
        // String型を呼び出すだけ
        String s = testController.MSG_COM_V_SAVE;
        s = testController.MSG_COM_I_SAVE;
        s = testController.MSG_PROP_I_BIKEPARKING_NOT_ALLRENTFEE;
        
        // お気に入りボタン押下
        testController.saveFavorite();
        
        // 改行メソッド呼び出し
        testController.autoKaigyo('aiueo',3);
    }

    // PDF画像URL確認
    @isTest static void createMapUrlTest() {

        Building__c building = [SELECT id, Latitude__c, Longitude__c FROM Building__c WHERE Name = 'test建物名'];
        building.Latitude__c = 111.011111100000000;
        building.Longitude__c = 222.022222200000000;
        update building;

        List<Property__c> getProperty = [SELECT Id FROM Property__c WHERE Name IN ('test部屋番号')];
        List<Account> getAccount = [SELECT Id FROM Account WHERE Name IN ('お気に入り用')];

        //パラメータ設定
        PageReference pageRef = Page.GA104004View;
        pageRef.getParameters().put('Id',getProperty.get(0).Id );
        pageRef.getParameters().put('accountId',getAccount.get(0).Id );
        pageRef.getParameters().put('customerFlg', 'true');
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104004Controller testController = new GA104004Controller();
        Building__c build = [SELECT id, Latitude__c, Longitude__c FROM Building__c WHERE Name = 'test建物名'];
        String googleKey = SystemConfig__c.getInstance().GoogleMapKey__c;
        String resultUrl = 'https://maps.googleapis.com/maps/api/staticmap?center=' + build.Latitude__c + ',' + build.Longitude__c + 
                            '&zoom=14&size=640x640&scale=2&language=ja&markers=' + build.Latitude__c + ',' + build.Longitude__c + '&key=' + googleKey;
        System.assertEquals(resultUrl, testController.mapUrl);
    }

    // 改行メソッドNullテスト
    @isTest static void autoKaigyoAdjustDistanceNullTest() {
        List<Property__c> getProperty = [SELECT Id FROM Property__c WHERE Name IN ('test部屋番号')];
        List<Account> getAccount = [SELECT Id FROM Account WHERE Name IN ('お気に入り用')];

        //パラメータ設定
        PageReference pageRef = Page.GA104004View;
        pageRef.getParameters().put('Id',getProperty.get(0).Id );
        pageRef.getParameters().put('accountId',getAccount.get(0).Id );
        pageRef.getParameters().put('customerFlg', 'true');
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104004Controller testController = new GA104004Controller();
        // 改行メソッド呼び出し
        // 本文の文字列
        String testStr = null;
        // 距離の文字列
        String distanceStr = 'aiueo';

        // 本文の文字列がnullの場合
        String result = testController.autoKaigyoAdjustDistance(testStr, distanceStr, 10);
        // 改行コードなしで出力される
        System.assertEquals('', result);
    }

    // 改行メソッド境界値テスト1
    @isTest static void autoKaigyoAdjustDistanceNewLineTest1() {
        List<Property__c> getProperty = [SELECT Id FROM Property__c WHERE Name IN ('test部屋番号')];
        List<Account> getAccount = [SELECT Id FROM Account WHERE Name IN ('お気に入り用')];

        //パラメータ設定
        PageReference pageRef = Page.GA104004View;
        pageRef.getParameters().put('Id',getProperty.get(0).Id );
        pageRef.getParameters().put('accountId',getAccount.get(0).Id );
        pageRef.getParameters().put('customerFlg', 'true');
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104004Controller testController = new GA104004Controller();
        // 改行メソッド呼び出し
        // 本文の文字列
        String testStr = 'aiueo';
        // 距離の文字列
        String distanceStr = 'kyori';
        // 結果の文字列
        String result;

        // 本文の文字列 + 距離の文字列の文字数が改行文字数より小さい場合
        result = testController.autoKaigyoAdjustDistance(testStr, distanceStr, 15);
        System.assertEquals(testStr + distanceStr, result);

        testStr = 'aiueoaiueo';
        // 本文の文字列 + 距離の文字列の文字数と改行文字数が同じ場合
        result = testController.autoKaigyoAdjustDistance(testStr, distanceStr, 15);
        // 改行コードなしで出力される
        System.assertEquals(testStr + distanceStr, result);

        testStr = 'aiueoaiueoaiue'; //14文字
        // 本文の文字列 + 距離の文字列が改行文字数より大きい　かつ　本文の文字数が改行文字数より小さい場合
        result = testController.autoKaigyoAdjustDistance(testStr, distanceStr, 15);
        // 本文の文字列 + '<wbr/>' + 距離の文字列 が出力される
        System.assertEquals(testStr + '<wbr/>' + distanceStr, result);

        testStr = 'aiueoaiueoaiueo'; //15文字
        // 本文の文字列 + 距離の文字列が改行文字数より大きい　かつ　本文の文字数が改行文字数と同じ場合
        result = testController.autoKaigyoAdjustDistance(testStr, distanceStr, 15);
        // 本文の文字列 + '<wbr/>' + 距離の文字列 が出力される
        System.assertEquals(testStr + '<wbr/>' + distanceStr, result);

        testStr = 'aiueoaiueoaiueoa'; //16文字
        // 本文の文字列 + 距離の文字列が改行文字数より大きい　かつ　本文の文字数が改行文字数より大きい場合
        result = testController.autoKaigyoAdjustDistance(testStr, distanceStr, 15);
        // 先頭から改行文字数分の本文の文字列 + '<wbr/>' + 残りの本文の文字列 + 距離の文字列 が出力される
        System.assertEquals(testStr.substring(0,15) + '<wbr/>' + testStr.substring(15) + distanceStr, result);    

    }
    
    // 改行メソッド境界値テスト2
    @isTest static void autoKaigyoAdjustDistanceNewLineTest2() {
        List<Property__c> getProperty = [SELECT Id FROM Property__c WHERE Name IN ('test部屋番号')];
        List<Account> getAccount = [SELECT Id FROM Account WHERE Name IN ('お気に入り用')];

        //パラメータ設定
        PageReference pageRef = Page.GA104004View;
        pageRef.getParameters().put('Id',getProperty.get(0).Id );
        pageRef.getParameters().put('accountId',getAccount.get(0).Id );
        pageRef.getParameters().put('customerFlg', 'true');
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104004Controller testController = new GA104004Controller();
        // 改行メソッド呼び出し
        // 本文の文字列
        String testStr = null;
        // 距離の文字列
        String distanceStr = 'kyori';
        // 結果の文字列
        String result;

        testStr = 'aiueoaiueoaiueoaiueoaiue'; //24文字
        // 本文の文字列 + 距離の文字列が改行文字数より大きい　かつ　残りの本文の文字数 + 距離の文字数が改行文字数より小さい場合
        result = testController.autoKaigyoAdjustDistance(testStr, distanceStr, 15);
        // 先頭から改行文字数分の本文の文字列 + '<wbr/>' + 残りの本文の文字列 + 距離の文字列 が出力される
        System.assertEquals(testStr.substring(0,15) + '<wbr/>' + testStr.substring(15) + distanceStr, result);

        testStr = 'aiueoaiueoaiueoaiueoaiueo'; //25文字
        // 本文の文字列 + 距離の文字列が改行文字数より大きい　かつ　残りの本文の文字数 + 距離の文字数が改行文字数と同じ場合
        result = testController.autoKaigyoAdjustDistance(testStr, distanceStr, 15);
        // 先頭から改行文字数分の本文の文字列 + '<wbr/>' + 残りの本文の文字列 + 距離の文字列 が出力される
        System.assertEquals(testStr.substring(0,15) + '<wbr/>' + testStr.substring(15) + distanceStr, result);

        testStr = 'aiueoaiueoaiueoaiueoaiueoa'; //26文字
        // 本文の文字列 + 距離の文字列が改行文字数より大きい　かつ　残りの本文の文字数 + 距離の文字数が改行文字数より大きい場合
        result = testController.autoKaigyoAdjustDistance(testStr, distanceStr, 15);
        // 先頭から改行文字数分の本文の文字列 + '<wbr/>' + 残りの本文の文字列 + '<wbr/>' + 距離の文字列 が出力される
        System.assertEquals(testStr.substring(0,15) + '<wbr/>' + testStr.substring(15) + '<wbr/>' + distanceStr, result);
    }

    // マージン計算テスト
    @isTest static void calcMarginTest() {
        List<Property__c> getProperty = [SELECT Id FROM Property__c WHERE Name IN ('test部屋番号')];
        List<Account> getAccount = [SELECT Id FROM Account WHERE Name IN ('お気に入り用')];

        //パラメータ設定
        PageReference pageRef = Page.GA104004View;
        pageRef.getParameters().put('Id',getProperty.get(0).Id );
        pageRef.getParameters().put('accountId',getAccount.get(0).Id );
        pageRef.getParameters().put('customerFlg', 'true');
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA104004Controller testController = new GA104004Controller();
        String testStr = null;

        // 引数がnullの場合
        Integer result = testController.calcMargin(testStr);
        // 55が返る
        System.assertEquals(55, result);

        testStr = 'test';
        // 引数の文字列に<wbr/>が含まれない場合
        result = testController.calcMargin(testStr);
        // 55が返る
        System.assertEquals(55, result);

        testStr = 'test<wbr/>';
        // 引数の文字列に<wbr/>が1つ含まれる場合
        result = testController.calcMargin(testStr);
        // 40が返る
        System.assertEquals(40, result);

        testStr = 'test<wbr/>test<wbr/>';
        // 引数の文字列に<wbr/>が2つ含まれる場合
        result = testController.calcMargin(testStr);
        // 25が返る
        System.assertEquals(25, result);

        testStr = 'test<wbr/>test<wbr/>test<wbr/>';
        // 引数の文字列に<wbr/>が3つ含まれる場合
        result = testController.calcMargin(testStr);
        // 10が返る
        System.assertEquals(10, result);
    }
    // -------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------

    // 登録後の整合性チェック
    private static void checkAfterInsert(GA104004Controller GA104004Controller,
                                            boolean pro, boolean photo, boolean fav,
                                            boolean facCon, boolean facRem, boolean item) {

        // 物件の確認
        if (pro) {
            System.assert(GA104004Controller.propertyTargetRecord <> null);
        } else {
            System.assert(GA104004Controller.propertyTargetRecord == null);
        }
        
        // 物件写真の確認
        if (photo) {
            //System.assert(GA104004Controller.publicPhotoData.photoCount > 0);
        } else {
            //System.assert(GA104004Controller.publicPhotoData.photoCount == null);
        }
        
        // お気に入りフラグの確認
        System.assertEquals(fav, GA104004Controller.hasFavoriteFlg);
        
        // 設備条件の確認
        if (facCon) {
            System.assert(GA104004Controller.facilityConditions <> null);
        } else {
            System.assert(GA104004Controller.facilityConditions == null);
        }
        
        // 設備備考の確認
        if (facRem) {
            System.assert(GA104004Controller.facilityRemarksPublic <> '');
        } else {
            System.assert(GA104004Controller.facilityRemarksPublic == null);
        }
        
        // 物件管理会社指定商品の確認
        if (item) {
            System.assert(GA104004Controller.managementCompanyItem <> '');
        } else {
            System.assert(GA104004Controller.managementCompanyItem == '' || 
                            GA104004Controller.managementCompanyItem == null);
        }
    }
}