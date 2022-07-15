//送信メール情報トリガーハンドラ
public with sharing class BK101030TriggerHandler {
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;
    //

    /** コンストラクタ */
    public BK101030TriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    /** 登録前処理 */
    public void onBeforeInsert(SendMailInformation__c[] newObjs){
    }
    
    /** 登録後処理 */
    public void onAfterInsert(SendMailInformation__c[] newObjs, Map<ID, SendMailInformation__c> newObjMap){
       
        // 送信メール情報を元に取引先作成、対応明細作成 その後処理した差分レコード削除
        sendMailProcessing(newObjs,newObjMap);

    }
    
    /** 更新前処理 */
    public void onBeforeUpdate(SendMailInformation__c[] oldObjs, Map<ID, SendMailInformation__c> oldObjMap, SendMailInformation__c[] newObjs, Map<ID, SendMailInformation__c> newObjMap){
    }
    
    
    /** 更新後処理 */
    public void onAfterUpdate(SendMailInformation__c[] oldObjs, Map<ID, SendMailInformation__c> oldObjMap, SendMailInformation__c[] newObjs, Map<ID, SendMailInformation__c> newObjMap){
    }
        
    /** 削除前処理 */
    public void onBeforeDelete(SendMailInformation__c[] oldObjs, Map<ID, SendMailInformation__c> oldObjMap){
    }
           
    /** 削除後処理 */
    public void onAfterDelete(SendMailInformation__c[] oldObjs, Map<ID, SendMailInformation__c> oldObjMap){
    }
    
    /** 復元後処理 */
    public void onUndelete(SendMailInformation__c[] newObjs){
    }
    
    
    
    // ********************************
    // privateメソッド
    // ******************************** 
    // 送信メール情報オブジェクト作成更新
    private void sendMailProcessing(SendMailInformation__c[] oldObjs, Map<ID, SendMailInformation__c> newObjMap){
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{
            //マップ<id,送信メール情報>
            Map<id,SendMailInformation__c> accountSendMailMap = new Map<id,SendMailInformation__c>();   //取引先
            Map<id,SendMailInformation__c> correspondSendMailMap = new Map<id,SendMailInformation__c>();//対応

            //Idセット
            Set<Id> accountIdSet = new Set<Id>();   //取引先取得
            Set<Id> correspondIdSet = new Set<Id>();//対応
            Set<Id> delSendMailSet = new Set<Id>(); //削除用送信メールIdセット

            //更新する取引先・対応明細の対応マップを作成
            createMap(oldObjs, accountSendMailMap, correspondSendMailMap, accountIdSet, correspondIdSet, delSendMailSet);

            //取引先、紹介メール情報更新
            updateAccount(accountSendMailMap,accountIdSet);

            //対応明細作成
            insertCorrespondDetail(correspondSendMailMap, correspondIdSet);

            //差分削除
            AsynchronousDeleteDifference(delSendMailSet);
        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
        }

    }
    //---------------------取引先----------------------------------------------

    //送信メール情報マップ作成
    private void createMap(SendMailInformation__c[] oldObjs, Map<id,SendMailInformation__c> accountSendMailMap, Map<id,SendMailInformation__c> correspondSendMailMap, Set<Id> accountIdSet, Set<Id> correspondIdSet, Set<Id> delSendMailSet){
        

        for (SendMailInformation__c oldObj : oldObjs){

            //マップに追加
            accountSendMailMap.put(oldObj.Account__c,oldObj );      //取引先

            correspondSendMailMap.put(oldObj.Correspond__c,oldObj );//対応

            //Idセット
            accountIdSet.add(oldObj.Account__c );                  //取引先

            correspondIdSet.add(oldObj.Correspond__c );            //対応

            //差分削除IdセットにId追加
            delSendMailSet.add(oldObj.Id);
        }
    }

    //取引先、紹介メール情報update
    private void updateAccount(Map<id,SendMailInformation__c> accountSendMailMap, Set<id> accountIdSet){
        //取得取引先リスト
        List<Account> accountList = getAccount(accountIdSet);

        //update用取引先リスト
        List<Account> updateAccountList = new List<Account>();

        //update用送信メール情報リスト 問合せNo0434で追加
        List<IntroductionMailInformation__c> updateIntroductionMailInformationList = new List<IntroductionMailInformation__c>(); 

        //取引先作成
        if(!accountList.isEmpty()){
            for (Account acc: accountList){
                updateAccountList.add(createAccount(acc, accountSendMailMap.get(acc.id)));
                //▼問合せNo0434で追加
                if(!acc.IntroductionMailInformationAccount__r.isEmpty() && accountSendMailMap.get(acc.id).SendFlag__c){
                    // 取引先に紐づく紹介メール情報があり、送信フラグが立っていれば更新Listにセットする。
                    IntroductionMailInformation__c introductionMailInformation = new IntroductionMailInformation__c();
                    introductionMailInformation.Id = acc.IntroductionMailInformationAccount__r[0].Id;
                    updateIntroductionMailInformationList.add(introductionMailInformation);
                }
                //▲問合せNo0434で追加
            }
            SecureDML.secureUpdate(updateAccountList);
            //▼問合せNo0434で追加
            if(updateIntroductionMailInformationList.size() > 0){
                SecureDML.secureUpdate(updateIntroductionMailInformationList);
            }
            //▲問合せNo0434で追加

        }
    }

    //更新取引先レコードの作成
    private Account createAccount(Account account, SendMailInformation__c sendMail){
        Account acc = new Account();
        //id
        acc.id = account.id;

        //追客回数（+1）に
        if (sendMail.SendFlag__c){
            if (account.IntroMailInfoPursuitCount__c == null || account.IntroMailInfoPursuitCount__c == 0){
                acc.IntroMailInfoPursuitCount__c = 1;
            }else{
                acc.IntroMailInfoPursuitCount__c = account.IntroMailInfoPursuitCount__c + 1;
            }
        }
        //最終配信日時
        acc.IntroMailInfoLastSendDatetime__c = sendMail.SendMailDate__c;

        return acc;
    }

    //取引先取得（取引先に紐づいている紹介メール情報も取得する）
    private List<Account> getAccount (Set<id> accountIdSet){
        List<Account> accList = [SELECT id,IntroMailInfoPursuitCount__c
                                ,      (SELECT id FROM IntroductionMailInformationAccount__r Limit 1)    // 紹介メール情報を取得する。 //問合せNo0430で追加
                                FROM Account
                                WHERE id IN :accountIdSet];
        return accList;
    }   
    
    
    //---------------------対応明細----------------------------------------------

    //対応明細insert
    private void insertCorrespondDetail(Map<id,SendMailInformation__c> correspondSendMailMap, Set<id> correspondIdSet){
        //取得対応リスト
        List<Correspond__c> correspondList = getCorrespond(correspondIdSet);

        //insert用対応明細リスト
        List<CorrespondDetail__c> insertCorrespondDetailList = new List<CorrespondDetail__c>();

        //対応明細作成
        if(!correspondList.isEmpty()){
            for (Correspond__c corr: correspondList){
                insertCorrespondDetailList.add(createCorrespondDetail(corr, correspondSendMailMap.get(corr.id)));
            }
            SecureDML.secureInsert(insertCorrespondDetailList); //外部Idをキーにuspert
        }
    }

    //対応取得
    private List<Correspond__c> getcorrespond (Set<id> correspondIdSet){
        List<Correspond__c> corrList = [SELECT id,EchoStaff__c 
                                FROM Correspond__c
                                WHERE id IN :correspondIdSet];
        return corrList;
    }   

    //登録対応明細レコードの作成
    private CorrespondDetail__c createCorrespondDetail(Correspond__c corr,SendMailInformation__c sendMail){
        CorrespondDetail__c corrDetail = new CorrespondDetail__c(
            Corresponds__c = sendMail.Correspond__c,                        //対応
            MailType__c = CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND,       //メール種別
            CorrespondType__c = CommonConst.TASK_CORRESPONDTYPE_MAIL,       //対応種別
            SupportedTitle__c = CommonUtil.subStringLeft(sendMail.Subject__c, 255),//対応表題 
            SupportedContent__c = sendMail.Body__c,                         //対応内容
            SupportedDateTime__c = sendMail.SendMailDate__c,                //対応日時  // 問合せNo0525で変更 送信メール情報．メール送信日時から取得
            Staff__c = corr.EchoStaff__c);                                  //反響担当者
        return corrDetail;
    }

    //---------------------送信メール情報削除----------------------------------------------

    // 非同期削除処理
    @future
    public static void AsynchronousDeleteDifference(Set<Id> deleteIdSet) {

        // 削除対処となるListを作成し、削除する。  
        List <SendMailInformation__c> deleteList= [SELECT Id FROM SendMailInformation__c 
                                                            WHERE Id IN :deleteIdSet
                                                            ];
        
        if(!deleteList.isEmpty()){// Listが空でなければ
            SecureDML.secureDelete(deleteList); // Delteを実施。
        }
    }
    
}