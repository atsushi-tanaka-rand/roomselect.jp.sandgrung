//来店受付差分バッチ
global with sharing class BK101009Batch implements Database.Batchable<sObject>{
    global BK101009Batch() {
    }

    //データ取得（有効店舗取得）
    global Database.QueryLocator start(Database.BatchableContext BC){
        String soql = '';
        soql += 'SELECT Id,';
        soql += ' AppointmentReceiptId__c,';     //来店受付カスタムオブジェクト ID
        soql += ' ReserveResultCount__c';        //予約実績数
        soql += ' FROM AppointmentReceiptDifference__c';//来店受付差分
        soql += ' WHERE LinkCd__c = \'HtoS\'';       //連携コードHtoS
        soql += ' AND CrudCd__c = \'U\'';            //クラッドコードU　（Cには対応していません）
        return Database.getQueryLocator(soql);   
    }

    //開始
    global void execute(Database.BatchableContext BC, List<AppointmentReceiptDifference__c> appReceList){

        //update用来店受付差分マップ<来店受付Id,来店受付差分>
        Map<String,AppointmentReceiptDifference__c> appointmentDiffMap = new Map<String,AppointmentReceiptDifference__c>();

        //差分削除用Idセット
        Set<Id> delAppointmentDiffSet = new Set<Id>();

        // 来店受付差分マップを作成（参照型なのでreturnしなくても値が入る）
        createAppointmentDiffMap(appReceList, appointmentDiffMap, delAppointmentDiffSet);

        //更新
        updateAppointment(appointmentDiffMap);

        //差分削除
        deleteDifference(delAppointmentDiffSet);
    }
        
    /*
    * バッチ処理の終了時に呼び出される
    * 終了処理を実装する
    */
    global void finish(Database.BatchableContext BC) {
        // 次回スケジュールバッチ登録判定
        Datetime nextBatchTime = CommonUtil.getNow().addMinutes(5);

        //次の時間が00分~04分以外の場合、スケジュールバッチを登録
        if (! (nextBatchTime.minute() >= 0 && nextBatchTime.minute() <= 4)){
            // 次回スケジュールバッチ実行時間登録
            BK101009Scheduler cls = new BK101009Scheduler();
            String jobName = '来店受付差分バッチ' + nextBatchTime.format('yyyyMMddHHmm');

            //テストクラスで実際のバッチ名と被りエラーとなる場合があるので、テストクラス実行時はバッチ名に'test'を追加する
            if (Test.isRunningTest()){
                jobName = jobName + 'test';
            }
            String sch = nextBatchTime.format('0 m H d M ? yyyy');

            System.schedule(jobName, sch, cls);

        }

    }

    //-----------------------------privateメソッド-----------------------------------------------------
    //来店受付差分マップ作成
    private void createAppointmentDiffMap(List<AppointmentReceiptDifference__c> oldObjs, Map<String,AppointmentReceiptDifference__c> appointmentDiffMap, Set<Id> delAppointmentDiffSet){
        for (AppointmentReceiptDifference__c oldObj : oldObjs){
            //マップに追加（同じ来店受付カスタムオブジェクト IDのものは、新しいものに上書きされる）
            appointmentDiffMap.put(oldObj.AppointmentReceiptId__c,oldObj );

            //差分削除IdセットにId追加
            delAppointmentDiffSet.add(oldObj.Id);
        }
    }
    
    //来店受付update
    private void updateAppointment(Map<String,AppointmentReceiptDifference__c> appointmentDiffMap){
        //update用来店受付リスト
        List<AppointmentReceipt__c> appointmentList = new List<AppointmentReceipt__c>();

        if(!appointmentDiffMap.values().isEmpty()){ // もし、マップのListが空ではなかったら
            for (AppointmentReceiptDifference__c appoDiff: appointmentDiffMap.values()){
                //来店受付カスタムオブジェクトIDを見て、同じIDを持つレコードがあれば上書きする
                if(String.isNotEmpty( appoDiff.AppointmentReceiptId__c)){
                    appointmentList.add(createAppointment(appoDiff));
                }
            }
            SecureDML.secureUpdate(appointmentList); 
        }
    }

    //来店受付レコードの作成
    private AppointmentReceipt__c createAppointment(AppointmentReceiptDifference__c appoDiff){
        AppointmentReceipt__c appointment = new AppointmentReceipt__c(
        
            Id = appoDiff.AppointmentReceiptId__c     //来店受付カスタムオブジェクト ID
            ,ReserveResultCount__c     = appoDiff.ReserveResultCount__c     //予約実績数

            );
                
        return appointment;
    }


    // 差分削除
    private void deleteDifference(Set<Id> deleteIdSet) {

        // 削除対処となるListを作成し、削除する。  
        List <AppointmentReceiptDifference__c> deleteList= [SELECT Id FROM AppointmentReceiptDifference__c 
                                                            WHERE Id IN :deleteIdSet
                                                            ];

        if(!deleteList.isEmpty()){// Listが空でなければ
            SecureDML.secureDelete(deleteList); // Delteを実施。
        }
    }
    

}