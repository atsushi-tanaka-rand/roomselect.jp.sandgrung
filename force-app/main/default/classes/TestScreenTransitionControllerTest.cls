/**
 * テスト用画面遷移画面のテスト
 */
@isTest
public class TestScreenTransitionControllerTest {

    //テストに使用するレコードを作成する
    @testSetup static void Setting() {

    }

    @isTest static void testAll() {
        //コントローラ作成
        TestScreenTransitionController testController = new TestScreenTransitionController();
        testController.param = '';
        testController.pageName = '';
        testController.isChecked = null;
        //メソッド実行
        testController.getItems();
        testController.setSelectSeni(null);
        testController.getSelectSeni();
    }

}