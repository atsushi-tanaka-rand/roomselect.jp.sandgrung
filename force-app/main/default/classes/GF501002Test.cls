/* *
* 小中学校登録画面のテストクラス
*/
@isTest
private class GF501002Test {

    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        List<School__c> testSchools = new List<School__c>();
        for(Integer i = 0; i < 5; i++) {
            String schoolType;
            if (i < 2) {
                schoolType = '小学校';
            } else if (i >= 2) {
                schoolType = '中学校';
            }
            testSchools.add(new School__c(Name = '学校名' + i //学校名
                                         , SchoolNameKana__c = 'ガッコウメイ' + i //学校名カナ
                                         , ShoolAbbreviationName__c = '学校名略称' + i //学校名略称
                                         , Type__c = schoolType //種別
                                         , PostalCode__c = '000-000' + i //郵便番号
                                         , State__c = '東京都' //都道府県
                                         , City__c = '芝浦区' //住所１（市区町村）
                                         , Street__c = '１丁目' + i //住所2（町名・番地）
                                         , Phone__c = '0000000000' + i //電話番号
                                         , Latitude__c = 0.000000000000001 + i //緯度
                                         , Longitude__c  = 0.000000000000002 + i //経度
                                        )
                            );
        }
        insert testSchools;
        
        // 小学校に中学校区を追加
        List<Advancement__c> testJuniorHighSchools = new List<Advancement__c>();
        testJuniorHighSchools.add(new Advancement__c(JuniorHighSchool__c = testSchools[2].Id
                                                     , PrimarySchool__c = testSchools[0].Id
                                                    )
                                );
        insert testJuniorHighSchools;

        // 小学校に通学住所を追加
        List<SchoolArea__c> testSchoolAddresses = new List<SchoolArea__c>();
        testSchoolAddresses.add(new SchoolArea__c(State__c = '東京都'
                                                 , City__c = '中央区'
                                                 , Street__c = '２丁目'
                                                 , School__c = testSchools[0].ID
                                                )
                                );
        insert testSchoolAddresses;

        // 中学校に進学元小学校を追加
        List<Advancement__c> testPrimarySchools = new List<Advancement__c>();
        testPrimarySchools.add(new Advancement__c(JuniorHighSchool__c = testSchools[3].Id
                                                 , PrimarySchool__c = testSchools[1].Id
                                                )
                                );
        insert testPrimarySchools;        

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('システム管理者')];
        System.assert(profiles.size() > 0);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            
            insert new User(
                UserName = 'GF501002Test@horaguchi.com',
                Email = 'test@example.com',
                LastName = 'test',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
        }
    }
    
    //初期表示テスト(小学校)
    @isTest static void initializeTest1(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF501002Test@horaguchi.com'];
        system.runas(userRecord){
            School__c testSchool = [SELECT Id FROM School__c WHERE Name = '学校名0'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF501002View;
            pageRef.getParameters().put('Id',testSchool.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF501002Controller testController = new GF501002Controller();
            
            //対応IDがパラメータのIDであること
            system.assertEquals(testController.targetId, testSchool.Id, 'targetIDが誤り');
            
            //学校レコード格納確認
            system.assertEquals(testController.displayTargetRecord.schoolName, '学校名0', 'schoolName');
            system.assertEquals(testController.displayTargetRecord.schoolNameKana, 'ガッコウメイ0', 'schoolNameKana');
            system.assertEquals(testController.displayTargetRecord.schoolAbbreviationName, '学校名略称0', 'schoolAbbreviationName');
            system.assertEquals(testController.displayTargetRecord.type, '小学校', 'type');
            system.assertEquals(testController.displayTargetRecord.postalCode, '000-0000', 'postalCode');
            system.assertEquals(testController.displayTargetRecord.state, '東京都', 'state');
            system.assertEquals(testController.displayTargetRecord.city, '芝浦区', 'city');
            system.assertEquals(testController.displayTargetRecord.street, '１丁目0', 'street');
            system.assertEquals(testController.displayTargetRecord.phone, '00000000000', 'phone');
            system.assertEquals(testController.displayTargetRecord.latitude, 0.000000000000001, 'latitude');
            system.assertEquals(testController.displayTargetRecord.longitude, 0.000000000000002, 'longitude');

            //中学校区確認
            system.assertEquals(testController.targetJuniorHighSchool, '学校名2', 'targetJuniorHighSchool');

            //通学住所確認
            system.assertEquals(testController.targetSchoolAddressList[0].Address__c, '東京都中央区 ２丁目', 'targetJuniorHighSchool');
        }
    }
    
    //初期表示テスト(中学校)
    @isTest static void initializeTest2(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF501002Test@horaguchi.com'];
        system.runas(userRecord){
            School__c testSchool = [SELECT Id FROM School__c WHERE Name = '学校名3'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF501002View;
            pageRef.getParameters().put('Id',testSchool.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF501002Controller testController = new GF501002Controller();
            
            //対応IDがパラメータのIDであること
            system.assertEquals(testController.targetId, testSchool.Id, 'targetIDが誤り');
            
            //学校レコード格納確認
            system.assertEquals(testController.displayTargetRecord.schoolName, '学校名3', 'schoolName');
            system.assertEquals(testController.displayTargetRecord.schoolNameKana, 'ガッコウメイ3', 'schoolNameKana');
            system.assertEquals(testController.displayTargetRecord.schoolAbbreviationName, '学校名略称3', 'schoolAbbreviationName');
            system.assertEquals(testController.displayTargetRecord.type, '中学校', 'type');
            system.assertEquals(testController.displayTargetRecord.postalCode, '000-0003', 'postalCode');
            system.assertEquals(testController.displayTargetRecord.state, '東京都', 'state');
            system.assertEquals(testController.displayTargetRecord.city, '芝浦区', 'city');
            system.assertEquals(testController.displayTargetRecord.street, '１丁目3', 'street');
            system.assertEquals(testController.displayTargetRecord.phone, '00000000003', 'phone');
            system.assertEquals(testController.displayTargetRecord.latitude, 3.000000000000001, 'latitude');
            system.assertEquals(testController.displayTargetRecord.longitude, 3.000000000000002, 'longitude');

            //進学元小学校確認
            system.assertEquals(testController.targetPrimarySchoolList[0].PrimarySchool__r.Name, '学校名1', 'targetPrimarySchoolList');
        }
    } 

    //保存テスト
    @isTest static void saveTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF501002Test@horaguchi.com'];
        system.runas(userRecord){
            School__c testSchool = [SELECT Id, SystemModStamp FROM School__c WHERE Name = '学校名0'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF101002View;
            pageRef.getParameters().put('Id',testSchool.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF501002Controller testController = new GF501002Controller();
            
            //スリープ
            CommonUtil.sleep(1);
            
            //保存処理起動
            testController.saveSchool();
            
            //保存後取引先レコード
            School__c saveSchool = [SELECT Id, SystemModStamp FROM School__c WHERE Name = '学校名0'];
            
            //更新日時確認
            system.assert(testSchool.systemModStamp != saveSchool.systemModStamp, '更新日時が変わっていない');
        }
    }
    
    //初期表示(異常系)
    @isTest static void initializeNotFindIdErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF501002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GF501002View;
            pageRef.getParameters().put('Id', '0060T0000023JEAQA2' );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF501002Controller testController = new GF501002Controller();
            
            //レコード情報が取得できないときのエラー
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)), messages[0]);
        }
    }
    
    
    //保存(異常系)
    @isTest static void optimisticLockSaveErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF501002Test@horaguchi.com'];
        system.runas(userRecord){
            School__c testSchool = [SELECT Id, SystemModStamp FROM School__c WHERE Name = '学校名0'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF501002View;
            pageRef.getParameters().put('Id',testSchool.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF501002Controller testController = new GF501002Controller();
            
            //スリープ
            CommonUtil.sleep(1);
            
            //保存前に更新
            testSchool.Name = 'koushin';
            update testSchool;
            
            //スリープ
            CommonUtil.sleep(1);
            
            //保存処理起動
            testController.saveSchool();
            
            //楽観ロックチェックエラー
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)), messages[0]);
        }
    }
    
    //カバレッジ率向上用（テスト仕様書はなし）
    @isTest static void callTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF501002Test@horaguchi.com'];
        system.runas(userRecord){
            School__c testSchool = [SELECT Id FROM School__c WHERE Name = '学校名0'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF501002View;
            pageRef.getParameters().put('Id',testSchool.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF501002Controller testController = new GF501002Controller();

            //保存ボタン押下処理(入力エラーパターン)
            testController.saveSchool();

            //写真アップロード呼び出し
            testController.updateSchoolPhoto();

            //モーダル起動呼び出し
            testController.GA102006FormOpen();
            
            //モーダル終了呼び出し
            testController.GA102006FormClose();

        }
    }

    // モザイク処理の実施設定値確認
    @isTest static void isMosaicTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF501002Test@horaguchi.com'];
        system.runas(userRecord){
            School__c testSchool = [SELECT Id FROM School__c WHERE Name = '学校名0'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF501002View;
            pageRef.getParameters().put('Id',testSchool.Id );
            Test.setCurrentPage(pageRef);
            
            Test.startTest();
            //パラメータありでコンストラクタ起動
            GF501002Controller testController = new GF501002Controller();
            // 初期表示時はモザイクラジオボタンがfalse
            System.assertEquals(testController.selectIsMosaic, 'false');
            // パラメータクラスも同じ値が設定されていることを確認
            System.assertEquals(testController.schoolPhotoData.GD901001Parameter.isMosaic, Boolean.valueOf(testController.selectIsMosaic));
            // モザイクラジオボタンをtrueに変更
            testController.selectIsMosaic = 'true';
            //写真アップロード呼び出し
            testController.updateSchoolPhoto();
            // パラメータクラスも同じ値が設定されていることを確認
            System.assertEquals(testController.schoolPhotoData.GD901001Parameter.isMosaic, Boolean.valueOf(testController.selectIsMosaic));
            Test.stopTest();
        }
    } 
    
}