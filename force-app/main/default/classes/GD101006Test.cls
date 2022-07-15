/**
 * @File Name          : GD101006Test.cls
 * @Description        : 業者名寄せ比較画面のテスト
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 2020/3/27 14:30:00
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2020/3/19   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
private class GD101006Test {

    //***************************************************** テストデータ作成用メソッド *****************************************************************

    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //システム設定
        SystemConfig__c s = new SystemConfig__c(SupplierMerge_PropertyUpdateMaxCount__c = 50); //業者名寄せ物件更新数
        s.SupplierMerge_BuildingMaxCount__c = 50; //業者名寄せ_建物最大件数
        insert s;

        //取引先レコード
        Account leftAccount = new Account(Name = '左業者',
                                            RecordTypeId =CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER),
                                            MaintenanceSupplierCode__c = '左',
                                            NameKana__c = 'ヒダリギョウシャ',
                                            PostalCode__c = '012-3456',
                                            State__c = '愛知県',
                                            City__c = '名古屋市港区',
                                            Street__c = '1-2',
                                            Phone = '01234567890',
                                            Fax = '05211112222',
                                            Email__c = 'test@co.jp',
                                            Introduction__c = '設定なし',
                                            IppamGyobutsu__c = '一般物',
                                            FixedTermSend__c = '有',
                                            RenewalFeeShow__c = '更新料',
                                            CleaningFeeShow__c = '定額補修費',
                                            GuarantorAgencyCompanyType__c = 'その他',
                                            RemarksPublic__c = '業者名寄せテスト',
                                            RemarksPrivate__c = '業者名寄せテスト実行',
                                            Representative__c = '名寄史益',
                                            RepresentativeDepartment__c = 'テスト',
                                            RepresentativePhone__c = '08012345678',
                                            DembutsuDate__c = Date.newInstance(2020, 3, 1),
                                            DembutsuStatus__c = '○',
                                            DembutsuStaff__c = '電物須瑠与',
                                            DembutsuEventMemo__c = '完了');
        insert leftAccount;
        //スリープ
        CommonUtil.sleep(1000);

        Account rightAccount = new Account(Name = '右業者',
                                             RecordTypeId =CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_SUPPLIER),
                                             MaintenanceSupplierCode__c = '右',
                                             NameKana__c = 'ミギギョウシャ',
                                             PostalCode__c = '012-3456',
                                             State__c = '愛知県',
                                             Phone = '01234567890',
                                             Fax = '05211112222',
                                             Email__c = 'test@co.jp',
                                             Introduction__c = '設定なし',
                                             IppamGyobutsu__c = '一般物',
                                             FixedTermSend__c = '有',
                                             RenewalFeeShow__c = '更新料',
                                             CleaningFeeShow__c = '定額補修費',
                                             GuarantorAgencyCompanyType__c = 'その他',
                                             RemarksPublic__c = '業者名寄せテスト',
                                             RemarksPrivate__c = '業者名寄せテスト実行',
                                             Representative__c = '名寄史益',
                                             RepresentativeDepartment__c = 'テスト',
                                             RepresentativePhone__c = '08012345678',
                                             DembutsuDate__c = Date.newInstance(2020, 3, 1),
                                             DembutsuStatus__c = '○',
                                             DembutsuStaff__c = '電物須瑠与',
                                             DembutsuEventMemo__c = '完了');  
        insert rightAccount;

        //保証会社用取引先   
        Account guarAccount = new Account(Name = '保証用取引先',
                                          RecordTypeId =CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_GUARANTEE));
        //火災保険会社用取引先   
        Account fireAccount = new Account(Name = '火災保険会社用取引先',
                                          RecordTypeId =CommonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_FIRE_INSURANCE));
        List<Account> accountList = new List<Account> {guarAccount,fireAccount};
        insert accountList;


        //商品レコード
        Item__c leftGuar = new Item__c(//左(保証会社)
                                       Account__c = guarAccount.id,
                                       ItemName__c = '左保証',
                                       AssuranceContent__c = '左保証内容',
                                       Remarks__c = '左保証備考',
                                       RecordTypeId =CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_GUARANTEE_PLAN));
        Item__c rightFire = new Item__c(//右(火災保険会社)
                                       Account__c = fireAccount.id,
                                       ItemName__c = '右火災保険',
                                       FireInsurance__c = '右保険内容',
                                       Remarks__c = '右保証備考(火災)',
                                       RecordTypeId = CommonUtil.getRecordTypeId('Item__c', commonConst.ITEM_RECTYPE_FIRE_INSURANCE));
        List<Item__c> itemList = new List<Item__c> {leftGuar,rightFire};
        insert itemList;


        //取引先保険保証レコード
        InsuranceGuarantee__c leftIG = new InsuranceGuarantee__c(//左(保証)
                                                                 Account__c = leftAccount.id,//取引先
                                                                 Item__c = leftGuar.id,//商品
                                                                 RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', commonConst.INSURANCE_RECTYPE_GUARANTEE_GUARANTEE));//レコードタイプ
        InsuranceGuarantee__c rightIG = new InsuranceGuarantee__c(//右(火災)
                                                                 Account__c = rightAccount.id,//取引先
                                                                 Item__c = rightFire.id,//商品
                                                                 RecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', commonConst.INSURANCE_RECTYPE_GUARANTEE_FIREINSURANCE));//レコードタイプ                                                         
        List<InsuranceGuarantee__c> igList = new List<InsuranceGuarantee__c> {leftIG,rightIG};
        insert igList;


        //管理会社指定指定商品レコード
        ManagementCompanyItem__c leftMCI = new ManagementCompanyItem__c(//左
                                                                        Account__c = leftAccount.id,//取引先
                                                                        ItemName__c = '左管理会社指定商品',//名前
                                                                        Amount__c = 5000,//金額
                                                                        TaxType__c = '課税');//税区分
        ManagementCompanyItem__c rightMCI = new ManagementCompanyItem__c(//右
                                                                         Account__c = rightAccount.id,//取引先
                                                                         ItemName__c = '右管理会社指定商品',//名前
                                                                         Amount__c = 4000,//金額
                                                                         TaxType__c = '非課税');//税区分                                                                 
        List<ManagementCompanyItem__c> MCIList = new List<ManagementCompanyItem__c> {leftMCI,rightMCI};
        insert MCIList;

        //建物レコード
        Building__c leftBuilding = new Building__c(//左
                                                     Name = '左建物',
                                                     District__c = '名東区',
                                                     State__c = '愛知県',
                                                     City__c = '名古屋市業者名寄せ比較町',                                                     
                                                     Street__c = '1-1');
        Building__c rightBuilding = new Building__c(//右
                                                     Name = '右建物',
                                                     District__c = '天白区',
                                                     State__c = '愛知県',
                                                     City__c = '名古屋市業者名寄せ比較町',                                                     
                                                     Street__c = '1-1');  
        List<Building__c> buildingList = new List<Building__c> {leftBuilding,rightBuilding};
        insert buildingList;                                                                                        
        
        //物件レコード
        Property__c leftPro = new Property__c(//左
                                              Name = '左物件',//名前
                                              building__c = leftBuilding.id,//建物
                                              FormerSupplier__c=leftAccount.id//元付業者
                                              );
        Property__c rightPro = new Property__c(//右
                                               Name = '右物件',//名前
                                               building__c = rightBuilding.id,//建物
                                               FormerSupplier__c=rightAccount.id//元付業者
                                               );
        List<Property__c> propertyList = new List<Property__c> {leftPro,rightPro};
        insert propertyList;


        //物件管理会社指定指定商品レコード(2020.05.11追加)
        PropertyManageCompayItem__c leftPMCI = new PropertyManageCompayItem__c(//左
                                                                        Account__c = leftAccount.id,//管理会社
                                                                        Item__c = leftMCI.Id,//管理会社指定プラン
                                                                        Property__c = leftPro.Id);//物件                                                                        
        PropertyManageCompayItem__c rightPMCI = new PropertyManageCompayItem__c(//右
                                                                        Account__c = rightAccount.id,//管理会社
                                                                        Item__c = rightMCI.Id,//管理会社指定プラン
                                                                        Property__c = rightPro.Id);//物件                                                               
        List<PropertyManageCompayItem__c> PMCIList = new List<PropertyManageCompayItem__c> {leftPMCI,rightPMCI};
        insert PMCIList;        

    }

    //***************************************************** テストメソッド *****************************************************************

    //初期表示テスト	
    @isTest static void initializeTest(){

        //テストデータ取得
        Account acc1 = [SELECT Id FROM Account WHERE Name = '左業者'];
        Account acc2 = [SELECT Id FROM Account WHERE Name = '右業者'];

        //パラメータ設定
        PageReference pageRef = Page.GD101006View;
        pageRef.getParameters().put('id1', acc1.Id);
        pageRef.getParameters().put('id2', acc2.Id);

        Test.setCurrentPage(pageRef);
        //コンストラクタ起動
        GD101006Controller testController = new GD101006Controller();

        //テスト結果確認
        System.assertEquals('左業者', testController.leftAccount.Name);
    }

    // 初期表示テスト(異常)
    @isTest static void parameterErrorTest(){

        //テストデータ取得
        Account acc1 = [SELECT Id FROM Account WHERE Name = '左業者'];
        Account acc2 = [SELECT Id FROM Account WHERE Name = '右業者'];

        //パラメータ設定
        PageReference pageRef = Page.GD101006View;
        pageRef.getParameters().put('id1', acc1.Id + '1');
        pageRef.getParameters().put('id2', acc2.Id + '1');

        Test.setCurrentPage(pageRef);
        //コンストラクタ起動
        GD101006Controller testController = new GD101006Controller();

        //テスト結果確認
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)));
    }

    // 登録ボタン押下処理（左に寄せる）
    @isTest static void leftMergeTest(){

        //テストデータ取得
        Account acc1 = [SELECT Id FROM Account WHERE Name = '左業者'];
        Account acc2 = [SELECT Id FROM Account WHERE Name = '右業者'];

        //パラメータ設定
        PageReference pageRef = Page.GD101006View;
        pageRef.getParameters().put('id1', acc1.Id);
        pageRef.getParameters().put('id2', acc2.Id);

        Test.setCurrentPage(pageRef);
        //コンストラクタ起動
        GD101006Controller testController = new GD101006Controller();

        //画面でエラーが起きていないか確認
        //List<ApexPages.Message> messages = ApexPages.getMessages();
        //System.debug('画面のエラー：' + messages[0].getDetail());

        //メンテナンス情報を右、基本情報を左に名寄せ
        testController.MaintenanceRadioButton= '右';
        testController.BasicInfoRadioButton= '左';
        testController.save();

        //テスト結果確認
        Account resultLeft = [SELECT Id,Name,MaintenanceSupplierCode__c FROM Account WHERE Id = :acc1.Id];
        List<Account> resultRight = [SELECT Id,Name,MaintenanceSupplierCode__c FROM Account WHERE Id = :acc2.Id];

        //名前は「左業者」のまま
        System.assertEquals( resultLeft.Name, '左業者');
        //右業者は取得できない（削除されているため）
        System.assertEquals( resultRight.size(), 0);

        //メンテナンス物件コードが「右」に更新されている
        System.assertEquals( resultLeft.MaintenanceSupplierCode__c, '右');
    }

    // 登録ボタン押下処理（右に寄せる）
    @isTest static void rightMergeTest(){

        //テストデータ取得
        Account acc1 = [SELECT Id FROM Account WHERE Name = '左業者'];
        Account acc2 = [SELECT Id FROM Account WHERE Name = '右業者'];

        //パラメータ設定
        PageReference pageRef = Page.GD101006View;
        pageRef.getParameters().put('id1', acc1.Id);
        pageRef.getParameters().put('id2', acc2.Id);

        Test.setCurrentPage(pageRef);
        //コンストラクタ起動
        GD101006Controller testController = new GD101006Controller();

        //メンテナンス情報を左、基本情報を右に名寄せ
        testController.MaintenanceRadioButton= '左';
        testController.BasicInfoRadioButton= '右';
        testController.save();

        //テスト結果確認
        Account resultRight = [SELECT Id,Name,MaintenanceSupplierCode__c FROM Account WHERE Id = :acc2.Id];
        List<Account> resultLeft = [SELECT Id,Name,MaintenanceSupplierCode__c FROM Account WHERE Id = :acc1.Id];

        //名前は「右業者」のまま
        System.assertEquals( resultRight.Name, '右業者');
        //左業者は取得できない（削除されているため）
        System.assertEquals( resultLeft.size(), 0);

        //メンテナンス物件コードが「左」に更新されている
        System.assertEquals( resultRight.MaintenanceSupplierCode__c, '左');
    }

    // 登録ボタン押下処理（楽観ロックチェック）
    @isTest static void optimisticLockSaveErrorTest(){

        //テストデータ取得
        Account acc1 = [SELECT Id FROM Account WHERE Name = '左業者'];
        Account acc2 = [SELECT Id FROM Account WHERE Name = '右業者'];

        //パラメータ設定
        PageReference pageRef = Page.GD101006View;
        pageRef.getParameters().put('id1', acc1.Id);
        pageRef.getParameters().put('id2', acc2.Id);

        Test.setCurrentPage(pageRef);
        //コンストラクタ起動
        GD101006Controller testController = new GD101006Controller();

        update acc1;
        //スリープ
        CommonUtil.sleep(1000);
        //更新
        testController.save();

        //テスト結果確認
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)));
    }

    //2020.05.06追加（業者名寄せCPU対策）
    //物件レコードが「業者名寄せ物件更新数」より多い場合
    @isTest static void PropertyUpdateMaxCountTest(){
        //テストデータ取得
        Integer propertyUpdateMaxCount = Integer.valueOf(SystemConfig__c.getInstance().SupplierMerge_PropertyUpdateMaxCount__c);//業者名寄せ物件更新数
        Account acc1 = [SELECT Id FROM Account WHERE Name = '左業者'];
        Account acc2 = [SELECT Id FROM Account WHERE Name = '右業者'];
        Building__c leftBuilding = [SELECT Id FROM Building__c WHERE Name = '左建物'];

        //物件レコードを「業者名寄せ物件更新数」分登録
        List<Property__c> propertyList = new List<Property__c>();
            for(Integer i=1 ; i <= propertyUpdateMaxCount; i++){
                Property__c leftPro = new Property__c(//左
                Name = '左物件',//名前
                building__c = leftBuilding.id,//建物
                FormerSupplier__c=acc1.id//元付業者
                );

                propertyList.add(leftPro);
            }

        insert propertyList;   

        //パラメータ設定
        PageReference pageRef = Page.GD101006View;
        pageRef.getParameters().put('id1', acc1.Id);
        pageRef.getParameters().put('id2', acc2.Id);

        Test.setCurrentPage(pageRef);
        //コンストラクタ起動
        GD101006Controller testController = new GD101006Controller();

        //メンテナンス情報を左、基本情報を右に名寄せ
        testController.MaintenanceRadioButton= '左';
        testController.BasicInfoRadioButton= '右';
        testController.save();

        //テスト結果確認
        Account resultRight = [SELECT Id,Name,MaintenanceSupplierCode__c FROM Account WHERE Id = :acc2.Id];
        Account resultLeft = [SELECT Id,Name,MaintenanceSupplierCode__c FROM Account WHERE Id = :acc1.Id];

        //名前は「右業者」のまま
        System.assertEquals( resultRight.Name, '右業者');
        //左業者が削除されていない
        System.assertEquals( resultLeft.Name, '左業者');

        //メンテナンス物件コードが更新されていない
        System.assertEquals( resultRight.MaintenanceSupplierCode__c, '右');
    }


    //カバレッジ率向上用（テスト仕様書はなし）
    @isTest static void callTest(){

        //テストデータ取得
        Account acc1 = [SELECT Id FROM Account WHERE Name = '左業者'];
        Account acc2 = [SELECT Id FROM Account WHERE Name = '右業者'];

        //パラメータ設定
        PageReference pageRef = Page.GD101006View;
        pageRef.getParameters().put('id1', acc1.Id);
        pageRef.getParameters().put('id2', acc2.Id);

        Test.setCurrentPage(pageRef);
        //コンストラクタ起動
        GD101006Controller testController = new GD101006Controller();

        //ラジオボタン設定
        testController.getMaintenanceRadioButtonSetting();
        testController.getBasicInfoRadioButtonSetting();

        //パブリック変数の呼び出し
        String s = testController.MSG_COM_V_EXECUTE_MERGE;
        s = testController.MSG_COM_I_MERGE_END;
    }
}