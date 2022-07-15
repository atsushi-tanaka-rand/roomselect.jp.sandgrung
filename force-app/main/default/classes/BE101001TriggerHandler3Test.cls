// 日報集計部品（物件メンテナンス履歴トリガー）のテストクラス
// 3.申込オブジェクトのトリガー起動テスト

@ isTest
private class BE101001TriggerHandler3Test {

    @TestSetup
    // テストに利用するListを用意する。
    static void Setting(){

        // 対応のListを用意する。
        List<Correspond__c> addCorrespondList = new List<Correspond__c>();
        List<Correspond__c> updCorrespondList = new List<Correspond__c>();
        Correspond__c addCorrespond = new Correspond__c();
        Correspond__c updCorrespond = new Correspond__c();


        // 対応オブジェクトを生成
        addCorrespond = new Correspond__c(
                Status__c = CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION
                ,Memo__c = '更新_金額上書きなし'
        );
        // Listに入れる。
        addCorrespondList.add(addCorrespond);

        // 対応オブジェクトを生成
        addCorrespond = new Correspond__c(
                Status__c = CommonConst.CORRESPOND_STATUS_DEPOSIT
                ,Memo__c = '更新_金額上書きあり'
        );
        // Listに入れる。
        addCorrespondList.add(addCorrespond);

        // 対応オブジェクトを生成
        for (Integer i = 0; i < 10; i++){ 
            addCorrespond = new Correspond__c(
                    Status__c = CommonConst.CORRESPOND_STATUS_ECHOAGGREGATION
                    ,Memo__c = '登録'
            );
            // Listに入れる。
            addCorrespondList.add(addCorrespond);
        }

        // insertを実施。
        insert addCorrespondList;


        // 取引先
        Id accountRecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER);
        Account customer = new Account(Name = 'テスト顧客', LastName__c = 'テスト', FirstName__c = '顧客', RecordTypeId = accountRecordTypeId);
        insert customer;

        // 取引先（顧客）
        Account AccountRecord = new Account(
            Name                    = 'テスト太郎'                  // 取引先名
            , LastName__c           = 'テスト'                      // 取引先（姓）
            , FirstName__c          = '太郎'                        // 取引先（名）
            , NameKana__c           = 'ﾃｽﾄﾀﾛｳ'                      // 取引先名（カナ）
            , Phone                 = '025-200-1234'                // 電話番号
            , Email__c              = 'aaa@hora'                    // メール
            , state__c              = '大阪府'                      // 都道府県
            , city__c               = '大阪市'                      // 住所１（市区町村）
            , street__c             = '中央区安土町４－１'          // 住所２（番地）
            , sex__c                = '女性'                        // 性別
            , PostalCode__c         = '1234567'                     // 郵便番号
            , HomeMovingDate__c     = date.valueof('2020-04-01')    // 引越時期
            , Birthdate__c          = commonutil.getToday()
            , ContractType__c       = '個人契約'
            , RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER) //レコードタイプID（顧客）
        );
        insert AccountRecord; 

        // 商品
        List<Item__c> ItemRecord = new List<Item__c>();
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = 'テスト保証プラン1', RecordTypeId = commonUtil.getRecordTypeId('Item__c','GuaranteePlanRecordType'),auxiliaryItemFeeTaxType__c = '課税',  RentFeeRate__c = 50,DirectDebitFee__c = 1000,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = 'テスト1火災保険'  , RecordTypeId = commonUtil.getRecordTypeId('Item__c','FireInsuranceRecordType'),auxiliaryItemFeeTaxType__c = '課税',  FireInsuranceMonth__c = 10000,PaymentType__c = '月型',IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = 'テスト2火災保険'  , RecordTypeId = commonUtil.getRecordTypeId('Item__c','FireInsuranceRecordType'),auxiliaryItemFeeTaxType__c = '課税',  FireInsuranceMonth__c = 20000,PaymentType__c = '月型',IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = '消毒1'            , RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),auxiliaryItemFeeTaxType__c = '課税',  AuxiliaryItemFee__c = 5000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_DISINFECTION,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = '消毒2'            , RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),auxiliaryItemFeeTaxType__c = '非課税',AuxiliaryItemFee__c = 2000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_DISINFECTION,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = '鍵交換1'          , RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),auxiliaryItemFeeTaxType__c = '課税',  AuxiliaryItemFee__c = 2000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_KEYEXCHANGE,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = '安心サポート1'    , RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),auxiliaryItemFeeTaxType__c = '非課税',AuxiliaryItemFee__c = 10000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_RELIABLESUPPORT,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = 'Fショット1'       , RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),auxiliaryItemFeeTaxType__c = '課税',  AuxiliaryItemFee__c = 2000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_FSHOT,IsAuxiliary__c = true));
        ItemRecord.add(new Item__c(Account__c = AccountRecord.id, ItemName__c = 'アルソック1'      , RecordTypeId = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType'),auxiliaryItemFeeTaxType__c = '非課税',AuxiliaryItemFee__c = 15000,AuxiliaryItemType__c = commonConst.AUXILIARY_ITEM_TYPE_ALSOKLOCK,IsAuxiliary__c = true));
        insert ItemRecord;
    }

    // insertUpdateTest_EchoTotal
    // 反響累計登録と更新の対象となる全パターンテスト
    // ※最初に登録し、同じデータで再度登録を行うことで更新を促す
    @isTest static void insertUpdateTest_EchoTotal(){

        // 対応のListを用意する。
        List<Application__c> addApplicationList = new List<Application__c>();
        List<Application__c> updApplicationList = new List<Application__c>();

        Application__c addApplication = new Application__c();
        Application__c updApplication = new Application__c();

        Account customer = [SELECT ID FROM Account LIMIT 1];

        // 対応データを取得
        List<Correspond__c> correspondList = [
                                        SELECT Id
                                            , Memo__c
                                        FROM  Correspond__c
                                        ];

        for (Correspond__c correspond : correspondList) {
            
            // ＜登録用処理＞
            // 申込オブジェクトを生成
            if (correspond.Memo__c == '更新_金額上書きなし') {

                addApplication = new Application__c(
                        Corresponds__c = correspond.Id
                        ,Account__c = customer.Id
                        ,JointGuarantorLastName__c = '更新_金額上書きなし'
                        ,BrokerageFirstFee__c = 100
                        ,ParkingBrokerageFirstFee__c = 200
                        ,ADFee__c = 300
                        ,AuxiliaryDepositPlanFee__c = 400
                        ,AuxiliaryFireInsuranceFee__c = 500
                );
                // Listに入れる。
                addApplicationList.add(addApplication);

            } else if (correspond.Memo__c == '更新_金額上書きあり') {

                addApplication = new Application__c(
                        Corresponds__c = correspond.Id
                        ,Account__c = customer.Id
                        ,JointGuarantorLastName__c = '更新_金額上書きあり'
                        ,BrokerageFirstFee__c = 100
                        ,ParkingBrokerageFirstFee__c = 200
                        ,ADFee__c = 300
                        ,AuxiliaryDepositPlanFee__c = 400
                        ,AuxiliaryFireInsuranceFee__c = 500
                );
                // Listに入れる。
                addApplicationList.add(addApplication);

            } else if (correspond.Memo__c == '登録') {

                // 対応.メモ＝'登録'
                addApplication = new Application__c(
                        Corresponds__c = correspond.Id
                        ,Account__c = customer.Id
                        ,JointGuarantorLastName__c = '登録'
                        ,BrokerageFirstFee__c = 100
                        ,ParkingBrokerageFirstFee__c = 200
                        ,ADFee__c = 300
                        ,AuxiliaryDepositPlanFee__c = 400
                        ,AuxiliaryFireInsuranceFee__c = 500
                );
                // Listに入れる。
                addApplicationList.add(addApplication);
            } 
        }

        // 対応に紐づかない申込
        addApplication = new Application__c(
                Account__c = customer.Id
                ,JointGuarantorLastName__c = '対応なし'
                ,BrokerageFirstFee__c = 100
                ,ParkingBrokerageFirstFee__c = 200
                ,ADFee__c = 300
                ,AuxiliaryDepositPlanFee__c = 400
                ,AuxiliaryFireInsuranceFee__c = 500
        );
        // Listに入れる。
        addApplicationList.add(addApplication);

        // insertを実施。
        insert addApplicationList;

        // 登録した申込オブジェクトを取得する
        List<Application__c> applicationList = [
                                        SELECT Id
                                            ,BrokerageFirstFee__c
                                            ,ParkingBrokerageFirstFee__c
                                            ,ADFee__c
                                            ,AuxiliaryDepositPlanFee__c
                                            ,AuxiliaryFireInsuranceFee__c
                                            ,AuxiliaryIndoorDisinfectionFee__c
                                            ,AuxiliaryKeyExchangeFee__c
                                            ,AuxiliaryReliableSupportFee__c
                                            ,AuxiliaryFShotFee__c
                                            ,AuxiliaryAlsokLockFee__c
                                        FROM  Application__c
                                        ];

        // 取得した件数分、更新処理を実施
        for (Application__c application : applicationList) {

            updApplication = new Application__c(
                    Id = application.Id,
                    PaymentDate__c = CommonUtil.getToday()
            );
            // Listに入れる。
            updApplicationList.add(updApplication);
        }
        // updateを実施。
        update updApplicationList;

    }

    // 申込データ登録テスト1：入金日は未登録
    @isTest static void testInsertApplication1() {
        TriggerTest test = new TriggerTest('登録', 'テスト顧客');
        Map<String, Item__c> itemMap = getItemMap();

        // 申込登録
        test.createNewApplication();
        for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            test.application.put(makeAuxName(i), itemMap.get('消毒1').id);
            test.application.put(makeAuxFeeName(i), 1000 + i);
        }
        test.testInsert();

        // 結果確認
        System.assertEquals(0, test.auxiList.size(), '付帯商品反響累計の登録件数');
    }

    // 申込データ登録テスト2：入金日を登録⇒反響累計の新規登録時は付帯商品反響累計は登録されない
    @isTest static void testInsertApplication2() {
        TriggerTest test = new TriggerTest('登録', 'テスト顧客');
        Map<String, Item__c> itemMap = getItemMap();

        // 申込登録
        test.createNewApplication();
        for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            test.application.put(makeAuxName(i), itemMap.get('消毒1').id);
            test.application.put(makeAuxFeeName(i), 1000 + i);
        }
        test.application.PaymentDate__c = Date.today();
        test.testInsert();

        // 結果確認
        System.assertEquals(0, test.auxiList.size(), '付帯商品反響累計の登録件数');
    }

    // 申込データ更新テスト１：入金日未設定⇒付帯商品反響累計は未登録
    @isTest static void testUpdateApplication1() {
        TriggerTest test = new TriggerTest('登録', 'テスト顧客');
        Map<String, Item__c> itemMap = getItemMap();

        // 申込登録
        test.createNewApplication();
        test.testInsert();

        // 申込更新
        for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            test.application.put(makeAuxName(i), itemMap.get('消毒1').id);
            test.application.put(makeAuxFeeName(i), 1000 + i);
        }
        test.testUpdate();

        // 結果確認
        System.assertEquals(0, test.auxiList.size(), '付帯商品反響累計の登録件数');
    }

    // 申込データ更新テスト２：入金日を設定⇒付帯商品反響累計の金額は申込金額で更新
    @isTest static void testUpdateApplication2() {
        TriggerTest test = new TriggerTest('登録', 'テスト顧客');
        Map<String, Item__c> itemMap = getItemMap();

        // 申込登録
        test.createNewApplication();
        test.testInsert();

        // 申込更新
        test.application.put(makeAuxName(1), itemMap.get('消毒1').id);
        test.application.put(makeAuxFeeName(1), 1001);
        test.application.put(makeAuxName(2), itemMap.get('鍵交換1').id);
        test.application.put(makeAuxFeeName(2), 1002);
        test.application.put(makeAuxName(3), itemMap.get('安心サポート1').id);
        test.application.put(makeAuxFeeName(3), 1003);
        test.application.put(makeAuxName(4), itemMap.get('Fショット1').id);
        test.application.put(makeAuxFeeName(4), 1004);
        test.application.put(makeAuxName(5), itemMap.get('アルソック1').id);
        test.application.put(makeAuxFeeName(5), 1005);
        for (Integer i = 6; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            test.application.put(makeAuxName(i), itemMap.get('消毒2').id);
            test.application.put(makeAuxFeeName(i), 1000 + i);
        }
        test.application.PaymentDate__c = Date.today();
        test.testUpdate();

        // 結果確認
        System.assertEquals(10, test.auxiList.size(), '付帯商品反響累計の登録件数');
        System.assertEquals('消毒',         test.auxiList[0].AuxiliaryItemType__c, '付帯商品種別1の確認');
        System.assertEquals(1001,           test.auxiList[0].AuxiliaryItemFee__c,  '付帯商品料1の金額確認');
        System.assertEquals('鍵交換',       test.auxiList[1].AuxiliaryItemType__c, '付帯商品種別2の確認');
        System.assertEquals(1002,           test.auxiList[1].AuxiliaryItemFee__c,  '付帯商品料2の金額確認');
        System.assertEquals('安心サポート', test.auxiList[2].AuxiliaryItemType__c, '付帯商品種別3の確認');
        System.assertEquals(1003,           test.auxiList[2].AuxiliaryItemFee__c,  '付帯商品料3の金額確認');
        System.assertEquals('Fショット',    test.auxiList[3].AuxiliaryItemType__c, '付帯商品種別4の確認');
        System.assertEquals(1004,           test.auxiList[3].AuxiliaryItemFee__c,  '付帯商品料4の金額確認');
        System.assertEquals('アルソック',   test.auxiList[4].AuxiliaryItemType__c, '付帯商品種別5の確認');
        System.assertEquals(1005,           test.auxiList[4].AuxiliaryItemFee__c,  '付帯商品料5の金額確認');
        for (Integer i = 6; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            System.assertEquals(itemMap.get('消毒2').AuxiliaryItemType__c, test.auxiList[i-1].AuxiliaryItemType__c, '付帯商品種別' + i + 'の確認');
            System.assertEquals(1000 + i, test.auxiList[i-1].AuxiliaryItemFee__c, '付帯商品料' + i + 'の金額確認');
        }
    }

    // 申込データ更新テスト３：入金日を登録後にもう一度更新⇒付帯商品反響累計は再登録時のもの
    @isTest static void testUpdateApplication3() {
        TriggerTest test = new TriggerTest('登録', 'テスト顧客');
        Map<String, Item__c> itemMap = getItemMap();

        // 申込登録
        test.createNewApplication();
        test.testInsert();

        // 申込更新1
        for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            test.application.put(makeAuxName(i), itemMap.get('消毒1').id);
            test.application.put(makeAuxFeeName(i), 1000 + i);
        }
        test.application.PaymentDate__c = Date.today();
        test.testUpdate();

        // 申込更新2
        for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            test.application.put(makeAuxName(i), itemMap.get('消毒2').id);
            test.application.put(makeAuxFeeName(i), 2000 + i);
        }
        test.testUpdate();

        // 結果確認
        System.assertEquals(10, test.auxiList.size(), '付帯商品反響累計の登録件数');
        for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            System.assertEquals(itemMap.get('消毒2').AuxiliaryItemType__c, test.auxiList[i-1].AuxiliaryItemType__c, '付帯商品種別' + i + 'の確認');
            System.assertEquals(2000 + i, test.auxiList[i-1].AuxiliaryItemFee__c, '付帯商品料' + i + 'の金額確認');
        }
    }

    // 申込データ更新テスト４：入金日を登録後に削除⇒付帯商品反響累計は再登録時のものとなる
    @isTest static void testUpdateApplication4() {
        TriggerTest test = new TriggerTest('登録', 'テスト顧客');
        Map<String, Item__c> itemMap = getItemMap();

        // 申込登録
        test.createNewApplication();
        test.testInsert();

        // 申込更新1
        for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            test.application.put(makeAuxName(i), itemMap.get('消毒1').id);
            test.application.put(makeAuxFeeName(i), 1000 + i);
        }
        test.application.PaymentDate__c = Date.today();
        test.testUpdate();

        // 申込更新2
        for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            test.application.put(makeAuxName(i), itemMap.get('消毒2').id);
            test.application.put(makeAuxFeeName(i), 2000 + i);
        }
        test.application.PaymentDate__c = null;
        test.testUpdate();

        // 結果確認
        System.assertEquals(10, test.auxiList.size(), '付帯商品反響累計の登録件数');
        for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            System.assertEquals(itemMap.get('消毒2').AuxiliaryItemType__c, test.auxiList[i-1].AuxiliaryItemType__c, '付帯商品種別' + i + 'の確認');
            System.assertEquals(2000 + i, test.auxiList[i-1].AuxiliaryItemFee__c, '付帯商品料' + i + 'の金額確認');
        }
    }

    // 申込データ更新テスト５：入金日を登録後に付帯商品の登録を削除⇒付帯商品反響累計は再登録時のものとなる
    @isTest static void testUpdateApplication5() {
        TriggerTest test = new TriggerTest('登録', 'テスト顧客');
        Map<String, Item__c> itemMap = getItemMap();

        // 申込登録
        test.createNewApplication();
        test.testInsert();

        // 申込更新1
        for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            test.application.put(makeAuxName(i), itemMap.get('消毒1').id);
            test.application.put(makeAuxFeeName(i), 1000 + i);
        }
        test.application.PaymentDate__c = Date.today();
        test.testUpdate();

        // 申込更新2
        for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            test.application.put(makeAuxName(i), null);
            test.application.put(makeAuxFeeName(i), 0);
        }
        test.testUpdate();

        // 結果確認
        System.assertEquals(0, test.auxiList.size(), '付帯商品反響累計の登録件数');
    }

    // 申込データ更新テスト６：入金日を登録後に付帯商品の登録を削減⇒付帯商品反響累計は再登録時のものとなる
    @isTest static void testUpdateApplication6() {
        TriggerTest test = new TriggerTest('登録', 'テスト顧客');
        Map<String, Item__c> itemMap = getItemMap();

        // 申込登録
        test.createNewApplication();
        test.testInsert();

        // 申込更新1
        for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            test.application.put(makeAuxName(i), itemMap.get('消毒1').id);
            test.application.put(makeAuxFeeName(i), 1000 + i);
        }
        test.application.PaymentDate__c = Date.today();
        test.testUpdate();

        // 申込更新2
        for (Integer i = 1; i <= 5; i++) {
            test.application.put(makeAuxName(i), itemMap.get('消毒2').id);
            test.application.put(makeAuxFeeName(i), 2000 + i);
        }
        for (Integer i = 6; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
            test.application.put(makeAuxName(i), null);
            test.application.put(makeAuxFeeName(i), 0);
        }
        test.testUpdate();

        // 結果確認
        System.assertEquals(5, test.auxiList.size(), '付帯商品反響累計の登録件数');
        for (Integer i = 1; i <= 5; i++) {
            System.assertEquals(itemMap.get('消毒2').AuxiliaryItemType__c, test.auxiList[i-1].AuxiliaryItemType__c, '付帯商品種別' + i + 'の確認:' + test.auxiList[i-1].name);
            System.assertEquals(2000 + i, test.auxiList[i-1].AuxiliaryItemFee__c, '付帯商品料' + i + 'の金額確認:' + test.auxiList[i-1].name);
        }
    }


    ////// 内部クラス
    private class TriggerTest {
        Correspond__c   correspond  { get; set; }       // 対応
        EchoTotal__c    echoTotal   { get; set; }       // 反響累計
        Application__c  application { get; set; }       // 申込
        Account         acc         { get; set; }       // 取引先
        List<AuxiliaryItemEchoTotal__c> auxiList { get; set; }      // 付帯商品反響累計

        public TriggerTest(String correspondMemo, String accountName) {
            correspond = selectCorrespond(correspondMemo);
            echoTotal = selectEchoTotal(correspond.Id);
            application = selectApplication(correspond.Id);
            acc = [SELECT Id, Name, LastName__c, FirstName__c, RecordTypeId FROM Account WHERE Name = :accountName];
        }

        public void testInsert() {
            insert application;
            this.selectAll();
        }

        public void testUpdate() {
            update application;
            this.selectAll();
        }

        public void createNewApplication() {
            application = new Application__c(
                Corresponds__c = correspond.Id
              , Account__c = acc.Id
          );
        }

        private void selectAll() {
            echoTotal = selectEchoTotal(correspond.Id);
            if (echoTotal == null) {
                auxiList = null;
            } else {
                auxiList = selectAuxiliaryItemEchoTotal(echoTotal.id);
            }
        }
    }

    ///// 共通メソッド
    public static Correspond__c selectCorrespond(String correspondMemo) {
        List<Correspond__c> correspondList = [SELECT Id, Status__c, Memo__c FROM Correspond__c];
        for (Correspond__c d: correspondList) {
            if (correspondMemo.equals(d.Memo__c)) return d;
        }
        return null;
    }

    public static EchoTotal__c selectEchoTotal(Id correspondId) {
        List<EchoTotal__c> datas = [
            SELECT Id
            , Corresponds__c                    // 対応Id
            , ContractDate__c                   // 契約日
            , ReviewCount__c                    // 口コミ獲得数
            , BrokerageFirstFee__c              // 仲介手数料
            , ParkingBrokerageFirstFee__c       // 駐車場紹介料
            , ADFee__c                          // 広告宣伝費
            , AuxiliaryDepositPlanFee__c        // 付帯保証プラン料
            , AuxiliaryFireInsuranceFee__c      // 付帯火災保険料
            FROM EchoTotal__c
            WHERE Corresponds__c = :correspondId
        ];
        if (datas.size() == 0) {
            return null;
        } else {
            return datas[0];
        }
    }

    public static List<AuxiliaryItemEchoTotal__c> selectAuxiliaryItemEchoTotal(Id echoTotalId) {
        List<AuxiliaryItemEchoTotal__c> datas = [
            SELECT Id
            , Name                              // 付帯商品反響累計番号
            , AuxiliaryItemType__c              // 付帯商品種別
            , AuxiliaryItemFee__c               // 付帯商品料
            , EchoTotal__c                      // 反響累計
            FROM AuxiliaryItemEchoTotal__c
            WHERE EchoTotal__c = :echoTotalId
            ORDER BY NAME
        ];
        return datas;
    }

    public static Application__c selectApplication(Id correspondId) {
        List<Application__c> datas = [
            SELECT Id
            , Corresponds__c                    // 対応Id
            , Account__c                        // 取引先Id
            , PaymentDate__c                    // 入金日
            , IsReviewEntry__c                  // 口コミ記入
            , BrokerageFirstFee__c              // 仲介手数料
            , ParkingBrokerageFirstFee__c       // 駐車場紹介料
            , ADFee__c                          // 広告宣伝費
            , AuxiliaryDepositPlanFee__c        // 付帯保証プラン料
            , AuxiliaryFireInsuranceFee__c      // 付帯火災保険料
            , AuxiliaryItemFee1__c              // 付帯商品料１
            , AuxiliaryItemFee2__c              // 付帯商品料２
            , AuxiliaryItemFee3__c              // 付帯商品料３
            , AuxiliaryItemFee4__c              // 付帯商品料４
            , AuxiliaryItemFee5__c              // 付帯商品料５
            , AuxiliaryItemFee6__c              // 付帯商品料６
            , AuxiliaryItemFee7__c              // 付帯商品料７
            , AuxiliaryItemFee8__c              // 付帯商品料８
            , AuxiliaryItemFee9__c              // 付帯商品料９
            , AuxiliaryItemFee10__c             // 付帯商品料１０
            , AuxiliaryItem1__c                 // 付帯商品１
            , AuxiliaryItem2__c                 // 付帯商品２
            , AuxiliaryItem3__c                 // 付帯商品３
            , AuxiliaryItem4__c                 // 付帯商品４
            , AuxiliaryItem5__c                 // 付帯商品５
            , AuxiliaryItem6__c                 // 付帯商品６
            , AuxiliaryItem7__c                 // 付帯商品７
            , AuxiliaryItem8__c                 // 付帯商品８
            , AuxiliaryItem9__c                 // 付帯商品９
            , AuxiliaryItem10__c                // 付帯商品１０
            FROM Application__c
            WHERE Corresponds__c = :correspondId
        ];
        if (datas.size() == 0) {
            return null;
        } else {
            return datas[0];
        }
    }

    // 番号付きカラム名称の作成
    private static final Integer ETCETERA_AUXILIARY_ITEM_LIST_COUNT = 10;                       // 付帯商品項目のリスト数
    private static final String COLUMN_NAME_AUXILIARY_ITEM_FEE = 'AuxiliaryItemFee{num}__c';    // 付帯商品項目の項目名
    private static final String COLUMN_NAME_AUXILIARY_ITEM      = 'AuxiliaryItem{num}__c';      // 付帯商品の項目名
    private static String makeNumberColumnName(String columnName, Integer num) {
        return columnName.replaceAll('\\{num\\}', String.valueOf(num));
    }
    public static String makeAuxFeeName(Integer num) {
        return makeNumberColumnName(COLUMN_NAME_AUXILIARY_ITEM_FEE, num);
    }
    public static String makeAuxName(Integer num) {
        return makeNumberColumnName(COLUMN_NAME_AUXILIARY_ITEM, num);
    }

    public static Map<String, Item__c> getItemMap() {
        List<Item__c> itemList = [
            SELECT Account__c
            , ItemName__c
            , RecordTypeId
            , auxiliaryItemFeeTaxType__c
            , AuxiliaryItemType__c
            , RentFeeRate__c
            , DirectDebitFee__c
            , IsAuxiliary__c
            FROM Item__c
        ];
        Map<String, Item__c> itemMap = new Map<String, Item__c>();
        for (Item__c item: itemList) {
            itemMap.put(item.ItemName__c, item);
        }
        return itemMap;
    }
}