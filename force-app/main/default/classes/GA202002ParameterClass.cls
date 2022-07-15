/**
 * 学区選択のクラス
 */
public with sharing class GA202002ParameterClass {

    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}

    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}

    /** 選択された中学校学区 */
    public String juniorHighSchoolArea{ get; set;}

    /** 選択された小学校学区 */
    public String elementarySchoolArea{ get; set;}

    /** 中学校=6 小学校=7 */
    public Integer modalMode{ get; set;}

    /** 選択済み学校 */
    public List<School__c> selectedSchool { get; set; }

    public GA202002ParameterClass() {
        selectedSchool = new  List<School__c>();   
        isDrawing = false;
        noFirst = false;
    }
}