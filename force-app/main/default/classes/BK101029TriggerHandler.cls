//お気に入り物件トリガーハンドラ
public with sharing class BK101029TriggerHandler {
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;

    /** コンストラクタ */
    public BK101029TriggerHandler(boolean isExecuting, integer size) {
         m_isExecuting = isExecuting;
         BatchSize = size;
    }

    /** 登録前処理 */
    public void onBeforeInsert(FavoriteProperty__c[] newObjs){
    }

    // ** 登録後処理 */
    public void onAfterInsert(FavoriteProperty__c[] newObjs, Map<ID, FavoriteProperty__c> newObjMap){
        // **お気に入り物件OBJ登録
        favoritePropertyProcessing(newObjs,'C');
    }

    /** 更新前処理 */
    public void onBeforeUpdate(FavoriteProperty__c[] oldObjs, Map<ID, FavoriteProperty__c> oldObjMap, FavoriteProperty__c[] newObjs, Map<ID, FavoriteProperty__c> newObjMap){
    }

    /** 更新後処理 */
    public void onAfterUpdate(FavoriteProperty__c[] oldObjs, Map<ID, FavoriteProperty__c> oldObjMap, FavoriteProperty__c[] newObjs, Map<ID, FavoriteProperty__c> newObjMap){
        // **お気に入り物件OBJ登録
        favoritePropertyProcessing(newObjs,'U');
    }

    /** 削除前処理 */
    public void onBeforeDelete(FavoriteProperty__c[] oldObjs, Map<ID, FavoriteProperty__c> oldObjMap){
        // **お気に入り物件OBJ登録
        favoritePropertyProcessing(oldObjs,'D');

    }

     /** 削除後処理 */
     public void onAfterDelete(FavoriteProperty__c[] oldObjs, Map<ID, FavoriteProperty__c> oldObjMap){
    }

    /** 復元後処理 */
    public void onUndelete(FavoriteProperty__c[] newObjs){
    }


    // ********************************
    // privateメソッド　　　　　　　　　　　　　
    // ******************************** 

    // お気に入り物件オブジェクト作成更新

    private void favoritePropertyProcessing(FavoriteProperty__c[] objs, String crudCd){
        //お気に入り物件差分リストの作成
        List<FavoritePropertyDifference__c> favoDiffList = new List<FavoritePropertyDifference__c>();

        Set<Id> proSet = new Set<Id>();
        //物件コード取得
        for (FavoriteProperty__c favo : objs){
            proSet.add(favo.Property__c);
        }
        Map<id,String> proCodeMap = new Map<id,String>();
        proCodeMap = getPropertyCode(proSet);
        
        for (FavoriteProperty__c favo : objs){
            //お気に入り物件を元にお気に入り物件差分作成
            FavoritePropertyDifference__c favoDiff = createfavoDiffDiff(favo, proCodeMap, crudCd);

            if(favoDiff != null){
                //空じゃなければリストに作成
                favoDiffList.add(favoDiff); 
            }          
        }
        //お気に入り物件差分をinsert
        if(!favoDiffList.isEmpty()){
            //リストが空でなければisnert
            SecureDML.secureInsert(favoDiffList);
        }
    }

    //お気に入り物件を元にお気に入り物件差分作成
    private FavoritePropertyDifference__c createfavoDiffDiff(FavoriteProperty__c favo, Map<id,String> proCodeMap, String crudCd){
        FavoritePropertyDifference__c favoDiff = new FavoritePropertyDifference__c(
            FavoritePropertyId__c = favo.Id,
            Status__c = favo.Status__c,                        //ステータス
            Address__c = favo.Address__c,                      //住所
            PreviewImpression__c = favo.PreviewImpression__c,  //内見感想
            Account__c = favo.Account__c,                      //取引先
            NearestStation__c = favo.NearestStation__c,        //最寄駅
            Property__c =favo.Property__c,                     //物件
            PropertyStatus__c = favo.PropertyStatus__c,        //状況
            BuildingYM__c = favo.BuildingYM__c,                //築年
            RentFee__c = favo.RentFee__c,                      //賃料
            ParkingFee__c = favo.ParkingFee__c,                //駐車場
            PropertyCode__c = proCodeMap.get(favo.Property__c),     //物件コード
            CrudCd__c = crudCd
        );
        return favoDiff;
    }

    //物件コード取得
    private Map<id, String> getPropertyCode(Set<id> proSet){
        List<Property__c> proLost = [SELECT id,PropertyCode__c 
                                    FROM Property__c 
                                    WHERE id IN :ProSet];
        
        Map<id,String> proCodeMap = new Map<id,String>();
        for (Property__c pro : proLost){
            proCodeMap.put(pro.id, pro.PropertyCode__c);
        }
        return proCodeMap;
    }
}