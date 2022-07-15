//紹介メール情報メンテナンスバッチ2
global with sharing class BK101035Batch implements Database.Batchable<sObject>{

    global BK101035Batch() {
    }


    //データ取得（来店受付_店舗日別取得）
    global Database.QueryLocator start(Database.BatchableContext BC){
    
        String soql ='';

        soql += 'SELECT Id, ';
        soql += ' Account__c, ';     //取引先
        soql += ' Correspond__c ';   //対応
        soql += ' FROM IntroductionMailInformation__c';             //紹介メール情報
        soql += ' WHERE Account__r.IntroMailInfoPursuitCount__c >= 10'; //取引先．紹介メール追客回数が10以上
        
        return Database.getQueryLocator(soql);   
    }

    //開始
    global void execute(Database.BatchableContext BC, List<IntroductionMailInformation__c> introMailList){
        
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        try{

            //自社HP権限がなければ処理を行わない
            if (!AuthorityCheckUtil.getAuthorityOptionPortal(false)){
                return;
            }

            List<IntroductionMailInformation__c> deleteIntroMailList = new List<IntroductionMailInformation__c>();//削除用紹介メール情報
            List<Account> updateAccList = new List<Account>();                                  //更新用取引先リスト
            List<Correspond__c> updateCorrList = new List<Correspond__c>();                     //更新用対応リスト
            List<CorrespondDetail__c> insertCorrDetailList = new List<CorrespondDetail__c>();   //登録用対応明細リスト
    
            Datetime nowtime = CommonUtil.getNow();

            for (IntroductionMailInformation__c  introMail : introMailList){
                system.debug(introMail);
                //削除紹介メール情報リスト
                deleteIntroMailList.add(introMail);
    
                //更新取引先リスト
                updateAccList.add(createUpdateAccount(introMail.Account__c));
    
                //更新用対応リスト
                updateCorrList.add(createUpdateCorrespond(introMail.Correspond__c ,nowtime));
    
                //登録用対応明細リスト
                insertCorrDetailList.add(createUpdateCorrespondDetail(introMail.Correspond__c, nowtime));
            }

            //紹介メール情報削除
            if (!deleteIntroMailList.isEmpty()){
                SecureDML.secureDelete(deleteIntroMailList);
            }
            //取引先更新
            if (!updateAccList.isEmpty()){
                SecureDML.secureUpdate(updateAccList);
            }
            //対応更新
            if (!updateCorrList.isEmpty()){
                SecureDML.secureUpdate(updateCorrList);
            }
            //対応明細作成
            if (!insertCorrDetailList.isEmpty()){
                SecureDML.secureInsert(insertCorrDetailList);
            }

        }catch(Exception e){
            Database.rollback(sp);//処理をロールバック
        }
    }

    //終了
    global void finish(Database.BatchableContext BC) {
        //なし
    }
    

    //----------------------------privateメソッド-------------------------------------------------------------------------
    private Account createUpdateAccount (id AccountId){
        Account acc = new Account(
            id = AccountId,
            IntroMailInfoStatus__c = CommonConst_ptl.INTRODUCTION_SENDSTOP); //配信停止
        return acc;
    }

    private Correspond__c createUpdateCorrespond (id CorrespondId,Datetime nowtime){
        Correspond__c corr = new Correspond__c(
            id = CorrespondId, 
            Status__c = CommonConst.CORRESPOND_STATUS_CLOSE,  //ステータス = 終了
            StatusBeforePursuitHold__c = null,                //追客保留前ステータス
            EndDate__c = nowtime,                             //終了日付
            EventDateTime__c = nowtime,                       //イベント時刻
            StaffSupportedFlg__c = true,                      //スタッフ対応フラグ
            IsSupportedListShow__c = true,                    //対応確認
            IsBrowseFlg__c = true,                            //閲覧フラグ
            ListViewDate__c = CommonConst.LAST_DATE,          //一覧表示日時
            IsEchoNotCalculation__c = true                    //反響非計算フラグ
        );
        return corr;
    }
    
    private CorrespondDetail__c createUpdateCorrespondDetail (id CorrespondId, Datetime nowtime){
        //対応明細登録
        CorrespondDetail__c corrDetail = new CorrespondDetail__c(
            SupportedDateTime__c   = nowtime,                                 // 対応日時
            Corresponds__c         = CorrespondId,                            // 対応ID
            CorrespondType__c      = CommonConst.TASK_CORRESPONDTYPE_CLOSE,   // 対応種別
            SupportedTitle__c      = '自動追客終了に伴い、終了',                // 対応表題
            SupportedContent__c    = '自動追客メール配信を停止しました。'        // 対応内容
        );
        return corrDetail;
    }
}