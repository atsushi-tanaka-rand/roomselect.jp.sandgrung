/**
 * 申込登録（ipad）画面2のテスト
 */

@isTest 
private class GA103001Test2{
    @testSetup static void Setting(){
        // システム設定登録
        SystemConfig__c sysCon = new SystemConfig__c();
        sysCon.FormLogoPath__c= '/sfc/servlet.shepherd/version/download/0685h000001AAYMAA4';
		sysCon.TaxRate__c = 10;
        insert sysCon;

        //★取引先
        Account accountRecord1 = new Account(Name = 'テスト1保証株式会社',IsAllRentFeeType__c = true);	// 総賃料に口座手数料を含む
        Account accountRecord2 = new Account(Name = 'テスト2保証株式会社',IsAllRentFeeType__c = false);	// 総賃料に口座手数料を含まない
        Account accountRecord3 = new Account(Name = 'テスト3保証株式会社',IsAllRentFeeType__c = false); // 総賃料に口座手数料を含まない
		Account accountRecord4 = new Account(Name = 'テスト1火災保険株式会社'); // 火災保険
        List<Account> accountList = new List<Account> {accountRecord1,accountRecord2,accountRecord3,accountRecord4};
        insert accountList;
        //★商品
        //保証プラン
		// テスト1保証株式会社：付帯商品、賃料割合（保証会社）５０％、手数料１０００
        Item__c guaranteeItemRecord1 = new Item__c(Account__c = accountRecord1.id
                                        ,IsAuxiliary__c = true
                                        ,ItemName__c = 'テスト保証プラン1'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
                                        ,RentFeeRate__c = 50
                                        ,DirectDebitFee__c = 1000);
		// テスト2保証株式会社：付帯商品でない、賃料割合（保証会社）１０％、手数料２０００
        Item__c guaranteeItemRecord2 = new Item__c(Account__c = accountRecord2.id
                                        ,IsAuxiliary__c = false
                                        ,ItemName__c = 'テスト保証プラン2'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
                                        ,RentFeeRate__c = 10
                                        ,DirectDebitFee__c = 2000);
		// テスト2保証株式会社：付帯商品、賃料割合（保証会社）８０％、手数料８０００
        Item__c guaranteeItemRecord3 = new Item__c(Account__c = accountRecord2.id
                                        ,IsAuxiliary__c = true
                                        ,ItemName__c = 'テスト保証プラン3'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
                                        ,RentFeeRate__c = 80
                                        ,DirectDebitFee__c = 8000);
		// ▼ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
		// テスト1保証株式会社：付帯商品、賃料割合（保証会社）８０％、手数料８０００非課税
        Item__c guaranteeItemRecord4 = new Item__c(Account__c = accountRecord1.id
                                        ,IsAuxiliary__c = true
                                        ,ItemName__c = 'テスト保証プラン4'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
                                        ,RentFeeRate__c = 80
										,DirectDebitFeeTaxType__c = commonconst.PROPERTY_TAXTYPE_NOTAXABLE
                                        ,DirectDebitFee__c = 8000);
		// テスト1保証株式会社：付帯商品、賃料割合（保証会社）８０％、手数料８０００＋税込み
		Item__c guaranteeItemRecord5 = new Item__c(Account__c = accountRecord1.id
                                        ,IsAuxiliary__c = true
                                        ,ItemName__c = 'テスト保証プラン5'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
                                        ,RentFeeRate__c = 80
										,DirectDebitFeeTaxType__c = commonconst.PROPERTY_TAXTYPE_TAXABLE
                                        ,DirectDebitFee__c = 8000);
		// テスト3保証株式会社：付帯商品、賃料割合（保証会社）８０％、手数料なし
		Item__c guaranteeItemRecord6 = new Item__c(Account__c = accountRecord3.id
										,IsAuxiliary__c = true
										,ItemName__c = 'テスト保証プラン6'
										,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),commonConst.ITEM_RECTYPE_GUARANTEE_PLAN)
										,RentFeeRate__c = 80);
		// ▲ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
        //火災保険
		// テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）５０％、火災保険料（月額）１００００
        Item__c fireInsuranceItemRecord1 = new Item__c(Account__c = accountRecord4.id
                                        ,ItemName__c = 'テスト1火災保険'
                                        ,FireInsuranceMonth__c = 10000
										,InsuranceFeeRate__c = 50
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),CommonConst.ITEM_RECTYPE_FIRE_INSURANCE)
                                        ,IsAuxiliary__c = true
                                        ,PaymentType__c = commonconst.ITEM_PAYMENTTYPE_MONTH);
		// テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）１００％、火災保険料（月額）２００００
        Item__c fireInsuranceItemRecord2 = new Item__c(Account__c = accountRecord4.id
                                        ,ItemName__c = 'テスト2火災保険'
                                        ,FireInsuranceMonth__c = 20000
                                        ,InsuranceFeeRate__c = 100
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),CommonConst.ITEM_RECTYPE_FIRE_INSURANCE)
                                        ,IsAuxiliary__c = true
                                        ,PaymentType__c = commonconst.ITEM_PAYMENTTYPE_MONTH);
		// ▼ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
		// テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）１００％、火災保険料（年額）９００００
        Item__c fireInsuranceItemRecord3 = new Item__c(Account__c = accountRecord4.id
                                        ,ItemName__c = 'テスト3火災保険'
                                        ,FireInsuranceYear__c = 90000
                                        ,InsuranceFeeRate__c = 100
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),CommonConst.ITEM_RECTYPE_FIRE_INSURANCE)
                                        ,IsAuxiliary__c = true
                                        ,PaymentType__c = commonconst.ITEM_PAYMENTTYPE_YEAR);
		// ▲ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
        //消毒
        Item__c disinfectionItemRecord1 = new Item__c(Account__c = accountRecord1.id
                                        ,ItemName__c = '消毒1'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),'AuxiliaryItemRecordType')
                                        ,AuxiliaryItemFee__c = 5000
                                        ,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_DISINFECTION
                                        ,IsAuxiliary__c = true
                                        );
        Item__c disinfectionItemRecord2 = new Item__c(Account__c = accountRecord1.id
                                        ,ItemName__c = '消毒2'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),'AuxiliaryItemRecordType')
                                        ,AuxiliaryItemFee__c = 2000
                                        ,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_DISINFECTION
                                        ,IsAuxiliary__c = true
                                        ); 
        //鍵交換
        Item__c keyExchangeItemRecord1 = new Item__c(Account__c = accountRecord1.id
                                        ,ItemName__c = '鍵交換1'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),'AuxiliaryItemRecordType')
                                        ,AuxiliaryItemFee__c = 2000
                                        ,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_KEYEXCHANGE
                                        ,IsAuxiliary__c = true
                                        );
        //安心サポート
        Item__c reliableSupportItemRecord1 = new Item__c(Account__c = accountRecord1.id
                                        ,ItemName__c = '安心サポート1'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),'AuxiliaryItemRecordType')
                                        ,AuxiliaryItemFee__c = 10000
                                        ,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_RELIABLESUPPORT
                                        ,IsAuxiliary__c = true
                                        );
        //Fショット
        Item__c fshotItemRecord1 = new Item__c(Account__c = accountRecord1.id
                                        ,ItemName__c = 'Fショット1'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),'AuxiliaryItemRecordType')
                                        ,AuxiliaryItemFee__c = 2000
                                        ,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_FSHOT
                                        ,IsAuxiliary__c = true
                                        );
        //アルソック
        Item__c alsokItemRecord1 = new Item__c(Account__c = accountRecord1.id
                                        ,ItemName__c = 'アルソック1'
                                        ,RecordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),'AuxiliaryItemRecordType')
                                        ,AuxiliaryItemFee__c = 15000
                                        ,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_ALSOKLOCK
                                        ,IsAuxiliary__c = true
                                        ); 
        List<Item__c> itemList = new List<Item__c> {guaranteeItemRecord1,guaranteeItemRecord2,guaranteeItemRecord3,guaranteeItemRecord4,guaranteeItemRecord5,guaranteeItemRecord6,
                                                    fireInsuranceItemRecord1,fireInsuranceItemRecord2,fireInsuranceItemRecord3,
                                                    disinfectionItemRecord1,disinfectionItemRecord2,keyExchangeItemRecord1,reliableSupportItemRecord1,
                                                    fshotItemRecord1,alsokItemRecord1};
        insert itemList;
        //★商品明細
        ItemDetail__c itemDetail1 = new ItemDetail__c(PlanDetail__c = 'やすいプラン',IsRentFeeType__c = true,Item__c = guaranteeItemRecord1.id,FirstFeeDepositRate__c = 50,DepositRate__c=60);
        ItemDetail__c itemDetail2 = new ItemDetail__c(PlanDetail__c = 'ふつう',IsRentFeeType__c = true,Item__c = guaranteeItemRecord2.id,FirstFeeDepositRate__c = 50,DepositRate__c=60);
        ItemDetail__c itemDetail3 = new ItemDetail__c(PlanDetail__c = 'たかいプラン',IsRentFeeType__c = false,Item__c = guaranteeItemRecord3.id,FirstFeeDepositRate__c = 50,DepositRate__c=60);

		// ▼ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
		// 初回保証料(割合)
		// 総賃料、総賃料に口座振替手数料を含む、手数料税込み
		ItemDetail__c itemDetail4 = new ItemDetail__c(PlanDetail__c = '割合総賃料口座税込み',IsRentFeeType__c = true,Item__c = guaranteeItemRecord5.id,FirstFeeDepositRate__c = 50,DepositRate__c=60);
		// 総賃料、総賃料に口座振替手数料を含む、手数料税無し
		ItemDetail__c itemDetail5 = new ItemDetail__c(PlanDetail__c = '割合総賃料口座税無し',IsRentFeeType__c = true,Item__c = guaranteeItemRecord4.id,FirstFeeDepositRate__c = 50,DepositRate__c=60);
		// 総賃料、総賃料に口座振替手数料を含まない
		ItemDetail__c itemDetail6 = new ItemDetail__c(PlanDetail__c = '割合総賃料口座無し',IsRentFeeType__c = true,Item__c = guaranteeItemRecord6.id,FirstFeeDepositRate__c = 50,DepositRate__c=60);
		// 賃料
		ItemDetail__c itemDetail7 = new ItemDetail__c(PlanDetail__c = '割合賃料',IsRentFeeType__c = false,Item__c = guaranteeItemRecord4.id,FirstFeeDepositRate__c = 50,DepositRate__c=60);

		// 初回保証料(金額)
		ItemDetail__c itemDetail8 = new ItemDetail__c(PlanDetail__c = '金額',IsRentFeeType__c = false,Item__c = guaranteeItemRecord4.id,FirstFeeDepositYen__c = 10000,DepositYen__c=15000	);

        List<ItemDetail__c> itemDetailList = new List<ItemDetail__c> {itemDetail1,itemDetail2,itemDetail3
		,itemDetail4,itemDetail5,itemDetail6,itemDetail7,itemDetail8};
		// ▲ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
        insert itemDetailList;

        //★建物
        Building__c appBuildingRecord = new Building__c( Name = 'テスト建物1'
                                                         ,State__c = '愛知県'
                                                         ,City__c = '名古屋市中区'
                                                         ,Street__c = '1-1');
        insert appBuildingRecord;

        //★物件
        Property__c appPropertyRecord = new Property__c(Name = '101',Building__c = appBuildingRecord.id);
        insert appPropertyRecord;

        //★申込
        Application__c applicationRecord = new Application__c(
            Account__c = accountRecord1.id
            ,Property__c = appPropertyRecord.id
            ,LastName__c ='申込'
            ,ParkingBrokerageFirstFee__c=3000       // 駐車場紹介料
            ,isReviewEntry__c = true
            ,isReviewRequestProhibited__c =false
            ,AuxiliaryFireInsurance__c =fireInsuranceItemRecord1.id
            ,AuxiliaryFireInsuranceFee__c = 9999
            ,AuxiliaryItem1__c = disinfectionItemRecord1.id
            ,AuxiliaryItemFee1__c = 3000
            ,AuxiliaryReliableSupportFee__c = 0
            ,AllRentFee__c = 75000
            ,RentFee__c = 55000
            ,BrokerageFirstFee__c = 20000           // 仲介手数料
            ,ADFee__c = 5000                        // 広告宣伝費

        );
        insert applicationRecord;
    }
    //=========================================================================================
    //◇初期表示
    @isTest static void initializeTest(){
        Application__c applicationRecord = [SELECT Id
                    FROM Application__c
                    WHERE LastName__c ='申込'];
        //パラメータ設定
        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId',applicationRecord.Id );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA103001Controller2 testController = new GA103001Controller2();
        //初期値で設定されているテスト1火災保険の値段（申込での設定金額）が表示されている？
        system.assertEquals('9999', testController.screenTargetRecord.auxiliaryFireInsuranceFee.replace(',',''));
        system.assertEquals(null, testController.screenTargetRecord.auxiliaryDepositPlan);
    }
    //◇選択リスト変更
    @isTest static void selectListChangeTest(){
        Application__c applicationRecord = [SELECT Id
                    FROM Application__c
                    WHERE LastName__c ='申込'];
        Item__c itemRecord = [SELECT Id
                    FROM Item__c
                    WHERE ItemName__c ='テスト2火災保険'];        
        //パラメータ設定
        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId',applicationRecord.Id );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA103001Controller2 testController = new GA103001Controller2();
        //火災保険の選択リストをテスト2火災保険に変更
        testController.screenTargetRecord.auxiliaryFireInsurance = itemRecord.id;
        testController.fireInsuranceListChange();
        //スリープ
        CommonUtil.sleep(1000);
        //火災保険の金額がテスト2火災保険のものになっている？
        system.assertEquals('20000', testController.screenTargetRecord.auxiliaryFireInsuranceFee.replace(',',''));
    }
    //◇保存
    @isTest static void saveTest(){
        Application__c applicationRecord = [SELECT Id,SystemModStamp
                    FROM Application__c
                    WHERE LastName__c ='申込'];
        //パラメータ設定
        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId',applicationRecord.Id );
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA103001Controller2 testController = new GA103001Controller2();
        //スリープ
        CommonUtil.sleep(1000);
        //保存
        testController.save();
        //スリープ
        CommonUtil.sleep(1000);
        //新しくSystemModStampを取得
        Application__c afterTestTargetRecor = [SELECT SystemModStamp 
                                            FROM Application__c
                                            WHERE LastName__c = '申込']; 

        system.assertNotEquals(afterTestTargetRecor.SystemModStamp, applicationRecord.SystemModStamp);
    }
    //◇新規（異常）
    @isTest static void initializeErrorTest(){
        Application__c applicationRecord = [SELECT Id,SystemModStamp
                    FROM Application__c
                    WHERE LastName__c ='申込'];
        //パラメータ設定をしない
        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId','aa');
        Test.setCurrentPage(pageRef);
        //コントローラ作成
        GA103001Controller2 testController = new GA103001Controller2();


        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)));
    }

    //◇保存（異常）
    @isTest static void saveErrorTest(){
        Application__c applicationRecord = [SELECT Id,SystemModStamp
                    FROM Application__c
                    WHERE LastName__c ='申込'];
        //パラメータ設定
        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId',applicationRecord.Id );
        Test.setCurrentPage(pageRef);
        
        //コントローラ作成
        GA103001Controller2 testController = new GA103001Controller2();
        //先に更新
        applicationRecord.FirstName__c = 'aaa';
        update applicationRecord;
         //スリープ
        CommonUtil.sleep(1000);
        //保存
        testController.save();

         //スリープ
        CommonUtil.sleep(1000);
       
        List<ApexPages.Message> messages = ApexPages.getMessages();

        //System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)));
    }
    
    //カバレッジ率上昇
    @isTest static void forCoverage(){
        Application__c applicationRecord = [SELECT Id,SystemModStamp
                    FROM Application__c
                    WHERE LastName__c ='申込'];
        //パラメータ設定
        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId',applicationRecord.Id );
        Test.setCurrentPage(pageRef);
        
        //コントローラ作成
        GA103001Controller2 testController = new GA103001Controller2();
        
        //カバレッジ率上昇
        testController.clickNext();
        testController.depositPlanListChange();
        testController.fireInsuranceListChange();
        testController.checkBox();
        
    }

    // --------------------------
    // 再販対応追加分（付帯商品の複数登録）
    // 初期表示
    @isTest static void testInit() {
        //パラメータ設定
        Id applicationId = ([SELECT Id FROM Application__c WHERE LastName__c ='申込']).Id;
        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId',applicationId );
        Test.setCurrentPage(pageRef);

        //コントローラ作成
        GA103001Controller2 ctrl = new GA103001Controller2();
        GA103001Controller2.ScreenItem screen = ctrl.screenTargetRecord;

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
            , 'テスト1保証株式会社/消毒1/\\5,000'
            , 'テスト1保証株式会社/消毒2/\\2,000'
            , 'テスト1保証株式会社/鍵交換1/\\2,000'
            , 'テスト1保証株式会社/安心サポート1/\\10,000'
            , 'テスト1保証株式会社/Fショット1/\\2,000'
            , 'テスト1保証株式会社/アルソック1/\\15,000'
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

    // 画面項目変更
    @isTest static void testChangeScreen() {
        //パラメータ設定
        Id applicationId = ([SELECT Id FROM Application__c WHERE LastName__c ='申込']).Id;
        Id itemId2 = ([SELECT Id FROM Item__c WHERE ItemName__c = '消毒2']).Id;

        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId',applicationId );
        Test.setCurrentPage(pageRef);

        //コントローラ作成
        GA103001Controller2 ctrl = new GA103001Controller2();
        GA103001Controller2.ScreenItem screen = ctrl.screenTargetRecord;

        //（ 選択リスト）付帯商品種別の変更
        screen.EtceteraAuxiliaryItemType = '消毒';
        ctrl.EtceteraAuxiliaryItemTypeListChange();
        List<String> nameList = new List<String>{
              CommonConst.SELECTION_LIST_NULL
            , 'テスト1保証株式会社/消毒1/\\5,000'
            , 'テスト1保証株式会社/消毒2/\\2,000'
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
        pageRef.getParameters().put('ListIndex', '0');
        Test.setCurrentPage(pageRef);
        ctrl.removeEtceteraAuxiliaryItemList();
        system.assertEquals(1, screen.etceteraAuxiliaryItemList.size(), 'その他付帯商品リストの件数');
        system.assertEquals('消毒2', screen.etceteraAuxiliaryItemList[0].auxiliaryItemName);
        system.assertEquals(1889, screen.etceteraAuxiliaryItemList[0].auxiliaryItemFeeDec);
    }

    // 入力チェック
    @isTest static void testInputCheck() {
        //パラメータ設定
        Id applicationId = ([SELECT Id FROM Application__c WHERE LastName__c ='申込']).Id;
        Id itemId1 = ([SELECT Id FROM Item__c WHERE ItemName__c = '消毒1']).Id;

        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId',applicationId );
        Test.setCurrentPage(pageRef);

        //コントローラ作成
        GA103001Controller2 ctrl = new GA103001Controller2();
        GA103001Controller2.ScreenItem screen = ctrl.screenTargetRecord;

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
    }

    // 保存
    @isTest static void testSave() {
        //パラメータ設定
        Id applicationId = ([SELECT Id FROM Application__c WHERE LastName__c ='申込']).Id;
        Id itemId1 = ([SELECT Id FROM Item__c WHERE ItemName__c = '消毒1']).Id;
        Id itemId2 = ([SELECT Id FROM Item__c WHERE ItemName__c = '消毒2']).Id;

        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId', applicationId);
        Test.setCurrentPage(pageRef);

        //コントローラ作成
        GA103001Controller2 ctrl = new GA103001Controller2();
        GA103001Controller2.ScreenItem screen = ctrl.screenTargetRecord;

        ///// 画面項目の編集
        // 消毒２の追加
        screen.EtceteraAuxiliaryItemName = itemId2;
        ctrl.EtceteraAuxiliaryItemNameListChange();
        screen.EtceteraAuxiliaryItemFee = '1,889';
        ctrl.addEtceteraAuxiliaryItemList();
        // 消毒１の削除
        pageRef.getParameters().put('ListIndex', '0');
        Test.setCurrentPage(pageRef);
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
        ctrl.save();
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
                WHERE LastName__c ='申込'
        ];
        system.assertEquals(itemId2, updateRec.AuxiliaryItem1__c,    '登録データの確認_付帯商品１');
        system.assertEquals(1889,    updateRec.auxiliaryItemFee1__c, '登録データの確認_付帯商品料１');
        for (Integer i = 2; i <= 10; i++) {
            system.assertEquals(itemId1,  updateRec.get('AuxiliaryItem' + i + '__c'),    '登録データの確認_付帯商品' + i);
            system.assertEquals(4000 + i, updateRec.get('auxiliaryItemFee' + i + '__c'), '登録データの確認_付帯商品料' + i);
        }
    }

	// ▼ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
    /**
    * 付帯保証プラン選択時
    * 「--なし--」を選択時、金額が空になること
	* 対象の金額を選択時、計算された内容にマージンがセットされること
    * ※複数パターン有
    */
    @isTest static void depositPlanListChangeTest() {
        //パラメータ設定
        Id applicationId = ([SELECT Id FROM Application__c WHERE LastName__c ='申込']).Id;

		// 選択用商品明細のID取得
		List<ItemDetail__c> itemDetailList = ([SELECT Id,PlanDetail__c FROM ItemDetail__c ]);
		// プラン詳細をmapのキーにする
		Map<String,Id> itemDetailIdMap = new Map<String,Id>();
		for (ItemDetail__c ItemDetail : itemDetailList) {
			itemDetailIdMap.put(ItemDetail.PlanDetail__c, ItemDetail.Id);
		}

        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId', applicationId);
        Test.setCurrentPage(pageRef);

		Test.startTest();

        //コントローラ作成
        GA103001Controller2 testController = new GA103001Controller2();
        GA103001Controller2.ScreenItem screen = testController.screenTargetRecord;

		///// 画面項目の編集
		// 対象の金額を選択時、計算された内容にマージンがセットされること
		screen.auxiliaryDepositPlan = itemDetailIdMap.get('金額');
		testController.depositPlanListChange();
		String auxiliaryDepositPlanFeeYen = screen.auxiliaryDepositPlanFee;

		// 「--なし--」を選択時、金額が空になること
		screen.auxiliaryDepositPlan = itemDetailIdMap.get('');
		testController.depositPlanListChange();
		String auxiliaryDepositPlanFeeNothing = screen.auxiliaryDepositPlanFee;
		Test.stopTest();

		// 初回保証料(金額)を選択した表示額
		system.assertEquals(8000, CommonUtil.stringToDecimal(auxiliaryDepositPlanFeeYen));
		// 「--なし--」を選択時、金額が空になること
		system.assertEquals(null, CommonUtil.stringToDecimal(auxiliaryDepositPlanFeeNothing));

    }
    /**
    * 付帯火災保険選択後
    * 「--なし--」を選択時、金額が空になること
	* 対象の金額を選択時、計算された内容にマージンがセットされること
    * ※複数パターン有
    */
    @isTest static void auxiliaryFireInsuranceFeeTest() {
        //パラメータ設定
        Id applicationId = ([SELECT Id FROM Application__c WHERE LastName__c ='申込']).Id;

        // レコードタイプ：火災保険
        Id recordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),CommonConst.ITEM_RECTYPE_FIRE_INSURANCE);
		// 選択用商品のID取得
		List<Item__c> itemList = ([SELECT Id,ItemName__c FROM Item__c WHERE RecordTypeId = :recordTypeId AND IsAuxiliary__c = true]);
		// プラン詳細をmapのキーにする
		Map<String,Id> itemMap = new Map<String,Id>();
		for (Item__c Item : itemList) {
			itemMap.put(Item.ItemName__c, Item.Id);
		}

        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId', applicationId);
        Test.setCurrentPage(pageRef);

		Test.startTest();

        //コントローラ作成
        GA103001Controller2 testController = new GA103001Controller2();
        GA103001Controller2.ScreenItem screen = testController.screenTargetRecord;

		///// 画面項目の編集
		// 対象の金額を選択時、計算された内容にマージンがセットされること
        // テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）５０％、火災保険料（月額）１００００
		screen.auxiliaryFireInsurance = itemMap.get('テスト1火災保険');
		testController.fireInsuranceListChange();
		String auxiliaryFireInsuranceFeeRate = screen.auxiliaryFireInsuranceFee;

        // テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）１００％、火災保険料（月額）２００００
        screen.auxiliaryFireInsurance = itemMap.get('テスト2火災保険');
		testController.fireInsuranceListChange();
		String auxiliaryFireInsuranceFeeYen = screen.auxiliaryFireInsuranceFee;

        // テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）１００％、火災保険料（年額）９００００
        screen.auxiliaryFireInsurance = itemMap.get('テスト3火災保険');
		testController.fireInsuranceListChange();
		String auxiliaryFireInsuranceFeeYear = screen.auxiliaryFireInsuranceFee;

		// 「--なし--」を選択時、金額が空になること
		screen.auxiliaryFireInsurance = itemMap.get('');
		testController.fireInsuranceListChange();
		String auxiliaryFireInsuranceFeeNothing = screen.auxiliaryFireInsuranceFee;
		Test.stopTest();

		// テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）５０％、火災保険料（月額）１００００
		system.assertEquals(5000, CommonUtil.stringToDecimal(auxiliaryFireInsuranceFeeRate));
		// テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）１００％、火災保険料（月額）２００００
		system.assertEquals(20000, CommonUtil.stringToDecimal(auxiliaryFireInsuranceFeeYen));

        // テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）１００％、火災保険料（年額）９００００
		system.assertEquals(90000, CommonUtil.stringToDecimal(auxiliaryFireInsuranceFeeYear));

        // 「‐―なし‐‐」」を選択時、金額が空になること
		system.assertEquals(null, CommonUtil.stringToDecimal(auxiliaryFireInsuranceFeeNothing));

    }

    /**
    * 付帯保証プラン選択時（更新後）
    * 「--なし--」を選択時、金額が空になること
	* 対象の金額を選択時、計算された内容にマージンがセットされること
    * ※複数パターン有
    */
    @isTest static void depositPlanListChangeUpDateTest() {
        //パラメータ設定
        Id applicationId = ([SELECT Id FROM Application__c WHERE LastName__c ='申込']).Id;

		// 選択用商品明細のID取得
		List<ItemDetail__c> itemDetailList = ([SELECT Id,PlanDetail__c FROM ItemDetail__c ]);
		// プラン詳細をmapのキーにする
		Map<String,Id> itemDetailIdMap = new Map<String,Id>();
		for (ItemDetail__c ItemDetail : itemDetailList) {
			itemDetailIdMap.put(ItemDetail.PlanDetail__c, ItemDetail.Id);
		}

        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId', applicationId);
        Test.setCurrentPage(pageRef);

        //コントローラ作成
        GA103001Controller2 testController = new GA103001Controller2();
        GA103001Controller2.ScreenItem screen = testController.screenTargetRecord;

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
	
		// 保存
		testController.save();
		Application__c beforeApplication = ([SELECT Id,AuxiliaryDepositPlan__c,AuxiliaryDepositPlanFee__c FROM Application__c WHERE LastName__c ='申込' LIMIT 1]);


		// 更新後
		Test.startTest();

		//コントローラ作成
		GA103001Controller2 testController2 = new GA103001Controller2();
		GA103001Controller2.ScreenItem screen2 = testController2.screenTargetRecord;
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
		// 保存
		testController2.save();
		Test.stopTest();
		
		Application__c afterApplication = ([SELECT Id,AuxiliaryDepositPlan__c,AuxiliaryDepositPlanFee__c FROM Application__c WHERE LastName__c ='申込' LIMIT 1]);

		// 割合総賃料口座税込み
		system.assertEquals(auxiliaryDepositPlanFeeWari4, '33,520');
		system.assertEquals(auxiliaryDepositPlanFeeWari24,'33,520' );
		// 割合総賃料口座税無し
		system.assertEquals(auxiliaryDepositPlanFeeWari3, '33,200');
		system.assertEquals(auxiliaryDepositPlanFeeWari23,'33,200');

		// 割合総賃料口座無し
		system.assertEquals(auxiliaryDepositPlanFeeWari2, '30,000');
		system.assertEquals(auxiliaryDepositPlanFeeWari22,'30,000' );
		// 割合賃料
		system.assertEquals(auxiliaryDepositPlanFeeWari1, '22,000');
		system.assertEquals(auxiliaryDepositPlanFeeWari21,'22,000');

		// 金額を選択
		system.assertEquals(auxiliaryDepositPlanFeeYen, '8,000');
		system.assertEquals(auxiliaryDepositPlanFeeYen2,'8,000' );
		// 「--なし--」を選択時、金額が空になること
		system.assertEquals(auxiliaryDepositPlanFeeNothing, null);
		system.assertEquals(auxiliaryDepositPlanFeeNothing2,null );

		// 保存内容が一致しない事
		system.assertNotEquals(beforeApplication.AuxiliaryDepositPlan__c, afterApplication.AuxiliaryDepositPlan__c);
		system.assertNotEquals(beforeApplication.AuxiliaryDepositPlanFee__c, afterApplication.AuxiliaryDepositPlanFee__c);
		

    }
    /**
    * 付帯火災保険選択後（更新後）
    * 「--なし--」を選択時、金額が空になること
	* 対象の金額を選択時、計算された内容にマージンがセットされること
    * ※複数パターン有
    */
    @isTest static void auxiliaryFireInsuranceFeeUpDateTest() {
        //パラメータ設定
        Id applicationId = ([SELECT Id FROM Application__c WHERE LastName__c ='申込']).Id;

        Id recordTypeId = commonUtil.getRecordTypeId(commonUtil.getNamespace('Item__c'),CommonConst.ITEM_RECTYPE_FIRE_INSURANCE);
		// 選択用商品のID取得
		List<Item__c> itemList = ([SELECT Id,ItemName__c FROM Item__c WHERE RecordTypeId = :recordTypeId]);
		// プラン詳細をmapのキーにする
		Map<String,Id> itemMap = new Map<String,Id>();
		for (Item__c Item : itemList) {
			itemMap.put(Item.ItemName__c, Item.Id);
		}

        PageReference pageRef = Page.GA103001View;
        pageRef.getParameters().put('applicationId', applicationId);
        Test.setCurrentPage(pageRef);

        //コントローラ作成
        GA103001Controller2 testController = new GA103001Controller2();
        GA103001Controller2.ScreenItem screen = testController.screenTargetRecord;

		///// 画面項目の編集
		// 対象の金額を選択時、計算された内容にマージンがセットされること
        // テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）５０％、火災保険料（月額）１００００
		screen.auxiliaryFireInsurance = itemMap.get('テスト1火災保険');
		testController.fireInsuranceListChange();
		String auxiliaryFireInsuranceFeeRate = screen.auxiliaryFireInsuranceFee;

        // テスト1火災保険株式会社：付帯商品、火災保険料（月額）２００００
        screen.auxiliaryFireInsurance = itemMap.get('テスト2火災保険');
		testController.fireInsuranceListChange();
		String auxiliaryFireInsuranceFeeYen = screen.auxiliaryFireInsuranceFee;

		// 「--なし--」を選択時、金額が空になること
		screen.auxiliaryFireInsurance = itemMap.get('');
		testController.fireInsuranceListChange();
		String auxiliaryFireInsuranceFeeNothing = screen.auxiliaryFireInsuranceFee;

		// 金額を手入力で変更
		screen.auxiliaryFireInsurance = itemMap.get('テスト1火災保険');
		testController.fireInsuranceListChange();
		screen.auxiliaryFireInsuranceFee = '123456';

		// 保存
		testController.save();

		Application__c beforeApplication = ([SELECT Id,AuxiliaryFireInsurance__c,AuxiliaryFireInsuranceFee__c FROM Application__c WHERE LastName__c ='申込' LIMIT 1]);

		// 更新後
		Test.startTest();

        //コントローラ作成
        GA103001Controller2 testController2 = new GA103001Controller2();
        GA103001Controller2.ScreenItem screen2 = testController2.screenTargetRecord;
		///// 画面項目の編集
		// 対象の金額を選択時、計算された内容にマージンがセットされること
        // テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）５０％、火災保険料（月額）１００００
		screen2.auxiliaryFireInsurance = itemMap.get('テスト1火災保険');
		testController2.fireInsuranceListChange();
		String auxiliaryFireInsuranceFeeRate2 = screen2.auxiliaryFireInsuranceFee;

        // テスト1火災保険株式会社：付帯商品、火災保険料（月額）２００００
        screen2.auxiliaryFireInsurance = itemMap.get('テスト2火災保険');
		testController2.fireInsuranceListChange();
		String auxiliaryFireInsuranceFeeYen2 = screen2.auxiliaryFireInsuranceFee;

		// 「--なし--」を選択時、金額が空になること
		screen2.auxiliaryFireInsurance = itemMap.get('');
		testController2.fireInsuranceListChange();
		String auxiliaryFireInsuranceFeeNothing2 = screen2.auxiliaryFireInsuranceFee;

		// 金額を手入力で変更
        screen2.auxiliaryFireInsurance = itemMap.get('テスト2火災保険');
		testController2.fireInsuranceListChange();
        screen2.auxiliaryFireInsuranceFee = '654321';
		// 保存
		testController2.save();
		Test.stopTest();

		Application__c afterApplication = ([SELECT Id,AuxiliaryFireInsurance__c,AuxiliaryFireInsuranceFee__c FROM Application__c WHERE LastName__c ='申込' LIMIT 1]);

		// テスト1火災保険株式会社：付帯商品、保険料割合（火災保険）５０％、火災保険料（月額）１００００
		system.assertEquals(auxiliaryFireInsuranceFeeRate,'5,000');
		system.assertEquals(auxiliaryFireInsuranceFeeRate2, '5,000');
		// テスト1火災保険株式会社：付帯商品、火災保険料（月額）２００００
		system.assertEquals(auxiliaryFireInsuranceFeeYen, '20,000');
		system.assertEquals(auxiliaryFireInsuranceFeeYen2, '20,000');

        // 「‐―なし‐‐」」を選択時、金額が空になること
		system.assertEquals(auxiliaryFireInsuranceFeeNothing, null);
		system.assertEquals(auxiliaryFireInsuranceFeeNothing2, null);

		// 保存内容が一致しない事
		system.assertNotEquals(beforeApplication.AuxiliaryFireInsurance__c, afterApplication.AuxiliaryFireInsurance__c);
		system.assertNotEquals(beforeApplication.AuxiliaryFireInsuranceFee__c, afterApplication.AuxiliaryFireInsuranceFee__c);

    }
    // ▲ 2022.02.15 No0727 付帯保証プラン・火災保証プランの金額変更
}