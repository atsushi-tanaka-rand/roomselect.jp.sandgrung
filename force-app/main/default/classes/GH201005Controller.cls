/**
 * 商圏・地区選択のコントローラ
 */
public inherited sharing class GH201005Controller {

    //**public変数 */

    /** 共通クラス表示用リスト */    
    public List<displayDistrict> displayDistrictList{ get; set; }// 内部クラス「displayDistrictList」

    /** 選択された商圏 */
    public String selectedTradeArea { get; set; }

    /** 共通クラス */    
    public GH201005ParameterClass parameter { get; set; }
    
    /** エラーフラグ */ 
    public Boolean isOpenError { get; set; }
    
    /** エラーメッセージ保有フラグ */ 
    public Boolean hasErrorMessage { get; set; } 

    //**定数 */
    private static final String TRADEAREA_ALL = SystemConfig__c.getInstance().TradeArea__c;//　商圏のリスト（;区切り）
    private static final String TRADEAREA_SEPARATOR = ';';//区切り文字
    
    //**変数 */
    private List<DisplayDistrict> districtList = new list<DisplayDistrict>();

    //** 初期化 */
    public Boolean init{
        get{
            if (parameter.isDrawing) {
                getSelectOption();
                parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }

    //商圏の選択リスト設定
    public List<SelectOption> getTradeAreaList() {
        //商圏 String　→　List<String>に変換（;区切り）
        List<String> tradeAreaList = TRADEAREA_ALL.split(TRADEAREA_SEPARATOR);
        // 商圏を選択リストにセット
        List<SelectOption>  tradeAreaOption= new List<SelectOption>();
            for (Integer i = 0; i < tradeAreaList.size(); i++) {
                tradeAreaOption.add(new SelectOption(tradeAreaList[i],tradeAreaList[i]));
        }
        return tradeAreaOption;
    }

    /**
    選択リスト型の選択できる値を取得
    オブジェクトと選択リスト項目を指定して、選択リストの全ての値を取得する
    @string obj 選択リストを取得してくるオブジェクトAPI名
    @string item 選択リストを取得してくる項目API名
    @return pickList 対象の選択リストの全ての値
    **/
    public List<Schema.PicklistEntry> getPicklist(String obj, String item){
        List<Schema.PicklistEntry> pickList;
        Schema.SObjectType sobjtype = (Schema.SObjectType)Schema.getGlobalDescribe().get(obj);
        if(sobjtype != null){
            Map<String, Schema.SObjectField> fieldmap = sobjtype.getDescribe().fields.getMap();
            Schema.SObjectField f = (Schema.SObjectField)fieldmap.get(item);
            if(f != null){
                Schema.DescribeFieldResult r = f.getDescribe();
                pickList = r.getPicklistValues();
            }
        }
        return pickList;
    }

    //地区リスト取得
    public void getDistrictList(){

        //選択された商圏(都道府県)の地区リストを作成
        List<DisplayDistrict> targetDistrictList  = new List<DisplayDistrict>();
        for (Integer i = 0; i < districtList.size(); i++) {
            if(districtList[i].State == selectedTradeArea ){
                targetDistrictList.add(districtList[i]);
            }
        }

        //画面表示用の地区名リストを作成
        displayDistrictList = new List<DisplayDistrict>();
        for(DisplayDistrict inDistrict : targetDistrictList){

            boolean isAddedInDistrict = false;// チェック済みの地区かどうか

            for(String inParameterDistrict : parameter.selectedDistrict){
                if(inDistrict.DistrictName == inParameterDistrict){
                    // チェック済みの地区かどうかを判定
                    // チェック済みの地区の場合、チェック済みフラグをtrueにする
                    displayDistrictList.add(new  DisplayDistrict(inDistrict.state, inDistrict.districtName, true));
                    isAddedInDistrict = true;
                }
            }
            if(!isAddedInDistrict){
                // チェック済みの地区ではない場合、チェック済みフラグをfalseにする
                displayDistrictList.add(new  DisplayDistrict(inDistrict.state, inDistrict.districtName, false));
            }
        }
    }

    /** 選択リストの取得 */ 
    public void getSelectOption(){
        try{
            //システム設定で設定された商圏をリスト化（;区切り）
            List<String> tradeAreaList = TRADEAREA_ALL.split(TRADEAREA_SEPARATOR);

            //商圏(都道府県)範囲内の全市区郡町村を国土地理協会住所マスタから取得
            List<JapanGeographicDataCenterAddress__c> japanGList = new List<JapanGeographicDataCenterAddress__c>();

            /*
            List<AggregateResult> aggList = 
            [SELECT City__c , State__c From JapanGeographicDataCenterAddress__c
            WHERE State__c IN:tradeAreaList
            GROUP BY State__c, City__c];
			*/

            for(AggregateResult agg : [SELECT City__c , State__c From JapanGeographicDataCenterAddress__c
            							WHERE State__c IN:tradeAreaList
            							GROUP BY State__c, City__c]){
                japanGList.add(new JapanGeographicDataCenterAddress__c(
                    State__c=String.valueOf(agg.get(CommonUtil.getNamespace('State__c'))) , 
                    City__c= String.valueOf(agg.get(CommonUtil.getNamespace('City__c')))));
            }

            // クローバル選択リストから地区リストを取得
            List<Schema.PicklistEntry> pickList = getPicklist('Building__c', 'District__c');

            // 取得した地区の値をList<String>にセット
            List<String> cityList = new List<String>();
            for(Schema.PicklistEntry pick : pickList){
                cityList.add(pick.getValue());
            }

            //地域がnullではない場合、地域の値で商圏を逆算してセット
            if(parameter.selectedDistrict != null){
                //選択された地区を格納するためのリスト
                List<String> selectedDistrictList = new list<string>();
                //可能性がある商圏(都道府県)を格納するためのマップ
                Map<String,String> possibleTradeAreaMap = new Map<String,String>();

                //地区名を国土地理.市区郡町村を合わせたリストを作成
                for(String district : parameter.selectedDistrict){
                    for(JapanGeographicDataCenterAddress__c japanG : japanGList){
                        if(japanG.city__c == null){
                        	continue;
                    	}
                        
                        //国土地理.市区郡町村名に地区名を含む場合、国土地理.市区郡町村名を取得
                        if(japanG.City__c.contains(district)){
                            selectedDistrictList.add(japanG.City__c);
                            possibleTradeAreaMap.put(japanG.State__c , japanG.City__c);
                        }   
                    }
                }
                //商圏が確実(1件)の場合、そのまま商圏にセット
                if(possibleTradeAreaMap.size() == 1){
                    for (String key : possibleTradeAreaMap.keyset()){
                        selectedTradeArea = key;
                    }
                }
            }
        
            //地区が未選択の場合or地区から逆算した商圏(都道府県)の可能性が複数ある場合、1番目の都道府県をセット
            if(string.isBlank(selectedTradeArea)){
                selectedTradeArea = tradeAreaList[0];
            }

            //districtListを初期化
            districtList  = new list<DisplayDistrict>();
            
            //地区リストを作成
            for(String city : cityList){
                for(JapanGeographicDataCenterAddress__c japanG : japanGList){
                    if(japanG.city__c == null){
                        continue;
                    }
                    if(japanG.city__c.contains(city)){
                        districtList.add(new  DisplayDistrict(japanG.State__c, city ,false));
                        
                    }else{
                        //地区を都道府県・市区郡に分割
                        String wkState = city.remove(japanG.City__c);
                        String wkCity  = city.remove(japanG.State__c);
                        if(japanG.State__c == wkState && japanG.City__c == wkCity){
                            districtList.add(new  DisplayDistrict(japanG.State__c, city , false));
                        }
                    }
                }
            }
            //表示用の地区名リストを作成
            getDistrictList();
        }catch(Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    } 

    /**
    選択済み対象の設定
    選択済みリストの内容を、選択済み対象として設定する
    **/
    public void settingSelect(){
        try{
            hasErrorMessage = false;

            if(displayDistrictList.size() > 0){    
                parameter.selectedDistrict = new list<String>();// チェック済み対象を初期化
                for(displayDistrict displayDistrict : displayDistrictList){
                    // チェック済みの駅をチェック済み対象に追加
                    if(displayDistrict.isSelected){
                        parameter.selectedDistrict.add(displayDistrict.districtName);
                    }
                }
            }
        }catch(Exception e){
            //エラーを設定
            CommonUtil.setErrorMessage(e);
            hasErrorMessage = true;
        }
    }

    /**
    県（商圏）が変更された場合、選択された地区リストをクリアする
    **/
    public void changeTradeArea(){
        //選択された地区リストをクリア
        parameter.selectedDistrict = new list<String>();
        //選択された商圏の地区リストを取得し直す
        getDistrictList();
    }

    // 内部クラス
    public class DisplayDistrict {
        
        public string state { get; set; }// 都道府県
        public string districtName{ get; set; }// 地区名
        public boolean isSelected{ get; set; }// チェック済みかどうか
            
        // コンストラクタ
        public DisplayDistrict(string state ,string districtName, boolean isSelected) {
            this.state = state;
            this.districtName = districtName;
            this.isSelected = isSelected;
        }
    }
}