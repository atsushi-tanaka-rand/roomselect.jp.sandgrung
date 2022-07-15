/*
* ポータル連携一覧のテスト
*/
@isTest
private class GD401001Test {
    
    //***************************************************** テストデータ作成用メソッド *****************************************************************
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        
        //テスト用レコードを作成
        SystemConfig__c s = new SystemConfig__c(PotalSearchMaxCount__c = 100
                                                ,PortalProcessNumForVerification__c = 50
                                                ,PotalSiteCheckboxWeight_Max__c = 900
                                                ,PotalSiteCheckboxWeight_PortalProperty__c = 1
                                                ,PotalSiteCheckboxWeight_Property__c = 9
                                                ,PotalDisplayMaxCount__c = 900
                                               );
        insert s;

        // ▼ 2022.04.12 CHINTAI本対応
        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = 'テスト店舗',
                                         PortalSitePostingDistrict__c = '名東区',
                                         SystemUseStartDate__c = Date.newInstance(2000, 12, 1),
                                         SystemUseEndDate__c = Date.newInstance(2999, 12, 1));

        //insert shopRecord;

		Shop__c shopRecord2 = new shop__c(Name = 'テスト店舗2',
                                         PortalSitePostingDistrict__c = '名東区',
                                         SystemUseStartDate__c = Date.newInstance(2000, 12, 1),
                                         SystemUseEndDate__c = Date.newInstance(2999, 12, 1),
										 IsChintaiPanoramaContract__c = true);

		Shop__c shopRecord3 = new shop__c(Name = 'テスト店舗3',
										PortalSitePostingDistrict__c = '名東区',
										SystemUseStartDate__c = Date.newInstance(2000, 12, 1),
										SystemUseEndDate__c = Date.newInstance(2999, 12, 1),
										IsChintaiPanoramaContract__c = false);

		List<Shop__c> shopRecordList = new List<Shop__c>{shopRecord,shopRecord2,shopRecord3};

		insert shopRecordList;
        // ▲ 2022.04.12 CHINTAI本対応

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

        // ▼ 2022.04.12 CHINTAI本対応
		OrganizationHierarchy__c orgRecord3 = new OrganizationHierarchy__c(
            OrganizationCode__c = '0003',
            OrganizationName__c = 'テスト店舗2',
            HierarchyCode__c = '20',
            HierarchyOrder__c = 2,
            UpperOrganizationHierarchy__c = orgRecord1.Id,
            ExpandedOrganizationCode__c = '0000_0001_0003',
            Shop__c = shopRecord2.Id
        );
        insert orgRecord3;

		OrganizationHierarchy__c orgRecord4 = new OrganizationHierarchy__c(
            OrganizationCode__c = '0004',
            OrganizationName__c = 'テスト店舗3',
            HierarchyCode__c = '20',
            HierarchyOrder__c = 3,
            UpperOrganizationHierarchy__c = orgRecord1.Id,
            ExpandedOrganizationCode__c = '0000_0001_0004',
            Shop__c = shopRecord3.Id
        );
        insert orgRecord4;
        // ▲ 2022.04.12 CHINTAI本対応

        //建物レコード
        Building__c buildingRecord = new Building__c(District__c = '名東区',
                                                     State__c = '愛知県',
                                                     City__c = '名古屋市名東区',
                                                     Name = 'テスト建物' );
        insert buildingRecord;
        
        //物件レコード
        Property__c propertyRecord = new Property__c(Building__c = buildingRecord.Id,
                                                     Name = '1',
                                                     WebPublishing__c = CommonConst.PROPERTY_WEBPUBLISHING_EXISTS,
                                                     OwnCompanyManageModDate__c = datetime.newInstance(2020, 2, 8),
                                                     LiveStatus__c = '空室',
                                                     Score__c = 36,
                                                     HomesPanoramaShop__c = shopRecord.Id,
                                                     IsBulkConfirmation__c = false);
        insert propertyRecord;
        
        //ポータルサイト掲載物件レコード
        PortalSitePostingProperty__c portalPropertyRecord = new PortalSitePostingProperty__c(
            Shop__c = shopRecord.Id,
            Property__c = propertyRecord.Id,
            IsHomes__c = true);

        // ▼ 2022.04.12 CHINTAI本対応
		PortalSitePostingProperty__c portalPropertyRecord2 = new PortalSitePostingProperty__c(
			Shop__c = shopRecord2.Id,
			Property__c = propertyRecord.Id,
			IsChintaiNet__c = true,
			IsChintaiPanoramaPosting__c = true);

		PortalSitePostingProperty__c portalPropertyRecord3 = new PortalSitePostingProperty__c(
			Shop__c = shopRecord3.Id,
			Property__c = propertyRecord.Id,
			IsChintaiNet__c = true,
			IsChintaiPanoramaPosting__c = true);

		List<PortalSitePostingProperty__c> portalPropertyRecordList = new List<PortalSitePostingProperty__c>{portalPropertyRecord,portalPropertyRecord2,portalPropertyRecord3};

        insert portalPropertyRecordList;
        // ▲ 2022.04.12 CHINTAI本対応
        
        //物件写真レコード
        PropertyPhoto__c propertyPhotoRecord = new PropertyPhoto__c(Property__c = propertyRecord.Id,
                                                                    PanoramaFileName1__c = 'テストパノラマ写真');
        insert propertyPhotoRecord;
        
        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('システム管理者')];
        System.assert(profiles.size() > 0);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            
            insert new User(
                UserName = 'GD401001Test@horaguchi.com',
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
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = userRecord.id,
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
        
        // ▼ 2022.04.12 CHINTAI本対応
		ShopTransfer__c ShopTransferRecord2 = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord3.id,
                                                                 Staff__c = userRecord.id,
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 

		ShopTransfer__c ShopTransferRecord3 = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord4.id,
																Staff__c = userRecord.id,
																StartDate__c = Date.newInstance(2000, 12, 1),
																EndDate__c = Date.newInstance(2999, 12, 1));

		List<ShopTransfer__c> ShopTransferRecordList = new List<ShopTransfer__c>{ShopTransferRecord,ShopTransferRecord2,ShopTransferRecord3};
        
		insert ShopTransferRecordList;
        // ▲ 2022.04.12 CHINTAI本対応
    }
    
    //***************************************************** テストメソッド *****************************************************************
    
    //初期表示テスト   
    @isTest static void initializeTest(){
        
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            //コントローラ作成
            GD401001Controller testController = new GD401001Controller();
            testController.shopsName = 'テスト店舗';
            //店舗が設定されている？
            system.assertEquals(testController.shopsName, 'テスト店舗');
            //ポータル連携物件がデフォルトで選択されている？
            system.assertEquals(testController.propertyType, 'ポータル連携物件');
            //点数：全てがデフォルトで選択されている？
            system.assertEquals(testController.propertyScore, '全て');
        }
    }
    
    //検索テスト(ポータル連携物件)
    @isTest static void searchPortalPropertyTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
            testController.propertyType = 'ポータル連携物件';
            testController.propertyName = 'テスト';
            testController.propertyAddress = '愛知県';
            testController.panoramaPostingProperty = true;
            
            //検索
            testController.search();
            
            
            //テスト結果確認
            system.assertEquals(testController.propertyAndPortalRecordList[0].propertyRecord.Building__r.Name, 'テスト建物');
            system.assertEquals(testController.propertyAndPortalRecordList[0].propertyRecord.Name, '1');
            
        }
    }
    
    //検索テスト(パノラマ掲載物件)
    @isTest static void searchPanoramaPropertyTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
            testController.propertyType = 'パノラマ掲載物件';
            testController.portalSite = 'HOMES';
            testController.propertyDistrict = '名東区';
            
            //検索
            testController.search();
            
            //テスト結果確認
            system.assertEquals(testController.propertyAndPortalRecordList[0].propertyRecord.LiveStatus__c, '空室');
            
        }
    }
    
    //検索テスト(全物件(空室・退去予定))
    @isTest static void searchAllPropertyTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
            testController.propertyType = '全物件(空室・退去予定)';
            testController.propertyScore = '36点以上';
            
            //検索
            testController.search();
            
            //テスト結果確認
            system.assertEquals(testController.propertyAndPortalRecordList[0].propertyRecord.LiveStatus__c, '空室');
            
        }
    }
    
    //登録テスト
    @isTest static void propertyRegisterTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
            testController.propertyType = 'ポータル連携物件';
            
            //検索
            testController.search();
            
            //掲載先(SUUMO)追加
            testController.propertyAndPortalRecordList[0].portalPropertyRecord.IsSuumo__c = true;
            
            //パノラマ掲載先(SUUMO)追加
            testController.propertyAndPortalRecordList[0].isSuumoPanoramaPropertyCheck = true;
            
            System.debug('テストクラスの掲載先1: '+ testController.propertyAndPortalRecordList[0].portalPropertyRecord.IsSuumo__c);
            System.debug('テストクラスのパノラマ掲載先1: '+ testController.propertyAndPortalRecordList[0].isSuumoPanoramaPropertyCheck);
            
            //登録
            testController.registerProperty();
            System.debug('テストクラスの掲載先2: '+ testController.propertyAndPortalRecordList[0].portalPropertyRecord.IsSuumo__c);
            System.debug('テストクラスのパノラマ掲載先2: '+ testController.propertyAndPortalRecordList[0].isSuumoPanoramaPropertyCheck);
            
            //テスト結果確認
            system.assertEquals(testController.propertyAndPortalRecordList[0].portalPropertyRecord.IsSuumo__c, true);
            system.assertEquals(testController.propertyAndPortalRecordList[0].isSuumoPanoramaPropertyCheck, true);
            
        }
    }

    //一括確認テスト
    @isTest static void propertyCheckTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
            testController.propertyType = 'ポータル連携物件';
            
            //検索
            testController.search();
            
            //一括確認
            testController.temporaryCheckedProperty();
            
            //テスト結果確認
            system.assertEquals(testController.propertyAndPortalRecordList[0].propertyRecord.IsBulkConfirmation__c, true);
            
        }
    }
    
    
    //検索ボタン押下処理(異常系)：検索結果件数チェック
    @isTest static void searchPropertyNoConditionErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定(0件になる検索条件)
            testController.shopsName = s.Id;
            testController.propertyType = 'ポータル連携物件';
            testController.propertyScore = '34点未満';
            
            //検索実行
            testController.search();
            
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));//「エラーメッセージ」の表示が正しいか確認
            
        }
    }   
    

    
    //登録ボタン押下処理(異常系)：楽観ロックチェック
    @isTest static void propertyLinkOptimisticLockExceptionErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            Property__c p =[SELECT Id FROM Property__c WHERE Name = '1'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
            testController.propertyType = 'ポータル連携物件';
            
            //検索実行
            testController.search();
            
            //掲載先(SUUMO)追加
            testController.propertyAndPortalRecordList[0].portalPropertyRecord.IsSuumo__c = true;
            
            //パノラマ掲載先(SUUMO)追加
            testController.propertyAndPortalRecordList[0].isSuumoPanoramaPropertyCheck = true;
            
            //更新時間調整用に待機
            CommonUtil.sleep(2000);
            
            //対象の物件を更新
            p.Name = '2';
            upsert p;
            
            //登録
            testController.registerProperty();
            
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));//「エラーメッセージ」の表示が正しいか確認
            
        }
    }   
    
    //登録ボタン押下処理(異常系)：パノラマ掲載先の登録チェック(SUUMO)
    @isTest static void suumoPanoramaRegisterErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
            testController.propertyType = 'ポータル連携物件';
            
            //検索
            testController.search();
            
            //パノラマ掲載先(SUUMO)追加
            testController.propertyAndPortalRecordList[0].isSuumoPanoramaPropertyCheck = true;
            
            //登録
            testController.registerProperty();
            
            //テスト結果確認
            // system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            // system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(1 + '行目 ' + CommonConst.MSG_PROP_E_PANORAMA_POSTING));//「エラーメッセージ」の表示が正しいか確認
            
        }
    }
    
    //登録ボタン押下処理(異常系)：パノラマ掲載先の登録チェック(AtHome)
    @isTest static void atHomePanoramaRegisterErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
            testController.propertyType = 'ポータル連携物件';
            
            //検索
            testController.search();
            
            //パノラマ掲載先(AtHome)追加
            testController.propertyAndPortalRecordList[0].isAtHomePanoramaPropertyCheck = true;
            
            //登録
            testController.registerProperty();
            
            //テスト結果確認(2020.8.20 IsAtHome__cを物件トリガでtrueにしているためエラーは発生しない)
            //system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            //system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(1 + '行目 ' + CommonConst.MSG_PROP_E_PANORAMA_POSTING));//「エラーメッセージ」の表示が正しいか確認
            
        }
    }
    
    //カバレッジ率向上用（テスト仕様書はなし）
    @isTest static void callTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //地区変更処理呼び出し
            testController.propertyDistrict = '港区';
            testController.changeDistrict();
            
            //ラジオボタン呼び出し
            testController.getIsPropertyTypeRadioButton();
            testController.getIsPropertyScoreRadioButton();  
            
            //パブリック変数の呼び出し
            String s = testController.MSG_COM_V_SAVE;
            s = testController.MSG_COM_I_SAVE;
            s = testController.MSG_COM_V_BULKREGISTRATION;
            s = testController.searchShopId;
            
            //表示ボタン押下
            testController.selectPage();
            
        }
    }

	// ▼ 2022.04.12 CHINTAI本対応 テストクラス追加
	//検索テスト(ポータル連携物件) CHINTAIパノラマ掲載契約=true確認
    @isTest static void searchPortalPropertyChintaiTrueTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗2'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
            testController.propertyType = 'ポータル連携物件';
            testController.propertyName = 'テスト';
            testController.propertyAddress = '愛知県';
            testController.panoramaPostingProperty = true;
            
            Test.startTest(); 
            //検索
            testController.search();
			Test.stopTest();
                  
            //テスト結果確認
            system.assertEquals(testController.propertyAndPortalRecordList[0].IsDisableChintaiPanoramaPosting, false); //CHINTAIパノラマ掲載先チェックボックスが押下可能であること
			system.assertEquals(testController.propertyAndPortalRecordList[0].propertyRecord.LiveStatus__c, '空室');
		}
    }

	//検索テスト(パノラマ掲載物件) CHINTAIパノラマ掲載契約=true確認
    @isTest static void searchPanoramaPropertyChintaiTrueTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗2'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
			//検索条件設定
            testController.shopsName = s.Id;
			testController.portalSite = 'CHINTAI';
            testController.propertyType = 'パノラマ掲載物件';

			//物件種別ラジオボタン（VFオプション）
			testController.getIsPropertyTypeRadioButton();

            Test.startTest(); 
            //検索
            testController.search();
			Test.stopTest();
                  
            //テスト結果確認
			system.assertEquals(testController.propertyAndPortalRecordList[0].IsDisableChintaiPanoramaPosting, false); //CHINTAIパノラマ掲載先チェックボックスが押下可能であること
			system.assertEquals(testController.propertyAndPortalRecordList[0].propertyRecord.LiveStatus__c, '空室');
		}
    }

	//検索テスト(全物件(空室・退去予定)) CHINTAIパノラマ掲載契約=true確認
    @isTest static void searchAllPropertyChintaiTrueTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗2'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
        	//検索条件設定
			testController.shopsName = s.Id;
			testController.propertyType = '全物件(空室・退去予定)';
			testController.propertyScore = '36点以上';
            
			Test.startTest(); 
			//検索
			testController.search();
			Test.stopTest();
                  
            //テスト結果確認
            system.assertEquals(testController.propertyAndPortalRecordList[0].IsDisableChintaiPanoramaPosting, false); //CHINTAIパノラマ掲載先チェックボックスが押下可能であること
			system.assertEquals(testController.propertyAndPortalRecordList[0].propertyRecord.LiveStatus__c, '空室');
		}
    }

	//検索テスト(ポータル連携物件) CHINTAIパノラマ掲載契約=false確認
    @isTest static void searchPortalPropertyChintaiFalseTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗3'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
            testController.propertyType = 'ポータル連携物件';
            testController.propertyName = 'テスト';
            testController.propertyAddress = '愛知県';
            testController.panoramaPostingProperty = true;
            
            Test.startTest(); 
            //検索
            testController.search();
			Test.stopTest();
                  
            //テスト結果確認
            system.assertEquals(testController.propertyAndPortalRecordList[0].IsDisableChintaiPanoramaPosting, true); //CHINTAIパノラマ掲載先チェックボックスが押下不可であること
			system.assertEquals(testController.propertyAndPortalRecordList[0].propertyRecord.LiveStatus__c, '空室');
		}
    }

	//検索テスト(パノラマ掲載物件) CHINTAIパノラマ掲載契約=false確認
    @isTest static void searchPanoramaPropertyChintaiFalseTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗3'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
			//検索条件設定(ポータルサイト:CHINTAI)
            testController.shopsName = s.Id;
			testController.portalSite = 'CHINTAI';
            testController.propertyType = 'パノラマ掲載物件';

			//物件種別ラジオボタン（VFオプション）
			testController.getIsPropertyTypeRadioButton();

            Test.startTest(); 
            //検索
            testController.search();
			Test.stopTest();
            //テスト結果確認
			system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA)); //「エラーメッセージ」の表示が正しいか確認
        }
    }

	//検索テスト(パノラマ掲載物件) CHINTAIパノラマ掲載契約=false確認
    @isTest static void searchPanoramaPropertyChintaiFalseTest2(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗3'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
			//検索条件設定(ポータルサイト:HOMES)
            testController.shopsName = s.Id;
			testController.portalSite = 'HOMES';
            testController.propertyType = 'パノラマ掲載物件';

			//物件種別ラジオボタン（VFオプション）
			testController.getIsPropertyTypeRadioButton();

            Test.startTest(); 
            //検索
            testController.search();
			Test.stopTest();
                  
            //テスト結果確認
            system.assertEquals(testController.propertyAndPortalRecordList[0].IsDisableChintaiPanoramaPosting, true); //CHINTAIパノラマ掲載先チェックボックスが押下不可であること
			system.assertEquals(testController.propertyAndPortalRecordList[0].propertyRecord.LiveStatus__c, '空室');
		}
    }

	//検索テスト(全物件(空室・退去予定)) CHINTAIパノラマ掲載契約=false確認
    @isTest static void searchAllPropertyChintaiFalseTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗3'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
        	//検索条件設定
			testController.shopsName = s.Id;
			testController.propertyType = '全物件(空室・退去予定)';
			testController.propertyScore = '36点以上';
            
		    Test.startTest(); 
            //検索
            testController.search();
			Test.stopTest();
                  
            //テスト結果確認
            system.assertEquals(testController.propertyAndPortalRecordList[0].IsDisableChintaiPanoramaPosting, true); //CHINTAIパノラマ掲載先チェックボックスが押下不可であること
			system.assertEquals(testController.propertyAndPortalRecordList[0].propertyRecord.LiveStatus__c, '空室');
		}
    }

	//検索テスト(ポータル連携物件) CHINTAI登録時エラーチェック
    @isTest static void searchPortalPropertyChintaiErrorTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗2'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
            testController.propertyType = 'ポータル連携物件';
            
            //検索
            testController.search();

			//パノラマ掲載先(CHINTAI)追加
            testController.propertyAndPortalRecordList[0].isChintaiPanoramaPropertyCheck = true;
			testController.propertyAndPortalRecordList[0].portalPropertyRecord.IsChintaiNet__c = false;
            
            Test.startTest(); 
            //登録
            testController.registerProperty();
			Test.stopTest();
                  
            //テスト結果確認
            system.assertEquals(testController.hasErrorMessage, true);//「エラーフラグ」がTRUEに設定されているか確認
            system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(1 + '行目 ' + CommonConst.MSG_PROP_E_PANORAMA_POSTING));//
        }
    }
    
    //登録テスト(CHINTAI) 掲載先、パノラマ掲載先(CHINTAI)のチェックボックスを変更し登録
    @isTest static void propertyRegisterChintaiTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗2'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
			testController.portalSite = 'CHINTAI';
            testController.propertyType = 'パノラマ掲載物件';

			//物件種別ラジオボタン（VFオプション）
			testController.getIsPropertyTypeRadioButton();
            
            //検索
            testController.search();
            
            //掲載先(CHINTAI)追加
            testController.propertyAndPortalRecordList[0].portalPropertyRecord.IsChintaiNet__c = true;
            
            //パノラマ掲載先(CHINTAI)追加
            testController.propertyAndPortalRecordList[0].isChintaiPanoramaPropertyCheck = true;
            
            Test.startTest(); 
            //登録
            testController.registerProperty();
			Test.stopTest();
            
            //テスト結果確認
			List<PortalSitePostingProperty__c> portalRecord = [SELECT Id, IsChintaiNet__c, IsChintaiPanoramaPosting__c 
                                                               FROM PortalSitePostingProperty__c
                                                               WHERE Shop__r.Name = 'テスト店舗2'];
			system.assertEquals(portalRecord[0].IsChintaiNet__c, true);
            system.assertEquals(portalRecord[0].IsChintaiPanoramaPosting__c, true);
        }
    }

	//登録テスト(CHINTAI) 掲載先 true→falseで登録
    @isTest static void propertyRegisterChintaiTest2(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗2'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
			testController.portalSite = 'CHINTAI';
            testController.propertyType = 'パノラマ掲載物件';

			//物件種別ラジオボタン（VFオプション）
			testController.getIsPropertyTypeRadioButton();
            
            //検索
            testController.search();
            
            //掲載先(CHINTAI)追加
            testController.propertyAndPortalRecordList[0].portalPropertyRecord.IsChintaiNet__c = false;
            
            Test.startTest(); 
            //登録
            testController.registerProperty();
			Test.stopTest();
            
            //テスト結果確認
			List<PortalSitePostingProperty__c> portalRecord = [SELECT Id, IsChintaiNet__c, IsChintaiPanoramaPosting__c 
                                                               FROM PortalSitePostingProperty__c
                                                               WHERE Shop__r.Name = 'テスト店舗2'];
            system.assertEquals(portalRecord[0].IsChintaiNet__c, false);
        }
    }

	//検索テスト(ポータル連携物件) 新規作成用リストに対象のポータル掲載物件データを追加
    @isTest static void searchNewPortalPropertyChintaiTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GD401001Test@horaguchi.com'];
        system.runas(userRecord){
            
            //テストデータ取得
            Shop__c s = [SELECT Id FROM Shop__c WHERE Name = 'テスト店舗2'];
            
            //コンストラクタ起動
            GD401001Controller testController = new GD401001Controller();
            
            //検索条件設定
            testController.shopsName = s.Id;
            testController.propertyType = 'ポータル連携物件';

            //検索
            testController.search();

			//新規作成条件を設定
            testController.propertyAndPortalRecordList[0].portalPropertyRecord.Id = null;
			testController.propertyAndPortalRecordList[0].portalPropertyRecord.IsChintaiNet__c = true;
        
			Test.startTest(); 
            //登録
            testController.registerProperty();
			Test.stopTest();

            //テスト結果確認
			system.assertNotEquals(testController.propertyAndPortalRecordList[0].portalPropertyRecord.Id, null);
        }
    }
    // ▲ 2022.04.12 CHINTAI本対応 
}