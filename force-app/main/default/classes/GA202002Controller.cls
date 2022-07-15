/**
 * 学校選択のコントローラ
 */
public inherited sharing class GA202002Controller {
    public GA202002Controller() {

    }

    /** 共通クラス */    
    public GA202002ParameterClass Parameter { get; set; }

    /** 共通クラス表示用リスト */    
    public List<DisplaySchool> DisplaySchoolList{ get; set; }// 内部クラス「DisplaySchool」

    /** エラーフラグ */ 
    public Boolean isOpenError { get; set; }

    /** 学区チェック */    
    public  Boolean isSchoolDistrictChecked { get; set; }
    
    /** エラーメッセージ保有フラグ */ 
    public Boolean hasErrorMessage { get; set; } 

    static final String JUNIORHIGHSCHOOL = '中学校';

    static final String ELEMENTARYSCHOOL = '小学校';

    public Boolean init{
        get{
            if (Parameter.isDrawing) {
                getSchool();
                Parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }  

    /**
    学校の設定
    パラメータ「学区」に関連する学校を取得して表示する。
    **/
    public void getSchool(){
        try {
            String targetSchoolDistrict;
            String schoolType;
            // 中学校区、小学校区の入力なしの場合、エラー
            if((Parameter.modalMode == 6 && string.isEmpty(Parameter.juniorHighSchoolArea)) ||
            (Parameter.modalMode == 7 && string.isEmpty(Parameter.elementarySchoolArea))) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                throw ex;
            }
            // クエリの条件の学区と学校の種類を設定
            if(Parameter.modalMode == 6) {
                targetSchoolDistrict = '%' + Parameter.juniorHighSchoolArea + '%';
                schoolType = JUNIORHIGHSCHOOL;
            } else if(Parameter.modalMode == 7) {
                targetSchoolDistrict = '%' + Parameter.elementarySchoolArea + '%';
                schoolType = ELEMENTARYSCHOOL;
            } else {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
                throw ex;
            }
            // パラメータ「学区」に関連する学校を取得
            List<School__c> targetSchoolList = [SELECT NAME FROM School__c 
                                                  WHERE Address__c Like :targetSchoolDistrict
                                                  AND Type__c = :schoolType];
            // 表示リストを初期化
            DisplaySchoolList = new List<DisplaySchool>();
            // 対象の学校を表示リストに設定する
            for(School__c inSchool : targetSchoolList){
                boolean isAddedInSchool = false;// チェック済みの学校かどうか
                
                for(School__c inParameterStation : Parameter.selectedSchool){
                    if(inSchool.NAME == inParameterStation.NAME){
                        // チェック済みの学校かどうかを駅名で判定
                        // チェック済みの学校の場合、チェック済みフラグをtrueにする
                        DisplaySchoolList.add(new  DisplaySchool(inSchool, true));
                        isAddedInSchool = true;
                        continue;
                    }
                }
                if(!isAddedInSchool){
                    // チェック済みの学校ではない場合、チェック済みフラグをfalseにする
                    DisplaySchoolList.add(new  DisplaySchool(inSchool, false));
                }
            }

        } catch(Exception e){
            //エラーを設定
            CommonUtil.setErrorMessage(e);
            hasErrorMessage = true;
        }
    }

    /**
    チェック済み対象の設定
    チェック済み学校を、チェック済み対象として設定する
    **/
    public void settingSelect(){
        try{
            hasErrorMessage = false;
            if(DisplaySchoolList.size() > 0){    
                Parameter.selectedSchool = new list<School__c>();// チェック済み対象を初期化
                for(DisplaySchool DisplaySchool : DisplaySchoolList){
                    // チェック済みの駅をチェック済み対象に追加
                    if(DisplaySchool.isSelected){
                        Parameter.selectedSchool.add(DisplaySchool.school);
                    }
                }
                
                if(Parameter.selectedSchool.size() == 0){
                    //チェック済みの駅が0件の場合エラーを設定
                    BusinessLogicException ex = new BusinessLogicException();
                    List<Object> parameters = new List<Object> {'学校の選択', '1'};
                        ex.addMessage(CommonUtil.callMessageCreate(String.format(CommonConst.MSG_COM_W_SELECTION_OR_MORE, parameters)));
                    throw ex;
                }
            }
            
        }catch(Exception e){
            //エラーを設定
            CommonUtil.setErrorMessage(e);
            hasErrorMessage = true;
        }
    }

    // 内部クラス
    public class DisplaySchool {
        
        public School__c school{ get; set; }   // 学校のレコード
        public string schoolName{ get; set; }  // 学校の名前
        public boolean isSelected{ get; set; } // チェック済みかどうか
        
        // コンストラクタ
        public DisplaySchool(School__c school, boolean isSelected) {
            this.school = school;
            this.schoolName = school.Name;
            this.isSelected = isSelected;
        }
    }
}