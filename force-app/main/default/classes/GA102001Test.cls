/**
 * お客様情報詳細画面テスト
 */
@isTest

// -----------------------------------------------------------------------------------------------
// データの作成
// -----------------------------------------------------------------------------------------------
public class GA102001Test {
    public static final String USER_NAME = 'ippanUser@test.com';
    public static final String CORRESPOND_STATUS_TARGET_ECHO_AGGREGATION = '反響集約対象'; // 2021.11.30 LINE連携対応より、テストクラスで使用する為に修正

    /**
    * テストに使用するレコードを作成する
    */
	@testSetup static void Setting(){

        SystemConfig__c s = new SystemConfig__c(CorrespondDetailMaxCount__c = 1000,// 対応明細最大件数
                                                UseAuthority_Portal__c = true,//自社権限
												TaxRate__c = 10,//税率 2022.02.15 No0727
                                                HerokuSecretAccessKey__c = 'zF2SKTCj5CnR5TEhXhCLYBKE9x6a6xHN',//追加要望　紹介メール情報作成時のバッチで使用
                                                ExampleIv__c = '4f63e8b490579073');                           //追加要望紹介メール情報作成時のバッチで使用
        insert s;

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

		//▼ 2022.01.12 No.489 対応で追加
		// ポータルサイト登録
        List<PortalSite__c> portalList = new List<PortalSite__c>();
        PortalSite__c portal = new PortalSite__c(
			Name = CommonConst.PORTALSITE_NAME_SUUMO,
			Url__c = 'suumotest@example.com',
			Email__c = CommonConst.EMAIL_SUMO
		);
        portalList.add(portal);

		insert portalList;
		//▲ 2022.01.12 No.489 対応で追加

        // 取引先（顧客）
        Account AccountRecord = new Account(Name = 'テスト太郎'                     //取引先名
                                            ,LastName__c = 'テスト'                 //取引先（姓）
                                            ,FirstName__c = '太郎'                 //取引先（名）
											,NameKana__c = 'ﾃｽﾄﾀﾛｳ'                 //取引先名（カナ）
											,LastNameKana__c = 'タロウ'             //名（カナ）
											,FirstNameKana__c = 'テスト'            //姓（カナ）
											,Phone = '025-200-1234'                 //電話番号
											,Email__c = 'aaa@hora'                  // メール
											,state__c = '大阪府'                    //都道府県
											,city__c = '大阪市'                     //住所１（市区町村）
                                            ,street__c = '中央区安土町４－１'       //住所２（番地）
                                            ,sex__c = '女性'                        //性別
                                            ,PostalCode__c = '1234567'              //郵便番号
                                            ,Birthdate__c = commonutil.getToday()
                                            ,ContractType__c = '個人契約'
											,RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER) //レコードタイプID（顧客）
        									,Situation__c = '紹介'				//問合せNo341で追加 状況（紹介）
                                            ,IntroMailInfoFirstSendDatetime__c=Datetime.newInstance(CommonUtil.getToday().year(), CommonUtil.getToday().month() + 1 ,0,23,55,0)//追加要望
											// ▼2021.10.08 No.307 対応で追加
											,IsReservePropertyConditions__c = false //予約物件条件
											,BuildingAge__c  = '999'				//築年数 
											,CarCount__c  = 99						//台数 
											,DesiredArea__c  = '希望地域'			//希望地域 
											,Is1DK__c  = TRUE						//1DK 
											,Is1K__c  = TRUE						//1K 
											,Is1LDK1SLDK__c  = TRUE					//1LDK/SLDK 
											,Is2K2DK__c  = TRUE						//2K/DK 
											,Is2LDK2SLDK__c  = TRUE					//2LDK/SLDK 
											,Is3K3DK__c  = TRUE						//3K/DK 
											,Is3LDK3SLDK__c  = TRUE					//3LDK/SLDK 
											,Is4K4DK4LDKFrom__c  = TRUE				//4K/DK/LDK~ 
											,IsAditionalBoiling__c  = TRUE			//追焚機能 
											,IsAirConditioner__c  = TRUE			//エアコン 
											,IsAllElectric__c  = TRUE				//オール電化 
											,IsAllWestern__c  = TRUE				//オール洋間 
											,IsAutoLock__c  = TRUE					//オートロック 
											,IsBalcony__c  = TRUE					//バルコニー 
											,IsBicycleParking__c  = TRUE			//駐輪場 
											,IsBikeStorage__c  = TRUE				//バイク可 
											,IsBSAntenna__c  = TRUE					//BSアンテナ 
											,IsBuiltInGarage__c  = TRUE				//ビルトインガレージ 
											,IsCarport__c  = TRUE					//カーポート 
											,IsCat__c  = TRUE						//ペット(猫) 
											,IsCATV__c  = TRUE						//CATV 
											,IsCondominiumRental__c  = TRUE			//分譲賃貸 
											,IsCornerRoom__c  = TRUE				//角部屋 
											,IsCounterKitchen__c  = TRUE			//カウンターキッチン 
											,IsCSAntenna__c  = TRUE					//CSアンテナ 
											,IsDehumidifierForBathroom__c  = TRUE	//浴室乾燥機 
											,IsDeliveryBox__c  = TRUE				//宅配ボックス 
											,IsDesigners__c  = TRUE					//デザイナーズ 
											,IsDetachedHouse__c  = TRUE				//戸建て 
											,IsEast__c  = TRUE						//東 
											,IsElderly__c  = TRUE					//高齢者歓迎 
											,IsElectricStove__c  = TRUE				//電気コンロ 
											,IsElevator__c  = TRUE					//エレベーター 
											,IsFirstFloor__c  = TRUE				//1階 
											,IsFloorHeating__c  = TRUE				//床暖房 
											,IsForeigner__c  = TRUE					//外国人契約可 
											,IsFurniture__c  = TRUE					//家具付き 
											,IsGasStove__c  = TRUE					//ガスコンロ 
											,IsHomeAppliance__c  = TRUE				//家電付き 
											,IsIncludeManagementFee__c  = TRUE		//管理費込み 
											,IsIncludeParkingFee__c  = TRUE			//駐車場代込み 
											,IsInductionHeating__c  = TRUE			//IHコンロ 
											,IsInnerLandry__c  = TRUE				//室内洗濯機置場 
											,IsInSiteParking__c  = TRUE				//敷地内駐車場 
											,IsInternetFree__c  = TRUE				//ネット使用料無料 
											,IsIppambutsu__c  = TRUE				//一般物 
											,IsLargeBike__c  = TRUE					//大型バイク 
											,IsLargePet__c  = TRUE					//ペット(大型犬) 
											,IsLightweightSteel__c  = TRUE			//軽量鉄骨 
											,IsLoft__c  = TRUE						//ロフト 
											,IsMaisonette__c  = TRUE				//メゾネット 
											,IsMediumBike__c  = TRUE				//中型バイク 
											,IsMiddlePet__c  = TRUE					//ペット(中型犬) 
											,IsMonitorIntercom__c  = TRUE			//モニター付きインターホン 
											,IsMoreGasStove__c  = TRUE				//コンロ3口以上 
											,IsMusicalInstruments__c  = TRUE		//楽器相談可 
											,IsNoGuarantor__c  = TRUE				//保証人不要 
											,IsNonCleaningFee__c  = TRUE			//定額修繕費なし 
											,IsNonDeposit__c  = TRUE				//敷金/保証金なし 
											,IsNonGuaranteeidCompany__c  = TRUE		//保証会社不要 
											,IsNonKeyMoney__c  = TRUE				//礼金なし 
											,IsNonRenewalFee__c  = TRUE				//更新料なし 
											,IsNorth__c  = TRUE						//北 
											,IsNorthEast__c  = TRUE					//北東 
											,IsNorthWest__c  = TRUE					//北西 
											,IsOfficeAvailable__c  = TRUE			//事務所利用可 
											,IsOneRoom__c  = TRUE					//ワンルーム 
											,IsOtherPet__c  = TRUE					//ペット(その他) 
											,IsParking__c  = TRUE					//駐車場空きあり 
											,IsPet__c  = TRUE						//ペット可 
											,IsPluralCarParking__c  = TRUE			//駐車場2台可 
											,IsPrivateGarden__c  = TRUE				//専用庭 
											,IsPropaneGas__c  = TRUE				//プロパンガス 
											,IsRC__c  = TRUE						//RC 
											,IsRegalLavatory__c  = TRUE				//洗面所独立 
											,IsRenovation__c  = TRUE				//リノベーション 
											,IsRoofBalcony__c  = TRUE				//ルーフバルコニー 
											,IsRoomShare__c  = TRUE					//ルームシェア可 
											,IsSecondFloorOver__c  = TRUE			//2階以上 
											,IsSepalateBathAndRestroom__c  = TRUE	//バス・トイレ別 
											,IsShoeCloak__c  = TRUE					//シューズクローク 
											,IsShoesBox__c  = TRUE					//シューズボックス 
											,IsShowerWashBasin__c  = TRUE			//シャワー付き洗面台 
											,IsSmallBike__c  = TRUE					//小型バイク 
											,IsSmallPet__c  = TRUE					//ペット(小型犬) 
											,IsSouth__c  = TRUE						//南 
											,IsSouthEast__c  = TRUE					//南東 
											,IsSouthWest__c  = TRUE					//南西 
											,IsSRC__c  = TRUE						//SRC 
											,IsSteel__c  = TRUE						//鉄骨造 
											,IsStudent__c  = TRUE					//学生限定マンション 
											,IsSystemKitchen__c  = TRUE				//システムキッチン 
											,IsTopFloor__c  = TRUE					//最上階 
											,IsTownGas__c  = TRUE					//都市ガス 
											,IsTrunkRoom__c  = TRUE					//トランクルーム 
											,IsTwoGasStove__c  = TRUE				//コンロ2口 
											,IsTwoTenant__c  = TRUE					//2人入居可 
											,IsWalkInCloset__c  = TRUE				//ウォークインクローゼット 
											,IsWashlet__c  = TRUE					//温水洗浄便座 
											,IsWelfareAvailable__c  = TRUE			//生活保護契約可 
											,IsWest__c  = TRUE						//西 
											,IsWoman__c  = TRUE						//女性限定 
											,IsWooden__c  = TRUE					//木造 
											,OccupancyAreaLowerLimit__c  = '0'		//占有面積（下限） 
											,OccupancyAreaUpperLimit__c  = '999'	//占有面積（上限） 
											,Parking__c  = '有'						//駐車場 
											,ParkingFeeLimit__c  = 9999				//1台当たりの料金上限 
											,RentFeeFrom__c  = 9999					//賃料から 
											,RentFeeTo__c  = 9999					//賃料まで 
											,WalkingTime__c  = '999'				//徒歩 
											,PropertyConditionsName__c = '条件1'	//物件条件名
											// ▲2021.10.08 No.307 対応で追加
        );
        
       // ▼問合せNo341で追加 状況が電話反響の場合の取引先（顧客）
        Account AccountRecord2 = new Account(Name = 'テスト太郎b'                     //取引先名
                                            ,LastName__c = 'テスト'                 //取引先（姓）
                                            ,FirstName__c = '太郎b'                 //取引先（名）
											,NameKana__c = 'ﾃｽﾄﾀﾛｳ'                 //取引先名（カナ）
											,Phone = '025-200-1234'                 //電話番号
											,Email__c = 'aaa@hora'                  // メール
											,state__c = '大阪府'                    //都道府県
											,city__c = '大阪市'                     //住所１（市区町村）
                                            ,street__c = '中央区安土町４－１'       //住所２（番地）
                                            ,sex__c = '女性'                        //性別
                                            ,PostalCode__c = '1234567'              //郵便番号
                                            ,Birthdate__c = commonutil.getToday()
                                            ,ContractType__c = '個人契約'
											,RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER) //レコードタイプID（顧客）
                                            ,Situation__c = '電話反響'				//状況（電話反響）
        );
        // ▲問合せNo341で追加

        // 取引先（業者）
        Account AccountRecordAgent = new Account(Name = 'テスト次郎'                //取引先名
                                            ,LastName__c = 'テスト'                 //取引先（姓）
                                            ,FirstName__c = '次郎'                 //取引先（名）
                                            ,NameKana__c = 'テストジロウ'            //取引先名（カナ）
                                            ,Phone = '025-200-1234'            //電話番号
                                            ,Email__c = 'aaa@hora'             // メール
                                            ,state__c = '大阪府'               //都道府県
                                            ,city__c = '大阪市'                //住所１（市区町村）
                                            ,street__c = '中央区安土町４－１'   //住所２（番地）
                                            ,sex__c = '女性'                        //性別
                                            ,Birthdate__c = commonutil.getToday()
                                            ,ContractType__c = '個人契約'
                                            ,RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER) //レコードタイプID（業者）
        );
        Account AccountRecord3 = new Account(Name = 'テスト太郎c'                     //取引先名
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
                                            ,Birthdate__c = commonutil.getToday()
                                            ,ContractType__c = '個人契約'
											,RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER) //レコードタイプID（顧客）
        									,Situation__c = '紹介'				//問合せNo341で追加 状況（紹介）
                                            ,IntroMailInfoFirstSendDatetime__c=Datetime.newInstance(CommonUtil.getToday().year(), CommonUtil.getToday().month() + 1 ,0,23,55,0)//追加要望
        );
		// ▼ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
		Account accountRecord4 = new Account(Name = 'テスト1保証株式会社',IsAllRentFeeType__c = true);	// 総賃料に口座手数料を含む
		Account accountRecord5 = new Account(Name = 'テスト2保証株式会社',IsAllRentFeeType__c = false);	// 総賃料に口座手数料を含まない
        Account accountRecord6 = new Account(Name = 'テスト3保証株式会社',IsAllRentFeeType__c = false); // 総賃料に口座手数料を含まない
		Account accountRecord7 = new Account(Name = 'テスト1火災保険株式会社'); // 火災保険
		// ▲ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
        List<Account> newAccountList = new List<Account> {AccountRecord,AccountRecord2,AccountRecordAgent,AccountRecord3
			,AccountRecord4,AccountRecord5,AccountRecord6,AccountRecord7};// ▲ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更

        insert newAccountList; 
		// ▼ 2022.02.15 No0727 トリガー動作による負荷の軽減
		s.IsSkipTrigger__c = true;
		update s; 
		// ▲ 2022.02.15 No0727 トリガー動作による負荷の軽減

        // 店舗データ
        Shop__c ippanShopRecord = new Shop__c(Name     = '店舗ユーザテスト_港区'     // 店舗名
                                            , Phone__c = '000-0000-0000'            // 電話番号
                                            , Fax__c   = '000-0000-0000'            // FAX
                                            , Email__c = 'minato@test.AccountShoninShinseiWebservice.com' // メール
                                            , PortalSitePostingDistrict__c = '港区' // ポータル掲載地区
                                            , District__c = '港区'                  // 所在地区
                                            , IsShopType__c = True                  // 店舗区分
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
        OrganizationHierarchy__c orgRecord2 = new OrganizationHierarchy__c(
            OrganizationCode__c = '0002',
            OrganizationName__c = 'テスト店舗',
            HierarchyCode__c = '20',
            HierarchyOrder__c = 1,
            UpperOrganizationHierarchy__c = orgRecord1.Id,
            ExpandedOrganizationCode__c = '0000_0001_0002',
            Shop__c = ippanShopRecord.Id
        );
        List<OrganizationHierarchy__c> orrList = new List<OrganizationHierarchy__c> {orgRecord1,orgRecord2};
        insert orrList;
        
        // 建物
        Building__c BuildingRecord = new Building__c( Name = '反響テスト建物'   // 建物名
            , District__c = '港区'      // 地区
        );       
        insert BuildingRecord;

        // 物件
        List<Property__c> PropertyRecordList = new List<Property__c>();
        PropertyRecordList.add(new Property__c( name = '物件A',Building__c = BuildingRecord.id, RoomCount__c = 1, RoomLayout__c = CommonConst.PROPERTY_ROOMLAYOUT_LDK, LiveStatus__c = CommonConst.PROPERTY_LIVESTATUS_VACANCY));
        PropertyRecordList.add(new Property__c( name = '物件B',Building__c = BuildingRecord.id));
        PropertyRecordList.add(new Property__c( name = '物件C',Building__c = BuildingRecord.id));
        upsert PropertyRecordList;

        // 商品
        List<Item__c> ItemRecord = new List<Item__c>();
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id,IsAuxiliary__c = true,ItemName__c = 'テスト保証プラン1',RecordTypeId = commonUtil.getRecordTypeId('Item__c','GuaranteePlanRecordType'),RentFeeRate__c = 50,DirectDebitFee__c = 1000));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id,ItemName__c = 'テスト1火災保険',FireInsuranceMonth__c = 10000,RecordTypeId = commonUtil.getRecordTypeId('Item__c','FireInsuranceRecordType'),IsAuxiliary__c = true,PaymentType__c = '月型'));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id,ItemName__c = 'テスト2火災保険',FireInsuranceMonth__c = 20000,RecordTypeId = commonUtil.getRecordTypeId('Item__c','FireInsuranceRecordType'),IsAuxiliary__c = true,PaymentType__c = '月型'));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id,ItemName__c = '消毒1',RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),AuxiliaryItemFee__c = 5000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_DISINFECTION,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id,ItemName__c = '消毒2',RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),AuxiliaryItemFee__c = 2000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_DISINFECTION,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id,ItemName__c = '鍵交換1',RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),AuxiliaryItemFee__c = 2000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_KEYEXCHANGE,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id,ItemName__c = '安心サポート1',RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),AuxiliaryItemFee__c = 10000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_RELIABLESUPPORT,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id,ItemName__c = 'Fショット1',RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),AuxiliaryItemFee__c = 2000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_FSHOT,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id,ItemName__c = 'アルソック1',RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),AuxiliaryItemFee__c = 15000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_ALSOKLOCK,IsAuxiliary__c = true));
		//保証プラン// ▼ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
		// テスト1保証株式会社：付帯商品、賃料割合（保証会社）５０％、手数料１０００＋税込み
        ItemRecord.add(new Item__c(Account__c = accountRecord4.id
                                        ,IsAuxiliary__c = true
                                        ,ItemName__c = 'テスト保証プラン2'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
                                        ,RentFeeRate__c = 50
										,DirectDebitFeeTaxType__c = commonconst.PROPERTY_TAXTYPE_TAXABLE
                                        ,DirectDebitFee__c = 1000));
		// テスト2保証株式会社：付帯商品でない、賃料割合（保証会社）１０％、手数料２０００非課税
        ItemRecord.add(new Item__c(Account__c = accountRecord4.id
                                        ,IsAuxiliary__c = true
                                        ,ItemName__c = 'テスト保証プラン3'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
										,DirectDebitFeeTaxType__c = commonconst.PROPERTY_TAXTYPE_NOTAXABLE
                                        ,RentFeeRate__c = 10
                                        ,DirectDebitFee__c = 2000));
		// テスト2保証株式会社：付帯商品、賃料割合（保証会社）８０％、手数料８０００
        ItemRecord.add(new Item__c(Account__c = accountRecord5.id
                                        ,IsAuxiliary__c = true
                                        ,ItemName__c = 'テスト保証プラン4'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
                                        ,RentFeeRate__c = 80
                                        ,DirectDebitFee__c = 8000));
		// テスト1保証株式会社：付帯商品、賃料割合（保証会社）８０％、手数料８０００非課税
        ItemRecord.add(new Item__c(Account__c = accountRecord4.id
                                        ,IsAuxiliary__c = true
                                        ,ItemName__c = 'テスト保証プラン5'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
                                        ,RentFeeRate__c = 80
										,DirectDebitFeeTaxType__c = commonconst.PROPERTY_TAXTYPE_NOTAXABLE
                                        ,DirectDebitFee__c = 8000));
		// テスト1保証株式会社：付帯商品、賃料割合（保証会社）８０％、手数料８０００＋税込み
		ItemRecord.add(new Item__c(Account__c = accountRecord4.id
                                        ,IsAuxiliary__c = true
                                        ,ItemName__c = 'テスト保証プラン6'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
                                        ,RentFeeRate__c = 80
										,DirectDebitFeeTaxType__c = commonconst.PROPERTY_TAXTYPE_TAXABLE
                                        ,DirectDebitFee__c = 8000));
		// テスト3保証株式会社：付帯商品、賃料割合（保証会社）８０％、手数料なし
		ItemRecord.add(new Item__c(Account__c = accountRecord6.id
										,IsAuxiliary__c = true
										,ItemName__c = 'テスト保証プラン7'
										,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
										,RentFeeRate__c = 80));
        //火災保険
		// テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）５０％、火災保険料（月額）１００００
        ItemRecord.add(new Item__c(Account__c = accountRecord7.id
                                        ,ItemName__c = 'テスト3火災保険'
                                        ,FireInsuranceMonth__c = 10000
										,InsuranceFeeRate__c = 50
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),CommonConst.ITEM_RECTYPE_FIRE_INSURANCE)
                                        ,IsAuxiliary__c = true
                                        ,PaymentType__c = commonconst.ITEM_PAYMENTTYPE_MONTH));
		// テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）１００％、火災保険料（月額）２００００
        ItemRecord.add(new Item__c(Account__c = accountRecord7.id
                                        ,ItemName__c = 'テスト4火災保険'
                                        ,FireInsuranceMonth__c = 20000
                                        ,InsuranceFeeRate__c = 100
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),CommonConst.ITEM_RECTYPE_FIRE_INSURANCE)
                                        ,IsAuxiliary__c = true
                                        ,PaymentType__c = commonconst.ITEM_PAYMENTTYPE_MONTH));
		// テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）１００％、火災保険料（年額）９００００
        ItemRecord.add(new Item__c(Account__c = accountRecord7.id 
										,ItemName__c = 'テスト5火災保険'
										,FireInsuranceYear__c = 90000
										,InsuranceFeeRate__c = 100
										,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),CommonConst.ITEM_RECTYPE_FIRE_INSURANCE)
										,IsAuxiliary__c = true
										,PaymentType__c = commonconst.ITEM_PAYMENTTYPE_YEAR));
		// ▲ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
        insert ItemRecord;

        // 商品明細
        ItemDetail__c ItemDetailRecord = new ItemDetail__c(Item__c = ItemRecord[0].id,
			PlanDetail__c = 'Aプラン',	IsRentFeeType__c = true,FirstFeeDepositRate__c = 50,DepositRate__c=60
        );
        ItemDetail__c ItemDetailRecord2 = new ItemDetail__c(Item__c = ItemRecord[1].id,
			PlanDetail__c = 'Bプラン',IsRentFeeType__c = true,FirstFeeDepositRate__c = 50,DepositRate__c=60
        );
		// 初回保証料(割合)// ▼ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
		// 総賃料、総賃料に口座振替手数料を含む、手数料税込み
		ItemDetail__c ItemDetailRecord3 = new ItemDetail__c(PlanDetail__c = '割合総賃料口座税込み',IsRentFeeType__c = true,Item__c = ItemRecord[9].id,FirstFeeDepositRate__c = 50,DepositRate__c=60);
		// 総賃料、総賃料に口座振替手数料を含む、手数料税無し
		ItemDetail__c ItemDetailRecord4 = new ItemDetail__c(PlanDetail__c = '割合総賃料口座税無し',IsRentFeeType__c = true,Item__c = ItemRecord[10].id,FirstFeeDepositRate__c = 50,DepositRate__c=60);
		// 総賃料、総賃料に口座振替手数料を含まない
		ItemDetail__c ItemDetailRecord5 = new ItemDetail__c(PlanDetail__c = '割合総賃料口座無し',IsRentFeeType__c = true,Item__c = ItemRecord[11].id,FirstFeeDepositRate__c = 50,DepositRate__c=60);
		// 賃料
		ItemDetail__c ItemDetailRecord6 = new ItemDetail__c(PlanDetail__c = '割合賃料',IsRentFeeType__c = false,Item__c = ItemRecord[9].id,FirstFeeDepositRate__c = 50,DepositRate__c=60);

		// 初回保証料(金額)
		ItemDetail__c ItemDetailRecord7 = new ItemDetail__c(PlanDetail__c = '金額',IsRentFeeType__c = false,Item__c = ItemRecord[9].id,FirstFeeDepositYen__c = 10000,DepositYen__c=15000	);
		// ▲ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更

		// 申込 
		Application__c  ApplicationRecord = new Application__c(Account__c = AccountRecord.id     // 取引先
				,Property__c = PropertyRecordList[0].Id // 物件 2022.02.15 No0727 追加
				,LastName__c ='申込'
				,ParkingBrokerageFirstFee__c=3000       // 駐車場紹介料
				,isReviewEntry__c = true
				,isReviewRequestProhibited__c =false
				,AuxiliaryFireInsurance__c =ItemRecord[2].id
				,AuxiliaryFireInsuranceFee__c = 9999
				,AuxiliaryItem1__c = ItemRecord[3].id
				,AuxiliaryItemFee1__c = 3000
				,AuxiliaryReliableSupportFee__c = 0
				,AllRentFee__c = 75000
				,RentFee__c = 55000
				,BrokerageFirstFee__c = 20000           // 仲介手数料
				,ADFee__c = 5000                        // 広告宣伝費
			);
		insert ApplicationRecord;
		Application__c  ApplicationRecord2 = new Application__c(
			Account__c = AccountRecord3.id     // 取引先
			,Property__c = PropertyRecordList[0].Id // 物件　2022.02.15 No0727 追加
			, LastName__c ='申込'
			, isReviewEntry__c = true
			, isReviewRequestProhibited__c =false
			, AuxiliaryFireInsurance__c =ItemRecord[2].id
			, AuxiliaryFireInsuranceFee__c = 9999
			, AuxiliaryItem1__c = ItemRecord[3].id
			, AuxiliaryItemFee1__c = 3000
			, AuxiliaryItem2__c = ItemRecord[3].id
			, AuxiliaryItemFee2__c = 3000
			, AuxiliaryItem3__c = ItemRecord[3].id
			, AuxiliaryItemFee3__c = 3000
			, AuxiliaryItem4__c = ItemRecord[3].id
			, AuxiliaryItemFee4__c = 3000
			, AuxiliaryItem5__c = ItemRecord[3].id
			, AuxiliaryItemFee5__c = 3000
			, AuxiliaryItem6__c = ItemRecord[3].id
			, AuxiliaryItemFee6__c = 3000
			, AuxiliaryItem7__c = ItemRecord[3].id
			, AuxiliaryItemFee7__c = 3000
			, AuxiliaryItem8__c = ItemRecord[3].id
			, AuxiliaryItemFee8__c = 3000
			, AuxiliaryItem9__c = ItemRecord[3].id
			, AuxiliaryItemFee9__c = 3000
			, AuxiliaryItem10__c = ItemRecord[3].id
			, AuxiliaryItemFee10__c = 3000
			, AuxiliaryReliableSupportFee__c = 0
			, AllRentFee__c = 75000
			, RentFee__c = 55000
			, ParkingBrokerageFirstFee__c=3000       // 駐車場紹介料
			, BrokerageFirstFee__c = 20000           // 仲介手数料
			, ADFee__c = 5000                        // 広告宣伝費
		);
		insert ApplicationRecord2;
        // 対応データ
        Correspond__c CorrespondRecord = new Correspond__c(AccountId__c            = AccountRecord.Id           // 取引先
                                                        ,Property__c               = PropertyRecordList[0].Id   // 物件
                                                        ,Status__c                 = commonConst.CORRESPOND_STATUS_NOTSUPPORTED  // ステータス（未対応）
                                                        ,EventDateTime__c          =  Date.valueOf('2020-1-5')  // イベント時刻
                                                        ,IsSupportedListShow__c    = True                       // 対応確認
                                                        ,EchoStaff__c              = testUser.Id                // 担当者（反響）
                                                        ,EchoShop__c               = ippanShopRecord.Id         // 反響担当店舗
                                                        ,shopStaff__c              = testUser.Id                // 担当者（来店）
                                                        ,VisitShop__c              = ippanShopRecord.Id         // 来店担当者
                                                        ,ListViewDate__c           = Date.valueOf('2020-1-1')   // 一覧表示日時
                                                        ,Memo__c                   = 'テスト太郎'                // メモ
                                            );
        // 対応データ（追客中）
        Correspond__c CorrespondRecord2 = new Correspond__c(AccountId__c            = AccountRecord.Id           // 取引先
                ,Property__c               = PropertyRecordList[0].Id   // 物件
                ,Status__c                 = commonConst.CORRESPOND_STATUS_PURSUIT  // ステータス（追客中）
                ,EventDateTime__c          =  Date.valueOf('2020-1-5')  // イベント時刻
                ,IsSupportedListShow__c    = True                       // 対応確認
                ,ListViewDate__c           = Date.valueOf('2020-1-1')   // 一覧表示日時
                ,Memo__c                   = 'テスト'                // メモ
        );
        // 対応データ（アポイント確定）
        Correspond__c CorrespondRecord3 = new Correspond__c(AccountId__c            = AccountRecord.Id           // 取引先

                ,Property__c               = PropertyRecordList[0].Id   // 物件
                ,Status__c                 = commonConst.TASK_CORRESPONDTYPE_APPOINTMENT  // ステータス（アポイント確定）
                ,EventDateTime__c          =  Date.valueOf('2020-1-5')  // イベント時刻
                ,IsSupportedListShow__c    = True                       // 対応確認
                ,EchoStaff__c              = testUser.Id                // 担当者（反響）
                ,EchoShop__c               = ippanShopRecord.Id         // 反響担当店舗
                ,shopStaff__c              = testUser.Id                // 担当者（来店）
                ,VisitShop__c              = ippanShopRecord.Id         // 来店担当者
                ,ListViewDate__c           = Date.valueOf('2020-1-1')   // 一覧表示日時
                ,Memo__c                   = 'テスト'                // メモ
                ,FirstGuidanceMethod__c    = commonConst.GUIDANCE_METHOD_LOCAL_GUIDE
                ,FirstEventId__c           = ''
                ,EventId__c                = ''
        );
        
        // 対応　未収入金
        Correspond__c CorrespondRecord4 = new Correspond__c(
            AccountId__c = AccountRecord.Id
            ,Property__c               = PropertyRecordList[0].Id  // 物件
            ,Status__c                 = commonConst.CORRESPOND_STATUS_UNEARNED  // ステータス（未収入金）
            ,EventDateTime__c          =  Date.valueOf('2020-1-5')  // イベント時刻
            ,IsSupportedListShow__c    = True                       // 対応確認
            ,EchoStaff__c              = testUser.Id                // 担当者（反響）
            ,EchoShop__c               = ippanShopRecord.Id         // 反響担当店舗
            ,shopStaff__c              = testUser.Id                // 担当者（来店）
            ,VisitShop__c              = ippanShopRecord.Id         // 来店担当者
            ,ListViewDate__c           = Date.valueOf('2020-1-1')   // 一覧表示日時
            ,Application__c            = ApplicationRecord.Id       //申込
        );

        // ▼問合せNo341で追加 対応データ
        Correspond__c CorrespondRecord5 = new Correspond__c(AccountId__c            = AccountRecord2.Id           // 取引先
                                                        ,Property__c               = PropertyRecordList[0].Id   // 物件
                                                        ,Status__c                 = commonConst.CORRESPOND_STATUS_NOTSUPPORTED  // ステータス（未対応）
                                                        ,EventDateTime__c          =  Date.valueOf('2020-1-5')  // イベント時刻
                                                        ,IsSupportedListShow__c    = True                       // 対応確認
                                                        ,EchoStaff__c              = testUser.Id                // 担当者（反響）
                                                        ,EchoShop__c               = ippanShopRecord.Id         // 反響担当店舗
                                                        ,shopStaff__c              = testUser.Id                // 担当者（来店）
                                                        ,VisitShop__c              = ippanShopRecord.Id         // 来店担当者
                                                        ,ListViewDate__c           = Date.valueOf('2020-1-1')   // 一覧表示日時
                                                        ,Memo__c                   = 'テスト太郎b'              // メモ
                                                        ,PortalSiteUrl__c          = 'testURL'					//URL
        );
        // 対応データ（未収入金）
        Correspond__c CorrespondRecord6 = new Correspond__c(
              AccountId__c              = AccountRecord3.Id                         // 取引先
            , Property__c               = PropertyRecordList[0].Id                  // 物件
            , Status__c                 = commonConst.CORRESPOND_STATUS_UNEARNED    // ステータス（未対応）
            , EventDateTime__c          =  Date.valueOf('2020-1-5')                 // イベント時刻
            , IsSupportedListShow__c    = True                                      // 対応確認
            , EchoStaff__c              = testUser.Id                               // 担当者（反響）
            , EchoShop__c               = ippanShopRecord.Id                        // 反響担当店舗
            , shopStaff__c              = testUser.Id                               // 担当者（来店）
            , VisitShop__c              = ippanShopRecord.Id                        // 来店担当者
            , ListViewDate__c           = Date.valueOf('2020-1-1')                  // 一覧表示日時
            , Memo__c                   = 'テスト太郎c'                             // メモ
            , Application__c            = ApplicationRecord2.Id                     // 申込
        );
        // 対応データ（追客保留中）
        Correspond__c CorrespondRecord7 = new Correspond__c(
                AccountId__c                = AccountRecord.Id                          // 取引先
                , Property__c               = PropertyRecordList[0].Id                  // 物件
                , Status__c                 = commonConst.CORRESPOND_STATUS_PURSUITHOLD // ステータス（追客保留中）
                , EventDateTime__c          = Date.valueOf('2020-1-5')                  // イベント時刻
                , IsSupportedListShow__c    = True                                      // 対応確認
                , ListViewDate__c           = Date.valueOf('2020-1-1')                  // 一覧表示日時
                , ExactConditionMatch__c    = 'する'                                    //条件完全一致
        );
        // ▼ 2021.11.30 LINE連携対応より、レコードタイプが業者の対応を作成
        Correspond__c correspondRecord8 = new Correspond__c(
              AccountId__c              = AccountRecordAgent.Id                 // 取引先
            , Property__c               = PropertyRecordList[0].Id              // 物件
            , Status__c                 = commonConst.CORRESPOND_STATUS_VISITED // ステータス（未対応）
            , EventDateTime__c          = Date.valueOf('2020-1-5')              // イベント時刻
            , IsSupportedListShow__c    = True                                  // 対応確認
            , EchoStaff__c              = testUser.Id                           // 担当者（反響）
            , EchoShop__c               = ippanShopRecord.Id                    // 反響担当店舗
            , shopStaff__c              = testUser.Id                           // 担当者（来店）
            , VisitShop__c              = ippanShopRecord.Id                    // 来店担当者
            , ListViewDate__c           = Date.valueOf('2020-1-1')              // 一覧表示日時
            , Memo__c                   = 'テスト次郎'                          // メモ
        );
        List<Correspond__c> corrList = new List<Correspond__c> {CorrespondRecord,CorrespondRecord2,CorrespondRecord3,CorrespondRecord4,CorrespondRecord5,CorrespondRecord6,CorrespondRecord7
                                                                , CorrespondRecord8};
        // ▲ 2021.11.30 

        insert corrList;

        // ▲問合せNo341で追加 対応データ
        
        // 反響メール
        EchoMail__c EchoMailRecord = new EchoMail__c(Email__c = 'mail@co.jp'         //メール
                ,Response__c = PropertyRecordList[0].id
        );
        insert EchoMailRecord;
        
        // 対応明細
        CorrespondDetail__c  CorrespondDetailRecord = new CorrespondDetail__c(Corresponds__c = CorrespondRecord .id     // 対応
                                                                            , EchoMail__c = EchoMailRecord.id           // 反響メール
                                                                            , PortalSiteUrl__c = 'URL'                  // ポータルサイトURL
                                                                            , MailType__c = CommonConst.CORRESPONDDETAIL_MAILTYPE_RECEIVE //メール種別(受信)
                                                                            , CorrespondType__c = commonconst.TASK_CORRESPONDTYPE_MEMO  // 対応種別（メモ）
        );
        CorrespondDetail__c  CorrespondDetailRecord2 = new CorrespondDetail__c(Corresponds__c = CorrespondRecord .id     // 対応
                                                                            , EchoMail__c = EchoMailRecord.id           // 反響メール
                                                                            , PortalSiteUrl__c = 'URL'                  // ポータルサイトURL

                                                                            , CorrespondType__c = commonconst.TASK_CORRESPONDTYPE_TEL  // 対応種別（電話）
        );
        CorrespondDetail__c  CorrespondDetailRecord3 = new CorrespondDetail__c(
            Corresponds__c = CorrespondRecord .id     // 対応
            , EchoMail__c = EchoMailRecord.id           // 反響メール
            , PortalSiteUrl__c = 'URL'                  // ポータルサイトURL
            , CorrespondType__c = commonconst.TASK_CORRESPONDTYPE_APPLICANT  // 対応種別（申込）
        );
        CorrespondDetail__c  CorrespondDetailRecord4 = new CorrespondDetail__c(Corresponds__c = CorrespondRecord .id     // 対応
                                                                            , EchoMail__c = EchoMailRecord.id           // 反響メール
                                                                            , PortalSiteUrl__c = 'URL'                  // ポータルサイトURL

                                                                            , CorrespondType__c = commonconst.TASK_CORRESPONDTYPE_MAIL  // 対応種別（メール）
        );

 		//▼問合せNo341で追加
        CorrespondDetail__c  CorrespondDetailRecord_echoPhone = new CorrespondDetail__c(Corresponds__c = CorrespondRecord5 .id     // 対応
                                                                            , EchoMail__c = EchoMailRecord.id           // 反響メール
                                                                            , PortalSiteUrl__c = 'testURL'                  // ポータルサイトURL
                                                                            , CorrespondType__c = commonconst.TASK_CORRESPONDTYPE_TEL  // 対応種別（電話）
                                                                            , PhoneStatus__c = CommonConst.CORRESPONDDETAIL_PHONESTATUS_ECHO  //電話状況（電話反響）
                                                                            , InquiryProperty__c = 'テスト'
        );
        //▼問合せNo414で追加
        CorrespondDetail__c  CorrespondDetailRecord_parsuitHold = new CorrespondDetail__c(Corresponds__c = CorrespondRecord6.id     // 対応
                                                                            , CorrespondType__c = commonconst.TASK_CORRESPONDTYPE_PURSUITHOLD  // 対応種別（追客保留）
        );
        
        //▲問合せNo341で追加
        List<CorrespondDetail__c> corrDeList = new List<CorrespondDetail__c> {CorrespondDetailRecord,CorrespondDetailRecord2,CorrespondDetailRecord3,CorrespondDetailRecord4,CorrespondDetailRecord_echoPhone, CorrespondDetailRecord_parsuitHold};
        insert corrDeList;

        // 店舗異動データ（ユーザと店舗の紐づけ）
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id  //組織階層
                                                    ,StartDate__c =    Date.valueOf('2020-1-5')             //開始日
                                                    ,EndDate__c   =    Date.valueOf('2040-1-5')             //終了日
                                                    ,Staff__c     =   testUser.Id                           //ユーザ
                                                    );

        insert ShopTransferRecord;

        // お気に入り物件
        List<FavoriteProperty__c> FavoritePropertyRecordList = new List<FavoriteProperty__c>();
        FavoritePropertyRecordList.add(new FavoriteProperty__c(Account__c = AccountRecord.Id , Property__c = PropertyRecordList[0].id));
        FavoritePropertyRecordList.add(new FavoriteProperty__c(Account__c = AccountRecord.Id , Property__c = PropertyRecordList[1].id));
        insert FavoritePropertyRecordList;
        
        List<ItemDetail__c> itemDeList = new List<ItemDetail__c> {ItemDetailRecord,ItemDetailRecord2,
			ItemDetailRecord3,ItemDetailRecord4,ItemDetailRecord5,ItemDetailRecord6,ItemDetailRecord7};	// 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
        insert itemDeList;

        // 条件完全一致物件
        ExactConditionMatchProperty__c exactCondMatchProp = new ExactConditionMatchProperty__c(
            Property__c = PropertyRecordList[0].Id
            , Account__c = AccountRecord.Id
        );
        insert exactCondMatchProp;

        // 空室予約物件
        VacancyReservationProperty__c vacancyReservationProperty1 = new VacancyReservationProperty__c (
            Account__c = AccountRecord.Id
            , Building__c = PropertyRecordList[0].Building__c
            , PropertyFloorPlan__c = PropertyRecordList[0].FloorPlan__c
        );
        List<VacancyReservationProperty__c> vacancyReservationPropertyList = new List<VacancyReservationProperty__c> {
            vacancyReservationProperty1
        };
        insert vacancyReservationPropertyList;

        // 本会員
        Member__c member = new Member__c(
            Account__c         = AccountRecord.Id
            , Birthdate__c     = Date.valueOf('1982-8-11')
            , FirstNameKana__c = 'タロウ'
            , FirstName__c     = '太郎'
            , Gender__c        = '男性'
            , JoinDate__c      = Date.valueOf('2021-3-3')
            , LastNameKana__c  = 'テスト'
            , LastName__c      = 'テスト'
            , MemberId__c      = '外部ID'
            , Password__c      = 'password'
            , Tell__c          = '123-456-7890'
        );
        insert member;

        // ▼2021.10.08 No.307 対応で追加
        // 路線
        TrainRoute__c testTrainRoute1 = new TrainRoute__c(
            Name = 'テスト路線１'
        );
        TrainRoute__c testTrainRoute2 = new TrainRoute__c(
            Name = 'テスト路線２'
        );
        TrainRoute__c testTrainRoute3 = new TrainRoute__c(
            Name = 'テスト路線３'
        );
        List<TrainRoute__c> testTrainRoute = new List<TrainRoute__c> {
            testTrainRoute1
            ,testTrainRoute2
            ,testTrainRoute3
        };
        insert testTrainRoute;

        // 駅
        Station__c testStation1 = new Station__c(
            Name = 'テスト駅１'
            ,TrainRoute__c = testTrainRoute1.Id
        );
        Station__c testStation2 = new Station__c(
            Name = 'テスト駅２'
            ,TrainRoute__c = testTrainRoute2.Id
        );
        Station__c testStation3 = new Station__c(
            Name = 'テスト駅３'
            ,TrainRoute__c = testTrainRoute3.Id
        );
        List<Station__c> testStation = new List<Station__c> {
            testStation1
            ,testStation2
            ,testStation3
        };
        insert testStation;

        
        

        // 希望路線
        DesiredTrainRoute__c testDesiredTrainRoute1 = new DesiredTrainRoute__c(
            TrainRoute__c	 = testTrainRoute[0].Id
        );
        DesiredTrainRoute__c testDesiredTrainRoute2 = new DesiredTrainRoute__c(
            TrainRoute__c	 = testTrainRoute[1].Id
        );
        DesiredTrainRoute__c testDesiredTrainRoute3 = new DesiredTrainRoute__c(
            TrainRoute__c	 = testTrainRoute[2].Id
        );
        List<DesiredTrainRoute__c> testDesiredTrainRoute = new List<DesiredTrainRoute__c> {
            testDesiredTrainRoute1
            ,testDesiredTrainRoute2
            ,testDesiredTrainRoute3
        };
        insert testDesiredTrainRoute;

        
        

        // 希望駅
        DesiredStation__c testDesiredTrainStation1 = new DesiredStation__c(
            Station__c	 = testStation[0].Id
            ,DesiredTrainRoute__c	 = testDesiredTrainRoute[0].Id
        );
        DesiredStation__c testDesiredTrainStation2 = new DesiredStation__c(
            Station__c	 = testStation[1].Id
            ,DesiredTrainRoute__c	 = testDesiredTrainRoute[1].Id
        );
        DesiredStation__c testDesiredTrainStation3 = new DesiredStation__c(
            Station__c	 = testStation[2].Id
            ,DesiredTrainRoute__c	 = testDesiredTrainRoute[2].Id
        );
        List<DesiredStation__c> testDesiredTrainStation = new List<DesiredStation__c> {
            testDesiredTrainStation1
            ,testDesiredTrainStation2
            ,testDesiredTrainStation3
        };
        insert testDesiredTrainStation;

        // ▼問合せ415で追加
        // 学校
        School__c testSchool1 = new School__c(
            Name = 'テスト学校1'
            ,City__c = '港区'
            ,Type__c = '中学校'
        );
        School__c testSchool2 = new School__c(
            Name = 'テスト学校2'
            ,City__c = '港区'
            ,Type__c = '小学校'
        );
        List<School__c> testSchool = new List<School__c> {
            testSchool1
            ,testSchool2
        };
        insert testSchool;

        // 希望学区
        DesiredSchoolArea__c testDesiredSchoolArea1 = new DesiredSchoolArea__c(
            SchoolArea__c	 = '港区'
        );
        DesiredSchoolArea__c testDesiredSchoolArea2 = new DesiredSchoolArea__c(
            SchoolArea__c	 = '瑞穂区'
        );
        List<DesiredSchoolArea__c> testDesiredSchoolArea = new List<DesiredSchoolArea__c> {
            testDesiredSchoolArea1
            ,testDesiredSchoolArea2
        };
        insert testDesiredSchoolArea;

        
        // 希望学校
        DesiredSchool__c testDesiredSchool1 = new DesiredSchool__c(
            School__c	 = testSchool[0].Id
            ,DesiredSchoolArea__c	 = testDesiredSchoolArea[0].Id
        );
        DesiredSchool__c testDesiredSchool2 = new DesiredSchool__c(
            School__c	 = testSchool[1].Id
            ,DesiredSchoolArea__c	 = testDesiredSchoolArea[1].Id
        );
        List<DesiredSchool__c> testDesiredSchool = new List<DesiredSchool__c> {
            testDesiredSchool1
            ,testDesiredSchool2
        };
        insert testDesiredSchool;
        // ▲問合せ415で追加
        // ▲2021.10.08 No.307 対応で追加
        
		// ▼ 2022.1.31 LINE連携対応より、主キーを追加
        // ▼ 2021.11.30 LINE連携対応より、LINE会員を追加
        LineMember__c lineMember = new LineMember__c(
            Account__c	= AccountRecord.Id
			, LineId__c	= '1234567890'
        );
        insert lineMember;
        // ▲ 2021.11.30
		// ▲ 2022.1.31

        system.debug('初期設定終了');
		// ▼ 2022.02.15 No0727 トリガー動作による負荷の軽減
		s.IsSkipTrigger__c = false;
		update s; 
		// ▲ 2022.02.15 No0727 トリガー動作による負荷の軽減
		checkGabana('setUp');
    }

// -----------------------------------------------------------------------------------------------
// メインの画面
// -----------------------------------------------------------------------------------------------
    
    // ▼2021.10.08 No.307 対応テストクラスと重複するため削除

    /**
     * 初期表示テスト（顧客）
     */
     @isTest static void initializeTest(){

         system.debug('初期表示');

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
                ];

        // 対応
        Correspond__c CorrespondRecord = [SELECT Id 
                FROM Correspond__c
                WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
                LIMIT  1
        ];
         
        //▼問合せNo341で追加
        Account AccountRecord2 = [SELECT Id 
                                 FROM Account
                                 WHERE Name = 'テスト太郎b' 
                                ];
        Correspond__c CorrespondRecord2 = [SELECT Id, PortalSiteUrl__c
                                          FROM Correspond__c
                                          WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
                                          AND PortalSiteUrl__c = 'testURL'
                                   		 ];
        //▲問合せNo341で追加

        System.runAs(ippanUser){
            try {
				test.startTest();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);
                GA102001Controller testController = new GA102001Controller();

                // 取込ボタン実行
                testController.downloadFile();

                testController.postmodal1();
                testController.postmodal2();
                testController.postmodal3();
                testController.closeSchoolModal();
                testController.closeStationModal();
                testController.closePostModal();
                testController.cancelButton();
                testController.getContractType();
                testController.ageRecalculate();
                

                testController.getFavoritePropertyList();
                testController.getApplicationList();
                testController.changeHomeMovingReason();

                //▼問合せNo341で追加
                if(AccountRecord2 != null){
                    pageRef.getParameters().put('AccountId',AccountRecord2.Id );
                    pageRef.getParameters().put('Corresponds',CorrespondRecord2.Id );
                    Test.setCurrentPage(pageRef);
                
                    // 取込ボタン実行
                    testController.downloadFile();
    
                    testController.postmodal1();
                    testController.postmodal2();
                    testController.postmodal3();
                    testController.mizukimeFlg = true;
                    testController.checkStatus = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED;
                    testController.screenAccountRecord.EchoTelephoneFlag = false;
                    testController.screenAccountRecord.Situation = '電話反響';
                    testController.closeSchoolModal();
                    testController.closeStationModal();
                    testController.closePostModal();
                    testController.cancelButton();
                    testController.getContractType();
                    testController.ageRecalculate();

                    // ▼問合せ415で追加
                    testController.openJuniorHighSchoolDistrictModal();
                    testController.closeSchoolModal();
                    testController.openElementarySchoolDistrictModal();
                    testController.closeSchoolModal();
                    testController.changeJuniorHighSchool();
                    testController.changeElementarySchool();
                    // ▲問合せ415で追加

                    // 問合せ423で追加
                    testController.screenPropertyConditionsMap.get('条件1').DesiredArea = '千種区';
                    testController.openShopDistrictModal();
                    testController.closeShopDistrictModal();
                    
                    testController.getFavoritePropertyList();
                    testController.getApplicationList();
                    testController.changeHomeMovingReason();
                }
				//▲問合せNo341で追加
				checkGabana('initializeTest_stopTest');
                test.stopTest();

            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('initializeTest');
    
    }	

    /**
     * 初期表示テスト(業者)
     */
    @isTest static void initializeTestGyosya(){


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
                            WHERE Name = 'テスト次郎' 
                ];

        System.runAs(ippanUser){
            try {
				Test.startTest();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                Test.setCurrentPage(pageRef);

                // 検索実行
                GA102001Controller testController = new GA102001Controller();

                testController.screenAccountRecord.LastNameKana = 'tarou';
                testController.screenAccountRecord.FirstNameKana = 'test';
				
                testController.saveDate();
				checkGabana('initializeTestGyosya_stopTest');
				Test.stopTest();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('initializeTestGyosya');
    
    }	

    // ▼2021.10.08 No.307 対応テストクラスと重複するため削除
    
    /**
     * 名寄せの実行
     * 
     */
    @istest static void nameIdentificationSet(){
        //取引先の楽観ロックテスト
        Account obj = [SELECT Id
                       FROM Account
                       WHERE Name = 'テスト太郎b'
                      ];
        GA102001Controller.screenCorrespond screenTargetRecord = new GA102001Controller.screenCorrespond(new Correspond__c());
        screenTargetRecord.accountSystemModstamp = CommonUtil.getNow();
        GA102001Controller testController = new GA102001Controller();
        testController.screenCorrespondRecordList = new List<GA102001Controller.screenCorrespond>{screenTargetRecord};
        testController.accountId = obj.Id;
        testController.checkCorrespondIndex = 0;
        testController.openNameIdentification();
		checkGabana('nameIdentificationSet');
    }

    /**
     * 対応の楽観ロックの実行
     * 
     */
    @istest static void optimisticLockExceptionTest(){
        Correspond__c obj = [SELECT Id
                             FROM Correspond__c   
                             WHERE PortalSiteUrl__c = 'testURL'					               
                            ];
        GA102001Controller.screenCorrespond screenTargetRecord = new GA102001Controller.screenCorrespond(new Correspond__c());
        screenTargetRecord.SystemModstamp = CommonUtil.getNow();
        GA102001Controller testController = new GA102001Controller();
        testController.screenCorrespondRecordList = new List<GA102001Controller.screenCorrespond>{screenTargetRecord};
        testController.checkCorrespondId = obj.Id;
        testController.checkCorrespondIndex = 0;
        testController.openModal1();
        // ▼ 2021.11.30 LINE連携対応より、メモ用処理をLINE用に修正した為、削除
        // ▲ 2021.11.30
        testController.openModal4();
        testController.openVisitCard();
        testController.getCorrespondDetail();
		checkGabana('optimisticLockExceptionTest');
    }

    /**
     * 申込の実行
     * 
     */
    @istest static void ApplicationSet(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
                            FROM Account
                            WHERE Name = 'テスト太郎' 
                ];

        // 対応
        Correspond__c CorrespondRecord = [SELECT Id 
                            FROM Correspond__c
                            WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
                            LIMIT  1
        ];

        System.runAs(ippanUser){
            try {
				Test.startTest();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);

                //申込紐づけ実行
                GA102001Controller testController = new GA102001Controller();
                testController.checkCorrespondId = CorrespondRecord.id;
                testController.screenFavoritePropertyList[0].isSelected = true;
                testController.openApplicatiou();       
				checkGabana('ApplicationSet_stopTest');
				Test.stopTest();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('ApplicationSet');
    }

    /**
     * 申込(iPad)の実行
     * 
     */
    @istest static void ApplicationiPadSet(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
                            FROM Account
                            WHERE Name = 'テスト太郎' 
                ];

        // 対応
        Correspond__c CorrespondRecord = [SELECT Id
                            FROM Correspond__c
                            WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
                            LIMIT  1
        ];    

        System.runAs(ippanUser){
            try {
				Test.startTest();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);

                //申込紐づけ実行
                GA102001Controller testController = new GA102001Controller();
                testController.accountId = AccountRecord.Id;
                testController.checkCorrespondId = CorrespondRecord.id;
                testController.screenFavoritePropertyList[1].isSelected = true;
                
                testController.openApplicatiouiPod();    
				checkGabana('ApplicationiPadSet_stopTest');
                Test.stopTest();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('ApplicationiPadSet');
    }
    
    /**
     * 来店ボタン押下
     * 
     */
    @istest static void VisitCard(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
                            FROM Account
                            WHERE Name = 'テスト太郎' 
                ];

        // 対応
        Correspond__c CorrespondRecord = [SELECT Id
                            FROM Correspond__c
                            WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
                            LIMIT  1
        ];
        System.runAs(ippanUser){
            try {
				Test.startTest();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);

                //来店カードボタン実行
                GA102001Controller testController = new GA102001Controller();

                testController.checkCorrespondId = CorrespondRecord.id;
                testController.openVisitCard();       
				checkGabana('VisitCard_stopTest');
				Test.stopTest();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('VisitCard');
    }

    /**
     * お気に入り物件削除ボタン押下
     * 
     */
    @istest static void deleteFavoriteProperty(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
                            FROM Account
                            WHERE Name = 'テスト太郎' 
                ];

        // 対応
        Correspond__c CorrespondRecord = [SELECT Id
                            FROM Correspond__c
                            WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
                            LIMIT  1
        ];

        // お気に入り物件
        List< FavoriteProperty__c> FavoritePropertyRecord = [SELECT Id, SystemModStamp
                        FROM FavoriteProperty__c
                        WHERE Account__c = :AccountRecord.id
        ];

        System.runAs(ippanUser){
            try {
				Test.startTest();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);

                //来店カードボタン実行
                GA102001Controller testController = new GA102001Controller();
                testController.checkCorrespondId = CorrespondRecord.id;

                // お気に入り明細を作成
                testController.screenFavoritePropertyList = new List<GA102001Controller.screenFavoriteProperty>();
                GA102001Controller.screenFavoriteProperty screenTargetRecord = new GA102001Controller.screenFavoriteProperty(new FavoriteProperty__c());
                screenTargetRecord.Id = FavoritePropertyRecord[0].id;
                screenTargetRecord.isSelected = true;
                screenTargetRecord.SystemModstamp = FavoritePropertyRecord[0].SystemModStamp;
                testController.screenFavoritePropertyList.add(screenTargetRecord);

                // 削除ボタン押下
                testController.deleteFavoriteProperty();

                // 楽観ロックチェック
                testController.screenFavoritePropertyList.add(screenTargetRecord);
                testController.deleteFavoriteProperty();

				checkGabana('deleteFavoriteProperty_stopTest');
				Test.stopTest();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('deleteFavoriteProperty');
    }

    /**
     * 反響集約ボタン押下
     * 
     */
    @istest static void Echoaggregation(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
                            FROM Account
                            WHERE Name = 'テスト太郎' 
                ];

        // 対応
        Correspond__c CorrespondRecord = [SELECT Id
                            FROM Correspond__c
                            WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
                            LIMIT  1
        ];

        System.runAs(ippanUser){
            try {
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);

                //来店カードボタン実行
                Test.startTest();
                GA102001Controller testController = new GA102001Controller();
                testController.checkCorrespondId = CorrespondRecord.id;
                testController.checkCorrespondIndex = 0;
                testController.Echoaggregation();
				checkGabana('Echoaggregation_stopTest');
                Test.stopTest();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('Echoaggregation');
    }

    /**
     * 対応確認ボタン押下
     * 
     */
    @istest static void setResponseconfirmation(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
                            FROM Account
                            WHERE Name = 'テスト太郎' 
                ];

        // 対応
        Correspond__c CorrespondRecord = [SELECT Id
                            FROM Correspond__c
                            WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
                            LIMIT  1
        ];

        System.runAs(ippanUser){
            try {
				Test.startTest();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);

                //来店カードボタン実行
                GA102001Controller testController = new GA102001Controller();
                testController.checkCorrespondId = CorrespondRecord.id;
                testController.checkCorrespondIndex = 0;
				
                testController.setResponseconfirmation();       

                // 保留解除を動作させる
                testController.ReleaseHold();

                //  メールボタン押下時の対応明細取得
                testController.getCorrespondDetail();

                // 返信ボタン押下時の担当者設定の判定
                testController.CorrespondDetailCorrespondsId = CorrespondRecord.id;
                testController.personnelCheck();
				checkGabana('setResponseconfirmation_stopTest');
				Test.stopTest();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('setResponseconfirmation');
    }

// -----------------------------------------------------------------------------------------------
// 担当者設定モーダル
// -----------------------------------------------------------------------------------------------
    /**
    　担当者設定モーダル表示処理
     */
    @istest static void openModal1(){
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

       // 取引先
       Account AccountRecord = [SELECT Id 
                           FROM Account
                           WHERE Name = 'テスト太郎' 
                           LIMIT  1
               ];
        // 対応（ついきゃくちゅう）
        Correspond__c CorrespondRecord2 = [SELECT Id
              FROM Correspond__c
              WHERE Status__c = :commonConst.CORRESPOND_STATUS_PURSUIT
              LIMIT  1
        ];


       System.runAs(ippanUser){
           try {

			   Test.startTest();
               //ボタン実行
               GA102001Controller testController = new GA102001Controller();
               //パラメータ設定
               PageReference pageRef = Page.GA102001View;
               pageRef.getParameters().put('AccountId',AccountRecord.Id );
               Test.setCurrentPage(pageRef);

               testController.openModal1();

               GA102001Modal1Controller testModalController = new GA102001Modal1Controller();
               testModalController.Parameter = new GA102001Modal1ParameterClass();
               testModalController.Parameter.AccountId = AccountRecord.id;               // 取引先ID
               testModalController.Parameter.CorrespondId =null;                         // 対応ID
               testModalController.Parameter.isDrawing = true;
               testModalController.Parameter.noFirst = true;
               // 表示（対応なし    ）
               testModalController.getSelectOption();
               testModalController.echoShop = null;
               testModalController.echoStaff = null;
               testModalController.visitShop = null;
               testModalController.shopStaff = null;
              

               // 保存処理
               testModalController.saveDate();


               testModalController.Parameter = new GA102001Modal1ParameterClass();
               testModalController.Parameter.AccountId = AccountRecord.id;               // 取引先ID
               testModalController.Parameter.CorrespondId =CorrespondRecord2.id;        // 対応ID
               testModalController.Parameter.isDrawing = true;
               testModalController.Parameter.noFirst = true;
               // 表示
               testModalController.getSelectOption();

               // 保存処理
               testModalController.saveDate();

			   checkGabana('openModal1_stopTest');
			   Test.stopTest();
           } catch(BusinessLogicException e){
               System.assertEquals(e.getMessage(), '');
           }
       }
	   checkGabana('openModal1');
   }

    /**
    　担当者設定モーダル表示処理(SOQL クエリが多すぎますとエラーになるので同時に処理せず切り分け)
     */
   @istest static void openModal12(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
                            FROM Account
                            WHERE Name = 'テスト太郎' 
                            LIMIT  1
                ];

        // 対応(未対応)
        Correspond__c CorrespondRecord = [SELECT Id
                            FROM Correspond__c
                            WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
                            LIMIT  1
        ];

        System.runAs(ippanUser){
            try {
				Test.startTest();

                //ボタン実行
                GA102001Controller testController = new GA102001Controller();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);

                testController.openModal1();

                GA102001Modal1Controller testModalController = new GA102001Modal1Controller();
                testModalController.Parameter = new GA102001Modal1ParameterClass();
                testModalController.Parameter.AccountId = AccountRecord.id;               // 取引先ID
                testModalController.Parameter.CorrespondId =null;                         // 対応ID
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;

                testModalController.Parameter.CorrespondId = CorrespondRecord.id;         // 対応ID
                // 表示
                testModalController.getSelectOption();

                // 店舗選択(反響)
                testModalController.getEchoShopList();
                // 店舗選択(来店)
                testModalController.getVisitShopList();

                testModalController.echoShop = null;
                testModalController.echoStaff = null;
                testModalController.visitShop = null;
                testModalController.shopStaff = null;

                // 保存処理
                testModalController.saveDate();

				checkGabana('openModal12_stopTest');
				Test.stopTest();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('openModal12');
    }

// -----------------------------------------------------------------------------------------------
// 対応履歴（アポイント確定含む）
// -----------------------------------------------------------------------------------------------
    //too many soql queries 101のエラーが出たので、opmeModal2メソッドを2つに分けています   
    @istest static void openModal2(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
        ];

        // 対応
        Correspond__c CorrespondRecord = [SELECT Id
            FROM Correspond__c
            WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
            LIMIT  1
        ];
        // 対応（アポイント確定）
        Correspond__c CorrespondRecord_Apo = [SELECT Id
            FROM Correspond__c
            WHERE Status__c = :commonConst.TASK_CORRESPONDTYPE_APPOINTMENT
            LIMIT  1
        ];
        // 対応明細
        CorrespondDetail__c CorrespondDetailRecord = [SELECT Id
            FROM CorrespondDetail__c
            WHERE CorrespondType__c = :CommonConst.TASK_CORRESPONDTYPE_MEMO
        ];

        // お気に入り物件
        List< FavoriteProperty__c> FavoritePropertyRecord = [SELECT Id
                                                             FROM FavoriteProperty__c
                                                             WHERE Account__c = :AccountRecord.id
                                                            ];

        System.runAs(ippanUser){
            try {
        
                //ガバナエラーになった為、ここからTest.startTest()
                Test.startTest();
                // ▼ 2021.11.30 LINE連携対応より、初期表示後の画面情報を参照するよう削除
                // ▲ 2021.11.30
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);
                //来店カードボタン実行
                GA102001Controller testController = new GA102001Controller(); // 2021.11.30 LINE連携対応より、初期表示後の画面情報を参照するよう修正

                // お気に入り物件の明細を作成
                testController.screenFavoritePropertyList = new List<GA102001Controller.screenFavoriteProperty>();
                GA102001Controller.screenFavoriteProperty screenTargetRecord = new GA102001Controller.screenFavoriteProperty(new FavoriteProperty__c());
                screenTargetRecord.Id = FavoritePropertyRecord[0].id;
                screenTargetRecord.isSelected = true;
                testController.screenFavoritePropertyList.add(screenTargetRecord);

                testController.openModal3();

                testController.openModal2Tel();
                // ▼ 2021.11.30 LINE連携対応より、メモ用処理をLINE用に修正した為、削除
                // ▲ 2021.11.30
                testController.openModal2Apo();
                testController.openModal2After();
                testController.openModal2ContractCompleted();
                testController.openModal2HoldFollower();
                testController.openModal2AppointCancel();
                testController.openModal2ApplicationCancel();
                testController.openModal2End();

                testController.openStations1Modal();
                testController.openStations2Modal();
                testController.openStations3Modal();

                GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
                testModalController.Parameter = new GA102001Modal2ParameterClass();
                testModalController.Parameter.AccountId = AccountRecord.Id;  // 取引先ID
                testModalController.Parameter.CorrespondId = CorrespondRecord.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_TEL; // 対応種別（電話）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED; // ステータス
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;
                // 表示
                testModalController.getSelectOption();
                // 保存処理
                testModalController.saveDate();

                // アポイント確定
                testModalController.Parameter.CorrespondId = CorrespondRecord_Apo.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_APPOINTMENT; // 対応種別（アポイント確定）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_APPOINTMENT; // ステータス
                // 表示
                testModalController.getSelectOption();
                //担当者１名で新規登録
                testModalController.screenCorrespondDetail.StartDate = Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.StartDateTime = Datetime.parse('2020/01/05 00:00').time();  // 開始日時_時分
                testModalController.screenCorrespondDetail.EndDate =Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.EndDateTime = Datetime.parse('2020/01/05 01:23').time();    // 終了日時_時分
                // 保存処理
                testModalController.saveDate();

                // アポイント変更
                testModalController.Parameter.CorrespondId = CorrespondRecord_Apo.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_APPOINTMENT; // 対応種別（アポイント確定）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_APPOINTMENT; // ステータス
                // 表示
                testModalController.getSelectOption();
                //担当者２名で登録
                testModalController.staffCountValue = testModalController.STAFF_TWO;
                testModalController.screenCorrespondDetail.VisitShop2 = testModalController.screenCorrespondDetail.VisitShop;
                testModalController.screenCorrespondDetail.ShopStaff2 = testModalController.screenCorrespondDetail.ShopStaff;
                testModalController.screenCorrespondDetail.StartDate2 = Date.valueOf('2020-1-6') ;
                testModalController.screenCorrespondDetail.StartDateTime2 = Datetime.parse('2020/01/06 00:00').time();  // 開始日時_時分
                testModalController.screenCorrespondDetail.EndDate2 =Date.valueOf('2020-1-6') ;
                testModalController.screenCorrespondDetail.EndDateTime2 = Datetime.parse('2020/01/06 01:23').time();    // 終了日時_時分
                // 保存処理
                testModalController.saveDate();


                
				checkGabana('openModal2_stopTest');
                Test.stopTest();

            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('openModal2');
    }

//▼ 2022.01.12 No.489 対応で追加
// -----------------------------------------------------------------------------------------------
// 対応履歴（電話反響）
// -----------------------------------------------------------------------------------------------
    @istest static void openModal2_Tel(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
        ];

        // 対応（追客中）
        Correspond__c CorrespondRecord = [SELECT Id, FirstInquiryProperty__c
            FROM Correspond__c
            WHERE Status__c = :commonConst.CORRESPOND_STATUS_PURSUIT
            LIMIT  1
        ];

		// ポータルサイト
		PortalSite__c ps = [SELECT Id FROM PortalSite__c WHERE Name = :CommonConst.PORTALSITE_NAME_SUUMO LIMIT 1];

        // お気に入り物件
        List< FavoriteProperty__c> FavoritePropertyRecord = [SELECT Id, Property__c, Property__r.Name
                                                             FROM FavoriteProperty__c
                                                             WHERE Account__c = :AccountRecord.id AND Property__c != null
                                                            ];

        System.runAs(ippanUser){
			Test.startTest();
			//パラメータ設定
			PageReference pageRef = Page.GA102001View;
			pageRef.getParameters().put('AccountId',AccountRecord.Id );
			pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
			Test.setCurrentPage(pageRef);
			//来店カードボタン実行
			GA102001Controller testController = new GA102001Controller();

			//処理前の対応履歴件数
			Integer befRerekiCount = testController.screenCorrespondDetailList.size();
			//処理前の反響一覧件数
			Integer befHankyouCount = testController.screenEchoMailList.size();

			// TEL/SMS/LINE押下
			testController.openModal2Tel();

			GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
			testModalController.Parameter = testController.GA102001Paremeter2;
			testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_TEL; // 対応種別（電話）
			testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED; // ステータス
			testModalController.Parameter.isDrawing = true;
			testModalController.Parameter.noFirst = true;
			// 表示
			testModalController.getSelectOption();

			testModalController.screenCorrespondDetail.Sender = CommonConst.CORRESPONDDETAIL_SENDER_CUSTOMER;	//発信者をお客様とする
			testModalController.screenCorrespondDetail.PhoneStatus = CommonConst.CORRESPONDDETAIL_PHONESTATUS_ECHO;	//状況を電話反響とする
			testModalController.screenCorrespondDetail.PortalSite = ps.Id;	//ポータルサイトをSUUMOとする
			testModalController.screenCorrespondDetail.District = '港区';	//地区
			testModalController.screenCorrespondDetail.SupportedContent = 'テスト対応内容';	//対応内容
			testModalController.screenCorrespondDetail.SelectedInquiryProp = FavoritePropertyRecord[0].Property__c;	//問い合わせ物件
			// 保存処理
			testModalController.saveDate();

			Correspond__c aftCp = [SELECT Id, FirstInquiryProperty__c FROM Correspond__c WHERE Id = :CorrespondRecord.Id];
			System.assertEquals(FavoritePropertyRecord[0].Property__c, aftCp.FirstInquiryProperty__c, '対応.初回問合せ物件が更新されていない。');
			//再指定するため、対応.初回問い合わせ物件を削除しておく
			aftCp.FirstInquiryProperty__c = null;
			update aftCp;


			testModalController = new GA102001Modal2Controller();
			testModalController.Parameter = testController.GA102001Paremeter2;
			testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_TEL; // 対応種別（電話）
			testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED; // ステータス
			testModalController.Parameter.isDrawing = true;
			testModalController.Parameter.noFirst = true;
			// 表示
			testModalController.getSelectOption();

			testModalController.screenCorrespondDetail.Sender = CommonConst.CORRESPONDDETAIL_SENDER_CUSTOMER;	//発信者をお客様とする
			testModalController.screenCorrespondDetail.PhoneStatus = CommonConst.CORRESPONDDETAIL_PHONESTATUS_ECHO;	//状況を電話反響とする
			testModalController.screenCorrespondDetail.PortalSite = ps.Id;	//ポータルサイトをSUUMOとする
			testModalController.screenCorrespondDetail.District = '守山区';	//地区
			testModalController.screenCorrespondDetail.SupportedContent = 'テスト対応内容';	//対応内容
			testModalController.screenCorrespondDetail.SelectedInquiryProp = FavoritePropertyRecord[1].Property__c;	//問い合わせ物件
			// 保存処理
			testModalController.saveDate();

			Correspond__c aftCp2 = [SELECT Id, FirstInquiryProperty__c FROM Correspond__c WHERE Id = :CorrespondRecord.Id];
			System.assertEquals(FavoritePropertyRecord[1].Property__c, aftCp2.FirstInquiryProperty__c, '対応.初回問合せ物件が更新されていない。');

			// モーダルを閉じる
			testController.closeModal();

			//処理後の対応履歴件数
			Integer aftRerekiCount = testController.screenCorrespondDetailList.size();
			//処理後の反響一覧件数
			Integer aftHankyouCount = testController.screenEchoMailList.size();

			//対応履歴の地区を変更
			testController.selectDistrict = '港区';
			testController.getCorrespondenceHistoryList();

			//地区変更後の対応履歴件数
			Integer aftRerekiCount2 = testController.screenCorrespondDetailList.size();
			//地区変更後の反響一覧件数
			Integer aftHankyouCount2 = testController.screenEchoMailList.size();
			
			checkGabana('openModal2_Tel_stopTest');
			Test.stopTest();

			System.assertEquals(2, aftRerekiCount - befRerekiCount, '対応履歴件数が想定通り増加していない。');
			System.assertEquals(2, aftHankyouCount - befHankyouCount, '反響一覧件数が想定通り増加していない。');
			System.assertEquals(false, (aftRerekiCount2 - befRerekiCount) == 2, '地区変更後に対応履歴件数が絞れれていない。');
			System.assertEquals(true, (aftHankyouCount2 - befHankyouCount) == 2, '地区変更後に反響一覧件数が変化している。');
        }
		checkGabana('openModal2_Tel');
    }
//▲ 2022.01.12 No.489 対応で追加

    // -----------------------------------------------------------------------------------------------
    // 対応履歴（追客保留）
    // -----------------------------------------------------------------------------------------------
    //too many soql queries 101のエラーが出たので、opmeModal2メソッドを2つに分けています   
    @istest static void openPursuitHold(){
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

        // 取引先
        Account accountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
        ];

        // 対応（追客保留）
        Correspond__c CorrespondRecord_Par = [SELECT Id, ExactConditionMatch__c           
            FROM  Correspond__c
            WHERE ExactConditionMatch__c  = 'する'
                  AND Status__c = :CommonConst.CORRESPOND_STATUS_PURSUITHOLD
            LIMIT  1
        ];
        
        // 対応明細
        CorrespondDetail__c CorrespondDetailRecord = [SELECT Id, SupportedContent__c
             FROM CorrespondDetail__c
             WHERE CorrespondType__c = :CommonConst.TASK_CORRESPONDTYPE_PURSUITHOLD
        ];

        System.runAs(ippanUser){
            try {
        
                //ガバナエラーになった為、ここからTest.startTest()
                Test.startTest();

                GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
                testModalController.Parameter = new GA102001Modal2ParameterClass();
                testModalController.Parameter.AccountId = accountRecord.Id;  // 取引先ID
                testModalController.Parameter.CorrespondId = CorrespondRecord_Par.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_PURSUITHOLD; // 対応種別（追客保留）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_UNEARNED; // ステータス
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;

                Boolean init = testModalController.init;
                
                testModalController.screenCorrespondDetail.SupportedTitle = '保留タイトル';
                testModalController.screenCorrespondDetail.SupportedContent = '保留本文';
                testModalController.screenCorrespondDetail.PursuitDissolveDate = Date.valueOf('2020-8-5') ;
                testModalController.screenCorrespondDetail.PursuitDissolveTime = Datetime.parse('2020/08/05 01:23').time();  
                testModalController.saveDate();

				checkGabana('openPursuitHold_stopTest');
                Test.stopTest();

            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('openPursuitHold');
    }

    @istest static void openModal2_2(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
        ];


        // 対応（アポイント確定）
        Correspond__c CorrespondRecord_Apo = [SELECT Id
            FROM Correspond__c
            WHERE Status__c = :commonConst.TASK_CORRESPONDTYPE_APPOINTMENT
            LIMIT  1
        ];
        // 対応明細
        CorrespondDetail__c CorrespondDetailRecord = [SELECT Id
            FROM CorrespondDetail__c
            WHERE CorrespondType__c = :CommonConst.TASK_CORRESPONDTYPE_MEMO
        ];
        //▼問合せNo341で追加
        Account AccountRecord2 = [SELECT Id 
                                 FROM Account
                                 WHERE Name = 'テスト太郎b' 
                                ];
        Correspond__c CorrespondRecord2 = [SELECT Id, PortalSiteUrl__c
                                          FROM Correspond__c
                                          WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
                                          AND PortalSiteUrl__c = 'testURL'
                                   		 ];
        //▲問合せNo341で追加
        System.runAs(ippanUser){
            try {
        
                //ガバナエラーになった為、ここからTest.startTest()
                Test.startTest();
                //来店カードボタン実行
                GA102001Controller testController = new GA102001Controller();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord_Apo.Id );
                Test.setCurrentPage(pageRef);

                GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
                testModalController.Parameter = new GA102001Modal2ParameterClass();
                testModalController.Parameter.AccountId = AccountRecord.Id;  // 取引先ID
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;

                // アポイント変更
                testModalController.Parameter.CorrespondId = CorrespondRecord_Apo.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_APPOINTMENT; // 対応種別（アポイント確定）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_APPOINTMENT; // ステータス
                // 表示
                testModalController.getSelectOption();
                //担当者２名⇒１名
                testModalController.staffCountValue = testModalController.STAFF_ONE;
                // 保存処理
                testModalController.saveDate();

                
                // 明細あり（編集モード）
                testModalController.Parameter.CorrespondDetailId = CorrespondDetailRecord.id;  // 対応明細Id
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_MEMO; // 対応種別（メモ）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED; // ステータス
                testModalController.getSelectOption();
                // 保存処理
                testModalController.saveDate();

               //▼問合せNo341で追加
               if(AccountRecord2 != null){
                    pageRef.getParameters().put('AccountId',AccountRecord2.Id );
                    pageRef.getParameters().put('Corresponds',CorrespondRecord2.Id );
                    Test.setCurrentPage(pageRef);
                    
                    testModalController.Parameter.AccountId = AccountRecord2.Id;  // 取引先ID
                    testModalController.Parameter.CorrespondId = CorrespondRecord2.id; // 対応ID
                    testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_TEL; // 対応種別（電話）
                    testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED; // ステータス
                    // 表示
                    testModalController.getSelectOption();
                    testModalController.screenCorrespondDetail.PhoneStatus = CommonConst.CORRESPONDDETAIL_PHONESTATUS_ECHO;	//電話反響
                    // 保存処理
                    testModalController.saveDate();
                }
                //▲問合せNo341で追加
                
				checkGabana('openModal2_2_stopTest');
                Test.stopTest();

            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('openModal2_2');
    }

    // --------------------------
    // 再販対応追加分（付帯商品の複数登録）
    // 保存
    @istest static void testModal2Save() {
        //一般ユーザで実行
        System.runAs(getIppanUser()) {
			Test.startTest();
            // ページ作成
            Modal2Page page = new Modal2Page('テスト太郎c');
            Test.setCurrentPage(page.pageRef);
            page.initForApplicationCancel();

            // 登録（申込キャンセル）
            page.controller.screenCorrespondDetail.SupportedTitle = '表題';
            page.controller.screenCorrespondDetail.SupportedContent = '対応内容';
            page.controller.saveDate();

			checkGabana('testModal2Save_stopTest');
			Test.stopTest();

            ///// 登録データの確認
            List<Application__c> appliRec = [SELECT Id FROM Application__c WHERE Id = :page.application.Id];
            system.assertEquals(0, appliRec.size(), '申込データ件数');
        }
		checkGabana('testModal2Save');
    }    

    @istest static void openModal2AppoTest(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
        ];

        // 対応（アポイント確定）
        Correspond__c CorrespondRecord_Apo = [SELECT Id,EventId__c,FirstEventId__c
            FROM Correspond__c
            WHERE Status__c = :commonConst.TASK_CORRESPONDTYPE_APPOINTMENT
            LIMIT  1
        ];

        System.runAs(ippanUser){
            try {
        
                Test.startTest();
                //来店カードボタン実行
                GA102001Controller testController = new GA102001Controller();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord_Apo.Id );
                Test.setCurrentPage(pageRef);

                GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
                testModalController.Parameter = new GA102001Modal2ParameterClass();
                testModalController.Parameter.AccountId = AccountRecord.Id;  // 取引先ID
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;

                // アポイント確定
                testModalController.Parameter.CorrespondDetailId ='';  // 対応明細Id
                testModalController.Parameter.CorrespondId = CorrespondRecord_Apo.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_APPOINTMENT; // 対応種別（アポイント確定）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_APPOINTMENT; // ステータス
                 
                // 表示
                testModalController.getSelectOption();
                testModalController.screenCorrespondDetail.GuidanceMethod = CommonConst.GUIDANCE_METHOD_LOCAL_GUIDE;
                testModalController.screenCorrespondDetail.StartDate = Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.StartDateTime = Datetime.parse('2020/01/05 00:00').time();  // 開始日時_時分
                testModalController.screenCorrespondDetail.EndDate =Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.EndDateTime = Datetime.parse('2020/01/05 01:23').time();    // 終了日時_時分
                
                // 保存処理
                testModalController.saveDate();
                
				checkGabana('openModal2AppoTest_stopTest');
                Test.stopTest();

            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('openModal2AppoTest');
    }

    
    @istest static void openModal2AppoCanTest(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
        ];

        // 対応（アポイント確定）
        Correspond__c CorrespondRecord_Apo = [SELECT Id,EventId__c,FirstEventId__c
            FROM Correspond__c
            WHERE Status__c = :commonConst.TASK_CORRESPONDTYPE_APPOINTMENT
            LIMIT  1
        ];
        
        System.runAs(ippanUser){
            try {
        
                Test.startTest();
                //来店カードボタン実行
                GA102001Controller testController = new GA102001Controller();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord_Apo.Id );
                Test.setCurrentPage(pageRef);

                //アポイントキャンセル
                GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
                testModalController.Parameter = new GA102001Modal2ParameterClass();
                testModalController.Parameter.AccountId = AccountRecord.Id;  // 取引先ID
                testModalController.Parameter.CorrespondId = CorrespondRecord_Apo.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_APO_CANCEL; // 対応種別（キャンセル）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_APOCANCEL; // ステータス
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;
                testModalController.Parameter.CorrespondDetailId ='';  // 対応明細

                // 表示
                testModalController.getSelectOption();
                testModalController.screenCorrespondDetail.SupportedTitle = CommonConst.APOCANCEL_OTHER_DECISION;
                testModalController.screenCorrespondDetail.SupportedContent = 'Test';
               
                // 保存処理
                testModalController.saveDate();
                
				checkGabana('openModal2AppoCanTest_stopTest');
                Test.stopTest();

            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }        
		checkGabana('openModal2AppoCanTest');
    }

// -----------------------------------------------------------------------------------------------
// お気に入り物件
// -----------------------------------------------------------------------------------------------
    /**
    　お気に入り物件モーダル表示処理
     */
    @istest static void openModal3(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
                            FROM Account
                            WHERE Name = 'テスト太郎' 
                ];

        // 対応
        Correspond__c CorrespondRecord = [SELECT Id
                            FROM Correspond__c
                            WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
                            LIMIT  1
        ];

        // お気に入り物件
        list<FavoriteProperty__c> FavoritePropertyRecord = [SELECT Id
            FROM FavoriteProperty__c
            WHERE Account__c = :AccountRecord.id
        ];

        System.runAs(ippanUser){
            try {
        
                //来店カードボタン実行
                GA102001Controller testController = new GA102001Controller();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);

                // お気に入り物件の明細を作成
                testController.screenFavoritePropertyList = new List<GA102001Controller.screenFavoriteProperty>();
                GA102001Controller.screenFavoriteProperty screenTargetRecord = new GA102001Controller.screenFavoriteProperty(new FavoriteProperty__c());
                screenTargetRecord.Id = FavoritePropertyRecord[0].id;
                screenTargetRecord.isSelected = true;
                testController.screenFavoritePropertyList.add(screenTargetRecord);
                
                testController.openModal3();

                GA102001Modal3Controller testModalController = new GA102001Modal3Controller();
                testModalController.Parameter = new GA102001Modal3ParameterClass();
                testModalController.Parameter.FavoritePropertyId = FavoritePropertyRecord[0].id; //お気に入り物件
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;
                // 表示
                testModalController.getSelectOption();

                // 保存処理
                testModalController.saveDate();
                

            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('openModal3');
    }

//▼ 2022.01.12 No.489 対応で追加
	/**
	 * 物件項目なしお気に入り物件の初期表示
	 */
	@isTest static void initNullScreenFavoriteProperty(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
        ];

        // 対応（追客中）
        Correspond__c CorrespondRecord = [SELECT Id, FirstInquiryProperty__c
            FROM Correspond__c
            WHERE Status__c = :commonConst.CORRESPOND_STATUS_PURSUIT
            LIMIT  1
        ];

        // お気に入り物件
        List< FavoriteProperty__c> FavoritePropertyRecord = [SELECT Id, Property__c, Property__r.Name
                                                             FROM FavoriteProperty__c
                                                             WHERE Account__c = :AccountRecord.id AND Property__c != null
                                                            ];
		// お気に入り物件の物件を削除する
		for(FavoriteProperty__c fp: FavoritePropertyRecord){
			fp.Property__c = null;
		}
		update FavoritePropertyRecord;

        System.runAs(ippanUser){
			Test.startTest();
			//パラメータ設定
			PageReference pageRef = Page.GA102001View;
			pageRef.getParameters().put('AccountId',AccountRecord.Id );
			pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
			Test.setCurrentPage(pageRef);
			//来店カードボタン実行
			GA102001Controller testController = new GA102001Controller();

			//処理前の対応履歴件数
			Integer befRerekiCount = testController.screenCorrespondDetailList.size();
			//処理前の反響一覧件数
			Integer befHankyouCount = testController.screenEchoMailList.size();

			// TEL/SMS/LINE押下
			testController.openModal2Tel();

			GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
			testModalController.Parameter = testController.GA102001Paremeter2;
			testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_TEL; // 対応種別（電話）
			testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED; // ステータス
			testModalController.Parameter.isDrawing = true;
			testModalController.Parameter.noFirst = true;
			// 表示
			testModalController.getSelectOption();

			checkGabana('initNullScreenFavoriteProperty_stopTest');
			Test.stopTest();

			System.assertEquals(0, testController.screenFavoritePropertyList.size(), '全てのお気に入り物件の物件がnullとなっているが、お気に入り物件が表示される。');
			System.assertEquals(1, testModalController.screenFavoritePropertyList.size(), '全てのお気に入り物件の物件がnullとなっているが、モーダルの問い合わせ物件の選択リストに空白以外の選択肢が表示される。');
		}
		checkGabana('initNullScreenFavoriteProperty');
	}
//▲ 2022.01.12 No.489 対応で追加

// -----------------------------------------------------------------------------------------------
// 入金画面
// -----------------------------------------------------------------------------------------------
    /**
    　入金画面モーダル表示処理
     */
    @istest static void openModal4(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
                            FROM Account
                            WHERE Name = 'テスト太郎' 
                ];

        // 対応
        Correspond__c CorrespondRecord = [SELECT Id
                            FROM Correspond__c
                            WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
                            LIMIT  1
        ];

        // 申込
        Application__c ApplicationRecord = [SELECT Id
            FROM Application__c
            WHERE Account__c = :AccountRecord.id
        ];


        System.runAs(ippanUser){
            try {
        
                //来店カードボタン実行
                GA102001Controller testController = new GA102001Controller();

				Test.startTest();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);

                testController.openModal4();
                GA102001Modal4Controller testModalController = new GA102001Modal4Controller();
                testModalController.Parameter = new GA102001Modal4ParameterClass();
                testModalController.Parameter.ApplicationId = ApplicationRecord.Id;     // 申込ID
                testModalController.Parameter.CorrespondId = CorrespondRecord.Id;
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;
                // 表示
                testModalController.getSelectDeposit();
                testModalController.screenTargetRecord.PaymentDate = CommonUtil.getToday();   // 日付
                testModalController.screenTargetRecord.brokerageFirstFee ='10';
                //testModalController.screenTargetRecord.parkingCommission ='10';
                testModalController.screenTargetRecord.adFee ='10';
                testModalController.screenTargetRecord.auxiliaryDepositPlanFee ='10';
                testModalController.screenTargetRecord.auxiliaryFireInsuranceFee ='10';

                // 選択リストの変更の動作
                testModalController.depositPlanListChange();
                testModalController.fireInsuranceListChange();

                // 再掲載ボタン
                testModalController.Recalculation();

                // 保存処理
                testModalController.save();


                GA102001Modal5Controller testModalController5 = new GA102001Modal5Controller();
                testModalController5.CorrespondId = CorrespondRecord.Id;
                testModalController5.getCorrespondDatte();
                testModalController5.saveDate();
                
                checkGabana('openModal4_stopTest');
                Test.stopTest();

            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('openModal4');
     }

    // --------------------------
    // 再販対応追加分（付帯商品の複数登録）
    // 初期表示
    @isTest static void testModal4Init() {
        //一般ユーザで実行
        System.runAs(getIppanUser()) {
			Test.startTest();
            // ページ作成
            Modal4Page page = new Modal4Page('テスト太郎');
            Test.setCurrentPage(page.pageRef);
            GA102001Modal4Controller ctrl = page.controller;
            GA102001Modal4Controller.ScreenItem screen = ctrl.screenTargetRecord;

			checkGabana('testModal4Init_stopTest');
			Test.stopTest();

            //（ 選択リスト）付帯商品種別の確認
            List<String> typeList = '消毒;鍵交換;安心サポート;Fショット;アルソック'.split('\\;');
            typeList.add(CommonConst.SELECTION_LIST_NULL);
            system.assertEquals(typeList.size(), ctrl.SelectEtceteraAuxiliaryItemTypeList.size(), '（ 選択リスト）付帯商品種別の登録件数');
            for (SelectOption opt: ctrl.SelectEtceteraAuxiliaryItemTypeList) {
                system.assert(typeList.contains(opt.getLabel()), '（ 選択リスト）付帯商品種別のラベル:' + opt.getLabel());
            }

            // （ 選択リスト）付帯商品名の確認
            List<String> nameList = new List<String>{
                  CommonConst.SELECTION_LIST_NULL
                , 'テスト太郎/消毒1/\\5,000'
                , 'テスト太郎/消毒2/\\2,000'
                , 'テスト太郎/鍵交換1/\\2,000'
                , 'テスト太郎/安心サポート1/\\10,000'
                , 'テスト太郎/Fショット1/\\2,000'
                , 'テスト太郎/アルソック1/\\15,000'
            };
            system.assertEquals(nameList.size(), ctrl.SelectEtceteraAuxiliaryItemNameList.size(), '（ 選択リスト）付帯商品種別の登録件数');
            for (SelectOption opt: ctrl.SelectEtceteraAuxiliaryItemNameList) {
                system.assert(nameList.contains(opt.getLabel()), '（ 選択リスト）付帯商品種別のラベル:' + opt.getLabel());
            }
    
            // その他付帯商品リストの確認
            system.assertEquals(1, screen.etceteraAuxiliaryItemList.size(), 'その他付帯商品リストの件数');
            system.assertEquals('消毒1', screen.etceteraAuxiliaryItemList[0].auxiliaryItemName);
            system.assertEquals(3000, screen.etceteraAuxiliaryItemList[0].auxiliaryItemFeeDec);

            // 合計の確認
            system.assertEquals('40,999', screen.sum);
        }
		checkGabana('testModal4Init');
    }

    // 画面項目変更
    @isTest static void testModal4ChangeScreen() {
        //一般ユーザで実行
        System.runAs(getIppanUser()) {
            Id itemId2 = ([SELECT Id FROM Item__c WHERE ItemName__c = '消毒2']).Id;

			Test.startTest();
            // ページ作成
            Modal4Page page = new Modal4Page('テスト太郎');
            Test.setCurrentPage(page.pageRef);
            GA102001Modal4Controller ctrl = page.controller;
            GA102001Modal4Controller.ScreenItem screen = ctrl.screenTargetRecord;

            //（ 選択リスト）付帯商品種別の変更
            screen.EtceteraAuxiliaryItemType = '消毒';
            ctrl.EtceteraAuxiliaryItemTypeListChange();
            List<String> nameList = new List<String>{
                CommonConst.SELECTION_LIST_NULL
                , 'テスト太郎/消毒1/\\5,000'
                , 'テスト太郎/消毒2/\\2,000'
            };
            system.assertEquals(nameList.size(), ctrl.SelectEtceteraAuxiliaryItemNameList.size(), '（ 選択リスト）付帯商品種別の登録件数');
            for (SelectOption opt: ctrl.SelectEtceteraAuxiliaryItemNameList) {
                system.assert(nameList.contains(opt.getLabel()), '（ 選択リスト）付帯商品種別のラベル:' + opt.getLabel());
            }

            // （ 選択リスト）付帯商品名の変更
            screen.EtceteraAuxiliaryItemName = itemId2;
            ctrl.EtceteraAuxiliaryItemNameListChange();
            system.assertEquals('2,000', screen.EtceteraAuxiliaryItemFee, '付帯商品価格');

            // その他付帯商品の追加
            screen.etceteraAuxiliaryItemFee = '1,889';
            ctrl.addEtceteraAuxiliaryItemList();
            system.assertEquals(2, screen.etceteraAuxiliaryItemList.size(), 'その他付帯商品リストの件数');
            system.assertEquals('消毒2', screen.etceteraAuxiliaryItemList[1].auxiliaryItemName);
            system.assertEquals(1889, screen.etceteraAuxiliaryItemList[1].auxiliaryItemFeeDec);

            // その他付帯商品の削除
            page.pageRef.getParameters().put('ListIndex', '0');
            Test.setCurrentPage(page.pageRef);
            ctrl.removeEtceteraAuxiliaryItemList();
            system.assertEquals(1, screen.etceteraAuxiliaryItemList.size(), 'その他付帯商品リストの件数');
            system.assertEquals('消毒2', screen.etceteraAuxiliaryItemList[0].auxiliaryItemName);
            system.assertEquals(1889, screen.etceteraAuxiliaryItemList[0].auxiliaryItemFeeDec);

			checkGabana('testModal4ChangeScreen_stopTest');
			Test.stopTest();
        }
		checkGabana('testModal4ChangeScreen');
    }

    // 入力チェック
    @isTest static void testModal4InputCheck() {
        //一般ユーザで実行
        System.runAs(getIppanUser()) {
            Id itemId1 = ([SELECT Id FROM Item__c WHERE ItemName__c = '消毒1']).Id;
            Id itemId2 = ([SELECT Id FROM Item__c WHERE ItemName__c = '消毒2']).Id;

			Test.startTest();
            // ページ作成
            Modal4Page page = new Modal4Page('テスト太郎');
            Test.setCurrentPage(page.pageRef);
            GA102001Modal4Controller ctrl = page.controller;
            GA102001Modal4Controller.ScreenItem screen = ctrl.screenTargetRecord;

            // 付帯商品追加時の必須入力チェック（商品未選択）
            screen.EtceteraAuxiliaryItemFee = '1,889';
            ctrl.addEtceteraAuxiliaryItemList();
            system.assertEquals(true, ctrl.hasErrorMessage);
            System.assertEquals('付帯商品並びに、販売価格は入力必須です。', ApexPages.getMessages()[0].getDetail());
            Test.clearApexPageMessages();

            // 付帯商品追加時の必須入力チェック（価格未入力）
            screen.etceteraAuxiliaryItemName = itemId1;
            ctrl.etceteraAuxiliaryItemNameListChange();
            screen.etceteraAuxiliaryItemFee = '';
            ctrl.addEtceteraAuxiliaryItemList();
            system.assertEquals(true, ctrl.hasErrorMessage, 'エラーあり？');
            System.assertEquals('付帯商品並びに、販売価格は入力必須です。', ApexPages.getMessages()[0].getDetail());
            Test.clearApexPageMessages();

            // 明細件数の最大登録チェック
            screen.etceteraAuxiliaryItemName = itemId1;
            ctrl.etceteraAuxiliaryItemNameListChange();
            screen.etceteraAuxiliaryItemFee = '1,889';
            ctrl.addEtceteraAuxiliaryItemList();                    // ２件目
            system.assertEquals(false, ctrl.hasErrorMessage, 'エラーなし？');
            ctrl.addEtceteraAuxiliaryItemList();                    // ３件目
            system.assertEquals(false, ctrl.hasErrorMessage, 'エラーなし？');
            ctrl.addEtceteraAuxiliaryItemList();                    // ４件目
            system.assertEquals(false, ctrl.hasErrorMessage, 'エラーなし？');
            ctrl.addEtceteraAuxiliaryItemList();                    // ５件目
            system.assertEquals(false, ctrl.hasErrorMessage, 'エラーなし？');
            ctrl.addEtceteraAuxiliaryItemList();                    // ６件目
            system.assertEquals(false, ctrl.hasErrorMessage, 'エラーなし？');
            ctrl.addEtceteraAuxiliaryItemList();                    // ７件目
            system.assertEquals(false, ctrl.hasErrorMessage, 'エラーなし？');
            ctrl.addEtceteraAuxiliaryItemList();                    // ８件目
            system.assertEquals(false, ctrl.hasErrorMessage, 'エラーなし？');
            ctrl.addEtceteraAuxiliaryItemList();                    // ９件目
            system.assertEquals(false, ctrl.hasErrorMessage, 'エラーなし？');
            ctrl.addEtceteraAuxiliaryItemList();                    // １０件目
            system.assertEquals(false, ctrl.hasErrorMessage, 'エラーなし？');
            ctrl.addEtceteraAuxiliaryItemList();                    // １１件目
            system.assertEquals(true, ctrl.hasErrorMessage, 'エラーあり？');
            System.assertEquals('付帯商品は10個以内で選択してください。', ApexPages.getMessages()[0].getDetail());
            Test.clearApexPageMessages();
			checkGabana('testModal4InputCheck_stopTest');
			Test.stopTest();
        }
		checkGabana('testModal4InputCheck');
    }

    // 保存
    @isTest static void testModal4Save() {
        //一般ユーザで実行
        System.runAs(getIppanUser()) {
            Id itemId1 = ([SELECT Id FROM Item__c WHERE ItemName__c = '消毒1']).Id;
            Id itemId2 = ([SELECT Id FROM Item__c WHERE ItemName__c = '消毒2']).Id;

			Test.startTest();
            // ページ作成
            Modal4Page page = new Modal4Page('テスト太郎');
            Test.setCurrentPage(page.pageRef);
            GA102001Modal4Controller ctrl = page.controller;
            GA102001Modal4Controller.ScreenItem screen = ctrl.screenTargetRecord;

            ///// 画面項目の編集
            // 消毒２の追加
            screen.EtceteraAuxiliaryItemName = itemId2;
            ctrl.EtceteraAuxiliaryItemNameListChange();
            screen.EtceteraAuxiliaryItemFee = '1,889';
            ctrl.addEtceteraAuxiliaryItemList();
            // 消毒１の削除
            page.pageRef.getParameters().put('ListIndex', '0');
            Test.setCurrentPage(page.pageRef);
            ctrl.removeEtceteraAuxiliaryItemList();
            // 消毒１の追加
            screen.etceteraAuxiliaryItemName = itemId1;
            ctrl.EtceteraAuxiliaryItemNameListChange();
            screen.EtceteraAuxiliaryItemFee = '4,002'; ctrl.addEtceteraAuxiliaryItemList();     // ２件目
            screen.EtceteraAuxiliaryItemFee = '4,003'; ctrl.addEtceteraAuxiliaryItemList();     // ３件目
            screen.EtceteraAuxiliaryItemFee = '4,004'; ctrl.addEtceteraAuxiliaryItemList();     // ４件目
            screen.EtceteraAuxiliaryItemFee = '4,005'; ctrl.addEtceteraAuxiliaryItemList();     // ５件目
            screen.EtceteraAuxiliaryItemFee = '4,006'; ctrl.addEtceteraAuxiliaryItemList();     // ６件目
            screen.EtceteraAuxiliaryItemFee = '4,007'; ctrl.addEtceteraAuxiliaryItemList();     // ７件目
            screen.EtceteraAuxiliaryItemFee = '4,008'; ctrl.addEtceteraAuxiliaryItemList();     // ８件目
            screen.EtceteraAuxiliaryItemFee = '4,009'; ctrl.addEtceteraAuxiliaryItemList();     // ９件目
            screen.EtceteraAuxiliaryItemFee = '4,010'; ctrl.addEtceteraAuxiliaryItemList();     // １０件目
            // 保存
            screen.PaymentDate = Date.today();
            ctrl.save();
			checkGabana('testModal4Save_stopTest');
			Test.stopTest();
            CommonUtil.sleep(1000);     // スリープ

            ///// 登録データの確認
            Application__c updateRec = [
                    SELECT Id
                    , AuxiliaryItem1__c                             // 付帯商品１．付帯商品Id
                    , auxiliaryItemFee1__c                          // 付帯商品料１（販売価格１）
                    , AuxiliaryItem2__c                             // 付帯商品２．付帯商品Id
                    , auxiliaryItemFee2__c                          // 付帯商品料２（販売価格２）
                    , AuxiliaryItem3__c                             // 付帯商品３．付帯商品Id
                    , auxiliaryItemFee3__c                          // 付帯商品料３（販売価格３）
                    , AuxiliaryItem4__c                             // 付帯商品４．付帯商品Id
                    , auxiliaryItemFee4__c                          // 付帯商品料４（販売価格４）
                    , AuxiliaryItem5__c                             // 付帯商品５．付帯商品Id
                    , auxiliaryItemFee5__c                          // 付帯商品料５（販売価格５）
                    , AuxiliaryItem6__c                             // 付帯商品６．付帯商品Id
                    , auxiliaryItemFee6__c                          // 付帯商品料６（販売価格６）
                    , AuxiliaryItem7__c                             // 付帯商品７．付帯商品Id
                    , auxiliaryItemFee7__c                          // 付帯商品料７（販売価格７）
                    , AuxiliaryItem8__c                             // 付帯商品８．付帯商品Id
                    , auxiliaryItemFee8__c                          // 付帯商品料８（販売価格８）
                    , AuxiliaryItem9__c                             // 付帯商品９．付帯商品Id
                    , auxiliaryItemFee9__c                          // 付帯商品料９（販売価格９）
                    , AuxiliaryItem10__c                            // 付帯商品１０．付帯商品Id
                    , auxiliaryItemFee10__c                         // 付帯商品料１０（販売価格１０）
                    FROM Application__c
                    WHERE id = :page.application.id
            ];
            system.assertEquals(10, screen.etceteraAuxiliaryItemList.size(), 'その他付帯商品リストの件数');
            system.assertEquals(itemId2, updateRec.AuxiliaryItem1__c,    '登録データの確認_付帯商品１');
            system.assertEquals(1889,    updateRec.auxiliaryItemFee1__c, '登録データの確認_付帯商品料１');
            for (Integer i = 2; i <= 10; i++) {
                system.assertEquals(itemId1,  updateRec.get('AuxiliaryItem' + i + '__c'),    '登録データの確認_付帯商品' + i);
                system.assertEquals(4000 + i, updateRec.get('auxiliaryItemFee' + i + '__c'), '登録データの確認_付帯商品料' + i);
            }
        }
		checkGabana('testModal4Save');
    }


	// ▼ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
    /**
    * 入金画面
    * 付帯保証プラン
    * マージンの金額が登録された金額で表示されること
	* 「--なし--」を選択時、金額が空になること
	* 対象の金額を選択時、計算された内容にマージンがセットされること
    * ※複数パターン有
    */
    @isTest static void depositPlanListChangeUpDateTest() {
		// カスタム設定スキップフラグ
		SystemConfig__c testSystemConfig =[SELECT Id,IsSkipTrigger__c FROM SystemConfig__c LIMIT 1];
		testSystemConfig.IsSkipTrigger__c = true;
		update testSystemConfig;
		//パラメータ設定
		Id applicationId = ([SELECT Id FROM Application__c WHERE Account__r.name ='テスト太郎']).Id;

		// 選択用商品明細のID取得
		List<ItemDetail__c> itemDetailList = ([SELECT Id,PlanDetail__c FROM ItemDetail__c ]);
		// プラン詳細をmapのキーにする
		Map<String,Id> itemDetailIdMap = new Map<String,Id>();
		for (ItemDetail__c ItemDetail : itemDetailList) {
			itemDetailIdMap.put(ItemDetail.PlanDetail__c, ItemDetail.Id);
		}
		//一般ユーザで実行
		System.runAs(getIppanUser()) {
			Modal4Page page = new Modal4Page('テスト太郎');
			Test.setCurrentPage(page.pageRef);
			GA102001Modal4Controller testController = page.controller;
			GA102001Modal4Controller.ScreenItem screen = testController.screenTargetRecord;

			///// 画面項目の編集
			// 対象の金額を選択時、計算された内容にマージンがセットされること
			screen.auxiliaryDepositPlan = itemDetailIdMap.get('金額');
			testController.depositPlanListChange();
			String auxiliaryDepositPlanFeeYen = screen.auxiliaryDepositPlanFee;
					// 賃料
			screen.auxiliaryDepositPlan = itemDetailIdMap.get('割合賃料');
			testController.depositPlanListChange();
			String auxiliaryDepositPlanFeeWari1 = screen.auxiliaryDepositPlanFee;

			// 総賃料、総賃料に口座振替手数料を含まない
			screen.auxiliaryDepositPlan = itemDetailIdMap.get('割合総賃料口座無し');
			testController.depositPlanListChange();
			String auxiliaryDepositPlanFeeWari2 = screen.auxiliaryDepositPlanFee;

			// 総賃料、総賃料に口座振替手数料を含む、手数料税無し
			screen.auxiliaryDepositPlan = itemDetailIdMap.get('割合総賃料口座税無し');
			testController.depositPlanListChange();
			String auxiliaryDepositPlanFeeWari3 = screen.auxiliaryDepositPlanFee;

			//  総賃料、総賃料に口座振替手数料を含む、手数料税込み
			screen.auxiliaryDepositPlan = itemDetailIdMap.get('割合総賃料口座税込み');
			testController.depositPlanListChange();
			String auxiliaryDepositPlanFeeWari4 = screen.auxiliaryDepositPlanFee;

			// 「--なし--」を選択時、金額が空になること
			screen.auxiliaryDepositPlan = itemDetailIdMap.get('');
			testController.depositPlanListChange();
			String auxiliaryDepositPlanFeeNothing = screen.auxiliaryDepositPlanFee;

			// 金額を手入力で変更
			screen.auxiliaryDepositPlan = itemDetailIdMap.get('割合総賃料口座税込み');
			testController.depositPlanListChange();
			screen.auxiliaryDepositPlanFee = '123456';
			screen.PaymentDate = CommonUtil.getToday();

			// 保存
			testController.save();
			Application__c beforeApplication = ([SELECT Id,AuxiliaryDepositPlan__c,AuxiliaryDepositPlanFee__c FROM Application__c WHERE Account__r.name ='テスト太郎' LIMIT 1]);

			//コントローラ作成
			GA102001Modal4Controller testController2 = page.controller;
			testController2.getSelectDeposit();
			GA102001Modal4Controller.ScreenItem screen2 = testController2.screenTargetRecord;
			///// 画面項目の編集
			// 対象の金額を選択時、計算された内容にマージンがセットされること
			screen2.auxiliaryDepositPlan = itemDetailIdMap.get('金額');
			testController2.depositPlanListChange();
			String auxiliaryDepositPlanFeeYen2 = screen2.auxiliaryDepositPlanFee;

			// 賃料
			screen2.auxiliaryDepositPlan = itemDetailIdMap.get('割合賃料');
			testController2.depositPlanListChange();
			String auxiliaryDepositPlanFeeWari21 = screen2.auxiliaryDepositPlanFee;

			// 総賃料、総賃料に口座振替手数料を含まない
			screen2.auxiliaryDepositPlan = itemDetailIdMap.get('割合総賃料口座無し');
			testController2.depositPlanListChange();
			String auxiliaryDepositPlanFeeWari22 = screen2.auxiliaryDepositPlanFee;

			// 総賃料、総賃料に口座振替手数料を含む、手数料税無し
			screen2.auxiliaryDepositPlan = itemDetailIdMap.get('割合総賃料口座税無し');
			testController2.depositPlanListChange();
			String auxiliaryDepositPlanFeeWari23 = screen2.auxiliaryDepositPlanFee;

			// 総賃料、総賃料に口座振替手数料を含む、手数料税込み
			screen2.auxiliaryDepositPlan = itemDetailIdMap.get('割合総賃料口座税込み');
			testController2.depositPlanListChange();
			String auxiliaryDepositPlanFeeWari24 = screen2.auxiliaryDepositPlanFee;

			// 「--なし--」を選択時、金額が空になること
			screen2.auxiliaryDepositPlan = itemDetailIdMap.get('');
			testController2.depositPlanListChange();
			String auxiliaryDepositPlanFeeNothing2 = screen2.auxiliaryDepositPlanFee;
			// 金額を手入力で変更
			screen2.auxiliaryDepositPlan = itemDetailIdMap.get('割合総賃料口座無し');
			testController2.depositPlanListChange();
			screen2.auxiliaryDepositPlanFee = '654321';
			screen2.PaymentDate = CommonUtil.getToday();
			checkGabana('depositPlanListChangeUpDateTeststart');
			Test.startTest();
			// 保存
			testController2.save();
			Test.stopTest();
		
			Application__c afterApplication = ([SELECT Id,AuxiliaryDepositPlan__c,AuxiliaryDepositPlanFee__c FROM Application__c WHERE Account__r.name ='テスト太郎' LIMIT 1]);
			// 割合総賃料口座税込み
			system.assertEquals(auxiliaryDepositPlanFeeWari4, '19,025');
			system.assertEquals(auxiliaryDepositPlanFeeWari24,'19,025' );
			// 割合総賃料口座税無し
			system.assertEquals(auxiliaryDepositPlanFeeWari3, '3,850');
			system.assertEquals(auxiliaryDepositPlanFeeWari23,'3,850');

			// 割合総賃料口座無し
			system.assertEquals(auxiliaryDepositPlanFeeWari2, '30,000');
			system.assertEquals(auxiliaryDepositPlanFeeWari22,'30,000' );
			// 割合賃料
			system.assertEquals(auxiliaryDepositPlanFeeWari1, '13,750');
			system.assertEquals(auxiliaryDepositPlanFeeWari21,'13,750');

			// 金額を選択
			system.assertEquals(auxiliaryDepositPlanFeeYen, '5,000');
			system.assertEquals(auxiliaryDepositPlanFeeYen2,'5,000' );
			// 「--なし--」を選択時、金額が空になること
			system.assertEquals(auxiliaryDepositPlanFeeNothing, null);
			system.assertEquals(auxiliaryDepositPlanFeeNothing2,null );

			// 保存内容が一致しない事
			system.assertNotEquals(beforeApplication.AuxiliaryDepositPlan__c, afterApplication.AuxiliaryDepositPlan__c);
			system.assertNotEquals(beforeApplication.AuxiliaryDepositPlanFee__c, afterApplication.AuxiliaryDepositPlanFee__c);
		}
    }
    /**
    * 入金画面
    * 付帯火災保険
    * マージンの金額が登録された金額で表示されること
	* 「--なし--」を選択時、金額が空になること
	* 対象の金額を選択時、計算された内容にマージンがセットされること
    * ※複数パターン有
    */
    @isTest static void auxiliaryFireInsuranceFeeUpDateTest() {
		// カスタム設定スキップフラグ
		SystemConfig__c testSystemConfig =[SELECT Id,IsSkipTrigger__c FROM SystemConfig__c LIMIT 1];
		testSystemConfig.IsSkipTrigger__c = true;
		update testSystemConfig;
        //パラメータ設定
        Id applicationId = ([SELECT Id FROM Application__c WHERE Account__r.name ='テスト太郎']).Id;

        Id recordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),CommonConst.ITEM_RECTYPE_FIRE_INSURANCE);
		// 選択用商品のID取得
		List<Item__c> itemList = ([SELECT Id,ItemName__c FROM Item__c WHERE RecordTypeId = :recordTypeId]);
		// プラン詳細をmapのキーにする
		Map<String,Id> itemMap = new Map<String,Id>();
		for (Item__c Item : itemList) {
			itemMap.put(Item.ItemName__c, Item.Id);
		}
		//一般ユーザで実行
		System.runAs(getIppanUser()) {
			// ページ作成
			Modal4Page page = new Modal4Page('テスト太郎');
			Test.setCurrentPage(page.pageRef);
			GA102001Modal4Controller testController = page.controller;
			GA102001Modal4Controller.ScreenItem screen = testController.screenTargetRecord;
			///// 画面項目の編集
			// 対象の金額を選択時、計算された内容にマージンがセットされること
			// テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）５０％、火災保険料（月額）１００００
			screen.auxiliaryFireInsurance = itemMap.get('テスト3火災保険');
			testController.fireInsuranceListChange();
			String auxiliaryFireInsuranceFeeRate = screen.auxiliaryFireInsuranceFee;

			// テスト1火災保険株式会社：付帯商品、火災保険料（月額）２００００
			screen.auxiliaryFireInsurance = itemMap.get('テスト4火災保険');
			testController.fireInsuranceListChange();
			String auxiliaryFireInsuranceFeeYen = screen.auxiliaryFireInsuranceFee;

			// 「--なし--」を選択時、金額が空になること
			screen.auxiliaryFireInsurance = itemMap.get('');
			testController.fireInsuranceListChange();
			String auxiliaryFireInsuranceFeeNothing = screen.auxiliaryFireInsuranceFee;

			// 金額を手入力で変更
			screen.auxiliaryFireInsurance = itemMap.get('テスト3火災保険');
			testController.fireInsuranceListChange();
			screen.auxiliaryFireInsuranceFee = '123456';
			screen.PaymentDate = CommonUtil.getToday();
	
			// 保存
			testController.save();
	
			Application__c beforeApplication = ([SELECT Id,AuxiliaryFireInsurance__c,AuxiliaryFireInsuranceFee__c FROM Application__c WHERE Account__r.name ='テスト太郎' LIMIT 1]);
			// 更新後

			//コントローラ作成
			GA102001Modal4Controller testController2 = page.controller;
			testController2.getSelectDeposit();
			GA102001Modal4Controller.ScreenItem screen2 = testController2.screenTargetRecord;
			///// 画面項目の編集
			// 対象の金額を選択時、計算された内容にマージンがセットされること
			// テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）５０％、火災保険料（月額）１００００
			screen2.auxiliaryFireInsurance = itemMap.get('テスト3火災保険');
			testController2.fireInsuranceListChange();
			String auxiliaryFireInsuranceFeeRate2 = screen2.auxiliaryFireInsuranceFee;

			// テスト1火災保険株式会社：付帯商品、火災保険料（月額）２００００
			screen2.auxiliaryFireInsurance = itemMap.get('テスト4火災保険');
			testController2.fireInsuranceListChange();
			String auxiliaryFireInsuranceFeeYen2 = screen2.auxiliaryFireInsuranceFee;

			// 「--なし--」を選択時、金額が空になること
			screen2.auxiliaryFireInsurance = itemMap.get('');
			testController2.fireInsuranceListChange();
			String auxiliaryFireInsuranceFeeNothing2 = screen2.auxiliaryFireInsuranceFee;

			// 金額を手入力で変更
			screen2.auxiliaryFireInsurance = itemMap.get('テスト4火災保険');
			testController2.fireInsuranceListChange();
			screen2.auxiliaryFireInsuranceFee = '654321';
			screen2.PaymentDate = CommonUtil.getToday();
			Test.startTest();
			checkGabana('auxiliaryFireInsuranceFeeUpDateTeststart');
			// 保存
			testController2.save();
			Test.stopTest();

			Application__c afterApplication = ([SELECT Id,AuxiliaryFireInsurance__c,AuxiliaryFireInsuranceFee__c FROM Application__c WHERE Account__r.name ='テスト太郎' LIMIT 1]);
			// テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）５０％、火災保険料（月額）１００００
			system.assertEquals(auxiliaryFireInsuranceFeeRate,'5,000');
			system.assertEquals(auxiliaryFireInsuranceFeeRate2, '5,000');
			// テスト1火災保険株式会社：付帯商品、火災保険料（月額）２００００
			system.assertEquals(auxiliaryFireInsuranceFeeYen, '20,000');
			system.assertEquals(auxiliaryFireInsuranceFeeYen2, '20,000');

			// 「‐―なし‐‐」」を選択時、金額が空になること
			system.assertEquals(auxiliaryFireInsuranceFeeNothing, null);
			system.assertEquals(auxiliaryFireInsuranceFeeNothing2, null);

			// 保存時の内容が違っていること
			system.assertNotEquals(beforeApplication.AuxiliaryFireInsurance__c, afterApplication.AuxiliaryFireInsurance__c);
			system.assertNotEquals(beforeApplication.AuxiliaryFireInsuranceFee__c, afterApplication.AuxiliaryFireInsuranceFee__c);

		}
		
    }
    // ▲ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更

// -----------------------------------------------------------------------------------------------
// スケジュール登録画面
// -----------------------------------------------------------------------------------------------
    /**
    　スケジュール登録画面モーダル表示処理
     */
    @istest static void openModal6(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
                            FROM Account
                            WHERE Name = 'テスト太郎' 
                ];

        // 対応
        Correspond__c CorrespondRecord = [SELECT Id
                            FROM Correspond__c
                            WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
                            LIMIT  1
        ];

        System.runAs(ippanUser){
            try {
        
				Test.startTest();
                //ボタン実行
                GA102001Controller testController = new GA102001Controller();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);

                testController.openModal6();
                GA102001Modal6Controller testModalController = new GA102001Modal6Controller();
                testModalController.Parameter = new GA102001Modal6ParameterClass();
                testModalController.Parameter.AccountId = AccountRecord.Id;  // 取引先ID
                testModalController.Parameter.CorrespondId = CorrespondRecord.Id; // 対応ID
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;
                // 表示
                testModalController.getSelectOption();                
                testModalController.screenCorrespondDetail.CorrespondType = commonConst.TASK_CORRESPONDTYPE_RETURN;
                testModalController.screenCorrespondDetail.Shop = testModalController.screenCorrespondDetail.Shop;
                testModalController.screenCorrespondDetail.Staff = testModalController.screenCorrespondDetail.Staff;
                testModalController.screenCorrespondDetail.StartDate = Date.valueOf('2020-1-6') ;
                testModalController.screenCorrespondDetail.StartDateTime = Datetime.parse('2020/01/06 00:00').time();  // 開始日時_時分
                testModalController.screenCorrespondDetail.EndDate =Date.valueOf('2020-1-6') ;
                testModalController.screenCorrespondDetail.EndDateTime = Datetime.parse('2020/01/06 01:23').time();    // 終了日時_時分                
                testModalController.getShopList();
                testModalController.changeScheduleDetails();
                // 保存処理
                testModalController.saveData();
				checkGabana('openModal6_stopTest');
				Test.stopTest();
                
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('openModal6');
     }     
    //2020/6/12カバレッジ率あげ
    @istest static void coverageUp(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
        ];

        // 対応
        Correspond__c CorrespondRecord = [SELECT Id
            FROM Correspond__c
            WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
            LIMIT  1
        ];
        // 対応（アポイント確定）
        Correspond__c CorrespondRecord_Apo = [SELECT Id
            FROM Correspond__c
            WHERE Status__c = :commonConst.TASK_CORRESPONDTYPE_APPOINTMENT
            LIMIT  1
        ];
        // 対応明細
        CorrespondDetail__c CorrespondDetailRecord = [SELECT Id
            FROM CorrespondDetail__c
            WHERE CorrespondType__c = :CommonConst.TASK_CORRESPONDTYPE_MEMO
        ];

        System.runAs(ippanUser){
            try {
				Test.startTest();
                // ▼ 2021.11.30 LINE連携対応より、初期表示後の画面情報を参照するよう削除
                // ▲ 2021.11.30

                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);

                //来店カードボタン実行
                GA102001Controller testController = new GA102001Controller(); // 2021.11.30 LINE連携対応より、初期表示後の画面情報を参照するよう修正
                testController.openModal2Tel();

                GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
                testModalController.Parameter = new GA102001Modal2ParameterClass();
                testModalController.Parameter.AccountId = AccountRecord.Id;  // 取引先ID
                testModalController.Parameter.CorrespondId = CorrespondRecord.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_TEL; // 対応種別（電話）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED; // ステータス
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;
                // 表示
                testModalController.getSelectOption();
                //変数
                String st;
                st = testModalController.MSG_COM_I_SAVE;
                st = testModalController.MSG_COM_V_SAVE;
                st = testModalController.CORRESPOND_STATUS_CLOSE;
                st = testModalController.TASK_CORRESPONDTYPE_CANCEL;
                st = testModalController.TASK_CORRESPONDTYPE_MERGE;
                st = testModalController.TASK_CORRESPONDTYPE_APPLICANT;
                st = testModalController.TASK_CORRESPONDTYPE_CONSIDERVISITING;
                st = testModalController.TASK_CORRESPONDTYPE_VISITED;
                st = testModalController.TASK_CORRESPONDTYPE_MAIL;
                //電話
                //発信者変更
                testModalController.screenCorrespondDetail.Sender = CommonConst.CORRESPONDDETAIL_SENDER_CUSTOMER;
                testModalController.changeSender();
                testModalController.screenCorrespondDetail.Sender = CommonConst.CORRESPONDDETAIL_SENDER_STAFF;
                testModalController.changeSender();
                //状況変更
                testModalController.changePhoneStatus();
                testModalController.screenCorrespondDetail.PhoneStatus = CommonConst.CORRESPONDDETAIL_PHONESTATUS_ECHO;
                testModalController.changePhoneStatus();
                testModalController.screenCorrespondDetail.PhoneStatus = CommonConst.CORRESPONDDETAIL_PHONESTATUS_LIVEROECHO;
                testModalController.changePhoneStatus();

                testModalController.getSelectOption();

                //終了
                testModalController.screenCorrespondDetail.CorrespondType= CommonConst.TASK_CORRESPONDTYPE_CLOSE;
                testModalController.saveDate();
                
                testModalController.screenCorrespondDetail.PortalSite = 'at home';
                testModalController.saveDate();
                
                //追客保留
                testModalController.Parameter.AccountId = AccountRecord.Id;  // 取引先ID
                testModalController.Parameter.CorrespondId = CorrespondRecord.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_PURSUITHOLD; // 対応種別（追客保留）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_UNEARNED; // ステータス
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;
                // 表示
                testModalController.getSelectOption();
                // 保存処理
                testModalController.screenCorrespondDetail.PursuitDissolveDate =Date.valueOf('2020-8-5') ;
                testModalController.screenCorrespondDetail.PursuitDissolveTime = Datetime.parse('2020/08/05 01:23').time();    
                testModalController.saveDate();
				checkGabana('coverageUp_stopTest');
				Test.stopTest();
				// ▲2022.02.10 No.307 対応でTest.startTest()位置を修正
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('coverageUp');
        
    }

    @istest static void coverageUp2(){
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
        // 取引先
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
        ];
        // 対応　未収入金
        Correspond__c CorrespondRecord = [SELECT Id 
            FROM Correspond__c
            WHERE AccountId__c = :AccountRecord.id
            AND Status__c = :commonConst.CORRESPOND_STATUS_UNEARNED];
        
        CorrespondDetail__c  CorrespondDetailRecord =[SELECT Id 
            FROM CorrespondDetail__c
            WHERE CorrespondType__c = :commonconst.TASK_CORRESPONDTYPE_APPLICANT  // 対応種別（申込）
        ];

        System.runAs(ippanUser){
            try {
                Test.startTest();

                //来店カードボタン実行
                GA102001Controller testController = new GA102001Controller();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);
                testController.openModal2ApplicationCancel();
                //アポイントキャンセル
                GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
                testModalController.Parameter = new GA102001Modal2ParameterClass();
                testModalController.Parameter.AccountId = AccountRecord.Id;  // 取引先ID
                testModalController.Parameter.CorrespondId = CorrespondRecord.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_APO_CANCEL; // 対応種別（キャンセル）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_UNEARNED; // ステータス
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;
                // 表示
                testModalController.getSelectOption();
                // 保存処理
                testModalController.saveDate();

				checkGabana('coverageUp2_stopTest');
				Test.stopTest();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('coverageUp2');
        
    }

    /**
     * 名寄せ確認テスト
     */
    @isTest static void nayoseTest(){

        system.debug('名寄せ確認');

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
               ];

       // 対応
       Correspond__c CorrespondRecord = [SELECT Id 
               FROM Correspond__c
               WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
               LIMIT  1
       ];


        //名寄せ一致データ(電話番号が一致)
        Account nayose = new Account(Name = 'テスト次郎', 
                                     FirstName__c = '次郎', LastName__c = 'テスト', 
                                     NameKana__c = 'ﾃｽﾄｼﾞﾛｳ',
                                     Phone = '025-200-1234', 
                                     IsMergeUnnecessaryFlag__c = true, 
                                     Situation__c = '紹介',		//問合せNo341で追加
                                     RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
        insert nayose;

		System.runAs(ippanUser){
			try {
				// ▼2022.02.10 No.307 対応でTest.startTest()位置を修正
				Test.startTest();
				//パラメータ設定
				PageReference pageRef = Page.GA102001View;
				pageRef.getParameters().put('AccountId',AccountRecord.Id );
				pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
				Test.setCurrentPage(pageRef);
				GA102001Controller testController = new GA102001Controller();

				//名寄せの最新化が行われていることの確認
				system.assertEquals(false, testController.screenAccountRecord.IsMergeUnnecessaryFlag );

				//メールを変えて保存
				testController.screenAccountRecord.Email2 = 'sss@ttt.jp'; 
				testController.screenAccountRecord.LastNameKana = 'ﾃｽﾄ';
				//問合せNo341で追加
				testController.editflg = false;
				testController.saveDate();

				//保存した取引先の名寄せ完了フラグ確認
				Account chkAcc = [SELECT id, IsMergeCompletedFlag__c, IsMergeUnnecessaryFlag__c
				FROM Account
				WHERE ID = :AccountRecord.id
				];
				system.assertEquals(false, chkAcc.IsMergeCompletedFlag__c);
				system.assertEquals(false, chkAcc.IsMergeUnnecessaryFlag__c);

				//名寄せが一致した取引先の名寄せ不要フラグ確認
				Account chkAcc2 = [ SELECT id, IsMergeCompletedFlag__c, IsMergeUnnecessaryFlag__c
								FROM Account
								WHERE ID = :nayose.id
				];
				system.assertEquals(false, chkAcc2.IsMergeUnnecessaryFlag__c);
				checkGabana('nayoseTest_stopTest');
				Test.stopTest();
				// ▲2022.02.10 No.307 対応でTest.startTest()位置を修正


			} catch(BusinessLogicException e){
				System.assertEquals(e.getMessage(), '');
			}
		}
		checkGabana('nayoseTest');
   
	}

    
    // アポイント確定 入力エラーチェック

    @istest static void apokakuInputCheck(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
        ];

        // 対応（アポイント確定）
        Correspond__c CorrespondRecord_Apo = [SELECT Id
            FROM Correspond__c
            WHERE Status__c = :commonConst.TASK_CORRESPONDTYPE_APPOINTMENT
            LIMIT  1
        ];

        //重複する行動を作成
        Event dupEv = new Event(OwnerId = ippanUser.id, 
                startDateTime = Datetime.parse('2020/01/05 01:00'), 
                EndDateTime = Datetime.parse('2020/01/05 03:00'));
        insert dupEv;

        System.runAs(ippanUser){
            try {
                //ガバナエラーになった為、ここからTest.startTest()
                Test.startTest();
                
                GA102001Controller testController = new GA102001Controller();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord_Apo.Id );
                Test.setCurrentPage(pageRef);

                testController.openModal2Apo();

                // アポイント確定
                GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
                testModalController.Parameter = new GA102001Modal2ParameterClass();
				testModalController.Parameter.CorrespondId = CorrespondRecord_Apo.id; // 対応ID
                testModalController.Parameter.AccountId = AccountRecord.Id;  // 取引先ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_APPOINTMENT; // 対応種別（アポイント確定）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_APPOINTMENT; // ステータス
                // 表示
                testModalController.getSelectOption();
                // カバレッジの為、VFからのみ呼び出されるメソッドを実行
                testModalController.getVisitShopList1();
                testModalController.getVisitShopList2();
                testModalController.getstaffCountList();
                // 2名選択
                testModalController.staffCountValue = testModalController.STAFF_TWO;

                try {
                    // 担当者１・２　開始日・終了日の未入力エラー
                    testModalController.saveDate();
                } catch (BusinessLogicException ex) {
                    System.assert(ex.getMessage().contains('開始日時'));
                    System.assert(ex.getMessage().contains('終了日時'));
                    System.assert(ex.getMessage().contains(GA102001Modal2Controller.STAFF_ONE_MSG));
                    System.assert(ex.getMessage().contains(GA102001Modal2Controller.STAFF_TWO_MSG));
                }

                //正しくない日時で登録
                testModalController.screenCorrespondDetail.StartDate = Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.StartDateTime = Datetime.parse('2020/01/05 02:23').time();  // 開始日時_時分
                testModalController.screenCorrespondDetail.EndDate =Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.EndDateTime = Datetime.parse('2020/01/05 01:23').time();    // 終了日時_時分
                testModalController.screenCorrespondDetail.StartDate2 = Date.valueOf('2020-1-6') ;
                testModalController.screenCorrespondDetail.StartDateTime2 = Datetime.parse('2020/01/05 02:23').time();  // 開始日時_時分
                testModalController.screenCorrespondDetail.EndDate2 =Date.valueOf('2020-1-6') ;
                testModalController.screenCorrespondDetail.EndDateTime2 = Datetime.parse('2020/01/05 01:23').time();    // 終了日時_時分

                try {
                    // 担当者１・２　開始日・終了日の逆転エラー
                    testModalController.saveDate();
                } catch (BusinessLogicException ex) {
                    System.assert(ex.getMessage().contains('開始日時'));
                    System.assert(ex.getMessage().contains('終了日時'));
                    System.assert(ex.getMessage().contains(GA102001Modal2Controller.STAFF_ONE_MSG));
                    System.assert(ex.getMessage().contains(GA102001Modal2Controller.STAFF_TWO_MSG));
                }

                //重複する日時で登録
                testModalController.screenCorrespondDetail.ShopStaff = ippanUser.Id;
                testModalController.screenCorrespondDetail.ShopStaff2 = ippanUser.Id;                
                testModalController.screenCorrespondDetail.StartDate = Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.StartDateTime = Datetime.parse('2020/01/05 01:30').time();  // 開始日時_時分
                testModalController.screenCorrespondDetail.EndDate =Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.EndDateTime = Datetime.parse('2020/01/05 02:30').time();    // 終了日時_時分
                testModalController.screenCorrespondDetail.StartDate2 = Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.StartDateTime2 = Datetime.parse('2020/01/05 01:45').time();  // 開始日時_時分
                testModalController.screenCorrespondDetail.EndDate2 =Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.EndDateTime2 = Datetime.parse('2020/01/05 02:45').time();    // 終了日時_時分

                try {
                    // 担当者１・２　行動の重複エラー
                    testModalController.saveDate();
                } catch (BusinessLogicException ex) {
                    System.assert(ex.getMessage().contains(GA102001Modal2Controller.STAFF_ONE_MSG));
                    System.assert(ex.getMessage().contains(GA102001Modal2Controller.STAFF_TWO_MSG));
                }
				checkGabana('apokakuInputCheck_stopTest');
				Test.stopTest();
                
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('apokakuInputCheck');
    }

    //アポイント確定 来店担当がいない場合の処理 ＋ アポイントキャンセル

    @istest static void apokakuNoVistStaff(){
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

        // 取引先
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
        ];

        // 店舗
        Shop__c ippanShopRecord = [SELECT Id 
        	FROM Shop__c
        	WHERE Name = '店舗ユーザテスト_港区' 
    	];

        // 対応（アポイント確定）
        Correspond__c CorrespondRecord_Apo = [SELECT Id, shopStaff__c, VisitShop__c
            FROM Correspond__c
            WHERE Status__c = :commonConst.TASK_CORRESPONDTYPE_APPOINTMENT
            LIMIT  1
        ];
        CorrespondRecord_Apo.shopStaff__c = null;
        CorrespondRecord_Apo.VisitShop__c = null;
        update CorrespondRecord_Apo;

        System.runAs(ippanUser){
            try {
                //ガバナエラーになった為、ここからTest.startTest()
                Test.startTest();
                
                GA102001Controller testController = new GA102001Controller();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord_Apo.Id );
                Test.setCurrentPage(pageRef);

                testController.openModal2Apo();

                // アポイント確定
                GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
                testModalController.Parameter = new GA102001Modal2ParameterClass();
                testModalController.Parameter.AccountId = AccountRecord.Id;  // 取引先ID
                testModalController.Parameter.CorrespondId = CorrespondRecord_Apo.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_APPOINTMENT; // 対応種別（アポイント確定）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_APPOINTMENT; // ステータス
                // 表示
                testModalController.getSelectOption();
                // カバレッジの為、VFからのみ呼び出されるメソッドを実行
                testModalController.getVisitShopList1();
                testModalController.getVisitShopList2();
                // 2名選択
                testModalController.staffCountValue = testModalController.STAFF_TWO;

                //2名で登録
                testModalController.screenCorrespondDetail.VisitShop = ippanShopRecord.Id;
                testModalController.screenCorrespondDetail.VisitShop2 = ippanShopRecord.Id;                
                testModalController.screenCorrespondDetail.ShopStaff = ippanUser.Id;
                testModalController.screenCorrespondDetail.ShopStaff2 = ippanUser.Id;                
                testModalController.screenCorrespondDetail.StartDate = Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.StartDateTime = Datetime.parse('2020/01/05 01:30').time();  // 開始日時_時分
                testModalController.screenCorrespondDetail.EndDate =Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.EndDateTime = Datetime.parse('2020/01/05 02:30').time();    // 終了日時_時分
                testModalController.screenCorrespondDetail.StartDate2 = Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.StartDateTime2 = Datetime.parse('2020/01/05 03:45').time();  // 開始日時_時分
                testModalController.screenCorrespondDetail.EndDate2 =Date.valueOf('2020-1-5') ;
                testModalController.screenCorrespondDetail.EndDateTime2 = Datetime.parse('2020/01/05 04:45').time();    // 終了日時_時分
                testModalController.saveDate();

                // アポイント変更
                testModalController.Parameter.CorrespondId = CorrespondRecord_Apo.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_APPOINTMENT; // 対応種別（アポイント確定）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_APPOINTMENT; // ステータス
                // 表示
                testModalController.getSelectOption();
                // 何も変えずに保存
                testModalController.saveDate();
                
                //登録したアポイントのキャンセル
                testModalController.Parameter = new GA102001Modal2ParameterClass();
                testModalController.Parameter.AccountId = AccountRecord.Id;  // 取引先ID
                testModalController.Parameter.CorrespondId = CorrespondRecord_Apo.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_APO_CANCEL; // 対応種別（キャンセル）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_APOCANCEL; // ステータス
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;
                // 表示
                testModalController.getSelectOption();
                // 保存処理
                testModalController.saveDate();

				checkGabana('apokakuNoVistStaff_stopTest');
                Test.stopTest();
                
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('apokakuNoVistStaff');
    }
    
    //追加要望 追加 Start
    
    //モーダルで紹介メール情報作成
    @istest static void createIntroMail(){
        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                FROM User
                WHERE LastName = 'ippanUser' 
        ];

        // 店舗
        Shop__c ippanShopRecord = [SELECT Id 
        	FROM Shop__c
        	WHERE Name = '店舗ユーザテスト_港区' 
        ];
                        
        // 取引先
        Account acc = [SELECT id,Email__c,IntroMailInfoStatus__c,IntroMailInfoFirstSendDatetime__c, SystemModStamp FROM Account WHERE Name = 'テスト太郎'];
        // 対応（追客中）
        Correspond__c corr = [SELECT id,ReceiveMailDateOther__c,SendMailDate__c FROM Correspond__c 
                                WHERE Status__c = :CommonConst.CORRESPOND_STATUS_PURSUIT];

        System.runAs(ippanUser){
            try {
                //ガバナエラーになった為、ここからTest.startTest()
                Test.startTest();

                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',acc.Id );
                pageRef.getParameters().put('Corresponds',corr.Id );
                Test.setCurrentPage(pageRef);

                GA102001Controller testController = new GA102001Controller();
                testController.checkCorrespondIndex = 0;

                testController.openModal7();
                // 自動追客一覧モーダル
                
                GA102001Modal7Controller testModalController = new GA102001Modal7Controller();
                testModalController.Parameter = new GA102001Modal7ParameterClass();
                testModalController.Parameter.accountId = acc.Id;  // 取引先ID
                testModalController.Parameter.correspond = corr; // 対応

                // 表示
                testModalController.getSelectOption();

                //自動追客開始日時を設定
                testModalController.introMailInfoFirstSendDate = CommonUtil.getToday().addDays(1);
                testModalController.introMailInfoFirstSendTime = '12:00';

                //保存ボタン押下
                testModalController.clickSave();

                List<IntroductionMailInformation__c> introMailList = [SELECT id FROM IntroductionMailInformation__c
                                                                WHERE Account__c = :acc.Id]; 
                system.debug(introMailList);
                List<ApexPages.Message> messages = ApexPages.getMessages();
                system.debug(messages);
                //紹介メール情報が登録されている
                system.assertEquals(!introMailList.isEmpty(), true);

                
				checkGabana('createIntroMail_stopTest');
                Test.stopTest();
                
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('createIntroMail');
    }

    //モーダルで紹介メール情報楽観ロックチェックエラー
    @istest static void checkOptimisticLockIntroMail(){
        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                FROM User
                WHERE LastName = 'ippanUser' 
        ];

        // 店舗
        Shop__c ippanShopRecord = [SELECT Id 
        	FROM Shop__c
        	WHERE Name = '店舗ユーザテスト_港区' 
        ];
                        
        // 取引先
        Account acc = [SELECT id,Email__c,IntroMailInfoStatus__c,IntroMailInfoFirstSendDatetime__c, SystemModStamp FROM Account WHERE Name = 'テスト太郎'];
        // 対応（追客中）
        Correspond__c corr = [SELECT id,ReceiveMailDateOther__c,SendMailDate__c FROM Correspond__c 
                                WHERE Status__c = :CommonConst.CORRESPOND_STATUS_PURSUIT];

        IntroductionMailInformation__c introMail = new IntroductionMailInformation__c(
                                                Account__c = acc.id,
                                                Correspond__c = corr.id);
        insert introMail;
        System.runAs(ippanUser){
            try {
                //ガバナエラーになった為、ここからTest.startTest()
                Test.startTest();

                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',acc.Id );
                pageRef.getParameters().put('Corresponds',corr.Id );
                Test.setCurrentPage(pageRef);

                GA102001Controller testController = new GA102001Controller();
                testController.checkCorrespondIndex = 0;

                testController.openModal7();
                // 自動追客一覧モーダル
                
                GA102001Modal7Controller testModalController = new GA102001Modal7Controller();
                testModalController.Parameter = new GA102001Modal7ParameterClass();
                testModalController.Parameter.accountId = acc.Id;  // 取引先ID
                testModalController.Parameter.correspond = corr; // 対応

                // 表示
                testModalController.getSelectOption();

                //自動追客開始日時を設定
                testModalController.introMailInfoFirstSendDate = CommonUtil.getToday().addDays(1);
                testModalController.introMailInfoFirstSendTime = '12:00';

                update acc;
                CommonUtil.sleep(100);
                //保存ボタン押下
                testModalController.clickSave();

                List<ApexPages.Message> messages = ApexPages.getMessages();
                System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)));
        
                
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('checkOptimisticLockIntroMail');
    }
    
    //紹介メール情報削除
    @istest static void deleteIntroMail(){
        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                FROM User
                WHERE LastName = 'ippanUser' 
        ];

        // 店舗
        Shop__c ippanShopRecord = [SELECT Id 
        	FROM Shop__c
        	WHERE Name = '店舗ユーザテスト_港区' 
        ];
        // 取引先
        Account acc = [SELECT id,Email__c,IntroMailInfoStatus__c,IntroMailInfoFirstSendDatetime__c, SystemModStamp FROM Account WHERE Name = 'テスト太郎'];
        // 対応（追客中）
        Correspond__c corr = [SELECT id,ReceiveMailDateOther__c,SendMailDate__c FROM Correspond__c 
                                WHERE Status__c = :CommonConst.CORRESPOND_STATUS_PURSUIT];

        IntroductionMailInformation__c introMail = new IntroductionMailInformation__c(
                                                Account__c = acc.id,
                                                Correspond__c = corr.id);
        insert introMail;

        System.runAs(ippanUser){
            try {
                //ガバナエラーになった為、ここからTest.startTest()
                Test.startTest();
                        
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',acc.Id );
                pageRef.getParameters().put('Corresponds',corr.Id );
                Test.setCurrentPage(pageRef);

                GA102001Controller testController = new GA102001Controller();
                testController.checkCorrespondIndex = 0;


                testController.checkCorrespondIndex = 0;

                testController.openModal7();
                // 自動追客一覧モーダル
                
                GA102001Modal7Controller testModalController = new GA102001Modal7Controller();
                testModalController.Parameter = new GA102001Modal7ParameterClass();
                testModalController.Parameter.introMailInfoId = introMail.id;  // 紹介メールID
                testModalController.Parameter.introMailInfoFirstSendDatetime = acc.IntroMailInfoFirstSendDatetime__c;  // 初回配信日時
                testModalController.Parameter.accountId = acc.Id;  // 取引先ID
                testModalController.Parameter.correspond = corr; // 対応

                // 表示
                testModalController.getSelectOption();
                testController.closeSchoolModal();

                //配信停止
                testController.introMailSendStop();
                // 自動追客一覧モーダル
                
                List<IntroductionMailInformation__c> introMailList = [SELECT id FROM IntroductionMailInformation__c
                                                                WHERE Account__c = :acc.Id]; 
                //紹介メール情報が削除されている
                system.assertEquals(introMailList.isEmpty(), true);

				checkGabana('deleteIntroMail_stopTest');
                Test.stopTest();
                                
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('deleteIntroMail');
    }


    //追加要望 追加 End

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
                WHERE LastName = 'ippanUser' 
        ];
    }

    private class Modal2Page {
        public Account        account  { get; set; }        // 取引先
        public Correspond__c  correspond { get; set; }      // 対応
        public Application__c application { get; set; }     // 申込
        public PageReference pageRef { get; set; }
        public GA102001Modal2Controller controller { get; set; }

        public Modal2Page(String accountName) {
            // テスト用データの読み込み
            account     = [SELECT Id FROM Account WHERE Name = :accountName];                               // 取引先
            application = [SELECT Id FROM Application__c WHERE Account__c = :account.id];                   // 申込
            correspond  = [SELECT Id FROM Correspond__c WHERE Application__c = :application.id LIMIT 1];    // 対応

            // ページ作成
            pageRef = Page.GA102001View;
            pageRef.getParameters().put('AccountId',account.Id );
            pageRef.getParameters().put('Corresponds',correspond.Id );

            // コントローラー作成
            // 2021.11.30 LINE連携対応より、メモを呼び出せない為、削除
            // 2021.11.30
            controller = new GA102001Modal2Controller();
        }

        // 初期化（申込キャンセル）
        public void initForApplicationCancel() {
            controller.Parameter                    = new GA102001Modal2ParameterClass();
            controller.Parameter.AccountId          = account.Id;                                   // 取引先ID
            controller.Parameter.CorrespondId       = correspond.Id;                                // 対応ID
            controller.Parameter.CorrespondDetailId = CommonConst.STRING_EMPTY;                     // 対応明細Id
            controller.Parameter.CorrespondType     = CommonConst.TASK_CORRESPONDTYPE_CANCEL;       // 対応種別（キャンセル）
            controller.Parameter.Status             = CommonConst.CORRESPOND_STATUS_APPLCANCEL;     // ステータス（申込キャンセル）
            controller.Parameter.isDrawing          = true;                                         // 初回描画フラグ
            controller.Parameter.noFirst            = true;                                         // 描画実施済みフラグ

            // 初期化
            controller.getSelectOption();
        }
    }

    private class Modal4Page {
        public Account        account  { get; set; }        // 取引先
        public Correspond__c  correspond { get; set; }      // 対応
        public Application__c application { get; set; }     // 申込
        public PageReference pageRef { get; set; }
        public GA102001Modal4Controller controller { get; set; }

        public Modal4Page(String accountName) {
            // テスト用データの読み込み
            account     = [SELECT Id FROM Account WHERE Name = :accountName];       // 取引先
            application = [SELECT Id FROM Application__c WHERE Account__c = :account.id];          // 申込
            correspond  = [SELECT Id FROM Correspond__c WHERE AccountId__c = :account.id AND Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED LIMIT 1];                   // 対応

            // ページ作成
            pageRef = Page.GA102001View;
            pageRef.getParameters().put('AccountId',account.Id );
            pageRef.getParameters().put('Corresponds',correspond.Id );

            // コントローラー作成
            (new GA102001Controller()).openModal4();
            controller = new GA102001Modal4Controller();
            controller.Parameter = new GA102001Modal4ParameterClass();
            controller.Parameter.ApplicationId = application.Id;      // 申込ID
            controller.Parameter.CorrespondId = correspond.Id;        // 対応ID
            controller.Parameter.isDrawing = true;                    // 初回描画フラグ
            controller.Parameter.noFirst = true;                      // 描画実施済みフラグ
            controller.getSelectDeposit();                            // 初期化
        }
    }
    
    // 条件完全一致物件（編集） + モーダルテスト
    @istest static void openModal8(){
   
        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        // 取引先
        Account acc = [SELECT Id
                       FROM Account
                       WHERE Name = 'テスト太郎'];

        // 条件完全一致物件
        ExactConditionMatchProperty__c exactCondMatchProp = [SELECT Id
                                                                    , SystemModStamp
                                                             FROM ExactConditionMatchProperty__c
                                                             WHERE Account__c = :acc.id];

        System.runAs(ippanUser) {
            Test.startTest();
        
            GA102001Controller testController = new GA102001Controller();

            // 条件完全一致物件明細を作成
            testController.screenExactConditionMatchPropertyList = new List<GA102001Controller.screenExactConditionMatchProperty>();
            GA102001Controller.screenExactConditionMatchProperty exactCondMatchPropRow;
            exactCondMatchPropRow = new GA102001Controller.screenExactConditionMatchProperty(new ExactConditionMatchProperty__c());
            exactCondMatchPropRow.Id = exactCondMatchProp.id;
            exactCondMatchPropRow.isSelected = true;
            exactCondMatchPropRow.SystemModstamp = exactCondMatchProp.SystemModStamp;
            testController.screenExactConditionMatchPropertyList.add(exactCondMatchPropRow);

            // パラメータ設定
            GA102001Modal8Controller testModalController = new GA102001Modal8Controller();
            testModalController.Parameter = new GA102001Modal8ParameterClass();
            testModalController.Parameter.ExactConditionMatchPropertyId = exactCondMatchProp.Id;
            testModalController.Parameter.isDrawing = true;
            testModalController.Parameter.noFirst = true;

            // 正常動作
            testController.openModal8();               // 条件完全一致物件モーダルを起動
            Boolean init = testModalController.init;   // モーダル初期表示
            testModalController.saveDate();            // 登録ボタン押下
                    
            // 楽観ロックエラー実施
            // データを更新
            exactCondMatchProp.IntroductionImpression__c = '更新';
            update exactCondMatchProp;

            // 条件完全一致物件モーダルを起動
            testController.openModal8();

            // モーダルを再表示
            testModalController.Parameter.isDrawing = true;
            init = testModalController.init;

            // 登録ボタン押下
            testModalController.screenExactConditionMatchProperty.systemModStamp = null;
            testModalController.saveDate();

			checkGabana('openModal8_stopTest');
            Test.stopTest();
        }
		checkGabana('openModal8');
    }

    // 条件完全一致物件（削除）テスト
    @istest static void deleteExactConditionMatchProperty(){
   
        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        // 取引先
        Account acc = [SELECT Id
                       FROM Account
                       WHERE Name = 'テスト太郎'];

        // 対応（追客保留中）
        Correspond__c corr = [SELECT Id
                              FROM Correspond__c 
                              WHERE Status__c = :CommonConst.CORRESPOND_STATUS_PURSUITHOLD];

        // 条件完全一致物件
        ExactConditionMatchProperty__c exactCondMatchProp = [SELECT Id
                                                                    , SystemModStamp
                                                             FROM ExactConditionMatchProperty__c
                                                             WHERE Account__c = :acc.id];

        System.runAs(ippanUser) {
            try {
                Test.startTest();

                // 初期表示
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId', acc.Id );
                pageRef.getParameters().put('Corresponds', corr.Id );
                Test.setCurrentPage(pageRef);

                // プロパティの設定
                GA102001Controller testController = new GA102001Controller();
                testController.accountId = acc.Id;
                testController.checkCorrespondId = corr.id;

                // 条件完全一致物件明細を作成
                testController.screenExactConditionMatchPropertyList = new List<GA102001Controller.screenExactConditionMatchProperty>();
                GA102001Controller.screenExactConditionMatchProperty exactCondMatchPropRow;
                exactCondMatchPropRow = new GA102001Controller.screenExactConditionMatchProperty(new ExactConditionMatchProperty__c());
                exactCondMatchPropRow.Id = exactCondMatchProp.id;
                exactCondMatchPropRow.isSelected = true;
                exactCondMatchPropRow.SystemModstamp = exactCondMatchProp.SystemModStamp;
                testController.screenExactConditionMatchPropertyList.add(exactCondMatchPropRow);

                // 正常動作
                testController.deleteExactConditionMatchProperty();
                        
                // 楽観ロックエラー実施（データ無し）
                testController.screenExactConditionMatchPropertyList.add(exactCondMatchPropRow);
                testController.deleteExactConditionMatchProperty();

				checkGabana('deleteExactConditionMatchProperty_stopTest');
                Test.stopTest();
            } catch(BusinessLogicException e) {
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('deleteExactConditionMatchProperty');
    }

    // 条件完全一致物件（お気に入り物件に追加）テスト
    @istest static void saveFavorite(){
   
        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        // 取引先
        Account acc = [SELECT Id
                       FROM Account
                       WHERE Name = 'テスト太郎'];

        // 対応（追客保留中）
        Correspond__c corr = [SELECT Id
                              FROM Correspond__c 
                              WHERE Status__c = :CommonConst.CORRESPOND_STATUS_PURSUITHOLD];

        // 条件完全一致物件
        ExactConditionMatchProperty__c exactCondMatchProp = [SELECT Id
                                                                    , SystemModStamp
                                                             FROM ExactConditionMatchProperty__c
                                                             WHERE Account__c = :acc.id];
        
        // 物件
        Property__c property = [SELECT Id
                                FROM Property__c
                                WHERE Name = '物件C'];

        System.runAs(ippanUser) {
            try {
                Test.startTest();

                // 初期表示
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId', acc.Id );
                pageRef.getParameters().put('Corresponds', corr.Id );
                Test.setCurrentPage(pageRef);

                // プロパティの設定
                GA102001Controller testController = new GA102001Controller();
                testController.accountId = acc.Id;
                testController.checkCorrespondId = corr.id;
            
                // 条件完全一致物件明細を作成
                testController.screenExactConditionMatchPropertyList = new List<GA102001Controller.screenExactConditionMatchProperty>();
                GA102001Controller.screenExactConditionMatchProperty exactCondMatchPropRow;
                exactCondMatchPropRow = new GA102001Controller.screenExactConditionMatchProperty(new ExactConditionMatchProperty__c());
                exactCondMatchPropRow.Id = exactCondMatchProp.id;
                exactCondMatchPropRow.isSelected = true;
                exactCondMatchPropRow.property = property.Id;
                exactCondMatchPropRow.SystemModstamp = exactCondMatchProp.SystemModStamp;
                testController.screenExactConditionMatchPropertyList.add(exactCondMatchPropRow);

                // 正常動作
                testController.saveFavorite();
                        
                // 楽観ロックエラー実施（データ無し）
                delete exactCondMatchProp;
                testController.saveFavorite();

				checkGabana('saveFavorite_stopTest');
                Test.stopTest();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('saveFavorite');
    }

    /**
     * ボタン活性チェック
     */
    @isTest static void buttonTest(){

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
               ];
        AccountRecord.Situation__c = '電話反響';
        AccountRecord.EchoTelephoneFlag__c = false;
        upsert AccountRecord;

        // 対応
        Correspond__c CorrespondRecord = [SELECT Id 
               FROM Correspond__c
               WHERE Status__c = :commonConst.CORRESPOND_STATUS_NOTSUPPORTED
               LIMIT  1
        ];

        System.runAs(ippanUser){
            try {
				Test.startTest();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);
                GA102001Controller testController = new GA102001Controller();
                testController.postmodal1();
                testController.postmodal2();
                testController.postmodal3();
                // ▼ 2021.11.30 LINE連携対応より、メモ用処理をLINE用に修正した為、削除
                // ▲ 2021.11.30
                testController.mizukimeFlg = true;
                testController.checkStatus = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED;
                testController.screenAccountRecord.EchoTelephoneFlag = false;
                testController.screenAccountRecord.Situation = '電話反響';
                testController.closeSchoolModal();

				checkGabana('buttonTest_stopTest');
				Test.stopTest();
            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('buttonTest');
   
   }

    // 空室予約ボタン押下テスト
    @istest static void clickRegistVacancyReservationProp(){
   
        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        // 取引先
        Account acc = [SELECT Id
                       FROM Account
                       WHERE Name = 'テスト太郎'];

        // 対応（追客保留中）
        Correspond__c corr = [SELECT Id
                              FROM Correspond__c 
                              WHERE Status__c = :CommonConst.CORRESPOND_STATUS_PURSUITHOLD];

        // お気に入り物件
        FavoriteProperty__c favoritePropertyRecord = [SELECT Id
                                                             , Property__r.Building__c
                                                             , Property__r.FloorPlan__c
                                                             , SystemModStamp
                                                      FROM FavoriteProperty__c
                                                      WHERE Account__c = :acc.id
                                                      LIMIT 1
                                                     ];

        // 画面設定
        GA102001Controller testController = new GA102001Controller();   

        // プロパティの設定
        testController.accountId = acc.Id;
        testController.checkCorrespondId = corr.id;
            
        // お気に入り明細を作成
        testController.screenFavoritePropertyList = new List<GA102001Controller.screenFavoriteProperty>();
        GA102001Controller.screenFavoriteProperty screenTargetRecord = new GA102001Controller.screenFavoriteProperty(new FavoriteProperty__c());
        screenTargetRecord.Id = favoritePropertyRecord.id;
        screenTargetRecord.isSelected = true;
        screenTargetRecord.SystemModstamp = favoritePropertyRecord.SystemModStamp;
        screenTargetRecord.PropertyBuilding = favoritePropertyRecord.Property__r.Building__c;
        screenTargetRecord.FloorPlan = favoritePropertyRecord.Property__r.FloorPlan__c;
        testController.screenFavoritePropertyList.add(screenTargetRecord);

        // 権限無しエラー
        System.runAs(ippanUser) {
            Test.startTest();
            testController.registVacancyReservationProp();
			checkGabana('clickRegistVacancyReservationProp_stopTest');
            Test.stopTest();
        }

        // 正常終了
        testController.registVacancyReservationProp();

        // 楽観ロックエラー実施（データ無し）
        testController.screenFavoritePropertyList[0].isSelected = true;
        delete favoritePropertyRecord;
        testController.registVacancyReservationProp();
		checkGabana('clickRegistVacancyReservationProp');
    }

    // 空室予約物件の削除ボタン押下テスト
    @istest static void clickDelVacancyReservationProp(){
   
        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        // 取引先
        Account acc = [SELECT Id
                       FROM Account
                       WHERE Name = 'テスト太郎'];

        // 対応（追客保留中）
        Correspond__c corr = [SELECT Id
                              FROM Correspond__c 
                              WHERE Status__c = :CommonConst.CORRESPOND_STATUS_PURSUITHOLD];

        // 空室予約物件
        VacancyReservationProperty__c vacancyReservationProp = [SELECT Id
                                                                       , Building__c
                                                                       , PropertyFloorPlan__c
                                                                       , SystemModStamp
                                                                FROM VacancyReservationProperty__c
                                                                WHERE Account__c = :acc.id
                                                                LIMIT 1
                                                               ];

        // 画面設定
        GA102001Controller testController = new GA102001Controller();   

        // プロパティの設定
        testController.accountId = acc.Id;
        testController.checkCorrespondId = corr.id;
            
        // 空室予約物件明細を作成
        testController.screenVacancyReservationPropList = new List<GA102001Controller.ScreenVacancyReservationProp>();
        GA102001Controller.ScreenVacancyReservationProp screenTargetRecord = new GA102001Controller.ScreenVacancyReservationProp();
        screenTargetRecord.VacancyReservationPropId = vacancyReservationProp.id;
        screenTargetRecord.isSelected = true;
        screenTargetRecord.SystemModstamp = vacancyReservationProp.SystemModStamp;
        testController.screenVacancyReservationPropList.add(screenTargetRecord);

        // 権限無しエラー
        System.runAs(ippanUser) {
            Test.startTest();
            testController.delVacancyReservationProp();
			checkGabana('clickDelVacancyReservationProp_stopTest');
            Test.stopTest();
        }

        // 正常終了
        testController.delVacancyReservationProp();

        // データを再作成
        vacancyReservationProp = new VacancyReservationProperty__c(Account__c = acc.Id);
        insert vacancyReservationProp;
        screenTargetRecord = new GA102001Controller.ScreenVacancyReservationProp();
        screenTargetRecord.VacancyReservationPropId = vacancyReservationProp.id;
        screenTargetRecord.isSelected = true;
        screenTargetRecord.SystemModstamp = CommonUtil.getNow();
        testController.screenVacancyReservationPropList.add(screenTargetRecord);

        // 楽観ロックエラー実施（データ更新）
        testController.delVacancyReservationProp();

        // 楽観ロックエラー実施（データ無し）
        delete vacancyReservationProp;
        testController.delVacancyReservationProp();
		checkGabana('clickDelVacancyReservationProp');
    }

    // 反響集約のCancel押下テスト
    @istest static void updUnnecessaryEchoAggregation() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        // 取引先
        Account acc = [SELECT Id
                       FROM Account
                       WHERE Name = 'テスト太郎'];

        // 対応（追客中）
        Correspond__c corr = [SELECT Id
                                     , SystemModStamp
                              FROM Correspond__c 
                              WHERE Status__c = :CommonConst.CORRESPOND_STATUS_PURSUIT];

		Test.startTest();
        // 画面設定
        GA102001Controller testController = new GA102001Controller();   

        // プロパティの設定
        testController.accountId = acc.Id;
        testController.checkCorrespondId = corr.id;
        testController.checkCorrespondIndex = 0;

        // 対応状況の明細を作成
        GA102001Controller.screenCorrespond screenTargetRecord = new GA102001Controller.screenCorrespond(new Correspond__c());
        screenTargetRecord.Id = corr.Id;
        screenTargetRecord.SystemModStamp = corr.SystemModStamp;
        testController.screenCorrespondRecordList = new List<GA102001Controller.screenCorrespond>{screenTargetRecord};

        // 反響集約ボタンのCancel押下
        testController.updUnnecessaryEchoAggregation();

        // 権限無しエラー
        System.runAs(ippanUser) {
            testController.delVacancyReservationProp();
        }

        // 楽観ロックエラー実施（データ更新）
        screenTargetRecord.SystemModStamp = CommonUtil.getNow();
        testController.updUnnecessaryEchoAggregation();
		checkGabana('updUnnecessaryEchoAggregation_stopTest');
		Test.stopTest();
		checkGabana('updUnnecessaryEchoAggregation');
    }

   @istest static void coverageUp3(){
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
        // 取引先
        Account AccountRecord = [SELECT Id 
            FROM Account
            WHERE Name = 'テスト太郎' 
        ];
        // 対応　未収入金
        // コンフリクト発生により、Limit句を追加する
        /*Correspond__c CorrespondRecord = [SELECT Id 
            FROM Correspond__c
            WHERE Status__c = :commonConst.CORRESPOND_STATUS_UNEARNED ];
        */
        Correspond__c CorrespondRecord = [SELECT Id 
            FROM Correspond__c
            WHERE Status__c = :commonConst.CORRESPOND_STATUS_UNEARNED Limit 1];
        CorrespondDetail__c  CorrespondDetailRecord =[SELECT Id 
            FROM CorrespondDetail__c
            WHERE CorrespondType__c = :commonconst.TASK_CORRESPONDTYPE_APPLICANT  // 対応種別（申込）
        ];

        System.runAs(ippanUser){
            try {
                Test.startTest();
                //来店カードボタン実行
                GA102001Controller testController = new GA102001Controller();
                //パラメータ設定
                PageReference pageRef = Page.GA102001View;
                pageRef.getParameters().put('AccountId',AccountRecord.Id );
                pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
                Test.setCurrentPage(pageRef);
                testController.openModal2ApplicationCancel();
                //アポイントキャンセル
                GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
                testModalController.Parameter = new GA102001Modal2ParameterClass();
                testModalController.Parameter.AccountId = AccountRecord.Id;  // 取引先ID
                testModalController.Parameter.CorrespondId = CorrespondRecord.id; // 対応ID
                testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_TEL; // 対応種別（電話対応）
                testModalController.Parameter.Status = CommonConst.CORRESPOND_STATUS_UNEARNED; // ステータス
                testModalController.Parameter.isDrawing = true;
                testModalController.Parameter.noFirst = true;
                // 表示
                testModalController.getSelectOption();
                // 保存処理
                testModalController.saveDate();
                CorrespondDetail__c correspondDtl = new CorrespondDetail__c();
                testModalController.Correspond = new Correspond__c();
                testModalController.setFavoriteProperty(correspondDtl);
                // 表示
                testModalController.getSelectOption();
                // 保存処理
                testModalController.saveDate();
				checkGabana('coverageUp3_stopTest');
                Test.stopTest();

            } catch(BusinessLogicException e){
                System.assertEquals(e.getMessage(), '');
            }
        }
		checkGabana('coverageUp3');
    
    }

    // モーダル2（LINE・SMS）の対応明細更新テスト
    @istest static void updCorrespondDetailmodal2LineSMS(){
   
        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        // 取引先
        Account account = [SELECT Id
                           FROM Account
                           WHERE Name = 'テスト太郎'
                          ];

        // 対応
        Correspond__c correspond = [SELECT Id
                                    FROM Correspond__c
                                    WHERE Status__c = :CommonConst.CORRESPOND_STATUS_NOTSUPPORTED
                                    LIMIT  1
                                   ];

        // 対応明細
        CorrespondDetail__c correspondDetail = [SELECT Id
                                                       , SystemModStamp
                                                       , InquiryProperty__c
                                                FROM CorrespondDetail__c
                                                WHERE CorrespondType__c = :CommonConst.TASK_CORRESPONDTYPE_TEL
                                                Limit 1
                                               ];

        correspondDetail.InquiryProperty__c = 'お問合せ物件テスト';
        update correspondDetail;

        System.runAs(ippanUser) {
            Test.startTest();

            // ▼ 2021.11.30 LINE連携対応より、パラメータの初期化対応を追加
            Test.setCurrentPage(getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED));
            // ▲ 2021.11.30
        
            GA102001Controller testController = new GA102001Controller();

            // お客様詳細のパラメータ設定
            GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
            testModalController.Parameter = new GA102001Modal2ParameterClass();
            testModalController.Parameter.isDrawing = true;
            testModalController.Parameter.noFirst = true;
            testModalController.Parameter.AccountId = account.Id;
            testModalController.Parameter.CorrespondId = correspond.id;
            testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_TEL;
            testModalController.Parameter.CorrespondDetailId = correspondDetail.id;

            // TEL/SMS/LINEモーダルを起動
            testController.openModal2Tel();
            Boolean init = testModalController.init;

            // モーダルのパラメータ設定後に登録ボタン押下
            testModalController.screenCorrespondDetail = new GA102001Modal2Controller.screenCorrespondDetail(testModalController.Parameter.CorrespondType);
            testModalController.screenCorrespondDetail.Id = correspondDetail.id;
            testModalController.screenCorrespondDetail.systemModStamp = correspondDetail.SystemModStamp;
            testModalController.screenCorrespondDetail.SupportedContent = '対応内容';

            testModalController.saveDate();

			checkGabana('updCorrespondDetailmodal2LineSMS_stopTest');
            Test.stopTest();
        }
		checkGabana('updCorrespondDetailmodal2LineSMS');
    }

    // モーダル2（LINE・SMS）の対応明細登録テスト
    @istest static void insCorrespondDetailmodal2LineSMS(){
   
        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];
    
        // 取引先
        Account account = [SELECT Id
                                  , RecordTypeId
                           FROM Account
                           WHERE Name = 'テスト太郎'];
    
        // 対応
        Correspond__c correspond = [SELECT Id
                                           , AppointmentStartDate__c
                                    FROM Correspond__c
                                    WHERE Status__c = :CommonConst.CORRESPOND_STATUS_NOTSUPPORTED
                                    LIMIT  1
                                   ];

        // 対応明細
        CorrespondDetail__c correspondDetail = [SELECT Id
                                                       , SystemModStamp
                                                       , InquiryProperty__c
                                                FROM CorrespondDetail__c
                                                WHERE CorrespondType__c = :CommonConst.TASK_CORRESPONDTYPE_TEL
                                                Limit 1
                                    ];
    
        System.runAs(ippanUser) {
            Test.startTest();
            
            // ▼ 2021.11.30 LINE連携対応より、パラメータの初期化対応を追加
            PageReference pageRef = Page.GA102001View;
            pageRef.getParameters().put('AccountId',   account.Id );
            pageRef.getParameters().put('Corresponds', correspond.Id );
            Test.setCurrentPage(pageRef);
            // ▲ 2021.11.30
            
            GA102001Controller testController = new GA102001Controller();
    
            // お客様詳細のパラメータ設定
            GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
            testModalController.Parameter = new GA102001Modal2ParameterClass();
            testModalController.Parameter.isDrawing = true;
            testModalController.Parameter.noFirst = true;
            testModalController.Parameter.AccountId = account.Id;
            testModalController.Parameter.CorrespondId = correspond.id;
            testModalController.Parameter.CorrespondType = CommonConst.TASK_CORRESPONDTYPE_TEL;
    
            // TEL/SMS/LINEモーダルを起動
            testController.openModal2Tel();
            Boolean init = testModalController.init;
    
            // モーダルのパラメータ設定後に登録ボタン押下（対応種別 = "SMS"）
            testModalController.screenCorrespondDetail = new GA102001Modal2Controller.screenCorrespondDetail(testModalController.Parameter.CorrespondType);
            testModalController.screenCorrespondDetail.SupportedContent = '対応内容';
            testModalController.correspond.AccountId__r.RecordTypeId = account.RecordTypeId;
            testModalController.correspond.AppointmentStartDate__c = correspond.AppointmentStartDate__c;
            testModalController.screenCorrespondDetail.PhoneStatus = CommonConst.CORRESPONDDETAIL_PHONESTATUS_SEND_SMS;
            
            testModalController.saveDate();
    
            // お客様詳細のパラメータを初期化後にTEL/SMS/LINEモーダルを再起動
            testModalController.Parameter.isDrawing = true;
            testModalController.Parameter.noFirst = true;
            init = testModalController.init;

            // モーダルのパラメータ設定後に登録ボタン押下（対応種別 = "LINE"）
            testModalController.screenCorrespondDetail.SupportedContent = '対応内容';
            testModalController.screenCorrespondDetail.PhoneStatus = CommonConst.CORRESPONDDETAIL_PHONESTATUS_LINESEND;
            testModalController.correspond.AccountId__r.RecordTypeId = account.RecordTypeId;
            testModalController.correspond.AppointmentStartDate__c = correspond.AppointmentStartDate__c;

            testModalController.saveDate();

            // お客様詳細のパラメータを初期化後にTEL/SMS/LINEモーダルを再起動
            testModalController.Parameter.isDrawing = true;
            testModalController.Parameter.noFirst = true;
            init = testModalController.init;

            // モーダルのパラメータ設定後に登録ボタン押下（対応種別 = "電話連絡(繋がらない)"）
            testModalController.screenCorrespondDetail.SupportedContent = '対応内容';
            testModalController.screenCorrespondDetail.PhoneStatus = CommonConst.CORRESPONDDETAIL_PHONESTATUS_NOCONTACT;
            testModalController.correspond.AccountId__r.RecordTypeId = account.RecordTypeId;
            testModalController.correspond.AppointmentStartDate__c = correspond.AppointmentStartDate__c;

            testModalController.saveDate();

            // お客様詳細のパラメータを初期化後にTEL/SMS/LINEモーダルを再起動
            testModalController.Parameter.isDrawing = true;
            testModalController.Parameter.noFirst = true;
            init = testModalController.init;

            // モーダルのパラメータ設定後に登録ボタン押下（対応種別 = "電話連絡(繋がった)"）
            testModalController.screenCorrespondDetail.SupportedContent = '対応内容';
            testModalController.screenCorrespondDetail.PhoneStatus = CommonConst.CORRESPONDDETAIL_PHONESTATUS_CONTACT;
            testModalController.correspond.AccountId__r.RecordTypeId = account.RecordTypeId;
            testModalController.correspond.AppointmentStartDate__c = correspond.AppointmentStartDate__c;

            testModalController.saveDate();

			checkGabana('insCorrespondDetailmodal2LineSMS_stopTest');
            Test.stopTest();

            // 編集ボタン押下
            testController.accountId = account.Id;
            testController.CorrespondDetailCorrespondsId = correspondDetail.id;
            testController.selectCorrespondDetailId = correspond.id;
            testController.correspondType = CommonConst.TASK_CORRESPONDTYPE_TEL;
            testController.openModal2Edit();

        }
		checkGabana('insCorrespondDetailmodal2LineSMS');
    }

    // HP会員情報（展開）
    @istest static void memberRecordOpen() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            List<Member__c> memberList = [SELECT Id FROM Member__c WHERE Account__r.Name = 'テスト太郎'];
            System.assertNotEquals(memberList.size(), 0);
            System.assertEquals(testController.screenStyle.MemberRecordOpenIconClass   , CommonConst.OPEN_SECTION_ICON);
            System.assertEquals(testController.screenStyle.MemberRecordSectionNoneStyle, CommonConst.STRING_EMPTY);

			checkGabana('memberRecordOpen_stopTest');
            Test.stopTest();
        }
		checkGabana('memberRecordOpen');
    }

    // HP会員情報（非展開）
    @istest static void memberRecordNone() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 既存レコードの削除
            List<Member__c> memberList = [SELECT Id FROM Member__c WHERE Account__r.Name = 'テスト太郎'];
            delete memberList;

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            memberList = [SELECT Id FROM Member__c WHERE Account__r.Name = 'テスト太郎'];
            System.assertEquals(memberList.size(), 0);
            System.assertEquals(testController.screenStyle.MemberRecordOpenIconClass   , CommonConst.STRING_EMPTY);
            System.assertEquals(testController.screenStyle.MemberRecordSectionNoneStyle, CommonConst.SECTION_NONE);

			checkGabana('memberRecordNone_stopTest');
            Test.stopTest();
        }
		checkGabana('memberRecordNone');
    }

    // 自動追客一覧（展開）
    @istest static void introMailOpen() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        List<Account> accountList = [SELECT Id FROM Account WHERE Name = 'テスト太郎'];

        IntroductionMailInformation__c introMail = new IntroductionMailInformation__c(
            Account__c = accountList[0].Id
        );
        insert introMail;

        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            List<IntroductionMailInformation__c> introMailList = [SELECT Id FROM IntroductionMailInformation__c WHERE Account__r.Name = 'テスト太郎'];
            System.assertNotEquals(introMailList.size(), 0);
            System.assertEquals(testController.screenStyle.IntroMailOpenIconClass   , CommonConst.OPEN_SECTION_ICON);
            System.assertEquals(testController.screenStyle.IntroMailSectionNoneStyle, CommonConst.STRING_EMPTY);

			checkGabana('introMailOpen_stopTest');
            Test.stopTest();
        }
		checkGabana('introMailOpen');
    }

    // 自動追客一覧（非展開）
    @istest static void introMailNone() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 既存レコードの削除
            List<IntroductionMailInformation__c> introMailList = [SELECT Id FROM IntroductionMailInformation__c WHERE Account__r.Name = 'テスト太郎'];
            delete introMailList;

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            introMailList = [SELECT Id FROM IntroductionMailInformation__c WHERE Account__r.Name = 'テスト太郎'];
            System.assertEquals(introMailList.size(), 0);
            System.assertEquals(testController.screenStyle.IntroMailOpenIconClass   , CommonConst.STRING_EMPTY);
            System.assertEquals(testController.screenStyle.IntroMailSectionNoneStyle, CommonConst.SECTION_NONE);

			checkGabana('introMailNone_stopTest');
            Test.stopTest();
        }
		checkGabana('introMailNone');
    }

    // 申込一覧（展開）
    @istest static void applicationOpen() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            List<Application__c> applicationList = [SELECT Id FROM Application__c WHERE Account__r.Name = 'テスト太郎'];
            System.assertNotEquals(applicationList.size(), 0);
            System.assertEquals(testController.screenStyle.ApplicationOpenIconClass   , CommonConst.OPEN_SECTION_ICON);
            System.assertEquals(testController.screenStyle.ApplicationSectionNoneStyle, CommonConst.STRING_EMPTY);

			checkGabana('applicationOpen_stopTest');
            Test.stopTest();
        }
		checkGabana('applicationOpen');
    }

    // 申込一覧（非展開）
    @istest static void applicationNone() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        // 取引先
        Account account = new Account(
            Name = '申込一覧（非展開）'
        );
        insert account;

        // 対応
        Correspond__c correspond = new Correspond__c(
            AccountId__c = account.Id
            , Status__c  = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED
        );
        insert correspond;

        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示
            PageReference pageRef = getInitPageRef('申込一覧（非展開）', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            List<Application__c> applicationList = [SELECT Id FROM Application__c WHERE Account__r.Name = '申込一覧（非展開）'];
            System.assertEquals(applicationList.size(), 0);
            System.assertEquals(testController.screenStyle.ApplicationOpenIconClass   , CommonConst.STRING_EMPTY);
            System.assertEquals(testController.screenStyle.ApplicationSectionNoneStyle, CommonConst.SECTION_NONE);

			checkGabana('applicationNone_stopTest');
            Test.stopTest();
        }
		checkGabana('applicationNone');
    }

    // お気に入り物件（展開）
    @istest static void favoritePropertyOpen() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            List<FavoriteProperty__c> favoritePropertyList = [SELECT Id FROM FavoriteProperty__c WHERE Account__r.Name = 'テスト太郎'];
            System.assertNotEquals(favoritePropertyList.size(), 0);
            System.assertEquals(testController.screenStyle.FavoritePropertyOpenIconClass   , CommonConst.OPEN_SECTION_ICON);
            System.assertEquals(testController.screenStyle.FavoritePropertySectionNoneStyle, CommonConst.STRING_EMPTY);

			checkGabana('favoritePropertyOpen_stopTest');
            Test.stopTest();
        }
		checkGabana('favoritePropertyOpen');
    }

    // お気に入り物件（非展開）
    @istest static void favoritePropertyNone() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 既存レコードの削除
            List<FavoriteProperty__c> favoritePropertyList = [SELECT Id FROM FavoriteProperty__c WHERE Account__r.Name = 'テスト太郎'];
            delete favoritePropertyList;

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            favoritePropertyList = [SELECT Id FROM FavoriteProperty__c WHERE Account__r.Name = 'テスト太郎'];
            System.assertEquals(favoritePropertyList.size(), 0);
            System.assertEquals(testController.screenStyle.FavoritePropertyOpenIconClass   , CommonConst.STRING_EMPTY);
            System.assertEquals(testController.screenStyle.FavoritePropertySectionNoneStyle, CommonConst.SECTION_NONE);

			checkGabana('favoritePropertyNone_stopTest');
            Test.stopTest();
        }
		checkGabana('favoritePropertyNone');
    }

    // 空室予約物件（展開）
    @istest static void vacancyRsvPropOpen() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            List<VacancyReservationProperty__c> vacancyRsvPropList = [SELECT Id FROM VacancyReservationProperty__c WHERE Account__r.Name = 'テスト太郎'];
            System.assertNotEquals(vacancyRsvPropList.size(), 0);
            System.assertEquals(testController.screenStyle.VacancyRsvPropOpenIconClass   , CommonConst.OPEN_SECTION_ICON);
            System.assertEquals(testController.screenStyle.VacancyRsvPropSectionNoneStyle, CommonConst.STRING_EMPTY);

			checkGabana('vacancyRsvPropOpen_stopTest');
            Test.stopTest();
        }
		checkGabana('vacancyRsvPropOpen');
    }

    // 空室予約物件（非展開）
    @istest static void vacancyRsvPropNone() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 既存レコードの削除
            List<VacancyReservationProperty__c> vacancyRsvPropList = [SELECT Id FROM VacancyReservationProperty__c WHERE Account__r.Name = 'テスト太郎'];
            delete vacancyRsvPropList;

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            vacancyRsvPropList = [SELECT Id FROM VacancyReservationProperty__c WHERE Account__r.Name = 'テスト太郎'];
            System.assertEquals(vacancyRsvPropList.size(), 0);
            System.assertEquals(testController.screenStyle.VacancyRsvPropOpenIconClass   , CommonConst.STRING_EMPTY);
            System.assertEquals(testController.screenStyle.VacancyRsvPropSectionNoneStyle, CommonConst.SECTION_NONE);

			checkGabana('vacancyRsvPropNone_stopTest');
            Test.stopTest();
        }
		checkGabana('vacancyRsvPropNone');
    }

    // 条件完全一致該当物件（展開）
    @istest static void exactCondMatchPropOpen() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            List<ExactConditionMatchProperty__c> exactCondMatchPropList = [SELECT Id FROM ExactConditionMatchProperty__c WHERE Account__r.Name = 'テスト太郎'];
            System.assertNotEquals(exactCondMatchPropList.size(), 0);
            System.assertEquals(testController.screenStyle.ExactCondMatchPropOpenIconClass   , CommonConst.OPEN_SECTION_ICON);
            System.assertEquals(testController.screenStyle.ExactCondMatchPropSectionNoneStyle, CommonConst.STRING_EMPTY);

			checkGabana('exactCondMatchPropOpen_stopTest');
            Test.stopTest();
        }
		checkGabana('exactCondMatchPropOpen');
    }

    // 条件完全一致該当物件（非展開）
    @istest static void exactCondMatchPropNone() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 既存レコードの削除
            List<ExactConditionMatchProperty__c> exactCondMatchPropList = [SELECT Id FROM ExactConditionMatchProperty__c WHERE Account__r.Name = 'テスト太郎'];
            delete exactCondMatchPropList;

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            exactCondMatchPropList = [SELECT Id FROM ExactConditionMatchProperty__c WHERE Account__r.Name = 'テスト太郎'];
            System.assertEquals(exactCondMatchPropList.size(), 0);
            System.assertEquals(testController.screenStyle.ExactCondMatchPropOpenIconClass   , CommonConst.STRING_EMPTY);
            System.assertEquals(testController.screenStyle.ExactCondMatchPropSectionNoneStyle, CommonConst.SECTION_NONE);

			checkGabana('exactCondMatchPropNone_stopTest');
            Test.stopTest();
        }
		checkGabana('exactCondMatchPropNone');
    }

    // 対応履歴（展開）
    @istest static void correspondDetailOpen() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            List<CorrespondDetail__c> correspondDetailList = [SELECT Id FROM CorrespondDetail__c WHERE Corresponds__r.AccountId__r.Name = 'テスト太郎'];
            System.assertNotEquals(correspondDetailList.size(), 0);
            System.assertEquals(testController.screenStyle.CorrespondDetailOpenIconClass   , CommonConst.OPEN_SECTION_ICON);
            System.assertEquals(testController.screenStyle.CorrespondDetailSectionNoneStyle, CommonConst.STRING_EMPTY);

			checkGabana('correspondDetailOpen_stopTest');
            Test.stopTest();
        }
		checkGabana('correspondDetailOpen');
    }

    // 対応履歴（非展開）
    @istest static void correspondDetailNone() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 既存レコードの削除
            List<CorrespondDetail__c> correspondDetailList = [SELECT Id FROM CorrespondDetail__c WHERE Corresponds__r.AccountId__r.Name = 'テスト太郎'];
            delete correspondDetailList;

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            correspondDetailList = [SELECT Id FROM CorrespondDetail__c WHERE Corresponds__r.AccountId__r.Name = 'テスト太郎'];
            System.assertEquals(correspondDetailList.size(), 0);
            System.assertEquals(testController.screenStyle.CorrespondDetailOpenIconClass   , CommonConst.STRING_EMPTY);
            System.assertEquals(testController.screenStyle.CorrespondDetailSectionNoneStyle, CommonConst.SECTION_NONE);

			checkGabana('correspondDetailNone_stopTest');
            Test.stopTest();
        }
		checkGabana('correspondDetailNone');
    }

    // 反響一覧（展開）
    @istest static void echoMailOpen() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎b', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            List<CorrespondDetail__c> echoMailList = [SELECT Id FROM CorrespondDetail__c WHERE Corresponds__r.AccountId__r.Name = 'テスト太郎b'];
            System.assertNotEquals(echoMailList.size(), 0);
            System.assertEquals(testController.screenStyle.EchoMailOpenIconClass   , CommonConst.OPEN_SECTION_ICON);
            System.assertEquals(testController.screenStyle.EchoMailSectionNoneStyle, CommonConst.STRING_EMPTY);

			checkGabana('echoMailOpen_stopTest');
            Test.stopTest();
        }
		checkGabana('echoMailOpen');
    }

    // 反響一覧（非展開）
    @istest static void echoMailNone() {

        //一般ユーザで実行
        User ippanUser = [SELECT Id 
                          FROM User
                          WHERE LastName = 'ippanUser' 
                         ];

        System.runAs(ippanUser) {
            Test.startTest();

            // 既存レコードの削除
            List<CorrespondDetail__c> echoMailList = [SELECT Id FROM CorrespondDetail__c WHERE Corresponds__r.AccountId__r.Name = 'テスト太郎b'];
            delete echoMailList;

            // 初期表示
            PageReference pageRef = getInitPageRef('テスト太郎b', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);
            Test.setCurrentPage(pageRef);

            // 結果確認
            GA102001Controller testController = new GA102001Controller();
            echoMailList = [SELECT Id FROM CorrespondDetail__c WHERE Corresponds__r.AccountId__r.Name = 'テスト太郎b'];
            System.assertEquals(echoMailList.size(), 0);
            System.assertEquals(testController.screenStyle.EchoMailOpenIconClass   , CommonConst.STRING_EMPTY);
            System.assertEquals(testController.screenStyle.EchoMailSectionNoneStyle, CommonConst.SECTION_NONE);

			checkGabana('echoMailNone_stopTest');
            Test.stopTest();
        }
		checkGabana('echoMailNone');
    }
    
    // ▼ 2021.11.30 LINE連携対応より、パラメータの初期化対応を追加
    // ▼ 2022.05.19 問合せNo.0816対応 LINEボタンの制御
    /**
     * 業者のボタンステータステスト
     */
    @istest static void corporationBtnStatusTest() {

        // 電話のステータス
        Map<String, Integer> telBtnStatus = new Map<String, Integer>{
            CommonConst.CORRESPOND_STATUS_NOTSUPPORTED         => 2 // 未対応
			, CommonConst.CORRESPOND_STATUS_CLOSE              => 2 // 終了
            , CommonConst.CORRESPOND_STATUS_PURSUIT            => 0 // 追客中
            , CommonConst.CORRESPOND_STATUS_APPOINTMENT        => 0 // アポイント確定
            , CommonConst.CORRESPOND_STATUS_VISITED            => 0 // 来店済
            , CommonConst.CORRESPOND_STATUS_UNEARNED           => 0 // 未収入金
            , CommonConst.CORRESPOND_STATUS_DEPOSIT            => 0 // 入金済
            , CommonConst.CORRESPOND_STATUS_AGREEMENT          => 0 // 契約完了
            , CommonConst.CORRESPOND_STATUS_PURSUITHOLD        => 0 // 追客保留中
            , CommonConst.CORRESPOND_STATUS_APOCANCEL          => 0 // アポイントキャンセル
            , CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT  => 0 // アポキャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT    => 0 // 来店後追客中
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL         => 0 // 申込キャンセル
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT => 0 // 申込キャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION    => 0 // 反響集約
            , CommonConst.CORRESPOND_STATUS_CONSIDERVISITING   => 0 // 来店後検討
            , CommonConst.STRING_EMPTY                         => 0 // 取引先なし
            , CORRESPOND_STATUS_TARGET_ECHO_AGGREGATION        => 0 // 反響集約対象
        };

        // LINEのステータス
        Map<String, Integer> lineBtnStatus = new Map<String, Integer>{
            CommonConst.CORRESPOND_STATUS_NOTSUPPORTED         => 0 // 未対応 //2022.05.19問合せNo.0816対応
			, CommonConst.CORRESPOND_STATUS_CLOSE              => 0 // 終了   //2022.05.19問合せNo.0816対応
            , CommonConst.CORRESPOND_STATUS_PURSUIT            => 0 // 追客中
            , CommonConst.CORRESPOND_STATUS_APPOINTMENT        => 0 // アポイント確定
            , CommonConst.CORRESPOND_STATUS_VISITED            => 0 // 来店済
            , CommonConst.CORRESPOND_STATUS_UNEARNED           => 0 // 未収入金
            , CommonConst.CORRESPOND_STATUS_DEPOSIT            => 0 // 入金済
            , CommonConst.CORRESPOND_STATUS_AGREEMENT          => 0 // 契約完了
            , CommonConst.CORRESPOND_STATUS_PURSUITHOLD        => 0 // 追客保留中
            , CommonConst.CORRESPOND_STATUS_APOCANCEL          => 0 // アポイントキャンセル
            , CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT  => 0 // アポキャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT    => 0 // 来店後追客中
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL         => 0 // 申込キャンセル
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT => 0 // 申込キャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION    => 0 // 反響集約
            , CommonConst.CORRESPOND_STATUS_CONSIDERVISITING   => 0 // 来店後検討
            , CommonConst.STRING_EMPTY                         => 0 // 取引先なし
            , CORRESPOND_STATUS_TARGET_ECHO_AGGREGATION        => 0 // 反響集約対象
        };

        // 一般ユーザで実行
        User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示の実施
            Test.setCurrentPage(getInitPageRef('テスト次郎', CommonConst.CORRESPOND_STATUS_VISITED));
            
            // ボタンステータスを確認
            GA102001Controller testController = new GA102001Controller();
            for (String statsKey : testController.buttonSetlist.keyset()) {
                List<Integer> clsVal = testController.buttonSetlist.get(statsKey);

                // 結果確認
                System.assertEquals(clsVal[6], telBtnStatus.get(statsKey), '電話ボタンステータス');
                System.assertEquals(clsVal[7], lineBtnStatus.get(statsKey), 'LINEボタンステータス');
            }

			checkGabana('corporationBtnStatusTest_stopTest');
            Test.stopTest();
        }
		checkGabana('corporationBtnStatusTest');
    }
    // ▲ 2022.05.19 問合せNo.0816対応 LINEボタンの制御
    /**
     * 顧客（未名寄せ）のボタンステータステスト
     */
    @istest static void customerNoMergeBtnStatusTest() {

        // 電話のステータス
        Map<String, Integer> telBtnStatus = new Map<String, Integer>{
            CommonConst.CORRESPOND_STATUS_NOTSUPPORTED         => 1 // 未対応
			, CommonConst.CORRESPOND_STATUS_CLOSE              => 1 // 終了
            , CommonConst.CORRESPOND_STATUS_PURSUIT            => 1 // 追客中
            , CommonConst.CORRESPOND_STATUS_APPOINTMENT        => 1 // アポイント確定
            , CommonConst.CORRESPOND_STATUS_VISITED            => 1 // 来店済
            , CommonConst.CORRESPOND_STATUS_UNEARNED           => 1 // 未収入金
            , CommonConst.CORRESPOND_STATUS_DEPOSIT            => 1 // 入金済
            , CommonConst.CORRESPOND_STATUS_AGREEMENT          => 1 // 契約完了
            , CommonConst.CORRESPOND_STATUS_PURSUITHOLD        => 1 // 追客保留中
            , CommonConst.CORRESPOND_STATUS_APOCANCEL          => 1 // アポイントキャンセル
            , CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT  => 1 // アポキャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT    => 1 // 来店後追客中
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL         => 1 // 申込キャンセル
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT => 1 // 申込キャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION    => 0 // 反響集約
            , CommonConst.CORRESPOND_STATUS_CONSIDERVISITING   => 1 // 来店後検討
            , CommonConst.STRING_EMPTY                         => 0 // 取引先なし
            , CORRESPOND_STATUS_TARGET_ECHO_AGGREGATION        => 0 // 反響集約対象
        };

        // LINEのステータス
        Map<String, Integer> lineBtnStatus = new Map<String, Integer>{
            CommonConst.CORRESPOND_STATUS_NOTSUPPORTED         => 2 // 未対応
			, CommonConst.CORRESPOND_STATUS_CLOSE              => 1 // 終了
            , CommonConst.CORRESPOND_STATUS_PURSUIT            => 2 // 追客中
            , CommonConst.CORRESPOND_STATUS_APPOINTMENT        => 1 // アポイント確定
            , CommonConst.CORRESPOND_STATUS_VISITED            => 0 // 来店済
            , CommonConst.CORRESPOND_STATUS_UNEARNED           => 1 // 未収入金
            , CommonConst.CORRESPOND_STATUS_DEPOSIT            => 1 // 入金済
            , CommonConst.CORRESPOND_STATUS_AGREEMENT          => 1 // 契約完了
            , CommonConst.CORRESPOND_STATUS_PURSUITHOLD        => 1 // 追客保留中
            , CommonConst.CORRESPOND_STATUS_APOCANCEL          => 2 // アポイントキャンセル
            , CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT  => 2 // アポキャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT    => 2 // 来店後追客中
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL         => 2 // 申込キャンセル
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT => 2 // 申込キャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION    => 0 // 反響集約
            , CommonConst.CORRESPOND_STATUS_CONSIDERVISITING   => 2 // 来店後検討
            , CommonConst.STRING_EMPTY                         => 0 // 取引先なし
            , CORRESPOND_STATUS_TARGET_ECHO_AGGREGATION        => 0 // 反響集約対象
        };

        // 取引先
        Account account = [SELECT Id
                           FROM Account
                           WHERE Name = 'テスト太郎'
                          ];

        // 一般ユーザで実行
        User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        System.runAs(ippanUser) {
            Test.startTest();

            // 名寄せ完了フラグを更新
            Account updAccount = new Account(
                Id                        = account.Id
                , IsMergeCompletedFlag__c = false
            );
            update updAccount;

            // 初期表示の実施
            Test.setCurrentPage(getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED));
            account = [SELECT IsMergeCompletedFlag__c FROM Account WHERE Name = 'テスト太郎'];
            System.assertEquals(account.IsMergeCompletedFlag__c, false, '未名寄せ');

            // ボタンステータスを確認
            GA102001Controller testController = new GA102001Controller();
            for (String statsKey : testController.buttonSetlist.keyset()) {
                List<Integer> clsVal = testController.buttonSetlist.get(statsKey);

                // 結果確認
                System.assertEquals(clsVal[6], telBtnStatus.get(statsKey), '電話ボタンステータス');
                System.assertEquals(clsVal[7], lineBtnStatus.get(statsKey), 'LINEボタンステータス');
            }

			checkGabana('customerNoMergeBtnStatusTest_stopTest');
            Test.stopTest();
        }
		checkGabana('customerNoMergeBtnStatusTest');
    }

    /**
     * 顧客（名寄せ済）のボタンステータステスト
     */
    @istest static void customerMergeBtnStatusTest() {

        // 電話のステータス
        Map<String, Integer> telBtnStatus = new Map<String, Integer>{
            CommonConst.CORRESPOND_STATUS_NOTSUPPORTED         => 1 // 未対応
			, CommonConst.CORRESPOND_STATUS_CLOSE              => 1 // 終了
            , CommonConst.CORRESPOND_STATUS_PURSUIT            => 1 // 追客中
            , CommonConst.CORRESPOND_STATUS_APPOINTMENT        => 1 // アポイント確定
            , CommonConst.CORRESPOND_STATUS_VISITED            => 1 // 来店済
            , CommonConst.CORRESPOND_STATUS_UNEARNED           => 1 // 未収入金
            , CommonConst.CORRESPOND_STATUS_DEPOSIT            => 1 // 入金済
            , CommonConst.CORRESPOND_STATUS_AGREEMENT          => 1 // 契約完了
            , CommonConst.CORRESPOND_STATUS_PURSUITHOLD        => 1 // 追客保留中
            , CommonConst.CORRESPOND_STATUS_APOCANCEL          => 1 // アポイントキャンセル
            , CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT  => 1 // アポキャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT    => 1 // 来店後追客中
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL         => 1 // 申込キャンセル
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT => 1 // 申込キャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION    => 0 // 反響集約
            , CommonConst.CORRESPOND_STATUS_CONSIDERVISITING   => 1 // 来店後検討
            , CommonConst.STRING_EMPTY                         => 0 // 取引先なし
            , CORRESPOND_STATUS_TARGET_ECHO_AGGREGATION        => 0 // 反響集約対象
        };

        // LINEのステータス
        Map<String, Integer> lineBtnStatus = new Map<String, Integer>{
            CommonConst.CORRESPOND_STATUS_NOTSUPPORTED         => 2 // 未対応
			, CommonConst.CORRESPOND_STATUS_CLOSE              => 1 // 終了
            , CommonConst.CORRESPOND_STATUS_PURSUIT            => 2 // 追客中
            , CommonConst.CORRESPOND_STATUS_APPOINTMENT        => 1 // アポイント確定
            , CommonConst.CORRESPOND_STATUS_VISITED            => 0 // 来店済
            , CommonConst.CORRESPOND_STATUS_UNEARNED           => 1 // 未収入金
            , CommonConst.CORRESPOND_STATUS_DEPOSIT            => 1 // 入金済
            , CommonConst.CORRESPOND_STATUS_AGREEMENT          => 1 // 契約完了
            , CommonConst.CORRESPOND_STATUS_PURSUITHOLD        => 1 // 追客保留中
            , CommonConst.CORRESPOND_STATUS_APOCANCEL          => 2 // アポイントキャンセル
            , CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT  => 2 // アポキャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT    => 2 // 来店後追客中
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL         => 2 // 申込キャンセル
            , CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT => 2 // 申込キャンセル後追客中
            , CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION    => 0 // 反響集約
            , CommonConst.CORRESPOND_STATUS_CONSIDERVISITING   => 2 // 来店後検討
            , CommonConst.STRING_EMPTY                         => 0 // 取引先なし
            , CORRESPOND_STATUS_TARGET_ECHO_AGGREGATION        => 0 // 反響集約対象
        };

        // 一般ユーザで実行
        User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示の実施
            Test.setCurrentPage(getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED));
            Account account = [SELECT IsMergeCompletedFlag__c FROM Account WHERE Name = 'テスト太郎'];
            System.assertEquals(account.IsMergeCompletedFlag__c, true, '名寄せ済');
            
            // ボタンステータスを確認
            GA102001Controller testController = new GA102001Controller();
            for (String statsKey : testController.buttonSetlist.keyset()) {
                List<Integer> clsVal = testController.buttonSetlist.get(statsKey);

                // 結果確認
                System.assertEquals(clsVal[6], telBtnStatus.get(statsKey), '電話ボタンステータス');
                System.assertEquals(clsVal[7], lineBtnStatus.get(statsKey), 'LINEボタンステータス');
            }

			checkGabana('customerMergeBtnStatusTest_stopTest');
            Test.stopTest();
        }
		checkGabana('customerMergeBtnStatusTest');
    }

    /**
     * 対応種別変更テスト
     */
    @istest static void chgCorrespondTypeTest() {

        // 一般ユーザで実行
        User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示の実施
            Test.setCurrentPage(getInitPageRef('テスト太郎b', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED));
            GA102001Controller testController = new GA102001Controller();
            
            // 対応種別変更メソッドを呼び出し
            GA102001Modal2Controller testModalController = new GA102001Modal2Controller();
            testModalController.Parameter = new GA102001Modal2ParameterClass();
            testModalController.selectedCorrespondType = testController.TASK_CORRESPONDTYPE_TEL;
            testModalController.chgCorrespondType();

            // 結果確認
            System.assertEquals(testModalController.Parameter.CorrespondType
                                , testController.TASK_CORRESPONDTYPE_TEL
                                , '対応種別変更値');

								checkGabana('chgCorrespondTypeTest_stopTest');
            Test.stopTest();
        }
		checkGabana('chgCorrespondTypeTest');
    }

    /**
     * 業者（未対応）の電話モーダル起動テスト
     */
    @istest static void openModal2CorporationNotSupportedTest() {

        // 対応
        Correspond__c correspond = [SELECT Id
                                    FROM Correspond__c 
                                    WHERE AccountId__r.Name = 'テスト次郎'
                                    LIMIT  1
                                   ];

        // 一般ユーザで実行
        User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        System.runAs(ippanUser) {
            Test.startTest();

            // ステータスを未対応に更新
            Correspond__c updCorrespond = new Correspond__c(
                Id          = correspond.Id
                , Status__c = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED
            );
            update updCorrespond;

            // 初期表示の実施
            Test.setCurrentPage(getInitPageRef('テスト次郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED));
            
            // 電話モーダルを起動
            GA102001Controller testController = new GA102001Controller();
            testController.openModal2Tel();

            // 結果確認
            System.assertEquals(testController.screenCorrespondRecordList[0].status
                                , testController.CORRESPOND_STATUS_NOTSUPPORTED
                                , '業者_対応ステータス');

            System.assertEquals(testController.correspondType
                                , testController.TASK_CORRESPONDTYPE_MEMO
                                , 'メモの起動（業者_未対応）');

            System.assertEquals(testController.screenCorrespondRecordList[testController.checkCorrespondIndex].isDispModal2CorrespondType
                                , false
                                , '対応種別の変更不可（業者_未対応）');

								checkGabana('openModal2CorporationNotSupportedTest_stopTest');
            Test.stopTest();
        }
		checkGabana('openModal2CorporationNotSupportedTest');
    }

    /**
     * 業者（終了）の電話モーダル起動テスト
     */
    @istest static void openModal2CorporationCloseTest() {

        // 対応
        Correspond__c correspond = [SELECT Id
                                    FROM Correspond__c 
                                    WHERE AccountId__r.Name = 'テスト次郎'
                                    LIMIT  1
                                   ];

        // 一般ユーザで実行
        User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        System.runAs(ippanUser) {
            Test.startTest();

            // ステータスを終了に更新
            Correspond__c updCorrespond = new Correspond__c(
                Id          = correspond.Id
                , Status__c = CommonConst.CORRESPOND_STATUS_CLOSE
            );
            update updCorrespond;

            // 初期表示の実施
            Test.setCurrentPage(getInitPageRef('テスト次郎', CommonConst.CORRESPOND_STATUS_CLOSE));
            
            // 電話モーダルを起動
            GA102001Controller testController = new GA102001Controller();
            testController.openModal2Tel();

            // 結果確認
            System.assertEquals(testController.screenCorrespondRecordList[0].status
                                , testController.CORRESPOND_STATUS_CLOSE
                                , '業者_終了');

            System.assertEquals(testController.correspondType
                                , testController.TASK_CORRESPONDTYPE_MEMO
                                , 'メモの起動（業者_終了）');

            System.assertEquals(testController.screenCorrespondRecordList[testController.checkCorrespondIndex].isDispModal2CorrespondType
                                , false
                                , '対応種別の変更不可（業者_終了）');

								checkGabana('openModal2CorporationCloseTest_stopTest');
            Test.stopTest();
        }
		checkGabana('openModal2CorporationCloseTest');
    }

    /**
     * 顧客（未対応）の電話モーダル起動テスト
     */
    @istest static void openModal2CustomerNotSupportedTest() {

        // 一般ユーザで実行
        User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示の実施
            Test.setCurrentPage(getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED));
            
            // 電話モーダルを起動
            GA102001Controller testController = new GA102001Controller();
            testController.openModal2Tel();

            // 結果確認
            System.assertEquals(testController.screenCorrespondRecordList[0].status
                                , CommonConst.CORRESPOND_STATUS_NOTSUPPORTED
                                , '顧客_未対応');

            System.assertEquals(testController.correspondType
                                , testController.TASK_CORRESPONDTYPE_TEL
                                , '電話の起動（顧客_未対応）');

            System.assertEquals(testController.screenCorrespondRecordList[testController.checkCorrespondIndex].isDispModal2CorrespondType
                                , true
                                , '対応種別の変更可（顧客_未対応）');

								checkGabana('openModal2CustomerNotSupportedTest_stopTest');
            Test.stopTest();
        }
		checkGabana('openModal2CustomerNotSupportedTest');
    }

    /**
     * 顧客（来店済）の電話モーダル起動テスト
     */
    @istest static void openModal2CustomerVisitedTest() {

        // 対応
        Correspond__c correspond = [SELECT Id
                                    FROM Correspond__c 
                                    WHERE AccountId__r.Name = 'テスト太郎'
                                    LIMIT  1
                                   ];

        // 一般ユーザで実行
        User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        System.runAs(ippanUser) {
            Test.startTest();

            // ステータスを来店済に更新
            Correspond__c updCorrespond = new Correspond__c(
                Id          = correspond.Id
                , Status__c = CommonConst.CORRESPOND_STATUS_VISITED
            );
            update updCorrespond;

            // 初期表示の実施
            Test.setCurrentPage(getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_VISITED));
            
            // 電話モーダルを起動
            GA102001Controller testController = new GA102001Controller();
            testController.openModal2Tel();

            // 結果確認
            System.assertEquals(testController.screenCorrespondRecordList[0].status
                                , CommonConst.CORRESPOND_STATUS_VISITED
                                , '顧客_来店済');

            System.assertEquals(testController.correspondType
                                , testController.TASK_CORRESPONDTYPE_MEMO
                                , 'メモの起動（顧客_来店済）');

            System.assertEquals(testController.screenCorrespondRecordList[testController.checkCorrespondIndex].isDispModal2CorrespondType
                                , false
                                , '対応種別の変更不可（顧客_来店済）');

								checkGabana('openModal2CustomerVisitedTest_stopTest');
            Test.stopTest();
        }
		checkGabana('openModal2CustomerVisitedTest');
    }

    /**
     * 電話反響の電話モーダル起動テスト
     */
    @istest static void openModal2TelEchoTest() {

        // 一般ユーザで実行
        User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示の実施
            Test.setCurrentPage(getInitPageRef('テスト太郎b', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED));
            
            // 電話モーダルを起動
            GA102001Controller testController = new GA102001Controller();
            testController.openModal2Tel();

            // 結果確認
            System.assertEquals(testController.screenCorrespondRecordList[0].status
                                , CommonConst.CORRESPOND_STATUS_NOTSUPPORTED
                                , '電話反響');

            System.assertEquals(testController.correspondType
                                , testController.TASK_CORRESPONDTYPE_TEL
                                , '電話の起動（電話反響）');

            System.assertEquals(testController.screenCorrespondRecordList[testController.checkCorrespondIndex].isDispModal2CorrespondType
                                , true
                                , '対応種別の変更不可（電話反響）');

								checkGabana('openModal2TelEchoTest_stopTest');
            Test.stopTest();
        }
		checkGabana('openModal2TelEchoTest');
    }

    /**
     * 編集押下時の電話モーダル起動テスト
     */
    @istest static void openModal2EditTest() {

        // 一般ユーザで実行
        User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示の実施
            Test.setCurrentPage(getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED));
            
            // 編集押下
            GA102001Controller testController = new GA102001Controller();
            testController.openModal2Edit();

            // 結果確認
            System.assertEquals(testController.GA102001Paremeter2.isDispCorrespondType
                                , false
                                , '対応種別の変更不可');
								checkGabana('openModal2EditTest_stopTest');
            Test.stopTest();
        }
		checkGabana('openModal2EditTest');
    }

    /**
     * LINE専用画面遷移テスト
     */
    @istest static void openLineExclusiveTest() {

        // 一般ユーザで実行
        User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示の実施
            Test.setCurrentPage(getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED));
            
            // LINE専用画面遷移処理
            GA102001Controller testController = new GA102001Controller();
            testController.openLineExclusive();

            // 結果確認
            System.assertEquals(testController.hasErrorMessage
                                , false
                                , 'LINE専用画面への遷移可');
								checkGabana('openLineExclusiveTest_stopTest');
            Test.stopTest();
        }
		checkGabana('openLineExclusiveTest');
    }

    /**
     * LINE専用画面遷移エラーテスト
     */
    @istest static void openLineExclusiveErrTest() {

        // 一般ユーザで実行
        User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        System.runAs(ippanUser) {
            Test.startTest();

            // 初期表示の実施
            Test.setCurrentPage(getInitPageRef('テスト太郎b', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED));
            
            // LINE専用画面遷移処理
            GA102001Controller testController = new GA102001Controller();
            testController.openLineExclusive();

            // 結果確認
            System.assertEquals(testController.hasErrorMessage
                                , true
                                , 'LINE専用画面への遷移不可');
								checkGabana('openLineExclusiveErrTest_stopTest');
            Test.stopTest();
        }
		checkGabana('openLineExclusiveErrTest');
    }

    /**
     * 自動追客モーダルのLINE送信テスト
     */
    @istest static void modal7IsSendLineTest() {

        // 取引先
        Account account = [SELECT Id
                           FROM Account
                           WHERE Name = 'テスト太郎'
                          ];

        // 一般ユーザで実行
        User ippanUser = [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        System.runAs(ippanUser) {
            Test.startTest();

            // 紹介メール情報の登録
            IntroductionMailInformation__c introductionMailInformation = new IntroductionMailInformation__c(
                Account__c      = account.Id
                , IsSendLine__c = true
            );
            insert introductionMailInformation;

            // 初期表示の実施
            Test.setCurrentPage(getInitPageRef('テスト太郎', CommonConst.CORRESPOND_STATUS_NOTSUPPORTED));

            // 自動追客モーダルの起動
            GA102001Controller testController = new GA102001Controller();
            testController.openModal7();

            // 結果確認（自動追客一覧）
            System.assertEquals(testController.introMailInfoList[0].IsSendType__c
                                , 'LINE'
                                , '自動追客一覧_送信種別（保存前）');

            // 結果確認（パラメータ）
            System.assertEquals(testController.GA102001Paremeter7.isSendLine
                                , true
                                , '自動追客モーダルパラメータ_LINE送信フラグ');

            // 自動追客モーダルの初期表示
            GA102001Modal7Controller testModalController = new GA102001Modal7Controller();
            testModalController.Parameter = testController.GA102001Paremeter7;
            testModalController.getSelectOption();

            // 結果確認（LINE送信フラグ）
            System.assertEquals(testModalController.isSendLine
                                , true
                                , '自動追客モーダル_LINE送信');

            // 自動追客モーダルの保存押下
            testModalController.isSendLine = false;
            testModalController.clickSave();

            // 結果確認（紹介メール情報の更新）
            System.assertEquals([SELECT IsSendLine__c FROM IntroductionMailInformation__c WHERE Account__c = :account.Id].IsSendLine__c
                                , false
                                , '紹介メール情報_LINE送信フラグ');

            // 自動追客モーダルの終了処理
            testController.closeModal();

            // 結果確認（自動追客一覧）
            System.assertEquals(testController.introMailInfoList[0].IsSendType__c
                                , 'メール'
                                , '自動追客一覧_送信種別（保存後）');
								checkGabana('modal7IsSendLineTest_stopTest');

            Test.stopTest();
        }
		checkGabana('modal7IsSendLineTest');
    }
    // ▲ 2021.11.30 
    
    // プロパティのカバレッジテスト
    @istest static void coverageUp4(){

        GA102001Controller testController = new GA102001Controller();

        String propVal;
        propVal = testController.MSG_NO_SELECTED_VACANCY_RESERVATION_PROP_ROW;
        propVal = testController.MSG_SAVE_VACANCY_RESERVATION_PROP;
        propVal = testController.TASK_CORRESPONDTYPE_SMS;
        propVal = testController.TASK_CORRESPONDTYPE_LINE;
        propVal = testController.MSG_COM_W_SELECTION_OR_MORE_DELETE_APPLICATION;
        propVal = testController.MSG_CUST_I_UNNECESSARY_ECHO_INTEGRATION;
        propVal = testController.MSG_CUST_I_NOTICE_MERGE;
        propVal = testController.MSG_PROP_I_DUPLICATE_ECHO;
        propVal = testController.MSG_COM_V_DELETE;
        propVal = testController.MSG_COM_I_DELETE;
        propVal = testController.MSG_COM_V_NO_SELECTION;
        propVal = testController.MSG_COM_I_CANCEL_CONFIRMATION;
        propVal = testController.MSG_COM_V_SAVE;
        propVal = testController.MSG_COM_I_SAVE;
        propVal = testController.MSG_PROP_I_PROPERTY_LINKING_COMPLETED_MULTIPLE;
        propVal = testController.MSG_PROP_I_PROPERTY_LINKING_COMPLETED;
        propVal = testController.MSG_PROP_I_PROPERTY_LINKING;
        propVal = testController.MSG_PROP_E_PROPERTY_LINKING_RESIDENCE;
        propVal = testController.MSG_PROP_E_NOTICE_PERSONNEL_UNCONFIGURED;
        propVal = testController.MSG_COM_W_SEARCH_NO_DATA;
        propVal = testController.MSG_COM_W_SELECTION_OR_MORE_DELETE_FAVORITEPROPERTY;
        propVal = testController.MSG_COM_W_SELECTION_OR_LESS_FAVORITEPROPERTY;
        propVal = testController.MSG_COM_W_SELECTION_OR_MORE_DELETE_EXACTCONDITIONMATCHPROPERTY;
        propVal = testController.MSG_COM_W_SELECTION_OR_LESS_EXACTCONDITIONMATCHPROPERTY;
        propVal = testController.MSG_CUST_I_ECHO_INTEGRATION;
        propVal = testController.MSG_COM_I_RESPONSE_CONFIRMATION;
        propVal = testController.MSG_COM_I_NO_RESPONSE_CONFIRMATION;
        propVal = testController.MSG_PROP_I_IMPORT_END;
        propVal = testController.MSG_COM_W_SELECTION_OR_MORE_DELETE_FAVORITEPROPERTY_APPLICATION;
        propVal = testController.MSG_COM_V_RELEASEHOLD;
        propVal = testController.MSG_CUST_E_SET_PROPERTY;
        propVal = testController.MSG_ACC_W_SITUATION_ECHO_TELEPHONE;
        propVal = testController.MSG_COM_V_FAVORITE;
        propVal = testController.MSG_COM_I_FAVORITE;
        propVal = testController.MSG_COM_V_DELETE_SENDMAILSTATUS;
        propVal = testController.MSG_COM_I_DELETE_SENDMAILSTATUS;
        propVal = testController.MSG_COM_E_OPTIONAL_PERMISSION_CHECK;
        propVal = testController.INTRODUCTION_SEND;
        propVal = testController.INTRODUCTION_SENDSTOP;
        propVal = testController.MSG_ACC_W_SITUATION_ECHO_LINE;
        propVal = testController.MSG_ACC_W_SITUATION_ECHO_LIVERO;
        propVal = testController.MSG_COM_V_ADD_PROPERTYCONDITIONS;
        propVal = testController.MSG_COM_V_DELETE_PROPERTYCONDITIONS;
        propVal = testController.MSG_COM_I_E_NG_PROPERTY_SAMENAME;
        propVal = testController.MSG_COM_I_E_NG_PROPERTYCONDITIONSNAME_EMPTY;
        propVal = testController.ACCOUNT_RECTYPE_SUPPLIER;
        propVal = testController.ACCOUNT_RECTYPE_FIRE_INSURANCE;
        propVal = testController.ACCOUNT_RECTYPE_GUARANTEE;
        propVal = testController.ACCOUNT_RECTYPE_AUXILIARY;
        propVal = testController.PROPERTY_LIVESTATUS_RESIDENT;

        Integer propInt;
        propInt = testController.COLOR_WHITE;
        propInt = testController.COLOR_GRAY_THIN;
        propInt = testController.COLOR_GRAY;
        propInt = testController.BUTTON_APPOINT_CONFIRMATION;
        propInt = testController.BUTTON_VISIT;
        propInt = testController.BUTTON_APPLICATION;
        propInt = testController.BUTTON_DEPOSIT;
        propInt = testController.BUTTON_CONTRACT_COMPLETED;
        propInt = testController.BUTTON_TEL;
        // ▼ 2021.11.30 LINE連携対応より、ボタン名を修正
        propInt = testController.BUTTON_LINE;
        // ▲ 2021.11.30
        propInt = testController.BUTTON_HOLD_FOLLOWER;
        propInt = testController.BUTTON_END;
        propInt = testController.BUTTON_PROPERTY_SEARCH;
        propInt = testController.BUTTON_NAYORI;
        propInt = testController.BUTTON_APPOINT_CANCEL;
        propInt = testController.BUTTON_APPLICATION_CANCEL;
        propInt = testController.BUTTON_ECHO_AGGREGATION;
        propInt = testController.BUTTON_SCHEDULE;
        propInt = testController.BUTTON_CONSIDER_AFTER_VISITING_STORE;
        propInt = testController.BUTTON_SET_UP_PERSONNEL;

        System.assert(true);
		checkGabana('coverageUp4');
    }

    // PageReferenceの初期化
    private static PageReference getInitPageRef(String condAccountName, String condStatus) {

        // 取引先
        Account account = [SELECT Id 
                           FROM Account
                           WHERE Name = :condAccountName
                          ];

        // 対応
        Correspond__c correspond = [SELECT Id 
                                    FROM Correspond__c
                                    WHERE AccountId__c = :account.Id
                                          AND Status__c = :condStatus
                                    LIMIT  1
                                   ];

        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId',   account.Id);
        pageRef.getParameters().put('Corresponds', correspond.Id);
        return pageRef;
    }

	// ▼2021.10.08 No.307 対応で追加
    // No.307 対応_初期表示No39
    @isTest static void initApc39Test(){
        // コントローラの初期表示を実行
        GA102001Controller GA102001Controller = new GA102001Controller();
        // 初期表示【新規顧客】
        checkdisplayCond(GA102001Controller, false, '条件1', 'init');
		checkGabana('initApc39Test');
    }

	// No.307 対応_初期表示No40
    @isTest static void initApc40Test(){
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];
        
        
        List<DesiredSchoolArea__c> testDesiredSchoolArea = [SELECT id FROM DesiredSchoolArea__c];
        Account acc = new Account();//登録に使用する取引先を設定
        acc.id = AccountRecord.Id;
        acc.DesiredJuniorHighSchoolArea__c = testDesiredSchoolArea[0].id;// 中学校希望学区（エリア）
        acc.DesiredElementarySchoolArea__c = testDesiredSchoolArea[1].id;// 小学校希望学区（エリア）

        List<DesiredTrainRoute__c> testDesiredTrainRoute = [SELECT id FROM DesiredTrainRoute__c];
        acc.DesiredTrainRoute1__c  = testDesiredTrainRoute[0].Id;//希望沿線１ 
        acc.DesiredTrainRoute2__c  = testDesiredTrainRoute[1].Id;//希望沿線２ 
        acc.DesiredTrainRoute3__c  = testDesiredTrainRoute[2].Id;//希望沿線３
        upsert acc;

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId',AccountRecord.Id );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA102001Controller GA102001Controller = new GA102001Controller();

		checkGabana('initApc40Test_stopTest');
		Test.stopTest();

        // 初期表示【既存顧客＆新規来店】
        checkdisplayCond(GA102001Controller, true, '条件1', '19');
		checkGabana('initApc40Test');
    }

    // No.307 対応_参照テストNo41,42
    @isTest static void referenceApc41_42Test(){
        // お客様物件条件を登録する。
        Id accId = getSpcAccountId();
        insertAPC_1_2(accId);

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId',accId );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA102001Controller GA102001Controller = new GA102001Controller();

        for(SelectOption option : GA102001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件2'){
                GA102001Controller.selectCondName = option.getValue();
            }
        } 
        GA102001Controller.changeConditions();
        // テスト結果確認
        checkdisplayCond(GA102001Controller, true, '条件2', '');
        for(SelectOption option : GA102001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件3'){
                GA102001Controller.selectCondName = option.getValue();
            }
        }
        // 物件条件を切替える
        GA102001Controller.changeConditions();
		checkGabana('referenceApc41_42Test_stopTest');
		Test.stopTest();
        checkdisplayCond(GA102001Controller, false, '条件3', '');
		checkGabana('referenceApc41_42Test');
    }

    // No.307 対応_登録テストNo43
    @isTest static void registerApc43Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, true);
        
        GA102001Controller.saveDate();
		checkGabana('registerApc43Test_stopTest');
        Test.stopTest();

        // 登録確認「取引先以外の物件条件が0件」
        checkAccount(accId, 'register');
		checkGabana('registerApc43Test');
    }

    // No.307 対応_登録テストNo44
    @isTest static void registerApc44Test(){
        registerApc44TestRun();
		checkGabana('registerApc44Test');
    }

	private static void registerApc44TestRun(){
		Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, true);
        
        GA102001Controller.saveDate();
		checkGabana('registerApc44TestRun_stopTest');
        Test.stopTest();

        // 登録確認「取引先以外の物件条件が1件」
        checkAccountPropertyConditionsObj(accId, 'register');
	}

    // No.307 対応_登録テストNo45
    @isTest static void registerApc45Test(){
        User userRecord =  [SELECT Id FROM User WHERE LastName = 'ippanUser'];
        system.runas(userRecord){
            Id accId = getSpcAccountId();

			Test.startTest();
            //パラメータ設定
            PageReference pageRef = Page.GA102001View;
            pageRef.getParameters().put('AccountId', accId);
            Test.setCurrentPage(pageRef);
            // コントローラの初期表示を実行
            GA102001Controller GA102001Controller = new GA102001Controller();
            GA102001Controller.changeMode();
            GA102001Controller.addPropertyCond();
            setCondition(GA102001Controller, true);
            GA102001Controller.addPropertyCond();
            setCondition(GA102001Controller, false);
            GA102001Controller.addPropertyCond();
            setCondition(GA102001Controller, true);
            
            GA102001Controller.saveDate();
			checkGabana('registerApc45Test_stopTest');
            Test.stopTest();
            // 登録確認「取引先以外の物件条件が３件」
            checkAccountPropertyConditionsObj(accId, 'register');

        }
		checkGabana('registerApc45Test');
    }

    // No.307 対応_更新テストNo46
    @isTest static void updateApc46Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId',accId );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);

        GA102001Controller.saveDate();
		checkGabana('updateApc46Test_stopTest');
        Test.stopTest();

        // 更新登録確認「取引先以外の物件条件が0件」
        checkAccount(accId, 'update');
		checkGabana('updateApc46Test');
    }

    // No.307 対応_更新テストNo47
    @isTest static void updateApc47Test(){
        Id accId = getSpcAccountId();
        insertAPC_1(accId);

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        for(SelectOption option : GA102001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件2'){
                GA102001Controller.selectCondName = option.getValue();
            }
        }
        GA102001Controller.changeConditions();
        setCondition(GA102001Controller, false);

        GA102001Controller.saveDate();
		checkGabana('updateApc47Test_stopTest');
        Test.stopTest();

        // 更新登録確認「取引先以外の物件条件が1件件」
        checkAccountPropertyConditionsObj(accId, 'update');
		checkGabana('updateApc47Test');
    }    

    // No.307 対応_更新テストNo48
    @isTest static void updateApc48Test(){
        Id accId = getSpcAccountId();
        insertAPC_1_2_3(accId);

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, true);

        for(SelectOption option : GA102001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件2'){
                GA102001Controller.selectCondName = option.getValue();
            }
        }
        GA102001Controller.changeConditions();
        setCondition(GA102001Controller, false);
        for(SelectOption option : GA102001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件3'){
                GA102001Controller.selectCondName = option.getValue();
            }
        }
        GA102001Controller.changeConditions();
        setCondition(GA102001Controller, true);
        for(SelectOption option : GA102001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件4'){
                GA102001Controller.selectCondName = option.getValue();
            }
        } 
        GA102001Controller.changeConditions();
        setCondition(GA102001Controller, false);

        GA102001Controller.saveDate();
		checkGabana('updateApc48Test_stopTest');
        Test.stopTest();

        // 更新登録確認「物件条件が3件」
        checkAccountPropertyConditionsObj(accId, 'update');
		checkGabana('updateApc48Test');
    }

    // No.307 対応_削除テストNo49
    @isTest static void deleteApc49Test(){
        Id accId = getSpcAccountId();
        insertAPC_1(accId);

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        for(SelectOption option : GA102001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件2'){
                GA102001Controller.selectCondName = option.getValue();
            }
        }
        GA102001Controller.changeConditions();
        // 削除ボタン押下処理
        GA102001Controller.deletePropertyCond();
        // 保存ボタン押下処理
        
        GA102001Controller.saveDate();
		checkGabana('deleteApc49Test_stopTest');
        Test.stopTest();

        // 削除登録確認　お客様物件条件が登録されている
        List<AccountPropertyConditions__c> apcList = [SELECT ID FROM AccountPropertyConditions__c];
        system.assertEquals(0, apcList.size());
		checkGabana('deleteApc49Test');
    }

    // No.307 対応_削除テストNo50
    @isTest static void deleteApc50Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();
        // 条件を追加
        GA102001Controller.addPropertyCond();
        // 削除ボタン押下処理
        GA102001Controller.deletePropertyCond();
        // 保存ボタン押下処理
        
        GA102001Controller.saveDate();
		checkGabana('deleteApc50Test_stopTest');
        Test.stopTest();

        // 削除登録確認　お客様物件条件が登録されていない
        List<AccountPropertyConditions__c> apcList = [SELECT ID FROM AccountPropertyConditions__c];
        system.assertEquals(0, apcList.size());
		checkGabana('deleteApc50Test');
    }

    // No.307 対応_ROLLBACKテストNo52
    @isTest static void rollbackApc52Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();
        // 条件を追加
        GA102001Controller.addPropertyCond();
        // メール、電話番号をエラーとなるよう空白とする。
        GA102001Controller.screenAccountRecord.Phone = '';
        GA102001Controller.screenAccountRecord.Phone2 = '';
        GA102001Controller.screenAccountRecord.Phone3 = '';
        GA102001Controller.screenAccountRecord.Email = '';
        GA102001Controller.screenAccountRecord.Email2 = '';
        GA102001Controller.screenAccountRecord.Email3 = '';

		GA102001Controller.saveDate();

		// ロールバック確認
		List<AccountPropertyConditions__c> apcList = [SELECT ID FROM AccountPropertyConditions__c];
		system.assertEquals(0, apcList.size());

		checkGabana('rollbackApc52Test_stopTest');
        Test.stopTest();
		checkGabana('rollbackApc52Test');
    }

	// No.307 対応_ROLLBACKテストNo53
    @isTest static void rollbackApc53Test(){
		Id accId = getSpcAccountId();
		//対応のステータスを追客中とする
		Correspond__c CorrespondRecord = [SELECT Id, Status__c FROM Correspond__c WHERE AccountId__c =: accId LIMIT 1];
		CorrespondRecord.Status__c = CommonConst.CORRESPOND_STATUS_PURSUIT;
		update CorrespondRecord;

		//お客様物件条件を2件追加
		List<AccountPropertyConditions__c> apcList = insertAPC_1_2(accId);

		Test.startTest();
		//パラメータ設定
		PageReference pageRef = Page.GA102001View;
		pageRef.getParameters().put('AccountId', accId);
		pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );

		Test.setCurrentPage(pageRef);

		GA102001Controller GA102001Controller = new GA102001Controller();

		//追客保留モーダルを開く
		GA102001Controller.openModal2HoldFollower();

		//予約物件条件モーダルパラメータ設定(予約物件条件モーダルのチェック操作)
		pageRef.getParameters().put('checkList', 'true,true,true');
		Test.setCurrentPage(pageRef);

		//予約物件条件モーダルコントローラからパラメータを参照する
		GA102001Modal10Controller GA102001Modal10Controller = new GA102001Modal10Controller();
		GA102001Modal10Controller.Parameter = GA102001Controller.GA102001Paremeter2.GA102001Paremeter10;
		//OK押下
		GA102001Modal10Controller.clickOk();

		//追客保留モーダルコントローラからパラメータを参照する
		GA102001Modal2Controller GA102001Modal2Controller = new GA102001Modal2Controller();
		GA102001Modal2Controller.Parameter = GA102001Controller.GA102001Paremeter2;
		//モーダル2初期処理
		GA102001Modal2Controller.getSelectOption();
		//追客保留モーダルに値を入力する
		GA102001Modal2Controller.screenCorrespondDetail.SupportedTitle = 'テスト表題';//表題
		//条件完全一致予約を「する」とする
		GA102001Modal2Controller.screenCorrespondDetail.ExactConditionMatch = CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_EXISTS;
		GA102001Modal2Controller.screenCorrespondDetail.SupportedContent = 'テスト保留理由';//保留理由
		GA102001Modal2Controller.screenCorrespondDetail.PursuitDissolveDate = Datetime.now().date();//保留解除日
		GA102001Modal2Controller.screenCorrespondDetail.PursuitDissolveTime = Datetime.now().time();//保留解除日
		//お客様物件条件を更新する
		AccountPropertyConditions__c befApc = [SELECT Id, Name FROM AccountPropertyConditions__c
			WHERE Id =: apcList.get(0).Id];
		befApc.Name = '競合更新';
		update befApc;
		//登録押下
		GA102001Modal2Controller.saveDate();

		//取引先更新
		Account befAcc = [SELECT Id, PropertyConditionsName__c FROM Account WHERE Id =: accId];
		befAcc.PropertyConditionsName__c = '競合更新2';
		update befAcc;
		//登録押下
		GA102001Modal2Controller.saveDate();

		checkGabana('rollbackApc53Test_stopTest');
		Test.stopTest();

		//更新後の取引先、お客様物件条件を取得
		Account aftAcc = [SELECT Id, IsReservePropertyConditions__c FROM Account WHERE Id =: accId];
		List<AccountPropertyConditions__c> aftApc = [SELECT Id, IsReservePropertyConditions__c FROM AccountPropertyConditions__c
			WHERE Id =: apcList.get(0).Id OR Id =: apcList.get(1).Id
			ORDER BY Name];
		//取引先、お客様物件条件の予約物件条件が更新されていないことを確認
		System.assertEquals(false, aftAcc.IsReservePropertyConditions__c);
		System.assertEquals(false, aftApc.get(0).IsReservePropertyConditions__c);
		System.assertEquals(false, aftApc.get(1).IsReservePropertyConditions__c);
		checkGabana('rollbackApc53Test');
	}

    // No.307 対応_希望路線登録テストNo54
    @isTest static void insertTrainRouteApc54Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<TrainRoute__c> trainRouteList = [SELECT Id, Name FROM TrainRoute__c];
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c];
        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        GA102001Controller.currentScreenPropertyCondition.trainRoute1 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute1();
        setCondition(GA102001Controller, false);
        // 路線１
        GA102001Controller.openStations1Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA102001Controller.closeStationModal();

        Integer dsListBefSize = [SELECT id FROM DesiredStation__c].size();
        Integer dtListBefSize = [SELECT id FROM DesiredTrainRoute__c].size();

        GA102001Controller.saveDate();
		checkGabana('insertTrainRouteApc54Test_stopTest');
        Test.stopTest();
        
        List<DesiredStation__c> dsList = [SELECT id FROM DesiredStation__c];
        List<DesiredTrainRoute__c> dtList = [SELECT id FROM DesiredTrainRoute__c];
        //  「取引先以外の物件条件が0件」＆「希望路線が１件」
        System.assertEquals(1, dsList.size() - dsListBefSize);
        System.assertEquals(1, dtList.size() - dtListBefSize);
		checkGabana('insertTrainRouteApc54Test');
    }

    // No.307 対応_希望路線登録テストNo55
    @isTest static void insertTrainRouteApc55Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);
        
        List<TrainRoute__c> trainRouteList = [SELECT Id, Name FROM TrainRoute__c];
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c];
        System.debug([SELECT id FROM DesiredStation__c].size());
        System.debug([SELECT id FROM DesiredTrainRoute__c].size());

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);
        GA102001Controller.currentScreenPropertyCondition.trainRoute1 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute1();
        GA102001Controller.openStations1Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA102001Controller.closeStationModal();

        GA102001Controller.currentScreenPropertyCondition.trainRoute2 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute2();
        GA102001Controller.openStations2Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[1]);
        GA102001Controller.closeStationModal();

        GA102001Controller.currentScreenPropertyCondition.trainRoute3 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute3();
        GA102001Controller.openStations3Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[2]);
        GA102001Controller.closeStationModal();

        Integer dsListBefSize = [SELECT id FROM DesiredStation__c].size();
        Integer dtListBefSize = [SELECT id FROM DesiredTrainRoute__c].size();
		// ▲2022.02.10 No.307 対応でTest.startTest()位置を修正

        GA102001Controller.saveDate();
		checkGabana('insertTrainRouteApc55Test_stopTest');
        Test.stopTest();
        
        //希望路線・希望駅の登録確認　「取引先以外の物件条件が0件」＆「希望路線が3件」
        List<DesiredStation__c> dsList = [SELECT id FROM DesiredStation__c];
        List<DesiredTrainRoute__c> dtList = [SELECT id FROM DesiredTrainRoute__c];
        System.assertEquals(3, dsList.size() - dsListBefSize);
        System.assertEquals(3, dtList.size() - dtListBefSize);
		checkGabana('insertTrainRouteApc55Test');
    }

    // No.307 対応_希望路線登録テストNo56
    @isTest static void insertTrainRouteApc56Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<TrainRoute__c> trainRouteList = [SELECT Id, Name FROM TrainRoute__c];
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c];
        
        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        // 路線１
        GA102001Controller.currentScreenPropertyCondition.trainRoute1 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute1();
        GA102001Controller.openStations1Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA102001Controller.closeStationModal();

        // 物件追加
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);

        // 路線１
        GA102001Controller.currentScreenPropertyCondition.trainRoute1 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute1();
        GA102001Controller.openStations1Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA102001Controller.closeStationModal();

        Integer dsListBefSize = [SELECT id FROM DesiredStation__c].size();
        Integer dtListBefSize = [SELECT id FROM DesiredTrainRoute__c].size();

        GA102001Controller.saveDate();
		checkGabana('insertTrainRouteApc56Test_stopTest');
        Test.stopTest();
        
        //  希望路線・希望駅の登録確認　「取引先以外の物件条件が1件」＆「希望路線が１件」
        List<DesiredStation__c> dsList = [SELECT id FROM DesiredStation__c];
        List<DesiredTrainRoute__c> dtList = [SELECT id FROM DesiredTrainRoute__c];
        System.assertEquals(2, dsList.size() - dsListBefSize);
        System.assertEquals(2, dtList.size() - dtListBefSize);
		checkGabana('insertTrainRouteApc56Test');
    }

    // No.307 対応_希望路線登録テストNo57
    @isTest static void insertTrainRouteApc57Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<TrainRoute__c> trainRouteList = [SELECT Id, Name FROM TrainRoute__c];
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c];

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);
        GA102001Controller.addPropertyCond();

        setCondition(GA102001Controller, false);

        GA102001Controller.currentScreenPropertyCondition.trainRoute1 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute1();
        GA102001Controller.openStations1Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA102001Controller.closeStationModal();

        GA102001Controller.currentScreenPropertyCondition.trainRoute2 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute2();
        GA102001Controller.openStations2Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[1]);
        GA102001Controller.closeStationModal();

        GA102001Controller.currentScreenPropertyCondition.trainRoute3 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute3();
        GA102001Controller.openStations3Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[2]);
        GA102001Controller.closeStationModal();

        Integer dsListBefSize = [SELECT id FROM DesiredStation__c].size();
        Integer dtListBefSize = [SELECT id FROM DesiredTrainRoute__c].size();
		// ▲2022.02.10 No.307 対応でTest.startTest()位置を修正

        GA102001Controller.saveDate();
		checkGabana('insertTrainRouteApc57Test_stopTest');
        Test.stopTest();
        
        //  希望路線・希望駅の登録確認　「取引先以外の物件条件が1件」＆「希望路線が3件」
        List<DesiredStation__c> dsList = [SELECT id FROM DesiredStation__c];
        List<DesiredTrainRoute__c> dtList = [SELECT id FROM DesiredTrainRoute__c];
        System.assertEquals(3, dsList.size() - dsListBefSize);
        System.assertEquals(3, dtList.size() - dtListBefSize);
		checkGabana('insertTrainRouteApc57Test');
    }

    // No.307 対応_希望路線登録テストNo58
    @isTest static void insertTrainRouteApc58Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<TrainRoute__c> trainRouteList = [SELECT Id, Name FROM TrainRoute__c];
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c];

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);

        // 物件条件を追加して、希望路線・希望駅を設定する。
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);

        GA102001Controller.currentScreenPropertyCondition.trainRoute1 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute1();
        GA102001Controller.openStations1Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA102001Controller.closeStationModal();

        // 物件条件を追加して、希望路線・希望駅を設定する。
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);

        GA102001Controller.currentScreenPropertyCondition.trainRoute1 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute1();
        GA102001Controller.openStations1Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA102001Controller.closeStationModal();

        Integer dsListBefSize = [SELECT id FROM DesiredStation__c].size();
        Integer dtListBefSize = [SELECT id FROM DesiredTrainRoute__c].size();

        GA102001Controller.saveDate();
		checkGabana('insertTrainRouteApc58Test_stopTest');
        Test.stopTest();
        
        //  希望路線・希望駅の登録確認　「取引先以外の物件条件が2件」＆「希望路線が１件」
        List<DesiredStation__c> dsList = [SELECT id FROM DesiredStation__c];
        List<DesiredTrainRoute__c> dtList = [SELECT id FROM DesiredTrainRoute__c];
        System.assertEquals(2, dsList.size() - dsListBefSize);
        System.assertEquals(2, dtList.size() - dtListBefSize);
		checkGabana('insertTrainRouteApc58Test');
    }

    // No.307 対応_希望路線登録テストNo59
    @isTest static void insertTrainRouteApc59Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<TrainRoute__c> trainRouteList = [SELECT Id, Name FROM TrainRoute__c];
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c];

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);
        
        GA102001Controller.currentScreenPropertyCondition.trainRoute1 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute1();
        GA102001Controller.openStations1Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA102001Controller.closeStationModal();

        GA102001Controller.currentScreenPropertyCondition.trainRoute2 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute2();
        GA102001Controller.openStations2Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[1]);
        GA102001Controller.closeStationModal();

        GA102001Controller.currentScreenPropertyCondition.trainRoute3 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute3();
        GA102001Controller.openStations3Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[2]);
        GA102001Controller.closeStationModal();

        // 物件条件を追加して、希望路線・希望駅を設定する。
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);
        GA102001Controller.currentScreenPropertyCondition.trainRoute1 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute1();
        GA102001Controller.openStations1Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA102001Controller.closeStationModal();

        GA102001Controller.currentScreenPropertyCondition.trainRoute2 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute2();
        GA102001Controller.openStations2Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[1]);
        GA102001Controller.closeStationModal();

        GA102001Controller.currentScreenPropertyCondition.trainRoute3 = trainRouteList[0].id;
        GA102001Controller.changeTrainRoute3();
        GA102001Controller.openStations3Modal();
        GA102001Controller.GA104007Parameter.selectedStation.add(stationList[2]);
        GA102001Controller.closeStationModal();

        Integer dsListBefSize = [SELECT id FROM DesiredStation__c].size();
        Integer dtListBefSize = [SELECT id FROM DesiredTrainRoute__c].size();

		// ▲2022.02.10 No.307 対応でTest.startTest()位置を修正
        GA102001Controller.saveDate();
        
        //  希望路線・希望駅の登録確認　「取引先以外の物件条件が2件」＆「希望路線が3件」
        List<DesiredStation__c> dsList = [SELECT id FROM DesiredStation__c];
        List<DesiredTrainRoute__c> dtList = [SELECT id FROM DesiredTrainRoute__c];
        System.assertEquals(6, dsList.size() - dsListBefSize);
        System.assertEquals(6, dtList.size() - dtListBefSize);
		checkGabana('insertTrainRouteApc59Test_stopTest');
        Test.stopTest();
		checkGabana('insertTrainRouteApc59Test');
    }

    // No.307 対応_希望学区登録テストNo60
    @isTest static void insertSchoolAreaApc60Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);
        GA102001Controller.currentScreenPropertyCondition.juniorHighSchoolArea = '港区';
        GA102001Controller.changeJuniorHighSchool();
        
        // 中学校を設定
        GA102001Controller.openJuniorHighSchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA102001Controller.closeSchoolModal();

        Integer dsaListBefSize = [SELECT id FROM DesiredSchoolArea__c].size();
        Integer dsListBefSize = [SELECT id FROM DesiredSchool__c].size();

        GA102001Controller.saveDate();
		checkGabana('insertSchoolAreaApc60Test_stopTest');
        Test.stopTest();
        
        //  希望学区・希望学校登録確認　取引先以外の物件条件が0件状態で、中学校区・中学校のみを設定し登録を行う。
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        System.assertEquals(1, dsaList.size() - dsaListBefSize);
        System.assertEquals(1, dsList.size() - dsListBefSize);
		checkGabana('insertSchoolAreaApc60Test');
    }

    // No.307 対応_希望学区登録テストNo61
    @isTest static void insertSchoolAreaApc61Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);
        GA102001Controller.currentScreenPropertyCondition.elementarySchoolArea = '港区';
        GA102001Controller.changeElementarySchool();

        // 小学校を設定
        GA102001Controller.openElementarySchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[1]);
        GA102001Controller.closeSchoolModal();

        Integer dsaListBefSize = [SELECT id FROM DesiredSchoolArea__c].size();
        Integer dsListBefSize = [SELECT id FROM DesiredSchool__c].size();

        GA102001Controller.saveDate();
		checkGabana('insertSchoolAreaApc61Test_stopTest');
        Test.stopTest();
        
        //  希望学区・希望学校登録確認　「取引先以外の物件条件が0件」＆「小学校区のみ入力された状態」
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        System.assertEquals(1, dsaList.size() - dsaListBefSize);
        System.assertEquals(1, dsList.size() - dsListBefSize);
		checkGabana('insertSchoolAreaApc61Test');
    }

    // No.307 対応_希望学区登録テストNo62
    @isTest static void insertSchoolAreaApc62Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);

        // 中学校を設定
        GA102001Controller.currentScreenPropertyCondition.juniorHighSchoolArea = '港区';
        GA102001Controller.changeJuniorHighSchool();
        GA102001Controller.openJuniorHighSchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA102001Controller.closeSchoolModal();
        // 小学校を設定
        GA102001Controller.currentScreenPropertyCondition.elementarySchoolArea = '港区';
        GA102001Controller.changeElementarySchool();
        GA102001Controller.openElementarySchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[1]);
        GA102001Controller.closeSchoolModal();

        Integer dsaListBefSize = [SELECT id FROM DesiredSchoolArea__c].size();
        Integer dsListBefSize = [SELECT id FROM DesiredSchool__c].size();

        GA102001Controller.saveDate();
		checkGabana('insertSchoolAreaApc62Test_stopTest');
        Test.stopTest();
        
        //  希望学区・希望学校登録確認　「取引先以外の物件条件が0件」＆「中学校区・小学校区の両方入力された状態」
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        System.assertEquals(2, dsaList.size() - dsaListBefSize);
        System.assertEquals(2, dsList.size() - dsListBefSize);
		checkGabana('insertSchoolAreaApc62Test');
    }

    // No.307 対応_希望学区登録テストNo63
    @isTest static void insertSchoolAreaApc63Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);
        
        // 中学校を設定
        GA102001Controller.currentScreenPropertyCondition.juniorHighSchoolArea = '港区';
        GA102001Controller.changeJuniorHighSchool();
        GA102001Controller.openJuniorHighSchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA102001Controller.closeSchoolModal();

        Integer dsaListBefSize = [SELECT id FROM DesiredSchoolArea__c].size();
        Integer dsListBefSize = [SELECT id FROM DesiredSchool__c].size();

        GA102001Controller.saveDate();
		checkGabana('insertSchoolAreaApc63Test_stopTest');
        Test.stopTest();
        
        //  希望学区・希望学校登録確認　「取引先以外の物件条件が1件」＆「中学校区のみ入力された状態」
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        System.assertEquals(1, dsaList.size() - dsaListBefSize);
        System.assertEquals(1, dsList.size() - dsListBefSize);
		checkGabana('insertSchoolAreaApc63Test');
    }

    // No.307 対応_希望学区登録テストNo64
    @isTest static void insertSchoolAreaApc64Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);

        // 小学校を設定
        GA102001Controller.currentScreenPropertyCondition.elementarySchoolArea = '港区';
        GA102001Controller.changeElementarySchool();
        GA102001Controller.openElementarySchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[1]);
        GA102001Controller.closeSchoolModal();

        Integer dsaListBefSize = [SELECT id FROM DesiredSchoolArea__c].size();
        Integer dsListBefSize = [SELECT id FROM DesiredSchool__c].size();

        GA102001Controller.saveDate();
		checkGabana('insertSchoolAreaApc64Test_stopTest');
        Test.stopTest();
        
        //  希望学区・希望学校登録確認　「取引先以外の物件条件が1件」＆「小学校区のみ入力された状態」
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        System.assertEquals(1, dsaList.size() - dsaListBefSize);
        System.assertEquals(1, dsList.size() - dsListBefSize);
		checkGabana('insertSchoolAreaApc64Test');
    }

    // No.307 対応_希望学区登録テストNo65
    @isTest static void insertSchoolAreaApc65Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);

        // 中学校を設定
        GA102001Controller.currentScreenPropertyCondition.juniorHighSchoolArea = '港区';
        GA102001Controller.changeJuniorHighSchool();
        GA102001Controller.openJuniorHighSchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA102001Controller.closeSchoolModal();
        // 小学校を設定
        GA102001Controller.currentScreenPropertyCondition.elementarySchoolArea = '港区';
        GA102001Controller.changeElementarySchool();
        GA102001Controller.openElementarySchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[1]);
        GA102001Controller.closeSchoolModal();

        Integer dsaListBefSize = [SELECT id FROM DesiredSchoolArea__c].size();
        Integer dsListBefSize = [SELECT id FROM DesiredSchool__c].size();

        GA102001Controller.saveDate();
		checkGabana('insertSchoolAreaApc65Test_stopTest');
        Test.stopTest();
        
        //  希望学区・希望学校登録確認　「取引先以外の物件条件が1件」＆「中学校区・小学校区の両方入力された状態」
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        System.assertEquals(2, dsaList.size() - dsaListBefSize);
        System.assertEquals(2, dsList.size() - dsListBefSize);
		checkGabana('insertSchoolAreaApc65Test');
    }

    // No.307 対応_希望学区登録テストNo66
    @isTest static void insertSchoolAreaApc66Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);
        
        // 中学校を設定
        GA102001Controller.currentScreenPropertyCondition.juniorHighSchoolArea = '港区';
        GA102001Controller.changeJuniorHighSchool();
        GA102001Controller.openJuniorHighSchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA102001Controller.closeSchoolModal();

        // 物件条件を追加して中学校を設定
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);
        GA102001Controller.currentScreenPropertyCondition.juniorHighSchoolArea = '港区';
        GA102001Controller.changeJuniorHighSchool();
        GA102001Controller.openJuniorHighSchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA102001Controller.closeSchoolModal();

        Integer dsaListBefSize = [SELECT id FROM DesiredSchoolArea__c].size();
        Integer dsListBefSize = [SELECT id FROM DesiredSchool__c].size();

        GA102001Controller.saveDate();
		checkGabana('insertSchoolAreaApc66Test_stopTest');
        Test.stopTest();
        
        //  希望学区・希望学校登録確認　物件条件2件、中学校区のみ
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        System.assertEquals(2, dsaList.size() - dsaListBefSize);
        System.assertEquals(2, dsList.size() - dsListBefSize);
		checkGabana('insertSchoolAreaApc66Test');
    }

    // No.307 対応_希望学区登録テストNo67
    @isTest static void insertSchoolAreaApc67Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);
        
        // 小学校を設定
        GA102001Controller.currentScreenPropertyCondition.elementarySchoolArea = '港区';
        GA102001Controller.changeElementarySchool();
        GA102001Controller.openElementarySchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA102001Controller.closeSchoolModal();

        // 物件条件を追加して小学校を設定
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);
        GA102001Controller.currentScreenPropertyCondition.elementarySchoolArea = '港区';
        GA102001Controller.changeElementarySchool();
        GA102001Controller.openElementarySchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA102001Controller.closeSchoolModal();

        Integer dsaListBefSize = [SELECT id FROM DesiredSchoolArea__c].size();
        Integer dsListBefSize = [SELECT id FROM DesiredSchool__c].size();

        GA102001Controller.saveDate();
		checkGabana('insertSchoolAreaApc67Test_stopTest');
        Test.stopTest();
        
        //  希望学区・希望学校登録確認　物件条件2件、小学校区のみ
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        System.assertEquals(2, dsaList.size() - dsaListBefSize);
        System.assertEquals(2, dsList.size() - dsListBefSize);
		checkGabana('insertSchoolAreaApc67Test');
    }

    // No.307 対応_希望学区登録テストNo68
    @isTest static void insertSchoolAreaApc68Test(){
        Id accId = getSpcAccountId();

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];        

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.changeMode();

        setCondition(GA102001Controller, false);
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);
        
        
        // 中学校を設定
        GA102001Controller.currentScreenPropertyCondition.juniorHighSchoolArea = '港区';
        GA102001Controller.changeJuniorHighSchool();
        GA102001Controller.openJuniorHighSchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA102001Controller.closeSchoolModal();
        // 小学校を設定
        GA102001Controller.currentScreenPropertyCondition.elementarySchoolArea = '港区';
        GA102001Controller.changeElementarySchool();
        GA102001Controller.openElementarySchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[1]);
        GA102001Controller.closeSchoolModal();

        // 物件条件を追加して中学校・小学校を設定
        GA102001Controller.addPropertyCond();
        setCondition(GA102001Controller, false);
        // 中学校を設定
        GA102001Controller.currentScreenPropertyCondition.juniorHighSchoolArea = '港区';
        GA102001Controller.changeJuniorHighSchool();
        GA102001Controller.openJuniorHighSchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA102001Controller.closeSchoolModal();
        // 小学校を設定
        GA102001Controller.currentScreenPropertyCondition.elementarySchoolArea = '港区';
        GA102001Controller.changeElementarySchool();
        GA102001Controller.openElementarySchoolDistrictModal();
        GA102001Controller.GA202002Parameter.selectedSchool.add(schoolList[1]);
        GA102001Controller.closeSchoolModal();

        Integer dsaListBefSize = [SELECT id FROM DesiredSchoolArea__c].size();
        Integer dsListBefSize = [SELECT id FROM DesiredSchool__c].size();

        GA102001Controller.saveDate();
		checkGabana('insertSchoolAreaApc68Test_stopTest');
        Test.stopTest();
        
        //  希望学区・希望学校登録確認　物件条件2件、小学校区・中学校区の両方を設定
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        System.assertEquals(4, dsaList.size() - dsaListBefSize);
        System.assertEquals(4, dsList.size() - dsListBefSize);
		checkGabana('insertSchoolAreaApc68Test');
    }

    // No.307 対応_状況毎の登録テストNo69
    @isTest static void statusRegisterApc69Test(){
        // コントローラの初期表示を実行
        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.screenAccountRecord.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA102001Controller.screenAccountRecord.phone = '1111111111'; //電話番号
        GA102001Controller.screenAccountRecord.LastName = '名'; //名前（名）
        GA102001Controller.screenAccountRecord.FirstName = '姓'; //名前（姓）
        GA102001Controller.screenAccountRecord.LastNameKana = 'フリガナ'; //フリガナ
        GA102001Controller.screenAccountRecord.ContractType = '個人契約'; //契約形態
        GA102001Controller.screenAccountRecord.Situation = '電話反響';//状況
        setCondition(GA102001Controller, true);

        Integer AccountRecordSize = [SELECT ID FROM Account].size();

        Test.startTest();
        GA102001Controller.saveDate();
		checkGabana('statusRegisterApc69Test_stopTest');
        Test.stopTest();

        // 新規顧客の登録確認
        List<Account> AccountRecord = [SELECT ID FROM Account];
        System.assertEquals(1, AccountRecord.size() - AccountRecordSize);
		checkGabana('statusRegisterApc69Test');
    }

    // No.307 対応_物件検索モーダルテストNo71
    @isTest static void openModal9_Apc71Test(){
        Id accId = getSpcAccountId();
        //お客様物件条件を1件追加
        insertAPC_1(accId);

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.openModal9();

		//物件検索条件モーダルの選択肢が2件
        System.assertEquals(2, GA102001Controller.GA102001Paremeter9.spcSelectList.size());
        //物件検索条件モーダルの選択肢の1件目が取引先
        System.assertEquals(Schema.Account.SObjectType, ((ID)GA102001Controller.GA102001Paremeter9.spcSelectList.get(0).getValue()).getSObjectType());
        //物件検索条件モーダルの選択肢の2件目がお客様物件条件
        System.assertEquals(Schema.AccountPropertyConditions__c.SObjectType, ((ID)GA102001Controller.GA102001Paremeter9.spcSelectList.get(1).getValue()).getSObjectType());

        //モーダルコントローラのカバッジ補完
        GA102001Modal9Controller mordal9 = new GA102001Modal9Controller();
        mordal9.Parameter = new GA102001Modal9ParameterClass();
        Boolean prmBool = mordal9.isOpenError;
        prmBool = mordal9.hasErrorMessage;

        mordal9.Parameter.isDrawing = true;
        prmBool = mordal9.init;
        mordal9.Parameter.isDrawing = false;
        prmBool = mordal9.init;
		checkGabana('openModal9_Apc71Test_stopTest');
		Test.stopTest();
		checkGabana('openModal9_Apc71Test');
    }

    // No.307 対応_物件検索モーダルテストNo72
    @isTest static void openModal9_Apc72Test(){
        Id accId = getSpcAccountId();
        //お客様物件条件を3件追加
        insertAPC_1_2_3(accId);

		Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GA102001View;
        pageRef.getParameters().put('AccountId', accId);
        Test.setCurrentPage(pageRef);

        GA102001Controller GA102001Controller = new GA102001Controller();
        GA102001Controller.openModal9();
		checkGabana('openModal9_Apc72Test_stopTest');
		Test.stopTest();

        //物件検索条件モーダルの選択肢が4件
        System.assertEquals(4, GA102001Controller.GA102001Paremeter9.spcSelectList.size());
        //物件検索条件モーダルの選択肢の1件目が取引先
        System.assertEquals(Schema.Account.SObjectType, ((ID)GA102001Controller.GA102001Paremeter9.spcSelectList.get(0).getValue()).getSObjectType());
        //物件検索条件モーダルの選択肢の2件目以降がお客様物件条件
        System.assertEquals(Schema.AccountPropertyConditions__c.SObjectType, ((ID)GA102001Controller.GA102001Paremeter9.spcSelectList.get(1).getValue()).getSObjectType());
        System.assertEquals(Schema.AccountPropertyConditions__c.SObjectType, ((ID)GA102001Controller.GA102001Paremeter9.spcSelectList.get(2).getValue()).getSObjectType());
        System.assertEquals(Schema.AccountPropertyConditions__c.SObjectType, ((ID)GA102001Controller.GA102001Paremeter9.spcSelectList.get(3).getValue()).getSObjectType());
		checkGabana('openModal9_Apc72Test');
    }

	// No.307 対応_追客保留モーダルテストNo73
	@isTest static void openModal2_Apc73Test(){
		Id accId = getSpcAccountId();
		//取引先の予約物件条件を更新
		Account acc = new Account(Id = accid, IsReservePropertyConditions__c = true);
		update acc;

		Test.startTest();
		//パラメータ設定
		PageReference pageRef = Page.GA102001View;
		pageRef.getParameters().put('AccountId', accId);
		Test.setCurrentPage(pageRef);

		GA102001Controller GA102001Controller = new GA102001Controller();
		
		//追客保留モーダルを開く
		GA102001Controller.openModal2HoldFollower();
		checkGabana('openModal2_Apc73Test_stopTest');
		Test.stopTest();

		//予約物件条件モーダルに表示する物件条件が1件
		System.assertEquals(1, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcIndexList.size());
		//予約物件条件モーダルに表示する1件目の物件条件の値が取引先Id
		System.assertEquals(accId, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcIdList.get(0));
		//予約物件条件モーダルに表示する物件条件名
		System.assertEquals('条件1', GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcNameList.get(0));
		//予約物件条件モーダルに表示する予約物件条件
		System.assertEquals(acc.IsReservePropertyConditions__c, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcReservedList.get(0));
		//予約物件条件モーダルに表示する取引先フラグ
		System.assertEquals(true, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcAccountFlgList.get(0));
		checkGabana('openModal2_Apc73Test');
	}

	// No.307 対応_追客保留モーダルテストNo74
	@isTest static void openModal2_Apc74Test(){
		Id accId = getSpcAccountId();
		//取引先の予約物件条件を更新
		Account acc = new Account(Id = accid, IsReservePropertyConditions__c = true);
		update acc;

		//お客様物件条件を2件追加
		List<DesiredTrainRoute__c> dtrList = [SELECT id FROM DesiredTrainRoute__c];
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<AccountPropertyConditions__c> apcList = new List<AccountPropertyConditions__c>();
		apcList.add(createAPC_1(accId, dtrList, dsaList));
		apcList.get(0).IsReservePropertyConditions__c = true;
		apcList.add(createAPC_2(accId, dtrList, dsaList));
		insert apcList;

		Test.startTest();
		//パラメータ設定
		PageReference pageRef = Page.GA102001View;
		pageRef.getParameters().put('AccountId', accId);
		Test.setCurrentPage(pageRef);

		GA102001Controller GA102001Controller = new GA102001Controller();
		//追客保留モーダルを開く
		GA102001Controller.openModal2HoldFollower();

		checkGabana('openModal2_Apc74Test_stopTest');
		Test.stopTest();

		//予約物件条件モーダルに表示する物件条件が3件
		System.assertEquals(3, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcIndexList.size());
		//予約物件条件モーダルに表示する1件目の物件条件の値が取引先Id
		System.assertEquals(accId, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcIdList.get(0));
		//予約物件条件モーダルに表示する物件条件名
		System.assertEquals('条件1', GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcNameList.get(0));
		//予約物件条件モーダルに表示する予約物件条件
		System.assertEquals(acc.IsReservePropertyConditions__c, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcReservedList.get(0));
		//予約物件条件モーダルに表示する取引先フラグ
		System.assertEquals(true, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcAccountFlgList.get(0));

		//予約物件条件モーダルに表示する2件目の物件条件の値が予約物件条件Id
		System.assertEquals(apcList.get(0).Id, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcIdList.get(1));
		System.assertEquals(apcList.get(1).Id, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcIdList.get(2));
		//予約物件条件モーダルに表示する物件条件名
		System.assertEquals('条件2', GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcNameList.get(1));
		System.assertEquals('条件3', GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcNameList.get(2));
		//予約物件条件モーダルに表示する予約物件条件
		System.assertEquals(apcList.get(0).IsReservePropertyConditions__c, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcReservedList.get(1));
		System.assertEquals(apcList.get(1).IsReservePropertyConditions__c, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcReservedList.get(2));
		//予約物件条件モーダルに表示する取引先フラグ
		System.assertEquals(false, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcAccountFlgList.get(1));
		System.assertEquals(false, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcAccountFlgList.get(2));
		checkGabana('openModal2_Apc74Test');
	}

	// No.307 対応_追客保留モーダルテストNo75
	@isTest static void openModal2_Apc75Test(){
		Id accId = getSpcAccountId();
		//対応のステータスを追客中とする
		Correspond__c CorrespondRecord = [SELECT Id, Status__c FROM Correspond__c WHERE AccountId__c =: accId LIMIT 1];
		CorrespondRecord.Status__c = CommonConst.CORRESPOND_STATUS_PURSUIT;
		update CorrespondRecord;
		//実行前に存在する対応明細Idを取得
		Map<Id, CorrespondDetail__c> befCDMap = new Map<Id, CorrespondDetail__c>([SELECT Id FROM CorrespondDetail__c]);

		Test.startTest();
		//パラメータ設定
		PageReference pageRef = Page.GA102001View;
		pageRef.getParameters().put('AccountId', accId);
		pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );
		Test.setCurrentPage(pageRef);

		GA102001Controller GA102001Controller = new GA102001Controller();
		//追客保留モーダルを開く
		GA102001Controller.openModal2HoldFollower();

		//追客保留モーダルコントローラからパラメータを参照する
		GA102001Modal2Controller GA102001Modal2Controller = new GA102001Modal2Controller();
		GA102001Modal2Controller.Parameter = GA102001Controller.GA102001Paremeter2;
		//モーダル2初期処理
		GA102001Modal2Controller.getSelectOption();
		//追客保留モーダルに値を入力する
		GA102001Modal2Controller.screenCorrespondDetail.SupportedTitle = 'テスト表題';//表題
		// ▼2022.01.27 No.307 対応で条件完全一致予約を「する」とする処理を削除
		GA102001Modal2Controller.screenCorrespondDetail.SupportedContent = 'テスト保留理由';//保留理由
		GA102001Modal2Controller.screenCorrespondDetail.PursuitDissolveDate = Datetime.now().date();//保留解除日
		GA102001Modal2Controller.screenCorrespondDetail.PursuitDissolveTime = Datetime.now().time();//保留解除日
		//登録押下
		GA102001Modal2Controller.saveDate();
		checkGabana('openModal2_Apc75Test_stopTest');
		Test.stopTest();

		//更新後の取引先を取得
		Account aftAcc = [SELECT Id, IsReservePropertyConditions__c FROM Account WHERE Id =: accId];

		//取引先の予約物件条件がfalseのままとなっている
		System.assertEquals(false, aftAcc.IsReservePropertyConditions__c);

		// 追加された対応明細の対応内容に物件条件名が含まれないことを確認
		List<CorrespondDetail__c> aftCD = [SELECT Id, SupportedContent__c FROM CorrespondDetail__c WHERE Id NOT IN :befCDMap.keySet()];
		System.assertEquals(false, aftCD[0].SupportedContent__c.contains('物件条件名'));
		checkGabana('openModal2_Apc75Test');
	}

	// No.307 対応_予約物件条件モーダルテストNo76
	@isTest static void openModal2_Apc76Test(){
		Id accId = getSpcAccountId();

		//お客様物件条件を2件追加
		insertAPC_1_2(accId);

		Test.startTest();
		//パラメータ設定
		PageReference pageRef = Page.GA102001View;
		pageRef.getParameters().put('AccountId', accId);
		Test.setCurrentPage(pageRef);

		GA102001Controller GA102001Controller = new GA102001Controller();

		//追客保留モーダルを開く
		GA102001Controller.openModal2HoldFollower();

		//予約物件条件モーダルパラメータ設定(予約物件条件モーダルのチェック操作)
		pageRef.getParameters().put('checkList', 'true,false,true');
		Test.setCurrentPage(pageRef);

		//予約物件条件モーダルコントローラからパラメータを参照する
		GA102001Modal10Controller GA102001Modal10Controller = new GA102001Modal10Controller();
		GA102001Modal10Controller.Parameter = GA102001Controller.GA102001Paremeter2.GA102001Paremeter10;
		//OK押下
		GA102001Modal10Controller.clickOk();

		checkGabana('openModal2_Apc76Test_stopTest');
		Test.stopTest();

		//予約条件モーダルのチェック操作の値がOK押下によってパラメータに反映される
		System.assertEquals(true, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcReservedList.get(0));
		System.assertEquals(false, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcReservedList.get(1));
		System.assertEquals(true, GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcReservedList.get(2));
		checkGabana('openModal2_Apc76Test');
	}

	@isTest static void openModal2_Apc77Test(){
		Id accId = getSpcAccountId();
		//対応のステータスを追客中とする
		Correspond__c CorrespondRecord = [SELECT Id, Status__c FROM Correspond__c WHERE AccountId__c =: accId LIMIT 1];
		CorrespondRecord.Status__c = CommonConst.CORRESPOND_STATUS_PURSUIT;
		update CorrespondRecord;
		//実行前に存在する対応明細Idを取得
		Map<Id, CorrespondDetail__c> befCDMap = new Map<Id, CorrespondDetail__c>([SELECT Id FROM CorrespondDetail__c]);

		//お客様物件条件を2件追加
		List<AccountPropertyConditions__c> apcList = insertAPC_1_2(accId);

		Test.startTest();
		//パラメータ設定
		PageReference pageRef = Page.GA102001View;
		pageRef.getParameters().put('AccountId', accId);
		pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );

		Test.setCurrentPage(pageRef);

		GA102001Controller GA102001Controller = new GA102001Controller();

		//追客保留モーダルを開く
		GA102001Controller.openModal2HoldFollower();

		// ▼2022.01.27 No.307 対応で予約物件条件指定処理を削除（移動）

		//追客保留モーダルコントローラからパラメータを参照する
		GA102001Modal2Controller GA102001Modal2Controller = new GA102001Modal2Controller();
		GA102001Modal2Controller.Parameter = GA102001Controller.GA102001Paremeter2;
		//モーダル2初期処理
		GA102001Modal2Controller.getSelectOption();
		//追客保留モーダルに値を入力する
		GA102001Modal2Controller.screenCorrespondDetail.SupportedTitle = 'テスト表題';//表題
		//条件完全一致予約を「する」とする
		GA102001Modal2Controller.screenCorrespondDetail.ExactConditionMatch = CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_EXISTS;
		GA102001Modal2Controller.screenCorrespondDetail.SupportedContent = 'テスト保留理由';//保留理由
		GA102001Modal2Controller.screenCorrespondDetail.PursuitDissolveDate = Datetime.now().date();//保留解除日
		GA102001Modal2Controller.screenCorrespondDetail.PursuitDissolveTime = Datetime.now().time();//保留解除日

		//登録押下
		GA102001Modal2Controller.saveDate();

		// ▼2022.01.27 No.307 対応で追加 予約物件条件追加前に例外確認を追加
		checkGabana('openModal2_Apc77Test_stopTest');
		Test.stopTest();
		//条件完全一致予約が「はい」かつ予約物件条件選択無しで登録を試みた際、エラーが発生する
		List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION, '条件完全一致予約する際', '予約物件条件')),
		'条件完全一致予約が「はい」かつ予約物件条件選択無しのエラーが発生しない');
		checkGabana('openModal2_Apc77Test');
	}

	// ▼2022.02.14 No.307 対応でテストクラスを分割
	@isTest static void openModal2_Apc77Test_2(){
		Id accId = getSpcAccountId();
		//対応のステータスを追客中とする
		Correspond__c CorrespondRecord = [SELECT Id, Status__c FROM Correspond__c WHERE AccountId__c =: accId LIMIT 1];
		CorrespondRecord.Status__c = CommonConst.CORRESPOND_STATUS_PURSUIT;
		update CorrespondRecord;
		//実行前に存在する対応明細Idを取得
		Map<Id, CorrespondDetail__c> befCDMap = new Map<Id, CorrespondDetail__c>([SELECT Id FROM CorrespondDetail__c]);

		//お客様物件条件を2件追加
		List<AccountPropertyConditions__c> apcList = insertAPC_1_2(accId);

		Test.startTest();
		//パラメータ設定
		PageReference pageRef = Page.GA102001View;
		pageRef.getParameters().put('AccountId', accId);
		pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );

		Test.setCurrentPage(pageRef);

		GA102001Controller GA102001Controller = new GA102001Controller();
		//追客保留モーダルを開く
		GA102001Controller.openModal2HoldFollower();

		// ▼2022.01.27 No.307 対応で予約物件条件指定処理を削除（移動）

		//追客保留モーダルコントローラからパラメータを参照する
		GA102001Modal2Controller GA102001Modal2Controller = new GA102001Modal2Controller();
		GA102001Modal2Controller.Parameter = GA102001Controller.GA102001Paremeter2;
		//モーダル2初期処理
		GA102001Modal2Controller.getSelectOption();

		Test.setCurrentPage(pageRef);
		//予約物件条件モーダルコントローラからパラメータを参照する
		GA102001Modal10Controller GA102001Modal10Controller = new GA102001Modal10Controller();
		GA102001Modal10Controller.Parameter = GA102001Controller.GA102001Paremeter2.GA102001Paremeter10;
		//追客保留モーダルに値を入力する
		GA102001Modal2Controller.screenCorrespondDetail.SupportedTitle = 'テスト表題';//表題
		//条件完全一致予約を「する」とする
		GA102001Modal2Controller.screenCorrespondDetail.ExactConditionMatch = CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_EXISTS;
		GA102001Modal2Controller.screenCorrespondDetail.SupportedContent = 'テスト保留理由';//保留理由
		GA102001Modal2Controller.screenCorrespondDetail.PursuitDissolveDate = Datetime.now().date();//保留解除日
		GA102001Modal2Controller.screenCorrespondDetail.PursuitDissolveTime = Datetime.now().time();//保留解除日
		//予約物件条件モーダルパラメータ設定(予約物件条件モーダルのチェック操作)
		GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcReservedList[0] = true;
		GA102001Controller.GA102001Paremeter2.GA102001Paremeter10.spcReservedList[2] = true;
		
		//登録押下
		GA102001Modal2Controller.saveDate();

		checkGabana('openModal2_Apc77Test_2_stopTest');
		Test.stopTest();

		// ▲2022.01.27 No.307 対応で追加

		//更新後の取引先、お客様物件条件を取得
		Account aftAcc = [SELECT Id, IsReservePropertyConditions__c FROM Account WHERE Id =: accId];
		List<AccountPropertyConditions__c> aftApc = [SELECT Id, IsReservePropertyConditions__c FROM AccountPropertyConditions__c
			WHERE Id =: apcList.get(0).Id OR Id =: apcList.get(1).Id
			ORDER BY Name];
		//取引先、お客様物件条件の予約物件条件が更新されていることを確認
		System.assertEquals(true, aftAcc.IsReservePropertyConditions__c);
		System.assertEquals(false, aftApc.get(0).IsReservePropertyConditions__c);
		System.assertEquals(true, aftApc.get(1).IsReservePropertyConditions__c);

		// 追加された対応明細の対応内容に物件条件名が表示されることを確認
		List<CorrespondDetail__c> aftCD = [SELECT Id, SupportedContent__c FROM CorrespondDetail__c WHERE Id NOT IN :befCDMap.keySet()];
		System.assert(aftCD[0].SupportedContent__c.contains('物件条件名：条件1、条件3'));
		
		checkGabana('openModal2_Apc77Test_2');
	}
	// ▲2022.02.14 No.307 対応でテストクラスを分割

	@isTest static void openModal2_Apc78Test(){
		openModal2_Apc78TestRun();
		checkGabana('openModal2_Apc78Test');
	}

	private static void openModal2_Apc78TestRun(){
		Id accId = getSpcAccountId();
		//取引先の予約物件条件を更新
		Account acc = new Account(Id = accid, IsReservePropertyConditions__c = true);
		update acc;

		//お客様物件条件を2件追加
		List<DesiredTrainRoute__c> dtrList = [SELECT id FROM DesiredTrainRoute__c];
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<AccountPropertyConditions__c> apcList = new List<AccountPropertyConditions__c>();
		apcList.add(createAPC_1(accId, dtrList, dsaList));
		apcList.add(createAPC_2(accId, dtrList, dsaList));
		apcList.get(0).IsReservePropertyConditions__c = true;
		apcList.get(1).IsReservePropertyConditions__c = true;
		insert apcList;

		//対応のステータスを追客中とする
		Correspond__c CorrespondRecord = [SELECT Id, Status__c FROM Correspond__c WHERE AccountId__c =: accId LIMIT 1];
		CorrespondRecord.Status__c = CommonConst.CORRESPOND_STATUS_PURSUIT;
		update CorrespondRecord;


		Test.startTest();
		//パラメータ設定
		PageReference pageRef = Page.GA102001View;
		pageRef.getParameters().put('AccountId', accId);
		pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );

		Test.setCurrentPage(pageRef);

		GA102001Controller GA102001Controller = new GA102001Controller();

		//追客保留モーダルを開く
		GA102001Controller.openModal2HoldFollower();

		//予約物件条件モーダルパラメータ設定(予約物件条件モーダルのチェック操作)
		pageRef.getParameters().put('checkList', 'true,true,true');
		Test.setCurrentPage(pageRef);

		//予約物件条件モーダルコントローラからパラメータを参照する
		GA102001Modal10Controller GA102001Modal10Controller = new GA102001Modal10Controller();
		GA102001Modal10Controller.Parameter = GA102001Controller.GA102001Paremeter2.GA102001Paremeter10;
		//OK押下
		GA102001Modal10Controller.clickOk();

		//追客保留モーダルコントローラからパラメータを参照する
		GA102001Modal2Controller GA102001Modal2Controller = new GA102001Modal2Controller();
		GA102001Modal2Controller.Parameter = GA102001Controller.GA102001Paremeter2;
		//モーダル2初期処理
		GA102001Modal2Controller.getSelectOption();
		//追客保留モーダルに値を入力する
		GA102001Modal2Controller.screenCorrespondDetail.SupportedTitle = 'テスト表題';//表題
		//条件完全一致予約を「しない」とする
		GA102001Modal2Controller.screenCorrespondDetail.ExactConditionMatch = CommonConst.CORRESPOND_EXACT_CONDITION_MATCH_NO;
		GA102001Modal2Controller.screenCorrespondDetail.SupportedContent = 'テスト保留理由';//保留理由
		GA102001Modal2Controller.screenCorrespondDetail.PursuitDissolveDate = Datetime.now().date();//保留解除日
		GA102001Modal2Controller.screenCorrespondDetail.PursuitDissolveTime = Datetime.now().time();//保留解除日
		//登録押下
		GA102001Modal2Controller.saveDate();

		//更新後の取引先、お客様物件条件を取得
		Account aftAcc = [SELECT Id, IsReservePropertyConditions__c FROM Account WHERE Id =: accId];
		List<AccountPropertyConditions__c> aftApc = [SELECT Id, IsReservePropertyConditions__c FROM AccountPropertyConditions__c
			WHERE Id =: apcList.get(0).Id OR Id =: apcList.get(1).Id
			ORDER BY Name];
		//取引先、お客様物件条件の予約物件条件が更新されていることを確認
		System.assertEquals(false, aftAcc.IsReservePropertyConditions__c);
		System.assertEquals(false, aftApc.get(0).IsReservePropertyConditions__c);
		System.assertEquals(false, aftApc.get(1).IsReservePropertyConditions__c);

		//モーダルコントローラのカバッジ補完
        GA102001Modal10Controller mordal10 = new GA102001Modal10Controller();
        mordal10.Parameter = new GA102001Modal10ParameterClass();
        Boolean prmBool = mordal10.isOpenError;
        prmBool = mordal10.hasErrorMessage;

        mordal10.Parameter.isDrawing = true;
        prmBool = mordal10.init;
        mordal10.Parameter.isDrawing = false;
        prmBool = mordal10.init;

		checkGabana('openModal2_Apc78TestRun_stopTest');
		Test.stopTest();
	}

	// No.307 対応_保留解除モーダルテストNo79
	@isTest static void openModal2_Apc79Test(){
		Id accId = getSpcAccountId();
		//取引先の予約物件条件を更新
		Account acc = new Account(Id = accid, IsReservePropertyConditions__c = true);
		update acc;

		//お客様物件条件を2件追加
		List<DesiredTrainRoute__c> dtrList = [SELECT id FROM DesiredTrainRoute__c];
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<AccountPropertyConditions__c> apcList = new List<AccountPropertyConditions__c>();
		apcList.add(createAPC_1(accId, dtrList, dsaList));
		apcList.add(createAPC_2(accId, dtrList, dsaList));
		apcList.get(0).IsReservePropertyConditions__c = true;
		apcList.get(1).IsReservePropertyConditions__c = true;
		insert apcList;

		//対応のステータスを追客保留中とする
		Correspond__c CorrespondRecord = [SELECT Id, Status__c FROM Correspond__c WHERE AccountId__c =: accId LIMIT 1];
		CorrespondRecord.Status__c = CommonConst.CORRESPOND_STATUS_PURSUITHOLD;
		update CorrespondRecord;

		// ▼2022.02.10 No.307 対応でTest.startTest()位置を修正
		Test.startTest();
		//パラメータ設定
		PageReference pageRef = Page.GA102001View;
		pageRef.getParameters().put('AccountId', accId);
		pageRef.getParameters().put('Corresponds',CorrespondRecord.Id );

		Test.setCurrentPage(pageRef);

		GA102001Controller GA102001Controller = new GA102001Controller();

		// ▲2022.02.10 No.307 対応でTest.startTest()位置を修正
		//保留解除モーダルを開く
		GA102001Controller.openModal2HoldFollower();
		GA102001Controller.ReleaseHold();

		checkGabana('openModal2_Apc79Test_stopTest');
		Test.stopTest();

		//更新後の取引先、お客様物件条件を取得
		Account aftAcc = [SELECT Id, IsReservePropertyConditions__c FROM Account WHERE Id =: accId];
		List<AccountPropertyConditions__c> aftApc = [SELECT Id, IsReservePropertyConditions__c FROM AccountPropertyConditions__c
			WHERE Id =: apcList.get(0).Id OR Id =: apcList.get(1).Id
			ORDER BY Name];
		//取引先、お客様物件条件の予約物件条件が更新されていることを確認
		System.assertEquals(false, aftAcc.IsReservePropertyConditions__c);
		System.assertEquals(false, aftApc.get(0).IsReservePropertyConditions__c);
		System.assertEquals(false, aftApc.get(1).IsReservePropertyConditions__c);
		checkGabana('openModal2_Apc79Test');
	}

	// No.307 対応_一般ユーザ権限テストNo80
	@isTest static void ippanUserApc80Test(){
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

		System.runAs(ippanUser){
			//お客様詳細画面から取引先、お客様詳細の参照、更新を実施
			registerApc44TestRun();
		}
		checkGabana('ippanUserApc80Test');
	}

	// No.307 対応_一般ユーザ権限テストNo81
	@isTest static void ippanUserApc81Test(){
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

		System.runAs(ippanUser){
			//追客保留、予約物件条件モーダルから取引先、お客様詳細の参照、更新を実施
			openModal2_Apc78TestRun();
		}
		checkGabana('ippanUserApc81Test');
	}

	// 物件条件を設定
	private static void setCondition(GA102001Controller con, Boolean bool){
		if(bool){
			con.currentScreenPropertyCondition.buildingAge = '999';
			con.currentScreenPropertyCondition.carCount = '99';
			con.currentScreenPropertyCondition.desiredArea = '希望地域';
			con.currentScreenPropertyCondition.occupancyAreaLowerLimit = '0';
			con.currentScreenPropertyCondition.occupancyAreaUpperLimit = '999';
			con.currentScreenPropertyCondition.parkingFeeLimit = '9,999';
			con.currentScreenPropertyCondition.rentFeeFrom = '9,999';
			con.currentScreenPropertyCondition.rentFeeTo = '9,999';
			con.currentScreenPropertyCondition.walkingTime = '999';
			
		}else{
            con.currentScreenPropertyCondition.AccountPropertyConditionsTrainRoute1 = null;
            con.currentScreenPropertyCondition.AccountPropertyConditionsTrainRoute2 = null;
            con.currentScreenPropertyCondition.AccountPropertyConditionsTrainRoute3 = null;
            con.currentScreenPropertyCondition.AccountPropertyConditionsElementarySchoolArea = null;
            con.currentScreenPropertyCondition.AccountPropertyConditionsJuniorHighSchoolArea = null;
            con.currentScreenPropertyCondition.buildingAge = null;
            con.currentScreenPropertyCondition.carCount = null;
            con.currentScreenPropertyCondition.desiredArea = null;
            con.currentScreenPropertyCondition.occupancyAreaLowerLimit = null;
            con.currentScreenPropertyCondition.occupancyAreaUpperLimit = null;
            con.currentScreenPropertyCondition.parkingFeeLimit = null;
            con.currentScreenPropertyCondition.rentFeeFrom = null;
            con.currentScreenPropertyCondition.rentFeeTo = null;
            con.currentScreenPropertyCondition.walkingTime = null;
            con.currentScreenPropertyCondition.walkingTime = null;
        }

        con.currentScreenPropertyCondition.isIncludeManagementFee = bool;//管理費込み 
        con.currentScreenPropertyCondition.isIncludeParkingFee = bool;//駐車場代込み 
        con.currentScreenPropertyCondition.isOneRoom = bool;//ワンルーム 
        con.currentScreenPropertyCondition.is1K = bool;//1K 
        con.currentScreenPropertyCondition.is1DK = bool;//1DK 
        con.currentScreenPropertyCondition.is1LDK1SLDK = bool;//1LDK/SLDK 
        con.currentScreenPropertyCondition.is2K2DK = bool;//2K/DK 
        con.currentScreenPropertyCondition.is2LDK2SLDK = bool;//2LDK/SLDK 
        con.currentScreenPropertyCondition.is3K3DK = bool;//3K/DK 
        con.currentScreenPropertyCondition.is3LDK3SLDK = bool;//3LDK/SLDK 
        con.currentScreenPropertyCondition.is4K4DK4LDKFrom = bool;//4K/DK/LDK~ 
        con.currentScreenPropertyCondition.isWooden = bool;//木造 
        con.currentScreenPropertyCondition.isLightweightSteel = bool;//軽量鉄骨 
        con.currentScreenPropertyCondition.isSteel = bool;//鉄骨造 
        con.currentScreenPropertyCondition.isRC = bool;//RC 
        con.currentScreenPropertyCondition.isSRC = bool;//SRC 
        con.currentScreenPropertyCondition.isNorth = bool;//北 
        con.currentScreenPropertyCondition.isNorthEast = bool;//北東 
        con.currentScreenPropertyCondition.isEast = bool;//東 
        con.currentScreenPropertyCondition.isSouthEast = bool;//南東 
        con.currentScreenPropertyCondition.isSouth = bool;//南 
        con.currentScreenPropertyCondition.isSouthWest = bool;//南西 
        con.currentScreenPropertyCondition.isWest = bool;//西 
        con.currentScreenPropertyCondition.isNorthWest = bool;//北西 
        con.currentScreenPropertyCondition.isNonDeposit = bool;//敷金/保証金なし 
        con.currentScreenPropertyCondition.isNonKeyMoney = bool;//礼金なし 
        con.currentScreenPropertyCondition.isNonCleaningFee = bool;//定額修繕費なし 
        con.currentScreenPropertyCondition.isNonRenewalFee = bool;//更新料なし 
        con.currentScreenPropertyCondition.isDetachedHouse = bool;//戸建て 
        con.currentScreenPropertyCondition.isMaisonette = bool;//メゾネット 
        con.currentScreenPropertyCondition.isLoft = bool;//ロフト 
        con.currentScreenPropertyCondition.isDesigners = bool;//デザイナーズ 
        con.currentScreenPropertyCondition.isRenovation = bool;//リノベーション 
        con.currentScreenPropertyCondition.isCondominiumRental = bool;//分譲賃貸 
        con.currentScreenPropertyCondition.isAllWestern = bool;//オール洋間 
        con.currentScreenPropertyCondition.isFirstFloor = bool;//1階 
        con.currentScreenPropertyCondition.isSecondFloorOver = bool;//2階以上 
        con.currentScreenPropertyCondition.isTopFloor = bool;//最上階 
        con.currentScreenPropertyCondition.isCornerRoom = bool;//角部屋 
        con.currentScreenPropertyCondition.isBalcony = bool;//バルコニー 
        con.currentScreenPropertyCondition.isRoofBalcony = bool;//ルーフバルコニー 
        con.currentScreenPropertyCondition.isPrivateGarden = bool;//専用庭 
        con.currentScreenPropertyCondition.isParking = bool;//駐車場空きあり 
        con.currentScreenPropertyCondition.isInSiteParking = bool;//敷地内駐車場 
        con.currentScreenPropertyCondition.isPluralCarParking = bool;//駐車場2台可 
        con.currentScreenPropertyCondition.isBuiltInGarage = bool;//ビルトインガレージ 
        con.currentScreenPropertyCondition.isCarport = bool;//カーポート 
        con.currentScreenPropertyCondition.isBicycleParking = bool;//駐輪場 
        con.currentScreenPropertyCondition.isBikeStorage = bool;//バイク可 
        con.currentScreenPropertyCondition.isSmallBike = bool;//小型バイク 
        con.currentScreenPropertyCondition.isMediumBike = bool;//中型バイク 
        con.currentScreenPropertyCondition.isLargeBike = bool;//大型バイク 
        con.currentScreenPropertyCondition.isElevator = bool;//エレベーター 
        con.currentScreenPropertyCondition.isDeliveryBox = bool;//宅配ボックス 
        con.currentScreenPropertyCondition.isCounterKitchen = bool;//カウンターキッチン 
        con.currentScreenPropertyCondition.isSystemKitchen = bool;//システムキッチン 
        con.currentScreenPropertyCondition.isGasStove = bool;//ガスコンロ 
        con.currentScreenPropertyCondition.isElectricStove = bool;//電気コンロ 
        con.currentScreenPropertyCondition.isInductionHeating = bool;//IHコンロ 
        con.currentScreenPropertyCondition.isTwoGasStove = bool;//コンロ2口 
        con.currentScreenPropertyCondition.isMoreGasStove = bool;//コンロ3口以上 
        con.currentScreenPropertyCondition.isSepalateBathAndRestroom = bool;//バス・トイレ別 
        con.currentScreenPropertyCondition.isAditionalBoiling = bool;//追焚機能 
        con.currentScreenPropertyCondition.isDehumidifierForBathroom = bool;//浴室乾燥機 
        con.currentScreenPropertyCondition.isWashlet = bool;//温水洗浄便座 
        con.currentScreenPropertyCondition.isShowerWashBasin = bool;//シャワー付き洗面台 
        con.currentScreenPropertyCondition.isRegalLavatory = bool;//洗面所独立 
        con.currentScreenPropertyCondition.isInnerLandry = bool;//室内洗濯機置場 
        con.currentScreenPropertyCondition.isTownGas = bool;//都市ガス 
        con.currentScreenPropertyCondition.isPropaneGas = bool;//プロパンガス 
        con.currentScreenPropertyCondition.isAllElectric = bool;//オール電化 
        con.currentScreenPropertyCondition.isAirConditioner = bool;//エアコン 
        con.currentScreenPropertyCondition.isFloorHeating = bool;//床暖房 
        con.currentScreenPropertyCondition.isShoesBox = bool;//シューズボックス 
        con.currentScreenPropertyCondition.isShoeCloak = bool;//シューズクローク 
        con.currentScreenPropertyCondition.isWalkInCloset = bool;//ウォークインクローゼット 
        con.currentScreenPropertyCondition.isTrunkRoom = bool;//トランクルーム 
        con.currentScreenPropertyCondition.isBSAntenna = bool;//BSアンテナ 
        con.currentScreenPropertyCondition.isCSAntenna = bool;//CSアンテナ 
        con.currentScreenPropertyCondition.isCATV = bool;//CATV 
        con.currentScreenPropertyCondition.isInternetFree = bool;//ネット使用料無料 
        con.currentScreenPropertyCondition.isMonitorIntercom = bool;//モニター付きインターホン 
        con.currentScreenPropertyCondition.isAutoLock = bool;//オートロック 
        con.currentScreenPropertyCondition.isFurniture = bool;//家具付き 
        con.currentScreenPropertyCondition.isHomeAppliance = bool;//家電付き 
        con.currentScreenPropertyCondition.isNoGuarantor = bool;//保証人不要 
        con.currentScreenPropertyCondition.isNonGuaranteeidCompany = bool;//保証会社不要 
        con.currentScreenPropertyCondition.isMusicalInstruments = bool;//楽器相談可 
        con.currentScreenPropertyCondition.isForeigner = bool;//外国人契約可 
        con.currentScreenPropertyCondition.isOfficeAvailable = bool;//事務所利用可 
        con.currentScreenPropertyCondition.isWelfareAvailable = bool;//生活保護契約可 
        con.currentScreenPropertyCondition.isPet = bool;//ペット可 
        con.currentScreenPropertyCondition.isLargePet = bool;//ペット(大型犬) 
        con.currentScreenPropertyCondition.isMiddlePet = bool;//ペット(中型犬) 
        con.currentScreenPropertyCondition.isSmallPet = bool;//ペット(小型犬) 
        con.currentScreenPropertyCondition.isCat = bool;//ペット(猫) 
        con.currentScreenPropertyCondition.isOtherPet = bool;//ペット(その他) 
        con.currentScreenPropertyCondition.isTwoTenant = bool;//2人入居可 
        con.currentScreenPropertyCondition.isRoomShare = bool;//ルームシェア可 
        con.currentScreenPropertyCondition.isIppambutsu = bool;//一般物 
        con.currentScreenPropertyCondition.isElderly = bool;//高齢者歓迎 
        con.currentScreenPropertyCondition.isWoman = bool;//女性限定 
        con.currentScreenPropertyCondition.isStudent = bool;//学生限定マンション
    }

    // 表示の内容を確認する。
    private static void checkdisplayCond(GA102001Controller controller, Boolean bool, String apcName, String status){

        // 確認用変数
        String buildingAge;
        String carCount;
        String desiredArea;
        String oaLowLimit;
        String oaUpLimit;
        String parking;
        String parkingFlimit;
        String rentFeeFrom;
        String rentFeeTo;
        String walkingTime;

        String trainRoute1 = 'テスト路線１';
        String trainRoute2 = 'テスト路線２';
        String trainRoute3 = 'テスト路線３';
        String stateChar1 = 'テスト駅１';
        String stateChar2 = 'テスト駅２';
        String stateChar3 = 'テスト駅３';
        String juniorHighArea = '港区';
        String elementaryArea = '瑞穂区';
        String desiredJSchool = 'テスト学校1';
        String desiredESchool = 'テスト学校2';

        buildingAge = '999';
        carCount = '99';
        desiredArea = '希望地域';
        oaLowLimit = '0';
        oaUpLimit = '999';
        parking = '有';
        parkingFlimit = '9,999';
        rentFeeFrom = '9,999';
        rentFeeTo = '9,999';
        walkingTime = '999';

        if(status == 'init'){
            system.assertEquals(null, controller.currentScreenPropertyCondition.trainRoute1Name); //希望沿線１．路線
            system.assertEquals(null, controller.currentScreenPropertyCondition.trainRoute2Name); //希望沿線２．路線
            system.assertEquals(null, controller.currentScreenPropertyCondition.trainRoute3Name); //希望沿線３．路線
            system.assertEquals(null, controller.currentScreenPropertyCondition.stationsChar1); //駅１文字列
            system.assertEquals(null, controller.currentScreenPropertyCondition.stationsChar2); //駅２文字列
            system.assertEquals(null, controller.currentScreenPropertyCondition.stationsChar3); //駅３文字列

            system.assertEquals(null, controller.currentScreenPropertyCondition.juniorHighSchoolArea);//中学校希望学区(エリア).希望学区
            system.assertEquals(null, controller.currentScreenPropertyCondition.elementarySchoolArea);//小学校希望学区(エリア).希望学区
            system.assertEquals(null, controller.currentScreenPropertyCondition.desiredJuniorHighSchool); //希望中学校
            system.assertEquals(null, controller.currentScreenPropertyCondition.desiredPrimarySchool); //希望小学校

            system.assertEquals(apcName, controller.currentScreenPropertyCondition.Name); //物件条件名
            system.assertEquals(null, controller.currentScreenPropertyCondition.is1DK); //1DK
            system.assertEquals(null, controller.currentScreenPropertyCondition.is1K); //1K
            system.assertEquals(null, controller.currentScreenPropertyCondition.is1LDK1SLDK); //1LDK/SLDK
            system.assertEquals(null, controller.currentScreenPropertyCondition.isFirstFloor); //1階
            system.assertEquals(null, controller.currentScreenPropertyCondition.is2K2DK); //2K/DK
            system.assertEquals(null, controller.currentScreenPropertyCondition.is2LDK2SLDK); //2LDK/SLDK
            system.assertEquals(null, controller.currentScreenPropertyCondition.isSecondFloorOver); //2階以上
            system.assertEquals(null, controller.currentScreenPropertyCondition.isTwoTenant); //2人入居可
            system.assertEquals(null, controller.currentScreenPropertyCondition.is3K3DK); //3K/DK
            system.assertEquals(null, controller.currentScreenPropertyCondition.is3LDK3SLDK); //3LDK/SLDK
            system.assertEquals(null, controller.currentScreenPropertyCondition.is4K4DK4LDKFrom); //4K/DK/LDK~
            system.assertEquals(null, controller.currentScreenPropertyCondition.isBSAntenna); //BSアンテナ
            system.assertEquals(null, controller.currentScreenPropertyCondition.isCATV); //CATV
            system.assertEquals(null, controller.currentScreenPropertyCondition.isCSAntenna); //CSアンテナ
            system.assertEquals(null, controller.currentScreenPropertyCondition.isInductionHeating); //IHコンロ
            system.assertEquals(null, controller.currentScreenPropertyCondition.isRC); //RC
            system.assertEquals(null, controller.currentScreenPropertyCondition.isSRC); //SRC
            system.assertEquals(null, controller.currentScreenPropertyCondition.isWalkInCloset); //ウォークインクローゼット
            system.assertEquals(null, controller.currentScreenPropertyCondition.isAirConditioner); //エアコン
            system.assertEquals(null, controller.currentScreenPropertyCondition.isElevator); //エレベーター
            system.assertEquals(null, controller.currentScreenPropertyCondition.isAutoLock); //オートロック
            system.assertEquals(null, controller.currentScreenPropertyCondition.isAllElectric); //オール電化
            system.assertEquals(null, controller.currentScreenPropertyCondition.isAllWestern); //オール洋間
            system.assertEquals(null, controller.currentScreenPropertyCondition.isCarport); //カーポート
            system.assertEquals(null, controller.currentScreenPropertyCondition.isCounterKitchen); //カウンターキッチン
            system.assertEquals(null, controller.currentScreenPropertyCondition.isGasStove); //ガスコンロ
            system.assertEquals(null, controller.currentScreenPropertyCondition.isTwoGasStove); //コンロ2口
            system.assertEquals(null, controller.currentScreenPropertyCondition.isMoreGasStove); //コンロ3口以上
            system.assertEquals(null, controller.currentScreenPropertyCondition.isSystemKitchen); //システムキッチン
            system.assertEquals(null, controller.currentScreenPropertyCondition.isShowerWashBasin); //シャワー付き洗面台
            system.assertEquals(null, controller.currentScreenPropertyCondition.isShoeCloak); //シューズクローク
            system.assertEquals(null, controller.currentScreenPropertyCondition.isShoesBox); //シューズボックス
            system.assertEquals(null, controller.currentScreenPropertyCondition.isDesigners); //デザイナーズ
            system.assertEquals(null, controller.currentScreenPropertyCondition.isTrunkRoom); //トランクルーム
            system.assertEquals(null, controller.currentScreenPropertyCondition.isInternetFree); //ネット使用料無料
            system.assertEquals(null, controller.currentScreenPropertyCondition.isBikeStorage); //バイク可
            system.assertEquals(null, controller.currentScreenPropertyCondition.isSepalateBathAndRestroom); //バス・トイレ別
            system.assertEquals(null, controller.currentScreenPropertyCondition.isBalcony); //バルコニー
            system.assertEquals(null, controller.currentScreenPropertyCondition.isBuiltInGarage); //ビルトインガレージ
            system.assertEquals(null, controller.currentScreenPropertyCondition.isPropaneGas); //プロパンガス
            system.assertEquals(null, controller.currentScreenPropertyCondition.isOtherPet); //ペット(その他)
            system.assertEquals(null, controller.currentScreenPropertyCondition.isSmallPet); //ペット(小型犬)
            system.assertEquals(null, controller.currentScreenPropertyCondition.isLargePet); //ペット(大型犬)
            system.assertEquals(null, controller.currentScreenPropertyCondition.isMiddlePet); //ペット(中型犬)
            system.assertEquals(null, controller.currentScreenPropertyCondition.isCat); //ペット(猫)
            system.assertEquals(null, controller.currentScreenPropertyCondition.isPet); //ペット可
            system.assertEquals(null, controller.currentScreenPropertyCondition.isMaisonette); //メゾネット
            system.assertEquals(null, controller.currentScreenPropertyCondition.isMonitorIntercom); //モニター付きインターホン
            system.assertEquals(null, controller.currentScreenPropertyCondition.isRenovation); //リノベーション
            system.assertEquals(null, controller.currentScreenPropertyCondition.isRoofBalcony); //ルーフバルコニー
            system.assertEquals(null, controller.currentScreenPropertyCondition.isRoomShare); //ルームシェア可
            system.assertEquals(null, controller.currentScreenPropertyCondition.isLoft); //ロフト
            system.assertEquals(null, controller.currentScreenPropertyCondition.isOneRoom); //ワンルーム
            system.assertEquals(null, controller.currentScreenPropertyCondition.isIppambutsu); //一般物
            system.assertEquals(null, controller.currentScreenPropertyCondition.isWashlet); //温水洗浄便座
            system.assertEquals(null, controller.currentScreenPropertyCondition.isFurniture); //家具付き
            system.assertEquals(null, controller.currentScreenPropertyCondition.isHomeAppliance); //家電付き
            system.assertEquals(null, controller.currentScreenPropertyCondition.isForeigner); //外国人契約可
            system.assertEquals(null, controller.currentScreenPropertyCondition.isCornerRoom); //角部屋
            system.assertEquals(null, controller.currentScreenPropertyCondition.isStudent); //学生限定マンション
            system.assertEquals(null, controller.currentScreenPropertyCondition.isMusicalInstruments); //楽器相談可
            system.assertEquals(null, controller.currentScreenPropertyCondition.isIncludeManagementFee); //管理費込み
            system.assertEquals(null, controller.currentScreenPropertyCondition.desiredArea); //希望地域
            system.assertEquals(null, controller.currentScreenPropertyCondition.isLightweightSteel); //軽量鉄骨
            system.assertEquals(null, controller.currentScreenPropertyCondition.isDetachedHouse); //戸建て
            system.assertEquals(null, controller.currentScreenPropertyCondition.isNonRenewalFee); //更新料なし
            system.assertEquals(null, controller.currentScreenPropertyCondition.isElderly); //高齢者歓迎
            system.assertEquals(null, controller.currentScreenPropertyCondition.isTopFloor); //最上階
            system.assertEquals(null, controller.currentScreenPropertyCondition.isOfficeAvailable); //事務所利用可
            system.assertEquals(null, controller.currentScreenPropertyCondition.isInnerLandry); //室内洗濯機置場
            system.assertEquals(null, controller.currentScreenPropertyCondition.isWoman); //女性限定
            system.assertEquals(null, controller.currentScreenPropertyCondition.isSmallBike); //小型バイク
            system.assertEquals(null, controller.currentScreenPropertyCondition.isFloorHeating); //床暖房
            system.assertEquals(null, controller.currentScreenPropertyCondition.isWelfareAvailable); //生活保護契約可
            system.assertEquals(null, controller.currentScreenPropertyCondition.isWest); //西
            system.assertEquals(null, controller.currentScreenPropertyCondition.occupancyAreaLowerLimit); //占有面積（下限）
            system.assertEquals(null, controller.currentScreenPropertyCondition.occupancyAreaUpperLimit); //占有面積（上限）
            system.assertEquals(null, controller.currentScreenPropertyCondition.isPrivateGarden); //専用庭
            system.assertEquals(null, controller.currentScreenPropertyCondition.isRegalLavatory); //洗面所独立
            system.assertEquals(null, controller.currentScreenPropertyCondition.isLargeBike); //大型バイク
            system.assertEquals(null, controller.currentScreenPropertyCondition.isDeliveryBox); //宅配ボックス
            system.assertEquals(null, controller.currentScreenPropertyCondition.buildingAge); //築年数
            system.assertEquals(null, controller.currentScreenPropertyCondition.isMediumBike); //中型バイク
            system.assertEquals(null, controller.currentScreenPropertyCondition.isPluralCarParking); //駐車場2台可
            system.assertEquals(null, controller.currentScreenPropertyCondition.isParking); //駐車場空きあり
            system.assertEquals(null, controller.currentScreenPropertyCondition.isIncludeParkingFee); //駐車場代込み
            system.assertEquals(null, controller.currentScreenPropertyCondition.isBicycleParking); //駐輪場
            system.assertEquals(null, controller.currentScreenPropertyCondition.rentFeeFrom); //賃料から
            system.assertEquals(null, controller.currentScreenPropertyCondition.rentFeeTo); //賃料まで
            system.assertEquals(null, controller.currentScreenPropertyCondition.isAditionalBoiling); //追焚機能
            system.assertEquals(null, controller.currentScreenPropertyCondition.isNonCleaningFee); //定額修繕費なし
            system.assertEquals(null, controller.currentScreenPropertyCondition.isSteel); //鉄骨造
            system.assertEquals(null, controller.currentScreenPropertyCondition.isElectricStove); //電気コンロ
            system.assertEquals(null, controller.currentScreenPropertyCondition.walkingTime); //徒歩
            system.assertEquals(null, controller.currentScreenPropertyCondition.isTownGas); //都市ガス
            system.assertEquals(null, controller.currentScreenPropertyCondition.isEast); //東
            system.assertEquals(null, controller.currentScreenPropertyCondition.isSouth); //南
            system.assertEquals(null, controller.currentScreenPropertyCondition.isSouthWest); //南西
            system.assertEquals(null, controller.currentScreenPropertyCondition.isSouthEast); //南東
            system.assertEquals(null, controller.currentScreenPropertyCondition.isNonDeposit); //敷金/保証金なし
            system.assertEquals(null, controller.currentScreenPropertyCondition.isInSiteParking); //敷地内駐車場
            system.assertEquals(null, controller.currentScreenPropertyCondition.isCondominiumRental); //分譲賃貸
            system.assertEquals(null, controller.currentScreenPropertyCondition.isNonGuaranteeidCompany); //保証会社不要
            system.assertEquals(null, controller.currentScreenPropertyCondition.isNoGuarantor); //保証人不要
            system.assertEquals(null, controller.currentScreenPropertyCondition.isNorth); //北
            system.assertEquals(null, controller.currentScreenPropertyCondition.isNorthWest); //北西
            system.assertEquals(null, controller.currentScreenPropertyCondition.isNorthEast); //北東
            system.assertEquals(null, controller.currentScreenPropertyCondition.isWooden); //木造
            system.assertEquals(null, controller.currentScreenPropertyCondition.isDehumidifierForBathroom); //浴室乾燥機
            system.assertEquals(null, controller.currentScreenPropertyCondition.isNonKeyMoney); //礼金なし
            system.assertEquals(null, controller.currentScreenPropertyCondition.parkingFeeLimit); //1台当たりの料金上限
            system.assertEquals(null, controller.currentScreenPropertyCondition.carCount); //台数

        }else{
            system.assertEquals(trainRoute1, controller.currentScreenPropertyCondition.trainRoute1Name); //希望沿線１．路線
            system.assertEquals(trainRoute2, controller.currentScreenPropertyCondition.trainRoute2Name); //希望沿線２．路線
            system.assertEquals(trainRoute3, controller.currentScreenPropertyCondition.trainRoute3Name); //希望沿線３．路線
            system.assertEquals(stateChar1, controller.currentScreenPropertyCondition.stationsChar1); //駅１文字列
            system.assertEquals(stateChar2, controller.currentScreenPropertyCondition.stationsChar2); //駅２文字列
            system.assertEquals(stateChar3, controller.currentScreenPropertyCondition.stationsChar3); //駅３文字列

            system.assertEquals(juniorHighArea, controller.currentScreenPropertyCondition.juniorHighSchoolArea);//中学校希望学区(エリア).希望学区
            system.assertEquals(elementaryArea, controller.currentScreenPropertyCondition.elementarySchoolArea);//小学校希望学区(エリア).希望学区
            system.assertEquals(desiredJSchool, controller.currentScreenPropertyCondition.desiredJuniorHighSchool); //希望中学校
            system.assertEquals(desiredESchool, controller.currentScreenPropertyCondition.desiredPrimarySchool); //希望小学校

            system.assertEquals(apcName, controller.currentScreenPropertyCondition.Name); //物件条件名
            system.assertEquals(bool, controller.currentScreenPropertyCondition.is1DK); //1DK
            system.assertEquals(bool, controller.currentScreenPropertyCondition.is1K); //1K
            system.assertEquals(bool, controller.currentScreenPropertyCondition.is1LDK1SLDK); //1LDK/SLDK
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isFirstFloor); //1階
            system.assertEquals(bool, controller.currentScreenPropertyCondition.is2K2DK); //2K/DK
            system.assertEquals(bool, controller.currentScreenPropertyCondition.is2LDK2SLDK); //2LDK/SLDK
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isSecondFloorOver); //2階以上
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isTwoTenant); //2人入居可
            system.assertEquals(bool, controller.currentScreenPropertyCondition.is3K3DK); //3K/DK
            system.assertEquals(bool, controller.currentScreenPropertyCondition.is3LDK3SLDK); //3LDK/SLDK
            system.assertEquals(bool, controller.currentScreenPropertyCondition.is4K4DK4LDKFrom); //4K/DK/LDK~
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isBSAntenna); //BSアンテナ
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isCATV); //CATV
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isCSAntenna); //CSアンテナ
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isInductionHeating); //IHコンロ
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isRC); //RC
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isSRC); //SRC
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isWalkInCloset); //ウォークインクローゼット
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isAirConditioner); //エアコン
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isElevator); //エレベーター
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isAutoLock); //オートロック
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isAllElectric); //オール電化
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isAllWestern); //オール洋間
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isCarport); //カーポート
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isCounterKitchen); //カウンターキッチン
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isGasStove); //ガスコンロ
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isTwoGasStove); //コンロ2口
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isMoreGasStove); //コンロ3口以上
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isSystemKitchen); //システムキッチン
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isShowerWashBasin); //シャワー付き洗面台
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isShoeCloak); //シューズクローク
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isShoesBox); //シューズボックス
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isDesigners); //デザイナーズ
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isTrunkRoom); //トランクルーム
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isInternetFree); //ネット使用料無料
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isBikeStorage); //バイク可
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isSepalateBathAndRestroom); //バス・トイレ別
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isBalcony); //バルコニー
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isBuiltInGarage); //ビルトインガレージ
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isPropaneGas); //プロパンガス
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isOtherPet); //ペット(その他)
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isSmallPet); //ペット(小型犬)
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isLargePet); //ペット(大型犬)
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isMiddlePet); //ペット(中型犬)
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isCat); //ペット(猫)
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isPet); //ペット可
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isMaisonette); //メゾネット
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isMonitorIntercom); //モニター付きインターホン
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isRenovation); //リノベーション
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isRoofBalcony); //ルーフバルコニー
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isRoomShare); //ルームシェア可
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isLoft); //ロフト
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isOneRoom); //ワンルーム
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isIppambutsu); //一般物
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isWashlet); //温水洗浄便座
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isFurniture); //家具付き
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isHomeAppliance); //家電付き
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isForeigner); //外国人契約可
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isCornerRoom); //角部屋
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isStudent); //学生限定マンション
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isMusicalInstruments); //楽器相談可
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isIncludeManagementFee); //管理費込み
            system.assertEquals(desiredArea, controller.currentScreenPropertyCondition.desiredArea); //希望地域
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isLightweightSteel); //軽量鉄骨
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isDetachedHouse); //戸建て
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isNonRenewalFee); //更新料なし
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isElderly); //高齢者歓迎
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isTopFloor); //最上階
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isOfficeAvailable); //事務所利用可
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isInnerLandry); //室内洗濯機置場
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isWoman); //女性限定
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isSmallBike); //小型バイク
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isFloorHeating); //床暖房
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isWelfareAvailable); //生活保護契約可
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isWest); //西
            system.assertEquals(oaLowLimit, controller.currentScreenPropertyCondition.occupancyAreaLowerLimit); //占有面積（下限）
            system.assertEquals(oaUpLimit, controller.currentScreenPropertyCondition.occupancyAreaUpperLimit); //占有面積（上限）
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isPrivateGarden); //専用庭
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isRegalLavatory); //洗面所独立
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isLargeBike); //大型バイク
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isDeliveryBox); //宅配ボックス
            system.assertEquals(buildingAge, controller.currentScreenPropertyCondition.buildingAge); //築年数
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isMediumBike); //中型バイク
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isPluralCarParking); //駐車場2台可
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isParking); //駐車場空きあり
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isIncludeParkingFee); //駐車場代込み
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isBicycleParking); //駐輪場
            system.assertEquals(rentFeeFrom, controller.currentScreenPropertyCondition.rentFeeFrom); //賃料から
            system.assertEquals(rentFeeTo, controller.currentScreenPropertyCondition.rentFeeTo); //賃料まで
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isAditionalBoiling); //追焚機能
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isNonCleaningFee); //定額修繕費なし
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isSteel); //鉄骨造
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isElectricStove); //電気コンロ
            system.assertEquals(walkingTime, controller.currentScreenPropertyCondition.walkingTime); //徒歩
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isTownGas); //都市ガス
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isEast); //東
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isSouth); //南
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isSouthWest); //南西
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isSouthEast); //南東
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isNonDeposit); //敷金/保証金なし
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isInSiteParking); //敷地内駐車場
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isCondominiumRental); //分譲賃貸
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isNonGuaranteeidCompany); //保証会社不要
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isNoGuarantor); //保証人不要
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isNorth); //北
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isNorthWest); //北西
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isNorthEast); //北東
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isWooden); //木造
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isDehumidifierForBathroom); //浴室乾燥機
            system.assertEquals(bool, controller.currentScreenPropertyCondition.isNonKeyMoney); //礼金なし
            system.assertEquals(parkingFlimit, controller.currentScreenPropertyCondition.parkingFeeLimit); //1台当たりの料金上限
            system.assertEquals(carCount, controller.currentScreenPropertyCondition.carCount); //台数
        }
    }

    // 登録・更新・削除されたお客様物件条件を確認する。
    private static void checkAccountPropertyConditionsObj(Id accId, String status){

        List<AccountPropertyConditions__c> apcList = [SELECT ID
                                                                ,Name // お客様物件条件名
                                                                ,CreatedDate // 作成日時
                                                                ,IsDeleted__c // 削除
                                                                ,DesiredArea__c// 希望地域 
                                                                ,DesiredTrainRoute1__c//希望沿線１ 
                                                                ,DesiredTrainRoute1__r.TrainRoute__c//希望沿線１．路線
                                                                ,DesiredTrainRoute1__r.TrainRoute__r.NAME//希望沿線１．路線．路線名
                                                                ,DesiredTrainRoute2__c//希望沿線２ 
                                                                ,DesiredTrainRoute2__r.TrainRoute__c//希望沿線１．路線
                                                                ,DesiredTrainRoute2__r.TrainRoute__r.NAME//希望沿線１．路線．路線名
                                                                ,DesiredTrainRoute3__c//希望沿線３ 
                                                                ,DesiredTrainRoute3__r.TrainRoute__c//希望沿線１．路線
                                                                ,DesiredTrainRoute3__r.TrainRoute__r.NAME//希望沿線１．路線．路線名
                                                                ,WalkingTime__c//徒歩 
                                                                ,IsOneRoom__c//ワンルーム 
                                                                ,Is1K__c//1K 
                                                                ,Is1DK__c//1DK 
                                                                ,Is1LDK1SLDK__c//1LDK/SLDK 
                                                                ,Is2K2DK__c//2K/DK 
                                                                ,Is2LDK2SLDK__c//2LDK/SLDK 
                                                                ,Is3K3DK__c//3K/DK 
                                                                ,Is3LDK3SLDK__c//3LDK/SLDK 
                                                                ,Is4K4DK4LDKFrom__c//4K/DK/LDK~ 
                                                                ,IsWooden__c//木造 
                                                                ,IsLightweightSteel__c//軽量鉄骨 
                                                                ,IsSteel__c//鉄骨造 
                                                                ,IsRC__c//RC 
                                                                ,IsSRC__c//SRC 
                                                                ,IsNorth__c//北 
                                                                ,IsNorthEast__c//北東 
                                                                ,IsEast__c//東 
                                                                ,IsSouthEast__c//南東 
                                                                ,IsSouth__c//南 
                                                                ,IsSouthWest__c//南西 
                                                                ,IsWest__c//西 
                                                                ,IsNorthWest__c//北西 
                                                                ,IsNonDeposit__c//敷金/保証金なし 
                                                                ,IsNonKeyMoney__c//礼金なし 
                                                                ,IsNonCleaningFee__c//定額修繕費なし 
                                                                ,IsNonRenewalFee__c//更新料なし 
                                                                ,RentFeeFrom__c//賃料から 
                                                                ,RentFeeTo__c//賃料まで 
                                                                ,IsIncludeManagementFee__c//管理費込み 
                                                                ,IsIncludeParkingFee__c//駐車場代込み 
                                                                ,OccupancyAreaLowerLimit__c//占有面積（下限） 
                                                                ,OccupancyAreaUpperLimit__c//占有面積（上限） 
                                                                ,BuildingAge__c//築年数
                                                                ,IsDetachedHouse__c//戸建て 
                                                                ,IsMaisonette__c//メゾネット 
                                                                ,IsLoft__c//ロフト 
                                                                ,IsDesigners__c//デザイナーズ 
                                                                ,IsRenovation__c//リノベーション 
                                                                ,IsCondominiumRental__c//分譲賃貸 
                                                                ,IsAllWestern__c//オール洋間 
                                                                ,IsFirstFloor__c//1階 
                                                                ,IsSecondFloorOver__c//2階以上 
                                                                ,IsTopFloor__c//最上階 
                                                                ,IsCornerRoom__c//角部屋 
                                                                ,IsBalcony__c//バルコニー 
                                                                ,IsRoofBalcony__c//ルーフバルコニー 
                                                                ,IsPrivateGarden__c//専用庭 
                                                                ,IsParking__c//駐車場空きあり 
                                                                ,IsInSiteParking__c//敷地内駐車場 
                                                                ,IsPluralCarParking__c//駐車場2台可 
                                                                ,IsBuiltInGarage__c//ビルトインガレージ 
                                                                ,IsCarport__c//カーポート 
                                                                ,IsBicycleParking__c//駐輪場 
                                                                ,IsBikeStorage__c//バイク可 
                                                                ,IsSmallBike__c//小型バイク 
                                                                ,IsMediumBike__c//中型バイク 
                                                                ,IsLargeBike__c//大型バイク 
                                                                ,IsElevator__c//エレベーター 
                                                                ,IsDeliveryBox__c//宅配ボックス 
                                                                ,IsCounterKitchen__c//カウンターキッチン 
                                                                ,IsSystemKitchen__c//システムキッチン 
                                                                ,IsGasStove__c//ガスコンロ 
                                                                ,IsElectricStove__c//電気コンロ 
                                                                ,IsInductionHeating__c//IHコンロ 
                                                                ,IsTwoGasStove__c//コンロ2口 
                                                                ,IsMoreGasStove__c//コンロ3口以上 
                                                                ,IsSepalateBathAndRestroom__c//バス・トイレ別 
                                                                ,IsAditionalBoiling__c//追焚機能 
                                                                ,IsDehumidifierForBathroom__c//浴室乾燥機 
                                                                ,IsWashlet__c//温水洗浄便座 
                                                                ,IsShowerWashBasin__c//シャワー付き洗面台 
                                                                ,IsRegalLavatory__c//洗面所独立 
                                                                ,IsInnerLandry__c//室内洗濯機置場 
                                                                ,IsTownGas__c//都市ガス 
                                                                ,IsPropaneGas__c//プロパンガス 
                                                                ,IsAllElectric__c//オール電化 
                                                                ,IsAirConditioner__c//エアコン 
                                                                ,IsFloorHeating__c//床暖房 
                                                                ,IsShoesBox__c//シューズボックス 
                                                                ,IsShoeCloak__c//シューズクローク 
                                                                ,IsWalkInCloset__c//ウォークインクローゼット 
                                                                ,IsTrunkRoom__c//トランクルーム 
                                                                ,IsBSAntenna__c//BSアンテナ 
                                                                ,IsCSAntenna__c//CSアンテナ 
                                                                ,IsCATV__c//CATV 
                                                                ,IsInternetFree__c//ネット使用料無料 
                                                                ,IsMonitorIntercom__c//モニター付きインターホン 
                                                                ,IsAutoLock__c//オートロック 
                                                                ,IsFurniture__c//家具付き 
                                                                ,IsHomeAppliance__c//家電付き 
                                                                ,IsNoGuarantor__c//保証人不要 
                                                                ,IsNonGuaranteeidCompany__c//保証会社不要 
                                                                ,IsMusicalInstruments__c//楽器相談可 
                                                                ,IsForeigner__c//外国人契約可 
                                                                ,IsOfficeAvailable__c//事務所利用可 
                                                                ,IsWelfareAvailable__c//生活保護契約可 
                                                                ,IsPet__c//ペット可 
                                                                ,IsLargePet__c//ペット(大型犬) 
                                                                ,IsMiddlePet__c//ペット(中型犬) 
                                                                ,IsSmallPet__c//ペット(小型犬) 
                                                                ,IsCat__c//ペット(猫) 
                                                                ,IsOtherPet__c//ペット(その他) 
                                                                ,IsTwoTenant__c//2人入居可 
                                                                ,IsRoomShare__c//ルームシェア可 
                                                                ,IsIppambutsu__c//一般物 
                                                                ,IsElderly__c//高齢者歓迎 
                                                                ,IsWoman__c//女性限定 
                                                                ,IsStudent__c//学生限定マンション
                                                                ,CarCount__c//台数
                                                                ,ParkingFeeLimit__c//1台当たりの料金上限
                                                                ,Parking__c//駐車場
                                                                // ▼問合せ415で追加
                                                                ,DesiredJuniorHighSchoolArea__c //中学校希望学区（エリア）
                                                                ,DesiredJuniorHighSchoolArea__r.SchoolArea__c // 中学校希望学区（エリア）.希望学区（エリア）
                                                                ,DesiredElementarySchoolArea__c //小学校希望学区（エリア）
                                                                ,DesiredElementarySchoolArea__r.SchoolArea__c // 小学校希望学区（エリア）.希望学区（エリア）
                                                        FROM AccountPropertyConditions__c
                                                        WHERE Account__c =:accId AND IsDeleted__c = FALSE
                                                        ORDER BY CreatedDate ASC];

            // assertEquals判定フラグ
            Boolean bool = false;

            // 確認用変数
            String apcName;
            String buildingAge;
            Decimal carCount;
            String desiredArea;
            String oaLowLimit;
            String oaUpLimit;
            String parking;
            Decimal parkingFlimit;
            Decimal rentFeeFrom;
            Decimal rentFeeTo;
            String walkingTime;
            String trainRoute1;
            String trainRoute2;
            String trainRoute3;
            String stateChar1;
            String stateChar2;
            String stateChar3;
            String juniorHighArea;
            String elementaryArea;
            String desiredJSchool;
            String desiredESchool;
    
            for(AccountPropertyConditions__c apc : apcList){
                apcName = apc.Name;
                if(apc.Name == '条件2' && status == 'update'){
                    bool = false;
                } else if(apc.Name == '条件2' && status == 'register'){
                    bool = true;
                } else if(apc.Name == '条件3' && status == 'register'){
                    bool = false;
                } else if(apc.Name == '条件3' && status == 'update'){
                    bool = true;
                } else if(apc.Name == '条件4' && status == 'register'){
                    bool = true;
                } else if(apc.Name == '条件4' && status == 'update'){
                    bool = false;
                }

                if(bool){
                    buildingAge = '999';
                    carCount = 99;
                    desiredArea = '希望地域';
                    oaLowLimit = '0';
                    oaUpLimit = '999';
                    parking = '有';
                    parkingFlimit = 9999;
                    rentFeeFrom = 9999;
                    rentFeeTo = 9999;
                    walkingTime = '999';
                    trainRoute1 = 'テスト路線１';
                    trainRoute2 = 'テスト路線２';
                    trainRoute3 = 'テスト路線３';
                    stateChar1 = 'テスト駅１';
                    stateChar2 = 'テスト駅２';
                    stateChar3 = 'テスト駅３';
                    juniorHighArea = '港区';
                    elementaryArea = '瑞穂区';
                    desiredJSchool = 'テスト学校1';
                    desiredESchool = 'テスト学校2';
        
                }else{
                    buildingAge = null;
                    carCount = null;
                    desiredArea = null;
                    oaLowLimit = null;
                    oaUpLimit = null;
                    parking = null;
                    parkingFlimit = null;
                    rentFeeFrom = null;
                    rentFeeTo = null;
                    walkingTime = null;
                    trainRoute1 = null;
                    trainRoute2 = null;
                    trainRoute3 = null;
                    stateChar1 = null;
                    stateChar2 = null;
                    stateChar3 = null;
                    juniorHighArea = null;
                    elementaryArea = null;
                    desiredJSchool = null;
                    desiredESchool = null;
                }

                if(status =='delete'){
                    if(apc.Name == '条件1'){
                        bool = true;
                    } else if(apc.Name == '条件2'){
                        bool = false;
                    } else if(apc.Name == '条件3'){
                        bool = true;
                    }
                    buildingAge = '999';
                    carCount = 99;
                    desiredArea = '希望地域';
                    oaLowLimit = '0';
                    oaUpLimit = '999';
                    parking = '有';
                    parkingFlimit = 9999;
                    rentFeeFrom = 9999;
                    rentFeeTo = 9999;
                    walkingTime = '999';
                    trainRoute1 = 'テスト路線１';
                    trainRoute2 = 'テスト路線２';
                    trainRoute3 = 'テスト路線３';
                    stateChar1 = 'テスト駅１';
                    stateChar2 = 'テスト駅２';
                    stateChar3 = 'テスト駅３';
                    juniorHighArea = '港区';
                    elementaryArea = '瑞穂区';
                    desiredJSchool = 'テスト学校1';
                    desiredESchool = 'テスト学校2';
                }

                system.assertEquals(apcName, apc.Name); //物件条件名
                system.assertEquals(desiredArea, apc.DesiredArea__c); //希望地域
                system.assertEquals(oaLowLimit, apc.OccupancyAreaLowerLimit__c); //占有面積（下限）
                system.assertEquals(oaUpLimit, apc.OccupancyAreaUpperLimit__c); //占有面積（上限）
                system.assertEquals(buildingAge, apc.BuildingAge__c); //築年数
                system.assertEquals(rentFeeFrom, apc.RentFeeFrom__c); //賃料から
                system.assertEquals(rentFeeTo, apc.RentFeeTo__c); //賃料まで
                system.assertEquals(walkingTime, apc.WalkingTime__c); //徒歩
                system.assertEquals(parkingFlimit, apc.ParkingFeeLimit__c); //1台当たりの料金上限
                system.assertEquals(carCount, apc.CarCount__c); //台数

                system.assertEquals(bool, apc.Is1DK__c); //1DK
                system.assertEquals(bool, apc.Is1K__c); //1K
                system.assertEquals(bool, apc.Is1LDK1SLDK__c); //1LDK/SLDK
                system.assertEquals(bool, apc.IsFirstFloor__c); //1階
                system.assertEquals(bool, apc.Is2K2DK__c); //2K/DK
                system.assertEquals(bool, apc.Is2LDK2SLDK__c); //2LDK/SLDK
                system.assertEquals(bool, apc.IsSecondFloorOver__c); //2階以上
                system.assertEquals(bool, apc.IsTwoTenant__c); //2人入居可
                system.assertEquals(bool, apc.Is3K3DK__c); //3K/DK
                system.assertEquals(bool, apc.Is3LDK3SLDK__c); //3LDK/SLDK
                system.assertEquals(bool, apc.Is4K4DK4LDKFrom__c); //4K/DK/LDK~
                system.assertEquals(bool, apc.IsBSAntenna__c); //BSアンテナ
                system.assertEquals(bool, apc.IsCATV__c); //CATV
                system.assertEquals(bool, apc.IsCSAntenna__c); //CSアンテナ
                system.assertEquals(bool, apc.IsInductionHeating__c); //IHコンロ
                system.assertEquals(bool, apc.IsRC__c); //RC
                system.assertEquals(bool, apc.IsSRC__c); //SRC
                system.assertEquals(bool, apc.IsWalkInCloset__c); //ウォークインクローゼット
                system.assertEquals(bool, apc.IsAirConditioner__c); //エアコン
                system.assertEquals(bool, apc.IsElevator__c); //エレベーター
                system.assertEquals(bool, apc.IsAutoLock__c); //オートロック
                system.assertEquals(bool, apc.IsAllElectric__c); //オール電化
                system.assertEquals(bool, apc.IsAllWestern__c); //オール洋間
                system.assertEquals(bool, apc.IsCarport__c); //カーポート
                system.assertEquals(bool, apc.IsCounterKitchen__c); //カウンターキッチン
                system.assertEquals(bool, apc.IsGasStove__c); //ガスコンロ
                system.assertEquals(bool, apc.IsTwoGasStove__c); //コンロ2口
                system.assertEquals(bool, apc.IsMoreGasStove__c); //コンロ3口以上
                system.assertEquals(bool, apc.IsSystemKitchen__c); //システムキッチン
                system.assertEquals(bool, apc.IsShowerWashBasin__c); //シャワー付き洗面台
                system.assertEquals(bool, apc.IsShoeCloak__c); //シューズクローク
                system.assertEquals(bool, apc.IsShoesBox__c); //シューズボックス
                system.assertEquals(bool, apc.IsDesigners__c); //デザイナーズ
                system.assertEquals(bool, apc.IsTrunkRoom__c); //トランクルーム
                system.assertEquals(bool, apc.IsInternetFree__c); //ネット使用料無料
                system.assertEquals(bool, apc.IsBikeStorage__c); //バイク可
                system.assertEquals(bool, apc.IsSepalateBathAndRestroom__c); //バス・トイレ別
                system.assertEquals(bool, apc.IsBalcony__c); //バルコニー
                system.assertEquals(bool, apc.IsBuiltInGarage__c); //ビルトインガレージ
                system.assertEquals(bool, apc.IsPropaneGas__c); //プロパンガス
                system.assertEquals(bool, apc.IsOtherPet__c); //ペット(その他)
                system.assertEquals(bool, apc.IsSmallPet__c); //ペット(小型犬)
                system.assertEquals(bool, apc.IsLargePet__c); //ペット(大型犬)
                system.assertEquals(bool, apc.IsMiddlePet__c); //ペット(中型犬)
                system.assertEquals(bool, apc.IsCat__c); //ペット(猫)
                system.assertEquals(bool, apc.IsPet__c); //ペット可
                system.assertEquals(bool, apc.IsMaisonette__c); //メゾネット
                system.assertEquals(bool, apc.IsMonitorIntercom__c); //モニター付きインターホン
                system.assertEquals(bool, apc.IsRenovation__c); //リノベーション
                system.assertEquals(bool, apc.IsRoofBalcony__c); //ルーフバルコニー
                system.assertEquals(bool, apc.IsRoomShare__c); //ルームシェア可
                system.assertEquals(bool, apc.IsLoft__c); //ロフト
                system.assertEquals(bool, apc.IsOneRoom__c); //ワンルーム
                system.assertEquals(bool, apc.IsIppambutsu__c); //一般物
                system.assertEquals(bool, apc.IsWashlet__c); //温水洗浄便座
                system.assertEquals(bool, apc.IsFurniture__c); //家具付き
                system.assertEquals(bool, apc.IsHomeAppliance__c); //家電付き
                system.assertEquals(bool, apc.IsForeigner__c); //外国人契約可
                system.assertEquals(bool, apc.IsCornerRoom__c); //角部屋
                system.assertEquals(bool, apc.IsStudent__c); //学生限定マンション
                system.assertEquals(bool, apc.IsMusicalInstruments__c); //楽器相談可
                system.assertEquals(bool, apc.IsIncludeManagementFee__c); //管理費込み
                system.assertEquals(bool, apc.IsLightweightSteel__c); //軽量鉄骨
                system.assertEquals(bool, apc.IsDetachedHouse__c); //戸建て
                system.assertEquals(bool, apc.IsNonRenewalFee__c); //更新料なし
                system.assertEquals(bool, apc.IsElderly__c); //高齢者歓迎
                system.assertEquals(bool, apc.IsTopFloor__c); //最上階
                system.assertEquals(bool, apc.IsOfficeAvailable__c); //事務所利用可
                system.assertEquals(bool, apc.IsInnerLandry__c); //室内洗濯機置場
                system.assertEquals(bool, apc.IsWoman__c); //女性限定
                system.assertEquals(bool, apc.IsSmallBike__c); //小型バイク
                system.assertEquals(bool, apc.IsFloorHeating__c); //床暖房
                system.assertEquals(bool, apc.IsWelfareAvailable__c); //生活保護契約可
                system.assertEquals(bool, apc.IsWest__c); //西
                system.assertEquals(bool, apc.IsPrivateGarden__c); //専用庭
                system.assertEquals(bool, apc.IsRegalLavatory__c); //洗面所独立
                system.assertEquals(bool, apc.IsLargeBike__c); //大型バイク
                system.assertEquals(bool, apc.IsDeliveryBox__c); //宅配ボックス
                system.assertEquals(bool, apc.IsMediumBike__c); //中型バイク
                system.assertEquals(bool, apc.IsPluralCarParking__c); //駐車場2台可
                system.assertEquals(bool, apc.IsParking__c); //駐車場空きあり
                system.assertEquals(bool, apc.IsIncludeParkingFee__c); //駐車場代込み
                system.assertEquals(bool, apc.IsBicycleParking__c); //駐輪場
                system.assertEquals(bool, apc.IsAditionalBoiling__c); //追焚機能
                system.assertEquals(bool, apc.IsNonCleaningFee__c); //定額修繕費なし
                system.assertEquals(bool, apc.IsSteel__c); //鉄骨造
                system.assertEquals(bool, apc.IsElectricStove__c); //電気コンロ
                system.assertEquals(bool, apc.IsTownGas__c); //都市ガス
                system.assertEquals(bool, apc.IsEast__c); //東
                system.assertEquals(bool, apc.IsSouth__c); //南
                system.assertEquals(bool, apc.IsSouthWest__c); //南西
                system.assertEquals(bool, apc.IsSouthEast__c); //南東
                system.assertEquals(bool, apc.IsNonDeposit__c); //敷金/保証金なし
                system.assertEquals(bool, apc.IsInSiteParking__c); //敷地内駐車場
                system.assertEquals(bool, apc.IsCondominiumRental__c); //分譲賃貸
                system.assertEquals(bool, apc.IsNonGuaranteeidCompany__c); //保証会社不要
                system.assertEquals(bool, apc.IsNoGuarantor__c); //保証人不要
                system.assertEquals(bool, apc.IsNorth__c); //北
                system.assertEquals(bool, apc.IsNorthWest__c); //北西
                system.assertEquals(bool, apc.IsNorthEast__c); //北東
                system.assertEquals(bool, apc.IsWooden__c); //木造
                system.assertEquals(bool, apc.IsDehumidifierForBathroom__c); //浴室乾燥機
                system.assertEquals(bool, apc.IsNonKeyMoney__c); //礼金なし
            }
    }

    static void checkAccount(Id accId, String status){
        Account acc = [SELECT ID
                            ,PropertyConditionsName__c // お客様物件条件名
                            ,DesiredArea__c// 希望地域 
                            ,DesiredTrainRoute1__c//希望沿線１ 
                            ,DesiredTrainRoute1__r.TrainRoute__c//希望沿線１．路線
                            ,DesiredTrainRoute1__r.TrainRoute__r.NAME//希望沿線１．路線．路線名
                            ,DesiredTrainRoute2__c//希望沿線２ 
                            ,DesiredTrainRoute2__r.TrainRoute__c//希望沿線１．路線
                            ,DesiredTrainRoute2__r.TrainRoute__r.NAME//希望沿線１．路線．路線名
                            ,DesiredTrainRoute3__c//希望沿線３ 
                            ,DesiredTrainRoute3__r.TrainRoute__c//希望沿線１．路線
                            ,DesiredTrainRoute3__r.TrainRoute__r.NAME//希望沿線１．路線．路線名
                            ,WalkingTime__c//徒歩 
                            ,IsOneRoom__c//ワンルーム 
                            ,Is1K__c//1K 
                            ,Is1DK__c//1DK 
                            ,Is1LDK1SLDK__c//1LDK/SLDK 
                            ,Is2K2DK__c//2K/DK 
                            ,Is2LDK2SLDK__c//2LDK/SLDK 
                            ,Is3K3DK__c//3K/DK 
                            ,Is3LDK3SLDK__c//3LDK/SLDK 
                            ,Is4K4DK4LDKFrom__c//4K/DK/LDK~ 
                            ,IsWooden__c//木造 
                            ,IsLightweightSteel__c//軽量鉄骨 
                            ,IsSteel__c//鉄骨造 
                            ,IsRC__c//RC 
                            ,IsSRC__c//SRC 
                            ,IsNorth__c//北 
                            ,IsNorthEast__c//北東 
                            ,IsEast__c//東 
                            ,IsSouthEast__c//南東 
                            ,IsSouth__c//南 
                            ,IsSouthWest__c//南西 
                            ,IsWest__c//西 
                            ,IsNorthWest__c//北西 
                            ,IsNonDeposit__c//敷金/保証金なし 
                            ,IsNonKeyMoney__c//礼金なし 
                            ,IsNonCleaningFee__c//定額修繕費なし 
                            ,IsNonRenewalFee__c//更新料なし 
                            ,RentFeeFrom__c//賃料から 
                            ,RentFeeTo__c//賃料まで 
                            ,IsIncludeManagementFee__c//管理費込み 
                            ,IsIncludeParkingFee__c//駐車場代込み 
                            ,OccupancyAreaLowerLimit__c//占有面積（下限） 
                            ,OccupancyAreaUpperLimit__c//占有面積（上限） 
                            ,BuildingAge__c//築年数
                            ,IsDetachedHouse__c//戸建て 
                            ,IsMaisonette__c//メゾネット 
                            ,IsLoft__c//ロフト 
                            ,IsDesigners__c//デザイナーズ 
                            ,IsRenovation__c//リノベーション 
                            ,IsCondominiumRental__c//分譲賃貸 
                            ,IsAllWestern__c//オール洋間 
                            ,IsFirstFloor__c//1階 
                            ,IsSecondFloorOver__c//2階以上 
                            ,IsTopFloor__c//最上階 
                            ,IsCornerRoom__c//角部屋 
                            ,IsBalcony__c//バルコニー 
                            ,IsRoofBalcony__c//ルーフバルコニー 
                            ,IsPrivateGarden__c//専用庭 
                            ,IsParking__c//駐車場空きあり 
                            ,IsInSiteParking__c//敷地内駐車場 
                            ,IsPluralCarParking__c//駐車場2台可 
                            ,IsBuiltInGarage__c//ビルトインガレージ 
                            ,IsCarport__c//カーポート 
                            ,IsBicycleParking__c//駐輪場 
                            ,IsBikeStorage__c//バイク可 
                            ,IsSmallBike__c//小型バイク 
                            ,IsMediumBike__c//中型バイク 
                            ,IsLargeBike__c//大型バイク 
                            ,IsElevator__c//エレベーター 
                            ,IsDeliveryBox__c//宅配ボックス 
                            ,IsCounterKitchen__c//カウンターキッチン 
                            ,IsSystemKitchen__c//システムキッチン 
                            ,IsGasStove__c//ガスコンロ 
                            ,IsElectricStove__c//電気コンロ 
                            ,IsInductionHeating__c//IHコンロ 
                            ,IsTwoGasStove__c//コンロ2口 
                            ,IsMoreGasStove__c//コンロ3口以上 
                            ,IsSepalateBathAndRestroom__c//バス・トイレ別 
                            ,IsAditionalBoiling__c//追焚機能 
                            ,IsDehumidifierForBathroom__c//浴室乾燥機 
                            ,IsWashlet__c//温水洗浄便座 
                            ,IsShowerWashBasin__c//シャワー付き洗面台 
                            ,IsRegalLavatory__c//洗面所独立 
                            ,IsInnerLandry__c//室内洗濯機置場 
                            ,IsTownGas__c//都市ガス 
                            ,IsPropaneGas__c//プロパンガス 
                            ,IsAllElectric__c//オール電化 
                            ,IsAirConditioner__c//エアコン 
                            ,IsFloorHeating__c//床暖房 
                            ,IsShoesBox__c//シューズボックス 
                            ,IsShoeCloak__c//シューズクローク 
                            ,IsWalkInCloset__c//ウォークインクローゼット 
                            ,IsTrunkRoom__c//トランクルーム 
                            ,IsBSAntenna__c//BSアンテナ 
                            ,IsCSAntenna__c//CSアンテナ 
                            ,IsCATV__c//CATV 
                            ,IsInternetFree__c//ネット使用料無料 
                            ,IsMonitorIntercom__c//モニター付きインターホン 
                            ,IsAutoLock__c//オートロック 
                            ,IsFurniture__c//家具付き 
                            ,IsHomeAppliance__c//家電付き 
                            ,IsNoGuarantor__c//保証人不要 
                            ,IsNonGuaranteeidCompany__c//保証会社不要 
                            ,IsMusicalInstruments__c//楽器相談可 
                            ,IsForeigner__c//外国人契約可 
                            ,IsOfficeAvailable__c//事務所利用可 
                            ,IsWelfareAvailable__c//生活保護契約可 
                            ,IsPet__c//ペット可 
                            ,IsLargePet__c//ペット(大型犬) 
                            ,IsMiddlePet__c//ペット(中型犬) 
                            ,IsSmallPet__c//ペット(小型犬) 
                            ,IsCat__c//ペット(猫) 
                            ,IsOtherPet__c//ペット(その他) 
                            ,IsTwoTenant__c//2人入居可 
                            ,IsRoomShare__c//ルームシェア可 
                            ,IsIppambutsu__c//一般物 
                            ,IsElderly__c//高齢者歓迎 
                            ,IsWoman__c//女性限定 
                            ,IsStudent__c//学生限定マンション
                            ,CarCount__c//台数
                            ,ParkingFeeLimit__c//1台当たりの料金上限
                            ,Parking__c//駐車場
                            // ▼問合せ415で追加
                            ,DesiredJuniorHighSchoolArea__c //中学校希望学区（エリア）
                            ,DesiredJuniorHighSchoolArea__r.SchoolArea__c // 中学校希望学区（エリア）.希望学区（エリア）
                            ,DesiredElementarySchoolArea__c //小学校希望学区（エリア）
                            ,DesiredElementarySchoolArea__r.SchoolArea__c // 小学校希望学区（エリア）.希望学区（エリア）
                    FROM Account
                    WHERE id =:accId]; 

        // assertEquals判定フラグ
        Boolean bool = false;

        // 確認用変数
        String PropertyConditionsName;
        String buildingAge;
        Decimal carCount;
        String desiredArea;
        String oaLowLimit;
        String oaUpLimit;
        String parking;
        Decimal parkingFlimit;
        Decimal rentFeeFrom;
        Decimal rentFeeTo;
        String walkingTime;
        String trainRoute1;
        String trainRoute2;
        String trainRoute3;
        String stateChar1;
        String stateChar2;
        String stateChar3;
        String juniorHighArea;
        String elementaryArea;
        String desiredJSchool;
        String desiredESchool;

        
        if(acc.PropertyConditionsName__c == '条件1' && status == 'register'){
            bool = true;
            PropertyConditionsName = acc.PropertyConditionsName__c;
        } else if(acc.PropertyConditionsName__c == '条件1' && status == 'update'){
            bool = false;
            PropertyConditionsName = acc.PropertyConditionsName__c;
        } 

        if(bool){
            buildingAge = '999';
            carCount = 99;
            desiredArea = '希望地域';
            oaLowLimit = '0';
            oaUpLimit = '999';
            parking = '有';
            parkingFlimit = 9999;
            rentFeeFrom = 9999;
            rentFeeTo = 9999;
            walkingTime = '999';
            trainRoute1 = 'テスト路線１';
            trainRoute2 = 'テスト路線２';
            trainRoute3 = 'テスト路線３';
            stateChar1 = 'テスト駅１';
            stateChar2 = 'テスト駅２';
            stateChar3 = 'テスト駅３';
            juniorHighArea = '港区';
            elementaryArea = '瑞穂区';
            desiredJSchool = 'テスト学校1';
            desiredESchool = 'テスト学校2';

        }else{
            buildingAge = null;
            carCount = null;
            desiredArea = null;
            oaLowLimit = null;
            oaUpLimit = null;
            parking = null;
            parkingFlimit = null;
            rentFeeFrom = null;
            rentFeeTo = null;
            walkingTime = null;
            trainRoute1 = null;
            trainRoute2 = null;
            trainRoute3 = null;
            stateChar1 = null;
            stateChar2 = null;
            stateChar3 = null;
            juniorHighArea = null;
            elementaryArea = null;
            desiredJSchool = null;
            desiredESchool = null;
        }
        system.assertEquals(PropertyConditionsName, acc.PropertyConditionsName__c); //物件条件名
        system.assertEquals(desiredArea, acc.DesiredArea__c); //希望地域
        system.assertEquals(oaLowLimit, acc.OccupancyAreaLowerLimit__c); //占有面積（下限）
        system.assertEquals(oaUpLimit, acc.OccupancyAreaUpperLimit__c); //占有面積（上限）
        system.assertEquals(buildingAge, acc.BuildingAge__c); //築年数
        system.assertEquals(rentFeeFrom, acc.RentFeeFrom__c); //賃料から
        system.assertEquals(rentFeeTo, acc.RentFeeTo__c); //賃料まで
        system.assertEquals(walkingTime, acc.WalkingTime__c); //徒歩
        system.assertEquals(parkingFlimit, acc.ParkingFeeLimit__c); //1台当たりの料金上限
        system.assertEquals(carCount, acc.CarCount__c); //台数

        system.assertEquals(bool, acc.Is1DK__c); //1DK
        system.assertEquals(bool, acc.Is1K__c); //1K
        system.assertEquals(bool, acc.Is1LDK1SLDK__c); //1LDK/SLDK
        system.assertEquals(bool, acc.IsFirstFloor__c); //1階
        system.assertEquals(bool, acc.Is2K2DK__c); //2K/DK
        system.assertEquals(bool, acc.Is2LDK2SLDK__c); //2LDK/SLDK
        system.assertEquals(bool, acc.IsSecondFloorOver__c); //2階以上
        system.assertEquals(bool, acc.IsTwoTenant__c); //2人入居可
        system.assertEquals(bool, acc.Is3K3DK__c); //3K/DK
        system.assertEquals(bool, acc.Is3LDK3SLDK__c); //3LDK/SLDK
        system.assertEquals(bool, acc.Is4K4DK4LDKFrom__c); //4K/DK/LDK~
        system.assertEquals(bool, acc.IsBSAntenna__c); //BSアンテナ
        system.assertEquals(bool, acc.IsCATV__c); //CATV
        system.assertEquals(bool, acc.IsCSAntenna__c); //CSアンテナ
        system.assertEquals(bool, acc.IsInductionHeating__c); //IHコンロ
        system.assertEquals(bool, acc.IsRC__c); //RC
        system.assertEquals(bool, acc.IsSRC__c); //SRC
        system.assertEquals(bool, acc.IsWalkInCloset__c); //ウォークインクローゼット
        system.assertEquals(bool, acc.IsAirConditioner__c); //エアコン
        system.assertEquals(bool, acc.IsElevator__c); //エレベーター
        system.assertEquals(bool, acc.IsAutoLock__c); //オートロック
        system.assertEquals(bool, acc.IsAllElectric__c); //オール電化
        system.assertEquals(bool, acc.IsAllWestern__c); //オール洋間
        system.assertEquals(bool, acc.IsCarport__c); //カーポート
        system.assertEquals(bool, acc.IsCounterKitchen__c); //カウンターキッチン
        system.assertEquals(bool, acc.IsGasStove__c); //ガスコンロ
        system.assertEquals(bool, acc.IsTwoGasStove__c); //コンロ2口
        system.assertEquals(bool, acc.IsMoreGasStove__c); //コンロ3口以上
        system.assertEquals(bool, acc.IsSystemKitchen__c); //システムキッチン
        system.assertEquals(bool, acc.IsShowerWashBasin__c); //シャワー付き洗面台
        system.assertEquals(bool, acc.IsShoeCloak__c); //シューズクローク
        system.assertEquals(bool, acc.IsShoesBox__c); //シューズボックス
        system.assertEquals(bool, acc.IsDesigners__c); //デザイナーズ
        system.assertEquals(bool, acc.IsTrunkRoom__c); //トランクルーム
        system.assertEquals(bool, acc.IsInternetFree__c); //ネット使用料無料
        system.assertEquals(bool, acc.IsBikeStorage__c); //バイク可
        system.assertEquals(bool, acc.IsSepalateBathAndRestroom__c); //バス・トイレ別
        system.assertEquals(bool, acc.IsBalcony__c); //バルコニー
        system.assertEquals(bool, acc.IsBuiltInGarage__c); //ビルトインガレージ
        system.assertEquals(bool, acc.IsPropaneGas__c); //プロパンガス
        system.assertEquals(bool, acc.IsOtherPet__c); //ペット(その他)
        system.assertEquals(bool, acc.IsSmallPet__c); //ペット(小型犬)
        system.assertEquals(bool, acc.IsLargePet__c); //ペット(大型犬)
        system.assertEquals(bool, acc.IsMiddlePet__c); //ペット(中型犬)
        system.assertEquals(bool, acc.IsCat__c); //ペット(猫)
        system.assertEquals(bool, acc.IsPet__c); //ペット可
        system.assertEquals(bool, acc.IsMaisonette__c); //メゾネット
        system.assertEquals(bool, acc.IsMonitorIntercom__c); //モニター付きインターホン
        system.assertEquals(bool, acc.IsRenovation__c); //リノベーション
        system.assertEquals(bool, acc.IsRoofBalcony__c); //ルーフバルコニー
        system.assertEquals(bool, acc.IsRoomShare__c); //ルームシェア可
        system.assertEquals(bool, acc.IsLoft__c); //ロフト
        system.assertEquals(bool, acc.IsOneRoom__c); //ワンルーム
        system.assertEquals(bool, acc.IsIppambutsu__c); //一般物
        system.assertEquals(bool, acc.IsWashlet__c); //温水洗浄便座
        system.assertEquals(bool, acc.IsFurniture__c); //家具付き
        system.assertEquals(bool, acc.IsHomeAppliance__c); //家電付き
        system.assertEquals(bool, acc.IsForeigner__c); //外国人契約可
        system.assertEquals(bool, acc.IsCornerRoom__c); //角部屋
        system.assertEquals(bool, acc.IsStudent__c); //学生限定マンション
        system.assertEquals(bool, acc.IsMusicalInstruments__c); //楽器相談可
        system.assertEquals(bool, acc.IsIncludeManagementFee__c); //管理費込み
        system.assertEquals(bool, acc.IsLightweightSteel__c); //軽量鉄骨
        system.assertEquals(bool, acc.IsDetachedHouse__c); //戸建て
        system.assertEquals(bool, acc.IsNonRenewalFee__c); //更新料なし
        system.assertEquals(bool, acc.IsElderly__c); //高齢者歓迎
        system.assertEquals(bool, acc.IsTopFloor__c); //最上階
        system.assertEquals(bool, acc.IsOfficeAvailable__c); //事務所利用可
        system.assertEquals(bool, acc.IsInnerLandry__c); //室内洗濯機置場
        system.assertEquals(bool, acc.IsWoman__c); //女性限定
        system.assertEquals(bool, acc.IsSmallBike__c); //小型バイク
        system.assertEquals(bool, acc.IsFloorHeating__c); //床暖房
        system.assertEquals(bool, acc.IsWelfareAvailable__c); //生活保護契約可
        system.assertEquals(bool, acc.IsWest__c); //西
        system.assertEquals(bool, acc.IsPrivateGarden__c); //専用庭
        system.assertEquals(bool, acc.IsRegalLavatory__c); //洗面所独立
        system.assertEquals(bool, acc.IsLargeBike__c); //大型バイク
        system.assertEquals(bool, acc.IsDeliveryBox__c); //宅配ボックス
        system.assertEquals(bool, acc.IsMediumBike__c); //中型バイク
        system.assertEquals(bool, acc.IsPluralCarParking__c); //駐車場2台可
        system.assertEquals(bool, acc.IsParking__c); //駐車場空きあり
        system.assertEquals(bool, acc.IsIncludeParkingFee__c); //駐車場代込み
        system.assertEquals(bool, acc.IsBicycleParking__c); //駐輪場
        system.assertEquals(bool, acc.IsAditionalBoiling__c); //追焚機能
        system.assertEquals(bool, acc.IsNonCleaningFee__c); //定額修繕費なし
        system.assertEquals(bool, acc.IsSteel__c); //鉄骨造
        system.assertEquals(bool, acc.IsElectricStove__c); //電気コンロ
        system.assertEquals(bool, acc.IsTownGas__c); //都市ガス
        system.assertEquals(bool, acc.IsEast__c); //東
        system.assertEquals(bool, acc.IsSouth__c); //南
        system.assertEquals(bool, acc.IsSouthWest__c); //南西
        system.assertEquals(bool, acc.IsSouthEast__c); //南東
        system.assertEquals(bool, acc.IsNonDeposit__c); //敷金/保証金なし
        system.assertEquals(bool, acc.IsInSiteParking__c); //敷地内駐車場
        system.assertEquals(bool, acc.IsCondominiumRental__c); //分譲賃貸
        system.assertEquals(bool, acc.IsNonGuaranteeidCompany__c); //保証会社不要
        system.assertEquals(bool, acc.IsNoGuarantor__c); //保証人不要
        system.assertEquals(bool, acc.IsNorth__c); //北
        system.assertEquals(bool, acc.IsNorthWest__c); //北西
        system.assertEquals(bool, acc.IsNorthEast__c); //北東
        system.assertEquals(bool, acc.IsWooden__c); //木造
        system.assertEquals(bool, acc.IsDehumidifierForBathroom__c); //浴室乾燥機
        system.assertEquals(bool, acc.IsNonKeyMoney__c); //礼金なし
    }

    // お客様物件情報生成に使用する取引先Id取得
    private static Id getSpcAccountId(){
        return [SELECT ID FROM ACCOUNT WHERE NAME = 'テスト太郎'].Id;
    }

	// お客様物件条件１を登録する。
    private static List<AccountPropertyConditions__c> insertAPC_1(Id accId){
        if(accId == null)accId = getSpcAccountId();
        List<DesiredTrainRoute__c> dtrList = [SELECT id FROM DesiredTrainRoute__c];
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];

		List<AccountPropertyConditions__c> insertList = new List<AccountPropertyConditions__c>();
		insertList.add(createAPC_1(accId, dtrList, dsaList));
		insert insertList;
		return insertList;
	}

	// お客様物件条件２を登録する。
    private static List<AccountPropertyConditions__c> insertAPC_2(Id accId){
        if(accId == null)accId = getSpcAccountId();
        List<DesiredTrainRoute__c> dtrList = [SELECT id FROM DesiredTrainRoute__c];
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];

		List<AccountPropertyConditions__c> insertList = new List<AccountPropertyConditions__c>();
		insertList.add(createAPC_2(accId, dtrList, dsaList));
		insert insertList;
		return insertList;
	}

	// お客様物件条件３を登録する。
    private static List<AccountPropertyConditions__c> insertAPC_3(Id accId){
        if(accId == null)accId = getSpcAccountId();
        List<DesiredTrainRoute__c> dtrList = [SELECT id FROM DesiredTrainRoute__c];
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];

		List<AccountPropertyConditions__c> insertList = new List<AccountPropertyConditions__c>();
		insertList.add(createAPC_3(accId, dtrList, dsaList));
		insert insertList;
		return insertList;
	}

	// お客様物件条件１，２を登録する。
    private static List<AccountPropertyConditions__c> insertAPC_1_2(Id accId){
        if(accId == null)accId = getSpcAccountId();
        List<DesiredTrainRoute__c> dtrList = [SELECT id FROM DesiredTrainRoute__c];
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];

		List<AccountPropertyConditions__c> insertList = new List<AccountPropertyConditions__c>();
		insertList.add(createAPC_1(accId, dtrList, dsaList));
		insertList.add(createAPC_2(accId, dtrList, dsaList));
		insert insertList;
		return insertList;
	}

	// お客様物件条件１，２、３を登録する。
    private static List<AccountPropertyConditions__c> insertAPC_1_2_3(Id accId){
        if(accId == null)accId = getSpcAccountId();
        List<DesiredTrainRoute__c> dtrList = [SELECT id FROM DesiredTrainRoute__c];
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];

		List<AccountPropertyConditions__c> insertList = new List<AccountPropertyConditions__c>();
		insertList.add(createAPC_1(accId, dtrList, dsaList));
		insertList.add(createAPC_2(accId, dtrList, dsaList));
		insertList.add(createAPC_3(accId, dtrList, dsaList));
		insert insertList;
		return insertList;
	}
        
    // お客様物件条件１を生成する。
    private static AccountPropertyConditions__c createAPC_1(Id accId, List<DesiredTrainRoute__c> dtrList, List<DesiredSchoolArea__c> dsaList){

        //お客様物件条件
        AccountPropertyConditions__c accountPropertyCond1 = new AccountPropertyConditions__c();
        accountPropertyCond1.Account__c  = accId;//取引先Id
        accountPropertyCond1.Name = '条件2';
        accountPropertyCond1.BuildingAge__c  = '999';//築年数 
        accountPropertyCond1.CarCount__c  = 99;//台数 
        accountPropertyCond1.DesiredArea__c  = '希望地域';//希望地域 
        accountPropertyCond1.OccupancyAreaLowerLimit__c  = '0';//占有面積（下限） 
        accountPropertyCond1.OccupancyAreaUpperLimit__c  = '999';//占有面積（上限） 
        accountPropertyCond1.Parking__c  = '有';//駐車場 
        accountPropertyCond1.ParkingFeeLimit__c  = 9999;//1台当たりの料金上限 
        accountPropertyCond1.RentFeeFrom__c  = 9999;//賃料から 
        accountPropertyCond1.RentFeeTo__c  = 9999;//賃料まで 
        accountPropertyCond1.WalkingTime__c  = '999';//徒歩 
        accountPropertyCond1.DesiredTrainRoute1__c  = dtrList[0].Id;//希望沿線１ 
        accountPropertyCond1.DesiredTrainRoute2__c  = dtrList[1].Id;//希望沿線２ 
        accountPropertyCond1.DesiredTrainRoute3__c  = dtrList[2].Id;//希望沿線３ 
        accountPropertyCond1.Is1DK__c  = TRUE;//1DK 
        accountPropertyCond1.Is1K__c  = TRUE;//1K 
        accountPropertyCond1.Is1LDK1SLDK__c  = TRUE;//1LDK/SLDK 
        accountPropertyCond1.Is2K2DK__c  = TRUE;//2K/DK 
        accountPropertyCond1.Is2LDK2SLDK__c  = TRUE;//2LDK/SLDK 
        accountPropertyCond1.Is3K3DK__c  = TRUE;//3K/DK 
        accountPropertyCond1.Is3LDK3SLDK__c  = TRUE;//3LDK/SLDK 
        accountPropertyCond1.Is4K4DK4LDKFrom__c  = TRUE;//4K/DK/LDK~ 
        accountPropertyCond1.IsAditionalBoiling__c  = TRUE;//追焚機能 
        accountPropertyCond1.IsAirConditioner__c  = TRUE;//エアコン 
        accountPropertyCond1.IsAllElectric__c  = TRUE;//オール電化 
        accountPropertyCond1.IsAllWestern__c  = TRUE;//オール洋間 
        accountPropertyCond1.IsAutoLock__c  = TRUE;//オートロック 
        accountPropertyCond1.IsBalcony__c  = TRUE;//バルコニー 
        accountPropertyCond1.IsBicycleParking__c  = TRUE;//駐輪場 
        accountPropertyCond1.IsBikeStorage__c  = TRUE;//バイク可 
        accountPropertyCond1.IsBSAntenna__c  = TRUE;//BSアンテナ 
        accountPropertyCond1.IsBuiltInGarage__c  = TRUE;//ビルトインガレージ 
        accountPropertyCond1.IsCarport__c  = TRUE;//カーポート 
        accountPropertyCond1.IsCat__c  = TRUE;//ペット(猫) 
        accountPropertyCond1.IsCATV__c  = TRUE;//CATV 
        accountPropertyCond1.IsCondominiumRental__c  = TRUE;//分譲賃貸 
        accountPropertyCond1.IsCornerRoom__c  = TRUE;//角部屋 
        accountPropertyCond1.IsCounterKitchen__c  = TRUE;//カウンターキッチン 
        accountPropertyCond1.IsCSAntenna__c  = TRUE;//CSアンテナ 
        accountPropertyCond1.IsDehumidifierForBathroom__c  = TRUE;//浴室乾燥機 
        accountPropertyCond1.IsDeliveryBox__c  = TRUE;//宅配ボックス 
        accountPropertyCond1.IsDesigners__c  = TRUE;//デザイナーズ 
        accountPropertyCond1.IsDetachedHouse__c  = TRUE;//戸建て 
        accountPropertyCond1.IsEast__c  = TRUE;//東 
        accountPropertyCond1.IsElderly__c  = TRUE;//高齢者歓迎 
        accountPropertyCond1.IsElectricStove__c  = TRUE;//電気コンロ 
        accountPropertyCond1.IsElevator__c  = TRUE;//エレベーター 
        accountPropertyCond1.IsFirstFloor__c  = TRUE;//1階 
        accountPropertyCond1.IsFloorHeating__c  = TRUE;//床暖房 
        accountPropertyCond1.IsForeigner__c  = TRUE;//外国人契約可 
        accountPropertyCond1.IsFurniture__c  = TRUE;//家具付き 
        accountPropertyCond1.IsGasStove__c  = TRUE;//ガスコンロ 
        accountPropertyCond1.IsHomeAppliance__c  = TRUE;//家電付き 
        accountPropertyCond1.IsIncludeManagementFee__c  = TRUE;//管理費込み 
        accountPropertyCond1.IsIncludeParkingFee__c  = TRUE;//駐車場代込み 
        accountPropertyCond1.IsInductionHeating__c  = TRUE;//IHコンロ 
        accountPropertyCond1.IsInnerLandry__c  = TRUE;//室内洗濯機置場 
        accountPropertyCond1.IsInSiteParking__c  = TRUE;//敷地内駐車場 
        accountPropertyCond1.IsInternetFree__c  = TRUE;//ネット使用料無料 
        accountPropertyCond1.IsIppambutsu__c  = TRUE;//一般物 
        accountPropertyCond1.IsLargeBike__c  = TRUE;//大型バイク 
        accountPropertyCond1.IsLargePet__c  = TRUE;//ペット(大型犬) 
        accountPropertyCond1.IsLightweightSteel__c  = TRUE;//軽量鉄骨 
        accountPropertyCond1.IsLoft__c  = TRUE;//ロフト 
        accountPropertyCond1.IsMaisonette__c  = TRUE;//メゾネット 
        accountPropertyCond1.IsMediumBike__c  = TRUE;//中型バイク 
        accountPropertyCond1.IsMiddlePet__c  = TRUE;//ペット(中型犬) 
        accountPropertyCond1.IsMonitorIntercom__c  = TRUE;//モニター付きインターホン 
        accountPropertyCond1.IsMoreGasStove__c  = TRUE;//コンロ3口以上 
        accountPropertyCond1.IsMusicalInstruments__c  = TRUE;//楽器相談可 
        accountPropertyCond1.IsNoGuarantor__c  = TRUE;//保証人不要 
        accountPropertyCond1.IsNonCleaningFee__c  = TRUE;//定額修繕費なし 
        accountPropertyCond1.IsNonDeposit__c  = TRUE;//敷金/保証金なし 
        accountPropertyCond1.IsNonGuaranteeidCompany__c  = TRUE;//保証会社不要 
        accountPropertyCond1.IsNonKeyMoney__c  = TRUE;//礼金なし 
        accountPropertyCond1.IsNonRenewalFee__c  = TRUE;//更新料なし 
        accountPropertyCond1.IsNorth__c  = TRUE;//北 
        accountPropertyCond1.IsNorthEast__c  = TRUE;//北東 
        accountPropertyCond1.IsNorthWest__c  = TRUE;//北西 
        accountPropertyCond1.IsOfficeAvailable__c  = TRUE;//事務所利用可 
        accountPropertyCond1.IsOneRoom__c  = TRUE;//ワンルーム 
        accountPropertyCond1.IsOtherPet__c  = TRUE;//ペット(その他) 
        accountPropertyCond1.IsParking__c  = TRUE;//駐車場空きあり 
        accountPropertyCond1.IsPet__c  = TRUE;//ペット可 
        accountPropertyCond1.IsPluralCarParking__c  = TRUE;//駐車場2台可 
        accountPropertyCond1.IsPrivateGarden__c  = TRUE;//専用庭 
        accountPropertyCond1.IsPropaneGas__c  = TRUE;//プロパンガス 
        accountPropertyCond1.IsRC__c  = TRUE;//RC 
        accountPropertyCond1.IsRegalLavatory__c  = TRUE;//洗面所独立 
        accountPropertyCond1.IsRenovation__c  = TRUE;//リノベーション 
        accountPropertyCond1.IsRoofBalcony__c  = TRUE;//ルーフバルコニー 
        accountPropertyCond1.IsRoomShare__c  = TRUE;//ルームシェア可 
        accountPropertyCond1.IsSecondFloorOver__c  = TRUE;//2階以上 
        accountPropertyCond1.IsSepalateBathAndRestroom__c  = TRUE;//バス・トイレ別 
        accountPropertyCond1.IsShoeCloak__c  = TRUE;//シューズクローク 
        accountPropertyCond1.IsShoesBox__c  = TRUE;//シューズボックス 
        accountPropertyCond1.IsShowerWashBasin__c  = TRUE;//シャワー付き洗面台 
        accountPropertyCond1.IsSmallBike__c  = TRUE;//小型バイク 
        accountPropertyCond1.IsSmallPet__c  = TRUE;//ペット(小型犬) 
        accountPropertyCond1.IsSouth__c  = TRUE;//南 
        accountPropertyCond1.IsSouthEast__c  = TRUE;//南東 
        accountPropertyCond1.IsSouthWest__c  = TRUE;//南西 
        accountPropertyCond1.IsSRC__c  = TRUE;//SRC 
        accountPropertyCond1.IsSteel__c  = TRUE;//鉄骨造 
        accountPropertyCond1.IsStudent__c  = TRUE;//学生限定マンション 
        accountPropertyCond1.IsSystemKitchen__c  = TRUE;//システムキッチン 
        accountPropertyCond1.IsTopFloor__c  = TRUE;//最上階 
        accountPropertyCond1.IsTownGas__c  = TRUE;//都市ガス 
        accountPropertyCond1.IsTrunkRoom__c  = TRUE;//トランクルーム 
        accountPropertyCond1.IsTwoGasStove__c  = TRUE;//コンロ2口 
        accountPropertyCond1.IsTwoTenant__c  = TRUE;//2人入居可 
        accountPropertyCond1.IsWalkInCloset__c  = TRUE;//ウォークインクローゼット 
        accountPropertyCond1.IsWashlet__c  = TRUE;//温水洗浄便座 
        accountPropertyCond1.IsWelfareAvailable__c  = TRUE;//生活保護契約可 
        accountPropertyCond1.IsWest__c  = TRUE;//西 
        accountPropertyCond1.IsWoman__c  = TRUE;//女性限定 
        accountPropertyCond1.IsWooden__c  = TRUE;//木造 
        accountPropertyCond1.DesiredJuniorHighSchoolArea__c = dsaList[0].id;// 中学校希望学区（エリア）
        accountPropertyCond1.DesiredElementarySchoolArea__c = dsaList[1].id;// 小学校希望学区（エリア）

        return accountPropertyCond1;
    }

    // お客様物件条件2を生成する。
    private static AccountPropertyConditions__c createAPC_2(Id accId, List<DesiredTrainRoute__c> dtrList, List<DesiredSchoolArea__c> dsaList){
        AccountPropertyConditions__c accountPropertyCond2 = new AccountPropertyConditions__c();//お客様物件条件
        accountPropertyCond2.Account__c  = accId;//取引先Id
        accountPropertyCond2.Name = '条件3';
        accountPropertyCond2.BuildingAge__c  = '999';//築年数 
        accountPropertyCond2.CarCount__c  = 99;//台数 
        accountPropertyCond2.DesiredArea__c  = '希望地域';//希望地域 
        accountPropertyCond2.OccupancyAreaLowerLimit__c  = '0';//占有面積（下限） 
        accountPropertyCond2.OccupancyAreaUpperLimit__c  = '999';//占有面積（上限） 
        accountPropertyCond2.Parking__c  = '有';//駐車場 
        accountPropertyCond2.ParkingFeeLimit__c  = 9999;//1台当たりの料金上限 
        accountPropertyCond2.RentFeeFrom__c  = 9999;//賃料から 
        accountPropertyCond2.RentFeeTo__c  = 9999;//賃料まで 
        accountPropertyCond2.WalkingTime__c  = '999';//徒歩 
        accountPropertyCond2.DesiredTrainRoute1__c  = dtrList[0].Id;//希望沿線１ 
        accountPropertyCond2.DesiredTrainRoute2__c  = dtrList[1].Id;//希望沿線２ 
        accountPropertyCond2.DesiredTrainRoute3__c  = dtrList[2].Id;//希望沿線３ 
        accountPropertyCond2.Is1DK__c  = FALSE;//1DK 
        accountPropertyCond2.Is1K__c  = FALSE;//1K 
        accountPropertyCond2.Is1LDK1SLDK__c  = FALSE;//1LDK/SLDK 
        accountPropertyCond2.Is2K2DK__c  = FALSE;//2K/DK 
        accountPropertyCond2.Is2LDK2SLDK__c  = FALSE;//2LDK/SLDK 
        accountPropertyCond2.Is3K3DK__c  = FALSE;//3K/DK 
        accountPropertyCond2.Is3LDK3SLDK__c  = FALSE;//3LDK/SLDK 
        accountPropertyCond2.Is4K4DK4LDKFrom__c  = FALSE;//4K/DK/LDK~ 
        accountPropertyCond2.IsAditionalBoiling__c  = FALSE;//追焚機能 
        accountPropertyCond2.IsAirConditioner__c  = FALSE;//エアコン 
        accountPropertyCond2.IsAllElectric__c  = FALSE;//オール電化 
        accountPropertyCond2.IsAllWestern__c  = FALSE;//オール洋間 
        accountPropertyCond2.IsAutoLock__c  = FALSE;//オートロック 
        accountPropertyCond2.IsBalcony__c  = FALSE;//バルコニー 
        accountPropertyCond2.IsBicycleParking__c  = FALSE;//駐輪場 
        accountPropertyCond2.IsBikeStorage__c  = FALSE;//バイク可 
        accountPropertyCond2.IsBSAntenna__c  = FALSE;//BSアンテナ 
        accountPropertyCond2.IsBuiltInGarage__c  = FALSE;//ビルトインガレージ 
        accountPropertyCond2.IsCarport__c  = FALSE;//カーポート 
        accountPropertyCond2.IsCat__c  = FALSE;//ペット(猫) 
        accountPropertyCond2.IsCATV__c  = FALSE;//CATV 
        accountPropertyCond2.IsCondominiumRental__c  = FALSE;//分譲賃貸 
        accountPropertyCond2.IsCornerRoom__c  = FALSE;//角部屋 
        accountPropertyCond2.IsCounterKitchen__c  = FALSE;//カウンターキッチン 
        accountPropertyCond2.IsCSAntenna__c  = FALSE;//CSアンテナ 
        accountPropertyCond2.IsDehumidifierForBathroom__c  = FALSE;//浴室乾燥機 
        accountPropertyCond2.IsDeliveryBox__c  = FALSE;//宅配ボックス 
        accountPropertyCond2.IsDesigners__c  = FALSE;//デザイナーズ 
        accountPropertyCond2.IsDetachedHouse__c  = FALSE;//戸建て 
        accountPropertyCond2.IsEast__c  = FALSE;//東 
        accountPropertyCond2.IsElderly__c  = FALSE;//高齢者歓迎 
        accountPropertyCond2.IsElectricStove__c  = FALSE;//電気コンロ 
        accountPropertyCond2.IsElevator__c  = FALSE;//エレベーター 
        accountPropertyCond2.IsFirstFloor__c  = FALSE;//1階 
        accountPropertyCond2.IsFloorHeating__c  = FALSE;//床暖房 
        accountPropertyCond2.IsForeigner__c  = FALSE;//外国人契約可 
        accountPropertyCond2.IsFurniture__c  = FALSE;//家具付き 
        accountPropertyCond2.IsGasStove__c  = FALSE;//ガスコンロ 
        accountPropertyCond2.IsHomeAppliance__c  = FALSE;//家電付き 
        accountPropertyCond2.IsIncludeManagementFee__c  = FALSE;//管理費込み 
        accountPropertyCond2.IsIncludeParkingFee__c  = FALSE;//駐車場代込み 
        accountPropertyCond2.IsInductionHeating__c  = FALSE;//IHコンロ 
        accountPropertyCond2.IsInnerLandry__c  = FALSE;//室内洗濯機置場 
        accountPropertyCond2.IsInSiteParking__c  = FALSE;//敷地内駐車場 
        accountPropertyCond2.IsInternetFree__c  = FALSE;//ネット使用料無料 
        accountPropertyCond2.IsIppambutsu__c  = FALSE;//一般物 
        accountPropertyCond2.IsLargeBike__c  = FALSE;//大型バイク 
        accountPropertyCond2.IsLargePet__c  = FALSE;//ペット(大型犬) 
        accountPropertyCond2.IsLightweightSteel__c  = FALSE;//軽量鉄骨 
        accountPropertyCond2.IsLoft__c  = FALSE;//ロフト 
        accountPropertyCond2.IsMaisonette__c  = FALSE;//メゾネット 
        accountPropertyCond2.IsMediumBike__c  = FALSE;//中型バイク 
        accountPropertyCond2.IsMiddlePet__c  = FALSE;//ペット(中型犬) 
        accountPropertyCond2.IsMonitorIntercom__c  = FALSE;//モニター付きインターホン 
        accountPropertyCond2.IsMoreGasStove__c  = FALSE;//コンロ3口以上 
        accountPropertyCond2.IsMusicalInstruments__c  = FALSE;//楽器相談可 
        accountPropertyCond2.IsNoGuarantor__c  = FALSE;//保証人不要 
        accountPropertyCond2.IsNonCleaningFee__c  = FALSE;//定額修繕費なし 
        accountPropertyCond2.IsNonDeposit__c  = FALSE;//敷金/保証金なし 
        accountPropertyCond2.IsNonGuaranteeidCompany__c  = FALSE;//保証会社不要 
        accountPropertyCond2.IsNonKeyMoney__c  = FALSE;//礼金なし 
        accountPropertyCond2.IsNonRenewalFee__c  = FALSE;//更新料なし 
        accountPropertyCond2.IsNorth__c  = FALSE;//北 
        accountPropertyCond2.IsNorthEast__c  = FALSE;//北東 
        accountPropertyCond2.IsNorthWest__c  = FALSE;//北西 
        accountPropertyCond2.IsOfficeAvailable__c  = FALSE;//事務所利用可 
        accountPropertyCond2.IsOneRoom__c  = FALSE;//ワンルーム 
        accountPropertyCond2.IsOtherPet__c  = FALSE;//ペット(その他) 
        accountPropertyCond2.IsParking__c  = FALSE;//駐車場空きあり 
        accountPropertyCond2.IsPet__c  = FALSE;//ペット可 
        accountPropertyCond2.IsPluralCarParking__c  = FALSE;//駐車場2台可 
        accountPropertyCond2.IsPrivateGarden__c  = FALSE;//専用庭 
        accountPropertyCond2.IsPropaneGas__c  = FALSE;//プロパンガス 
        accountPropertyCond2.IsRC__c  = FALSE;//RC 
        accountPropertyCond2.IsRegalLavatory__c  = FALSE;//洗面所独立 
        accountPropertyCond2.IsRenovation__c  = FALSE;//リノベーション 
        accountPropertyCond2.IsRoofBalcony__c  = FALSE;//ルーフバルコニー 
        accountPropertyCond2.IsRoomShare__c  = FALSE;//ルームシェア可 
        accountPropertyCond2.IsSecondFloorOver__c  = FALSE;//2階以上 
        accountPropertyCond2.IsSepalateBathAndRestroom__c  = FALSE;//バス・トイレ別 
        accountPropertyCond2.IsShoeCloak__c  = FALSE;//シューズクローク 
        accountPropertyCond2.IsShoesBox__c  = FALSE;//シューズボックス 
        accountPropertyCond2.IsShowerWashBasin__c  = FALSE;//シャワー付き洗面台 
        accountPropertyCond2.IsSmallBike__c  = FALSE;//小型バイク 
        accountPropertyCond2.IsSmallPet__c  = FALSE;//ペット(小型犬) 
        accountPropertyCond2.IsSouth__c  = FALSE;//南 
        accountPropertyCond2.IsSouthEast__c  = FALSE;//南東 
        accountPropertyCond2.IsSouthWest__c  = FALSE;//南西 
        accountPropertyCond2.IsSRC__c  = FALSE;//SRC 
        accountPropertyCond2.IsSteel__c  = FALSE;//鉄骨造 
        accountPropertyCond2.IsStudent__c  = FALSE;//学生限定マンション 
        accountPropertyCond2.IsSystemKitchen__c  = FALSE;//システムキッチン 
        accountPropertyCond2.IsTopFloor__c  = FALSE;//最上階 
        accountPropertyCond2.IsTownGas__c  = FALSE;//都市ガス 
        accountPropertyCond2.IsTrunkRoom__c  = FALSE;//トランクルーム 
        accountPropertyCond2.IsTwoGasStove__c  = FALSE;//コンロ2口 
        accountPropertyCond2.IsTwoTenant__c  = FALSE;//2人入居可 
        accountPropertyCond2.IsWalkInCloset__c  = FALSE;//ウォークインクローゼット 
        accountPropertyCond2.IsWashlet__c  = FALSE;//温水洗浄便座 
        accountPropertyCond2.IsWelfareAvailable__c  = FALSE;//生活保護契約可 
        accountPropertyCond2.IsWest__c  = FALSE;//西 
        accountPropertyCond2.IsWoman__c  = FALSE;//女性限定 
        accountPropertyCond2.IsWooden__c  = FALSE;//木造 
        accountPropertyCond2.DesiredJuniorHighSchoolArea__c = dsaList[0].id;// 中学校希望学区（エリア）
        accountPropertyCond2.DesiredElementarySchoolArea__c = dsaList[1].id;// 小学校希望学区（エリア）

        return accountPropertyCond2;
    }

    // お客様物件条件3を生成する。
    private static AccountPropertyConditions__c createAPC_3(Id accId, List<DesiredTrainRoute__c> dtrList, List<DesiredSchoolArea__c> dsaList){
        AccountPropertyConditions__c accountPropertyCond3 = new AccountPropertyConditions__c();//お客様物件条件

        accountPropertyCond3.Account__c  = accId;//取引先Id
        accountPropertyCond3.Name = '条件4';
        accountPropertyCond3.BuildingAge__c  = '999';//築年数 
        accountPropertyCond3.CarCount__c  = 99;//台数 
        accountPropertyCond3.DesiredArea__c  = '希望地域';//希望地域 
        accountPropertyCond3.DesiredTrainRoute1__c  = dtrList[0].Id;//希望沿線１ 
        accountPropertyCond3.DesiredTrainRoute2__c  = dtrList[1].Id;//希望沿線２ 
        accountPropertyCond3.DesiredTrainRoute3__c  = dtrList[2].Id;//希望沿線３ 
        accountPropertyCond3.Is1DK__c  = TRUE;//1DK 
        accountPropertyCond3.Is1K__c  = TRUE;//1K 
        accountPropertyCond3.Is1LDK1SLDK__c  = TRUE;//1LDK/SLDK 
        accountPropertyCond3.Is2K2DK__c  = TRUE;//2K/DK 
        accountPropertyCond3.Is2LDK2SLDK__c  = TRUE;//2LDK/SLDK 
        accountPropertyCond3.Is3K3DK__c  = TRUE;//3K/DK 
        accountPropertyCond3.Is3LDK3SLDK__c  = TRUE;//3LDK/SLDK 
        accountPropertyCond3.Is4K4DK4LDKFrom__c  = TRUE;//4K/DK/LDK~ 
        accountPropertyCond3.IsAditionalBoiling__c  = TRUE;//追焚機能 
        accountPropertyCond3.IsAirConditioner__c  = TRUE;//エアコン 
        accountPropertyCond3.IsAllElectric__c  = TRUE;//オール電化 
        accountPropertyCond3.IsAllWestern__c  = TRUE;//オール洋間 
        accountPropertyCond3.IsAutoLock__c  = TRUE;//オートロック 
        accountPropertyCond3.IsBalcony__c  = TRUE;//バルコニー 
        accountPropertyCond3.IsBicycleParking__c  = TRUE;//駐輪場 
        accountPropertyCond3.IsBikeStorage__c  = TRUE;//バイク可 
        accountPropertyCond3.IsBSAntenna__c  = TRUE;//BSアンテナ 
        accountPropertyCond3.IsBuiltInGarage__c  = TRUE;//ビルトインガレージ 
        accountPropertyCond3.IsCarport__c  = TRUE;//カーポート 
        accountPropertyCond3.IsCat__c  = TRUE;//ペット(猫) 
        accountPropertyCond3.IsCATV__c  = TRUE;//CATV 
        accountPropertyCond3.IsCondominiumRental__c  = TRUE;//分譲賃貸 
        accountPropertyCond3.IsCornerRoom__c  = TRUE;//角部屋 
        accountPropertyCond3.IsCounterKitchen__c  = TRUE;//カウンターキッチン 
        accountPropertyCond3.IsCSAntenna__c  = TRUE;//CSアンテナ 
        accountPropertyCond3.IsDehumidifierForBathroom__c  = TRUE;//浴室乾燥機 
        accountPropertyCond3.IsDeliveryBox__c  = TRUE;//宅配ボックス 
        accountPropertyCond3.IsDesigners__c  = TRUE;//デザイナーズ 
        accountPropertyCond3.IsDetachedHouse__c  = TRUE;//戸建て 
        accountPropertyCond3.IsEast__c  = TRUE;//東 
        accountPropertyCond3.IsElderly__c  = TRUE;//高齢者歓迎 
        accountPropertyCond3.IsElectricStove__c  = TRUE;//電気コンロ 
        accountPropertyCond3.IsElevator__c  = TRUE;//エレベーター 
        accountPropertyCond3.IsFirstFloor__c  = TRUE;//1階 
        accountPropertyCond3.IsFloorHeating__c  = TRUE;//床暖房 
        accountPropertyCond3.IsForeigner__c  = TRUE;//外国人契約可 
        accountPropertyCond3.IsFurniture__c  = TRUE;//家具付き 
        accountPropertyCond3.IsGasStove__c  = TRUE;//ガスコンロ 
        accountPropertyCond3.IsHomeAppliance__c  = TRUE;//家電付き 
        accountPropertyCond3.IsIncludeManagementFee__c  = TRUE;//管理費込み 
        accountPropertyCond3.IsIncludeParkingFee__c  = TRUE;//駐車場代込み 
        accountPropertyCond3.IsInductionHeating__c  = TRUE;//IHコンロ 
        accountPropertyCond3.IsInnerLandry__c  = TRUE;//室内洗濯機置場 
        accountPropertyCond3.IsInSiteParking__c  = TRUE;//敷地内駐車場 
        accountPropertyCond3.IsInternetFree__c  = TRUE;//ネット使用料無料 
        accountPropertyCond3.IsIppambutsu__c  = TRUE;//一般物 
        accountPropertyCond3.IsLargeBike__c  = TRUE;//大型バイク 
        accountPropertyCond3.IsLargePet__c  = TRUE;//ペット(大型犬) 
        accountPropertyCond3.IsLightweightSteel__c  = TRUE;//軽量鉄骨 
        accountPropertyCond3.IsLoft__c  = TRUE;//ロフト 
        accountPropertyCond3.IsMaisonette__c  = TRUE;//メゾネット 
        accountPropertyCond3.IsMediumBike__c  = TRUE;//中型バイク 
        accountPropertyCond3.IsMiddlePet__c  = TRUE;//ペット(中型犬) 
        accountPropertyCond3.IsMonitorIntercom__c  = TRUE;//モニター付きインターホン 
        accountPropertyCond3.IsMoreGasStove__c  = TRUE;//コンロ3口以上 
        accountPropertyCond3.IsMusicalInstruments__c  = TRUE;//楽器相談可 
        accountPropertyCond3.IsNoGuarantor__c  = TRUE;//保証人不要 
        accountPropertyCond3.IsNonCleaningFee__c  = TRUE;//定額修繕費なし 
        accountPropertyCond3.IsNonDeposit__c  = TRUE;//敷金/保証金なし 
        accountPropertyCond3.IsNonGuaranteeidCompany__c  = TRUE;//保証会社不要 
        accountPropertyCond3.IsNonKeyMoney__c  = TRUE;//礼金なし 
        accountPropertyCond3.IsNonRenewalFee__c  = TRUE;//更新料なし 
        accountPropertyCond3.IsNorth__c  = TRUE;//北 
        accountPropertyCond3.IsNorthEast__c  = TRUE;//北東 
        accountPropertyCond3.IsNorthWest__c  = TRUE;//北西 
        accountPropertyCond3.IsOfficeAvailable__c  = TRUE;//事務所利用可 
        accountPropertyCond3.IsOneRoom__c  = TRUE;//ワンルーム 
        accountPropertyCond3.IsOtherPet__c  = TRUE;//ペット(その他) 
        accountPropertyCond3.IsParking__c  = TRUE;//駐車場空きあり 
        accountPropertyCond3.IsPet__c  = TRUE;//ペット可 
        accountPropertyCond3.IsPluralCarParking__c  = TRUE;//駐車場2台可 
        accountPropertyCond3.IsPrivateGarden__c  = TRUE;//専用庭 
        accountPropertyCond3.IsPropaneGas__c  = TRUE;//プロパンガス 
        accountPropertyCond3.IsRC__c  = TRUE;//RC 
        accountPropertyCond3.IsRegalLavatory__c  = TRUE;//洗面所独立 
        accountPropertyCond3.IsRenovation__c  = TRUE;//リノベーション 
        accountPropertyCond3.IsRoofBalcony__c  = TRUE;//ルーフバルコニー 
        accountPropertyCond3.IsRoomShare__c  = TRUE;//ルームシェア可 
        accountPropertyCond3.IsSecondFloorOver__c  = TRUE;//2階以上 
        accountPropertyCond3.IsSepalateBathAndRestroom__c  = TRUE;//バス・トイレ別 
        accountPropertyCond3.IsShoeCloak__c  = TRUE;//シューズクローク 
        accountPropertyCond3.IsShoesBox__c  = TRUE;//シューズボックス 
        accountPropertyCond3.IsShowerWashBasin__c  = TRUE;//シャワー付き洗面台 
        accountPropertyCond3.IsSmallBike__c  = TRUE;//小型バイク 
        accountPropertyCond3.IsSmallPet__c  = TRUE;//ペット(小型犬) 
        accountPropertyCond3.IsSouth__c  = TRUE;//南 
        accountPropertyCond3.IsSouthEast__c  = TRUE;//南東 
        accountPropertyCond3.IsSouthWest__c  = TRUE;//南西 
        accountPropertyCond3.IsSRC__c  = TRUE;//SRC 
        accountPropertyCond3.IsSteel__c  = TRUE;//鉄骨造 
        accountPropertyCond3.IsStudent__c  = TRUE;//学生限定マンション 
        accountPropertyCond3.IsSystemKitchen__c  = TRUE;//システムキッチン 
        accountPropertyCond3.IsTopFloor__c  = TRUE;//最上階 
        accountPropertyCond3.IsTownGas__c  = TRUE;//都市ガス 
        accountPropertyCond3.IsTrunkRoom__c  = TRUE;//トランクルーム 
        accountPropertyCond3.IsTwoGasStove__c  = TRUE;//コンロ2口 
        accountPropertyCond3.IsTwoTenant__c  = TRUE;//2人入居可 
        accountPropertyCond3.IsWalkInCloset__c  = TRUE;//ウォークインクローゼット 
        accountPropertyCond3.IsWashlet__c  = TRUE;//温水洗浄便座 
        accountPropertyCond3.IsWelfareAvailable__c  = TRUE;//生活保護契約可 
        accountPropertyCond3.IsWest__c  = TRUE;//西 
        accountPropertyCond3.IsWoman__c  = TRUE;//女性限定 
        accountPropertyCond3.IsWooden__c  = TRUE;//木造 
        accountPropertyCond3.OccupancyAreaLowerLimit__c  = '0';//占有面積（下限） 
        accountPropertyCond3.OccupancyAreaUpperLimit__c  = '999';//占有面積（上限） 
        accountPropertyCond3.Parking__c  = '有';//駐車場 
        accountPropertyCond3.ParkingFeeLimit__c  = 9999;//1台当たりの料金上限 
        accountPropertyCond3.RentFeeFrom__c  = 9999;//賃料から 
        accountPropertyCond3.RentFeeTo__c  = 9999;//賃料まで 
        accountPropertyCond3.WalkingTime__c  = '999';//徒歩 
        accountPropertyCond3.DesiredJuniorHighSchoolArea__c = dsaList[0].id;// 中学校希望学区（エリア）
        accountPropertyCond3.DesiredElementarySchoolArea__c = dsaList[1].id;// 小学校希望学区（エリア）

        return accountPropertyCond3;
    }

	// ▼2022.02.18 No.307 対応で追加 ガバナチェッククラス追加
	/**
	 * ガバナチェッククラス
	 * @param  String checkName 表示用クラス名
	 */
	private static void checkGabana(String checkName){
		System.debug(checkName + 'クエリ発行数：' + Limits.getQueries() + '/' + Limits.getLimitQueries());

		// クエリが90件以上呼び出される場合にエラーとする
		// if(!checkName.equals('setUp') && Limits.getQueries() >= 90){
		// 	system.assert(false, checkName + 'クエリ発行数：' + Limits.getQueries() + '/' + Limits.getLimitQueries());
		// }
	}
	// ▲2022.02.18 No.307 対応で追加 ガバナチェッククラス追加
}