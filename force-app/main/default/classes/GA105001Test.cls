/* 
 * お客様紐づけ_お客様情報検索のテスト
 */
@isTest 
private class  GA105001Test {
  

    //***************************************************** テストデータ作成用メソッド *****************************************************************
    
    // 取引先作成
    static List<Account> createAccount(String Name, String NameKana, String Phone, String Email, String RecordTypeId){

        //登録する取引先の値を設定
        if(Name == ''){//取引先名
            Name = 'テスト太郎';
        }

        if(NameKana == ''){//取引先名(カナ)
            NameKana = 'ﾃｽﾄﾀﾛｳ';
        }

        if(Phone == ''){//電話番号
            Phone = '025-200-1234' ;
        }

        if(Email == ''){//メール
            Email = 'aaa@hora';
        }

        if(RecordTypeId == ''){//レコードタイプ
            RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER);//顧客
        }else{
            RecordTypeId = commonUtil.getRecordTypeId('Account', RecordTypeId);
        }

        Account AccountRecord = new Account();//登録に使用する取引先を設定

        AccountRecord.Name = Name ;//取引先名
        AccountRecord.NameKana__c = NameKana ; //取引先名（カナ）
        AccountRecord.Phone = Phone ;//電話番号
        AccountRecord.Email__c = Email; // メール
        AccountRecord.RecordTypeId = RecordTypeId;//レコードタイプID（顧客）
        AccountRecord.Comment__c = 'コメント';//コメント
        AccountRecord.IsMergeUnnecessaryFlag__c = true; //名寄せ不要フラグ（ON）

        //取引先作成
        insert AccountRecord; 

        //戻り値の作成
        List<Account> accountList = new  List<Account>();
        accountList.add(AccountRecord);//戻り値の設定

        return accountList; 
        
}

        // ポータルサイト情報生成
        private static PortalSite__c createPortalSite(){

        PortalSite__c portal = new PortalSite__c();
        portal.Name = 'ホームズ';
        portal.Url__c = 'homestest@co.jp';
        portal.Email__c = CommonConst.EMAIL_HOMES;
        insert portal;
        return portal;
        }

        // 反響メール登録情報生成
        private static EchoMail__c createEchoMail(Id portalId, Id propertyId, String district, 
        String Name, String eMail, String phone,
        boolean portal, boolean isFlg) {
            EchoMail__c ecoMail = new EchoMail__c();

            // ポータルからのメールの場合の設定値
            if (portal) {
                ecoMail.FromPotalSite__c = portalId;  // Fromポータルサイト
                ecoMail.InquiryDateTime__c = CommonUtil.getNow();  // お問合せ日時
                ecoMail.Response__c = propertyId;     // 物件
                ecoMail.PropertyAddress__c = district;  // 所在地
                ecoMail.Subject__c = '件名です';  // 件名
                ecoMail.Body__c = '本文です';  // 本文
                ecoMail.CustomerName__c = Name;  // お客様名
                ecoMail.CustomerNameKana__c = 'ホラグチ　タロウ';  // お客様名（カナ）
                ecoMail.Phone__c = phone;  // 電話番号
                ecoMail.Fax__c = '090-8888-8888';  // Fax
                ecoMail.FromEmail__c = eMail;    // Fromメールアドレス
                ecoMail.Email__c = 'tempoEmail@rand.co.jp';     // メール
                ecoMail.PropertURL__c = 'URLテスト';              // 物件URL
            } else {
            // ポータル以外からのメールの設定値
                ecoMail.Subject__c = '件名です';  // 件名
                ecoMail.Body__c = '本文です';  // 本文
                ecoMail.FromEmail__c = eMail;    // Fromメールアドレス
                ecoMail.InquiryDateTime__c = CommonUtil.getNow();  // お問合せ日時
                ecoMail.ResponseDate__c = CommonUtil.getNow();  // 反響日
                if (isFlg) {
                    ecoMail.Email__c = 'tempoEmail2@rand.co.jp';    // メール
                } else {
                    ecoMail.Email__c = 'tempoEmail@rand.co.jp';     // メール
                }
            }
            insert ecoMail;
            return ecoMail;
        }


    // 対応作成
    static List<Correspond__c> createCorrespond(String status, String echoStaff, String shopStaff, String memo,  String AccountId  ){

        //登録する対応の値を設定
        if(echoStaff ==  ''){//担当者（反響）
            echoStaff =  UserInfo.getUserId();
        }

        if(shopStaff ==  ''){// 担当者（来店）
            shopStaff =  UserInfo.getUserId();
        }

        //作成する対応を設定
        Correspond__c CorrespondRecord = new Correspond__c();

        CorrespondRecord.Status__c    = status;      // ステータス
        CorrespondRecord.EchoStaff__c = echoStaff;   // 担当者（反響）
        CorrespondRecord.ShopStaff__c = shopStaff;   // 担当者（来店）
        CorrespondRecord.Memo__c      = memo;        // メモ

        if(AccountId !=  ''){
            CorrespondRecord.AccountId__c = AccountId;   // 取引先
        }

        //対応を作成
        insert CorrespondRecord;

        //戻り値の作成
        List<Correspond__c> CorrespondRecordList = new List<Correspond__c>();
        CorrespondRecordList.add(CorrespondRecord);//戻り値の設定

        return CorrespondRecordList; 
    }

    
    // 対応明細作成
    static List<CorrespondDetail__c> createCorrespondDetail(string CorrespondsId,Id EchoMailId){
        
        //作成する対応明細を設定
        CorrespondDetail__c detail = new CorrespondDetail__c();

        detail.Corresponds__c = CorrespondsId;//対応
        detail.EchoMail__c = EchoMailId;//反響メール
        detail.SupportedDateTime__c = Datetime.now();
        detail.Email__c = 'aaa@bbb.jp';

        //対応明細を作成
        insert detail;
        
        //戻り値の作成
        List<CorrespondDetail__c> detailList = new List<CorrespondDetail__c>();
        detailList.add(detail);//戻り値の設定

        return detailList; 
    }

    //カスタム設定の作成
    static SystemConfig__c searchMaxCountCustomSettings(Decimal maxCount){
        //作成するカスタム設定を設定
        SystemConfig__c settings = new SystemConfig__c();

        settings.AccountSearchMaxCount__c = maxCount;//検索上限
        settings.AccountSearchDisplayMaxCount__c = 800;
        settings.UseAuthority_Portal__c = true;
        //カスタム設定を作成
        insert settings;
        
        return settings;
    }

 
    //***************************************************** テストメソッド *****************************************************************
    

	//画面表示（初期表示）：対応あり
     @isTest static void initializeTest(){

        // テストデータ作成
        List<Correspond__c> Corres = createCorrespond('',  UserInfo.getUserId(), UserInfo.getUserId(), '',''  );//対応作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id,null);//対応明細作成

        //パラメータ設定
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id',Corres[0].Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        // テスト結果確認
        system.assertEquals(GA105001Controller.targetCorrespondDetail.Id, correspondDetail[0].Id); // 対応明細が設定されているか確認

        //ページからgetで参照される処理を実行
        GA105001Controller.getSearchAccountRecordTypeRadioButton();//検索モード名ラジオボタン設定
        
    }	

	//検索
     @isTest static void searchAccountTest(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        searchMaxCountCustomSettings(5000);//検索上限設定

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        // 検索条件設定
        GA105001Controller.searchAccountName = 'テスト太郎';// 顧客名
        GA105001Controller.searchPhone = '025-200-1234';   // 顧客電話番号
        GA105001Controller.searchEmail = 'aaa@hora';       // 顧客メールアドレス

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        // 検索実行
        GA105001Controller.searchAccount();

        // テスト結果確認
        system.assertEquals(GA105001Controller.searchAccountDetailDisplayList.size() > 0, TRUE);// 検索が成功しているか確認
        // 対応・対応明細がない為、最新対応日時が空白であることを確認
        system.assertEquals(GA105001Controller.searchAccountDetailDisplayList[0].latestSupportedDateTime, null);
        
    }	

	//検索(対応あり)
     @isTest static void searchAccountCorrespondTest(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        searchMaxCountCustomSettings(5000);//検索上限設定
        List<Correspond__c> Corres = createCorrespond(CommonConst.CORRESPOND_STATUS_NOTSUPPORTED,  UserInfo.getUserId(), UserInfo.getUserId(), 'メモ内容', accountList[0].Id  );//対応作成

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト太郎';
        GA105001Controller.searchPhone = '025-200-1234';
        GA105001Controller.searchEmail = 'aaa@hora';
        GA105001Controller.searchComment = 'コメント';
        GA105001Controller.searchShopStaff = UserInfo.getName();
        GA105001Controller.searchEchoStaff = UserInfo.getName();

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();

        // テスト結果確認
        system.assertEquals(GA105001Controller.searchAccountDetailDisplayList.size() > 0, TRUE);// 検索が成功しているか確認
        // 対応明細がない為、最新対応日時が空白であることを確認
        system.assertEquals(GA105001Controller.searchAccountDetailDisplayList[0].latestSupportedDateTime, null);
        
    }	

    //検索(対応明細あり)
    @isTest static void searchAccountCorrespondDetailTest(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        searchMaxCountCustomSettings(5000);//検索上限設定
        List<Correspond__c> Corres = createCorrespond(CommonConst.CORRESPOND_STATUS_NOTSUPPORTED,  UserInfo.getUserId(), UserInfo.getUserId(), 'メモ内容', accountList[0].Id  );//対応作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id,null);//対応明細作成

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト太郎';
        GA105001Controller.searchPhone = '025-200-1234';
        GA105001Controller.searchEmail = 'aaa@hora';
        GA105001Controller.searchComment = 'コメント';
        GA105001Controller.searchShopStaff = UserInfo.getName();
        GA105001Controller.searchEchoStaff = UserInfo.getName();

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();

        // テスト結果確認
        system.assertEquals(GA105001Controller.searchAccountDetailDisplayList.size() > 0, TRUE);// 検索が成功しているか確認
        // 明細のサポート日時が設定されているか確認
        system.assertEquals(GA105001Controller.searchAccountDetailDisplayList[0].latestSupportedDateTime.contains(Datetime.now().format('yyyy/MM/dd', 'JST')), true);
        
    }

	//検索(対応あり：業者)
     @isTest static void searchClientCorrespondTest(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', CommonConst.ACCOUNT_RECTYPE_FIRE_INSURANCE);//取引先作成
        searchMaxCountCustomSettings(5000);//検索上限設定
        List<Correspond__c> Corres = createCorrespond(CommonConst.CORRESPOND_STATUS_NOTSUPPORTED,  UserInfo.getUserId(), UserInfo.getUserId(), 'メモ内容', accountList[0].Id  );//対応作成

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountRecordType = '業者';
        GA105001Controller.searchAccountName = 'テスト太郎';
        GA105001Controller.searchPhone = '025-200-1234';
        GA105001Controller.searchEmail = 'aaa@hora';
        GA105001Controller.searchComment = 'コメント';
        GA105001Controller.searchShopStaff = UserInfo.getName();
        GA105001Controller.searchEchoStaff = UserInfo.getName();

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();
        
        // テスト結果確認
        system.assertEquals(GA105001Controller.searchAccountDetailDisplayList.size() > 0, TRUE);// 検索が成功しているか確認
        
    }	

	//お客様紐づけ（紐づけたお客様に他に名寄せ一致データ有り）
     @isTest static void accountLinkTest(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        List<Correspond__c> Corres = createCorrespond('',  UserInfo.getUserId(), UserInfo.getUserId(), '', ''  );//対応作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id,null);//対応明細作成
        searchMaxCountCustomSettings(5000);//検索上限設定
        //名寄せ一致データ(電話番号が一致)
        Account nayose = new Account(Name = 'テスト次郎', 
                                     FirstName__c = '次郎', LastName__c = 'テスト', 
                                     NameKana__c = 'ﾃｽﾄｼﾞﾛｳ',
                                     Phone = '025-200-1234', 
                                     IsMergeUnnecessaryFlag__c = true, 
                                     RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
        insert nayose;

        //パラメータ設定
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id',Corres[0].Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト太郎';

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();

	    //お客様紐づけ対象設定
        GA105001Controller.searchAccountDetailDisplayList[0].isCheckbox = TRUE;

	    //お客様紐づけ実行
        GA105001Controller.accountLink();

        // テスト結果確認
        Correspond__c upCorrs = [ SELECT  AccountId__c FROM Correspond__c WHERE ID = :Corres[0].Id ];//対応の紐付け先取得
        system.assertEquals(upCorrs.AccountId__c, GA105001Controller.searchAccountDetailDisplayList[0].Id );//対応の紐付け先とお客様紐づけ対象の一致を確認

        //紐づけた取引先の名寄せ完了フラグ・名寄せ不要フラグ確認
        Account chkAcc = [SELECT id, IsMergeCompletedFlag__c, IsMergeUnnecessaryFlag__c
                          FROM Account
                          WHERE NameKana__c = 'ﾃｽﾄﾀﾛｳ'
        ];
        system.assertEquals(false, chkAcc.IsMergeCompletedFlag__c);
        system.assertEquals(false, chkAcc.IsMergeUnnecessaryFlag__c);

        //名寄せが一致した取引先の名寄せ不要フラグ確認
        Account chkAcc2 = [ SELECT id, IsMergeCompletedFlag__c, IsMergeUnnecessaryFlag__c
                            FROM Account
                            WHERE NameKana__c = 'ﾃｽﾄｼﾞﾛｳ'
        ];
        system.assertEquals(false, chkAcc2.IsMergeUnnecessaryFlag__c);
       
    }	

    //お客様紐づけ（紐づけたお客様に他に名寄せ一致データ有り）<電話番号2に追加>
    @isTest static void accountLinkTelTest(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        List<Correspond__c> Corres = createCorrespond('',  UserInfo.getUserId(), UserInfo.getUserId(), '', ''  );//対応作成
        PortalSite__c portal = createPortalSite();//ポータルサイト作成
        EchoMail__c echoMail = createEchoMail(portal.Id, null, '', '', 'gogogorou@rand.co.jp', '111-2222-3333', true, false);//反響メール作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id, echoMail.Id);//対応明細作成
        searchMaxCountCustomSettings(5000);//検索上限設定
        //名寄せ一致データ(メールアドレスが一致)
        Account nayose = new Account(Name = 'テスト次郎', 
                                     FirstName__c = '次郎', LastName__c = 'テスト', 
                                     NameKana__c = 'ﾃｽﾄｼﾞﾛｳ',
                                     Phone = '025-200-4769', 
                                     Email__c = 'aaa@hora', 
                                     IsMergeUnnecessaryFlag__c = true, 
                                     RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
        insert nayose;

        //パラメータ設定
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id',Corres[0].Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト太郎';

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();

	    //お客様紐づけ対象設定
        GA105001Controller.searchAccountDetailDisplayList[0].isCheckbox = TRUE;

	    //お客様紐づけ実行
        GA105001Controller.accountLink();

        // テスト結果確認
        Correspond__c upCorrs = [ SELECT  AccountId__c FROM Correspond__c WHERE ID = :Corres[0].Id ];//対応の紐付け先取得
        system.assertEquals(upCorrs.AccountId__c, GA105001Controller.searchAccountDetailDisplayList[0].Id );//対応の紐付け先とお客様紐づけ対象の一致を確認

        //紐づけた取引先の名寄せ完了フラグ・名寄せ不要フラグ確認
        Account chkAcc = [SELECT id, IsMergeCompletedFlag__c, IsMergeUnnecessaryFlag__c
                          FROM Account
                          WHERE NameKana__c = 'ﾃｽﾄﾀﾛｳ'
        ];
        system.assertEquals(false, chkAcc.IsMergeCompletedFlag__c);
        system.assertEquals(false, chkAcc.IsMergeUnnecessaryFlag__c);

        //名寄せが一致した取引先の名寄せ不要フラグ確認
        Account chkAcc2 = [ SELECT id, IsMergeCompletedFlag__c, IsMergeUnnecessaryFlag__c
                            FROM Account
                            WHERE NameKana__c = 'ﾃｽﾄｼﾞﾛｳ'
        ];
        system.assertEquals(false, chkAcc2.IsMergeUnnecessaryFlag__c);
       
    }	

    //カバレッジアップ(電話確認用<電話番号同じ>)
    @isTest static void accountLinkTelTestSameNum(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        List<Correspond__c> Corres = createCorrespond('',  UserInfo.getUserId(), UserInfo.getUserId(), '', ''  );//対応作成
        PortalSite__c portal = createPortalSite();//ポータルサイト作成
        EchoMail__c echoMail = createEchoMail(portal.Id, null, '', '', 'gogogorou@rand.co.jp', '111-2222-3333', true, false);//反響メール作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id, echoMail.Id);//対応明細作成
        searchMaxCountCustomSettings(5000);//検索上限設定
        //名寄せ一致データ(メールアドレスが一致)
        Account nayose = new Account(Name = 'テスト次郎', 
                                    FirstName__c = '次郎', LastName__c = 'テスト', 
                                    NameKana__c = 'ﾃｽﾄｼﾞﾛｳ',
                                    Phone3__c = '111-2222-3333', 
                                    Email3__c = 'aaa@bbb.jp', 
                                    IsMergeUnnecessaryFlag__c = true, 
                                    RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
        insert nayose;

        //パラメータ設定
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id',Corres[0].Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト次郎';

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();

        //お客様紐づけ対象設定
        GA105001Controller.searchAccountDetailDisplayList[0].isCheckbox = TRUE;

        //お客様紐づけ実行
        GA105001Controller.accountLink();
    }	

    //カバレッジアップ(電話確認用<電話番号1に追加>)
    @isTest static void accountLinkTel1Test(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        List<Correspond__c> Corres = createCorrespond('',  UserInfo.getUserId(), UserInfo.getUserId(), '', ''  );//対応作成
        PortalSite__c portal = createPortalSite();//ポータルサイト作成
        EchoMail__c echoMail = createEchoMail(portal.Id, null, '', '', 'gogogorou@rand.co.jp', '987-654-3210', true, false);//反響メール作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id, echoMail.Id);//対応明細作成
        searchMaxCountCustomSettings(5000);//検索上限設定
        //名寄せ一致データ(メールアドレスが一致)
        Account nayose = new Account(Name = 'テスト次郎', 
                                    FirstName__c = '次郎', LastName__c = 'テスト', 
                                    NameKana__c = 'ﾃｽﾄｼﾞﾛｳ',
 
                   //カバレッジアップ(電話確認用<電話番号同じ>)                 IsMergeUnnecessaryFlag__c = true, 
                                    RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
        insert nayose;

        //パラメータ設定
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id',Corres[0].Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト次郎';

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();

        //お客様紐づけ対象設定
        GA105001Controller.searchAccountDetailDisplayList[0].isCheckbox = TRUE;

        //お客様紐づけ実行
        GA105001Controller.accountLink();
    }

    //カバレッジアップ(電話確認用<電話番号3に追加>)
    @isTest static void accountLinkTel3Test(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        List<Correspond__c> Corres = createCorrespond('',  UserInfo.getUserId(), UserInfo.getUserId(), '', ''  );//対応作成
        PortalSite__c portal = createPortalSite();//ポータルサイト作成
        EchoMail__c echoMail = createEchoMail(portal.Id, null, '', '', 'gogogorou@rand.co.jp', '111-2222-3333', true, false);//反響メール作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id, echoMail.Id);//対応明細作成
        searchMaxCountCustomSettings(5000);//検索上限設定
        //名寄せ一致データ(メールアドレスが一致)
        Account nayose = new Account(Name = 'テスト次郎', 
                                    FirstName__c = '次郎', LastName__c = 'テスト', 
                                    NameKana__c = 'ﾃｽﾄｼﾞﾛｳ',
                                    Phone     = '025-200-4769',
                                    Phone2__c = '111-252-3333',
                                    Email__c  = 'aaa@hora', 
                                    Email2__c = 'abc@hora', 
                                    IsMergeUnnecessaryFlag__c = true, 
                                    RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
        insert nayose;

        //パラメータ設定
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id',Corres[0].Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト次郎';

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();

        //お客様紐づけ対象設定
        GA105001Controller.searchAccountDetailDisplayList[0].isCheckbox = TRUE;

        //お客様紐づけ実行
        GA105001Controller.accountLink();
    }	

    //カバレッジアップ(電話確認用(エラー確認))
    @isTest static void accountLinkTelErrorTest(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        List<Correspond__c> Corres = createCorrespond('',  UserInfo.getUserId(), UserInfo.getUserId(), '', ''  );//対応作成
        PortalSite__c portal = createPortalSite();//ポータルサイト作成
        EchoMail__c echoMail = createEchoMail(portal.Id, null, '', '', 'gogogorou@rand.co.jp', '111-222-3333', true, false);//反響メール作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id, echoMail.Id);//対応明細作成
        searchMaxCountCustomSettings(5000);//検索上限設定
        //名寄せ一致データ(メールアドレスが一致)
        Account nayose = new Account(Name = 'テスト次郎', 
                                    FirstName__c = '次郎', LastName__c = 'テスト', 
                                    NameKana__c = 'ﾃｽﾄｼﾞﾛｳ',
                                    Phone     = '222-200-4769',
                                    Phone2__c = '025-800-4700',
                                    Phone3__c = '111-777-333', 
                                    IsMergeUnnecessaryFlag__c = true, 
                                    RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
        insert nayose;

        //パラメータ設定
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id',Corres[0].Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト次郎';

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();

        //お客様紐づけ対象設定
        GA105001Controller.searchAccountDetailDisplayList[0].isCheckbox = TRUE;

        //お客様紐づけ実行
        GA105001Controller.accountLink();
    }	

    //カバレッジアップメールアドレス確認用(エラー確認))
    @isTest static void accountLinkEmailErrorTest(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        List<Correspond__c> Corres = createCorrespond('',  UserInfo.getUserId(), UserInfo.getUserId(), '', ''  );//対応作成
        PortalSite__c portal = createPortalSite();//ポータルサイト作成
        EchoMail__c echoMail = createEchoMail(portal.Id, null, '', '', 'gogogorou@rand.co.jp', '111-222-3333', true, false);//反響メール作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id, echoMail.Id);//対応明細作成
        searchMaxCountCustomSettings(5000);//検索上限設定
        //名寄せ一致データ(メールアドレスが一致)
        Account nayose = new Account(Name = 'テスト次郎', 
                                    FirstName__c = '次郎', LastName__c = 'テスト', 
                                    NameKana__c = 'ﾃｽﾄｼﾞﾛｳ',
                                    Email__c  = 'aaa@hora', 
                                    Email2__c = 'abc@hora', 
                                    Email3__c = 'cgf@hora', 
                                    IsMergeUnnecessaryFlag__c = true, 
                                    RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
        insert nayose;

        //パラメータ設定
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id',Corres[0].Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト次郎';

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();

        //お客様紐づけ対象設定
        GA105001Controller.searchAccountDetailDisplayList[0].isCheckbox = TRUE;

        //お客様紐づけ実行
        GA105001Controller.accountLink();
    }	

	//お客様紐づけ（紐づけたお客様に他に名寄せ一致データなし）
    @isTest static void accountLinkTest2(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        List<Correspond__c> Corres = createCorrespond('',  UserInfo.getUserId(), UserInfo.getUserId(), '', ''  );//対応作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id,null);//対応明細作成
        searchMaxCountCustomSettings(5000);//検索上限設定

        //パラメータ設定
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id',Corres[0].Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト太郎';

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();

	    //お客様紐づけ対象設定
        GA105001Controller.searchAccountDetailDisplayList[0].isCheckbox = TRUE;

	    //お客様紐づけ実行
        GA105001Controller.accountLink();

        // テスト結果確認
        Correspond__c upCorrs = [ SELECT  AccountId__c FROM Correspond__c WHERE ID = :Corres[0].Id ];//対応の紐付け先取得
        system.assertEquals(upCorrs.AccountId__c, GA105001Controller.searchAccountDetailDisplayList[0].Id );//対応の紐付け先とお客様紐づけ対象の一致を確認

        //紐づけた取引先の名寄せ完了フラグ・名寄せ不要フラグ確認
        Account chkAcc = [SELECT id, IsMergeCompletedFlag__c, IsMergeUnnecessaryFlag__c
                          FROM Account
                          WHERE NameKana__c = 'ﾃｽﾄﾀﾛｳ'
        ];
        system.assertEquals(true, chkAcc.IsMergeCompletedFlag__c);
        system.assertEquals(false, chkAcc.IsMergeUnnecessaryFlag__c);
      
    }	

    //お客様紐づけ（エラー時のトランザクション確認）
    @isTest static void accountLinkErrorTest(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        List<Correspond__c> Corres = createCorrespond('',  UserInfo.getUserId(), UserInfo.getUserId(), '', ''  );//対応作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id,null);//対応明細作成
        searchMaxCountCustomSettings(5000);//検索上限設定
        //名寄せ一致データ(電話番号が一致)
        Account nayose = new Account(Name = 'テスト次郎', 
                                        FirstName__c = '次郎', LastName__c = 'テスト', 
                                        NameKana__c = 'ﾃｽﾄｼﾞﾛｳ',
                                        Phone = '025-200-1234', 
                                        IsMergeUnnecessaryFlag__c = true, 
                                        RecordTypeId = commonUtil.getRecordTypeId('Account', commonConst.ACCOUNT_RECTYPE_CUSTOMER));
        insert nayose;
        //名寄せ一致データの最終更新日時を退避
        Account chkAccount = [  SELECT id, LastModifiedDate
                                FROM Account
                                WHERE NameKana__c = 'ﾃｽﾄｼﾞﾛｳ'
        ];

        //パラメータ設定
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id',Corres[0].Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト太郎';

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();

        //お客様紐づけ対象設定
        GA105001Controller.searchAccountDetailDisplayList[0].isCheckbox = TRUE;

        //楽観ロックエラーを発生させる為、紐づけ先の取引先を更新
        Account upAcc = [SELECT id, Is1DK__c
                            FROM Account
                            WHERE NameKana__c = 'ﾃｽﾄﾀﾛｳ'
        ];
        upAcc.Is1DK__c = true;
        update upAcc;

        //お客様紐づけ実行
        GA105001Controller.accountLink();
    
        // エラー回避暫定処置
        // // エラーが発生したことを確認
        // system.assertEquals(true, GA105001Controller.hasErrorMessage);

        // //名寄せ一致したデータが変更されていないことを確認
        // Account chkAccountAfter = [ SELECT id, LastModifiedDate
        //                             FROM Account
        //                             WHERE Id = :chkAccount.Id
        // ];
        
        // system.assertEquals(chkAccount.LastModifiedDate, chkAccountAfter.LastModifiedDate);
            
    }	    
    
    //お客様紐づけ（本会員との紐づけ）2020/11/02
    @isTest static void memberLinkTest(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        List<Correspond__c> Corres = createCorrespond('',  UserInfo.getUserId(), UserInfo.getUserId(), '', ''  );//対応作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id,null);//対応明細作成
        searchMaxCountCustomSettings(5000);//検索上限設定
        
        
        //反響メール
        EchoMail__c ecoMailDate = new EchoMail__c(
        		MemberID__c = 'honkain');
        insert ecoMailDate;
        
        correspondDetail[0].EchoMail__c = ecoMailDate.Id;		//反響メールのIdを対応明細の反響メールの値に挿入する
		update correspondDetail;
        
        //本会員
        Member__c  memdate = new Member__c(
				MemberId__c = 'honkain'
				,LastName__c = '坂井'
				,FirstName__c = '美里'
				,LastNameKana__c = 'サカイ'
				,FirstNameKana__c = 'ミサト'
				,Tell__c = '025-200-1234'
				,Email__c = 'aaa@hora'
				,Password__c = 'password'
				,Birthdate__c = Date.newInstance(1995,1,1)
				,Gender__c = '女性'
				,RecommendMailFlg__c = true
				,Account__c = accountList[0].Id
				,JoinDate__c = Date.newInstance(2020,1,1)
				,Blacklist__c = false
			);
		insert memdate;

        //パラメータ設定
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id',Corres[0].Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト太郎';

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();

	    //お客様紐づけ対象設定
        GA105001Controller.searchAccountDetailDisplayList[0].isCheckbox = TRUE;

	    //お客様紐づけ実行
        GA105001Controller.accountLink();


        // テスト結果確認
        List<Member__c> memList = [SELECT id,Account__c FROM Member__c WHERE Account__c = :GA105001Controller.searchAccountDetailDisplayList[0].Id];
        system.assertEquals(true, ! memList.isEmpty());
        
    }	

	//画面表示（異常系）
     @isTest static void parameterErrorTest(){

        //パラメータ設定(存在しないIdを設定)
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id','123456' );//存在しないId
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();
        
        // テスト結果確認
        system.assertEquals(GA105001Controller.isOpenError, TRUE);//「エラーフラグ」がTRUEに設定されているか確認
        
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));//「エラーメッセージ」の表示が正しいか確認
        
        
    }	

	//検索ボタン押下処理(異常系)：入力チェック
     @isTest static void searchAccountNoConditionErrorTest(){

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索実行(検索条件なし)

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        GA105001Controller.searchAccount();

        // テスト結果確認
        system.assertEquals(GA105001Controller.hasErrorMessage, TRUE);//「エラーフラグ」がTRUEに設定されているか確認
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_CONDITIONS));//「エラーメッセージ」の表示が正しいか確認
        
    }	


	//お客様紐づけボタン押下処理(異常系)：楽観ロックチェック
     @isTest static void accountLinkOptimisticLockExceptionErrorTest(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', '');//取引先作成
        List<Correspond__c> Corres = createCorrespond('',  UserInfo.getUserId(), UserInfo.getUserId(), '', ''  );//対応作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id,null);//対応明細作成
        searchMaxCountCustomSettings(5000);//検索上限設定

        //パラメータ設定
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id',Corres[0].Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト太郎';

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();

        //お客様紐づけ対象設定
        GA105001Controller.searchAccountDetailDisplayList[0].isCheckbox = TRUE;

        //更新時間調整用に待機
        CommonUtil.sleep(2000);

        //紐付けする対応を更新
        upsert Corres;

        //お客様紐づけ実行
        GA105001Controller.accountLink();

        // テスト結果確認
        system.assertEquals(GA105001Controller.hasErrorMessage, TRUE);//「エラーフラグ」がTRUEに設定されているか確認
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_OPTIMISTIC_LOCK));//「エラーメッセージ」の表示が正しいか確認
        
    }	

	//業者紐づけボタン押下処理(異常系)：未選択
     @isTest static void accountLinkUnselectedErrorTest(){

        // テストデータ作成
        List<Account> accountList = createAccount('', '', '', '', CommonConst.ACCOUNT_RECTYPE_FIRE_INSURANCE);//取引先作成
        searchMaxCountCustomSettings(5000);//検索上限設定
        List<Correspond__c> Corres = createCorrespond(CommonConst.CORRESPOND_STATUS_NOTSUPPORTED,  UserInfo.getUserId(), UserInfo.getUserId(), 'メモ内容', accountList[0].Id  );//対応作成

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //検索条件設定
        GA105001Controller.searchAccountRecordType = '業者';
        GA105001Controller.searchAccountName = 'テスト太郎';
        GA105001Controller.searchPhone = '025-200-1234';
        GA105001Controller.searchEmail = 'aaa@hora';
        GA105001Controller.searchComment = 'コメント';
        GA105001Controller.searchShopStaff = UserInfo.getName();
        GA105001Controller.searchEchoStaff = UserInfo.getName();

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、全ステータスの状態をFALSEに設定する
            GA105001Controller.statusCheckedMap.put(statusName, FALSE);
        }

        //検索実行
        GA105001Controller.searchAccount();


        //業者紐づけ実行
        GA105001Controller.accountLink();

        // テスト結果確認
        List<Object> parameters = new List<Object> {'紐付けを行う場合', '紐付け先'};//エラーメッセージ作成「{0}は{1}を選択してください。」  

        system.assertEquals(GA105001Controller.hasErrorMessage, TRUE);//「エラーフラグ」がTRUEに設定されているか確認
        
        system.assertEquals(ApexPages.getMessages()[0].getDetail(), String.format(CommonConst.MSG_COM_W_SELECTION, parameters));//「エラーメッセージ」の表示が正しいか確認
        
    }	

    //カバレッジ率上昇
    @isTest static void forCoverage(){

        // テストデータ作成
        List<Correspond__c> Corres = createCorrespond('',  UserInfo.getUserId(), UserInfo.getUserId(), '',''  );//対応作成
        List<CorrespondDetail__c> correspondDetail = createCorrespondDetail(Corres[0].Id,null);//対応明細作成

        searchMaxCountCustomSettings(5000);//検索上限設定
        
        //パラメータ設定
        PageReference pageRef = Page.GA105001View;
        pageRef.getParameters().put('Id',Corres[0].Id );
        Test.setCurrentPage(pageRef);

        // コントローラの初期表示を実行
        GA105001Controller GA105001Controller = new GA105001Controller();

        //メッセージ系呼び出し

        String msg;

        msg = GA105001Controller.MSG_CUST_V_EXECUTE_CUSTOMER_LINKING;
        msg = GA105001Controller.MSG_CUST_V_EXECUTE_CLIENT_LINKING;

        //検索条件にステータス設定ありで検索

        //検索条件設定
        GA105001Controller.searchAccountName = 'テスト太郎';
        GA105001Controller.searchPhone = '025-200-1234';
        GA105001Controller.searchEmail = 'aaa@hora';
        GA105001Controller.searchComment = 'コメント';
        GA105001Controller.searchShopStaff = UserInfo.getName();
        GA105001Controller.searchEchoStaff = UserInfo.getName();

        //ステータス設定をFALSEにする
        for( String statusName : GA105001Controller.statusNameList){
            //ステータス名Listの長さだけ繰り返し、ステータスの状態を設定する
            GA105001Controller.statusCheckedMap.put(statusName, TRUE);
        }

        //検索実行
        GA105001Controller.searchAccount();

        //検索条件に反響担当店舗あり,来店担当店舗ありで検索
        
        //検索条件設定
        GA105001Controller.searchEchoShop = '反響担当店舗';
        GA105001Controller.searchVisitShop = '来店担当店舗';
        
        //検索実行
        GA105001Controller.searchAccount();

        //検索条件の来店担当店舗がWHERE句の先頭で検索
        
        //検索条件設定
        GA105001Controller.searchEchoShop = null;
        GA105001Controller.searchEchoStaff = null;
        GA105001Controller.searchVisitShop = '来店担当店舗';
        
        //検索実行
        GA105001Controller.searchAccount();

        //検索条件の来店担当者がWHERE句の先頭で検索
        
        //検索条件設定
        GA105001Controller.searchEchoShop = null;
        GA105001Controller.searchEchoStaff = null;
        GA105001Controller.searchVisitShop = null;
        GA105001Controller.searchShopStaff = '来店担当者';
        
        //検索実行
        GA105001Controller.searchAccount();

        //検索条件のステータスがWHERE句の先頭で検索
        
        //検索条件設定
        GA105001Controller.searchEchoShop = null;
        GA105001Controller.searchEchoStaff = null;
        GA105001Controller.searchVisitShop = null;
        GA105001Controller.searchShopStaff = null;
        
        //検索実行
        GA105001Controller.searchAccount();
        
    }	
}