/**
 * 駅名選択のコントローラ
 */
public inherited sharing class GA104007Controller {
    
    //Public変数
    
    /** 共通クラス */    
    public GA104007ParameterClass Parameter { get; set; }
    
    /** 共通クラス表示用リスト */    
    public List<DisplayStation> DisplayStationList{ get; set; }// 内部クラス「DisplayStation」
    
    /** 路線チェック */    
    public  Boolean isTrainRouteChecked { get; set; }
    
    /** エラーフラグ */ 
    public Boolean isOpenError { get; set; }
    
    /** エラーメッセージ保有フラグ */ 
    public Boolean hasErrorMessage { get; set; } 
    
    // ページの初期表示時の処理
    public Boolean init{
        get{
            if (Parameter.isDrawing) {
                getStation();
                Parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }     
    
    /**
    駅の設定
    パラメータ「選択されている路線」に関連する駅を取得して表示し、パラメータ「選択済み駅名」の駅はチェック済みに設定する
    **/
    public void getStation(){
        
        try{
            
            // 初期化
            isTrainRouteChecked = false;
            
            if(string.isEmpty(string.valueOf(Parameter.selectedTrainRoute.NAME))){
                //パラメータ「路線名」がない場合、エラーを設定
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                throw ex;
            }
            
            // パラメータ「選択されている路線」に関連する駅を取得
            List<Station__c> targetStationList = [SELECT NAME FROM Station__c 
                                                  WHERE TrainRoute__r.NAME = :Parameter.selectedTrainRoute.NAME // 路線名
                                                  ORDER BY Order__c ASC];// 項目「順序」の昇順

            // 表示リストを初期化
            DisplayStationList = new List<DisplayStation>();
            
            // 対象の駅を表示リストに設定する
            for(Station__c inStation : targetStationList){
                boolean isAddedInStation = false;// チェック済みの駅かどうか
                
                for(Station__c inParameterStation : Parameter.selectedStation){
                    if(inStation.NAME == inParameterStation.NAME){
                        // チェック済みの駅かどうかを駅名で判定
                        // チェック済みの駅の場合、チェック済みフラグをtrueにする
                        DisplayStationList.add(new  DisplayStation(inStation, true));
                        isAddedInStation = true;
                    }
                }
                if(!isAddedInStation){
                    // チェック済みの駅ではない場合、チェック済みフラグをfalseにする
                    DisplayStationList.add(new  DisplayStation(inStation, false));
                }
            }
            
        }catch(Exception e){
            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    

    
    /**
    チェック済み対象の設定
    チェック済み駅を、チェック済み対象として設定する
    **/
    public void settingSelect(){
        try{
            hasErrorMessage = false;
            if(DisplayStationList.size() > 0){    
                Parameter.selectedStation = new list<Station__c>();// チェック済み対象を初期化
                for(DisplayStation DisplayStation : DisplayStationList){
                    // チェック済みの駅をチェック済み対象に追加
                    if(DisplayStation.isSelected){
                        Parameter.selectedStation.add(DisplayStation.station);
                    }
                }
                
                if(Parameter.selectedStation.size() == 0){
                    //チェック済みの駅が0件の場合エラーを設定
                    BusinessLogicException ex = new BusinessLogicException();
                    List<Object> parameters = new List<Object> {'駅の選択', '1'};
                        ex.addMessage(CommonUtil.callMessageCreate(String.format(CommonConst.MSG_COM_W_SELECTION_OR_MORE, parameters)));
                    throw ex;
                }
                // ▼ 2022.04.08 No.782 単一フラグ=TRUE かつ駅が複数選択された場合、エラーメッセージを返す
                if(Parameter.singleChoice && Parameter.selectedStation.size() > 1 ){
                    //チェック済みの駅が複数件、かつ単一フラグがONの場合エラーを設定
                    BusinessLogicException ex = new BusinessLogicException();
                    List<Object> parameters = new List<Object> {'駅の選択', '1'};
                        ex.addMessage(CommonUtil.callMessageCreate(String.format(CommonConst.MSG_COM_W_SELECTION_OR_LESS, parameters)));
                    throw ex;
                }
                // ▲ 2022.04.08 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
            }
            
        }catch(Exception e){
            //エラーを設定
            CommonUtil.setErrorMessage(e);
            hasErrorMessage = true;
        }
    }
    
    // 内部クラス
    public class DisplayStation {
        
        public Station__c station{ get; set; }// 駅のレコード
        public string stationName{ get; set; }// 駅の名前
        public boolean isSelected{ get; set; }// チェック済みかどうか
        
        // コンストラクタ
        public DisplayStation(Station__c station, boolean isSelected) {
            this.station = station;
            this.stationName = station.Name;
            this.isSelected = isSelected;
        }
    }
}