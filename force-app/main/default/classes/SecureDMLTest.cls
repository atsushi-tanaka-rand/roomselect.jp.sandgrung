/**
 * CRUD/FLSチェック用テストクラス
 */
@isTest
public class SecureDMLTest {
    
    private static Set<String> profileNames = new Set<String> {
        '一般ユーザ'
            , 'システム管理者'
    };
    //レコードタイプID取得
    static ID testAccountRecordTypeId = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_AUXILIARY);
    
    //テストに使用するレコードを作成する
    @testSetup static void Setting(){
        
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(Name = '付帯業者名' + i               //付帯業者名
                                         , PostalCode__c = '000-000' + i         //郵便番号
                                         , State__c = '大阪府'                   //都道府県
                                         , City__c = '大阪市中央区'              //市区町村
                                         , Street__c = '1丁目' + i               //丁目・番地
                                         , Phone = '0000000000' + i              //電話番号
                                         , Fax = '0000000000' + i                //FAX
                                         , Email__c = 'sample@example.com'       //メールアドレス
                                         , RemarksPublic__c = '備考備考備考' + i  //備考（公開）
                                         , RecordTypeId = testAccountRecordTypeId    //レコードタイプ
                                        )
                            );
        }
        insert testAccounts;
        
        //『付帯業者名0』に商品レコード追加
        List<Item__c> testItem = new List<Item__c>();
        for(Integer i = 0; i < 3; i++){
            testItem.add(new Item__c( ItemName__c = '付帯業者0用商品No.' + i         //付帯商品名
                                     , IsAuxiliary__c = TRUE                   //付帯商品区分
                                     , Remarks__c = '付帯商品の備考が入ります' + i     //備考
                                     , Account__c = testAccounts[0].Id            //レコードID（取引先）
                                     , RecordTypeId = CommonUtil.getRecordTypeId('Item__c', CommonConst.ITEM_RECTYPE_AUXILIARY_ITEM)
                                    ) 
                        );
        }
        insert testItem;
        
        //ユーザ作成
        Map<String, Profile> profileMap = new Map<String, Profile>();
        
        for(Profile profile : [SELECT Id,Name FROM Profile WHERE Name IN : profileNames]){
            profileMap.put(profile.Name,profile);
        }
        
        User standardUser = new User(
            UserName = 'standard@horaguchi.com',
            Email = 'hutaigyousya_test@example.com',
            LastName = 'FutaiTest',
            Alias = 'F・test',
            TimeZoneSidKey = 'Asia/Tokyo',
            LocaleSidKey = 'ja_JP',
            EmailEncodingKey = 'ISO-2022-JP',
            LanguageLocaleKey = 'ja',
            ProfileId = profileMap.get('一般ユーザ').Id);
        
        User admin = new User(
            UserName = 'admin@horaguchi.com',
            Email = 'hutaigyousya_test@example.com',
            LastName = 'FutaiTest',
            Alias = 'F・test',
            TimeZoneSidKey = 'Asia/Tokyo',
            LocaleSidKey = 'ja_JP',
            EmailEncodingKey = 'ISO-2022-JP',
            LanguageLocaleKey = 'ja',
            ProfileId = profileMap.get('システム管理者').Id);
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            insert new List<User>{standardUser,admin};
        }
        
        // ニュースリリース登録
        insert new NewsRelease__c[]{new NewsRelease__c(
            FixedDisplayFlag__c = true,     // 固定表示フラグ
            Name = 'test',                  // タイトル
            ReleaseStartDate__c = Date.newInstance(2020,09,01),   // 掲載開始日
            ReleaseEndDate__c = Date.newInstance(2020,09,30),                       // 掲載終了日
            ReleaseStatus__c = CommonConst_ptl.NEWSRELEASE_RELEASESTATUS_PUBLIC     // 公開状況
        )};
    }
    /**
     * 標準ユーザテスト
     */    
    @isTest static void standarUserTest(){
        
        User u = [SELECT Id FROM User WHERE UserName = 'standard@horaguchi.com'];
        
        System.runAs(u){
            dmlAll();
            // 子リレーションチェック
            SecureDML.secureInsert([Select Name,(Select Id From ItemAccount__r) From Account].deepClone(false));
        }
        
    }
    
    /**
     * システム管理者テスト
     */    
    @isTest static void adminUserTest(){
        User u = [SELECT Id FROM User WHERE UserName = 'admin@horaguchi.com'];
        
        System.runAs(u){
            dmlAll();
            // 子リレーションチェック
            SecureDML.secureUpsert([Select Id,(Select Id From ItemAccount__r) From Account]);
        }
        
    }
       
    private static void dmlAll(){
        // 登録テスト
        InsertTest();
        // 更新テスト            
        updateTest();
        // 登録・更新テスト            
        upsertTest();
        // 削除テスト            
        deleteTest();     
    }
    /**
     * 登録テスト
     */     
    private static void InsertTest(){
        
        NewsRelease__c rec = getNewsRelease().get(0);
        
        rec = rec.clone();
        
        SecureDML.secureInsert(new List<NewsRelease__c>{rec});
        
        system.assert(rec.Id != null,'登録できていない。');
        
        rec = rec.clone();
        
        SecureDML.secureInsert(rec);
        
        system.assert(rec.Id != null,'登録できていない。');
    }
    
    /**
     * 更新テスト
     */    
    private static void updateTest(){
        
        NewsRelease__c rec = getNewsRelease().get(0);
        
        rec.Name = 'UpdateTest1';
        SecureDML.secureUpdate(new List<NewsRelease__c>{rec});
        rec = getNewsRelease(rec.Id);
        system.assert(rec.Name == 'UpdateTest1','更新できていない。');
        
        rec.Name = 'UpdateTest2';
        SecureDML.secureUpdate(rec);
        rec = getNewsRelease(rec.Id);
        system.assert(rec.Name == 'UpdateTest2','更新できていない。');
        
    }
    
    /**
     * 登録・更新テスト
     */     
    private static void upsertTest(){
        
        NewsRelease__c rec = getNewsRelease().get(0);
        
        rec = rec.clone();
        SecureDML.secureUpsert(new List<NewsRelease__c>{rec});
        system.assert(rec.Id != null,'登録できていない。');
        
        rec.ForeignID__c = '1111111';
        SecureDML.secureUpsert(rec);
        rec = getNewsRelease(rec.Id);
        system.assert(rec.ForeignID__c == '1111111','更新できていない。');
        
        rec.ForeignID__c = '1111111';
        rec.Name = 'UpsertTest1';
        SecureDML.secureUpsert(new List<NewsRelease__c>{rec}, NewsRelease__c.ForeignID__c);   
        rec = getNewsRelease(rec.Id);

        system.assert(rec.Name == 'UpsertTest1','更新できていない。');
        
        rec.ForeignID__c = '1111111';
        rec.Name = 'UpsertTest2';
        SecureDML.secureUpsert(rec, NewsRelease__c.ForeignID__c);   
        rec = getNewsRelease(rec.Id);

        system.assert(rec.Name == 'UpsertTest2','更新できていない。');
    }
    
    /**
     * 登録・更新テスト
     */         
    private static void deleteTest(){
        
        List<NewsRelease__c> recs = getNewsRelease();
        
        Integer size = recs.size();
        
        SecureDML.secureDelete(recs.get(0));
        recs = getNewsRelease();
        system.assert(size == recs.size()+1 ,'削除できていない。');
        
        SecureDML.secureDelete(recs);
        system.assert(getNewsRelease().isEmpty(),'削除できていない。');
    }
    
    /**
     * ニュースリリースを取得する
     */
    private static List<NewsRelease__c> getNewsRelease(){
        sObjectType sObjType = NewsRelease__c.getSObjectType();
        String soql = ''
            + ' SELECT ' + getFieldNames(sObjType)
            + ' FROM ' + sObjType.getDescribe().getName();
        return Database.query(soql);
    }
    
    /**
     * ニュースリリースを取得する
     */
    private static NewsRelease__c getNewsRelease(Id recordId){
        
        sObjectType sObjType = NewsRelease__c.getSObjectType();
        
        String soql = ''
            + ' SELECT ' + getFieldNames(sObjType)
            + ' FROM ' + sObjType.getDescribe().getName()
            + ' WHERE Id = :recordId';
        return Database.query(soql);
    }
    
    /*
     * 対象オブジェクトの項目名を全て取得する
     */ 
    private static String getFieldNames(SObjectType sObjType){
        // IDは必須とする
        List<String> fields = new List<String>{'Id'};
        
        for(Schema.SObjectField field : sObjType.getDescribe().fields.getmap().values()){
            // 各フィールドの情報を保持するスキーマを取得する
            Schema.DescribeFieldResult dfr = field.getDescribe();
            // カスタム項目と名前項目のみ対象とする
            if(dfr.isCustom() || dfr.isNameField()){
                fields.add(dfr.getName());
            }
        }
        return String.join(fields,',');
    }
    
}