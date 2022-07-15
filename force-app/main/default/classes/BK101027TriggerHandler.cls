//来店受付トリガハンドラ

public with sharing class BK101027TriggerHandler {
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;


    /** コンストラクタ */
    public BK101027TriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    /** 登録前処理 */
    public void onBeforeInsert(AppointmentReceipt__c[] newObjs){
    }
    
    /** 登録後処理 */
    public void onAfterInsert(AppointmentReceipt__c[] newObjs, Map<ID, AppointmentReceipt__c> newObjMap){
        
        //来店受付差分作成 //問合せNo0439で変更（引数追加）
        insertAppointmentReceiptDifference(newObjs, 'C',null);
    }
    
    /** 更新前処理 */
    public void onBeforeUpdate(AppointmentReceipt__c[] oldObjs, Map<ID, AppointmentReceipt__c> oldObjMap, AppointmentReceipt__c[] newObjs, Map<ID, AppointmentReceipt__c> newObjMap){
    }

    /** 更新後処理 */
    public void onAfterUpdate(AppointmentReceipt__c[] oldObjs, Map<ID, AppointmentReceipt__c> oldObjMap, AppointmentReceipt__c[] newObjs, Map<ID, AppointmentReceipt__c> newObjMap){
        //来店受付差分作成 //問合せNo0439で変更（引数追加）
        insertAppointmentReceiptDifference(newObjs, 'U',oldObjMap);
    }
    
    /** 削除前処理 */
    public void onBeforeDelete(AppointmentReceipt__c[] oldObjs, Map<ID, AppointmentReceipt__c> oldObjMap){
        }

    /** 削除後処理 */
    public void onAfterDelete(AppointmentReceipt__c[] oldObjs, Map<ID, AppointmentReceipt__c> oldObjMap){
    }
    
    /** 復元後処理 */
    public void onUndelete(AppointmentReceipt__c[] newObjs){
    }


    // ********************************
    // privateメソッド　　　　　　　　　　　　　
    // ******************************** 

    //来店受付差分作成 //問合せNo0439で変更（引数追加）
    private void insertAppointmentReceiptDifference(AppointmentReceipt__c[] objs,String crudCd, Map<ID, AppointmentReceipt__c> oldObjMap){
        
        //来店受付差分リストの作成
        List<AppointmentReceiptDifference__c> appointmentList = new List<AppointmentReceiptDifference__c>();
        
        for (AppointmentReceipt__c appo : objs){
            //▼問合せNo0439で追加
            if(oldObjMap != null){
                // 予約実績数が更新前と後で違っているものは差分を作成しない（ポータルからの連携データによる来店受付の更新のため差分の2重作成を防ぐ）
                if(oldObjMap.get(appo.id).ReserveResultCount__c != appo.ReserveResultCount__c){
                    continue;
                }
            }
            //▲問合せNo0439で追加

            //来店受付を元に来店受付差分作成
            AppointmentReceiptDifference__c appoDiff = createAppoDiffDiff(appo, crudCd);

            if(appoDiff != null){
                //空じゃなければリストに作成
                appointmentList.add(appoDiff); 
            }            
        }
        //来店受付差分をinsert
        if(!appointmentList.isEmpty()){
            //リストが空でなければisnert
            SecureDML.secureInsert(appointmentList);
        }
    }

    //来店受付を元に来店受付差分作成
    private AppointmentReceiptDifference__c createAppoDiffDiff(AppointmentReceipt__c Appo, String crudCd){
        AppointmentReceiptDifference__c appoDiff = new AppointmentReceiptDifference__c(
            
                AppointmentReceiptId__c       = Appo.Id,                    //Idを来店受付カスタムオブジェクト IDへ
                ReceiptDate__c                = Appo.ReceiptDate__c,          //受付日 
                Shop__c                       = Appo.Shop__c,             //店舗
                ReserveStartTime__c           = Appo.ReserveStartTime__c,             //予約開始時刻
                ReserveEndTime__c             = Appo.ReserveEndTime__c,             //予約終了時刻
                ReserveCanCount__c            = Appo.ReserveCanCount__c,             //予約可能数
                ReserveCanNotCount__c         = Appo.ReserveCanNotCount__c,             //予約不能数
                CrudCd__c                     = crudCd,                     //クラッドコード
                LinkCd__c                     = 'StoH'                      //連携コード

                );
        
        return appoDiff;
    }    
}