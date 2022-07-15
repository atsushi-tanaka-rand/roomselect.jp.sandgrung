/* *
* ﾒﾝﾃﾅﾝｽ一覧のテスト
*/
@ isTest

private class GD601001Test {
    
    /** 検索地区リスト */ 
    static List<SelectOption> searchDistrictList= CommonUtil.getSelectOptionFromObject('Building__c', 'District__c');//検索地区リストを建物__cの地区__cから設定
    
    /** メンテナンス種別:新規追加 */ 
    static String  automaintenanceTypeAddnew = CommonConst.AUTOMAINTENANCE_TYPE_ADDNEW;
    
    /** メンテナンス種別:更新(条件変更) */ 
    static String  automaintenanceTypeConditionchangeupdate = CommonConst.AUTOMAINTENANCE_TYPE_CONDITIONCHANGEUPDATE;
    
    /** メンテナンス種別:更新(居住中→空室) */ 
    static String  automaintenanceTypeOccupiedtovacantupdate = CommonConst.AUTOMAINTENANCE_TYPE_OCCUPIEDTOVACANTUPDATE;
    
    /** メンテナンス種別:掲載終了 */ 
    static String  automaintenanceTypeEndofposting = CommonConst.AUTOMAINTENANCE_TYPE_ENDOFPOSTING;             
    
    // 建物テストデータ作成
    static List<Building__c> createBuilding(String name, String district) {
        
        Building__c building = new Building__c();
        
        building.Name = name;
        
        building.District__c = district;
        
        insert building;
        
        List<Building__c> buildingList = [SELECT ID, SystemModStamp FROM Building__c WHERE Name = :name];
        
        return buildingList;
    }	
    
    
    // 物件テストデータ作成
    static List<Property__c> createProperty(String name, String building, Decimal rentFee) {
        
        Property__c property = new Property__c();
        
        property.Name = name;
        
        property.Building__c = building;
        
        property.RentFee__c = rentFee;
        
        insert property;
        
        List<Property__c> propertyList = [SELECT ID, SystemModStamp FROM Property__c WHERE Name = :name];
        
        return propertyList;
    }	
    
    // 地区別メンテナンス条件テストデータ作成
    static List<AreaMaintenanceCondition__c> createAreaMaintenanceCondition(String district, Decimal propertyAmountLowerLimit, Decimal propertyAmountUpperLimit) {
        
        AreaMaintenanceCondition__c areaMaintenanceCondition = new AreaMaintenanceCondition__c();
        
        areaMaintenanceCondition.District__c = district;
        
        areaMaintenanceCondition.PropertyAmountLowerLimit__c = propertyAmountLowerLimit;
        
        areaMaintenanceCondition.PropertyAmountUpperLimit__c = propertyAmountUpperLimit;
        
        
        
        insert areaMaintenanceCondition;
        
        List<AreaMaintenanceCondition__c> areaMaintenanceConditionList = [SELECT ID, SystemModStamp FROM AreaMaintenanceCondition__c WHERE District__c = :district];
        
        return areaMaintenanceConditionList;
    }	
    
    // 自動メンテナンステストデータ作成
    static List<AutoMaintenance__c> createAutoMaintenance(String name
                                                          , String building
                                                          , String property
                                                          , String type
                                                          , Boolean isCompletedFlag
                                                          , Datetime importDatetime) {
                                                              
                                                              AutoMaintenance__c autoMaintenance = new AutoMaintenance__c();
                                                              
                                                              autoMaintenance.Name = name;
                                                              autoMaintenance.Building__c = building;
                                                              autoMaintenance.Property__c = property;
                                                              autoMaintenance.Type__c = type;
                                                              autoMaintenance.IsCompletedFlag__c = isCompletedFlag;
                                                              autoMaintenance.ImportDatetime__c = importDatetime;
                                                              autoMaintenance.CrawlingSource__c = 'リアプロ';
                                                              autoMaintenance.AutoMaintenance__c = '自動メンテナンス内容';
                                                              
                                                              
                                                              
                                                              insert autoMaintenance;
                                                              
                                                              List<AutoMaintenance__c> autoMaintenanceList = [SELECT ID, SystemModStamp, Name FROM AutoMaintenance__c WHERE Name = :name];
                                                              
                                                              return autoMaintenanceList;
                                                          }	
    
    //カスタム設定の作成
    static SystemConfig__c autoMaintenanceSearchMaxCountCustomSettings(Decimal maxCount){
        SystemConfig__c settings = new SystemConfig__c();
        settings.AutoMaintenanceSearchMaxCount__c = maxCount;
        insert settings;
        
        return settings;
    }
    
    //「検索対象地区」の選択値変更
    @isTest static void changeDistrictTest() {
        
        System.debug('searchDistrictList ' + searchDistrictList);
        
        //地区別メンテナンス条件テストデータ作成
        //検索地区リスト[0]は「--なし--」なので検索地区リスト[1]を使用
        System.debug('地区別メンテナンス条件テストデータ ' + searchDistrictList[1].getValue());
        createAreaMaintenanceCondition(searchDistrictList[1].getValue(), 1000, 2000);
        
        //コントローラー作成
        GD601001Controller GD601001Controller = new GD601001Controller();
        
        //「検索対象地区」の選択値変更
        GD601001Controller.district = searchDistrictList[1].getValue();
        
        //「検索対象地区」の選択値変更時処理実行
        GD601001Controller.changeDistrict();
        
        System.debug('district:' + GD601001Controller.district);
        System.debug('amountLowerLimit:' + GD601001Controller.amountLowerLimit);
        System.debug('amountUpperLimit:' + GD601001Controller.amountUpperLimit);
        
        //ページの「取扱い物件　金額(下限)」、「取扱い物件　金額(上限)」が設定されていることを確認
        system.assertEquals(1000, GD601001Controller.amountLowerLimit);
        system.assertEquals(2000, GD601001Controller.amountUpperLimit);
        
    }
    
    //新規追加(残)
    @isTest static void addnewNotPastSearchTest() {
        
        //地区別メンテナンス条件テストデータ作成
        //検索地区リスト[0]は「--なし--」なので検索地区リスト[1]を使用
        System.debug('地区別メンテナンス条件テストデータ ' + searchDistrictList[1].getValue());
        List<AreaMaintenanceCondition__c> inAreaMaintenanceCondition = createAreaMaintenanceCondition(searchDistrictList[1].getValue(), 1000, 2000);
        
        //建物テストデータ作成
        List<Building__c> inBuilding = createBuilding('addnewNotPastSearchTest', searchDistrictList[1].getValue());
        
        //物件テストデータ作成
        List<Property__c> inProperty = createProperty('addnewNotPastSearchTest', inBuilding[0].ID, 1500);
        
        // 自動メンテナンステストデータ作成
        //日付時間型に変更用の項目宣言
        Date today = commonUtil.getToday();
        Time zerotime = Time.newInstance(0, 0, 0, 0);
        Datetime todayDatetime = datetime.newInstance(today, zerotime);
        
        List<AutoMaintenance__c> inAutoMaintenance = createAutoMaintenance('addnewNotPastSearchTest'
                                                                           , inBuilding[0].ID
                                                                           , inProperty[0].ID
                                                                           , automaintenanceTypeAddnew
                                                                           , FALSE
                                                                           , todayDatetime);
        
        autoMaintenanceSearchMaxCountCustomSettings(5000);
        
        
        //コントローラー作成
        GD601001Controller GD601001Controller = new GD601001Controller();
        
        //「取込日From」の設定
        GD601001Controller.fromImportDate = today.addDays(-1);
        
        //「取込日To」の設定
        GD601001Controller.toImportDate = today.addDays(+1);
        
        //「検索対象地区」の選択値変更
        GD601001Controller.district = searchDistrictList[1].getValue();
        
        //「検索対象地区」の選択値変更時処理実行
        GD601001Controller.changeDistrict();
        
        //ページの「取扱い物件　金額(下限)」、「取扱い物件　金額(上限)」が設定されていることを確認
        system.assertEquals(1000, GD601001Controller.amountLowerLimit);
        system.assertEquals(2000, GD601001Controller.amountUpperLimit);
        
        GD601001Controller.addnewNotPastSearch();
        System.debug('inAutoMaintenance[0].ID　' + inAutoMaintenance[0].ID);
        System.debug('GD601001Controller.automaintenanceList[0].ID　' + GD601001Controller.automaintenanceList[0].ID);
        
        
        system.assertEquals(inAutoMaintenance[0].ID, GD601001Controller.automaintenanceList[0].ID);
    }
    
    //更新(居住中→空室)(残)
    @isTest static void occupiedtovacantupdateNotPastSearchTest() {
        
        //地区別メンテナンス条件テストデータ作成
        //検索地区リスト[0]は「--なし--」なので検索地区リスト[1]を使用
        System.debug('地区別メンテナンス条件テストデータ ' + searchDistrictList[1].getValue());
        List<AreaMaintenanceCondition__c> inAreaMaintenanceCondition = createAreaMaintenanceCondition(searchDistrictList[1].getValue(), 1000, 2000);
        
        //建物テストデータ作成
        List<Building__c> inBuilding = createBuilding('occupiedtovacantupdateNotPastSearchTest', searchDistrictList[1].getValue());
        
        //物件テストデータ作成
        List<Property__c> inProperty = createProperty('occupiedtovacantupdateNotPastSearchTest', inBuilding[0].ID, 1500);
        
        // 自動メンテナンステストデータ作成
        //日付時間型に変更用の項目宣言
        Date today = commonUtil.getToday();
        Time zerotime = Time.newInstance(0, 0, 0, 0);
        Datetime todayDatetime = datetime.newInstance(today, zerotime);
        
        List<AutoMaintenance__c> inAutoMaintenance = createAutoMaintenance('occupiedtovacantupdateNotPastSearchTest'
                                                                           , inBuilding[0].ID
                                                                           , inProperty[0].ID
                                                                           , automaintenanceTypeOccupiedtovacantupdate
                                                                           , FALSE
                                                                           , todayDatetime);
        
        autoMaintenanceSearchMaxCountCustomSettings(5000);
        
        
        //コントローラー作成
        GD601001Controller GD601001Controller = new GD601001Controller();
        
        //「取込日From」の設定
        GD601001Controller.fromImportDate = today.addDays(-1);
        
        //「取込日To」の設定
        GD601001Controller.toImportDate = today.addDays(+1);
        
        //「検索対象地区」の選択値変更
        GD601001Controller.district = searchDistrictList[1].getValue();
        
        //「検索対象地区」の選択値変更時処理実行
        GD601001Controller.changeDistrict();
        
        //ページの「取扱い物件　金額(下限)」、「取扱い物件　金額(上限)」が設定されていることを確認
        system.assertEquals(1000, GD601001Controller.amountLowerLimit);
        system.assertEquals(2000, GD601001Controller.amountUpperLimit);
        
        GD601001Controller.occupiedtovacantupdateNotPastSearch();
        System.debug('inAutoMaintenance[0].ID　' + inAutoMaintenance[0].ID);
        System.debug('GD601001Controller.automaintenanceList[0].ID　' + GD601001Controller.automaintenanceList[0].ID);
        
        
        system.assertEquals(inAutoMaintenance[0].ID, GD601001Controller.automaintenanceList[0].ID);
    }
    
    //更新(条件変更)(当日)
    @isTest static void conditionchangeupdateNotPastSearchTest() {
        
        //地区別メンテナンス条件テストデータ作成
        //検索地区リスト[0]は「--なし--」なので検索地区リスト[1]を使用
        System.debug('地区別メンテナンス条件テストデータ ' + searchDistrictList[1].getValue());
        List<AreaMaintenanceCondition__c> inAreaMaintenanceCondition = createAreaMaintenanceCondition(searchDistrictList[1].getValue(), 1000, 2000);
        
        //建物テストデータ作成
        List<Building__c> inBuilding = createBuilding('conditionchangeupdateNotPastSearchTest', searchDistrictList[1].getValue());
        
        //物件テストデータ作成
        List<Property__c> inProperty = createProperty('conditionchangeupdateNotPastSearchTest', inBuilding[0].ID, 1500);
        
        // 自動メンテナンステストデータ作成
        //日付時間型に変更用の項目宣言
        Date today = commonUtil.getToday();
        Time zerotime = Time.newInstance(0, 0, 0, 0);
        Datetime todayDatetime = datetime.newInstance(today, zerotime);
        
        List<AutoMaintenance__c> inAutoMaintenance = createAutoMaintenance('conditionchangeupdateNotPastSearchTest'
                                                                           , inBuilding[0].ID
                                                                           , inProperty[0].ID
                                                                           , automaintenanceTypeConditionchangeupdate
                                                                           , FALSE
                                                                           , todayDatetime);
        
        autoMaintenanceSearchMaxCountCustomSettings(5000);
        
        
        //コントローラー作成
        GD601001Controller GD601001Controller = new GD601001Controller();
        
        //「取込日From」の設定
        GD601001Controller.fromImportDate = today.addDays(-1);
        
        //「取込日To」の設定
        GD601001Controller.toImportDate = today.addDays(+1);
        
        //「検索対象地区」の選択値変更
        GD601001Controller.district = searchDistrictList[1].getValue();
        
        //「検索対象地区」の選択値変更時処理実行
        GD601001Controller.changeDistrict();
        
        //ページの「取扱い物件　金額(下限)」、「取扱い物件　金額(上限)」が設定されていることを確認
        system.assertEquals(1000, GD601001Controller.amountLowerLimit);
        system.assertEquals(2000, GD601001Controller.amountUpperLimit);
        
        GD601001Controller.conditionchangeupdateNotPastSearch();
        System.debug('inAutoMaintenance[0].ID　' + inAutoMaintenance[0].ID);
        System.debug('GD601001Controller.automaintenanceList[0].ID　' + GD601001Controller.automaintenanceList[0].ID);
        
        
        system.assertEquals(inAutoMaintenance[0].ID, GD601001Controller.automaintenanceList[0].ID);
    }
    
    //掲載終了(当日)
    @isTest static void endofpostingNotPastSearchTest() {
        
        //地区別メンテナンス条件テストデータ作成
        //検索地区リスト[0]は「--なし--」なので検索地区リスト[1]を使用
        System.debug('地区別メンテナンス条件テストデータ ' + searchDistrictList[1].getValue());
        List<AreaMaintenanceCondition__c> inAreaMaintenanceCondition = createAreaMaintenanceCondition(searchDistrictList[1].getValue(), 1000, 2000);
        
        //建物テストデータ作成
        List<Building__c> inBuilding = createBuilding('endofpostingNotPastSearchTest', searchDistrictList[1].getValue());
        
        //物件テストデータ作成
        List<Property__c> inProperty = createProperty('endofpostingNotPastSearchTest', inBuilding[0].ID, 1500);
        
        // 自動メンテナンステストデータ作成
        //日付時間型に変更用の項目宣言
        Date today = commonUtil.getToday();
        Time zerotime = Time.newInstance(0, 0, 0, 0);
        Datetime todayDatetime = datetime.newInstance(today, zerotime);
        
        List<AutoMaintenance__c> inAutoMaintenance = createAutoMaintenance('endofpostingNotPastSearchTest'
                                                                           , inBuilding[0].ID
                                                                           , inProperty[0].ID
                                                                           , automaintenanceTypeEndofposting
                                                                           , FALSE
                                                                           , todayDatetime);
        
        autoMaintenanceSearchMaxCountCustomSettings(5000);
        
        
        //コントローラー作成
        GD601001Controller GD601001Controller = new GD601001Controller();
        
        //「取込日From」の設定
        GD601001Controller.fromImportDate = today.addDays(-1);
        
        //「取込日To」の設定
        GD601001Controller.toImportDate = today.addDays(+1);
        
        //「検索対象地区」の選択値変更
        GD601001Controller.district = searchDistrictList[1].getValue();
        
        //「検索対象地区」の選択値変更時処理実行
        GD601001Controller.changeDistrict();
        
        //ページの「取扱い物件　金額(下限)」、「取扱い物件　金額(上限)」が設定されていることを確認
        system.assertEquals(1000, GD601001Controller.amountLowerLimit);
        system.assertEquals(2000, GD601001Controller.amountUpperLimit);
        
        GD601001Controller.endofpostingNotPastSearch();
        System.debug('inAutoMaintenance[0].ID　' + inAutoMaintenance[0].ID);
        System.debug('GD601001Controller.automaintenanceList[0].ID　' + GD601001Controller.automaintenanceList[0].ID);
        
        
        system.assertEquals(inAutoMaintenance[0].ID, GD601001Controller.automaintenanceList[0].ID);
    }
    
    //新規追加
    @isTest static void addnewPastSearchTest() {
        
        //地区別メンテナンス条件テストデータ作成
        //検索地区リスト[0]は「--なし--」なので検索地区リスト[1]を使用
        System.debug('地区別メンテナンス条件テストデータ ' + searchDistrictList[1].getValue());
        List<AreaMaintenanceCondition__c> inAreaMaintenanceCondition = createAreaMaintenanceCondition(searchDistrictList[1].getValue(), 1000, 2000);
        
        //建物テストデータ作成
        List<Building__c> inBuilding = createBuilding('addnewPastSearchTest', searchDistrictList[1].getValue());
        
        //物件テストデータ作成
        List<Property__c> inProperty = createProperty('addnewPastSearchTest', inBuilding[0].ID, 1500);
        
        // 自動メンテナンステストデータ作成
        //日付時間型に変更用の項目宣言
        Date today = commonUtil.getToday();
        Time zerotime = Time.newInstance(0, 0, 0, 0);
        Datetime todayDatetime = datetime.newInstance(today, zerotime);
        
        List<AutoMaintenance__c> inAutoMaintenance = createAutoMaintenance('addnewPastSearchTest'
                                                                           , inBuilding[0].ID
                                                                           , inProperty[0].ID
                                                                           , automaintenanceTypeAddnew
                                                                           , TRUE
                                                                           , todayDatetime);
        
        autoMaintenanceSearchMaxCountCustomSettings(5000);
        
        
        //コントローラー作成
        GD601001Controller GD601001Controller = new GD601001Controller();
        
        //「取込日From」の設定
        GD601001Controller.fromImportDate = today.addDays(-1);
        
        //「取込日To」の設定
        GD601001Controller.toImportDate = today.addDays(+1);
        
        //「検索対象地区」の選択値変更
        GD601001Controller.district = searchDistrictList[1].getValue();
        
        //「検索対象地区」の選択値変更時処理実行
        GD601001Controller.changeDistrict();
        
        //ページの「取扱い物件　金額(下限)」、「取扱い物件　金額(上限)」が設定されていることを確認
        system.assertEquals(1000, GD601001Controller.amountLowerLimit);
        system.assertEquals(2000, GD601001Controller.amountUpperLimit);
        
        GD601001Controller.addnewPastSearch();
        System.debug('inAutoMaintenance[0].ID　' + inAutoMaintenance[0].ID);
        System.debug('GD601001Controller.automaintenanceList[0].ID　' + GD601001Controller.automaintenanceList[0].ID);
        
        
        system.assertEquals(inAutoMaintenance[0].ID, GD601001Controller.automaintenanceList[0].ID);
    }
    
    //更新(居住中→空室)
    @isTest static void occupiedtovacantupdatePastSearchTest() {
        
        //地区別メンテナンス条件テストデータ作成
        //検索地区リスト[0]は「--なし--」なので検索地区リスト[1]を使用
        System.debug('地区別メンテナンス条件テストデータ ' + searchDistrictList[1].getValue());
        List<AreaMaintenanceCondition__c> inAreaMaintenanceCondition = createAreaMaintenanceCondition(searchDistrictList[1].getValue(), 1000, 2000);
        
        //建物テストデータ作成
        List<Building__c> inBuilding = createBuilding('occupiedtovacantupdatePastSearchTest', searchDistrictList[1].getValue());
        
        //物件テストデータ作成
        List<Property__c> inProperty = createProperty('occupiedtovacantupdatePastSearchTest', inBuilding[0].ID, 1500);
        
        // 自動メンテナンステストデータ作成
        //日付時間型に変更用の項目宣言
        Date today = commonUtil.getToday();
        Time zerotime = Time.newInstance(0, 0, 0, 0);
        Datetime todayDatetime = datetime.newInstance(today, zerotime);
        
        List<AutoMaintenance__c> inAutoMaintenance = createAutoMaintenance('occupiedtovacantupdatePastSearchTest'
                                                                           , inBuilding[0].ID
                                                                           , inProperty[0].ID
                                                                           , automaintenanceTypeOccupiedtovacantupdate
                                                                           , TRUE
                                                                           , todayDatetime);
        
        autoMaintenanceSearchMaxCountCustomSettings(5000);
        
        
        //コントローラー作成
        GD601001Controller GD601001Controller = new GD601001Controller();
        
        //「取込日From」の設定
        GD601001Controller.fromImportDate = today.addDays(-1);
        
        //「取込日To」の設定
        GD601001Controller.toImportDate = today.addDays(+1);
        
        //「検索対象地区」の選択値変更
        GD601001Controller.district = searchDistrictList[1].getValue();
        
        //「検索対象地区」の選択値変更時処理実行
        GD601001Controller.changeDistrict();
        
        //ページの「取扱い物件　金額(下限)」、「取扱い物件　金額(上限)」が設定されていることを確認
        system.assertEquals(1000, GD601001Controller.amountLowerLimit);
        system.assertEquals(2000, GD601001Controller.amountUpperLimit);
        
        GD601001Controller.occupiedtovacantupdatePastSearch();
        System.debug('inAutoMaintenance[0].ID　' + inAutoMaintenance[0].ID);
        System.debug('GD601001Controller.automaintenanceList[0].ID　' + GD601001Controller.automaintenanceList[0].ID);
        
        
        system.assertEquals(inAutoMaintenance[0].ID, GD601001Controller.automaintenanceList[0].ID);
    }
    
    //更新(条件変更)
    @isTest static void conditionchangeupdatePastSearchTest() {
        
        //地区別メンテナンス条件テストデータ作成
        //検索地区リスト[0]は「--なし--」なので検索地区リスト[1]を使用
        System.debug('地区別メンテナンス条件テストデータ ' + searchDistrictList[1].getValue());
        List<AreaMaintenanceCondition__c> inAreaMaintenanceCondition = createAreaMaintenanceCondition(searchDistrictList[1].getValue(), 1000, 2000);
        
        //建物テストデータ作成
        List<Building__c> inBuilding = createBuilding('conditionchangeupdatePastSearchTest', searchDistrictList[1].getValue());
        
        //物件テストデータ作成
        List<Property__c> inProperty = createProperty('conditionchangeupdatePastSearchTest', inBuilding[0].ID, 1500);
        
        // 自動メンテナンステストデータ作成
        //日付時間型に変更用の項目宣言
        Date today = commonUtil.getToday();
        Time zerotime = Time.newInstance(0, 0, 0, 0);
        Datetime todayDatetime = datetime.newInstance(today, zerotime);
        
        List<AutoMaintenance__c> inAutoMaintenance = createAutoMaintenance('conditionchangeupdatePastSearchTest'
                                                                           , inBuilding[0].ID
                                                                           , inProperty[0].ID
                                                                           , automaintenanceTypeConditionchangeupdate
                                                                           , TRUE
                                                                           , todayDatetime);
        
        autoMaintenanceSearchMaxCountCustomSettings(5000);
        
        
        //コントローラー作成
        GD601001Controller GD601001Controller = new GD601001Controller();
        
        //「取込日From」の設定
        GD601001Controller.fromImportDate = today.addDays(-1);
        
        //「取込日To」の設定
        GD601001Controller.toImportDate = today.addDays(+1);
        
        //「検索対象地区」の選択値変更
        GD601001Controller.district = searchDistrictList[1].getValue();
        //「検索対象地区」の選択値変更時処理実行
        GD601001Controller.changeDistrict();
        
        //ページの「取扱い物件　金額(下限)」、「取扱い物件　金額(上限)」が設定されていることを確認
        system.assertEquals(1000, GD601001Controller.amountLowerLimit);
        system.assertEquals(2000, GD601001Controller.amountUpperLimit);
        
        GD601001Controller.conditionchangeupdatePastSearch();
        System.debug('inAutoMaintenance[0].ID　' + inAutoMaintenance[0].ID);
        System.debug('GD601001Controller.automaintenanceList[0].ID　' + GD601001Controller.automaintenanceList[0].ID);
        
        
        system.assertEquals(inAutoMaintenance[0].ID, GD601001Controller.automaintenanceList[0].ID);
    }
    
    //掲載終了
    @isTest static void endofpostingPastSearchTest() {
        
        //地区別メンテナンス条件テストデータ作成
        //検索地区リスト[0]は「--なし--」なので検索地区リスト[1]を使用
        System.debug('地区別メンテナンス条件テストデータ ' + searchDistrictList[1].getValue());
        List<AreaMaintenanceCondition__c> inAreaMaintenanceCondition = createAreaMaintenanceCondition(searchDistrictList[1].getValue(), 1000, 2000);
        
        //建物テストデータ作成
        List<Building__c> inBuilding = createBuilding('endofpostingPastSearchTest', searchDistrictList[1].getValue());
        
        //物件テストデータ作成
        List<Property__c> inProperty = createProperty('endofpostingPastSearchTest', inBuilding[0].ID, 1500);
        
        // 自動メンテナンステストデータ作成
        //日付時間型に変更用の項目宣言
        Date today = commonUtil.getToday();
        Time zerotime = Time.newInstance(0, 0, 0, 0);
        Datetime todayDatetime = datetime.newInstance(today, zerotime);
        
        List<AutoMaintenance__c> inAutoMaintenance = createAutoMaintenance('endofpostingPastSearchTest'
                                                                           , inBuilding[0].ID
                                                                           , inProperty[0].ID
                                                                           , automaintenanceTypeEndofposting
                                                                           , TRUE
                                                                           , todayDatetime);
        
        autoMaintenanceSearchMaxCountCustomSettings(5000);
        
        
        //コントローラー作成
        GD601001Controller GD601001Controller = new GD601001Controller();
        
        //「取込日From」の設定
        GD601001Controller.fromImportDate = today.addDays(-1);
        
        //「取込日To」の設定
        GD601001Controller.toImportDate = today.addDays(+1);
        
        //「検索対象地区」の選択値変更
        GD601001Controller.district = searchDistrictList[1].getValue();
        
        //「検索対象地区」の選択値変更時処理実行
        GD601001Controller.changeDistrict();
        
        //ページの「取込日From」、「取込日To」が設定されていることを確認
        system.assertEquals(1000, GD601001Controller.amountLowerLimit);
        system.assertEquals(2000, GD601001Controller.amountUpperLimit);
        
        GD601001Controller.endofpostingPastSearch();
        System.debug('inAutoMaintenance[0].ID　' + inAutoMaintenance[0].ID);
        System.debug('GD601001Controller.automaintenanceList[0].ID　' + GD601001Controller.automaintenanceList[0].ID);
        
        
        system.assertEquals(inAutoMaintenance[0].ID, GD601001Controller.automaintenanceList[0].ID);
    }
    
    //完了
    @isTest static void maintenanceCompleteTest() {
        
        //地区別メンテナンス条件テストデータ作成
        //検索地区リスト[0]は「--なし--」なので検索地区リスト[1]を使用
        System.debug('地区別メンテナンス条件テストデータ ' + searchDistrictList[1].getValue());
        List<AreaMaintenanceCondition__c> inAreaMaintenanceCondition = createAreaMaintenanceCondition(searchDistrictList[1].getValue(), 1000, 2000);
        
        //建物テストデータ作成
        List<Building__c> inBuilding = createBuilding('addnewNotPastSearchTest', searchDistrictList[1].getValue());
        
        //物件テストデータ作成
        List<Property__c> inProperty = createProperty('addnewNotPastSearchTest', inBuilding[0].ID, 1500);
        
        // 自動メンテナンステストデータ作成
        //日付時間型に変更用の項目宣言
        Date today = commonUtil.getToday();
        Time zerotime = Time.newInstance(0, 0, 0, 0);
        Datetime todayDatetime = datetime.newInstance(today, zerotime);
        
        List<AutoMaintenance__c> inAutoMaintenance = createAutoMaintenance('addnewNotPastSearchTest'
                                                                           , inBuilding[0].ID
                                                                           , inProperty[0].ID
                                                                           , automaintenanceTypeAddnew
                                                                           , FALSE
                                                                           , todayDatetime);
        
        autoMaintenanceSearchMaxCountCustomSettings(5000);
        
        
        //コントローラー作成
        GD601001Controller GD601001Controller = new GD601001Controller();
        
        //「取込日From」の設定
        GD601001Controller.fromImportDate = today.addDays(-1);
        
        //「取込日To」の設定
        GD601001Controller.toImportDate = today.addDays(+1);
        
        //「検索対象地区」の選択値変更
        GD601001Controller.district = searchDistrictList[1].getValue();
        
        //「検索対象地区」の選択値変更時処理実行
        GD601001Controller.changeDistrict();
        
        //ページの「取扱い物件　金額(下限)」、「取扱い物件　金額(上限)」が設定されていることを確認
        system.assertEquals(1000, GD601001Controller.amountLowerLimit);
        system.assertEquals(2000, GD601001Controller.amountUpperLimit);
        
        GD601001Controller.addnewNotPastSearch();
        System.debug('inAutoMaintenance[0].ID　' + inAutoMaintenance[0].ID);
        System.debug('GD601001Controller.automaintenanceList[0].ID　' + GD601001Controller.automaintenanceList[0].ID);
        
        
        system.assertEquals(inAutoMaintenance[0].ID, GD601001Controller.automaintenanceList[0].ID);
        
        GD601001Controller.index = 1;
        
        GD601001Controller.maintenanceComplete();
        
        List<AutoMaintenance__c> completeAutoMaintenance = [SELECT IsCompletedFlag__c FROM AutoMaintenance__c WHERE ID = :inAutoMaintenance[0].ID];
        
        //system.assertEquals(TRUE, completeAutoMaintenance[0].IsCompletedFlag__c);
    }
    
    //「新規追加(残)」押下(異常系)：取込日エラー
    @isTest static void importDatetimeErrorTest() {
        
        //地区別メンテナンス条件テストデータ作成
        //検索地区リスト[0]は「--なし--」なので検索地区リスト[1]を使用
        System.debug('地区別メンテナンス条件テストデータ ' + searchDistrictList[1].getValue());
        List<AreaMaintenanceCondition__c> inAreaMaintenanceCondition = createAreaMaintenanceCondition(searchDistrictList[1].getValue(), 1000, 2000);
        
        //建物テストデータ作成
        List<Building__c> inBuilding = createBuilding('addnewNotPastSearchTest', searchDistrictList[1].getValue());
        
        //物件テストデータ作成
        List<Property__c> inProperty = createProperty('addnewNotPastSearchTest', inBuilding[0].ID, 1500);
        
        // 自動メンテナンステストデータ作成
        //日付時間型に変更用の項目宣言
        Date today = commonUtil.getToday();
        Time zerotime = Time.newInstance(0, 0, 0, 0);
        Datetime todayDatetime = datetime.newInstance(today, zerotime);
        
        List<AutoMaintenance__c> inAutoMaintenance = createAutoMaintenance('addnewNotPastSearchTest'
                                                                           , inBuilding[0].ID
                                                                           , inProperty[0].ID
                                                                           , automaintenanceTypeAddnew
                                                                           , FALSE
                                                                           , todayDatetime);
        
        autoMaintenanceSearchMaxCountCustomSettings(5000);
        
        
        //コントローラー作成
        GD601001Controller GD601001Controller = new GD601001Controller();
        
        //「取込日From」の設定
        GD601001Controller.fromImportDate = today.addDays(+1);
        
        //「取込日To」の設定
        GD601001Controller.toImportDate = today.addDays(-1);
        
        //「検索対象地区」の選択値変更
        GD601001Controller.district = searchDistrictList[1].getValue();
        
        //「検索対象地区」の選択値変更時処理実行
        GD601001Controller.changeDistrict();
        
        //ページの「取扱い物件　金額(下限)」、「取扱い物件　金額(上限)」が設定されていることを確認
        system.assertEquals(1000, GD601001Controller.amountLowerLimit);
        system.assertEquals(2000, GD601001Controller.amountUpperLimit);
        
        GD601001Controller.addnewNotPastSearch();
        
        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GD601001Controller.hasErrorMessage, TRUE);
        
        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_DATE_TERM));
        
        system.debug('ApexPages.getMessages()[0].getDetail()' + ApexPages.getMessages()[0].getDetail());
    }
    

    
    //完了(異常系)
    @isTest static void maintenanceCompleteErrorTest() {
        
        //地区別メンテナンス条件テストデータ作成
        //検索地区リスト[0]は「--なし--」なので検索地区リスト[1]を使用
        System.debug('地区別メンテナンス条件テストデータ ' + searchDistrictList[1].getValue());
        List<AreaMaintenanceCondition__c> inAreaMaintenanceCondition = createAreaMaintenanceCondition(searchDistrictList[1].getValue(), 1000, 2000);
        
        //建物テストデータ作成
        List<Building__c> inBuilding = createBuilding('addnewNotPastSearchTest', searchDistrictList[1].getValue());
        
        //物件テストデータ作成
        List<Property__c> inProperty = createProperty('addnewNotPastSearchTest', inBuilding[0].ID, 1500);
        
        // 自動メンテナンステストデータ作成
        //日付時間型に変更用の項目宣言
        Date today = commonUtil.getToday();
        Time zerotime = Time.newInstance(0, 0, 0, 0);
        Datetime todayDatetime = datetime.newInstance(today, zerotime);
        
        List<AutoMaintenance__c> inAutoMaintenance = createAutoMaintenance('addnewNotPastSearchTest'
                                                                           , inBuilding[0].ID
                                                                           , inProperty[0].ID
                                                                           , automaintenanceTypeAddnew
                                                                           , FALSE
                                                                           , todayDatetime);
        
        autoMaintenanceSearchMaxCountCustomSettings(5000);
        
        
        //コントローラー作成
        GD601001Controller GD601001Controller = new GD601001Controller();
        
        //「取込日From」の設定
        GD601001Controller.fromImportDate = today.addDays(-1);
        
        //「取込日To」の設定
        GD601001Controller.toImportDate = today.addDays(+1);
        
        //「検索対象地区」の選択値変更
        GD601001Controller.district = searchDistrictList[1].getValue();
        
        //「検索対象地区」の選択値変更時処理実行
        GD601001Controller.changeDistrict();
        
        //ページの「取扱い物件　金額(下限)」、「取扱い物件　金額(上限)」が設定されていることを確認
        system.assertEquals(1000, GD601001Controller.amountLowerLimit);
        system.assertEquals(2000, GD601001Controller.amountUpperLimit);
        
        GD601001Controller.addnewNotPastSearch();
        System.debug('inAutoMaintenance[0].ID　' + inAutoMaintenance[0].ID);
        System.debug('GD601001Controller.automaintenanceList[0].ID　' + GD601001Controller.automaintenanceList[0].ID);
        
        
        system.assertEquals(inAutoMaintenance[0].ID, GD601001Controller.automaintenanceList[0].ID);
        
        //更新時間調整用に待機
        CommonUtil.sleep(2000);

        //対象のレコードを「完了」前に更新
        update inAutoMaintenance;
        
        GD601001Controller.index = 1;
        
        GD601001Controller.maintenanceComplete();
        
        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GD601001Controller.hasErrorMessage, TRUE);
        
        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));
        
        system.debug('ApexPages.getMessages()[0].getDetail()' + ApexPages.getMessages()[0].getDetail());
        
    }
    
}