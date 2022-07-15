/**
 * 画像アップロード用コンポーネントのテスト
 */
@isTest
public class GD901001Test {

    //テストに使用するレコードを作成する
    @testSetup static void Setting() {

        // カスタム設定
        SystemConfig__c testSystemConfig = new SystemConfig__c();
        testSystemConfig.S3Region__c            = 'dummy';
        testSystemConfig.S3BucketName__c        = 'dummy';
        testSystemConfig.S3SecretAccessKey__c   = 'dummy';
        testSystemConfig.S3AccessKey__c         = 'dummy';
        testSystemConfig.S3RootDirectory__c     = 'dummy';
        insert testSystemConfig;

    }

    @isTest static void testAll() {
        //コントローラ作成
        GD901001Controller testController = new GD901001Controller();
        //パラメータ作成
        GD901001ParameterClass testParam = new GD901001ParameterClass();
        testController.Parameter = testParam;
        //メソッド実行
    }

}