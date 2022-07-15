//日報更新Utilクラス
public class DailyReportUtil {

    /** クラス内定数 */
    public static final String CONCAT_VALUE = '_';
    private static final Integer ETCETERA_AUXILIARY_ITEM_LIST_COUNT = 10;                       // 付帯商品項目のリスト数
    private static final String COLUMN_NAME_AUXILIARY_ITEM_FEE  = 'AuxiliaryItemFee{num}__c';   // 付帯商品料の項目名
    private static final String COLUMN_NAME_AUXILIARY_ITEM      = 'AuxiliaryItem{num}__c';      // 付帯商品の項目名
    
    // 列挙型
    private enum DIARLY_UPDATE_ITEM {MANUAL_MAINTENANCE, AUTO_MAINTENANCE, ELECTRONIC, PHOTO_REGIST} // 日報を更新する項目種別
    
    
    // 反響累計の更新or登録（対応トリガーより）
	public static void upsertEchoTotal_Correspond(Correspond__c[] targetList) {

        // 変数宣言
        List<Id> inputIdList = new List<Id>();
        List<Correspond__c> taishoList = new List<Correspond__c>();
        Map<Id, EchoTotal__c> echoTotalIdMap = new Map<Id, EchoTotal__c>();
        List<EchoTotal__c> upsertList = new List<EchoTotal__c>();

        // システム日付を設定
        Date sysDate = CommonUtil.getToday();

        // 処理対象データの絞り込み
        // ・対応.取引先. レコードタイプ  = "顧客：CustomerRecordType" の場合
        // ・かつ　対応.ステータス <> "終了" の場合
        for (Correspond__c taisho : targetList) {

            if (taisho.AccountRecordType__c == CommonConst.ACCOUNT_RECTYPE_CUSTOMER
                && taisho.Status__c <> CommonConst.CORRESPOND_STATUS_CLOSE) {
                    taishoList.add(taisho);
                    inputIdList.add(taisho.Id);
            }
        }

        // 処理対象データが存在しない場合は処理を終了する
        if (taishoList.isEmpty()) {
            return;
        }


        // 対応番号を格納
        for (Correspond__c target : taishoList) {
            inputIdList.add(target.Id);
        }

        // 反響累計の存在チェック
        List<EchoTotal__c> echoTotalList = [SELECT Id
                                                    , Corresponds__c
                                                    , FirstVisitsCount__c
                                                    , FirstVisitsDate__c
                                                    , ContractCount__c
                                                    , EchoDateTime__c
                                                FROM EchoTotal__c
                                                WHERE Corresponds__c IN :inputIdList
                                                ];

        // 反響累計に存在する対応番号を格納（マッチング用）
        for (EchoTotal__c echoTotal : echoTotalList) {
            echoTotalIdMap.put(echoTotal.Corresponds__c, echoTotal);
        }

        // 登録or更新項目を設定
        for (Correspond__c target : taishoList) {

            // 変数宣言
            EchoTotal__c addEchoTotal = new EchoTotal__c();

            // 共通項目の設定
            addEchoTotal.Corresponds__c         = target.Id;
            addEchoTotal.EchoShop__c            = target.EchoShop__c;          // 反響店舗
            addEchoTotal.EchoStaff__c           = target.EchoStaff__c;         // 反響担当者
            addEchoTotal.VisitsStaff__c         = target.ShopStaff__c;         // 来店店舗
            addEchoTotal.EchoDistrict__c        = target.District__c;          // 地区
            addEchoTotal.VisitsShop__c          = target.VisitShop__c;         // 来店店舗
            addEchoTotal.PortalSite__c          = target.PortalSite__c;        // ポータルサイト
            addEchoTotal.ContactWay__c          = target.VisitReason__c;       // 来店理由
            addEchoTotal.MediaType__c           = target.FirstInquiryMeans__c; // 問合種別
            addEchoTotal.Remarks__c             = target.Remarks__c;           // 問合せ323で追加　備考
            addEchoTotal.FirstGuidanceMethod__c = target.FirstGuidanceMethod__c; // 問合せ405で追加　初回案内方法

            //ポータルサイト構築 変更 Start

            addEchoTotal.FirstVisitReservationDate__c   =   target.FirstVisitReservationDate__c;     //初回来店予約日
            //処理対象リスト．初回来店予約キャンセルフラグがtrueの場合、初回来店予約キャンセル数は１
            if(target.FirstVisitReservationCancelFlg__c){
                addEchoTotal.FirstVisitReservationCancelCount__c = 1;
            //処理対象リスト．初回来店予約キャンセルフラグがfalseの場合、初回来店予約キャンセル数は0に設定
            }else if(! target.FirstVisitReservationCancelFlg__c){
                addEchoTotal.FirstVisitReservationCancelCount__c = 0;
            }

            //ポータルサイト構築 追加 End
            
            // 反響数非計算フラグ
            if (target.IsEchoNotCalculation__c){
                addEchoTotal.IsEchoNotCalculation__c = true; //対応の同項目がTrueなら、Trueにする
            }
            
            // 来店数非計算フラグ
            if (target.IsVisitNotCalculation__c){
                addEchoTotal.IsVisitNotCalculation__c = true; //対応の同項目がTrueなら、Trueにする
            }
            
            

            // メール受信日時（ポータル）が設定されている場合のみ、
            if (target.ReceiveMailDatePortal__c != null) {
                addEchoTotal.EchoCount__c = 1; // 反響数を設定する
                
                //▼問合せNo0340で変更
                // 反響取得日が空なら、反響取得日を設定する
                if (!echoTotalIdMap.containsKey(target.Id) || echoTotalIdMap.get(target.Id).EchoDateTime__c == null){
                    addEchoTotal.EchoDateTime__c = target.ReceiveMailDatePortal__c;
                }
                //▲問合せNo0340で変更
            }
            


            // 来店日（初回）が設定されている場合のみ、
            if (target.VisitDate__c != null) {
                
                // 来店日が空なら、来店日を設定する
                if (!echoTotalIdMap.containsKey(target.Id) || echoTotalIdMap.get(target.Id).FirstVisitsDate__c == null){
                    addEchoTotal.FirstVisitsDate__c = target.VisitDate__c;
                }
            }
            

            // 対応ステータスがアポイント確定または来店済みの場合
            if (target.Status__c == CommonConst.CORRESPOND_STATUS_APPOINTMENT || 
                target.Status__c == CommonConst.CORRESPOND_STATUS_VISITED) {
                addEchoTotal.AppointConfirmedCount__c = 1;// アポイント確定数に1を設定する
                addEchoTotal.AppointCancelCount__c = 0;   // アポイントキャンセル数を0に設定する
            }

            // 対応ステータスがアポイントキャンセル
            if (target.Status__c == CommonConst.CORRESPOND_STATUS_APOCANCEL) {
                if (target.VisitDate__c == null) {
                    //来店日が入っていないことが条件（来店日が入っていたら、もうISはアポ確したのでキャンセル数は増やさない）
                    addEchoTotal.AppointCancelCount__c = 1;   // アポイントキャンセル数に1を設定する
                }
            }
            
            // 対応ステータスが未収入金
            if (target.Status__C == CommonConst.CORRESPOND_STATUS_UNEARNED) {
                addEchoTotal.ContractCount__c = 1;         // 契約数に1を設定する
            }
            
            // 対応ステータスが申込キャンセル
            if (target.Status__C == CommonConst.CORRESPOND_STATUS_APPLCANCEL) {
                addEchoTotal.ContractCount__c = 0;         // 契約数に0を設定する
            }
            

            // インプット情報と反響累計情報の同一データ存在チェックを行う
            if (echoTotalIdMap.containsKey(target.Id)) {
                // ＜更新用に項目格納＞

                addEchoTotal.Id = echoTotalIdMap.get(target.Id).Id;

                // 対応ステータスが来店済
                if (target.Status__c == CommonConst.CORRESPOND_STATUS_VISITED) {
                    // かつ、初回来店数が0の場合、初回来店数に1を設定する
                    if (echoTotalIdMap.get(target.Id).FirstVisitsCount__c == 0) {
                        addEchoTotal.FirstVisitsCount__c = 1;
                    }
                }

            } else {
                // ＜登録用に項目格納＞


                // 対応ステータスが来店済の場合
                // ・初回来店数に1を設定する
                if (target.Status__c == CommonConst.CORRESPOND_STATUS_VISITED) {
                    addEchoTotal.FirstVisitsCount__c = 1;
                }
                
            }

            // 格納結果を登録・更新用リストに格納
            upsertList.add(addEchoTotal);
        }

        // 対象データの登録・更新を行う
        if (!upsertList.isEmpty()) {
            SecureDML.secureUpsert(upsertList);
        }
    }


    //反響累計の更新or登録（申込トリガーより）
    public static void upsertEchoTotal_Application(Application__c[] targetList,
                                                    Application__c[] targetOldList) {

        // 変数宣言
        List<Id> inputIdList = new List<Id>();
        List<Application__c> taishoList = new List<Application__c>();
        Map<Id, Correspond__c> correspondMap = new Map<Id, Correspond__c>();
        Map<Id, EchoTotal__c> echoTotalIdMap = new Map<Id, EchoTotal__c>();
        List<EchoTotal__c> upsertList = new List<EchoTotal__c>();
        Date oldPaymentDate = null;
        AuxiliaryItemEchoTotalAndEchoTotalList aietList = new AuxiliaryItemEchoTotalAndEchoTotalList();

        // 引数（申込）の対応番号をリストに格納
        for (Application__c taisho : targetList) {
            inputIdList.add(taisho.Corresponds__c);
        }

        // 対応オブジェクトより、引数に紐づくデータを取得する
        List<Correspond__c> correspondList = [SELECT Id
                                                FROM Correspond__c
                                                WHERE Id IN :inputIdList
                                                ];

        // マッチング用にマップ生成
        for (Correspond__c correspond : correspondList) {

            correspondMap.put(correspond.Id, correspond);
        }

        // 対応オブジェクトに紐づく引数のみ後続処理で利用する
        for (Application__c taisho : targetList) {

            if (correspondMap.containskey(taisho.Corresponds__c)) {
                taishoList.add(taisho);
            }
        }

        // 処理対象データが存在しない場合は処理を終了する
        if (taishoList.isEmpty()) {
            return;
        }


        // 反響累計の存在チェック
        List<EchoTotal__c> echoTotalList = [SELECT Id
                                                , Corresponds__c
                                                , ContractCount__c
                                            FROM EchoTotal__c
                                            WHERE Corresponds__c IN :correspondList
                                            ];

        // 反響累計に存在する対応番号を格納（マッチング用）
        for (EchoTotal__c echoTotal : echoTotalList) {
            echoTotalIdMap.put(echoTotal.Corresponds__c, echoTotal);
        }

        // 申込オブジェクトに対応する商品データを取得する
        List<Id> itemIdList = new List<Id>();
        for (Application__c taisho : targetList) {
            for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
                Id itemId = (Id) taisho.get(makeNumberColumnName(COLUMN_NAME_AUXILIARY_ITEM, i));
                if (itemId != null && !itemIdList.contains(itemId)) {
                    itemIdList.add(itemId);
                }
            }
        }
        Map<Id, Item__c> itemMap = new Map<Id, Item__c>(
            [SELECT Id, AuxiliaryItemType__c FROM Item__c WHERE ID in :itemIdList]
        );

        // 登録or更新項目を設定
        for (Application__c taisho : taishoList) {

            // 変数宣言
            EchoTotal__c addEchoTotal = new EchoTotal__c();

            // 共通項目の設定
            addEchoTotal.Corresponds__c = taisho.Corresponds__c;
            addEchoTotal.ContractDate__c = taisho.PaymentDate__c;      // 契約日←申込の入金日に設定
            if (taisho.IsReviewEntry__c) {
                addEchoTotal.ReviewCount__c = 1;
            } else {
                addEchoTotal.ReviewCount__c = 0;
            }
            addEchoTotal.BrokerageFirstFee__c = 0;
            // addEchoTotal.ParkingCommission__c = 0;
            addEchoTotal.ParkingBrokerageFirstFee__c = 0;
            addEchoTotal.ADFee__c = 0;
            addEchoTotal.AuxiliaryDepositPlanFee__c = 0;
            addEchoTotal.AuxiliaryFireInsuranceFee__c = 0;

            // インプット情報と反響累計情報の同一データ存在チェックを行う
            if (echoTotalIdMap.containsKey(taisho.Corresponds__c)) {
                // ＜更新用に項目格納＞

                // 更新前の入金日を取得
                for (Application__c old : targetOldList) {
                    if (taisho.Id == old.Id) {
                        oldPaymentDate = old.PaymentDate__c;
                        break;
                    }
                }

                // IDをセット
                addEchoTotal.Id = echoTotalIdMap.get(taisho.Corresponds__c).Id;

                // 入金日に値が入っている、もしくは入金日ある→ない状態になった場合上書きする
                if(taisho.PaymentDate__c != null  || 
                   (taisho.PaymentDate__c == null && oldPaymentDate != null)){

                    addEchoTotal.BrokerageFirstFee__c = taisho.BrokerageFirstFee__c;
                    // addEchoTotal.ParkingCommission__c = taisho.ParkingCommission__c;
                    addEchoTotal.ParkingBrokerageFirstFee__c = taisho.ParkingBrokerageFirstFee__c;
                    addEchoTotal.ADFee__c = taisho.ADFee__c;
                    addEchoTotal.AuxiliaryDepositPlanFee__c = taisho.AuxiliaryDepositPlanFee__c;
                    addEchoTotal.AuxiliaryFireInsuranceFee__c = taisho.AuxiliaryFireInsuranceFee__c;

                    // 付帯商品の登録がある場合は、付帯商品反響累計の登録データを作成
                    for (Integer i = 1; i <= ETCETERA_AUXILIARY_ITEM_LIST_COUNT; i++) {
                        Id tempItemId = (Id) taisho.get(makeNumberColumnName(COLUMN_NAME_AUXILIARY_ITEM, i));
                        if (tempItemId != null) {
                            Item__c tempItem = itemMap.get(tempItemId);
                            String tempItemType = tempItem == null? null: tempItem.AuxiliaryItemType__c;
                            Decimal tempItemFee = (Decimal) taisho.get(makeNumberColumnName(COLUMN_NAME_AUXILIARY_ITEM_FEE, i));
                            aietList.add(addEchoTotal, new AuxiliaryItemEchoTotal__c(
                                AuxiliaryItemType__c = tempItemType             // 付帯商品種別
                                , AuxiliaryItemFee__c = tempItemFee             // 付帯商品料
                            ));
                        }
                    }
                }

            }

            // 格納結果を登録・更新用リストに格納
            upsertList.add(addEchoTotal);
        }

        // 対象データの登録・更新を行う
        if (!upsertList.isEmpty()) {
            SecureDML.secureUpsert(upsertList);
        }

        // 付帯商品反響累計の削除
        List<AuxiliaryItemEchoTotal__c> delAuxiEchoList = getAuxiliaryItemEchoTotalList(upsertList);
        if (!delAuxiEchoList.isEmpty()) {
            SecureDML.secureDelete(delAuxiEchoList);
        }

        // 付帯商品反響累計の登録
        aietList.linkEchoTotal();
        List<AuxiliaryItemEchoTotal__c> insAuxiEchoList = aietList.getAuxiliaryItemEchoTotalList();
        if (!insAuxiEchoList.isEmpty()) {
            SecureDML.secureInsert(insAuxiEchoList);
        }
    }


    // ★★以下、画面から呼び出される日報UPSERTメソッド★★

    //日報情報更新（物件登録から）
	public static void upsertDailyReportManualMaintenance() {
        dailyReportUpsert(DIARLY_UPDATE_ITEM.MANUAL_MAINTENANCE, 1); //1増やす
    }
    
    //日報情報更新（メンテナンス一覧画面から）
	public static void upsertDailyReportMaintenance() {
        dailyReportUpsert(DIARLY_UPDATE_ITEM.AUTO_MAINTENANCE, 1); //1増やす
    }

    //日報情報更新（電物メンテ一覧画面から）
	public static void upsertDailyReportDembutsu(Integer updateNumber) {
        dailyReportUpsert(DIARLY_UPDATE_ITEM.ELECTRONIC, updateNumber); //引数の値に更新する
    }

    //日報情報更新（物件登録画面から）
	public static void upsertDailyReportProperty() {
        dailyReportUpsert(DIARLY_UPDATE_ITEM.PHOTO_REGIST, 1); //１増やす
    }

    
    
    
    // 日報の登録、更新メイン処理
    private static void dailyReportUpsert(DIARLY_UPDATE_ITEM updateItem, Integer updateNumber) {

        // 項目取得
        Date sysDate     = CommonUtil.getToday();            //本日日付
        Shop__c userShop = CommonUtil.getStaffCurrentShop(); // 店舗情報を取得する

        // 本日のユーザの日報取得
        List<DailyReport__c> dailyReportList = getDialyReportList(sysDate, userShop);
        
        
        // upsertするデータの設定
        DailyReport__c upsertDialyReport; //更新対象
        
        if (dailyReportList.isEmpty()) {
            upsertDialyReport = setInsertDialyReport(sysDate, userShop); // レコードを新規作成
        } else {
            upsertDialyReport = dailyReportList[0];                      // 取得してきたレコード
        }

        // 項目の変更
        changeItemNumber(upsertDialyReport, updateItem, updateNumber);
        
        // 対象データの登録・更新を行う
        SecureDML.secureUpsert(upsertDialyReport);
    }
    
    //ユーザの本日の日報取得
    private static List<DailyReport__c> getDialyReportList(Date sysDate, Shop__c userShop){
        
        
        //List取得
        List<DailyReport__c> dailyReportList = 
            [SELECT Id
             , AutoMaintenanceCount__c
             , ManualMaintenanceCount__c
             , Electronic__c
             , PhotoRegist__c
             FROM DailyReport__c
             WHERE ReportDate__c = :sysDate
             AND Staff__c = :UserInfo.getUserId()
             AND Shop__c = :userShop.Id
             LIMIT 1
            ];
        return dailyReportList;
    }
    
    //新規登録用の日報情報設定
    private static DailyReport__c setInsertDialyReport(date sysDate, Shop__c userShop){
        
        DailyReport__c insertDialyReport = new DailyReport__c();
        insertDialyReport.PropertyConfirmation__c   = 0;
        insertDialyReport.PropertyResearch__c       = 0;
        insertDialyReport.ManualMaintenanceCount__c = 0;
        insertDialyReport.AutoMaintenanceCount__c   = 0;
        insertDialyReport.Electronic__c             = 0;
        insertDialyReport.PhotoRegist__c            = 0;
        insertDialyReport.ImprovementPlan__c        = 0;
        insertDialyReport.ReportDate__c             = sysDate;                    //日付
        insertDialyReport.Staff__c                  = UserInfo.getUserId();       //ユーザ
        insertDialyReport.Shop__c                   = userShop.Id;                //店舗
        
        return insertDialyReport;
    }
    
    //日報の項目の変更
    private static void changeItemNumber(DailyReport__c upsertDailyReport, DIARLY_UPDATE_ITEM updateItem, Integer updateNumber) {
        
        //更新する項目の種別ごと
        switch on updateItem {
            when MANUAL_MAINTENANCE {
                upsertDailyReport.ManualMaintenanceCount__c += updateNumber; //値を増やす
            }
            when AUTO_MAINTENANCE {
                upsertDailyReport.AutoMaintenanceCount__c += updateNumber; //値を増やす
            }
            when ELECTRONIC {
                upsertDailyReport.Electronic__c = updateNumber; //その値に変更する
            }
            when PHOTO_REGIST {
                upsertDailyReport.PhotoRegist__c += updateNumber; //値を増やす
            }            
        }
    }

    // 番号付きカラム名称の作成
    private static String makeNumberColumnName(String columnName, Integer num) {
        return columnName.replaceAll('\\{num\\}', String.valueOf(num));
    }

    // 引数の反響累計リストに紐づく付帯商品反響累計を取得する
    private static List<AuxiliaryItemEchoTotal__c> getAuxiliaryItemEchoTotalList(List<EchoTotal__c> echoTotalList) {
        List<Id> targetEchoTotalIdList = new List<Id>();
        for (EchoTotal__c et: echoTotalList) {
            targetEchoTotalIdList.add(et.Id);
        }
        List<AuxiliaryItemEchoTotal__c> auxiEchoList = [
            SELECT ID FROM AuxiliaryItemEchoTotal__c WHERE EchoTotal__c IN :targetEchoTotalIdList
        ];
        return auxiEchoList;
    }

    // 付帯商品反響累計と反響累計オブジェクトを紐づけて保持するクラス
    class AuxiliaryItemEchoTotalAndEchoTotal {
        // クラス変数
        AuxiliaryItemEchoTotal__c dat;       // 付帯商品反響累計
        EchoTotal__c echoTotal;              // 反響累計（親レコード）

        // コンストラクタ
        public AuxiliaryItemEchoTotalAndEchoTotal(EchoTotal__c echoTotal, AuxiliaryItemEchoTotal__c dat) {
            this.echoTotal = echoTotal;
            this.dat = dat;
        }
    }

    // 付帯商品反響累計と反響累計オブジェクトを紐づけて保持するクラスのリスト
    class AuxiliaryItemEchoTotalAndEchoTotalList {
        // クラス変数
        List<AuxiliaryItemEchoTotalAndEchoTotal> itemList = new List<AuxiliaryItemEchoTotalAndEchoTotal>();

        // 一件追加
        public void add(EchoTotal__c echoTotal, AuxiliaryItemEchoTotal__c dat) {
            itemList.add(new AuxiliaryItemEchoTotalAndEchoTotal(echoTotal, dat));
        }

        // 反響累計との紐づけ
        public void linkEchoTotal() {
            // 付帯商品反響累計に反響累計IDを登録
            for (AuxiliaryItemEchoTotalAndEchoTotal item: this.itemList) {
                item.dat.EchoTotal__c = item.echoTotal.id;
            }
        }

        // 付帯商品反響累計のリストを取得
        public List<AuxiliaryItemEchoTotal__c> getAuxiliaryItemEchoTotalList() {
            List<AuxiliaryItemEchoTotal__c> itemList = new List<AuxiliaryItemEchoTotal__c>();
            for (AuxiliaryItemEchoTotalAndEchoTotal item: this.itemList) {
                itemList.add(item.dat);
            }
            return itemList;
        }
    }
}