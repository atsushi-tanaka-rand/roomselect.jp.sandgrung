//本会員差分トリガーハンドラ
public with sharing class BK101018TriggerHandler {
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;
    //

    /** コンストラクタ */
    public BK101018TriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    /** 登録前処理 */
    public void onBeforeInsert(MemberDifference__c[] newObjs){
    }
    
    /** 登録後処理 */
    public void onAfterInsert(MemberDifference__c[] newObjs, Map<ID, MemberDifference__c> newObjMap){
        
        // 本会員OBJ登録・更新 その後処理した差分レコード削除
        memberProcessing(newObjs,newObjMap);
        

    }
    
    /** 更新前処理 */
    public void onBeforeUpdate(MemberDifference__c[] oldObjs, Map<ID, MemberDifference__c> oldObjMap, MemberDifference__c[] newObjs, Map<ID, MemberDifference__c> newObjMap){
    }
    
    
    /** 更新後処理 */
    public void onAfterUpdate(MemberDifference__c[] oldObjs, Map<ID, MemberDifference__c> oldObjMap, MemberDifference__c[] newObjs, Map<ID, MemberDifference__c> newObjMap){
    }
        
    /** 削除前処理 */
    public void onBeforeDelete(MemberDifference__c[] oldObjs, Map<ID, MemberDifference__c> oldObjMap){
    }
           
    /** 削除後処理 */
    public void onAfterDelete(MemberDifference__c[] oldObjs, Map<ID, MemberDifference__c> oldObjMap){
    }
    
    /** 復元後処理 */
    public void onUndelete(MemberDifference__c[] newObjs){
    }
    
    
    
    // ********************************
    // privateメソッド
    // ******************************** 
    // 本会員オブジェクト作成更新
    private void memberProcessing(MemberDifference__c[] oldObjs, Map<ID, MemberDifference__c> newObjMap){
        
        //upsert用本会員差分マップ<会員Id,本会員差分>
        Map<String,MemberDifference__c> memberDiffMap = new Map<String,MemberDifference__c>();

        //差分削除用Idセット
        Set<Id> delMemberDiffSet = new Set<Id>();

        // 本会員差分マップを作成（参照型なのでreturnしなくても値が入る）
        createMemberDiffMap(oldObjs, memberDiffMap, delMemberDiffSet);

        //更新
        upsertMember(memberDiffMap);

        //差分削除
        AsynchronousDeleteDifference(delMemberDiffSet);
    }

    //本会員差分マップ作成
    private void createMemberDiffMap(MemberDifference__c[] oldObjs, Map<String,MemberDifference__c> memberDiffMap, Set<Id> delMemberDiffSet){
        for (MemberDifference__c oldObj : oldObjs){

            //Herokuから来たクラッドコードCまたはUのレコードのみ　作成更新処理、差分削除を行う
            if (oldObj.LinkCd__c == 'HtoS' && ( oldObj.CrudCd__c == 'C' || oldObj.CrudCd__c == 'U') ){

                //マップに追加（同じ会員Idのものは、新しいものに上書きされる）
                memberDiffMap.put(oldObj.MemberId__c,oldObj );

                //差分削除IdセットにId追加
                delMemberDiffSet.add(oldObj.Id);
            }
        }
    }

    //本会員と関連オブジェクトupsert
    private void upsertMember(Map<String,MemberDifference__c> memberDiffMap){
        //upsert用本会員リスト
        List<Member__c> memberList = new List<Member__c>();

        if(!memberDiffMap.values().isEmpty()){ // もし、マップのListが空ではなかったら
            for (MemberDifference__c memDiff: memberDiffMap.values()){
                memberList.add(createMember(memDiff));
            }
            SecureDML.secureUpsert(memberList, Member__c.MemberId__c); //外部Idをキーにuspert
        }
        //退会理由をupsert
        insertQuitReason(memberList, memberDiffMap);
        //希望のエリアをupsert
        insertDesireArea(memberList, memberDiffMap);
    }

    //本会員レコードの作成
    private Member__c createMember(MemberDifference__c memberDiff){
        Member__c member = new Member__c(
            MemberId__c          = memberDiff.MemberId__c        //会員ID
            ,LastName__c         = String.isBlank(memberDiff.LastName__c) ? '': PortalUtil.Decryption(memberDiff.LastName__c)  //姓
            ,FirstName__c        = String.isBlank(memberDiff.FirstName__c) ? '': PortalUtil.Decryption(memberDiff.FirstName__c)//名
            ,LastNameKana__c     = String.isBlank(memberDiff.LastNameKana__c) ? '': PortalUtil.Decryption(memberDiff.LastNameKana__c) //姓（カナ）
            ,FirstNameKana__c    = String.isBlank(memberDiff.FirstNameKana__c) ? '': PortalUtil.Decryption(memberDiff.FirstNameKana__c)//名（カナ）
            ,Tell__c             = String.isBlank(memberDiff.Tell__c) ? '': PortalUtil.Decryption(memberDiff.Tell__c)         //電話番号
            ,Fax__c              = String.isBlank(memberDiff.Fax__c) ? '': PortalUtil.Decryption(memberDiff.Fax__c)           //FAX
            ,Email__c            = String.isBlank(memberDiff.Email__c) ? '': PortalUtil.Decryption(memberDiff.Email__c)       //メールアドレス
            ,Zip__c              = String.isBlank(memberDiff.Zip__c) ? '': PortalUtil.Decryption(memberDiff.Zip__c)           //郵便番号
            ,State__c            = String.isBlank(memberDiff.State__c) ? '': PortalUtil.Decryption(memberDiff.State__c)       //都道府県
            ,City__c             = String.isBlank(memberDiff.City__c) ? '': PortalUtil.Decryption(memberDiff.City__c)         //住所1(市区町村)
            ,Street__c           = String.isBlank(memberDiff.Street__c) ? '': PortalUtil.Decryption(memberDiff.Street__c)     //住所2(番地)
            ,Password__c         = memberDiff.Password__c        //パスワード※復号化せずそのまま項目に入れる
            ,Birthdate__c        = memberDiff.Birthdate__c       //生年月日
            ,Gender__c           = memberDiff.Gender__c          //性別
            ,Job__c              = memberDiff.Job__c             //職業
            ,BloodType__c        = memberDiff.BloodType__c       //血液型
            ,FamilyStructure__c  = memberDiff.FamilyStructure__c //家族構成
            ,OwnHouse__c         = memberDiff.OwnHouse__c        //持ち家
            ,LivePeople__c       = memberDiff.LivePeople__c      //ご入居の予定人数
            ,DesireMoveIn__c     = memberDiff.DesireMoveIn__c    //入居希望時期
            ,DesireTrainRouteStation__c = memberDiff.DesireTrainRouteStation__c //希望の沿線・駅
            ,DesireArea__c       = memberDiff.DesireArea__c      //希望のエリア
            ,DesireRoomPlan__c   = memberDiff.DesireRoomPlan__c  //希望する間取り
            ,DesireRentFee__c    = memberDiff.DesireRentFee__c   //希望の家賃
            ,ManageFeeFlg__c     = memberDiff.ManageFeeFlg__c    //管理費・共益費込み
            ,RecommendMailFlg__c = memberDiff.RecommendMailFlg__c//レコメンドメールフラグ
            ,HomeMovingReason__c = memberDiff.HomeMovingReason__c//引越理由
            ,Dissatisfaction__c  = memberDiff.Dissatisfaction__c //不満理由
            ,Taste__c            = memberDiff.Taste__c           //趣味・嗜好
            ,JobZip__c           = memberDiff.JobZip__c          //目的地郵便番号
            ,JobState__c         = memberDiff.JobState__c        //目的地都道府県
            ,JobCity__c          = memberDiff.JobCity__c         //目的地住所1(市区町村)
            ,JobStreet__c        = memberDiff.JobStreet__c       //目的地住所2(番地)
            ,MemberStatus__c     = memberDiff.MemberStatus__c    //会員状況
            ,PasswordReissue__c  = memberDiff.PasswordReissue__c //パスワード再発行
            ,NextPasswordReissueCanDate__c = memberDiff.NextPasswordReissueCanDate__c //次回パスワード再発行可能日時
            ,Account__c          = memberDiff.Account__c         //取引先
            ,JoinDate__c         = memberDiff.JoinDate__c        //入会日
            ,QuitDate__c         = memberDiff.QuitDate__c        //退会日
            ,QuitReason__c       = memberDiff.QuitReason__c      //退会理由
            ,QuitReasonOther__c  = memberDiff.QuitReasonOther__c //退会理由（その他）
            ,QuitRemarks__c      = memberDiff.QuitRemarks__c     //退会備考
            ,Blacklist__c        = memberDiff.Blacklist__c       //ブラックリスト
            ,LastAccessDate__c   = memberDiff.LastAccessDate__c  //最終アクセス日時
            ,EmailReissue__c     = memberDiff.EmailReissue__c    //メールアドレス再取得
            ,NextEmailReissueCanDate__c	= memberDiff.NextEmailReissueCanDate__c//次回メールアドレス再発行可能日時
            ,JobLongitude__c     = memberDiff.JobLongitude__c    //目的地住所経度
            ,JobLatitude__c      = memberDiff.JobLatitude__c     //目的地住所緯度
            ,JobNearStation__c   = memberDiff.JobNearStation__c  //目的地最寄り駅        
            );
        return member;
    }
    
    //-----------------------↓退会理由関連------------------------------------------------------------------------
    //退会理由をupsert
    private void insertQuitReason(List<Member__c> memberList, Map<String,MemberDifference__c> memberDiffMap){
        // null対策
        if(memberList.isEmpty()){
            return;
        }
        Map<String, QuitReasonForReport__c> existingQuitReasonMap = new Map<String, QuitReasonForReport__c>();
        Set<Id> hasChildrenMemberIdSet =  new Set<Id>();
        
        //退会理由（子）を持つ本会員レコードIDを取得
        //<退会理由（子）を持つ本会員（親）Id, 退会理由（子）>Map作成
        setHasChildrenQuitReasonMemberIdSet(memberDiffMap, hasChildrenMemberIdSet, existingQuitReasonMap);
        // 退会理由レコード、削除リスト作成
        List<QuitReasonForReport__c> insertQuitReasonList = createInsertQuitReasonList(memberList, hasChildrenMemberIdSet ,existingQuitReasonMap);

        // insert処理
        if (! insertQuitReasonList.isEmpty()){
            SecureDML.secureInsert(insertQuitReasonList);
        }
        // delete処理
        if (! existingQuitReasonMap.isEmpty()){
            SecureDML.secureDelete(existingQuitReasonMap.values());
        }

    }

    //退会理由がある本会員レコード一覧　取得
    private void setHasChildrenQuitReasonMemberIdSet(Map<String,MemberDifference__c> memberDiffMap, Set<Id> hasChildrenMemberIdSet, Map<String,QuitReasonForReport__c> existingQuitReasonMap) {

        //退会理由（子）がある本会員レコードを取得する
        List<Member__c> memberList = [SELECT Id, MemberId__c,(SELECT Id,QuitReasonItem__c FROM QuitReasonForReportMember__r) FROM Member__c WHERE Id IN (SELECT Member__c FROM QuitReasonForReport__c WHERE Member__r.MemberId__c IN : memberDiffMap.keySet())];
        
        //リストからIdのSetを作成
        for (Member__c m: memberList) {
            hasChildrenMemberIdSet.add(m.Id);
            //今回変更された本会員に紐づく退会理由Map<本会員Id,退会理由（子）>を取得
            for (QuitReasonForReport__c qr : m.QuitReasonForReportMember__r){
                existingQuitReasonMap.put(m.MemberId__c + qr.QuitReasonItem__c, qr);
            }
        }
    }
        

    //退会理由レコード作成
    private List<QuitReasonForReport__c> createInsertQuitReasonList(List<Member__c> memberList, Set<Id> hasChildrenMemberIdSet, Map<String, QuitReasonForReport__c> existingQuitReasonMap){
        List<QuitReasonForReport__c> insertQuitReasonList = new List<QuitReasonForReport__c>();

        for (Member__c m: memberList){
            // 退会理由upsertListに追加
            addInsertQuitReasonList(m, insertQuitReasonList, hasChildrenMemberIdSet, existingQuitReasonMap);
        }
        return insertQuitReasonList;
    }
    
    //退会理由upsertListに追加
    private void addInsertQuitReasonList(Member__c m, List<QuitReasonForReport__c> insertQuitReasonList, Set<Id> hasChildrenMemberIdSet, Map<String,  QuitReasonForReport__c> existingQuitReasonMap) {
        //null対策
        if (String.isBlank(m.QuitReason__c)) {
            return ;
        }
        //退会理由を分割
        List<String> uqStringList = m.QuitReason__c.split(';');
        
        //退会理由毎にレコードを生成
        for (String uqSt : uqStringList) {
            
            // 既に本会員、選択リストが同じレコードが存在した場合　
            if (existingQuitReasonMap.containsKey(m.MemberId__c + uqSt)){
                //追加をせず、Mapから要素を除く（残ったものをあとでdeleteする）
                existingQuitReasonMap.remove(m.MemberId__c + uqSt);

            // 存在しない場合、insertリストに追加
            }else{
                QuitReasonForReport__c addQR = new QuitReasonForReport__c(Member__c = m.Id, QuitReasonItem__c = uqSt);
                insertQuitReasonList.add(addQR);
            }
        }
    }

    //-----------------------↑退会理由関連------------------------------------------------------------------------
    //-----------------------↓希望のエリア関連------------------------------------------------------------------------
    //希望のエリアをinsert
    private void insertDesireArea(List<Member__c> memberList, Map<String,MemberDifference__c> memberDiffMap){

        // null対策
        if(memberList.isEmpty()){
            return;
        }

        Map<String,DesireAreaForReport__c> existingDesireAreaMap = new Map<String,DesireAreaForReport__c>();
        Set<Id> hasChildrenMemberIdSet =  new Set<Id>();
        //希望のエリア（子）を持つ本会員レコードIDを取得
        //<希望のエリア（子）を持つ本会員（親）Id, 希望のエリア（子）Id>Map作成
        setHasChildrenDesireAreaMemberIdSet(memberDiffMap, hasChildrenMemberIdSet, existingDesireAreaMap);

        // 希望のエリアレコード作成
        List<DesireAreaForReport__c> insertDesireAreaList = createInsertDesireAreaList(memberList, hasChildrenMemberIdSet ,existingDesireAreaMap);

        //insert処理
        if (! insertDesireAreaList.isEmpty()){
            SecureDML.secureInsert(insertDesireAreaList);
        }
        
        //delete処理
        if (! existingDesireAreaMap.isEmpty()){
            SecureDML.secureDelete(existingDesireAreaMap.values());
        }
    }
        

    //希望のエリアがある本会員レコード一覧　取得
    private void setHasChildrenDesireAreaMemberIdSet(Map<String,MemberDifference__c> memberDiffMap, Set<Id> hasChildrenMemberIdSet, Map<String,DesireAreaForReport__c> existingDesireAreaMap) {

        //希望のエリア（子）がある本会員レコードを取得する
        List<Member__c> memberList = [SELECT Id,MemberId__c, (SELECT Id,DesireAreaItem__c FROM DesireAreaForReportMember__r ) From Member__c WHERE Id IN (SELECT Member__c FROM DesireAreaForReport__c WHERE Member__r.MemberId__c IN : memberDiffMap.keySet())];
        
        //リストからIdのSetを作成
        for (Member__c m: memberList) {
            hasChildrenMemberIdSet.add(m.Id);
            //今回変更された本会員に紐づく希望のエリアMap<本会員Id,希望のエリア（子）>を取得
            for (DesireAreaForReport__c da : m.DesireAreaForReportMember__r){
                existingDesireAreaMap.put(m.MemberId__c + da.DesireAreaItem__c, da);
            }
            
        }
    }

    //希望のエリアレコード作成
    private List<DesireAreaForReport__c> createInsertDesireAreaList(List<Member__c> memberList, Set<Id> hasChildrenMemberIdSet, Map<String,DesireAreaForReport__c> existingDesireAreaMap){
        List<DesireAreaForReport__c> upsertDesireAreaList = new List<DesireAreaForReport__c>();

        for (Member__c m: memberList){
            // 希望のエリアupsertListに追加
            addInsertDesireAreaList(m, upsertDesireAreaList, hasChildrenMemberIdSet, existingDesireAreaMap);
        }
        return upsertDesireAreaList;
    }
    
    //希望のエリアinsertListに追加
    private void addInsertDesireAreaList(Member__c m, List<DesireAreaForReport__c> insertDesireAreaList, Set<Id> hasChildrenMemberIdSet, Map<String,DesireAreaForReport__c> existingDesireAreaMap) {
        //null対策
        if (String.isBlank(m.DesireArea__c)) {
            return ;
        }
        
        //希望のエリアを分割
        List<String> uqStringList = m.DesireArea__c.split(';');
        
        //希望のエリア毎にレコードを生成
        for (String uqSt : uqStringList) {
        
            // 既に本会員、選択リストが同じレコードが存在した場合　
            if (existingDesireAreaMap.containsKey(m.MemberId__c + uqSt)){
                //追加をせず、Mapから要素を除く（残ったものをあとでdeleteする）
                existingDesireAreaMap.remove(m.MemberId__c + uqSt);

            // 存在しない場合、insertリストに追加
            }else{
                DesireAreaForReport__c addQR = new DesireAreaForReport__c(Member__c = m.Id, DesireAreaItem__c = uqSt);
                insertDesireAreaList.add(addQR);
            }
        }

    }

    //-----------------------↑希望のエリア関連------------------------------------------------------------------------



    // 非同期削除処理（メール受信でエラーとなるため非同期では行わない）
    // @future
    public static void AsynchronousDeleteDifference(Set<Id> deleteIdSet) {

        // 削除対処となるListを作成し、削除する。  
        List <MemberDifference__c> deleteList= [SELECT Id FROM MemberDifference__c 
                                                            WHERE Id IN :deleteIdSet
                                                            ];
        
        if(!deleteList.isEmpty()){// Listが空でなければ
            SecureDML.secureDelete(deleteList); // Delteを実施。
        }
    }
    
}