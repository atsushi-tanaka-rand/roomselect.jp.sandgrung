// RS移行(申込)　テストクラス
@isTest 
private class BX001001BatchTest {

    // バッチサイズ
    private final static Integer BATCH_SIZE = 200;

    @testSetup static void Setting() {

        // --------------------------------------------------
        // 取引先
        // --------------------------------------------------
        Account acnt = new Account(NAME = 'ACNT-T001');
        Insert acnt;

        // --------------------------------------------------
        // 付帯商品
        // --------------------------------------------------
        List<Item__c> itemList = new List<Item__c>();
        final Id recTypeAuxi = commonUtil.getRecordTypeId('Item__c','AuxiliaryItemRecordType');
        itemList.add(new Item__c(ItemName__c = '消毒1',         AuxiliaryItemFee__c = 1001, AuxiliaryItemType__c = CommonConst.AUXILIARY_ITEM_TYPE_DISINFECTION,     Account__c = acnt.id, RecordTypeId = recTypeAuxi, IsAuxiliary__c = true));
        itemList.add(new Item__c(ItemName__c = '消毒2',         AuxiliaryItemFee__c = 1002, AuxiliaryItemType__c = CommonConst.AUXILIARY_ITEM_TYPE_DISINFECTION,     Account__c = acnt.id, RecordTypeId = recTypeAuxi, IsAuxiliary__c = true));
        itemList.add(new Item__c(ItemName__c = '鍵交換1',       AuxiliaryItemFee__c = 1003, AuxiliaryItemType__c = CommonConst.AUXILIARY_ITEM_TYPE_KEYEXCHANGE,      Account__c = acnt.id, RecordTypeId = recTypeAuxi, IsAuxiliary__c = true));
        itemList.add(new Item__c(ItemName__c = '安心サポート1', AuxiliaryItemFee__c = 1004, AuxiliaryItemType__c = CommonConst.AUXILIARY_ITEM_TYPE_RELIABLESUPPORT,  Account__c = acnt.id, RecordTypeId = recTypeAuxi, IsAuxiliary__c = true));
        itemList.add(new Item__c(ItemName__c = 'Fショット1',    AuxiliaryItemFee__c = 1005, AuxiliaryItemType__c = CommonConst.AUXILIARY_ITEM_TYPE_FSHOT,            Account__c = acnt.id, RecordTypeId = recTypeAuxi, IsAuxiliary__c = true));
        itemList.add(new Item__c(ItemName__c = 'アルソック1',   AuxiliaryItemFee__c = 1006, AuxiliaryItemType__c = CommonConst.AUXILIARY_ITEM_TYPE_ALSOKLOCK,        Account__c = acnt.id, RecordTypeId = recTypeAuxi, IsAuxiliary__c = true));
        Insert itemList;
    }

    // ケース001.付帯商品登録なし
    @isTest static void testBatch001() {
        final String TEST_NUMBER = 'APLI-T001';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // 申込データ登録
        Insert new Application__c(
              LastName__c                       = TEST_NUMBER                       // 取引先_姓（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
        );

        // 更新前データを保存
        Application__c before = readApplication(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001001Batch b = new BX001001Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        Application__c after = readApplication(TEST_NUMBER);

        // チェック
        system.assertEquals(after.SystemModstamp, before.SystemModstamp, TEST_NUMBER + ':更新日付が変わっていないこと');
    }

    // ケース002.消毒1のみ
    @isTest static void testBatch002() {
        final String TEST_NUMBER = 'APLI-T002';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // 申込データ登録
        Insert new Application__c(
              LastName__c                       = TEST_NUMBER                       // 取引先_姓（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , AuxiliaryDisinfection__c          = itemMap.get('消毒1').Id           // 付帯室内消毒
            , AuxiliaryIndoorDisinfectionFee__c = 2001                              // 付帯室内消毒料
        );

        // 更新前データを保存
        Application__c before = readApplication(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001001Batch b = new BX001001Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        Application__c after = readApplication(TEST_NUMBER);

        // チェック
        system.assertNotEquals(before.SystemModstamp, after.SystemModstamp, TEST_NUMBER + ':更新日付が変わっていること');
        List<Id> expectedId = new List<Id> {itemMap.get('消毒1').Id, null, null, null, null, null, null, null, null, null };
        List<Decimal> expectedFee = new List<Decimal> {2001, null, null, null, null, null, null, null, null, null };
        for (Integer i = 1; i <= 10; i++) {
            system.assertEquals(expectedId[i-1], after.get('AuxiliaryItem' + i + '__c'), TEST_NUMBER + ':AuxiliaryItem' + i + '__c');
            system.assertEquals(expectedFee[i-1], after.get('AuxiliaryItemFee' + i + '__c'), TEST_NUMBER + ':AuxiliaryItemFee' + i + '__c');
        }
    }

    // ケース003.鍵交換1のみ
    @isTest static void testBatch003() {
        final String TEST_NUMBER = 'APLI-T003';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // 申込データ登録
        Insert new Application__c(
              LastName__c                       = TEST_NUMBER                       // 取引先_姓（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , AuxiliaryKeyExchange__c           = itemMap.get('鍵交換1').Id         // 付帯鍵交換
            , AuxiliaryKeyExchangeFee__c        = 2002                              // 付帯鍵交換費
        );

        // 更新前データを保存
        Application__c before = readApplication(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001001Batch b = new BX001001Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        Application__c after = readApplication(TEST_NUMBER);

        // チェック
        system.assertNotEquals(before.SystemModstamp, after.SystemModstamp, TEST_NUMBER + ':更新日付が変わっていること');
        List<Id> expectedId = new List<Id> {itemMap.get('鍵交換1').Id, null, null, null, null, null, null, null, null, null };
        List<Decimal> expectedFee = new List<Decimal> {2002, null, null, null, null, null, null, null, null, null };
        for (Integer i = 1; i <= 10; i++) {
            system.assertEquals(expectedId[i-1], after.get('AuxiliaryItem' + i + '__c'), TEST_NUMBER + ':AuxiliaryItem' + i + '__c');
            system.assertEquals(expectedFee[i-1], after.get('AuxiliaryItemFee' + i + '__c'), TEST_NUMBER + ':AuxiliaryItemFee' + i + '__c');
        }
    }

    // ケース004.安心サポート1のみ
    @isTest static void testBatch004() {
        final String TEST_NUMBER = 'APLI-T004';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // 申込データ登録
        Insert new Application__c(
              LastName__c                       = TEST_NUMBER                               // 取引先_姓（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id               // 取引先（顧客）
            , AuxiliaryReliableSupport__c       = itemMap.get('安心サポート1').Id           // 付帯安心サポート
            , AuxiliaryReliableSupportFee__c    = 2003                                      // 付帯安心サポート料
        );

        // 更新前データを保存
        Application__c before = readApplication(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001001Batch b = new BX001001Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        Application__c after = readApplication(TEST_NUMBER);

        // チェック
        system.assertNotEquals(before.SystemModstamp, after.SystemModstamp, TEST_NUMBER + ':更新日付が変わっていること');
        List<Id> expectedId = new List<Id> {itemMap.get('安心サポート1').Id, null, null, null, null, null, null, null, null, null };
        List<Decimal> expectedFee = new List<Decimal> {2003, null, null, null, null, null, null, null, null, null };
        for (Integer i = 1; i <= 10; i++) {
            system.assertEquals(expectedId[i-1], after.get('AuxiliaryItem' + i + '__c'), TEST_NUMBER + ':AuxiliaryItem' + i + '__c');
            system.assertEquals(expectedFee[i-1], after.get('AuxiliaryItemFee' + i + '__c'), TEST_NUMBER + ':AuxiliaryItemFee' + i + '__c');
        }
    }

    // ケース005.Fショット1のみ
    @isTest static void testBatch005() {
        final String TEST_NUMBER = 'APLI-T005';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // 申込データ登録
        Insert new Application__c(
              LastName__c                       = TEST_NUMBER                       // 取引先_姓（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , AuxiliaryFShot__c                 = itemMap.get('Fショット1').Id      // 付帯Fショット
            , AuxiliaryFShotFee__c              = 2004                              // 付帯Fショット料
        );

        // 更新前データを保存
        Application__c before = readApplication(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001001Batch b = new BX001001Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        Application__c after = readApplication(TEST_NUMBER);

        // チェック
        system.assertNotEquals(before.SystemModstamp, after.SystemModstamp, TEST_NUMBER + ':更新日付が変わっていること');
        List<Id> expectedId = new List<Id> {itemMap.get('Fショット1').Id, null, null, null, null, null, null, null, null, null };
        List<Decimal> expectedFee = new List<Decimal> {2004, null, null, null, null, null, null, null, null, null };
        for (Integer i = 1; i <= 10; i++) {
            system.assertEquals(expectedId[i-1], after.get('AuxiliaryItem' + i + '__c'), TEST_NUMBER + ':AuxiliaryItem' + i + '__c');
            system.assertEquals(expectedFee[i-1], after.get('AuxiliaryItemFee' + i + '__c'), TEST_NUMBER + ':AuxiliaryItemFee' + i + '__c');
        }
    }

    // ケース006.アルソック1のみ
    @isTest static void testBatch006() {
        final String TEST_NUMBER = 'APLI-T006';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // 申込データ登録
        Insert new Application__c(
              LastName__c                       = TEST_NUMBER                       // 取引先_姓（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , AuxiliaryAlsokLock__c             = itemMap.get('アルソック1').Id     // 付帯アルソックロック
            , AuxiliaryAlsokLockFee__c          = 2005                              // 付帯アルソックロック料
        );

        // 更新前データを保存
        Application__c before = readApplication(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001001Batch b = new BX001001Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        Application__c after = readApplication(TEST_NUMBER);

        // チェック
        system.assertNotEquals(before.SystemModstamp, after.SystemModstamp, TEST_NUMBER + ':更新日付が変わっていること');
        List<Id> expectedId = new List<Id> {itemMap.get('アルソック1').Id, null, null, null, null, null, null, null, null, null };
        List<Decimal> expectedFee = new List<Decimal> {2005, null, null, null, null, null, null, null, null, null };
        for (Integer i = 1; i <= 10; i++) {
            system.assertEquals(expectedId[i-1], after.get('AuxiliaryItem' + i + '__c'), TEST_NUMBER + ':AuxiliaryItem' + i + '__c');
            system.assertEquals(expectedFee[i-1], after.get('AuxiliaryItemFee' + i + '__c'), TEST_NUMBER + ':AuxiliaryItemFee' + i + '__c');
        }
    }

    // ケース007.すべて登録
    @isTest static void testBatch007() {
        final String TEST_NUMBER = 'APLI-T007';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // 申込データ登録
        Insert new Application__c(
              LastName__c                       = TEST_NUMBER                       // 取引先_姓（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , AuxiliaryDisinfection__c          = itemMap.get('消毒1').Id           // 付帯室内消毒
            , AuxiliaryIndoorDisinfectionFee__c = 2001                              // 付帯室内消毒料
            , AuxiliaryKeyExchange__c           = itemMap.get('鍵交換1').Id         // 付帯鍵交換
            , AuxiliaryKeyExchangeFee__c        = 2002                              // 付帯鍵交換費
            , AuxiliaryReliableSupport__c       = itemMap.get('安心サポート1').Id   // 付帯安心サポート
            , AuxiliaryReliableSupportFee__c    = 2003                              // 付帯安心サポート料
            , AuxiliaryFShot__c                 = itemMap.get('Fショット1').Id      // 付帯Fショット
            , AuxiliaryFShotFee__c              = 2004                              // 付帯Fショット料
            , AuxiliaryAlsokLock__c             = itemMap.get('アルソック1').Id     // 付帯アルソックロック
            , AuxiliaryAlsokLockFee__c          = 2005                              // 付帯アルソックロック料
        );

        // 更新前データを保存
        Application__c before = readApplication(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001001Batch b = new BX001001Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        Application__c after = readApplication(TEST_NUMBER);

        // チェック
        system.assertNotEquals(before.SystemModstamp, after.SystemModstamp, TEST_NUMBER + ':更新日付が変わっていること');
        List<Id> expectedId = new List<Id> {itemMap.get('消毒1').Id, itemMap.get('鍵交換1').Id, itemMap.get('安心サポート1').Id, itemMap.get('Fショット1').Id, itemMap.get('アルソック1').Id, null, null, null, null, null };
        List<Decimal> expectedFee = new List<Decimal> {2001, 2002, 2003, 2004, 2005, null, null, null, null, null };
        for (Integer i = 1; i <= 10; i++) {
            system.assertEquals(expectedId[i-1], after.get('AuxiliaryItem' + i + '__c'), TEST_NUMBER + ':AuxiliaryItem' + i + '__c');
            system.assertEquals(expectedFee[i-1], after.get('AuxiliaryItemFee' + i + '__c'), TEST_NUMBER + ':AuxiliaryItemFee' + i + '__c');
        }
    }

    // ケース008.消毒2とアルソック1の２つ
    @isTest static void testBatch008() {
        final String TEST_NUMBER = 'APLI-T008';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // 申込データ登録
        Insert new Application__c(
              LastName__c                       = TEST_NUMBER                       // 取引先_姓（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , AuxiliaryDisinfection__c          = itemMap.get('消毒2').Id           // 付帯室内消毒
            , AuxiliaryIndoorDisinfectionFee__c = 3001                              // 付帯室内消毒料
            , AuxiliaryAlsokLock__c             = itemMap.get('アルソック1').Id     // 付帯アルソックロック
            , AuxiliaryAlsokLockFee__c          = 2005                              // 付帯アルソックロック料
        );

        // 更新前データを保存
        Application__c before = readApplication(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001001Batch b = new BX001001Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        Application__c after = readApplication(TEST_NUMBER);

        // チェック
        system.assertNotEquals(before.SystemModstamp, after.SystemModstamp, TEST_NUMBER + ':更新日付が変わっていること');
        List<Id> expectedId = new List<Id> {itemMap.get('消毒2').Id, itemMap.get('アルソック1').Id, null, null, null, null, null, null, null, null };
        List<Decimal> expectedFee = new List<Decimal> {3001, 2005, null, null, null, null, null, null, null, null };
        for (Integer i = 1; i <= 10; i++) {
            system.assertEquals(expectedId[i-1], after.get('AuxiliaryItem' + i + '__c'), TEST_NUMBER + ':AuxiliaryItem' + i + '__c');
            system.assertEquals(expectedFee[i-1], after.get('AuxiliaryItemFee' + i + '__c'), TEST_NUMBER + ':AuxiliaryItemFee' + i + '__c');
        }
    }

    // ケース009.申込データ登録なし
    @isTest static void testBatch009() {
        final String TEST_NUMBER = 'APLI-T009';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001001Batch b = new BX001001Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        List<Application__c> after = [SELECT ID FROM Application__c];

        // チェック
        system.assertEquals(0, after.size(), TEST_NUMBER + ':データ件数０件（バッチの正常終了）');
    }

    // ケース010.２件のデータ（消毒2とアルソック1）
    @isTest static void testBatch010() {
        final String TEST_NUMBER1 = 'APLI-T010-1';
        final String TEST_NUMBER2 = 'APLI-T010-2';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // 申込データ登録
        Insert new Application__c(
              LastName__c                       = TEST_NUMBER1                      // 取引先_姓（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , AuxiliaryDisinfection__c          = itemMap.get('消毒2').Id           // 付帯室内消毒
            , AuxiliaryIndoorDisinfectionFee__c = 3001                              // 付帯室内消毒料
        );
        Insert new Application__c(
              LastName__c                       = TEST_NUMBER2                      // 取引先_姓（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , AuxiliaryAlsokLock__c             = itemMap.get('アルソック1').Id     // 付帯アルソックロック
            , AuxiliaryAlsokLockFee__c          = 2005                              // 付帯アルソックロック料
        );

        // 更新前データを保存
        Application__c before1 = readApplication(TEST_NUMBER1);
        Application__c before2 = readApplication(TEST_NUMBER2);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001001Batch b = new BX001001Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        Application__c after1 = readApplication(TEST_NUMBER1);
        Application__c after2 = readApplication(TEST_NUMBER2);

        // チェック
        system.assertNotEquals(before1.SystemModstamp, after1.SystemModstamp, TEST_NUMBER1 + ':更新日付が変わっていること');
        system.assertNotEquals(before2.SystemModstamp, after2.SystemModstamp, TEST_NUMBER2 + ':更新日付が変わっていること');
        List<Id> expectedId1 = new List<Id> {itemMap.get('消毒2').Id, null, null, null, null, null, null, null, null, null };
        List<Decimal> expectedFee1 = new List<Decimal> {3001, null, null, null, null, null, null, null, null, null };
        List<Id> expectedId2 = new List<Id> {itemMap.get('アルソック1').Id, null, null, null, null, null, null, null, null, null };
        List<Decimal> expectedFee2 = new List<Decimal> {2005, null, null, null, null, null, null, null, null, null };
        for (Integer i = 1; i <= 10; i++) {
            system.assertEquals(expectedId1[i-1],  after1.get('AuxiliaryItem' + i + '__c'),    TEST_NUMBER1 + ':AuxiliaryItem' + i + '__c');
            system.assertEquals(expectedFee1[i-1], after1.get('AuxiliaryItemFee' + i + '__c'), TEST_NUMBER1 + ':AuxiliaryItemFee' + i + '__c');
            system.assertEquals(expectedId2[i-1],  after2.get('AuxiliaryItem' + i + '__c'),    TEST_NUMBER2 + ':AuxiliaryItem' + i + '__c');
            system.assertEquals(expectedFee2[i-1], after2.get('AuxiliaryItemFee' + i + '__c'), TEST_NUMBER2 + ':AuxiliaryItemFee' + i + '__c');
        }
    }

    //--------------------------------------privateメソッド----------------------------------------------------------------------------
    private static Application__c readApplication(String lastName) {
        return [
            SELECT Id
            , SystemModstamp
            , LastName__c
            , Account__c
            , AuxiliaryDisinfection__c
            , AuxiliaryIndoorDisinfectionFee__c
            , AuxiliaryKeyExchange__c
            , AuxiliaryKeyExchangeFee__c
            , AuxiliaryReliableSupport__c
            , AuxiliaryReliableSupportFee__c
            , AuxiliaryFShot__c
            , AuxiliaryFShotFee__c
            , AuxiliaryAlsokLock__c
            , AuxiliaryAlsokLockFee__c
            , AuxiliaryItem1__c
            , AuxiliaryItemFee1__c
            , AuxiliaryItem2__c
            , AuxiliaryItemFee2__c
            , AuxiliaryItem3__c
            , AuxiliaryItemFee3__c
            , AuxiliaryItem4__c
            , AuxiliaryItemFee4__c
            , AuxiliaryItem5__c
            , AuxiliaryItemFee5__c
            , AuxiliaryItem6__c
            , AuxiliaryItemFee6__c
            , AuxiliaryItem7__c
            , AuxiliaryItemFee7__c
            , AuxiliaryItem8__c
            , AuxiliaryItemFee8__c
            , AuxiliaryItem9__c
            , AuxiliaryItemFee9__c
            , AuxiliaryItem10__c
            , AuxiliaryItemFee10__c
            FROM Application__c
            WHERE LastName__c = :lastName
        ];
    }

    // 取引先マップの取得
    private static Map<String, Account> getAcntMap() {
        List<Account> acntList = [SELECT Id, Name FROM Account];
        Map<String, Account> acntMap = new Map<String, Account>();
        for (Account acnt: acntList) {
            acntMap.put(acnt.Name, acnt);
        }
        return acntMap;
    }

    // 付帯商品マップの取得
    private static Map<String, Item__c> getItemMap() {
        List<Item__c> itemList = [SELECT Id, ItemName__c FROM Item__c];
        Map<String, Item__c> itemMap = new Map<String, Item__c>();
        for (Item__c item: itemList) {
            itemMap.put(item.ItemName__c, item);
        }        
        return itemMap;
    }
}