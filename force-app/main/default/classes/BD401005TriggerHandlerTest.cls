// ポータルサイト掲載物件APEXテスト
@isTest
public with sharing class BD401005TriggerHandlerTest {
    
    // InsetTest
    @isTest static void InsertTest(){ 
    
        List<PortalSitePostingProperty__c> portalList = new List<PortalSitePostingProperty__c>(); // ポータルサイト掲載物件のListをnewする。

        for (Integer i = 0; i < 10; i++){ // 10件登録。
            // insertの準備
            PortalSitePostingProperty__c addPortal = new PortalSitePostingProperty__c(
            );
            
            portalLIst.add(addPortal); // Listへ入れる。
        }
        // Inset!!
        insert portalList;

        // 確認のためIdをセレクトする。(ポータルサイト掲載物件)
        List<PortalSitePostingPropertyDifference__c> portalDifferenceList = [SELECT Id FROM PortalSitePostingPropertyDifference__c];

        System.assertEquals(10,portalDifferenceList.size());
    }

    // updateテスト
    @isTest static void UpdateTest(){

        List<PortalSitePostingProperty__c> portalList = new List<PortalSitePostingProperty__c>(); // ポータルサイト掲載物件のListをnewする。

        for (Integer i = 0; i < 10; i++){ // 10件登録。
            // insertの準備
            PortalSitePostingProperty__c addPortal = new PortalSitePostingProperty__c(
            );
            
            portalLIst.add(addPortal); // Listへ入れる。
        }
        // Inset!!
        insert portalList;        

        // 更新処理
        List<PortalSitePostingProperty__c> updPortalList = new List<PortalSitePostingProperty__c>(); // 更新用のListをnewする。

        for(PortalSitePostingProperty__c newList : portalList){ // 10件更新(先ほど登録したListを使用する。)
            // Listの作成準備(項目の再設定)
            PortalSitePostingProperty__c addUpdPortal = new PortalSitePostingProperty__c(
                    Id = newList.Id 
            );

            updPortalList.add(addUpdPortal);// update用のListを作成。
        }

        // update!!
        update updPortalList;

        // 確認のためIdをSELECTする(ポータルサイト掲載物件差分）。
        List<PortalSitePostingPropertyDifference__c> portalDifferenceList = [SELECT Id FROM PortalSitePostingPropertyDifference__c];

        // アサート
        System.assertEquals(20,portalDifferenceList.size());
    }
    
    // Delete
    @isTest static void DeleteTest(){
        
        List<PortalSitePostingProperty__c> portalList = new List<PortalSitePostingProperty__c>(); // insert用のListをnewする
        
        for (Integer i = 0; i < 10; i++){ // 10件登録。
            // insertの準備
            PortalSitePostingProperty__c addPortal = new PortalSitePostingProperty__c(
            );
            
            portalLIst.add(addPortal); // Listへ入れる。
        }
        // Inset!!
        insert portalList;

        // Delete!!
        delete portalList;

        // 確認のために、IdをSELECTする
        List<PortalSitePostingPropertyDifference__c> portalDifferenceList = [SELECT Id FROM PortalSitePostingPropertyDifference__c];
        

        // assert
        System.assertEquals(20, portalDifferenceList.size());



    }
}