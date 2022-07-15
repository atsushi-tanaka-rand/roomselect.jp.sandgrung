//ポータルお気に入り物件差分トリガハンドラ

public with sharing class BK101021TriggerHandler {
    
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;

    /** コンストラクタ */
    public BK101021TriggerHandler(boolean isExecuting, integer size) {
         m_isExecuting = isExecuting;
         BatchSize = size;
    }

    /** 登録前処理 */
    public void onBeforeInsert(PortalFavoritePropertyDifference__c[] newObjs){
    }

    // ** 登録後処理 */
    public void onAfterInsert(PortalFavoritePropertyDifference__c[] newObjs, Map<ID, PortalFavoritePropertyDifference__c> newObjMap){
        
        // **ポータルお気に入り物件OBJ登録・更新 その後処理した差分レコード削除 */
        portalProcessing(newObjs,newObjMap);
    }

    /** 更新前処理 */
    public void onBeforeUpdate(PortalFavoritePropertyDifference__c[] oldObjs, Map<ID, PortalFavoritePropertyDifference__c> oldObjMap, PortalFavoritePropertyDifference__c[] newObjs, Map<ID, PortalFavoritePropertyDifference__c> newObjMap){
    }

    /** 更新後処理 */
    public void onAfterUpdate(PortalFavoritePropertyDifference__c[] oldObjs, Map<ID, PortalFavoritePropertyDifference__c> oldObjMap, PortalFavoritePropertyDifference__c[] newObjs, Map<ID, PortalFavoritePropertyDifference__c> newObjMap){
    }

    /** 削除前処理 */
    public void onBeforeDelete(PortalFavoritePropertyDifference__c[] oldObjs, Map<ID, PortalFavoritePropertyDifference__c> oldObjMap){
    }

     /** 削除後処理 */
     public void onAfterDelete(PortalFavoritePropertyDifference__c[] oldObjs, Map<ID, PortalFavoritePropertyDifference__c> oldObjMap){
    }

    /** 復元後処理 */
    public void onUndelete(PortalFavoritePropertyDifference__c[] newObjs){
    }


    // ********************************
    // privateメソッド　　　　　　　　　　　　　
    // ******************************** 

    // ポータルお気に入り物件オブジェクト作成更新
    private void portalProcessing(PortalFavoritePropertyDifference__c[] oldObjs, Map<ID, PortalFavoritePropertyDifference__c> newObjMap){
        //upsert用ポータルお気に入り物件差分マップ<ポータルお気に入り物件Id,ポータルお気に入り物件差分>
        Map<String,PortalFavoritePropertyDifference__c> portalDiffMap = new Map<String,PortalFavoritePropertyDifference__c>();
 		
        //Idセット
        Set<String> proSet =new Set<String>();	//物件コードセット
        Set<String> memSet =new Set<String>();	//会員Idセット
        Set<Id> delPortalDiffSet = new Set<Id>();	//差分削除用Idセット
        Set<String> portalDeleteSet = new Set<String>();      //ポータルお気に入り物件レコード削除用セット

        // ポータルお気に入り物件差分マップを作成（参照型なのでreturnしなくても値が入る）  追加Idセットをついでに取得
        createPortalDiffMap(oldObjs, portalDiffMap, delPortalDiffSet, proSet, memSet, portalDeleteSet);

        //レコードを更新
        upsertPortal(portalDiffMap, proSet, memSet);

        //レコードを削除
        deletePortal(portalDeleteSet);


        //差分削除
        asynchronousDeleteDifference(delPortalDiffSet);
    }

    //ポータルお気に入り物件差分マップ作成 
    private void createPortalDiffMap(PortalFavoritePropertyDifference__c[] oldObjs, Map<String,PortalFavoritePropertyDifference__c> portalDiffMap, Set<Id> delPortalDiffSet, Set<String> proSet, Set<String> memSet, Set<String> portalDeleteSet){
        for (PortalFavoritePropertyDifference__c oldObj : oldObjs){

            //Herokuから来たCまたはUまたはDのレコードは作成更新削除処理、差分削除を行う
            if (oldObj.CrudCd__c == 'C' || oldObj.CrudCd__c == 'U' ){

                //マップに追加（同じポータルお気に入り物件IDのものは、新しいものに上書きされる）
                portalDiffMap.put(oldObj.portalFavoritePropertId__c,oldObj );

                //Idセットに値追加
				proSet.add(oldObj.PropertyCd__c);	//物件コードセットに物件コード追加
                memSet.add(oldObj.MemberId__c);		//会員Idセットに会員Id追加
                delPortalDiffSet.add(oldObj.Id);	//差分削除IdセットにId追加

            }else if(oldObj.CrudCd__c == 'D'){
                //クラッドコードがDの場合、portalDeleteSetに削除するポータルお気に入り物件IDを追加する
                portalDeleteSet.add(oldObj.portalFavoritePropertId__c);
                delPortalDiffSet.add(oldObj.Id);	//差分削除IdセットにId追加
            }
            
        }
    }

    //ポータルお気に入り物件upsert
    private void upsertPortal(Map<String,PortalFavoritePropertyDifference__c> portalDiffMap, Set<String> proSet, Set<String> memSet){
        //upsert用ポータルお気に入り物件リスト
        List<PortalFavoriteProperty__c> portalList = new List<PortalFavoriteProperty__c>();

        //Map作成
		Map<String,Id> proMap = new Map<String,Id>();
        createPropertyMap(proSet,proMap);//物件コードMap作成
        
		Map<String,Id> memMap = new Map<String,Id>();
        createMemberMap(memSet,memMap);	//会員IdMap作成
        
        if(!portalDiffMap.values().isEmpty()){ // もし、マップのListが空ではなかったら
            for (PortalFavoritePropertyDifference__c portalDiff: portalDiffMap.values()){               
                //レコード作成
                portalList.add(createPortal(portalDiff, proMap, memMap)); //引数追加      	         
            }
            SecureDML.secureUpsert(portalList, PortalFavoriteProperty__c.portalFavoritePropertId__c);  //外部(ポータルお気に入り物件)Idをキーにuspert
        }
    }

    //ポータルお気に入り物件Delete

    //portalDeleteSetの中身を渡すので削除する
    private void deletePortal(Set<String> portalDeleteSet){
        //delete用ポータルお気に入り物件リストに、クラッドコードDで追加されたIDを入れていく
    
        List<PortalFavoriteProperty__c> DeleteList = [SELECT id FROM PortalFavoriteProperty__c WHERE portalFavoritePropertId__c IN :portalDeleteSet];

        if(!DeleteList.isEmpty()){ // もし、マップのListが空ではなかったら
            SecureDML.secureDelete(DeleteList);  //リストの中身を削除    
        }
    }

    //ポータルお気に入り物件レコードの作成
    private PortalFavoriteProperty__c createPortal(PortalFavoritePropertyDifference__c portalDiff, Map<String,Id> proMap, Map<String,Id> memMap){
        PortalFavoriteProperty__c portal = new PortalFavoriteProperty__c(
        
            portalFavoritePropertId__c = portalDiff.portalFavoritePropertId__c      //ポータルお気に入り物件ID
            ,MemberId__c     = portalDiff.MemberId__c           //会員ID
            ,PropertyCd__c   = portalDiff.PropertyCd__c        //物件コード
            ,BrowsingDate__c = portalDiff.BrowsingDate__c      //お気に入り登録日時
            ,IsDeleted__c    = portalDiff.IsDeleted__c         //削除
            ,PropertyId__c   = proMap.get(portalDiff.PropertyCd__c)		//物件Id
            ,MemberCoId__c   = memMap.get(portalDiff.memberId__c)		//本会員Id
            );                   
        return portal;
    }

    //物件マップ作成
    private void createPropertyMap(Set<String> proSet, Map<String,Id> proMap){
        List<Property__c> proList = [SELECT id,PropertyCode__c FROM Property__c WHERE PropertyCode__c IN :proSet];      //proSetから当てはまる物件IDを取ってきてリストに入れる
        for (Property__c pro: proList){
           
            proMap.put(pro.PropertyCode__c, pro.Id);
        }
         System.debug(proList);
    }

    //本会員マップ作成
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
        List <PortalFavoritePropertyDifference__c> deleteList= [SELECT Id FROM PortalFavoritePropertyDifference__c 
                                                            WHERE Id IN :deleteIdSet
                                                            ];

        if(!deleteList.isEmpty()){// Listが空でなければ
            SecureDML.secureDelete(deleteList); // Delteを実施。
        }
    }
}