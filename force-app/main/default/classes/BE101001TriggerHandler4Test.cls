//日報集計部品（画面呼び出し）のテストクラス
@ isTest
private class BE101001TriggerHandler4Test {

    @TestSetup

    // テストに利用するListを用意する。
    static void Setting(){
        //店舗レコード
        Shop__c shopRecord = new shop__c(Name = '横井店舗',
                                         PortalSitePostingDistrict__c = '港区;北区');
        insert shopRecord;

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
            Shop__c = shopRecord.Id
        );
        insert orgRecord2;

        //店舗異動レコード
        List<ShopTransfer__c> ShopTransferList = new List<ShopTransfer__c>();
        // ログインユーザ用にデータ格納
        ShopTransfer__c ShopTransferRecord = new ShopTransfer__c(OrgzanizationHierarchy__c = orgRecord2.id,
                                                                 Staff__c = UserInfo.getUserId(),
                                                                 StartDate__c = Date.newInstance(2000, 12, 1),
                                                                 EndDate__c = Date.newInstance(2999, 12, 1)); 
        ShopTransferList.add(ShopTransferRecord);

        insert ShopTransferList;

    }

    // メンテナンス一覧画面から登録・更新された場合のテスト
    @isTest static void upsertDailyReportMaintenance(){
        // 登録

        // 日報登録・更新部品呼び出し
        DailyReportUtil.upsertDailyReportMaintenance();

        // 登録した日報オブジェクトの結果を確認する
        List<DailyReport__c> addDailyReportList = [SELECT Id
                                                    , AutoMaintenanceCount__c
                                                    , Electronic__c
                                                    , PhotoRegist__c
                                                FROM DailyReport__c
                                                ];

        System.assertEquals(1, addDailyReportList.size());
        for (DailyReport__c dt : addDailyReportList) {
            System.assertEquals(1, dt.AutoMaintenanceCount__c);
            System.assertEquals(0, dt.Electronic__c);
            System.assertEquals(0, dt.PhotoRegist__c);
        }

        // 更新
        // メンテナンス一覧画面から呼び出される登録処理を呼び出し
        DailyReportUtil.upsertDailyReportMaintenance();

        // 日報登録・更新部品呼び出し
        List<DailyReport__c> updDailyReportList = [SELECT Id
                                                    , AutoMaintenanceCount__c
                                                    , Electronic__c
                                                    , PhotoRegist__c
                                                FROM DailyReport__c
                                                ];

        System.assertEquals(1, updDailyReportList.size());
        for (DailyReport__c dt : updDailyReportList) {
            System.assertEquals(2, dt.AutoMaintenanceCount__c);
            System.assertEquals(0, dt.Electronic__c);
            System.assertEquals(0, dt.PhotoRegist__c);
        }
    }

    // 電物メンテ一覧画面から登録・更新された場合のテスト
    @isTest static void upsertDailyReportDembutsu(){
        // 登録



        // 登録した日報オブジェクトの結果を確認する
        List<DailyReport__c> addDailyReportList = [SELECT Id
                                                    , AutoMaintenanceCount__c
                                                    , Electronic__c
                                                    , PhotoRegist__c
                                                FROM DailyReport__c
                                                ];




        // 登録した日報オブジェクトの結果を確認する
        List<DailyReport__c> updDailyReportList = [SELECT Id
                                                    , AutoMaintenanceCount__c
                                                    , Electronic__c
                                                    , PhotoRegist__c
                                                FROM DailyReport__c
                                                ];

    }

    // 物件登録画面から登録・更新された場合のテスト
    @isTest static void upsertDailyReportProperty(){
        // 登録

        // 日報登録・更新部品呼び出し
        DailyReportUtil.upsertDailyReportProperty();

        // 登録した日報オブジェクトの結果を確認する
        List<DailyReport__c> addDailyReportList = [SELECT Id
                                                    , AutoMaintenanceCount__c
                                                    , Electronic__c
                                                    , PhotoRegist__c
                                                FROM DailyReport__c
                                                ];

        System.assertEquals(1, addDailyReportList.size());
        for (DailyReport__c dt : addDailyReportList) {
            System.assertEquals(0, dt.AutoMaintenanceCount__c);
            System.assertEquals(0, dt.Electronic__c);
            System.assertEquals(1, dt.PhotoRegist__c);
        }

        // 更新
        // 日報登録・更新部品呼び出し
        DailyReportUtil.upsertDailyReportProperty();

        // 登録した日報オブジェクトの結果を確認する
        List<DailyReport__c> updDailyReportList = [SELECT Id
                                                    , AutoMaintenanceCount__c
                                                    , Electronic__c
                                                    , PhotoRegist__c
                                                FROM DailyReport__c
                                                ];

        System.assertEquals(1, updDailyReportList.size());
        for (DailyReport__c dt : updDailyReportList) {
            System.assertEquals(0, dt.AutoMaintenanceCount__c);
            System.assertEquals(0, dt.Electronic__c);
            System.assertEquals(2, dt.PhotoRegist__c);
        }
    }
}