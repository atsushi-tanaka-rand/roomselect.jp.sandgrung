public inherited sharing class TA102004Controller {

    // パブリック変数
    public String csvName           { get; set; }   // CSV名
    public OutputCsvData csvData    { get; set; }   // CSVデータ
    public String breakString { get{ return '\r\n';} set; } // 改行

    // コンストラクタ（CSV出力）
    public TA102004Controller() {
        // パラメータ取得
        String applicationId = ApexPages.currentPage().getParameters().get('applicationId');

        // 引数必須チェック
        if (String.isEmpty(applicationId)) {
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }

        // 出力データ抽出
        Application__c appli            = this.selectApplication(applicationId);
        PropertyConditions__c propCond  = this.selectPropertyConditions(appli.Property__c);
        List<Room__c> roomList          = this.selectRoom(appli.Property__c);
        Item__c item                    = this.selectItem(appli.Property__c, appli.Account__c);
        List<Tenant__c> tenantList      = this.selectTenant(applicationId);
        Shop__c shop                    = CommonUtil.getStaffCurrentShop();

        // 出力データ作成
        this.csvData = new OutputCsvData(
            appli
            ,propCond
            ,roomList
            ,item
            ,tenantList
            ,shop
        );

        // csv名設定
        csvName = '標準形式' + CommonUtil.getNow().format('yyyy-MM-dd') + '.csv';

    }

    // CSV出力用内部クラス
    public class OutputCsvData {
        // CSV項目
        public List<CsvItem> itemList { get; set; }
        // コンストラクタ
        public OutputCsvData(Application__c appli, PropertyConditions__c propCond, List<Room__c> roomList, Item__c item, List<Tenant__c> tenantList, Shop__c shop) {
            this.itemList = new List<CsvItem>();
            this.addItem('Building__c.BuildKana__c'                                     , appli.Property__r.Building__r.BuildKana__c);                  // 建物．建物名(カナ)
            this.addItem('Building__c.Name'                                             , appli.Property__r.Building__r.Name);                          // 建物．建物名
            this.addItem('Building__c.PropertyType__c'                                  , appli.Property__r.Building__r.PropertyType__c);               // 建物．物件種別
            this.addItem('Building__c.Structure__c'                                     , appli.Property__r.Building__r.Structure__c);                  // 建物．建物構造
            this.addItem('Building__c.PostalCode__c'                                    , appli.Property__r.Building__r.PostalCode__c);                 // 建物．郵便番号
            this.addItem('Building__c.State__c'                                         , appli.Property__r.Building__r.State__c);                      // 建物．都道府県
            this.addItem('Building__c.City__c'                                          , appli.Property__r.Building__r.City__c);                       // 建物．住所１（市区町村）
            this.addItem('Building__c.Street__c'                                        , appli.Property__r.Building__r.Street__c);                     // 建物．住所２（番地）
            this.addItem('Building__c.TrainRoute1__c.Name'                              , appli.Property__r.Building__r.TrainRoute1__r.Name);           // 建物．沿線１
            this.addItem('Building__c.Station1__c.Name'                                 , appli.Property__r.Building__r.Station1__r.Name);              // 建物．駅１
            this.addItem('Building__c.StationWalkTime1__c'                              , appli.Property__r.Building__r.StationWalkTime1__c);           // 建物．駅までの時間１
            this.addItem('Building__c.TrainRoute2__c.Name'                              , appli.Property__r.Building__r.TrainRoute2__r.Name);           // 建物．沿線２
            this.addItem('Building__c.Station2__c.Name'                                 , appli.Property__r.Building__r.Station2__r.Name);              // 建物．駅２
            this.addItem('Building__c.StationWalkTime2__c'                              , appli.Property__r.Building__r.StationWalkTime2__c);           // 建物．駅までの時間２
            this.addItem('Building__c.TrainRoute3__c.Name'                              , appli.Property__r.Building__r.TrainRoute3__r.Name);           // 建物．沿線３
            this.addItem('Building__c.Station3__c.Name'                                 , appli.Property__r.Building__r.Station3__r.Name);              // 建物．駅３
            this.addItem('Building__c.StationWalkTime3__c'                              , appli.Property__r.Building__r.StationWalkTime3__c);           // 建物．駅までの時間３
            this.addItem('Building__c.BusStop1__c'                                      , appli.Property__r.Building__r.BusStop1__c);                   // 建物．バス停
            this.addItem('Building__c.BusRideTime1__c'                                  , appli.Property__r.Building__r.BusRideTime1__c);               // 建物．バス乗車時間
            this.addItem('Building__c.GroundFloorCount__c'                              , appli.Property__r.Building__r.GroundFloorCount__c);           // 建物．地上階数
            this.addItem('Building__c.UndergroundFloorCount__c'                         , appli.Property__r.Building__r.UndergroundFloorCount__c);      // 建物．地下階数
            this.addItem('Building__c.HouseCount__c'                                    , appli.Property__r.Building__r.HouseCount__c);                 // 建物．棟総戸数
            this.addItem('Building__c.BuildingYM__c'                                    , appli.Property__r.Building__r.BuildingYM__c);                 // 建物．築年月
            this.addItem('Building__c.Leasehold__c'                                     , appli.Property__r.Building__r.Leasehold__c);                  // 建物．借地権
            this.addItem('Building__c.Location__c'                                      , appli.Property__r.Building__r.Location__c);                   // 建物．地勢
            this.addItem('Building__c.CaretakerType__c'                                 , appli.Property__r.Building__r.CaretakerType__c);              // 建物．管理人種別
            this.addItem('Building__c.PrimarySchool1__c.Name'                           , appli.Property__r.Building__r.PrimarySchool1__r.Name);        // 建物．小学校
            this.addItem('Building__c.PrimarySchoolDistance1__c'                        , appli.Property__r.Building__r.PrimarySchoolDistance1__c);     // 建物．小学校までの距離１
            this.addItem('Building__c.JuniorHighSchool1__c.Name'                        , appli.Property__r.Building__r.JuniorHighSchool1__r.Name);     // 建物．中学校
            this.addItem('Building__c.JuniorHighSchoolDistance1__c'                     , appli.Property__r.Building__r.JuniorHighSchoolDistance1__c);  // 建物．中学校までの距離１
            this.addItem('Building__c.ConvenienceStoreDistance__c'                      , appli.Property__r.Building__r.ConvenienceStoreDistance__c);   // 建物．コンビニまでの距離
            this.addItem('Building__c.SupermarketDistance__c'                           , appli.Property__r.Building__r.SupermarketDistance__c);        // 建物．スーパーまでの距離
            this.addItem('Building__c.GeneralHospitalDistance__c'                       , appli.Property__r.Building__r.GeneralHospitalDistance__c);    // 建物．総合病院までの距離
            this.addItem('Property__c.TransactionAspect__c'                             , appli.Property__r.TransactionAspect__c);                      // 物件．取引態様
            this.addItem('Property__c.RentFee__c'                                       , appli.Property__r.RentFee__c);                                // 物件．賃料
            this.addItem('Property__c.DepositYen__c'                                    , appli.Property__r.DepositYen__c);                             // 物件．保証料金(円)
            this.addItem('Property__c.DepositMonth__c'                                  , appli.Property__r.DepositMonth__c);                           // 物件．保証料金（ヶ月）
            this.addItem('Property__c.DepositUnit__c'                                   , appli.Property__r.DepositUnit__c);                            // 物件．保証金単位
            this.addItem('Property__c.SecurityDepositYen__c'                            , appli.Property__r.SecurityDepositYen__c);                     // 物件．敷金（円）
            this.addItem('Property__c.SecurityDepositMonth__c'                          , appli.Property__r.SecurityDepositMonth__c);                   // 物件．敷金（ヶ月）
            this.addItem('Property__c.SecurityDepositUnit__c'                           , appli.Property__r.SecurityDepositUnit__c);                    // 物件．敷金単位
            this.addItem('Property__c.KeyMoneyYen__c'                                   , appli.Property__r.KeyMoneyYen__c);                            // 物件．礼金（円）
            this.addItem('Property__c.KeyMoneyMonth__c'                                 , appli.Property__r.KeyMoneyMonth__c);                          // 物件．礼金（ヶ月）
            this.addItem('Property__c.KeyMoneyUnit__c'                                  , appli.Property__r.KeyMoneyUnit__c);                           // 物件．礼金単位
            this.addItem('Property__c.CancellationActualFeeYen__c'                      , appli.Property__r.CancellationActualFeeYen__c);               // 物件．敷引・償却（円）
            this.addItem('Property__c.CancellationActualFeeMonth__c'                    , appli.Property__r.CancellationActualFeeMonth__c);             // 物件．敷引・償却（ヶ月）
            this.addItem('Property__c.CancellationActualFeeRate__c'                     , appli.Property__r.CancellationActualFeeRate__c);              // 物件．敷引・償却（％）
            this.addItem('Property__c.CancellationActualFeeUnit__c'                     , appli.Property__r.CancellationActualFeeUnit__c);              // 物件．敷引・償却単位
            this.addItem('Property__c.ManagementFeeTax__c'                              , appli.Property__r.ManagementFeeTax__c);                       // 物件．管理費（税込）
            this.addItem('Property__c.ManagementFeeTaxType__c'                          , appli.Property__r.ManagementFeeTaxType__c);                   // 物件．管理費税区分
            this.addItem('Property__c.RenewalFeeMonth__c'                               , appli.Property__r.RenewalFeeMonth__c);                        // 物件．更新料（ヶ月）
            this.addItem('Property__c.RenewalFee__c'                                    , appli.Property__r.RenewalFee__c);                             // 物件．更新料（税込）
            this.addItem('Property__c.RenewalFeeUnit__c'                                , appli.Property__r.RenewalFeeUnit__c);                         // 物件．更新単位
            this.addItem('Property__c.RenewalFeeTaxType__c'                             , appli.Property__r.RenewalFeeTaxType__c);                      // 物件．更新税区分
            this.addItem('Property__c.WortFeeTax__c'                                    , appli.Property__r.WortFeeTax__c);                             // 物件．水道料金（税込）
            this.addItem('Property__c.WortFeeTaxType__c'                                , appli.Property__r.WortFeeTaxType__c);                         // 物件．水道料金税区分
            this.addItem('Property__c.TownshipFeeTax__c'                                , appli.Property__r.TownshipFeeTax__c);                         // 物件．町会費（税込）
            this.addItem('Property__c.TownshipFeeTaxType__c'                            , appli.Property__r.TownshipFeeTaxType__c);                     // 物件．町会費税区分
            this.addItem('Property__c.TownshipFeePaymentType__c'                        , appli.Property__r.TownshipFeePaymentType__c);                 // 物件．町会費支払区分
            this.addItem('Property__c.MonetaryPublic__c'                                , appli.Property__r.MonetaryPublic__c);                         // 物件．金銭備考（公開）
            this.addItem('Property__c.ParkingType__c'                                   , appli.Property__r.ParkingType__c);                            // 物件．駐車場種別
            this.addItem('Property__c.ParkingDepositTax__c'                             , appli.Property__r.ParkingDepositTax__c);                      // 物件．駐車場保証料金（税込）
            this.addItem('Property__c.ParkingFeeTax__c'                                 , appli.Property__r.ParkingFeeTax__c);                          // 物件．駐車場料金（税込）
            this.addItem('Property__c.RoomCount__c'                                     , appli.Property__r.RoomCount__c);                              // 物件．部屋数
            this.addItem('Property__c.RoomLayout__c'                                    , appli.Property__r.RoomLayout__c);                             // 物件．間取り
            this.addItem('Property__c.Floor__c'                                         , appli.Property__r.Floor__c);                                  // 物件．所在階
            this.addItem('Property__c.BalconyDirection__c'                              , appli.Property__r.BalconyDirection__c);                       // 物件．バルコニー方向
            this.addItem('Property__c.BalconyArea__c'                                   , appli.Property__r.BalconyArea__c);                            // 物件．バルコニー面積
            this.addItem('Property__c.RoomArea__c'                                      , appli.Property__r.RoomArea__c);                               // 物件．専有面積
            this.addItem('Property__c.LiveStatus__c'                                    , appli.Property__r.LiveStatus__c);                             // 物件．現況
            this.addItem('Property__c.LivedType__c'                                     , appli.Property__r.LivedType__c);                              // 物件．未入居種別
            this.addItem('Property__c.DeliveryType__c'                                  , appli.Property__r.DeliveryType__c);                           // 物件．引渡種別
            this.addItem('Property__c.DeliveryYear__c'                                  , appli.Property__r.DeliveryYear__c);                           // 物件．引渡年
            this.addItem('Property__c.DeliveryMonth__c'                                 , appli.Property__r.DeliveryMonth__c);                          // 物件．引渡月
            this.addItem('Property__c.DeliveryTiming__c'                                , appli.Property__r.DeliveryTiming__c);                         // 物件．引渡旬
            this.addItem('Property__c.DeliveryDay__c'                                   , appli.Property__r.DeliveryDay__c);                            // 物件．引渡日
            this.addItem('Property__c.WebPublishing__c'                                 , appli.Property__r.WebPublishing__c);                          // 物件．Web公開
            this.addItem('Property__c.WebPostingComment__c.ExampleSentence__c'          , appli.Property__r.WebPostingComment__r.ExampleSentence__c);   // 物件．Web掲載時コメント
            this.addItem('Property__c.RewardBurdenLender__c'                            , appli.Property__r.RewardBurdenLender__c);                     // 物件．報酬負担貸主
            this.addItem('Property__c.RewardBurdenBorrower__c'                          , appli.Property__r.RewardBurdenBorrower__c);                   // 物件．報酬負担借主
            this.addItem('Property__c.RewardSplitFormerSupplier__c'                     , appli.Property__r.RewardSplitFormerSupplier__c);              // 物件．報酬配分元付
            this.addItem('Property__c.RewardSplitCustomer__c'                           , appli.Property__r.RewardSplitCustomer__c);                    // 物件．報酬配分客付
            this.addItem('Property__c.ADFeeTax__c'                                      , appli.Property__r.ADFeeTax__c);                               // 物件．広告料
            this.addItem('Property__c.ADFeeComment__c'                                  , appli.Property__r.ADFeeComment__c);                           // 物件．広告料コメント
            this.addItem('Property__c.PropertyComment__c'                               , appli.Property__r.PropertyComment__c);                        // 物件．物件コメント
            this.addItem('Property__c.RepresentativeComment__c'                         , appli.Property__r.RepresentativeComment__c);                  // 物件．担当者コメント
            this.addItem('Property__c.KeyPlace__c'                                      , appli.Property__r.KeyPlace__c);                               // 物件．鍵所在
            this.addItem('Property__c.FormerSupplier__c.Name'                           , appli.Property__r.FormerSupplier__r.Name);                    // 物件．元付業者
            this.addItem('Property__c.FormerSupplierDepartment__c'                      , appli.Property__r.FormerSupplierDepartment__c);               // 物件．担当部署
            this.addItem('Property__c.FormerSupplierRepresentative__c'                  , appli.Property__r.FormerSupplierRepresentative__c);           // 物件．担当者
            this.addItem('Property__c.FormerSupplierRepresentativePhone__c'             , appli.Property__r.FormerSupplierRepresentativePhone__c);      // 物件．担当者電話番号
            this.addItem('Property__c.FormerSupplierPostalCode__c'                      , appli.Property__r.FormerSupplierPostalCode__c);               // 物件．郵便番号
            this.addItem('Property__c.FormerSupplierState__c'                           , appli.Property__r.FormerSupplierState__c);                    // 物件．都道府県
            this.addItem('Property__c.FormerSupplierCity__c'                            , appli.Property__r.FormerSupplierCity__c);                     // 物件．住所１（市区町村）
            this.addItem('Property__c.FormerSupplierStreet__c'                          , appli.Property__r.FormerSupplierStreet__c);                   // 物件．住所２（番地）
            this.addItem('Property__c.FormerSupplierPhone__c'                           , appli.Property__r.FormerSupplierPhone__c);                    // 物件．電話番号
            this.addItem('Property__c.FormerSupplierFax__c'                             , appli.Property__r.FormerSupplierFax__c);                      // 物件．FAX
            this.addItem('Property__c.FormerSupplierEmail__c'                           , appli.Property__r.FormerSupplierEmail__c);                    // 物件．メール
            this.addItem('Property__c.FormerSupplier__r.RemarksPublic__c'               , appli.Property__r.FormerSupplier__r.RemarksPublic__c);        // 物件．元付 元付業者.備考
            this.addItem('Property__c.Creditor__c.Name'                                 , appli.Property__r.Creditor__r.Name);                          // 物件．貸主
            this.addItem('Property__c.CreditorDepartment__c'                            , appli.Property__r.CreditorDepartment__c);                     // 物件．担当部署
            this.addItem('Property__c.CreditorRepresentative__c'                        , appli.Property__r.CreditorRepresentative__c);                 // 物件．担当者
            this.addItem('Property__c.CreditorRepresentativePhone__c'                   , appli.Property__r.CreditorRepresentativePhone__c);            // 物件．担当者電話番号
            this.addItem('Property__c.CreditorPostalCode__c'                            , appli.Property__r.CreditorPostalCode__c);                     // 物件．郵便番号
            this.addItem('Property__c.CreditorState__c'                                 , appli.Property__r.CreditorState__c);                          // 物件．都道府県
            this.addItem('Property__c.CreditorCity__c'                                  , appli.Property__r.CreditorCity__c);                           // 物件．住所１（市区町村）
            this.addItem('Property__c.CreditorStreet__c'                                , appli.Property__r.CreditorStreet__c);                         // 物件．住所２（番地）
            this.addItem('Property__c.CreditorPhone__c'                                 , appli.Property__r.CreditorPhone__c);                          // 物件．電話番号
            this.addItem('Property__c.CreditorFax__c'                                   , appli.Property__r.CreditorFax__c);                            // 物件．FAX
            this.addItem('Property__c.CreditorEmail__c'                                 , appli.Property__r.CreditorEmail__c);                          // 物件．メール
            this.addItem('Property__c.Creditor__r.RemarksPublic__c'                     , appli.Property__r.Creditor__r.RemarksPublic__c);              // 物件．貸主.備考
            this.addItem('Property__c.Owner__c.Name'                                    , appli.Property__r.Owner__r.Name);                             // 物件．所有者
            this.addItem('Property__c.OwnerDepartment__c'                               , appli.Property__r.OwnerDepartment__c);                        // 物件．担当部署
            this.addItem('Property__c.OwnerRepresentative__c'                           , appli.Property__r.OwnerRepresentative__c);                    // 物件．担当者
            this.addItem('Property__c.OwnerRepresentativePhone__c'                      , appli.Property__r.OwnerRepresentativePhone__c);               // 物件．担当者電話番号
            this.addItem('Property__c.OwnerPostalCode__c'                               , appli.Property__r.OwnerPostalCode__c);                        // 物件．郵便番号
            this.addItem('Property__c.OwnerState__c'                                    , appli.Property__r.OwnerState__c);                             // 物件．都道府県
            this.addItem('Property__c.OwnerCity__c'                                     , appli.Property__r.OwnerCity__c);                              // 物件．住所１（市区町村）
            this.addItem('Property__c.OwnerStreet__c'                                   , appli.Property__r.OwnerStreet__c);                            // 物件．住所２（番地）
            this.addItem('Property__c.OwnerPhone__c'                                    , appli.Property__r.OwnerPhone__c);                             // 物件．電話番号
            this.addItem('Property__c.OwnerFax__c'                                      , appli.Property__r.OwnerFax__c);                               // 物件．FAX
            this.addItem('Property__c.OwnerEmail__c'                                    , appli.Property__r.OwnerEmail__c);                             // 物件．メール     
            this.addItem('Property__c.Owner__r.RemarksPublic__c'                        , appli.Property__r.Owner__r.RemarksPublic__c);                 // 物件．所有者.備考
            // 物件条件
            Map<String, Schema.SObjectField> propCondFieldMap = Schema.getGlobalDescribe().get('PropertyConditions__c').getDescribe().fields.getMap();
            propCondFieldMap.get('IsMaisonette__c').getDescribe().getLabel();
            this.addItem('PropertyConditions__c.IsMaisonette__c'                    , propCond.IsMaisonette__c                      , propCondFieldMap  , 'IsMaisonette__c'                 );  // メゾネット
            this.addItem('PropertyConditions__c.IsLoft__c'                          , propCond.IsLoft__c                            , propCondFieldMap  , 'IsLoft__c'                       );  // ロフト
            this.addItem('PropertyConditions__c.IsDesigners__c'                     , propCond.IsDesigners__c                       , propCondFieldMap  , 'IsDesigners__c'                  );  // デザイナーズ
            this.addItem('PropertyConditions__c.IsCondominiumRental__c'             , propCond.IsCondominiumRental__c               , propCondFieldMap  , 'IsCondominiumRental__c'          );  // 分譲賃貸
            this.addItem('PropertyConditions__c.IsAllWesternStyleRoom__c'           , propCond.IsAllWesternStyleRoom__c             , propCondFieldMap  , 'IsAllWesternStyleRoom__c'        );  // オール洋間
            this.addItem('PropertyConditions__c.IsTowerMansion__c'                  , propCond.IsTowerMansion__c                    , propCondFieldMap  , 'IsTowerMansion__c'               );  // タワーマンション
            this.addItem('PropertyConditions__c.IsBarrierFree__c'                   , propCond.IsBarrierFree__c                     , propCondFieldMap  , 'IsBarrierFree__c'                );  // バリアフリー
            this.addItem('PropertyConditions__c.IsOuterWallTile__c'                 , propCond.IsOuterWallTile__c                   , propCondFieldMap  , 'IsOuterWallTile__c'              );  // 外壁タイル張り
            this.addItem('PropertyConditions__c.IsDampingStructure__c'              , propCond.IsDampingStructure__c                , propCondFieldMap  , 'IsDampingStructure__c'           );  // 制震構造
            this.addItem('PropertyConditions__c.IsSeismicStructure__c'              , propCond.IsSeismicStructure__c                , propCondFieldMap  , 'IsSeismicStructure__c'           );  // 耐震構造
            this.addItem('PropertyConditions__c.IsSeismicIsolationStructure__c'     , propCond.IsSeismicIsolationStructure__c       , propCondFieldMap  , 'IsSeismicIsolationStructure__c'  );  // 免震構造
            this.addItem('PropertyConditions__c.IsUndergroundRoom__c'               , propCond.IsUndergroundRoom__c                 , propCondFieldMap  , 'IsUndergroundRoom__c'            );  // 地下室
            this.addItem('PropertyConditions__c.IsSoundproofRoom__c'                , propCond.IsSoundproofRoom__c                  , propCondFieldMap  , 'IsSoundproofRoom__c'             );  // 防音室
            this.addItem('PropertyConditions__c.IsSepticTank__c'                    , propCond.IsSepticTank__c                      , propCondFieldMap  , 'IsSepticTank__c'                 );  // 浄化槽
            this.addItem('PropertyConditions__c.IsQuietResidenceTown__c'            , propCond.IsQuietResidenceTown__c              , propCondFieldMap  , 'IsQuietResidenceTown__c'         );  // 閑静な住宅街
            this.addItem('PropertyConditions__c.IsCornerRoom__c'                    , propCond.IsCornerRoom__c                      , propCondFieldMap  , 'IsCornerRoom__c'                 );  // 角部屋
            this.addItem('PropertyConditions__c.IsBayWindow__c'                     , propCond.IsBayWindow__c                       , propCondFieldMap  , 'IsBayWindow__c'                  );  // 出窓
            this.addItem('PropertyConditions__c.IsPrivateGarden__c'                 , propCond.IsPrivateGarden__c                   , propCondFieldMap  , 'IsPrivateGarden__c'              );  // 専用庭
            this.addItem('PropertyConditions__c.IsBalcony__c'                       , propCond.IsBalcony__c                         , propCondFieldMap  , 'IsBalcony__c'                    );  // バルコニー
            this.addItem('PropertyConditions__c.IsRoofBalcony__c'                   , propCond.IsRoofBalcony__c                     , propCondFieldMap  , 'IsRoofBalcony__c'                );  // ルーフバルコニー
            this.addItem('PropertyConditions__c.IsWoodDeck__c'                      , propCond.IsWoodDeck__c                        , propCondFieldMap  , 'IsWoodDeck__c'                   );  // ウッドデッキ
            this.addItem('PropertyConditions__c.IsBuiltInGarage__c'                 , propCond.IsBuiltInGarage__c                   , propCondFieldMap  , 'IsBuiltInGarage__c'              );  // ビルトインガレージ
            this.addItem('PropertyConditions__c.IsCarport__c'                       , propCond.IsCarport__c                         , propCondFieldMap  , 'IsCarport__c'                    );  // カーポート
            this.addItem('PropertyConditions__c.IsElevator__c'                      , propCond.IsElevator__c                        , propCondFieldMap  , 'IsElevator__c'                   );  // エレベーター
            this.addItem('PropertyConditions__c.IsPluralElevators__c'               , propCond.IsPluralElevators__c                 , propCondFieldMap  , 'IsPluralElevators__c'            );  // エレベーター2基
            this.addItem('PropertyConditions__c.IsInSiteTtrashArea__c'              , propCond.IsInSiteTtrashArea__c                , propCondFieldMap  , 'IsInSiteTtrashArea__c'           );  // 敷地内ゴミ置場
            this.addItem('PropertyConditions__c.IsAnytimeTtrashArea__c'             , propCond.IsAnytimeTtrashArea__c               , propCondFieldMap  , 'IsAnytimeTtrashArea__c'          );  // 24時間ゴミ出し可
            this.addItem('PropertyConditions__c.IsFrontService__c'                  , propCond.IsFrontService__c                    , propCondFieldMap  , 'IsFrontService__c'               );  // フロントサービス
            this.addItem('PropertyConditions__c.IsDeliveryBox__c'                   , propCond.IsDeliveryBox__c                     , propCondFieldMap  , 'IsDeliveryBox__c'                );  // 宅配ボックス
            this.addItem('PropertyConditions__c.IsCleaningBox__c'                   , propCond.IsCleaningBox__c                     , propCondFieldMap  , 'IsCleaningBox__c'                );  // クリーニングボックス
            this.addItem('PropertyConditions__c.IsCoinLaundry__c'                   , propCond.IsCoinLaundry__c                     , propCondFieldMap  , 'IsCoinLaundry__c'                );  // コインランドリー
            this.addItem('PropertyConditions__c.IsCounterKitchen__c'                , propCond.IsCounterKitchen__c                  , propCondFieldMap  , 'IsCounterKitchen__c'             );  // カウンターキッチン
            this.addItem('PropertyConditions__c.IsSystemKitchen__c'                 , propCond.IsSystemKitchen__c                   , propCondFieldMap  , 'IsSystemKitchen__c'              );  // システムキッチン
            this.addItem('PropertyConditions__c.IsGasStove__c'                      , propCond.IsGasStove__c                        , propCondFieldMap  , 'IsGasStove__c'                   );  // ガスコンロ
            this.addItem('PropertyConditions__c.IsElectricStove__c'                 , propCond.IsElectricStove__c                   , propCondFieldMap  , 'IsElectricStove__c'              );  // 電気コンロ
            this.addItem('PropertyConditions__c.IsIhStove__c'                       , propCond.IsIhStove__c                         , propCondFieldMap  , 'IsIhStove__c'                    );  // IHコンロ
            this.addItem('PropertyConditions__c.IsTwoGasStove__c'                   , propCond.IsTwoGasStove__c                     , propCondFieldMap  , 'IsTwoGasStove__c'                );  // コンロ2口
            this.addItem('PropertyConditions__c.IsMoreGasStove__c'                  , propCond.IsMoreGasStove__c                    , propCondFieldMap  , 'IsMoreGasStove__c'               );  // コンロ3口以上
            this.addItem('PropertyConditions__c.IsWaterPurifier__c'                 , propCond.IsWaterPurifier__c                   , propCondFieldMap  , 'IsWaterPurifier__c'              );  // 浄水器
            this.addItem('PropertyConditions__c.IsDishwasher__c'                    , propCond.IsDishwasher__c                      , propCondFieldMap  , 'IsDishwasher__c'                 );  // 食器洗い乾燥機
            this.addItem('PropertyConditions__c.IsDisposer__c'                      , propCond.IsDisposer__c                        , propCondFieldMap  , 'IsDisposer__c'                   );  // ディスポーザー
            this.addItem('PropertyConditions__c.IsSeparate__c'                      , propCond.IsSeparate__c                        , propCondFieldMap  , 'IsSeparate__c'                   );  // バス・トイレ別
            this.addItem('PropertyConditions__c.IsReheating__c'                     , propCond.IsReheating__c                       , propCondFieldMap  , 'IsReheating__c'                  );  // 追焚機能
            this.addItem('PropertyConditions__c.IsHotWaterFormula__c'               , propCond.IsHotWaterFormula__c                 , propCondFieldMap  , 'IsHotWaterFormula__c'            );  // 高温差湯式
            this.addItem('PropertyConditions__c.IsBathroomDryer__c'                 , propCond.IsBathroomDryer__c                   , propCondFieldMap  , 'IsBathroomDryer__c'              );  // 浴室乾燥機
            this.addItem('PropertyConditions__c.IsBathroomFloorHeating__c'          , propCond.IsBathroomFloorHeating__c            , propCondFieldMap  , 'IsBathroomFloorHeating__c'       );  // 浴室床暖房
            this.addItem('PropertyConditions__c.IsTvBath__c'                        , propCond.IsTvBath__c                          , propCondFieldMap  , 'IsTvBath__c'                     );  // TV付浴槽
            this.addItem('PropertyConditions__c.IsWashletToiletSeat__c'             , propCond.IsWashletToiletSeat__c               , propCondFieldMap  , 'IsWashletToiletSeat__c'          );  // 温水洗浄便座
            this.addItem('PropertyConditions__c.IsTanklessToilet__c'                , propCond.IsTanklessToilet__c                  , propCondFieldMap  , 'IsTanklessToilet__c'             );  // タンクレストイレ
            this.addItem('PropertyConditions__c.IsWashroomDscrete__c'               , propCond.IsWashroomDscrete__c                 , propCondFieldMap  , 'IsWashroomDscrete__c'            );  // 洗面所独立
            this.addItem('PropertyConditions__c.IsShowerWashBasin__c'               , propCond.IsShowerWashBasin__c                 , propCondFieldMap  , 'IsShowerWashBasin__c'            );  // シャワー付き洗面台
            this.addItem('PropertyConditions__c.IsShowerRoom__c'                    , propCond.IsShowerRoom__c                      , propCondFieldMap  , 'IsShowerRoom__c'                 );  // シャワールーム
            this.addItem('PropertyConditions__c.IsMistSauna__c'                     , propCond.IsMistSauna__c                       , propCondFieldMap  , 'IsMistSauna__c'                  );  // ミストサウナ
            this.addItem('PropertyConditions__c.IsIndoorWashingMachineStorage__c'   , propCond.IsIndoorWashingMachineStorage__c     , propCondFieldMap  , 'IsIndoorWashingMachineStorage__c');  // 室内洗濯機置場
            this.addItem('PropertyConditions__c.IsCityGas__c'                       , propCond.IsCityGas__c                         , propCondFieldMap  , 'IsCityGas__c'                    );  // 都市ガス
            this.addItem('PropertyConditions__c.IsPropaneGas__c'                    , propCond.IsPropaneGas__c                      , propCondFieldMap  , 'IsPropaneGas__c'                 );  // プロパンガス
            this.addItem('PropertyConditions__c.IsAllElectric__c'                   , propCond.IsAllElectric__c                     , propCondFieldMap  , 'IsAllElectric__c'                );  // オール電化
            this.addItem('PropertyConditions__c.IsAirConditioner__c'                , propCond.IsAirConditioner__c                  , propCondFieldMap  , 'IsAirConditioner__c'             );  // エアコン
            this.addItem('PropertyConditions__c.IsFloorHeating__c'                  , propCond.IsFloorHeating__c                    , propCondFieldMap  , 'IsFloorHeating__c'               );  // 床暖房
            this.addItem('PropertyConditions__c.IsGasHeating__c'                    , propCond.IsGasHeating__c                      , propCondFieldMap  , 'IsGasHeating__c'                 );  // ガス暖房
            this.addItem('PropertyConditions__c.IsKeroseneHeating__c'               , propCond.IsKeroseneHeating__c                 , propCondFieldMap  , 'IsKeroseneHeating__c'            );  // 灯油暖房
            this.addItem('PropertyConditions__c.IsFurniture__c'                     , propCond.IsFurniture__c                       , propCondFieldMap  , 'IsFurniture__c'                  );  // 家具付き
            this.addItem('PropertyConditions__c.IsHomeAppliance__c'                 , propCond.IsHomeAppliance__c                   , propCondFieldMap  , 'IsHomeAppliance__c'              );  // 家電付き
            this.addItem('PropertyConditions__c.IsWashingDryer__c'                  , propCond.IsWashingDryer__c                    , propCondFieldMap  , 'IsWashingDryer__c'               );  // 洗濯乾燥機
            this.addItem('PropertyConditions__c.IsFlooring__c'                      , propCond.IsFlooring__c                        , propCondFieldMap  , 'IsFlooring__c'                   );  // フローリング
            this.addItem('PropertyConditions__c.IsCushionFloor__c'                  , propCond.IsCushionFloor__c                    , propCondFieldMap  , 'IsCushionFloor__c'               );  // クッションフロア
            this.addItem('PropertyConditions__c.IsSolidWood__c'                     , propCond.IsSolidWood__c                       , propCondFieldMap  , 'IsSolidWood__c'                  );  // 無垢材使用
            this.addItem('PropertyConditions__c.IsStormShutter__c'                  , propCond.IsStormShutter__c                    , propCondFieldMap  , 'IsStormShutter__c'               );  // 雨戸
            this.addItem('PropertyConditions__c.IsShutter__c'                       , propCond.IsShutter__c                         , propCondFieldMap  , 'IsShutter__c'                    );  // シャッター
            this.addItem('PropertyConditions__c.IsElectricShutter__c'               , propCond.IsElectricShutter__c                 , propCondFieldMap  , 'IsElectricShutter__c'            );  // 電動シャッター
            this.addItem('PropertyConditions__c.IsHighSash__c'                      , propCond.IsHighSash__c                        , propCondFieldMap  , 'IsHighSash__c'                   );  // ハイサッシ
            this.addItem('PropertyConditions__c.IsSoundproofSash__c'                , propCond.IsSoundproofSash__c                  , propCondFieldMap  , 'IsSoundproofSash__c'             );  // 防音サッシ
            this.addItem('PropertyConditions__c.IsPairGlass__c'                     , propCond.IsPairGlass__c                       , propCondFieldMap  , 'IsPairGlass__c'                  );  // 複層ガラス
            this.addItem('PropertyConditions__c.IsShoesBox__c'                      , propCond.IsShoesBox__c                        , propCondFieldMap  , 'IsShoesBox__c'                   );  // シューズボックス
            this.addItem('PropertyConditions__c.IsShoeCloak__c'                     , propCond.IsShoeCloak__c                       , propCondFieldMap  , 'IsShoeCloak__c'                  );  // シューズクローク
            this.addItem('PropertyConditions__c.IsWalkInCloset__c'                  , propCond.IsWalkInCloset__c                    , propCondFieldMap  , 'IsWalkInCloset__c'               );  // ウォークインクローゼット
            this.addItem('PropertyConditions__c.IsTrunkRoom__c'                     , propCond.IsTrunkRoom__c                       , propCondFieldMap  , 'IsTrunkRoom__c'                  );  // トランクルーム
            this.addItem('PropertyConditions__c.IsUnderfloorStorage__c'             , propCond.IsUnderfloorStorage__c               , propCondFieldMap  , 'IsUnderfloorStorage__c'          );  // 床下収納
            this.addItem('PropertyConditions__c.IsBSAntenna__c'                     , propCond.IsBSAntenna__c                       , propCondFieldMap  , 'IsBSAntenna__c'                  );  // BSアンテナ
            this.addItem('PropertyConditions__c.IsCSAntenna__c'                     , propCond.IsCSAntenna__c                       , propCondFieldMap  , 'IsCSAntenna__c'                  );  // CSアンテナ
            this.addItem('PropertyConditions__c.IsCATV__c'                          , propCond.IsCATV__c                            , propCondFieldMap  , 'IsCATV__c'                       );  // CATV
            this.addItem('PropertyConditions__c.IsCATVInternet__c'                  , propCond.IsCATVInternet__c                    , propCondFieldMap  , 'IsCATVInternet__c'               );  // CATVインターネット
            this.addItem('PropertyConditions__c.IsCATVFree__c'                      , propCond.IsCATVFree__c                        , propCondFieldMap  , 'IsCATVFree__c'                   );  // CATV使用料不要
            this.addItem('PropertyConditions__c.IsOpticalFiber__c'                  , propCond.IsOpticalFiber__c                    , propCondFieldMap  , 'IsOpticalFiber__c'               );  // 光ファイバー
            this.addItem('PropertyConditions__c.IsInternetFree__c'                  , propCond.IsInternetFree__c                    , propCondFieldMap  , 'IsInternetFree__c'               );  // ネット使用料無料
            this.addItem('PropertyConditions__c.IsMonitorIntercom__c'               , propCond.IsMonitorIntercom__c                 , propCondFieldMap  , 'IsMonitorIntercom__c'            );  // モニター付きインターホン
            this.addItem('PropertyConditions__c.IsAutoLock__c'                      , propCond.IsAutoLock__c                        , propCondFieldMap  , 'IsAutoLock__c'                   );  // オートロック
            this.addItem('PropertyConditions__c.IsDimpleKey__c'                     , propCond.IsDimpleKey__c                       , propCondFieldMap  , 'IsDimpleKey__c'                  );  // ディンプルキー
            this.addItem('PropertyConditions__c.IsSurveillanceCamera__c'            , propCond.IsSurveillanceCamera__c              , propCondFieldMap  , 'IsSurveillanceCamera__c'         );  // 防犯カメラ
            this.addItem('PropertyConditions__c.IsSecurityGlass__c'                 , propCond.IsSecurityGlass__c                   , propCondFieldMap  , 'IsSecurityGlass__c'              );  // 防犯ガラス
            this.addItem('PropertyConditions__c.IsAnytimeSecurity__c'               , propCond.IsAnytimeSecurity__c                 , propCondFieldMap  , 'IsAnytimeSecurity__c'            );  // 24時間セキュリティ
            this.addItem('PropertyConditions__c.IsSecurityCompanyJoin__c'           , propCond.IsSecurityCompanyJoin__c             , propCondFieldMap  , 'IsSecurityCompanyJoin__c'        );  // セキュリティ会社加入済
            this.addItem('PropertyConditions__c.IsNoGuarantor__c'                   , propCond.IsNoGuarantor__c                     , propCondFieldMap  , 'IsNoGuarantor__c'                );  // 保証人不要
            this.addItem('PropertyConditions__c.IsMusicalInstruments__c'            , propCond.IsMusicalInstruments__c              , propCondFieldMap  , 'IsMusicalInstruments__c'         );  // 楽器相談可
            this.addItem('PropertyConditions__c.IsForeigner__c'                     , propCond.IsForeigner__c                       , propCondFieldMap  , 'IsForeigner__c'                  );  // 外国人契約可
            this.addItem('PropertyConditions__c.IsWelfareAvailable__c'              , propCond.IsWelfareAvailable__c                , propCondFieldMap  , 'IsWelfareAvailable__c'           );  // 生活保護契約可
            this.addItem('PropertyConditions__c.IsOfficeAvailable__c'               , propCond.IsOfficeAvailable__c                 , propCondFieldMap  , 'IsOfficeAvailable__c'            );  // 事務所利用可
            this.addItem('PropertyConditions__c.IsPet__c'                           , propCond.IsPet__c                             , propCondFieldMap  , 'IsPet__c'                        );  // ペット可
            this.addItem('PropertyConditions__c.IsSmallPet__c'                      , propCond.IsSmallPet__c                        , propCondFieldMap  , 'IsSmallPet__c'                   );  // ペット(小型犬)
            this.addItem('PropertyConditions__c.IsMiddlePet__c'                     , propCond.IsMiddlePet__c                       , propCondFieldMap  , 'IsMiddlePet__c'                  );  // ペット(中型犬)
            this.addItem('PropertyConditions__c.IsLargePet__c'                      , propCond.IsLargePet__c                        , propCondFieldMap  , 'IsLargePet__c'                   );  // ペット(大型犬)
            this.addItem('PropertyConditions__c.IsCat__c'                           , propCond.IsCat__c                             , propCondFieldMap  , 'IsCat__c'                        );  // ペット(猫)
            this.addItem('PropertyConditions__c.IsOtherPet__c'                      , propCond.IsOtherPet__c                        , propCondFieldMap  , 'IsOtherPet__c'                   );  // ペット(その他)
            this.addItem('PropertyConditions__c.IsTwoTenant__c'                     , propCond.IsTwoTenant__c                       , propCondFieldMap  , 'IsTwoTenant__c'                  );  // 2人入居可
            this.addItem('PropertyConditions__c.IsRoomShare__c'                     , propCond.IsRoomShare__c                       , propCondFieldMap  , 'IsRoomShare__c'                  );  // ルームシェア可
            this.addItem('PropertyConditions__c.IsMonthly__c'                       , propCond.IsMonthly__c                         , propCondFieldMap  , 'IsMonthly__c'                    );  // マンスリー可
            this.addItem('PropertyConditions__c.IsCustomize__c'                     , propCond.IsCustomize__c                       , propCondFieldMap  , 'IsCustomize__c'                  );  // カスタマイズ可
            this.addItem('PropertyConditions__c.IsDIY__c'                           , propCond.IsDIY__c                             , propCondFieldMap  , 'IsDIY__c'                        );  // DIY可
            this.addItem('PropertyConditions__c.IsITImportantDescription__c'        , propCond.IsITImportantDescription__c          , propCondFieldMap  , 'IsITImportantDescription__c'     );  // IT重説対応物件
            this.addItem('PropertyConditions__c.IsRentCreditPayment__c'             , propCond.IsRentCreditPayment__c               , propCondFieldMap  , 'IsRentCreditPayment__c'          );  // 家賃カード決済可
            this.addItem('PropertyConditions__c.IsInitialCostCreditPayment__c'      , propCond.IsInitialCostCreditPayment__c        , propCondFieldMap  , 'IsInitialCostCreditPayment__c'   );  // 初期費用カード決済可
            this.addItem('PropertyConditions__c.IsWoman__c'                         , propCond.IsWoman__c                           , propCondFieldMap  , 'IsWoman__c'                      );  // 女性限定
            this.addItem('PropertyConditions__c.IsStudent__c'                       , propCond.IsStudent__c                         , propCondFieldMap  , 'IsStudent__c'                    );  // 学生限定
            this.addItem('PropertyConditions__c.IsCorporation__c'                   , propCond.IsCorporation__c                     , propCondFieldMap  , 'IsCorporation__c'                );  // 法人契約限定
            this.addItem('PropertyConditions__c.IsElderly__c'                       , propCond.IsElderly__c                         , propCondFieldMap  , 'IsElderly__c'                    );  // 高齢者歓迎
            this.addItem('PropertyConditions__c.IsLbgt__c'                          , propCond.IsLbgt__c                            , propCondFieldMap  , 'IsLbgt__c'                       );  // LGBTフレンドリー
            this.addItem('PropertyConditions__c.IsNotChild__c'                      , propCond.IsNotChild__c                        , propCondFieldMap  , 'IsNotChild__c'                   );  // 子供不可
            this.addItem('PropertyConditions__c.IsTwoStation__c'                    , propCond.IsTwoStation__c                      , propCondFieldMap  , 'IsTwoStation__c'                 );  // 2駅利用可
            this.addItem('PropertyConditions__c.IsTwoTrainRoute__c'                 , propCond.IsTwoTrainRoute__c                   , propCondFieldMap  , 'IsTwoTrainRoute__c'              );  // 2沿線利用可
            this.addItem('PropertyConditions__c.IsThreeStation__c'                  , propCond.IsThreeStation__c                    , propCondFieldMap  , 'IsThreeStation__c'               );  // 3駅以上利用可
            this.addItem('PropertyConditions__c.IsThreeTrainRoute__c'               , propCond.IsThreeTrainRoute__c                 , propCondFieldMap  , 'IsThreeTrainRoute__c'            );  // 3沿線以上利用可
            this.addItem('PropertyConditions__c.IsFrontStation__c'                  , propCond.IsFrontStation__c                    , propCondFieldMap  , 'IsFrontStation__c'               );  // 駅前
            this.addItem('PropertyConditions__c.IsParking__c'                       , propCond.IsParking__c                         , propCondFieldMap  , 'IsParking__c'                    );  // 駐車場空きあり
            this.addItem('PropertyConditions__c.IsInSiteParking__c'                 , propCond.IsInSiteParking__c                   , propCondFieldMap  , 'IsInSiteParking__c'              );  // 敷地内駐車場
            this.addItem('PropertyConditions__c.IsBikeStorage__c'                   , propCond.IsBikeStorage__c                     , propCondFieldMap  , 'IsBikeStorage__c'                );  // バイク可
            this.addItem('PropertyConditions__c.IsSmallBike__c'                     , propCond.IsSmallBike__c                       , propCondFieldMap  , 'IsSmallBike__c'                  );  // 小型バイク
            this.addItem('PropertyConditions__c.IsMediumBike__c'                    , propCond.IsMediumBike__c                      , propCondFieldMap  , 'IsMediumBike__c'                 );  // 中型バイク
            this.addItem('PropertyConditions__c.IsLargeBike__c'                     , propCond.IsLargeBike__c                       , propCondFieldMap  , 'IsLargeBike__c'                  );  // 大型バイク
            this.addItem('PropertyConditions__c.IsFirstFloor__c'                    , propCond.IsFirstFloor__c                      , propCondFieldMap  , 'IsFirstFloor__c'                 );  // 1階
            this.addItem('PropertyConditions__c.IsSecondFloorOver__c'               , propCond.IsSecondFloorOver__c                 , propCondFieldMap  , 'IsSecondFloorOver__c'            );  // 2階以上
            this.addItem('PropertyConditions__c.IsTopFloor__c'                      , propCond.IsTopFloor__c                        , propCondFieldMap  , 'IsTopFloor__c'                   );  // 最上階
            this.addItem('PropertyConditions__c.IsSouth__c'                         , propCond.IsSouth__c                           , propCondFieldMap  , 'IsSouth__c'                      );  // 南向き
            this.addItem('PropertyConditions__c.IsJanitor__c'                       , propCond.IsJanitor__c                         , propCondFieldMap  , 'IsJanitor__c'                    );  // 管理人有
            this.addItem('PropertyConditions__c.IsJanitorReside__c'                 , propCond.IsJanitorReside__c                   , propCondFieldMap  , 'IsJanitorReside__c'              );  // 管理人(常駐)
            this.addItem('PropertyConditions__c.IsJanitorCommuter__c'               , propCond.IsJanitorCommuter__c                 , propCondFieldMap  , 'IsJanitorCommuter__c'            );  // 管理人(通勤)
            this.addItem('PropertyConditions__c.IsJanitorPatrol__c'                 , propCond.IsJanitorPatrol__c                   , propCondFieldMap  , 'IsJanitorPatrol__c'              );  // 管理人(巡回)
            this.addItem('PropertyConditions__c.IsTurnkey__c'                       , propCond.IsTurnkey__c                         , propCondFieldMap  , 'IsTurnkey__c'                    );  // 即入居可
            this.addItem('PropertyConditions__c.IsNotFixedTermTenant__c'            , propCond.IsNotFixedTermTenant__c              , propCondFieldMap  , 'IsNotFixedTermTenant__c'         );  // 定期借家を含まない
            this.addItem('PropertyConditions__c.IsPluralCarParking__c'              , propCond.IsPluralCarParking__c                , propCondFieldMap  , 'IsPluralCarParking__c'           );  // 駐車場2台可
            this.addItem('PropertyConditions__c.IsBicycleParking__c'                , propCond.IsBicycleParking__c                  , propCondFieldMap  , 'IsBicycleParking__c'             );  // 駐輪場
            this.addItem('PropertyConditions__c.IsRenovation__c'                    , propCond.IsRenovation__c                      , propCondFieldMap  , 'IsRenovation__c'                 );  // リノベーション
            this.addItem('PropertyConditions__c.IsFreeRent__c'                      , propCond.IsFreeRent__c                        , propCondFieldMap  , 'IsFreeRent__c'                   );  // フリーレント
            this.addItem('PropertyConditions__c.IsSpecialRent__c'                   , propCond.IsSpecialRent__c                     , propCondFieldMap  , 'IsSpecialRent__c'                );  // 特定優良賃貸住宅
            this.addItem('PropertyConditions__c.FacilityRemarksPublic__c'           , propCond.FacilityRemarksPublic__c);                               // 設備備考（公開）
            this.addItem('PropertyConditions__c.ContractRemarks__c'                 , propCond.ContractRemarks__c);                                     // 契約備考
            // 商品（火災保険）
            this.addItem('Item__c.FireInsuranceMonth__c'                                , item.FireInsuranceMonth__c);                                  // 火災保険料(月額)
            this.addItem('Item__c.FireInsuranceYear__c'                                 , item.FireInsuranceYear__c);                                   // 火災保険料(年額)
            this.addItem('Item__c.PaymentType__c'                                       , item.PaymentType__c);                                         // 更新期間
            // 部屋（1～10）
            for (Integer i = 1; i <= 10; i++) {
                if (roomList.size() >= i) {
                    this.addItem('Room__c' + i + '.RoomType__c'                         , roomList[i-1].RoomType__c);                                   // 部屋タイプ
                    this.addItem('Room__c' + i + '.RoomFloorSpace__c'                   , roomList[i-1].RoomFloorSpace__c);                             // 部屋帖数
                } else {
                    this.addItem('Room__c' + i + '.RoomType__c'                         , '');                                                          // 部屋タイプ
                    this.addItem('Room__c' + i + '.RoomFloorSpace__c'                   , '');                                                          // 部屋帖数
                }
            }
            // 申込
            this.addItem('Property__c.Name'                                             , appli.Property__r.Name);                                      // 物件．部屋番号
            this.addItem('Application__c.Address__c'                                    , appli.Address__c);                                            // 住所
            this.addItem('Application__c.Rent__c'                                       , appli.Rent__c);                                               // 家賃
            this.addItem('Application__c.ManagementFee__c'                              , appli.ManagementFee__c);                                      // 共益費
            this.addItem('Application__c.ParkingFee__c'                                 , appli.ParkingFee__c);                                         // 駐車場
            this.addItem('Application__c.SecurityDeposit__c'                            , appli.SecurityDeposit__c);                                    // 敷金
            this.addItem('Application__c.KeyMoney__c'                                   , appli.KeyMoney__c);                                           // 礼金
            this.addItem('Application__c.Deposit__c'                                    , appli.Deposit__c);                                            // 保証料金
            this.addItem('Application__c.TownshipAdmissionFee__c'                       , appli.TownshipAdmissionFee__c);                               // 町会入会金
            this.addItem('Application__c.TownshipFee__c'                                , appli.TownshipFee__c);                                        // 町会費
            this.addItem('Application__c.CATV__c'                                       , appli.CATV__c);                                               // CATV
            this.addItem('Application__c.WortFee__c'                                    , appli.WortFee__c);                                            // 水道料金
            this.addItem('Application__c.ActualFee__c'                                  , appli.ActualFee__c);                                          // 償却
            this.addItem('Application__c.SpecialContract__c'                            , appli.SpecialContract__c);                                    // 特約
            this.addItem('Application__c.ApplicationDate__c'                            , appli.ApplicationDate__c);                                    // 申込日
            this.addItem('Application__c.TenantDesiredDate__c'                          , appli.TenantDesiredDate__c);                                  // 入居希望日
            this.addItem('Application__c.LastNameKana__c'                               , appli.LastNameKana__c);                                       // 姓（カナ）
            this.addItem('Application__c.FirstNameKana__c'                              , appli.FirstNameKana__c);                                      // 名（カナ）
            this.addItem('Application__c.LastName__c'                                   , appli.LastName__c);                                           // 姓
            this.addItem('Application__c.FirstName__c'                                  , appli.FirstName__c);                                          // 名
            this.addItem('Application__c.Age__c'                                        , appli.Age__c);                                                // 年齢
            this.addItem('Application__c.Birthdate__c'                                  , appli.Birthdate__c);                                          // 生年月日
            this.addItem('Application__c.Current__c'                                    , appli.Current__c);                                            // 郵便番号
            this.addItem('Application__c.CurrentState__c'                               , appli.CurrentState__c);                                       // 現住所　都道府県
            this.addItem('Application__c.CurrentCity__c'                                , appli.CurrentCity__c);                                        // 現住所１（市区町村）
            this.addItem('Application__c.CurrentStreet__c'                              , appli.CurrentStreet__c);                                      // 現住所２（番地）
            this.addItem('Application__c.CurrentPhone__c'                               , appli.CurrentPhone__c);                                       // 電話番号
            this.addItem('Application__c.CurrentMobilePhone__c'                         , appli.CurrentMobilePhone__c);                                 // 携帯番号
            this.addItem('Application__c.Affiliation__c'                                , appli.Affiliation__c);                                        // 勤務先
            this.addItem('Application__c.AffiliationState__c'                           , appli.AffiliationState__c);                                   // 都道府県
            this.addItem('Application__c.AffiliationCity__c'                            , appli.AffiliationCity__c);                                    // 住所１（市区町村）
            this.addItem('Application__c.AffiliationStreet__c'                          , appli.AffiliationStreet__c);                                  // 住所２（番地）
            this.addItem('Application__c.AffiliationPhone__c'                           , appli.AffiliationPhone__c);                                   // 電話番号
            this.addItem('Application__c.Industries__c'                                 , appli.Industries__c);                                         // 業種
            this.addItem('Application__c.JobType__c'                                    , appli.JobType__c);                                            // 職種
            this.addItem('Application__c.Department__c'                                 , appli.Department__c);                                         // 部署
            this.addItem('Application__c.Post__c'                                       , appli.Post__c);                                               // 役職
            this.addItem('Application__c.AnnualIncome__c'                               , appli.AnnualIncome__c);                                       // 年収
            this.addItem('Application__c.ContinuedServiceYearsYear__c'                  , appli.ContinuedServiceYearsYear__c);                          // 勤続年数（年）
            this.addItem('Application__c.ContinuedServiceYearsMonth__c'                 , appli.ContinuedServiceYearsMonth__c);                         // 勤続年数（月）
            this.addItem('Application__c.IsSpouse__c'                                   , appli.IsSpouse__c);                                           // 配偶者有無
            this.addItem('Application__c.ChildrenCount__c'                              , appli.ChildrenCount__c);                                      // 子供
            this.addItem('Application__c.ResidenceTermYear__c'                          , appli.ResidenceTermYear__c);                                  // 住居期間（年）
            this.addItem('Application__c.ResidenceTermMonth__c'                         , appli.ResidenceTermMonth__c);                                 // 住居期間（月）
            this.addItem('Application__c.ResidenceType__c'                              , appli.ResidenceType__c);                                      // 住居種別
            this.addItem('Application__c.CompanyNameKana__c'                            , appli.CompanyNameKana__c);                                    // 会社名（カナ）
            this.addItem('Application__c.CompanyName__c'                                , appli.CompanyName__c);                                        // 会社名
            this.addItem('Application__c.CompanyIndustries__c'                          , appli.CompanyIndustries__c);                                  // 会社 業種
            this.addItem('Application__c.CompanyPostalCode__c'                          , appli.CompanyPostalCode__c);                                  // 会社 郵便番号
            this.addItem('Application__c.CompanyState__c'                               , appli.CompanyState__c);                                       // 会社 都道府県
            this.addItem('Application__c.CompanyCity__c'                                , appli.CompanyCity__c);                                        // 会社 住所１
            this.addItem('Application__c.CompanyStreet__c'                              , appli.CompanyStreet__c);                                      // 会社 住所２
            this.addItem('Application__c.CompanyPhone__c'                               , appli.CompanyPhone__c);                                       // 会社 電話番号
            this.addItem('Application__c.CompanyFax__c'                                 , appli.CompanyFax__c);                                         // 会社 FAX
            this.addItem('Application__c.CompanyEstablishmentYear__c'                   , appli.CompanyEstablishmentYear__c);                           // 設立(年)
            this.addItem('Application__c.CompanyEstablishmentMonth__c'                  , appli.CompanyEstablishmentMonth__c);                          // 設立(月)
            this.addItem('Application__c.CompanyCapital__c'                             , appli.CompanyCapital__c);                                     // 資本金
            this.addItem('Application__c.CorporationRepresentative__c'                  , appli.CorporationRepresentative__c);                          // 担当者（法人用）
            this.addItem('Application__c.CorporationDepartment__c'                      , appli.CorporationDepartment__c);                              // 所属部署
            this.addItem('Application__c.CorporationRepresentativePhone__c'             , appli.CorporationRepresentativePhone__c);                     // 担当者（法人用）電話番号
            this.addItem('Application__c.CorporationPost__c'                            , appli.CorporationPost__c);                                    // 役職
            this.addItem('Application__c.AffiliationSchool__c'                          , appli.AffiliationSchool__c);                                  // 現在学校名
            this.addItem('Application__c.PlannedEnrollment__c'                          , appli.PlannedEnrollment__c);                                  // 入学予定校
            this.addItem('Application__c.CarMaker__c'                                   , appli.CarMaker__c);                                           // メーカー
            this.addItem('Application__c.CarType__c'                                    , appli.CarType__c);                                            // 車種
            this.addItem('Application__c.CarColor__c'                                   , appli.CarColor__c);                                           // 色
            this.addItem('Application__c.EngineSize__c'                                 , appli.EngineSize__c);                                         // 排気量（cc）
            this.addItem('Application__c.RegistNumber__c'                               , appli.RegistNumber__c);                                       // 登録ナンバー
            this.addItem('Application__c.JointGuarantorLastNameKana__c'                 , appli.JointGuarantorLastNameKana__c);                         // 連帯保証人 姓（カナ）
            this.addItem('Application__c.JointGuarantorFirstNameKana__c'                , appli.JointGuarantorFirstNameKana__c);                        // 連帯保証人 名（カナ）
            this.addItem('Application__c.JointGuarantorLastName__c'                     , appli.JointGuarantorLastName__c);                             // 連帯保証人 姓
            this.addItem('Application__c.JointGuarantorFirstName__c'                    , appli.JointGuarantorFirstName__c);                            // 連帯保証人 名
            this.addItem('Application__c.JointGuarantorAge__c'                          , appli.JointGuarantorAge__c);                                  // 連帯保証人 年齢
            this.addItem('Application__c.JointGuarantorBirthdate__c'                    , appli.JointGuarantorBirthdate__c);                            // 連帯保証人 生年月日
            this.addItem('Application__c.JointGuarantorPostalCode__c'                   , appli.JointGuarantorPostalCode__c);                           // 連帯保証人 郵便番号
            this.addItem('Application__c.JointGuarantorState__c'                        , appli.JointGuarantorState__c);                                // 連帯保証人 都道府県
            this.addItem('Application__c.JointGuarantorCity__c'                         , appli.JointGuarantorCity__c);                                 // 連帯保証人 住所１（市区町村）
            this.addItem('Application__c.JointGuarantorStreet__c'                       , appli.JointGuarantorStreet__c);                               // 連帯保証人 住所２（番地）
            this.addItem('Application__c.JointGuarantorPhone__c'                        , appli.JointGuarantorPhone__c);                                // 連帯保証人 電話番号
            this.addItem('Application__c.JointGuarantorMobilePhone__c'                  , appli.JointGuarantorMobilePhone__c);                          // 連帯保証人 携帯番号
            this.addItem('Application__c.JointGuarantorAffiliation__c'                  , appli.JointGuarantorAffiliation__c);                          // 連帯保証人 勤務先
            this.addItem('Application__c.JointGuarantorAffiliationState__c'             , appli.JointGuarantorAffiliationState__c);                     // 連帯保証人 都道府県
            this.addItem('Application__c.JointGuarantorAffiliationCity__c'              , appli.JointGuarantorAffiliationCity__c);                      // 連帯保証人 住所１（市区町村）
            this.addItem('Application__c.JointGuarantorAffiliationStreet__c'            , appli.JointGuarantorAffiliationStreet__c);                    // 連帯保証人 住所２（番地）
            this.addItem('Application__c.JointGuarantorAffiliationPhone__c'             , appli.JointGuarantorAffiliationPhone__c);                     // 連帯保証人 電話番号
            this.addItem('Application__c.JointGuarantorIndustries__c'                   , appli.JointGuarantorIndustries__c);                           // 連帯保証人 業種
            this.addItem('Application__c.JointGuarantorJobType__c'                      , appli.JointGuarantorJobType__c);                              // 連帯保証人 職種
            this.addItem('Application__c.JointGuarantorDepartment__c'                   , appli.JointGuarantorDepartment__c);                           // 連帯保証人 部署
            this.addItem('Application__c.JointGuarantorPost__c'                         , appli.JointGuarantorPost__c);                                 // 連帯保証人 役職
            this.addItem('Application__c.JointGuarantorAnnualIncome__c'                 , appli.JointGuarantorAnnualIncome__c);                         // 連帯保証人 年収
            this.addItem('Application__c.JointGuarantorContinuedServiceYearsYear__c'    , appli.JointGuarantorContinuedServiceYearsYear__c);            // 連帯保証人 勤続年数（年）
            this.addItem('Application__c.JointGuarantorContinuedServiceYearsMonth__c'   , appli.JointGuarantorContinuedServiceYearsMonth__c);           // 連帯保証人 勤続年数（月）
            this.addItem('Application__c.JointGuarantorIsSpouse__c'                     , appli.JointGuarantorIsSpouse__c);                             // 連帯保証人 配偶者有無
            this.addItem('Application__c.JointGuarantorChildrenCount__c'                , appli.JointGuarantorChildrenCount__c);                        // 連帯保証人 子供
            this.addItem('Application__c.JointGuarantorParentBrotherCount__c'           , appli.JointGuarantorParentBrotherCount__c);                   // 連帯保証人 親兄弟
            this.addItem('Application__c.JointGuarantorResidenceTermYear__c'            , appli.JointGuarantorResidenceTermYear__c);                    // 連帯保証人 住居期間（年）
            this.addItem('Application__c.JointGuarantorResidenceTermMonth__c'           , appli.JointGuarantorResidenceTermMonth__c);                   // 連帯保証人 住居期間（月）
            this.addItem('Application__c.JointGuarantorResidenceType__c'                , appli.JointGuarantorResidenceType__c);                        // 連帯保証人 住居種別
            this.addItem('Application__c.ApplicantRelationship__c'                      , appli.ApplicantRelationship__c);                              // お申込者との関係
            this.addItem('Application__c.TenantCount__c'                                , appli.TenantCount__c);                                        // 入居人数（本人含め）
            // 入居者（1～4）
            for (Integer i = 1; i <= 4; i++) {
                if (tenantList.size() >= i) {
                    this.addItem('Tenant__c' + i + '.FullNameKana__c'                   , tenantList[i-1].FullNameKana__c);                             // 氏名（カナ）
                    this.addItem('Tenant__c' + i + '.FullName__c'                       , tenantList[i-1].FullName__c);                                 // 氏名
                    this.addItem('Tenant__c' + i + '.Age__c'                            , tenantList[i-1].Age__c);                                      // 年齢
                    this.addItem('Tenant__c' + i + '.Relationship__c'                   , tenantList[i-1].Relationship__c);                             // 続柄
                    this.addItem('Tenant__c' + i + '.Birthdate__c'                      , tenantList[i-1].Birthdate__c);                                // 生年月日
                    this.addItem('Tenant__c' + i + '.JobType__c'                        , tenantList[i-1].JobType__c);                                  // 職種
                    this.addItem('Tenant__c' + i + '.Remarks__c'                        , tenantList[i-1].Remarks__c);                                  // 備考
                } else {
                    this.addItem('Tenant__c' + i + '.FullNameKana__c'                   , '');                                                          // 氏名（カナ）
                    this.addItem('Tenant__c' + i + '.FullName__c'                       , '');                                                          // 氏名
                    this.addItem('Tenant__c' + i + '.Age__c'                            , '');                                                          // 年齢
                    this.addItem('Tenant__c' + i + '.Relationship__c'                   , '');                                                          // 続柄
                    this.addItem('Tenant__c' + i + '.Birthdate__c'                      , '');                                                          // 生年月日
                    this.addItem('Tenant__c' + i + '.JobType__c'                        , '');                                                          // 職種
                    this.addItem('Tenant__c' + i + '.Remarks__c'                        , '');                                                          // 備考
                }
            }
            // 店舗
            this.addItem('Shop__c.Phone__c'                                             , shop.Phone__c);                                               // 店舗 電話番号
            this.addItem('Shop__c.Fax__c'                                               , shop.Fax__c);                                                 // 店舗 FAX
        }
        private void addItem(String header, String str) {
            String value = str;
            CsvItem item = new CsvItem(header, value);
            this.itemList.add(item);
        }
        private void addItem(String header, Decimal dec) {
            String value = dec == null ? '' : CommonUtil.decimalToString(dec).replace(',', '');
            CsvItem item = new CsvItem(header, value);
            this.itemList.add(item);
        }
        private void addItem(String header, Date d) {
            String value = d == null ? '' : Datetime.newInstance(d.year(), d.month(), d.day()).format('yyyy/MM/dd');
            CsvItem item = new CsvItem(header, value);
            this.itemList.add(item);
        }
        private void addItem(String header, DateTime dt) {
            String value = dt == null ? '' : dt.format('yyyy/MM/dd HH:mm:ss');
            CsvItem item = new CsvItem(header, value);
            this.itemList.add(item);
        }
        private void addItem(String header, Boolean bl, Map<String, Schema.SObjectField> propCondFieldMap, String fieldName) {
            String value = bl ? propCondFieldMap.get(fieldName).getDescribe().getLabel() : '';
            CsvItem item = new CsvItem(header, value);
            this.itemList.add(item);
        }
    }
    // CSV項目
    public class CsvItem {
        public String header { get; set; }  // ヘッダ
        public String value  { get; set; }  // データ内容
        public CsvItem() {
            this.header = '';
            this.value  = '';
        }
        public CsvItem(String header, String value) {
            this.header = header;
            this.value  = String.isNotEmpty(value) ? '"' + value.replace('\n', ' ') + '"' : '""';
        }
    }

    // 申込情報取得
    private Application__c selectApplication(Id targetId){
        List<Application__c> application = [
            SELECT
                Id
                ,Account__c
                ,Property__c
                ,Property__r.Building__r.BuildKana__c                               // 建物．建物名(カナ)
                ,Property__r.Building__r.Name                                       // 建物．建物名
                ,Property__r.Building__r.PropertyType__c                            // 建物．物件種別
                ,Property__r.Building__r.Structure__c                               // 建物．建物構造
                ,Property__r.Building__r.PostalCode__c                              // 建物．郵便番号
                ,Property__r.Building__r.State__c                                   // 建物．都道府県
                ,Property__r.Building__r.City__c                                    // 建物．住所１（市区町村）
                ,Property__r.Building__r.Street__c                                  // 建物．住所２（番地）
                ,Property__r.Building__r.TrainRoute1__r.Name                        // 建物．沿線１
                ,Property__r.Building__r.Station1__r.Name                           // 建物．駅１
                ,Property__r.Building__r.StationWalkTime1__c                        // 建物．駅までの時間１
                ,Property__r.Building__r.TrainRoute2__r.Name                        // 建物．沿線２
                ,Property__r.Building__r.Station2__r.Name                           // 建物．駅２
                ,Property__r.Building__r.StationWalkTime2__c                        // 建物．駅までの時間２
                ,Property__r.Building__r.TrainRoute3__r.Name                        // 建物．沿線３
                ,Property__r.Building__r.Station3__r.Name                           // 建物．駅３
                ,Property__r.Building__r.StationWalkTime3__c                        // 建物．駅までの時間３
                ,Property__r.Building__r.BusStop1__c                                // 建物．バス停
                ,Property__r.Building__r.BusRideTime1__c                            // 建物．バス乗車時間
                ,Property__r.Building__r.GroundFloorCount__c                        // 建物．地上階数
                ,Property__r.Building__r.UndergroundFloorCount__c                   // 建物．地下階数
                ,Property__r.Building__r.HouseCount__c                              // 建物．棟総戸数
                ,Property__r.Building__r.BuildingYM__c                              // 建物．築年月
                ,Property__r.Building__r.Leasehold__c                               // 建物．借地権
                ,Property__r.Building__r.Location__c                                // 建物．地勢
                ,Property__r.Building__r.CaretakerType__c                           // 建物．管理人種別
                ,Property__r.Building__r.PrimarySchool1__r.Name                     // 建物．小学校
                ,Property__r.Building__r.PrimarySchoolDistance1__c                  // 建物．小学校までの距離１
                ,Property__r.Building__r.JuniorHighSchool1__r.Name                  // 建物．中学校
                ,Property__r.Building__r.JuniorHighSchoolDistance1__c               // 建物．中学校までの距離１
                ,Property__r.Building__r.ConvenienceStoreDistance__c                // 建物．コンビニまでの距離
                ,Property__r.Building__r.SupermarketDistance__c                     // 建物．スーパーまでの距離
                ,Property__r.Building__r.GeneralHospitalDistance__c                 // 建物．総合病院までの距離
                ,Property__r.TransactionAspect__c                       // 物件．取引態様
                ,Property__r.RentFee__c                                 // 物件．賃料
                ,Property__r.DepositYen__c                              // 物件．保証料金(円)
                ,Property__r.DepositMonth__c                            // 物件．保証料金（ヶ月）
                ,Property__r.DepositUnit__c                             // 物件．保証金単位
                ,Property__r.SecurityDepositYen__c                      // 物件．敷金（円）
                ,Property__r.SecurityDepositMonth__c                    // 物件．敷金（ヶ月）
                ,Property__r.SecurityDepositUnit__c                     // 物件．敷金単位
                ,Property__r.KeyMoneyYen__c                             // 物件．礼金（円）
                ,Property__r.KeyMoneyMonth__c                           // 物件．礼金（ヶ月）
                ,Property__r.KeyMoneyUnit__c                            // 物件．礼金単位
                ,Property__r.CancellationActualFeeYen__c                // 物件．敷引・償却（円）
                ,Property__r.CancellationActualFeeMonth__c              // 物件．敷引・償却（ヶ月）
                ,Property__r.CancellationActualFeeRate__c               // 物件．敷引・償却（％）
                ,Property__r.CancellationActualFeeUnit__c               // 物件．敷引・償却単位
                ,Property__r.ManagementFeeTax__c                        // 物件．管理費（税込）
                ,Property__r.ManagementFeeTaxType__c                    // 物件．管理費税区分
                ,Property__r.RenewalFeeMonth__c                         // 物件．更新料（ヶ月）
                ,Property__r.RenewalFee__c                              // 物件．更新料（税込）
                ,Property__r.RenewalFeeUnit__c                          // 物件．更新単位
                ,Property__r.RenewalFeeTaxType__c                       // 物件．更新税区分
                ,Property__r.WortFeeTax__c                              // 物件．水道料金（税込）
                ,Property__r.WortFeeTaxType__c                          // 物件．水道料金税区分
                ,Property__r.TownshipFeeTax__c                          // 物件．町会費（税込）
                ,Property__r.TownshipFeeTaxType__c                      // 物件．町会費税区分
                ,Property__r.TownshipFeePaymentType__c                  // 物件．町会費支払区分
                ,Property__r.MonetaryPublic__c                          // 物件．金銭備考（公開）
                ,Property__r.ParkingType__c                             // 物件．駐車場種別
                ,Property__r.ParkingDepositTax__c                       // 物件．駐車場保証料金（税込）
                ,Property__r.ParkingFeeTax__c                           // 物件．駐車場料金（税込）
                ,Property__r.RoomCount__c                               // 物件．部屋数
                ,Property__r.RoomLayout__c                              // 物件．間取り
                ,Property__r.Floor__c                                   // 物件．所在階
                ,Property__r.BalconyDirection__c                        // 物件．バルコニー方向
                ,Property__r.BalconyArea__c                             // 物件．バルコニー面積
                ,Property__r.RoomArea__c                                // 物件．専有面積
                ,Property__r.LiveStatus__c                              // 物件．現況
                ,Property__r.LivedType__c                               // 物件．未入居種別
                ,Property__r.DeliveryType__c                            // 物件．引渡種別
                ,Property__r.DeliveryYear__c                            // 物件．引渡年
                ,Property__r.DeliveryMonth__c                           // 物件．引渡月
                ,Property__r.DeliveryTiming__c                          // 物件．引渡旬
                ,Property__r.DeliveryDay__c                             // 物件．引渡日
                ,Property__r.WebPublishing__c                           // 物件．Web公開
                ,Property__r.WebPostingComment__r.ExampleSentence__c    // 物件．Web掲載時コメント
                ,Property__r.RewardBurdenLender__c                      // 物件．報酬負担貸主
                ,Property__r.RewardBurdenBorrower__c                    // 物件．報酬負担借主
                ,Property__r.RewardSplitFormerSupplier__c               // 物件．報酬配分元付
                ,Property__r.RewardSplitCustomer__c                     // 物件．報酬配分客付
                ,Property__r.ADFeeTax__c                                // 物件．広告料
                ,Property__r.ADFeeComment__c                            // 物件．広告料コメント
                ,Property__r.PropertyComment__c                         // 物件．物件コメント
                ,Property__r.RepresentativeComment__c                   // 物件．担当者コメント
                ,Property__r.KeyPlace__c                                // 物件．鍵所在
                ,Property__r.FormerSupplier__r.Name                     // 物件．元付業者
                ,Property__r.FormerSupplierDepartment__c                // 物件．担当部署
                ,Property__r.FormerSupplierRepresentative__c            // 物件．担当者
                ,Property__r.FormerSupplierRepresentativePhone__c       // 物件．担当者電話番号
                ,Property__r.FormerSupplierPostalCode__c                // 物件．郵便番号
                ,Property__r.FormerSupplierState__c                     // 物件．都道府県
                ,Property__r.FormerSupplierCity__c                      // 物件．住所１（市区町村）
                ,Property__r.FormerSupplierStreet__c                    // 物件．住所２（番地）
                ,Property__r.FormerSupplierPhone__c                     // 物件．電話番号
                ,Property__r.FormerSupplierFax__c                       // 物件．FAX
                ,Property__r.FormerSupplierEmail__c                     // 物件．メール
                ,Property__r.FormerSupplier__r.RemarksPublic__c         // 物件．元付 元付業者.備考
                ,Property__r.Creditor__r.Name                           // 物件．貸主
                ,Property__r.CreditorDepartment__c                      // 物件．担当部署
                ,Property__r.CreditorRepresentative__c                  // 物件．担当者
                ,Property__r.CreditorRepresentativePhone__c             // 物件．担当者電話番号
                ,Property__r.CreditorPostalCode__c                      // 物件．郵便番号
                ,Property__r.CreditorState__c                           // 物件．都道府県
                ,Property__r.CreditorCity__c                            // 物件．住所１（市区町村）
                ,Property__r.CreditorStreet__c                          // 物件．住所２（番地）
                ,Property__r.CreditorPhone__c                           // 物件．電話番号
                ,Property__r.CreditorFax__c                             // 物件．FAX
                ,Property__r.CreditorEmail__c                           // 物件．メール
                ,Property__r.Creditor__r.RemarksPublic__c               // 物件．貸主.備考
                ,Property__r.Owner__r.Name                              // 物件．所有者
                ,Property__r.OwnerDepartment__c                         // 物件．担当部署
                ,Property__r.OwnerRepresentative__c                     // 物件．担当者
                ,Property__r.OwnerRepresentativePhone__c                // 物件．担当者電話番号
                ,Property__r.OwnerPostalCode__c                         // 物件．郵便番号
                ,Property__r.OwnerState__c                              // 物件．都道府県
                ,Property__r.OwnerCity__c                               // 物件．住所１（市区町村）
                ,Property__r.OwnerStreet__c                             // 物件．住所２（番地）
                ,Property__r.OwnerPhone__c                              // 物件．電話番号
                ,Property__r.OwnerFax__c                                // 物件．FAX
                ,Property__r.OwnerEmail__c                              // 物件．メール
                ,Property__r.Owner__r.RemarksPublic__c                  // 物件．所有者.備考
                ,Property__r.Name                                       // 物件．部屋番号
                ,Address__c                                             // 住所
                ,Rent__c                                                // 家賃
                ,ManagementFee__c                                       // 共益費
                ,ParkingFee__c                                          // 駐車場
                ,SecurityDeposit__c                                     // 敷金
                ,KeyMoney__c                                            // 礼金
                ,Deposit__c                                             // 保証料金
                ,TownshipAdmissionFee__c                                // 町会入会金
                ,TownshipFee__c                                         // 町会費
                ,CATV__c                                                // CATV
                ,WortFee__c                                             // 水道料金
                ,ActualFee__c                                           // 償却
                ,SpecialContract__c                                     // 特約
                ,ApplicationDate__c                                     // 申込日
                ,TenantDesiredDate__c                                   // 入居希望日
                ,LastNameKana__c                                        // 姓（カナ）
                ,FirstNameKana__c                                       // 名（カナ）
                ,LastName__c                                            // 姓
                ,FirstName__c                                           // 名
                ,Age__c                                                 // 年齢
                ,Birthdate__c                                           // 生年月日
                ,Current__c                                             // 郵便番号
                ,CurrentState__c                                        // 現住所　都道府県
                ,CurrentCity__c                                         // 現住所１（市区町村）
                ,CurrentStreet__c                                       // 現住所２（番地）
                ,CurrentPhone__c                                        // 電話番号
                ,CurrentMobilePhone__c                                  // 携帯番号
                ,Affiliation__c                                         // 勤務先
                ,AffiliationState__c                                    // 都道府県
                ,AffiliationCity__c                                     // 住所１（市区町村）
                ,AffiliationStreet__c                                   // 住所２（番地）
                ,AffiliationPhone__c                                    // 電話番号
                ,Industries__c                                          // 業種
                ,JobType__c                                             // 職種
                ,Department__c                                          // 部署
                ,Post__c                                                // 役職
                ,AnnualIncome__c                                        // 年収
                ,ContinuedServiceYearsYear__c                           // 勤続年数（年）
                ,ContinuedServiceYearsMonth__c                          // 勤続年数（月）
                ,IsSpouse__c                                            // 配偶者有無
                ,ChildrenCount__c                                       // 子供
                ,ResidenceTermYear__c                                   // 住居期間（年）
                ,ResidenceTermMonth__c                                  // 住居期間（月）
                ,ResidenceType__c                                       // 住居種別
                ,CompanyNameKana__c                                     // 会社名（カナ）
                ,CompanyName__c                                         // 会社名
                ,CompanyIndustries__c                                   // 会社 業種
                ,CompanyPostalCode__c                                   // 会社 郵便番号
                ,CompanyState__c                                        // 会社 都道府県
                ,CompanyCity__c                                         // 会社 住所１
                ,CompanyStreet__c                                       // 会社 住所２
                ,CompanyPhone__c                                        // 会社 電話番号
                ,CompanyFax__c                                          // 会社 FAX
                ,CompanyEstablishmentYear__c                            // 設立(年)
                ,CompanyEstablishmentMonth__c                           // 設立(月)
                ,CompanyCapital__c                                      // 資本金
                ,CorporationRepresentative__c                           // 担当者（法人用）
                ,CorporationDepartment__c                               // 所属部署
                ,CorporationRepresentativePhone__c                      // 担当者（法人用）電話番号
                ,CorporationPost__c                                     // 役職
                ,AffiliationSchool__c                                   // 現在学校名
                ,PlannedEnrollment__c                                   // 入学予定校
                ,CarMaker__c                                            // メーカー
                ,CarType__c                                             // 車種
                ,CarColor__c                                            // 色
                ,EngineSize__c                                          // 排気量（cc）
                ,RegistNumber__c                                        // 登録ナンバー
                ,JointGuarantorLastNameKana__c                          // 連帯保証人 姓（カナ）
                ,JointGuarantorFirstNameKana__c                         // 連帯保証人 名（カナ）
                ,JointGuarantorLastName__c                              // 連帯保証人 姓
                ,JointGuarantorFirstName__c                             // 連帯保証人 名
                ,JointGuarantorAge__c                                   // 連帯保証人 年齢
                ,JointGuarantorBirthdate__c                             // 連帯保証人 生年月日
                ,JointGuarantorPostalCode__c                            // 連帯保証人 郵便番号
                ,JointGuarantorState__c                                 // 連帯保証人 都道府県
                ,JointGuarantorCity__c                                  // 連帯保証人 住所１（市区町村）
                ,JointGuarantorStreet__c                                // 連帯保証人 住所２（番地）
                ,JointGuarantorPhone__c                                 // 連帯保証人 電話番号
                ,JointGuarantorMobilePhone__c                           // 連帯保証人 携帯番号
                ,JointGuarantorAffiliation__c                           // 連帯保証人 勤務先
                ,JointGuarantorAffiliationState__c                      // 連帯保証人 都道府県
                ,JointGuarantorAffiliationCity__c                       // 連帯保証人 住所１（市区町村）
                ,JointGuarantorAffiliationStreet__c                     // 連帯保証人 住所２（番地）
                ,JointGuarantorAffiliationPhone__c                      // 連帯保証人 電話番号
                ,JointGuarantorIndustries__c                            // 連帯保証人 業種
                ,JointGuarantorJobType__c                               // 連帯保証人 職種
                ,JointGuarantorDepartment__c                            // 連帯保証人 部署
                ,JointGuarantorPost__c                                  // 連帯保証人 役職
                ,JointGuarantorAnnualIncome__c                          // 連帯保証人 年収
                ,JointGuarantorContinuedServiceYearsYear__c             // 連帯保証人 勤続年数（年）
                ,JointGuarantorContinuedServiceYearsMonth__c            // 連帯保証人 勤続年数（月）
                ,JointGuarantorIsSpouse__c                              // 連帯保証人 配偶者有無
                ,JointGuarantorChildrenCount__c                         // 連帯保証人 子供
                ,JointGuarantorParentBrotherCount__c                    // 連帯保証人 親兄弟
                ,JointGuarantorResidenceTermYear__c                     // 連帯保証人 住居期間（年）
                ,JointGuarantorResidenceTermMonth__c                    // 連帯保証人 住居期間（月）
                ,JointGuarantorResidenceType__c                         // 連帯保証人 住居種別
                ,ApplicantRelationship__c                               // お申込者との関係
                ,TenantCount__c                                         // 入居人数（本人含め）
            FROM Application__c     // 申込
            WHERE
                Id  = :targetId
        ];
        // レコードが取得できない場合はビジネスロジックExceptionを発行する
        if(application.isEmpty()){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }
        return application[0];
    }

    // 物件条件情報取得
    private PropertyConditions__c selectPropertyConditions(Id propertyId){
        List<PropertyConditions__c> propCondition = [
            SELECT
                Id
                ,IsMaisonette__c                    // メゾネット
                ,IsLoft__c                          // ロフト
                ,IsDesigners__c                     // デザイナーズ
                ,IsCondominiumRental__c             // 分譲賃貸
                ,IsAllWesternStyleRoom__c           // オール洋間
                ,IsTowerMansion__c                  // タワーマンション
                ,IsBarrierFree__c                   // バリアフリー
                ,IsOuterWallTile__c                 // 外壁タイル張り
                ,IsDampingStructure__c              // 制震構造
                ,IsSeismicStructure__c              // 耐震構造
                ,IsSeismicIsolationStructure__c     // 免震構造
                ,IsUndergroundRoom__c               // 地下室
                ,IsSoundproofRoom__c                // 防音室
                ,IsSepticTank__c                    // 浄化槽
                ,IsQuietResidenceTown__c            // 閑静な住宅街
                ,IsCornerRoom__c                    // 角部屋
                ,IsBayWindow__c                     // 出窓
                ,IsPrivateGarden__c                 // 専用庭
                ,IsBalcony__c                       // バルコニー
                ,IsRoofBalcony__c                   // ルーフバルコニー
                ,IsWoodDeck__c                      // ウッドデッキ
                ,IsBuiltInGarage__c                 // ビルトインガレージ
                ,IsCarport__c                       // カーポート
                ,IsElevator__c                      // エレベーター
                ,IsPluralElevators__c               // エレベーター2基
                ,IsInSiteTtrashArea__c              // 敷地内ゴミ置場
                ,IsAnytimeTtrashArea__c             // 24時間ゴミ出し可
                ,IsFrontService__c                  // フロントサービス
                ,IsDeliveryBox__c                   // 宅配ボックス
                ,IsCleaningBox__c                   // クリーニングボックス
                ,IsCoinLaundry__c                   // コインランドリー
                ,IsCounterKitchen__c                // カウンターキッチン
                ,IsSystemKitchen__c                 // システムキッチン
                ,IsGasStove__c                      // ガスコンロ
                ,IsElectricStove__c                 // 電気コンロ
                ,IsIhStove__c                       // IHコンロ
                ,IsTwoGasStove__c                   // コンロ2口
                ,IsMoreGasStove__c                  // コンロ3口以上
                ,IsWaterPurifier__c                 // 浄水器
                ,IsDishwasher__c                    // 食器洗い乾燥機
                ,IsDisposer__c                      // ディスポーザー
                ,IsSeparate__c                      // バス・トイレ別
                ,IsReheating__c                     // 追焚機能
                ,IsHotWaterFormula__c               // 高温差湯式
                ,IsBathroomDryer__c                 // 浴室乾燥機
                ,IsBathroomFloorHeating__c          // 浴室床暖房
                ,IsTvBath__c                        // TV付浴槽
                ,IsWashletToiletSeat__c             // 温水洗浄便座
                ,IsTanklessToilet__c                // タンクレストイレ
                ,IsWashroomDscrete__c               // 洗面所独立
                ,IsShowerWashBasin__c               // シャワー付き洗面台
                ,IsShowerRoom__c                    // シャワールーム
                ,IsMistSauna__c                     // ミストサウナ
                ,IsIndoorWashingMachineStorage__c   // 室内洗濯機置場
                ,IsCityGas__c                       // 都市ガス
                ,IsPropaneGas__c                    // プロパンガス
                ,IsAllElectric__c                   // オール電化
                ,IsAirConditioner__c                // エアコン
                ,IsFloorHeating__c                  // 床暖房
                ,IsGasHeating__c                    // ガス暖房
                ,IsKeroseneHeating__c               // 灯油暖房
                ,IsFurniture__c                     // 家具付き
                ,IsHomeAppliance__c                 // 家電付き
                ,IsWashingDryer__c                  // 洗濯乾燥機
                ,IsFlooring__c                      // フローリング
                ,IsCushionFloor__c                  // クッションフロア
                ,IsSolidWood__c                     // 無垢材使用
                ,IsStormShutter__c                  // 雨戸
                ,IsShutter__c                       // シャッター
                ,IsElectricShutter__c               // 電動シャッター
                ,IsHighSash__c                      // ハイサッシ
                ,IsSoundproofSash__c                // 防音サッシ
                ,IsPairGlass__c                     // 複層ガラス
                ,IsShoesBox__c                      // シューズボックス
                ,IsShoeCloak__c                     // シューズクローク
                ,IsWalkInCloset__c                  // ウォークインクローゼット
                ,IsTrunkRoom__c                     // トランクルーム
                ,IsUnderfloorStorage__c             // 床下収納
                ,IsBSAntenna__c                     // BSアンテナ
                ,IsCSAntenna__c                     // CSアンテナ
                ,IsCATV__c                          // CATV
                ,IsCATVInternet__c                  // CATVインターネット
                ,IsCATVFree__c                      // CATV使用料不要
                ,IsOpticalFiber__c                  // 光ファイバー
                ,IsInternetFree__c                  // ネット使用料無料
                ,IsMonitorIntercom__c               // モニター付きインターホン
                ,IsAutoLock__c                      // オートロック
                ,IsDimpleKey__c                     // ディンプルキー
                ,IsSurveillanceCamera__c            // 防犯カメラ
                ,IsSecurityGlass__c                 // 防犯ガラス
                ,IsAnytimeSecurity__c               // 24時間セキュリティ
                ,IsSecurityCompanyJoin__c           // セキュリティ会社加入済
                ,IsNoGuarantor__c                   // 保証人不要
                ,IsMusicalInstruments__c            // 楽器相談可
                ,IsForeigner__c                     // 外国人契約可
                ,IsWelfareAvailable__c              // 生活保護契約可
                ,IsOfficeAvailable__c               // 事務所利用可
                ,IsPet__c                           // ペット可
                ,IsSmallPet__c                      // ペット(小型犬)
                ,IsMiddlePet__c                     // ペット(中型犬)
                ,IsLargePet__c                      // ペット(大型犬)
                ,IsCat__c                           // ペット(猫)
                ,IsOtherPet__c                      // ペット(その他)
                ,IsTwoTenant__c                     // 2人入居可
                ,IsRoomShare__c                     // ルームシェア可
                ,IsMonthly__c                       // マンスリー可
                ,IsCustomize__c                     // カスタマイズ可
                ,IsDIY__c                           // DIY可
                ,IsITImportantDescription__c        // IT重説対応物件
                ,IsRentCreditPayment__c             // 家賃カード決済可
                ,IsInitialCostCreditPayment__c      // 初期費用カード決済可
                ,IsWoman__c                         // 女性限定
                ,IsStudent__c                       // 学生限定
                ,IsCorporation__c                   // 法人契約限定
                ,IsElderly__c                       // 高齢者歓迎
                ,IsLbgt__c                          // LGBTフレンドリー
                ,IsNotChild__c                      // 子供不可
                ,IsTwoStation__c                    // 2駅利用可
                ,IsTwoTrainRoute__c                 // 2沿線利用可
                ,IsThreeStation__c                  // 3駅以上利用可
                ,IsThreeTrainRoute__c               // 3沿線以上利用可
                ,IsFrontStation__c                  // 駅前
                ,IsParking__c                       // 駐車場空きあり
                ,IsInSiteParking__c                 // 敷地内駐車場
                ,IsBikeStorage__c                   // バイク可
                ,IsSmallBike__c                     // 小型バイク
                ,IsMediumBike__c                    // 中型バイク
                ,IsLargeBike__c                     // 大型バイク
                ,IsFirstFloor__c                    // 1階
                ,IsSecondFloorOver__c               // 2階以上
                ,IsTopFloor__c                      // 最上階
                ,IsSouth__c                         // 南向き
                ,IsJanitor__c                       // 管理人有
                ,IsJanitorReside__c                 // 管理人(常駐)
                ,IsJanitorCommuter__c               // 管理人(通勤)
                ,IsJanitorPatrol__c                 // 管理人(巡回)
                ,IsTurnkey__c                       // 即入居可
                ,IsNotFixedTermTenant__c            // 定期借家を含まない
                ,IsPluralCarParking__c              // 駐車場2台可
                ,IsBicycleParking__c                // 駐輪場
                ,IsRenovation__c                    // リノベーション
                ,IsFreeRent__c                      // フリーレント
                ,IsSpecialRent__c                   // 特定優良賃貸住宅
                ,FacilityRemarksPublic__c           // 設備備考（公開）
                ,ContractRemarks__c                 // 契約備考
            FROM PropertyConditions__c  // 物件条件
            WHERE
            Property__c = :propertyId
        ];
        if(propCondition.isEmpty()){
            return new PropertyConditions__c();
        }
        return propCondition[0];
    }

    // 部屋情報取得
    private List<Room__c> selectRoom(Id propertyId){
        List<Room__c> room = [
            SELECT
                Id
                ,RoomType__c        // 部屋タイプ
                ,RoomFloorSpace__c  // 部屋帖数
            FROM Room__c      // 部屋
            WHERE
                Property__c = :propertyId
        ];
        return room;
    }

    // 商品情報取得（仮見積で選択した火災保険）
    private Item__c selectItem(Id propertyId, Id accountId){
        List<Item__c> item = [
            SELECT
                Id
                ,FireInsuranceMonth__c  // 火災保険料(月額)
                ,FireInsuranceYear__c   // 火災保険料(年額)
                ,PaymentType__c         // 更新期間
            FROM Item__c    // 商品
            WHERE
                Id  IN (
                    SELECT
                        FireInsuranceItem__c
                    FROM ProvisionalQuote__c      // 仮見積
                    WHERE
                        Property__c = :propertyId
                    AND Account__c  = :accountId
                )
        ];
        if(item.isEmpty()){
            return new Item__c();
        }
        return item[0];
    }

    // 入居者情報取得
    private List<Tenant__c> selectTenant(Id applicationId){
        List<Tenant__c> tenant = [
            SELECT
                Id
                ,FullNameKana__c    // 氏名（カナ）
                ,FullName__c        // 氏名
                ,Age__c             // 年齢
                ,Relationship__c    // 続柄
                ,Birthdate__c       // 生年月日
                ,JobType__c         // 職種
                ,Remarks__c         // 備考
            FROM Tenant__c      // 入居者
            WHERE
                Application__c = :applicationId
        ];
        return tenant;
    }

}