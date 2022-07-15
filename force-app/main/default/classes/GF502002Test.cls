/**
 * 高校・大学登録画面のテストクラス
 */
@isTest
private class  GF502002Test {

    /**
     * 共通設定
     */
    @testSetup static void Setting() {

        // ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('システム管理者')];
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            insert new User(UserName = 'GF502002Test@horaguchi.com'
                            , Email = 'test@example.com'
                            , LastName = 'test'
                            , Alias = 'test'
                            , TimeZoneSidKey = 'Asia/Tokyo'
                            , LocaleSidKey = 'ja_JP'
                            , EmailEncodingKey = 'ISO-2022-JP'
                            , LanguageLocaleKey = 'ja'
                            , ProfileId = profiles.get(0).Id
                           );
        }

        // 周辺施設
        SurroundingFacility__c surroundingFacility = new SurroundingFacility__c (
            Name               = '周辺施設テスト1'
            , PhotoFileName__c = '写真名テスト1'
        );
        insert surroundingFacility;
    }

    /**
     * 初期表示テスト
     */
    @isTest static void initTest(){

        // 周辺施設
        SurroundingFacility__c surroundingFacility = [SELECT Id 
                                                      FROM SurroundingFacility__c
                                                      WHERE Name = '周辺施設テスト1'];

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GF502002Test@horaguchi.com'];
        system.runas(userRecord) {

            // パラメータエラー
            PageReference pageRef = Page.GF502002View;
            pageRef.getParameters().put('surroundingFacilityId', userRecord.Id);
            Test.setCurrentPage(pageRef);

            GF502002Controller testController = new GF502002Controller();
            
            // 正常動作
            pageRef.getParameters().put('surroundingFacilityId', surroundingFacility.Id );
            Test.setCurrentPage(pageRef);

            testController = new GF502002Controller();
        }
    }

    /**
     * モザイクの設定テスト
     */
    @isTest static void setParamMoosaicTest(){

        // 周辺施設
        SurroundingFacility__c surroundingFacility = selectSurroundingFacility('周辺施設テスト1');

        // 初期表示
        PageReference pageRef = Page.GF502002View;
        pageRef.getParameters().put('surroundingFacilityId', surroundingFacility.Id );
        Test.setCurrentPage(pageRef);

        GF502002Controller testController = new GF502002Controller();

        // モザイクの設定
        testController.setParamMoosaic();
    }

    /**
     * 写真情報アップロード後処理テスト
     */
    @isTest static void updateCompletePhotoTest(){

        // 周辺施設
        SurroundingFacility__c surroundingFacility = selectSurroundingFacility('周辺施設テスト1');

        // 画面設定
        GF502002Controller testController = new GF502002Controller();
        testController.screenRegistSchool = new GF502002Controller.ScreenRegistSchool(surroundingFacility);

        // 写真情報アップロード後処理
        testController.updateCompletePhoto();
    }

    /**
     * 写真情報削除処理テスト
     */
    @isTest static void deletePhotoTest(){

        // 周辺施設
        SurroundingFacility__c surroundingFacility = selectSurroundingFacility('周辺施設テスト1');

        // 画面設定
        GF502002Controller testController = new GF502002Controller();
        testController.screenRegistSchool = new GF502002Controller.ScreenRegistSchool(surroundingFacility);

        // 写真情報削除処理
        testController.deletePhoto();
    }

    /**
     * 学校保存処理テスト
     */
    @isTest static void saveSchool(){

        // 周辺施設
        SurroundingFacility__c surroundingFacility = selectSurroundingFacility('周辺施設テスト1');

        // 画面設定
        GF502002Controller testController = new GF502002Controller();
        testController.screenRegistSchool = new GF502002Controller.ScreenRegistSchool(surroundingFacility);

        // 写真情報削除処理
        // 必須項目無し
        testController.screenRegistSchool.Name = CommonConst.STRING_EMPTY;
        testController.saveSchool();

        // 楽観ロックエラー
        testController.screenRegistSchool.Name = surroundingFacility.Name;
        update testController.screenRegistSchool.surroundingFacility;
        testController.saveSchool();

        // 正常動作
        surroundingFacility = selectSurroundingFacility('周辺施設テスト1');
        testController.screenRegistSchool = new GF502002Controller.ScreenRegistSchool(surroundingFacility);
        testController.saveSchool();
    }

    /**
     * カバレッジ向上テスト
     */
    @isTest static void coverageUp() {

        GF502002Controller testController = new GF502002Controller();

        // プロパティ
        String propVal;
        propVal = testController.MSG_COM_V_SAVE;
        propVal = testController.MSG_COM_I_SAVE;
        propVal = testController.MSG_COM_V_DELETE;
    }

    /**
     * 周辺施設の取得
     * @param String condName 施設
     * @return SurroundingFacility__c 周辺施設
     */
    private static SurroundingFacility__c selectSurroundingFacility(String condName) {

        return [SELECT Id 
                       , Name             // 施設
                       , Address__c       // 住所
                       , Latitude__c      // 緯度
                       , Longitude__c     // 経度
                       , Remarks__c       // 備考
                       , PhotoFilePath__c // 写真ファイルパス
                       , PhotoFileName__c // 写真ファイル名
                       , ForeignID__c     // 外部ID
                       , SystemModStamp
                FROM SurroundingFacility__c
                WHERE Name = :condName];
    }
}