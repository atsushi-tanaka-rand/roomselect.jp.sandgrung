/**
 * テスト用モーダル起動画面のテスト
 */
@isTest
public class componentViewTestControllerTest {

    //テストに使用するレコードを作成する
    @testSetup static void Setting() {

    }

    @isTest static void testAll() {
        //コントローラ作成
        componentViewTestController testController = new componentViewTestController();
        //メソッド実行
        testController.GH201003FormOpen();
        testController.GH201003FormClose();
        testController.GA104007FormOpen();
        testController.GA104007FormClose();
        testController.GA102006FormOpen();
        testController.GA102006FormClose();
        testController.GD101004FormOpen();
        testController.GD101004FormClose();
        testController.GD101003FormOpen();
        testController.GD101003FormClose();
        testController.GD301003FormOpen();
        testController.GD301003FormClose();
    }

}