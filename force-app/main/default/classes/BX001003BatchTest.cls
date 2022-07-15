// RS移行(反響累計)　テストクラス
@isTest 
private class BX001003BatchTest {

    // バッチサイズ
    private final static Integer BATCH_SIZE = 200;

    @testSetup static void Setting() {
        // --------------------------------------------------
        // 対応
        // --------------------------------------------------
        List<Correspond__c> corrList = new List<Correspond__c>();
        corrList.add(new Correspond__c(EventId__c = 'CORR-T001', Status__c = '未収入金'));
        corrList.add(new Correspond__c(EventId__c = 'CORR-T002', Status__c = '未収入金'));
        Insert corrList;
    }

    // ケース001.付帯商品登録なし
    @isTest static void testBatch001() {
        // データ登録
        BatchTest test = new BatchTest('CORR-T001');
        test.upsertEchoTotal();

        // バッチ実行
        test.batchExecute();

        // チェック
        system.assertEquals(0, test.auxiList.size(), '付帯商品反響累計の登録件数チェック');
    }

    // ケース002.消毒のみ
    @isTest static void testBatch002() {
        // データ登録
        BatchTest test = new BatchTest('CORR-T001');
        test.echoTotal.AuxiliaryIndoorDisinfectionFee__c = 1001;        // 付帯室内消毒料
        test.upsertEchoTotal();

        // バッチ実行
        test.batchExecute();

        // チェック
        Integer i = 0;
        system.assertEquals(1, test.auxiList.size(), '付帯商品反響累計の登録件数チェック');
        system.assertEquals(test.echoTotal.Id   , test.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('消毒'              , test.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1001                , test.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
    }

    // ケース003.鍵交換のみ
    @isTest static void testBatch003() {
        // データ登録
        BatchTest test = new BatchTest('CORR-T001');
        test.echoTotal.AuxiliaryKeyExchangeFee__c = 1002;               // 付帯鍵交換費
        test.upsertEchoTotal();

        // バッチ実行
        test.batchExecute();

        // チェック
        Integer i = 0;
        system.assertEquals(1, test.auxiList.size(), '付帯商品反響累計の登録件数チェック');
        system.assertEquals(test.echoTotal.Id   , test.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('鍵交換'            , test.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1002                , test.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
    }

    // ケース004.安心サポートのみ
    @isTest static void testBatch004() {
        // データ登録
        BatchTest test = new BatchTest('CORR-T001');
        test.echoTotal.AuxiliaryReliableSupportFee__c       = 1003;     // 付帯安心サポート料
        test.upsertEchoTotal();

        // バッチ実行
        test.batchExecute();

        // チェック
        Integer i = 0;
        system.assertEquals(1, test.auxiList.size(), '付帯商品反響累計の登録件数チェック');
        system.assertEquals(test.echoTotal.Id   , test.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('安心サポート'      , test.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1003                , test.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
    }

    // ケース005.Fショットのみ
    @isTest static void testBatch005() {
        // データ登録
        BatchTest test = new BatchTest('CORR-T001');
        test.echoTotal.AuxiliaryFShotFee__c                 = 1004;     // 付帯Fショット料
        test.upsertEchoTotal();

        // バッチ実行
        test.batchExecute();

        // チェック
        Integer i = 0;
        system.assertEquals(1, test.auxiList.size(), '付帯商品反響累計の登録件数チェック');
        system.assertEquals(test.echoTotal.Id   , test.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('Fショット'         , test.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1004                , test.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
    }

    // ケース006.アルソックのみ
    @isTest static void testBatch006() {
        // データ登録
        BatchTest test = new BatchTest('CORR-T001');
        test.echoTotal.AuxiliaryAlsokLockFee__c             = 1005;     // 付帯アルソックロック料
        test.upsertEchoTotal();

        // バッチ実行
        test.batchExecute();

        // チェック
        Integer i = 0;
        system.assertEquals(1, test.auxiList.size(), '付帯商品反響累計の登録件数チェック');
        system.assertEquals(test.echoTotal.Id   , test.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('アルソック'        , test.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1005                , test.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
    }

    // ケース007.すべて登録
    @isTest static void testBatch007() {
        // データ登録
        BatchTest test = new BatchTest('CORR-T001');
        test.echoTotal.AuxiliaryIndoorDisinfectionFee__c    = 1001;     // 付帯室内消毒料
        test.echoTotal.AuxiliaryKeyExchangeFee__c           = 1002;     // 付帯鍵交換費
        test.echoTotal.AuxiliaryReliableSupportFee__c       = 1003;     // 付帯安心サポート料
        test.echoTotal.AuxiliaryFShotFee__c                 = 1004;     // 付帯Fショット料
        test.echoTotal.AuxiliaryAlsokLockFee__c             = 1005;     // 付帯アルソックロック料
        test.upsertEchoTotal();

        // バッチ実行
        test.batchExecute();

        // チェック
        Integer i = 0;
        system.assertEquals(5, test.auxiList.size(), '付帯商品反響累計の登録件数チェック');
        system.assertEquals(test.echoTotal.Id   , test.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('消毒'              , test.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1001                , test.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
        i++;
        system.assertEquals(test.echoTotal.Id   , test.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('鍵交換'            , test.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1002                , test.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
        i++;
        system.assertEquals(test.echoTotal.Id   , test.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('安心サポート'      , test.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1003                , test.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
        i++;
        system.assertEquals(test.echoTotal.Id   , test.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('Fショット'         , test.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1004                , test.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
        i++;
        system.assertEquals(test.echoTotal.Id   , test.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('アルソック'        , test.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1005                , test.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
    }

    // ケース008.消毒とアルソック1の２つ
    @isTest static void testBatch008() {
        // データ登録
        BatchTest test = new BatchTest('CORR-T001');
        test.echoTotal.AuxiliaryIndoorDisinfectionFee__c    = 1001;     // 付帯室内消毒料
        test.echoTotal.AuxiliaryAlsokLockFee__c             = 1005;     // 付帯アルソックロック料
        test.upsertEchoTotal();

        // バッチ実行
        test.batchExecute();

        // チェック
        Integer i = 0;
        system.assertEquals(2, test.auxiList.size(), '付帯商品反響累計の登録件数チェック');
        system.assertEquals(test.echoTotal.Id   , test.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('消毒'              , test.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1001                , test.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
        i++;
        system.assertEquals(test.echoTotal.Id   , test.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('アルソック'        , test.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1005                , test.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
    }

    // ケース009.データ登録なし
    @isTest static void testBatch009() {
        // データ登録
        BatchTest test = new BatchTest('CORR-T001');

        // バッチ実行
        test.batchExecute();

        // 更新後データの取得
        List<EchoTotal__c> after = [SELECT ID FROM EchoTotal__c];

        // チェック
        system.assertEquals(0, after.size(), 'データ件数０件（バッチの正常終了）');
    }

    // ケース010.２件のデータ（消毒とアルソック1）
    @isTest static void testBatch010() {
        // データ登録
        BatchTest test1 = new BatchTest('CORR-T001');
        test1.echoTotal.AuxiliaryIndoorDisinfectionFee__c    = 1001;     // 付帯室内消毒料
        test1.upsertEchoTotal();
        BatchTest test2 = new BatchTest('CORR-T002');
        test2.echoTotal.AuxiliaryAlsokLockFee__c             = 1005;     // 付帯アルソックロック料
        test2.upsertEchoTotal();

        // バッチ実行
        test1.batchExecute();
        test2.updateAuxiList();

        // チェック
        Integer i = 0;
        system.assertEquals(1, test1.auxiList.size(), '付帯商品反響累計の登録件数チェック');
        system.assertEquals(test1.echoTotal.Id  , test1.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('消毒'              , test1.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1001                , test1.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
        system.assertEquals(1, test2.auxiList.size(), '付帯商品反響累計の登録件数チェック');
        system.assertEquals(test2.echoTotal.Id  , test2.auxiList[i].EchoTotal__c         , '付帯商品反響累計の登録内容[反響累計]チェック');
        system.assertEquals('アルソック'        , test2.auxiList[i].AuxiliaryItemType__c , '付帯商品反響累計の登録内容[付帯商品種別]チェック');
        system.assertEquals(1005                , test2.auxiList[i].AuxiliaryItemFee__c  , '付帯商品反響累計の登録内容[付帯商品料]チェック');
    }

    ////// 内部クラス
    private class BatchTest {
        Correspond__c                   correspond  { get; set; }       // 対応
        EchoTotal__c                    echoTotal   { get; set; }       // 反響累計
        List<AuxiliaryItemEchoTotal__c> auxiList    { get; set; }       // 付帯商品反響累計

        // コンストラクタ
        public batchTest(String correspondMemo) {
            correspond = getCorrespond(correspondMemo);
            echoTotal = new EchoTotal__c();
            echoTotal.Corresponds__c = correspond.Id;
        }

        // データ登録
        public void upsertEchoTotal() {
            upsert echoTotal;
        }

        // バッチ実行
        public void batchExecute() {
            BX001003Batch b = new BX001003Batch();
            Test.startTest();
            system.debug(Database.executeBatch(b, BATCH_SIZE));
            Test.stopTest();
            auxiList = getAuxiliaryItemEchoTotal(this.echoTotal.id);
        }

        // 付帯商品反響累計のデータ抽出のみ
        public void updateAuxiList() {
            auxiList = getAuxiliaryItemEchoTotal(this.echoTotal.id);
        }

    }

    //--------------------------------------privateメソッド----------------------------------------------------------------------------
    // 反響累計データの取得
    private static EchoTotal__c getEchoTotal(Id targetId) {
        List<EchoTotal__c> ectoList = [
            SELECT Id
            , SystemModstamp
            , AuxiliaryIndoorDisinfectionFee__c
            , AuxiliaryKeyExchangeFee__c
            , AuxiliaryReliableSupportFee__c
            , AuxiliaryFShotFee__c
            , AuxiliaryAlsokLockFee__c
            FROM EchoTotal__c
            WHERE Id = :targetId
        ];
        if (ectoList.size() == 0) {
            throw new NoDataFoundException();
        }
        return ectoList[0];
    }

    // 付帯商品反響累計データの取得
    private static List<AuxiliaryItemEchoTotal__c> getAuxiliaryItemEchoTotal(Id echoTotalId) {
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

    // 対応データの取得
    private static Correspond__c getCorrespond(String key) {
        List<Correspond__c> corrList = [SELECT Id FROM Correspond__c WHERE EventId__c = :key];
        if (corrList.size() == 0) {
            throw new NoDataFoundException();
        }
        return corrList[0];
    }
}