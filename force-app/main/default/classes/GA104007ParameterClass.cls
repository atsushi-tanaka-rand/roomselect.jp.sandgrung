/**
 * 駅名選択のクラス
 */
public with sharing class GA104007ParameterClass {
    /** 選択されている路線 */
    public TrainRoute__c selectedTrainRoute { get; set; }

    /** 選択済み駅名 */
    public List<Station__c> selectedStation { get; set; }
    
    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}

    //** 単一選択フラグ */ 
    public Boolean singleChoice { get; set;}// GA104007から呼び出された場合のフラグ　2022.04.08 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
    
    public GA104007ParameterClass() {
        // 初期化処理
        selectedTrainRoute = new  TrainRoute__c();  
        selectedStation = new  List<Station__c>();        
        isDrawing = false;
        noFirst = false;
        singleChoice = false;// 単一選択フラグの初期値を設定 2022.04.12 No.782 問合せNo0782_建物画面の沿線名と駅名の登録について
    }
}