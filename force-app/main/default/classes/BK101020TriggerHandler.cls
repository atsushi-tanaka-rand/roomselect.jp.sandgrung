//閲覧履歴差分トリガーハンドラ
public with sharing class BK101020TriggerHandler {
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;

    /** コンストラクタ */
    public BK101020TriggerHandler(boolean isExecuting, integer size) {
         m_isExecuting = isExecuting;
         BatchSize = size;
    }

    /** 登録前処理 */
    public void onBeforeInsert(BrowsingHistoryDifference__c[] newObjs){
    }

    // ** 登録後処理 */
    public void onAfterInsert(BrowsingHistoryDifference__c[] newObjs, Map<ID, BrowsingHistoryDifference__c> newObjMap){
        
        // **閲覧履歴OBJ登録・更新 その後処理した差分レコード削除 */
        browsingHistoryProcessing(newObjs,newObjMap);
    }

    /** 更新前処理 */
    public void onBeforeUpdate(BrowsingHistoryDifference__c[] oldObjs, Map<ID, BrowsingHistoryDifference__c> oldObjMap, BrowsingHistoryDifference__c[] newObjs, Map<ID, BrowsingHistoryDifference__c> newObjMap){
    }

    /** 更新後処理 */
    public void onAfterUpdate(BrowsingHistoryDifference__c[] oldObjs, Map<ID, BrowsingHistoryDifference__c> oldObjMap, BrowsingHistoryDifference__c[] newObjs, Map<ID, BrowsingHistoryDifference__c> newObjMap){
    }

    /** 削除前処理 */
    public void onBeforeDelete(BrowsingHistoryDifference__c[] oldObjs, Map<ID, BrowsingHistoryDifference__c> oldObjMap){
    }

     /** 削除後処理 */
     public void onAfterDelete(BrowsingHistoryDifference__c[] oldObjs, Map<ID, BrowsingHistoryDifference__c> oldObjMap){
    }

    /** 復元後処理 */
    public void onUndelete(BrowsingHistoryDifference__c[] newObjs){
    }


    // ********************************
    // privateメソッド　　　　　　　　　　　　　
    // ******************************** 


    // 閲覧履歴オブジェクト作成更新

    private void browsingHistoryProcessing(BrowsingHistoryDifference__c[] oldObjs, Map<ID, BrowsingHistoryDifference__c> newObjMap){
        //upsert用閲覧履歴差分マップ<閲覧履歴Id,閲覧履歴差分>
        Map<String,BrowsingHistoryDifference__c> bHDiffMap = new Map<String,BrowsingHistoryDifference__c>();
 		
        //Idセット
        Set<String> proSet =new Set<String>();	//物件コードセット
        Set<String> memSet =new Set<String>();	//会員Idセット
        Set<Id> delBHDiffSet = new Set<Id>();	//差分削除用Idセット

        // 閲覧履歴差分マップを作成（参照型なのでreturnしなくても値が入る）  追加Idセットをついでに取得
        createBHDiffMap(oldObjs, bHDiffMap, delBHDiffSet, proSet, memSet);

        //更新
        upsertBH(bHDiffMap, proSet, memSet);

        //差分削除
        asynchronousDeleteDifference(delBHDiffSet);
    }

    //閲覧履歴差分マップ作成 
    private void createBHDiffMap(BrowsingHistoryDifference__c[] oldObjs, Map<String,BrowsingHistoryDifference__c> bHDiffMap, Set<Id> delBHDiffSet, Set<String> proSet, Set<String> memSet){
        for (BrowsingHistoryDifference__c oldObj : oldObjs){

                //Herokuから来たCまたはUのレコードは作成更新処理、差分削除を行う
                if (oldObj.CrudCd__c == 'C' || oldObj.CrudCd__c == 'U'){

                //マップに追加（同じ閲覧履歴IDのものは、新しいものに上書きされる）
                bHDiffMap.put(oldObj.BrowsingHistoryId__c,oldObj );

                //Idセットに値追加
				proSet.add(oldObj.PropertyCd__c);	//物件コードセットに物件コード追加
                memSet.add(oldObj.MemberId__c);		//会員Idセットに会員Id追加
                delBHDiffSet.add(oldObj.Id);		//差分削除IdセットにId追加
            }
        }
    }
  
    //閲覧履歴upsert
    private void upsertBH(Map<String,BrowsingHistoryDifference__c> bHDiffMap, Set<String> proSet, Set<String> memSet){
        //upsert用閲覧履歴リスト
        List<BrowsingHistory__c> bHList = new List<BrowsingHistory__c>();

        //Map作成
		Map<String,Id> proMap = new Map<String,Id>();
        createPropertyMap(proSet,proMap);//物件コードMap作成
        
		Map<String,Id> memMap = new Map<String,Id>();
        createMemberMap(memSet,memMap);	//会員IdMap作成
        
        if(!bHDiffMap.values().isEmpty()){ // もし、マップのListが空ではなかったら
            for (BrowsingHistoryDifference__c bHDiff: bHDiffMap.values()){               
                //レコード作成
                bHList.add(createBH(bHDiff, proMap, memMap)); //引数追加      	         
            }
            SecureDML.secureUpsert(bHList, BrowsingHistory__c.BrowsingHistoryId__c);  //外部Idをキーにuspert
        }
    }

    //閲覧履歴レコードの作成
    private BrowsingHistory__c createBH(BrowsingHistoryDifference__c bHDiff, Map<String,Id> proMap, Map<String,Id> memMap){
        BrowsingHistory__c browsingHistory = new BrowsingHistory__c(
        
            BrowsingHistoryId__c = bHDiff.BrowsingHistoryId__c      //閲覧履歴ID
            ,MemberId__c     = bHDiff.MemberId__c           //会員ID
            ,SessionKey__c   = bHDiff.SessionKey__c        //セッションキー
            ,BrowsingDate__c = bHDiff.BrowsingDate__c      //閲覧日時
            ,PropertyCd__c   = bHDiff.PropertyCd__c        //物件コード
            ,IsDeleted__c    = bHDiff.IsDeleted__c         //削除
            ,PropertyId__c   = proMap.get(bHDiff.PropertyCd__c)		//物件Id
            ,MemberCoId__c   = memMap.get(bHDiff.memberId__c)		//本会員Id
            );                   
        return browsingHistory;
    }
    
    //物件マップ作成
    private void createPropertyMap(Set<String> proSet, Map<String,Id> proMap){
        List<Property__c> proList = [SELECT id,PropertyCode__c FROM Property__c WHERE PropertyCode__c IN :proSet];      //proSetから当てはまる物件IDを取ってきてリストに入れる
        for (Property__c pro: proList){
            proMap.put(pro.PropertyCode__c, pro.Id);
        }
    }
    
    //●●本会員マップ作成
    private void createMemberMap(Set<String> memSet, Map<String,Id> memMap){
        List<Member__c> memList = [SELECT id,MemberId__c FROM Member__c WHERE MemberId__c IN :memSet];      //memSetから当てはまる会員IDを取ってきてリストに入れる
        for (Member__c mem: memList){
            //会員Idと本会員Idを紐付け
            memMap.put(mem.MemberId__c, mem.Id);
        }
    }

    // 非同期削除処理
    @future
    public static void asynchronousDeleteDifference(Set<Id> deleteIdSet) {

        // 削除対処となるListを作成し、削除する。  
        List <BrowsingHistoryDifference__c> deleteList= [SELECT Id FROM BrowsingHistoryDifference__c 
                                                            WHERE Id IN :deleteIdSet
                                                            ];

        if(!deleteList.isEmpty()){// Listが空でなければ
            SecureDML.secureDelete(deleteList); // Delteを実施。
        }
    }
}