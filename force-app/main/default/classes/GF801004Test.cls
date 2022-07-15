/**
 * 災害保険プラン登録モーダルのテスト
 */
@isTest
public class GF801004Test {

    //テストに使用するレコードを作成する
    @testSetup static void Setting() {
    }

    @isTest static void testAll() {
        //コントローラ作成
        GF801004Controller testController = new GF801004Controller();

        //パラメータ作成
        GF801004ParameterClass testParam = new GF801004ParameterClass();
        testParam.isDrawing = true;
        testParam.noFirst = true;
        testParam.companyName = '火災保険会社名0';
        testController.parameter = testParam;

        //初期表示処理実行
        Boolean action = testController.init;

        //設定処理実行（入力値なし）
        testController.closeModal();

        //設定処理実行（入力値あり）
        testController.modalParameter.itemName = '火災保険プラン';
        testController.modalParameter.isAuxiliary = true;
        testController.modalParameter.insuranceFeeRate = '10';
        testController.modalParameter.insuranceFee = '10000';
        //月型から年型に変更
        testController.modalParameter.paymentType = CommonConst.ITEM_PAYMENTTYPE_YEAR;
        testController.modalParameter.paymentYear = '1';
        testController.closeModal();
        //年型から月型に変更
        testController.modalParameter.paymentType = CommonConst.ITEM_PAYMENTTYPE_MONTH;
        testController.closeModal();
    }

}