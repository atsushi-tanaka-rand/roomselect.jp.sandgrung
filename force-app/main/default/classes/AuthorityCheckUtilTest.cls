/* *
 * 共通部品　テストクラス
 */
@isTest 
public with sharing class AuthorityCheckUtilTest {
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        
        //ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('一般ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert new User(
                UserName = 'Test@horaguchi.com',
                Email = 'test@example.com',
                LastName = 'test',
                Alias = 'test',
                TimeZoneSidKey = 'Asia/Tokyo',
                LocaleSidKey = 'ja_JP',
                EmailEncodingKey = 'ISO-2022-JP',
                LanguageLocaleKey = 'ja',
                ProfileId = profiles.get(0).Id);
        }

        // システム設定登録
        SystemConfig__c sysCon = new SystemConfig__c();
        sysCon.UseAuthority_ContractManagement__c = false;
        sysCon.UseAuthority_Portal__c = false;
        sysCon.UseAuthority_FloorPlanAutomation__c = false;
        sysCon.UseAuthority_HousingSecurityMutualAid__c = false;
        sysCon.UseAuthority_PanoramaTour__c = false;
        insert sysCon;
    }

    //権限確認　
    @isTest static void AuthorityOption_Test(){

        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        system.runas(userRecord){

            // 利用権限チェック（戻り値False）
            AuthorityCheckUtil.getAuthorityOptionContractManagement(false);
            AuthorityCheckUtil.getAuthorityOptionPortal(false);
            AuthorityCheckUtil.getAuthorityOptionFloorPlanAutomation(false);
            AuthorityCheckUtil.getAuthorityOptionHousingSecurityMutualAid(false);
            AuthorityCheckUtil.getAuthorityOptionPanoramaTour(false);

            // 利用権限チェック（例外処理）
            try {
                AuthorityCheckUtil.getAuthorityOptionContractManagement(true);    
            } catch (Exception e) {
                
            }
            try {
                AuthorityCheckUtil.getAuthorityOptionPortal(true); 
            } catch (Exception e) {
                
            }
            try {
                AuthorityCheckUtil.getAuthorityOptionFloorPlanAutomation(true); 
            } catch (Exception e) {
                
            }
            try {
                AuthorityCheckUtil.getAuthorityOptionHousingSecurityMutualAid(true);   
            } catch (Exception e) {
                
            }
            try {
                AuthorityCheckUtil.getAuthorityOptionPanoramaTour(true);   
            } catch (Exception e) {
                
            }
        }
    }

    // 利用権限_パノラマツアーチェック　（権限なし設定の場合）
    @isTest static void AuthorityOptionPanoramaTour_Test(){
        String testName = 'パノラマツアーの利用権限';
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];
        system.runas(userRecord){

            // 利用権限チェック（戻り値False）
            System.assertEquals(false, AuthorityCheckUtil.getAuthorityOptionPanoramaTour(false), testName + 'チェック1：想定値false');

            // 利用権限チェック（例外処理）
            Exception ex;
            try {
                AuthorityCheckUtil.getAuthorityOptionPanoramaTour(true);   
            } catch (Exception e) {
                ex = e;
            }
            System.assert(ex instanceof BusinessLogicException, testName + 'チェック２：想定値BusinessLogicException ' + ex);
            List<String> errorMessages = ((BusinessLogicException) ex).errMessage;
            String errorMessage = errorMessages.get(errorMessages.size() -1);
            System.assert(errorMessage.equals('このページは利用できません。' + testName + 'が必要です。'), testName + 'チェック３：例外メッセージ ' + errorMessage);
        }
    }

    // 利用権限_パノラマツアーチェック　（権限あり設定の場合）
    // システム設定読み込みがstaticのため、テストメソッドを分割する必要がある
    @isTest static void AuthorityOptionPanoramaTour_Test2(){
        String testName = 'パノラマツアーの利用権限';
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'Test@horaguchi.com'];

        // システム設定変更
        // テスト対象のクラスを呼び出す前に設定変更を行う（staticのため）
        SystemConfig__c sysCon = [SELECT Id, UseAuthority_PanoramaTour__c FROM SystemConfig__c];
        sysCon.UseAuthority_PanoramaTour__c = true;
        update sysCon;

        system.runas(userRecord){
            // 利用権限チェック（戻り値true）
            System.assertEquals(true, AuthorityCheckUtil.getAuthorityOptionPanoramaTour(false), testName + 'チェック４：想定値true');
        }
    }

}