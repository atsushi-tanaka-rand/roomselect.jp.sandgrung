/* *
 * 目標値登録のテスト
 */
@isTest 
private class GEA01001Test {

    /**
    * テストに使用するレコードを作成する
    */
    @TestSetup static void setting(){  
        system.debug('初期設定開始');       

        Date toDay = Date.newInstance(2020, 1, 1);//現在の年を設定
        String targetYear = String.valueOf(toDay.year());//現在の年を設定

        //店舗
        List<Shop__c> shop = new List<Shop__c>();


        //店舗10件
        for(Integer i = 0 ; i < 10 ; i++){
            //店舗
            shop.add(new Shop__c(Name = '店舗' + i//店舗名
                                                     ,SystemUseStartDate__c = toDay.addYears(-1)//システム使用開始日
                                                     ,SystemUseEndDate__c = toDay.addYears(+1)//システム使用終了日
                                                     ,SortOrder__c = i//表示順
                                                     ,IsShopType__c = TRUE//店舗区分
                                                     ));
        }

        insert shop;

        //全社目標
        CompanyGoal__c companyGoal = new CompanyGoal__c(TargetYear__c = targetYear//対象年
                                                       ,EchoCount__c = 10//反響数
                                                       ,CallRate__c = 10//呼込率
                                                       ,ApplicantRate__c = 10//申込率
                                                       ,JanRate__c = 1//1月
                                                       ,FebRate__c = 2//2月
                                                       ,MarRate__c = 3//3月
                                                       ,AprRate__c = 4//4月
                                                       ,MayRate__c = 5//5月
                                                       ,JunRate__c = 6//6月
                                                       ,JulRate__c = 7//7月
                                                       ,AugRate__c = 8//8月
                                                       ,SepRate__c = 9//9月
                                                       ,OctRate__c = 10//10月
                                                       ,NovRate__c = 11//11月
                                                       ,DecRate__c = 12//12月
                                                       );

        insert companyGoal;

        //店舗
        List<ShopGoal__c> shopGoal = new List<ShopGoal__c>();
        for(Shop__c inShop : shop){

            shopGoal.add(new ShopGoal__c(CompanyGoal__c = companyGoal.Id//全社目標
                                     ,Shop__c = inShop.Id//店舗
                                     ,SalesGoal__c = 100//売上目標
                                     ,AverageUnitPrice__c = 100//平均単価
                                     ,EchoCountGoal__c = 100//反響数（目標）
                                     ,PropertyConfirmationCountGoal__c = 100//物確数（目標）
                                     ,EchoCountJan__c = 1 //反響数（1月）
                                     ,EchoCountFeb__c = 2 //反響数（2月）
                                     ,EchoCountMar__c = 3 //反響数（3月）
                                     ,EchoCountApr__c = 4 //反響数（4月）
                                     ,EchoCountMay__c = 5 //反響数（5月）
                                     ,EchoCountJun__c = 6 //反響数（6月）
                                     ,EchoCountJul__c = 7 //反響数（7月）
                                     ,EchoCountAug__c = 8 //反響数（8月）
                                     ,EchoCountSep__c = 9 //反響数（9月）
                                     ,EchoCountOct__c = 10//反響数（10月）
                                     ,EchoCountNov__c = 11//反響数（11月）
                                     ,EchoCountDec__c = 12//反響数（12月）
                                     ,PropertyConfirmationCountJan__c = 1 //物確数（1月）
                                     ,PropertyConfirmationCountFeb__c = 2 //物確数（2月）
                                     ,PropertyConfirmationCountMar__c = 3 //物確数（3月）
                                     ,PropertyConfirmationCountApr__c = 4 //物確数（4月）
                                     ,PropertyConfirmationCountMay__c = 5 //物確数（5月）
                                     ,PropertyConfirmationCountJun__c = 6 //物確数（6月）
                                     ,PropertyConfirmationCountJul__c = 7 //物確数（7月）
                                     ,PropertyConfirmationCountAug__c = 8 //物確数（8月）
                                     ,PropertyConfirmationCountSep__c = 9 //物確数（9月）
                                     ,PropertyConfirmationCountOct__c = 10//物確数（10月）
                                     ,PropertyConfirmationCountNov__c = 11//物確数（11月）
                                     ,PropertyConfirmationCountDec__c = 12//物確数（12月）
                 
                                     )
                        );
        }

        insert shopGoal;


        system.debug('初期設定終了');        

    }

 
    //***************************************************** テストメソッド *****************************************************************
    
    //作成または表示：押下(全社目標あり、店舗目標あり)
    @isTest static void setDisplayTest(){
        CompanyGoal__c companyGoal = [SELECT Id FROM CompanyGoal__c LIMIT 1];
        
        GEA01001Controller GEA010012Controller = new GEA01001Controller();//コンストラクタ起動

        Date toDay = Date.newInstance(2020, 1, 1);//現在の年を設定
        String targetYear = String.valueOf(toDay.year());//現在の年を設定
        GEA010012Controller.targetYear = targetYear;

        GEA010012Controller.setDisplay();

        system.assertEquals(TRUE, GEA010012Controller.displayCompanyGoal.Id == companyGoal.Id);
        system.assertEquals(TRUE, GEA010012Controller.displayShopGoalList.size() > 0);
        
    }

    //月別再計算
    @isTest static void calculateShopGoalEchoCountTest(){
        
        GEA01001Controller GEA010012Controller = new GEA01001Controller();//コンストラクタ起動

        Date toDay = Date.newInstance(2020, 1, 1);//現在の年を設定
        String targetYear = String.valueOf(toDay.year());//現在の年を設定
        GEA010012Controller.targetYear = targetYear;

        GEA010012Controller.setDisplay();

        system.debug('GEA010012Controller.displayShopGoalList.size():' + GEA010012Controller.displayShopGoalList.size());

        GEA010012Controller.displayShopGoalList[0].echoCountGoal = '10000';

        GEA010012Controller.displayShopGoalList[0].echoCountJun = '0';//反響数（1月）
        GEA010012Controller.displayShopGoalList[0].echoCountFeb = '0';//反響数（2月）
        GEA010012Controller.displayShopGoalList[0].echoCountMar = '0';//反響数（3月）
        GEA010012Controller.displayShopGoalList[0].echoCountApr = '0';//反響数（4月）
        GEA010012Controller.displayShopGoalList[0].echoCountMay = '0';//反響数（5月）
        GEA010012Controller.displayShopGoalList[0].echoCountJun = '0';//反響数（6月）
        GEA010012Controller.displayShopGoalList[0].echoCountJul = '0';//反響数（7月）
        GEA010012Controller.displayShopGoalList[0].echoCountAug = '0';//反響数（8月）
        GEA010012Controller.displayShopGoalList[0].echoCountSep = '0';//反響数（9月）
        GEA010012Controller.displayShopGoalList[0].echoCountOct = '0';//反響数（10月）
        GEA010012Controller.displayShopGoalList[0].echoCountNov = '0';//反響数（11月）
        GEA010012Controller.displayShopGoalList[0].echoCountDec = '0';//反響数（12月）
        GEA010012Controller.displayShopGoalList[0].isCheckbox = TRUE;  //月別再計算対象設定


        GEA010012Controller.calculateShopGoalEchoCount();

        system.assertEquals(TRUE, GEA010012Controller.displayShopGoalList[0].echoCountJan != '0');
        
    }
    //全社目標保存
    @isTest static void saveCompanyGoalTest(){
        CompanyGoal__c companyGoal = [SELECT Id, SystemModStamp FROM CompanyGoal__c LIMIT 1];
        
        GEA01001Controller GEA010012Controller = new GEA01001Controller();//コンストラクタ起動

        Date toDay = Date.newInstance(2020, 1, 1);//現在の年を設定
        String targetYear = String.valueOf(toDay.year());//現在の年を設定
        GEA010012Controller.targetYear = targetYear;

        GEA010012Controller.setDisplay();

        //更新時間調整用に待機
        CommonUtil.sleep(1000);

        GEA010012Controller.displayCompanyGoal.applicantRate = '10';//申込率
        GEA010012Controller.displayCompanyGoal.callRate = '10';//呼込率
        //合計100%を設定
        GEA010012Controller.displayCompanyGoal.janRate = '1';//1月
        GEA010012Controller.displayCompanyGoal.febRate = '2';//2月
        GEA010012Controller.displayCompanyGoal.marRate = '3';//3月
        GEA010012Controller.displayCompanyGoal.aprRate = '4';//4月
        GEA010012Controller.displayCompanyGoal.mayRate = '5';//5月
        GEA010012Controller.displayCompanyGoal.junRate = '6';//6月
        GEA010012Controller.displayCompanyGoal.julRate = '7';//7月
        GEA010012Controller.displayCompanyGoal.augRate = '8';//8月
        GEA010012Controller.displayCompanyGoal.sepRate = '9';//9月
        GEA010012Controller.displayCompanyGoal.octRate = '10';//10月
        GEA010012Controller.displayCompanyGoal.novRate = '11';//11月
        GEA010012Controller.displayCompanyGoal.decRate = '34';//12月

        //合計の計算
        GEA010012Controller.calcCompanyGoalRateSum();

        //全社目標保存
        GEA010012Controller.saveCompanyGoal();

        //エラーが発生しないことを確認
        system.assertEquals(FALSE, GEA010012Controller.hasErrorMessage);

        // 全社目標の登録値確認
        CompanyGoal__c record = [ SELECT id
                                        , janRate__c
                                        , febRate__c
                                        , marRate__c
                                        , aprRate__c
                                        , mayRate__c
                                        , junRate__c
                                        , julRate__c
                                        , augRate__c
                                        , sepRate__c
                                        , octRate__c
                                        , novRate__c
                                        , decRate__c
                                        , SystemModStamp
                                        FROM CompanyGoal__c
                                        WHERE id = :companyGoal.Id
                                        LIMIT 1 ];
        system.assertEquals(1,  record.janRate__c, '全社目標の1月の値が不正');
        system.assertEquals(2,  record.febRate__c, '全社目標の2月の値が不正');
        system.assertEquals(3,  record.marRate__c, '全社目標の3月の値が不正');
        system.assertEquals(4,  record.aprRate__c, '全社目標の4月の値が不正');
        system.assertEquals(5,  record.mayRate__c, '全社目標の5月の値が不正');
        system.assertEquals(6,  record.junRate__c, '全社目標の6月の値が不正');
        system.assertEquals(7,  record.julRate__c, '全社目標の7月の値が不正');
        system.assertEquals(8,  record.augRate__c, '全社目標の8月の値が不正');
        system.assertEquals(9,  record.sepRate__c, '全社目標の9月の値が不正');
        system.assertEquals(10, record.octRate__c, '全社目標の10月の値が不正');
        system.assertEquals(11, record.novRate__c, '全社目標の11月の値が不正');
        system.assertEquals(34, record.decRate__c, '全社目標の12月の値が不正');
        system.assertNotEquals(companyGoal.SystemModStamp, record.SystemModStamp);

    }

    //店舗目標(反響)保存
    @isTest static void saveEchoShopGoalTest(){
        ShopGoal__c shopGoal = [SELECT Id, SystemModStamp FROM ShopGoal__c LIMIT 1];
        
        GEA01001Controller GEA010012Controller = new GEA01001Controller();//コンストラクタ起動

        Date toDay = Date.newInstance(2020, 1, 1);//現在の年を設定
        String targetYear = String.valueOf(toDay.year());//現在の年を設定
        GEA010012Controller.targetYear = targetYear;

        GEA010012Controller.setDisplay();

        //更新時間調整用に待機
        CommonUtil.sleep(1000);

        // 反響数の更新
        GEA010012Controller.displayShopGoalList[0].echoCountJan = '101';   // 1月
        GEA010012Controller.displayShopGoalList[0].echoCountFeb = '102';   // 2月
        GEA010012Controller.displayShopGoalList[0].echoCountMar = '103';   // 3月
        GEA010012Controller.displayShopGoalList[0].echoCountApr = '104';   // 4月
        GEA010012Controller.displayShopGoalList[0].echoCountMay = '105';   // 5月
        GEA010012Controller.displayShopGoalList[0].echoCountJun = '106';   // 6月
        GEA010012Controller.displayShopGoalList[0].echoCountJul = '107';   // 7月
        GEA010012Controller.displayShopGoalList[0].echoCountAug = '108';   // 8月
        GEA010012Controller.displayShopGoalList[0].echoCountSep = '109';   // 9月
        GEA010012Controller.displayShopGoalList[0].echoCountOct = '110';   // 10月
        GEA010012Controller.displayShopGoalList[0].echoCountNov = '111';   // 11月
        GEA010012Controller.displayShopGoalList[0].echoCountDec = '112';   // 12月

        //合計の計算
        GEA010012Controller.calculateShopGoalRateSum();
        GEA010012Controller.calculateShopGoalSales();

        //店舗目標(反響)
        GEA010012Controller.saveEchoShopGoal();

        //エラーが発生しないことを確認
        system.assertEquals(FALSE, GEA010012Controller.hasErrorMessage);

        // 更新確認
        ShopGoal__c savedShopGoalRecord = [ SELECT id,SystemModStamp
                                        , EchoCountJan__c
                                        , EchoCountFeb__c
                                        , EchoCountMar__c
                                        , EchoCountApr__c
                                        , EchoCountMay__c
                                        , EchoCountJun__c
                                        , EchoCountJul__c
                                        , EchoCountAug__c
                                        , EchoCountSep__c
                                        , EchoCountOct__c
                                        , EchoCountNov__c
                                        , EchoCountDec__c
                                        FROM ShopGoal__c
                                        WHERE id = :shopGoal.Id
                                        LIMIT 1];

        
        system.assertEquals(101,  savedShopGoalRecord.EchoCountJan__c, '店舗目標の反響数（1月）の値が不正');
        system.assertEquals(102,  savedShopGoalRecord.EchoCountFeb__c, '店舗目標の反響数（2月）の値が不正');
        system.assertEquals(103,  savedShopGoalRecord.EchoCountMar__c, '店舗目標の反響数（3月）の値が不正');
        system.assertEquals(104,  savedShopGoalRecord.EchoCountApr__c, '店舗目標の反響数（4月）の値が不正');
        system.assertEquals(105,  savedShopGoalRecord.EchoCountMay__c, '店舗目標の反響数（5月）の値が不正');
        system.assertEquals(106,  savedShopGoalRecord.EchoCountJun__c, '店舗目標の反響数（6月）の値が不正');
        system.assertEquals(107,  savedShopGoalRecord.EchoCountJul__c, '店舗目標の反響数（7月）の値が不正');
        system.assertEquals(108,  savedShopGoalRecord.EchoCountAug__c, '店舗目標の反響数（8月）の値が不正');
        system.assertEquals(109,  savedShopGoalRecord.EchoCountSep__c, '店舗目標の反響数（9月）の値が不正');
        system.assertEquals(110,  savedShopGoalRecord.EchoCountOct__c, '店舗目標の反響数（10月）の値が不正');
        system.assertEquals(111,  savedShopGoalRecord.EchoCountNov__c, '店舗目標の反響数（11月）の値が不正');
        system.assertEquals(112,  savedShopGoalRecord.EchoCountDec__c, '店舗目標の反響数（12月）の値が不正');
        system.assertNotEquals(shopGoal.SystemModStamp, savedShopGoalRecord.SystemModStamp);

    }

    //店舗目標(物確)保存
    @isTest static void savePropertyConfirmationShopGoalTest(){
        ShopGoal__c shopGoal = [SELECT Id, SystemModStamp FROM ShopGoal__c LIMIT 1];
        
        GEA01001Controller GEA010012Controller = new GEA01001Controller();//コンストラクタ起動

        Date toDay = Date.newInstance(2020, 1, 1);//現在の年を設定
        String targetYear = String.valueOf(toDay.year());//現在の年を設定
        GEA010012Controller.targetYear = targetYear;

        GEA010012Controller.setDisplay();

        // 物確数の更新
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountJan = '201';   // 1月
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountFeb = '202';   // 2月
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountMar = '203';   // 3月
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountApr = '204';   // 4月
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountMay = '205';   // 5月
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountJun = '206';   // 6月
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountJul = '207';   // 7月
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountAug = '208';   // 8月
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountSep = '209';   // 9月
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountOct = '210';   // 10月
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountNov = '211';   // 11月
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountDec = '212';   // 12月

        //更新時間調整用に待機
        CommonUtil.sleep(1000);

        //店舗目標表示切替
        GEA010012Controller.changeDisplayShopGoal();

        //店舗目標(物確)保存
        GEA010012Controller.savePropertyConfirmationShopGoal();

        //エラーが発生しないことを確認
        system.assertEquals(FALSE, GEA010012Controller.hasErrorMessage);

        // 更新確認
        ShopGoal__c savedShopGoalRecord = [ SELECT id,SystemModStamp
                                        , PropertyConfirmationCountJan__c
                                        , PropertyConfirmationCountFeb__c
                                        , PropertyConfirmationCountMar__c
                                        , PropertyConfirmationCountApr__c
                                        , PropertyConfirmationCountMay__c
                                        , PropertyConfirmationCountJun__c
                                        , PropertyConfirmationCountJul__c
                                        , PropertyConfirmationCountAug__c
                                        , PropertyConfirmationCountSep__c
                                        , PropertyConfirmationCountOct__c
                                        , PropertyConfirmationCountNov__c
                                        , PropertyConfirmationCountDec__c
                                        FROM ShopGoal__c
                                        WHERE id = :shopGoal.Id
                                        LIMIT 1];

        system.assertEquals(201,  savedShopGoalRecord.PropertyConfirmationCountJan__c, '店舗目標の物確数（1月）の値が不正');
        system.assertEquals(202,  savedShopGoalRecord.PropertyConfirmationCountFeb__c, '店舗目標の物確数（2月）の値が不正');
        system.assertEquals(203,  savedShopGoalRecord.PropertyConfirmationCountMar__c, '店舗目標の物確数（3月）の値が不正');
        system.assertEquals(204,  savedShopGoalRecord.PropertyConfirmationCountApr__c, '店舗目標の物確数（4月）の値が不正');
        system.assertEquals(205,  savedShopGoalRecord.PropertyConfirmationCountMay__c, '店舗目標の物確数（5月）の値が不正');
        system.assertEquals(206,  savedShopGoalRecord.PropertyConfirmationCountJun__c, '店舗目標の物確数（6月）の値が不正');
        system.assertEquals(207,  savedShopGoalRecord.PropertyConfirmationCountJul__c, '店舗目標の物確数（7月）の値が不正');
        system.assertEquals(208,  savedShopGoalRecord.PropertyConfirmationCountAug__c, '店舗目標の物確数（8月）の値が不正');
        system.assertEquals(209,  savedShopGoalRecord.PropertyConfirmationCountSep__c, '店舗目標の物確数（9月）の値が不正');
        system.assertEquals(210,  savedShopGoalRecord.PropertyConfirmationCountOct__c, '店舗目標の物確数（10月）の値が不正');
        system.assertEquals(211,  savedShopGoalRecord.PropertyConfirmationCountNov__c, '店舗目標の物確数（11月）の値が不正');
        system.assertEquals(212,  savedShopGoalRecord.PropertyConfirmationCountDec__c, '店舗目標の物確数（12月）の値が不正');
        system.assertNotEquals(shopGoal.SystemModStamp, savedShopGoalRecord.SystemModStamp);

    }
    //作成または表示：対象年なしエラー
    @isTest static void setDisplayErrorTest(){
        GEA01001Controller GEA010012Controller = new GEA01001Controller();//コンストラクタ起動

        //対象年をNULLにする
        GEA010012Controller.targetYear = null;

        GEA010012Controller.setDisplay();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GEA010012Controller.hasErrorMessage, TRUE);

        
        //入力チェック
        List<String> requiredItem = new List<String>();
        requiredItem.add('対象年');


        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));

        
    }
    //全社目標保存：入力チェックエラー
    @isTest static void saveCompanyGoalInputErrorTest(){
        CompanyGoal__c companyGoal = [SELECT Id, SystemModStamp FROM CompanyGoal__c LIMIT 1];
        
        GEA01001Controller GEA010012Controller = new GEA01001Controller();//コンストラクタ起動

        Date toDay = Date.newInstance(2020, 1, 1);//現在の年を設定
        String targetYear = String.valueOf(toDay.year());//現在の年を設定
        GEA010012Controller.targetYear = targetYear;

        GEA010012Controller.setDisplay();

        GEA010012Controller.displayCompanyGoal.applicantRate = null;//申込率
        GEA010012Controller.displayCompanyGoal.callRate = null;//呼込率
        GEA010012Controller.displayCompanyGoal.janRate = null;//1月
        GEA010012Controller.displayCompanyGoal.febRate = null;//2月
        GEA010012Controller.displayCompanyGoal.marRate = null;//3月
        GEA010012Controller.displayCompanyGoal.aprRate = null;//4月
        GEA010012Controller.displayCompanyGoal.mayRate = null;//5月
        GEA010012Controller.displayCompanyGoal.junRate = null;//6月
        GEA010012Controller.displayCompanyGoal.julRate = null;//7月
        GEA010012Controller.displayCompanyGoal.augRate = null;//8月
        GEA010012Controller.displayCompanyGoal.sepRate = null;//9月
        GEA010012Controller.displayCompanyGoal.octRate = null;//10月
        GEA010012Controller.displayCompanyGoal.novRate = null;//11月
        GEA010012Controller.displayCompanyGoal.decRate = null;//12月

        //全社目標保存
        GEA010012Controller.saveCompanyGoal();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GEA010012Controller.hasErrorMessage, TRUE);

        
        //入力チェック
        List<String> requiredItem = new List<String>();

        requiredItem.add('1月');
        requiredItem.add('2月');
        requiredItem.add('3月');
        requiredItem.add('4月');
        requiredItem.add('5月');
        requiredItem.add('6月');
        requiredItem.add('7月');
        requiredItem.add('8月');
        requiredItem.add('9月');
        requiredItem.add('10月');
        requiredItem.add('11月');
        requiredItem.add('12月');
        requiredItem.add('ISの呼込率(%)');
        requiredItem.add('全体の申込率(%)');


        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, '月別反響目標割合の' + String.join(requiredItem, ',')));

    }
    //全社目標保存：月別反響目標割合エラー
    @isTest static void saveCompanyGoalSumErrorTest(){
        CompanyGoal__c companyGoal = [SELECT Id, SystemModStamp FROM CompanyGoal__c LIMIT 1];
        
        GEA01001Controller GEA010012Controller = new GEA01001Controller();//コンストラクタ起動

        Date toDay = Date.newInstance(2020, 1, 1);//現在の年を設定
        String targetYear = String.valueOf(toDay.year());//現在の年を設定
        GEA010012Controller.targetYear = targetYear;

        GEA010012Controller.setDisplay();

        GEA010012Controller.displayCompanyGoal.applicantRate = '10';//申込率
        GEA010012Controller.displayCompanyGoal.callRate = '10';//呼込率

        //合計を100%以外に設定
        GEA010012Controller.displayCompanyGoal.janRate = '0';//1月
        GEA010012Controller.displayCompanyGoal.febRate = '10';//2月
        GEA010012Controller.displayCompanyGoal.marRate = '10';//3月
        GEA010012Controller.displayCompanyGoal.aprRate = '10';//4月
        GEA010012Controller.displayCompanyGoal.mayRate = '10';//5月
        GEA010012Controller.displayCompanyGoal.junRate = '10';//6月
        GEA010012Controller.displayCompanyGoal.julRate = '10';//7月
        GEA010012Controller.displayCompanyGoal.augRate = '10';//8月
        GEA010012Controller.displayCompanyGoal.sepRate = '10';//9月
        GEA010012Controller.displayCompanyGoal.octRate = '4';//10月
        GEA010012Controller.displayCompanyGoal.novRate = '5';//11月
        GEA010012Controller.displayCompanyGoal.decRate = '1';//12月

        //合計の計算
        GEA010012Controller.calcCompanyGoalRateSum();

        //全社目標保存
        GEA010012Controller.saveCompanyGoal();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GEA010012Controller.hasErrorMessage, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_TOTAL_RATE, '月別反響目標割合'));


    }
    //全社目標保存：楽観ロックチェックエラー
    @isTest static void saveCompanyGoalOptimisticLockExceptionErrorTest(){
        CompanyGoal__c companyGoal = [SELECT Id, SystemModStamp FROM CompanyGoal__c LIMIT 1];
        
        GEA01001Controller GEA010012Controller = new GEA01001Controller();//コンストラクタ起動

        Date toDay = Date.newInstance(2020, 1, 1);//現在の年を設定
        String targetYear = String.valueOf(toDay.year());//現在の年を設定
        GEA010012Controller.targetYear = targetYear;

        GEA010012Controller.setDisplay();

        //更新時間調整用に待機
        CommonUtil.sleep(1000);

        //別処理内で保存
        upsert companyGoal;

        GEA010012Controller.displayCompanyGoal.applicantRate = '10';//申込率
        GEA010012Controller.displayCompanyGoal.callRate = '10';//呼込率
        //合計100%を設定
        GEA010012Controller.displayCompanyGoal.janRate = '10';//1月
        GEA010012Controller.displayCompanyGoal.febRate = '10';//2月
        GEA010012Controller.displayCompanyGoal.marRate = '10';//3月
        GEA010012Controller.displayCompanyGoal.aprRate = '10';//4月
        GEA010012Controller.displayCompanyGoal.mayRate = '10';//5月
        GEA010012Controller.displayCompanyGoal.junRate = '10';//6月
        GEA010012Controller.displayCompanyGoal.julRate = '10';//7月
        GEA010012Controller.displayCompanyGoal.augRate = '10';//8月
        GEA010012Controller.displayCompanyGoal.sepRate = '10';//9月
        GEA010012Controller.displayCompanyGoal.octRate = '4';//10月
        GEA010012Controller.displayCompanyGoal.novRate = '5';//11月
        GEA010012Controller.displayCompanyGoal.decRate = '1';//12月

        //合計の計算
        GEA010012Controller.calcCompanyGoalRateSum();

        //全社目標保存
        GEA010012Controller.saveCompanyGoal();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GEA010012Controller.hasErrorMessage, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));


    }
    //店舗目標(反響)保存：入力チェックエラー
    @isTest static void saveEchoShopGoalInputErrorTest(){
        ShopGoal__c shopGoal = [SELECT Id, SystemModStamp FROM ShopGoal__c LIMIT 1];
        
        GEA01001Controller GEA010012Controller = new GEA01001Controller();//コンストラクタ起動

        Date toDay = Date.newInstance(2020, 1, 1);//現在の年を設定
        String targetYear = String.valueOf(toDay.year());//現在の年を設定
        GEA010012Controller.targetYear = targetYear;

        GEA010012Controller.setDisplay();

        //更新時間調整用に待機
        CommonUtil.sleep(1000);

        GEA010012Controller.displayShopGoalList[0].salesGoal  = null;//売上目標
        GEA010012Controller.displayShopGoalList[0].averageUnitPrice  = null;//平均単価
        GEA010012Controller.displayShopGoalList[0].echoCountGoal  = null;//反響数（目標）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountGoal  = null;//物確数（目標）
        GEA010012Controller.displayShopGoalList[0].echoCountJan  = null;//反響数（1月）
        GEA010012Controller.displayShopGoalList[0].echoCountFeb  = null;//反響数（2月）
        GEA010012Controller.displayShopGoalList[0].echoCountMar  = null;//反響数（3月）
        GEA010012Controller.displayShopGoalList[0].echoCountApr  = null;//反響数（4月）
        GEA010012Controller.displayShopGoalList[0].echoCountMay  = null;//反響数（5月）
        GEA010012Controller.displayShopGoalList[0].echoCountJun  = null;//反響数（6月）
        GEA010012Controller.displayShopGoalList[0].echoCountJul  = null;//反響数（7月）
        GEA010012Controller.displayShopGoalList[0].echoCountAug  = null;//反響数（8月）
        GEA010012Controller.displayShopGoalList[0].echoCountSep  = null;//反響数（9月）
        GEA010012Controller.displayShopGoalList[0].echoCountOct  = null;//反響数（10月）
        GEA010012Controller.displayShopGoalList[0].echoCountNov  = null;//反響数（11月）
        GEA010012Controller.displayShopGoalList[0].echoCountDec  = null;//反響数（12月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountJan  = null;//物確数（1月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountFeb  = null;//物確数（2月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountMar  = null;//物確数（3月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountApr  = null;//物確数（4月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountMay  = null;//物確数（5月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountJun  = null;//物確数（6月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountJul  = null;//物確数（7月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountAug  = null;//物確数（8月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountSep  = null;//物確数（9月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountOct  = null;//物確数（10月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountNov  = null;//物確数（11月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountDec  = null;//物確数（12月）

        //店舗目標(反響)
        GEA010012Controller.saveEchoShopGoal();


        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GEA010012Controller.hasErrorMessage, TRUE);

        
        //入力チェック
        List<String> requiredItem = new List<String>();

        requiredItem.add('平均単価');
        requiredItem.add('呼込数');


        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));


    }
    //店舗目標(反響)保存：楽観ロックチェックエラー
    @isTest static void saveEchoShopGoalOptimisticLockExceptionErrorTest(){
        ShopGoal__c shopGoal = [SELECT Id, SystemModStamp FROM ShopGoal__c LIMIT 1];
        
        GEA01001Controller GEA010012Controller = new GEA01001Controller();//コンストラクタ起動

        Date toDay = Date.newInstance(2020, 1, 1);//現在の年を設定
        String targetYear = String.valueOf(toDay.year());//現在の年を設定
        GEA010012Controller.targetYear = targetYear;

        GEA010012Controller.setDisplay();

        //更新時間調整用に待機
        CommonUtil.sleep(1000);

        //別処理内で保存
        upsert shopGoal;

        //店舗目標(反響)
        GEA010012Controller.saveEchoShopGoal();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GEA010012Controller.hasErrorMessage, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));


    }
    //店舗目標(物確)保存：入力チェックエラー
    @isTest static void savePropertyConfirmationShopGoalInputErrorTest(){
        ShopGoal__c shopGoal = [SELECT Id, SystemModStamp FROM ShopGoal__c LIMIT 1];
        
        GEA01001Controller GEA010012Controller = new GEA01001Controller();//コンストラクタ起動

        Date toDay = Date.newInstance(2020, 1, 1);//現在の年を設定
        String targetYear = String.valueOf(toDay.year());//現在の年を設定
        GEA010012Controller.targetYear = targetYear;

        GEA010012Controller.setDisplay();

        //更新時間調整用に待機
        CommonUtil.sleep(1000);

        GEA010012Controller.displayShopGoalList[0].salesGoal  = null;//売上目標
        GEA010012Controller.displayShopGoalList[0].averageUnitPrice  = null;//平均単価
        GEA010012Controller.displayShopGoalList[0].echoCountGoal  = null;//反響数（目標）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountGoal  = null;//物確数（目標）
        GEA010012Controller.displayShopGoalList[0].echoCountJan  = null;//反響数（1月）
        GEA010012Controller.displayShopGoalList[0].echoCountFeb  = null;//反響数（2月）
        GEA010012Controller.displayShopGoalList[0].echoCountMar  = null;//反響数（3月）
        GEA010012Controller.displayShopGoalList[0].echoCountApr  = null;//反響数（4月）
        GEA010012Controller.displayShopGoalList[0].echoCountMay  = null;//反響数（5月）
        GEA010012Controller.displayShopGoalList[0].echoCountJun  = null;//反響数（6月）
        GEA010012Controller.displayShopGoalList[0].echoCountJul  = null;//反響数（7月）
        GEA010012Controller.displayShopGoalList[0].echoCountAug  = null;//反響数（8月）
        GEA010012Controller.displayShopGoalList[0].echoCountSep  = null;//反響数（9月）
        GEA010012Controller.displayShopGoalList[0].echoCountOct  = null;//反響数（10月）
        GEA010012Controller.displayShopGoalList[0].echoCountNov  = null;//反響数（11月）
        GEA010012Controller.displayShopGoalList[0].echoCountDec  = null;//反響数（12月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountJan  = null;//物確数（1月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountFeb  = null;//物確数（2月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountMar  = null;//物確数（3月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountApr  = null;//物確数（4月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountMay  = null;//物確数（5月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountJun  = null;//物確数（6月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountJul  = null;//物確数（7月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountAug  = null;//物確数（8月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountSep  = null;//物確数（9月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountOct  = null;//物確数（10月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountNov  = null;//物確数（11月）
        GEA010012Controller.displayShopGoalList[0].propertyConfirmationCountDec  = null;//物確数（12月）

        //店舗目標(物確)
        GEA010012Controller.savePropertyConfirmationShopGoal();


        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GEA010012Controller.hasErrorMessage, TRUE);

        
        //入力チェック
        List<String> requiredItem = new List<String>();

        requiredItem.add('物確数（目標）');


        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_REQUIRED, String.join(requiredItem, ',')));


    }
    //店舗目標(物確)保存：楽観ロックチェックエラー
    @isTest static void savePropertyConfirmationShopGoalOptimisticLockExceptionErrorTest(){
        ShopGoal__c shopGoal = [SELECT Id, SystemModStamp FROM ShopGoal__c LIMIT 1];
        
        GEA01001Controller GEA010012Controller = new GEA01001Controller();//コンストラクタ起動

        Date toDay = Date.newInstance(2020, 1, 1);//現在の年を設定
        String targetYear = String.valueOf(toDay.year());//現在の年を設定
        GEA010012Controller.targetYear = targetYear;

        GEA010012Controller.setDisplay();

        //更新時間調整用に待機
        CommonUtil.sleep(1000);

        //別処理内で保存
        upsert shopGoal;

        //店舗目標(物確)
        GEA010012Controller.savePropertyConfirmationShopGoal();

        //「エラーフラグ」がTRUEに設定されている？
        system.assertEquals(GEA010012Controller.hasErrorMessage, TRUE);

        //「エラーメッセージ」が正しく設定されている？
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));


    }
}