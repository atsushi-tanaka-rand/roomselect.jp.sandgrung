/* *
* 自動メンテナンス一覧のテスト
*/
@ isTest

private class TD601001Test {

    //変数設定
    
    static List<SelectOption> searchDistrictList= CommonUtil.getSelectOptionFromObject('Building__c', 'District__c');//検索地区リストを建物__cの地区__cから設定
    
    static String  automaintenanceTypeAddnew = CommonConst.AUTOMAINTENANCE_TYPE_ADDNEW;//メンテナンス種別:新規追加
    static String  automaintenanceTypeConditionchangeupdate = CommonConst.AUTOMAINTENANCE_TYPE_CONDITIONCHANGEUPDATE;//メンテナンス種別:更新(条件変更)
    static String  automaintenanceTypeOccupiedtovacantupdate = CommonConst.AUTOMAINTENANCE_TYPE_OCCUPIEDTOVACANTUPDATE;//メンテナンス種別:更新(居住中→空室)
    static String  automaintenanceTypeEndofposting = CommonConst.AUTOMAINTENANCE_TYPE_ENDOFPOSTING;//メンテナンス種別:掲載終了           
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        // 建物テストデータ作成
        Building__c building = new Building__c();
        
        building.Name = 'buildName';
        building.District__c = searchDistrictList[1].getValue();
        
        insert building;// 建物テストデータ作成
        
        
        // 物件テストデータ作成
        Property__c property = new Property__c();
        
        property.Name = 'propertyName';
        property.Building__c = building.Id;
        property.RentFee__c = 1500;
        
        insert property;// 物件テストデータ作成

        
        // 地区別メンテナンス条件作成
        AreaMaintenanceCondition__c areaMaintenanceCondition = new AreaMaintenanceCondition__c();
        
        areaMaintenanceCondition.District__c = searchDistrictList[1].getValue();
        areaMaintenanceCondition.PropertyAmountLowerLimit__c = 1000;
        areaMaintenanceCondition.PropertyAmountUpperLimit__c = 2000;
        
        insert areaMaintenanceCondition;// 地区別メンテナンス条件作成


        //日付時間型の項目宣言
        Date today = commonUtil.getToday();
        Time zerotime = Time.newInstance(0, 0, 0, 0);
        Datetime todayDatetime = datetime.newInstance(today, zerotime);


        // 自動メンテナンステストデータ作成
        AutoMaintenance__c autoMaintenance = new AutoMaintenance__c();
        
        autoMaintenance.Name = 'autoMaintenanceName';
        autoMaintenance.Building__c = building.Id;
        autoMaintenance.Property__c = property.Id;
        autoMaintenance.Type__c = automaintenanceTypeEndofposting;
        autoMaintenance.IsCompletedFlag__c = FALSE;
        autoMaintenance.ImportDatetime__c = todayDatetime;
        autoMaintenance.CrawlingSource__c = 'リアプロ';
        autoMaintenance.AutoMaintenance__c = '自動メンテナンス内容';
        
        insert autoMaintenance;// 自動メンテナンステストデータ作成1
        
        AutoMaintenance__c autoMaintenance2 = new AutoMaintenance__c();
        
        autoMaintenance2.Name = 'autoMaintenanceName';
        autoMaintenance2.Building__c = building.Id;
        autoMaintenance2.Property__c = property.Id;
        autoMaintenance2.Type__c = automaintenanceTypeEndofposting;
        autoMaintenance2.IsCompletedFlag__c = FALSE;
        autoMaintenance2.ImportDatetime__c = todayDatetime;
        autoMaintenance2.CrawlingSource__c = 'リアプロ';
        autoMaintenance2.AutoMaintenance__c = '自動メンテナンス内容2';
        
        insert autoMaintenance2;// 自動メンテナンステストデータ作成2
    }	
    
    //カスタム設定の作成
    static SystemConfig__c autoMaintenanceSearchMaxCountCustomSettings(Decimal maxCount){
        SystemConfig__c settings = new SystemConfig__c();
        settings.AutoMaintenanceSearchMaxCount__c = maxCount;//検索上限
        insert settings;
        
        return settings;
    }
    
    //帳票出力
    @isTest static void outputTest() {
        
        autoMaintenanceSearchMaxCountCustomSettings(5000);//検索上限
        
        
        Date today = commonUtil.getToday();//テスト実施日付
        
        //パラメータ設定
        PageReference pageRef = Page.TD601001View;

        pageRef.getParameters().put('automaintenanceType',automaintenanceTypeEndofposting );
        pageRef.getParameters().put('isUp','false' );
        pageRef.getParameters().put('fromImportDate',string.valueOf(today.addDays(-1)) );
        pageRef.getParameters().put('toImportDate',string.valueOf(today.addDays(+1)) );
        pageRef.getParameters().put('district',searchDistrictList[1].getValue());
        pageRef.getParameters().put('amountLowerLimit',string.valueOf(1000) );
        pageRef.getParameters().put('amountUpperLimit',string.valueOf(2000) );
        pageRef.getParameters().put('isCompletedFlag',null );

        Test.setCurrentPage(pageRef);
        
        //コントローラー作成
        TD601001Controller TD601001Controller = new TD601001Controller();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(TD601001Controller.isOpenError, FALSE);

    }

    
    //帳票出力エラー
    @isTest static void parameterErrorTest() {
        
        autoMaintenanceSearchMaxCountCustomSettings(5000);//検索上限
        Date today = commonUtil.getToday();//テスト実施日付
        
        //パラメータ設定
        PageReference pageRef = Page.TD601001View;

        pageRef.getParameters().put('automaintenanceType',null );//自動メンテ種別がnullの場合エラー
        pageRef.getParameters().put('isUp','false' );
        pageRef.getParameters().put('fromImportDate',string.valueOf(today.addDays(-1)) );
        pageRef.getParameters().put('toImportDate',string.valueOf(today.addDays(+1)) );
        pageRef.getParameters().put('district',searchDistrictList[1].getValue());
        pageRef.getParameters().put('amountLowerLimit',string.valueOf(1000) );
        pageRef.getParameters().put('amountUpperLimit',string.valueOf(2000) );
        pageRef.getParameters().put('isCompletedFlag',null );

        Test.setCurrentPage(pageRef);
        
        //コントローラー作成
        TD601001Controller TD601001Controller = new TD601001Controller();
        
        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(TD601001Controller.isOpenError, TRUE);
        
        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
        
        system.debug('ApexPages.getMessages()[0].getDetail()' + ApexPages.getMessages()[0].getDetail());
        
    }
    
}