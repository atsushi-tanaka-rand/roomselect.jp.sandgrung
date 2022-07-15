/* *
* 病院登録画面のテストクラス
*/
@isTest
private class GF701002Test {

    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        List<Hospital__c> testHospotals = new List<Hospital__c>();
        for(Integer i = 0; i < 5; i++) {
            testHospotals.add(new Hospital__c(Name = '病院名' + i               //病院名
                                             , PostalCode__c = '000-000' + i         //郵便番号
                                             , State__c = '東京都'                   //都道府県
                                             , City__c = '芝浦区'              //住所１（市区町村）
                                             , Street__c = '1丁目' + i               //住所2（町名・番地）
                                             , Phone__c = '0000000000' + i              //電話番号
                                             , SickbedCount__c = i
                                             , Latitude__c = 0.000000000000001 + i //緯度
                                             , Longitude__c  = 0.000000000000002 + i //経度
                                             , ClinicalDepartment__c = '診療科目' + i //診療科目
                                             , Remarks__c = '備考' + i //備考
                                            )
                                );
        }
        insert testHospotals;

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('システム管理者')];
        System.assert(profiles.size() > 0);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            
            insert new User(
                UserName = 'GF701002Test@horaguchi.com',
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

    //初期表示テスト(新規登録)
    @isTest static void newInitializeTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF701002Test@horaguchi.com'];
        system.runas(userRecord){
            GF701002Controller testController = new GF701002Controller();
            
            system.assert(String.isBlank(testController.targetId), 'targetIDが空ではない');
            system.assertEquals(testController.isNew, True, 'isNewがtrueではない');
            system.assert(String.isBlank(testController.displayTargetRecord.hospitalName), 'hospitalName');
            system.assert(String.isBlank(testController.displayTargetRecord.postalCode), 'postalCode');
            system.assert(String.isBlank(testController.displayTargetRecord.state), 'state');
            system.assert(String.isBlank(testController.displayTargetRecord.city), 'city');
            system.assert(String.isBlank(testController.displayTargetRecord.street), 'street');
            system.assert(String.isBlank(testController.displayTargetRecord.phone), 'phone');
            system.assertEquals(testController.displayTargetRecord.latitude, null, 'latitude');
            system.assertEquals(testController.displayTargetRecord.longitude, null, 'longitude');
            system.assert(String.isBlank(testController.displayTargetRecord.clinicalDepartment), 'clinicalDepartment');
            system.assert(String.isBlank(testController.displayTargetRecord.remarks), 'remarks');
        }        
    } 

    //初期表示(既登録)テスト
    @isTest static void initializeTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF701002Test@horaguchi.com'];
        system.runas(userRecord){
            Hospital__c testHospital = [SELECT Id FROM Hospital__c WHERE Name = '病院名0'];
 
            //パラメータ設定
            PageReference pageRef = Page.GF701002View;
            pageRef.getParameters().put('Id',testHospital.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF701002Controller testController = new GF701002Controller();
            
            //対応IDがパラメータのIDであること
            system.assertEquals(testController.targetId, testHospital.Id, 'targetIDが誤り');
            
            //新規フラグがfalseであること
            system.assertEquals(testController.isNew, False, 'isNewがfalseではない');
            
            //病院レコード格納確認
            system.assertEquals(testController.displayTargetRecord.hospitalName, '病院名0', 'hospitalName');
            system.assertEquals(testController.displayTargetRecord.postalCode, '000-0000', 'postalCode');
            system.assertEquals(testController.displayTargetRecord.state, '東京都', 'state');
            system.assertEquals(testController.displayTargetRecord.city, '芝浦区', 'city');
            system.assertEquals(testController.displayTargetRecord.street, '1丁目0', 'street');
            system.assertEquals(testController.displayTargetRecord.phone, '00000000000', 'phone');
            system.assertEquals(testController.displayTargetRecord.latitude, 0.000000000000001, 'latitude');
            system.assertEquals(testController.displayTargetRecord.longitude, 0.000000000000002, 'longitude');
            system.assertEquals(testController.displayTargetRecord.clinicalDepartment, '診療科目0', 'clinicalDepartment');
            system.assertEquals(testController.displayTargetRecord.remarks, '備考0', 'remarks');

        }        
    }

    //保存テスト
    @isTest static void saveTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF701002Test@horaguchi.com'];
        system.runas(userRecord){
            Hospital__c testHospital = [SELECT Id, SystemModStamp FROM Hospital__c WHERE Name = '病院名0'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF701002View;
            pageRef.getParameters().put('Id',testHospital.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF701002Controller testController = new GF701002Controller();
            
            //スリープ
            CommonUtil.sleep(1);
            
            //保存処理起動
            testController.saveHospital();
            
            //保存後取引先レコード
            Hospital__c saveHospital = [SELECT Id, SystemModStamp FROM Hospital__c WHERE Name = '病院名0'];
            
            //更新日時確認
            system.assert(testHospital.systemModStamp != saveHospital.systemModStamp, '更新日時が変わっていない');
        }        
    }

    //削除テスト
    @isTest static void deleteTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF701002Test@horaguchi.com'];
        system.runas(userRecord){
            Hospital__c testHospital = [SELECT Id, SystemModStamp FROM Hospital__c WHERE Name = '病院名0'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF701002View;
            pageRef.getParameters().put('Id',testHospital.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF701002Controller testController = new GF701002Controller();
            
            //削除処理起動
            testController.deleteHospital();
            
            //各レコード再取得
            List<Hospital__c> testHospital2 = [SELECT Id FROM Hospital__c WHERE Id = :testHospital.Id];
            
            //レコードが取得できていないことを確認
            system.assert(testHospital2.isEmpty(), '削除できてない');
        }
    }

    //初期表示(異常系)
    @isTest static void initializeNotFindIdErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF701002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GF701002View;
            pageRef.getParameters().put('Id', '0060T0000023JEAQA2' );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF701002Controller testController = new GF701002Controller();
            
            //レコード情報が取得できないときのエラー出てる？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)), messages[0]);
        }
    }
    
    
    //保存(異常系)
    @isTest static void optimisticLockSaveErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF701002Test@horaguchi.com'];
        system.runas(userRecord){
            Hospital__c testHospital = [SELECT Id, SystemModStamp FROM Hospital__c WHERE Name = '病院名0'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF701002View;
            pageRef.getParameters().put('Id',testHospital.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF701002Controller testController = new GF701002Controller();
            
            //スリープ
            CommonUtil.sleep(1);
            
            //保存前に更新
            testHospital.Name = 'koushin';
            update testHospital;
            
            //スリープ
            CommonUtil.sleep(1);
            
            //保存処理起動
            testController.saveHospital();
            
            //楽観ロックチェックエラー
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)), messages[0]);
        }
    }

    //削除(異常系)
    @IsTest static void deletedDeleteErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF701002Test@horaguchi.com'];
        system.runas(userRecord){
            Hospital__c testHospital = [SELECT Id, SystemModStamp FROM Hospital__c WHERE Name = '病院名0'];

            //パラメータ設定
            PageReference pageRef = Page.GF701002View;
            pageRef.getParameters().put('Id',testHospital.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF701002Controller testController = new GF701002Controller();
            
            //削除前に削除
            delete testHospital;
            
            //削除処理起動
            testController.deleteHospital();
            
            //削除レコードが取得できないときのエラー
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(ApexPages.getMessages()[0].getDetail(),CommonConst.MSG_COM_E_NOTICE_DELETED);
        }        
    }

    //カバレッジ率向上用（テスト仕様書はなし）
    @isTest static void callTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF701002Test@horaguchi.com'];
        system.runas(userRecord){
            Hospital__c testHospital = [SELECT Id FROM Hospital__c WHERE Name = '病院名0'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF701002View;
            pageRef.getParameters().put('Id',testHospital.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF701002Controller testController = new GF701002Controller();

            //保存ボタン押下処理(入力エラーパターン)
            testController.displayTargetRecord.hospitalName = '';
            testController.displayTargetRecord.latitude = 0;
            testController.displayTargetRecord.longitude = 0;
            testController.saveHospital();

            //写真アップロード呼び出し
            testController.updateHospitalPhoto();

            //モーダル起動呼び出し
            testController.GA102006FormOpen();
            
            //モーダル終了呼び出し
            testController.GA102006FormClose();

        }
    }

    // モザイク処理の実施設定値確認
    @isTest static void isMosaicTest() {
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF701002Test@horaguchi.com'];
        system.runas(userRecord){
            Hospital__c testHospital = [SELECT Id FROM Hospital__c WHERE Name = '病院名0'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF701002View;
            pageRef.getParameters().put('Id',testHospital.Id );
            Test.setCurrentPage(pageRef);
            Test.startTest();
            //パラメータありでコンストラクタ起動
            GF701002Controller testController = new GF701002Controller();
            // 初期表示時はモザイクラジオボタンがfalse
            System.assertEquals(testController.selectIsMosaic, 'false');
            // パラメータクラスも同じ値が設定されていることを確認
            System.assertEquals(testController.hospitalPhotoData.GD901001Parameter.isMosaic, Boolean.valueOf(testController.selectIsMosaic));
            // モザイクラジオボタンをtrueに変更
            testController.selectIsMosaic = 'true';
            //写真アップロード呼び出し
            testController.updateHospitalPhoto();
            // パラメータクラスも同じ値が設定されていることを確認
            System.assertEquals(testController.hospitalPhotoData.GD901001Parameter.isMosaic, Boolean.valueOf(testController.selectIsMosaic));
            Test.stopTest();

        }
    }
}