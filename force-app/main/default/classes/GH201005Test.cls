@isTest
public class GH201005Test {

    @TestSetup static void setting(){

        // ユーザ作成
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name IN ('Standard User', '一般ユーザ')];
        System.assert(profiles.size() > 0);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser){
            User testUser = new User(UserName = 'GH201005Test@horaguchi.com',
                                     Email = 'test@example.com',
                                     LastName = 'test',
                                     Alias = 'test',
                                     TimeZoneSidKey = 'Asia/Tokyo',
                                     LocaleSidKey = 'ja_JP',
                                     EmailEncodingKey = 'ISO-2022-JP',
                                     LanguageLocaleKey = 'ja',
                                     ProfileId = profiles.get(0).Id );
            insert testUser;
        }

        // 商圏をセット（;区切り） 
        SystemConfig__c sysconf = new SystemConfig__c(
            TradeArea__c = '愛知県;東京都'
        );
        insert sysconf;



        //国土地理協会住所レコードを作成
        JapanGeographicDataCenterAddress__c j1 = new JapanGeographicDataCenterAddress__c(
                                                        State__c = '東京都',
                                                        City__c = '新宿区'
                                                    );
        JapanGeographicDataCenterAddress__c j2 = new JapanGeographicDataCenterAddress__c(
                                                        State__c = '東京都',
                                                        City__c = '豊島区'
                                                    );
        JapanGeographicDataCenterAddress__c j3 = new JapanGeographicDataCenterAddress__c(
                                                        State__c = '東京都',
                                                        City__c = '中央区'
                                                    );
        JapanGeographicDataCenterAddress__c j4 = new JapanGeographicDataCenterAddress__c(
                                                        State__c = '愛知県',
                                                        City__c = '名古屋市千種区'
                                                    );
        JapanGeographicDataCenterAddress__c j5 = new JapanGeographicDataCenterAddress__c(
                                                        State__c = '愛知県',
                                                        City__c = '名古屋市中央区'
                                                    );
        JapanGeographicDataCenterAddress__c j6 = new JapanGeographicDataCenterAddress__c(
                                                        State__c = '愛知県',
                                                        City__c = '北名古屋市'
                                                    );                                                

        List<JapanGeographicDataCenterAddress__c> JRecord = new List<JapanGeographicDataCenterAddress__c>{
            j1,j2,j3,j4,j5,j6
        };
        insert JRecord;

    }

    /**
    来店カード新規作成時、商圏(都道府県)の初期表示はシステム設定で設定された商圏(都道府県)の
    最初の値を確認するケース
    */
    @isTest static void initializeTest1(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH201005Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラー、パラメータークラス
            GH201005Controller GH201005Controller = new GH201005Controller();
            GH201005ParameterClass GH201005Parameter = new GH201005ParameterClass();

            // ページ遷移時の設定
            GH201005Parameter.isDrawing = TRUE;
            GH201005Parameter.noFirst = TRUE;
        
            // 選択済み地区を設定
            GH201005Parameter.selectedDistrict = new list<String>();
    
            // コントローラの共通クラスを設定
            GH201005Controller.Parameter = GH201005Parameter;
            
            Test.startTest();
            GH201005Controller.getSelectOption();
            Test.stopTest();

            //商圏リストを取得
            String TRADEAREA_ALL = SystemConfig__c.getInstance().TradeArea__c;//　商圏のリスト（;区切り）
            String TRADEAREA_SEPARATOR = ';';//区切り文字
            List<String> tradeAreaList = TRADEAREA_ALL.split(TRADEAREA_SEPARATOR);

            //セットされた商圏が商圏リストの1番目の値であることを確認する。
            system.assertEquals(GH201005Controller.selectedTradeArea, tradeAreaList[0]);
        }
    }

    /**
    メソッドが問題なく呼び出されることを確認するケース
     */
    @isTest static void callTest(){
        User userRecord =  [SELECT Id FROM User WHERE UserName = 'GH201005Test@horaguchi.com'];
        system.runas(userRecord){

            //コントローラー、パラメータークラス
            GH201005Controller GH201005Controller = new GH201005Controller();
            GH201005ParameterClass GH201005Parameter = new GH201005ParameterClass();
            
            // ページ遷移時の設定
            GH201005Parameter.isDrawing = TRUE;
            GH201005Parameter.noFirst = TRUE;

            // コントローラの共通クラスを設定
            
            GH201005Controller.Parameter = GH201005Parameter;

            // 選択済み地区を設定
            GH201005Parameter.selectedDistrict = new list<String>();
            GH201005Parameter.selectedDistrict.add('千種区');

    
            Test.startTest();
            try{
                GH201005Controller.getSelectOption();
                GH201005Controller.changeTradeArea();
                GH201005Controller.settingSelect();
            }catch(BusinessLogicException e){
                System.assert(false); // 例外が発生したら失敗
            }
            Test.stopTest();
        }
    }
}