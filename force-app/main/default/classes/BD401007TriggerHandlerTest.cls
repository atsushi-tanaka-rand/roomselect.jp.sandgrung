// ポータルサイト閲覧履歴トリガハンドラーAPEXテスト
@isTest
public with sharing class BD401007TriggerHandlerTest {
    //▼ No.0625 対応履歴に閲覧形跡が残っていない対応
    //テストに使用するレコードを作成する
    @testSetup static void Setting() {
        // 取引先
        Account AccountRecord = new Account(Name = 'テスト太郎'                //取引先名
                        ,NameKana__c = 'ﾃｽﾄﾀﾛｳ'            //取引先名（カナ）
                        ,Phone = '025-200-1234'            //電話番号
                        ,Email__c = 'aaa@hora'             // メール
                        ,state__c = '大阪府'               //都道府県
                        ,city__c = '大阪市'                //住所１（市区町村）
                        ,street__c = '中央区安土町４－１'   //住所２（番地）
                        ,RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER) //レコードタイプID（顧客）
        );
        Account AccountRecord2 = new Account(Name = 'テスト次郎'                //取引先名
                        ,NameKana__c = 'ﾃｽﾄｼﾞﾛｳ'            //取引先名（カナ）
                        ,Phone = '025-200-1234'            //電話番号
                        ,Email__c = 'bbb@hora'             // メール
                        ,state__c = '大阪府'               //都道府県
                        ,city__c = '大阪市'                //住所１（市区町村）
                        ,street__c = '中央区安土町４－１'   //住所２（番地）
                        ,RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER) //レコードタイプID（顧客）
        );
        List<Account> accountList = new List<Account> {AccountRecord,AccountRecord2};
        insert accountList;

        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = 'テスト１',
                                        PortalSitePostingDistrict__c = '港区;北区',
                                        Email__c = 'tempoEmail@rand.co.jp');
        Shop__c shopRecord2 = new shop__c(Name = 'テスト２',
                                        PortalSitePostingDistrict__c = '港区;北区',
                                        Email__c = 'tempoEmail2@rand.co.jp');
        List<shop__c> shopList = new List<shop__c>{shopRecord,shopRecord2};
        insert shopList;

        // 対応OBJに登録を行う。
        List<Correspond__c> correspondList = new List<Correspond__c> ();
        Correspond__c addCorrespond = new Correspond__c(
            AccountId__c = AccountRecord.id ,
            EchoShop__c = shopRecord.id
        );
        Correspond__c addCorrespond2 = new Correspond__c(
            AccountId__c = AccountRecord.id ,
            EchoShop__c = shopRecord2.id
        );
        Correspond__c addCorrespond3 = new Correspond__c(
            AccountId__c = AccountRecord2.id ,
            EchoShop__c = shopRecord.id
        );
        Correspond__c addCorrespond4 = new Correspond__c(
            AccountId__c = AccountRecord2.id ,
            EchoShop__c = shopRecord2.id
        );

        correspondList.add(addCorrespond);
        correspondList.add(addCorrespond2);
        correspondList.add(addCorrespond3);
        correspondList.add(addCorrespond4);
        insert correspondList;
    }
    //▲ No.0625 対応履歴に閲覧形跡が残っていない対応

    // InsertTest
    @isTest static void InsertTest(){

        // 対応OBJに登録を行う。
        List<Correspond__c> correspondList = new List<Correspond__c> ();
        Correspond__c addCorrespond = new Correspond__c(
            IsBrowseFlg__c = false // falseを指定。トリガにより、trueとなる想定。            
        );
        correspondList.add(addCorrespond);
        List<Correspond__c> correspondIdList = [SELECT Id FROM Correspond__c] ; // 登録する際の、idを取得するために、SELCTする。


        // ポータルサイト閲覧履歴OBJに登録をおこなう。
        List<PortalSiteBrowseDifference__c> portalDiferenceList = new List<PortalSiteBrowseDifference__c>();

        for(Integer i = 0; i < 10; i++ ){
            PortalSiteBrowseDifference__c addPoratalDifference = new PortalSiteBrowseDifference__c(
                    CorrespondId__c = correspondIdList.get(0).Id

            );
            portalDiferenceList.add(addPoratalDifference);
        }
        // insert 
        Test.startTest();
        // 対象メソッドを呼び出す
        insert portalDiferenceList;
        Test.stopTest();



        

        // 確認のためIdを取得する(対応明細)
        List<CorrespondDetail__c> CorrespondDetailList = [SELECT Id FROM CorrespondDetail__c]; 

        // 確認のためIdを取得する(対応OBJ)
        List<Correspond__c> correspondFlgList = [SELECT IsBrowseFlg__c FROM Correspond__c];
    
        //確認のためIdを取得する(ポータルサイト閲覧差分OBJ)
        List<PortalSiteBrowseDifference__c> poratalIDList = [SELECT Id FROM PortalSiteBrowseDifference__c];

        // assertする(対応明細)
        System.assert(CorrespondDetailList.size() > 0);

        // assertする(対応OBJ)
        System.assertEquals(true, correspondFlgList.get(0).IsBrowseFlg__c);

        // assertする(ポータルサイト閲覧差分OBJ)
        System.assertEquals(0, poratalIDList.size());
    }

    // 対応無しテスト
    @isTest static void noCorrespondsTest(){

        // ポータルサイト閲覧差分の登録
        PortalSiteBrowseDifference__c poratalDiff = new PortalSiteBrowseDifference__c();
        insert poratalDiff;
    }

    //▼ No.0625 対応履歴に閲覧形跡が残っていない対応
    /**
     * 対応明細作成
     * 複数登録（対応、取引先違い）
     * 複数登録した分の対応明細が作成されること
     */   
    @isTest static void pluralPortalSiteBrowseDifference(){
        List<Correspond__c> correspondList = [SELECT Id,AccountId__c FROM Correspond__c ];
        List<PortalSiteBrowseDifference__c> PortalSiteBrowseDifferenceList = new List<PortalSiteBrowseDifference__c>();
        // ポータルサイト閲覧差分の登録
        for(Correspond__c  correspond: correspondList){
            PortalSiteBrowseDifference__c poratalDiff = new PortalSiteBrowseDifference__c(
                AccountId__c = correspond.AccountId__c,
                CorrespondId__c = correspond.id ,
                PortalSiteUrl__c = 'https://test/12345/',
                PropertyDetail__c = 'テスト建物'
            );
            PortalSiteBrowseDifferenceList.add(poratalDiff);
        }

        Test.startTest();
        insert PortalSiteBrowseDifferenceList;

        Test.stopTest();

        // 対応明細
        List<CorrespondDetail__c> correspondDetailList = [SELECT Id
                                                            ,      Corresponds__c 
                                                            FROM   CorrespondDetail__c
        ];
        
        system.assertEquals(4,correspondDetailList.size());
    }

    /**
     * 対応明細作成
     * 複数登録（対応、取引先同じ）
     * 同じ場合、その1件のみ作成されること
     */   
    @isTest static void pluralPortalSiteBrowseDifference2(){
        List<Correspond__c> correspondList = [SELECT Id,AccountId__c FROM Correspond__c WHERE  EchoShop__r.name = 'テスト１'];
        List<PortalSiteBrowseDifference__c> PortalSiteBrowseDifferenceList = new List<PortalSiteBrowseDifference__c>();
        // ポータルサイト閲覧差分の登録
        for(Correspond__c  correspond: correspondList){
            PortalSiteBrowseDifference__c poratalDiff = new PortalSiteBrowseDifference__c(
                AccountId__c = correspond.AccountId__c,
                CorrespondId__c = correspond.id ,
                PortalSiteUrl__c = 'https://test/12345/',
                PropertyDetail__c = 'テスト建物'
            );
            PortalSiteBrowseDifferenceList.add(poratalDiff);
            PortalSiteBrowseDifference__c poratalDiff2 = new PortalSiteBrowseDifference__c(
                AccountId__c = correspond.AccountId__c,
                CorrespondId__c = correspond.id ,
                PortalSiteUrl__c = 'https://test/123456789/',
                PropertyDetail__c = 'テスト建物2'
            );
            PortalSiteBrowseDifferenceList.add(poratalDiff2);
        }

        Test.startTest();
        insert PortalSiteBrowseDifferenceList;

        Test.stopTest();

        // 対応明細
        List<CorrespondDetail__c> correspondDetailList = [SELECT Id
                                                            ,      Corresponds__c 
                                                            FROM   CorrespondDetail__c
        ];
        
        system.assertEquals(2,correspondDetailList.size());
    }
    //▲ No.0625 対応履歴に閲覧形跡が残っていない対応
}