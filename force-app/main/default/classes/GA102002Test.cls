/**
 * 仮見積画面テスト
 */
@isTest

// -----------------------------------------------------------------------------------------------
// データの作成
// -----------------------------------------------------------------------------------------------
public with sharing class GA102002Test {
    public static final String USER_NAME = 'ippanUser@test.com'; 

    /**
    * テストに使用するレコードを作成する
    */
	@testSetup static void Setting(){
        // システム設定登録
        SystemConfig__c sysCon = new SystemConfig__c();
        sysCon.FormLogoPath__c= '/sfc/servlet.shepherd/version/download/0685h000001AAYMAA4';
        sysCon.TaxRate__c = 10;
        insert sysCon;

        //標準プロファイルを取得
        Id profileId = [SELECT Id FROM Profile WHERE Name = '一般ユーザ'].Id;

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            //ユーザの登録
            User testUser = new User(LastName = 'ippanUser'                     //姓
                                    ,Alias =  'alias'                           //別名
                                    ,Email = 'ippanUser@test.com'               //メール
                                    ,UserName =  USER_NAME           //ユーザ名
                                    ,CommunityNickname ='テストニックネーム'     //ニックネーム
                                    ,EmailEncodingKey = 'ISO-2022-JP'           //メールの文字コード
                                    ,TimeZoneSidKey = 'Asia/Tokyo'              //タイムゾーン
                                    ,LocaleSidKey = 'ja_JP'                     //地域
                                    ,LanguageLocaleKey= 'ja'                    //言語
                                    ,ProfileId = profileId                      //プロファイルID
            );
            insert testUser;     
        }
        User testUser =  [SELECT Id FROM User WHERE UserName = :USER_NAME];

        // 店舗データ
        Shop__c ippanShopRecord = new Shop__c(Name     = '店舗ユーザテスト_港区'     // 店舗名
                        , Phone__c = '000-0000-0000'            // 電話番号
                        , Fax__c   = '000-0000-0000'            // FAX
                        , Email__c = 'minato@test.AccountShoninShinseiWebservice.com' // メール
                        , PortalSitePostingDistrict__c = '港区' // ポータル掲載地区
                        , District__c = '港区'                  // 所在地区
                        , IsShopType__c = True                  // 店舗区分
                        , PostalCode__c = '999-9999'            // 郵便番号
                        , State__c      = '愛知県'              // 都道府県
                        , City__c       = '住所１'              // 住所１
                        , Street__c     = '住所２'              // 住所２
                        , CompanyName__c = '会社名'             // 会社名
        );
        insert ippanShopRecord;  

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
            Shop__c = ippanShopRecord.Id
        );
        insert orgRecord2;

        // 店舗異動データ（ユーザと店舗の紐づけ）
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id
                        ,StartDate__c =    Date.valueOf('2020-1-5')             //開始日
                        ,EndDate__c   =    Date.valueOf('2040-1-5')             //終了日
                        ,Staff__c     =   testUser.Id                           //ユーザ
                        );                            
        insert ShopTransferRecord;

        // 取引先（顧客）
        Account AccountRecord = new Account(Name = 'テスト太郎'                     //取引先名
                                            ,LastName__c = 'テスト'                 //取引先（姓）
                                            ,FirstName__c = '太郎'                 //取引先（名）
											,NameKana__c = 'ﾃｽﾄﾀﾛｳ'                 //取引先名（カナ）
											,Phone = '025-200-1234'                 //電話番号
											,Email__c = 'aaa@hora'                  // メール
											,state__c = '大阪府'                    //都道府県
											,city__c = '大阪市'                     //住所１（市区町村）
                                            ,street__c = '中央区安土町４－１'       //住所２（番地）
                                            ,sex__c = '女性'                        //性別
                                            ,PostalCode__c = '1234567'              //郵便番号
                                            ,HomeMovingDate__c = date.valueof('2020-04-01')    //引越時期
                                            ,Birthdate__c = commonutil.getToday()
                                            ,ContractType__c = '個人契約'
											,RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER) //レコードタイプID（顧客）
        );
        insert AccountRecord; 

        // 建物
        Building__c BuildingRecord = new Building__c( Name = '反響テスト建物'   // 建物名
            , District__c = '港区'      // 地区
        );       
        insert BuildingRecord;

        // 物件
        List<Property__c> PropertyRecordList = new List<Property__c>();
        PropertyRecordList.add(new Property__c( name = '物件A',Building__c = BuildingRecord.id ,GuaranteeidCompanyType__c = '利用可'));
        PropertyRecordList.add(new Property__c( name = '物件B',Building__c = BuildingRecord.id ,GuaranteeidCompanyType__c = '利用可'));
        upsert PropertyRecordList;

        // 商品
        List<Item__c> ItemRecord = new List<Item__c>();
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = 'テスト保証プラン1', RecordTypeId = commonUtil.getRecordTypeId('Item__c','GuaranteePlanRecordType'),auxiliaryItemFeeTaxType__c = '課税',  RentFeeRate__c = 50,DirectDebitFee__c = 1000,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = 'テスト1火災保険',   RecordTypeId = commonUtil.getRecordTypeId('Item__c','FireInsuranceRecordType'),auxiliaryItemFeeTaxType__c = '課税',  FireInsuranceMonth__c = 10000,PaymentType__c = '月型',IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = 'テスト2火災保険',   RecordTypeId = commonUtil.getRecordTypeId('Item__c','FireInsuranceRecordType'),auxiliaryItemFeeTaxType__c = '課税',  FireInsuranceMonth__c = 20000,PaymentType__c = '月型',IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = '消毒1',             RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),auxiliaryItemFeeTaxType__c = '課税',  AuxiliaryItemFee__c = 5000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_DISINFECTION,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = '消毒2',             RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),auxiliaryItemFeeTaxType__c = '非課税',AuxiliaryItemFee__c = 2000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_DISINFECTION,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = '鍵交換1',           RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),auxiliaryItemFeeTaxType__c = '課税',  AuxiliaryItemFee__c = 2000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_KEYEXCHANGE,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = '安心サポート1',     RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),auxiliaryItemFeeTaxType__c = '非課税',AuxiliaryItemFee__c = 10000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_RELIABLESUPPORT,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = 'Fショット1',        RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),auxiliaryItemFeeTaxType__c = '課税',  AuxiliaryItemFee__c = 2000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_FSHOT,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = 'アルソック1',       RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),auxiliaryItemFeeTaxType__c = '非課税',AuxiliaryItemFee__c = 15000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_ALSOKLOCK,IsAuxiliary__c = true));
        insert ItemRecord;
        Map<String, Item__c> itemMap = readItemC();

        // 商品明細
        ItemDetail__c ItemDetailRecord = new ItemDetail__c(Item__c = itemMap.get('テスト保証プラン1').id
                                                          ,FirstFeeDepositRate__c = 1
                                                          ,FirstFeeDepositYen__c = 1000);
        upsert ItemDetailRecord;
        List<ItemDetail__c> hosho = [select id from ItemDetail__c LIMIT  1] ;

        // 仮見積
        ProvisionalQuote__c ProvisionalQuote = new ProvisionalQuote__c(
              Property__c = PropertyRecordList[0].id
            , Account__c = AccountRecord.id
            , RentProratedFee__c = 10
            , ContractStartDate__c  = Date.today()
            , FireInsuranceItem__c  = itemMap.get('テスト1火災保険').id
            , AuxiliaryItem1__c     = itemMap.get('消毒1').id
            , AuxiliaryItemFee1__c  = 10001
            , AuxiliaryItem2__c     = itemMap.get('鍵交換1').id
            , AuxiliaryItemFee2__c  = 10002
            , AuxiliaryItem3__c     = itemMap.get('安心サポート1').id
            , AuxiliaryItemFee3__c  = 10003
            , AuxiliaryItem4__c     = itemMap.get('Fショット1').id
            , AuxiliaryItemFee4__c  = 10004
            , AuxiliaryItem5__c     = itemMap.get('アルソック1').id
            , AuxiliaryItemFee5__c  = 10005
            , DepositItem__c        = hosho[0].id
        );
        upsert ProvisionalQuote;

    }

// -----------------------------------------------------------------------------------------------
// メインの画面
// -----------------------------------------------------------------------------------------------
    /**
     * 初期表示テスト
     */
    @istest static void initializeTestNew() {
       //一般ユーザで実行
       User ippanUser = [SELECT Id 
                           ,LastName 
                           ,Alias
                           ,Email
                           ,UserName
                           ,CommunityNickname
                           ,EmailEncodingKey
                           ,TimeZoneSidKey 
                           ,LocaleSidKey 
                           ,LanguageLocaleKey
                           ,ProfileId 
                           FROM User
                           WHERE LastName = 'ippanUser' 
               ];
        Account AccountRecord = [SELECT Id 
               FROM Account
               WHERE Name = 'テスト太郎' 
               LIMIT  1
        ];

        Property__c PropertyRecord = [SELECT Id
                            FROM Property__c
                            WHERE name = '物件A'
                            LIMIT  1

        ];
        
       System.runAs(ippanUser){
            try {
                // パラメータ設定
                PageReference pageRef = Page.GA102002View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('PropertyId',PropertyRecord.Id );
                Test.setCurrentPage(pageRef);
                System.debug('AccountId='+AccountRecord.Id);
                System.debug('PropertyId='+PropertyRecord.Id);
                GA102002Controller testController = new GA102002Controller();

                testController.Proratedflag = true;
                testController.ProratedCalculationDay = 31;
                testController.Parkingflag =true;
                testController.ParkingNumberRequired = '1' ;
                testController.ParkingFee = '1000';
                testController.BicycleParkingFlag =true;
                testController.BicycleParkingNumberRequired = '1';
                testController.BicycleParkingFee = '2000';
                testController.BikeParkingSmallFlag =true;
                testController.BikeParkingSmallNumberRequired = '1';
                testController.BikeParkingSmallFee = '3000';
                testController.BikeParkingMediumFlag =true;
                testController.BikeParkingMediumNumberRequired = '1';
                testController.BikeParkingMediumFee = '4000';
                testController.BikeParkinLargeFlag =true;
                testController.BikeParkinLargeNumberRequired = '1';
                testController.BikeParkinLargeFee = '5000';
                testController.checkInput();
                
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
    }

    /**
     * 仮見積画面出力
     */
    @istest static void initializeTest() {
        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                            ,LastName 
                            ,Alias
                            ,Email
                            ,UserName
                            ,CommunityNickname
                            ,EmailEncodingKey
                            ,TimeZoneSidKey 
                            ,LocaleSidKey 
                            ,LanguageLocaleKey
                            ,ProfileId 
                            FROM User
                            WHERE LastName = 'ippanUser' 
                ];
         Account AccountRecord = [SELECT Id 
                FROM Account
                WHERE Name = 'テスト太郎' 
                LIMIT  1
         ];
 
         Property__c PropertyRecord = [SELECT Id
                             FROM Property__c
                             WHERE name = '物件A'
                             LIMIT  1
 
         ];

         Map<String, Item__c> itemMap = readItemC();
         Item__c auxiliaryFireInsurance     = itemMap.get('テスト1火災保険');
         Item__c auxiliaryDisinfection      = itemMap.get('消毒1');
         Item__c auxiliaryKeyExchange       = itemMap.get('鍵交換1');
         Item__c auxiliaryReliableSuppor    = itemMap.get('安心サポート1');
         Item__c auxiliaryFShot             = itemMap.get('Fショット1');
         Item__c auxiliaryAlsokLock         = itemMap.get('アルソック1');
         
        System.runAs(ippanUser){
             try {
                // パラメータ設定
                PageReference pageRef = Page.GA102002View2;

                pageRef.getParameters().put('accountId',AccountRecord.Id );
                pageRef.getParameters().put('PropertyId',PropertyRecord.Id );
                pageRef.getParameters().put('SavedOutputFlag', 'false');
                pageRef.getParameters().put('HomeMovingDate', '2020/04/02');
                pageRef.getParameters().put('Proratedflag', 'true' );
                pageRef.getParameters().put('ProratedCalculationDay', '31');
                pageRef.getParameters().put('Parkingflag', 'true');
                pageRef.getParameters().put('ParkingNumberRequired', '1');
                pageRef.getParameters().put('ParkingFee', '1000');
                pageRef.getParameters().put('BicycleParkingFlag', 'true');
                pageRef.getParameters().put('BicycleParkingNumberRequired', '1');
                pageRef.getParameters().put('BicycleParkingFee', '2000');
                pageRef.getParameters().put('BikeParkingSmallFlag', 'true');
                pageRef.getParameters().put('BikeParkingSmallNumberRequired', '1');
                pageRef.getParameters().put('BikeParkingSmallFee', '3000');
                pageRef.getParameters().put('BikeParkingMediumFlag', 'true');
                pageRef.getParameters().put('BikeParkingMediumNumberRequired', '1');
                pageRef.getParameters().put('BikeParkingMediumFee', '4000');
                pageRef.getParameters().put('BikeParkinLargeFlag', 'true');
                pageRef.getParameters().put('BikeParkinLargeNumberRequired', '1');
                pageRef.getParameters().put('BikeParkinLargeFee', '5000');
                pageRef.getParameters().put('auxiliaryDepositPlan', '');      //保証プラン
                pageRef.getParameters().put('auxiliaryFireInsurance', auxiliaryFireInsurance.id);    //火災
                pageRef.getParameters().put('AuxiliaryItem1__c', auxiliaryDisinfection.id);     //室内消毒
                pageRef.getParameters().put('AuxiliaryItem2__c', auxiliaryKeyExchange.id);      //鍵交換費
                pageRef.getParameters().put('AuxiliaryItem3__c', auxiliaryReliableSuppor.id);   //安心サポート 
                pageRef.getParameters().put('AuxiliaryItem4__c', auxiliaryFShot.id);            //Fショット
                pageRef.getParameters().put('AuxiliaryItem5__c',auxiliaryAlsokLock.id );        //アルソック
                pageRef.getParameters().put('RenewalFeeShow', '更新料');
                pageRef.getParameters().put('CleaningFeeShow', 'クリーニング費');
                 
                Test.setCurrentPage(pageRef);
                GA102002Controller2 testController = new GA102002Controller2();

                testController.saveDate();
                 
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
    }

    /**
     * 仮見積画面出力（保存と仮見積の出力）
     */
    @istest static void initializeTestSave() {
        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                        ,LastName 
                        ,Alias
                        ,Email
                        ,UserName
                        ,CommunityNickname
                        ,EmailEncodingKey
                        ,TimeZoneSidKey 
                        ,LocaleSidKey 
                        ,LanguageLocaleKey
                        ,ProfileId 
                        FROM User
                        WHERE LastName = 'ippanUser' 
            ];
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
            LIMIT  1
        ];

        ProvisionalQuote__c ProvisionalQuote = [SELECT Id
                        FROM ProvisionalQuote__c
                        WHERE Account__c = :AccountRecord.id
                        LIMIT  1

        ];

        Property__c PropertyRecord = [SELECT Id
                        FROM Property__c
                        WHERE name = '物件A'
                        LIMIT  1

        ];  

        Map<String, Item__c> itemMap = readItemC();
        Item__c auxiliaryFireInsurance     = itemMap.get('テスト1火災保険');
        Item__c auxiliaryDisinfection      = itemMap.get('消毒1');
        Item__c auxiliaryKeyExchange       = itemMap.get('鍵交換1');
        Item__c auxiliaryReliableSuppor    = itemMap.get('安心サポート1');
        Item__c auxiliaryFShot             = itemMap.get('Fショット1');
        Item__c auxiliaryAlsokLock         = itemMap.get('アルソック1');

        system.debug('auxiliaryFireInsurance='+auxiliaryFireInsurance);
        system.debug('auxiliaryDisinfection='+auxiliaryDisinfection);
        system.debug('auxiliaryKeyExchange='+auxiliaryKeyExchange);
        system.debug('auxiliaryReliableSuppor='+auxiliaryReliableSuppor);
        system.debug('auxiliaryFShot='+auxiliaryFShot);
        system.debug('auxiliaryAlsokLock='+auxiliaryAlsokLock);

        System.runAs(ippanUser){
            try {
                // パラメータ設定
                PageReference pageRef = Page.GA102002View2;

                pageRef.getParameters().put('accountId',AccountRecord.Id );
                pageRef.getParameters().put('PropertyId',PropertyRecord.Id );
                pageRef.getParameters().put('SavedOutputFlag', 'true');
                pageRef.getParameters().put('HomeMovingDate', '2020/04/01');
                pageRef.getParameters().put('Proratedflag', 'true' );
                pageRef.getParameters().put('ProratedCalculationDay', '31');
                pageRef.getParameters().put('Parkingflag', 'true');
                pageRef.getParameters().put('ParkingNumberRequired', '1');
                pageRef.getParameters().put('ParkingFee', '1000');
                pageRef.getParameters().put('BicycleParkingFlag', 'true');
                pageRef.getParameters().put('BicycleParkingNumberRequired', '1');
                pageRef.getParameters().put('BicycleParkingFee', '2000');
                pageRef.getParameters().put('BikeParkingSmallFlag', 'true');
                pageRef.getParameters().put('BikeParkingSmallNumberRequired', '1');
                pageRef.getParameters().put('BikeParkingSmallFee', '3000');
                pageRef.getParameters().put('BikeParkingMediumFlag', 'true');
                pageRef.getParameters().put('BikeParkingMediumNumberRequired', '1');
                pageRef.getParameters().put('BikeParkingMediumFee', '4000');
                pageRef.getParameters().put('BikeParkinLargeFlag', 'true');
                pageRef.getParameters().put('BikeParkinLargeNumberRequired', '1');
                pageRef.getParameters().put('BikeParkinLargeFee', '5000');
                pageRef.getParameters().put('auxiliaryDepositPlan', '');      //保証プラン
                pageRef.getParameters().put('auxiliaryFireInsurance', auxiliaryFireInsurance.id);    //火災
                pageRef.getParameters().put('AuxiliaryItem1__c', auxiliaryDisinfection.id);     //室内消毒
                pageRef.getParameters().put('AuxiliaryItem2__c', auxiliaryKeyExchange.id);      //鍵交換費
                pageRef.getParameters().put('AuxiliaryItem3__c', auxiliaryReliableSuppor.id);   //安心サポート 
                pageRef.getParameters().put('AuxiliaryItem4__c', auxiliaryFShot.id);            //Fショット
                pageRef.getParameters().put('AuxiliaryItem5__c', auxiliaryAlsokLock.id );        //アルソック
                pageRef.getParameters().put('RenewalFeeShow', '更新料');
                pageRef.getParameters().put('CleaningFeeShow', 'クリーニング費');
                
                Test.setCurrentPage(pageRef);
                GA102002Controller2 testController = new GA102002Controller2();
                // testController.screenProvisionalQuoteRecord.Id = 
                
                testController.saveDate();
                
                
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
    }

    // --------------------------
    // 再販対応追加分（付帯商品の複数登録）
    // 初期表示
    @isTest static void testPage1Init() {
        //一般ユーザで実行
        System.runAs(getIppanUser()) {
            // ページ作成
            TestPage page = new TestPage('テスト太郎', '物件A');

            //（ 選択リスト）付帯商品種別の確認
            List<String> typeList = '消毒;鍵交換;安心サポート;Fショット;アルソック'.split('\\;');
            typeList.add(CommonConst.SELECTION_LIST_NULL);
            System.assertEquals(typeList.size(), page.ctrl.SelectEtceteraAuxiliaryItemTypeList.size(), '（ 選択リスト）付帯商品種別の登録件数');
            for (SelectOption opt: page.ctrl.SelectEtceteraAuxiliaryItemTypeList) {
                System.assert(typeList.contains(opt.getLabel()), '（ 選択リスト）付帯商品種別のラベル:' + opt.getLabel());
            }

            // （ 選択リスト）付帯商品名の確認
            List<String> nameList = new List<String>{
                  CommonConst.SELECTION_LIST_NULL
                , 'テスト太郎/消毒1/\\5,500'
                , 'テスト太郎/消毒2/\\2,000'
                , 'テスト太郎/鍵交換1/\\2,200'
                , 'テスト太郎/安心サポート1/\\10,000'
                , 'テスト太郎/Fショット1/\\2,200'
                , 'テスト太郎/アルソック1/\\15,000'
            };
            System.assertEquals(nameList.size(), page.ctrl.SelectEtceteraAuxiliaryItemNameList.size(), '（ 選択リスト）付帯商品種別の登録件数');
            for (SelectOption opt: page.ctrl.SelectEtceteraAuxiliaryItemNameList) {
                System.assert(nameList.contains(opt.getLabel()), '（ 選択リスト）付帯商品種別のラベル:' + opt.getLabel());
            }
    
            // その他付帯商品リストの確認
            System.assertEquals(0, page.screen.etceteraAuxiliaryItemList.size(), 'その他付帯商品リストの件数');
        }
    }

    // 画面項目変更
    @isTest static void testPage1ChangeScreen() {
        //一般ユーザで実行
        System.runAs(getIppanUser()) {

            // ページ作成
            TestPage page = new TestPage('テスト太郎', '物件A');

            //（ 選択リスト）付帯商品種別の変更
            page.screen.EtceteraAuxiliaryItemType = '消毒';
            page.ctrl.EtceteraAuxiliaryItemTypeListChange();
            List<String> nameList = new List<String>{
                CommonConst.SELECTION_LIST_NULL
                , 'テスト太郎/消毒1/\\5,500'
                , 'テスト太郎/消毒2/\\2,000'
            };
            System.assertEquals(nameList.size(), page.ctrl.SelectEtceteraAuxiliaryItemNameList.size(), '（ 選択リスト）付帯商品種別の登録件数');
            for (SelectOption opt: page.ctrl.SelectEtceteraAuxiliaryItemNameList) {
                System.assert(nameList.contains(opt.getLabel()), '（ 選択リスト）付帯商品種別のラベル:' + opt.getLabel());
            }

            // その他付帯商品の追加
            page.screen.etceteraAuxiliaryItemName = page.itemMap.get('消毒2').Id;
            page.ctrl.addEtceteraAuxiliaryItemList();
            System.assertEquals(1, page.screen.etceteraAuxiliaryItemList.size(), 'その他付帯商品リストの件数');
            System.assertEquals('消毒2', page.screen.etceteraAuxiliaryItemList[0].auxiliaryItemName);

            // その他付帯商品の削除
            page.screen.EtceteraAuxiliaryItemName = page.itemMap.get('消毒1').Id;
            page.ctrl.addEtceteraAuxiliaryItemList();
            page.addParameter('ListIndex', '0');
            Test.setCurrentPage(page.pageRef);
            page.ctrl.removeEtceteraAuxiliaryItemList();
            System.assertEquals(1, page.screen.etceteraAuxiliaryItemList.size(), 'その他付帯商品リストの件数');
            System.assertEquals('消毒1', page.screen.etceteraAuxiliaryItemList[0].auxiliaryItemName);
        }
    }


    // 入力チェック
    @isTest static void testPage1InputCheck() {
        //一般ユーザで実行
        System.runAs(getIppanUser()) {

            // ページ作成
            TestPage page = new TestPage('テスト太郎', '物件A');

            // 付帯商品追加時の必須入力チェック（商品未選択）
            page.ctrl.addEtceteraAuxiliaryItemList();
            System.assertEquals(true, page.hasError());
            System.assertEquals('付帯商品は入力必須です。', page.getErrorMessage());
            page.clearErrorMessage();

            // 明細件数の最大登録チェック
            page.screen.etceteraAuxiliaryItemName = page.itemMap.get('消毒1').Id;
            page.ctrl.addEtceteraAuxiliaryItemList();                    // １件目
            System.assertEquals(false, page.hasError(), 'エラーなし？');
            page.ctrl.addEtceteraAuxiliaryItemList();                    // ２件目
            System.assertEquals(false, page.hasError(), 'エラーなし？');
            page.ctrl.addEtceteraAuxiliaryItemList();                    // ３件目
            System.assertEquals(false, page.hasError(), 'エラーなし？');
            page.ctrl.addEtceteraAuxiliaryItemList();                    // ４件目
            System.assertEquals(false, page.hasError(), 'エラーなし？');
            page.ctrl.addEtceteraAuxiliaryItemList();                    // ５件目
            System.assertEquals(false, page.hasError(), 'エラーなし？');
            page.ctrl.addEtceteraAuxiliaryItemList();                    // ６件目
            System.assertEquals(false, page.hasError(), 'エラーなし？');
            page.ctrl.addEtceteraAuxiliaryItemList();                    // ７件目
            System.assertEquals(false, page.hasError(), 'エラーなし？');
            page.ctrl.addEtceteraAuxiliaryItemList();                    // ８件目
            System.assertEquals(false, page.hasError(), 'エラーなし？');
            page.ctrl.addEtceteraAuxiliaryItemList();                    // ９件目
            System.assertEquals(false, page.hasError(), 'エラーなし？');
            page.ctrl.addEtceteraAuxiliaryItemList();                    // １０件目
            System.assertEquals(false, page.hasError(), 'エラーなし？');
            Page.ctrl.addEtceteraAuxiliaryItemList();                    // １１件目
            system.assertEquals(true, page.hasError(), 'エラーあり？');
            System.assertEquals('付帯商品は10個以内で選択してください。', page.getErrorMessage());
            page.clearErrorMessage();
        }
    }

    // ページ２初期表示（１．保存済みの内容で出力）
    @isTest static void testPage2Init1() {
        //一般ユーザで実行
        System.runAs(getIppanUser()) {
            // ページ作成
            TestPage2 page = new TestPage2('テスト太郎', '物件A');
            page.createCtrlFromData();

            // その他付帯商品リストの確認
            List<List<String>> expecteds = new List<List<String>> {
                  new List<String>{'消毒1',         '消毒',         '10,001', '課税'}
                , new List<String>{'鍵交換1',       '鍵交換',       '10,002', '課税'}
                , new List<String>{'安心サポート1', '安心サポート', '10,003', '非課税'}
                , new List<String>{'Fショット1',    'Fショット',    '10,004', '課税'}
                , new List<String>{'アルソック1',   'アルソック',   '10,005', '非課税'}
            };
            System.assertEquals(expecteds.size(), page.screen.etceteraAuxiliaryItemList.size(), 'その他付帯商品リストの件数');
            for (Integer i = 0; i < expecteds.size(); i++) {
                List<String> ex = expecteds[i];
                System.assertEquals(ex[0], page.screen.etceteraAuxiliaryItemList[i].name,    'その他付帯商品リスト' + i + '件目の名前');
                System.assertEquals(ex[1], page.screen.etceteraAuxiliaryItemList[i].title,   'その他付帯商品リスト' + i + '件目のタイトル');
                System.assertEquals(ex[2], page.screen.etceteraAuxiliaryItemList[i].fee,     'その他付帯商品リスト' + i + '件目の金額');
                System.assertEquals(ex[3], page.screen.etceteraAuxiliaryItemList[i].taxType, 'その他付帯商品リスト' + i + '件目の税種別');
            }
        }
    }

    // ページ２初期表示（２．仮見積書出力）
    @isTest static void testPage2Init2() {
        //一般ユーザで実行
        System.runAs(getIppanUser()) {
            // ページ作成
            TestPage2 page = new TestPage2('テスト太郎', '物件B');
            page.createCtrlFromTestFullData();

            // その他付帯商品リストの確認
            List<List<String>> expecteds = new List<List<String>> {
                  new List<String>{'消毒1',         '消毒',          '5,000', '課税'}
                , new List<String>{'消毒2',         '消毒',          '2,000', '非課税'}
                , new List<String>{'鍵交換1',       '鍵交換',        '2,000', '課税'}
                , new List<String>{'安心サポート1', '安心サポート', '10,000', '非課税'}
                , new List<String>{'Fショット1',    'Fショット',     '2,000', '課税'}
                , new List<String>{'アルソック1',   'アルソック',   '15,000', '非課税'}
                , new List<String>{'消毒1',         '消毒',          '5,000', '課税'}
                , new List<String>{'消毒1',         '消毒',          '5,000', '課税'}
                , new List<String>{'消毒1',         '消毒',          '5,000', '課税'}
                , new List<String>{'消毒1',         '消毒',          '5,000', '課税'}
            };
            System.assertEquals(expecteds.size(), page.screen.etceteraAuxiliaryItemList.size(), 'その他付帯商品リストの件数');
            for (Integer i = 0; i < expecteds.size(); i++) {
                List<String> ex = expecteds[i];
                System.assertEquals(ex[0], page.screen.etceteraAuxiliaryItemList[i].name,    'その他付帯商品リスト' + i + '件目の名前');
                System.assertEquals(ex[1], page.screen.etceteraAuxiliaryItemList[i].title,   'その他付帯商品リスト' + i + '件目のタイトル');
                System.assertEquals(ex[2], page.screen.etceteraAuxiliaryItemList[i].fee,     'その他付帯商品リスト' + i + '件目の金額');
                System.assertEquals(ex[3], page.screen.etceteraAuxiliaryItemList[i].taxType, 'その他付帯商品リスト' + i + '件目の税種別');
            }
        }
    }

    // ページ２保存
    @isTest static void testPage2Save() {
        //一般ユーザで実行
        System.runAs(getIppanUser()) {
            // ページ作成
            TestPage2 page = new TestPage2('テスト太郎', '物件B');
            page.createCtrlFromTestFullData();

            // その他付帯商品金額の変更
            for (Integer i = 0; i < 10; i++) {
                page.screen.etceteraAuxiliaryItemList[i].fee = String.valueOf(20000 + i);
            }

            // 保存実行
            page.ctrl.saveDate();
            page.checkError();
            System.assertEquals(false, page.hasError());

            // 保存内容の確認
            List<String> expecteds = new List<String> {'消毒1', '消毒2', '鍵交換1', '安心サポート1', 'Fショット1', 'アルソック1', '消毒1', '消毒1', '消毒1', '消毒1'};
            ProvisionalQuote__c result = selectPQuote(page.account.Id, page.property.Id);
            for (Integer i = 1; i <= 10; i++) {
                System.assertEquals(page.itemMap.get(expecteds[i-1]).Id, result.get('AuxiliaryItem' + i + '__c'),   'その他付帯商品リスト' + i + '件目の商品ID');
                System.assertEquals(20000 + i - 1, result.get('AuxiliaryItemFee' + i + '__c'),                      'その他付帯商品リスト' + i + '件目の金額');
            }
        }
    }

    // DB保存内容確認　日割りなし
    @isTest static void saveProvisionalQuoteNotProratedTest() {
        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                        ,LastName 
                        ,Alias
                        ,Email
                        ,UserName
                        ,CommunityNickname
                        ,EmailEncodingKey
                        ,TimeZoneSidKey 
                        ,LocaleSidKey 
                        ,LanguageLocaleKey
                        ,ProfileId 
                        FROM User
                        WHERE LastName = 'ippanUser' 
            ];
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
            LIMIT  1
        ];

        ProvisionalQuote__c ProvisionalQuote = [SELECT Id
                        FROM ProvisionalQuote__c
                        WHERE Account__c = :AccountRecord.id
                        LIMIT  1

        ];

        ManagementCompanyItem__c managementCompanyItem = new ManagementCompanyItem__c(
            Account__c = AccountRecord.id,
            PaymentType__c = CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH
        );
        insert managementCompanyItem;


        ProvisionalQuoteManageCompayItem__c provisionalQuoteManageCompayItem = new ProvisionalQuoteManageCompayItem__c(
            ProvisionalQuote__c = provisionalQuote.id,
            ProvisionalQuoteItemNextMonthText__c = '仮見積指定商品_契約次月テキスト',
            ProvisionalQuoteItemThisMonthText__c = '仮見積指定商品_契約当月テキスト',
            ProvisionalQuoteItemFullMonthText__c = '仮見積指定商品_契約当月テキスト(日割り無し)',
            ManagementCompanyItem__c = managementCompanyItem.id
        );
        insert provisionalQuoteManageCompayItem;

        Property__c PropertyRecord = [SELECT Id
                        FROM Property__c
                        WHERE name = '物件A'
                        LIMIT  1

        ];  

        Map<String, Item__c> itemMap = readItemC();
        Item__c auxiliaryFireInsurance     = itemMap.get('テスト1火災保険');
        Item__c auxiliaryDisinfection      = itemMap.get('消毒1');
        Item__c auxiliaryKeyExchange       = itemMap.get('鍵交換1');
        Item__c auxiliaryReliableSuppor    = itemMap.get('安心サポート1');
        Item__c auxiliaryFShot             = itemMap.get('Fショット1');
        Item__c auxiliaryAlsokLock         = itemMap.get('アルソック1');

        System.runAs(ippanUser){
            try {
                Test.startTest();
                // パラメータ設定
                PageReference pageRef = Page.GA102002View2;

                pageRef.getParameters().put('accountId',AccountRecord.Id );
                pageRef.getParameters().put('PropertyId',PropertyRecord.Id );
                pageRef.getParameters().put('SavedOutputFlag', 'true');
                pageRef.getParameters().put('HomeMovingDate', '2020/04/01');
                pageRef.getParameters().put('Proratedflag', 'false' );//true 日割り
                pageRef.getParameters().put('ProratedCalculationDay', '31');
                pageRef.getParameters().put('Parkingflag', 'true');
                pageRef.getParameters().put('ParkingNumberRequired', '1');
                pageRef.getParameters().put('ParkingFee', '1000');
                pageRef.getParameters().put('BicycleParkingFlag', 'true');
                pageRef.getParameters().put('BicycleParkingNumberRequired', '1');
                pageRef.getParameters().put('BicycleParkingFee', '2000');
                pageRef.getParameters().put('BikeParkingSmallFlag', 'true');
                pageRef.getParameters().put('BikeParkingSmallNumberRequired', '1');
                pageRef.getParameters().put('BikeParkingSmallFee', '3000');
                pageRef.getParameters().put('BikeParkingMediumFlag', 'true');
                pageRef.getParameters().put('BikeParkingMediumNumberRequired', '1');
                pageRef.getParameters().put('BikeParkingMediumFee', '4000');
                pageRef.getParameters().put('BikeParkinLargeFlag', 'true');
                pageRef.getParameters().put('BikeParkinLargeNumberRequired', '1');
                pageRef.getParameters().put('BikeParkinLargeFee', '5000');
                pageRef.getParameters().put('auxiliaryDepositPlan', '');      //保証プラン
                pageRef.getParameters().put('auxiliaryFireInsurance', auxiliaryFireInsurance.id);    //火災
                pageRef.getParameters().put('AuxiliaryItem1__c', auxiliaryDisinfection.id);     //室内消毒
                pageRef.getParameters().put('AuxiliaryItem2__c', auxiliaryKeyExchange.id);      //鍵交換費
                pageRef.getParameters().put('AuxiliaryItem3__c', auxiliaryReliableSuppor.id);   //安心サポート 
                pageRef.getParameters().put('AuxiliaryItem4__c', auxiliaryFShot.id);            //Fショット
                pageRef.getParameters().put('AuxiliaryItem5__c', auxiliaryAlsokLock.id );        //アルソック
                pageRef.getParameters().put('RenewalFeeShow', '更新料');
                pageRef.getParameters().put('CleaningFeeShow', 'クリーニング費');
                
                Test.setCurrentPage(pageRef);
                GA102002Controller2 testController = new GA102002Controller2();

                // 値の変更
                testController.screenProvisionalQuoteRecord.rentFullMonthText = '家賃_契約当月テキスト(日割り無し)';                             // 家賃_契約当月テキスト
                testController.screenProvisionalQuoteRecord.managementFullMonthText = '管理費_契約当月テキスト(日割り無し)';                     // 管理費_契約当月テキスト
                testController.screenProvisionalQuoteRecord.townshipFullMonthText = '町会費_契約当月テキスト(日割り無し)';                       // 町会費_契約当月テキスト
                testController.screenProvisionalQuoteRecord.waterFullMonthText = '水道代_契約当月テキスト(日割り無し)';                          // 水道代_契約当月テキスト
                testController.screenProvisionalQuoteRecord.catvFullMonthText = 'CATV_契約当月テキスト(日割り無し)';                             // CATV_契約当月テキスト
                testController.screenProvisionalQuoteRecord.garbageDisposalFullMonthText = 'ゴミ処理費_契約当月テキスト(日割り無し)';             // ゴミ処理費_契約当月テキスト
                testController.screenProvisionalQuoteRecord.bicycleParkingFullMonthText = '駐輪場代_契約当月テキスト(日割り無し)';                // 駐輪場代_契約当月テキスト
                testController.screenProvisionalQuoteRecord.parkingFullMonthText = '駐車場代_契約当月テキスト(日割り無し)';                       // 駐車場代_契約当月テキスト
                testController.screenProvisionalQuoteRecord.bikeStorageSmallFullMonthText = 'バイク置き場代（小型）_契約当月テキスト(日割り無し)'; // バイク置き場代（小型）_契約当月テキスト
                testController.screenProvisionalQuoteRecord.bikeStorageMediumFullMonthText = 'バイク置き場代（中型）_契約当月テキスト(日割り無し)';// バイク置き場代（中型）_契約当月テキスト
                testController.screenProvisionalQuoteRecord.bikeStorageLargeFullMonthText = 'バイク置き場代（大型）_契約当月テキスト(日割り無し)'; // バイク置き場代（大型）_契約当月テキスト
                testController.screenProvisionalQuoteRecord.depositFullMonthText = '月額保証料（初回）_契約当月テキスト(日割り無し)';              // 月額保証料（初回）_契約当月テキスト
                testController.screenProvisionalQuoteRecord.fireInsuranceFullMonthText = '保険料（火災）_契約当月テキスト(日割り無し)';            // 保険料（火災）_契約当月テキスト
                testController.saveDate();

                List<ProvisionalQuote__c> provisionalList = [
                    SELECT id
                    ,RentFullMonthText__c
                    ,ManagementFullMonthText__c
                    ,TownshipFullMonthText__c
                    ,WaterFullMonthText__c
                    ,CatvFullMonthText__c
                    ,GarbageDisposalFullMonthText__c
                    ,BicycleParkingFullMonthText__c
                    ,ParkingFullMonthText__c
                    ,BikeStorageSmallFullMonthText__c
                    ,BikeStorageMediumFullMonthText__c
                    ,BikeStorageLargeFullMonthText__c
                    ,DepositFullMonthText__c
                    ,FireInsuranceFullMonthText__c
                    FROM ProvisionalQuote__c ];
                ProvisionalQuote__c result = provisionalList.get(0);
                System.assertEquals(result.RentFullMonthText__c, '家賃_契約当月テキスト(日割り無し)');
                System.assertEquals(result.ManagementFullMonthText__c, '管理費_契約当月テキスト(日割り無し)');
                System.assertEquals(result.TownshipFullMonthText__c, '町会費_契約当月テキスト(日割り無し)');
                System.assertEquals(result.WaterFullMonthText__c, '水道代_契約当月テキスト(日割り無し)');
                System.assertEquals(result.CatvFullMonthText__c, 'CATV_契約当月テキスト(日割り無し)');
                System.assertEquals(result.GarbageDisposalFullMonthText__c, 'ゴミ処理費_契約当月テキスト(日割り無し)');
                System.assertEquals(result.BicycleParkingFullMonthText__c, '駐輪場代_契約当月テキスト(日割り無し)');
                System.assertEquals(result.ParkingFullMonthText__c, '駐車場代_契約当月テキスト(日割り無し)');
                System.assertEquals(result.BikeStorageSmallFullMonthText__c, 'バイク置き場代（小型）_契約当月テキスト(日割り無し)');
                System.assertEquals(result.BikeStorageMediumFullMonthText__c, 'バイク置き場代（中型）_契約当月テキスト(日割り無し)');
                System.assertEquals(result.BikeStorageLargeFullMonthText__c, 'バイク置き場代（大型）_契約当月テキスト(日割り無し)');
                System.assertEquals(result.DepositFullMonthText__c, '月額保証料（初回）_契約当月テキスト(日割り無し)');
                System.assertEquals(result.FireInsuranceFullMonthText__c, '保険料（火災）_契約当月テキスト(日割り無し)');
                
                List<ProvisionalQuoteManageCompayItem__c> ItemDetailList = [
                    SELECT id,
                    SystemModstamp,
                    ManagementCompanyItem__r.ItemName__c,
                    ManagementCompanyItem__r.PaymentType__c,
                    ManagementCompanyItem__r.TaxType__c,
                    DailyFee__c,
                    ProvisionalQuoteItemNextMonthText__c,
                    ProvisionalQuoteItemThisMonthText__c,
                    ProvisionalQuoteItemFullMonthText__c,
                    Fee__c,
                    NextFee__c,
                    ManagementCompanyItem__c
                    FROM ProvisionalQuoteManageCompayItem__c
                    // WHERE ProvisionalQuote__c = :ProvisionalQuoteId
                ];
                ProvisionalQuoteManageCompayItem__c resultCompanyItem = ItemDetailList.get(0);
                System.assertEquals(resultCompanyItem.ProvisionalQuoteItemFullMonthText__c, '仮見積指定商品_契約当月テキスト(日割り無し)');
                Test.stopTest();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
    }

    // DB保存内容確認　日割りあり
    @isTest static void saveProvisionalQuoteProratedTest() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                        ,LastName 
                        ,Alias
                        ,Email
                        ,UserName
                        ,CommunityNickname
                        ,EmailEncodingKey
                        ,TimeZoneSidKey 
                        ,LocaleSidKey 
                        ,LanguageLocaleKey
                        ,ProfileId 
                        FROM User
                        WHERE LastName = 'ippanUser' 
            ];
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
            LIMIT  1
        ];

        ProvisionalQuote__c ProvisionalQuote = [SELECT Id
                        FROM ProvisionalQuote__c
                        WHERE Account__c = :AccountRecord.id
                        LIMIT  1

        ];

        ManagementCompanyItem__c managementCompanyItem = new ManagementCompanyItem__c(
            Account__c = AccountRecord.id,
            PaymentType__c = CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH
        );
        insert managementCompanyItem;


        ProvisionalQuoteManageCompayItem__c provisionalQuoteManageCompayItem = new ProvisionalQuoteManageCompayItem__c(
            ProvisionalQuote__c = provisionalQuote.id,
            ProvisionalQuoteItemNextMonthText__c = '仮見積指定商品_契約次月テキスト',
            ProvisionalQuoteItemThisMonthText__c = '仮見積指定商品_契約当月テキスト',
            ProvisionalQuoteItemFullMonthText__c = '仮見積指定商品_契約当月テキスト(日割り無し)',
            ManagementCompanyItem__c = managementCompanyItem.id
        );
        insert provisionalQuoteManageCompayItem;

        Property__c PropertyRecord = [SELECT Id
                        FROM Property__c
                        WHERE name = '物件A'
                        LIMIT  1

        ];  

        Map<String, Item__c> itemMap = readItemC();
        Item__c auxiliaryFireInsurance     = itemMap.get('テスト1火災保険');
        Item__c auxiliaryDisinfection      = itemMap.get('消毒1');
        Item__c auxiliaryKeyExchange       = itemMap.get('鍵交換1');
        Item__c auxiliaryReliableSuppor    = itemMap.get('安心サポート1');
        Item__c auxiliaryFShot             = itemMap.get('Fショット1');
        Item__c auxiliaryAlsokLock         = itemMap.get('アルソック1');

        System.runAs(ippanUser){
            try {
                Test.startTest();
                // パラメータ設定
                PageReference pageRef = Page.GA102002View2;

                pageRef.getParameters().put('accountId',AccountRecord.Id );
                pageRef.getParameters().put('PropertyId',PropertyRecord.Id );
                pageRef.getParameters().put('SavedOutputFlag', 'true');
                pageRef.getParameters().put('HomeMovingDate', '2020/04/01');
                pageRef.getParameters().put('Proratedflag', 'true' );//true 日割り
                pageRef.getParameters().put('ProratedCalculationDay', '31');
                pageRef.getParameters().put('Parkingflag', 'true');
                pageRef.getParameters().put('ParkingNumberRequired', '1');
                pageRef.getParameters().put('ParkingFee', '1000');
                pageRef.getParameters().put('BicycleParkingFlag', 'true');
                pageRef.getParameters().put('BicycleParkingNumberRequired', '1');
                pageRef.getParameters().put('BicycleParkingFee', '2000');
                pageRef.getParameters().put('BikeParkingSmallFlag', 'true');
                pageRef.getParameters().put('BikeParkingSmallNumberRequired', '1');
                pageRef.getParameters().put('BikeParkingSmallFee', '3000');
                pageRef.getParameters().put('BikeParkingMediumFlag', 'true');
                pageRef.getParameters().put('BikeParkingMediumNumberRequired', '1');
                pageRef.getParameters().put('BikeParkingMediumFee', '4000');
                pageRef.getParameters().put('BikeParkinLargeFlag', 'true');
                pageRef.getParameters().put('BikeParkinLargeNumberRequired', '1');
                pageRef.getParameters().put('BikeParkinLargeFee', '5000');
                pageRef.getParameters().put('auxiliaryDepositPlan', '');      //保証プラン
                pageRef.getParameters().put('auxiliaryFireInsurance', auxiliaryFireInsurance.id);    //火災
                pageRef.getParameters().put('AuxiliaryItem1__c', auxiliaryDisinfection.id);     //室内消毒
                pageRef.getParameters().put('AuxiliaryItem2__c', auxiliaryKeyExchange.id);      //鍵交換費
                pageRef.getParameters().put('AuxiliaryItem3__c', auxiliaryReliableSuppor.id);   //安心サポート 
                pageRef.getParameters().put('AuxiliaryItem4__c', auxiliaryFShot.id);            //Fショット
                pageRef.getParameters().put('AuxiliaryItem5__c', auxiliaryAlsokLock.id );        //アルソック
                pageRef.getParameters().put('RenewalFeeShow', '更新料');
                pageRef.getParameters().put('CleaningFeeShow', 'クリーニング費');
                Test.setCurrentPage(pageRef);
                GA102002Controller2 testController = new GA102002Controller2();

                // 値の変更
                testController.screenProvisionalQuoteRecord.rentThisMonthText = '家賃_契約当月テキスト';                             // 家賃_契約当月テキスト
                testController.screenProvisionalQuoteRecord.managementThisMonthText = '管理費_契約当月テキスト';                     // 管理費_契約当月テキスト
                testController.screenProvisionalQuoteRecord.townshipThisMonthText = '町会費_契約当月テキスト';                       // 町会費_契約当月テキスト
                testController.screenProvisionalQuoteRecord.waterThisMonthText = '水道代_契約当月テキスト';                          // 水道代_契約当月テキスト
                testController.screenProvisionalQuoteRecord.catvThisMonthText = 'CATV_契約当月テキスト';                             // CATV_契約当月テキスト
                testController.screenProvisionalQuoteRecord.garbageDisposalThisMonthText = 'ゴミ処理費_契約当月テキスト';             // ゴミ処理費_契約当月テキスト
                testController.screenProvisionalQuoteRecord.bicycleParkingThisMonthText = '駐輪場代_契約当月テキスト';                // 駐輪場代_契約当月テキスト
                testController.screenProvisionalQuoteRecord.parkingThisMonthText = '駐車場代_契約当月テキスト';                       // 駐車場代_契約当月テキスト
                testController.screenProvisionalQuoteRecord.bikeStorageSmallThisMonthText = 'バイク置き場代（小型）_契約当月テキスト'; // バイク置き場代（小型）_契約当月テキスト
                testController.screenProvisionalQuoteRecord.bikeStorageMediumThisMonthText = 'バイク置き場代（中型）_契約当月テキスト';// バイク置き場代（中型）_契約当月テキスト
                testController.screenProvisionalQuoteRecord.bikeStorageLargeThisMonthText = 'バイク置き場代（大型）_契約当月テキスト'; // バイク置き場代（大型）_契約当月テキスト
                testController.screenProvisionalQuoteRecord.depositThisMonthText = '月額保証料（初回）_契約当月テキスト';              // 月額保証料（初回）_契約当月テキスト
                testController.screenProvisionalQuoteRecord.fireInsuranceThisMonthText = '保険料（火災）_契約当月テキスト';            // 保険料（火災）_契約当月テキスト
                testController.screenProvisionalQuoteRecord.Proratedflag = true;
                testController.saveDate();

                List<ProvisionalQuote__c> provisionalList = [
                    SELECT id
                    ,RentThisMonthText__c
                    ,ManagementThisMonthText__c
                    ,TownshipThisMonthText__c
                    ,WaterThisMonthText__c
                    ,CatvThisMonthText__c
                    ,GarbageDisposalThisMonthText__c
                    ,BicycleParkingThisMonthText__c
                    ,ParkingThisMonthText__c
                    ,BikeStorageSmallThisMonthText__c
                    ,BikeStorageMediumThisMonthText__c
                    ,BikeStorageLargeThisMonthText__c
                    ,DepositThisMonthText__c
                    ,FireInsuranceThisMonthText__c
                    FROM ProvisionalQuote__c ];
                ProvisionalQuote__c result = provisionalList.get(0);
                System.assertEquals(result.RentThisMonthText__c, '家賃_契約当月テキスト');
                System.assertEquals(result.ManagementThisMonthText__c, '管理費_契約当月テキスト');
                System.assertEquals(result.TownshipThisMonthText__c, '町会費_契約当月テキスト');
                System.assertEquals(result.WaterThisMonthText__c, '水道代_契約当月テキスト');
                System.assertEquals(result.CatvThisMonthText__c, 'CATV_契約当月テキスト');
                System.assertEquals(result.GarbageDisposalThisMonthText__c, 'ゴミ処理費_契約当月テキスト');
                System.assertEquals(result.BicycleParkingThisMonthText__c, '駐輪場代_契約当月テキスト');
                System.assertEquals(result.ParkingThisMonthText__c, '駐車場代_契約当月テキスト');
                System.assertEquals(result.BikeStorageSmallThisMonthText__c, 'バイク置き場代（小型）_契約当月テキスト');
                System.assertEquals(result.BikeStorageMediumThisMonthText__c, 'バイク置き場代（中型）_契約当月テキスト');
                System.assertEquals(result.BikeStorageLargeThisMonthText__c, 'バイク置き場代（大型）_契約当月テキスト');
                System.assertEquals(result.DepositThisMonthText__c, '月額保証料（初回）_契約当月テキスト');
                System.assertEquals(result.FireInsuranceThisMonthText__c, '保険料（火災）_契約当月テキスト');
                
                List<ProvisionalQuoteManageCompayItem__c> ItemDetailList = [
                    SELECT id,
                    SystemModstamp,
                    ManagementCompanyItem__r.ItemName__c,
                    ManagementCompanyItem__r.PaymentType__c,
                    ManagementCompanyItem__r.TaxType__c,
                    DailyFee__c,
                    ProvisionalQuoteItemNextMonthText__c,
                    ProvisionalQuoteItemThisMonthText__c,
                    ProvisionalQuoteItemFullMonthText__c,
                    Fee__c,
                    NextFee__c,
                    ManagementCompanyItem__c
                    FROM ProvisionalQuoteManageCompayItem__c
                    // WHERE ProvisionalQuote__c = :ProvisionalQuoteId
                ];
                ProvisionalQuoteManageCompayItem__c resultCompanyItem = ItemDetailList.get(0);
                System.assertEquals(resultCompanyItem.ProvisionalQuoteItemThisMonthText__c, '仮見積指定商品_契約当月テキスト');
                Test.stopTest();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
    }

    // -----------------------------------------------------------------------------------------------
    // ユーザーの読み込み
    // -----------------------------------------------------------------------------------------------
    private static User getIppanUser() {
        return [SELECT Id
                , LastName
                , Alias
                , Email
                , UserName
                , CommunityNickname
                , EmailEncodingKey
                , TimeZoneSidKey
                , LocaleSidKey
                , LanguageLocaleKey
                , ProfileId
                FROM User
                WHERE UserName = :USER_NAME
        ];
    }

    // -----------------------------------------------------------------------------------------------
    // ページ作成クラス
    // -----------------------------------------------------------------------------------------------
    private class TestPage {
        public Account              account     { get; set; }       // 取引先
        public ProvisionalQuote__c  pQuote      { get; set; }       // 仮見積もり
        public Property__c          property    { get; set; }       // 物件
        public Map<String, Item__c> itemMap     { get; set; }       // 商品
        public PageReference        pageRef     { get; set; }
        public GA102002Controller   ctrl        { get; set; }
        public GA102002Controller.ScreenItem screen { get; set; }

        public TestPage(String accountName, String propertyName) {
            // テスト用データの読み込み
            account     = [SELECT Id FROM Account WHERE Name = :accountName];
            property    = [SELECT Id FROM Property__c WHERE Name = :propertyName];
            pQuote      = [SELECT Id FROM ProvisionalQuote__c WHERE Account__c = :account.id AND Property__c = :property.Id];
            itemMap     = readItemC();

            // ページ作成
            pageRef = Page.GA102002View;
            pageRef.getParameters().put('AccountId',  account.Id );
            pageRef.getParameters().put('PropertyId', property.Id );
            Test.setCurrentPage(pageRef);

            // コントローラー作成
            ctrl = new GA102002Controller();
            screen = ctrl.screen;

            // エラーチェック
            checkError();
        }

        public Boolean hasError() {
            Boolean ret = ctrl.hasErrorMessage;
            ret = (ret == null)? false: ret;
            return ret;
        }

        public void checkError() {
            if (hasError() || ctrl.isOpenError) {
                for (ApexPages.Message msg :ApexPages.getMessages()) {
                    system.debug(msg.getDetail());
                }
                throw new BusinessLogicException();
            }
        }

        public String getErrorMessage() {
            return ApexPages.getMessages()[0].getDetail();
        }

        public void clearErrorMessage() {
            Test.clearApexPageMessages();
        }

        public void addParameter(String name, String value) {
            pageRef.getParameters().put(name, value);
            Test.setCurrentPage(pageRef);
        }
    }

    private class TestPage2 {
        public Account              account     { get; set; }       // 取引先
        public ProvisionalQuote__c  pQuote      { get; set; }       // 仮見積もり
        public Property__c          property    { get; set; }       // 物件
        public Map<String, Item__c> itemMap     { get; set; }       // 商品
        public PageReference        pageRef     { get; set; }
        public GA102002Controller2   ctrl        { get; set; }
        public GA102002Controller2.screenProvisionalQuote screen { get; set; }

        public TestPage2(String accountName, String propertyName) {
            // テスト用データの読み込み
            account     = [SELECT Id FROM Account WHERE Name = :accountName];
            property    = [SELECT Id FROM Property__c WHERE Name = :propertyName];
            pQuote      = selectPQuote(account.Id, property.Id);
            itemMap     = readItemC();

            // ページ作成
            pageRef = Page.GA102002View2;
        }

        public Boolean hasError() {
            Boolean ret = ctrl.hasErrorMessage;
            ret = (ret == null)? false: ret;
            return ret;
        }

        public void checkError() {
            if (hasError() || ctrl.isOpenError) {
                for (ApexPages.Message msg :ApexPages.getMessages()) {
                    system.debug(msg.getDetail());
                }
                throw new BusinessLogicException();
            }
        }

        public String getErrorMessage() {
            return ApexPages.getMessages()[0].getDetail();
        }

        public void clearErrorMessage() {
            Test.clearApexPageMessages();
        }

        public void createCtrl(Map<String, String> params) {
            for (String key: params.keySet()) {
                pageRef.getParameters().put(key, params.get(key));
            }
            Test.setCurrentPage(pageRef);

            // コントローラー作成
            ctrl = new GA102002Controller2();
            screen = ctrl.screenProvisionalQuoteRecord;

            // エラーチェック
            checkError();
        }

        public void createCtrlFromData() {
            Map<String, String> params = new Map<String, String> {
                    'accountId'                       => String.valueOf(account.Id)
                , 'PropertyId'                      => String.valueOf(property.Id)
                , 'SavedOutputFlag'                 => 'true'
                , 'HomeMovingDate'                  => String.valueOf(pQuote.ContractStartDate__c.format())
                , 'Proratedflag'                    => booleanToString(pQuote.IsProrated__c)
                , 'ProratedCalculationDay'          => CommonUtil.decimalToString(pQuote.ProratedMonthDays__c)
                , 'Parkingflag'                     => booleanToString(pQuote.IsParkingUse__c)
                , 'ParkingNumberRequired'           => CommonUtil.decimalToString(pQuote.ParkingRequiredNumber__c)
                , 'ParkingFee'                      => CommonUtil.decimalToString(pQuote.ParkingRequiredNumberFee__c)
                , 'BicycleParkingFlag'              => booleanToString(pQuote.IsBicycleParkingUse__c)
                , 'BicycleParkingNumberRequired'    => CommonUtil.decimalToString(pQuote.BicycleParkingRequiredNumber__c)
                , 'BicycleParkingFee'               => CommonUtil.decimalToString(pQuote.BicycleParkingRequiredNumberFee__c)
                , 'BikeParkingSmallFlag'            => booleanToString(pQuote.IsBikeStorageSmallUse__c)
                , 'BikeParkingSmallNumberRequired'  => CommonUtil.decimalToString(pQuote.BikeStorageSmallRequiredNumber__c)
                , 'BikeParkingSmallFee'             => CommonUtil.decimalToString(pQuote.BikeStorageSmallRequiredNumberFee__c)
                , 'BikeParkingMediumFlag'           => booleanToString(pQuote.IsBikeStorageMediumUse__c)
                , 'BikeParkingMediumNumberRequired' => CommonUtil.decimalToString(pQuote.BikeStorageMediumRequiredNumber__c)
                , 'BikeParkingMediumFee'            => CommonUtil.decimalToString(pQuote.BikeStorageMediumRequiredNumberFee__c)
                , 'BikeParkinLargeFlag'             => booleanToString(pQuote.IsBikeStorageLargeUse__c)
                , 'BikeParkinLargeNumberRequired'   => CommonUtil.decimalToString(pQuote.BikeStorageLargeRequiredNumber__c)
                , 'BikeParkinLargeFee'              => CommonUtil.decimalToString(pQuote.BikeStorageLargeRequiredNumberFee__c)
                , 'auxiliaryDepositPlan'            => pQuote.DepositItem__c
                , 'auxiliaryFireInsurance'          => pQuote.FireInsuranceItem__c
                , 'AuxiliaryItem1'                  => pQuote.AuxiliaryItem1__c
                , 'AuxiliaryItem2'                  => pQuote.AuxiliaryItem2__c
                , 'AuxiliaryItem3'                  => pQuote.AuxiliaryItem3__c
                , 'AuxiliaryItem4'                  => pQuote.AuxiliaryItem4__c
                , 'AuxiliaryItem5'                  => pQuote.AuxiliaryItem5__c
                , 'AuxiliaryItem6'                  => pQuote.AuxiliaryItem6__c
                , 'AuxiliaryItem7'                  => pQuote.AuxiliaryItem7__c
                , 'AuxiliaryItem8'                  => pQuote.AuxiliaryItem8__c
                , 'AuxiliaryItem9'                  => pQuote.AuxiliaryItem9__c
                , 'AuxiliaryItem10'                 => pQuote.AuxiliaryItem10__c
                , 'RenewalFeeShow'                  => pQuote.RenewalFeeShow__c
                , 'CleaningFeeShow'                 => pQuote.CleaningFeeShow__c
            };
            createCtrl(params);
        }

        public void createCtrlFromTestFullData() {
            Map<String, String> params = new Map<String, String> {
                  'accountId'                       => account.Id
                , 'PropertyId'                      => property.Id
                , 'SavedOutputFlag'                 => 'false'
                , 'HomeMovingDate'                  => String.valueOf(Date.today().format())
                , 'Proratedflag'                    => 'true'
                , 'ProratedCalculationDay'          => '30'
                , 'Parkingflag'                     => 'true'
                , 'ParkingNumberRequired'           => '1'
                , 'ParkingFee'                      => '10,001'
                , 'BicycleParkingFlag'              => 'true'
                , 'BicycleParkingNumberRequired'    => '2'
                , 'BicycleParkingFee'               => '10,002'
                , 'BikeParkingSmallFlag'            => 'true'
                , 'BikeParkingSmallNumberRequired'  => '3'
                , 'BikeParkingSmallFee'             => '10,003'
                , 'BikeParkingMediumFlag'           => 'true'
                , 'BikeParkingMediumNumberRequired' => '4'
                , 'BikeParkingMediumFee'            => '10,004'
                , 'BikeParkinLargeFlag'             => 'true'
                , 'BikeParkinLargeNumberRequired'   => '5'
                , 'BikeParkinLargeFee'              => '10,005'
                , 'auxiliaryDepositPlan'            => [select id from ItemDetail__c LIMIT  1].Id
                , 'auxiliaryFireInsurance'          => itemMap.get('テスト1火災保険').Id
                , 'RenewalFeeShow'                  => '更新料'
                , 'CleaningFeeShow'                 => '定額補修費'
                , 'AuxiliaryItem1'                  => itemMap.get('消毒1').Id
                , 'AuxiliaryItem2'                  => itemMap.get('消毒2').Id
                , 'AuxiliaryItem3'                  => itemMap.get('鍵交換1').Id
                , 'AuxiliaryItem4'                  => itemMap.get('安心サポート1').Id
                , 'AuxiliaryItem5'                  => itemMap.get('Fショット1').Id
                , 'AuxiliaryItem6'                  => itemMap.get('アルソック1').Id
                , 'AuxiliaryItem7'                  => itemMap.get('消毒1').Id
                , 'AuxiliaryItem8'                  => itemMap.get('消毒1').Id
                , 'AuxiliaryItem9'                  => itemMap.get('消毒1').Id
                , 'AuxiliaryItem10'                 => itemMap.get('消毒1').Id
            };
            createCtrl(params);
        }

        private String booleanToString(Boolean val) {
            return val? 'true': 'false';
        }
    }

    // -----------------------------------------------------------------------------------------------
    // データの読み込み
    // -----------------------------------------------------------------------------------------------
    private static Map<String, Item__c> readItemC() {
        Map<String, Item__c> itemMap = new Map<String, Item__c>();
        List<Item__c> records = [
            SELECT Id
            , AuxiliaryItemType__c              // 付帯商品種別
            , Account__r.Name                   // 付帯業者名
            , ItemName__c                       // 商品名
            , auxiliaryItemFeeTaxType__c        // 付帯料金税区分
            , auxiliaryItemFeeTax__c            // 付帯料金(税込)
            , auxiliaryItemFee__c               // 付帯料金
            FROM Item__c
        ];
        for (Item__c rec: records) {
            itemMap.put(rec.ItemName__c, rec);
        }
        return itemMap;
    }

    private static ProvisionalQuote__c selectPQuote(Id accountId, Id propertyId) {
        List<ProvisionalQuote__c> pQuoteList = [
            SELECT Id
            , ContractStartDate__c
            , IsProrated__c
            , ProratedMonthDays__c
            , IsParkingUse__c
            , ParkingRequiredNumber__c
            , ParkingRequiredNumberFee__c
            , IsBicycleParkingUse__c
            , BicycleParkingRequiredNumber__c
            , BicycleParkingRequiredNumberFee__c
            , IsBikeStorageSmallUse__c
            , BikeStorageSmallRequiredNumber__c
            , BikeStorageSmallRequiredNumberFee__c
            , IsBikeStorageMediumUse__c
            , BikeStorageMediumRequiredNumber__c
            , BikeStorageMediumRequiredNumberFee__c
            , IsBikeStorageLargeUse__c
            , BikeStorageLargeRequiredNumber__c
            , BikeStorageLargeRequiredNumberFee__c
            , DepositItem__c
            , FireInsuranceItem__c
            , AuxiliaryItem1__c
            , AuxiliaryItem2__c
            , AuxiliaryItem3__c
            , AuxiliaryItem4__c
            , AuxiliaryItem5__c
            , AuxiliaryItem6__c
            , AuxiliaryItem7__c
            , AuxiliaryItem8__c
            , AuxiliaryItem9__c
            , AuxiliaryItem10__c
            , AuxiliaryItemFee1__c
            , AuxiliaryItemFee2__c
            , AuxiliaryItemFee3__c
            , AuxiliaryItemFee4__c
            , AuxiliaryItemFee5__c
            , AuxiliaryItemFee6__c
            , AuxiliaryItemFee7__c
            , AuxiliaryItemFee8__c
            , AuxiliaryItemFee9__c
            , AuxiliaryItemFee10__c
            , RenewalFeeShow__c
            , CleaningFeeShow__c
            FROM ProvisionalQuote__c
            WHERE Account__c = :accountId
            AND Property__c = :propertyId
        ];

        if (pQuoteList.size() == 0) {
            return null;
        } else {
            return pQuoteList[0];
        }
    }

}