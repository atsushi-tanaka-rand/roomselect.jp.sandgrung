/* *
* 火災保険会社登録画面のテストクラス
*/
@isTest
private class GF801002Test {

    //レコードタイプID取得
    static ID testAccountRecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_FIRE_INSURANCE);
    static ID testItemRecordTypeId = CommonUtil.getRecordTypeId('Item__c', CommonConst.ITEM_RECTYPE_FIRE_INSURANCE);

    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(Name = '火災保険会社名' + i //火災保険会社
                                        , PostalCode__c = '000-000' + i //郵便番号
                                        , State__c = '東京都' //都道府県
                                        , City__c = '芝浦区' //住所１（市区町村）
                                        , Street__c = '1丁目' + i //住所2（町名・番地）
                                        , Phone = '0000000000' + i //電話番号
                                        , Fax = '0000000000' + i //FAX
                                        , Email__c = 'sample@example.com' //メールアドレス
                                        , RemarksPublic__c = '備考' + i //備考（公開）
                                        , RecordTypeId = testAccountRecordTypeId //レコードタイプ
                                        )
                            );
        }
        insert testAccounts;

        //『火災保険会社名0』に商品レコード追加
        List<Item__c> testItems = new List<Item__c>();
        for(Integer i = 0; i < 3; i++){
            testItems.add(new Item__c(ItemName__c = '火災保険会社0用No.' + i //火災保険プラン名
                                    , FireInsuranceYear__c = 10000 + i //火災保険料(年額)
                                    , FireInsuranceMonth__c = 20000 + i //火災保険料(月額)
                                    , TenantCompensation__c = 30000 + i //借家人賠償額
                                    , HouseGoodsDeposit__c = 40000 + i //家財保証額
                                    , PaymentType__c = CommonConst.ITEM_PAYMENTTYPE_YEAR //更新期間
                                    , PaymentYear__c = 1 + i //更新年数
                                    , IsAuxiliary__c = true //付帯商品区分
                                    , InsuranceFeeRate__c = 10 + i //保険料割合（火災保険）
                                    , FireInsurance__c = '保険内容' + i //保険内容
                                    , Account__c = testAccounts[0].Id //レコードID（取引先）
                                    , RecordTypeId = testItemRecordTypeId //レコードタイプ
                                    )
                            );
        }
        insert testItems;

        //『火災保険会社名0～3』に対応レコード追加
        List<Correspond__c> testCorresponds = new List<Correspond__c>();
        for(Integer i = 0; i < 4; i++){
            testCorresponds.add(new Correspond__c( AccountId__c = testAccounts[i].Id )
                               );
        }
        insert testCorresponds;

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('システム管理者')];
        System.assert(profiles.size() > 0);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            
            insert new User(
                UserName = 'GF801002Test@horaguchi.com',
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF801002Test@horaguchi.com'];
        system.runas(userRecord){
            GF801002Controller testController = new GF801002Controller();
            
            system.assert(String.isBlank(testController.targetId), 'targetIDが空ではない');
            system.assertEquals(testController.targetAccountRecordTypeId, testAccountRecordTypeId, '取引先レコードタイプIDが誤り');
            system.assertEquals(testController.isNew, True, 'isNewがtrueではない');
            system.assert(String.isBlank(testController.screenTargetRecord.name), 'name');
            system.assert(String.isBlank(testController.screenTargetRecord.titleName), 'titleName');
            system.assertEquals(testController.screenTargetRecord.planCount, null, 'planCount');
            system.assert(String.isBlank(testController.screenTargetRecord.postalCode), 'postalCode');
            system.assert(String.isBlank(testController.screenTargetRecord.state), 'state');
            system.assert(String.isBlank(testController.screenTargetRecord.city), 'city');
            system.assert(String.isBlank(testController.screenTargetRecord.street), 'street');
            system.assert(String.isBlank(testController.screenTargetRecord.phone), 'phone');
            system.assert(String.isBlank(testController.screenTargetRecord.fax), 'fax');
            system.assert(String.isBlank(testController.screenTargetRecord.email), 'email');
            system.assert(String.isBlank(testController.screenTargetRecord.remarksPublic), 'remarksPublic');
        }        
    } 

    //初期表示(既登録)テスト
    @isTest static void initializeTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF801002Test@horaguchi.com'];
        system.runas(userRecord){
            Account testAccout = [SELECT Id FROM Account WHERE Name = '火災保険会社名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF801002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF801002Controller testController = new GF801002Controller();
            
            //対応IDがパラメータのIDであること
            system.assertEquals(testController.targetId, testAccout.Id, 'targetIDが誤り');
            
            //取引先レコードタイプID、商品レコードタイプIDが火災保険会社であること
            system.assertEquals(testController.targetAccountRecordTypeId, testAccountRecordTypeId, '取引先レコードタイプIDが誤り');
            
            //新規フラグがTRUEであること
            system.assertEquals(testController.isNew, False, 'isNewがfalseではない');
            
            //取引先レコード格納確認
            system.assertEquals(testController.screenTargetRecord.name, '火災保険会社名0', 'name');
            system.assertEquals(testController.screenTargetRecord.titleName, '火災保険会社名0', 'titleName');
            system.assertEquals(testController.screenTargetRecord.planCount, 3, 'planCount');
            system.assertEquals(testController.screenTargetRecord.postalCode, '000-0000', 'postalCode');
            system.assertEquals(testController.screenTargetRecord.state, '東京都', 'state');
            system.assertEquals(testController.screenTargetRecord.city, '芝浦区', 'city');
            system.assertEquals(testController.screenTargetRecord.street, '1丁目0', 'street');
            system.assertEquals(testController.screenTargetRecord.phone, '00000000000', 'phone');
            system.assertEquals(testController.screenTargetRecord.fax, '00000000000', 'fax');
            system.assertEquals(testController.screenTargetRecord.email, 'sample@example.com', 'email');
            system.assertEquals(testController.screenTargetRecord.remarksPublic, '備考0', 'remarksPublic');
            
            //商品レコード格納確認
            Integer i = 0;
            for ( GF801002Controller.screenItem   item : testController.screenItemList ){
                
                system.assertEquals(item.itemRecord.ItemName__c, '火災保険会社0用No.' + i, '火災保険プラン名');
                system.assertEquals(item.itemRecord.FireInsuranceYear__c, 10000 + i, '火災保険料(年額)');
                system.assertEquals(item.itemRecord.FireInsuranceMonth__c, 20000 + i, '火災保険料(月額)');
                system.assertEquals(item.itemRecord.TenantCompensation__c, 30000 + i, '借家人賠償額');
                system.assertEquals(item.itemRecord.HouseGoodsDeposit__c, 40000 + i, '家財保証額');
                system.assertEquals(item.itemRecord.PaymentType__c, CommonConst.ITEM_PAYMENTTYPE_YEAR, '更新期間');
                system.assertEquals(item.itemRecord.PaymentYear__c, 1 + i, '更新年数');
                system.assertEquals(item.itemRecord.IsAuxiliary__c, True, '付帯商品区分');
                system.assertEquals(item.itemRecord.InsuranceFeeRate__c, 10 + i, '保険料割合（火災保険）');
                system.assertEquals(item.itemRecord.FireInsurance__c, '保険内容' + i, '保険内容');
                i++ ;
            }
            
            //対応レコード格納確認
            system.assertEquals(testController.targetCorrespondRecord.Id, testCorrespond.Id, '対応レコードId');
        }
    }

    //保存テスト
    @isTest static void saveTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF801002Test@horaguchi.com'];
        system.runas(userRecord){
            Account testAccount = [SELECT Id, SystemModStamp FROM Account WHERE Name = '火災保険会社名0'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF701002View;
            pageRef.getParameters().put('Id',testAccount.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF801002Controller testController = new GF801002Controller();
            
            //スリープ
            CommonUtil.sleep(1);
            
            //保存処理起動
            testController.TargetRecordSave();
            
            //保存後取引先レコード
            Account saveAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '火災保険会社名0'];
            
            //更新日時確認
            system.assert(testAccount.systemModStamp != saveAccout.systemModStamp, '更新日時が変わっていない');
        }        
    }

    //削除テスト
    @isTest static void deleteTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF801002Test@horaguchi.com'];
        system.runas(userRecord){
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '火災保険会社名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF801002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF801002Controller testController = new GF801002Controller();
            
            //削除処理起動
            testController.TargetRecordDelete();
            
            //各レコード再取得
            List<Account> testAccout2 = [SELECT Id FROM Account WHERE Id = :testAccout.Id];
            List<Item__c> testItem = [SELECT ItemName__c FROM Item__c WHERE Account__c = :testAccout.Id];
            List<Correspond__c> testCorrespond2 = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //レコードが取得できていないことを確認
            system.assert(testAccout2.isEmpty(), '削除できてない');
            system.assert(testItem.isEmpty(), '削除できてない');
            system.assert(testCorrespond2.isEmpty(), '削除できてない');
        }
    }

    //初期表示(異常系)
    @isTest static void initializeNotFindIdErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF801002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GF801002View;
            pageRef.getParameters().put('Id', '0060T0000023JEAQA2' );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF801002Controller testController = new GF801002Controller();
            
            //レコード情報が取得できないときのエラー出てる？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)), messages[0]);
        }
    }

    //保存(異常系)
    @isTest static void optimisticLockSaveErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF801002Test@horaguchi.com'];
        system.runas(userRecord){
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '火災保険会社名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF801002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF801002Controller testController = new GF801002Controller();
            
            //スリープ
            CommonUtil.sleep(1);
            
            //保存前に更新
            testAccout.Name = 'koushin';
            update testAccout;
            
            //スリープ
            CommonUtil.sleep(1);
            
            //保存処理起動
            testController.TargetRecordSave();
            
            //楽観ロックチェックエラー？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)), messages[0]);
        }
    }
    
    
    //削除(異常系)
    @isTest static void deletedDeleteErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF801002Test@horaguchi.com'];
        system.runas(userRecord){
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '火災保険会社名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF801002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF801002Controller testController = new GF801002Controller();
            
            //削除前に削除
            delete testAccout;
            
            //削除処理起動
            testController.TargetRecordDelete();
            
            //削除レコードが取得できないときのエラー出てる？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            system.assertEquals(ApexPages.getMessages()[0].getDetail(),CommonConst.MSG_COM_E_NOTICE_DELETED);
        }
    }

    //カバレッジ率向上用（テスト仕様書はなし）
    @isTest static void callTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF801002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータなしでコンストラクタ起動
            GF801002Controller NoController = new GF801002Controller();

            //項目を入力せずに保存
            NoController.screenTargetRecord.name = '';
            NoController.screenTargetRecord.postalCode = '';
            NoController.screenTargetRecord.state = '';
            NoController.screenTargetRecord.city = '';
            NoController.screenTargetRecord.street = '';
            NoController.screenTargetRecord.phone = '';
            NoController.TargetRecordSave();

            //新規で保存
            NoController.screenTargetRecord.name = '火災保険会社0';
            NoController.screenTargetRecord.postalCode = '00000000';
            NoController.screenTargetRecord.state = '東京都';
            NoController.screenTargetRecord.city = '芝浦区';
            NoController.screenTargetRecord.street = '0番地';
            NoController.screenTargetRecord.phone = '0000000';
            NoController.TargetRecordSave();

            //パラメータ設定
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '火災保険会社名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];            
            PageReference pageRef = Page.GF801002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF801002Controller testController = new GF801002Controller();

            //郵便番号モーダル起動呼び出し
            testController.openModal();

            //郵便番号モーダル終了呼び出し
            testController.closeModal(); 

            //火災保険プラン登録モーダル起動呼び出し（新規）
            testController.openModalCreateItem();

            //火災保険プラン登録モーダル起動呼び出し（編集）
            testController.selectedIndex = 0;
            testController.openModalUpdateItem();

            //火災保険プラン登録モーダル終了呼び出し
            testController.closeNewModal();

            //商品削除ボタン押下
            testController.screenItemList[0].isItemCheck = true;
            testController.targetItemRecordDelete();

            //メッセージ取得
            String testMessage1 = testController.MSG_COM_V_SAVE;
            String testMessage2 = testController.MSG_COM_I_SAVE;
            String testMessage3 = testController.MSG_COM_V_DELETE;
            String testMessage4 = testController.MSG_COM_I_DELETE;
        }
    }
}