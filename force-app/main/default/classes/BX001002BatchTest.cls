// RS移行(仮見積)　テストクラス
@isTest 
private class BX001002BatchTest {

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
        final String TEST_NUMBER = 'PROV-T001';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // データ登録
        Insert new ProvisionalQuote__c(
              RemarksRenewalFee__c              = TEST_NUMBER                       // 取引先_姓（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
        );

        // 更新前データを保存
        ProvisionalQuote__c before = readProvisionalQuote(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001002Batch b = new BX001002Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        ProvisionalQuote__c after = readProvisionalQuote(TEST_NUMBER);

        // チェック
        system.assertEquals(after.SystemModstamp, before.SystemModstamp, TEST_NUMBER + ':更新日付が変わっていないこと');
    }

    // ケース002.消毒1のみ
    @isTest static void testBatch002() {
        final String TEST_NUMBER = 'PROV-T002';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // データ登録
        Insert new ProvisionalQuote__c(
              RemarksRenewalFee__c              = TEST_NUMBER                       // 備考（更新料）（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , DisinfectionItem__c               = itemMap.get('消毒1').Id           // 室内消毒商品
            , IndoorDisinfectionItemFee__c      = 2001                              // 室内消毒料金
        );

        // 更新前データを保存
        ProvisionalQuote__c before = readProvisionalQuote(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001002Batch b = new BX001002Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        ProvisionalQuote__c after = readProvisionalQuote(TEST_NUMBER);

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
        final String TEST_NUMBER = 'PROV-T003';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // データ登録
        Insert new ProvisionalQuote__c(
              RemarksRenewalFee__c              = TEST_NUMBER                       // 備考（更新料）（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , KeyExchangeFeeItem__c             = itemMap.get('鍵交換1').Id         // 鍵交換費商品
            , AuxiliaryKeyExchangeFee__c        = 2002                              // カギ交換料金
        );

        // 更新前データを保存
        ProvisionalQuote__c before = readProvisionalQuote(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001002Batch b = new BX001002Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        ProvisionalQuote__c after = readProvisionalQuote(TEST_NUMBER);

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
        final String TEST_NUMBER = 'PROV-T004';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // データ登録
        Insert new ProvisionalQuote__c(
              RemarksRenewalFee__c              = TEST_NUMBER                       // 備考（更新料）（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , ReliableSupportItem__c            = itemMap.get('安心サポート1').Id   // 安心サポート商品
            , ReliableSupportItemFee__c         = 2003                              // 安心サポート料金
        );

        // 更新前データを保存
        ProvisionalQuote__c before = readProvisionalQuote(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001002Batch b = new BX001002Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        ProvisionalQuote__c after = readProvisionalQuote(TEST_NUMBER);

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
        final String TEST_NUMBER = 'PROV-T005';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // データ登録
        Insert new ProvisionalQuote__c(
              RemarksRenewalFee__c              = TEST_NUMBER                       // 備考（更新料）（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , FShotItem__c                      = itemMap.get('Fショット1').Id      // Fショット商品
            , FShotItemFee__c                   = 2004                              // Fショット料金
        );

        // 更新前データを保存
        ProvisionalQuote__c before = readProvisionalQuote(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001002Batch b = new BX001002Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        ProvisionalQuote__c after = readProvisionalQuote(TEST_NUMBER);

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
        final String TEST_NUMBER = 'PROV-T006';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // データ登録
        Insert new ProvisionalQuote__c(
              RemarksRenewalFee__c              = TEST_NUMBER                       // 備考（更新料）（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , AlsokLockItem__c                  = itemMap.get('アルソック1').Id     // アルソックロック商品	
            , AlsokLockItemFee__c               = 2005                              // アルソックロック料金	
        );

        // 更新前データを保存
        ProvisionalQuote__c before = readProvisionalQuote(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001002Batch b = new BX001002Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        ProvisionalQuote__c after = readProvisionalQuote(TEST_NUMBER);

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
        final String TEST_NUMBER = 'PROV-T007';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // データ登録
        Insert new ProvisionalQuote__c(
              RemarksRenewalFee__c              = TEST_NUMBER                       // 備考（更新料）（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , DisinfectionItem__c               = itemMap.get('消毒1').Id           // 室内消毒商品
            , IndoorDisinfectionItemFee__c      = 2001                              // 室内消毒料金
            , KeyExchangeFeeItem__c             = itemMap.get('鍵交換1').Id         // 鍵交換費商品
            , AuxiliaryKeyExchangeFee__c        = 2002                              // カギ交換料金
            , ReliableSupportItem__c            = itemMap.get('安心サポート1').Id   // 安心サポート商品
            , ReliableSupportItemFee__c         = 2003                              // 安心サポート料金
            , FShotItem__c                      = itemMap.get('Fショット1').Id      // Fショット商品
            , FShotItemFee__c                   = 2004                              // Fショット料金
            , AlsokLockItem__c                  = itemMap.get('アルソック1').Id     // アルソックロック商品	
            , AlsokLockItemFee__c               = 2005                              // アルソックロック料金	
        );

        // 更新前データを保存
        ProvisionalQuote__c before = readProvisionalQuote(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001002Batch b = new BX001002Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        ProvisionalQuote__c after = readProvisionalQuote(TEST_NUMBER);

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
        final String TEST_NUMBER = 'PROV-T008';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // データ登録
        Insert new ProvisionalQuote__c(
              RemarksRenewalFee__c              = TEST_NUMBER                       // 備考（更新料）（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , DisinfectionItem__c               = itemMap.get('消毒2').Id           // 室内消毒商品
            , IndoorDisinfectionItemFee__c      = 3001                              // 室内消毒料金
            , AlsokLockItem__c                  = itemMap.get('アルソック1').Id     // アルソックロック商品	
            , AlsokLockItemFee__c               = 2005                              // アルソックロック料金	
        );

        // 更新前データを保存
        ProvisionalQuote__c before = readProvisionalQuote(TEST_NUMBER);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001002Batch b = new BX001002Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        ProvisionalQuote__c after = readProvisionalQuote(TEST_NUMBER);

        // チェック
        system.assertNotEquals(before.SystemModstamp, after.SystemModstamp, TEST_NUMBER + ':更新日付が変わっていること');
        List<Id> expectedId = new List<Id> {itemMap.get('消毒2').Id, itemMap.get('アルソック1').Id, null, null, null, null, null, null, null, null };
        List<Decimal> expectedFee = new List<Decimal> {3001, 2005, null, null, null, null, null, null, null, null };
        for (Integer i = 1; i <= 10; i++) {
            system.assertEquals(expectedId[i-1], after.get('AuxiliaryItem' + i + '__c'), TEST_NUMBER + ':AuxiliaryItem' + i + '__c');
            system.assertEquals(expectedFee[i-1], after.get('AuxiliaryItemFee' + i + '__c'), TEST_NUMBER + ':AuxiliaryItemFee' + i + '__c');
        }
    }

    // ケース009.データ登録なし
    @isTest static void testBatch009() {
        final String TEST_NUMBER = 'PROV-T009';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001002Batch b = new BX001002Batch();
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
        final String TEST_NUMBER1 = 'PROV-T010-1';
        final String TEST_NUMBER2 = 'PROV-T010-2';
        Map<String, Account> acntMap = getAcntMap();
        Map<String, Item__c> itemMap = getItemMap();

        // データ登録
        Insert new ProvisionalQuote__c(
              RemarksRenewalFee__c              = TEST_NUMBER1                      // 備考（更新料）（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , DisinfectionItem__c               = itemMap.get('消毒2').Id           // 室内消毒商品
            , IndoorDisinfectionItemFee__c      = 3001                              // 室内消毒料金
        );
        Insert new ProvisionalQuote__c(
              RemarksRenewalFee__c              = TEST_NUMBER2                      // 備考（更新料）（テスト用番号）
            , Account__c                        = acntMap.get('ACNT-T001').Id       // 取引先（顧客）
            , AlsokLockItem__c                  = itemMap.get('アルソック1').Id     // アルソックロック商品	
            , AlsokLockItemFee__c               = 2005                              // アルソックロック料金	
        );

        // 更新前データを保存
        ProvisionalQuote__c before1 = readProvisionalQuote(TEST_NUMBER1);
        ProvisionalQuote__c before2 = readProvisionalQuote(TEST_NUMBER2);

        // バッチ実行
        CommonUtil.sleep(1000);
        BX001002Batch b = new BX001002Batch();
        Test.startTest();
        system.debug(Database.executeBatch(b, BATCH_SIZE));
        Test.stopTest();

        // 更新後データの取得
        ProvisionalQuote__c after1 = readProvisionalQuote(TEST_NUMBER1);
        ProvisionalQuote__c after2 = readProvisionalQuote(TEST_NUMBER2);

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
    private static ProvisionalQuote__c readProvisionalQuote(String lastName) {
        return [
            SELECT Id
            , SystemModstamp
            , RemarksRenewalFee__c
            , Account__c
            , DisinfectionItem__c
            , IndoorDisinfectionItemFee__c
            , KeyExchangeFeeItem__c
            , AuxiliaryKeyExchangeFee__c
            , ReliableSupportItem__c
            , ReliableSupportItemFee__c
            , FShotItem__c
            , FShotItemFee__c
            , AlsokLockItem__c
            , AlsokLockItemFee__c
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
            FROM ProvisionalQuote__c
            WHERE RemarksRenewalFee__c = :lastName
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