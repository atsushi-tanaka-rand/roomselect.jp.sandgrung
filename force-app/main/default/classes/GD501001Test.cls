/**
* @File Name          : GD501001Test.cls
* @Description        : ポータル連携物件登録のテスト
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              :
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 2020/2/25 16:36:57
* @Modification Log   :
* Ver       Date            Author      		    Modification
* 1.0    2020/2/25   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
private class GD501001Test {
    
    //***************************************************** テストデータ作成用メソッド *****************************************************************
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        
        //テスト用レコードを作成
        SystemConfig__c s = new SystemConfig__c(PortalProcessNumForDelete__c = 500,
                                                PortalProcessNumForInsert__c = 500);
        insert s;
        
        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = 'テスト店舗',
                                         PortalSitePostingDistrict__c = '港区',
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

        //建物レコード
        Building__c buildingRecord = new Building__c(District__c = '千種区',
                                                     State__c = '愛知県',
                                                     City__c = '名古屋市千種区',
                                                     Name = 'テスト建物' );
        insert buildingRecord;
        
        //取引先
        Account account = new Account(
                    Name = 'テスト株式会社'
                    ,at_home_press_ban__c = true
                    ,HOME_S_press_ban__c = true
                    ,SUUMO_press_ban__c = false
					,Chintai_press_ban__c = false // 2022.03.16 CHINTAI本対応
                    ,Our_HP_press_ban__c = false);
        insert account;

        //物件レコード
        Property__c propertyRecord = new Property__c(Building__c = buildingRecord.Id,
                                                     Name = 'テスト物件',
                                                     WebPublishing__c = CommonConst.PROPERTY_WEBPUBLISHING_EXISTS,
                                                     LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE, // 2022.04.15 CHINTAI本対応
                                                     FormerSupplier__c = account.Id);
        insert propertyRecord;
        
        
        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('システム管理者')];
        System.assert(profiles.size() > 0);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            
            insert new User(
                UserName = 'GD501001Test@horaguchi.com',
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = userRecord.id,
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
        insert ShopTransferRecord;

        //システム変数オブジェクトを作成
        SystemVariables__c systemVariablesDistrlct = new SystemVariables__c(
            VariablesName__c = commonconst.PORTALPROCESSCHECKBOX_DISTRICT
            ,VariablesLabel__c = 'ポータル連携処理中チェックボックス_地区情報'
        );
        insert systemVariablesDistrlct;
        SystemVariables__c systemVariablesShop = new SystemVariables__c(
            VariablesName__c = commonconst.PORTALPROCESSCHECKBOX_SHOP
            ,VariablesLabel__c = 'ポータル連携処理中チェックボックス_店舗'
        );
        insert systemVariablesShop;
    }
    
    //***************************************************** テストメソッド *****************************************************************
    
    //初期表示テスト	
    @isTest static void initializeTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller(); 
            
            //テスト結果確認(全て非表示・港区にチェックあり)
            system.assertEquals(testController.postingMeansRecordList[0].isNotSuumoPropertyShow, true);
            system.assertEquals(testController.postingMeansRecordList[0].isNotHomesPropertyShow, true);
            system.assertEquals(testController.postingMeansRecordList[0].isNotAtHomePropertyShow, true);
            system.assertEquals(testController.postingMeansRecordList[0].isNotChintaiPropertyShow, true); // 2022.03.16 CHINTAI本対応
            system.assertEquals(testController.postingDistrictsRecordList[0].checkBoxList[0].check, true);
        }
    }
    
    //掲載方法登録テスト
    @isTest static void postingMeansRegisterTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //SUUMO(物件名表示)に変更
            testController.postingMeansRecordList[0].isSuumoPropertyShow = true;
            testController.postingMeansRecordList[0].isNotSuumoPropertyShow = false;
            
            //HOME’S(物件名表示)に変更
            testController.postingMeansRecordList[0].isHomesPropertyShow = true;
            testController.postingMeansRecordList[0].isNotHomesPropertyShow = false;
            
            //at home(物件名表示)に変更
            testController.postingMeansRecordList[0].isAtHomePropertyShow = true;
            testController.postingMeansRecordList[0].isNotAtHomePropertyShow = false;

            // ▼ 2022.03.16 CHINTAI本対応 
            //CHINTAI(物件名表示)に変更
            testController.postingMeansRecordList[0].isChintaiPropertyShow = true;
            testController.postingMeansRecordList[0].isNotChintaiPropertyShow = false;
            // ▲ 2022.03.16 CHINTAI本対応
            
            System.debug('掲載方法のSUUMO(物件名表示)1: '+ testController.postingMeansRecordList[0].isSuumoPropertyShow);
            System.debug('掲載方法のSUUMO(物件名表示)2: '+ testController.postingMeansRecordList[0].shopsRecord.IsSuumoPropertyShow__c);
            
            Test.startTest(); // 2022.04.15 CHINTAI本対応 
            //掲載方法登録
            testController.registerPostingMeans();
            Test.stopTest(); // 2022.04.15 CHINTAI本対応 
            
            System.debug('掲載方法のSUUMO(物件名表示)3: '+ testController.postingMeansRecordList[0].shopsRecord.IsSuumoPropertyShow__c);
            
            //テスト結果確認
            system.assertEquals(testController.postingMeansRecordList[0].shopsRecord.IsSuumoPropertyShow__c, true);
            system.assertEquals(testController.postingMeansRecordList[0].shopsRecord.IsHomesPropertyShow__c, true);
            system.assertEquals(testController.postingMeansRecordList[0].shopsRecord.IsAtHomePropertyShow__c, true);
            // ▼ 2022.03.16 CHINTAI本対応
            system.assertEquals(testController.postingMeansRecordList[0].shopsRecord.IsChintaiPropertyShow__c, true);
            // ▲ 2022.03.16 CHINTAI本対応
            
        }
    }
    
    //掲載地区登録テスト
    @isTest static void postingDistrictsRegisterTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //掲載地区を追加
            testController.postingDistrictsRecordList[0].checkBoxList[5].check = true;
            testController.changeDistrictIndex = 5;
            testController.changeShopIndex = 0;
            
            //掲載地区登録
            testController.registerPostingDistricts();
            
            //system.debug('掲載地区(チェックボックス)；' + testController.postingDistrictsRecordList[0].checkBoxList);
            
            //テスト結果確認(掲載地区が追加されているか)
            //system.assertEquals(testController.postingDistrictsRecordList[0].shopsRecordForDistrict.PortalSitePostingDistrict__c, '港区;' + testController.districtStringList[5]);   
            
            //テスト結果確認(ポータルサイト掲載物件がつくられているか)
            List<PortalSitePostingProperty__c> portalRecord = [SELECT Id 
                                                               FROM PortalSitePostingProperty__c
                                                               WHERE Shop__r.Name = 'テスト店舗'
                                                               AND Property__r.Name = 'テスト物件'];
            // system.assertEquals(portalRecord.size(), 1);   
            
            //掲載地区を削除
            testController.postingDistrictsRecordList[0].checkBoxList[5].check = false;
            
            //掲載地区登録
            testController.registerPostingDistricts();
            
            //テスト結果確認(掲載地区が削除されているか)
            //system.assertEquals(testController.postingDistrictsRecordList[0].shopsRecordForDistrict.PortalSitePostingDistrict__c, '港区'); 
            
            //テスト結果確認(ポータルサイト掲載物件が削除されているか)
            List<PortalSitePostingProperty__c> deletePortalRecord = [SELECT Id 
                                                                     FROM PortalSitePostingProperty__c
                                                                     WHERE Shop__r.Name = 'テスト店舗'
                                                                     AND Property__r.Name = 'テスト物件'];
            system.assertEquals(deletePortalRecord.size(), 0);   
        }
    }
    
    //登録ボタン押下処理(異常系)：掲載方法の選択制限チェック
    @isTest static void searchSuumoPostingMeansErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //SUUMO(物件名表示・非表示)を両方選択
            testController.postingMeansRecordList[0].isSuumoPropertyShow = true;
            testController.postingMeansRecordList[0].isNotSuumoPropertyShow = true;
            
            //掲載方法登録
            testController.registerPostingMeans();
            
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_ANYONE));//「エラーメッセージ」の表示が正しいか確認
        }
    }
    
    //登録ボタン押下処理(異常系)：掲載方法の選択制限チェック(未選択)
    @isTest static void checkSuumoPostingMeansErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //SUUMO(物件名表示・非表示)を両方選択
            testController.postingMeansRecordList[0].isSuumoPropertyShow = false;
            testController.postingMeansRecordList[0].isNotSuumoPropertyShow = false;
            
            //掲載方法登録
            testController.registerPostingMeans();
            
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_CHOOSE));//「エラーメッセージ」の表示が正しいか確認
        }
    }
    
    //登録ボタン押下処理(異常系)：掲載方法の楽観ロックチェック
    @isTest static void postingMeansOptimisticLockExceptionErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //HOME’S(物件名表示)に変更
            testController.postingMeansRecordList[0].isHomesPropertyShow = true;
            testController.postingMeansRecordList[0].isNotHomesPropertyShow = false;
            
            //更新時間調整用に待機
            CommonUtil.sleep(2000);
            
            //対象の店舗を更新
            s.Name = 'テスト店舗2';
            upsert s;
            
            //掲載方法登録
            testController.registerPostingMeans();
            
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));//「エラーメッセージ」の表示が正しいか確認
        }
    }
    
    //登録ボタン押下処理(異常系)：掲載地区の選択制限チェック
    @isTest static void postingDistrictsRegisterErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //掲載地区を２つ追加
            testController.postingDistrictsRecordList[0].checkBoxList[1].check = true;
            testController.postingDistrictsRecordList[0].checkBoxList[2].check = true;
            
            //掲載地区登録
            testController.registerPostingDistricts();
            
            //テスト結果確認
            //system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            //system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_PROP_W_INPUT_POSTINGDISTRICT_UPPERLIMIT));//「エラーメッセージ」の表示が正しいか確認
        }
    }
    
    //登録ボタン押下処理(異常系)：掲載地区の楽観ロックチェック
    @isTest static void postingDistrictsOptimisticLockExceptionErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //掲載地区を追加
            testController.postingDistrictsRecordList[0].checkBoxList[5].check = true;
            
            //更新時間調整用に待機
            CommonUtil.sleep(2000);
            
            //対象の店舗を更新
            s.Name = 'テスト店舗2';
            upsert s;
            
            //掲載地区登録
            testController.registerPostingDistricts();
            
            //テスト結果確認
            //system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            //system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));//「エラーメッセージ」の表示が正しいか確認
        }
    }
    
    //カバレッジ率向上用（テスト仕様書はなし）
    @isTest static void callTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //パブリック変数の呼び出し
            String s = testController.MSG_COM_V_SAVE;
            s = testController.MSG_COM_I_SAVE;
        }
    }

    // ▼ 2022.04.15 CHINTAI本対応
    //掲載方法登録テスト(非表示)
    @isTest static void postingMeansRegisterHideTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();

            //SUUMO(物件名非表示)に変更
            testController.postingMeansRecordList[0].shopsRecord.isSuumoPropertyShow__c = true;  
            testController.postingMeansRecordList[0].isNotSuumoPropertyShow = true;

            //HOME’S(物件名非表示)に変更
            testController.postingMeansRecordList[0].shopsRecord.isHomesPropertyShow__c = true;  
            testController.postingMeansRecordList[0].isNotHomesPropertyShow = true;

            //at home(物件名非表示)に変更
            testController.postingMeansRecordList[0].shopsRecord.isAtHomePropertyShow__c = true;  
            testController.postingMeansRecordList[0].isNotAtHomePropertyShow = true;

            //CHINTAI(物件名非表示)に変更
            testController.postingMeansRecordList[0].shopsRecord.isChintaiPropertyShow__c = true;  
            testController.postingMeansRecordList[0].isNotChintaiPropertyShow = true;


            System.debug('掲載方法のSUUMO(物件名表示)1: '+ testController.postingMeansRecordList[0].isSuumoPropertyShow);
            System.debug('掲載方法のSUUMO(物件名非表示)2: '+ testController.postingMeansRecordList[0].isNotSuumoPropertyShow);
            System.debug('掲載方法のHOME’S(物件名表示)1: '+ testController.postingMeansRecordList[0].isHomesPropertyShow);
            System.debug('掲載方法のHOME’S(物件名非表示)2: '+ testController.postingMeansRecordList[0].isNotHomesPropertyShow);
            System.debug('掲載方法のat home(物件名表示)1: '+ testController.postingMeansRecordList[0].isAtHomePropertyShow);
            System.debug('掲載方法のat home(物件名非表示)2: '+ testController.postingMeansRecordList[0].isNotAtHomePropertyShow);
            System.debug('掲載方法のCHINTAI(物件名表示)1: '+ testController.postingMeansRecordList[0].isChintaiPropertyShow);
            System.debug('掲載方法のCHINTAI(物件名非表示)2: '+ testController.postingMeansRecordList[0].isNotChintaiPropertyShow);

            Test.startTest(); 
            //掲載方法登録
            testController.registerPostingMeans();
            Test.stopTest(); 

            System.debug('掲載方法のSUUMO(物件名表示)3: '+ testController.postingMeansRecordList[0].shopsRecord.isSuumoPropertyShow__c);
            System.debug('掲載方法のSUUMO(物件名非表示)4: '+ testController.postingMeansRecordList[0].isNotSuumoPropertyShow);
            System.debug('掲載方法のHOME’S(物件名表示)3: '+ testController.postingMeansRecordList[0].shopsRecord.isHomesPropertyShow__c);
            System.debug('掲載方法のHOME’S(物件名非表示)4: '+ testController.postingMeansRecordList[0].isNotHomesPropertyShow);
            System.debug('掲載方法のat home(物件名表示)3: '+ testController.postingMeansRecordList[0].shopsRecord.isAtHomePropertyShow__c);
            System.debug('掲載方法のat home(物件名非表示)4: '+ testController.postingMeansRecordList[0].isNotAtHomePropertyShow);
            System.debug('掲載方法のCHINTAI(物件名表示)3: '+ testController.postingMeansRecordList[0].shopsRecord.isChintaiPropertyShow__c);
            System.debug('掲載方法のCHINTAI(物件名非表示)4: '+ testController.postingMeansRecordList[0].isNotChintaiPropertyShow);

            //テスト結果確認
            system.assertEquals(testController.postingMeansRecordList[0].shopsRecord.IsSuumoPropertyShow__c, false);
            system.assertEquals(testController.postingMeansRecordList[0].shopsRecord.IsHomesPropertyShow__c, false);
            system.assertEquals(testController.postingMeansRecordList[0].shopsRecord.IsAtHomePropertyShow__c, false);
            system.assertEquals(testController.postingMeansRecordList[0].shopsRecord.IsChintaiPropertyShow__c, false);
        }
    }

    //登録ボタン押下処理(異常系)：HOME’S掲載方法の選択制限チェック
    @isTest static void searchHomesPostingMeansErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //CHINTAI(物件名表示・非表示)を両方選択
            testController.postingMeansRecordList[0].isHomesPropertyShow = true;
            testController.postingMeansRecordList[0].isNotHomesPropertyShow = true;
            
            Test.startTest(); 
            //掲載方法登録
            testController.registerPostingMeans();
            Test.stopTest(); 
            
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_ANYONE));//「エラーメッセージ」の表示が正しいか確認
        }
    }

    //登録ボタン押下処理(異常系)：at home掲載方法の選択制限チェック
    @isTest static void searchAtHomePostingMeansErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //CHINTAI(物件名表示・非表示)を両方選択
            testController.postingMeansRecordList[0].isAtHomePropertyShow = true;
            testController.postingMeansRecordList[0].isNotAtHomePropertyShow = true;
            
            Test.startTest(); 
            //掲載方法登録
            testController.registerPostingMeans();
            Test.stopTest(); 
            
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_ANYONE));//「エラーメッセージ」の表示が正しいか確認
        }
    }

    //登録ボタン押下処理(異常系)：CHINTAI掲載方法の選択制限チェック
    @isTest static void searchChintaiPostingMeansErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //CHINTAI(物件名表示・非表示)を両方選択
            testController.postingMeansRecordList[0].isChintaiPropertyShow = true;
            testController.postingMeansRecordList[0].isNotChintaiPropertyShow = true;
            
            Test.startTest(); 
            //掲載方法登録
            testController.registerPostingMeans();
            Test.stopTest(); 
            
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_ANYONE));//「エラーメッセージ」の表示が正しいか確認
        }
    }

    //登録ボタン押下処理(異常系)：HOME’S掲載方法の選択制限チェック(未選択)
    @isTest static void checkHomesPostingMeansErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //CHINTAI(物件名表示・非表示)を両方選択
            testController.postingMeansRecordList[0].isHomesPropertyShow = false;
            testController.postingMeansRecordList[0].isNotHomesPropertyShow = false;
            
            Test.startTest(); 
            //掲載方法登録
            testController.registerPostingMeans();
            Test.stopTest(); 
            
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_CHOOSE));//「エラーメッセージ」の表示が正しいか確認
        }
    }

    //登録ボタン押下処理(異常系)：at home掲載方法の選択制限チェック(未選択)
    @isTest static void checkAtHomePostingMeansErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //CHINTAI(物件名表示・非表示)を両方選択
            testController.postingMeansRecordList[0].isAtHomePropertyShow = false;
            testController.postingMeansRecordList[0].isNotAtHomePropertyShow = false;
            
            Test.startTest(); 
            //掲載方法登録
            testController.registerPostingMeans();
            Test.stopTest(); 
            
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_CHOOSE));//「エラーメッセージ」の表示が正しいか確認
        }
    }

    //登録ボタン押下処理(異常系)：CHINTAI掲載方法の選択制限チェック(未選択)
    @isTest static void checkChintaiPostingMeansErrorTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //CHINTAI(物件名表示・非表示)を両方選択
            testController.postingMeansRecordList[0].isChintaiPropertyShow = false;
            testController.postingMeansRecordList[0].isNotChintaiPropertyShow = false;
            
            Test.startTest(); 
            //掲載方法登録
            testController.registerPostingMeans();
            Test.stopTest(); 
            
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_PROP_E_SELECTION_PORTALSITE_POSTING_CHOOSE));//「エラーメッセージ」の表示が正しいか確認
        }
    }

    //ポータルサイト掲載物件登録処理テスト ※Settingで、取引先.Chintai_press_ban__c = falseで設定
    @isTest static void PortalSitePostingPropertyRegistrationProcessTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD501001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD501001Controller testController = new GD501001Controller();
            
            //掲載地区を追加
            testController.postingDistrictsRecordList[0].checkBoxList[5].check = true;
            testController.changeDistrictIndex = 5;
            testController.changeShopIndex = 0;
            
            Test.startTest(); 
            //掲載地区登録
            testController.registerPostingDistricts();
            Test.stopTest(); 
            
            //テスト結果確認
            List<PortalSitePostingProperty__c> portalRecord = [SELECT Id, IsChintaiNet__c 
                                                               FROM PortalSitePostingProperty__c
                                                               WHERE Shop__r.Name = 'テスト店舗'
                                                               AND Property__r.Name = 'テスト物件'];

            system.assertEquals(portalRecord[0].IsChintaiNet__c, true); //CHINTAIフラグが反映されていることを確認   
        }
    }
    // ▲ 2022.04.15 CHINTAI本対応
}