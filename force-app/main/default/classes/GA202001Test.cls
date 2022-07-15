/* *
* 来店カードのテスト
 */
@isTest 
private class GA202001Test {

    /**
    * テストに使用するレコードを作成する
    */
    @TestSetup static void setting(){

        system.debug('初期設定開始');

        

        Account AccountRecord = new Account();//登録に使用する取引先を設定

        AccountRecord.Name = 'テスト太郎' ;//取引先名
        AccountRecord.NameKana__c = 'ﾃｽﾄﾀﾛｳ' ; //取引先名（カナ）
        AccountRecord.Phone = '025-200-1234' ;//電話番号
        AccountRecord.Email__c = 'aaa@hora'; // メール
        AccountRecord.RecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER);//顧客;//レコードタイプID（顧客）
        AccountRecord.Comment__c = 'コメント';//コメント
        AccountRecord.IsMergeUnnecessaryFlag__c = true;//名寄せ不要フラグ(ON)

        // ▼2021.10.08 No.307 対応で追加
        AccountRecord.BuildingAge__c  = '999';//築年数 
        AccountRecord.CarCount__c  = 99;//台数 
        AccountRecord.DesiredArea__c  = '希望地域';//希望地域 
        AccountRecord.Is1DK__c  = TRUE;//1DK 
        AccountRecord.Is1K__c  = TRUE;//1K 
        AccountRecord.Is1LDK1SLDK__c  = TRUE;//1LDK/SLDK 
        AccountRecord.Is2K2DK__c  = TRUE;//2K/DK 
        AccountRecord.Is2LDK2SLDK__c  = TRUE;//2LDK/SLDK 
        AccountRecord.Is3K3DK__c  = TRUE;//3K/DK 
        AccountRecord.Is3LDK3SLDK__c  = TRUE;//3LDK/SLDK 
        AccountRecord.Is4K4DK4LDKFrom__c  = TRUE;//4K/DK/LDK~ 
        AccountRecord.IsAditionalBoiling__c  = TRUE;//追焚機能 
        AccountRecord.IsAirConditioner__c  = TRUE;//エアコン 
        AccountRecord.IsAllElectric__c  = TRUE;//オール電化 
        AccountRecord.IsAllWestern__c  = TRUE;//オール洋間 
        AccountRecord.IsAutoLock__c  = TRUE;//オートロック 
        AccountRecord.IsBalcony__c  = TRUE;//バルコニー 
        AccountRecord.IsBicycleParking__c  = TRUE;//駐輪場 
        AccountRecord.IsBikeStorage__c  = TRUE;//バイク可 
        AccountRecord.IsBSAntenna__c  = TRUE;//BSアンテナ 
        AccountRecord.IsBuiltInGarage__c  = TRUE;//ビルトインガレージ 
        AccountRecord.IsCarport__c  = TRUE;//カーポート 
        AccountRecord.IsCat__c  = TRUE;//ペット(猫) 
        AccountRecord.IsCATV__c  = TRUE;//CATV 
        AccountRecord.IsCondominiumRental__c  = TRUE;//分譲賃貸 
        AccountRecord.IsCornerRoom__c  = TRUE;//角部屋 
        AccountRecord.IsCounterKitchen__c  = TRUE;//カウンターキッチン 
        AccountRecord.IsCSAntenna__c  = TRUE;//CSアンテナ 
        AccountRecord.IsDehumidifierForBathroom__c  = TRUE;//浴室乾燥機 
        AccountRecord.IsDeliveryBox__c  = TRUE;//宅配ボックス 
        AccountRecord.IsDesigners__c  = TRUE;//デザイナーズ 
        AccountRecord.IsDetachedHouse__c  = TRUE;//戸建て 
        AccountRecord.IsEast__c  = TRUE;//東 
        AccountRecord.IsElderly__c  = TRUE;//高齢者歓迎 
        AccountRecord.IsElectricStove__c  = TRUE;//電気コンロ 
        AccountRecord.IsElevator__c  = TRUE;//エレベーター 
        AccountRecord.IsFirstFloor__c  = TRUE;//1階 
        AccountRecord.IsFloorHeating__c  = TRUE;//床暖房 
        AccountRecord.IsForeigner__c  = TRUE;//外国人契約可 
        AccountRecord.IsFurniture__c  = TRUE;//家具付き 
        AccountRecord.IsGasStove__c  = TRUE;//ガスコンロ 
        AccountRecord.IsHomeAppliance__c  = TRUE;//家電付き 
        AccountRecord.IsIncludeManagementFee__c  = TRUE;//管理費込み 
        AccountRecord.IsIncludeParkingFee__c  = TRUE;//駐車場代込み 
        AccountRecord.IsInductionHeating__c  = TRUE;//IHコンロ 
        AccountRecord.IsInnerLandry__c  = TRUE;//室内洗濯機置場 
        AccountRecord.IsInSiteParking__c  = TRUE;//敷地内駐車場 
        AccountRecord.IsInternetFree__c  = TRUE;//ネット使用料無料 
        AccountRecord.IsIppambutsu__c  = TRUE;//一般物 
        AccountRecord.IsLargeBike__c  = TRUE;//大型バイク 
        AccountRecord.IsLargePet__c  = TRUE;//ペット(大型犬) 
        AccountRecord.IsLightweightSteel__c  = TRUE;//軽量鉄骨 
        AccountRecord.IsLoft__c  = TRUE;//ロフト 
        AccountRecord.IsMaisonette__c  = TRUE;//メゾネット 
        AccountRecord.IsMediumBike__c  = TRUE;//中型バイク 
        AccountRecord.IsMiddlePet__c  = TRUE;//ペット(中型犬) 
        AccountRecord.IsMonitorIntercom__c  = TRUE;//モニター付きインターホン 
        AccountRecord.IsMoreGasStove__c  = TRUE;//コンロ3口以上 
        AccountRecord.IsMusicalInstruments__c  = TRUE;//楽器相談可 
        AccountRecord.IsNoGuarantor__c  = TRUE;//保証人不要 
        AccountRecord.IsNonCleaningFee__c  = TRUE;//定額修繕費なし 
        AccountRecord.IsNonDeposit__c  = TRUE;//敷金/保証金なし 
        AccountRecord.IsNonGuaranteeidCompany__c  = TRUE;//保証会社不要 
        AccountRecord.IsNonKeyMoney__c  = TRUE;//礼金なし 
        AccountRecord.IsNonRenewalFee__c  = TRUE;//更新料なし 
        AccountRecord.IsNorth__c  = TRUE;//北 
        AccountRecord.IsNorthEast__c  = TRUE;//北東 
        AccountRecord.IsNorthWest__c  = TRUE;//北西 
        AccountRecord.IsOfficeAvailable__c  = TRUE;//事務所利用可 
        AccountRecord.IsOneRoom__c  = TRUE;//ワンルーム 
        AccountRecord.IsOtherPet__c  = TRUE;//ペット(その他) 
        AccountRecord.IsParking__c  = TRUE;//駐車場空きあり 
        AccountRecord.IsPet__c  = TRUE;//ペット可 
        AccountRecord.IsPluralCarParking__c  = TRUE;//駐車場2台可 
        AccountRecord.IsPrivateGarden__c  = TRUE;//専用庭 
        AccountRecord.IsPropaneGas__c  = TRUE;//プロパンガス 
        AccountRecord.IsRC__c  = TRUE;//RC 
        AccountRecord.IsRegalLavatory__c  = TRUE;//洗面所独立 
        AccountRecord.IsRenovation__c  = TRUE;//リノベーション 
        AccountRecord.IsRoofBalcony__c  = TRUE;//ルーフバルコニー 
        AccountRecord.IsRoomShare__c  = TRUE;//ルームシェア可 
        AccountRecord.IsSecondFloorOver__c  = TRUE;//2階以上 
        AccountRecord.IsSepalateBathAndRestroom__c  = TRUE;//バス・トイレ別 
        AccountRecord.IsShoeCloak__c  = TRUE;//シューズクローク 
        AccountRecord.IsShoesBox__c  = TRUE;//シューズボックス 
        AccountRecord.IsShowerWashBasin__c  = TRUE;//シャワー付き洗面台 
        AccountRecord.IsSmallBike__c  = TRUE;//小型バイク 
        AccountRecord.IsSmallPet__c  = TRUE;//ペット(小型犬) 
        AccountRecord.IsSouth__c  = TRUE;//南 
        AccountRecord.IsSouthEast__c  = TRUE;//南東 
        AccountRecord.IsSouthWest__c  = TRUE;//南西 
        AccountRecord.IsSRC__c  = TRUE;//SRC 
        AccountRecord.IsSteel__c  = TRUE;//鉄骨造 
        AccountRecord.IsStudent__c  = TRUE;//学生限定マンション 
        AccountRecord.IsSystemKitchen__c  = TRUE;//システムキッチン 
        AccountRecord.IsTopFloor__c  = TRUE;//最上階 
        AccountRecord.IsTownGas__c  = TRUE;//都市ガス 
        AccountRecord.IsTrunkRoom__c  = TRUE;//トランクルーム 
        AccountRecord.IsTwoGasStove__c  = TRUE;//コンロ2口 
        AccountRecord.IsTwoTenant__c  = TRUE;//2人入居可 
        AccountRecord.IsWalkInCloset__c  = TRUE;//ウォークインクローゼット 
        AccountRecord.IsWashlet__c  = TRUE;//温水洗浄便座 
        AccountRecord.IsWelfareAvailable__c  = TRUE;//生活保護契約可 
        AccountRecord.IsWest__c  = TRUE;//西 
        AccountRecord.IsWoman__c  = TRUE;//女性限定 
        AccountRecord.IsWooden__c  = TRUE;//木造 
        AccountRecord.OccupancyAreaLowerLimit__c  = '0';//占有面積（下限） 
        AccountRecord.OccupancyAreaUpperLimit__c  = '999';//占有面積（上限） 
        AccountRecord.Parking__c  = '有';//駐車場 
        AccountRecord.ParkingFeeLimit__c  = 9999;//1台当たりの料金上限 
        AccountRecord.RentFeeFrom__c  = 9999;//賃料から 
        AccountRecord.RentFeeTo__c  = 9999;//賃料まで 
        AccountRecord.WalkingTime__c  = '999';//徒歩 
        AccountRecord.PropertyConditionsName__c = '条件1';
        // ▲2021.10.08 No.307 対応で追加

        //取引先作成
        insert AccountRecord; 

        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('一般ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert new User(
                UserName = 'Test@horaguchi.com',
                Email = 'test@example.com',
                LastName = 'test',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
        }
        // ▲2021.10.08 No.307 対応で追加

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

        // 店舗テストデータ作成
        Shop__c shop = new Shop__c();
        shop.Name = '店舗テスト';
        insert shop;

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
            Shop__c = shop.Id
        );
        insert orgRecord2;

        // 店舗異動テストデータ作成
        ShopTransfer__c shopTransfer = new ShopTransfer__c();

        shopTransfer.OrgzanizationHierarchy__c = orgRecord2.id;
        shopTransfer.Staff__c = UserInfo.getUserId();
        shopTransfer.StartDate__c = CommonUtil.getToday();
        shopTransfer.EndDate__c = CommonUtil.getToday();

        insert shopTransfer;

        VisitCard__c visitCard = new VisitCard__c();//来店カード

        visitCard.Account__c  = AccountRecord.Id;//取引先Id
        visitCard.Affiliation__c  = '勤務先/学校';//勤務先/学校名
        visitCard.AffiliationCity__c  = '勤務先/学校 住所１（市区町村）';//勤務先/学校 住所１（市区町村）
        visitCard.AffiliationPhone__c  = '勤務先/学校 電話番号';//勤務先/学校 電話番号
        visitCard.AffiliationPostalCode__c  = '勤務先/学校 郵';//勤務先/学校 郵便番号
        visitCard.AffiliationState__c  = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'State__c')[1].getValue();//勤務先/学校 都道府県
        visitCard.AffiliationStreet__c  = '勤務先/学校 住所２（番地）';//勤務先/学校 住所２（番地）
        visitCard.Birthdate__c  = date.newInstance(1999,1,1);//生年月日 
        visitCard.BuildingAge__c  = '999';//築年数 
        visitCard.CarCount__c  = 99;//台数 
        visitCard.City__c  = '住所１（市区町村）';//住所１（市区町村） 
        visitCard.ContractType__c  = '個人契約';//契約形態 
        visitCard.DesiredArea__c  = '希望地域';//希望地域 
        visitCard.DesiredTrainRoute1__c  = testDesiredTrainRoute[0].Id;//希望沿線１ 
        visitCard.DesiredTrainRoute2__c  = testDesiredTrainRoute[1].Id;//希望沿線２ 
        visitCard.DesiredTrainRoute3__c  = testDesiredTrainRoute[2].Id;//希望沿線３ 
        visitCard.Dissatisfaction__c  = '不満理由';//不満理由 
        visitCard.Email__c  = 'aaa@hora';//メール 
        visitCard.HomeMovingDate__c  = date.newInstance(2020,2,19);//引越時期（日付）までに 
        visitCard.HomeMovingReason__c  = '入学;就職;転勤;結婚;独立;転職;住替;現状不満';//引越理由 
        visitCard.HomeMovingSeason__c  = '即入居';//引越時期 
        visitCard.Introducer__c  = '紹介者';//紹介者 
        visitCard.Is1DK__c  = TRUE;//1DK 
        visitCard.Is1K__c  = TRUE;//1K 
        visitCard.Is1LDK1SLDK__c  = TRUE;//1LDK/SLDK 
        visitCard.Is2K2DK__c  = TRUE;//2K/DK 
        visitCard.Is2LDK2SLDK__c  = TRUE;//2LDK/SLDK 
        visitCard.Is3K3DK__c  = TRUE;//3K/DK 
        visitCard.Is3LDK3SLDK__c  = TRUE;//3LDK/SLDK 
        visitCard.Is4K4DK4LDKFrom__c  = TRUE;//4K/DK/LDK~ 
        visitCard.IsAditionalBoiling__c  = TRUE;//追焚機能 
        visitCard.IsAirConditioner__c  = TRUE;//エアコン 
        visitCard.IsAllElectric__c  = TRUE;//オール電化 
        visitCard.IsAllWestern__c  = TRUE;//オール洋間 
        visitCard.IsAutoLock__c  = TRUE;//オートロック 
        visitCard.IsBalcony__c  = TRUE;//バルコニー 
        visitCard.IsBicycleParking__c  = TRUE;//駐輪場 
        visitCard.IsBikeStorage__c  = TRUE;//バイク可 
        visitCard.IsBSAntenna__c  = TRUE;//BSアンテナ 
        visitCard.IsBuiltInGarage__c  = TRUE;//ビルトインガレージ 
        visitCard.IsCarport__c  = TRUE;//カーポート 
        visitCard.IsCat__c  = TRUE;//ペット(猫) 
        visitCard.IsCATV__c  = TRUE;//CATV 
        visitCard.IsCondominiumRental__c  = TRUE;//分譲賃貸 
        visitCard.IsCornerRoom__c  = TRUE;//角部屋 
        visitCard.IsCounterKitchen__c  = TRUE;//カウンターキッチン 
        visitCard.IsCSAntenna__c  = TRUE;//CSアンテナ 
        visitCard.IsDehumidifierForBathroom__c  = TRUE;//浴室乾燥機 
        visitCard.IsDeliveryBox__c  = TRUE;//宅配ボックス 
        visitCard.IsDesigners__c  = TRUE;//デザイナーズ 
        visitCard.IsDetachedHouse__c  = TRUE;//戸建て 
        visitCard.IsEast__c  = TRUE;//東 
        visitCard.IsElderly__c  = TRUE;//高齢者歓迎 
        visitCard.IsElectricStove__c  = TRUE;//電気コンロ 
        visitCard.IsElevator__c  = TRUE;//エレベーター 
        visitCard.IsFirstFloor__c  = TRUE;//1階 
        visitCard.IsFloorHeating__c  = TRUE;//床暖房 
        visitCard.IsForeigner__c  = TRUE;//外国人契約可 
        visitCard.IsFurniture__c  = TRUE;//家具付き 
        visitCard.IsGasStove__c  = TRUE;//ガスコンロ 
        visitCard.IsHomeAppliance__c  = TRUE;//家電付き 
        visitCard.IsIncludeManagementFee__c  = TRUE;//管理費込み 
        visitCard.IsIncludeParkingFee__c  = TRUE;//駐車場代込み 
        visitCard.IsInductionHeating__c  = TRUE;//IHコンロ 
        visitCard.IsInnerLandry__c  = TRUE;//室内洗濯機置場 
        visitCard.IsInSiteParking__c  = TRUE;//敷地内駐車場 
        visitCard.IsInternetFree__c  = TRUE;//ネット使用料無料 
        visitCard.IsIppambutsu__c  = TRUE;//一般物 
        visitCard.IsLargeBike__c  = TRUE;//大型バイク 
        visitCard.IsLargePet__c  = TRUE;//ペット(大型犬) 
        visitCard.IsLightweightSteel__c  = TRUE;//軽量鉄骨 
        visitCard.IsLoft__c  = TRUE;//ロフト 
        visitCard.IsMaisonette__c  = TRUE;//メゾネット 
        visitCard.IsMediumBike__c  = TRUE;//中型バイク 
        visitCard.IsMiddlePet__c  = TRUE;//ペット(中型犬) 
        visitCard.IsMonitorIntercom__c  = TRUE;//モニター付きインターホン 
        visitCard.IsMoreGasStove__c  = TRUE;//コンロ3口以上 
        visitCard.IsMusicalInstruments__c  = TRUE;//楽器相談可 
        visitCard.IsNoGuarantor__c  = TRUE;//保証人不要 
        visitCard.IsNonCleaningFee__c  = TRUE;//定額修繕費なし 
        visitCard.IsNonDeposit__c  = TRUE;//敷金/保証金なし 
        visitCard.IsNonGuaranteeidCompany__c  = TRUE;//保証会社不要 
        visitCard.IsNonKeyMoney__c  = TRUE;//礼金なし 
        visitCard.IsNonRenewalFee__c  = TRUE;//更新料なし 
        visitCard.IsNorth__c  = TRUE;//北 
        visitCard.IsNorthEast__c  = TRUE;//北東 
        visitCard.IsNorthWest__c  = TRUE;//北西 
        visitCard.IsOfficeAvailable__c  = TRUE;//事務所利用可 
        visitCard.IsOneRoom__c  = TRUE;//ワンルーム 
        visitCard.IsOtherPet__c  = TRUE;//ペット(その他) 
        visitCard.IsParking__c  = TRUE;//駐車場空きあり 
        visitCard.IsPet__c  = TRUE;//ペット可 
        visitCard.IsPluralCarParking__c  = TRUE;//駐車場2台可 
        visitCard.IsPrivateGarden__c  = TRUE;//専用庭 
        visitCard.IsPropaneGas__c  = TRUE;//プロパンガス 
        visitCard.IsProxyCompany__c  = '有';//代理会社有無 
        visitCard.IsRC__c  = TRUE;//RC 
        visitCard.IsRegalLavatory__c  = TRUE;//洗面所独立 
        visitCard.IsRenovation__c  = TRUE;//リノベーション 
        visitCard.IsRoofBalcony__c  = TRUE;//ルーフバルコニー 
        visitCard.IsRoomShare__c  = TRUE;//ルームシェア可 
        visitCard.IsSecondFloorOver__c  = TRUE;//2階以上 
        visitCard.IsSepalateBathAndRestroom__c  = TRUE;//バス・トイレ別 
        visitCard.IsShoeCloak__c  = TRUE;//シューズクローク 
        visitCard.IsShoesBox__c  = TRUE;//シューズボックス 
        visitCard.IsShowerWashBasin__c  = TRUE;//シャワー付き洗面台 
        visitCard.IsSmallBike__c  = TRUE;//小型バイク 
        visitCard.IsSmallPet__c  = TRUE;//ペット(小型犬) 
        visitCard.IsSouth__c  = TRUE;//南 
        visitCard.IsSouthEast__c  = TRUE;//南東 
        visitCard.IsSouthWest__c  = TRUE;//南西 
        visitCard.IsSRC__c  = TRUE;//SRC 
        visitCard.IsSteel__c  = TRUE;//鉄骨造 
        visitCard.IsStudent__c  = TRUE;//学生限定マンション 
        visitCard.IsSystemKitchen__c  = TRUE;//システムキッチン 
        visitCard.IsTopFloor__c  = TRUE;//最上階 
        visitCard.IsTownGas__c  = TRUE;//都市ガス 
        visitCard.IsTrunkRoom__c  = TRUE;//トランクルーム 
        visitCard.IsTwoGasStove__c  = TRUE;//コンロ2口 
        visitCard.IsTwoTenant__c  = TRUE;//2人入居可 
        visitCard.IsWalkInCloset__c  = TRUE;//ウォークインクローゼット 
        visitCard.IsWashlet__c  = TRUE;//温水洗浄便座 
        visitCard.IsWelfareAvailable__c  = TRUE;//生活保護契約可 
        visitCard.IsWest__c  = TRUE;//西 
        visitCard.IsWoman__c  = TRUE;//女性限定 
        visitCard.IsWooden__c  = TRUE;//木造 
        visitCard.JobType__c  = '会社員';//職種 
        //visitCard.MobilePhone__c  = '携帯番号';//携帯番号 
        visitCard.OccupancyAreaLowerLimit__c  = '0';//占有面積（下限） 
        visitCard.OccupancyAreaUpperLimit__c  = '999';//占有面積（上限） 
        visitCard.Parking__c  = '有';//駐車場 
        visitCard.ParkingFeeLimit__c  = 9999;//1台当たりの料金上限 
        visitCard.Phone__c  = '電話番号';//電話番号 
        visitCard.PortalSite__c  = 'スーモ/SUUMO;ライフルホームズ/LIFULL HOME’S;アットホーム/at home;ルームセレクト/ROOM SELECT(当店ホームページ)';//ポータルサイト 
        visitCard.PostalCode__c  = '郵便番号';//郵便番号 
        visitCard.ProxyCompanyName__c  = '代理会社名';//代理会社名 
        visitCard.RentFeeFrom__c  = 9999;//賃料から 
        visitCard.RentFeeTo__c  = 9999;//賃料まで 
        visitCard.Sex__c  = '男性';//性別 
        visitCard.SiteView__c  = '見た';//事前にネット
        visitCard.Staff__c  = UserInfo.getUserId();//担当者
        visitCard.State__c  = CommonUtil.getSelectOptionFromObject('VisitCard__c', 'State__c')[1].getValue();//都道府県 
        visitCard.Street__c  = '住所２（番地）';//住所２（番地） 
        visitCard.TenantCount__c  = 99;//入居人数 
        visitCard.VisitDate__c  = date.newInstance(2020,2,19);//来店日
        visitCard.VisiterFirstName__c  = '名';//名 
        visitCard.VisiterFirstNameKana__c  = '名（カナ）';//名（カナ） 
        visitCard.VisiterLastName__c  = '姓';//姓 
        visitCard.VisiterLastNameKana__c  = '姓（カナ）';//姓（カナ） 
        visitCard.VisitReason__c  = '予約';//来店理由（スタッフ欄） 
        visitCard.VisitTrigger__c  = '閲覧サイト;以前にご来店の経験あり;ご紹介;通りがかり;無人コーナー';//来店のきっかけ 
        visitCard.WalkingTime__c  = '999';//徒歩 
        visitCard.DesiredJuniorHighSchoolArea__c = testDesiredSchoolArea[0].id;// 中学校希望学区（エリア）
        visitCard.DesiredElementarySchoolArea__c = testDesiredSchoolArea[1].id;// 小学校希望学区（エリア）
        
        insert visitCard;

        Correspond__c correspond = new Correspond__c();//対応

        //対応作成
        correspond.AccountId__c = AccountRecord.Id;//取引先
        correspond.Status__c = CommonConst.TASK_CORRESPONDTYPE_VISITED;//ステータス
        correspond.EventDateTime__c = CommonUtil.getNow();//イベント時刻
        correspond.IsSupportedListShow__c = FALSE;//対応確認
        correspond.ShopStaff__c	= UserInfo.getUserId();//担当者（来店）
        correspond.VisitShop__c = CommonUtil.getStaffCurrentShop().Id;//来店担当店舗
        correspond.VisitReason__c = '予約';//来店理由（スタッフ欄）画面．来店理由（スタッフ欄）

        insert correspond;

        system.debug('初期設定終了');        
    }

 
    //***************************************************** テストメソッド *****************************************************************
    

	//画面表示（初期表示）
	@isTest static void initializeTest(){

		Account AccountRecord = [SELECT ID
										,(SELECT ID
											FROM VisitsCardAccount__r
											ORDER BY SystemModstamp DESC
											LIMIT 1
										)
									FROM ACCOUNT WHERE NAME = 'テスト太郎'];

		Correspond__c correspond = [SELECT ID
										FROM Correspond__c 
										WHERE AccountId__c = :AccountRecord.Id];

		//パラメータ設定
		PageReference pageRef = Page.GA202001View;
		pageRef.getParameters().put('acc',AccountRecord.Id );
		pageRef.getParameters().put('Corresponds',correspond.Id );
		Test.setCurrentPage(pageRef);

		// コントローラの初期表示を実行
		GA202001Controller GA202001Controller = new GA202001Controller();

		// テスト結果確認
		system.assertNotEquals(TRUE, GA202001Controller.isOpenError); 
		system.assertEquals(AccountRecord.Id, GA202001Controller.displayVisitCard.account.Id);
		system.assertEquals(AccountRecord.VisitsCardAccount__r[0].Id, GA202001Controller.displayVisitCard.visitCard.Id);

        
    }	
    
	//モーダル処理
    @isTest static void modalTest(){

        Account AccountRecord = [SELECT ID
                                       ,(SELECT ID
                                         FROM VisitsCardAccount__r
                                         ORDER BY SystemModstamp DESC
                                         LIMIT 1
                                        )
                                 FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                       FROM Correspond__c 
                                       WHERE AccountId__c = :AccountRecord.Id];

        // ▼2021.10.08 No.307 対応で追加
        insertAPC_1(); // 画面の初期値を設定のため追加
        // ▲2021.10.08 No.307 対応で追加

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        //お客様連絡先 郵便番号
        GA202001Controller.postmodal1();
        
        system.assertEquals(GA202001Controller.GA102006Parameter.postalCode, GA202001Controller.displayVisitCard.PostalCode); //モーダルに渡す用郵便番号
        system.assertEquals(GA202001Controller.GA102006Parameter.state, GA202001Controller.displayVisitCard.state); //モーダルに渡す用都道府県
        system.assertEquals(GA202001Controller.GA102006Parameter.city, GA202001Controller.displayVisitCard.city); //モーダルに渡す用市町村
        
        //パラメータ変更
        GA202001Controller.GA102006Parameter.postalCode = 'A';
        GA202001Controller.GA102006Parameter.state =  CommonUtil.getSelectOptionFromObject('VisitCard__c', 'State__c')[2].getValue();
        GA202001Controller.GA102006Parameter.city = 'C';
        GA202001Controller.GA102006Parameter.street = 'D';

        GA202001Controller.closeModal();

        //パラメータ変更の反映確認
        system.assertEquals('A', GA202001Controller.displayVisitCard.PostalCode); //郵便番号
        system.assertEquals(CommonUtil.getSelectOptionFromObject('VisitCard__c', 'State__c')[2].getValue(), GA202001Controller.displayVisitCard.state); //都道府県
        system.assertEquals('CD', GA202001Controller.displayVisitCard.city); //市町村


        //お客様勤務先/学校連絡先 郵便番号
        GA202001Controller.postmodal2();
        
        system.assertEquals(GA202001Controller.GA102006Parameter.postalCode, GA202001Controller.displayVisitCard.affiliationPostalCode); //モーダルに渡す用郵便番号
        system.assertEquals(GA202001Controller.GA102006Parameter.state, GA202001Controller.displayVisitCard.affiliationState); //モーダルに渡す用都道府県
        system.assertEquals(GA202001Controller.GA102006Parameter.city, GA202001Controller.displayVisitCard.affiliationCity); //モーダルに渡す用市町村
        
        //パラメータ変更
        GA202001Controller.GA102006Parameter.postalCode = 'E';
        GA202001Controller.GA102006Parameter.state =  CommonUtil.getSelectOptionFromObject('VisitCard__c', 'State__c')[2].getValue();
        GA202001Controller.GA102006Parameter.city = 'G';
        GA202001Controller.GA102006Parameter.street = 'H';

        GA202001Controller.closeModal();

        //パラメータ変更の反映確認
        system.assertEquals('E', GA202001Controller.displayVisitCard.affiliationPostalCode); //郵便番号
        system.assertEquals(CommonUtil.getSelectOptionFromObject('VisitCard__c', 'State__c')[2].getValue(), GA202001Controller.displayVisitCard.affiliationState); //都道府県
        system.assertEquals('GH', GA202001Controller.displayVisitCard.affiliationCity); //市町村

        // 路線１
        GA202001Controller.openStations1Modal();

        // ▼2021.10.08 No.307 対応で変更
        system.assertEquals(GA202001Controller.GA104007Parameter.selectedTrainRoute.Id, GA202001Controller.displayVisitCard.displayCond.trainRoute1); //希望路線
        // ▲2021.10.08 No.307 対応で変更
        system.assertEquals(GA202001Controller.GA104007Parameter.selectedStation.isEmpty(), FALSE); //希望路線

        //パラメータ変更
        GA202001Controller.GA104007Parameter.selectedStation = new  List<Station__c>();

        GA202001Controller.closeModal();

        //パラメータ変更の反映確認
        // ▼2021.10.08 No.307 対応で変更
        system.assertEquals(GA202001Controller.displayVisitCard.displayCond.trainRoute1, GA202001Controller.GA104007Parameter.selectedTrainRoute.Id); //希望路線
        // ▲2021.10.08 No.307 対応で変更
        system.assertEquals(GA202001Controller.GA104007Parameter.selectedStation.isEmpty(), TRUE); //希望路線
        
        // 路線2
        GA202001Controller.openStations2Modal();
        // ▼2021.10.08 No.307 対応で変更
        system.assertEquals(GA202001Controller.GA104007Parameter.selectedTrainRoute.Id, GA202001Controller.displayVisitCard.displayCond.trainRoute2); //希望路線
        // ▲2021.10.08 No.307 対応で変更
        system.assertEquals(GA202001Controller.GA104007Parameter.selectedStation.isEmpty(), FALSE); //希望路線

        //パラメータ変更
        GA202001Controller.GA104007Parameter.selectedStation = new  List<Station__c>();

        GA202001Controller.closeModal();

        //パラメータ変更の反映確認
        // ▼2021.10.08 No.307 対応で変更
        system.assertEquals(GA202001Controller.displayVisitCard.displayCond.trainRoute2, GA202001Controller.GA104007Parameter.selectedTrainRoute.Id); //希望路線
        // ▲2021.10.08 No.307 対応で変更
        system.assertEquals(GA202001Controller.GA104007Parameter.selectedStation.isEmpty(), TRUE); //希望路線
        
        // 路線3
        GA202001Controller.openStations3Modal();

        // ▼2021.10.08 No.307 対応で変更
        system.assertEquals(GA202001Controller.GA104007Parameter.selectedTrainRoute.Id, GA202001Controller.displayVisitCard.displayCond.trainRoute3); //希望路線
        // ▲2021.10.08 No.307 対応で変更
        system.assertEquals(GA202001Controller.GA104007Parameter.selectedStation.isEmpty(), FALSE); //希望路線

        //パラメータ変更
        GA202001Controller.GA104007Parameter.selectedStation = new  List<Station__c>();

        GA202001Controller.closeModal();

        //パラメータ変更の反映確認
        // ▼2021.10.08 No.307 対応で変更
        system.assertEquals(GA202001Controller.displayVisitCard.displayCond.trainRoute3, GA202001Controller.GA104007Parameter.selectedTrainRoute.Id); //希望路線
        // ▲2021.10.08 No.307 対応で変更
        system.assertEquals(GA202001Controller.GA104007Parameter.selectedStation.isEmpty(), TRUE); //希望路線
        
        // 問合せ415で追加　中学校区
        GA202001Controller.openJuniorHighSchoolDistrictModal();
        GA202001Controller.closeModal();

        // 小学校区
        GA202001Controller.openElementarySchoolDistrictModal();
        GA202001Controller.closeModal();

        // 問合せ423で追加　地区
        GA202001Controller.openDistrictModal();
        GA202001Controller.closeModal();
    }

	//路線変更処理
    @isTest static void changeTrainRouteTest(){

        Account AccountRecord = [SELECT ID
                                       ,(SELECT ID
                                         FROM VisitsCardAccount__r
                                         ORDER BY SystemModstamp DESC
                                         LIMIT 1
                                        )
                                 FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                       FROM Correspond__c 
                                       WHERE AccountId__c = :AccountRecord.Id];

        // ▼2021.10.08 No.307 対応で追加
        insertAPC_1(); // 画面の初期値を設定のため追加
        // ▲2021.10.08 No.307 対応で追加
        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        //駅1の初期化確認
        // ▼2021.10.08 No.307 対応で変更
        system.assertEquals(TRUE, String.isNotBlank(GA202001Controller.displayVisitCard.displayCond.stationsChar1));
        GA202001Controller.changeTrainRoute1();
        system.assertEquals(FALSE, String.isNotBlank(GA202001Controller.displayVisitCard.displayCond.stationsChar1));
        // ▲2021.10.08 No.307 対応で変更

        //駅2の初期化確認
        // ▼2021.10.08 No.307 対応で変更
        system.assertEquals(TRUE, String.isNotBlank(GA202001Controller.displayVisitCard.displayCond.stationsChar2));
        GA202001Controller.changeTrainRoute2();
        system.assertEquals(FALSE, String.isNotBlank(GA202001Controller.displayVisitCard.displayCond.stationsChar2));
        // ▲2021.10.08 No.307 対応で変更

        //駅3の初期化確認
        // ▼2021.10.08 No.307 対応で変更
        system.assertEquals(TRUE, String.isNotBlank(GA202001Controller.displayVisitCard.displayCond.stationsChar3));
        GA202001Controller.changeTrainRoute3();
        system.assertEquals(FALSE, String.isNotBlank(GA202001Controller.displayVisitCard.displayCond.stationsChar3));
        // ▲2021.10.08 No.307 対応で変更

        GA202001Controller.changeJuniorHighSchool();
        GA202001Controller.changeElementarySchool();
        
    }

	//年齢再計算
    @isTest static void ageRecalculateTest(){

        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        //検証用来店カード作成
        VisitCard__c visitCard = new VisitCard__c(Birthdate__c = date.newInstance(2000,1,1), VisitDate__c = CommonUtil.getToday());//計算用レコード作成
        visitCard.recalculateFormulas();//計算実行

        //ページ表示年齢と検証用年齢比較
        system.assertNotEquals(String.valueOf(visitCard.age__c), GA202001Controller.displayVisitCard.age);

        //生年月日入力欄変更
        GA202001Controller.displayVisitCard.birthdate = date.newInstance(2000,1,1);

        //年齢再計算
        GA202001Controller.ageRecalculate();//計算実行

        system.assertEquals(String.valueOf(visitCard.age__c), GA202001Controller.displayVisitCard.age);

    }

	//チェック変更処理
    @isTest static void changeCheckboxTest(){
        
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        //ご来店のきっかけ変更時
        GA202001Controller.visitsTriggerCheckList.put('閲覧サイト', FALSE);//閲覧サイトのチェックFALSE

        for (SelectOption portalSiteList : CommonUtil.getSelectOptionFromObject('VisitCard__c', 'PortalSite__c', false)) {//閲覧サイトの全チェックボックス
            String value = portalSiteList.getValue();
            
            //リスト設定
            GA202001Controller.portalSiteCheckList.put(value,TRUE);
            system.assertEquals(TRUE, GA202001Controller.portalSiteCheckList.get(value));//リスト設定確認
        }

        //ご来店のきっかけ変更時
        GA202001Controller.visitsTriggerCheckList.put('ご紹介', FALSE);//閲覧サイトのチェックFALSE

        //紹介者設定
        GA202001Controller.displayVisitCard.introducer = '紹介者';
        system.assertEquals(TRUE, GA202001Controller.displayVisitCard.introducer == '紹介者');//紹介者設定確認

        //ご来店のきっかけ変更時の処理実行
        GA202001Controller.changeVisitTrigger();

        for (SelectOption portalSiteList : CommonUtil.getSelectOptionFromObject('VisitCard__c', 'PortalSite__c', false)) {//閲覧サイトの全チェックボックス
            String value = portalSiteList.getValue();
            
            system.assertEquals(false, GA202001Controller.portalSiteCheckList.get(value));//閲覧サイトのチェックが外れた場合、「閲覧サイトの全チェックボックス」を初期化
        }

        system.assertEquals(null, GA202001Controller.displayVisitCard.introducer);//閲覧サイトのチェックが外れた場合、「ご紹介者様」を初期化


        //お引越し理由変更時の処理
        GA202001Controller.homeMovingReasonCheckList.put('現状不満', FALSE);//閲覧サイトのチェックFALSE

        //現状不満設定
        GA202001Controller.displayVisitCard.dissatisfaction = '現状不満';
        system.assertEquals(TRUE, GA202001Controller.displayVisitCard.dissatisfaction == '現状不満');//現状不満設定確認

        //お引越し理由変更時の処理実行
        GA202001Controller.changeHomeMovingReason();

        system.assertEquals(null, GA202001Controller.displayVisitCard.dissatisfaction);//閲覧サイトのチェックが外れた場合、「現状不満」を初期化


        //引越時期変更時の処理
        GA202001Controller.homeMovingSeasonCheckList.put('その他', FALSE);//閲覧サイトのチェックFALSE

        //引っ越し時期（日付）設定
        GA202001Controller.displayVisitCard.homeMovingDate = CommonUtil.getToday();
        system.assertEquals(TRUE, GA202001Controller.displayVisitCard.homeMovingDate == CommonUtil.getToday());//引っ越し時期（日付）設定確認

        //お引越し理由変更時の処理実行
        GA202001Controller.changeHomeMovingSeason();

        system.assertEquals(TRUE, GA202001Controller.displayVisitCard.homeMovingDate == null);//その他のチェックが外れた場合、引っ越し時期（日付）を初期化

    }

	//来店理由(スタッフ欄)の確定処理
    @isTest static void visitReasonConfirmTest(){
        
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        GA202001Controller.displayVisitCard.visitReason = GA202001Controller.visitReasonOption[1].getValue();
        
        GA202001Controller.visitReasonConfirm();

        //エラーが発生しないことを確認
        system.assertEquals(FALSE, GA202001Controller.hasErrorMessage);
        
    }

	//登録（名寄せ一致データなし）
    @isTest static void saveTest(){
        

        Account AccountRecord = [SELECT ID
                                       ,SystemModstamp
                                       ,(SELECT ID
                                               ,SystemModstamp
                                         FROM VisitsCardAccount__r
                                         ORDER BY SystemModstamp DESC
                                         LIMIT 1
                                        )
                                 FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Datetime accountRecordSystemModstamp = AccountRecord.SystemModstamp;
        Datetime visitsCardRecordSystemModstamp = AccountRecord.VisitsCardAccount__r[0].SystemModstamp;

        Correspond__c correspond = [SELECT ID
                                          ,SystemModstamp
                                       FROM Correspond__c 
                                       WHERE AccountId__c = :AccountRecord.Id];

        Datetime correspondSystemModstamp = correspond.SystemModstamp;

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        GA202001Controller.displayVisitCard.visitReason = GA202001Controller.visitReasonOption[1].getValue();

        // ▼2021.10.08 No.307 対応で追加
        setCondition(GA202001Controller, false);
        // ▲2021.10.08 No.307 対応で追加

        GA202001Controller.displayVisitCard.account.Email__c = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え

        CommonUtil.sleep(3000);

        GA202001Controller.save();

        // テスト結果確認

        //エラーが発生しないことを確認
        system.assertEquals(FALSE, GA202001Controller.hasErrorMessage);

        
        List<ACCOUNT> savedAccountRecord = [ SELECT id,SystemModStamp
                                        FROM ACCOUNT
                                        WHERE id = :AccountRecord.Id
                                        AND SystemModStamp = :AccountRecord.systemModStamp ];//更新確認

        
        system.assertEquals(TRUE, savedAccountRecord.isEmpty());

        List<VisitCard__c> savedVisitCard = [ SELECT id,SystemModStamp
                                        FROM VisitCard__c
                                        WHERE id = :AccountRecord.VisitsCardAccount__r[0].Id
                                        AND SystemModStamp = :AccountRecord.VisitsCardAccount__r[0].systemModStamp ];//更新確認
        system.debug(savedVisitCard);
        
        system.assertEquals(TRUE, savedVisitCard.isEmpty());

        List<Correspond__c> savedcorrespond = [ SELECT id
                                        FROM Correspond__c
                                        WHERE id = :correspond.Id
                                        AND SystemModStamp = :correspond.systemModStamp ];//更新確認
        
        system.assertEquals(TRUE, savedcorrespond.isEmpty());

        //取引先の名寄せ完了フラグ・名寄せ不要フラグ確認
        Account chkAcc = [SELECT id, IsMergeCompletedFlag__c, IsMergeUnnecessaryFlag__c
                          FROM Account
                          WHERE id = :AccountRecord.Id
        ];
        system.assertEquals(true, chkAcc.IsMergeCompletedFlag__c);
        system.assertEquals(false, chkAcc.IsMergeUnnecessaryFlag__c);

    }

    //登録（名寄せ一致データあり）
    @isTest static void saveTest2(){
        
        //名寄せ一致データ登録(電話番号が一致)
        Account nayose = new Account(Name = 'テスト次郎', 
                                     FirstName__c = '次郎', LastName__c = 'テスト', 
                                     NameKana__c = 'ﾃｽﾄｼﾞﾛｳ',
                                     Phone = '025-200-1234', 
                                     IsMergeUnnecessaryFlag__c = true, 
                                     RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
        insert nayose;

        Account AccountRecord = [SELECT ID
                                        ,SystemModstamp
                                        ,(SELECT ID
                                                ,SystemModstamp
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Datetime accountRecordSystemModstamp = AccountRecord.SystemModstamp;
        Datetime visitsCardRecordSystemModstamp = AccountRecord.VisitsCardAccount__r[0].SystemModstamp;

        Correspond__c correspond = [SELECT ID
                                            ,SystemModstamp
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];

        Datetime correspondSystemModstamp = correspond.SystemModstamp;

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        GA202001Controller.displayVisitCard.visitReason = GA202001Controller.visitReasonOption[1].getValue();

        // ▼2021.10.08 No.307 対応で追加
        setCondition(GA202001Controller, false);
        // ▲2021.10.08 No.307 対応で追加

        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま

        CommonUtil.sleep(3000);

        GA202001Controller.save();

        // テスト結果確認

        //エラーが発生しないことを確認
        system.assertEquals(FALSE, GA202001Controller.hasErrorMessage);

        
        List<ACCOUNT> savedAccountRecord = [ SELECT id,SystemModStamp
                                        FROM ACCOUNT
                                        WHERE id = :AccountRecord.Id
                                        AND SystemModStamp = :AccountRecord.systemModStamp ];//更新確認

        
        system.assertEquals(TRUE, savedAccountRecord.isEmpty());

        List<VisitCard__c> savedVisitCard = [ SELECT id,SystemModStamp
                                        FROM VisitCard__c
                                        WHERE id = :AccountRecord.VisitsCardAccount__r[0].Id
                                        AND SystemModStamp = :AccountRecord.VisitsCardAccount__r[0].systemModStamp ];//更新確認
        
        system.assertEquals(TRUE, savedVisitCard.isEmpty());

        List<Correspond__c> savedcorrespond = [ SELECT id
                                        FROM Correspond__c
                                        WHERE id = :correspond.Id
                                        AND SystemModStamp = :correspond.systemModStamp ];//更新確認
        
        system.assertEquals(TRUE, savedcorrespond.isEmpty());

        //取引先の名寄せ完了フラグ・名寄せ不要フラグ確認
        Account chkAcc = [SELECT id, IsMergeCompletedFlag__c, IsMergeUnnecessaryFlag__c
                          FROM Account
                          WHERE id = :AccountRecord.Id
        ];
        system.assertEquals(false, chkAcc.IsMergeCompletedFlag__c);
        system.assertEquals(false, chkAcc.IsMergeUnnecessaryFlag__c);

        //名寄せが一致した取引先の名寄せ不要フラグ確認
        Account chkAcc2 = [ SELECT id, IsMergeCompletedFlag__c, IsMergeUnnecessaryFlag__c
                            FROM Account
                            WHERE NameKana__c = 'ﾃｽﾄｼﾞﾛｳ'
        ];
        system.assertEquals(false, chkAcc2.IsMergeUnnecessaryFlag__c);

    }
    
	//パラメータエラー
    @isTest static void parameterErrorTest(){
        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc','ABC' );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        //エラーを確認
        system.assertEquals(TRUE, GA202001Controller.isOpenError);
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));//「エラーメッセージ」の表示が正しいか確認

    }

	//確定ボタン押下(異常系)
    @isTest static void notSelectVisitReasonErrorTest(){
        
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();
        
        GA202001Controller.visitReasonConfirm();

        //エラーが発生しないことを確認
        system.assertEquals(TRUE, GA202001Controller.hasErrorMessage);
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_NO_SELECTION,'来店理由'));//「エラーメッセージ」の表示が正しいか確認
        
        
    }

	//必須入力エラー
    @isTest static void requiredErrorTest(){
        

        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();


        //ご来店のきっかけ変更時
        GA202001Controller.visitsTriggerCheckList.put('閲覧サイト', TRUE);//閲覧サイトのチェックTRUE

        //ご来店のきっかけ変更時
        GA202001Controller.visitsTriggerCheckList.put('ご紹介', TRUE);//閲覧サイトのチェックTRUE

        //お引越し理由変更時
        GA202001Controller.homeMovingReasonCheckList.put('現状不満', TRUE);//閲覧サイトのチェックTRUE

        //引越時期変更時
        GA202001Controller.homeMovingSeasonCheckList.put('その他', TRUE);//閲覧サイトのチェックTRUE

        //紹介者設定
        GA202001Controller.displayVisitCard.introducer = null;

        //現状不満設定
        GA202001Controller.displayVisitCard.dissatisfaction = null;

        //引っ越し時期（日付）設定
        GA202001Controller.displayVisitCard.homeMovingDate = null;

        //駐車場「台数」設定
        GA202001Controller.displayVisitCard.displayCond.carCount = '1';

        //登録処理
        GA202001Controller.save();

        //エラーが発生することを確認
        system.assertEquals(TRUE, GA202001Controller.hasErrorMessage);

        //検証用エラーメッセージ作成
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_INPUT,'電話番号、メール','どちらか1つ'));//「エラーメッセージ」の表示確認
        system.assertEquals(ApexPages.getMessages()[1].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'ご紹介者様'));//「エラーメッセージ」の表示確認
        system.assertEquals(ApexPages.getMessages()[2].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'現状不満理由'));//「エラーメッセージ」の表示確認
        system.assertEquals(ApexPages.getMessages()[3].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'引越時期'));//「エラーメッセージ」の表示確認
        system.assertEquals(ApexPages.getMessages()[4].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED,'1台あたりの料金'));//「エラーメッセージ」の表示確認
    
        List<String> requiredItem = new List<String>();//入力チェックリストを初期化
        requiredItem.add('来店理由（スタッフ欄）');
        requiredItem.add('名前（姓）');
        requiredItem.add('名前（名）');
        requiredItem.add('名前（姓）フリガナ');
        requiredItem.add('名前（名）フリガナ');
        requiredItem.add('生年月日');
        requiredItem.add('郵便番号');
        requiredItem.add('都道府県');
        requiredItem.add('住所（市区町村）');
        requiredItem.add('住所（番地）');
        requiredItem.add('入居人数');
        requiredItem.add('希望地域');
        requiredItem.add('希望路線①');

        //system.assertEquals(ApexPages.getMessages()[5].getDetail(), CommonUtil.callMessageCreate(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ','))));//「エラーメッセージ」の表示確認

    }

	//楽観ロックチェックエラー（取引先）
    @isTest static void accountSaveErrorTest(){

        

        Account AccountRecord = [SELECT ID
                                       ,SystemModstamp
                                       ,(SELECT ID
                                               ,SystemModstamp
                                         FROM VisitsCardAccount__r
                                         ORDER BY SystemModstamp DESC
                                         LIMIT 1
                                        )
                                 FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Datetime accountRecordSystemModstamp = AccountRecord.SystemModstamp;
        Datetime visitsCardRecordSystemModstamp = AccountRecord.VisitsCardAccount__r[0].SystemModstamp;

        Correspond__c correspond = [SELECT ID
                                          ,SystemModstamp
                                       FROM Correspond__c 
                                       WHERE AccountId__c = :AccountRecord.Id];

        Datetime correspondSystemModstamp = correspond.SystemModstamp;

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        GA202001Controller.displayVisitCard.visitReason = GA202001Controller.visitReasonOption[1].getValue();

        CommonUtil.sleep(3000);

        upsert AccountRecord;

        GA202001Controller.save();

        // テスト結果確認

        //エラーが発生していることを確認
        system.assertEquals(TRUE, GA202001Controller.hasErrorMessage);
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));//「エラーメッセージ」の表示が正しいか確認

    }

	//楽観ロックチェックエラー（来店カード）
    @isTest static void visitCardSaveErrorTest(){

        

        Account AccountRecord = [SELECT ID
                                       ,SystemModstamp
                                       ,(SELECT ID
                                               ,SystemModstamp
                                         FROM VisitsCardAccount__r
                                         ORDER BY SystemModstamp DESC
                                         LIMIT 1
                                        )
                                 FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Datetime accountRecordSystemModstamp = AccountRecord.SystemModstamp;
        Datetime visitsCardRecordSystemModstamp = AccountRecord.VisitsCardAccount__r[0].SystemModstamp;

        Correspond__c correspond = [SELECT ID
                                          ,SystemModstamp
                                       FROM Correspond__c 
                                       WHERE AccountId__c = :AccountRecord.Id];

        Datetime correspondSystemModstamp = correspond.SystemModstamp;

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        GA202001Controller.displayVisitCard.visitReason = GA202001Controller.visitReasonOption[1].getValue();

        CommonUtil.sleep(3000);

        VisitCard__c visitCard = new VisitCard__c(Id = AccountRecord.VisitsCardAccount__r[0].Id);//来店カード
        upsert visitCard;

        GA202001Controller.save();

        // テスト結果確認

        //エラーが発生していることを確認
        system.assertEquals(TRUE, GA202001Controller.hasErrorMessage);
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));//「エラーメッセージ」の表示が正しいか確認

        
    }

	//楽観ロックチェックエラー（対応）
    @isTest static void correspondSaveErrorTest(){

        

        Account AccountRecord = [SELECT ID
                                       ,SystemModstamp
                                       ,(SELECT ID
                                               ,SystemModstamp
                                         FROM VisitsCardAccount__r
                                         ORDER BY SystemModstamp DESC
                                         LIMIT 1
                                        )
                                 FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Datetime accountRecordSystemModstamp = AccountRecord.SystemModstamp;
        Datetime visitsCardRecordSystemModstamp = AccountRecord.VisitsCardAccount__r[0].SystemModstamp;

        Correspond__c correspond = [SELECT ID
                                          ,SystemModstamp
                                       FROM Correspond__c 
                                       WHERE AccountId__c = :AccountRecord.Id];

        Datetime correspondSystemModstamp = correspond.SystemModstamp;

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        GA202001Controller.displayVisitCard.visitReason = GA202001Controller.visitReasonOption[1].getValue();

        CommonUtil.sleep(3000);

        upsert correspond;

        GA202001Controller.save();

        // テスト結果確認

        //エラーが発生していることを確認
        system.assertEquals(TRUE, GA202001Controller.hasErrorMessage);
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));//「エラーメッセージ」の表示が正しいか確認

        
    }

	//メールの入力規則エラー
    @isTest static void isWrongMailStringErrorTest(){
        

        

        Account AccountRecord = [SELECT ID
                                       ,SystemModstamp
                                       ,(SELECT ID
                                               ,SystemModstamp
                                         FROM VisitsCardAccount__r
                                         ORDER BY SystemModstamp DESC
                                         LIMIT 1
                                        )
                                 FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Datetime accountRecordSystemModstamp = AccountRecord.SystemModstamp;
        Datetime visitsCardRecordSystemModstamp = AccountRecord.VisitsCardAccount__r[0].SystemModstamp;

        Correspond__c correspond = [SELECT ID
                                          ,SystemModstamp
                                       FROM Correspond__c 
                                       WHERE AccountId__c = :AccountRecord.Id];

        Datetime correspondSystemModstamp = correspond.SystemModstamp;

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        //メール
        GA202001Controller.displayVisitCard.email = 'A@B@mail.com';


        //登録処理
        GA202001Controller.save();

        //エラーが発生することを確認
        system.assertEquals(TRUE, GA202001Controller.hasErrorMessage);

        //検証用エラーメッセージ作成
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_MAILADDRESS_VALIDATION, 'メール'));//「エラーメッセージ」の表示確認

    }

	//ログインユーザパラメータエラー
    @isTest static void loginUserErrorTest(){
        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('userId','ABC' );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        //エラーを確認
        system.assertEquals(TRUE, GA202001Controller.isOpenError);
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_LOGGING_DIFFERENT_USER, UserInfo.getName()));//「エラーメッセージ」の表示が正しいか確認

    }

// ▼2021.10.08 No.307 対応で追加
    //初期表示No18
    @isTest static void init18Test(){
        // コントローラの初期表示を実行
        deleteAccount();
        GA202001Controller GA202001Controller = new GA202001Controller();
        // 初期表示【新規顧客】
        checkdisplayCond(GA202001Controller, false, '条件1', 'init');
    }

    //初期表示No19
    @isTest static void init19Test(){
        deleteVisitCard();
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];
        
        
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

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();
        // 初期表示【既存顧客＆新規来店】
        checkdisplayCond(GA202001Controller, true, '条件1', '19');
    }

    //初期表示No20
    @isTest static void init20Test(){
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行

        GA202001Controller GA202001Controller = new GA202001Controller();
        // 初期表示【既存顧客＆新規来店】お客様物件条件あり
        checkdisplayCond(GA202001Controller, true, '条件1', '20');
    }

    //参照テスNo21,22
    @isTest static void reference2122Test(){
        // お客様物件条件を登録する。
        insertAPC_1();
        insertAPC_2();
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();

        for(SelectOption option : GA202001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件2'){
                GA202001Controller.selectCondName = option.getValue();
            }
        } 
        GA202001Controller.changeConditions();
        // テスト結果確認
        checkdisplayCond(GA202001Controller, true, '条件2', '');
        for(SelectOption option : GA202001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件3'){
                GA202001Controller.selectCondName = option.getValue();
            }
        } 
        // 物件条件を切替える
        GA202001Controller.changeConditions();
        checkdisplayCond(GA202001Controller, false, '条件3', '');
    }

    //登録No23
    @isTest static void register23Test(){
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, true);
        GA202001Controller.save();

        // 登録確認「取引先以外の物件条件が0件」
        checkAccountVisitCord(AccountRecord.Id, 'register');
    }

    //登録No24
    @isTest static void register24Test(){
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        GA202001Controller.addPropertyCond();
        setCondition(GA202001Controller, true);
        GA202001Controller.save();

        // 登録確認「取引先以外の物件条件が1件」
        checkAccountPropertyConditionsObj(AccountRecord.Id, 'register');
    }

    //登録No25
    @isTest static void register25Test(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        system.runas(userRecord){
            Account AccountRecord = [SELECT ID
                                            ,(SELECT ID
                                                FROM VisitsCardAccount__r
                                                ORDER BY SystemModstamp DESC
                                                LIMIT 1
                                            )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

            Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];

            //パラメータ設定
            PageReference pageRef = Page.GA202001View;
            pageRef.getParameters().put('acc',AccountRecord.Id );
            pageRef.getParameters().put('Corresponds',correspond.Id );
            Test.setCurrentPage(pageRef);
            // コントローラの初期表示を実行
            GA202001Controller GA202001Controller = new GA202001Controller();
            GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
            GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
            GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
            GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
            GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
            GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
            GA202001Controller.addPropertyCond();
            setCondition(GA202001Controller, true);
            GA202001Controller.addPropertyCond();
            setCondition(GA202001Controller, false);
            GA202001Controller.addPropertyCond();
            setCondition(GA202001Controller, true);
            GA202001Controller.save();

            // 登録確認「取引先以外の物件条件が３件」
            checkAccountPropertyConditionsObj(AccountRecord.Id, 'register');

        }

    }    

    // 更新No26
    @isTest static void update26Test(){
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, false);
        GA202001Controller.save();

        // 更新登録確認「取引先以外の物件条件が0件」
        checkAccountVisitCord(AccountRecord.id, 'update');
    }

    // 更新No27
    @isTest static void update27Test(){
        insertAPC_1();
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ

        for(SelectOption option : GA202001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件2'){
                GA202001Controller.selectCondName = option.getValue();
            }
        }
        GA202001Controller.changeConditions();
        setCondition(GA202001Controller, false);
        GA202001Controller.save();

        // 更新登録確認「取引先以外の物件条件が1件件」
        checkAccountPropertyConditionsObj(AccountRecord.Id, 'update');
    }    

    // 更新No28
    @isTest static void update28Test(){
        insertAPC_1();
        insertAPC_2();
        insertAPC_3();
        deleteVisitCard();
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, true);

        for(SelectOption option : GA202001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件2'){
                GA202001Controller.selectCondName = option.getValue();
            }
        }
        GA202001Controller.changeConditions();
        setCondition(GA202001Controller, false);
        for(SelectOption option : GA202001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件3'){
                GA202001Controller.selectCondName = option.getValue();
            }
        }
        GA202001Controller.changeConditions();
        setCondition(GA202001Controller, true);
        for(SelectOption option : GA202001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件4'){
                GA202001Controller.selectCondName = option.getValue();
            }
        } 
        GA202001Controller.changeConditions();
        setCondition(GA202001Controller, false);
        GA202001Controller.save();

        // 更新登録確認「物件条件が3件」
        checkAccountPropertyConditionsObj(AccountRecord.Id, 'update');
    }
    
    // 削除No29
    @isTest static void delete29Test(){
        insertAPC_1();
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ

        for(SelectOption option : GA202001Controller.AccountPropertyConditions){
            if(option.getLabel() == '条件2'){
                GA202001Controller.selectCondName = option.getValue();
            }
        }
        GA202001Controller.changeConditions();
        // 削除ボタン押下処理
        GA202001Controller.deletePropertyCond();
        GA202001Controller.save();

        // 削除登録確認　お客様物件条件が登録されている
        List<AccountPropertyConditions__c> apcList = [SELECT ID FROM AccountPropertyConditions__c];
        system.assertEquals(0, apcList.size());
    }

    // 削除No30
    @isTest static void delete30Test(){
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        // 条件を追加
        GA202001Controller.addPropertyCond();
        // 削除ボタン押下処理
        GA202001Controller.deletePropertyCond();
        // 保存ボタン押下処理
        GA202001Controller.save();

        // 削除登録確認　お客様物件条件が登録されていない
        List<AccountPropertyConditions__c> apcList = [SELECT ID FROM AccountPropertyConditions__c];
        system.assertEquals(0, apcList.size());
    }

    // ROLLBACKNo32
    @isTest static void rollback32Test(){
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        // 来店理由でエラーとなる値を設定する。
        GA202001Controller.displayVisitCard.visitReason = 'rollback';

        // 保存前の最終更新日を取得　取引先、来店カード、希望路線、希望駅、希望学区、希望学校
        Account accBefore = [SELECT LastModifiedDate FROM Account ORDER BY LastModifiedDate DESC LIMIT 1]; // 取引先
        VisitCard__c visitBefore = [SELECT LastModifiedDate FROM VisitCard__c ORDER BY LastModifiedDate DESC LIMIT 1]; // 来店カード
        DesiredTrainRoute__c routeBefore = [SELECT LastModifiedDate FROM DesiredTrainRoute__c ORDER BY LastModifiedDate DESC LIMIT 1]; // 希望路線
        DesiredStation__c stationBefore = [SELECT LastModifiedDate FROM DesiredStation__c ORDER BY LastModifiedDate DESC LIMIT 1]; // 希望駅
        DesiredSchoolArea__c schoolAreaBefore = [SELECT LastModifiedDate FROM DesiredSchoolArea__c ORDER BY LastModifiedDate DESC LIMIT 1]; // 希望学区
        DesiredSchool__c schoolBefore = [SELECT LastModifiedDate FROM DesiredSchool__c ORDER BY LastModifiedDate DESC LIMIT 1]; // 希望学校追加

        GA202001Controller.save();
        
        // ロールバック確認
        // お客様物件条件
        List<AccountPropertyConditions__c> apcList = [SELECT ID FROM AccountPropertyConditions__c];
        system.assertEquals(0, apcList.size());

        // 保存後の最終更新日を取得　取引先、来店カード、希望路線、希望駅、希望学区、希望学校
        Account accAfter = [SELECT LastModifiedDate FROM Account ORDER BY LastModifiedDate DESC LIMIT 1]; // 取引先
        VisitCard__c visitAfter = [SELECT LastModifiedDate FROM VisitCard__c ORDER BY LastModifiedDate DESC LIMIT 1]; // 来店カード
        DesiredTrainRoute__c routeAfter = [SELECT LastModifiedDate FROM DesiredTrainRoute__c ORDER BY LastModifiedDate DESC LIMIT 1]; // 希望路線
        DesiredStation__c stationAfter = [SELECT LastModifiedDate FROM DesiredStation__c ORDER BY LastModifiedDate DESC LIMIT 1]; // 希望駅
        DesiredSchoolArea__c schoolAreaAfter = [SELECT LastModifiedDate FROM DesiredSchoolArea__c ORDER BY LastModifiedDate DESC LIMIT 1]; // 希望学区
        DesiredSchool__c schoolAfter = [SELECT LastModifiedDate FROM DesiredSchool__c ORDER BY LastModifiedDate DESC LIMIT 1]; // 希望学校追加
        
        // 保存前から更新されていないことを確認する
        system.assertEquals(accBefore.LastModifiedDate, accAfter.LastModifiedDate);
        system.assertEquals(visitBefore.LastModifiedDate, visitAfter.LastModifiedDate);
        system.assertEquals(routeBefore.LastModifiedDate, routeAfter.LastModifiedDate);
        system.assertEquals(stationBefore.LastModifiedDate, stationAfter.LastModifiedDate);
        system.assertEquals(schoolAreaBefore.LastModifiedDate, schoolAreaAfter.LastModifiedDate);
        system.assertEquals(schoolBefore.LastModifiedDate, schoolAfter.LastModifiedDate);


    }

    //希望路線登録No33
    @isTest static void insertTrainRoute33Test(){
        List<TrainRoute__c> trainRouteList = [SELECT Id, Name FROM TrainRoute__c];
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c];
        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.displayCond.trainRoute1 = trainRouteList[0].id;
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        setCondition(GA202001Controller, false);
        // 路線１
        GA202001Controller.openStations1Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA202001Controller.closeModal();
        GA202001Controller.save();
        
        List<DesiredStation__c> dsList = [SELECT id FROM DesiredStation__c];
        List<DesiredTrainRoute__c> dtList = [SELECT id FROM DesiredTrainRoute__c];
        //  「取引先以外の物件条件が0件」＆「希望路線が１件」
        system.assertEquals(3, dtList.size());
        system.assertEquals(3, dsList.size());
    }

    //希望路線登録No34
    @isTest static void insertTrainRoute34Test(){
        deleteVisitCard();
        List<TrainRoute__c> trainRouteList = [SELECT Id, Name FROM TrainRoute__c];
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c];

        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
    
        setCondition(GA202001Controller, false);
        GA202001Controller.displayVisitCard.displayCond.trainRoute1 = trainRouteList[0].id;
        GA202001Controller.openStations1Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA202001Controller.closeModal();
        GA202001Controller.displayVisitCard.displayCond.trainRoute2 = trainRouteList[0].id;
        GA202001Controller.openStations2Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[1]);
        GA202001Controller.closeModal();
        GA202001Controller.displayVisitCard.displayCond.trainRoute3 = trainRouteList[0].id;
        GA202001Controller.openStations3Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[2]);
        GA202001Controller.closeModal();
        GA202001Controller.save();
        
        //  希望路線・希望駅の登録確認　「取引先以外の物件条件が0件」＆「希望路線が3件」
        List<DesiredStation__c> dsList = [SELECT id FROM DesiredStation__c];
        List<DesiredTrainRoute__c> dtList = [SELECT id FROM DesiredTrainRoute__c];
        System.assertEquals(9, dtList.size());
        system.assertEquals(9, dsList.size());
    }

    //希望路線登録No35
    @isTest static void insertTrainRoute35Test(){
        List<TrainRoute__c> trainRouteList = [SELECT Id, Name FROM TrainRoute__c];
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c];
        
        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.addPropertyCond();
        GA202001Controller.displayVisitCard.displayCond.trainRoute1 = trainRouteList[0].id;
        setCondition(GA202001Controller, false);
        // 路線１
        GA202001Controller.openStations1Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA202001Controller.closeModal();
        GA202001Controller.save();

        //  希望路線・希望駅の登録確認　「取引先以外の物件条件が1件」＆「希望路線が１件」
        List<DesiredStation__c> dsList = [SELECT id FROM DesiredStation__c];
        List<DesiredTrainRoute__c> dtList = [SELECT id FROM DesiredTrainRoute__c];
        System.assertEquals(3, dtList.size());
        system.assertEquals(3, dsList.size());
    }

    //希望路線登録No36
    @isTest static void insertTrainRoute36Test(){
        List<TrainRoute__c> trainRouteList = [SELECT Id, Name FROM TrainRoute__c];
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c];

        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, false);
        GA202001Controller.addPropertyCond();
        GA202001Controller.displayVisitCard.displayCond.trainRoute1 = trainRouteList[0].id;
        setCondition(GA202001Controller, false);

        GA202001Controller.openStations1Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA202001Controller.closeModal();
        GA202001Controller.displayVisitCard.displayCond.trainRoute2 = trainRouteList[0].id;
        GA202001Controller.openStations2Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[1]);
        GA202001Controller.closeModal();
        GA202001Controller.displayVisitCard.displayCond.trainRoute3 = trainRouteList[0].id;
        GA202001Controller.openStations3Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[2]);
        GA202001Controller.closeModal();

        // 保存処理
        GA202001Controller.save();
        
        //  希望路線・希望駅の登録確認　「取引先以外の物件条件が1件」＆「希望路線が3件」
        List<DesiredStation__c> dsList = [SELECT id FROM DesiredStation__c];
        List<DesiredTrainRoute__c> dtList = [SELECT id FROM DesiredTrainRoute__c];
        System.assertEquals(6, dtList.size());
        system.assertEquals(6, dsList.size());
    }

    //希望路線登録No37
    @isTest static void insertTrainRoute37Test(){
        List<TrainRoute__c> trainRouteList = [SELECT Id, Name FROM TrainRoute__c];
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c];

        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
    
        setCondition(GA202001Controller, false);
        GA202001Controller.addPropertyCond();
        setCondition(GA202001Controller, false);
        GA202001Controller.displayVisitCard.displayCond.trainRoute1 = trainRouteList[0].id;
        GA202001Controller.openStations1Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA202001Controller.closeModal();

        // 物件条件を追加して、希望路線・希望駅を設定する。
        GA202001Controller.addPropertyCond();
        GA202001Controller.displayVisitCard.displayCond.trainRoute1 = trainRouteList[0].id;
        setCondition(GA202001Controller, false);
        GA202001Controller.openStations1Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA202001Controller.closeModal();

        // 保存処理
        GA202001Controller.save();
        
        //  希望路線・希望駅の登録確認　「取引先以外の物件条件が2件」＆「希望路線が１件」
        List<DesiredStation__c> dsList = [SELECT id FROM DesiredStation__c];
        List<DesiredTrainRoute__c> dtList = [SELECT id FROM DesiredTrainRoute__c];
        System.assertEquals(5, dtList.size());
        system.assertEquals(5, dsList.size());
    }

    //希望路線登録No38
    @isTest static void insertTrainRoute38Test(){
        List<TrainRoute__c> trainRouteList = [SELECT Id, Name FROM TrainRoute__c];
        List<Station__c> stationList = [SELECT Id, Name FROM Station__c];

        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, false);
        GA202001Controller.addPropertyCond();
        GA202001Controller.displayVisitCard.displayCond.trainRoute1 = trainRouteList[0].id;
        setCondition(GA202001Controller, false);

        GA202001Controller.openStations1Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA202001Controller.closeModal();
        GA202001Controller.displayVisitCard.displayCond.trainRoute2 = trainRouteList[0].id;
        GA202001Controller.openStations2Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[1]);
        GA202001Controller.closeModal();
        GA202001Controller.displayVisitCard.displayCond.trainRoute3 = trainRouteList[0].id;
        GA202001Controller.openStations3Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[2]);
        GA202001Controller.closeModal();

        // 物件条件を追加して、希望路線・希望駅を設定する。
        GA202001Controller.addPropertyCond();
        GA202001Controller.displayVisitCard.displayCond.trainRoute1 = trainRouteList[0].id;
        setCondition(GA202001Controller, false);
        GA202001Controller.openStations1Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[0]);
        GA202001Controller.closeModal();
        GA202001Controller.displayVisitCard.displayCond.trainRoute2 = trainRouteList[0].id;
        GA202001Controller.openStations2Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[1]);
        GA202001Controller.closeModal();
        GA202001Controller.displayVisitCard.displayCond.trainRoute3 = trainRouteList[0].id;
        GA202001Controller.openStations3Modal();
        GA202001Controller.GA104007Parameter.selectedStation.add(stationList[2]);
        GA202001Controller.closeModal();

        // 保存処理
        GA202001Controller.save();
        
        //  希望路線・希望駅の登録確認　「取引先以外の物件条件が2件」＆「希望路線が3件」
        List<DesiredStation__c> dsList = [SELECT id FROM DesiredStation__c];
        List<DesiredTrainRoute__c> dtList = [SELECT id FROM DesiredTrainRoute__c];
        System.assertEquals(9, dtList.size());
        system.assertEquals(9, dsList.size());
    }
    
    //希望学区登録No39
    @isTest static void insertSchoolArea39Test(){
        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, false);
        GA202001Controller.displayVisitCard.displayCond.juniorHighSchoolArea = '港区';
        
        // 中学校を設定
        GA202001Controller.openJuniorHighSchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA202001Controller.closeModal();
        GA202001Controller.save();
        
        //  希望学区・希望学校登録確認　取引先以外の物件条件が0件状態で、中学校区・中学校のみを設定し登録を行う。
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        system.assertEquals(4, dsaList.size());
        system.assertEquals(4, dsList.size());
    }

    //希望学区登録No40
    @isTest static void insertSchoolArea40Test(){
        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, false);
        GA202001Controller.displayVisitCard.displayCond.elementarySchoolArea = '港区';

        // 小学校を設定
        GA202001Controller.openElementarySchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[1]);
        GA202001Controller.closeModal();
        GA202001Controller.save();
        
        //  希望学区・希望学校登録確認　「取引先以外の物件条件が0件」＆「小学校区のみ入力された状態」
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        system.assertEquals(4, dsaList.size());
        system.assertEquals(4, dsList.size());
    }

    //希望学区登録No41
    @isTest static void insertSchoolArea41Test(){
        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, false);
        GA202001Controller.displayVisitCard.displayCond.juniorHighSchoolArea = '港区';
        GA202001Controller.displayVisitCard.displayCond.elementarySchoolArea = '港区';

        // 中学校を設定
        GA202001Controller.openJuniorHighSchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA202001Controller.closeModal();
        // 小学校を設定
        GA202001Controller.openElementarySchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[1]);
        GA202001Controller.closeModal();
        GA202001Controller.save();
        
        //  希望学区・希望学校登録確認　「取引先以外の物件条件が0件」＆「中学校区・小学校区の両方入力された状態」
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        system.assertEquals(6, dsaList.size());
        system.assertEquals(6, dsList.size());
    }

    //希望学区登録No42
    @isTest static void insertSchoolArea42Test(){
        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, false);
        GA202001Controller.addPropertyCond();
        setCondition(GA202001Controller, false);
        GA202001Controller.displayVisitCard.displayCond.juniorHighSchoolArea = '港区';
        
        // 中学校を設定
        GA202001Controller.openJuniorHighSchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA202001Controller.closeModal();
        GA202001Controller.save();
        
        //  希望学区・希望学校登録確認　「取引先以外の物件条件が1件」＆「中学校区のみ入力された状態」
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        system.assertEquals(3, dsaList.size());
        system.assertEquals(3, dsList.size());
    }

    //希望学区登録No43
    @isTest static void insertSchoolArea43Test(){
        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, false);
        GA202001Controller.addPropertyCond();
        setCondition(GA202001Controller, false);
        GA202001Controller.displayVisitCard.displayCond.elementarySchoolArea = '港区';

        // 小学校を設定
        GA202001Controller.openElementarySchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[1]);
        GA202001Controller.closeModal();
        GA202001Controller.save();
        
        //  希望学区・希望学校登録確認　「取引先以外の物件条件が1件」＆「小学校区のみ入力された状態」
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        system.assertEquals(3, dsaList.size());
        system.assertEquals(3, dsList.size());
    }

    //希望学区登録No44
    @isTest static void insertSchoolArea44Test(){
        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, false);
        GA202001Controller.addPropertyCond();
        setCondition(GA202001Controller, false);
        GA202001Controller.displayVisitCard.displayCond.juniorHighSchoolArea = '港区';
        GA202001Controller.displayVisitCard.displayCond.elementarySchoolArea = '港区';

        // 中学校を設定
        GA202001Controller.openJuniorHighSchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA202001Controller.closeModal();
        // 小学校を設定
        GA202001Controller.openElementarySchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[1]);
        GA202001Controller.closeModal();
        GA202001Controller.save();
        
        //  希望学区・希望学校登録確認　「取引先以外の物件条件が1件」＆「中学校区・小学校区の両方入力された状態」
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        system.assertEquals(4, dsaList.size());
        system.assertEquals(4, dsList.size());
    }

    //希望学区登録No45
    @isTest static void insertSchoolArea45Test(){
        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, false);
        GA202001Controller.addPropertyCond();
        setCondition(GA202001Controller, false);
        GA202001Controller.displayVisitCard.displayCond.juniorHighSchoolArea = '港区';
        // 中学校を設定
        GA202001Controller.openJuniorHighSchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA202001Controller.closeModal();

        // 物件条件を追加して中学校を設定
        GA202001Controller.addPropertyCond();
        GA202001Controller.displayVisitCard.displayCond.juniorHighSchoolArea = '港区';
        setCondition(GA202001Controller, false);
        GA202001Controller.openJuniorHighSchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA202001Controller.closeModal();

        GA202001Controller.save();
        
        //  希望学区・希望学校登録確認　物件条件2件、中学校区のみ
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        system.assertEquals(4, dsaList.size());
        system.assertEquals(4, dsList.size());
    }

    //希望学区登録No46
    @isTest static void insertSchoolArea46Test(){
        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];

        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, false);
        GA202001Controller.addPropertyCond();
        setCondition(GA202001Controller, false);
        GA202001Controller.displayVisitCard.displayCond.elementarySchoolArea = '港区';
        // 小学校を設定
        GA202001Controller.openElementarySchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA202001Controller.closeModal();

        // 物件条件を追加して小学校を設定
        GA202001Controller.addPropertyCond();
        GA202001Controller.displayVisitCard.displayCond.elementarySchoolArea = '港区';
        setCondition(GA202001Controller, false);
        GA202001Controller.openElementarySchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA202001Controller.closeModal();

        GA202001Controller.save();
        
        //  希望学区・希望学校登録確認　「取引先以外の物件条件が2件」＆「中学校区のみ入力された状態」
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        system.assertEquals(4, dsaList.size());
        system.assertEquals(4, dsList.size());
    }

    //希望学区登録No47
    @isTest static void insertSchoolArea47Test(){
        List<School__c> schoolList = [SELECT Id, City__c, Name FROM School__c];        

        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '025-200-1234'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, false);
        GA202001Controller.addPropertyCond();
        setCondition(GA202001Controller, false);
        GA202001Controller.displayVisitCard.displayCond.juniorHighSchoolArea = '港区';
        GA202001Controller.displayVisitCard.displayCond.elementarySchoolArea = '港区';
        
        // 中学校を設定
        GA202001Controller.openJuniorHighSchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA202001Controller.closeModal();
        // 小学校を設定
        GA202001Controller.openElementarySchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[1]);
        GA202001Controller.closeModal();

        // 物件条件を追加して中学校・小学校を設定
        GA202001Controller.addPropertyCond();
        setCondition(GA202001Controller, false);
        GA202001Controller.displayVisitCard.displayCond.juniorHighSchoolArea = '港区';
        GA202001Controller.displayVisitCard.displayCond.elementarySchoolArea = '港区';
        // 中学校を設定
        GA202001Controller.openJuniorHighSchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[0]);
        GA202001Controller.closeModal();
        // 小学校を設定
        GA202001Controller.openElementarySchoolDistrictModal();
        GA202001Controller.GA202002Parameter.selectedSchool.add(schoolList[1]);
        GA202001Controller.closeModal();

        GA202001Controller.save();
        
        //  希望学区・希望学校登録確認　物件条件2件、小学校区・中学校区の両方を設定
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];
        List<DesiredSchool__c> dsList = [SELECT id FROM DesiredSchool__c];
        system.assertEquals(6, dsaList.size());
        system.assertEquals(6, dsList.size());
    }


    //状況毎の登録No48
    @isTest static void statusRegister48Test(){
        // コントローラの初期表示を実行
        deleteAccount();
        deleteVisitCard();
        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '1111111111'; //電話番号
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        setCondition(GA202001Controller, true);
        GA202001Controller.save();

        // 新規顧客の登録確認
        List<Account> AccountRecord = [SELECT ID, Name FROM Account];
        List<VisitCard__c> VisitCard = [SELECT ID FROM VisitCard__c];
        system.assertEquals(1, AccountRecord.size());
        system.assertEquals(1, VisitCard.size());
    }

    //状況毎の登録No49
    @isTest static void statusRegister49Test(){
        deleteVisitCard();
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];

        //パラメータ設定
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '1111'; //電話番号を変更
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, true);
        GA202001Controller.save();

        // 【既存顧客＆新規来店】の登録確認
        List<Account> AccountRecordList = [SELECT ID FROM Account WHERE phone = '1111'];
        List<VisitCard__c> VisitCard = [SELECT ID FROM VisitCard__c];
        system.assertEquals(1, AccountRecordList.size());
        system.assertEquals(1, VisitCard.size());
    }

    //状況毎の登録No50
    @isTest static void statusRegister50Test(){
        Account AccountRecord = [SELECT ID
                                        ,(SELECT ID
                                            FROM VisitsCardAccount__r
                                            ORDER BY SystemModstamp DESC
                                            LIMIT 1
                                        )
                                    FROM ACCOUNT WHERE NAME = 'テスト太郎'];

        Correspond__c correspond = [SELECT ID
                                        FROM Correspond__c 
                                        WHERE AccountId__c = :AccountRecord.Id];
        PageReference pageRef = Page.GA202001View;
        pageRef.getParameters().put('acc',AccountRecord.Id );
        pageRef.getParameters().put('Corresponds',correspond.Id );
        Test.setCurrentPage(pageRef);
        // コントローラの初期表示を実行
        GA202001Controller GA202001Controller = new GA202001Controller();
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.email = 'bbb@hora'; //名寄せ確認の為、メールアドレス書き換え
        GA202001Controller.displayVisitCard.phone = '1111'; //電話番号はそのまま
        GA202001Controller.displayVisitCard.visitReason = '予約'; //来店理由
        GA202001Controller.displayVisitCard.visiterLastName = '名'; //名前（名）
        GA202001Controller.displayVisitCard.visiterFirstName = '姓'; //名前（姓）
        GA202001Controller.displayVisitCard.visiterLastNameKana = 'フリガナ'; //フリガナ
        setCondition(GA202001Controller, true);
		GA202001Controller.addPropertyCond();
        setCondition(GA202001Controller, true);
        GA202001Controller.save();

        // 【既存顧客＆来店カード作成済みの場合】の登録確認
        List<Account> AccountRecordList = [SELECT ID FROM Account];
        List<VisitCard__c> VisitCard = [SELECT ID FROM VisitCard__c];
        List<AccountPropertyConditions__c> apcList = [SELECT ID FROM AccountPropertyConditions__c];
        system.assertEquals(1, AccountRecordList.size());
        system.assertEquals(1, VisitCard.size());
        system.assertEquals(1, apcList.size());
    }

	// 取引先.物件条件名NULLの初期表示
	@isTest static void initAccountPropetyConditionsNameNullCheck(){
		deleteVisitCard();
		Account AccountRecord = [SELECT ID
										,(SELECT ID
											FROM VisitsCardAccount__r
											ORDER BY SystemModstamp DESC
											LIMIT 1
										)
									FROM ACCOUNT WHERE NAME = 'テスト太郎'];
		AccountRecord.PropertyConditionsName__c = null;
		upsert AccountRecord;
		Correspond__c correspond = [SELECT ID
										FROM Correspond__c 
										WHERE AccountId__c = :AccountRecord.Id];
		
		
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

		//パラメータ設定
		PageReference pageRef = Page.GA202001View;
		pageRef.getParameters().put('acc',AccountRecord.Id );
		pageRef.getParameters().put('Corresponds',correspond.Id );
		Test.setCurrentPage(pageRef);
		// コントローラの初期表示を実行
		GA202001Controller GA202001Controller = new GA202001Controller();
		// 初期表示【既存顧客＆新規来店】
		checkdisplayCond(GA202001Controller, true, '条件1', '19');
	}

    // 物件条件を設定
    static void setCondition(GA202001Controller con, Boolean bool){
        if(bool){
            con.displayVisitCard.displayCond.buildingAge = '999';
            con.displayVisitCard.displayCond.carCount = '99';
            con.displayVisitCard.displayCond.desiredArea = '希望地域';
            con.displayVisitCard.displayCond.occupancyAreaLowerLimit = '0';
            con.displayVisitCard.displayCond.occupancyAreaUpperLimit = '999';
            con.displayVisitCard.displayCond.parkingFeeLimit = '9,999';
            con.displayVisitCard.displayCond.rentFeeFrom = '9,999';
            con.displayVisitCard.displayCond.rentFeeTo = '9,999';
            con.displayVisitCard.displayCond.walkingTime = '999';
            
        }else{
            con.displayVisitCard.displayCond.AccountPropertyConditionsTrainRoute1 = null;
            con.displayVisitCard.displayCond.AccountPropertyConditionsTrainRoute2 = null;
            con.displayVisitCard.displayCond.AccountPropertyConditionsTrainRoute3 = null;
            con.displayVisitCard.displayCond.AccountPropertyConditionsElementarySchoolArea = null;
            con.displayVisitCard.displayCond.AccountPropertyConditionsJuniorHighSchoolArea = null;
            con.displayVisitCard.displayCond.buildingAge = null;
            con.displayVisitCard.displayCond.carCount = null;
            con.displayVisitCard.displayCond.desiredArea = null;
            con.displayVisitCard.displayCond.occupancyAreaLowerLimit = null;
            con.displayVisitCard.displayCond.occupancyAreaUpperLimit = null;
            con.displayVisitCard.displayCond.parkingFeeLimit = null;
            con.displayVisitCard.displayCond.rentFeeFrom = null;
            con.displayVisitCard.displayCond.rentFeeTo = null;
            con.displayVisitCard.displayCond.walkingTime = null;
            con.displayVisitCard.displayCond.walkingTime = null;
        }

        con.displayVisitCard.displayCond.isIncludeManagementFee = bool;//管理費込み 
        con.displayVisitCard.displayCond.isIncludeParkingFee = bool;//駐車場代込み 
        con.displayVisitCard.displayCond.isOneRoom = bool;//ワンルーム 
        con.displayVisitCard.displayCond.is1K = bool;//1K 
        con.displayVisitCard.displayCond.is1DK = bool;//1DK 
        con.displayVisitCard.displayCond.is1LDK1SLDK = bool;//1LDK/SLDK 
        con.displayVisitCard.displayCond.is2K2DK = bool;//2K/DK 
        con.displayVisitCard.displayCond.is2LDK2SLDK = bool;//2LDK/SLDK 
        con.displayVisitCard.displayCond.is3K3DK = bool;//3K/DK 
        con.displayVisitCard.displayCond.is3LDK3SLDK = bool;//3LDK/SLDK 
        con.displayVisitCard.displayCond.is4K4DK4LDKFrom = bool;//4K/DK/LDK~ 
        con.displayVisitCard.displayCond.isWooden = bool;//木造 
        con.displayVisitCard.displayCond.isLightweightSteel = bool;//軽量鉄骨 
        con.displayVisitCard.displayCond.isSteel = bool;//鉄骨造 
        con.displayVisitCard.displayCond.isRC = bool;//RC 
        con.displayVisitCard.displayCond.isSRC = bool;//SRC 
        con.displayVisitCard.displayCond.isNorth = bool;//北 
        con.displayVisitCard.displayCond.isNorthEast = bool;//北東 
        con.displayVisitCard.displayCond.isEast = bool;//東 
        con.displayVisitCard.displayCond.isSouthEast = bool;//南東 
        con.displayVisitCard.displayCond.isSouth = bool;//南 
        con.displayVisitCard.displayCond.isSouthWest = bool;//南西 
        con.displayVisitCard.displayCond.isWest = bool;//西 
        con.displayVisitCard.displayCond.isNorthWest = bool;//北西 
        con.displayVisitCard.displayCond.isNonDeposit = bool;//敷金/保証金なし 
        con.displayVisitCard.displayCond.isNonKeyMoney = bool;//礼金なし 
        con.displayVisitCard.displayCond.isNonCleaningFee = bool;//定額修繕費なし 
        con.displayVisitCard.displayCond.isNonRenewalFee = bool;//更新料なし 
        con.displayVisitCard.displayCond.isDetachedHouse = bool;//戸建て 
        con.displayVisitCard.displayCond.isMaisonette = bool;//メゾネット 
        con.displayVisitCard.displayCond.isLoft = bool;//ロフト 
        con.displayVisitCard.displayCond.isDesigners = bool;//デザイナーズ 
        con.displayVisitCard.displayCond.isRenovation = bool;//リノベーション 
        con.displayVisitCard.displayCond.isCondominiumRental = bool;//分譲賃貸 
        con.displayVisitCard.displayCond.isAllWestern = bool;//オール洋間 
        con.displayVisitCard.displayCond.isFirstFloor = bool;//1階 
        con.displayVisitCard.displayCond.isSecondFloorOver = bool;//2階以上 
        con.displayVisitCard.displayCond.isTopFloor = bool;//最上階 
        con.displayVisitCard.displayCond.isCornerRoom = bool;//角部屋 
        con.displayVisitCard.displayCond.isBalcony = bool;//バルコニー 
        con.displayVisitCard.displayCond.isRoofBalcony = bool;//ルーフバルコニー 
        con.displayVisitCard.displayCond.isPrivateGarden = bool;//専用庭 
        con.displayVisitCard.displayCond.isParking = bool;//駐車場空きあり 
        con.displayVisitCard.displayCond.isInSiteParking = bool;//敷地内駐車場 
        con.displayVisitCard.displayCond.isPluralCarParking = bool;//駐車場2台可 
        con.displayVisitCard.displayCond.isBuiltInGarage = bool;//ビルトインガレージ 
        con.displayVisitCard.displayCond.isCarport = bool;//カーポート 
        con.displayVisitCard.displayCond.isBicycleParking = bool;//駐輪場 
        con.displayVisitCard.displayCond.isBikeStorage = bool;//バイク可 
        con.displayVisitCard.displayCond.isSmallBike = bool;//小型バイク 
        con.displayVisitCard.displayCond.isMediumBike = bool;//中型バイク 
        con.displayVisitCard.displayCond.isLargeBike = bool;//大型バイク 
        con.displayVisitCard.displayCond.isElevator = bool;//エレベーター 
        con.displayVisitCard.displayCond.isDeliveryBox = bool;//宅配ボックス 
        con.displayVisitCard.displayCond.isCounterKitchen = bool;//カウンターキッチン 
        con.displayVisitCard.displayCond.isSystemKitchen = bool;//システムキッチン 
        con.displayVisitCard.displayCond.isGasStove = bool;//ガスコンロ 
        con.displayVisitCard.displayCond.isElectricStove = bool;//電気コンロ 
        con.displayVisitCard.displayCond.isInductionHeating = bool;//IHコンロ 
        con.displayVisitCard.displayCond.isTwoGasStove = bool;//コンロ2口 
        con.displayVisitCard.displayCond.isMoreGasStove = bool;//コンロ3口以上 
        con.displayVisitCard.displayCond.isSepalateBathAndRestroom = bool;//バス・トイレ別 
        con.displayVisitCard.displayCond.isAditionalBoiling = bool;//追焚機能 
        con.displayVisitCard.displayCond.isDehumidifierForBathroom = bool;//浴室乾燥機 
        con.displayVisitCard.displayCond.isWashlet = bool;//温水洗浄便座 
        con.displayVisitCard.displayCond.isShowerWashBasin = bool;//シャワー付き洗面台 
        con.displayVisitCard.displayCond.isRegalLavatory = bool;//洗面所独立 
        con.displayVisitCard.displayCond.isInnerLandry = bool;//室内洗濯機置場 
        con.displayVisitCard.displayCond.isTownGas = bool;//都市ガス 
        con.displayVisitCard.displayCond.isPropaneGas = bool;//プロパンガス 
        con.displayVisitCard.displayCond.isAllElectric = bool;//オール電化 
        con.displayVisitCard.displayCond.isAirConditioner = bool;//エアコン 
        con.displayVisitCard.displayCond.isFloorHeating = bool;//床暖房 
        con.displayVisitCard.displayCond.isShoesBox = bool;//シューズボックス 
        con.displayVisitCard.displayCond.isShoeCloak = bool;//シューズクローク 
        con.displayVisitCard.displayCond.isWalkInCloset = bool;//ウォークインクローゼット 
        con.displayVisitCard.displayCond.isTrunkRoom = bool;//トランクルーム 
        con.displayVisitCard.displayCond.isBSAntenna = bool;//BSアンテナ 
        con.displayVisitCard.displayCond.isCSAntenna = bool;//CSアンテナ 
        con.displayVisitCard.displayCond.isCATV = bool;//CATV 
        con.displayVisitCard.displayCond.isInternetFree = bool;//ネット使用料無料 
        con.displayVisitCard.displayCond.isMonitorIntercom = bool;//モニター付きインターホン 
        con.displayVisitCard.displayCond.isAutoLock = bool;//オートロック 
        con.displayVisitCard.displayCond.isFurniture = bool;//家具付き 
        con.displayVisitCard.displayCond.isHomeAppliance = bool;//家電付き 
        con.displayVisitCard.displayCond.isNoGuarantor = bool;//保証人不要 
        con.displayVisitCard.displayCond.isNonGuaranteeidCompany = bool;//保証会社不要 
        con.displayVisitCard.displayCond.isMusicalInstruments = bool;//楽器相談可 
        con.displayVisitCard.displayCond.isForeigner = bool;//外国人契約可 
        con.displayVisitCard.displayCond.isOfficeAvailable = bool;//事務所利用可 
        con.displayVisitCard.displayCond.isWelfareAvailable = bool;//生活保護契約可 
        con.displayVisitCard.displayCond.isPet = bool;//ペット可 
        con.displayVisitCard.displayCond.isLargePet = bool;//ペット(大型犬) 
        con.displayVisitCard.displayCond.isMiddlePet = bool;//ペット(中型犬) 
        con.displayVisitCard.displayCond.isSmallPet = bool;//ペット(小型犬) 
        con.displayVisitCard.displayCond.isCat = bool;//ペット(猫) 
        con.displayVisitCard.displayCond.isOtherPet = bool;//ペット(その他) 
        con.displayVisitCard.displayCond.isTwoTenant = bool;//2人入居可 
        con.displayVisitCard.displayCond.isRoomShare = bool;//ルームシェア可 
        con.displayVisitCard.displayCond.isIppambutsu = bool;//一般物 
        con.displayVisitCard.displayCond.isElderly = bool;//高齢者歓迎 
        con.displayVisitCard.displayCond.isWoman = bool;//女性限定 
        con.displayVisitCard.displayCond.isStudent = bool;//学生限定マンション
    }

    // 取引先削除
    static void deleteAccount(){
        Set<Id> ids = new Set<Id>();
        List<Account> accList = [SELECT ID FROM Account];
        for(Account acc : accList){
            ids.add(acc.id);
        }
        List<Account> accDelList = [SELECT ID FROM Account WHERE id =:ids];
        delete accDelList;
    }

    static void deleteVisitCard(){
        Set<Id> ids = new Set<Id>();
        List<VisitCard__c> vcList = [SELECT ID FROM VisitCard__c];
        for(VisitCard__c vc : vcList){
            ids.add(vc.id);
        }
        List<VisitCard__c> vcDelList = [SELECT ID FROM VisitCard__c WHERE id =:ids];
        delete vcDelList;
    }

    // 表示の内容を確認する。
    static void checkdisplayCond(GA202001Controller controller, Boolean bool, String apcName, String status){

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
            system.assertEquals(null, controller.displayVisitCard.displayCond.trainRoute1Name); //希望沿線１．路線
            system.assertEquals(null, controller.displayVisitCard.displayCond.trainRoute2Name); //希望沿線２．路線
            system.assertEquals(null, controller.displayVisitCard.displayCond.trainRoute3Name); //希望沿線３．路線
            system.assertEquals('', controller.displayVisitCard.displayCond.stationsChar1); //駅１文字列
            system.assertEquals('', controller.displayVisitCard.displayCond.stationsChar2); //駅２文字列
            system.assertEquals('', controller.displayVisitCard.displayCond.stationsChar3); //駅３文字列

            system.assertEquals(null, controller.displayVisitCard.displayCond.juniorHighSchoolArea);//中学校希望学区(エリア).希望学区
            system.assertEquals(null, controller.displayVisitCard.displayCond.elementarySchoolArea);//小学校希望学区(エリア).希望学区
            system.assertEquals('', controller.displayVisitCard.displayCond.desiredJuniorHighSchool); //希望中学校
            system.assertEquals('', controller.displayVisitCard.displayCond.desiredPrimarySchool); //希望小学校

            system.assertEquals(apcName, controller.displayVisitCard.displayCond.Name); //物件条件名
            system.assertEquals(null, controller.displayVisitCard.displayCond.is1DK); //1DK
            system.assertEquals(null, controller.displayVisitCard.displayCond.is1K); //1K
            system.assertEquals(null, controller.displayVisitCard.displayCond.is1LDK1SLDK); //1LDK/SLDK
            system.assertEquals(null, controller.displayVisitCard.displayCond.isFirstFloor); //1階
            system.assertEquals(null, controller.displayVisitCard.displayCond.is2K2DK); //2K/DK
            system.assertEquals(null, controller.displayVisitCard.displayCond.is2LDK2SLDK); //2LDK/SLDK
            system.assertEquals(null, controller.displayVisitCard.displayCond.isSecondFloorOver); //2階以上
            system.assertEquals(null, controller.displayVisitCard.displayCond.isTwoTenant); //2人入居可
            system.assertEquals(null, controller.displayVisitCard.displayCond.is3K3DK); //3K/DK
            system.assertEquals(null, controller.displayVisitCard.displayCond.is3LDK3SLDK); //3LDK/SLDK
            system.assertEquals(null, controller.displayVisitCard.displayCond.is4K4DK4LDKFrom); //4K/DK/LDK~
            system.assertEquals(null, controller.displayVisitCard.displayCond.isBSAntenna); //BSアンテナ
            system.assertEquals(null, controller.displayVisitCard.displayCond.isCATV); //CATV
            system.assertEquals(null, controller.displayVisitCard.displayCond.isCSAntenna); //CSアンテナ
            system.assertEquals(null, controller.displayVisitCard.displayCond.isInductionHeating); //IHコンロ
            system.assertEquals(null, controller.displayVisitCard.displayCond.isRC); //RC
            system.assertEquals(null, controller.displayVisitCard.displayCond.isSRC); //SRC
            system.assertEquals(null, controller.displayVisitCard.displayCond.isWalkInCloset); //ウォークインクローゼット
            system.assertEquals(null, controller.displayVisitCard.displayCond.isAirConditioner); //エアコン
            system.assertEquals(null, controller.displayVisitCard.displayCond.isElevator); //エレベーター
            system.assertEquals(null, controller.displayVisitCard.displayCond.isAutoLock); //オートロック
            system.assertEquals(null, controller.displayVisitCard.displayCond.isAllElectric); //オール電化
            system.assertEquals(null, controller.displayVisitCard.displayCond.isAllWestern); //オール洋間
            system.assertEquals(null, controller.displayVisitCard.displayCond.isCarport); //カーポート
            system.assertEquals(null, controller.displayVisitCard.displayCond.isCounterKitchen); //カウンターキッチン
            system.assertEquals(null, controller.displayVisitCard.displayCond.isGasStove); //ガスコンロ
            system.assertEquals(null, controller.displayVisitCard.displayCond.isTwoGasStove); //コンロ2口
            system.assertEquals(null, controller.displayVisitCard.displayCond.isMoreGasStove); //コンロ3口以上
            system.assertEquals(null, controller.displayVisitCard.displayCond.isSystemKitchen); //システムキッチン
            system.assertEquals(null, controller.displayVisitCard.displayCond.isShowerWashBasin); //シャワー付き洗面台
            system.assertEquals(null, controller.displayVisitCard.displayCond.isShoeCloak); //シューズクローク
            system.assertEquals(null, controller.displayVisitCard.displayCond.isShoesBox); //シューズボックス
            system.assertEquals(null, controller.displayVisitCard.displayCond.isDesigners); //デザイナーズ
            system.assertEquals(null, controller.displayVisitCard.displayCond.isTrunkRoom); //トランクルーム
            system.assertEquals(null, controller.displayVisitCard.displayCond.isInternetFree); //ネット使用料無料
            system.assertEquals(null, controller.displayVisitCard.displayCond.isBikeStorage); //バイク可
            system.assertEquals(null, controller.displayVisitCard.displayCond.isSepalateBathAndRestroom); //バス・トイレ別
            system.assertEquals(null, controller.displayVisitCard.displayCond.isBalcony); //バルコニー
            system.assertEquals(null, controller.displayVisitCard.displayCond.isBuiltInGarage); //ビルトインガレージ
            system.assertEquals(null, controller.displayVisitCard.displayCond.isPropaneGas); //プロパンガス
            system.assertEquals(null, controller.displayVisitCard.displayCond.isOtherPet); //ペット(その他)
            system.assertEquals(null, controller.displayVisitCard.displayCond.isSmallPet); //ペット(小型犬)
            system.assertEquals(null, controller.displayVisitCard.displayCond.isLargePet); //ペット(大型犬)
            system.assertEquals(null, controller.displayVisitCard.displayCond.isMiddlePet); //ペット(中型犬)
            system.assertEquals(null, controller.displayVisitCard.displayCond.isCat); //ペット(猫)
            system.assertEquals(null, controller.displayVisitCard.displayCond.isPet); //ペット可
            system.assertEquals(null, controller.displayVisitCard.displayCond.isMaisonette); //メゾネット
            system.assertEquals(null, controller.displayVisitCard.displayCond.isMonitorIntercom); //モニター付きインターホン
            system.assertEquals(null, controller.displayVisitCard.displayCond.isRenovation); //リノベーション
            system.assertEquals(null, controller.displayVisitCard.displayCond.isRoofBalcony); //ルーフバルコニー
            system.assertEquals(null, controller.displayVisitCard.displayCond.isRoomShare); //ルームシェア可
            system.assertEquals(null, controller.displayVisitCard.displayCond.isLoft); //ロフト
            system.assertEquals(null, controller.displayVisitCard.displayCond.isOneRoom); //ワンルーム
            system.assertEquals(null, controller.displayVisitCard.displayCond.isIppambutsu); //一般物
            system.assertEquals(null, controller.displayVisitCard.displayCond.isWashlet); //温水洗浄便座
            system.assertEquals(null, controller.displayVisitCard.displayCond.isFurniture); //家具付き
            system.assertEquals(null, controller.displayVisitCard.displayCond.isHomeAppliance); //家電付き
            system.assertEquals(null, controller.displayVisitCard.displayCond.isForeigner); //外国人契約可
            system.assertEquals(null, controller.displayVisitCard.displayCond.isCornerRoom); //角部屋
            system.assertEquals(null, controller.displayVisitCard.displayCond.isStudent); //学生限定マンション
            system.assertEquals(null, controller.displayVisitCard.displayCond.isMusicalInstruments); //楽器相談可
            system.assertEquals(null, controller.displayVisitCard.displayCond.isIncludeManagementFee); //管理費込み
            system.assertEquals(null, controller.displayVisitCard.displayCond.desiredArea); //希望地域
            system.assertEquals(null, controller.displayVisitCard.displayCond.isLightweightSteel); //軽量鉄骨
            system.assertEquals(null, controller.displayVisitCard.displayCond.isDetachedHouse); //戸建て
            system.assertEquals(null, controller.displayVisitCard.displayCond.isNonRenewalFee); //更新料なし
            system.assertEquals(null, controller.displayVisitCard.displayCond.isElderly); //高齢者歓迎
            system.assertEquals(null, controller.displayVisitCard.displayCond.isTopFloor); //最上階
            system.assertEquals(null, controller.displayVisitCard.displayCond.isOfficeAvailable); //事務所利用可
            system.assertEquals(null, controller.displayVisitCard.displayCond.isInnerLandry); //室内洗濯機置場
            system.assertEquals(null, controller.displayVisitCard.displayCond.isWoman); //女性限定
            system.assertEquals(null, controller.displayVisitCard.displayCond.isSmallBike); //小型バイク
            system.assertEquals(null, controller.displayVisitCard.displayCond.isFloorHeating); //床暖房
            system.assertEquals(null, controller.displayVisitCard.displayCond.isWelfareAvailable); //生活保護契約可
            system.assertEquals(null, controller.displayVisitCard.displayCond.isWest); //西
            system.assertEquals(null, controller.displayVisitCard.displayCond.occupancyAreaLowerLimit); //占有面積（下限）
            system.assertEquals(null, controller.displayVisitCard.displayCond.occupancyAreaUpperLimit); //占有面積（上限）
            system.assertEquals(null, controller.displayVisitCard.displayCond.isPrivateGarden); //専用庭
            system.assertEquals(null, controller.displayVisitCard.displayCond.isRegalLavatory); //洗面所独立
            system.assertEquals(null, controller.displayVisitCard.displayCond.isLargeBike); //大型バイク
            system.assertEquals(null, controller.displayVisitCard.displayCond.isDeliveryBox); //宅配ボックス
            system.assertEquals(null, controller.displayVisitCard.displayCond.buildingAge); //築年数
            system.assertEquals(null, controller.displayVisitCard.displayCond.isMediumBike); //中型バイク
            system.assertEquals(null, controller.displayVisitCard.displayCond.isPluralCarParking); //駐車場2台可
            system.assertEquals(null, controller.displayVisitCard.displayCond.isParking); //駐車場空きあり
            system.assertEquals(null, controller.displayVisitCard.displayCond.isIncludeParkingFee); //駐車場代込み
            system.assertEquals(null, controller.displayVisitCard.displayCond.isBicycleParking); //駐輪場
            system.assertEquals(null, controller.displayVisitCard.displayCond.rentFeeFrom); //賃料から
            system.assertEquals(null, controller.displayVisitCard.displayCond.rentFeeTo); //賃料まで
            system.assertEquals(null, controller.displayVisitCard.displayCond.isAditionalBoiling); //追焚機能
            system.assertEquals(null, controller.displayVisitCard.displayCond.isNonCleaningFee); //定額修繕費なし
            system.assertEquals(null, controller.displayVisitCard.displayCond.isSteel); //鉄骨造
            system.assertEquals(null, controller.displayVisitCard.displayCond.isElectricStove); //電気コンロ
            system.assertEquals(null, controller.displayVisitCard.displayCond.walkingTime); //徒歩
            system.assertEquals(null, controller.displayVisitCard.displayCond.isTownGas); //都市ガス
            system.assertEquals(null, controller.displayVisitCard.displayCond.isEast); //東
            system.assertEquals(null, controller.displayVisitCard.displayCond.isSouth); //南
            system.assertEquals(null, controller.displayVisitCard.displayCond.isSouthWest); //南西
            system.assertEquals(null, controller.displayVisitCard.displayCond.isSouthEast); //南東
            system.assertEquals(null, controller.displayVisitCard.displayCond.isNonDeposit); //敷金/保証金なし
            system.assertEquals(null, controller.displayVisitCard.displayCond.isInSiteParking); //敷地内駐車場
            system.assertEquals(null, controller.displayVisitCard.displayCond.isCondominiumRental); //分譲賃貸
            system.assertEquals(null, controller.displayVisitCard.displayCond.isNonGuaranteeidCompany); //保証会社不要
            system.assertEquals(null, controller.displayVisitCard.displayCond.isNoGuarantor); //保証人不要
            system.assertEquals(null, controller.displayVisitCard.displayCond.isNorth); //北
            system.assertEquals(null, controller.displayVisitCard.displayCond.isNorthWest); //北西
            system.assertEquals(null, controller.displayVisitCard.displayCond.isNorthEast); //北東
            system.assertEquals(null, controller.displayVisitCard.displayCond.isWooden); //木造
            system.assertEquals(null, controller.displayVisitCard.displayCond.isDehumidifierForBathroom); //浴室乾燥機
            system.assertEquals(null, controller.displayVisitCard.displayCond.isNonKeyMoney); //礼金なし
            system.assertEquals(null, controller.displayVisitCard.displayCond.parkingFeeLimit); //1台当たりの料金上限
            system.assertEquals(null, controller.displayVisitCard.displayCond.carCount); //台数

        }else{
            system.assertEquals(trainRoute1, controller.displayVisitCard.displayCond.trainRoute1Name); //希望沿線１．路線
            system.assertEquals(trainRoute2, controller.displayVisitCard.displayCond.trainRoute2Name); //希望沿線２．路線
            system.assertEquals(trainRoute3, controller.displayVisitCard.displayCond.trainRoute3Name); //希望沿線３．路線
            system.assertEquals(stateChar1, controller.displayVisitCard.displayCond.stationsChar1); //駅１文字列
            system.assertEquals(stateChar2, controller.displayVisitCard.displayCond.stationsChar2); //駅２文字列
            system.assertEquals(stateChar3, controller.displayVisitCard.displayCond.stationsChar3); //駅３文字列

            system.assertEquals(juniorHighArea, controller.displayVisitCard.displayCond.juniorHighSchoolArea);//中学校希望学区(エリア).希望学区
            system.assertEquals(elementaryArea, controller.displayVisitCard.displayCond.elementarySchoolArea);//小学校希望学区(エリア).希望学区
            system.assertEquals(desiredJSchool, controller.displayVisitCard.displayCond.desiredJuniorHighSchool); //希望中学校
            system.assertEquals(desiredESchool, controller.displayVisitCard.displayCond.desiredPrimarySchool); //希望小学校

            system.assertEquals(apcName, controller.displayVisitCard.displayCond.Name); //物件条件名
            system.assertEquals(bool, controller.displayVisitCard.displayCond.is1DK); //1DK
            system.assertEquals(bool, controller.displayVisitCard.displayCond.is1K); //1K
            system.assertEquals(bool, controller.displayVisitCard.displayCond.is1LDK1SLDK); //1LDK/SLDK
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isFirstFloor); //1階
            system.assertEquals(bool, controller.displayVisitCard.displayCond.is2K2DK); //2K/DK
            system.assertEquals(bool, controller.displayVisitCard.displayCond.is2LDK2SLDK); //2LDK/SLDK
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isSecondFloorOver); //2階以上
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isTwoTenant); //2人入居可
            system.assertEquals(bool, controller.displayVisitCard.displayCond.is3K3DK); //3K/DK
            system.assertEquals(bool, controller.displayVisitCard.displayCond.is3LDK3SLDK); //3LDK/SLDK
            system.assertEquals(bool, controller.displayVisitCard.displayCond.is4K4DK4LDKFrom); //4K/DK/LDK~
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isBSAntenna); //BSアンテナ
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isCATV); //CATV
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isCSAntenna); //CSアンテナ
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isInductionHeating); //IHコンロ
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isRC); //RC
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isSRC); //SRC
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isWalkInCloset); //ウォークインクローゼット
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isAirConditioner); //エアコン
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isElevator); //エレベーター
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isAutoLock); //オートロック
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isAllElectric); //オール電化
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isAllWestern); //オール洋間
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isCarport); //カーポート
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isCounterKitchen); //カウンターキッチン
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isGasStove); //ガスコンロ
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isTwoGasStove); //コンロ2口
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isMoreGasStove); //コンロ3口以上
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isSystemKitchen); //システムキッチン
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isShowerWashBasin); //シャワー付き洗面台
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isShoeCloak); //シューズクローク
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isShoesBox); //シューズボックス
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isDesigners); //デザイナーズ
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isTrunkRoom); //トランクルーム
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isInternetFree); //ネット使用料無料
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isBikeStorage); //バイク可
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isSepalateBathAndRestroom); //バス・トイレ別
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isBalcony); //バルコニー
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isBuiltInGarage); //ビルトインガレージ
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isPropaneGas); //プロパンガス
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isOtherPet); //ペット(その他)
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isSmallPet); //ペット(小型犬)
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isLargePet); //ペット(大型犬)
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isMiddlePet); //ペット(中型犬)
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isCat); //ペット(猫)
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isPet); //ペット可
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isMaisonette); //メゾネット
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isMonitorIntercom); //モニター付きインターホン
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isRenovation); //リノベーション
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isRoofBalcony); //ルーフバルコニー
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isRoomShare); //ルームシェア可
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isLoft); //ロフト
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isOneRoom); //ワンルーム
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isIppambutsu); //一般物
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isWashlet); //温水洗浄便座
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isFurniture); //家具付き
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isHomeAppliance); //家電付き
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isForeigner); //外国人契約可
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isCornerRoom); //角部屋
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isStudent); //学生限定マンション
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isMusicalInstruments); //楽器相談可
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isIncludeManagementFee); //管理費込み
            system.assertEquals(desiredArea, controller.displayVisitCard.displayCond.desiredArea); //希望地域
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isLightweightSteel); //軽量鉄骨
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isDetachedHouse); //戸建て
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isNonRenewalFee); //更新料なし
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isElderly); //高齢者歓迎
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isTopFloor); //最上階
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isOfficeAvailable); //事務所利用可
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isInnerLandry); //室内洗濯機置場
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isWoman); //女性限定
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isSmallBike); //小型バイク
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isFloorHeating); //床暖房
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isWelfareAvailable); //生活保護契約可
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isWest); //西
            system.assertEquals(oaLowLimit, controller.displayVisitCard.displayCond.occupancyAreaLowerLimit); //占有面積（下限）
            system.assertEquals(oaUpLimit, controller.displayVisitCard.displayCond.occupancyAreaUpperLimit); //占有面積（上限）
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isPrivateGarden); //専用庭
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isRegalLavatory); //洗面所独立
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isLargeBike); //大型バイク
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isDeliveryBox); //宅配ボックス
            system.assertEquals(buildingAge, controller.displayVisitCard.displayCond.buildingAge); //築年数
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isMediumBike); //中型バイク
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isPluralCarParking); //駐車場2台可
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isParking); //駐車場空きあり
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isIncludeParkingFee); //駐車場代込み
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isBicycleParking); //駐輪場
            system.assertEquals(rentFeeFrom, controller.displayVisitCard.displayCond.rentFeeFrom); //賃料から
            system.assertEquals(rentFeeTo, controller.displayVisitCard.displayCond.rentFeeTo); //賃料まで
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isAditionalBoiling); //追焚機能
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isNonCleaningFee); //定額修繕費なし
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isSteel); //鉄骨造
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isElectricStove); //電気コンロ
            system.assertEquals(walkingTime, controller.displayVisitCard.displayCond.walkingTime); //徒歩
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isTownGas); //都市ガス
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isEast); //東
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isSouth); //南
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isSouthWest); //南西
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isSouthEast); //南東
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isNonDeposit); //敷金/保証金なし
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isInSiteParking); //敷地内駐車場
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isCondominiumRental); //分譲賃貸
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isNonGuaranteeidCompany); //保証会社不要
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isNoGuarantor); //保証人不要
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isNorth); //北
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isNorthWest); //北西
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isNorthEast); //北東
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isWooden); //木造
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isDehumidifierForBathroom); //浴室乾燥機
            system.assertEquals(bool, controller.displayVisitCard.displayCond.isNonKeyMoney); //礼金なし
            system.assertEquals(parkingFlimit, controller.displayVisitCard.displayCond.parkingFeeLimit); //1台当たりの料金上限
            system.assertEquals(carCount, controller.displayVisitCard.displayCond.carCount); //台数
        }
    }

    // 登録・更新・削除されたお客様物件条件を確認する。
    static void checkAccountPropertyConditionsObj(Id accId, String status){

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
                    if(apc.Name == '条件2'){
                        bool = true;
                    } else if(apc.Name == '条件3'){
                        bool = false;
                    } else if(apc.Name == '条件4'){
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

    static void checkAccountVisitCord(Id accId, String status){
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

        VisitCard__c visi = [SELECT ID
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
                        FROM VisitCard__c
                        WHERE Account__c =:accId];


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

        // 来店カードテスト
        system.assertEquals(desiredArea, visi.DesiredArea__c); //希望地域
        system.assertEquals(oaLowLimit, visi.OccupancyAreaLowerLimit__c); //占有面積（下限）
        system.assertEquals(oaUpLimit, visi.OccupancyAreaUpperLimit__c); //占有面積（上限）
        system.assertEquals(buildingAge, visi.BuildingAge__c); //築年数
        system.assertEquals(rentFeeFrom, visi.RentFeeFrom__c); //賃料から
        system.assertEquals(rentFeeTo, visi.RentFeeTo__c); //賃料まで
        system.assertEquals(walkingTime, visi.WalkingTime__c); //徒歩
        system.assertEquals(parkingFlimit, visi.ParkingFeeLimit__c); //1台当たりの料金上限
        system.assertEquals(carCount, visi.CarCount__c); //台数

        system.assertEquals(bool, visi.Is1DK__c); //1DK
        system.assertEquals(bool, visi.Is1K__c); //1K
        system.assertEquals(bool, visi.Is1LDK1SLDK__c); //1LDK/SLDK
        system.assertEquals(bool, visi.IsFirstFloor__c); //1階
        system.assertEquals(bool, visi.Is2K2DK__c); //2K/DK
        system.assertEquals(bool, visi.Is2LDK2SLDK__c); //2LDK/SLDK
        system.assertEquals(bool, visi.IsSecondFloorOver__c); //2階以上
        system.assertEquals(bool, visi.IsTwoTenant__c); //2人入居可
        system.assertEquals(bool, visi.Is3K3DK__c); //3K/DK
        system.assertEquals(bool, visi.Is3LDK3SLDK__c); //3LDK/SLDK
        system.assertEquals(bool, visi.Is4K4DK4LDKFrom__c); //4K/DK/LDK~
        system.assertEquals(bool, visi.IsBSAntenna__c); //BSアンテナ
        system.assertEquals(bool, visi.IsCATV__c); //CATV
        system.assertEquals(bool, visi.IsCSAntenna__c); //CSアンテナ
        system.assertEquals(bool, visi.IsInductionHeating__c); //IHコンロ
        system.assertEquals(bool, visi.IsRC__c); //RC
        system.assertEquals(bool, visi.IsSRC__c); //SRC
        system.assertEquals(bool, visi.IsWalkInCloset__c); //ウォークインクローゼット
        system.assertEquals(bool, visi.IsAirConditioner__c); //エアコン
        system.assertEquals(bool, visi.IsElevator__c); //エレベーター
        system.assertEquals(bool, visi.IsAutoLock__c); //オートロック
        system.assertEquals(bool, visi.IsAllElectric__c); //オール電化
        system.assertEquals(bool, visi.IsAllWestern__c); //オール洋間
        system.assertEquals(bool, visi.IsCarport__c); //カーポート
        system.assertEquals(bool, visi.IsCounterKitchen__c); //カウンターキッチン
        system.assertEquals(bool, visi.IsGasStove__c); //ガスコンロ
        system.assertEquals(bool, visi.IsTwoGasStove__c); //コンロ2口
        system.assertEquals(bool, visi.IsMoreGasStove__c); //コンロ3口以上
        system.assertEquals(bool, visi.IsSystemKitchen__c); //システムキッチン
        system.assertEquals(bool, visi.IsShowerWashBasin__c); //シャワー付き洗面台
        system.assertEquals(bool, visi.IsShoeCloak__c); //シューズクローク
        system.assertEquals(bool, visi.IsShoesBox__c); //シューズボックス
        system.assertEquals(bool, visi.IsDesigners__c); //デザイナーズ
        system.assertEquals(bool, visi.IsTrunkRoom__c); //トランクルーム
        system.assertEquals(bool, visi.IsInternetFree__c); //ネット使用料無料
        system.assertEquals(bool, visi.IsBikeStorage__c); //バイク可
        system.assertEquals(bool, visi.IsSepalateBathAndRestroom__c); //バス・トイレ別
        system.assertEquals(bool, visi.IsBalcony__c); //バルコニー
        system.assertEquals(bool, visi.IsBuiltInGarage__c); //ビルトインガレージ
        system.assertEquals(bool, visi.IsPropaneGas__c); //プロパンガス
        system.assertEquals(bool, visi.IsOtherPet__c); //ペット(その他)
        system.assertEquals(bool, visi.IsSmallPet__c); //ペット(小型犬)
        system.assertEquals(bool, visi.IsLargePet__c); //ペット(大型犬)
        system.assertEquals(bool, visi.IsMiddlePet__c); //ペット(中型犬)
        system.assertEquals(bool, visi.IsCat__c); //ペット(猫)
        system.assertEquals(bool, visi.IsPet__c); //ペット可
        system.assertEquals(bool, visi.IsMaisonette__c); //メゾネット
        system.assertEquals(bool, visi.IsMonitorIntercom__c); //モニター付きインターホン
        system.assertEquals(bool, visi.IsRenovation__c); //リノベーション
        system.assertEquals(bool, visi.IsRoofBalcony__c); //ルーフバルコニー
        system.assertEquals(bool, visi.IsRoomShare__c); //ルームシェア可
        system.assertEquals(bool, visi.IsLoft__c); //ロフト
        system.assertEquals(bool, visi.IsOneRoom__c); //ワンルーム
        system.assertEquals(bool, visi.IsIppambutsu__c); //一般物
        system.assertEquals(bool, visi.IsWashlet__c); //温水洗浄便座
        system.assertEquals(bool, visi.IsFurniture__c); //家具付き
        system.assertEquals(bool, visi.IsHomeAppliance__c); //家電付き
        system.assertEquals(bool, visi.IsForeigner__c); //外国人契約可
        system.assertEquals(bool, visi.IsCornerRoom__c); //角部屋
        system.assertEquals(bool, visi.IsStudent__c); //学生限定マンション
        system.assertEquals(bool, visi.IsMusicalInstruments__c); //楽器相談可
        system.assertEquals(bool, visi.IsIncludeManagementFee__c); //管理費込み
        system.assertEquals(bool, visi.IsLightweightSteel__c); //軽量鉄骨
        system.assertEquals(bool, visi.IsDetachedHouse__c); //戸建て
        system.assertEquals(bool, visi.IsNonRenewalFee__c); //更新料なし
        system.assertEquals(bool, visi.IsElderly__c); //高齢者歓迎
        system.assertEquals(bool, visi.IsTopFloor__c); //最上階
        system.assertEquals(bool, visi.IsOfficeAvailable__c); //事務所利用可
        system.assertEquals(bool, visi.IsInnerLandry__c); //室内洗濯機置場
        system.assertEquals(bool, visi.IsWoman__c); //女性限定
        system.assertEquals(bool, visi.IsSmallBike__c); //小型バイク
        system.assertEquals(bool, visi.IsFloorHeating__c); //床暖房
        system.assertEquals(bool, visi.IsWelfareAvailable__c); //生活保護契約可
        system.assertEquals(bool, visi.IsWest__c); //西
        system.assertEquals(bool, visi.IsPrivateGarden__c); //専用庭
        system.assertEquals(bool, visi.IsRegalLavatory__c); //洗面所独立
        system.assertEquals(bool, visi.IsLargeBike__c); //大型バイク
        system.assertEquals(bool, visi.IsDeliveryBox__c); //宅配ボックス
        system.assertEquals(bool, visi.IsMediumBike__c); //中型バイク
        system.assertEquals(bool, visi.IsPluralCarParking__c); //駐車場2台可
        system.assertEquals(bool, visi.IsParking__c); //駐車場空きあり
        system.assertEquals(bool, visi.IsIncludeParkingFee__c); //駐車場代込み
        system.assertEquals(bool, visi.IsBicycleParking__c); //駐輪場
        system.assertEquals(bool, visi.IsAditionalBoiling__c); //追焚機能
        system.assertEquals(bool, visi.IsNonCleaningFee__c); //定額修繕費なし
        system.assertEquals(bool, visi.IsSteel__c); //鉄骨造
        system.assertEquals(bool, visi.IsElectricStove__c); //電気コンロ
        system.assertEquals(bool, visi.IsTownGas__c); //都市ガス
        system.assertEquals(bool, visi.IsEast__c); //東
        system.assertEquals(bool, visi.IsSouth__c); //南
        system.assertEquals(bool, visi.IsSouthWest__c); //南西
        system.assertEquals(bool, visi.IsSouthEast__c); //南東
        system.assertEquals(bool, visi.IsNonDeposit__c); //敷金/保証金なし
        system.assertEquals(bool, visi.IsInSiteParking__c); //敷地内駐車場
        system.assertEquals(bool, visi.IsCondominiumRental__c); //分譲賃貸
        system.assertEquals(bool, visi.IsNonGuaranteeidCompany__c); //保証会社不要
        system.assertEquals(bool, visi.IsNoGuarantor__c); //保証人不要
        system.assertEquals(bool, visi.IsNorth__c); //北
        system.assertEquals(bool, visi.IsNorthWest__c); //北西
        system.assertEquals(bool, visi.IsNorthEast__c); //北東
        system.assertEquals(bool, visi.IsWooden__c); //木造
        system.assertEquals(bool, visi.IsDehumidifierForBathroom__c); //浴室乾燥機
        system.assertEquals(bool, visi.IsNonKeyMoney__c); //礼金なし
    }
        
    // お客様物件条件１を登録する。
    static void insertAPC_1(){
        Account acc = [SELECT id FROM Account];
        List<DesiredTrainRoute__c> dtrList = [SELECT id FROM DesiredTrainRoute__c];
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];

        //お客様物件条件
        AccountPropertyConditions__c accountPropertyCond1 = new AccountPropertyConditions__c();
        accountPropertyCond1.Account__c  = acc.Id;//取引先Id
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

        insert accountPropertyCond1;
    }

    // お客様物件条件2を登録する。
    static void insertAPC_2(){

        Account acc = [SELECT id FROM Account];
        List<DesiredTrainRoute__c> dtrList = [SELECT id FROM DesiredTrainRoute__c];
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];

        AccountPropertyConditions__c accountPropertyCond2 = new AccountPropertyConditions__c();//お客様物件条件
        accountPropertyCond2.Account__c  = acc.Id;//取引先Id
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

        insert accountPropertyCond2;
    }

    // お客様物件条件3を登録する。
    static void insertAPC_3(){

        Account acc = [SELECT id FROM Account];
        List<DesiredTrainRoute__c> dtrList = [SELECT id FROM DesiredTrainRoute__c];
        List<DesiredSchoolArea__c> dsaList = [SELECT id FROM DesiredSchoolArea__c];

        AccountPropertyConditions__c accountPropertyCond3 = new AccountPropertyConditions__c();//お客様物件条件

        accountPropertyCond3.Account__c  = acc.Id;//取引先Id
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

        insert accountPropertyCond3;
    }

}
// ▲2021.10.08 No.307 対応で追加