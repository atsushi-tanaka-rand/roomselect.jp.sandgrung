//紹介メール情報トリガーハンドラ
public with sharing class BK101028TriggerHandler {
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;

    /** コンストラクタ */
    public BK101028TriggerHandler(boolean isExecuting, integer size) {
         m_isExecuting = isExecuting;
         BatchSize = size;
    }

    /** 登録前処理 */
    public void onBeforeInsert(IntroductionMailInformation__c[] newObjs){
    }

    // ** 登録後処理 */
    public void onAfterInsert(IntroductionMailInformation__c[] newObjs, Map<ID, IntroductionMailInformation__c> newObjMap){
        // **紹介メール情報OBJ登録
        introductionMailInformationProcessing(newObjs,'C');
    }

    /** 更新前処理 */
    public void onBeforeUpdate(IntroductionMailInformation__c[] oldObjs, Map<ID, IntroductionMailInformation__c> oldObjMap, IntroductionMailInformation__c[] newObjs, Map<ID, IntroductionMailInformation__c> newObjMap){
    }

    /** 更新後処理 */
    public void onAfterUpdate(IntroductionMailInformation__c[] oldObjs, Map<ID, IntroductionMailInformation__c> oldObjMap, IntroductionMailInformation__c[] newObjs, Map<ID, IntroductionMailInformation__c> newObjMap){
        // **紹介メール情報OBJ登録
        introductionMailInformationProcessing(newObjs,'U');
    }

    /** 削除前処理 */
    public void onBeforeDelete(IntroductionMailInformation__c[] oldObjs, Map<ID, IntroductionMailInformation__c> oldObjMap){
        // **紹介メール情報OBJ登録
        introductionMailInformationProcessing(oldObjs,'D');

    }

     /** 削除後処理 */
     public void onAfterDelete(IntroductionMailInformation__c[] oldObjs, Map<ID, IntroductionMailInformation__c> oldObjMap){
    }

    /** 復元後処理 */
    public void onUndelete(IntroductionMailInformation__c[] newObjs){
    }


    // ********************************
    // privateメソッド　　　　　　　　　　　　　
    // ******************************** 

    // 紹介メール情報オブジェクト作成更新
    private void introductionMailInformationProcessing(IntroductionMailInformation__c[] objs, String crudCd){
        //紹介メール情報差分リストの作成
        List<IntroductionMailInformationDifference__c> introMailDiffList = new List<IntroductionMailInformationDifference__c>();

        for (IntroductionMailInformation__c introMail : objs){
            //紹介メール情報を元に紹介メール情報差分作成
            IntroductionMailInformationDifference__c introMailDiff = createintroMailDiffDiff(introMail, crudCd);

            if(introMailDiff != null){
                //空じゃなければリストに作成
                introMailDiffList.add(introMailDiff); 
            }          
        }
        //紹介メール情報差分をinsert
        if(!introMailDiffList.isEmpty()){
            //リストが空でなければisnert
            SecureDML.secureInsert(introMailDiffList);
        }
    }

    //紹介メール情報を元に紹介メール情報差分作成
    private IntroductionMailInformationDifference__c createintroMailDiffDiff(IntroductionMailInformation__c introMail, String crudCd){
        
        system.debug(introMail.UserName__c);
        system.debug(introMail.Email__c);
        system.debug(String.isBlank(introMail.UserName__c));
        system.debug(String.isBlank(introMail.Email__c));
        IntroductionMailInformationDifference__c introMailDiff = new IntroductionMailInformationDifference__c(
            IntroductionMailInformationId__c = introMail.Id,
            Account__c = introMail.Account__c,                              //取引先
            UserName__c = String.isBlank(introMail.UserName__c) ? '' : portalUtil.encryption(introMail.UserName__c),//氏名
            Email__c = String.isBlank(introMail.Email__c) ? '' : portalUtil.encryption(introMail.Email__c),//メール
            SendMailDate__c = introMail.SendMailDate__c,                    //メール送信日時
            ReceiveMailDateOther__c = introMail.ReceiveMailDateOther__c,    //メール受信日時（その他）
            Correspond__c =introMail.Correspond__c,                         //対応
            IntroMailInfoFirstSendDatetime__c = introMail.IntroMailInfoFirstSendDatetime__c,//初回配信日時
            IntroMailInfoPursuitCount__c = introMail.IntroMailInfoPursuitCount__c,          //追客回数
            Shop__c = introMail.Shop__c,                                    //店舗
            StaffName__c = introMail.StaffName__c,                          //担当者名
			// ▼ 2021.11.30 LINE連携対応より、LINE送信フラグを追加・修正
			CrudCd__c = crudCd,											    //クラッドコード
			IsSendLINE__c = introMail.IsSendLINE__c
			// ▲ 2021.11.30
            
        );
        return introMailDiff;
    }


}