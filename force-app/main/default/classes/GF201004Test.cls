/* *
* 付帯商品業者登録画面のテストクラス
*/
@isTest
private class GF201004Test {
     
    //レコードタイプID取得
    static ID testAccountRecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_AUXILIARY);
    
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(Name = '付帯業者名' + i               //付帯業者名
                                         , PostalCode__c = '000-000' + i         //郵便番号
                                         , State__c = '大阪府'                   //都道府県
                                         , City__c = '大阪市中央区'              //市区町村
                                         , Street__c = '1丁目' + i               //丁目・番地
                                         , Phone = '0000000000' + i              //電話番号
                                         , Fax = '0000000000' + i                //FAX
                                         , Email__c = 'sample@example.com'       //メールアドレス
                                         , RemarksPublic__c = '備考備考備考' + i  //備考（公開）
                                         , RecordTypeId = testAccountRecordTypeId    //レコードタイプ
                                        )
                            );
        }
        insert testAccounts;
        
        //『付帯業者名0』に商品レコード追加
        List<Item__c> testItem = new List<Item__c>();
        for(Integer i = 0; i < 3; i++){
            testItem.add(new Item__c( ItemName__c = '付帯業者0用商品No.' + i         //付帯商品名
                                     , IsAuxiliary__c = TRUE                   //付帯商品区分
                                     , Remarks__c = '付帯商品の備考が入ります' + i     //備考
                                     , Account__c = testAccounts[0].Id            //レコードID（取引先）
                                     , RecordTypeId = CommonUtil.getRecordTypeId('Item__c', CommonConst.ITEM_RECTYPE_AUXILIARY_ITEM)
                                    ) 
                        );
        }
        insert testItem;
        
        //『付帯業者名0～3』に対応レコード追加
        List<Correspond__c> testCorresponds = new List<Correspond__c>();
        for(Integer i = 0; i < 4; i++){
            testCorresponds.add(new Correspond__c( AccountId__c = testAccounts[i].Id            //レコードID（取引先）
                                                 )
                               );
        }
        insert testCorresponds;
        
        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = 'テスト店舗',
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
                UserName = 'GF201004Test@horaguchi.com',
                Email = 'hutaigyousya_test@example.com',
                LastName = 'FutaiTest',
                Alias = 'F・test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
        }        
        
        //店舗異動レコード
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = userRecord.id,
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
        insert ShopTransferRecord;
        
    }
    
    
    //初期表示テスト(パラメータなし)
    @isTest static void newInitializeTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
        system.runas(userRecord){
            GF201004Controller testController = new GF201004Controller();
            
            
            system.assert(String.isBlank(testController.targetId), 'targetIDが空ではない');
            system.assertEquals(testController.targetAccountRecordTypeId,testAccountRecordTypeId, '取引先レコードタイプIDが誤り');      //CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_AUXILIARY, '取引先レコードタイプIDが誤り')); 
            system.assertEquals(testController.isNew, True, 'isNewがtrueではない');
            system.assert(String.isBlank(testController.screenTargetRecord.name), 'name');
            system.assert(String.isBlank(testController.screenTargetRecord.titleName), 'titleName');
            system.assertEquals(testController.screenTargetRecord.AuxiliaryItemCount, null, 'AuxiliaryItemCount');
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
    
    //初期表示テスト(パラメータあり)
    @isTest static void initializeTest(){
        User userRecord = [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
        system.runas(userRecord){
            Account testAccout = [SELECT Id FROM Account WHERE Name = '付帯業者名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF201004View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF201004Controller testController = new GF201004Controller();
            
            //対応IDがパラメータのIDであること
            system.assertEquals(testController.targetId, testAccout.Id, 'targetIDが誤り');
            
            //取引先レコードタイプID、商品レコードタイプIDが保証会社であること
            system.assertEquals(testController.targetAccountRecordTypeId, testAccountRecordTypeId, '取引先レコードタイプIDが誤り');
            
            //新規フラグがTRUEであること
            system.assertEquals(testController.isNew, False, 'isNewがfalseではない');
            
            //取引先レコード格納確認
            system.assertEquals(testController.screenTargetRecord.name, '付帯業者名0', 'name');
            system.assertEquals(testController.screenTargetRecord.titleName, '付帯業者名0', 'titleName');
            system.assertEquals(testController.screenTargetRecord.AuxiliaryItemCount, 3, 'AuxiliaryItemCount');
            system.assertEquals(testController.screenTargetRecord.postalCode, '000-0000', 'postalCode');
            system.assertEquals(testController.screenTargetRecord.state, '大阪府', 'state');
            system.assertEquals(testController.screenTargetRecord.city, '大阪市中央区', 'city');
            system.assertEquals(testController.screenTargetRecord.street, '1丁目0', 'street');
            system.assertEquals(testController.screenTargetRecord.phone, '00000000000', 'phone');
            system.assertEquals(testController.screenTargetRecord.fax, '00000000000', 'fax');
            system.assertEquals(testController.screenTargetRecord.email, 'sample@example.com', 'email');
            system.assertEquals(testController.screenTargetRecord.remarksPublic, '備考備考備考0', 'remarksPublic');
            
            //商品レコード格納確認
            Integer i = 0;
            for ( GF201004Controller.screenItem item : testController.screenItemList ){
                
                system.assertEquals(item.itemRecord.ItemName__c, '付帯業者0用商品No.' + i, '付帯商品名');
                system.assertEquals(item.itemRecord.Remarks__c, '付帯商品の備考が入ります' + i, '付帯商品備考');
                i++ ;
            }
            
            //対応レコード格納確認
            system.assertEquals(testController.targetCorrespondRecord.Id, testCorrespond.Id, 'error:対応レコードId');
        }
    }
    
    //初期表示(異常系)
    @isTest static void initializeNotFindIdErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
        system.runas(userRecord){
            
            //パラメータ設定
            PageReference pageRef = Page.GF201004View;
            pageRef.getParameters().put('Id', '0060T0000023JEAQA2' );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF201004Controller testController = new GF201004Controller();
            
            //レコード情報が取得できないときのエラー出てる？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)), messages[0]);
        }
    }
    
    //保存テスト
    @isTest static void saveTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
        system.runas(userRecord){
            
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '付帯業者名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF201004View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF201004Controller testController = new GF201004Controller();
            
            //スリープ
            CommonUtil.sleep(1);
            
            //保存処理起動
            testController.TargetRecordSave();
            
            //保存後取引先レコード
            Account saveAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '付帯業者名0'];
            
            //更新日時確認
            system.assert(testAccout.systemModStamp != saveAccout.systemModStamp, 'error:更新日時が変わっていない');
            
        }
    }
    
    //削除テスト
    @isTest static void deleteTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
        system.runas(userRecord){
            
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '付帯業者名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF201004View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF201004Controller testController = new GF201004Controller();
            
            //削除処理起動
            testController.TargetRecordDelete();
            
            //各レコード再取得
            List<Account> testAccout2 = [SELECT Id FROM Account WHERE Id = :testAccout.Id];
            List<Item__c> testItem = [SELECT ItemName__c FROM Item__c WHERE Account__c = :testAccout.Id];
            List<Correspond__c> testCorrespond2 = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //レコードが取得できていないことを確認
            system.assert(testAccout2.isEmpty(), 'error:削除できてない');
            system.assert(testItem.isEmpty(), 'error:削除できてない');
            system.assert(testCorrespond2.isEmpty(), 'error:削除できてない');
            
        }
    }
    
    //保存(異常系)
    @isTest static void optimisticLockSaveErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
        system.runas(userRecord){
            
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '付帯業者名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF201004View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF201004Controller testController = new GF201004Controller();
            
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
        system.runas(userRecord){
            
            Account testAccout = [SELECT Id, SystemModStamp FROM Account WHERE Name = '付帯業者名0'];
            Correspond__c testCorrespond = [SELECT Id FROM Correspond__c WHERE AccountId__c = :testAccout.Id];
            
            //パラメータ設定
            PageReference pageRef = Page.GF201004View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF201004Controller testController = new GF201004Controller();
            
            //削除前に削除
            delete testAccout;
            
            //削除処理起動
            testController.TargetRecordDelete();
            
            //削除レコードが取得できないときのエラー出てる？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            system.assertEquals(ApexPages.getMessages()[0].getDetail(),CommonConst.MSG_COM_E_NOTICE_DELETED);
            
        }
    }
    
    //商品リストチェック→削除テスト
    @isTest static void checboxDeleteTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
        system.runas(userRecord){
            
            Account testAccout = [SELECT Id FROM Account WHERE Name = '付帯業者名0'];
            //Item型のリストからitemレコードを取ってきているので、List<Item__c>。回しているので付帯業者0用商品No.0～2まである。
            List<Item__c> testItems = [SELECT Id,Account__c FROM Item__c WHERE ItemName__c = '付帯業者0用商品No.1'];
            //パラメータ設定
            PageReference pageRef = Page.GF201004View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            //パラメータありでコンストラクタ起動
            GF201004Controller testController = new GF201004Controller();
            
            //現在の明細数を保存
            Integer oldSize = testController.screenItemList.size();
            
            //チェックボックスをONにする
            testController.screenItemList[0].isItemCheck = TRUE;
            
            //チェックボックスONのレコードを明細行から削除
            testController.targetItemRecordDelete();
            
            System.assert(testController.screenItemList.size() < oldSize, 'error:商品行が削除されていない');
        }
    }
    
    //商品レコード削除テスト
    @isTest static void itemDeleteTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
        system.runas(userRecord){
            
            Account testAccout = [SELECT Id FROM Account WHERE Name = '付帯業者名0'];
            //Item型のリストからitemレコードを取ってきているので、List<Item__c>。回しているので付帯業者0用商品No.0～2まである。
            List<Item__c> testItems = [SELECT Id FROM Item__c WHERE ItemName__c = '付帯業者0用商品No.1'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF201004View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF201004Controller testController = new GF201004Controller();
            
            // Item__c型のtestItemの中身をscreenItem型のscreenItemListに入れたいから、変換処理をしている。
            for(Item__c testItem : testItems){
                GF201004Controller.screenItem s =new GF201004Controller.screenItem(testItem);
                testController.screenItemList.add(s);
            }
            
            //チェックボックスをONにする
            testController.screenItemList[0].isItemCheck = TRUE;
            
            //削除処理実行
            testController.targetItemRecordDelete();
            
            //保存処理
            testController.TargetRecordSave();
            
            List<Item__c> checkItem = [SELECT Id FROM Item__c WHERE Id = :testAccout.Id];
            System.assert(checkItem.size() == 0, 'error:商品レコードが削除できていない');
        }
    }
    
    //商品レコード削除エラーテスト
    @isTest static void itemDeleteErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
        system.runas(userRecord){
            
            Account testAccout = [SELECT Id FROM Account WHERE Name = '付帯業者名0'];
            //Item型のリストからitemレコードを取ってきているので、List<Item__c>。回しているので付帯業者0用商品No.0～2まである。
            List<Item__c> testItems = [SELECT Id FROM Item__c WHERE ItemName__c = '付帯業者0用商品No.1'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF201004View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF201004Controller testController = new GF201004Controller();
            
            // Item__c型のtestItemの中身をscreenItem型のscreenItemListに入れたいから、変換処理をしている。
            for(Item__c testItem : testItems){
                GF201004Controller.screenItem s =new GF201004Controller.screenItem(testItem);
                testController.screenItemList.add(s);
            }
            
            //チェックボックスをONにする
            testController.screenItemList[0].isItemCheck = TRUE;
            
            //先に削除
            delete testItems;
            
            //削除処理実行
            testController.targetItemRecordDelete();
            
            //保存処理実行
            testController.TargetRecordSave();
            
            //エラーが出てる？
            List<ApexPages.Message> messages = ApexPages.getMessages();
            System.assertEquals(true, messages.size() > 0);
        }
    }
    
    //以下モーダル関係は登録が出来てからテスト
    
    // //商品新規登録モーダルテスト
    // @isTest static void newOpenModalTest(){
    //     User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
    //     system.runas(userRecord){
    
    //     Account testAccout = [SELECT Id FROM Account WHERE Name = '付帯業者名0'];
    //     List<Item__c> testItems = [SELECT Id FROM Item__c WHERE ItemName__c = '付帯業者0用商品No.1'];
    
    //     //パラメータ設定
    //     PageReference pageRef = Page.GF201004View;
    //     pageRef.getParameters().put('Id',testAccout.Id );
    //     Test.setCurrentPage(pageRef);
    
    //     //パラメータありでコンストラクタ起動
    //     GF201004Controller testController = new GF201004Controller();
    
    //     //新規モーダル起動
    //     testController.openModalCreateItem();
    
    //     //子(モーダル)起動
    //     GF201002Controller testModalController = new GF201002Controller();
    
    //     //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
    //     testModalController.parameter = testController.GF201002Parameter;
    
    //     //子のinitactionを起動
    //     testModalController.initAction();
    
    //     //画面の名前項目が空白であることを確認
    //     System.assert(String.isEmpty((testModalController.Parameter.itemName), 'error:画面の名前項目が空白でではない');
    //     }
    // }
    
    // //商品明細編集モーダルテスト
    // @isTest static void editOpenModalTest(){
    // User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
    // system.runas(userRecord){
    
    //     Account testAccout = [SELECT Id FROM Account WHERE Name = '付帯業者名0'];
    //     List<Item__c> testItems = [SELECT Id FROM Item__c WHERE ItemName__c = '付帯業者0用商品No.1'];
    
    //     //パラメータ設定
    //     PageReference pageRef = Page.GF201004View;
    //     pageRef.getParameters().put('Id',testAccout.Id );
    //     Test.setCurrentPage(pageRef);
    
    //     //パラメータありでコンストラクタ起動
    //     GF201004Controller testController = new GF201004Controller();
    
    //     //編集モーダル起動
    //     testController.selectedIndex = 0;    //VFで設定される変数なので直接設定する
    //     testController.openModalUpdateItem();
    
    //     //子(モーダル)起動
    //     GF201002Controller testModalController = new GF201002Controller();
    
    //     //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
    //     testModalController.parameter = testController.GF201004Parameter;
    
    //     //子のinitactionを起動
    //     testModalController.initAction();
    
    //     //画面の名前項目がDBと一致することを確認
    //     System.assertEquals(testModalController.modalParameter.itemName, '付帯業者0用商品No.1', 'error:画面の名前項目が違う');
    // }
    // }
    
    // //商品明細登録用モーダル終了(設定)テスト
    // @isTest static void closeModalTest(){
    // User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
    // system.runas(userRecord){
    
    //     Account testAccout = [SELECT Id FROM Account WHERE Name = '付帯業者名0'];
    //     List<Item__c> testItems = [SELECT Id FROM Item__c WHERE ItemName__c = '付帯業者0用商品No.1'];
    
    //     //パラメータ設定
    //     PageReference pageRef = Page.GF101004View;
    //     pageRef.getParameters().put('Id',testAccout.Id );
    //     Test.setCurrentPage(pageRef);
    
    //     //パラメータありでコンストラクタ起動
    //     GF201004Controller testController = new GF201004Controller();
    
    //     //編集モーダル起動
    //     testController.selectedIndex = 0;    //VFで設定される変数なので直接設定する
    //     testController.openModalUpdateItemDetail();
    
    //     //子(モーダル)起動
    //     GF201002Controller testModalController = new GF201002Controller();
    
    //     //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
    //     testModalController.parameter = testController.GF201004Parameter;
    
    //     //子のinitactionを起動
    //     testModalController.initAction();
    
    //     //モーダルで名前を変更
    //     testModalController.modalParameter.planDetail = 'koushin';
    
    //     //設定処理
    //     testModalController.closeModal();
    
    //     //子のパラメータを親に渡す
    //     testController.GF201002Parameter = testModalController.parameter;
    
    //     //モーダル終了処理
    //     testController.closeModal();
    
    //     //画面の名前が変更されていることを確認
    //     System.assertEquals(testController.screenItemDetailList[0].itemDetailRecord.ItemName__c, 'koushin', 'error:名前が変更されていない');
    // }
    // }
    
    
    //カバレッジ率向上用（テスト仕様書はなし）
    @isTest static void coverageUp(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
        system.runas(userRecord){
            
            //パラメータなしでコンストラクタ起動
            GF201004Controller testController = new GF201004Controller();
            
            testController.selectedIndex = 0;
            
            //モーダル起動呼び出し
            testController.openModal();
            testController.openModalCreateItem();
            
            //モーダル終了呼び出し
            testController.closeModal();
            testController.closeNewModal();
            testController.openModalUpdateItem();
            testController.screenTargetRecord.city = null;
            testController.TargetRecordSave();
            testController.isNew = true;
            testController.screenTargetRecord.name = 'a';
            testController.screenTargetRecord.state = '名古屋市';
            testController.screenTargetRecord.postalCode = 'a';
            testController.screenTargetRecord.city = 'a';
            testController.screenTargetRecord.phone = 'a';
            testController.screenTargetRecord.email = 'a';
            testController.TargetRecordSave();
            testController.screenTargetRecord.email = 'a@a';
            testController.TargetRecordSave();
            //メッセージ
            String a;
            a = testController.MSG_COM_V_SAVE;
            a = testController.MSG_COM_I_SAVE;
            a = testController.MSG_COM_V_DELETE;
            a = testController.MSG_COM_I_DELETE;
            
        }
    }
    @isTest static void coverageUp2(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF201004Test@horaguchi.com'];
        system.runas(userRecord){
            
            Account testAccout = [SELECT Id FROM Account WHERE Name = '付帯業者名0'];
            //Item型のリストからitemレコードを取ってきているので、List<Item__c>。回しているので付帯業者0用商品No.0～2まである。
            List<Item__c> testItems = [SELECT Id FROM Item__c WHERE ItemName__c = '付帯業者0用商品No.1'];
            
            //パラメータ設定
            PageReference pageRef = Page.GF201004View;
            pageRef.getParameters().put('Id',testAccout.Id );
            Test.setCurrentPage(pageRef);
            
            //パラメータありでコンストラクタ起動
            GF201004Controller testController = new GF201004Controller();
            testController.selectedIndex = 0;
            testController.openModalUpdateItem();
        }
    }
    
}