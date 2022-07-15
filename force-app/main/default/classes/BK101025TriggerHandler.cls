//検索履歴差分トリガハンドラ
public with sharing class BK101025TriggerHandler {
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;

    /** コンストラクタ */
    public BK101025TriggerHandler(boolean isExecuting, integer size) {
         m_isExecuting = isExecuting;
         BatchSize = size;
    }

    /** 登録前処理 */
    public void onBeforeInsert(SearchHistoryDifference__c[] newObjs){
    }

    // ** 登録後処理 */
    public void onAfterInsert(SearchHistoryDifference__c[] newObjs, Map<ID, SearchHistoryDifference__c> newObjMap){
        
        // **検索履歴OBJ登録・更新 その後処理した差分レコード削除 */
        searchHistoryProcessing(newObjs,newObjMap);
    }

    /** 更新前処理 */
    public void onBeforeUpdate(SearchHistoryDifference__c[] oldObjs, Map<ID, SearchHistoryDifference__c> oldObjMap, SearchHistoryDifference__c[] newObjs, Map<ID, SearchHistoryDifference__c> newObjMap){
    }

    /** 更新後処理 */
    public void onAfterUpdate(SearchHistoryDifference__c[] oldObjs, Map<ID, SearchHistoryDifference__c> oldObjMap, SearchHistoryDifference__c[] newObjs, Map<ID, SearchHistoryDifference__c> newObjMap){
    }

    /** 削除前処理 */
    public void onBeforeDelete(SearchHistoryDifference__c[] oldObjs, Map<ID, SearchHistoryDifference__c> oldObjMap){
    }

     /** 削除後処理 */
     public void onAfterDelete(SearchHistoryDifference__c[] oldObjs, Map<ID, SearchHistoryDifference__c> oldObjMap){
    }

    /** 復元後処理 */
    public void onUndelete(SearchHistoryDifference__c[] newObjs){
    }


    // ********************************
    // privateメソッド　　　　　　　　　　　　　
    // ********************************


    //検索履歴オブジェクト作成
    private void searchHistoryProcessing(SearchHistoryDifference__c[] oldObjs, Map<ID, SearchHistoryDifference__c> newObjMap){
        //upsert用検索履歴差分マップ<検索履歴Id,検索履歴差分>
        Map<String,SearchHistoryDifference__c> sHDiffMap = new Map<String,SearchHistoryDifference__c>();
 		
        //Idセット 
        Set<String> memSet =new Set<String>();	//会員Idセット
        Set<Id> delSHDiffSet = new Set<Id>();	//差分削除用Idセット

        // 検索履歴差分マップを作成（参照型なのでreturnしなくても値が入る）  追加Idセットをついでに取得
        createsHDiffMap(oldObjs, sHDiffMap, delSHDiffSet, memSet);

        //レコード更新
        upsertSH(sHDiffMap, memSet);

        //差分削除
        asynchronousDeleteDifference(delSHDiffSet);
    }
    
    //検索履歴差分マップ作成 
    private void createSHDiffMap(SearchHistoryDifference__c[] oldObjs, Map<String,SearchHistoryDifference__c> sHDiffMap, Set<Id> delSHDiffSet, Set<String> memSet){
        for (SearchHistoryDifference__c oldObj : oldObjs){

                //Herokuから来たCまたはUのレコードは作成更新処理、差分削除を行う
                if (oldObj.CrudCd__c == 'C' || oldObj.CrudCd__c == 'U'){

                //マップに追加（同じ検索履歴IDのものは、新しいものに上書きされる）
                sHDiffMap.put(oldObj.SearchHistoryId__c,oldObj );

                //Idセットに値追加
				memSet.add(oldObj.MemberId__c);		//会員Idセットに会員Id追加
                delSHDiffSet.add(oldObj.Id);		//差分削除IdセットにId追加
            }
        }
    }

    //検索履歴upsert
    private void upsertSH(Map<String,SearchHistoryDifference__c> sHDiffMap, Set<String> memSet){
        //upsert用検索履歴リスト
        List<SearchHistory__c> sHList = new List<SearchHistory__c>();

        //Map作成
		Map<String,Id> memMap = new Map<String,Id>();
        createMemberMap(memSet,memMap);	//会員IdMap作成
        
        if(!sHDiffMap.values().isEmpty()){ // もし、マップのListが空ではなかったら
            for (SearchHistoryDifference__c sHDiff: sHDiffMap.values()){               
                //レコード作成
                sHList.add(createSH(sHDiff, memMap)); //引数追加      	         
            }
            SecureDML.secureUpsert(sHList, SearchHistory__c.SearchHistoryId__c);  //外部Idをキーにuspert
        }
    }

    //検索履歴レコードの作成
    private SearchHistory__c createSH(SearchHistoryDifference__c sHDiff, Map<String,Id> memMap){
        SearchHistory__c SearchHistory = new SearchHistory__c(
        
            SearchHistoryId__c                  =   sHDiff.SearchHistoryId__c      //検索履歴ID（検索履歴オブジェクトで必須項目）
            ,MemberId__c                        =   sHDiff.MemberId__c           //会員ID（検索履歴オブジェクトで必須項目）
            ,SearchDate__c                      =   sHDiff.SearchDate__c        //検索日時（検索履歴オブジェクトで必須項目）
            ,SaveDate__c                        =   sHDiff.SaveDate__c      //保存日時
            ,SaveFlg__c                         =   sHDiff.SaveFlg__c        //保存フラグ
            ,NewMailDeliveryFlg__c              =   sHDiff.NewMailDeliveryFlg__c         //新着メール配信フラグ
            ,TrainRouteStation__c               =   sHDiff.TrainRouteStation__c         //沿線・駅
            ,Area__c                            =   sHDiff.Area__c         //エリア
            ,SchoolName__c                      =   sHDiff.SchoolName__c                //学区名
            ,StationId__c                       =   sHDiff.StationId__c             //駅ID
            ,CityCd__c                          =   sHDiff.CityCd__c                //市区郡コード
            ,ChoazaCd__c                        =   sHDiff.ChoazaCd__c             //町字コード
            ,SchoolId__c                        =   sHDiff.SchoolId__c      //学校ID
            ,RentFeeUnder__c                    =   sHDiff.RentFeeUnder__c          //賃料_下限
            ,RentFeeUpper__c                    =   sHDiff.RentFeeUpper__c          //賃料_上限
            ,ManageFee__c                       =   sHDiff.ManageFee__c              //管理費・共益費込み
            ,KeyMoneyNashi__c                   =   sHDiff.KeyMoneyNashi__c         //礼金なし
            ,DepositNashi__c                    =   sHDiff.DepositNashi__c          //敷金・保証金なし
            ,FloorPlan1r__c                     =   sHDiff.FloorPlan1r__c           //間取り_ワンルーム
            ,FloorPlan1k__c                     =   sHDiff.FloorPlan1k__c           //間取り_1K
            ,FloorPlan1dk__c                    =   sHDiff.FloorPlan1dk__c          //間取り_1DK
            ,FloorPlan1ldk__c                   =   sHDiff.FloorPlan1ldk__c         //間取り_1LDK/SLDK
            ,FloorPlan2k__c                     =   sHDiff.FloorPlan2k__c           //間取り_2K/DK
            ,FloorPlan2ldk__c                   =   sHDiff.FloorPlan2ldk__c         //間取り_2LDK/SLDK
            ,FloorPlan3k__c                     =   sHDiff.FloorPlan3k__c           //間取り_3K/DK
            ,FloorPlan3ldk__c                   =   sHDiff.FloorPlan3ldk__c         //間取り_3LDK/SLDK
            ,FloorPlan4k__c                     =   sHDiff.FloorPlan4k__c           //間取り_4K/DK/LDK～
            ,PrivateAreaUnder__c                =   sHDiff.PrivateAreaUnder__c          //専有面積_下限
            ,PrivateAreaUpper__c                =   sHDiff.PrivateAreaUpper__c          //専有面積_上限
            ,StationWalk__c                     =   sHDiff.StationWalk__c            //駅徒歩
            ,BuildYear__c                       =   sHDiff.BuildYear__c         //築年数
            ,MansionType__c                     =   sHDiff.MansionType__c           //マンションタイプ
            ,ApartmentType__c                   =   sHDiff.ApartmentType__c         //アパートタイプ
            ,HouseType__c                       =   sHDiff.HouseType__c         //戸建てタイプ
            ,FirstFloor__c                      =   sHDiff.FirstFloor__c            //１階
            ,SecondFloorOver__c                 =   sHDiff.SecondFloorOver__c            //２階以上
            ,Pet__c                             =   sHDiff.Pet__c           //ペット可
            ,SmallPet__c                        =   sHDiff.SmallPet__c          //ペット_小型犬
            ,MiddlePet__c                       =   sHDiff.MiddlePet__c         //ペット_中型犬
            ,LargePet__c                        =   sHDiff.LargePet__c          //ペット_大型犬
            ,Cat__c                             =   sHDiff.Cat__c           //ペット_猫
            ,OtherPet__c                        =   sHDiff.OtherPet__c          //ペット_その他
            ,Parking__c                         =   sHDiff.Parking__c           //駐車場空きあり
            ,NoGuarantor__c                     =   sHDiff.NoGuarantor__c           //保証人不要
            ,WoodBuilding__c                    =   sHDiff.WoodBuilding__c          //木造
            ,LightSteelFrame__c                 =   sHDiff.LightSteelFrame__c           //軽量鉄骨
            ,SteelFrameBuilding__c              =   sHDiff.SteelFrameBuilding__c            //鉄骨造
            ,RcBuilding__c                      =   sHDiff.RcBuilding__c            //RC
            ,SrcBuilding__c                     =   sHDiff.SrcBuilding__c           //SRC
            ,North__c                           =   sHDiff.North__c             //方角_北
            ,NorthEast__c                       =   sHDiff.NorthEast__c             //方角_北東
            ,East__c                            =   sHDiff.East__c          //方角_東
            ,SouthEast__c                       =   sHDiff.SouthEast__c         //方角_南東
            ,South__c                           =   sHDiff.South__c             //方角_南
            ,SouthWest__c                       =   sHDiff.SouthWest__c         //方角_南西
            ,West__c                            =   sHDiff.West__c              //方角_西
            ,NorthWest__c                       =   sHDiff.NorthWest__c             //方角_北西
            ,Maisonette__c                      =   sHDiff.Maisonette__c            //メゾネット
            ,Loft__c                            =   sHDiff.Loft__c              //ロフト
            ,Designers__c                       =   sHDiff.Designers__c             //デザイナーズ
            ,Renovation__c                      =   sHDiff.Renovation__c            //リノベーション
            ,CondominiumRental__c               =   sHDiff.CondominiumRental__c         //分譲賃貸
            ,AllWesternStyleRoom__c             =   sHDiff.AllWesternStyleRoom__c           //オール洋間
            ,TopFloor__c                        =   sHDiff.TopFloor__c              //最上階
            ,CornerRoom__c                      =   sHDiff.CornerRoom__c            //角部屋
            ,PrivateGarden__c                   =   sHDiff.PrivateGarden__c             //専用庭
            ,RoofBalcony__c                     =   sHDiff.RoofBalcony__c           //ルーフバルコニー
            ,DeliveryBox__c                     =   sHDiff.DeliveryBox__c            //宅配ボックス
            ,Elevator__c                        =   sHDiff.Elevator__c            //エレベーター
            ,InSiteParking__c                   =   sHDiff.InSiteParking__c             //敷地内駐車場
            ,PluralCarParking__c                =   sHDiff.PluralCarParking__c          //駐車場2台可
            ,Carport__c                         =   sHDiff.Carport__c           //カーポート
            ,BuiltInGarage__c                   =   sHDiff.BuiltInGarage__c             //ビルトインガレージ
            ,BicycleParking__c                  =   sHDiff.BicycleParking__c            //駐輪場
            ,BikeStorage__c                     =   sHDiff.BikeStorage__c           //バイク可
            ,SmallBike__c                       =   sHDiff.SmallBike__c             //バイク_小型
            ,MediumBike__c                      =   sHDiff.MediumBike__c            //バイク_中型
            ,LargeBike__c                       =   sHDiff.LargeBike__c             //バイク_大型
            ,CounterKitchen__c                  =   sHDiff.CounterKitchen__c            //カウンターキッチン
            ,SystemKitchen__c                   =   sHDiff.SystemKitchen__c             //システムキッチン
            ,GasStove__c                        =   sHDiff.GasStove__c              //ガスコンロ
            ,ElectricStove__c                   =   sHDiff.ElectricStove__c             //電気コンロ
            ,IhStove__c                         =   sHDiff.IhStove__c               //IHコンロ
            ,TwoGasStove__c                     =   sHDiff.TwoGasStove__c           //コンロ2口
            ,MoreGasStove__c                    =   sHDiff.MoreGasStove__c              //コンロ3口以上
            ,Separate__c                        =   sHDiff.Separate__c              //バス・トイレ別
            ,Reheating__c                       =   sHDiff.Reheating__c             //追焚き機能
            ,BathroomDryer__c                   =   sHDiff.BathroomDryer__c             //浴室乾燥機
            ,WashletToilletSeat__c              =   sHDiff.WashletToilletSeat__c            //温水洗浄便座
            ,ShowerWashBasin__c                 =   sHDiff.ShowerWashBasin__c               //シャワー付洗面台
            ,WashroomDscrete__c                 =   sHDiff.WashroomDscrete__c               //洗面所独立
            ,IndoorWashingMachineStorage__c     =   sHDiff.IndoorWashingMachineStorage__c               //室内洗濯機置場
            ,CityGas__c                         =   sHDiff.CityGas__c               //都市ガス
            ,PropaneGas__c                      =   sHDiff.PropaneGas__c                //プロパンガス
            ,AllElectric__c                     =   sHDiff.AllElectric__c               //オール電化
            ,AirConditioner__c                  =   sHDiff.AirConditioner__c                //エアコン
            ,FloorHeating__c                    =   sHDiff.FloorHeating__c              //床暖房
            ,ShoesCloak__c                      =   sHDiff.ShoesCloak__c                //シューズクローク
            ,WalkInCloset__c                    =   sHDiff.WalkInCloset__c              //ウォークインクローゼット
            ,TrunkRoom__c                       =   sHDiff.TrunkRoom__c             //トランクルーム
            ,BsAntenna__c                       =   sHDiff.BsAntenna__c             //BSアンテナ
            ,CsAntenna__c                       =   sHDiff.CsAntenna__c             //CSアンテナ
            ,Catv__c                            =   sHDiff.Catv__c          //CATV
            ,InternetFree__c                    =   sHDiff.InternetFree__c          //ネット使用料無料
            ,MonitorIntercom__c                 =   sHDiff.MonitorIntercom__c               //モニター付きインターホン
            ,AutoLock__c                        =   sHDiff.AutoLock__c              //オートロック
            ,Furniture__c                       =   sHDiff.Furniture__c             //家具付き
            ,HomeAppliance__c                   =   sHDiff.HomeAppliance__c             //家電付き
            ,GuaranteeNotNeed__c                =   sHDiff.GuaranteeNotNeed__c              //保証会社不要
            ,MusicalInstruments__c              =   sHDiff.MusicalInstruments__c            //楽器相談可
            ,RoomShare__c                       =   sHDiff.RoomShare__c             //ルームシェア可
            ,OfficeAvailable__c                 =   sHDiff.OfficeAvailable__c               //事務所利用可
            ,Student__c                         =   sHDiff.Student__c               //学生限定
            ,Woman__c                           =   sHDiff.Woman__c             //女性限定
            ,RentCarditPayment__c               =   sHDiff.RentCarditPayment__c             //家賃カード決済可
            ,InitialCostCreditPayment__c        =   sHDiff.InitialCostCreditPayment__c           //初期費用カード決済可
            ,SearchHistoryHiddenFlg__c          =   sHDiff.SearchHistoryHiddenFlg__c             //検索履歴非表示フラグ
            ,IsDeleted__c                       =   sHDiff.IsDeleted__c             //削除
            ,MemberCoId__c                      =   memMap.get(sHDiff.memberId__c)		//本会員Id
            ,FreewordSearch__c                  =   SHDiff.FreewordSearch__c            //フリーワード検索      追加要望　追加
            );                   
        return SearchHistory;
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
        List <SearchHistoryDifference__c> deleteList= [SELECT Id FROM SearchHistoryDifference__c 
                                                            WHERE Id IN :deleteIdSet
                                                            ];

        if(!deleteList.isEmpty()){// Listが空でなければ
            SecureDML.secureDelete(deleteList); // Delteを実施。
        }
    }
}