/**
 * 所属部署の複数選択リストモーダルのテスト
 */
@isTest
public class GA101002ModalTest {

    //テストに使用するレコードを作成する
    @testSetup static void Setting() {

    }

    @isTest static void testAll() {
        //コントローラ作成
        GA101002Modal1Controller testController = new GA101002Modal1Controller();
        //パラメータ作成
        GA101002Modal1ParameterClass testParam = new GA101002Modal1ParameterClass();
        testController.Parameter = testParam;
        //メソッド実行
        testController.getSelectOption();
    }

}