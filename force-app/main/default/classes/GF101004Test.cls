/* *
 * 保証プラン登録画面のテストクラス
 */
@isTest
private class GF101004Test {

    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        //レコードタイプID取得
        ID testAccountRecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_GUARANTEE);
        ID testItemRecordTypeId = CommonUtil.getRecordTypeId('Item__c', CommonConst.ITEM_RECTYPE_GUARANTEE_PLAN);

        Account testAccount = new Account( Name = '保証会社名A'                   //保証会社名
                                         , PostalCode__c = '000-000'              //郵便番号
                                         , State__c = '大阪府'                    //都道府県
                                         , City__c = '大阪市中央区'               //市区町村
                                         , Street__c = '1丁目'                    //丁目・番地
                                         , Phone = '0000000000'                   //電話番号
                                         , Fax = '0000000000'                     //FAX
                                         , Email__c = 'sample@example.com'        //メールアドレス
                                         , isAllRentFeeType__c = TRUE             //総賃料区分
                                         , RemarksPublic__c = '備考備考備考'       //備考（公開）
                                         , RecordTypeId = testAccountRecordTypeId //レコードタイプ
                                         );
        insert testAccount;

        //上記保証会社に紐づく商品レコード追加
        Item__c testItem = new Item__c( ItemName__c = '保証プランA'              //保証プラン名
                                      , AssuranceContent__c = '保証プラン内容A'  //保証プラン内容
                                      , Remarks__c = '保証内容A備考'             //保証内容備考
                                      , IsAuxiliary__c = TRUE                   //付帯商品区分
                                      , RentFeeRate__c = 10                     //賃料割合（保証会社）
                                      , DirectDebitFee__c = 1000                //手数料
                                      , DirectDebitFeeTaxType__c = '課税'       //手数料税区分
                                      , Account__c = testAccount.Id             //レコードID（取引先）
                                      , RecordTypeId = testItemRecordTypeId     //レコードタイプ
                                      );
        insert testItem;

        //上記保証プランに紐づく商品明細レコードを追加
        ItemDetail__c testItemDetail = new ItemDetail__c( PlanDetail__c = '保証プラン明細A'         //保証プラン明細
                                                        , IsRentFeeType__c = TRUE                  //賃料区分
                                                        , FirstFeeDepositRate__c = 10              //初回保証料(%)
                                                        , FirstFeeDepositYen__c = null             //初回保証料(円)
                                                        , DepositRate__c = 10                      //月額保証料(%)
                                                        , DepositYen__c = null                     //月額保証料(円)
                                                        , DepositRemarks__c = '保証プラン明細A備考' //備考
                                                        , Item__c = testItem.Id                    //レコードID（商品）
        );
        insert testItemDetail;
    }

    //初期表示テスト(新規)
    @isTest static void newInintializeTest(){
        Account testAccout = [SELECT Id FROM Account WHERE Name = '保証会社名A'];

        //パラメータ設定
        PageReference pageRef = Page.GF101004View;
        pageRef.getParameters().put('AccountId',testAccout.Id );
        Test.setCurrentPage(pageRef);

        //パラメータありでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //対象取引先にレコードが格納されていることを確認
        system.assert(testController.targetAccountRecord != null, 'error:対象取引先レコードがない');

    }


    //初期表示テスト(既存)
    @isTest static void initializeTest(){

        Account testAccout = [SELECT Id FROM Account WHERE Name = '保証会社名A'];
        Item__c testItem = [SELECT Id FROM Item__c WHERE ItemName__c = '保証プランA'];

        //パラメータ設定
        PageReference pageRef = Page.GF101004View;
        pageRef.getParameters().put('AccountId',testAccout.Id );
        pageRef.getParameters().put('Id',testItem.Id );
        Test.setCurrentPage(pageRef);

        //パラメータありでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //対象取引先にレコードが格納されていることを確認
        system.assert(testController.targetItemId != null, 'error:対象商品レコードがない');
    }


    //初期表示エラーテスト(パラメータなし)
    @isTest static void initializeNonParameterErrorTest(){

        //パラメータなしでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //レコード情報が取得できないときのエラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)), messages[0]);
        
    }


    //初期表示エラーテスト(取引先IDパラメータ不正)
    @isTest static void initializeAccountIdParameterErrorTest(){
        //パラメータ設定
        PageReference pageRef = Page.GF101004View;
        pageRef.getParameters().put('AccountId', '1060T0000023JEAQA2' );
        Test.setCurrentPage(pageRef);

        //パラメータありでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //レコード情報が取得できないときのエラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)), messages[0]);
    }


    //初期表示エラーテスト(商品IDパラメータ不正)
    @isTest static void initializeIdParameterErrorTest(){

        Account testAccout = [SELECT Id FROM Account WHERE Name = '保証会社名A'];

        //パラメータ設定
        PageReference pageRef = Page.GF101004View;
        pageRef.getParameters().put('AccountId',testAccout.Id );
        pageRef.getParameters().put('Id', '1060T0000023JEAQA2' );
        Test.setCurrentPage(pageRef);

        //パラメータありでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //レコード情報が取得できないときのエラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER)), messages[0]);
    }


    //保存テスト
    @isTest static void saveTest(){

        Account testAccout = [SELECT Id FROM Account WHERE Name = '保証会社名A'];
        Item__c testItem = [SELECT Id, systemModStamp FROM Item__c WHERE ItemName__c = '保証プランA'];

        //パラメータ設定
        PageReference pageRef = Page.GF101004View;
        pageRef.getParameters().put('AccountId',testAccout.Id );
        pageRef.getParameters().put('Id',testItem.Id );
        Test.setCurrentPage(pageRef);

        //パラメータありでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //スリープ
        CommonUtil.sleep(1000);

        //保存処理起動
        testController.targetRecordSave();

        //保存後商品レコード
        Item__c saveItem = [SELECT Id, SystemModStamp FROM Item__c WHERE Id = :testItem.Id];

        //更新日時確認
        system.assert(testItem.systemModStamp != saveItem.systemModStamp, 'errror:更新日時が変わっていない');

    }


    //保存エラーテスト
    @isTest static void saveErrorTest(){

        Account testAccout = [SELECT Id FROM Account WHERE Name = '保証会社名A'];
        Item__c testItem = [SELECT Id, systemModStamp FROM Item__c WHERE ItemName__c = '保証プランA'];

        //パラメータ設定
        PageReference pageRef = Page.GF101004View;
        pageRef.getParameters().put('AccountId',testAccout.Id );
        pageRef.getParameters().put('Id',testItem.Id );
        Test.setCurrentPage(pageRef);

        //パラメータありでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //スリープ
        CommonUtil.sleep(1000);
       
        //保存前に更新
        testItem.ItemName__c = 'koushin';
        update testItem;

        //スリープ
        CommonUtil.sleep(1000);

        //保存処理起動
        testController.targetRecordSave();

        //保存後商品レコード
        Item__c saveItem = [SELECT Id, SystemModStamp FROM Item__c WHERE Id = :testItem.Id];

        //楽観ロックチェックエラー？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK)), messages[0]);

    }


    //商品明細チェック→削除テスト
    @isTest static void checboxDeleteTest(){

        Account testAccout = [SELECT Id FROM Account WHERE Name = '保証会社名A'];
        Item__c testItem = [SELECT Id FROM Item__c WHERE ItemName__c = '保証プランA'];
        ItemDetail__c testItemDetail = [SELECT Id FROM ItemDetail__c WHERE PlanDetail__c = '保証プラン明細A'];

        //パラメータ設定
        PageReference pageRef = Page.GF101004View;
        pageRef.getParameters().put('AccountId',testAccout.Id );
        pageRef.getParameters().put('Id',testItem.Id );
        Test.setCurrentPage(pageRef);

        //パラメータありでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //チェックボックスをONにする
        testController.screenItemDetailList[0].isItemDetailCheck = TRUE;

        //チェックボックスONのレコードを明細行から削除
        testController.targetItemDetailRecordDelete();

        system.assert(testController.screenItemDetailList.isEmpty(), 'error:商品明細行が空ではない');
    }


    //商品レコード削除テスト
    @isTest static void itemDeleteTest(){

        Account testAccout = [SELECT Id FROM Account WHERE Name = '保証会社名A'];
        Item__c testItem = [SELECT Id FROM Item__c WHERE ItemName__c = '保証プランA'];
        ItemDetail__c testItemDetail = [SELECT Id FROM ItemDetail__c WHERE PlanDetail__c = '保証プラン明細A'];

        //パラメータ設定
        PageReference pageRef = Page.GF101004View;
        pageRef.getParameters().put('AccountId',testAccout.Id );
        pageRef.getParameters().put('Id',testItem.Id );
        Test.setCurrentPage(pageRef);

        //パラメータありでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //削除処理実行
        testController.targetItemRecordDelete();

        List<Item__c> checkItem = [SELECT Id FROM Item__c WHERE Id = :testItem.Id];
        System.assert(checkItem.size() == 0, 'error:商品レコードが削除できていない');

    }


    //商品レコード削除エラーテスト
    @isTest static void itemDeleteErrorTest(){

        Account testAccout = [SELECT Id FROM Account WHERE Name = '保証会社名A'];
        Item__c testItem = [SELECT Id FROM Item__c WHERE ItemName__c = '保証プランA'];
        ItemDetail__c testItemDetail = [SELECT Id FROM ItemDetail__c WHERE PlanDetail__c = '保証プラン明細A'];

        //パラメータ設定
        PageReference pageRef = Page.GF101004View;
        pageRef.getParameters().put('AccountId',testAccout.Id );
        pageRef.getParameters().put('Id',testItem.Id );
        Test.setCurrentPage(pageRef);

        //パラメータありでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //先に削除
        delete testItem;

        //削除処理実行
        testController.targetItemRecordDelete();

        //削除レコードが取得できないときのエラー出てる？
        List<ApexPages.Message> messages = ApexPages.getMessages();
        system.assertEquals(ApexPages.getMessages()[0].getDetail(),CommonConst.MSG_COM_E_NOTICE_DELETED);

    }


    //商品明細新規登録モーダルテスト
    @isTest static void newOpenModalTest(){

        Account testAccout = [SELECT Id FROM Account WHERE Name = '保証会社名A'];
        Item__c testItem = [SELECT Id FROM Item__c WHERE ItemName__c = '保証プランA'];

        //パラメータ設定
        PageReference pageRef = Page.GF101004View;
        pageRef.getParameters().put('AccountId',testAccout.Id );
        pageRef.getParameters().put('Id',testItem.Id );
        Test.setCurrentPage(pageRef);

        //パラメータありでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //新規モーダル起動
        testController.openModalCreateItemDetail();

        //子(モーダル)起動
        GF101004Modal1Controller testModalController = new GF101004Modal1Controller();

        //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
        testModalController.parameter = testController.GF101004Modal1Parameter;

        //子のinitactionを起動
        testModalController.initAction();

        //画面の名前項目が空白であることを確認
        System.assert(String.isEmpty((testModalController.modalParameter.planDetail)), 'error:画面の名前項目が空白でではない');
    }


    //商品明細編集モーダルテスト
    @isTest static void editOpenModalTest(){

        Account testAccout = [SELECT Id FROM Account WHERE Name = '保証会社名A'];
        Item__c testItem = [SELECT Id FROM Item__c WHERE ItemName__c = '保証プランA'];
        ItemDetail__c testItemDetail = [SELECT Id FROM ItemDetail__c WHERE PlanDetail__c = '保証プラン明細A'];

        //パラメータ設定
        PageReference pageRef = Page.GF101004View;
        pageRef.getParameters().put('AccountId',testAccout.Id );
        pageRef.getParameters().put('Id',testItem.Id );
        Test.setCurrentPage(pageRef);

        //パラメータありでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //編集モーダル起動
        testController.selectedIndex = 0;    //VFで設定される変数なので直接設定する
        testController.openModalUpdateItemDetail();

        //子(モーダル)起動
        GF101004Modal1Controller testModalController = new GF101004Modal1Controller();

        //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
        testModalController.parameter = testController.GF101004Modal1Parameter;

        //子のinitactionを起動
        testModalController.initAction();

        //画面の名前項目がDBと一致することを確認
        System.assertEquals(testModalController.modalParameter.planDetail, '保証プラン明細A', 'error:画面の名前項目が違う');
    }


    //商品明細登録用モーダル終了(設定)テスト
    @isTest static void closeModalTest(){

        Account testAccout = [SELECT Id FROM Account WHERE Name = '保証会社名A'];
        Item__c testItem = [SELECT Id FROM Item__c WHERE ItemName__c = '保証プランA'];
        ItemDetail__c testItemDetail = [SELECT Id FROM ItemDetail__c WHERE PlanDetail__c = '保証プラン明細A'];

        //パラメータ設定
        PageReference pageRef = Page.GF101004View;
        pageRef.getParameters().put('AccountId',testAccout.Id );
        pageRef.getParameters().put('Id',testItem.Id );
        Test.setCurrentPage(pageRef);

        //パラメータありでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //編集モーダル起動
        testController.selectedIndex = 0;    //VFで設定される変数なので直接設定する
        testController.openModalUpdateItemDetail();

        //子(モーダル)起動
        GF101004Modal1Controller testModalController = new GF101004Modal1Controller();

        //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
        testModalController.parameter = testController.GF101004Modal1Parameter;

        //子のinitactionを起動
        testModalController.initAction();

        //モーダルで名前を変更
        testModalController.modalParameter.planDetail = 'koushin';

        //設定処理
        testModalController.closeModal();

        //子のパラメータを親に渡す
        testController.GF101004Modal1Parameter = testModalController.parameter;

        //モーダル終了処理
        testController.closeModal();

        //画面の名前が変更されていることを確認
        System.assertEquals(testController.screenItemDetailList[0].itemDetailRecord.PlanDetail__c, 'koushin', 'error:名前が変更されていない');

    }

    
    //商品明細登録用モーダル設定エラーテスト
    @isTest static void closeModalErrorTest(){

        Account testAccout = [SELECT Id FROM Account WHERE Name = '保証会社名A'];
        Item__c testItem = [SELECT Id FROM Item__c WHERE ItemName__c = '保証プランA'];
        ItemDetail__c testItemDetail = [SELECT Id FROM ItemDetail__c WHERE PlanDetail__c = '保証プラン明細A'];

        //パラメータ設定
        PageReference pageRef = Page.GF101004View;
        pageRef.getParameters().put('AccountId',testAccout.Id );
        pageRef.getParameters().put('Id',testItem.Id );
        Test.setCurrentPage(pageRef);

        //パラメータありでコンストラクタ起動
        GF101004Controller testController = new GF101004Controller();

        //編集モーダル起動
        testController.selectedIndex = 0;    //VFで設定される変数なので直接設定する
        testController.openModalUpdateItemDetail();

        //子(モーダル)起動
        GF101004Modal1Controller testModalController = new GF101004Modal1Controller();

        //親のパラメータを子に渡す(親で設定しているモーダル用のパラメータをそのまま格納)
        testModalController.parameter = testController.GF101004Modal1Parameter;

        //子のinitactionを起動
        testModalController.initAction();

        //nullの項目も全て埋める
        testModalController.modalParameter.firstFeeDepositYen = '1';
        testModalController.modalParameter.depositYen = '1';

        //設定処理
        testModalController.closeModal();

        //二重登録エラーが出ているか確認
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(true, messages[0].getDetail().contains('初回保証料(％),初回保証料(円)'));
        System.assertEquals(true, messages[1].getDetail().contains('月額保証料(％),月額保証料(円)'));
    }

}