/**
 * 条件完全一致物件 スケジューラ
 **/
global class BD301005Scheduler implements Schedulable {

    global void execute(SchedulableContext ctx) {
        
        Savepoint sp = Database.setSavepoint();
        try {

            // 実施時間チェック
            Integer sysTime = CommonUtil.getNow().hour();
            if (3 <= sysTime && sysTime <= 5) {
                return;
            }

            // 物件存在チェック
            Set<Id> propMatchIdSet = this.selectExactCondMatchBatExePropId();
            if (propMatchIdSet.size() == 0) {
                return;
            }

            // 条件完全一致物件バッチの実施チェック
            SystemVariables__c systemVariables = this.selectSystemVariables(CommonConst.IS_EXACT_COND_MATCH_PROP_BATCH_PROCESSING);
            if (systemVariables == null || systemVariables.BooleanValue__c) {
                return;
            }

            // 条件完全一致処理可能バッチサイズを取得（取引先 * 物件）
            Decimal batchSizeVal = SystemConfig__c.getInstance().ExactConditionMatchProcessableBatchSize__c;
            if (Test.isRunningTest() || batchSizeVal == null) {
                batchSizeVal = 1500;
            }

            // フラグを更新
            systemVariables.BooleanValue__c = true;
            SecureDML.secureUpdate(systemVariables);

            // 取引先の処理可能件数を設定
            Integer batchSize = batchSizeVal.intValue() / propMatchIdSet.size();
            batchSize = (batchSize == 0) ? 1: batchSize;

            // バッチ起動
            BD301005Batch b = new BD301005Batch(propMatchIdSet);
            Database.executeBatch(b, batchSize);

        } catch (Exception e) {
            System.debug('例外メッセージ:' + e.getMessage());
            System.debug('例外スタックトレース:' + e.getStackTraceString());
            Database.rollback(sp);
        }
    }
    
    /**
    * 条件完全一致バッチ実行の物件IDの取得
    * @return Set<Id> 物件ID
    */
    private Set<Id> selectExactCondMatchBatExePropId() {

        // 条件完全一致バッチ実行の取得
        List<ExactConditionMatchBatchExecution__c> ecmbeList;
        ecmbeList = [SELECT PropertyId__c
                     FROM ExactConditionMatchBatchExecution__c];
        
        // 実行対象の物件IDの取得
        Set<Id> propMatchIdSet = new Set<Id>();
        for (ExactConditionMatchBatchExecution__c ecmbe : ecmbeList) {
            propMatchIdSet.add(ecmbe.PropertyId__c);
        }

        return propMatchIdSet;
    }
    
    /**
    * システム変数を取得
    * @param String condVariablesName 変数名
    * @return SystemVariables__c システム変数
    */
    private SystemVariables__c selectSystemVariables(String condVariablesName) {

        SystemVariables__c systemVariables;

        // システム変数を取得
        List<SystemVariables__c> systemVariablesList = [SELECT Id
                                                               , BooleanValue__c
                                                        FROM SystemVariables__c
                                                        WHERE VariablesName__c = :condVariablesName];

        if (!systemVariablesList.isEmpty()) {
            systemVariables = systemVariablesList[0];
        }

        return systemVariables;
    }
}