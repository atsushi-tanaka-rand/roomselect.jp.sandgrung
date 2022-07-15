/**
 * 自動メンテナンス作成　スケジューラ
 **/
global class BD601005Scheduler4 implements Schedulable {
    /** 定数 */
    private static final String IS_AUTOMAINTENANCE_BATCHPROCESSING4 = CommonConst.IS_AUTOMAINTENANCE_BATCHPROCESSING4;

    global void execute(SchedulableContext ctx) {

        //バッチ処理中フラグ取得
        SystemVariables__c SystemVariablesData;
        Boolean isProcessing;
        SystemVariablesData = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :IS_AUTOMAINTENANCE_BATCHPROCESSING4];
        isProcessing = SystemVariablesData.BooleanValue__c;

        //バッチ実行中でなければ
        if (!isProcessing) {

            //フラグを実行中に更新
            SystemVariablesData.BooleanValue__c = true;
            SecureDML.secureUpdate(SystemVariablesData);

            //バッチ実行
            final Integer BATCH_SIZE = 1; //バッチサイズ（※httpコールアウトの上限があるので、2件以上はできない）
            BD601005Batch_4 b = new BD601005Batch_4();
            Database.executeBatch(b, BATCH_SIZE);
        }
        
    }
    
}