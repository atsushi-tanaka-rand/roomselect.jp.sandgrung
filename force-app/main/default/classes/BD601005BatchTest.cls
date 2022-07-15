//自動メンテナンス差分バッチのテストクラス
@isTest
private class BD601005BatchTest {
    // 業者のレコードタイプID
    private static final Id     RECORDTYPE_ID_SUPPLIER = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_SUPPLIER);
    // メンテナンスコード
    private static final String BUILDING_MAINT_CODE    = 'BUILD';
    private static final String SUPPLIER_MAINT_CODE    = 'SUP-01';
    private static final String PROPERTY_MAINT_CODE    = 'PROP';
    // メンテナンスコード(既存)
    private static final String BUILDING_MAINT_CODE_EXISTS = 'BUILD_EXISTS'; 
    private static final String SUPPLIER_MAINT_CODE_EXISTS = 'SUP-EXISTS';
    private static final String PROPERTY_MAINT_CODE_EXISTS = 'PROP_EXISTS';

    // 自動メンテナンス差分　登録最大値
    private static final Integer AUTOMAINTEDIFF_ROOM_MAXCOUNT = 10;

    /** 自動メンテナンス差分 物件種別 */
    private static final String AUTOMAINTEDIFF_PROPERTYTYPE_MANSION            = 'マンション';
    private static final String AUTOMAINTEDIFF_PROPERTYTYPE_APARTMENT          = 'アパート';
    private static final String AUTOMAINTEDIFF_PROPERTYTYPE_DETACHEDHOUSE      = '一戸建て';
    private static final String AUTOMAINTEDIFF_PROPERTYTYPE_TERRACEDHOUSE      = 'テラスハウス';
    private static final String AUTOMAINTEDIFF_PROPERTYTYPE_TOWNHOUSE          = 'タウンハウス';
    private static final String AUTOMAINTEDIFF_PROPERTYTYPE_SHAREHOUSE         = 'シェアハウス';
    private static final String AUTOMAINTEDIFF_PROPERTYTYPE_DORMITORY_BOARDING = '寮・下宿';
    private static final String AUTOMAINTEDIFF_PROPERTYTYPE_OTHER              = 'その他';

    /** 自動メンテナンス差分 建物構造 */
    private static final String AUTOMAINTEDIFF_STRUCTURE_WOODEN           = '木造';
    private static final String AUTOMAINTEDIFF_STRUCTURE_BLOCK            = 'ブロック造';
    private static final String AUTOMAINTEDIFF_STRUCTURE_STEEL            = '鉄骨造';
    private static final String AUTOMAINTEDIFF_STRUCTURE_RC               = 'RC';
    private static final String AUTOMAINTEDIFF_STRUCTURE_SRC              = 'SRC';
    private static final String AUTOMAINTEDIFF_STRUCTURE_PC               = 'PC';
    private static final String AUTOMAINTEDIFF_STRUCTURE_HPC              = 'HPC';
    private static final String AUTOMAINTEDIFF_STRUCTURE_ALC              = 'ALC';
    private static final String AUTOMAINTEDIFF_STRUCTURE_LIGHTWEIGHTSTEEL = '軽量鉄骨';
    private static final String AUTOMAINTEDIFF_STRUCTURE_OTHER            = 'その他';

    /** 自動メンテナンス差分 管理人種別 */
    private static final String AUTOMAINTEDIFF_CARETAKERTYPE_RESIDE    = '常駐';
    private static final String AUTOMAINTEDIFF_CARETAKERTYPE_NORESIDE  = '非常駐';
    private static final String AUTOMAINTEDIFF_CARETAKERTYPE_PATROL    = '巡回方式';
    private static final String AUTOMAINTEDIFF_CARETAKERTYPE_COMMUTER  = '通勤方式';

    /** 自動メンテナンス差分 バルコニー方向 */
    private static final String AUTOMAINTEDIFF_BALCONYDIRECTION_NORTH      = '北';
    private static final String AUTOMAINTEDIFF_BALCONYDIRECTION_NORTHEAST  = '北東';
    private static final String AUTOMAINTEDIFF_BALCONYDIRECTION_EAST       = '東';
    private static final String AUTOMAINTEDIFF_BALCONYDIRECTION_SOUTHEAST  = '南東';
    private static final String AUTOMAINTEDIFF_BALCONYDIRECTION_SOUTH      = '南';
    private static final String AUTOMAINTEDIFF_BALCONYDIRECTION_SOUTHWEST  = '南西';
    private static final String AUTOMAINTEDIFF_BALCONYDIRECTION_WEST       = '西';
    private static final String AUTOMAINTEDIFF_BALCONYDIRECTION_NORTHWEST  = '北西';

    /** 自動メンテナンス差分 間取り */
    private static final String AUTOMAINTEDIFF_ROOMLAYOUT_R      = 'R';
    private static final String AUTOMAINTEDIFF_ROOMLAYOUT_K      = 'K';
    private static final String AUTOMAINTEDIFF_ROOMLAYOUT_DK     = 'DK';
    private static final String AUTOMAINTEDIFF_ROOMLAYOUT_LK     = 'LK';
    private static final String AUTOMAINTEDIFF_ROOMLAYOUT_LDK    = 'LDK';
    private static final String AUTOMAINTEDIFF_ROOMLAYOUT_SK     = 'SK';
    private static final String AUTOMAINTEDIFF_ROOMLAYOUT_SDK    = 'SDK';
    private static final String AUTOMAINTEDIFF_ROOMLAYOUT_SLK    = 'SLK';
    private static final String AUTOMAINTEDIFF_ROOMLAYOUT_SLDK   = 'SLDK';

    /** 自動メンテナンス差分 現況 */
    private static final String AUTOMAINTEDIFF_LIVESTATUS_RESIDENT         = '居住中';
    private static final String AUTOMAINTEDIFF_LIVESTATUS_VACANCY          = '空室';
    private static final String AUTOMAINTEDIFF_LIVESTATUS_INCOMPLETE       = '未完成';
    private static final String AUTOMAINTEDIFF_LIVESTATUS_SCHEDULEDTOLEAVE = '退去予定';

    /** 自動メンテナンス差分 引渡種別 */
    private static final String AUTOMAINTEDIFF_DELIVERYTYPE_IMMEDIATE      = '即時';
    private static final String AUTOMAINTEDIFF_DELIVERYTYPE_CONSULTATION   = '相談';
    private static final String AUTOMAINTEDIFF_DELIVERYTYPE_DUEDATE        = '期日指定';

    /** 自動メンテナンス差分 引渡 月*/
    private static final String AUTOMAINTEDIFF_DELIVERYMONTH_JAN     = '1月';
    private static final String AUTOMAINTEDIFF_DELIVERYMONTH_FED     = '2月';
    private static final String AUTOMAINTEDIFF_DELIVERYMONTH_MAR     = '3月';
    private static final String AUTOMAINTEDIFF_DELIVERYMONTH_APR     = '4月';
    private static final String AUTOMAINTEDIFF_DELIVERYMONTH_MAY     = '5月';
    private static final String AUTOMAINTEDIFF_DELIVERYMONTH_JUN     = '6月';
    private static final String AUTOMAINTEDIFF_DELIVERYMONTH_JUL     = '7月';
    private static final String AUTOMAINTEDIFF_DELIVERYMONTH_AUG     = '8月';
    private static final String AUTOMAINTEDIFF_DELIVERYMONTH_SEP     = '9月';
    private static final String AUTOMAINTEDIFF_DELIVERYMONTH_OCT     = '10月';
    private static final String AUTOMAINTEDIFF_DELIVERYMONTH_NOV     = '11月';
    private static final String AUTOMAINTEDIFF_DELIVERYMONTH_DEC     = '12月';

    /** 自動メンテナンス差分 引渡 旬*/
    private static final String AUTOMAINTEDIFF_DELIVERYTIMING_EARLY      = '上旬';
    private static final String AUTOMAINTEDIFF_DELIVERYTIMING_MID        = '中旬';
    private static final String AUTOMAINTEDIFF_DELIVERYTIMING_LATE       = '下旬';

    /** 自動メンテナンス差分 各種料金単位 */
    private static final String AUTOMAINTEDIFF_FEEUNIT_YEN         = '円';
    private static final String AUTOMAINTEDIFF_FEEUNIT_MONTH       = 'ヵ月';
    private static final String AUTOMAINTEDIFF_FEEUNIT_RATE        = '%';
    private static final String AUTOMAINTEDIFF_FEEUNIT_ACTUALCOST  = '実費';

    /** 自動メンテナンス差分 各種税区分 */
    private static final String AUTOMAINTEDIFF_TAXTYPE_TAXABLE     = '課税';
    private static final String AUTOMAINTEDIFF_TAXTYPE_NOTAXABLE   = '非課税';

    /** 自動メンテナンス差分 支払区分 */
    private static final String AUTOMAINTEDIFF_PAYMENTTYPE_MONTH = '月額';
    private static final String AUTOMAINTEDIFF_PAYMENTTYPE_YEAR  = '年額';
    private static final String AUTOMAINTEDIFF_PAYMENTTYPE_BEFORE_OCCUPANCY    = '入居前';
    private static final String AUTOMAINTEDIFF_PAYMENTTYPE_AFTER_OCCUPANCY     = '入居後';

    /** 自動メンテナンス差分 保証会社(利用区分) */
    private static final String AUTOMAINTEDIFF_GUARANTEEIDCOMPANYTYPE_REQUIRED = '利用必須';
    private static final String AUTOMAINTEDIFF_GUARANTEEIDCOMPANYTYPE_POSSIBLE = '利用可';

    /** 自動メンテナンス差分 駐車場種別 */
    private static final String AUTOMAINTEDIFF_PARKINGTYPE_EMPTY_EXISTS        = '空有';
    private static final String AUTOMAINTEDIFF_PARKINGTYPE_NO_EMPTY            = '空無';
    private static final String AUTOMAINTEDIFF_PARKINGTYPE_NO                  = '無';
    private static final String AUTOMAINTEDIFF_PARKINGTYPE_NEIGHBORHOOD_SECURE = '近隣確保';

    /** 自動メンテナンス差分 web公開 */
    private static final String AUTOMAINTEDIFF_WEBPUBLISHING_EXISTS    = 'する';
    private static final String AUTOMAINTEDIFF_WEBPUBLISHING_NO        = 'しない';

    /** システム変数　項目名 */
    private static final String IS_AUTOMAINTENANCE_BATCHPROCESSING  = CommonConst.IS_AUTOMAINTENANCE_BATCHPROCESSING; 
	private static final String IS_AUTOMAINTENANCE_BATCHPROCESSING2 = CommonConst.IS_AUTOMAINTENANCE_BATCHPROCESSING2; 
	private static final String IS_AUTOMAINTENANCE_BATCHPROCESSING3 = CommonConst.IS_AUTOMAINTENANCE_BATCHPROCESSING3; 
	private static final String IS_AUTOMAINTENANCE_BATCHPROCESSING4 = CommonConst.IS_AUTOMAINTENANCE_BATCHPROCESSING4; 
	private static final String IS_AUTOMAINTENANCE_BATCHPROCESSING5 = CommonConst.IS_AUTOMAINTENANCE_BATCHPROCESSING5; 

    /** 物件備考（非公開） */
    private static final String PROP_REMARKS_PRIVATE_INIT1    = '初期値1';
    private static final String PROP_REMARKS_PRIVATE_INIT2    = '初期値2';

    /** 設備備考（非公開） */
    private static final String FACILITY_REMARKS_PRIVATE_INIT1    = '初期値1';
    private static final String FACILITY_REMARKS_PRIVATE_INIT2    = '初期値2';

    /** 自動メンテナンス差分間取図ファイル名 */
    private static final String DIFF_ROOMLAYOUT_FILE_NAME_INIT1    = '初期値1';
    private static final String DIFF_ROOMLAYOUT_FILE_NAME_INIT2    = '初期値2';

    @TestSetup
    static void Setting(){
        // カスタム設定を登録 ※周辺施設取得Batchサイズ
        SystemConfig__c sysconf = new SystemConfig__c(
            SurroundingBatchProcessCount__c = 5
            ,AutoMaintenanceBatchProcessMaxCount__c = 200
        );
        insert sysconf;

		//システム変数オブジェクトを作成
		SystemVariables__c systemVariables = new SystemVariables__c(
			VariablesName__c = IS_AUTOMAINTENANCE_BATCHPROCESSING
			,VariablesLabel__c = '自動メンテナンスバッチ処理中フラグ'
		);
		SystemVariables__c systemVariables2 = new SystemVariables__c(
			VariablesName__c = IS_AUTOMAINTENANCE_BATCHPROCESSING2
			,VariablesLabel__c = '自動メンテナンスバッチ処理中フラグ2'
		);
		SystemVariables__c systemVariables3 = new SystemVariables__c(
			VariablesName__c = IS_AUTOMAINTENANCE_BATCHPROCESSING3
			,VariablesLabel__c = '自動メンテナンスバッチ処理中フラグ3'
		);
		SystemVariables__c systemVariables4 = new SystemVariables__c(
			VariablesName__c = IS_AUTOMAINTENANCE_BATCHPROCESSING4
			,VariablesLabel__c = '自動メンテナンスバッチ処理中フラグ4'
		);
		SystemVariables__c systemVariables5 = new SystemVariables__c(
			VariablesName__c = IS_AUTOMAINTENANCE_BATCHPROCESSING5
			,VariablesLabel__c = '自動メンテナンスバッチ処理中フラグ5'
		);
		List <SystemVariables__c> systemVariablesList = new List<SystemVariables__c> {
			systemVariables,systemVariables2,systemVariables3,systemVariables4,systemVariables5
		};
        insert systemVariablesList;

        // 業者
        Account supplier = new Account(
            Name                        = '自動メンテナンス業者',
            recordTypeId                = RECORDTYPE_ID_SUPPLIER,
            MaintenanceSupplierCode__c  = SUPPLIER_MAINT_CODE_EXISTS,
            IsManagementCompany__c      = true
        );
        insert supplier;

        // 建物
        Building__c building = new Building__c(
            Name                       = '自動メンテナンス建物',
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE_EXISTS
        );
        insert building;

        // 物件
        Property__c prop = new Property__c(
            Building__c = building.Id,
            Name        = '自動メンテナンス物件',
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE_EXISTS,
            FormerSupplier__c          = supplier.Id,
            AutoMaintenanceDiffRoomLayoutFileName__c = DIFF_ROOMLAYOUT_FILE_NAME_INIT1,
            RewardBurdenBorrower__c = 3.0, //報酬負担借主テスト用(2022/04/13追記)
            PropertyRemarksPrivate__c = PROP_REMARKS_PRIVATE_INIT1
        );
        insert prop;

        // 物件条件
        PropertyConditions__c propCond = new PropertyConditions__c(
            Property__c = prop.Id,
            FacilityRemarksPrivate__c = FACILITY_REMARKS_PRIVATE_INIT1,
            IsAirConditioner__c       = True
        );
        insert propCond;

        // 建物写真
        BuildingPhoto__c buildingPhoto = new BuildingPhoto__c(
            Building__c = building.Id
        );
        insert buildingPhoto;

        // 物件写真
        PropertyPhoto__c porpPhoto = new PropertyPhoto__c(
            Property__c = prop.Id
        );
        insert porpPhoto;

        // 部屋
        Room__c room = new Room__c(
            Property__c = prop.Id
        );
        insert room;
    }


    // 1:新規
    @isTest static void newRecord() {
        // 自動メンテナンス差分作成(トリガー起動)
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE,
            MaintenanceSupplierCode__c = SUPPLIER_MAINT_CODE,
            BuildingName__c            = '自動メンテ建物',
            PropertyName__c            = '自動メンテ物件',
            ManagementCompanyName__c   = '自動メンテ業者',
            RoomType1__c               = CommonConst.AUTOMAINTEDIFF_ROOMTYPE_K,
            RoomFloorSpace1__c         = 10.0,
            ExcecuteBatchNo__c         = 1
        );
        insert autoMainteDiff;


        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    // 業者データ登録値確認(新規登録)
    @isTest static void checkSupplierNewData() {
        String supplierName             = '自動メンテ業者';
        String supplierAccress          = '愛知県名古屋市名東区上社１丁目２１３−１';
        String supplierState            = '愛知県';
        String supplierCity             = '名古屋市名東区上社１丁目２１３−１';
        String supplierStreet           = null;
        String supplierPhone            = '052-726-3031';
        String supplierFax              = '052-726-3032';
        String supplierLicense          = '管理会社免許';
        String supplierStaffName        = '洞口 太郎';
        String supplierCompanyRemarks   = '管理会社備考';
        String supplierRemarks          = '';
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyLicense__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierLicense + CommonConst.BREAK_CODE;
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyRemarks__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierCompanyRemarks;

        // 自動メンテナンス差分
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c          = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c      = BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c      = PROPERTY_MAINT_CODE,
            MaintenanceSupplierCode__c      = SUPPLIER_MAINT_CODE,
            BuildingName__c                 = '自動メンテ建物',
            PropertyName__c                 = '自動メンテ物件',
            ManagementCompanyName__c        = supplierName,
            ManagementCompanyAddress__c     = supplierAccress,
            ManagementCompanyPhone__c       = supplierPhone,
            ManagementCompanyFax__c         = supplierFax,
            ManagementCompanyLicense__c     = supplierLicense,
            ManagementCompanyStaffName__c   = supplierStaffName,
            ManagementCompanyRemarks__c     = supplierCompanyRemarks,
            ExcecuteBatchNo__c              = 1
        );
        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    // 建物データ登録値確認(新規登録)
    @isTest static void checkBuildingNewData() {
        String BuildingName           = '自動メンテ建物名';                                 // 建物名
        String BuildKana              = 'ｼﾞﾄﾞｳﾒﾝﾃﾀﾃﾓﾉﾒｲ';                                   // 建物名(カナ)
        String ChoazaCode             = '12345678901';                                      // 町字コード
        String State                  = '愛知県';                                           // 都道府県
        String City                   = '名古屋市名東区上社１丁目';                         // 住所１(市区町村)
        String Street                 = '２１３−１';                                        // 住所２(番地)
        Decimal Latitude              = 35.169364;                                          // 緯度
        Decimal Longitude             = 137.002627;                                         // 経度
        String BuildingYM             = '200012';                                           // 築年月
        String PropertyType           = AUTOMAINTEDIFF_PROPERTYTYPE_MANSION;                // 物件種別
        String Structure              = AUTOMAINTEDIFF_STRUCTURE_WOODEN;                    // 建物構造
        Decimal GroundFloorCount      = 100;                                                // 地上階数
        Decimal UndergroundFloorCount = 10;                                                 // 地下階数
        Decimal HouseCount            = 9999;                                               // 棟総戸数
        String CaretakerType          = AUTOMAINTEDIFF_CARETAKERTYPE_RESIDE;                // 管理人種別
        String BuildingRemarksPrivate = '建物備考(非公開)';                                 // 建物備考(非公開)
        // 業者
        String supplierName             = '自動メンテ業者';
        String supplierAccress          = '愛知県名古屋市名東区上社１丁目２１３−１';
        String supplierState            = '愛知県';
        String supplierCity             = '名古屋市名東区上社１丁目２１３−１';
        String supplierStreet           = null;
        String supplierPhone            = '052-726-3031';
        String supplierFax              = '052-726-3032';
        String supplierLicense          = '管理会社免許';
        String supplierStaffName        = '洞口 太郎';
        String supplierCompanyRemarks   = '管理会社備考';
        String supplierRemarks          = '';
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyLicense__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierLicense + CommonConst.BREAK_CODE;
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyRemarks__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierCompanyRemarks;        


        // 自動メンテナンス差分データ作成
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c          = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c      = BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c      = PROPERTY_MAINT_CODE,
            MaintenanceSupplierCode__c      = SUPPLIER_MAINT_CODE,
            PropertyName__c                 = '自動メンテ物件',
            BuildingName__c                 = BuildingName,
            BuildKana__c                    = BuildKana,
            ChoazaCode__c                   = ChoazaCode,
            State__c                        = State,
            City__c                         = City,
            Street__c                       = Street,
            Latitude__c                     = Latitude,
            Longitude__c                    = Longitude,
            BuildingYM__c                   = BuildingYM,
            PropertyType__c                 = PropertyType,
            Structure__c                    = Structure,
            GroundFloorCount__c             = GroundFloorCount,
            UndergroundFloorCount__c        = UndergroundFloorCount,
            HouseCount__c                   = HouseCount,
            CaretakerType__c                = CaretakerType,
            BuildingRemarksPrivate__c       = BuildingRemarksPrivate,
            ManagementCompanyName__c        = supplierName,
            ManagementCompanyAddress__c     = supplierAccress,
            ManagementCompanyPhone__c       = supplierPhone,
            ManagementCompanyFax__c         = supplierFax,
            ManagementCompanyLicense__c     = supplierLicense,
            ManagementCompanyStaffName__c   = supplierStaffName,
            ManagementCompanyRemarks__c     = supplierCompanyRemarks,
            ExcecuteBatchNo__c              = 1
        );

        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    // 物件データ登録値確認(新規登録)
    @isTest static void checkPropertyNewData() {
        String importType   = CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO;       // 取込区分
        String externalSiteCd = CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO; // 外部サイトコード
        String propertyName = '自動メンテ物件';                                 // 部屋番号
        Decimal floor = 100;                                                    // 所在階
        String balconyDirection = AUTOMAINTEDIFF_BALCONYDIRECTION_NORTH;        //  バルコニー方向
        Decimal roomArea = 123.45;                                              // 専有面積
        Decimal balconyArea = 978.65;                                           // バルコニー面積
        Decimal roomCount = 99;                                                 // 部屋数
        String roomLayout = AUTOMAINTEDIFF_ROOMLAYOUT_R;                        // 間取り
        String liveStatus = AUTOMAINTEDIFF_LIVESTATUS_RESIDENT;                 // 現況
        String deliveryType = AUTOMAINTEDIFF_DELIVERYTYPE_DUEDATE;              // 引渡種別
        String deliveryYear = '2020';                                           // 引渡 年
        String deliveryMonth = AUTOMAINTEDIFF_DELIVERYMONTH_JAN;                // 引渡 月
        String deliveryDay = '01';                                              // 引渡 日
        String deliveryTiming = null;                                           // 引渡 旬
        String propertyRemarksPrivate = '物件備考(非公開)';                     // 物件備考(非公開)
        Decimal rentFee = 1234567;                                              // 賃料
        Decimal managementFee = 123456;                                         // 管理費
        String managementFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;           // 管理費税区分
        String securityDepositUnit = AUTOMAINTEDIFF_FEEUNIT_YEN;                // 敷金単位
        Decimal securityDepositMonth = null;                                    // 敷金(ヶ月)
        Decimal securityDepositYen = 1111111;                                   // 敷金(円)
        String keyMoneyUnit = AUTOMAINTEDIFF_FEEUNIT_YEN;                       // 礼金単位
        Decimal keyMoneyMonth = null;                                           // 礼金(ヶ月)
        Decimal keyMoneyYen = 2222222;                                          // 礼金(円)
        String depositUnit = AUTOMAINTEDIFF_FEEUNIT_YEN;                        // 保証料金単位
        Decimal depositMonth = null;                                            // 保証料金(ヶ月)
        Decimal depositYen = 3333333;                                           // 保証料金(円)
        String cancellationActualFeeUnit = AUTOMAINTEDIFF_FEEUNIT_YEN;          // 敷引・償却単位
        Decimal cancellationActualFeeMonth = null;                              // 敷引・償却(ヵ月)
        Decimal cancellationActualFeeRate = null;                               // 敷引・償却(%)
        Decimal cancellationActualFeeYen = 4444444;                             // 敷引・償却(円)
        Decimal renewalFeeMonth = null;                                         // 更新料(ヵ月)
        String renewalFeeUnit = AUTOMAINTEDIFF_FEEUNIT_YEN;                     // 更新料単位
        String renewalFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;              // 更新料税区分
        Decimal renewalFeeYen = 5555555;                                        // 更新料(円)
        Decimal keyExchangeFee = 666666;                                        // 鍵交換費
        String keyExchangeFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;          // 鍵交換費税区分
        Decimal wortFee = 777777;                                               // 水道料金
        String wortFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;                 // 水道料金税区分
        Decimal townshipFee = 888888;                                           // 町会費
        String townshipFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;             // 町会費税区分
        String townshipFeePaymentType = AUTOMAINTEDIFF_PAYMENTTYPE_MONTH;       // 町会費支払区分
        Decimal CATVFee = 9999999;                                              // CATV
        String CATVTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;                    // CATV税区分
        Decimal cleaningFeeYen = 1111111;                                       // 定額修繕費(円)
        Decimal cleaningFeeMonth = null;                                        // 定額修繕費(ヵ月)
        String cleaningFeeUnit = AUTOMAINTEDIFF_FEEUNIT_YEN;                    // 定額修繕費単位
        String cleaningFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;             // 定額修繕費税区分
        String cleaningFeePaymentType = AUTOMAINTEDIFF_PAYMENTTYPE_BEFORE_OCCUPANCY;    // 定額修繕費支払区分
        String guaranteeidCompanyType = AUTOMAINTEDIFF_GUARANTEEIDCOMPANYTYPE_REQUIRED; // 保証会社(利用区分)
        String monetaryPrivate = '金銭備考(非公開)';                            // 金銭備考(非公開)
        String parkingType = AUTOMAINTEDIFF_PARKINGTYPE_NEIGHBORHOOD_SECURE;    // 駐車場種別
        Decimal parkingDistance = 22222;                                        // 近隣駐車場までの距離
        Decimal parkingFee = 333333;                                            // 駐車場料金
        String parkingFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;              // 駐車場料金税区分
        String parkingRemarksPrivate = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;          // 駐車場備考(非公開)
        String keyPlace = '鍵所在';                                             // 鍵所在
        Decimal rewardBurdenLender = 4.44;                                      // 報酬負担貸主
        Decimal rewardBurdenBorrower = 5.55;                                    // 報酬負担借主
        Decimal rewardSplitFormerSupplier = 6.66;                               // 報酬配分元付
        Decimal rewardSplitCustomer = 7.77;                                     // 報酬配分客付
        String ADRemarksPrivate = '広告備考(非公開)';                           // 広告備考(非公開)
        String webPublishing = AUTOMAINTEDIFF_WEBPUBLISHING_NO;                 // web公開　
        String supplierName             = '自動メンテ業者';
        String supplierAccress          = '愛知県名古屋市名東区上社１丁目２１３−１';
        String supplierState            = '愛知県';
        String supplierCity             = '名古屋市名東区上社１丁目２１３−１';
        String supplierStreet           = null;
        String supplierPhone            = '052-726-3031';
        String supplierFax              = '052-726-3032';
        String supplierLicense          = '管理会社免許';
        String supplierStaffName        = '洞口 太郎';
        String supplierCompanyRemarks   = '管理会社備考';
        String supplierRemarks          = '';
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyLicense__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierLicense + CommonConst.BREAK_CODE;
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyRemarks__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierCompanyRemarks;





        // 自動メンテナンス差分作成(トリガー起動)
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c          = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c      = BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c      = PROPERTY_MAINT_CODE,
            MaintenanceSupplierCode__c      = SUPPLIER_MAINT_CODE,
            BuildingName__c                 = '自動メンテ建物',
            PropertyName__c                 = propertyName,
            ExternalSiteCd__c               = externalSiteCd,
            Floor__c                        = floor,
            BalconyDirection__c             = balconyDirection,
            RoomArea__c                     = roomArea,
            BalconyArea__c                  = balconyArea,
            RoomCount__c                    = roomCount,
            RoomLayout__c                   = roomLayout,
            LiveStatus__c                   = liveStatus,
            DeliveryType__c                 = deliveryType,
            DeliveryYear__c                 = deliveryYear,
            DeliveryMonth__c                = deliveryMonth,
            DeliveryDay__c                  = deliveryDay,
            DeliveryTiming__c               = deliveryTiming,
            PropertyRemarksPrivate__c       = propertyRemarksPrivate,
            RentFee__c                      = rentFee,
            ManagementFee__c                = managementFee,
            ManagementFeeTaxType__c         = managementFeeTaxType,
            SecurityDepositUnit__c          = securityDepositUnit,
            SecurityDepositMonth__c         = securityDepositMonth,
            SecurityDepositYen__c           = securityDepositYen,
            KeyMoneyUnit__c                 = keyMoneyUnit,
            KeyMoneyMonth__c                = keyMoneyMonth,
            KeyMoneyYen__c                  = keyMoneyYen,
            DepositUnit__c                  = depositUnit,
            DepositMonth__c                 = depositMonth,
            DepositYen__c                   = depositYen,
            CancellationActualFeeUnit__c    = cancellationActualFeeUnit,
            CancellationActualFeeMonth__c   = cancellationActualFeeMonth,
            CancellationActualFeeRate__c    = cancellationActualFeeRate,
            CancellationActualFeeYen__c     = cancellationActualFeeYen,
            RenewalFeeMonth__c              = renewalFeeMonth,
            RenewalFeeUnit__c               = renewalFeeUnit,
            RenewalFeeTaxType__c            = renewalFeeTaxType,
            RenewalFeeYen__c                = renewalFeeYen,
            KeyExchangeFee__c               = keyExchangeFee,
            KeyExchangeFeeTaxType__c        = keyExchangeFeeTaxType,
            WortFee__c                      = wortFee,
            WortFeeTaxType__c               = wortFeeTaxType,
            TownshipFee__c                  = townshipFee,
            TownshipFeeTaxType__c           = townshipFeeTaxType,
            TownshipFeePaymentType__c       = townshipFeePaymentType,
            CATVFee__c                      = CATVFee,
            CATVTaxType__c                  = CATVTaxType,
            CleaningFeeYen__c               = cleaningFeeYen,
            CleaningFeeMonth__c             = cleaningFeeMonth,
            CleaningFeeUnit__c              = cleaningFeeUnit,
            CleaningFeeTaxType__c           = cleaningFeeTaxType,
            CleaningFeePaymentType__c       = cleaningFeePaymentType,
            GuaranteeidCompanyType__c       = guaranteeidCompanyType,
            MonetaryRemarksPrivate__c       = monetaryPrivate,
            ParkingType__c                  = parkingType,
            ParkingDistance__c              = parkingDistance,
            ParkingFee__c                   = parkingFee,
            ParkingFeeTaxType__c            = parkingFeeTaxType,
            ParkingRemarksPrivate__c        = parkingRemarksPrivate,
            KeyPlace__c                     = keyPlace,
            RewardBurdenLender__c           = rewardBurdenLender,
            RewardBurdenBorrower__c         = rewardBurdenBorrower,
            RewardSplitFormerSupplier__c    = rewardSplitFormerSupplier,
            RewardSplitCustomer__c          = rewardSplitCustomer,
            ADRemarksPrivate__c             = ADRemarksPrivate,
            ManagementCompanyName__c        = supplierName,
            ManagementCompanyAddress__c     = supplierAccress,
            ManagementCompanyPhone__c       = supplierPhone,
            ManagementCompanyFax__c         = supplierFax,
            ManagementCompanyLicense__c     = supplierLicense,
            ManagementCompanyStaffName__c   = supplierStaffName,
            ManagementCompanyRemarks__c     = supplierCompanyRemarks,
            ExcecuteBatchNo__c              = 1
        );
        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();

        // 登録値確認
        // 2021.02.25 Y.Hirata追加
        // AutoMaintenanceUtilの都道府県リストをシステム設定から取得するように変更したため、ここで登録値を確認する
        Account ac = [SELECT Id, State__c, City__c FROM Account WHERE Name = :supplierName LIMIT 1];
        System.assertEquals(supplierState, ac.State__c, '物件データ登録値確認(新規登録) 登録値確認：都道府県');
        System.assertEquals(supplierCity,  ac.City__c,  '物件データ登録値確認(新規登録) 登録値確認：住所１');
    }

    // 物件条件データ登録値確認（新規登録）
    @isTest static void checkPropCondNewData() {
        String facilityRemarksPrivate = '設備備考(非公開)';
        // 物件条件の作成（全てチェック）
        List<String> facilityApiList   = new List<String>();
        List<String> facilityLableList = new List<String>();
        Map<String, Schema.SObjectField> propCondFieldMap = Schema.getGlobalDescribe().get('PropertyConditions__c').getDescribe().fields.getMap();
        Map<String, String> customCheckBoxFieldName = new Map<String, String>();
        for (String apiName : propCondFieldMap.keySet()) {
            // 項目定義情報取得
            Schema.SObjectField sof = propCondFieldMap.get(apiName);
            Boolean isCustom = sof.getDescribe().isCustom();        // カスタム項目フラグ
            Schema.DisplayType type = sof.getDescribe().getType();  // データ型
            // カスタムチェックボックス項目の、API名・表示名をMapに保持
            if (isCustom && type == Schema.DisplayType.BOOLEAN) {
                facilityApiList.add(apiName);
                facilityLableList.add(sof.getDescribe().getLabel());
            }
        }
        String facility = String.join(facilityLableList,';');

        // 自動メンテナンス差分作成(トリガー起動)
        t_auto_maintenance_difference__c autoMeinteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE,
            MaintenanceSupplierCode__c = SUPPLIER_MAINT_CODE,
            BuildingName__c            = '自動メンテ建物',
            PropertyName__c            = '自動メンテ物件',
            ManagementCompanyName__c   = '自動メンテ業者',
            Facility__c                = facility,
            FacilityRemarksPrivate__c  = facilityRemarksPrivate,
            ExcecuteBatchNo__c         = 1
        );
        Insert autoMeinteDiff;


        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    // 部屋データ登録値確認（新規登録）
    @isTest static void checkRoomNewData() {
        // 登録値
        String roomType = CommonConst.AUTOMAINTEDIFF_ROOMTYPE_K;

        // 自動メンテナンス差分作成
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE,
            MaintenanceSupplierCode__c = SUPPLIER_MAINT_CODE,
            BuildingName__c            = '自動メンテ建物',
            PropertyName__c            = '自動メンテ物件',
            ManagementCompanyName__c   = '自動メンテ業者',
            ExcecuteBatchNo__c         = 1
        );
        // 部屋設定
        for (Integer i = 1; i <= AUTOMAINTEDIFF_ROOM_MAXCOUNT; i++) {
            autoMainteDiff.put('RoomType' + i + '__c', roomType);
            autoMainteDiff.put('RoomFloorSpace' + i + '__c', i * 10.1);
        }

        // 自動メンテナンス差分作成（トリガー起動）
        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    // 建物写真データ登録確認（新規）
    @isTest static void checkBuildingPhotoNewData() {
        String buildingPhotoFileName1  = '建物写真ファイル名1';
        String buildingPhotoFileName2  = '建物写真ファイル名2';
        String buildingPhotoFileName3  = '建物写真ファイル名3';
        String buildingPhotoFileName4  = '建物写真ファイル名4';
        String buildingPhotoFileName5  = '建物写真ファイル名5';
        String buildingPhotoFileName6  = '建物写真ファイル名6';
        String buildingPhotoFileName7  = '建物写真ファイル名7';
        String buildingPhotoFileName8  = '建物写真ファイル名8';
        String buildingPhotoFileName9  = '建物写真ファイル名9';
        String buildingPhotoFileName10 = '建物写真ファイル名10';
        String buildingTag1            = CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_APPEARANCE;         // 建物外観
        String buildingTag2            = CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_APPEARANCE_PARSE;   // 外観パース
        String buildingTag3            = CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_ENTRANCE;           // エントランス
        String buildingTag4            = CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_LOBBY;              // ロビー
        String buildingTag5            = CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_PARKING;            // 駐車場
        String buildingTag6            = CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_MAP;                // 地図
        String buildingTag7            = CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_OTHERSHARING;       // その他共有部分
        String buildingTag8            = CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_SURROUNDING;        // 周辺写真
        String buildingTag9            = CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_SURROUNDING;        // 周辺写真
        String buildingTag10           = CommonConst.AUTOMAINTDIFF_BUILDINGPHOTOTAG_OTHER;              // その他
        String buildingComment1        = '建物写真コメント1';
        String buildingComment2        = '建物写真コメント2';
        String buildingComment3        = '建物写真コメント3';
        String buildingComment4        = '建物写真コメント4';
        String buildingComment5        = '建物写真コメント5';
        String buildingComment6        = '建物写真コメント6';
        String buildingComment7        = '建物写真コメント7';
        String buildingComment8        = '建物写真コメント8';
        String buildingComment9        = '建物写真コメント9';
        String buildingComment10       = '建物写真コメント10';


        // 自動メンテナンス差分作成
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE,
            MaintenanceSupplierCode__c = SUPPLIER_MAINT_CODE,
            BuildingName__c            = '自動メンテ建物',
            PropertyName__c            = '自動メンテ物件',
            ManagementCompanyName__c   = '自動メンテ業者',
            BuildingPhotoFileName1__c  = buildingPhotoFileName1,
            BuildingPhotoFileName2__c  = buildingPhotoFileName2,
            BuildingPhotoFileName3__c  = buildingPhotoFileName3,
            BuildingPhotoFileName4__c  = buildingPhotoFileName4,
            BuildingPhotoFileName5__c  = buildingPhotoFileName5,
            BuildingPhotoFileName6__c  = buildingPhotoFileName6,
            BuildingPhotoFileName7__c  = buildingPhotoFileName7,
            BuildingPhotoFileName8__c  = buildingPhotoFileName8,
            BuildingPhotoFileName9__c  = buildingPhotoFileName9,
            BuildingPhotoFileName10__c = buildingPhotoFileName10,
            BuildingTag1__c            = buildingTag1,
            BuildingTag2__c            = buildingTag2,
            BuildingTag3__c            = buildingTag3,
            BuildingTag4__c            = buildingTag4,
            BuildingTag5__c            = buildingTag5,
            BuildingTag6__c            = buildingTag6,
            BuildingTag7__c            = buildingTag7,
            BuildingTag8__c            = buildingTag8,
            BuildingTag9__c            = buildingTag9,
            BuildingTag10__c           = buildingTag10,
            BuildingComment1__c        = buildingComment1,
            BuildingComment2__c        = buildingComment2,
            BuildingComment3__c        = buildingComment3,
            BuildingComment4__c        = buildingComment4,
            BuildingComment5__c        = buildingComment5,
            BuildingComment6__c        = buildingComment6,
            BuildingComment7__c        = buildingComment7,
            BuildingComment8__c        = buildingComment8,
            BuildingComment9__c        = buildingComment9,
            BuildingComment10__c       = buildingComment10,
            ExcecuteBatchNo__c         = 1
        );
        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    // 物件写真データ登録確認１（新規）※玄関まで
    @isTest static void checkPropertyPhotoNewData1() {
        String roomLayoutFileName  = '間取図ファイル';
        String propPhotoFileName1  = '物件写真ファイル名1';
        String propPhotoFileName2  = '物件写真ファイル名2';
        String propPhotoFileName3  = '物件写真ファイル名3';
        String propPhotoFileName4  = '物件写真ファイル名4';
        String propPhotoFileName5  = '物件写真ファイル名5';
        String propPhotoFileName6  = '物件写真ファイル名6';
        String propPhotoFileName7  = '物件写真ファイル名7';
        String propPhotoFileName8  = '物件写真ファイル名8';
        String propPhotoFileName9  = '物件写真ファイル名9';
        String propPhotoFileName10 = '物件写真ファイル名10';
        String roomLaoyoutTag      = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_ROOMLAYOUT; // 間取り
        String propPhotoTag1       = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_LIVING;     // 居室・リビング
        String propPhotoTag2       = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_OTHERROOM;  // その他部屋・スペース
        String propPhotoTag3       = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_KITCHEN;    // キッチン
        String propPhotoTag4       = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_BATH;       // バス・シャワールーム
        String propPhotoTag5       = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_TOILET;     // トイレ
        String propPhotoTag6       = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_WASHROOM;   // 洗面設備
        String propPhotoTag7       = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_STORAGE;    // 収納
        String propPhotoTag8       = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_BALCONY;    // バルコニー
        String propPhotoTag9       = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_GARDEN;     // 庭
        String propPhotoTag10      = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_ENTRANCE;   // 玄関
        String propPhotoComment1   = '物件写真コメント1';
        String propPhotoComment2   = '物件写真コメント2';
        String propPhotoComment3   = '物件写真コメント3';
        String propPhotoComment4   = '物件写真コメント4';
        String propPhotoComment5   = '物件写真コメント5';
        String propPhotoComment6   = '物件写真コメント6';
        String propPhotoComment7   = '物件写真コメント7';
        String propPhotoComment8   = '物件写真コメント8';
        String propPhotoComment9   = '物件写真コメント9';
        String propPhotoComment10  = '物件写真コメント10';
        String supplierName             = '自動メンテ業者';
        String supplierAccress          = '愛知県名古屋市名東区上社１丁目２１３−１';
        String supplierState            = '愛知県';
        String supplierCity             = '名古屋市名東区上社１丁目２１３−１';
        String supplierStreet           = null;
        String supplierPhone            = '052-726-3031';
        String supplierFax              = '052-726-3032';
        String supplierLicense          = '管理会社免許';
        String supplierStaffName        = '洞口 太郎';
        String supplierCompanyRemarks   = '管理会社備考';
        String supplierRemarks          = '';
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyLicense__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierLicense + CommonConst.BREAK_CODE;
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyRemarks__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierCompanyRemarks;


        // 自動メンテナンス差分作成
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE,
            MaintenanceSupplierCode__c = SUPPLIER_MAINT_CODE,
            BuildingName__c            = '自動メンテ建物',
            PropertyName__c            = '自動メンテ物件',
            RoomLayoutFileName__c      = roomLayoutFileName,
            RoomLayoutTag__c           = roomLaoyoutTag,
            PropertyPhotoFileName1__c  = propPhotoFileName1,
            PropertyPhotoFileName2__c  = propPhotoFileName2,
            PropertyPhotoFileName3__c  = propPhotoFileName3,
            PropertyPhotoFileName4__c  = propPhotoFileName4,
            PropertyPhotoFileName5__c  = propPhotoFileName5,
            PropertyPhotoFileName6__c  = propPhotoFileName6,
            PropertyPhotoFileName7__c  = propPhotoFileName7,
            PropertyPhotoFileName8__c  = propPhotoFileName8,
            PropertyPhotoFileName9__c  = propPhotoFileName9,
            PropertyPhotoFileName10__c = propPhotoFileName10,
            PropertyTag1__c            = propPhotoTag1,
            PropertyTag2__c            = propPhotoTag2,
            PropertyTag3__c            = propPhotoTag3,
            PropertyTag4__c            = propPhotoTag4,
            PropertyTag5__c            = propPhotoTag5,
            PropertyTag6__c            = propPhotoTag6,
            PropertyTag7__c            = propPhotoTag7,
            PropertyTag8__c            = propPhotoTag8,
            PropertyTag9__c            = propPhotoTag9,
            PropertyTag10__c           = propPhotoTag10,
            PropertyComment1__c        = propPhotoComment1,
            PropertyComment2__c        = propPhotoComment2,
            PropertyComment3__c        = propPhotoComment3,
            PropertyComment4__c        = propPhotoComment4,
            PropertyComment5__c        = propPhotoComment5,
            PropertyComment6__c        = propPhotoComment6,
            PropertyComment7__c        = propPhotoComment7,
            PropertyComment8__c        = propPhotoComment8,
            PropertyComment9__c        = propPhotoComment9,
            PropertyComment10__c       = propPhotoComment10,
            ManagementCompanyName__c        = supplierName,
            ManagementCompanyAddress__c     = supplierAccress,
            ManagementCompanyPhone__c       = supplierPhone,
            ManagementCompanyFax__c         = supplierFax,
            ManagementCompanyLicense__c     = supplierLicense,
            ManagementCompanyStaffName__c   = supplierStaffName,
            ManagementCompanyRemarks__c     = supplierCompanyRemarks,
            ExcecuteBatchNo__c              = 1
        );
        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
        
    }

    // 物件写真データ登録確認２（新規）※セキュリティ;その他設備;眺望;その他
    @isTest static void checkPropertyPhotoNewData2() {
        String propPhotoFileName1  = '物件写真ファイル名1';
        String propPhotoFileName2  = '物件写真ファイル名2';
        String propPhotoFileName3  = '物件写真ファイル名3';
        String propPhotoFileName4  = '物件写真ファイル名4';
        String propPhotoTag1       = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_SECURITY;      // セキュリティ
        String propPhotoTag2       = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_OTHERFACILITY; // その他設備
        String propPhotoTag3       = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_VIEW;          // 眺望
        String propPhotoTag4       = CommonConst.AUTOMAINTEDIFF_PROPERTYPHOTOTAG_OTHER;         // その他
        String propPhotoComment1   = '物件写真コメント1';
        String propPhotoComment2   = '物件写真コメント2';
        String propPhotoComment3   = '物件写真コメント3';
        String propPhotoComment4   = '物件写真コメント4';
        String supplierName             = '自動メンテ業者';
        String supplierAccress          = '愛知県名古屋市名東区上社１丁目２１３−１';
        String supplierState            = '愛知県';
        String supplierCity             = '名古屋市名東区上社１丁目２１３−１';
        String supplierStreet           = null;
        String supplierPhone            = '052-726-3031';
        String supplierFax              = '052-726-3032';
        String supplierLicense          = '管理会社免許';
        String supplierStaffName        = '洞口 太郎';
        String supplierCompanyRemarks   = '管理会社備考';
        String supplierRemarks          = '';
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyLicense__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierLicense + CommonConst.BREAK_CODE;
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyRemarks__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierCompanyRemarks;        

        // 自動メンテナンス差分作成
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE,
            MaintenanceSupplierCode__c = SUPPLIER_MAINT_CODE,
            BuildingName__c            = '自動メンテ建物',
            PropertyName__c            = '自動メンテ物件',
            PropertyPhotoFileName1__c  = propPhotoFileName1,
            PropertyPhotoFileName2__c  = propPhotoFileName2,
            PropertyPhotoFileName3__c  = propPhotoFileName3,
            PropertyPhotoFileName4__c  = propPhotoFileName4,
            PropertyTag1__c            = propPhotoTag1,
            PropertyTag2__c            = propPhotoTag2,
            PropertyTag3__c            = propPhotoTag3,
            PropertyTag4__c            = propPhotoTag4,
            PropertyComment1__c        = propPhotoComment1,
            PropertyComment2__c        = propPhotoComment2,
            PropertyComment3__c        = propPhotoComment3,
            PropertyComment4__c        = propPhotoComment4,
            ManagementCompanyName__c        = supplierName,
            ManagementCompanyAddress__c     = supplierAccress,
            ManagementCompanyPhone__c       = supplierPhone,
            ManagementCompanyFax__c         = supplierFax,
            ManagementCompanyLicense__c     = supplierLicense,
            ManagementCompanyStaffName__c   = supplierStaffName,
            ManagementCompanyRemarks__c     = supplierCompanyRemarks,
            ExcecuteBatchNo__c              = 1
        );
        insert autoMainteDiff;
        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    // 自動メンテナンス登録確認
    @isTest static void checkAutoMaintenanceNewData() {
        // 自動メンテナンス差分作成(トリガー起動)
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE,
            MaintenanceSupplierCode__c = SUPPLIER_MAINT_CODE,
            BuildingName__c            = '自動メンテ建物',
            PropertyName__c            = '自動メンテ物件',
            ManagementCompanyName__c   = '自動メンテ業者',
            ExternalSiteCd__c          = CommonConst.AUTOMAINTEDIFF_SITECODE_DAIWALIVING,
            ExcecuteBatchNo__c         = 1
        );
        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    // 条件変更
    @isTest static void changeConditions() {
        // 自動メンテナンス差分作成(トリガー起動)
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION,
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE_EXISTS,
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE_EXISTS,
            MaintenanceSupplierCode__c = SUPPLIER_MAINT_CODE_EXISTS,
            BuildingName__c            = '自動メンテ建物',
            PropertyName__c            = '自動メンテ物件',
            ManagementCompanyName__c   = '自動メンテ業者',
            RoomType1__c               = CommonConst.AUTOMAINTEDIFF_ROOMTYPE_K,
            RoomFloorSpace1__c         = 10.0,
            ExcecuteBatchNo__c         = 1
        );
        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    // 4:居住中→空室
    @isTest static void roomEmpty() {
        // 自動メンテナンス差分作成(トリガー起動)
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_LIVESTATUS_EMPTY,
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE_EXISTS,
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE_EXISTS,
            MaintenanceSupplierCode__c = SUPPLIER_MAINT_CODE_EXISTS + '2',
            BuildingName__c            = '自動メンテ建物',
            PropertyName__c            = '自動メンテ物件',
            ManagementCompanyName__c   = '自動メンテ業者',
            RoomType1__c               = CommonConst.AUTOMAINTEDIFF_ROOMTYPE_K,
            RoomFloorSpace1__c         = 10.0,
            ExcecuteBatchNo__c         = 1
        );
        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    // 5:掲載終了
    @isTest static void roomPostingEnd() {
        // 自動メンテナンス差分作成(トリガー起動)
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END,
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE_EXISTS,
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE_EXISTS,
            MaintenanceSupplierCode__c = SUPPLIER_MAINT_CODE_EXISTS,
            BuildingName__c            = '自動メンテ建物',
            PropertyName__c            = '自動メンテ物件',
            ManagementCompanyName__c   = '自動メンテ業者',
            RoomType1__c               = CommonConst.AUTOMAINTEDIFF_ROOMTYPE_K,
            RoomFloorSpace1__c         = 10.0,
            ExcecuteBatchNo__c         = 1
        );
        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    // 物件賃料項目　ヵ月
    @isTest static void propertyMoneyMonth() {
        String importType                   = CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO;       // 取込区分
        String externalSiteCd               = CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO;   // 外部サイトコード
        String propertyName                 = '自動メンテ物件';                                 // 部屋番号
        String deliveryType                 = AUTOMAINTEDIFF_DELIVERYTYPE_DUEDATE;              // 引渡種別
        String deliveryYear                 = '2020';                                           // 引渡 年
        String deliveryMonth                = AUTOMAINTEDIFF_DELIVERYMONTH_JAN;                 // 引渡 月
        String deliveryTiming               = AUTOMAINTEDIFF_DELIVERYTIMING_EARLY;              // 引渡 旬
        Decimal rentFee                     = 123456;                                           // 賃料
        String securityDepositUnit          = AUTOMAINTEDIFF_FEEUNIT_MONTH;                     // 敷金単位
        Decimal securityDepositMonth        = 1.2;                                              // 敷金(ヶ月)
        String keyMoneyUnit                 = AUTOMAINTEDIFF_FEEUNIT_MONTH;                     // 礼金単位
        Decimal keyMoneyMonth               = 3.4;                                              // 礼金(ヶ月)
        String depositUnit                  = AUTOMAINTEDIFF_FEEUNIT_MONTH;                     // 保証料金単位
        Decimal depositMonth                = 5.6;                                              // 保証料金(ヶ月)
        String cancellationActualFeeUnit    = AUTOMAINTEDIFF_FEEUNIT_MONTH;                     // 敷引・償却単位
        Decimal cancellationActualFeeMonth  = 7.8;                                              // 敷引・償却(ヵ月)
        Decimal renewalFeeMonth             = 9.0;                                              // 更新料(ヵ月)
        String renewalFeeUnit               = AUTOMAINTEDIFF_FEEUNIT_MONTH;                     // 更新料単位
        String renewalFeeTaxType            = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;                   // 更新料税区分
        Decimal cleaningFeeMonth            = 11.2;                                             // 定額修繕費(ヵ月)
        String cleaningFeeUnit              = AUTOMAINTEDIFF_FEEUNIT_MONTH;                     // 定額修繕費単位
        String cleaningFeeTaxType           = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;                   // 定額修繕費税区分
        String supplierName             = '自動メンテ業者';
        String supplierAccress          = '愛知県名古屋市名東区上社１丁目２１３−１';
        String supplierState            = '愛知県';
        String supplierCity             = '名古屋市名東区上社１丁目２１３−１';
        String supplierStreet           = null;
        String supplierPhone            = '052-726-3031';
        String supplierFax              = '052-726-3032';
        String supplierLicense          = '管理会社免許';
        String supplierStaffName        = '洞口 太郎';
        String supplierCompanyRemarks   = '管理会社備考';
        String supplierRemarks          = '';
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyLicense__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierLicense + CommonConst.BREAK_CODE;
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyRemarks__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierCompanyRemarks;

        // 自動メンテナンス差分作成(トリガー起動)
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c          = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c      = BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c      = PROPERTY_MAINT_CODE,
            MaintenanceSupplierCode__c      = SUPPLIER_MAINT_CODE,
            BuildingName__c                 = '自動メンテ建物',
            PropertyName__c                 = propertyName,
            ExternalSiteCd__c               = externalSiteCd,
            DeliveryType__c                 = deliveryType,
            DeliveryYear__c                 = deliveryYear,
            DeliveryMonth__c                = deliveryMonth,
            DeliveryTiming__c               = deliveryTiming,
            RentFee__c                      = rentFee,
            SecurityDepositUnit__c          = securityDepositUnit,
            SecurityDepositMonth__c         = securityDepositMonth,
            KeyMoneyUnit__c                 = keyMoneyUnit,
            KeyMoneyMonth__c                = keyMoneyMonth,
            DepositUnit__c                  = depositUnit,
            DepositMonth__c                 = depositMonth,
            CancellationActualFeeUnit__c    = cancellationActualFeeUnit,
            CancellationActualFeeMonth__c   = cancellationActualFeeMonth,
            RenewalFeeMonth__c              = renewalFeeMonth,
            RenewalFeeUnit__c               = renewalFeeUnit,
            RenewalFeeTaxType__c            = renewalFeeTaxType,
            CleaningFeeMonth__c             = cleaningFeeMonth,
            CleaningFeeUnit__c              = cleaningFeeUnit,
            CleaningFeeTaxType__c           = cleaningFeeTaxType,
            ManagementCompanyName__c        = supplierName,
            ManagementCompanyAddress__c     = supplierAccress,
            ManagementCompanyPhone__c       = supplierPhone,
            ManagementCompanyFax__c         = supplierFax,
            ManagementCompanyLicense__c     = supplierLicense,
            ManagementCompanyStaffName__c   = supplierStaffName,
            ManagementCompanyRemarks__c     = supplierCompanyRemarks,
            ExcecuteBatchNo__c              = 1
        );
        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    // 物件データ登録値確認(新規登録)
    @isTest static void checkPropertyNewDataTEST() {
        String importType   = CommonConst.PROPERTY_IMPORTTYPE_REALNETPRO;       // 取込区分
        String externalSiteCd = CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO; // 外部サイトコード
        String propertyName = '自動メンテ物件';                                 // 部屋番号
        Decimal floor = 100;                                                    // 所在階
        String balconyDirection = AUTOMAINTEDIFF_BALCONYDIRECTION_NORTH;        //  バルコニー方向
        Decimal roomArea = 123.45;                                              // 専有面積
        Decimal balconyArea = 978.65;                                           // バルコニー面積
        Decimal roomCount = 99;                                                 // 部屋数
        String roomLayout = AUTOMAINTEDIFF_ROOMLAYOUT_R;                        // 間取り
        String liveStatus = AUTOMAINTEDIFF_LIVESTATUS_RESIDENT;                 // 現況
        String deliveryType = AUTOMAINTEDIFF_DELIVERYTYPE_DUEDATE;              // 引渡種別
        String deliveryYear = '2020';                                           // 引渡 年
        String deliveryMonth = AUTOMAINTEDIFF_DELIVERYMONTH_JAN;                // 引渡 月
        String deliveryDay = '01';                                              // 引渡 日
        String deliveryTiming = null;                                           // 引渡 旬
        String propertyRemarksPrivate = '物件備考(非公開)';                     // 物件備考(非公開)
        Decimal rentFee = 150000;                                              // 賃料
        Decimal managementFee = null;                                         // 管理費
        String managementFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;           // 管理費税区分
        String securityDepositUnit = AUTOMAINTEDIFF_FEEUNIT_MONTH;                // 敷金単位
        Decimal securityDepositMonth = 1.1;                                    // 敷金(ヶ月)        
        String keyMoneyUnit = AUTOMAINTEDIFF_FEEUNIT_MONTH;                       // 礼金単位
        Decimal keyMoneyMonth = 2.2;                                           // 礼金(ヶ月)
        String depositUnit = AUTOMAINTEDIFF_FEEUNIT_MONTH;                        // 保証料金単位
        Decimal depositMonth = 3.3;                                            // 保証料金(ヶ月)
        String cancellationActualFeeUnit = AUTOMAINTEDIFF_FEEUNIT_MONTH;          // 敷引・償却単位
        Decimal cancellationActualFeeMonth = 4.4;                              // 敷引・償却(ヵ月)
        Decimal cancellationActualFeeRate = null;                               // 敷引・償却(%)
        Decimal renewalFeeMonth = 5.5;                                         // 更新料(ヵ月)
        String renewalFeeUnit = AUTOMAINTEDIFF_FEEUNIT_MONTH;                     // 更新料単位
        String renewalFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;              // 更新料税区分
        Decimal keyExchangeFee = 666666;                                        // 鍵交換費
        String keyExchangeFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;          // 鍵交換費税区分
        Decimal wortFee = 777777;                                               // 水道料金
        String wortFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;                 // 水道料金税区分
        Decimal townshipFee = 10000;                                           // 町会費
        String townshipFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;             // 町会費税区分
        String townshipFeePaymentType = AUTOMAINTEDIFF_PAYMENTTYPE_MONTH;       // 町会費支払区分
        Decimal CATVFee = 1000;                                              // CATV
        String CATVTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;                    // CATV税区分
        Decimal cleaningFeeMonth = 6.6;                                        // 定額修繕費(ヵ月)
        String cleaningFeeUnit = AUTOMAINTEDIFF_FEEUNIT_MONTH;                    // 定額修繕費単位
        String cleaningFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;             // 定額修繕費税区分
        String cleaningFeePaymentType = AUTOMAINTEDIFF_PAYMENTTYPE_BEFORE_OCCUPANCY;    // 定額修繕費支払区分
        String guaranteeidCompanyType = AUTOMAINTEDIFF_GUARANTEEIDCOMPANYTYPE_REQUIRED; // 保証会社(利用区分)
        String monetaryPrivate = '金銭備考(非公開)';                            // 金銭備考(非公開)
        String parkingType = AUTOMAINTEDIFF_PARKINGTYPE_NEIGHBORHOOD_SECURE;    // 駐車場種別
        Decimal parkingDistance = 22222;                                        // 近隣駐車場までの距離
        Decimal parkingFee = 333333;                                            // 駐車場料金
        String parkingFeeTaxType = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;              // 駐車場料金税区分
        String parkingRemarksPrivate = AUTOMAINTEDIFF_TAXTYPE_TAXABLE;          // 駐車場備考(非公開)
        String keyPlace = '鍵所在';                                             // 鍵所在
        Decimal rewardBurdenLender = 4.44;                                      // 報酬負担貸主
        Decimal rewardBurdenBorrower = 5.55;                                    // 報酬負担借主
        Decimal rewardSplitFormerSupplier = 6.66;                               // 報酬配分元付
        Decimal rewardSplitCustomer = 7.77;                                     // 報酬配分客付
        String ADRemarksPrivate = '広告備考(非公開)';                           // 広告備考(非公開)
        String webPublishing = AUTOMAINTEDIFF_WEBPUBLISHING_NO;                 // web公開

        String supplierName             = '自動メンテ業者';
        String supplierAccress          = '愛知県名古屋市名東区上社１丁目２１３−１';
        String supplierState            = '愛知県';
        String supplierCity             = '名古屋市名東区上社１丁目２１３−１';
        String supplierStreet           = null;
        String supplierPhone            = '052-726-3031';
        String supplierFax              = '052-726-3032';
        String supplierLicense          = '管理会社免許';
        String supplierStaffName        = '洞口 太郎';
        String supplierCompanyRemarks   = '管理会社備考';
        String supplierRemarks          = '';
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyLicense__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierLicense + CommonConst.BREAK_CODE;
        supplierRemarks += t_auto_maintenance_difference__c.ManagementCompanyRemarks__c.getDescribe().getlabel() + ':';
        supplierRemarks += supplierCompanyRemarks;



        // 自動メンテナンス差分作成(トリガー起動)
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c          = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c      = BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c      = PROPERTY_MAINT_CODE,
            MaintenanceSupplierCode__c      = SUPPLIER_MAINT_CODE,
            BuildingName__c                 = '自動メンテ建物',
            PropertyName__c                 = propertyName,
            ExternalSiteCd__c               = externalSiteCd,
            Floor__c                        = floor,
            BalconyDirection__c             = balconyDirection,
            RoomArea__c                     = roomArea,
            BalconyArea__c                  = balconyArea,
            RoomCount__c                    = roomCount,
            RoomLayout__c                   = roomLayout,
            LiveStatus__c                   = liveStatus,
            DeliveryType__c                 = deliveryType,
            DeliveryYear__c                 = deliveryYear,
            DeliveryMonth__c                = deliveryMonth,
            DeliveryDay__c                  = deliveryDay,
            DeliveryTiming__c               = deliveryTiming,
            PropertyRemarksPrivate__c       = propertyRemarksPrivate,
            RentFee__c                      = rentFee,
            ManagementFee__c                = managementFee,
            ManagementFeeTaxType__c         = managementFeeTaxType,
            SecurityDepositUnit__c          = securityDepositUnit,
            SecurityDepositMonth__c         = securityDepositMonth,
            KeyMoneyUnit__c                 = keyMoneyUnit,
            KeyMoneyMonth__c                = keyMoneyMonth,
            DepositUnit__c                  = depositUnit,
            DepositMonth__c                 = depositMonth,
            CancellationActualFeeUnit__c    = cancellationActualFeeUnit,
            CancellationActualFeeMonth__c   = cancellationActualFeeMonth,
            CancellationActualFeeRate__c    = cancellationActualFeeRate,
            RenewalFeeMonth__c              = renewalFeeMonth,
            RenewalFeeUnit__c               = renewalFeeUnit,
            RenewalFeeTaxType__c            = renewalFeeTaxType,
            KeyExchangeFee__c               = keyExchangeFee,
            KeyExchangeFeeTaxType__c        = keyExchangeFeeTaxType,
            WortFee__c                      = wortFee,
            WortFeeTaxType__c               = wortFeeTaxType,
            TownshipFee__c                  = townshipFee,
            TownshipFeeTaxType__c           = townshipFeeTaxType,
            TownshipFeePaymentType__c       = townshipFeePaymentType,
            CATVFee__c                      = CATVFee,
            CATVTaxType__c                  = CATVTaxType,
            CleaningFeeMonth__c             = cleaningFeeMonth,
            CleaningFeeUnit__c              = cleaningFeeUnit,
            CleaningFeeTaxType__c           = cleaningFeeTaxType,
            CleaningFeePaymentType__c       = cleaningFeePaymentType,
            GuaranteeidCompanyType__c       = guaranteeidCompanyType,
            MonetaryRemarksPrivate__c       = monetaryPrivate,
            ParkingType__c                  = parkingType,
            ParkingDistance__c              = parkingDistance,
            ParkingFee__c                   = parkingFee,
            ParkingFeeTaxType__c            = parkingFeeTaxType,
            ParkingRemarksPrivate__c        = parkingRemarksPrivate,
            KeyPlace__c                     = keyPlace,
            RewardBurdenLender__c           = rewardBurdenLender,
            RewardBurdenBorrower__c         = rewardBurdenBorrower,
            RewardSplitFormerSupplier__c    = rewardSplitFormerSupplier,
            RewardSplitCustomer__c          = rewardSplitCustomer,
            ADRemarksPrivate__c             = ADRemarksPrivate,
            ManagementCompanyName__c        = supplierName,
            ManagementCompanyAddress__c     = supplierAccress,
            ManagementCompanyPhone__c       = supplierPhone,
            ManagementCompanyFax__c         = supplierFax,
            ManagementCompanyLicense__c     = supplierLicense,
            ManagementCompanyStaffName__c   = supplierStaffName,
            ManagementCompanyRemarks__c     = supplierCompanyRemarks,
            ExcecuteBatchNo__c              = 1
        );
        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }


    // 建物オブジェクトデータ取得
    private static List<Building__c> selectBuilding() {
        return selectBuilding(null);
    }
    private static List<Building__c> selectBuilding(String manteCode) {
        String sql = 'SELECT ' + getSelectAllField('Building__c') + ' FROM Building__c';
        if (!String.isEmpty(manteCode)) {
            sql += ' WHERE MaintenanceBuildingCode__c = :manteCode';
        }
        return Database.query(sql);
    }
    // 物件オブジェクトデータ取得
    private static List<Property__c> selectProperty() {
        return selectProperty(null);
    }
    private static List<Property__c> selectProperty(String mainteCode) {
        String sql = 'SELECT ' + getSelectAllField('Property__c') + ' FROM Property__c';
        if (!String.isEmpty(mainteCode)) {
            sql += ' WHERE MaintenancePropertyCode__c = :mainteCode';
        }
        return Database.query(sql);
    }
    // 建物写真オブジェクト　データ取得
    private static List<BuildingPhoto__c> selectBuildingPhoto() {
        return selectBuildingPhoto(null);
    }
    private static List<BuildingPhoto__c> selectBuildingPhoto(String mainteCode) {
        String sql = 'SELECT ' + getSelectAllField('BuildingPhoto__c') + ' FROM BuildingPhoto__c';
        if (!String.isEmpty(mainteCode)) {
            sql += ' WHERE Building__c IN (SELECT Id FROM Building__c WHERE MaintenanceBuildingCode__c = :mainteCode)';
        }
        return Database.query(sql);
    }
    // 物件写真オブジェクト データ取得
    private static List<PropertyPhoto__c> selectPropertyPhoto() {
        return selectPropertyPhoto(null);
    }
    private static List<PropertyPhoto__c> selectPropertyPhoto(String mainteCode) {
        String sql = 'SELECT ' + getSelectAllField('PropertyPhoto__c') + ' FROM PropertyPhoto__c';
        if (!String.isEmpty(mainteCode)) {
            sql += ' WHERE Property__c IN (SELECT Id FROM Property__c WHERE MaintenancePropertyCode__c = :mainteCode)';
        }
        return Database.query(sql);
    }
    // 部屋オブジェクト データ取得
    private static List<Room__c> selectRoom() {
        return selectRoom(null);
    }
    private static List<Room__c> selectRoom(String mainteCode) {
        String sql = 'SELECT ' + getSelectAllField('Room__c') + ' FROM Room__c';
        if (!String.isEmpty(mainteCode)) {
            sql += ' WHERE Property__c IN (SELECT Id FROM Property__c WHERE MaintenancePropertyCode__c = :mainteCode)';
        }
        sql += ' ORDER BY RoomFloorSpace__c';
        return Database.query(sql);
    }
    // 物件条件オブジェクト　データ取得
    private static List<PropertyConditions__c> selectPropertyConditions() {
        return selectPropertyConditions(null);
    }
    private static List<PropertyConditions__c> selectPropertyConditions(String mainteCode) {
        String sql = 'SELECT ' + getSelectAllField('PropertyConditions__c') + ' FROM PropertyConditions__c';
        if (!String.isEmpty(mainteCode)) {
            sql += ' WHERE Property__c IN (SELECT Id FROM Property__c WHERE MaintenancePropertyCode__c = :mainteCode)';
        }
        return Database.query(sql);
    }
    // 取引先オブジェクト　データ取得
    private static List<Account> selectAccount() {
        return selectAccount(null);
    }
    private static List<Account> selectAccount(String mainteCode) {
        String sql = 'SELECT ' + getSelectAllField('Account') + ' FROM Account';
        if (!String.isEmpty(mainteCode)) {
            sql += ' WHERE MaintenanceSupplierCode__c = :mainteCode';
        }
        return Database.query(sql);
    }
    // 自動メンテナンスオブジェクト　データ取得
    private static List<AutoMaintenance__c> selectAutoMainte() {
        String sql = 'SELECT ' + getSelectAllField('AutoMaintenance__c') + ' FROM AutoMaintenance__c';
        return Database.query(sql);
    }

    // 指定したオブジェクトの項目取得 ※,区切り
    private static String getSelectAllField(String objName){
        //項目名を区切る',' : 最初の項目の前には不要なため、初期値は空欄
        String commaString  = '';
        List<String> apiList = new List<String>();
        // SObject Describe
        Schema.DescribeSObjectResult obj = Schema.getGlobalDescribe().get(objName).getDescribe();
        // Fieldマップ取得
        Map<String, Schema.SObjectField> fieldMap = obj.fields.getMap();
        for (Schema.SObjectField item : fieldMap.values()) {
            apiList.add(item.getDescribe().getName());
        }
        return String.join(apiList, ',');
    }

    // 条件変更
    @isTest static void changeConditionsNotice() {
            
        // 自動メンテナンス差分作成(トリガー起動)
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION,
            ExternalSiteCd__c          = CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO,
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE_EXISTS,
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE_EXISTS,
            MaintenanceSupplierCode__c = SUPPLIER_MAINT_CODE_EXISTS,
            BuildingName__c            = '自動メンテ建物',
            PropertyName__c            = '自動メンテ物件',
            ManagementCompanyName__c   = '自動メンテ業者',
            RoomType1__c               = CommonConst.AUTOMAINTEDIFF_ROOMTYPE_K,
            RoomFloorSpace1__c         = 10.0,
            ExcecuteBatchNo__c         = 1,
            PropertyRemarksPrivate__c  = PROP_REMARKS_PRIVATE_INIT2,
            FacilityRemarksPrivate__c  = FACILITY_REMARKS_PRIVATE_INIT2,
            RoomLayoutFileName__c      = DIFF_ROOMLAYOUT_FILE_NAME_INIT2,
            ParkingType__c             = CommonConst.PROPERTY_PARKINGTYPE_NEIGHBORHOOD_SECURE,
            Facility__c                = 'メゾネット;'
        );
        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

    // 地区（エラー時）登録テスト
    @isTest static void RegistdistrictError() {
        // 自動メンテナンス差分作成(トリガー起動)
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE_EXISTS,
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE_EXISTS,
            MaintenanceSupplierCode__c = SUPPLIER_MAINT_CODE_EXISTS,
            BuildingName__c            = '自動メンテ建物',
            PropertyName__c            = '自動メンテ物件',
            ManagementCompanyName__c   = '自動メンテ業者',
            RoomType1__c               = CommonConst.AUTOMAINTEDIFF_ROOMTYPE_K,
            RoomFloorSpace1__c         = 10.0,
            ExcecuteBatchNo__c         = 1,
            DepositMonth__c            = 1234567,
            ExternalSiteCd__c          = CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO
        );
        insert autoMainteDiff;
    
        //バッチ実行
        AutoMaintenanceUtil.savePoint = GoogleApiUtil.savePoint;
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
    }

    // 1:新規（既存物件有り）
    @isTest static void newBuildingOldProperty() {
        // 自動メンテナンス差分作成(トリガー起動)
        t_auto_maintenance_difference__c autoMainteDiff = new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     = CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c = BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c = PROPERTY_MAINT_CODE_EXISTS,
            MaintenanceSupplierCode__c = SUPPLIER_MAINT_CODE_EXISTS,
            BuildingName__c            = '自動メンテ建物',
            PropertyName__c            = '自動メンテ物件',
            ManagementCompanyName__c   = '自動メンテ業者',
            RoomType1__c               = CommonConst.AUTOMAINTEDIFF_ROOMTYPE_K,
            RoomFloorSpace1__c         = 10.0,
            ExcecuteBatchNo__c         = 1
        );
        insert autoMainteDiff;

        //バッチ実行
        Test.startTest();
        BD601005Batch batch = new BD601005Batch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }

	//▼ No.614 異常終了時の処理を追加
	/**
	 * BD601005Batch
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグがFalseになること
	 */
	@isTest static void autoMaintenance1Error() {
		// 自動メンテナンス差分作成(トリガー起動)
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(1,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1);
		insert autoMainteDiff;

		//バッチ実行
		Test.startTest();
		BD601005Batch batch = new BD601005Batch();
		BD601005Batch.isExceptionTest = true;
		Database.executeBatch(batch, 1);
		Test.stopTest();

		SystemVariables__c SystemVariablesData;
		SystemVariablesData = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :IS_AUTOMAINTENANCE_BATCHPROCESSING];
		System.assertEquals(false,SystemVariablesData.BooleanValue__c);
	}

	/**
	 * BD601005Batch
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグの更新がエラーになった際、メールがエラー送信先に送られること
	 */
	@isTest static void autoMaintenance1ErrorMail() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(1,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1);
		insert autoMainteDiff;
		
		// エラーメール用のシステム変数の変更
		changeSystemVariables(IS_AUTOMAINTENANCE_BATCHPROCESSING);

		//バッチ実行
		Test.startTest();
		BD601005Batch batch = new BD601005Batch();
		BD601005Batch.isExceptionTest = true;
		Database.executeBatch(batch, 1);
		Test.stopTest();
	}

	/**
	 * BD601005Batch_2
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグがFalseになること
	 */
	@isTest static void autoMaintenance2Error() {
		// 自動メンテナンス差分作成(トリガー起動)
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(2,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1);
		insert autoMainteDiff;

		//バッチ実行
		Test.startTest();
		BD601005Batch_2 batch = new BD601005Batch_2();
		BD601005Batch_2.isExceptionTest = true;
		Database.executeBatch(batch, 1);
		Test.stopTest();

		SystemVariables__c SystemVariablesData;
		SystemVariablesData = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :IS_AUTOMAINTENANCE_BATCHPROCESSING2];
		System.assertEquals(false,SystemVariablesData.BooleanValue__c);
	}

	/**
	 * BD601005Batch_2
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグの更新がエラーになった際、メールがエラー送信先に送られること
	 */
	@isTest static void autoMaintenance2ErrorMail() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(2,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1);
		insert autoMainteDiff;
		
		// エラーメール用のシステム変数の変更
		changeSystemVariables(IS_AUTOMAINTENANCE_BATCHPROCESSING2);

		//バッチ実行
		Test.startTest();
		BD601005Batch_2 batch = new BD601005Batch_2();
		BD601005Batch_2.isExceptionTest = true;
		Database.executeBatch(batch, 1);
		Test.stopTest();
	}

	/**
	 * BD601005Batch_3
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグがFalseになること
	 */
	@isTest static void autoMaintenance3Error() {
		// 自動メンテナンス差分作成(トリガー起動)
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(3,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1);
		insert autoMainteDiff;

		//バッチ実行
		Test.startTest();
		BD601005Batch_3 batch = new BD601005Batch_3();
		BD601005Batch_3.isExceptionTest = true;
		Database.executeBatch(batch, 1);
		Test.stopTest();

		SystemVariables__c SystemVariablesData;
		SystemVariablesData = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :IS_AUTOMAINTENANCE_BATCHPROCESSING3];
		System.assertEquals(false,SystemVariablesData.BooleanValue__c);
	}

	/**
	 * BD601005Batch_3
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグの更新がエラーになった際、メールがエラー送信先に送られること
	 */
	@isTest static void autoMaintenance3ErrorMail() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(3,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1);
		insert autoMainteDiff;
		
		// エラーメール用のシステム変数の変更
		changeSystemVariables(IS_AUTOMAINTENANCE_BATCHPROCESSING3);

		//バッチ実行
		Test.startTest();
		BD601005Batch_3 batch = new BD601005Batch_3();
		BD601005Batch_3.isExceptionTest = true;
		Database.executeBatch(batch, 1);
		Test.stopTest();
	}

    /**
	 * BD601005Batch_4
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグがFalseになること
	 */
	@isTest static void autoMaintenance4Error() {
		// 自動メンテナンス差分作成(トリガー起動)
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(4,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1);
		insert autoMainteDiff;

		//バッチ実行
		Test.startTest();
		BD601005Batch_4 batch = new BD601005Batch_4();
		BD601005Batch_4.isExceptionTest = true;
		Database.executeBatch(batch, 1);
		Test.stopTest();

		SystemVariables__c SystemVariablesData;
		SystemVariablesData = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :IS_AUTOMAINTENANCE_BATCHPROCESSING4];
		System.assertEquals(false,SystemVariablesData.BooleanValue__c);
	}

	/**
	 * BD601005Batch_4
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグの更新がエラーになった際、メールがエラー送信先に送られること
	 */
	@isTest static void autoMaintenance4ErrorMail() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(4,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1);
		insert autoMainteDiff;
		
		// エラーメール用のシステム変数の変更
		changeSystemVariables(IS_AUTOMAINTENANCE_BATCHPROCESSING4);

		//バッチ実行
		Test.startTest();
		BD601005Batch_4 batch = new BD601005Batch_4();
		BD601005Batch_4.isExceptionTest = true;
		Database.executeBatch(batch, 1);
		Test.stopTest();
	}

    /**
	 * BD601005Batch_5
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグがFalseになること
	 */
	@isTest static void autoMaintenance5Error() {
		// 自動メンテナンス差分作成(トリガー起動)
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(5,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1);
		insert autoMainteDiff;

		//バッチ実行
		Test.startTest();
		BD601005Batch_5 batch = new BD601005Batch_5();
		BD601005Batch_5.isExceptionTest = true;
		Database.executeBatch(batch, 1);
		Test.stopTest();

		SystemVariables__c SystemVariablesData;
		SystemVariablesData = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :IS_AUTOMAINTENANCE_BATCHPROCESSING5];
		System.assertEquals(false,SystemVariablesData.BooleanValue__c);
	}

	/**
	 * BD601005Batch_5
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグの更新がエラーになった際、メールがエラー送信先に送られること
	 */
	@isTest static void autoMaintenance5ErrorMail() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(5,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1);
		insert autoMainteDiff;
		
		// エラーメール用のシステム変数の変更
		changeSystemVariables(IS_AUTOMAINTENANCE_BATCHPROCESSING5);

		//バッチ実行
		Test.startTest();
		BD601005Batch_5 batch = new BD601005Batch_5();
		BD601005Batch_5.isExceptionTest = true;
		Database.executeBatch(batch, 1);
		Test.stopTest();
	}




	/**
	 * BD601005Batch2
	 * バッチ終了時
	 * システム変数の自動メンテナンスバッチ処理中フラグがFalseになること
	 */
	@isTest static void autoMaintenance1Batch2Error() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(1,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_2);
		insert autoMainteDiff;

		//バッチ実行
		Test.startTest();
		BD601005Batch2 batch = new BD601005Batch2();
		Database.executeBatch(batch, 1);
		Test.stopTest();

		SystemVariables__c SystemVariablesData;
		SystemVariablesData = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :IS_AUTOMAINTENANCE_BATCHPROCESSING];
		System.assertEquals(false,SystemVariablesData.BooleanValue__c);
	}
	
	/**
	 * BD601005Batch2
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグの更新がエラーになった際、メールがエラー送信先に送られること
	 */
	@isTest static void autoMaintenance1Batch2ErrorMail() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(1,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_2);
		insert autoMainteDiff;

		// エラーメール用のシステム変数の変更
		changeSystemVariables(IS_AUTOMAINTENANCE_BATCHPROCESSING);

		//バッチ実行
		Test.startTest();
		BD601005Batch2 batch = new BD601005Batch2();
		Database.executeBatch(batch, 1);
		Test.stopTest();
	}

	/**
	 * BD601005Batch2_2
	 * バッチ終了時
	 * システム変数の自動メンテナンスバッチ処理中フラグがFalseになること
	 */
	@isTest static void autoMaintenance2Batch2Error() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(2,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_2);
		insert autoMainteDiff;

		//バッチ実行
		Test.startTest();
		BD601005Batch2_2 batch = new BD601005Batch2_2();
		Database.executeBatch(batch, 1);
		Test.stopTest();

		SystemVariables__c SystemVariablesData;
		SystemVariablesData = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :IS_AUTOMAINTENANCE_BATCHPROCESSING2];
		System.assertEquals(false,SystemVariablesData.BooleanValue__c);
	}
	
	/**
	 * BD601005Batch2_2
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグの更新がエラーになった際、メールがエラー送信先に送られること
	 */
	@isTest static void autoMaintenance2Batch2ErrorMail() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(2,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_2);
		insert autoMainteDiff;

		// エラーメール用のシステム変数の変更
		changeSystemVariables(IS_AUTOMAINTENANCE_BATCHPROCESSING2);

		//バッチ実行
		Test.startTest();
		BD601005Batch2_2 batch = new BD601005Batch2_2();
		Database.executeBatch(batch, 1);
		Test.stopTest();
	}
	/**
	 * BD601005Batch2_3
	 * バッチ終了時
	 * システム変数の自動メンテナンスバッチ処理中フラグがFalseになること
	 */
	@isTest static void autoMaintenance3Batch2Error() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(3,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_2);
		insert autoMainteDiff;

		//バッチ実行
		Test.startTest();
		BD601005Batch2_3 batch = new BD601005Batch2_3();
		Database.executeBatch(batch, 1);
		Test.stopTest();

		SystemVariables__c SystemVariablesData;
		SystemVariablesData = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :IS_AUTOMAINTENANCE_BATCHPROCESSING3];
		System.assertEquals(false,SystemVariablesData.BooleanValue__c);
	}
	
	/**
	 * BD601005Batch2_3
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグの更新がエラーになった際、メールがエラー送信先に送られること
	 */
	@isTest static void autoMaintenance3Batch2ErrorMail() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(3,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_2);
		insert autoMainteDiff;

		// エラーメール用のシステム変数の変更
		changeSystemVariables(IS_AUTOMAINTENANCE_BATCHPROCESSING3);

		//バッチ実行
		Test.startTest();
		BD601005Batch2_3 batch = new BD601005Batch2_3();
		Database.executeBatch(batch, 1);
		Test.stopTest();
	}
    /**
	 * BD601005Batch2_4
	 * バッチ終了時
	 * システム変数の自動メンテナンスバッチ処理中フラグがFalseになること
	 */
	@isTest static void autoMaintenance4Batch2Error() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(4,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_2);
		insert autoMainteDiff;

		//バッチ実行
		Test.startTest();
		BD601005Batch2_4 batch = new BD601005Batch2_4();
		Database.executeBatch(batch, 1);
		Test.stopTest();

		SystemVariables__c SystemVariablesData;
		SystemVariablesData = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :IS_AUTOMAINTENANCE_BATCHPROCESSING4];
		System.assertEquals(false,SystemVariablesData.BooleanValue__c);
	}
	
	/**
	 * BD601005Batch2_4
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグの更新がエラーになった際、メールがエラー送信先に送られること
	 */
	@isTest static void autoMaintenance4Batch2ErrorMail() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(4,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_2);
		insert autoMainteDiff;

		// エラーメール用のシステム変数の変更
		changeSystemVariables(IS_AUTOMAINTENANCE_BATCHPROCESSING4);

		//バッチ実行
		Test.startTest();
		BD601005Batch2_4 batch = new BD601005Batch2_4();
		Database.executeBatch(batch, 1);
		Test.stopTest();
	}

	/**
	 * BD601005Batch2_5
	 * バッチ終了時
	 * システム変数の自動メンテナンスバッチ処理中フラグがFalseになること
	 */
	@isTest static void autoMaintenance5Batch2Error() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(5,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_2);
		insert autoMainteDiff;

		//バッチ実行
		Test.startTest();
		BD601005Batch2_5 batch = new BD601005Batch2_5();
		Database.executeBatch(batch, 1);
		Test.stopTest();

		SystemVariables__c SystemVariablesData;
		SystemVariablesData = [SELECT Id ,BooleanValue__c FROM SystemVariables__c  WHERE VariablesName__c = :IS_AUTOMAINTENANCE_BATCHPROCESSING5];
		System.assertEquals(false,SystemVariablesData.BooleanValue__c);
	}
	
	/**
	 * BD601005Batch2_5
	 * バッチ終了時の例外エラー
	 * システム変数の自動メンテナンスバッチ処理中フラグの更新がエラーになった際、メールがエラー送信先に送られること
	 */
	@isTest static void autoMaintenance5Batch2ErrorMail() {
		// 自動メンテナンス差分作成
		t_auto_maintenance_difference__c autoMainteDiff = setAutoMaintenanceDifference(5,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_2);
		insert autoMainteDiff;

		// エラーメール用のシステム変数の変更
		changeSystemVariables(IS_AUTOMAINTENANCE_BATCHPROCESSING5);

		//バッチ実行
		Test.startTest();
		BD601005Batch2_5 batch = new BD601005Batch2_5();
		Database.executeBatch(batch, 1);
		Test.stopTest();
	}

	// ▼2022.04.07 No.0723 対応
    /**
    * １．自動メンテナンス区分1:新規
    * 　　実行された日付で物件の自社管理修正日にセットされないこと。
	* ２. 自動メンテナンス区分1:新規
	*     自動メンテナンス差分の報酬負担借主の内容で物件の報酬負担借主に更新されること。
    */
	@isTest static void AutomainteTest_kbn1(){
		// 自動メンテナンス差分作成
        t_auto_maintenance_difference__c autoMainteDiff = SetAutoMaintenanceDifference(1,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1,CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,'test');

        insert autoMainteDiff;
		//バッチ実行
		Test.startTest();
		BD601005Batch b = new BD601005Batch();
		Database.executeBatch(b, 1);
		Test.stopTest();

		//必要な情報を習得
        Property__c PropertyData = [SELECT CreatedDate, Id ,OwnCompanyManageModDate__c,RewardBurdenBorrower__c FROM Property__c order by CreatedDate desc Limit 1];
        // 実行された日付で物件の自社管理修正日にセットされないこと。
        System.assertEquals(null,PropertyData.OwnCompanyManageModDate__c);

        //自動メンテナンス差分の報酬負担借主の内容で物件の報酬負担借主に更新されること。
        System.assertEquals(1.0,PropertyData.RewardBurdenBorrower__c);
	}

     /**
    * １．自動メンテナンス区分2:物件新規
    * 　　実行された日付で物件の自社管理修正日にセットされないこと。
	* ２. 自動メンテナンス区分2:物件新規
	*     自動メンテナンス差分の報酬負担借主の内容で物件の報酬負担借主に更新されること。
    */
	@isTest static void AutomainteTest_kbn2(){
		// 自動メンテナンス差分作成
        t_auto_maintenance_difference__c autoMainteDiff = SetAutoMaintenanceDifference(1,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1,CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_PROPERTY_NEW,'test');

        insert autoMainteDiff;
		//バッチ実行
		Test.startTest();
		BD601005Batch b = new BD601005Batch();
		Database.executeBatch(b, 1);
		Test.stopTest();

		//必要な情報を習得
        Property__c PropertyData = [SELECT CreatedDate, Id ,OwnCompanyManageModDate__c,RewardBurdenBorrower__c FROM Property__c order by CreatedDate desc Limit 1];
		// 実行された日付で物件の自社管理修正日にセットされないこと。
        System.assertEquals(null,PropertyData.OwnCompanyManageModDate__c);
        //自動メンテナンス差分の報酬負担借主の内容で物件の報酬負担借主に更新されること。
        System.assertEquals(1.0,PropertyData.RewardBurdenBorrower__c);
        
	}

    /**
    * １．自動メンテナンス区分3:条件変更
    * 　　実行された日付で物件の自社管理修正日にセットされること。
	* ２. 自動メンテナンス区分3:条件変更
	*     自動メンテナンス差分の報酬負担借主の内容で物件の報酬負担借主に更新されないこと。
    */
	@isTest static void AutomainteTest_kbn3(){
		// 自動メンテナンス差分作成
        t_auto_maintenance_difference__c autoMainteDiff = SetAutoMaintenanceDifference(1,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1,CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_CHANGE_CONDITION,PROPERTY_MAINT_CODE_EXISTS);

        insert autoMainteDiff;
        //更新前にデータを取得し、保持 (2022/04/14 追記)
        Property__c PropertyData_before = [SELECT CreatedDate, Id ,OwnCompanyManageModDate__c,RewardBurdenBorrower__c FROM Property__c order by CreatedDate desc Limit 1];
		//バッチ実行
		Test.startTest();
		BD601005Batch b = new BD601005Batch();
		Database.executeBatch(b, 1);
		Test.stopTest();

		//必要な情報を習得 , 更新後のデータ取得(2022/04/13 追記)
        Property__c PropertyData_after = [SELECT CreatedDate, Id ,OwnCompanyManageModDate__c,RewardBurdenBorrower__c FROM Property__c order by CreatedDate desc Limit 1];
        // 実行された日付で物件の自社管理修正日にセットされること。
        System.assertEquals(CommonUtil.getNow().format('yyyy-MM-dd'),autoMainteDiff.InfoModifiedDate__c.format('yyyy-MM-dd'));//数秒差でエラーになるのでformat() 2022/04/13追記

        //自動メンテナンス差分の報酬負担借主の内容で物件の報酬負担借主に更新されないこと。
        System.assertEquals(PropertyData_before.RewardBurdenBorrower__c,PropertyData_after.RewardBurdenBorrower__c);

	}

	/**
    * １．自動メンテナンス区分4:居住中→空室
    * 　　実行された日付で物件の自社管理修正日にセットされないこと。
	* ２. 自動メンテナンス区分4:居住中→空室
	*     自動メンテナンス差分の報酬負担借主の内容で物件の報酬負担借主に更新されること。
    */
	@isTest static void AutomainteTest_kbn4(){
		// 自動メンテナンス差分作成
        t_auto_maintenance_difference__c autoMainteDiff = SetAutoMaintenanceDifference(1,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1,CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_LIVESTATUS_EMPTY,PROPERTY_MAINT_CODE_EXISTS);

        insert autoMainteDiff;
		//バッチ実行
		Test.startTest();
		BD601005Batch b = new BD601005Batch();
		Database.executeBatch(b, 1);
		Test.stopTest();

		//必要な情報を習得 
        Property__c PropertyData = [SELECT LastModifiedDate, Id ,OwnCompanyManageModDate__c,RewardBurdenBorrower__c  FROM Property__c order by LastModifiedDate desc Limit 1];
		// 実行された日付で物件の自社管理修正日にセットされないこと。
        System.assertEquals(null,PropertyData.OwnCompanyManageModDate__c);
        //自動メンテナンス差分の報酬負担借主の内容で物件の報酬負担借主に更新されること。
        System.assertEquals(1.0,PropertyData.RewardBurdenBorrower__c);
	}

    /**
    * １．自動メンテナンス区分5:掲載終了
    * 　　実行された日付で物件の自社管理修正日にセットされること。
	* ２. 自動メンテナンス区分5:
	*     自動メンテナンス差分の報酬負担借主の内容で物件の報酬負担借主に更新されないこと。
    */
	@isTest static void AutomainteTest_kbn5(){
		// 自動メンテナンス差分作成
        t_auto_maintenance_difference__c autoMainteDiff = SetAutoMaintenanceDifference(1,CommonConst.AUTOMAINTEDIFF_BATCHSTATUS_1,CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_POSTING_END,PROPERTY_MAINT_CODE_EXISTS);       

        insert autoMainteDiff;
		//バッチ実行
		Test.startTest();
		BD601005Batch b = new BD601005Batch();
		Database.executeBatch(b, 1);
		Test.stopTest();
		//必要な情報を習得 
         Property__c PropertyData = [SELECT CreatedDate, Id ,OwnCompanyManageModDate__c,RewardBurdenBorrower__c FROM Property__c order by CreatedDate desc Limit 1];
		
        // 実行された日付で物件の自社管理修正日にセットされること
        System.assertEquals(CommonUtil.getNow().format('yyyy-MM-dd'),autoMainteDiff.InfoModifiedDate__c.format('yyyy-MM-dd'));//数秒差でエラーになるのでformat() 2022/04/13追記
        //自動メンテナンス差分の報酬負担借主の内容で物件の報酬負担借主に更新されること
        System.assertNotEquals(1.0,PropertyData.RewardBurdenBorrower__c);
        
	}

	// テスト用自動メンテナンス差分作成 No0723用
	private static t_auto_maintenance_difference__c SetAutoMaintenanceDifference(Integer excecuteBatchNo,String batchStatus, String AutoMenteKbn, String MaintenancePropertyCode ) {
		return new t_auto_maintenance_difference__c(
			AutoMaintenanceType__c     	= AutoMenteKbn,
			MaintenanceBuildingCode__c 	= BUILDING_MAINT_CODE_EXISTS,
			MaintenancePropertyCode__c 	= MaintenancePropertyCode,
			MaintenanceSupplierCode__c 	= SUPPLIER_MAINT_CODE_EXISTS,
			BuildingName__c            	= '自動メンテ建物',
			PropertyName__c            	= '自動メンテ物件',
			ManagementCompanyName__c   	= '自動メンテ業者',
            ExternalSiteCd__c           = CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO,    // 外部サイトコード
            InfoModifiedDate__c         = CommonUtil.getNow(), // 情報更新日
            RewardBurdenBorrower__c     = 1.0, //報酬負担借主
			ExcecuteBatchNo__c         	= excecuteBatchNo,
			BatchStatus__c				= batchStatus
		);
	}
    // ▲2022.04.09 No.0723 対応

    // テスト用自動メンテナンス差分作成 1:新規
    private static t_auto_maintenance_difference__c setAutoMaintenanceDifference(Integer excecuteBatchNo,String batchStatus) {
        return new t_auto_maintenance_difference__c(
            AutoMaintenanceType__c     	= CommonConst.AUTOMAINTEDIFF_AUTOMAINTETYPE_NEW,
            MaintenanceBuildingCode__c 	= BUILDING_MAINT_CODE,
            MaintenancePropertyCode__c 	= PROPERTY_MAINT_CODE_EXISTS,
            MaintenanceSupplierCode__c 	= SUPPLIER_MAINT_CODE_EXISTS,
            BuildingName__c            	= '自動メンテ建物',
            PropertyName__c            	= '自動メンテ物件',
            ManagementCompanyName__c   	= '自動メンテ業者',
            ExcecuteBatchNo__c         	= excecuteBatchNo,
            BatchStatus__c				= batchStatus
        );
    }

	// システム設定エラー変更
	private static void changeSystemVariables(String variablesName) {
		SystemVariables__c SystemVariablesData;
		SystemVariablesData = [SELECT Id ,VariablesName__c FROM SystemVariables__c  WHERE VariablesName__c = :variablesName];
		SystemVariablesData.VariablesName__c = 'エラーになるよう';
		update SystemVariablesData;
	}
	//▲ No.614 異常終了時の処理を追加
}