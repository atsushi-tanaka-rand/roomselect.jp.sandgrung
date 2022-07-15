/**
 * 保証会社プラン登録モーダルのテスト
 */
@isTest
public class GF101004ModalTest {

    //テストに使用するレコードを作成する
    @testSetup static void Setting() {

    }

    @isTest static void testAll() {
        //コントローラ作成
        GF101004Modal1Controller testController = new GF101004Modal1Controller();
        //パラメータ作成
        GF101004Modal1ParameterClass testParam = new GF101004Modal1ParameterClass();
        testController.parameter = testParam;
        //メソッド実行
    }

}