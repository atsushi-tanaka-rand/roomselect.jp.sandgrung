/**
 * 所属部署の複数選択リスト用コントローラ
 */
public with sharing class GA101002Modal1Controller {
    
    //Public変数
    
    /** 選択可能リスト */
    public list<SelectOption> chooseableOptions { get; set; }
    
    /** 選択済みリスト */
    public list<SelectOption> selectedOptions { get; set; }
    
    /** 選択可能リストの選択値 */
    public list<string> chooseableSelection { get; set; }
    
    /** 選択済みリストの選択値 */
    public list<string> selectedSelection { get; set; }
        
    /** 共通クラス */    
    public GA101002Modal1ParameterClass Parameter { get; set; }
    
    /** エラーフラグ */ 
    public Boolean isOpenError { get; set; }
    
    /** エラーメッセージ保有フラグ */ 
    public Boolean hasErrorMessage { get; set; } 

    public Map<string,SelectOption> selectlist { get;set; }               
    
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

            selectlist = new Map<String,SelectOption>();
                        
            for(SelectOption ShopDate: Parameter.selectedShopList){
                Boolean flg = false;
                for(String shopId: Parameter.selectedShopListId){


                    if(ShopDate.getValue() == shopId){
                        flg = true;
                        continue;
                    }
                }
                if(flg){
                    selectedOptions.add(ShopDate);
                    selectedSelection.add(ShopDate.getvalue());
                    
                }else{
                    chooseableOptions.add(ShopDate);
                    chooseableSelection.add(ShopDate.getvalue());
                }
                selectlist.put(ShopDate.getvalue(),ShopDate);
            }
  
        }catch(Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    
    /**
    選択対象の追加
    選択可能リストから、選択済みリストへ、選択可能リストの選択値を移動する
    **/
    public void setSelect(){
        for(string selected : chooseableSelection){
            
            // 選択可能リストの選択値を選択可能リストから削除し、選択済みリストへ追加する
            chooseableOptions.remove(chooseableOptions.indexOf(new SelectOption(selectlist.get(selected).getvalue(), selectlist.get(selected).getLabel())));
            
            selectedOptions.add(new SelectOption(selectlist.get(selected).getvalue(), selectlist.get(selected).getLabel()));
        }
    
    }   
    
    /**
    選択対象の除外
    選択済みリストから、選択可能リストへ、選択済みリストの選択値を移動する
    **/ 
    public void removeSelect(){
        for(string selected : selectedSelection){
            
            // 選択可能リストの選択値を選択可能リストから削除し、選択済みリストへ追加する
            selectedOptions.remove(selectedOptions.indexOf(new SelectOption(selectlist.get(selected).getvalue(), selectlist.get(selected).getLabel())));
            
            chooseableOptions.add(new SelectOption(selectlist.get(selected).getvalue(), selectlist.get(selected).getLabel()));
        }

    }    
    
    /**
    選択済み対象の設定
    選択済みリストの内容を、選択済み対象として設定する
    **/
    public void settingSelect(){
        try{
            hasErrorMessage = false;
            Parameter.selectedShopList = new list<SelectOption>();// 選択済み対象を初期化
            Parameter.selectedShopListId = new list<string>();// 選択済み対象を初期化
            
            if(selectedOptions.size() > 0){    
                for(SelectOption selectedOption : selectedOptions){
                    // 選択済みリストの値を選択済み対象に追加
                    Parameter.selectedShopList.add(selectedOption);
                    Parameter.selectedShopListId.add(selectedOption.getLabel());
                }
            }
            
        }catch(Exception e){
            //エラーを設定
            CommonUtil.setErrorMessage(e);
            hasErrorMessage = true;
        }
    }

}