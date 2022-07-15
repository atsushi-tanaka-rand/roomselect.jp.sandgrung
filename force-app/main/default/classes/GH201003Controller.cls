/**
 * 店舗・地区選択のコントローラ
 */
public inherited sharing class GH201003Controller {
    
    //Public変数
    
    /** 選択可能リスト */
    public list<SelectOption> chooseableOptions { get; set; }
    
    /** 選択済みリスト */
    public list<SelectOption> selectedOptions { get; set; }
    
    /** 選択可能リストの選択値 */
    public list<string> chooseableSelection { get; set; }
    
    /** 選択済みリストの選択値 */
    public list<string> selectedSelection { get; set; }
    
    /** 店舗/地区モード */
    public string mode { get; set; }
    
    /** 共通クラス */    
    public GH201003ParameterClass Parameter { get; set; }
    
    /** エラーフラグ */ 
    public Boolean isOpenError { get; set; }
    
    /** エラーメッセージ保有フラグ */ 
    public Boolean hasErrorMessage { get; set; } 
    
    public Boolean init{
        get{
            if (Parameter.isDrawing) {
                getSelectOption();
                Parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }
    
    /** 選択リストの取得 */    
    public void getSelectOption(){
        try{
            // 選択リストの初期化
            chooseableSelection = new list<string>();
            selectedSelection = new list<string>();
            chooseableOptions = new list<SelectOption>();
            selectedOptions = new list<SelectOption>();  
            if(string.isEmpty(string.valueOf(Parameter.isShopMode))){
                //エラーを設定
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                throw ex;
            }
            
            // モードに合わせて、店舗か地区を選択リストに設定する      
            if(Parameter.isShopMode){
                // 店舗モード
                string queryString = qString();// 動的SQOL文の作成
                mode = '店舗';
                getShopList(queryString);
            } else{
                // 地区モード   
                mode = '地区';     
                getDistrictList();
            }
            
        }catch(Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    /**
    動的SOQL文の作成
    選択済みリストにない店舗を取得する為のSOQLの条件文を作成する
    @return queryString SOQLの条件文
    **/
    private string qString(){
        
        String queryString = '';// SOQLの条件文
        
        // 選択済みの名前のレコードは取得しない
        if(Parameter.selectedShopOrDistrictList.size() > 0){
            for(Integer i = 0 ; i < Parameter.selectedShopOrDistrictList.size();){
                
                if(i != 0){
                    // 2つ目以降の条件の前にはAND文を追加する
                    queryString += ' AND ';
                }
                queryString += 'NAME != \''+ Parameter.selectedShopOrDistrictList[i] + '\'';
                i++;
            }
            
            // 現在の日付が「システム使用開始日」～「システム使用終了日」の期間中かどうかを条件に追加する
            queryString += ' AND SystemUseStartDate__c <= ' + String.valueOf(date.today()) + ' AND SystemUseEndDate__c	 >= '+ String.valueOf(date.today()); 
            
            return queryString;
        }
        
        // 選択済みの値が存在しない場合の処理
        queryString += ' SystemUseStartDate__c <= ' + String.valueOf(date.today()) + ' AND SystemUseEndDate__c	 >= '+ String.valueOf(date.today()); 
        
        return queryString;
    }
    
    /**
    選択リストの設定(店舗モード)
    店舗を取得して、選択可能リストと選択済みリストに設定する
    @string queryString 動的SOQL文
    **/
    private void getShopList(string queryString){
        list<Shop__c> shopList = new list<Shop__c>();// 選択可能リストに追加する店舗
        shopList = Database.query('SELECT NAME FROM Shop__c WHERE ' + queryString);// 店舗を取得
        
        for(string selected : Parameter.selectedShopOrDistrictList){
            // 選択済みの値を選択済みリストに追加
            selectedOptions.add(new SelectOption(selected, selected));
        }
        
        if(shopList.size()!=0){
            for(Shop__c inShop : shopList){
                // 店舗を選択可能リストに追加
                chooseableOptions.add(new SelectOption(inShop.NAME, inShop.NAME));
            }
        }
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
    
    /**
    選択リストの設定(地区モード)
    地区を取得して、選択可能リストと選択済みリストに設定する
    **/
    private void getDistrictList(){
        list<string> districtList = new list<string>();// 地区のリスト
        List<String> excludedDistrictList = new List<String>();// 除外する地区のリスト　問合せ423で追加
        // カスタム設定から地域選択リスト除外項目を取得
        String excludedDistrict = SystemConfig__c.getInstance().ExcludedDistrict__c;
        if(!String.isEmpty(excludedDistrict)) {
            excludedDistrictList = excludedDistrict.split(',');
        }
        
        // 全ての地区の値を建物オブジェクトの地区項目から取得する
        List<Schema.PicklistEntry> pickList = getPicklist('Building__c', 'District__c');
        
        // 全ての地区の値を地区のリストに設定する
        for(Schema.PicklistEntry pick : pickList){
            // 問合せ423で追加、地域選択フラグがtrueの場合、除外する地区のリストに含まれるものを除外
            if(Parameter.regionSelectionFlg) {
                if(excludedDistrictList.contains(pick.getValue())) {
                    continue;
                }
            }
            districtList.add(pick.getValue());
        }
        
        if(districtList.size()!=0){
            
            // 全ての地区のリストから、選択済みの地区と未選択の地区でリストを分ける
            for(string district : districtList){
                if(Parameter.selectedShopOrDistrictList.indexOf(District) >= 0){
                    // 選択済みの値を選択済みリストに追加
                    selectedOptions.add(new SelectOption(District, District));
                }else{
                    // 地区を選択可能リストに追加
                    chooseableOptions.add(new SelectOption(District, District));
                }
            }
        }
    }
    
    /**
    選択対象の追加
    選択可能リストから、選択済みリストへ、選択可能リストの選択値を移動する
    **/
    public void setSelect(){
        for(string selected : chooseableSelection){
            // 選択可能リストの選択値を選択可能リストから削除し、選択済みリストへ追加する
            chooseableOptions.remove(chooseableOptions.indexOf(new SelectOption(selected, selected)));
            selectedOptions.add(new SelectOption(selected, selected));
        }
    }   
    
    /**
    選択対象の除外
    選択済みリストから、選択可能リストへ、選択済みリストの選択値を移動する
    **/ 
    public void removeSelect(){
        for(string selected : selectedSelection){
            // 選択済みリストの選択値を選択済みリストから削除し、選択可能リストへ追加する
            selectedOptions.remove(selectedOptions.indexOf(new SelectOption(selected, selected)));
            chooseableOptions.add(new SelectOption(selected, selected));
        }
    }    
    
    /**
    選択済み対象の設定
    選択済みリストの内容を、選択済み対象として設定する
    **/
    public void settingSelect(){
        try{
            hasErrorMessage = false;
            Parameter.selectedShopOrDistrictList = new list<string>();// 選択済み対象を初期化
            
            if(selectedOptions.size() > 0){    
                for(SelectOption selectedOption : selectedOptions){
                    // 選択済みリストの値を選択済み対象に追加
                    Parameter.selectedShopOrDistrictList.add(selectedOption.getValue());
                }
            }
            
        }catch(Exception e){
            //エラーを設定
            CommonUtil.setErrorMessage(e);
            hasErrorMessage = true;
        }
    }
}