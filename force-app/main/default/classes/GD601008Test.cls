//物件名寄せ比較テスト

@isTest
public class GD601008Test {


    //テストに使用するレコードを作成
    @testSetup static void Setting(){
        // 建物テストデータ作成
        Building__c building = new Building__c(
            Name = 'テスト建物',
            District__c ='北区',
            State__c = '愛知県',
            City__c = '名古屋市物件名寄せ比較町',
            Street__c = '1-1');    
        insert building;

        // 建物写真
        BuildingPhoto__c buildPhoto = new BuildingPhoto__c(
            Building__c = building.id
        );
        insert buildPhoto;

        //保証会社用取引先   
        Account guarAccount = new Account(
            Name = '保証用取引先',
            RecordTypeId =CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_GUARANTEE));
        //管理会社指定商品用取引先   
        Account MCIAccount = new Account(
            Name = '管理会社指定商品用取引先',
            RecordTypeId =CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_AUXILIARY));
        //左元付用取引先
        Account leftAccount = new Account(
            Name = '左元付業者',
            RecordTypeId =CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER));
        //右元付用取引先
        Account rightAccount = new Account(
            Name = '右元付業者',
            RecordTypeId =CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER));
        List<Account> accountList = new List<Account> {guarAccount,MCIAccount,leftAccount,rightAccount};
        insert accountList;

        //保証
        Item__c leftGuar = new Item__c(//左
            Account__c = guarAccount.id
            ,ItemName__c = '左保証'
            ,AssuranceContent__c = '左保証内容'
            ,Remarks__c = '左保証備考'
            ,DirectDebitFeeTaxType__c = '課税'
            ,DirectDebitFee__c = 10000
            ,RecordTypeId =CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_GUARANTEE_PLAN));
        Item__c rightGuar = new Item__c(//右
            Account__c = guarAccount.id
            ,ItemName__c = '右保証'
            ,AssuranceContent__c = '右保証内容'
            ,Remarks__c = '右保証備考'
            ,DirectDebitFeeTaxType__c = '非課税'
            ,DirectDebitFee__c = 10000
            ,RecordTypeId = CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_GUARANTEE_PLAN));
        List<Item__c> itemList = new List<Item__c> {leftGuar,rightGuar};
        insert itemList;
        //物件
        Property__c leftPro = new Property__c(//左
            Name = '左物件',//名前
            building__c = building.id,//建物
            MaintenancePropertyCode__c = '左',
            Guaranteeid__c = leftGuar.id,//保証タイトル
            FormerSupplier__c=leftAccount.id//元付業者
            );

        Property__c leftPro2 = new Property__c(Building__c = building.id,
                                        Name = '左物件2');
        List<Property__c> proLeftList = new List<Property__c> {leftPro,leftPro2};
        insert proLeftList;

        //スリープ
        CommonUtil.sleep(1000);

        Property__c rightPro = new Property__c(//右
            Name = '右物件',//名前
            building__c = building.id,//建物
            MaintenancePropertyCode__c = '右',
            Guaranteeid__c = rightGuar.id,//保証タイトル
            FormerSupplier__c=rightAccount.id//元付業者
            );

        Property__c rightPro2 = new Property__c(Building__c = building.id,
                                                Name = '右物件2');

        List<Property__c> proRightList = new List<Property__c> {rightPro,rightPro2};
        insert proRightList;

        //物件条件
        PropertyConditions__c leftProCon = new PropertyConditions__c(//左
            Property__c = leftPro.id,//物件Id
            IsQuietResidenceTown__c = true,
            IsTowerMansion__c = true,
            IsDesigners__c = true,
            IsBarrierFree__c = true,
            IsOuterWallTile__c = true,
            IsCondominiumRental__c = true,
            IsDampingStructure__c = true,
            IsTopFloor__c = true,
            IsElevator__c = true,
            IsPluralElevators__c = true,
            IsFrontService__c = true,
            IsDeliveryBox__c = true,
            IsCleaningBox__c = true,
            IsCoinLaundry__c = true,
            IsAnytimeTtrashArea__c = true,
            IsInSiteTtrashArea__c = true,
            IsSepticTank__c = true,
            IsPluralCarParking__c = true,
            IsBicycleParking__c = true,
            IsCornerRoom__c = true,
            IsBayWindow__c = true,
            IsPrivateGarden__c = true,
            IsAutoLock__c = true,
            IsAnytimeSecurity__c = true,
            IsSecurityCompanyJoin__c = true,
            IsDimpleKey__c = true,
            IsSurveillanceCamera__c = true,
            IsSecurityGlass__c = true,
            IsMaisonette__c = true,
            IsLoft__c = true,
            IsUndergroundRoom__c = true,
            IsSoundproofRoom__c = true,
            IsGasStove__c = true,
            IsTwoGasStove__c = true,
            IsElectricStove__c = true,
            IsCounterKitchen__c = true,
            IsWaterPurifier__c = true,
            IsDishwasher__c = true,
            IsDisposer__c = true,
            IsCityGas__c = true,
            IsSeparate__c = true,
            IsMistSauna__c = true,
            IsTvBath__c = true,
            IsReheating__c = true,
            IsHotWaterFormula__c = true,
            IsBathroomDryer__c = true,
            IsBathroomFloorHeating__c = true,
            IsWashletToiletSeat__c = true,
            IsTanklessToilet__c = true,
            IsShowerWashBasin__c = true,
            IsWashroomDscrete__c = true,
            IsFloorHeating__c = true,
            IsGasHeating__c = true,
            IsKeroseneHeating__c = true,
            IsAirConditioner__c = true,
            IsFurniture__c = true,
            IsHomeAppliance__c = true,
            IsWashingDryer__c = true,
            IsBalcony__c = true,
            IsRoofBalcony__c = true,
            IsWoodDeck__c = true,
            IsFlooring__c = true,
            IsCushionFloor__c = true,
            IsStormShutter__c = true,
            IsShutter__c = true,
            IsElectricShutter__c = true,
            IsHighSash__c = true,
            IsSoundproofSash__c = true,
            IsPairGlass__c = true,
            IsSolidWood__c = true,
            IsIndoorWashingMachineStorage__c = true,
            IsWalkInCloset__c = true,
            IsShoesBox__c = true,
            IsTrunkRoom__c = true,
            IsUnderfloorStorage__c = true,
            IsBSAntenna__c = true,
            IsCSAntenna__c = true,
            IsCATV__c = true,
            IsCATVInternet__c = true,
            IsCATVFree__c = true,
            IsOpticalFiber__c = true,
            IsInternetFree__c = true,
            IsMonitorIntercom__c = true,
            IsRenovation__c = true,
            IsRentCreditPayment__c = true,
            IsInitialCostCreditPayment__c = true,
            IsITImportantDescription__c = true,
            IsNoGuarantor__c = true,
            IsCustomize__c = true,
            IsDIY__c = true,
            IsMusicalInstruments__c = true,
            IsPet__c = true,
            IsTwoTenant__c = true,
            IsWoman__c = true,
            IsLbgt__c = true,
            IsElderly__c = true,
            IsRoomShare__c = true,
            IsMonthly__c = true,
            IsOfficeAvailable__c = true,
            IsFreeRent__c = true,
            IsSpecialRent__c = true,
            IsForeigner__c = true,
            IsStudent__c = true,
            IsNotChild__c = true,
            IsWelfareAvailable__c = true,
            IsCorporation__c = true,
            IsLargePet__c = true,
            IsMiddlePet__c = true,
            IsSmallPet__c = true,
            IsCat__c = true,
            IsOtherPet__c = true,
            IsAllWesternStyleRoom__c = true,
            IsBuiltInGarage__c = true,
            IsCarport__c = true,
            IsShoeCloak__c = true);
        PropertyConditions__c rightProCon = new PropertyConditions__c(//右
            IsCarport__c = true,
            IsSeismicStructure__c = true,
            IsSeismicIsolationStructure__c = true,
            IsIhStove__c = true,
            IsMoreGasStove__c =true,
            IsAllElectric__c =true,
            IsPropaneGas__c =true,

            Property__c = rightPro.id);

        List<PropertyConditions__c> proConList = new List<PropertyConditions__c> {leftProCon,rightProCon};
        insert proConList;
        
        //管理会社指定指定商品
        ManagementCompanyItem__c leftMCI = new ManagementCompanyItem__c(//左
            Account__c = MCIAccount.id,//取引先
            ItemName__c = '左管理会社指定商品',//名前
            Amount__c = 5000,//金額
            TaxType__c = '課税');//税区分
        ManagementCompanyItem__c rightMCI = new ManagementCompanyItem__c(//右
            Account__c = MCIAccount.id,//取引先
            ItemName__c = '右管理会社指定商品',//名前
            Amount__c = 4000,//金額
            TaxType__c = '非課税');//税区分
        List<ManagementCompanyItem__c> MCIList = new List<ManagementCompanyItem__c> {leftMCI,rightMCI};
        insert MCIList;

        //物件管理会社指定
        PropertyManageCompayItem__c leftPMCI = new PropertyManageCompayItem__c(//左
            Property__c = leftPro.id,
            Item__c = leftMCI.id);
        PropertyManageCompayItem__c rightPMCI = new PropertyManageCompayItem__c(//右
            Property__c = rightPro.id,
            Item__c = rightMCI.id);
        List<PropertyManageCompayItem__c> PMCIList = new List<PropertyManageCompayItem__c> {leftPMCI,rightPMCI};
        insert PMCIList;

        //部屋
        Room__c leftRoom = new Room__c(
            Property__c = leftPro.id,
            RoomFloorSpace__c = 7,
            RoomType__c = '洋室');
        Room__c rightRoom = new Room__c(
            Property__c = rightPro.id,
            RoomFloorSpace__c = 9,
            RoomType__c = '和室');
        List<Room__c> roomList = new List<Room__c> {leftRoom,rightRoom};
        insert roomList;

        //添付ファイル
        String leftBodyString = ('0').repeat(1000);
        Attachment leftAtt = new Attachment(//左1
            ParentId = leftPro.Id
            ,Name = '左添付'
            ,Body = Blob.valueOf(leftBodyString)
        );

        String left2BodyString = ('0').repeat(1025);
        Attachment leftAtt2 = new Attachment(//左2
            ParentId = leftPro.Id
            ,Name = '左添付2'
            ,Body = Blob.valueOf(left2BodyString)
        );

        String left3BodyString = ('0').repeat(1048577);
        Attachment leftAtt3 = new Attachment(//左3
            ParentId = leftPro.Id
            ,Name = '左添付3'
            ,Body = Blob.valueOf(left3BodyString)
        );

        /*
        String left4BodyString = ('0').repeat(1073741825);
        Attachment leftAtt4 = new Attachment(//左4
            ParentId = leftPro.Id
            ,Name = '左添付4'
            ,Body = Blob.valueOf(left4BodyString)
        );

        String left5BodyString = ('0').repeat(1074741824*1024);
        Attachment leftAtt5 = new Attachment(//左5
            ParentId = leftPro.Id
            ,Name = '左添付5'
            ,Body = Blob.valueOf(left5BodyString)
        );
        */

        List<Attachment> attList = new List<Attachment> {leftAtt,leftAtt2,leftAtt3};
        insert attList;

        //画像
        PropertyPhoto__c testPropertyPhoto = new PropertyPhoto__c(
            Property__c                 = leftPro.Id   // 物件
            ,PropertyPhotoFileName1__c  = '画像1'          // 物件写真ファイル名１
            ,PropertyPhotoTag1__c       = 'その他'          // 物件写真タグ１
            ,PropertyPhotoComment1__c   = ''          // 物件写真コメント１
            ,PrivatePhotoFileName1__c   = ''          // 非公開写真ファイル名１
        );
        insert testPropertyPhoto;

        PropertyPhoto__c testPropertyPhoto2 = new PropertyPhoto__c(
            Property__c                 = rightPro.Id   // 物件
            ,PropertyPhotoFileName1__c  = '画像1'          // 物件写真ファイル名１
            ,PropertyPhotoTag1__c       = 'その他'          // 物件写真タグ１
            ,PropertyPhotoComment1__c   = ''          // 物件写真コメント１
            ,PrivatePhotoFileName1__c   = ''          // 非公開写真ファイル名１
        );
        insert testPropertyPhoto2;

        // ポータルサイト構築 追加 Start
        //システム設定を作成
        SystemConfig__c s = new SystemConfig__c(
            UseAuthority_Portal__c = true
            ,Theta360bizApiId__c = 'YRJ2hheSXZ'          // パノラマツアー認証Id  
            ,Theta360bizApiAccessKey__c = '2mNySK4frewxewf487pUJ3tdfcs2Nn'    // パノラマツアーAccessKey 
            ,S3BucketName__c = 'aaa'
            ,S3RootDirectory__c = 'aaa'
            );
        insert s;
        // ポータルサイト構築 追加 End
    }

    // 初期表示テスト(新規)
    @isTest static void initializeTest(){
        Property__c pro1 = [SELECT Id FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id FROM Property__c WHERE Name = '右物件'];

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();
        //System.assertEquals('左物件', testController.leftProperty.Name);
    }
    
    // 初期表示テスト(異常)
    @isTest static void initializeErrorTest(){
        Property__c pro1 = [SELECT Id FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id FROM Property__c WHERE Name = '右物件'];

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id + '1');
        pageRef.getParameters().put('id2', pro2.Id + '1');

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        //不正なパラメータのエラー
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)));

    }

    // 登録ボタン（左に寄せる）
    @isTest static void leftMergeTest(){
        Property__c pro1 = [SELECT Id FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id FROM Property__c WHERE Name = '右物件'];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        //元付を右→左に名寄せ
        testController.FormerSupplierRadioButton= '右';
        testController.BasicInfoRadioButton= '左';
        // 問合せ374で追加
        testController.pictureRadioButton = '右';
        testController.floorPlanRadioButton = '右';
        testController.save();

        Property__c resultLeft = [SELECT Id,Name,MaintenancePropertyCode__c,Guaranteeid__c FROM Property__c WHERE id = :pro1.Id];
        List<Property__c>  resultRight= [SELECT Id,Name,MaintenancePropertyCode__c,Guaranteeid__c FROM Property__c WHERE id = :pro2.Id];
        //名前は「左物件」のまま
        System.assertEquals( resultLeft.Name, '左物件');
        //右物件は取得できない（削除されているため）
        System.assertEquals( resultRight.size(), 0);

        //メンテナンス物件コードが「右」に更新されている
        System.assertEquals( resultLeft.MaintenancePropertyCode__c, '左');
  
        Item__c guar = [SELECT Id FROM Item__c WHERE ItemName__c = '右保証'];
        //保証が右のものに変更されている
        System.assertEquals(resultLeft.Guaranteeid__c, guar.id);
        
    }
    // 登録ボタン（右に寄せる）
    @isTest static void rightMergeTest(){
        Property__c pro1 = [SELECT Id FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id FROM Property__c WHERE Name = '右物件'];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        //元付を左→右に名寄せ
        testController.FormerSupplierRadioButton= '左';
        testController.BasicInfoRadioButton= '右';
        // 問合せ374で追加
        testController.pictureRadioButton = '左';
        testController.floorPlanRadioButton = '左';
        testController.save();

        List<Property__c> resulLeft = [SELECT Id,Name,MaintenancePropertyCode__c,Guaranteeid__c FROM Property__c WHERE id = :pro1.Id];
        Property__c resultRight = [SELECT Id,Name,MaintenancePropertyCode__c,Guaranteeid__c FROM Property__c WHERE id = :pro2.Id];
        //名前は「右物件」のまま
        System.assertEquals( resultRight.Name, '右物件');
        //左物件は取得できない（削除されているため）
        System.assertEquals( resulLeft.size(), 0);

        //メンテナンス物件コードが「右」に更新されている
        System.assertEquals( resultRight.MaintenancePropertyCode__c, '右');
  
        Item__c guar = [SELECT Id FROM Item__c WHERE ItemName__c = '左保証'];
        //保証が左のものに変更されている
        System.assertEquals(resultRight.Guaranteeid__c, guar.id);
        
    }

    // 登録ボタン（楽観ロックチェック）
    @isTest static void optimisticLockSaveErrorTest(){
        Property__c pro1 = [SELECT Id FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id FROM Property__c WHERE Name = '右物件'];

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        update pro1;
        //スリープ
        CommonUtil.sleep(1000);
        //更新
        testController.save();

        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)));
    
    }

    // 登録ボタン（ポータルサイト掲載物件）
    @isTest static void mergeErrorTest(){
        Property__c pro1 = [SELECT Id FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id FROM Property__c WHERE Name = '右物件'];
        //ポータルサイト掲載物件を紐づける
        PortalSitePostingProperty__c PSPP = new PortalSitePostingProperty__c(
            Property__c=pro2.id
        );
        insert PSPP;
        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();
        //更新
        testController.save();

    
    }

    // ポータルサイト構築 追加 Start
    //登録ボタン（おすすめ物件） 2020/11/06
    @isTest static void RecommendPropertyTest(){

        //テストデータ作成
        //物件名寄せ比較の物件２つ
        Property__c pro1 = [SELECT Id,PropertyCode__c FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id,PropertyCode__c FROM Property__c WHERE Name = '右物件'];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;

        //おすすめ物件
        RecommendProperty__c osusume = new RecommendProperty__c(
            PropertyCode__c = pro2.PropertyCode__c,
            Property__c = pro2.id,
            PanoramaTourUrl__c = 'testURL'
        );
        insert osusume;

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);

        Test.startTest();
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        //物件名寄せ比較で全データを左→右に名寄せ
        testController.FormerSupplierRadioButton= '右';
        testController.BasicInfoRadioButton= '右';
        testController.pictureRadioButton = '右';
        testController.save();

        //おすすめ物件の物件コードが'789100'に変更されているか？
        List<RecommendProperty__c> osusumeDate = [SELECT PropertyCode__c FROM RecommendProperty__c];
        System.assertEquals(pro2.PropertyCode__c, osusumeDate[0].PropertyCode__c);
        Test.stopTest();

    }
    // パノラマツアーのAPI接続
    @isTest static void saveAfterPanorama(){
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();


        Test.setMock(HttpCalloutMock.class, new GK101003TestHttpRequestMock());
        Test.startTest();
        testController.saveAfter();
        Test.stopTest();
        
    }
    // ポータルサイト構築 追加 End

    //カバレッジ率あげる用
    @isTest static void coverageUp(){
        Property__c pro1 = [SELECT Id FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id FROM Property__c WHERE Name = '右物件'];
        //添付ファイル
        String leftBodyString = ('0').repeat(1000);
        Attachment rightAtt = new Attachment(//右の添付ファイル作成
            ParentId = pro2.id
            ,Name = '右添付'
            ,Body = Blob.valueOf(leftBodyString)
        );
        insert rightAtt;
        //左の添付ファイルを消す
        List<Attachment> leftAtt =[SELECT id FROM  Attachment WHERE ParentId=:pro1.id];
        delete leftAtt;
        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);
        Test.setCurrentPage(pageRef);
        
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();
        //ラジオボタン設定
        testController.getFormerSupplierRadioButtonSetting();
        testController.getBasicInfoRadioButtonSetting();
        testController.getPictureRadioButtonSetting();
        testController.getFloorPlanRadioButtonSetting();

        String a = testController.MSG_COM_V_EXECUTE_MERGE;
        a = testController.MSG_COM_I_MERGE_END;

    }

    @isTest static void coverageUp2(){
        Property__c pro1 = [SELECT Id FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id FROM Property__c WHERE Name = '右物件2'];

        Property__c pro3 = [SELECT Id FROM Property__c WHERE Name = '左物件2'];
        Property__c pro4 = [SELECT Id FROM Property__c WHERE Name = '右物件'];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;
        
        Test.startTest();
        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        //メンテナンス情報と元付を左→右に名寄せ
        testController.FormerSupplierRadioButton= '左';
        testController.BasicInfoRadioButton= '右';
        testController.save();

        //パラメータ設定
        PageReference pageRef2 = Page.GD601008View;
        pageRef2.getParameters().put('id1', pro3.Id);
        pageRef2.getParameters().put('id2', pro4.Id);

        Test.setCurrentPage(pageRef2);
        //メンテナンス情報と元付を左→右に名寄せ
        GD601008Controller testController2 = new GD601008Controller();
        testController2.FormerSupplierRadioButton= '右';
        testController2.BasicInfoRadioButton= '左';
        testController2.save();
        Test.stopTest();
    }

    @isTest static void getRecommendPropertyTest(){

        //テストデータ作成
        Building__c building = [SELECT id,ForeignID__c FROM Building__c];
        //物件名寄せ比較の物件２つ
        Property__c pro1 = [SELECT Id, PropertyCode__c, ForeignID__c FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id, PropertyCode__c, ForeignID__c FROM Property__c WHERE Name = '右物件'];

        PropertyPhoto__c proPhoto = [
            SELECT id, PropertyPhotoFileName1__c, PropertyPhotoFilePath1__c FROM PropertyPhoto__c WHERE Property__c = :pro1.id
        ];
        PropertyPhoto__c proPhoto2 = [
            SELECT id, PropertyPhotoFileName1__c, PropertyPhotoFilePath1__c FROM PropertyPhoto__c WHERE Property__c = :pro2.id
        ];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;

        //おすすめ物件
        RecommendProperty__c osusume = new RecommendProperty__c(
            PropertyCode__c = pro1.PropertyCode__c,
            Property__c = pro1.id,
            PanoramaTourUrl__c = 'testURL',
            PhotoFilePath__c = 'https://aaa.s3.amazonaws.com/aaa/public/salesforce/photo/building_property/' + building.ForeignID__c + '/' + pro1.ForeignID__c + '/画像1'
        );
        insert osusume;

        //おすすめ物件
        RecommendProperty__c osusume2 = new RecommendProperty__c(
            PropertyCode__c = pro2.PropertyCode__c,
            Property__c = pro2.id,
            PanoramaTourUrl__c = 'testURL',
            PhotoFilePath__c = 'https://aaa.s3.amazonaws.com/aaa/public/salesforce/photo/building_property/' +  + building.ForeignID__c + '/' + pro2.ForeignID__c + '/画像1'
        );
        insert osusume2;

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);

        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        //物件名寄せ比較で全データを左→右に名寄せ
        testController.FormerSupplierRadioButton= '右';
        testController.BasicInfoRadioButton= '右';
        testController.save();

    }

    //web公開変更チェック
    @isTest static void changeWebPublishing(){
        Property__c pro1 = [SELECT Id FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id FROM Property__c WHERE Name = '右物件'];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;

        pro1.WebPublishing__c = CommonConst.PROPERTY_WEBPUBLISHING_EXISTS;
        update pro1;

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);
        Test.setCurrentPage(pageRef);
        
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();
        //メンテナンス情報と元付を右→左に名寄せ
        testController.FormerSupplierRadioButton= '右';
        testController.BasicInfoRadioButton= '左';
        testController.pictureRadioButton = '右';
        testController.floorPlanRadioButton = '右';
        testController.save();

    }

    //写真移動テスト
    @isTest static void pictureMovementTest(){
        Property__c pro1 = [SELECT Id FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id FROM Property__c WHERE Name = '右物件'];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;

        PropertyPhoto__c propPhoto = [
            SELECT id, PropertyPhotoFileName1__c FROM PropertyPhoto__c WHERE Property__c = :pro1.id
        ];
        PropertyPhoto__c propPhoto2 = [
            SELECT id, PropertyPhotoFileName1__c FROM PropertyPhoto__c WHERE Property__c = :pro2.id
        ];

        // 物件写真ファイル名
        propPhoto.PropertyPhotoFileName1__c = 'テスト';
        propPhoto.PropertyPhotoFileName2__c = 'テスト';
        propPhoto.PropertyPhotoFileName3__c = 'テスト';
        propPhoto.PropertyPhotoFileName4__c = 'テスト';
        propPhoto.PropertyPhotoFileName5__c = 'テスト';
        propPhoto.PropertyPhotoFileName6__c = 'テスト';
        propPhoto.PropertyPhotoFileName7__c = 'テスト';
        propPhoto.PropertyPhotoFileName8__c = 'テスト';
        propPhoto.PropertyPhotoFileName9__c = 'テスト';
        propPhoto.PropertyPhotoFileName10__c = 'テスト';
        propPhoto.PropertyPhotoFileName11__c = 'テスト';
        propPhoto.PropertyPhotoFileName12__c = 'テスト';
        propPhoto.PropertyPhotoFileName13__c = 'テスト';
        propPhoto.PropertyPhotoFileName14__c = 'テスト';
        propPhoto.PropertyPhotoFileName15__c = 'テスト';
        propPhoto.PropertyPhotoFileName16__c = 'テスト';
        propPhoto.PropertyPhotoFileName17__c = 'テスト';
        propPhoto.PropertyPhotoFileName18__c = 'テスト';
        propPhoto.PropertyPhotoFileName19__c = 'テスト';
        propPhoto.PropertyPhotoFileName20__c = 'テスト';

        // 非公開写真ファイル名
        propPhoto.PrivatePhotoFileName1__c = 'テスト';
        propPhoto.PrivatePhotoFileName2__c = 'テスト';
        propPhoto.PrivatePhotoFileName3__c = 'テスト';
        propPhoto.PrivatePhotoFileName4__c = 'テスト';
        propPhoto.PrivatePhotoFileName5__c = 'テスト';
        propPhoto.PrivatePhotoFileName6__c = 'テスト';
        propPhoto.PrivatePhotoFileName7__c = 'テスト';
        propPhoto.PrivatePhotoFileName8__c = 'テスト';

        // パノラマファイル名
        propPhoto.PanoramaFileName1__c = 'テスト';
        propPhoto.PanoramaFileName2__c = 'テスト';
        propPhoto.PanoramaFileName3__c = 'テスト';
        propPhoto.PanoramaFileName4__c = 'テスト';
        propPhoto.PanoramaFileName5__c = 'テスト';

        // 間取り図ファイル名
        propPhoto.RoomLayoutFileName__c = 'テスト';
        // 間取り図メモファイル名
        propPhoto.RoomLayoutMemoFileName__c = 'テスト';

        // 物件写真ファイル名
        propPhoto2.PropertyPhotoFileName1__c = 'テスト';
        propPhoto2.PropertyPhotoFileName2__c = 'テスト';
        propPhoto2.PropertyPhotoFileName3__c = 'テスト';
        propPhoto2.PropertyPhotoFileName4__c = 'テスト';
        propPhoto2.PropertyPhotoFileName5__c = 'テスト';
        propPhoto2.PropertyPhotoFileName6__c = 'テスト';
        propPhoto2.PropertyPhotoFileName7__c = 'テスト';
        propPhoto2.PropertyPhotoFileName8__c = 'テスト';
        propPhoto2.PropertyPhotoFileName9__c = 'テスト';
        propPhoto2.PropertyPhotoFileName10__c = 'テスト';
        propPhoto2.PropertyPhotoFileName11__c = 'テスト';
        propPhoto2.PropertyPhotoFileName12__c = 'テスト';
        propPhoto2.PropertyPhotoFileName13__c = 'テスト';
        propPhoto2.PropertyPhotoFileName14__c = 'テスト';
        propPhoto2.PropertyPhotoFileName15__c = 'テスト';
        propPhoto2.PropertyPhotoFileName16__c = 'テスト';
        propPhoto2.PropertyPhotoFileName17__c = 'テスト';
        propPhoto2.PropertyPhotoFileName18__c = 'テスト';
        propPhoto2.PropertyPhotoFileName19__c = 'テスト';
        propPhoto2.PropertyPhotoFileName20__c = 'テスト';

        // 非公開写真ファイル名
        propPhoto2.PrivatePhotoFileName1__c = 'テスト';
        propPhoto2.PrivatePhotoFileName2__c = 'テスト';
        propPhoto2.PrivatePhotoFileName3__c = 'テスト';
        propPhoto2.PrivatePhotoFileName4__c = 'テスト';
        propPhoto2.PrivatePhotoFileName5__c = 'テスト';
        propPhoto2.PrivatePhotoFileName6__c = 'テスト';
        propPhoto2.PrivatePhotoFileName7__c = 'テスト';
        propPhoto2.PrivatePhotoFileName8__c = 'テスト';

        // パノラマファイル名
        propPhoto2.PanoramaFileName1__c = 'テスト';
        propPhoto2.PanoramaFileName2__c = 'テスト';
        propPhoto2.PanoramaFileName3__c = 'テスト';
        propPhoto2.PanoramaFileName4__c = 'テスト';
        propPhoto2.PanoramaFileName5__c = 'テスト';

        // 間取り図ファイル名
        propPhoto2.RoomLayoutFileName__c = 'テスト';
        // 間取り図メモファイル名
        propPhoto2.RoomLayoutMemoFileName__c = 'テスト';

        upsert propPhoto;
        upsert propPhoto2;

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);
        Test.setCurrentPage(pageRef);
        
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();
        //メンテナンス情報と元付を右→左に名寄せ
        testController.FormerSupplierRadioButton= '右';
        testController.BasicInfoRadioButton= '左';
        testController.pictureRadioButton = '右';
        testController.floorPlanRadioButton = '右';
        testController.save();

    }

    //写真表示テスト
    @isTest static void matchPhotoCountTest(){
        Property__c pro1 = [SELECT Id FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id FROM Property__c WHERE Name = '右物件'];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;

        PropertyPhoto__c propPhoto = [
            SELECT id, PropertyPhotoFileName1__c FROM PropertyPhoto__c WHERE Property__c = :pro1.id
        ];
        PropertyPhoto__c propPhoto2 = [
            SELECT id, PropertyPhotoFileName1__c FROM PropertyPhoto__c WHERE Property__c = :pro2.id
        ];

        // 物件写真ファイル名
        propPhoto.PropertyPhotoFileName1__c = 'テスト';

        // 非公開写真ファイル名
        propPhoto.PrivatePhotoFileName1__c = 'テスト';

        // パノラマファイル名
        propPhoto.PanoramaFileName1__c = 'テスト';

        // 物件写真ファイル名
        propPhoto2.PropertyPhotoFileName1__c = 'テスト';
        propPhoto2.PropertyPhotoFileName2__c = 'テスト';

        // 非公開写真ファイル名
        propPhoto2.PrivatePhotoFileName1__c = 'テスト';
        propPhoto2.PrivatePhotoFileName2__c = 'テスト';

        // パノラマファイル名
        propPhoto2.PanoramaFileName1__c = 'テスト';
        propPhoto2.PanoramaFileName2__c = 'テスト';

        upsert propPhoto;
        upsert propPhoto2;

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);
        Test.setCurrentPage(pageRef);
        
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        // 物件写真ファイル名
        propPhoto.PropertyPhotoFileName1__c = 'テスト';
        propPhoto.PropertyPhotoFileName2__c = 'テスト';
        propPhoto.PropertyPhotoFileName3__c = 'テスト';

        // 非公開写真ファイル名
        propPhoto.PrivatePhotoFileName1__c = 'テスト';
        propPhoto.PrivatePhotoFileName2__c = 'テスト';
        propPhoto.PrivatePhotoFileName3__c = 'テスト';

        // パノラマファイル名
        propPhoto.PanoramaFileName1__c = 'テスト';
        propPhoto.PanoramaFileName2__c = 'テスト';
        propPhoto.PanoramaFileName3__c = 'テスト';
        upsert propPhoto;

        //パラメータ設定
        PageReference pageRef2 = Page.GD601008View;
        pageRef2.getParameters().put('id1', pro1.Id);
        pageRef2.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef2);
        GD601008Controller testController2 = new GD601008Controller();

    }

    @isTest static void RecommendPropertyExistTest(){

        //テストデータ作成
        //物件名寄せ比較の物件２つ
        Property__c pro1 = [SELECT Id,PropertyCode__c FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id,PropertyCode__c FROM Property__c WHERE Name = '右物件'];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;

        //おすすめ物件
        RecommendProperty__c osusume = new RecommendProperty__c(
            PropertyCode__c = pro1.PropertyCode__c,
            Property__c = pro1.id,
            PhotoFileName__c = 'PROPERTPHOTO',
            PanoramaTourUrl__c = 'testURL'
        );
        insert osusume;

        //おすすめ物件2
        RecommendProperty__c osusume2 = new RecommendProperty__c(
            PropertyCode__c = pro2.PropertyCode__c,
            Property__c = pro2.id,
            PhotoFileName__c = 'PROPERTPHOTO',
            PanoramaTourUrl__c = 'testURL'
        );
        insert osusume2;

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);

        Test.startTest();
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        testController.BasicInfoRadioButton= '左';
        testController.pictureRadioButton = '右';
        testController.save();

        Test.stopTest();
    }

    @isTest static void RecommendPropertyLeftExistTest(){

        //テストデータ作成
        //物件名寄せ比較の物件２つ
        Property__c pro1 = [SELECT Id,PropertyCode__c FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id,PropertyCode__c FROM Property__c WHERE Name = '右物件'];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;

        //おすすめ物件
        RecommendProperty__c osusume = new RecommendProperty__c(
            PropertyCode__c = pro1.PropertyCode__c,
            Property__c = pro1.id,
            PhotoFileName__c = 'PROPERTPHOTO',
            PanoramaTourUrl__c = 'testURL'
        );
        insert osusume;

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);

        Test.startTest();
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        testController.BasicInfoRadioButton= '左';
        testController.pictureRadioButton = '右';
        testController.save();

        Test.stopTest();
    }

    @isTest static void RecommendPropertyPhotoBuildTest(){

        //テストデータ作成
        //物件名寄せ比較の物件２つ
        Property__c pro1 = [SELECT Id,PropertyCode__c FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id,PropertyCode__c FROM Property__c WHERE Name = '右物件'];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;

        //おすすめ物件
        RecommendProperty__c osusume = new RecommendProperty__c(
            PropertyCode__c = pro1.PropertyCode__c,
            Property__c = pro1.id,
            PhotoFileName__c = 'APPEARANCE',
            PanoramaTourUrl__c = 'testURL'
        );
        insert osusume;

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);

        Test.startTest();
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        testController.BasicInfoRadioButton= '右';
        testController.pictureRadioButton = '左';
        testController.save();

        Test.stopTest();
    }

    @isTest static void RecommendPropertyDeletePhotoPathTest(){
        //テストデータ作成
        Building__c building = [SELECT id,ForeignID__c FROM Building__c];

        //テストデータ作成
        //物件名寄せ比較の物件２つ
        Property__c pro1 = [SELECT Id,PropertyCode__c,ForeignID__c FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id,PropertyCode__c,ForeignID__c FROM Property__c WHERE Name = '右物件'];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;

        PropertyPhoto__c proPhoto = [
            SELECT id, PropertyPhotoFileName1__c, PropertyPhotoFilePath1__c FROM PropertyPhoto__c WHERE Property__c = :pro1.id
        ];
        PropertyPhoto__c proPhoto2 = [
            SELECT id, PropertyPhotoFileName1__c, PropertyPhotoFilePath1__c FROM PropertyPhoto__c WHERE Property__c = :pro2.id
        ];

        String filePath = proPhoto.PropertyPhotoFilePath1__c;
        String filePath2 = proPhoto2.PropertyPhotoFilePath1__c;

        //おすすめ物件
        RecommendProperty__c osusume = new RecommendProperty__c(
            Property__c = pro1.id,
            PanoramaTourUrl__c = 'testURL',
            PhotoFileName__c = 'PROPERTPHOTO',
            PhotoFilePath__c = filePath
        );
        insert osusume;

        //おすすめ物件
        RecommendProperty__c osusume2 = new RecommendProperty__c(
            Property__c = pro2.id,
            PanoramaTourUrl__c = 'testURL',
            PhotoFileName__c = 'PROPERTPHOTO',
            PhotoFilePath__c = filePath2
        );
        insert osusume2;

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);

        Test.startTest();
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        testController.BasicInfoRadioButton= '右';
        testController.pictureRadioButton = '左';
        testController.save();

        Test.stopTest();
    }

    @isTest static void RecommendPropertyLeftExistPropertyTest(){

        //テストデータ作成
        //物件名寄せ比較の物件２つ
        Property__c pro1 = [SELECT Id,PropertyCode__c FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id,PropertyCode__c FROM Property__c WHERE Name = '右物件'];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;

        //おすすめ物件
        RecommendProperty__c osusume = new RecommendProperty__c(
            PropertyCode__c = pro1.PropertyCode__c,
            Property__c = pro1.id,
            PhotoFileName__c = 'PROPERTPHOTO',
            PanoramaTourUrl__c = 'testURL'
        );
        insert osusume;

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);

        Test.startTest();
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        testController.BasicInfoRadioButton= '右';
        testController.pictureRadioButton = '左';
        testController.save();

        Test.stopTest();
    }

    @isTest static void RecommendPropertyNotDeleteTest(){
        //テストデータ作成
        //物件名寄せ比較の物件２つ
        Property__c pro1 = [SELECT Id,PropertyCode__c FROM Property__c WHERE Name = '左物件'];
        Property__c pro2 = [SELECT Id,PropertyCode__c FROM Property__c WHERE Name = '右物件'];

        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_S3FILEMOVE_BATCHPROCESSING,
                                                        VariablesLabel__c = 'テスト',
                                                        BooleanValue__c = true);
        insert sysVar;

        //おすすめ物件
        RecommendProperty__c osusume = new RecommendProperty__c(
            PropertyCode__c = pro1.PropertyCode__c,
            Property__c = pro1.id,
            PhotoFileName__c = 'PROPERTPHOTO',
            PanoramaTourUrl__c = 'testURL'
        );
        insert osusume;

        //おすすめ物件
        RecommendProperty__c osusume2 = new RecommendProperty__c(
            PropertyCode__c = pro2.PropertyCode__c,
            Property__c = pro2.id,
            PhotoFileName__c = 'APPEARANCE',
            PanoramaTourUrl__c = 'testURL'
        );
        insert osusume2;

        //パラメータ設定
        PageReference pageRef = Page.GD601008View;
        pageRef.getParameters().put('id1', pro1.Id);
        pageRef.getParameters().put('id2', pro2.Id);

        Test.setCurrentPage(pageRef);

        Test.startTest();
        //コントローラ作成
        GD601008Controller testController = new GD601008Controller();

        testController.BasicInfoRadioButton= '左';
        testController.pictureRadioButton = '右';
        testController.save();

        Test.stopTest();
    }
}