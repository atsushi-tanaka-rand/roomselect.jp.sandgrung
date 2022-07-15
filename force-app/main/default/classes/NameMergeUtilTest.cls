@isTest 
private class NameMergeUtilTest {
    @isTest static void setBuildingMergeCompletedFlagTest() {

        Building__c build = new Building__c(
            Name = '建物1',
            BuildName2__c = '建物2',
            BuildName3__c = '建物3',
            BuildKana__c = 'タテモノ1',
            BuildKana2__c = 'タテモノ2',
            BuildKana3__c = 'タテモノ3',
            State__c = '愛知県'
        );
        Building__c build2 = new Building__c(
            Name = '建物1',
            BuildName2__c = '建物2',
            BuildName3__c = '建物3',
            BuildKana__c = 'タテモノ1',
            BuildKana2__c = 'タテモノ2',
            BuildKana3__c = 'タテモノ3',
            State__c = '静岡県'
        );
        Building__c build3 = new Building__c(
            Name = '建物6',
            BuildName2__c = '建物7',
            BuildName3__c = '建物8',
            BuildKana__c = 'タテモノ6',
            BuildKana2__c = 'タテモノ7',
            BuildKana3__c = 'タテモノ8',
            State__c = '兵庫県'
        );
        List<Building__c> buildingList = new List<Building__c>();
        buildingList.add(build);
        buildingList.add(build2);
        buildingList.add(build3);
        NameMergeUtil.setBuildingMergeCompletedFlag(buildingList);

    }

    @isTest static void setAccountMergeCompletedFlagTest() {

        Account acc = new Account(
            Name = '取引先1',
            Phone = '111',
            Phone2__c = '222',
            Phone3__c = '333',
            Email__c = '111@yahoo.co.jp',
            Email2__c = '222@yahoo.co.jp',
            Email3__c = '333@yahoo.co.jp'
        );
        Account acc2 = new Account(
            Name = '取引先1',
            Phone = '111',
            Phone2__c = '222',
            Phone3__c = '333',
            Email__c = '111@yahoo.co.jp',
            Email2__c = '222@yahoo.co.jp',
            Email3__c = '333@yahoo.co.jp'
        );
        Account acc3 = new Account(
            Name = '取引先2',
            Phone = '444',
            Phone2__c = '555',
            Phone3__c = '666',
            Email__c = '444@yahoo.co.jp',
            Email2__c = '555@yahoo.co.jp',
            Email3__c = '666@yahoo.co.jp'
        );
        List<Account> accList = new List<Account>();
        accList.add(acc);
        accList.add(acc2);
        accList.add(acc3);
        NameMergeUtil.setAccountMergeCompletedFlag(accList);
        NameMergeUtil.setCustomerMergeCompletedFlag(accList);
    }

    @isTest static void setCustomerMergeCompletedFlagTest() {
        Account acc = new Account(
            Name = '取引先1',
            Phone = '111',
            Phone2__c = '222',
            Phone3__c = '333',
            Email__c = '111@yahoo.co.jp',
            Email2__c = '222@yahoo.co.jp',
            Email3__c = '333@yahoo.co.jp'
        );
        Account acc2 = new Account(
            Name = '取引先1',
            Phone = '444',
            Phone2__c = '555',
            Phone3__c = '666',
            Email__c = '444@yahoo.co.jp',
            Email2__c = '555@yahoo.co.jp',
            Email3__c = '666@yahoo.co.jp'
        );
        List<Account> accList = new List<Account>();
        accList.add(acc);
        accList.add(acc2);
        NameMergeUtil.setCustomerMergeCompletedFlag(accList);
    }

    @isTest static void setPropertyMergeCompletedFlagTest() {
        Property__c property = new Property__c(
            Name = '物件'
        );
        Property__c property2 = new Property__c(
            Name = '物件1'
        );
        List<Property__c> propertyList = new List<Property__c>();
        propertyList.add(property);
        propertyList.add(property2);
        NameMergeUtil.setPropertyMergeCompletedFlag(propertyList);
    }
}