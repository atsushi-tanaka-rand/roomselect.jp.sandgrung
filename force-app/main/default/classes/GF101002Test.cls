/* *
* 保証会社登録画面のテストクラス
*/
@isTest
private class GF101002Test {
    
    //レコードタイプID取得
    static ID testAccountRecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_GUARANTEE);
    static ID testItemRecordTypeId = CommonUtil.getRecordTypeId('Item__c', CommonConst.ITEM_RECTYPE_GUARANTEE_PLAN);
    
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
             
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(Name = '保証会社名' + i               //保証会社名
                                         , PostalCode__c = '000-000' + i         //郵便番号
                                         , State__c = '大阪府'                   //都道府県
                                         , City__c = '大阪市中央区'              //市区町村
                                         , Street__c = '1丁目' + i               //丁目・番地
                                         , Phone = '0000000000' + i              //電話番号
                                         , Fax = '0000000000' + i                //FAX
                                         , Email__c = 'sample@example.com'       //メールアドレス
                                         , isAllRentFeeType__c = TRUE            //総賃料区分
                                         , RemarksPublic__c = '備考備考備考' + i  //備考（公開）
                                         , RecordTypeId = testAccountRecordTypeId    //レコードタイプ
                                        )
                            );
        }
        insert testAccounts;
        
        //『保証会社名0』に商品レコード追加
        List<Item__c> testItems = new List<Item__c>();
        for(Integer i = 0; i < 3; i++){
            testItems.add(new Item__c( ItemName__c = '保証会社0用No.' + i         //保証プラン名
                                      , AssuranceContent__c = '内容：' + i         //保証プラン内容
                                      , Remarks__c = '保証内容備考備考備考' + i     //保証内容備考
                                      , Account__c = testAccounts[0].Id            //レコードID（取引先）
                                      , RecordTypeId = testItemRecordTypeId        //レコードタイプ
                                     ) 
                         );
        }
        insert testItems;
        
        //『保証会社名0～3』に対応レコード追加
        List<Correspond__c> testCorresponds = new List<Correspond__c>();
        for(Integer i = 0; i < 4; i++){
            testCorresponds.add(new Correspond__c( AccountId__c = testAccounts[i].Id            //レコードID（取引先）
                                                 )
                               );
        }
        insert testCorresponds;
        
        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = 'テス店舗',
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

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('システム管理者')];
        System.assert(profiles.size() > 0);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert new User(
                UserName = 'GF101002Test@horaguchi.com',
                Email = 'test@example.com',
                LastName = 'test',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
        }
        //店舗異動レコード
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF101002Test@horaguchi.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = userRecord.id,
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
        insert ShopTransferRecord;
    }
    
    //初期表示テスト(パラメータなし)
    @isTest static void newInitializeTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF101002Test@horaguchi.com'];
        system.runas(userRecord){
            GF101002Controller testController = new GF101002Controller();
            
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
            system.assertEquals(testController.screenTargetRecord.isAllRentFeeType, 'false', 'isAllRentFeeType');
            system.assert(String.isBlank(testController.screenTargetRecord.remarksPublic), 'remarksPublic');
        }
    }
    
    //初期表示テスト(パラメータあり)
    @isTest static void initializeTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF101002Test@horaguchi.com'];
        system.runas(userRecord){
            Account testAccout = [SELECT Id FROM Account WHERE Name = '保証会社名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF101002Controller testController = new GF101002Controller();
            
            //対応IDがパラメータのIDであること
            system.assertEquals(testController.targetId, testAccout.Id, 'targetIDが誤り');
            
            //取引先レコードタイプID、商品レコードタイプIDが保証会社であること
            system.assertEquals(testController.targetAccountRecordTypeId, testAccountRecordTypeId, '取引先レコードタイプIDが誤り');
            
            //新規フラグがTRUEであること
            system.assertEquals(testController.isNew, False, 'isNewがfalseではない');
            
            //取引先レコード格納確認
            system.assertEquals(testController.screenTargetRecord.name, '保証会社名0', 'name');
            system.assertEquals(testController.screenTargetRecord.titleName, '保証会社名0', 'titleName');
            system.assertEquals(testController.screenTargetRecord.planCount, 3, 'planCount');
            system.assertEquals(testController.screenTargetRecord.postalCode, '000-0000', 'postalCode');
            system.assertEquals(testController.screenTargetRecord.state, '大阪府', 'state');
            system.assertEquals(testController.screenTargetRecord.city, '大阪市中央区', 'city');
            system.assertEquals(testController.screenTargetRecord.street, '1丁目0', 'street');
            system.assertEquals(testController.screenTargetRecord.phone, '00000000000', 'phone');
            system.assertEquals(testController.screenTargetRecord.fax, '00000000000', 'fax');
            system.assertEquals(testController.screenTargetRecord.email, 'sample@example.com', 'email');
            system.assertEquals(testController.screenTargetRecord.isAllRentFeeType, 'true', 'isAllRentFeeType');
            system.assertEquals(testController.screenTargetRecord.remarksPublic, '備考備考備考0', 'remarksPublic');
            
            //商品レコード格納確認
            Integer i = 0;
            for ( Item__c   item : testController.targetItemRecordList ){
                
                system.assertEquals(item.ItemName__c, '保証会社0用No.' + i, '保証プラン名');
                system.assertEquals(item.AssuranceContent__c, '内容：' + i, '保証プラン内容');
                system.assertEquals(item.Remarks__c, '保証内容備考備考備考' + i, '保証内容備考');
                i++ ;
            }
            
            //対応レコード格納確認
            system.assertEquals(testController.targetCorrespondRecord.Id, testCorrespond.Id, '対応レコードId');
        }
    }
    
    
    //保存テスト
    @isTest static void saveTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF101002Test@horaguchi.com'];
        system.runas(userRecord){
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '保証会社名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF101002Controller testController = new GF101002Controller();
            
            //スリープ
            CommonUtil.sleep(1);
            
            //保存処理起動
            testController.TargetRecordSave();
            
            //保存後取引先レコード
            Account saveAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '保証会社名0'];
            
            //更新日時確認
            system.assert(testAccout.systemModStamp != saveAccout.systemModStamp, '更新日時が変わっていない');
        }
    }
    
    //削除テスト
    @isTest static void deleteTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF101002Test@horaguchi.com'];
        system.runas(userRecord){
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '保証会社名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF101002Controller testController = new GF101002Controller();
            
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF101002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータ設定
            PageReference pageRef = Page.GF101002View;
            pageRef.getParameters().put('Id', '0060T0000023JEAQA2' );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF101002Controller testController = new GF101002Controller();
            
            //レコード情報が取得できないときのエラー出てる？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)), messages[0]);
        }
    }
    
    
    //保存(異常系)
    @isTest static void optimisticLockSaveErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF101002Test@horaguchi.com'];
        system.runas(userRecord){
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '保証会社名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF101002Controller testController = new GF101002Controller();
            
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF101002Test@horaguchi.com'];
        system.runas(userRecord){
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '保証会社名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF101002Controller testController = new GF101002Controller();
            
            //削除前に削除
            delete testAccout;
            
            //削除処理起動
            testController.TargetRecordDelete();
            
            //削除レコードが取得できないときのエラー出てる？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            system.assertEquals(ApexPages.getMessages()[0].getDetail(),CommonConst.MSG_COM_E_NOTICE_DELETED);
        }
    }
    
    
    //新規(異常系)
    @isTest static void newChangeItemErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF101002Test@horaguchi.com'];
        system.runas(userRecord){
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '保証会社名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF101002View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF101002Controller testController = new GF101002Controller();
            
            //内部クラスを一部変更
            testController.screenTargetRecord.name = 'henkou';
            
            //新規処理起動
            testController.NewItemCreate();
            
            //画面に変更があるエラー出てる？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_NOTICE_SAVE, '保存')), messages[0]);
        }
    }
    
    
    //カバレッジ率向上用（テスト仕様書はなし）
    @isTest static void callTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF101002Test@horaguchi.com'];
        system.runas(userRecord){
            //パラメータなしでコンストラクタ起動
            GF101002Controller testController = new GF101002Controller();
            
            //モーダル起動呼び出し
            testController.openModal();
            
            //モーダル終了呼び出し
            testController.closeModal();
            
            //総賃料区分ラジオボタン（VFオプション）呼び出し
            testController.getIsAllRentFeeTypeRadioButton();
        }
    }
    
}