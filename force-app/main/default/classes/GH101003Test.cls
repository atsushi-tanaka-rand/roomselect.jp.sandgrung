/**
* @File Name          : GH101003Test.cls
* @Description        : ユーザー異動登録のテスト
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 2020/3/31 15:57:10
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    2020/3/10   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
private class GH101003Test {
    
    //***************************************************** テストデータ作成用メソッド *****************************************************************
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //テスト用レコードを作成
        
        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = 'テスト店舗',
                                         District__c ='港区',
                                         SystemUseStartDate__c = Date.newInstance(2000, 12, 1),
                                         SystemUseEndDate__c = Date.newInstance(2999, 12, 1));
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
                UserName = 'GH101003Test@horaguchi.com',
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH101003Test@horaguchi.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(
            OrgzanizationHierarchy__c = orgRecord2.id,
            Staff__c = userRecord.id,
            StartDate__c = Date.newInstance(2000, 12, 1),
            EndDate__c = Date.newInstance(2999, 12, 1),
            StatusType__c = '入社',
            IsShopStaffType__c = true); 
        insert ShopTransferRecord;
    }
    
    //***************************************************** テストメソッド *****************************************************************
    
    //初期表示テスト	
    @isTest static void initializeTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH101003Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            OrganizationHierarchy__c org = [SELECT Id FROM OrganizationHierarchy__c WHERE OrganizationCode__c = '0002'];
            ShopTransfer__c st = [SELECT Id FROM ShopTransfer__c];
            
            //コンストラクタ起動
            GH101003Controller testController = new GH101003Controller(); 
            
            //テスト結果確認
            system.assertEquals(testController.shopTransferInfoRecordList[0].shopTransferRecord.IsShopStaffType__c, true);
        }
    }
    
    //新規ユーザー異動追加テスト
    @isTest static void setNewShopTransferTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH101003Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            OrganizationHierarchy__c org = [SELECT Id FROM OrganizationHierarchy__c WHERE OrganizationCode__c = '0002'];
            
            //コンストラクタ起動
            GH101003Controller testController = new GH101003Controller(); 
            
            //モーダル起動呼び出し
            testController.openNewShopTransferModal();
            
            //子(モーダル)起動
            GH101003Modal1Controller testModalController = new GH101003Modal1Controller();
            
            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GH101003Modal1Parameter;
            
            //子のinitactionを起動
            testModalController.initAction();
            
            //新規ユーザー異動情報を設定
            testModalController.screenShopTransferRecord.staffName = userRecord.Id;
            testModalController.screenShopTransferRecord.orgzanizationHierarchy = org.id;
            testModalController.screenShopTransferRecord.startDate = Date.newInstance(3000, 1, 1);
            testModalController.screenShopTransferRecord.endDate = Date.newInstance(3000, 12, 31);
            testModalController.screenShopTransferRecord.staffType = false;
            
            //設定
            testModalController.setShopTransferInfo();
            
            //子のパラメータを親に渡す
            testController.GH101003Modal1Parameter = testModalController.parameter;
            
            //画面閉じる
            testController.closeNewShopTransferModal();
            
            //テスト結果確認
            system.assertEquals(testController.shopTransferInfoRecordList[1].shopTransferRecord.IsShopStaffType__c, false);
        }
    }
    
    //店舗異動情報の編集テスト
    @isTest static void editShopTransferTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH101003Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            OrganizationHierarchy__c org = [SELECT Id FROM OrganizationHierarchy__c WHERE OrganizationCode__c = '0002'];
            ShopTransfer__c st = [SELECT Id FROM ShopTransfer__c];
            
            //コンストラクタ起動
            GH101003Controller testController = new GH101003Controller(); 
            
            //明細の選択
            testController.stInfoIndex = 0;
            
            //モーダル起動呼び出し
            testController.editShopTransferModal();
            
            //子(モーダル)起動
            GH101003Modal1Controller testModalController = new GH101003Modal1Controller();
            
            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GH101003Modal1Parameter;
            
            //子のinitactionを起動
            testModalController.initAction();
            
            //店舗異動情報を編集
            testModalController.screenShopTransferRecord.staffName = userRecord.Id;
            testModalController.screenShopTransferRecord.orgzanizationHierarchy = org.id;
            testModalController.screenShopTransferRecord.startDate = Date.newInstance(2000, 12, 1);
            testModalController.screenShopTransferRecord.endDate = Date.newInstance(2030, 12, 1);
            testModalController.screenShopTransferRecord.statusType = '異動';
            testModalController.screenShopTransferRecord.staffType = false;
            
            //設定
            testModalController.setShopTransferInfo();
            
            //子のパラメータを親に渡す
            testController.GH101003Modal1Parameter = testModalController.parameter;
            
            //画面閉じる
            testController.closeNewShopTransferModal();
            
            //テスト結果確認
            system.assertEquals(testController.shopTransferInfoRecordList[0].shopTransferRecord.StatusType__c, '異動');
            system.assertEquals(testController.shopTransferInfoRecordList[0].shopTransferRecord.IsShopStaffType__c, false);
        }
    }
    
    //設定ボタン押下処理(異常系)：完全重複エラーチェック
    @isTest static void checkExistanceErrorCheck(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH101003Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            OrganizationHierarchy__c org = [SELECT Id FROM OrganizationHierarchy__c WHERE OrganizationCode__c = '0002'];
            ShopTransfer__c st = [SELECT Id FROM ShopTransfer__c];
            
            //コンストラクタ起動
            GH101003Controller testController = new GH101003Controller(); 
            
            //モーダル起動呼び出し
            testController.openNewShopTransferModal();
            
            //子(モーダル)起動
            GH101003Modal1Controller testModalController = new GH101003Modal1Controller();
            
            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GH101003Modal1Parameter;
            
            //子のinitactionを起動
            testModalController.initAction();
            
            //新規ユーザー異動情報を設定(管理職でユーザー名、店舗、期間が重複)
            testModalController.screenShopTransferRecord.staffName = userRecord.Id;
            testModalController.screenShopTransferRecord.orgzanizationHierarchy = org.id;
            testModalController.screenShopTransferRecord.startDate = Date.newInstance(2000, 12, 1);
            testModalController.screenShopTransferRecord.endDate = Date.newInstance(2999, 12, 1);
            testModalController.screenShopTransferRecord.staffType = true;
            
            //設定
            testModalController.setShopTransferInfo();
            
            //テスト結果確認
            system.assertEquals(testModalController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_EXISTENCE,'「test」' ));//「エラーメッセージ」の表示が正しいか確認
        }
    }
    
    //設定ボタン押下処理(異常系)：重複エラーチェック(店舗・期間)
    @isTest static void checkDuplicationErrorCheck(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH101003Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            OrganizationHierarchy__c org = [SELECT Id FROM OrganizationHierarchy__c WHERE OrganizationCode__c = '0002'];
            ShopTransfer__c st = [SELECT Id FROM ShopTransfer__c];
            
            //コンストラクタ起動
            GH101003Controller testController = new GH101003Controller(); 
            
            //モーダル起動呼び出し
            testController.openNewShopTransferModal();
            
            //子(モーダル)起動
            GH101003Modal1Controller testModalController = new GH101003Modal1Controller();
            
            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GH101003Modal1Parameter;
            
            //子のinitactionを起動
            testModalController.initAction();
            
            //新規ユーザー異動情報を設定(管理職でユーザー名、店舗、期間が重複)
            testModalController.screenShopTransferRecord.staffName = userRecord.Id;
            testModalController.screenShopTransferRecord.orgzanizationHierarchy = org.id;
            testModalController.screenShopTransferRecord.startDate = Date.newInstance(2020, 1, 1);
            testModalController.screenShopTransferRecord.endDate = Date.newInstance(2030, 12, 31);
            testModalController.screenShopTransferRecord.staffType = true;
            
            //設定
            testModalController.setShopTransferInfo();
            
            //テスト結果確認
            system.assertEquals(testModalController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_USER_E_SAVE_SHOP_TERM_DUPLICATE));//「エラーメッセージ」の表示が正しいか確認
        }
    }
      
    //削除ボタン押下処理(異常系)：削除エラーチェック
    @isTest static void deleteShopTransferTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH101003Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            OrganizationHierarchy__c org = [SELECT Id FROM OrganizationHierarchy__c WHERE OrganizationCode__c = '0002'];
            ShopTransfer__c st = [SELECT Id FROM ShopTransfer__c];
            
            //コンストラクタ起動
            GH101003Controller testController = new GH101003Controller(); 
            
            //削除する明細を選択
            testController.shopTransferInfoRecordList[0].shopTransferCheck = true;
            
            //削除処理
            testController.deleteShopTransferInfo();
            
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(1 + '行目 ' + CommonConst.MSG_USER_E_DELETE_DURING_TERM));//「エラーメッセージ」の表示が正しいか確認
        }
    }
   
    //保存ボタン押下処理
    @isTest static void saveShopTransferTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH101003Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            OrganizationHierarchy__c org = [SELECT Id FROM OrganizationHierarchy__c WHERE OrganizationCode__c = '0002'];
            
            //コンストラクタ起動
            GH101003Controller testController = new GH101003Controller(); 
            
            //モーダル起動呼び出し
            testController.openNewShopTransferModal();
            
            //子(モーダル)起動
            GH101003Modal1Controller testModalController = new GH101003Modal1Controller();
            
            //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
            testModalController.parameter = testController.GH101003Modal1Parameter;
            
            //子のinitactionを起動
            testModalController.initAction();
            
            //新規ユーザー異動情報を設定
            testModalController.screenShopTransferRecord.staffName = userRecord.Id;
            testModalController.screenShopTransferRecord.orgzanizationHierarchy = org.id;
            testModalController.screenShopTransferRecord.startDate = Date.newInstance(3000, 1, 1);
            testModalController.screenShopTransferRecord.endDate = Date.newInstance(3000, 12, 31);
            testModalController.screenShopTransferRecord.staffType = false;
            
            //設定
            testModalController.setShopTransferInfo();
            
            //子のパラメータを親に渡す
            testController.GH101003Modal1Parameter = testModalController.parameter;
            
            //画面閉じる
            testController.closeNewShopTransferModal();
            
            //保存
            testController.saveShopTransferInfo();
            
            //テスト結果確認
            system.assertEquals(testController.shopTransferInfoRecordList[1].shopTransferRecord.IsShopStaffType__c, false);
            
            //テスト結果確認(店舗異動が作成されているか)
            List<ShopTransfer__c> newSTRecord = [SELECT Id 
                                                 FROM ShopTransfer__c
                                                 WHERE IsShopStaffType__c = false];
            
            system.assertEquals(newSTRecord.size(), 1); 
        }
    }
    
    //保存ボタン押下処理(異常系)：店舗異動の楽観ロックチェック
    @isTest static void shopTransferOptimisticLockExceptionErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH101003Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            OrganizationHierarchy__c org = [SELECT Id FROM OrganizationHierarchy__c WHERE OrganizationCode__c = '0002'];
            ShopTransfer__c st = [SELECT Id FROM ShopTransfer__c];
            
            //コンストラクタ起動
            GH101003Controller testController = new GH101003Controller(); 
            
            //更新時間調整用に待機
            CommonUtil.sleep(2000);
            
            //対象の店舗異動を更新
            upsert st;
            
            //保存
            testController.saveShopTransferInfo();
            
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));//「エラーメッセージ」の表示が正しいか確認
        }
    }
    
    
    //カバレッジ率向上用（テスト仕様書はなし）
    @isTest static void callTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH101003Test@horaguchi.com'];
        system.runas(userRecord){
            
            //コンストラクタ起動
            GH101003Controller testController = new GH101003Controller();
            
            //パブリック変数の呼び出し
            String s = testController.MSG_COM_V_SAVE;
            s = testController.MSG_COM_I_SAVE;
            s = testController.MSG_COM_V_DELETE;
            s = testController.MSG_COM_I_DELETE;
        }
    }
    
}