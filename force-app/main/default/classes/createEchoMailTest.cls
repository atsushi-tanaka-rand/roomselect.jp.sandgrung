@isTest
private with sharing class createEchoMailTest {

    /**
    * テストに使用するレコードを作成する
    */
    @TestSetup static void setting(){

        List<PortalSite__c> portalSiteList = new List<PortalSite__c>();
        List<Property__c> propertyList = new List<Property__c>();

        // 建物
        Building__c BuildingRecord = new Building__c( Name = '対応テスト建物'   // 建物名
                                                    , District__c = '港区'      // 地区
        );     
        insert BuildingRecord;

        // 物件
        Property__c PropertyRecord = new Property__c( Name = '物件コード用'                      // 部屋番号
                                                    , Building__c = BuildingRecord.Id   // 建物
                                                  
        );
        propertyList.add(PropertyRecord);
        // 物件
        PropertyRecord = new Property__c( Name = 'ポータルサイト物件コード用'                      // 部屋番号
                                                    , Building__c = BuildingRecord.Id   // 建物
                                                  
        ); 
        propertyList.add(PropertyRecord); 
        insert propertyList;

		// 2022/3/23 システム設定にアドレスが正常に登録されていなかったため、createPortalSite()へ独立させ転記。

        // 店舗１
        Shop__c shop1 = new Shop__c(  Name = 'テスト１店'                                        // 名前
                                    , Email__c = 'toTESTShop1@TEST.co.jp'                       // メール 
                                    , EmailSF__c = 'toTESTShop1@abcde12345apex.salesforce.com'  // メール(SF) 
        );
        // 店舗２
        Shop__c shop2 = new Shop__c(  Name = 'テスト２店'                                        // 名前
                                    , Email__c = 'toTESTShop2@TEST.co.jp'                       // メール 
                                    , EmailSF__c = 'toTESTShop2@abcde12345apex.salesforce.com'  // メール(SF) 
        );
        List<Shop__c> shopList = new List<Shop__c>{
             shop1
            ,shop2
        };
        insert shopList;
    }

    
    private static void afterInsertOutput() {
        // 反響メール登録後の登録値確認用デバッグログ
        List<String> result = New List<String>{};
        Map<String, Schema.SObjectField> echoMailFieldMap = Schema.getGlobalDescribe().get('EchoMail__c').getDescribe().fields.getMap();
        for(String s: echoMailFieldMap.keySet()) {
            // カスタム項目だけ選択
            if (s.endsWith('__c')) {
                result.add(s);
            }
        }
        List<EchoMail__c> echoMail = Database.query(
        ' SELECT ID, Name, ' + String.join(result, ',') +' FROM EchoMail__c');

        for (EchoMail__c data : echoMail) {
            system.debug('カスタムオブジェクト ID：' + data.Id);
            system.debug('お客様名：' + data.CustomerName__c);
            system.debug('電話番号：' + data.Phone__c);
            system.debug('Fax：' + data.Fax__c);
            system.debug('メール：' + data.Email__c);
            system.debug('反響日：' + data.ResponseDate__c);
            system.debug('Fromメールアドレス：' + data.FromEmail__c);
            system.debug('Fromポータルサイト：' + data.FromPotalSite__c);
            system.debug('SUUMOID：' + data.SuumoId__c);
            system.debug('お問合せ日時：' + data.InquiryDateTime__c);
            system.debug('ポータルサイト番号：' + data.PortalSiteNo__c);
            system.debug('お問合せ企画：' + data.InquiryPlan__c);
            system.debug('反響送付先区分：' + data.ResponseSendType__c);
            system.debug('反響送付先コード：' + data.ResponseSendCode__c);
            system.debug('会社名：' + data.CompanyName__c);
            system.debug('物件種別：' + data.PropertyType__c);
            system.debug('ポータルサイト物件コード：' + data.PortalSitePropertyCode__c);
            system.debug('物件名：' + data.PropertyName__c);
            system.debug('物件コード：' + data.PropertyCode__c);
            system.debug('最寄駅：' + data.ClosestStation__c);
            system.debug('バス：' + data.BusTime__c);
            system.debug('徒歩：' + data.WalkTime__c);
            system.debug('所在地：' + data.PropertyAddress__c);
            system.debug('賃料：' + data.RentFee__c);
            system.debug('間取り：' + data.RoomLayout__c);
            system.debug('面積：' + data.PropertyArea__c);
            system.debug('物件URL：' + data.PropertURL__c);
            system.debug('連絡方法：' + data.ContactMeans__c);
            system.debug('お問合せ内容：' + data.InquiryContent__c);
            system.debug('物件：' + data.Response__c);
            system.debug('お客様名（カナ）：' + data.CustomerNameKana__c);
            system.debug('件名：' + data.Subject__c);
            // system.debug('本文：' + data.Body__c); // ログが見にくくなるのでコメントアウト
            system.debug('交通：' + data.Transportation__c);
            system.debug('バス停名：' + data.BusStop__c);
            system.debug('バス乗車分：' + data.BusRideTime__c);
            system.debug('不動産会社名（元付）：' + data.FormerSupplier__c);
            system.debug('電話番号（元付）：' + data.FormerSupplierPhone__c);
            system.debug('メールアドレス（元付）：' + data.FormerSupplierEmail__c);
            system.debug('土地面積：' + data.GroundArea__c);
            system.debug('担当スタッフ：' + data.Staff__c);
            system.debug('郵便番号：' + data.PostalCode__c);
            system.debug('住所：' + data.Address__c);
            system.debug('ご希望時間帯：' + data.DesiredTime__c);
            system.debug('その他の連絡方法：' + data.OtherContact__c);
            system.debug('性別：' + data.Sex__c);
            system.debug('年齢：' + data.Age__c);
            system.debug('入居希望時期：' + data.OccupancyDesiredSeason__c);
            system.debug('見学希望日時：' + data.VisitDesiredDateTime__c);
            system.debug('LINE＠ID：' + data.LineId__c);
            system.debug('LINEプロフィール名：' + data.LineName__c);
            system.debug('お問い合わせ理由：' + data.InquiryReason__c);
            system.debug('ケータイサイト用_物件URL：' + data.PropertMobileURL__c);
            system.debug('ＡＴＢＢのアドレス：' + data.ATBBURL__c);
            system.debug('MessageId：' + data.MessageId__c);
            system.debug('References：' + data.References__c);
        }
    }

    @IsTest
    static void mailTestOther() {
        system.debug('～～～～～～～～～～～ その他テストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = 'other@text.co.jp';
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = '洞口新瑞橋店\n';
        mailText = mailText + 'ROOM SELECT新瑞橋店(株)洞口  緒方俊也様\n';
        mailText = mailText + '反響到着日時　2019/08/25 07:08:11\n';
        mailText = mailText + '\n';
        mailText = mailText + 'ＩＤ：111969501303\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お問合せ日時：2019/9/25 07:08:11\n';
        mailText = mailText + '連番：0042141526\n';
        mailText = mailText + 'お問合せ企画：ＳＵＵＭＯネット／賃貸物件枠問い合わせ（モバイル）\n';
        mailText = mailText + '反響送付先区分：会社\n';
        mailText = mailText + '反響送付先コード：11969501303\n';
        mailText = mailText + '\n';
        mailText = mailText + '☆☆☆　お客様からの反響です　☆☆☆\n';
        mailText = mailText + '\n';
        mailText = mailText + '※お問合せ内容に従ってお客様へご連絡お願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '問合せ物件\n';
        mailText = mailText + '会社名：ROOM SELECT新瑞橋店(株)洞口\n';
        mailText = mailText + '物件種別：アパート\n';
        mailText = mailText + '物件コード：' + property[0].PropertyCode__c + '\n';
        mailText = mailText + '物件名：仮）D-room南区西桜町101\n';
        mailText = mailText + '貴社物件コード：160512\n';
        mailText = mailText + '最寄り駅：名鉄名古屋本線/本笠寺\n';
        mailText = mailText + 'バス／歩：-／4分\n';
        mailText = mailText + '所在地：愛知県名古屋市南区西桜町\n';
        mailText = mailText + '賃料：8.2万円\n';
        mailText = mailText + '間取り：1LDK\n';
        mailText = mailText + '専有面積：52.11平米\n';
        mailText = mailText + '物件詳細画面：https://suumo.jp/chintai/bc_100161634439/\n';
        mailText = mailText + '\n';
        mailText = mailText + '－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お客様プロフィール\n';
        mailText = mailText + '名前（漢字）：不動産　花子\n';
        mailText = mailText + '名前（カナ）：\n';
        mailText = mailText + 'メールアドレス：hudousan@roomselect.jp\n';
        mailText = mailText + 'ＴＥＬ：000-0000-0000\n';
        mailText = mailText + 'FAX：000-000-0000\n';
        mailText = mailText + '連絡方法：メール\n';
        mailText = mailText + 'お問合せ内容：この部屋の最新の空室状況を知りたい\n';
        mailText = mailText + '\n';
        mailText = mailText + '－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－';

        email.plainTextBody = mailText;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ その他テストクラス終了 ～～～～～～～～～～～');
    }

	@IsTest
    static void mailTestSumo() {
        system.debug('～～～～～～～～～～～ スーモテストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_SUMO;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = '洞口新瑞橋店\n';
        mailText = mailText + 'ROOM SELECT新瑞橋店(株)洞口  緒方俊也様\n';
        mailText = mailText + '反響到着日時　2019/08/25 07:08:11\n';
        mailText = mailText + '\n';
        mailText = mailText + 'ＩＤ：111969501303\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お問合せ日時：2019/9/25 07:08:11\n';
        mailText = mailText + '連番：0042141526\n';
        mailText = mailText + 'お問合せ企画：ＳＵＵＭＯネット／賃貸物件枠問い合わせ（モバイル）\n';
        mailText = mailText + '反響送付先区分：会社\n';
        mailText = mailText + '反響送付先コード：11969501303\n';
        mailText = mailText + '\n';
        mailText = mailText + '☆☆☆　お客様からの反響です　☆☆☆\n';
        mailText = mailText + '\n';
        mailText = mailText + '※お問合せ内容に従ってお客様へご連絡お願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '問合せ物件\n';
        mailText = mailText + '会社名：ROOM SELECT新瑞橋店(株)洞口\n';
        mailText = mailText + '物件種別：アパート\n';
        mailText = mailText + '物件コード：物件コード：ポータルサイト物件番号12345\n';
        mailText = mailText + '物件名：仮）D-room南区西桜町101\n';
        mailText = mailText + '貴社物件コード：' + property[0].PropertyCode__c + '\n';
        mailText = mailText + '最寄り駅：名鉄名古屋本線/本笠寺\n';
        mailText = mailText + 'バス／歩：-／4分\n';
        mailText = mailText + '所在地：愛知県名古屋市南区西桜町\n';
        mailText = mailText + '賃料：8.2万円\n';
        mailText = mailText + '間取り：1LDK\n';
        mailText = mailText + '専有面積：52.11平米\n';
        mailText = mailText + '物件詳細画面：https://suumo.jp/chintai/bc_100161634439/\n';
        mailText = mailText + '\n';
        mailText = mailText + '－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お客様プロフィール\n';
        mailText = mailText + '名前（漢字）：不動産　花子\n';
        mailText = mailText + '名前（カナ）：\n';
        mailText = mailText + 'メールアドレス：hudousan@roomselect.jp\n';
        mailText = mailText + 'ＴＥＬ：000-0000-0000\n';
        mailText = mailText + 'FAX：000-000-0000\n';
        mailText = mailText + '連絡方法：メール\n';
        mailText = mailText + 'お問合せ内容：この部屋の最新の空室状況を知りたい\n';
        // 問合せ323で追加
        mailText = mailText + 'お問合せ内容コメント：この部屋の最新の空室状況を知りたい\n';
        mailText = mailText + '\n';
        mailText = mailText + '－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－';

        email.plainTextBody = mailText;

        //添付ファイルの生成
        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.txt';
        String algorithmName = 'HMacSHA1';
        Blob b = Crypto.generateMac(algorithmName, Blob.valueOf('test'), Blob.valueOf('test_key'));
        binaryAttachment.Body = b;
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ スーモテストクラス終了 ～～～～～～～～～～～');
    }

    @IsTest
    static void mailTestHomes() {
        system.debug('～～～～～～～～～～～ ホームズテストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_HOMES;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = 'ROOM SELECT中村本陣店 株式会社洞口様\n';
        mailText = mailText + '\n';
        mailText = mailText + '◆◇━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '　お客様より下記内容のお問合せがありました。\n';
        mailText = mailText + '　ご確認の上、ご連絡をお願いいたします。\n';
        mailText = mailText + '　　　　　　　2019/08/23 16:00:49　　　\n';
        // mailText = mailText + '          2019/08/23 16:00:49\n';
        mailText = mailText + '　━━━━━━━━━━━━━━━━━━━━━━◇◆\n';
        mailText = mailText + '\n';
        mailText = mailText + '下記URLをクリックすると問合せ物件の詳細を見ることができます。\n';
        mailText = mailText + 'https://www.homes.co.jp/chintai/b-1384850011276/\n';
        mailText = mailText + '\n';
        mailText = mailText + '　　　物件種別：賃貸 マンション\n';
        mailText = mailText + '　　　　物件名：横電千成ビル\n';
        mailText = mailText + '　　　　　賃料：5.6万円\n';
        mailText = mailText + '　　　　所在地：愛知県名古屋市中村区千成通6丁目\n';
        mailText = mailText + '　　　　　交通：名古屋市営東山線 岩塚駅\n';
        mailText = mailText + '　　　　　面積：32.8m2\n';
        mailText = mailText + '　　　　　間取：ワンルーム\n';
        mailText = mailText + '　　　物件番号：物件コード：ポータルサイト物件番号12345\n';    
        mailText = mailText + '　自社管理番号：'+ property[0].PropertyCode__c + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '　　問合せ番号：25508006\n';
        mailText = mailText + '\n';
        mailText = mailText + '　　　　　名前：不動産　花子\n';
        mailText = mailText + 'メールアドレス：hudousan@roomselect.jp\n';
        mailText = mailText + '　　　電話番号：00000000000\n';
        mailText = mailText + '　お問合せ内容：物件を実際に見たい\n';
        mailText = mailText + '\n';
        // ▼問合せ323で追加
        mailText = mailText + '　備考：物件を実際に見たい\n';
        mailText = mailText + '　【見学予約問合せ】：物件を実際に見たい\n';
        // ▲問合せ323で追加
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '　LIFULL HOME\'Sではお客様からのお問合せについて\n';
        mailText = mailText + '　３営業日以内の返信をお願いしています。\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '　効果的な対応メールの作成方法を動画でご紹介中。\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '申込不要で今すぐ利用可能！無料のe-learning基本コース\n';
        mailText = mailText + '\n';
        mailText = mailText + '>>>e-learning視聴画面はこちら【パスワード： homesfree1 】\n';
        mailText = mailText + 'http://www.homes.co.jp/homesfree\n';
        mailText = mailText + '\n';
        mailText = mailText + '■■■■■■■□□　サポートデスク　□□■■■■■■■\n';
        mailText = mailText + '\n';
        mailText = mailText + 'LIFULL HOME\'Sに関するご質問がございましたら、お気軽にご相談ください。\n';
        mailText = mailText + '\n';
        mailText = mailText + 'TEL：0120-462-389　09:00～19:00 (土・日・祝日を除く)\n';
        mailText = mailText + '※携帯電話からは　050-5577-7460　までお問合せください\n';
        mailText = mailText + 'E-MAIL：support@homes.co.jp　FAX：03-6862-9964\n';
        mailText = mailText + '\n';
        mailText = mailText + '株式会社LIFULL\n';
        mailText = mailText + '〒102-0083 東京都千代田区麹町1-4-4\n';
        mailText = mailText + '\n';
        mailText = mailText + '不動産・住宅情報サイト「LIFULL HOME\'S」 https://www.homes.co.jp/\n';

        email.plainTextBody = mailText;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ ホームズテストクラス終了 ～～～～～～～～～～～');
    }

    @IsTest
    static void mailTestAtHomeSumaho() {
        system.debug('～～～～～～～～～～～ アットホーム（スマホ）テストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_ATHOME;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = '';
        mailText = mailText + '□■アットホーム（スマートフォンサイト・アプリ） 　反響のお知らせ ■□\n';
        mailText = mailText + '\n';
        mailText = mailText + 'スマートフォンサイト・アプリで物件をご覧になった【お客様からの反響】です。\n';
        mailText = mailText + '下記の内容をご確認のうえ、お客様へのご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + 'なお、お問合せ情報の中には、ご本人の個人情報が含まれていますので、\n';
        mailText = mailText + 'お取り扱いには十分にご留意ください。なお、本個人情報は、資料の送付、\n';
        mailText = mailText + '問合せに対する連絡以外の目的では利用できません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'テスト物件名です　 御中\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お問合わせ日時：2020/02/26 16:00:49\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お問合せされた物件の概要＞\n';
        mailText = mailText + '物件種目　　　　　：アパート\n';
        mailText = mailText + '建物名　　　　　　：テスト建物名\n';
        mailText = mailText + '交通　　　　　　　：テスト交通名\n';
        mailText = mailText + '駅名　　　　　　　：テスト駅名\n';
        mailText = mailText + '\n';
        mailText = mailText + '徒歩　　　　　　　：徒歩５分\n';
        mailText = mailText + 'バス停名　　　　　：テストバス停名\n';
        mailText = mailText + 'バス乗車分　　　　：バス乗車１０分\n';
        mailText = mailText + 'バス停歩分　　　　：バス停徒歩２０分\n';
        mailText = mailText + '所在地　　　　　　：テスト所在地です\n';
        mailText = mailText + '価格　　　　　　　：999\n';
        mailText = mailText + '間取り　　　　　　：5SLDK+α\n';
        mailText = mailText + '専有・建物面積　　：専有面積100\n';
        mailText = mailText + '土地面積　　　　　：土地面積200\n';
        mailText = mailText + '\n';
        mailText = mailText + 'at home 物件番号　　：'+ property[1].Id + '\n';
        mailText = mailText + '貴社物件管理番号　　：'+ property[0].PropertyCode__c + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '担当スタッフ　　　　：テストスタッフ名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '詳しい物件情報はコチラ↓\n';
        mailText = mailText + '詳しい物件情報はこちらという欄を適当に変更\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お客様のプロフィール＞\n';
        mailText = mailText + '## 貸事務所/貸店舗/貸その他の場合\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '会社名　　　　　　　：テスト会社名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お名前・ご担当者様名：テストユーザ名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'メールアドレス　　　： testMailAdress@test.co.jp\n';
        mailText = mailText + '郵便番号　　　　　　：555-1111\n';
        mailText = mailText + '住所　　　　　　　　：テスト住所です\n';
        mailText = mailText + '電話番号　　　　　　：111-222-333\n';
        mailText = mailText + 'ご希望時間帯　　　　：希望時間帯は１９時以降です\n';
        mailText = mailText + 'その他の連絡方法　　：その他の連絡方法です\n';
        mailText = mailText + '\n';
        mailText = mailText + '性別　　　　　　　　：女性\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '入居希望時期　　　　：入居希望時期は春ごろです\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜物件に関するお問合せ内容＞\n';
        mailText = mailText + '物件に関するお問い合わせ内容の１行目です\n';
        mailText = mailText + '物件に関するお問い合わせ内容の２行目です\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '## 貸事務所/貸店舗/貸その他の場合\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '＜物件のお問い合わせ理由＞\n';
        mailText = mailText + '物件のお問い合わせ理由の１行目です\n';
        mailText = mailText + '物件のお問い合わせ理由の２行目です\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '\n';
        mailText = mailText + '☆お客さまのメール送信先が携帯アドレスの場合・・・\n';
        mailText = mailText + '　ドメイン指定で制御されている可能性がございます。\n';
        mailText = mailText + '　また、携帯へメールを送る際は、文字数の制限にご注意ください。\n';
        mailText = mailText + '\n';
        mailText = mailText + '■対応方法\n';
        mailText = mailText + '　３営業日以内に上記＜お客様のプロフィール＞にある連絡先まで\n';
        mailText = mailText + '　直接ご連絡くださいますようお願いいたします。\n';
        mailText = mailText + '　Ｅメールでのご返信は、＜お客様のプロフィール＞中にあるメール\n';
        mailText = mailText + '　アドレス宛になっているかを確認の上、お送りください。\n';
        mailText = mailText + '　※お客様が入力した情報をそのまま送信しておりますので、\n';
        mailText = mailText + '　　弊社でも＜お客様のプロフィール＞と同じ情報しかわかりません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '■反響メール返信文例集＆メール操作簡単ガイドなど\n';
        mailText = mailText + '　お客様対応に役立つ記事を掲載、下記ＵＲＬにアクセス！\n';
        mailText = mailText + '　http://atbb.athome.jp/customer/concierge/leftindex_sample.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このお知らせをFAXで受信されたアットホーム会員さまへ\n';
        mailText = mailText + '　このサービスをEメールで受信することも可能です。ぜひご登録を！\n';
        mailText = mailText + '　（アットホーム会員の方はご商号・ご住所・電話番号・Eメールを下記まで\n';
        mailText = mailText + '　お知らせください。\n';
        mailText = mailText + '　会員登録がない方は、ぜひアットホームへのご加盟をご検討ください。\n';
        mailText = mailText + '　詳細は下記ページをご覧ください。）\n';
        mailText = mailText + '　http://atbb.athome.jp/business/index.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このサービスはアットホーム(株)が行っております。\n';
        mailText = mailText + '　お心あたりのない方は、恐れ入りますが TEL 0120-134-855 まで\n';
        mailText = mailText + '　ご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';
        mailText = mailText + '　アットホーム カスタマーセンター\n';
        mailText = mailText + '　TEL : 0570-01-1967\n';
        mailText = mailText + '　※PHS・IP電話の方は、TEL.045-330-3410 まで\n';
        mailText = mailText + '　E-Mail : mailcenter@athome.jp\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';

        
        email.plainTextBody = mailText;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ アットホーム（スマホ）クラス終了 ～～～～～～～～～～～');
    }

    @IsTest
    static void mailTestAtHomePc() {
        system.debug('～～～～～～～～～～～ アットホーム（PC）テストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_ATHOME;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = '';
        mailText = mailText + '□■ アットホーム　インターネット　反響のお知らせ ■□\n';
        mailText = mailText + '\n';
        mailText = mailText + 'インターネットで物件をご覧になった【お客様からの反響】です。\n';
        mailText = mailText + '下記の内容をご確認のうえ、お客様へのご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + 'なお、お問合せ情報の中には、ご本人の個人情報が含まれていますので、\n';
        mailText = mailText + 'お取り扱いには十分にご留意ください。なお、本個人情報は、資料の送付、\n';
        mailText = mailText + '問合せに対する連絡以外の目的では利用できません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'テスト物件名です　 御中\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お問合わせ日時：2020/02/26 16:00:49\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お問合せされた物件の概要＞\n';
        mailText = mailText + '物件種目　　　　　：アパート\n';
        mailText = mailText + '建物名　　　　　　：テスト建物名\n';
        mailText = mailText + '交通　　　　　　　：テスト交通名\n';
        mailText = mailText + '駅名　　　　　　　：テスト駅名\n';
        mailText = mailText + '\n';
        mailText = mailText + '徒歩　　　　　　　：徒歩５分\n';
        mailText = mailText + 'バス停名　　　　　：テストバス停名\n';
        mailText = mailText + 'バス乗車分　　　　：バス乗車１０分\n';
        mailText = mailText + 'バス停歩分　　　　：バス停徒歩２０分\n';
        mailText = mailText + '所在地　　　　　　：テスト所在地です\n';
        mailText = mailText + '賃料　　　　　　　：999\n';
        mailText = mailText + '間取り　　　　　　：5SLDK+α\n';
        mailText = mailText + '専有面積　　　　　：専有面積100\n';
        mailText = mailText + '\n';
        mailText = mailText + 'at home 物件番号　　：'+ property[1].Id + '\n';
        mailText = mailText + '貴社物件管理番号　　：'+ property[0].PropertyCode__c + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '担当スタッフ　　　　：テストスタッフ名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '詳しい物件情報はコチラ↓\n';
        mailText = mailText + '詳しい物件情報はこちらという欄を適当に変更\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お客様のプロフィール＞\n';
        mailText = mailText + 'お名前　　　　　　　：テストユーザ名\n';
        mailText = mailText + '希望連絡方法　　　　：希望連絡方法は電話です\n';
        mailText = mailText + 'メールアドレス　　　： testMailAdress@test.co.jp\n';
        mailText = mailText + '電話番号　　　　　　：111-222-333\n';
        mailText = mailText + '連絡希望の時間帯　　：希望時間帯は１９時以降です\n';
        mailText = mailText + 'その他の連絡方法　　：その他の連絡方法です\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '性別　　　　　　　　：男性\n';
        mailText = mailText + '\n';
        mailText = mailText + '年齢　　　　　　　　：25歳\n';
        mailText = mailText + '\n';
        mailText = mailText + '入居希望時期　　　　：入居希望時期は春ごろです\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜物件に関するお問合せ内容＞\n';
        mailText = mailText + '物件に関するお問い合わせ内容の１行目です\n';
        mailText = mailText + '物件に関するお問い合わせ内容の２行目です\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '\n';
        mailText = mailText + '■対応方法\n';
        mailText = mailText + '　３営業日以内に上記＜お客様のプロフィール＞にある連絡先まで\n';
        mailText = mailText + '　直接ご連絡くださいますようお願いいたします。\n';
        mailText = mailText + '　Ｅメールでのご返信は、＜お客様のプロフィール＞中にあるメール\n';
        mailText = mailText + '　アドレス宛になっているかを確認の上、お送りください。\n';
        mailText = mailText + '　※お客様が入力した情報をそのまま送信しておりますので、\n';
        mailText = mailText + '　　弊社でも＜お客様のプロフィール＞と同じ情報しかわかりません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '■反響メール返信文例集＆メール操作簡単ガイドなど\n';
        mailText = mailText + '　お客様対応に役立つ記事を掲載、下記ＵＲＬにアクセス！\n';
        mailText = mailText + '　http://atbb.athome.jp/customer/concierge/leftindex_sample.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このお知らせをFAXで受信されたアットホーム会員さまへ\n';
        mailText = mailText + '　このサービスをEメールで受信することも可能です。ぜひご登録を！\n';
        mailText = mailText + '　（アットホーム会員の方はご商号・ご住所・電話番号・Eメールを下記まで\n';
        mailText = mailText + '　お知らせください。\n';
        mailText = mailText + '　会員登録がない方は、ぜひアットホームへのご加盟をご検討ください。\n';
        mailText = mailText + '　詳細は下記ページをご覧ください。）\n';
        mailText = mailText + '　http://atbb.athome.jp/business/index.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このサービスはアットホーム(株)が行っております。\n';
        mailText = mailText + '　お心あたりのない方は、恐れ入りますが TEL 0120-134-855 まで\n';
        mailText = mailText + '　ご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';
        mailText = mailText + '　アットホーム カスタマーセンター\n';
        mailText = mailText + '　TEL : 0570-01-1967\n';
        mailText = mailText + '　※PHS・IP電話の方は、TEL.045-330-3410 まで\n';
        mailText = mailText + '　E-Mail : mailcenter@athome.jp\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';

        email.plainTextBody = mailText;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ アットホーム（PC）クラス終了 ～～～～～～～～～～～');
    }

    @IsTest
    static void mailTestAtHomeEnjin() {
        system.debug('～～～～～～～～～～～ アットホーム（エンジンレンタル）テストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_ATHOME;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = '';
        mailText = mailText + '\n';
        mailText = mailText + '□■ アットホーム　検索エンジンレンタル（PC）　反響のお知らせ ■□　\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '　アットホーム 検索エンジンレンタルサービスをご利用いただいております、\n';
        mailText = mailText + '　貴社ホームページで物件をご覧になった【お客様からの反響】です。\n';
        mailText = mailText + '　下記の内容をご確認のうえ、お客様へのご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '　なお、お問合せ情報の中には、ご本人の個人情報が含まれていますので、\n';
        mailText = mailText + '　お取り扱いには十分にご留意ください。なお、本個人情報は、資料の送付、\n';
        mailText = mailText + '　問合せに対する連絡以外の目的では利用できません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'テスト物件名です　 御中\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お問合わせ日時：2020/02/26 16:00:49\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お問合せされた物件の概要＞\n';
        mailText = mailText + '物件種目　　　　　：アパート\n';
        mailText = mailText + '建物名　　　　　　：テスト建物名\n';
        mailText = mailText + '交通　　　　　　　：テスト交通名\n';
        mailText = mailText + '駅名　　　　　　　：テスト駅名\n';
        mailText = mailText + '\n';
        mailText = mailText + '徒歩　　　　　　　：徒歩５分\n';
        mailText = mailText + 'バス停名　　　　　：テストバス停名\n';
        mailText = mailText + 'バス乗車分　　　　：バス乗車１０分\n';
        mailText = mailText + 'バス停歩分　　　　：バス停徒歩２０分\n';
        mailText = mailText + '所在地　　　　　　：テスト所在地です\n';
        mailText = mailText + '賃料　　　　　　　：999\n';
        mailText = mailText + '間取り　　　　　　：5SLDK+α\n';
        mailText = mailText + '専有面積　　　　　：専有面積100\n';
        mailText = mailText + '\n';
        mailText = mailText + '不動産会社名（元付）　：テスト不動産会社名です\n';
        mailText = mailText + '電話番号（元付）　　　：999-1111-2222\n';
        mailText = mailText + 'メールアドレス（元付）： motoduke@test.co.jp\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'at home 物件番号　　：'+ property[1].Id + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '貴社物件管理番号　　：'+ property[0].PropertyCode__c + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '担当スタッフ　　　　：テストスタッフ名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '物件の詳細に関しましては、ＡＴＢＢの物件入手の物件番号検索をご利用ください。\n';
        mailText = mailText + '<ＡＴＢＢのアドレス>\n';
        mailText = mailText + 'ＵＲＬ：http://atbb.athome.jp/\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'エンジンレンタルに公開されている物件情報はコチラ↓\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '詳しい物件情報はこちらという欄を適当に変更\n';
        mailText = mailText + '\n';
        mailText = mailText + '※モバイルプランのためＰＣサイトでは表示できません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お客様のプロフィール＞\n';
        mailText = mailText + 'お名前　　　　　　　：テストユーザ名\n';
        mailText = mailText + '希望連絡方法　　　　：希望連絡方法は電話です\n';
        mailText = mailText + 'メールアドレス　　　： testMailAdress@test.co.jp\n';
        mailText = mailText + '\n';
        mailText = mailText + '郵便番号　　　　　　：555-1111\n';
        mailText = mailText + '住所　　　　　　　　：テスト住所です\n';
        mailText = mailText + '\n';
        mailText = mailText + '電話番号　　　　　　：111-222-333\n';
        mailText = mailText + 'ご希望時間帯　　　　：希望時間帯は１９時以降です\n';
        mailText = mailText + 'その他の連絡方法　　：その他の連絡方法です\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '性別　　　　　　　　：男性\n';
        mailText = mailText + '\n';
        mailText = mailText + '年齢　　　　　　　　：25歳\n';
        mailText = mailText + '\n';
        mailText = mailText + '入居希望時期　　　　：入居希望時期は春ごろです\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜物件に関するお問合せ内容＞\n';
        mailText = mailText + '物件に関するお問い合わせ内容の１行目です\n';
        mailText = mailText + '物件に関するお問い合わせ内容の２行目です\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '\n';
        mailText = mailText + '■対応方法\n';
        mailText = mailText + '　３営業日以内に上記＜お客様のプロフィール＞にある連絡先まで \n';
        mailText = mailText + '　直接ご連絡くださいますようお願いいたします。 \n';
        mailText = mailText + '　Ｅメールでのご返信は、＜お客様のプロフィール＞中にあるメール \n';
        mailText = mailText + '　アドレス宛になっているかを確認の上、お送りください。 \n';
        mailText = mailText + '　※お客様が入力した情報をそのまま送信しておりますので、\n';
        mailText = mailText + '　　弊社でも＜お客様のプロフィール＞と同じ情報しかわかりません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '■Eメール活用テクニック＆パソコン操作簡単ガイドなど\n';
        mailText = mailText + '　お客様対応に役立つ記事を掲載、下記ＵＲＬにアクセス！\n';
        mailText = mailText + '　http://atbb.athome.jp/customer/concierge/emailkatuyou.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このお知らせをFAXで受信されたアットホーム会員さまへ \n';
        mailText = mailText + '　このサービスをEメールで受信することも可能です。ぜひご登録を！ \n';
        mailText = mailText + '　（アットホーム会員の方はご商号・ご住所・電話番号・Eメールを下記まで\n';
        mailText = mailText + '　お知らせください。\n';
        mailText = mailText + '　会員登録がない方は、ぜひアットホームへのご加盟をご検討ください。\n';
        mailText = mailText + '　詳細は下記ページをご覧ください。） \n';
        mailText = mailText + '　http://atbb.athome.jp/service/a_service/service.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このサービスはアットホーム(株)が行っております。\n';
        mailText = mailText + '　お心あたりのない方は、恐れ入りますが TEL 0120-134-855 まで\n';
        mailText = mailText + '　ご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';
        mailText = mailText + '　アットホーム カスタマーセンター\n';
        mailText = mailText + '　TEL : 0570-01-1967\n';
        mailText = mailText + '　※PHS・IP電話の方は、TEL.045-330-3410 まで\n';
        mailText = mailText + '　E-Mail : mailcenter@athome.co.jp\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';


        email.plainTextBody = mailText;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ アットホーム（エンジンレンタル）クラス終了 ～～～～～～～～～～～');
    }

    @IsTest
    static void mailTestAtHomeOemGara() {
        system.debug('～～～～～～～～～～～ アットホーム（OEM＿ガラケー）テストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_ATHOME;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = '';
        mailText = mailText + '携帯サイトで物件をご覧になった【お客様からの反響】です。\n';
        mailText = mailText + '下記の内容をご確認のうえ、お客様へのご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + 'なお、お問合せ情報の中には、ご本人の個人情報が含まれていますので、\n';
        mailText = mailText + 'お取り扱いには十分にご留意ください。なお、本個人情報は、資料の送付、\n';
        mailText = mailText + '問合せに対する連絡以外の目的では利用できません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'テスト物件名です　 御中\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お問合わせ日時：2020/02/26 16:00:49\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お問合せされた物件の概要＞\n';
        mailText = mailText + '物件種目　　　　　：アパート\n';
        mailText = mailText + '建物名　　　　　　：テスト建物名\n';
        mailText = mailText + '交通　　　　　　　：テスト交通名\n';
        mailText = mailText + '駅名　　　　　　　：テスト駅名\n';
        mailText = mailText + '\n';
        mailText = mailText + '徒歩　　　　　　　：徒歩５分\n';
        mailText = mailText + 'バス停名　　　　　：テストバス停名\n';
        mailText = mailText + 'バス乗車分　　　　：バス乗車１０分\n';
        mailText = mailText + 'バス停歩分　　　　：バス停徒歩２０分\n';
        mailText = mailText + '所在地　　　　　　：テスト所在地です\n';
        mailText = mailText + '\n';
        mailText = mailText + '賃料　　　　　　　：999\n';
        mailText = mailText + '間取り　　　　　　：5SLDK+α\n';
        mailText = mailText + '専有面積　　　　　：専有面積100\n';
        mailText = mailText + '#else\n';
        mailText = mailText + '価格　　　　　　　：999\n';
        mailText = mailText + '間取り　　　　　　：5SLDK+α\n';
        mailText = mailText + '専有面積　　　　　：専有面積100\n';
        mailText = mailText + '土地面積　　　　　：土地面積200\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'at home 物件番号　　：'+ property[1].Id + '\n';
        mailText = mailText + '貴社物件管理番号　　：'+ property[0].PropertyCode__c + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '担当スタッフ　　　　：テストスタッフ名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '詳しい物件情報はコチラ↓\n';
        mailText = mailText + '詳しい物件情報はこちらという欄を適当に変更\n';
        mailText = mailText + 'ケータイサイト用はコチラ↓\n';
        mailText = mailText + 'ケータイサイト用はこちらの欄を適当に編集\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お客様のプロフィール＞\n';
        mailText = mailText + 'お名前(漢字)　　　　：テスト名前漢字です\n';
        mailText = mailText + 'お名前(カナ)　　　　：テストナマエカナデス\n';
        mailText = mailText + '希望連絡方法　　　　：希望連絡方法は電話です\n';
        mailText = mailText + 'メールアドレス　　　： testMailAdress@test.co.jp\n';
        mailText = mailText + '郵便番号　　　　　　：555-1111\n';
        mailText = mailText + '住所　　　　　　　　：テスト住所です\n';
        mailText = mailText + '電話番号　　　　　　：111-222-333\n';
        mailText = mailText + '連絡希望の時間帯　　：希望時間帯は１９時以降です\n';
        mailText = mailText + 'ＦＡＸ　　　　　　　：123-456-789\n';
        mailText = mailText + 'その他の連絡方法　　：その他の連絡方法です\n';
        mailText = mailText + '性別　　　　　　　　：女性\n';
        mailText = mailText + '入居希望時期　　　　：入居希望時期は春ごろです\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜物件に関するお問合せ内容＞\n';
        mailText = mailText + '物件に関するお問い合わせ内容の１行目です\n';
        mailText = mailText + '物件に関するお問い合わせ内容の２行目です\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '☆お客さまのメール送信先が携帯アドレスの場合・・・\n';
        mailText = mailText + '　ドメイン指定で制御されている可能性がございます。\n';
        mailText = mailText + '　また、携帯へメールを送る際は、文字数の制限にご注意ください。\n';
        mailText = mailText + '\n';
        mailText = mailText + '■対応方法 \n';
        mailText = mailText + '　３営業日以内に上記＜お客様のプロフィール＞にある連絡先まで \n';
        mailText = mailText + '　直接ご連絡くださいますようお願いいたします。 \n';
        mailText = mailText + '　Ｅメールでのご返信は、＜お客様のプロフィール＞中にあるメール \n';
        mailText = mailText + '　アドレス宛になっているかを確認の上、お送りください。 \n';
        mailText = mailText + '　※お客様が入力した情報をそのまま送信しておりますので、\n';
        mailText = mailText + '　　弊社でも＜お客様のプロフィール＞と同じ情報しかわかりません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '■Eメール活用テクニック＆パソコン操作簡単ガイドなど\n';
        mailText = mailText + '　お客様対応に役立つ記事を掲載、下記ＵＲＬにアクセス！\n';
        mailText = mailText + '　http://atbb.athome.jp/customer/concierge/emailkatuyou.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このお知らせをFAXで受信されたアットホーム会員さまへ \n';
        mailText = mailText + '　このサービスをEメールで受信することも可能です。ぜひご登録を！ \n';
        mailText = mailText + '　（アットホーム会員の方はご商号・ご住所・電話番号・Eメールを下記まで\n';
        mailText = mailText + '　お知らせください。\n';
        mailText = mailText + '　会員登録がない方は、ぜひアットホームへのご加盟をご検討ください。\n';
        mailText = mailText + '　詳細は下記ページをご覧ください。） \n';
        mailText = mailText + '　http://atbb.athome.jp/service/a_service/service.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このサービスはアットホーム(株)が行っております。\n';
        mailText = mailText + '　お心あたりのない方は、恐れ入りますが TEL 0120-134-855 まで\n';
        mailText = mailText + '　ご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';
        mailText = mailText + '　アットホーム カスタマーセンター\n';
        mailText = mailText + '　TEL : 0570-01-1967\n';
        mailText = mailText + '　※PHS・IP電話の方は、TEL.045-330-3410 まで\n';
        mailText = mailText + '　E-Mail : mailcenter@athome.co.jp\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';

        email.plainTextBody = mailText;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ アットホーム（OEM＿ガラケー）クラス終了 ～～～～～～～～～～～');
    }

    @IsTest
    static void mailTestAtHomeOemSumaho() {
        system.debug('～～～～～～～～～～～ アットホーム（OEM＿スマホ）テストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_ATHOME;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = '';
        mailText = mailText + '□■アットホーム（スマートフォンサイト・アプリ） 　反響のお知らせ ■□\n';
        mailText = mailText + '\n';
        mailText = mailText + 'スマートフォンサイト・アプリで物件をご覧になった【お客様からの反響】です。\n';
        mailText = mailText + '下記の内容をご確認のうえ、お客様へのご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + 'なお、お問合せ情報の中には、ご本人の個人情報が含まれていますので、\n';
        mailText = mailText + 'お取り扱いには十分にご留意ください。なお、本個人情報は、資料の送付、\n';
        mailText = mailText + '問合せに対する連絡以外の目的では利用できません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'テスト物件名です　 御中\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お問合わせ日時：2020/02/26 16:00:49\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お問合せされた物件の概要＞\n';
        mailText = mailText + '物件種目　　　　　：アパート\n';
        mailText = mailText + '建物名　　　　　　：テスト建物名\n';
        mailText = mailText + '交通　　　　　　　：テスト交通名\n';
        mailText = mailText + '駅名　　　　　　　：テスト駅名\n';
        mailText = mailText + '\n';
        mailText = mailText + '徒歩　　　　　　　：徒歩５分\n';
        mailText = mailText + 'バス停名　　　　　：テストバス停名\n';
        mailText = mailText + 'バス乗車分　　　　：バス乗車１０分\n';
        mailText = mailText + 'バス停歩分　　　　：バス停徒歩２０分\n';
        mailText = mailText + '所在地　　　　　　：テスト所在地です\n';
        mailText = mailText + '\n';
        mailText = mailText + '賃料　　　　　　　：999\n';
        mailText = mailText + '間取り　　　　　　：5SLDK+α\n';
        mailText = mailText + '専有面積　　　　　：専有面積100\n';
        mailText = mailText + '#else\n';
        mailText = mailText + '価格　　　　　　　：999\n';
        mailText = mailText + '間取り　　　　　　：5SLDK+α\n';
        mailText = mailText + '専有面積　　　　　：専有面積100\n';
        mailText = mailText + '土地面積　　　　　：土地面積200\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'at home 物件番号　　：'+ property[1].Id + '\n';
        mailText = mailText + '貴社物件管理番号　　：'+ property[0].PropertyCode__c + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '担当スタッフ　　　　：テストスタッフ名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '詳しい物件情報はコチラ↓\n';
        mailText = mailText + '詳しい物件情報はこちらという欄を適当に変更\n';
        mailText = mailText + 'ケータイサイト用はコチラ↓\n';
        mailText = mailText + 'ケータイサイト用はこちらの欄を適当に編集\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お客様のプロフィール＞\n';
        mailText = mailText + 'お名前(漢字)　　　　：テスト名前漢字です\n';
        mailText = mailText + 'お名前(カナ)　　　　：テストナマエカナデス\n';
        mailText = mailText + '希望連絡方法　　　　：希望連絡方法は電話です\n';
        mailText = mailText + 'メールアドレス　　　： testMailAdress@test.co.jp\n';
        mailText = mailText + '郵便番号　　　　　　：555-1111\n';
        mailText = mailText + '住所　　　　　　　　：テスト住所です\n';
        mailText = mailText + '電話番号　　　　　　：111-222-333\n';
        mailText = mailText + '連絡希望の時間帯　　：希望時間帯は１９時以降です\n';
        mailText = mailText + 'ＦＡＸ　　　　　　　：123-456-789\n';
        mailText = mailText + 'その他の連絡方法　　：その他の連絡方法です\n';
        mailText = mailText + '性別　　　　　　　　：女性\n';
        mailText = mailText + '入居希望時期　　　　：入居希望時期は春ごろです\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜物件に関するお問合せ内容＞\n';
        mailText = mailText + '物件に関するお問い合わせ内容の１行目です\n';
        mailText = mailText + '物件に関するお問い合わせ内容の２行目です\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '☆お客さまのメール送信先が携帯アドレスの場合・・・\n';
        mailText = mailText + '　ドメイン指定で制御されている可能性がございます。\n';
        mailText = mailText + '　また、携帯へメールを送る際は、文字数の制限にご注意ください。\n';
        mailText = mailText + '\n';
        mailText = mailText + '■対応方法\n';
        mailText = mailText + '　３営業日以内に上記＜お客様のプロフィール＞にある連絡先まで\n';
        mailText = mailText + '　直接ご連絡くださいますようお願いいたします。\n';
        mailText = mailText + '　Ｅメールでのご返信は、＜お客様のプロフィール＞中にあるメール\n';
        mailText = mailText + '　アドレス宛になっているかを確認の上、お送りください。\n';
        mailText = mailText + '　※お客様が入力した情報をそのまま送信しておりますので、\n';
        mailText = mailText + '　　弊社でも＜お客様のプロフィール＞と同じ情報しかわかりません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '■反響メール返信文例集＆メール操作簡単ガイドなど\n';
        mailText = mailText + '　お客様対応に役立つ記事を掲載、下記ＵＲＬにアクセス！\n';
        mailText = mailText + '　http://atbb.athome.jp/business/concierge/emailkatuyou.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このお知らせをFAXで受信されたアットホーム会員さまへ\n';
        mailText = mailText + '　このサービスをEメールで受信することも可能です。ぜひご登録を！\n';
        mailText = mailText + '　（アットホーム会員の方はご商号・ご住所・電話番号・Eメールを下記まで\n';
        mailText = mailText + '　お知らせください。\n';
        mailText = mailText + '　会員登録がない方は、ぜひアットホームへのご加盟をご検討ください。\n';
        mailText = mailText + '　詳細は下記ページをご覧ください。）\n';
        mailText = mailText + '　http://atbb.athome.jp/business/index.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このサービスはアットホーム(株)が行っております。\n';
        mailText = mailText + '　お心あたりのない方は、恐れ入りますが TEL 0120-134-855 まで\n';
        mailText = mailText + '　ご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';
        mailText = mailText + '　アットホーム カスタマーセンター\n';
        mailText = mailText + '　TEL : 0570-01-1967\n';
        mailText = mailText + '　※PHS・IP電話の方は、TEL.045-330-3410 まで\n';
        mailText = mailText + '　E-Mail : mailcenter@athome.jp\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';

        email.plainTextBody = mailText;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ アットホーム（OEM＿スマホ）クラス終了 ～～～～～～～～～～～');
    }

    @IsTest
    static void mailTestAtHomeOemPc() {
        system.debug('～～～～～～～～～～～ アットホーム（OEM＿PC）テストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_ATHOME;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = '';
        mailText = mailText + '□■ アットホーム　インターネット　反響のお知らせ ■□\n';
        mailText = mailText + '\n';
        mailText = mailText + 'インターネットで物件をご覧になった【お客様からの反響】です。\n';
        mailText = mailText + '下記の内容をご確認のうえ、お客様へのご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + 'なお、お問合せ情報の中には、ご本人の個人情報が含まれていますので、\n';
        mailText = mailText + 'お取り扱いには十分にご留意ください。なお、本個人情報は、資料の送付、\n';
        mailText = mailText + '問合せに対する連絡以外の目的では利用できません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'テスト物件名です　 御中\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お問合わせ日時：2020/02/26 16:00:49\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お問合せされた物件の概要＞\n';
        mailText = mailText + '物件種目　　　　　：アパート\n';
        mailText = mailText + '建物名　　　　　　：テスト建物名\n';
        mailText = mailText + '交通　　　　　　　：テスト交通名\n';
        mailText = mailText + '駅名　　　　　　　：テスト駅名\n';
        mailText = mailText + '\n';
        mailText = mailText + '徒歩　　　　　　　：徒歩５分\n';
        mailText = mailText + 'バス停名　　　　　：テストバス停名\n';
        mailText = mailText + 'バス乗車分　　　　：バス乗車１０分\n';
        mailText = mailText + 'バス停歩分　　　　：バス停徒歩２０分\n';
        mailText = mailText + '所在地　　　　　　：テスト所在地です\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '価格　　　　　　　：999\n';
        mailText = mailText + '間取り　　　　　　：5SLDK+α\n';
        mailText = mailText + '専有面積　　　　　：専有面積100\n';
        mailText = mailText + '土地面積　　　　　：土地面積200\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'at home 物件番号　　：'+ property[1].Id + '\n';
        mailText = mailText + '貴社物件管理番号　　：'+ property[0].PropertyCode__c + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '担当スタッフ　　　　：テストスタッフ名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '詳しい物件情報はコチラ↓\n';
        mailText = mailText + '詳しい物件情報はこちらという欄を適当に変更\n';
        mailText = mailText + 'ケータイサイト用はコチラ↓\n';
        mailText = mailText + 'ケータイサイト用はこちらの欄を適当に編集\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お客様のプロフィール＞\n';
        mailText = mailText + 'お名前(漢字)　　　　：テスト名前漢字です\n';
        mailText = mailText + 'お名前(カナ)　　　　：テストナマエカナデス\n';
        mailText = mailText + '希望連絡方法　　　　：希望連絡方法は電話です\n';
        mailText = mailText + 'メールアドレス　　　： testMailAdress@test.co.jp\n';
        mailText = mailText + '郵便番号　　　　　　：555-1111\n';
        mailText = mailText + '住所　　　　　　　　：テスト住所です\n';
        mailText = mailText + '電話番号　　　　　　：111-222-333\n';
        mailText = mailText + '連絡希望の時間帯　　：希望時間帯は１９時以降です\n';
        mailText = mailText + 'ＦＡＸ　　　　　　　：123-456-789\n';
        mailText = mailText + 'その他の連絡方法　　：その他の連絡方法です\n';
        mailText = mailText + '性別　　　　　　　　：女性\n';
        mailText = mailText + '年齢　　　　　　　　：25歳\n';
        mailText = mailText + '\n';
        mailText = mailText + '入居希望時期　　　　：入居希望時期は春ごろです\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜物件に関するお問合せ内容＞\n';
        mailText = mailText + '物件に関するお問い合わせ内容の１行目です\n';
        mailText = mailText + '物件に関するお問い合わせ内容の２行目です\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '\n';
        mailText = mailText + '■対応方法\n';
        mailText = mailText + '　３営業日以内に上記＜お客様のプロフィール＞にある連絡先まで \n';
        mailText = mailText + '　直接ご連絡くださいますようお願いいたします。 \n';
        mailText = mailText + '　Ｅメールでのご返信は、＜お客様のプロフィール＞中にあるメール \n';
        mailText = mailText + '　アドレス宛になっているかを確認の上、お送りください。 \n';
        mailText = mailText + '　※お客様が入力した情報をそのまま送信しておりますので、\n';
        mailText = mailText + '　　弊社でも＜お客様のプロフィール＞と同じ情報しかわかりません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '■Eメール活用テクニック＆パソコン操作簡単ガイドなど\n';
        mailText = mailText + '　お客様対応に役立つ記事を掲載、下記ＵＲＬにアクセス！\n';
        mailText = mailText + '　http://atbb.athome.jp/customer/concierge/emailkatuyou.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このお知らせをFAXで受信されたアットホーム会員さまへ \n';
        mailText = mailText + '　このサービスをEメールで受信することも可能です。ぜひご登録を！ \n';
        mailText = mailText + '　（アットホーム会員の方はご商号・ご住所・電話番号・Eメールを下記まで\n';
        mailText = mailText + '　お知らせください。\n';
        mailText = mailText + '　会員登録がない方は、ぜひアットホームへのご加盟をご検討ください。\n';
        mailText = mailText + '　詳細は下記ページをご覧ください。） \n';
        mailText = mailText + '　http://atbb.athome.jp/service/a_service/service.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このサービスはアットホーム(株)が行っております。\n';
        mailText = mailText + '　お心あたりのない方は、恐れ入りますが TEL 0120-134-855 まで\n';
        mailText = mailText + '　ご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';
        mailText = mailText + '　アットホーム カスタマーセンター\n';
        mailText = mailText + '　TEL : 0570-01-1967\n';
        mailText = mailText + '　※PHS・IP電話の方は、TEL.045-330-3410 まで\n';
        mailText = mailText + '　E-Mail : mailcenter@athome.co.jp\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';

        email.plainTextBody = mailText;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ アットホーム（OEM＿PC）クラス終了 ～～～～～～～～～～～');
    }

    @IsTest
    static void mailTestAtHomeLine() {
        system.debug('～～～～～～～～～～～ アットホーム（LINE）テストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_ATHOME;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = '';
        mailText = mailText + '□■アットホーム（スマートフォンサイト・アプリ） 　LINE反響のお知らせ ■□\n';
        mailText = mailText + '\n';
        mailText = mailText + 'スマートフォンサイト・アプリで物件をご覧になり、【LINEで問合わせ】を選択\n';
        mailText = mailText + 'されたお客さまからの反響です。\n';
        mailText = mailText + 'お客様のLINEアカウントから貴店LINE＠に直接メッセージが届いておりますので、\n';
        mailText = mailText + '内容をご確認の上、LINE@マネージャーからお客様へご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + 'なお、お問合せ情報の中には、ご本人の個人情報が含まれていますので、\n';
        mailText = mailText + 'お取り扱いには十分にご留意ください。なお、本個人情報は、資料の送付、\n';
        mailText = mailText + '問合せに対する連絡以外の目的では利用できません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'テスト物件名です　 御中\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お問合わせ日時：2020/02/26 16:00:49\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お問合せされた物件の概要＞\n';
        mailText = mailText + '物件種目　　　　　：アパート\n';
        mailText = mailText + '建物名　　　　　　：テスト建物名\n';
        mailText = mailText + '交通　　　　　　　：テスト交通名\n';
        mailText = mailText + '駅名　　　　　　　：テスト駅名\n';
        mailText = mailText + '\n';
        mailText = mailText + '徒歩　　　　　　　：徒歩５分\n';
        mailText = mailText + 'バス停名　　　　　：テストバス停名\n';
        mailText = mailText + 'バス乗車分　　　　：バス乗車１０分\n';
        mailText = mailText + 'バス停歩分　　　　：バス停徒歩２０分\n';
        mailText = mailText + '所在地　　　　　　：テスト所在地です\n';
        mailText = mailText + '賃料　　　　　　　：999\n';
        mailText = mailText + '間取り　　　　　　：5SLDK+α\n';
        mailText = mailText + '専有・建物面積　　：専有面積100\n';
        mailText = mailText + '\n';
        mailText = mailText + 'at home 物件番号　　：'+ property[1].Id + '\n';
        mailText = mailText + '貴社物件管理番号　　：'+ property[0].PropertyCode__c + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '担当スタッフ　　　　：テストスタッフ名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '詳しい物件情報はコチラ↓\n';
        mailText = mailText + '詳しい物件情報はこちらという欄を適当に変更\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お客様のプロフィール＞\n';
        mailText = mailText + 'LINEプロフィール名　：LINEのプロファイル名です\n';
        mailText = mailText + '## 貸事務所/貸店舗/貸その他の場合\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '会社名　　　　　　　：テスト会社名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お名前・ご担当者様名：テストユーザ名\n';
        mailText = mailText + '希望連絡方法　　　　：LINE（LINE@のトークにてご返信ください）\n';
        mailText = mailText + '連絡希望の時間帯　　：希望時間帯は１９時以降です\n';
        mailText = mailText + 'メールアドレス　　　： testMailAdress@test.co.jp\n';
        mailText = mailText + '電話番号　　　　　　：111-222-333\n';
        mailText = mailText + '\n';
        mailText = mailText + '性別　　　　　　　　：女性\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '入居希望時期　　　　：入居希望時期は春ごろです\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜物件に関するお問合せ内容＞\n';
        mailText = mailText + '物件に関するお問い合わせ内容の１行目です\n';
        mailText = mailText + '物件に関するお問い合わせ内容の２行目です\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '## 貸事務所/貸店舗/貸その他の場合\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '＜物件のお問い合わせ理由＞\n';
        mailText = mailText + '物件のお問い合わせ理由の１行目です\n';
        mailText = mailText + '物件のお問い合わせ理由の２行目です\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '<問合せがあった貴店LINE＠アカウント>\n';
        mailText = mailText + 'LINE＠ID　：1234567890\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '\n';
        mailText = mailText + '■ご返信方法\n';
        mailText = mailText + '　・LINE＠をひらく。（PCでLINE@マネージャーを利用する場合はGoogle　Chromeブラウザでご利用ください。）\n';
        mailText = mailText + '　・ 「1:1トーク」をクリックし、トーク一覧から上記LINEプロフィール名のメッセージをクリックしてください。\n';
        mailText = mailText + '　・お問い合わせ内容をご確認いただきましたら、そのままトーク画面からご返信ください。\n';
        mailText = mailText + '\n';
        mailText = mailText + '　※お客様が入力した情報をそのまま送信しておりますので、\n';
        mailText = mailText + '　　弊社でも＜お客様のプロフィール＞と同じ情報しかわかりません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '☆＜お客様のプロフィール＞にＥメールや電話番号がある場合は、メールや\n';
        mailText = mailText + '　電話で直接ご連絡いただくこともできます。\n';
        mailText = mailText + '\n';
        mailText = mailText + '☆お客さまのメール送信先が携帯アドレスの場合・・・\n';
        mailText = mailText + '　ドメイン指定で制御されている可能性がございます。\n';
        mailText = mailText + '　また、携帯へメールを送る際は、文字数の制限にご注意ください。\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このサービスはアットホーム(株)が行っております。\n';
        mailText = mailText + '　お心あたりのない方は、恐れ入りますが下記までご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';
        mailText = mailText + '　アットホーム カスタマーセンター\n';
        mailText = mailText + '　TEL : 0570-01-1967\n';
        mailText = mailText + '　※PHS・IP電話の方は、TEL.045-330-3410 まで\n';
        mailText = mailText + '　E-Mail : mailcenter@athome.jp\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';

        email.plainTextBody = mailText;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ アットホーム（LINE）クラス終了 ～～～～～～～～～～～');
    }

    @IsTest
    static void mailTestAtHomeChatbot() {
        system.debug('～～～～～～～～～～～ アットホーム（LINE（chatbot））テストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_ATHOME;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = '';
        mailText = mailText + '□■アットホーム（スマートフォンサイト・アプリ） 　LINE反響のお知らせ ■□\n';
        mailText = mailText + '\n';
        mailText = mailText + 'スマートフォンサイト・アプリで物件をご覧になり、【LINEで問合わせ】を選択\n';
        mailText = mailText + 'されたお客さまからの反響です。\n';
        mailText = mailText + 'お客様のLINEアカウントから貴店LINE＠に直接メッセージが届いておりますので、\n';
        mailText = mailText + '内容をご確認の上、LINE@マネージャーからお客様へご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + 'なお、お問合せ情報の中には、ご本人の個人情報が含まれていますので、\n';
        mailText = mailText + 'お取り扱いには十分にご留意ください。なお、本個人情報は、資料の送付、\n';
        mailText = mailText + '問合せに対する連絡以外の目的では利用できません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'テスト物件名です　 御中\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お問合わせ日時：2020/02/26 16:00:49\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お問合せされた物件の概要＞\n';
        mailText = mailText + '物件種目　　　　　：アパート\n';
        mailText = mailText + '建物名　　　　　　：テスト建物名\n';
        mailText = mailText + '交通　　　　　　　：テスト交通名\n';
        mailText = mailText + '駅名　　　　　　　：テスト駅名\n';
        mailText = mailText + '\n';
        mailText = mailText + '徒歩　　　　　　　：徒歩５分\n';
        mailText = mailText + 'バス停名　　　　　：テストバス停名\n';
        mailText = mailText + 'バス乗車分　　　　：バス乗車１０分\n';
        mailText = mailText + 'バス停歩分　　　　：バス停徒歩２０分\n';
        mailText = mailText + '所在地　　　　　　：テスト所在地です\n';
        mailText = mailText + '賃料　　　　　　　：999\n';
        mailText = mailText + '間取り　　　　　　：5SLDK+α\n';
        mailText = mailText + '専有・建物面積　　：専有面積100\n';
        mailText = mailText + '\n';
        mailText = mailText + 'at home 物件番号　　：'+ property[1].Id + '\n';
        mailText = mailText + '貴社物件管理番号　　：'+ property[0].PropertyCode__c + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '担当スタッフ　　　　：テストスタッフ名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '詳しい物件情報はコチラ↓\n';
        mailText = mailText + '詳しい物件情報はこちらという欄を適当に変更\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お客様のプロフィール＞\n';
        mailText = mailText + 'LINEプロフィール名　：LINEのプロファイル名です\n';
        mailText = mailText + 'お名前　　　　　　　：テスト名前です\n';
        mailText = mailText + '希望連絡方法　　　　：LINE（LINE@のトークにてご返信ください）\n';
        mailText = mailText + '電話番号　　　　　　：111-222-333\n';
        mailText = mailText + '入居予定時期　　　　：入居予定時期は夏ごろです\n';
        mailText = mailText + '\n';
        mailText = mailText + '見学希望日時　　　　：見学希望日時は気が向いたらです\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜その他お問い合わせ内容・ご希望内容＞\n';
        mailText = mailText + 'その他お問い合わせ内容・ご希望内容の１行目です\n';
        mailText = mailText + 'その他お問い合わせ内容・ご希望内容の２行目です\n';
        mailText = mailText + 'その他お問い合わせ内容・ご希望内容の３行目です\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '<問合せがあった貴店LINE＠アカウント>\n';
        mailText = mailText + 'LINE＠ID　：1234567890\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '\n';
        mailText = mailText + '■ご返信方法\n';
        mailText = mailText + '　・LINE＠をひらく。（PCでLINE@マネージャーを利用する場合はGoogle　Chromeブラウザでご利用ください。）\n';
        mailText = mailText + '　・「1:1トーク」をクリックし、トーク一覧から上記LINEプロフィール名のメッセージをクリックしてください。\n';
        mailText = mailText + '　・お問い合わせ内容をご確認いただきましたら、そのままトーク画面からご返信ください。\n';
        mailText = mailText + '\n';
        mailText = mailText + '　※お客様が入力した情報をそのまま送信しておりますので、\n';
        mailText = mailText + '　　弊社でも＜お客様のプロフィール＞と同じ情報しかわかりません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '☆＜お客様のプロフィール＞にＥメールや電話番号がある場合は、メールや\n';
        mailText = mailText + '　電話で直接ご連絡いただくこともできます。\n';
        mailText = mailText + '\n';
        mailText = mailText + '☆お客さまのメール送信先が携帯アドレスの場合・・・\n';
        mailText = mailText + '　ドメイン指定で制御されている可能性がございます。\n';
        mailText = mailText + '　また、携帯へメールを送る際は、文字数の制限にご注意ください。\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このサービスはアットホーム(株)が行っております。\n';
        mailText = mailText + '　お心あたりのない方は、恐れ入りますが下記までご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';
        mailText = mailText + '　アットホーム カスタマーセンター\n';
        mailText = mailText + '　TEL : 0570-01-1967\n';
        mailText = mailText + '　※PHS・IP電話の方は、TEL.045-330-3410 まで\n';
        mailText = mailText + '　E-Mail : mailcenter@athome.jp\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';

        email.plainTextBody = mailText;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ アットホーム（LINE（chatbot））クラス終了 ～～～～～～～～～～～');
    }

    @IsTest
    static void mailTestAtHomeOemApli() {
        system.debug('～～～～～～～～～～～ アットホーム（アプリ）テストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_ATHOME;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = '';
        mailText = mailText + '□■アットホーム（スマートフォンサイト・アプリ） 　反響のお知らせ ■□\n';
        mailText = mailText + '\n';
        mailText = mailText + 'スマートフォンサイト・アプリで物件をご覧になった【お客様からの反響】です。\n';
        mailText = mailText + '下記の内容をご確認のうえ、お客様へのご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + 'なお、お問合せ情報の中には、ご本人の個人情報が含まれていますので、\n';
        mailText = mailText + 'お取り扱いには十分にご留意ください。なお、本個人情報は、資料の送付、\n';
        mailText = mailText + '問合せに対する連絡以外の目的では利用できません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'テスト物件名です　 御中\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お問合わせ日時：2020/02/26 16:00:49\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お問合せされた物件の概要＞\n';
        mailText = mailText + '物件種目　　　　　：アパート\n';
        mailText = mailText + '建物名　　　　　　：テスト建物名\n';
        mailText = mailText + '交通　　　　　　　：テスト交通名\n';
        mailText = mailText + '駅名　　　　　　　：テスト駅名\n';
        mailText = mailText + '\n';
        mailText = mailText + '徒歩　　　　　　　：徒歩５分\n';
        mailText = mailText + 'バス停名　　　　　：テストバス停名\n';
        mailText = mailText + 'バス乗車分　　　　：バス乗車１０分\n';
        mailText = mailText + 'バス停歩分　　　　：バス停徒歩２０分\n';
        mailText = mailText + '所在地　　　　　　：テスト所在地です\n';
        mailText = mailText + '賃料　　　　　　　：999\n';
        mailText = mailText + '間取り　　　　　　：5SLDK+α\n';
        mailText = mailText + '専有・建物面積　　：専有面積100\n';
        mailText = mailText + '\n';
        mailText = mailText + 'at home 物件番号　　：'+ property[1].Id + '\n';
        mailText = mailText + '貴社物件管理番号　　：'+ property[0].PropertyCode__c + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '担当スタッフ　　　　：テストスタッフ名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '詳しい物件情報はコチラ↓\n';
        mailText = mailText + '詳しい物件情報はこちらという欄を適当に変更\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜お客様のプロフィール＞\n';
        mailText = mailText + '## 貸事務所/貸店舗/貸その他の場合\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '会社名　　　　　　　：テスト会社名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お名前・ご担当者様名：テストユーザ名\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '希望連絡方法　　　　：希望連絡方法は電話です\n';
        mailText = mailText + 'メールアドレス　　　： testMailAdress@test.co.jp\n';
        mailText = mailText + '電話番号　　　　　　：111-222-333\n';
        mailText = mailText + '連絡希望の時間帯　　：希望時間帯は１９時以降です\n';
        mailText = mailText + 'その他の連絡方法　　：その他の連絡方法です\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '性別　　　　　　　　：男性\n';
        mailText = mailText + '\n';
        mailText = mailText + '入居希望時期　　　　：入居希望時期は春ごろです\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '＜物件に関するお問い合わせ内容＞\n';
        mailText = mailText + '物件に関するお問い合わせ内容の１行目です\n';
        mailText = mailText + '物件に関するお問い合わせ内容の２行目です\n';
        mailText = mailText + '\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '## 貸事務所/貸店舗/貸その他の場合\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '＜物件のお問い合わせ理由＞\n';
        mailText = mailText + '物件のお問い合わせ理由の１行目です\n';
        mailText = mailText + '物件のお問い合わせ理由の２行目です\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '\n';
        mailText = mailText + '☆お客さまのメール送信先が携帯アドレスの場合・・・\n';
        mailText = mailText + '　ドメイン指定で制御されている可能性がございます。\n';
        mailText = mailText + '　また、携帯へメールを送る際は、文字数の制限にご注意ください。\n';
        mailText = mailText + '\n';
        mailText = mailText + '■対応方法\n';
        mailText = mailText + '　３営業日以内に上記＜お客様のプロフィール＞にある連絡先まで\n';
        mailText = mailText + '　直接ご連絡くださいますようお願いいたします。\n';
        mailText = mailText + '　Ｅメールでのご返信は、＜お客様のプロフィール＞中にあるメール\n';
        mailText = mailText + '　アドレス宛になっているかを確認の上、お送りください。\n';
        mailText = mailText + '　※お客様が入力した情報をそのまま送信しておりますので、\n';
        mailText = mailText + '　　弊社でも＜お客様のプロフィール＞と同じ情報しかわかりません。\n';
        mailText = mailText + '\n';
        mailText = mailText + '■反響メール返信文例集＆メール操作簡単ガイドなど\n';
        mailText = mailText + '　お客様対応に役立つ記事を掲載、下記ＵＲＬにアクセス！\n';
        mailText = mailText + '　http://atbb.athome.jp/customer/concierge/leftindex_sample.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このお知らせをFAXで受信されたアットホーム会員さまへ\n';
        mailText = mailText + '　このサービスをEメールで受信することも可能です。ぜひご登録を！\n';
        mailText = mailText + '　（アットホーム会員の方はご商号・ご住所・電話番号・Eメールを下記まで\n';
        mailText = mailText + '　お知らせください。\n';
        mailText = mailText + '　会員登録がない方は、ぜひアットホームへのご加盟をご検討ください。\n';
        mailText = mailText + '　詳細は下記ページをご覧ください。）\n';
        mailText = mailText + '　http://atbb.athome.jp/business/index.html\n';
        mailText = mailText + '\n';
        mailText = mailText + '■このサービスはアットホーム(株)が行っております。\n';
        mailText = mailText + '　お心あたりのない方は、恐れ入りますが TEL 0120-134-855 まで\n';
        mailText = mailText + '　ご連絡をお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';
        mailText = mailText + '　アットホーム カスタマーセンター\n';
        mailText = mailText + '　TEL : 0570-01-1967\n';
        mailText = mailText + '　※PHS・IP電話の方は、TEL.045-330-3410 まで\n';
        mailText = mailText + '　E-Mail : mailcenter@athome.jp\n';
        mailText = mailText + '◆◇ ………………………………………………… ◇◆\n';

        email.plainTextBody = mailText;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ アットホーム（アプリ）クラス終了 ～～～～～～～～～～～');
    }

    //ポータルサイト構築 追加
    @IsTest
    static void mailTestPortal() {
        system.debug('～～～～～～～～～～～ 自社ポータルテストクラス開始 ～～～～～～～～～～～');
		createPortalSite();	// 2022/3/23　setting()より、システム設定のデータ登録を独立させたため、メソッド追加
        //システム変数
        SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_ECHOMAIL_BATCHPROCESSING,
                                                        VariablesLabel__c = '反響メールバッチフラグ',
                                                        BooleanValue__c = true);
        insert sysVar;

        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst_ptl.EMAIL_PORTAL;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        email.plainTextBody = createPortalBody();
        

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email,env);

        List<EchoMail__c> echo = [SELECT id FROM EchoMail__c WHERE MemberId__c = '12345678' ];
        system.assertEquals(true, !echo.isEmpty());

        Test.stopTest();
        afterInsertOutput();
        
        system.debug('～～～～～～～～～～～ 自社ポータルクラス終了 ～～～～～～～～～～～');
    }

   //カバレッジ率あげ
   @IsTest
   static void coverageUp() {
       //システム変数
       SystemVariables__c sysVar = new SystemVariables__c(VariablesName__c = CommonConst.IS_ECHOMAIL_BATCHPROCESSING,
                                                       VariablesLabel__c = '反響メールバッチフラグ',
                                                       BooleanValue__c = false);
       insert sysVar;

       createEchoMail hm = new createEchoMail();

       List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

       // 引数に指定するメールと宛先
       Messaging.inboundEmail email = new Messaging.inboundEmail();
       email.headers = new  List<Messaging.InboundEmail.Header>();
       email.subject = 'テスト件名です。';
       email.fromAddress = CommonConst_ptl.EMAIL_PORTAL;
       email.toAddresses = new List<String>();
       email.toAddresses.add('testToAdress@rand.co.jp');
       email.References = new List<String>();
       email.References.add('テストreferencesです。１行目');
       email.References.add('テストreferencesです。２行目');
       email.References.add('テストreferencesです。３行目');
       email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();               
       email.plainTextBody = createPortalBody();

       email.plainTextBody = email.plainTextBody.replace( '2020/07/01 00:00:00','');
       email.plainTextBody = email.plainTextBody.replace( 'hanako.hudousan@rand.co.jp','');
       email.plainTextBody = email.plainTextBody.replace( '不動産','');
       email.plainTextBody = email.plainTextBody.replace( '花子','');

       // メールサービスの結果（期待値）
       Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
       expect.success = true;
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

       Test.startTest();
       Messaging.InboundEmailResult result = hm.handleInboundEmail(email,env);
       
       Test.stopTest();

       
   }
   //自社ポータルの本文作成
   private static String createPortalBody(){
        string mailText = '{ "Property":[],\n';
        mailText+= '"Customer":[  {\n';
        mailText+= '      "MemberId":"12345678",\n';
        mailText+= '      "InquiryDateTime":"2020/07/01 00:00:00",\n';
        mailText+= '      "MailType":"' + CommonConst_ptl.ECHOMAIL_MAILTYPE_INQUIRY +'",\n';
        mailText+= '      "InquiryType":"最新の情がしりたい",\n';
        mailText+= '      "textOther" : "",\n';
        mailText+= '      "Shop":"",\n';
        mailText+= '      "VisitDateTime":"2020/07/15 15:00:00",\n';
        mailText+= '      "VisitDateTime2":"2020/07/16 15:00:00",\n';
        mailText+= '      "LastName":"不動産",\n';
        mailText+= '      "FirstName":"花子",\n';
        mailText+= '      "LastName_kana":"フドウサン",\n';
        mailText+= '      "FirstName_kana":"ハナコ",\n';
        mailText+= '      "Email":"hanako.hudousan@rand.co.jp",\n';
        mailText+= '      "Phone":"000-0000-0000",\n';
        mailText+= '      "BirthDay":"2000/01/15",\n';
        mailText+= '      "Zip":"460-0000",\n';
        mailText+= '      "State":"愛知県",\n';
        mailText+= '      "City":"名古屋市",\n';
        mailText+= '      "Street":"123",\n';
        mailText+= '      "ContactMeans":"庭付きの賃貸物件を探しています",\n';
        mailText+= '      "InquiryContent":"",\n';
        mailText+= '      "DesireArea":"",\n';
        mailText+= '      "RentFee":"",\n';
        mailText+= '      "RentFeeUpper":"",\n';
        mailText+= '      "RoomPlan": [ ],\n';
        mailText+= '      "HomeMovingReason": [ ],\n';
        mailText+= '      "OccupancyDesiredSeason":"",\n';
        mailText+= '      "LivePeople":""   \n';
        mailText+= '  }]}';
        return mailText;
   }

    @isTest static void setErrorMailItemTest() {
        createEchoMail hm = new createEchoMail();
        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        email.subject = 'テスト件名です。';
        email.fromAddress = 'mailer-daemon@salesforce.com';
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = 'いつもご利用いただきありがとうございます。\n';
        mailText = mailText + 'メールが送信されなかった可能性があります。添付された送信通知を参照してください。\n';
        mailText = mailText + 'このメッセージは、送信したメールの送信状況通知を転送するように組織で選択されているため、送信されています。\n';

        email.plainTextBody = mailText;

        //添付ファイルの生成
        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'ForwardedAttachment_1.txt';

        String mailAttachment = 'This message was created automatically by the mail system.\n';
        mailAttachment = mailAttachment + ', \n';
        mailAttachment = mailAttachment + ',A message that you sent could not be delivered to one or more of its\n';
        mailAttachment = mailAttachment + ',recipients. This is a permanent error. The following address(es) failed:\n';
        mailAttachment = mailAttachment + ', \n';
        mailAttachment = mailAttachment + ' , >>> test20201207.rand@yahoo.co.jp (Undelivered): 554 delivery error: dd This user doesnt have a yahoo.co.jp account (test20201207.rand@yahoo.co.jp) [-5] - mta028.mail.bbt.yahoo.co.jp\n';
        mailAttachment = mailAttachment + ',\n';
        mailAttachment = mailAttachment + ', ------ This is a copy of the original message, including all headers. ------\n';
        
        Blob myBlob = Blob.valueof(mailAttachment);
        binaryAttachment.Body = myBlob;
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();        

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
    }

	@IsTest
    static void mailTestSumo2() {
        system.debug('～～～～～～～～～～～ スーモテストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_SUMO;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = '洞口新瑞橋店\n';
        mailText = mailText + 'ROOM SELECT新瑞橋店(株)洞口  緒方俊也様\n';
        mailText = mailText + '反響到着日時　2019/08/25 07:08:11\n';
        mailText = mailText + '\n';
        mailText = mailText + 'ＩＤ：111969501303\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お問合せ日時：2019/9/25 07:08:11\n';
        mailText = mailText + '連番：0042141526\n';
        mailText = mailText + 'お問合せ企画：ＳＵＵＭＯネット／賃貸物件枠問い合わせ（モバイル）\n';
        mailText = mailText + '反響送付先区分：会社\n';
        mailText = mailText + '反響送付先コード：11969501303\n';
        mailText = mailText + '\n';
        mailText = mailText + '☆☆☆　お客様からの反響です　☆☆☆\n';
        mailText = mailText + '\n';
        mailText = mailText + '※お問合せ内容に従ってお客様へご連絡お願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '問合せ物件\n';
        mailText = mailText + '会社名：ROOM SELECT新瑞橋店(株)洞口\n';
        mailText = mailText + '物件種別：アパート\n';
        mailText = mailText + '物件コード：物件コード：ポータルサイト物件番号12345\n';
        mailText = mailText + '物件名：仮）D-room南区西桜町101\n';
        mailText = mailText + '貴社物件コード：' + property[0].PropertyCode__c + '\n';
        mailText = mailText + '最寄り駅：名鉄名古屋本線/本笠寺\n';
        mailText = mailText + 'バス／歩：-／4分\n';
        mailText = mailText + '所在地：愛知県名古屋市南区西桜町\n';
        mailText = mailText + '賃料：8.2万円\n';
        mailText = mailText + '間取り：1LDK\n';
        mailText = mailText + '専有面積：52.11平米\n';
        mailText = mailText + '物件詳細画面：https://suumo.jp/chintai/bc_100161634439/\n';
        mailText = mailText + '\n';
        mailText = mailText + '－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お客様プロフィール\n';
        mailText = mailText + '名前（漢字）：不動産　花子\n';
        mailText = mailText + '名前（カナ）：\n';
        mailText = mailText + 'メールアドレス：hudousan@roomselect.jp\n';
        mailText = mailText + 'ＴＥＬ：000-0000-0000\n';
        mailText = mailText + 'FAX：000-000-0000\n';
        mailText = mailText + '連絡方法：メール\n';
        mailText = mailText + 'お問合せ内容コメント：この部屋の最新の空室状況を知りたい\n';
        mailText = mailText + '\n';
        mailText = mailText + '－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－';

        email.plainTextBody = mailText;

        //添付ファイルの生成
        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.txt';
        String algorithmName = 'HMacSHA1';
        Blob b = Crypto.generateMac(algorithmName, Blob.valueOf('test'), Blob.valueOf('test_key'));
        binaryAttachment.Body = b;
        binaryAttachments[0] =  binaryAttachment ;
        email.binaryAttachments = binaryAttachments ;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ スーモテストクラス終了 ～～～～～～～～～～～');
    }

    @IsTest
    static void mailTestHomes2() {
        system.debug('～～～～～～～～～～～ ホームズテストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_HOMES;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = 'ROOM SELECT中村本陣店 株式会社洞口様\n';
        mailText = mailText + '\n';
        mailText = mailText + '◆◇━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '　お客様より下記内容のお問合せがありました。\n';
        mailText = mailText + '　ご確認の上、ご連絡をお願いいたします。\n';
        mailText = mailText + '　　　　　　　2019/08/23 16:00:49　　　\n';
        // mailText = mailText + '          2019/08/23 16:00:49\n';
        mailText = mailText + '　━━━━━━━━━━━━━━━━━━━━━━◇◆\n';
        mailText = mailText + '\n';
        mailText = mailText + '下記URLをクリックすると問合せ物件の詳細を見ることができます。\n';
        mailText = mailText + 'https://www.homes.co.jp/chintai/b-1384850011276/\n';
        mailText = mailText + '\n';
        mailText = mailText + '　　　物件種別：賃貸 マンション\n';
        mailText = mailText + '　　　　物件名：横電千成ビル\n';
        mailText = mailText + '　　　　　賃料：5.6万円\n';
        mailText = mailText + '　　　　所在地：愛知県名古屋市中村区千成通6丁目\n';
        mailText = mailText + '　　　　　交通：名古屋市営東山線 岩塚駅\n';
        mailText = mailText + '　　　　　面積：32.8m2\n';
        mailText = mailText + '　　　　　間取：ワンルーム\n';
        mailText = mailText + '　　　物件番号：物件コード：ポータルサイト物件番号12345\n';    
        mailText = mailText + '　自社管理番号：'+ property[0].PropertyCode__c + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '　　問合せ番号：25508006\n';
        mailText = mailText + '\n';
        mailText = mailText + '　　　　　名前：不動産　花子\n';
        mailText = mailText + 'メールアドレス：hudousan@roomselect.jp\n';
        mailText = mailText + '　　　電話番号：00000000000\n';
        mailText = mailText + '\n';
        mailText = mailText + '　備考：物件を実際に見たい\n';
        mailText = mailText + '　【見学予約問合せ】：物件を実際に見たい\n';
        mailText = mailText + '　内容\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '　LIFULL HOME\'Sではお客様からのお問合せについて\n';
        mailText = mailText + '　３営業日以内の返信をお願いしています。\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '　効果的な対応メールの作成方法を動画でご紹介中。\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '申込不要で今すぐ利用可能！無料のe-learning基本コース\n';
        mailText = mailText + '\n';
        mailText = mailText + '>>>e-learning視聴画面はこちら【パスワード： homesfree1 】\n';
        mailText = mailText + 'http://www.homes.co.jp/homesfree\n';
        mailText = mailText + '\n';
        mailText = mailText + '■■■■■■■□□　サポートデスク　□□■■■■■■■\n';
        mailText = mailText + '\n';
        mailText = mailText + 'LIFULL HOME\'Sに関するご質問がございましたら、お気軽にご相談ください。\n';
        mailText = mailText + '\n';
        mailText = mailText + 'TEL：0120-462-389　09:00～19:00 (土・日・祝日を除く)\n';
        mailText = mailText + '※携帯電話からは　050-5577-7460　までお問合せください\n';
        mailText = mailText + 'E-MAIL：support@homes.co.jp　FAX：03-6862-9964\n';
        mailText = mailText + '\n';
        mailText = mailText + '株式会社LIFULL\n';
        mailText = mailText + '〒102-0083 東京都千代田区麹町1-4-4\n';
        mailText = mailText + '\n';
        mailText = mailText + '不動産・住宅情報サイト「LIFULL HOME\'S」 https://www.homes.co.jp/\n';

        email.plainTextBody = mailText;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ ホームズテストクラス終了 ～～～～～～～～～～～');
    }

    @IsTest
    static void mailTestHomes3() {
        system.debug('～～～～～～～～～～～ ホームズテストクラス開始 ～～～～～～～～～～～');
        createEchoMail hm = new createEchoMail();

        List <Property__c> property = [SELECT PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = 'テスト件名です。';
        email.fromAddress = CommonConst.EMAIL_HOMES;
        email.toAddresses = new List<String>();
        email.toAddresses.add('testToAdress@rand.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.References.add('テストreferencesです。２行目');
        email.References.add('テストreferencesです。３行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = 'ROOM SELECT中村本陣店 株式会社洞口様\n';
        mailText = mailText + '\n';
        mailText = mailText + '◆◇━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '　お客様より下記内容のお問合せがありました。\n';
        mailText = mailText + '　ご確認の上、ご連絡をお願いいたします。\n';
        mailText = mailText + '　　　　　　　2019/08/23 16:00:49　　　\n';
        // mailText = mailText + '          2019/08/23 16:00:49\n';
        mailText = mailText + '　━━━━━━━━━━━━━━━━━━━━━━◇◆\n';
        mailText = mailText + '\n';
        mailText = mailText + '下記URLをクリックすると問合せ物件の詳細を見ることができます。\n';
        mailText = mailText + 'https://www.homes.co.jp/chintai/b-1384850011276/\n';
        mailText = mailText + '\n';
        mailText = mailText + '　　　物件種別：賃貸 マンション\n';
        mailText = mailText + '　　　　物件名：横電千成ビル\n';
        mailText = mailText + '　　　　　賃料：5.6万円\n';
        mailText = mailText + '　　　　所在地：愛知県名古屋市中村区千成通6丁目\n';
        mailText = mailText + '　　　　　交通：名古屋市営東山線 岩塚駅\n';
        mailText = mailText + '　　　　　面積：32.8m2\n';
        mailText = mailText + '　　　　　間取：ワンルーム\n';
        mailText = mailText + '　　　物件番号：物件コード：ポータルサイト物件番号12345\n';    
        mailText = mailText + '　自社管理番号：'+ property[0].PropertyCode__c + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '　　問合せ番号：25508006\n';
        mailText = mailText + '\n';
        mailText = mailText + '　　　　　名前：不動産　花子\n';
        mailText = mailText + 'メールアドレス：hudousan@roomselect.jp\n';
        mailText = mailText + '　　　電話番号：00000000000\n';
        mailText = mailText + '\n';
        mailText = mailText + '　【見学予約問合せ】：物件を実際に見たい\n';
        mailText = mailText + '　内容\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '　LIFULL HOME\'Sではお客様からのお問合せについて\n';
        mailText = mailText + '　３営業日以内の返信をお願いしています。\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '　効果的な対応メールの作成方法を動画でご紹介中。\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━\n';
        mailText = mailText + '申込不要で今すぐ利用可能！無料のe-learning基本コース\n';
        mailText = mailText + '\n';
        mailText = mailText + '>>>e-learning視聴画面はこちら【パスワード： homesfree1 】\n';
        mailText = mailText + 'http://www.homes.co.jp/homesfree\n';
        mailText = mailText + '\n';
        mailText = mailText + '■■■■■■■□□　サポートデスク　□□■■■■■■■\n';
        mailText = mailText + '\n';
        mailText = mailText + 'LIFULL HOME\'Sに関するご質問がございましたら、お気軽にご相談ください。\n';
        mailText = mailText + '\n';
        mailText = mailText + 'TEL：0120-462-389　09:00～19:00 (土・日・祝日を除く)\n';
        mailText = mailText + '※携帯電話からは　050-5577-7460　までお問合せください\n';
        mailText = mailText + 'E-MAIL：support@homes.co.jp　FAX：03-6862-9964\n';
        mailText = mailText + '\n';
        mailText = mailText + '株式会社LIFULL\n';
        mailText = mailText + '〒102-0083 東京都千代田区麹町1-4-4\n';
        mailText = mailText + '\n';
        mailText = mailText + '不動産・住宅情報サイト「LIFULL HOME\'S」 https://www.homes.co.jp/\n';

        email.plainTextBody = mailText;

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();
        afterInsertOutput();
        system.debug('～～～～～～～～～～～ ホームズテストクラス終了 ～～～～～～～～～～～');
    }

	// ▼ 2022/3/7 CHINTAI対応による追加
    @isTest
    static void testChintaiPropertyInquiry() {
		createPortalSite();
		List <Property__c> property = [SELECT PropertyCode__c FROM Property__c ORDER BY Id];
		// 引数に指定するメールと宛先
		Messaging.inboundEmail email = new Messaging.inboundEmail();
		email.headers = new List<Messaging.InboundEmail.Header>();
		email.subject = '【CHINTAI】 物件お問合せお知らせメール';
		email.fromAddress = CommonConst.EMAIL_CHINTAI;
		email.toAddresses = new List<String>();
		email.toAddresses.add('testToAdress@rand.co.jp');
		email.References = new List<String>();
		email.References.add('テストreferencesです。１行目');
		email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

		string mailText = '───────────────────────────────────\n';
		mailText = mailText + '　CHINTAI　https://www.chintai.net\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '\n';
		mailText = mailText + '物件お問合せお知らせメール\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '\n';
		mailText = mailText + '株式会社洞口 ROOM SERECT丸の内店 御中\n';
		mailText = mailText + '\n';
		mailText = mailText + '「CHINTAI」お問合せフォームを利用し、\n';
		mailText = mailText + '貴社に対してお客様からお問合せがありました。\n';
		mailText = mailText + '\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + 'お問合せ時刻 : 2022/02/17 17:06:41\n';
		mailText = mailText + 'お問合せ元 : ネット\n';
		mailText = mailText + 'お問合せＩＤ : 2202171706417191\n';
		mailText = mailText + '\n';
		mailText = mailText + '＜見学希望日＞\n';
		mailText = mailText + '[第１希望日]　2022年3月16日（水） 11:00\n';
		mailText = mailText + '[第２希望日]　2022年3月17日（木） 11:00\n';
		mailText = mailText + '\n';
		mailText = mailText + '＜問合せ内容＞\n';
		mailText = mailText + '最寄り駅 : 名古屋市営地下鉄東山線/本陣\n';
		mailText = mailText + '所在地 : 名古屋市中村区大秋町4丁目\n';
		mailText = mailText + '賃料 : 45,000円\n';
		mailText = mailText + '共益費 : 3,500円\n';
		mailText = mailText + '間取り : 1K\n';
		mailText = mailText + '専有面積 : 22m2\n';
		mailText = mailText + '建物種別 : マンション\n';
		mailText = mailText + '建物構造 : 鉄筋コンクリート造\n';
		mailText = mailText + '築年 : 07/04\n';
		mailText = mailText + '物件番号 : 000000000' + property[0].PropertyCode__c + '\n';
		mailText = mailText + '部屋連番 : 0001\n';
		mailText = mailText + '物件名称 : ハウス大秋\n';
		mailText = mailText + '部屋号室 : 101\n';
		mailText = mailText + '問合せ番号 : CHINTAI東海575342\n';
		mailText = mailText + '掲載物件ＵＲＬ : https://www.chintai.net/detail/bk-C010092460000000005753420001/?vm=0\n';
		mailText = mailText + '\n';
		mailText = mailText + '＜お客様情報＞\n';
		mailText = mailText + '名前 : テスト　一郎\n';
		mailText = mailText + '名前（カナ） : テスト　イチロウ\n';
		mailText = mailText + '希望連絡方法 : メール/電話\n';
		mailText = mailText + 'メール : testchintai@hoge.com\n';
		mailText = mailText + '電話番号 : 0311111111\n';
		mailText = mailText + 'ＦＡＸ番号 :0322222222\n';
		mailText = mailText + '内容 : 初期費用が知りたい\n';
		mailText = mailText + 'コメント : この物件の初期費用をおしえてください。\n';
		mailText = mailText + '4月1日入居予定、駐車場もお願いする際は家賃代に追加となるのですか？それとも別途契約になりますか？\n';
		mailText = mailText + '転勤のため、家賃に含まれる方が都合が良いです。\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + '\n';
		mailText = mailText + '「店舗管理ログイン画面」からログイン後、\n';
		mailText = mailText + 'TOP画面のメニューから「お問い合せ検索」を行ってください。\n';
		mailText = mailText + '\n';
		mailText = mailText + '※「店舗管理ログイン画面」はこちら\n';
		mailText = mailText + 'https://system.chintai.net/crs\n';
		mailText = mailText + '\n';
		mailText = mailText + '以上、ご対応よろしくお願い致します。\n';
		mailText = mailText + '\n';
		mailText = mailText + '\n';
		mailText = mailText + '\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '※ このメールは CHINTAIシステムより送信されております。\n';
		mailText = mailText + '(C) CHINTAI Corporation All rights reserved.\n';
		mailText = mailText + 'https://www.chintai.net';

		email.plainTextBody = mailText;

		String subject = email.subject;
		
		// メールサービスの結果（期待値）
		Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
		expect.success = true;
		Test.startTest();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		createEchoMail hm = new createEchoMail();
		Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
		afterInsertAssertCheck(subject, mailText, '＜見学希望日＞', true, CommonConst.PORTALSITE_NAME_CHINTAI);
		Test.stopTest();
    }
	// ▲ 2022/3/7 CHINTAI対応による追加

	// ▼ 2022/3/7 CHINTAI対応による追加
    @isTest
    static void testChintaiShopInquiry() {
		createPortalSite();
		List <Property__c> property = [SELECT PropertyCode__c FROM Property__c ORDER BY Id];
		// 引数に指定するメールと宛先
		Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new List<Messaging.InboundEmail.Header>();
		email.subject = '【CHINTAI】 店舗お問合せお知らせメール';
		email.fromAddress = CommonConst.EMAIL_CHINTAI;
		email.toAddresses = new List<String>();
		email.toAddresses.add('testToAdress@rand.co.jp');
		email.References = new List<String>();
		email.References.add('テストreferencesです。１行目');
		email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

		string mailText = '───────────────────────────────────\n';
		mailText = mailText + '　CHINTAI　https://www.chintai.net\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '店舗お問合せお知らせメール\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '株式会社洞口 ルームセレクト丸の内店　御中\n';
		mailText = mailText + '「CHINTAI」お問合せフォームを利用し、\n';
		mailText = mailText + '貴社に対してお客様からお問合せがありました。\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + 'お問合せ時刻 : 2022/02/17 17:06:41\n';
		mailText = mailText + 'お問合せ元 : スマホ\n';
		mailText = mailText + 'お問合せＩＤ : 2203092049384246\n';
		mailText = mailText + '＜お客様情報＞\n';
		mailText = mailText + '名前 : テスト　一郎\n';
		mailText = mailText + '名前（カナ） : テスト　イチロウ\n';
		mailText = mailText + '希望連絡方法 : メール/電話\n';
		mailText = mailText + 'メール : testchintai@hoge.com\n';
		mailText = mailText + '電話番号 : 0311111111\n';
		mailText = mailText + 'ＦＡＸ番号 :0322222222\n';
		mailText = mailText + 'お問合せ内容 : 初期費用が知りたい\n';
		mailText = mailText + 'コメント : この物件の初期費用をおしえてください。\n';
		mailText = mailText + '4月1日入居予定、駐車場もお願いする際は家賃代に追加となるのですか？それとも別途契約になりますか？\n';
		mailText = mailText + '転勤のため、家賃に含まれる方が都合が良いです。\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + '\n';
		mailText = mailText + '＜来店希望日＞\n';
		mailText = mailText + '[第１希望日]　2022年3月16日（水） 11:00\n';
		mailText = mailText + '[第２希望日]　2022年3月17日（木） 11:00\n';
		mailText = mailText + '\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + '「店舗管理ログイン画面」からログイン後、\n';
		mailText = mailText + 'TOP画面のメニューから「お問い合せ検索」を行ってください。\n';
		mailText = mailText + '※「店舗管理ログイン画面」はこちら\n';
		mailText = mailText + 'https://system.chintai.net/crs\n';
		mailText = mailText + '以上、ご対応よろしくお願い致します。\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '※ このメールは CHINTAIシステムより送信されております。\n';
		mailText = mailText + '(C) CHINTAI Corporation All rights reserved.\n';
		mailText = mailText + 'https://www.chintai.net\n';
		mailText = mailText + '────────── お問合せ確認メールについて ──────────\n';
		mailText = mailText + '・本メールは送信専用アドレスより配信されています。このメールに\n';
		mailText = mailText + '　返信されても不動産会社へは届きませんので、ご注意下さい。\n';
		mailText = mailText + '・このメールは、等幅フォントで最適にご覧いただけます。\n';
		mailText = mailText + '・内容に関するお問合せは以下のURLよりお問合せ下さい。\n';
		mailText = mailText + '　https://www.chintai.net/contact/\n';
		mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
		mailText = mailText + 'CHINTAI　https://www.chintai.net\n';
		mailText = mailText + '株式会社CHINTAI\n';
		mailText = mailText + '〒107-0051　東京都港区元赤坂1-2-7 AKASAKA K-TOWER 10階\n';
		mailText = mailText + 'CHINTAI Corporation All rights reserved.\n';
		mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

		email.plainTextBody = mailText;
		
		String subject = email.subject;
		// メールサービスの結果（期待値）
		Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
		expect.success = true;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		Test.startTest();
		createEchoMail hm = new createEchoMail();
		Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
		afterInsertAssertCheck(subject, mailText, '＜来店希望日＞', false, CommonConst.PORTALSITE_NAME_CHINTAI);
		Test.stopTest();
    }
	// ▲ 2022/3/7 CHINTAI対応による追加

	// ▼ 2022/3/7 CHINTAI対応による追加
    @isTest
    static void testWomanChintaiPropertyInquiry() {
		createPortalSite();
		List <Property__c> property = [SELECT PropertyCode__c FROM Property__c ORDER BY Id];
        // 引数に指定するメールと宛先
		Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new List<Messaging.InboundEmail.Header>();
		email.subject = '【Woman.CHINTAI】 物件お問合せお知らせメール';
		email.fromAddress = CommonConst.EMAIL_CHINTAI;
		email.toAddresses = new List<String>();
		email.toAddresses.add('testToAdress@rand.co.jp');
		email.References = new List<String>();
		email.References.add('テストreferencesです。１行目');
		email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
		
		string mailText = '───────────────────────────────────\n';
		mailText = mailText + '　株式会社CHINTAI　https://woman.chintai/\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '\n';
		mailText = mailText + '物件お問合せお知らせメール\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '\n';
		mailText = mailText + '株式会社洞口 ROOM SERECT丸の内店 御中\n';
		mailText = mailText + '\n';
		mailText = mailText + '「CHINTAI」が運営する「Woman.CHINTAI」お問合せフォームを利用し、\n';
		mailText = mailText + '貴社に対してお客様からお問合せがありました。\n';
		mailText = mailText + '\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + 'お問合せ時刻 : 2022/02/17 17:06:41\n';
		mailText = mailText + 'お問合せ元 : CHINTAIサテライトサイト\n';
		mailText = mailText + 'お問合せＩＤ : 2202071242133189\n';
		mailText = mailText + '\n';
		mailText = mailText + '＜見学希望日＞\n';
		mailText = mailText + '[第１希望日]　2022年3月16日（水） 11:00\n';
		mailText = mailText + '[第２希望日]　2022年3月17日（木） 11:00\n';
		mailText = mailText + '\n';
		mailText = mailText + '＜問合せ内容＞\n';
		mailText = mailText + '最寄り駅 : 名古屋市営地下鉄東山線/本陣\n';
		mailText = mailText + '所在地 : 名古屋市中村区大秋町4丁目\n';
		mailText = mailText + '賃料 : 45,000円\n';
		mailText = mailText + '共益費 : 3,500円\n';
		mailText = mailText + '間取り : 1K\n';
		mailText = mailText + '専有面積 : 22m2\n';
		mailText = mailText + '建物種別 : マンション\n';
		mailText = mailText + '建物構造 : 鉄筋コンクリート造\n';
		mailText = mailText + '築年 : 07/04\n';
		mailText = mailText + '物件番号 : 000000000' + property[0].PropertyCode__c + '\n';
		mailText = mailText + '部屋連番 : 0001\n';
		mailText = mailText + '物件名称 : ハウス大秋\n';
		mailText = mailText + '部屋号室 : 101\n';
		mailText = mailText + '問合せ番号 : CHINTAI東海575342\n';
		mailText = mailText + '掲載物件ＵＲＬ : https://www.chintai.net/detail/bk-C010092460000000005753420001/?vm=0\n';
		mailText = mailText + '\n';
		mailText = mailText + '＜お客様情報＞\n';
		mailText = mailText + '名前 : テスト　一郎\n';
		mailText = mailText + '名前（カナ） : テスト　イチロウ\n';
		mailText = mailText + '希望連絡方法 : メール/電話\n';
		mailText = mailText + 'メール : testchintai@hoge.com\n';
		mailText = mailText + '電話番号 : 0311111111\n';
		mailText = mailText + 'ＦＡＸ番号 :0322222222\n';
		mailText = mailText + '内容 : 初期費用が知りたい\n';
		mailText = mailText + 'コメント : この物件の初期費用をおしえてください。\n';
		mailText = mailText + '4月1日入居予定、駐車場もお願いする際は家賃代に追加となるのですか？それとも別途契約になりますか？\n';
		mailText = mailText + '転勤のため、家賃に含まれる方が都合が良いです。\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + '\n';
		mailText = mailText + '「店舗管理ログイン画面」からログイン後、\n';
		mailText = mailText + 'TOP画面のメニューから「お問い合せ検索」を行ってください。\n';
		mailText = mailText + '\n';
		mailText = mailText + '※「店舗管理ログイン画面」はこちら\n';
		mailText = mailText + 'https://system.chintai.net/crs\n';
		mailText = mailText + '\n';
		mailText = mailText + '以上、ご対応よろしくお願い致します。\n';
		mailText = mailText + '\n';
		mailText = mailText + '\n';
		mailText = mailText + '\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '※ このメールは CHINTAIシステムより送信されております。\n';
		mailText = mailText + '(C) CHINTAI Corporation All rights reserved.\n';
		mailText = mailText + 'https://woman.chintai/';

		email.plainTextBody = mailText;

		String subject = email.subject;
		System.debug(subject);
		// メールサービスの結果（期待値）
		Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
		expect.success = true;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		Test.startTest();
		createEchoMail hm = new createEchoMail();
		Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        System.debug(CommonConst.PORTALSITE_NAME_WOMANCHINTAI);
		afterInsertAssertCheck(subject, mailText, '＜見学希望日＞', true, CommonConst.PORTALSITE_NAME_WOMANCHINTAI);
		Test.stopTest();
    }
	// ▲ 2022/3/7 CHINTAI対応による追加

	// ▼ 2022/3/7 CHINTAI対応による追加
    @isTest
    static void testWomanChintaiShopInquiry() {
		createPortalSite();
		List <Property__c> property = [SELECT PropertyCode__c FROM Property__c ORDER BY Id];
		// 引数に指定するメールと宛先
		Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new List<Messaging.InboundEmail.Header>();
		email.subject = '【Woman.CHINTAI】店舗お問合せお知らせメール';
		email.fromAddress = CommonConst.EMAIL_CHINTAI;
		email.toAddresses = new List<String>();
		email.toAddresses.add('testToAdress@rand.co.jp');
		email.References = new List<String>();
		email.References.add('テストreferencesです。１行目');
		email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

		string mailText = '───────────────────────────────────\n';
		mailText = mailText + '　CHINTAI　https://www.chintai.net\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '店舗お問合せお知らせメール\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '株式会社洞口 ルームセレクト丸の内店　御中\n';
		mailText = mailText + '「Woman.CHINTAI」お問合せフォームを利用し、\n';
		mailText = mailText + '貴社に対してお客様からお問合せがありました。\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + 'お問合せ時刻 : 2022/02/17 17:06:41\n';
		mailText = mailText + 'お問合せ元 : CHINTAIサテライトサイト\n';
		mailText = mailText + 'お問合せＩＤ : 2203092049384246\n';
		mailText = mailText + '＜お客様情報＞\n';
		mailText = mailText + '名前 : テスト　一郎\n';
		mailText = mailText + '名前（カナ） : テスト　イチロウ\n';
		mailText = mailText + '希望連絡方法 : メール/電話\n';
		mailText = mailText + 'メール : testchintai@hoge.com\n';
		mailText = mailText + '電話番号 : 0311111111\n';
		mailText = mailText + 'ＦＡＸ番号 :0322222222\n';
		mailText = mailText + 'お問合せ内容 : 初期費用が知りたい\n';
		mailText = mailText + 'コメント : この物件の初期費用をおしえてください。\n';
		mailText = mailText + '4月1日入居予定、駐車場もお願いする際は家賃代に追加となるのですか？それとも別途契約になりますか？\n';
		mailText = mailText + '転勤のため、家賃に含まれる方が都合が良いです。\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + '\n';
		mailText = mailText + '＜来店希望日＞\n';
		mailText = mailText + '[第１希望日]　2022年3月16日（水） 11:00\n';
		mailText = mailText + '[第２希望日]　2022年3月17日（木） 11:00\n';
		mailText = mailText + '\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + '「店舗管理ログイン画面」からログイン後、\n';
		mailText = mailText + 'TOP画面のメニューから「お問い合せ検索」を行ってください。\n';
		mailText = mailText + '※「店舗管理ログイン画面」はこちら\n';
		mailText = mailText + 'https://system.chintai.net/crs\n';
		mailText = mailText + '以上、ご対応よろしくお願い致します。\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '※ このメールは CHINTAIシステムより送信されております。\n';
		mailText = mailText + '(C) CHINTAI Corporation All rights reserved.\n';
		mailText = mailText + 'https://www.chintai.net\n';
		mailText = mailText + '────────── お問合せ確認メールについて ──────────\n';
		mailText = mailText + '・本メールは送信専用アドレスより配信されています。このメールに\n';
		mailText = mailText + '　返信されても不動産会社へは届きませんので、ご注意下さい。\n';
		mailText = mailText + '・このメールは、等幅フォントで最適にご覧いただけます。\n';
		mailText = mailText + '・内容に関するお問合せは以下のURLよりお問合せ下さい。\n';
		mailText = mailText + '　https://www.chintai.net/contact/\n';
		mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
		mailText = mailText + 'CHINTAI　https://www.chintai.net\n';
		mailText = mailText + '株式会社CHINTAI\n';
		mailText = mailText + '〒107-0051　東京都港区元赤坂1-2-7 AKASAKA K-TOWER 10階\n';
		mailText = mailText + 'CHINTAI Corporation All rights reserved.\n';
		mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

		email.plainTextBody = mailText;
		
		String subject = email.subject;
		// メールサービスの結果（期待値）
		Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
		expect.success = true;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		Test.startTest();
		createEchoMail hm = new createEchoMail();
		Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
		afterInsertAssertCheck(subject, mailText, '＜来店希望日＞', false, CommonConst.PORTALSITE_NAME_WOMANCHINTAI);
		Test.stopTest();
    }
	// ▲ 2022/3/7 CHINTAI対応による追加

	// ▼ 2022/3/7 CHINTAI対応による追加
    @isTest
    static void testOnlineChintaiPropertyInquiry() {
		createPortalSite();
		List <Property__c> property = [SELECT PropertyCode__c FROM Property__c ORDER BY Id];
		// 引数に指定するメールと宛先
		Messaging.inboundEmail email = new Messaging.inboundEmail();
		email.headers = new List<Messaging.InboundEmail.Header>();
		email.subject = '【CHINTAI】物件オンライン相談お問合せお知らせメール';
		email.fromAddress = CommonConst.EMAIL_CHINTAI;
		email.toAddresses = new List<String>();
		email.toAddresses.add('testToAdress@rand.co.jp');
		email.References = new List<String>();
		email.References.add('テストreferencesです。１行目');
		email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

		string mailText = '───────────────────────────────────\n';
		mailText = mailText + '　CHINTAI　https://www.chintai.net\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '\n';
		mailText = mailText + '物件オンライン相談お問合せお知らせメール\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '\n';
		mailText = mailText + '株式会社洞口 ROOM SERECT丸の内店 御中\n';
		mailText = mailText + '\n';
		mailText = mailText + '「CHINTAI」お問合せフォームを利用し、\n';
		mailText = mailText + '貴社に対してお客様からお問合せがありました。\n';
		mailText = mailText + '\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + 'お問合せ時刻 : 2022/02/17 17:06:41\n';
		mailText = mailText + 'お問合せ元 : ネット\n';
		mailText = mailText + 'お問合せＩＤ : 2202171706417191\n';
		mailText = mailText + '\n';
		mailText = mailText + '＜オンライン相談希望日＞\n';
		mailText = mailText + '[第１希望日]　2022年3月16日（水） 11:00\n';
		mailText = mailText + '[第２希望日]　2022年3月17日（木） 11:00\n';
		mailText = mailText + '\n';
		mailText = mailText + '＜問合せ内容＞\n';
		mailText = mailText + '最寄り駅 : 名古屋市営地下鉄東山線/本陣\n';
		mailText = mailText + '所在地 : 名古屋市中村区大秋町4丁目\n';
		mailText = mailText + '賃料 : 45,000円\n';
		mailText = mailText + '共益費 : 3,500円\n';
		mailText = mailText + '間取り : 1K\n';
		mailText = mailText + '専有面積 : 22m2\n';
		mailText = mailText + '建物種別 : マンション\n';
		mailText = mailText + '建物構造 : 鉄筋コンクリート造\n';
		mailText = mailText + '築年 : 07/04\n';
		mailText = mailText + '物件番号 : 000000000' + property[0].PropertyCode__c + '\n';
		mailText = mailText + '部屋連番 : 0001\n';
		mailText = mailText + '物件名称 : ハウス大秋\n';
		mailText = mailText + '部屋号室 : 101\n';
		mailText = mailText + '問合せ番号 : CHINTAI東海575342\n';
		mailText = mailText + '掲載物件ＵＲＬ : https://www.chintai.net/detail/bk-C010092460000000005753420001/?vm=0\n';
		mailText = mailText + '\n';
		mailText = mailText + '＜お客様情報＞\n';
		mailText = mailText + '名前 : テスト　一郎\n';
		mailText = mailText + '名前（カナ） : テスト　イチロウ\n';
		mailText = mailText + '希望連絡方法 : メール/電話\n';
		mailText = mailText + 'メール : testchintai@hoge.com\n';
		mailText = mailText + '電話番号 : 0311111111\n';
		mailText = mailText + 'ＦＡＸ番号 :0322222222\n';
		mailText = mailText + '内容 : 初期費用が知りたい\n';
		mailText = mailText + 'コメント : この物件の初期費用をおしえてください。\n';
		mailText = mailText + '4月1日入居予定、駐車場もお願いする際は家賃代に追加となるのですか？それとも別途契約になりますか？\n';
		mailText = mailText + '転勤のため、家賃に含まれる方が都合が良いです。\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + '\n';
		mailText = mailText + '「店舗管理ログイン画面」からログイン後、\n';
		mailText = mailText + 'TOP画面のメニューから「お問い合せ検索」を行ってください。\n';
		mailText = mailText + '\n';
		mailText = mailText + '※「店舗管理ログイン画面」はこちら\n';
		mailText = mailText + 'https://system.chintai.net/crs\n';
		mailText = mailText + '\n';
		mailText = mailText + '以上、ご対応よろしくお願い致します。\n';
		mailText = mailText + '\n';
		mailText = mailText + '\n';
		mailText = mailText + '\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '※ このメールは CHINTAIシステムより送信されております。\n';
		mailText = mailText + '(C) CHINTAI Corporation All rights reserved.\n';
		mailText = mailText + 'https://www.chintai.net';

		email.plainTextBody = mailText;

		String subject = email.subject;
		
		// メールサービスの結果（期待値）
		Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
		expect.success = true;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		Test.startTest();
		createEchoMail hm = new createEchoMail();
		Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
		afterInsertAssertCheck(subject, mailText, '＜オンライン相談希望日＞', true, CommonConst.PORTALSITE_NAME_CHINTAI);
		Test.stopTest();
    }
	// ▲ 2022/3/7 CHINTAI対応による追加

	// ▼ 2022/3/7 CHINTAI対応による追加
    @isTest
    static void testOnlineChintaiShopInquiry() {
		createPortalSite();
		List <Property__c> property = [SELECT PropertyCode__c FROM Property__c ORDER BY Id];
		// 引数に指定するメールと宛先
		Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new List<Messaging.InboundEmail.Header>();
		email.subject = '【CHINTAI】 店舗オンライン相談お問合せお知らせメール';
		email.fromAddress = CommonConst.EMAIL_CHINTAI;
		email.toAddresses = new List<String>();
		email.toAddresses.add('testToAdress@rand.co.jp');
		email.References = new List<String>();
		email.References.add('テストreferencesです。１行目');
		email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

		string mailText = '───────────────────────────────────\n';
		mailText = mailText + '　CHINTAI　https://www.chintai.net\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '店舗オンライン相談お問合せお知らせメール\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '株式会社洞口 ルームセレクト丸の内店　御中\n';
		mailText = mailText + '「CHINTAI」お問合せフォームを利用し、\n';
		mailText = mailText + '貴社に対してお客様からお問合せがありました。\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + 'お問合せ時刻 : 2022/02/17 17:06:41\n';
		mailText = mailText + 'お問合せ元 : スマホ\n';
		mailText = mailText + 'お問合せＩＤ : 2203092049384246\n';
		mailText = mailText + '＜お客様情報＞\n';
		mailText = mailText + '名前 : テスト　一郎\n';
		mailText = mailText + '名前（カナ） : テスト　イチロウ\n';
		mailText = mailText + '希望連絡方法 : メール/電話\n';
		mailText = mailText + 'メール : testchintai@hoge.com\n';
		mailText = mailText + '電話番号 : 0311111111\n';
		mailText = mailText + 'ＦＡＸ番号 :0322222222\n';
		mailText = mailText + 'お問合せ内容 : 初期費用が知りたい\n';
		mailText = mailText + 'コメント : この物件の初期費用をおしえてください。\n';
		mailText = mailText + '4月1日入居予定、駐車場もお願いする際は家賃代に追加となるのですか？それとも別途契約になりますか？\n';
		mailText = mailText + '転勤のため、家賃に含まれる方が都合が良いです。\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + '\n';
		mailText = mailText + '＜オンライン相談希望日＞\n';
		mailText = mailText + '[第１希望日]　2022年3月16日（水） 11:00\n';
		mailText = mailText + '[第２希望日]　2022年3月17日（木） 11:00\n';
		mailText = mailText + '\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + '「店舗管理ログイン画面」からログイン後、\n';
		mailText = mailText + 'TOP画面のメニューから「お問い合せ検索」を行ってください。\n';
		mailText = mailText + '※「店舗管理ログイン画面」はこちら\n';
		mailText = mailText + 'https://system.chintai.net/crs\n';
		mailText = mailText + '以上、ご対応よろしくお願い致します。\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '※ このメールは CHINTAIシステムより送信されております。\n';
		mailText = mailText + '(C) CHINTAI Corporation All rights reserved.\n';
		mailText = mailText + 'https://www.chintai.net\n';
		mailText = mailText + '────────── お問合せ確認メールについて ──────────\n';
		mailText = mailText + '・本メールは送信専用アドレスより配信されています。このメールに\n';
		mailText = mailText + '　返信されても不動産会社へは届きませんので、ご注意下さい。\n';
		mailText = mailText + '・このメールは、等幅フォントで最適にご覧いただけます。\n';
		mailText = mailText + '・内容に関するお問合せは以下のURLよりお問合せ下さい。\n';
		mailText = mailText + '　https://www.chintai.net/contact/\n';
		mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
		mailText = mailText + 'CHINTAI　https://www.chintai.net\n';
		mailText = mailText + '株式会社CHINTAI\n';
		mailText = mailText + '〒107-0051　東京都港区元赤坂1-2-7 AKASAKA K-TOWER 10階\n';
		mailText = mailText + 'CHINTAI Corporation All rights reserved.\n';
		mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

		email.plainTextBody = mailText;
		
		String subject = email.subject;
		// メールサービスの結果（期待値）
		Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
		expect.success = true;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		Test.startTest();
		createEchoMail hm = new createEchoMail();
		Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
		afterInsertAssertCheck(subject, mailText, '＜オンライン相談希望日＞', false, CommonConst.PORTALSITE_NAME_CHINTAI);
		Test.stopTest();
    }
	// ▲ 2022/3/7 CHINTAI対応による追加

	// ▼ 2022/3/7 CHINTAI対応による追加
	@isTest
	static void testChintaiBlankMail() {
		createPortalSite();
		List <Property__c> property = [SELECT PropertyCode__c FROM Property__c ORDER BY Id];
		// 引数に指定するメールと宛先
		Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new List<Messaging.InboundEmail.Header>();
		email.subject = '【CHINTAI】 店舗お問合せお知らせメール';
		email.fromAddress = CommonConst.EMAIL_CHINTAI;
		email.toAddresses = new List<String>();
		email.toAddresses.add('testToAdress@rand.co.jp');
		email.References = new List<String>();
		email.References.add('テストreferencesです。１行目');
		email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

		String mailText = null;
		email.plainTextBody = mailText;
		
		String subject = email.subject;
		// メールサービスの結果（期待値）
		Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
		expect.success = true;
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		Test.startTest();
		Datetime nowDate = CommonUtil.getNow();
		createEchoMail hm = new createEchoMail();
		Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
		afterInsertBlankMailAssertCheck(subject, mailText, CommonConst.PORTALSITE_NAME_CHINTAI, nowDate);
		Test.stopTest();
	}
	// ▲ 2022/3/7 CHINTAI対応による追加

    //▼問合せNo0595で追加 
    /**
    * １、メール受信
    *     問合せメール1件（店舗）
    *     メールアドレスに店舗のアドレスがセットされること
    */
    @istest static void mailQueryShop(){
        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        email.subject = 'テスト件名です。';
        Messaging.InboundEmail.Header addre = new Messaging.InboundEmail.Header();
        addre.name = 'X-SFDC-Original-RCPT';
        addre.value = 'toTESTShop1@abcde12345apex.salesforce.com';
        email.headers.add(addre);
        email.fromAddress = 'fromTEST@TEST.co.jp';
        email.toAddresses = new List<String>();
        email.toAddresses.add('toTESTShop1@TEST.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
        
        string mailText = 'テスト店１\n';
        mailText = mailText + 'テスト店(株)  テスト様\n';
        
        email.plainTextBody = mailText;

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        createEchoMail hm = new createEchoMail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();

        Shop__c shopData = [SELECT ID
                            ,      Email__c
                            FROM   Shop__c
                            WHERE  name = 'テスト１店'
                            LIMIT  1
        ];
        EchoMail__c EchoMailData = [SELECT ID
                                    ,      Email__c
                                    FROM   EchoMail__c
                                    LIMIT  1
        ];

        // 店舗のメールアドレスが反響メールのメールと一致
        system.assertEquals(EchoMailData.Email__c,shopData.Email__c);       
        
    }

    /**
    * ２、メール受信
    *     問合せメール1件（店舗外）
    *     メールアドレスに店舗外のアドレスがセットされること
    */
    @istest static void mailQueryGeneral(){
        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        email.subject = 'テスト件名です。';
        Messaging.InboundEmail.Header addre = new Messaging.InboundEmail.Header();
        addre.name = 'X-SFDC-Original-RCPT';
        addre.value = 'toTESTnotShop@abcde12345apex.salesforce.com';
        email.headers.add(addre);
        email.fromAddress = 'fromTEST@TEST.co.jp';
        email.toAddresses = new List<String>();
        email.toAddresses.add('toTESTnotShop@TEST.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
        
        string mailText = 'テスト店\n';
        mailText = mailText + 'テスト店(株)  テスト様\n';
        
        email.plainTextBody = mailText;

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        createEchoMail hm = new createEchoMail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();

        Shop__c shopData = [SELECT ID
                            ,      Email__c
                            FROM   Shop__c
                            WHERE  name = 'テスト１店'
                            LIMIT  1
        ];
        EchoMail__c EchoMailData = [SELECT ID
                                    ,      Email__c
                                    FROM   EchoMail__c
                                    LIMIT  1
        ];

        // 店舗のメールアドレスが反響メールのメールと不一致
        system.assertNotEquals(EchoMailData.Email__c,shopData.Email__c);
        
    }

    
    /**
    * ３、メール受信
    *     問合せメール複数（店舗）
    *     メールアドレスにToの1件目の店舗アドレスがセットされること
    */
    @istest static void mailQueryShopPlural(){

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        email.subject = 'テスト件名です。';
        Messaging.InboundEmail.Header addre = new Messaging.InboundEmail.Header();
        addre.name = 'X-SFDC-Original-RCPT';
        addre.value = 'toTESTShop2@abcde12345apex.salesforce.com';
        email.headers.add(addre);
        addre = new Messaging.InboundEmail.Header();
        addre.name = 'X-SFDC-Original-RCPT';
        addre.value = 'toTESTShop1@abcde12345apex.salesforce.com';        
        email.headers.add(addre);
        email.fromAddress = 'fromTEST@TEST.co.jp';
        email.toAddresses = new List<String>();
        email.toAddresses.add('toTESTShop2@TEST.co.jp');
        email.toAddresses.add('toTESTShop1@TEST.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
        
        string mailText = 'テスト２店\n';
        mailText = mailText + 'テスト店(株)  テスト様\n';
        
        email.plainTextBody = mailText;

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        createEchoMail hm = new createEchoMail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();

        Shop__c shopData = [SELECT ID
                            ,      Email__c
                            FROM   Shop__c
                            WHERE  name = 'テスト２店'
                            LIMIT  1
        ];
        EchoMail__c EchoMailData = [SELECT ID
                                    ,      Email__c
                                    FROM   EchoMail__c
                                    LIMIT  1
        ];

        // 店舗のメールアドレスが反響メールのメールと一致
        system.assertEquals(EchoMailData.Email__c,shopData.Email__c);
        
    }

    /**
    * ４、メール受信
    *     問合せメール複数（店舗、店舗外）
    *     メールアドレスに店舗アドレスがセットされること
    */
    @istest static void mailQueryShopAndGeneral(){

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        email.subject = 'テスト件名です。';
        Messaging.InboundEmail.Header addre = new Messaging.InboundEmail.Header();
        addre.name = 'X-SFDC-Original-RCPT';
        addre.value = 'toTESTShop2@abcde12345apex.salesforce.com';
        email.headers.add(addre);
        addre = new Messaging.InboundEmail.Header();
        addre.name = 'X-SFDC-Original-RCPT';
        addre.value = 'toTESTnotShop1@abcde12345apex.salesforce.com';        
        email.headers.add(addre);
        email.fromAddress = 'fromTEST@TEST.co.jp';
        email.toAddresses = new List<String>();
        email.toAddresses.add('toTESTShop2@TEST.co.jp');
        email.toAddresses.add('toTESTnotShop@TEST.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
        
        string mailText = 'テスト店\n';
        mailText = mailText + 'テスト店(株)  テスト様\n';
        
        email.plainTextBody = mailText;        

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        createEchoMail hm = new createEchoMail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();

        Shop__c shopData = [SELECT ID
                            ,      Email__c
                            FROM   Shop__c
                            WHERE  name = 'テスト２店'
                            LIMIT  1
        ];
        EchoMail__c EchoMailData = [SELECT ID
                                    ,      Email__c
                                    FROM   EchoMail__c
                                    LIMIT  1
        ];

        // 店舗のメールアドレスが反響メールのメールと一致
        system.assertEquals(EchoMailData.Email__c,shopData.Email__c);
        
    }

    /**
    * ５、メール受信
    *     問合せメール複数（店舗外、店舗）
    *     メールアドレスに店舗アドレスがセットされること
    */
    @istest static void mailQueryGeneralAndShop(){
        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        email.subject = 'テスト件名です。';
        email.fromAddress = 'fromTEST@TEST.co.jp';
        email.toAddresses = new List<String>();
        email.toAddresses.add('toTESTnotShop@TEST.co.jp');
        email.toAddresses.add('toTESTShop2@TEST.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
        
        string mailText = 'テスト店\n';
        mailText = mailText + 'テスト店(株)  テスト様\n';
        
        email.plainTextBody = mailText;       

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        createEchoMail hm = new createEchoMail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();

        Shop__c shopData = [SELECT ID
                            ,      Email__c
                            FROM   Shop__c
                            WHERE  name = 'テスト２店'
                            LIMIT  1
        ];
        EchoMail__c EchoMailData = [SELECT ID
                                    ,      Email__c
                                    FROM   EchoMail__c
                                    LIMIT  1
        ];

        // 店舗のメールアドレスが反響メールのメールと一致
        system.assertEquals(EchoMailData.Email__c,shopData.Email__c);
        
    }

    
    /**
    * ６、メール受信
    *     問合せメール複数（店舗外）
    *     メールアドレスに店舗外のアドレスがセットされること
    */
    @istest static void mailQueryGeneralPlural(){
        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        email.subject = 'テスト件名です。';
        Messaging.InboundEmail.Header addre = new Messaging.InboundEmail.Header();
        addre.name = 'X-SFDC-Original-RCPT';
        addre.value = 'toTESTnotShop@abcde12345apex.salesforce.com';        
        email.headers.add(addre);
        addre = new Messaging.InboundEmail.Header();
        addre.name = 'X-SFDC-Original-RCPT';
        addre.value = 'toTESTnotShop2@abcde12345apex.salesforce.com';
        email.headers.add(addre);
        email.fromAddress = 'fromTEST@TEST.co.jp';
        email.toAddresses = new List<String>();
        email.toAddresses.add('toTESTnotShop@TEST.co.jp');
        email.toAddresses.add('toTESTnotShop2@TEST.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
        
        string mailText = 'テスト店\n';
        mailText = mailText + 'テスト店(株)  テスト様\n';
        
        email.plainTextBody = mailText;

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        createEchoMail hm = new createEchoMail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();

        Shop__c shopData = [SELECT ID
                            ,      Email__c
                            FROM   Shop__c
                            WHERE  name = 'テスト２店'
                            LIMIT  1
        ];
        EchoMail__c EchoMailData = [SELECT ID
                                    ,      Email__c
                                    FROM   EchoMail__c
                                    LIMIT  1
        ];

        // 店舗のメールアドレスが反響メールのメールと一致
        system.assertnotEquals(EchoMailData.Email__c,shopData.Email__c);
        
    }

    /**
    * ７、メール受信
    *     問合せメール複数To（店舗、店舗外）
    *     CC（店舗）
    *     メールアドレスに店舗アドレスがセットされること
    */
    @istest static void mailQueryGeneralAndShopCC(){

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        email.subject = 'テスト件名です。';
        Messaging.InboundEmail.Header addre = new Messaging.InboundEmail.Header();
        addre.name = 'X-SFDC-Original-RCPT';
        addre.value = 'toTESTnotShop@abcde12345apex.salesforce.com';        
        email.headers.add(addre);
        addre = new Messaging.InboundEmail.Header();
        addre.name = 'X-SFDC-Original-RCPT';
        addre.value = 'toTESTnotShop2@abcde12345apex.salesforce.com';
        email.headers.add(addre);
        email.fromAddress = 'fromTEST@TEST.co.jp';
        email.toAddresses = new List<String>();
        email.toAddresses.add('toTESTShop1@TEST.co.jp');
        email.toAddresses.add('toTESTnotShop2@TEST.co.jp');
        email.ccAddresses = new List<String>();
        email.ccAddresses.add('toTESTShop2@TEST.co.jp'); 
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
        
        string mailText = 'テスト店\n';
        mailText = mailText + 'テスト店(株)  テスト様\n';
        
        email.plainTextBody = mailText;


    
        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        createEchoMail hm = new createEchoMail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();

        Shop__c shopData = [SELECT ID
                            ,      Email__c
                            FROM   Shop__c
                            WHERE  name = 'テスト１店'
                            LIMIT  1
        ];
        EchoMail__c EchoMailData = [SELECT ID
                                    ,      Email__c
                                    FROM   EchoMail__c
                                    LIMIT  1
        ];

        // 店舗のメールアドレスが反響メールのメールと一致
        system.assertEquals(EchoMailData.Email__c,shopData.Email__c);
        
    }

    /**
    * ８、メール受信
    *     ポータルサイト問合せメール（他社ポータル）
    *     メールアドレスに店舗アドレスがセットされること
    */
    @istest static void mailOtherCompaniesPortal(){

        List <Property__c> property = [SELECT Id, PropertyCode__c FROM Property__c ORDER BY Id];

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.subject = '[リクルートＪＤＳ]反響お知らせメール';
        Messaging.InboundEmail.Header addre = new Messaging.InboundEmail.Header();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        addre.name = 'X-SFDC-Original-RCPT';
        addre.value = 'toTESTShop1@abcde12345apex.salesforce.com';        
        email.headers.add(addre);
        email.fromAddress = CommonConst.EMAIL_ATHOME;
        email.toAddresses = new List<String>();
        email.toAddresses.add('toTESTShop1@TEST.co.jp');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        string mailText = '';
        mailText = mailText + '洞口テスト店\n';
        mailText = mailText + 'テスト会社 テスト太郎様\n';
        mailText = mailText + '反響到着日時　2021/09/03 17:30:01\n';
        mailText = mailText + '\n';
        mailText = mailText + 'ＩＤ：111969501303\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お問合せ日時：2021/09/03 17:30:01\n';
        mailText = mailText + '連番：0056942091\n';
        mailText = mailText + 'お問合せ企画：ＳＵＵＭＯネット／賃貸物件枠問い合わせ（モバイル）\n';
        mailText = mailText + '反響送付先区分：会社\n';
        mailText = mailText + '反響送付先コード：11969501303\n';
        mailText = mailText + '\n';
        mailText = mailText + '☆☆☆　お客様からの反響です　☆☆☆\n';
        mailText = mailText + '\n';
        mailText = mailText + '※お問合せ内容に従ってお客様へご連絡お願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '問合せ物件\n';
        mailText = mailText + '会社名：ROOM SELECT桜山店(株)洞口\n';
        mailText = mailText + '物件種別：アパート\n';
        mailText = mailText + '物件コード：100212882325\n';
        mailText = mailText + '物件名：てすたにacc\n';
        mailText = mailText + '物件コード：' + property[0].PropertyCode__c + '\n';
        mailText = mailText + '最寄り駅：地下鉄鶴舞線/御器所\n';
        mailText = mailText + 'バス／歩：-／7分\n';
        mailText = mailText + '所在地：愛知県名古屋市ああ\n';
        mailText = mailText + '賃料：2万円\n';
        mailText = mailText + '間取り：\n';
        mailText = mailText + '専有面積：1.00平米\n';
        mailText = mailText + '物件詳細画面：https://suumo.jp/chintai/bc_100212882325/\n';
        mailText = mailText + '\n';
        mailText = mailText + '−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−\n';
        mailText = mailText + '\n';
        mailText = mailText + 'お客様プロフィール\n';
        mailText = mailText + '名前（漢字）：テスト次郎\n';
        mailText = mailText + '名前（カナ）：\n';
        mailText = mailText + 'メールアドレス：testToAdress@rand.co.jp\n';
        mailText = mailText + 'ＴＥＬ：123456789000\n';
        mailText = mailText + 'FAX：\n';
        mailText = mailText + '連絡方法：メール\n';
        mailText = mailText + 'お問合せ内容：この部屋を実際に見学したい\n';
        mailText = mailText + 'お問合せ内容コメント：初期費用について知りたい\n';
        mailText = mailText + '\n';
        mailText = mailText + '−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '\n';
        mailText = mailText + '■■■■■■■■　住宅情報ダウンロードシステム（ＪＤＳ）より お知らせ　■■■■■■■■\n';
        mailText = mailText + '\n';
        mailText = mailText + '平素より大変お世話になっております。\n';
        mailText = mailText + '下記、２点お知らせがございます。ご確認のほどよろしくお願いいたします。\n';
        mailText = mailText + '\n';
        mailText = mailText + '１）システムメンテナンスによる夜間利用停止について\n';
        mailText = mailText + '　下記日程はシステムメンテナンスの為、住宅情報ダウンロードシステム（ＪＤＳ）がご利用頂けません。\n';
        mailText = mailText + '　ご不便をおかけいたしますが、何卒ご理解を頂きますようお願い申し上げます。\n';
        mailText = mailText + '\n';
        mailText = mailText + '　07月28日（水）AM 2:00 〜 AM 8:00　サービス停止\n';
        mailText = mailText + '\n';
        mailText = mailText + '２）利用規約（約款）の変更について\n';
        mailText = mailText + '　JDSの利用規約（約款）について、下記の改訂を行いますので通知致します。\n';
        mailText = mailText + '　詳細は、JDSログイン後トップ画面の JDS利用約款 をご確認下さい。\n';
        mailText = mailText + '\n';
        mailText = mailText + '　・ 2年間以上利用されていないIDの削除について表記を追加（利用約款 第５条、第１８条）\n';
        mailText = mailText + '\n';
        mailText = mailText + '　改訂日：2021年6月23日\n';
        mailText = mailText + '　適用日：2021年7月26日\n';
        mailText = mailText + '\n';
        mailText = mailText + '※このメールは（株）リクルート　住宅情報ダウンロードシステムより\n';
        mailText = mailText + '　自動発信しています。\n';
        mailText = mailText + '※お客様の入力した情報をそのまま送信しておりますので、情報に誤りがあっても\n';
        mailText = mailText + '　リクルートではその真偽はわかりかねます。ご了承くださいませ。\n';
        mailText = mailText + '　お心当たりのない方は恐れ入りますが下記までご連絡願います。\n';
        mailText = mailText + '※反響情報が含まれる反響お知らせメールの設定は、ＪＤＳの最終ログイン日から６ヶ月の間有効です。\n';
        mailText = mailText + '　設定を維持するためには、定期的にＪＤＳにログインして下さい。\n';
        mailText = mailText + '\n';
        mailText = mailText + '株式会社リクルート　ＪＤＳ（住宅情報ダウンロードシステム）サポートセンター\n';
        mailText = mailText + '０１２０−２３６−５２０\n';
        mailText = mailText + '０１２０−５３３−７３０（首都圏新築分譲マンション用）\n';
        mailText = mailText + 'jds_support@r.recruit.co.jp\n';
        mailText = mailText + '受付時間：月〜金　１０：００〜１８：００（祝日を除く）\n';
        mailText = mailText + 'ＪＤＳ（住宅情報ダウンロードシステム）：https://jds.suumo.jp/\n';
        mailText = mailText + '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ RECRUIT ■□■\n';

        email.plainTextBody = mailText;


        
        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        createEchoMail hm = new createEchoMail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();

        Shop__c shopData = [SELECT ID
                            ,      Email__c
                            FROM   Shop__c
                            WHERE  name = 'テスト１店'
                            LIMIT  1
        ];
        EchoMail__c EchoMailData = [SELECT ID
                        ,      Email__c
                        FROM   EchoMail__c
                        LIMIT  1
        ];

        // 店舗のメールアドレスが反響メールのメールと一致
        system.assertEquals(EchoMailData.Email__c,shopData.Email__c);
        
    }

    
    /**
    * ９、メール受信
    *     ポータルサイト問合せメール（自社ポータル）
    *     メールアドレスに店舗アドレスがセットされること
    */
    @istest static void mailTheirPortal(){
        // 引数に指定するメールと宛先
        Messaging.InboundEmail.Header addre = new Messaging.InboundEmail.Header();
        addre.name = 'X-SFDC-Original-RCPT';
        addre.value = 'toTESTShop1@abcde12345apex.salesforce.com';    
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        email.subject = 'テスト件名です。';
        email.headers.add(addre);
        email.fromAddress = CommonConst_ptl.EMAIL_PORTAL;    
        email.toAddresses = new List<String>();
        email.toAddresses.add('toTESTShop1@TEST.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

        email.plainTextBody = createPortalBody();
        
        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;


        Test.startTest();
        createEchoMail hm = new createEchoMail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email,env);

        Test.stopTest();

        Shop__c shopData = [SELECT ID
                            ,      Email__c
                            FROM   Shop__c
                            WHERE  name = 'テスト１店'
                            LIMIT  1
        ];
        EchoMail__c EchoMailData = [SELECT ID
                                    ,      Email__c
                                    FROM   EchoMail__c
                                    LIMIT  1
        ];

        // 店舗のメールアドレスが反響メールのメールと一致
        system.assertEquals(EchoMailData.Email__c,shopData.Email__c);
    }

    /**
    * １０、転送のメールアドレスが無い
    *       店舗のメールアドレスを受信
    *       メールアドレスに店舗アドレスがセットされること
    */
    @istest static void mailQueryShopNotSFDC(){

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        email.subject = 'テスト件名です。';
        email.fromAddress = 'fromTEST@TEST.co.jp';
        email.toAddresses = new List<String>();
        email.toAddresses.add('toTESTShop1@TEST.co.jp'); 
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
        
        string mailText = 'テスト店\n';
        mailText = mailText + 'テスト店(株)  テスト様\n';
        
        email.plainTextBody = mailText;

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        createEchoMail hm = new createEchoMail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();

        Shop__c shopData = [SELECT ID
                            ,      Email__c
                            FROM   Shop__c
                            WHERE  name = 'テスト１店'
                            LIMIT  1
        ];
        EchoMail__c EchoMailData = [SELECT ID
                                    ,      Email__c
                                    FROM   EchoMail__c
                                    LIMIT  1
        ];

        // 店舗のメールアドレスが反響メールのメールと一致
        system.assertEquals(EchoMailData.Email__c,shopData.Email__c);
        
    }

    /**
    * １１、転送のメールアドレスが無い
    *       店舗外のメールアドレスを受信
    *       メールアドレスに店舗外のアドレスがセットされること
    */
    @istest static void mailQueryGeneralNotSFDC(){

        // 引数に指定するメールと宛先
        Messaging.inboundEmail email = new Messaging.inboundEmail();
        email.headers = new  List<Messaging.InboundEmail.Header>();
        email.subject = 'テスト件名です。';
        email.fromAddress = 'fromTEST@TEST.co.jp';
        email.toAddresses = new List<String>();
        email.toAddresses.add('toTESTnotShop2@TEST.co.jp');
        email.References = new List<String>();
        email.References.add('テストreferencesです。１行目');
        email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
        
        string mailText = 'テスト店\n';
        mailText = mailText + 'テスト店(株)  テスト様\n';
        
        email.plainTextBody = mailText;

        // メールサービスの結果（期待値）
        Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
        expect.success = true;

        Test.startTest();
        createEchoMail hm = new createEchoMail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
        Test.stopTest();

        Shop__c shopData = [SELECT ID
                            ,      Email__c
                            FROM   Shop__c
                            WHERE  name = 'テスト１店'
                            LIMIT  1
        ];
        EchoMail__c EchoMailData = [SELECT ID
                                    ,      Email__c
                                    FROM   EchoMail__c
                                    LIMIT  1
        ];

        // 店舗のメールアドレスが反響メールのメールと不一致
        system.assertnotEquals(EchoMailData.Email__c,shopData.Email__c);
        
    }
    //▲問合せNo0595で追加 

	// ▼ 2022/3/7 CHINTAI対応による追加
	private static void afterInsertAssertCheck(String subject, String mailText, String visitDay, Boolean isPropertyMail , String portalSiteName){
		// 反響メール登録後の登録値確認用デバッグログ
        List<String> result = New List<String>{};
        Map<String, Schema.SObjectField> echoMailFieldMap = Schema.getGlobalDescribe().get('EchoMail__c').getDescribe().fields.getMap();
        for(String s: echoMailFieldMap.keySet()) {
            // カスタム項目だけ選択
            if (s.endsWith('__c')) {
                result.add(s);
            }
        }
        List<EchoMail__c> echoMail = Database.query(
        ' SELECT ID, Name, ' + String.join(result, ',') +' FROM EchoMail__c');
		List <Property__c> property = [SELECT PropertyCode__c FROM Property__c ORDER BY Id];
        List <PortalSite__c> portalSiteList = [SELECT Id FROM PortalSite__c WHERE Name =: portalSiteName];
        for (EchoMail__c echoMailData : echoMail) {
			// 共通確認項目
			system.assertEquals(echoMailData.Subject__c, subject);
			system.assertEquals(echoMailData.Body__c, mailText);
			system.assertEquals(echoMailData.InquiryDateTime__c, Datetime.newInstance(2022, 02, 17, 17, 06, 41));
			system.assertEquals(echoMailData.VisitDesiredDateTime__c, visitDay + ':[第１希望日]　2022年3月16日（水） 11:00　[第２希望日]　2022年3月17日（木） 11:00');
			system.assertEquals(echoMailData.CustomerName__c, 'テスト　一郎');
			system.assertEquals(echoMailData.CustomerNameKana__c, 'テスト　イチロウ');
			system.assertEquals(echoMailData.ContactMeans__c, 'メール/電話');
			system.assertEquals(echoMailData.FromEmail__c, 'testchintai@hoge.com');
			system.assertEquals(echoMailData.Phone__c, '0311111111');
			system.assertEquals(echoMailData.Fax__c, '0322222222');
			system.assertEquals(echoMailData.FromPotalSite__c, portalSiteList[0].Id);
            // 物件問合せはTrue、店舗問合せはFalseに設定
			if (isPropertyMail) {
				system.assertEquals(echoMailData.ClosestStation__c, '名古屋市営地下鉄東山線/本陣');
				system.assertEquals(echoMailData.PropertyAddress__c, '名古屋市中村区大秋町4丁目');
				system.assertEquals(echoMailData.RentFee__c, '45,000円');
				system.assertEquals(echoMailData.RoomLayout__c, '1K');
				system.assertEquals(echoMailData.PropertyArea__c, '22m2');
				system.assertEquals(echoMailData.PropertyCode__c, property[0].PropertyCode__c);
				system.assertEquals(echoMailData.Response__c, property[0].Id);
				system.assertEquals(echoMailData.PropertyName__c, 'ハウス大秋 101');
				system.assertEquals(echoMailData.PropertURL__c, 'https://www.chintai.net/detail/bk-C010092460000000005753420001/?vm=0');	
				system.assertEquals(echoMailData.InquiryContent__c, '内容 : 初期費用が知りたい\nコメント : この物件の初期費用をおしえてください。\n4月1日入居予定、駐車場もお願いする際は家賃代に追加となるのですか？それとも別途契約になりますか？\n転勤のため、家賃に含まれる方が都合が良いです。');
			} else {
				system.assertEquals(echoMailData.InquiryContent__c, 'お問合せ内容 : 初期費用が知りたい\nコメント : この物件の初期費用をおしえてください。\n4月1日入居予定、駐車場もお願いする際は家賃代に追加となるのですか？それとも別途契約になりますか？\n転勤のため、家賃に含まれる方が都合が良いです。');
			}
		}
	}
	// ▲ 2022/3/7 CHINTAI対応による追加

	// ▼ 2022/3/7 CHINTAI対応による追加
	private static void afterInsertBlankMailAssertCheck(String subject, String mailText, String portalSiteName, Datetime nowDate){
		// 反響メール登録後の登録値確認用デバッグログ
        List<String> result = New List<String>{};
        Map<String, Schema.SObjectField> echoMailFieldMap = Schema.getGlobalDescribe().get('EchoMail__c').getDescribe().fields.getMap();
        for(String s: echoMailFieldMap.keySet()) {
            // カスタム項目だけ選択
            if (s.endsWith('__c')) {
                result.add(s);
            }
        }
        List<EchoMail__c> echoMail = Database.query(
        ' SELECT ID, Name, ' + String.join(result, ',') +' FROM EchoMail__c');
		List <Property__c> property = [SELECT PropertyCode__c FROM Property__c ORDER BY Id];
        List <PortalSite__c> portalSiteList = [SELECT Id, Email__c FROM PortalSite__c WHERE Name =: portalSiteName];
        for (EchoMail__c echoMailData : echoMail) {
			// 共通確認項目
			system.assertEquals(echoMailData.Subject__c, subject);
			system.assertEquals(echoMailData.Body__c, mailText);
			system.assertEquals(echoMailData.InquiryDateTime__c, nowDate);
			system.assertEquals(echoMailData.VisitDesiredDateTime__c, null);
			system.assertEquals(echoMailData.CustomerName__c, null);
			system.assertEquals(echoMailData.CustomerNameKana__c, null);
			system.assertEquals(echoMailData.ContactMeans__c, null);
			system.assertEquals(echoMailData.FromEmail__c, CommonConst.EMAIL_CHINTAI);
			system.assertEquals(echoMailData.Phone__c, null);
			system.assertEquals(echoMailData.Fax__c, null);
			system.assertEquals(echoMailData.FromPotalSite__c, portalSiteList[0].Id);
			system.assertEquals(echoMailData.ClosestStation__c, null);
			system.assertEquals(echoMailData.PropertyAddress__c, null);
			system.assertEquals(echoMailData.RentFee__c, null);
			system.assertEquals(echoMailData.RoomLayout__c, null);
			system.assertEquals(echoMailData.PropertyArea__c, null);
			system.assertEquals(echoMailData.PropertyCode__c, null);
			system.assertEquals(echoMailData.Response__c, null);
			system.assertEquals(echoMailData.PropertyName__c, null);
			system.assertEquals(echoMailData.PropertURL__c, null);	
			system.assertEquals(echoMailData.InquiryContent__c, null);
		}
	}
	// ▲ 2022/3/7 CHINTAI対応による追加

	// ▼ 2022/3/23 CHINTAI対応時、システム設定にアドレスが正常に登録されていなかったため、setting()から独立
	static void createPortalSite(){
		// システム設定登録（ポータルサイトのメールアドレス）
        SystemConfig__c sysCon = new SystemConfig__c();
        sysCon.EmailSumo__c = 'system@jds.suumo.jp';
        sysCon.EmailHomes__c = 'support@homes.co.jp';
        sysCon.EmailAthome__c = 'mailcenter@athome.jp';
        sysCon.EmailChintai__c = 'confirm@chintai.co.jp';
        insert sysCon;
		
        // ポータルサイト
		List<PortalSite__c> portalSiteList = new List<PortalSite__c>();
        PortalSite__c PortalSite = new PortalSite__c( Name = 'スーモアドレス'
                                                    , Email__c = CommonConst.EMAIL_SUMO 
        );
        portalSiteList.add(PortalSite);

        PortalSite = new PortalSite__c( Name = 'ホームズアドレス'
                                        , Email__c = CommonConst.EMAIL_HOMES 
        );
        portalSiteList.add(PortalSite);

        PortalSite = new PortalSite__c( Name = 'アットホームアドレス'
                                        , Email__c = CommonConst.EMAIL_ATHOME 
        );
        portalSiteList.add(PortalSite);

		// ▼ 2022/3/7 CHINTAI対応による追加
        PortalSite = new PortalSite__c( Name = CommonConst.PORTALSITE_NAME_CHINTAI
                                        , Email__c = CommonConst.EMAIL_CHINTAI
        );
        portalSiteList.add(PortalSite);

        PortalSite = new PortalSite__c(	Name = CommonConst.PORTALSITE_NAME_WOMANCHINTAI
										, Email__c = CommonConst.EMAIL_CHINTAI
		);
		portalSiteList.add(PortalSite);
		// ▲ 2022/3/7 CHINTAI対応による追加
        insert portalSiteList;
        System.debug(portalSiteList);
	}

    // ▼ 2022/5/31 CHINTAI本対応後の対応(反響メール)
    @isTest
    static void testChintaiPropertyInquiryRoo() {
		createPortalSite();
		List <Property__c> property = [SELECT PropertyCode__c FROM Property__c ORDER BY Id];
		// 引数に指定するメールと宛先
		Messaging.inboundEmail email = new Messaging.inboundEmail();
		email.headers = new List<Messaging.InboundEmail.Header>();
		email.subject = '【CHINTAI】 物件お問合せお知らせメール';
		email.fromAddress = CommonConst.EMAIL_CHINTAI;
		email.toAddresses = new List<String>();
		email.toAddresses.add('testToAdress@rand.co.jp');
		email.References = new List<String>();
		email.References.add('テストreferencesです。１行目');
		email.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();

		string mailText = '───────────────────────────────────\n';
		mailText = mailText + '　CHINTAI　https://www.chintai.net\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '\n';
		mailText = mailText + '物件お問合せお知らせメール\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '\n';
		mailText = mailText + '株式会社ＲＯＯ（ルー） エイブルネットワーク姫路飾磨店  御中\n';
		mailText = mailText + '\n';
		mailText = mailText + '「CHINTAI」お問合せフォームを利用し、\n';
		mailText = mailText + '貴社に対してお客様からお問合せがありました。\n';
		mailText = mailText + '\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + '  お問合せ時刻   :  2022/05/27 14:14:49\n';
		mailText = mailText + '  お問合せ元     :  ネット\n';
		mailText = mailText + '  お問合せＩＤ   :  2205271414491373\n';
		mailText = mailText + '\n';
		mailText = mailText + '\n';
		mailText = mailText + '＜問合せ内容＞\n';
		mailText = mailText + '  最寄り駅       :  山陽電気鉄道本線/八家\n';
		mailText = mailText + '  所在地         :  姫路市継\n';
		mailText = mailText + '  賃料           :  36,000円\n';
		mailText = mailText + '  共益費         :  3,000円\n';
		mailText = mailText + '  間取り         :  1K\n';
		mailText = mailText + '  専有面積       :  19.87m2\n';
		mailText = mailText + '  建物種別       :  ハイツ\n';
		mailText = mailText + '  建物構造       :  軽量鉄骨造\n';
		mailText = mailText + '  築年           :  02/08\n';
		mailText = mailText + '  物件番号       :  000000000133227' + property[0].PropertyCode__c + '\n';
		mailText = mailText + '  部屋連番       :  0001\n';
		mailText = mailText + '  物件名称       :  サニーパレス継\n';
		mailText = mailText + '  部屋号室       :  202\n';
		mailText = mailText + '  問合せ番号     :  CHINTAI近畿133227\n';
		mailText = mailText + '  掲載物件ＵＲＬ :  https://www.chintai.net/detail/bk-C030009150000000001332270001/?vm=0';
		mailText = mailText + '\n';
		mailText = mailText + '＜お客様情報＞\n';
		mailText = mailText + '  名前           :  テスト　グラング\n';
		mailText = mailText + '  名前（カナ）   :  テスト　グラング\n';
		mailText = mailText + '  希望連絡方法   :  メール\n';
		mailText = mailText + '  メール         :  1222@grung.co.jp\n';
		mailText = mailText + '  電話番号       :  \n';
		mailText = mailText + '  ＦＡＸ番号     :  \n';
		mailText = mailText + '  内容           :  最新の空室状況を確認したい\n';
		mailText = mailText + '  コメント       :  テストです\n';
		mailText = mailText + '======================================================================\n';
		mailText = mailText + '\n';
		mailText = mailText + '「店舗管理ログイン画面」からログイン後、\n';
		mailText = mailText + 'TOP画面のメニューから「お問い合せ検索」を行ってください。\n';
		mailText = mailText + '\n';
		mailText = mailText + '※「店舗管理ログイン画面」はこちら\n';
		mailText = mailText + 'https://system.chintai.net/crs\n';
		mailText = mailText + '\n';
		mailText = mailText + '以上、ご対応よろしくお願い致します。\n';
		mailText = mailText + '\n';
		mailText = mailText + '\n';
		mailText = mailText + '\n';
		mailText = mailText + '───────────────────────────────────\n';
		mailText = mailText + '※ このメールは CHINTAIシステムより送信されております。\n';
		mailText = mailText + '(C) CHINTAI Corporation All rights reserved.\n';
		mailText = mailText + 'https://www.chintai.net';

		email.plainTextBody = mailText;

		String subject = email.subject;
		
		// メールサービスの結果（期待値）
		Messaging.InboundEmailResult expect = new Messaging.InboundEmailResult();
		expect.success = true;
		Test.startTest();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		createEchoMail hm = new createEchoMail();
		Messaging.InboundEmailResult result = hm.handleInboundEmail(email, env);
		Test.stopTest();
    }
	// ▲ 2022/5/31 CHINTAI本対応後の対応(反響メール)
}