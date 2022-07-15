//建物物件共通処理クラス
public class BuildingPropertyUtil {

    /**
     * 総賃料の計算と更新
     * @param Set<Id> propIdSet 計算対象の物件ID
     */
    public static void updateCalcAllRent(Set<Id> propIdSet) {

        // 物件の取得（key:物件.Id、value:物件）
        Map<Id, Property__c> propertyMap = selectProperty(propIdSet);

        // 全物件の保証会社、火災保険のId一覧を取得
        Set<Id> fireInsuranceItemSet = new Set<Id>(); // 火災保険
        Set<Id> GuaranteeidItemSet   = new Set<Id>(); // 保証会社

        for (Property__c property : propertyMap.values()) {
            fireInsuranceItemSet.add(property.FireInsurancePlan__c);
            GuaranteeidItemSet.add(property.Guaranteeid__c);
        }

        // 火災保険会社の商品の取得（key:商品（カスタム）.Id、value:商品（カスタム））
        Map<Id, Item__c> itemFireInsuranceMap = selectItemFireInsurance(fireInsuranceItemSet);

        // 保証会社の商品の取得（key:商品（カスタム）.Id、value:商品（カスタム））
        Map<Id, Item__c> itemDepositMap = selectItemDeposit(GuaranteeidItemSet);

        // 物件に紐づく管理会社指定商品の取得（key:物件.Id、value:管理会社指定商品）
        Map<Id, List<ManagementCompanyItem__c>> propsManaCorpItemMap;
        propsManaCorpItemMap = getPropsManaCorpItem(propertyMap.keySet());

        // 総賃料取得用エンティティ
        Property__c tmpProperty;          // 物件
        Item__c     tmpItemFireInsurance; // 火災保険の商品（カスタム）
        Item__c     tmpItemDeposit;       // 保証会社の商品（カスタム）

        List<ManagementCompanyItem__c> tmpManaCorpItemList;  // 管理会社指定商品

        // 総賃料の取得
        List<Property__c> updPropertyList = new List<Property__c>();
        for (Property__c property : propertyMap.values()) {

            // 火災保険会社の商品（カスタム）
            tmpItemFireInsurance = new Item__c();
            if (itemFireInsuranceMap.containsKey(property.FireInsurancePlan__c)) {
                tmpItemFireInsurance = itemFireInsuranceMap.get(property.FireInsurancePlan__c);
            }

            // 保証会社の商品（カスタム）
            tmpItemDeposit = new Item__c();
            if (itemDepositMap.containsKey(property.Guaranteeid__c)) {
                tmpItemDeposit = itemDepositMap.get(property.Guaranteeid__c);
            }

            // 管理会社指定商品
            tmpManaCorpItemList = new List<ManagementCompanyItem__c>();
            if (propsManaCorpItemMap.containsKey(property.Id)) {
                tmpManaCorpItemList = propsManaCorpItemMap.get(property.Id);
            }

            // 総賃料の更新情報を取得
            tmpProperty = new Property__c(Id = property.Id);
            tmpProperty.AllRentFee__c = calcAllRent(property
                                                    , tmpManaCorpItemList
                                                    , tmpItemFireInsurance
                                                    , tmpItemDeposit);

            updPropertyList.add(tmpProperty);
        }

        // 総賃料の更新
        if (updPropertyList.size() > 0) {
            SecureDML.secureUpsert(updPropertyList);
        }
    }
    
    /**
     * 総賃料計算処理
     * @param  Property__c                    prop                   計算に使用する物件オブジェクト
     * @param  List<ManagementCompanyItem__c> manageItemList         計算に使用する管理会社指定商品オブジェクト
     * @param  Item__c                        fireInsuranceItem      計算に使用する火災保険の商品オブジェクト
     * @param  Item__c                        DepositItem            計算に使用する保証プランの商品オブジェクト（保証料の計算のためサブクエリにて商品明細、取引先の情報を取得している状態であること）
     * @return Decimal                                               計算結果
     */
    public static Decimal calcAllRent(Property__c prop, List<ManagementCompanyItem__c> manageItemList, Item__c fireInsuranceItem, Item__c DepositItem) {
        Decimal allRent = 0;
        prop.recalculateFormulas(); // 数式項目の再計算
        allRent += BuildingPropertyUtil.getNullToDecimalValue(prop.RentFee__c);                     // 賃料
        allRent += BuildingPropertyUtil.getNullToDecimalValue(prop.WortFeeTax__c);                  // 水道料金（税込）
        allRent += BuildingPropertyUtil.getNullToDecimalValue(prop.ManagementFeeTax__c);            // 管理費（税込）
        allRent += BuildingPropertyUtil.getNullToDecimalValue(prop.CATVFeeTax__c);                  // CATV（税込）
        if (prop.TownshipFeePaymentType__c == CommonConst.PROPERTY_PAYMENTTYPE_MONTH) {
            allRent += BuildingPropertyUtil.getNullToDecimalValue(prop.TownshipFeeTax__c);          // 町会費（税込）※月額の場合
        }
        if (prop.GarbageDisposalFeePaymentType__c == CommonConst.PROPERTY_PAYMENTTYPE_MONTH) {
            allRent += BuildingPropertyUtil.getNullToDecimalValue(prop.GarbageDisposalFeeTax__c);   // ゴミ処理費（税込）※月額の場合
        }
        allRent += BuildingPropertyUtil.getNullToDecimalValue(prop.BicycleParkingFeeTax__c);        // 駐輪場料金（税込）
        if (prop.ParkingType__c != CommonConst.PROPERTY_PARKINGTYPE_NEIGHBORHOOD_SECURE) {
            allRent += BuildingPropertyUtil.getNullToDecimalValue(prop.ParkingFeeTax__c);           // 駐車場料金（税込）※近隣確保以外の場合
        }
        for (ManagementCompanyItem__c item : manageItemList) {                                      // 管理会社指定商品（税込）※月額のみ
            if (item.PaymentType__c == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH) {
                // 支払区分「月額」の商品の料金のみ計上
                allRent += BuildingPropertyUtil.getNullToDecimalValue(item.AmountTax__c);
            }
        }

        // 火災保険料算出
        if(prop.FireInsuranceUseType__c == CommonConst.PROPERTY_FIREINSURANCEUSETYPE_EXISTS){
            allRent += setMonthlyFireInsurance(fireInsuranceItem);
        }

        // 月額保証料の計算（小数点切り上げ）
        if(prop.GuaranteeidCompanyType__c == CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_REQUIRED){
            allRent += setMonthlyFeeDeposit(DepositItem,allRent,prop.RentFee__c).setScale(0, RoundingMode.UP);
        }

        return allRent;
    }
    private static Decimal getNullToDecimalValue(Decimal dec) {
        return dec == null ? 0 : dec;
    }
    // 火災保険料
    private static Decimal setMonthlyFireInsurance(Item__c fireInsuranceItem){
        // 火災保険が取れていなければ0円で返す
        if (fireInsuranceItem == null){
            return 0;
        }

        // 更新期間が月額か年額
        if(fireInsuranceItem.PaymentType__c == CommonConst.ITEM_PAYMENTTYPE_MONTH){
            // 月額
            return fireInsuranceItem.FireInsuranceMonth__c;
        }else{
            // 年額
            return 0;
        }
    }
    // 月額保証料算出用
    private static Decimal setMonthlyFeeDeposit(Item__c DepositItem,Decimal allRent,Decimal RentFee){
        // 保証プランが取得できていなければ0円で返す。
        if(DepositItem == null){
            return 0;
        }

        // 明細が取得できなかった場合、月額保証料の算出が行えないので0円で返す。
        if(DepositItem.ItemDetailItem__r.isEmpty()){
            return 0;
        }

        // 保証プランが金額か割合かで金額を求める。
        if(DepositItem.ItemDetailItem__r[0].DepositRate__c != null ){
            // 保証料（割合）
            return setMonthlyFeeDepositRate(DepositItem, allRent, RentFee);

        }else{
            // 保証料（金額）
            return BuildingPropertyUtil.getNullToDecimalValue(DepositItem.ItemDetailItem__r[0].DepositYen__c);
        }

    }
    // 月額保証料の割合での算出
    private static Decimal setMonthlyFeeDepositRate(Item__c DepositItem,Decimal allRent,Decimal RentFee){

        // 賃料区分が総賃料
        if(DepositItem.ItemDetailItem__r[0].IsRentFeeType__c){
            // 総賃料
            return setMonthlyFeeDepositAllRate(DepositItem,allRent);
        }else{
            // 賃料
            return (DepositItem.ItemDetailItem__r[0].DepositRate__c / 100) * RentFee;

        }
    }
    // 月額保証料の総賃料での算出
    private static Decimal setMonthlyFeeDepositAllRate(Item__c DepositItem,Decimal allRent){

        Decimal Fee = 0 ; // 手数料
        // 口座手数料を含むか
        if(DepositItem.Account__r.IsAllRentFeeType__c){
            // 含む

            // 手数料の税込みを使用するか
            if(DepositItem.DirectDebitFeeTaxType__c == CommonConst.PROPERTY_TAXTYPE_TAXABLE){
                // 課税
                Fee = DepositItem.DirectDebitFeeTax__c;     // 手数料の税込み
            }else{
                // 非課税
                Fee = DepositItem.DirectDebitFee__c;        // 手数料税抜き
            }
        }else {
            // 含まない場合は手数料を入れない。
        }

        // 総賃料の計算
        return (DepositItem.ItemDetailItem__r[0].DepositRate__c / 100) * (allRent + Fee);
    }

    /**
     * スーモスコア計算処理呼び出し
     * @param  Id      propertyId       計算に使用する物件オブジェクトId
     * @return Integer   スーモスコア
     */
    public static Integer getSuumoScore(Id propertyId) {
        Set<Id> propIdSet = new Set<Id>();
        Map<id, Integer> resultMap = new Map<id, Integer>();
        propIdSet.add(propertyId);
        resultMap = getSuumoScore(propIdSet);
        return resultMap.get(propertyId);
    }

    /**
     * スーモスコア計算処理呼び出し
     * @param  Set<Id>      propertyIdSet       計算に使用する物件オブジェクトIdのSet
     * @return Map<id, Integer>     物件IDとスーモスコアのMap
     */
    public static Map<id, Integer> getSuumoScore(Set<Id> propertyIdSet) {

        // 取得結果のMap
        Map<id, Integer> idScoreMap = new Map<id, Integer>();
        // 物件情報の取得
        List<Property__c> propList = selectBuildingPropertyData(propertyIdSet);
        if(propList.size() == 0) {
            return idScoreMap;
        }
        // 建物Mapの作成
        Map<id, Building__c> idBuildMap = setBuildingDataForCalcScore(propList);
        // 建物写真の取得
        List<BuildingPhoto__c> buildPhotoList = selectBuildingPhotoData(propertyIdSet);
        // 建物IDと建物写真のMapを作成
        Map<id, BuildingPhoto__c> idBuildPhotoMap = new Map<id, BuildingPhoto__c>();
        for(BuildingPhoto__c buildPhoto : buildPhotoList) {
            idBuildPhotoMap.put(buildPhoto.Building__c, buildPhoto);
        }
        // 物件写真の取得
        List<PropertyPhoto__c> propPhotoList = selectPropertyPhotoData(propertyIdSet);
        // 物件IDと物件写真のMapを作成
        Map<id, PropertyPhoto__c> idPropPhotoMap = new Map<id, PropertyPhoto__c>();
        for(PropertyPhoto__c propPhoto : propPhotoList) {
            idPropPhotoMap.put(propPhoto.Property__c, propPhoto);
        }

        // スーモスコア計算
        for(Property__c prop : propList) {
            // 建物
            Building__c building = idBuildMap.get(prop.id);
            // 建物写真
            BuildingPhoto__c buildingPhoto = idBuildPhotoMap.get(building.id);
            // 物件写真
            PropertyPhoto__c propertyPhoto = idPropPhotoMap.get(prop.id);
            // 計算実行
            Integer score = getSuumoScore(building, buildingPhoto, prop, propertyPhoto, true);
            idScoreMap.put(prop.id, score);
        }

        return idScoreMap;
    }

    /**
     * スーモスコア計算処理
     * @param  Building__c      build       計算に使用する建物オブジェクト
     * @param  BuildingPhoto__c buildPhoto  計算に使用する建物写真オブジェクト
     * @param  Property__c      prop        計算に使用する物件オブジェクト
     * @param  PropertyPhoto__c propPhoto   計算に使用する物件写真オブジェクト
     * @param  Boolean          isSelectedSurroundingPhotoName  建物オブジェクトに参照関係の周辺施設系の写真名がSELECTされているか
     * @return Integer          計算結果
     */
    public static Integer getSuumoScore(Building__c build, BuildingPhoto__c buildPhoto, Property__c prop, PropertyPhoto__c propPhoto) {
        return getSuumoScore(build, buildPhoto, prop, propPhoto, false);
    }
    public static Integer getSuumoScore(Building__c build, BuildingPhoto__c buildPhoto, Property__c prop, PropertyPhoto__c propPhoto, Boolean isSelectedSurroundingPhotoName) {

        //null対応
        if (build == null) {
            build = new Building__c();
        }
        if (buildPhoto == null) {
            buildPhoto = new BuildingPhoto__c();
        }
        if (prop == null) {
            prop = new Property__c();
        }
        if (propPhoto == null ){
            propPhoto = new PropertyPhoto__c();
        }
                
        // 計上項目１（対象タグ毎5点、最大25点）
        // 対象タグ：
        //  物件写真（間取り図、居間・リビング、キッチン、バス）
        //  建物写真（建物外観）
        Integer itemCount = 0;
        itemCount += !String.isEmpty(buildPhoto.AppearanceFileName__c) ? 1 : 0; // 建物外観
        itemCount += !String.isEmpty(propPhoto.RoomLayoutFileName__c)  ? 1 : 0; // 間取り図
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_LIVING)  ? 1 : 0;  // 居間・リビング
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_KITCHEN) ? 1 : 0;  // キッチン
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_BATH)    ? 1 : 0;  // バス
        Integer calcItem1 = itemCount * 5;

        // 計上項目２（対象タグ毎1点、最大9点）
        // 対象タグ：
        //  物件写真（その他部屋・スペース、トイレ、洗面所、収納、バルコニー、庭、玄関、セキュリティ、その他設備、眺望、その他）
        //  建物写真（エントランス、ロビー、駐車場、その他共有部分）
        itemCount = 0;
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHERROOM)     ? 1 : 0;    // その他部屋・スペース
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_TOILET)        ? 1 : 0;    // トイレ
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_WASHROOM)      ? 1 : 0;    // 洗面所
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_STORAGE)       ? 1 : 0;    // 収納
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_BALCONY)       ? 1 : 0;    // バルコニー
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_GARDEN)        ? 1 : 0;    // 庭
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_ENTRANCE)      ? 1 : 0;    // 玄関
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_SECURITY)      ? 1 : 0;    // セキュリティ
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHERFACILITY) ? 1 : 0;    // その他設備
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_VIEW)          ? 1 : 0;    // 眺望
        itemCount += BuildingPropertyUtil.getExistsPropertyTag(propPhoto, CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHER)         ? 1 : 0;    // その他
        itemCount += !String.isEmpty(buildPhoto.EntranceFileName__c)        ? 1 : 0;    // エントランス
        itemCount += !String.isEmpty(buildPhoto.LobbyFileName__c)           ? 1 : 0;    // ロビー
        itemCount += !String.isEmpty(buildPhoto.ParkingFileName__c)         ? 1 : 0;    // 駐車場
        itemCount += !String.isEmpty(buildPhoto.OtherSharingFileName__c)    ? 1 : 0;    // その他共有部分
        Integer calcItem2 = itemCount > 9 ? 9 : itemCount;

        // 計上項目３（対象毎1点、最大1点）
        // 対象：
        //  建物写真．周辺写真
        //  建物．スーパー、コンビニ、病院、小学校、中学校、高校、大学
        itemCount = 0;
        itemCount += BuildingPropertyUtil.getExistsBuildingSurrounding(buildPhoto)          ? 1 : 0;    // 物件．周辺写真
        Building__c buildSurrPhoto = new Building__c();
        if (isSelectedSurroundingPhotoName) {
            buildSurrPhoto = build;
        } else {
            // 建物の周辺写真名がSelectされていなければ、Selectする
            buildSurrPhoto = selectBuildingSurroundingFacilityPhoto(build.Id);
        }
        itemCount += !String.isEmpty(buildSurrPhoto.Supermarket__r.PhotoFileName__c)        ? 1 : 0;    // スーパー
        itemCount += !String.isEmpty(buildSurrPhoto.ConvenienceStore__r.PhotoFileName__c)   ? 1 : 0;    // コンビニ
        itemCount += !String.isEmpty(buildSurrPhoto.GeneralHospital__r.PhotoFileName__c)    ? 1 : 0;    // 病院
        itemCount += !String.isEmpty(buildSurrPhoto.PrimarySchool1__r.PhotoFileName__c)     ? 1 : 0;    // 小学校１
        itemCount += !String.isEmpty(buildSurrPhoto.PrimarySchool2__r.PhotoFileName__c)     ? 1 : 0;    // 小学校２
        itemCount += !String.isEmpty(buildSurrPhoto.PrimarySchool3__r.PhotoFileName__c)     ? 1 : 0;    // 小学校３
        itemCount += !String.isEmpty(buildSurrPhoto.JuniorHighSchool1__r.PhotoFileName__c)  ? 1 : 0;    // 中学校１
        itemCount += !String.isEmpty(buildSurrPhoto.JuniorHighSchool2__r.PhotoFileName__c)  ? 1 : 0;    // 中学校２
        itemCount += !String.isEmpty(buildSurrPhoto.JuniorHighSchool3__r.PhotoFileName__c)  ? 1 : 0;    // 中学校３
        itemCount += !String.isEmpty(buildSurrPhoto.HighSchool__r.PhotoFileName__c)         ? 1 : 0;    // 高校
        itemCount += !String.isEmpty(buildSurrPhoto.University__r.PhotoFileName__c)         ? 1 : 0;    // 大学
        Integer calcItem3 = itemCount > 1 ? 1 : itemCount;

        // 計上項目４（対象の２項目両方に登録ありで2点）
        // 対象：
        //  SUUMOネット用キャッチ、SUUMOネット用キャッチコメント
        Integer calcItem4 = 0;
        if (!String.isEmpty(prop.SuumoNetCatch__c) && !String.isEmpty(prop.SuumoNetCatchComment__c)) {
            calcItem4 = 2;
        }

        // 計上項目５（対象が1つでもあれば4点）
        // 対象：
        //  物件写真．パノラマ写真
        Integer calcItem5 = getExistsPropertyPanorama(propPhoto) ? 4 : 0;

        return calcItem1 + calcItem2 + calcItem3 + calcItem4 + calcItem5;

    }
    // 指定した物件写真タグの有無取得
    private static Boolean getExistsPropertyTag(PropertyPhoto__c propPhoto, String targetTag) {
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) {
            if (targetTag == (String)propPhoto.get('PropertyPhotoTag' + i + '__c')) {
                return true;
            }
        }
        return false;
    }
    // 建物周辺写真の有無取得
    private static Boolean getExistsBuildingSurrounding(BuildingPhoto__c buildPhoto) {
        for (Integer i = 1; i <= CommonConst.MAXINDEX_BUILDING_SURROUNDING; i++) {
            if (!String.isEmpty((String)buildPhoto.get('SurroundingFileName' + i + '__c'))) {
                return true;
            }
        }
        return false;
    }
    // 物件パノラマ写真の有無取得
    private static Boolean getExistsPropertyPanorama(PropertyPhoto__c propPhoto) {
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) {
            if (!String.isEmpty((String)propPhoto.get('PanoramaFileName' + i + '__c'))) {
                return true;
            }
        }
        return false;
    }
    // 建物の周辺写真名の取得
    public static Building__c selectBuildingSurroundingFacilityPhoto(Id targetId) {
        List<Building__c> build = [
            SELECT
                Id
                ,Supermarket__r.PhotoFileName__c
                ,ConvenienceStore__r.PhotoFileName__c
                ,GeneralHospital__r.PhotoFileName__c
                ,PrimarySchool1__r.PhotoFileName__c
                ,PrimarySchool2__r.PhotoFileName__c
                ,PrimarySchool3__r.PhotoFileName__c
                ,JuniorHighSchool1__r.PhotoFileName__c
                ,JuniorHighSchool2__r.PhotoFileName__c
                ,JuniorHighSchool3__r.PhotoFileName__c
                ,HighSchool__r.PhotoFileName__c
                ,University__r.PhotoFileName__c
            FROM
                Building__c
            WHERE
                Id = :targetId
        ];
        if (build.isEmpty()){
            build = new List<Building__c>();
            return new Building__c();
        }
        return build[0];
    }


    /**
    * 設備情報の取得
    * @param  Id        propertyId  処理対象とする物件のId
    * @param  String    delimiter   区切り文字列
    * @return String    設備チェック項目文字列
    */
    public static String getFacilityList(Id propertyId, String delimiter) {
        Set<Id> propertyIdSet = new Set<Id>{propertyId};
        Map<Id, String> facilityMap = BuildingPropertyUtil.getFacilityList(propertyIdSet, delimiter);
        if (facilityMap.containsKey(propertyId)){
            return facilityMap.get(propertyId);
        } else {
            return null;
        }
    }
    /**
    * 設備情報の取得
    * @param  Set<Id>           propertyId  処理対象とする物件のId
    * @param  String            delimiter   区切り文字列
    * @return Map<Id, String>   設備チェック項目文字列Map ※Keyは物件ID
    */
    public static Map<Id, String> getFacilityList(Set<Id> propertyIdSet, String delimiter) {
        // 設備情報の対象項目の項目名を取得
        // 物件条件の項目の内、カスタムのチェックボックス項目をMapで取得
        Map<String, Schema.SObjectField> propCondFieldMap = Schema.getGlobalDescribe().get('PropertyConditions__c').getDescribe().fields.getMap();
        Map<String, String> customCheckBoxFieldName = new Map<String, String>();
        for (String apiName : propCondFieldMap.keySet()) {
            // 項目定義情報取得
            Schema.SObjectField sof = propCondFieldMap.get(apiName);
            Boolean isCustom = sof.getDescribe().isCustom();        // カスタム項目フラグ
            Schema.DisplayType type = sof.getDescribe().getType();  // データ型
            // カスタムチェックボックス項目の、API名・表示名をMapに保持
            if (isCustom && type == Schema.DisplayType.BOOLEAN) {
                customCheckBoxFieldName.put(
                    apiName
                    ,sof.getDescribe().getLabel()
                );
            }
        }
        
        // 物件条件の情報取得
        Map<Id, PropertyConditions__c> propCondMap = BuildingPropertyUtil.selectFacilityListData(propertyIdSet, customCheckBoxFieldName);
        Map<Id, String> facilityMap = new Map<Id, String>();
        for(Id propId : propCondMap.keySet()){
            PropertyConditions__c propCond = propCondMap.get(propId);
            String facilityList            = CommonConst.STRING_EMPTY;

            for (String apiName : customCheckBoxFieldName.keySet()) {   // 設備情報文字列の作成
                if ((Boolean)propCond.get(apiName)) {
                    if (!String.isEmpty(facilityList)) {    // チェックされているカスタムチェックボックス項目の「;」区切りの項目名一覧
                        facilityList += delimiter;
                    }
                    facilityList += customCheckBoxFieldName.get(apiName);
                }
            }
            facilityMap.put(propId, facilityList);
        } 
        return facilityMap;
    }

    /**
    * 設備情報の設定     
    * @param  PropertyConditions__c     propCond    設定先の物件条件
    * @param  String                    facility    設備の文字列
    * @param  String                    delimiter   区切り文字列
    * @return なし
     */
    public static void setFacility(PropertyConditions__c propCond, String facility, String delimiter) {
        // 値が空白の場合は、返却
        if (String.isEmpty(facility)) {
            return;
        }

        // 物件条件オブジェクト定義設定　※Keyは表示ラベル名
        Map<String, String> propCondFieldMap = new Map<String, String>();
        Set<String> propCondCheckboxSet      = new Set<String>();
        for(Schema.SObjectField field : Schema.getGlobalDescribe().get('PropertyConditions__c').getDescribe().fields.getMap().values()){
            // API名取得用
            propCondFieldMap.put(field.getDescribe().getLabel(), field.getDescribe().getName());    
            // カスタム項目&チェックボックス判定用
            Boolean isCustom = field.getDescribe().isCustom();          // カスタム項目フラグ
            Schema.DisplayType type = field.getDescribe().getType();    // データ型
            if (isCustom && type == Schema.DisplayType.BOOLEAN) {
                propCondCheckBoxSet.add(field.getDescribe().getLabel());
            }
        }

        // 物件条件を設定
        for (String labelName : facility.split(delimiter)) {
            if (propCondCheckboxSet.contains(labelName) && propCondFieldMap.containsKey(labelName)) {
                propCond.put(propCondFieldMap.get(labelName), true);
            }
        }
    }

    /**
    * 設備情報と物件条件の相違メッセージの設定
    * @param  PropertyConditions__c     propCond       設定先の物件条件
    * @param  String                    facility       設備の文字列
    * @param  String                    externalSiteCd 外部サイトコード
    * @param  String                    delimiter      区切り文字列
    * @param  Map<String, String>       changeFacilitiesMessageMap    設備と条件との相違メッセージ取得
    * @param  String                    changeFacilitiesMessageMapKey 設備と条件との相違メッセージ取得のKey値
    * @return なし
     */
    public static void changeFacilityMessage(PropertyConditions__c propCond, String facility, String externalSiteCd
                                             , String delimiter, Map<String, String> changeFacilitiesMessageMap
                                             , String changeFacilitiesMessageMapKey) {

        // 物件条件オブジェクトの定義取得
        String changeFacilitiesMessage = String.isBlank(changeFacilitiesMessageMap.get(changeFacilitiesMessageMapKey)) ? '' : changeFacilitiesMessageMap.get(changeFacilitiesMessageMapKey);

        // 物件条件の変更対象メッセージの生成
        changeFacilitiesMessage += checkPropertyConditions(propCond, facility, externalSiteCd, delimiter);

        // 物件条件変更メッセージをセットする。
        changeFacilitiesMessageMap.put(changeFacilitiesMessageMapKey,+ changeFacilitiesMessage);
    }

    /**
    * 管理会社指定商品の文字列の作成（物件詳細画面で使用しているためpublic）
    * @param  List<PropertyManageCompayItem__c>       propertyManageCompanyItemList  処理対象とする物件のId
    * @return String                                  連結された文字列
    */
    public static String createManagementCompanyItemString(List<PropertyManageCompayItem__c> propertyManageCompanyItemList) {
        List<String> itemDetailList = new List<String>();
        for (PropertyManageCompayItem__c item : propertyManageCompanyItemList) {
            String itemDetail = '';
            itemDetail += item.Item__r.ItemName__c;
            itemDetail += '：' + item.Item__r.AmountTax__c + '円';
            if (       item.Item__r.PaymentType__c == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_MONTH) {
                itemDetail += '/' + '月';
            } else if (item.Item__r.PaymentType__c == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_YEAR){
                itemDetail += '/' + '年';
            } else if (item.Item__r.PaymentType__c == CommonConst.MANAGEMENTCOMPANYITEM_PAYMENTTYPE_FIRST){
                itemDetail += '/' + '初回';
            }
            itemDetailList.add(itemDetail);
        }
        //連結
        return String.join(itemDetailList,'、');
    }

    /**
    * 建物物件差分作成処理
    * @param  Id       propertyId  処理対象とする物件のId
    * @return Boolean  実行結果（true:正常終了／false:異常終了）
    */
    private static final Integer MAXINDEX_BUILDPROPDIFF_ROOM = 10;
    private static final Integer MAXINDEX_BUILDPROPDIFFPHOTO_BUILDPHOTO = 5;
    private static final Integer MAXINDEX_BUILDPROPDIFFPHOTO_PROPPHOTO = 30;
    private static final Integer MAXINDEX_BUILDPROPDIFFPHOTO_PANORAMAPHOTO = 5;
    public static Boolean createBuildingPropertyDifference(Id propertyId) {
        try {
            Set<Id> propIdSet = new Set<Id>{propertyId};
            return BuildingPropertyUtil.createBuildingPropertyDifference(propIdSet);
        } catch(Exception e) {
            System.debug(e);
            return false;
        }
    }
    /**
    * 建物物件差分作成処理
    * @param  Set<Id>       propertyIdSet  処理対象とする物件のId
    * @return Boolean       実行結果（true:正常終了／false:異常終了）
    */
    public static Boolean createBuildingPropertyDifference(Set<Id> propertyIdSet) {
        // 建物物件差分の作成、INSERT
        Map<Id, Property__c> buildPropDiffMap = BuildingPropertyUtil.insertBuildingPropertyDifference(propertyIdSet);

        // // 建物物件差分（写真）の作成、INSERT
        BuildingPropertyUtil.insertBuildingPropertyDifferencePhoto(buildPropDiffMap);

        return true;
    }
    /**
     * 建物物件差分の作成
     * @param   Set<Id>                 処理対象とする物件のIdのセット
     * @return  Map<Id, Property__c>    作成した建物物件差分のもと物件の情報 Keyは建物物件差分ID
     */
    private static Map<Id, Property__c> insertBuildingPropertyDifference(Set<Id> propertyIdSet) {

        // 建物・物件関連情報の取得
        List<Property__c> bildPropList = BuildingPropertyUtil.selectBuildingPropertyData(propertyIdSet);

        // 部屋情報の取得
        Map<Id, List<Room__c>> roomMap = BuildingPropertyUtil.selectRoomData(propertyIdSet);

        // 物件条件の情報取得
        Map<Id, PropertyConditions__c> propCondMap = BuildingPropertyUtil.selectPropertyConditionsData(propertyIdSet);
        Map<Id, String> facilityMap                = BuildingPropertyUtil.getFacilityList(propertyIdSet, ';');
        
        // 物件管理会社指定商品の取得
        Map<Id, List<PropertyManageCompayItem__c>> propertyManageCompanyItemMap = BuildingPropertyUtil.selectPropertyManageCompanyItemData(propertyIdSet);
        
        // 国土地理協会の情報取得
        Set<String> choazaSet = new Set<String>();
        for (Property__c obj: bildPropList) {
            choazaSet.add(obj.Building__r.ChoazaCode__c);
        }
        Map<String, JapanGeographicDataCenterAddress__c> JGDCAddressMap = BuildingPropertyUtil.selectJGDCAddressData(choazaSet);

        // 建物物件差分の作成
        List<BuildingPropertyDifference__c> buildPropDiffList = new List<BuildingPropertyDifference__c>();
        for (Property__c prop : bildPropList) {
            BuildingPropertyDifference__c buildPropDiff = new BuildingPropertyDifference__c();
            buildPropDiff.BuildingId__c                                 = prop.Building__r.Id;                                                  // 建物.カスタムオブジェクト ID
            buildPropDiff.BuildingOwnerId__c                            = prop.Building__r.OwnerId;                                             // 建物.所有者 ID
            buildPropDiff.BuildingIsDeleted__c                          = prop.Building__r.IsDeleted;                                           // 建物.削除
            buildPropDiff.BuildingName__c                               = prop.Building__r.Name;                                                // 建物.建物名
            buildPropDiff.BuildingCreatedDate__c                        = prop.Building__r.CreatedDate;                                         // 建物.作成日
            buildPropDiff.BuildingCreatedById__c                        = prop.Building__r.CreatedById;                                         // 建物.作成者 ID
            buildPropDiff.BuildingLastModifiedDate__c                   = prop.Building__r.LastModifiedDate;                                    // 建物.最終更新日
            buildPropDiff.BuildingLastModifiedById__c                   = prop.Building__r.LastModifiedById;                                    // 建物.最終更新者 ID
            buildPropDiff.BuildingSystemModstamp__c                     = prop.Building__r.SystemModstamp;                                      // 建物.System Modstamp
            buildPropDiff.BuildName2__c                                 = prop.Building__r.BuildName2__c;                                       // 建物名2
            buildPropDiff.BuildName3__c                                 = prop.Building__r.BuildName3__c;                                       // 建物名3
            buildPropDiff.BuildKana__c                                  = prop.Building__r.BuildKana__c;                                        // 建物名(カナ)
            buildPropDiff.BuildKana2__c                                 = prop.Building__r.BuildKana2__c;                                       // 建物名(カナ)2
            buildPropDiff.BuildKana3__c                                 = prop.Building__r.BuildKana3__c;                                       // 建物名(カナ)3
            buildPropDiff.PostalCode__c                                 = prop.Building__r.PostalCode__c;                                       // 郵便番号
            buildPropDiff.ChoazaCode__c                                 = prop.Building__r.ChoazaCode__c;                                       // 町・字コード
            buildPropDiff.Address__c                                    = prop.Building__r.Address__c;                                          // 住所
            buildPropDiff.State__c                                      = prop.Building__r.State__c;                                            // 都道府県
            buildPropDiff.City__c                                       = prop.Building__r.City__c;                                             // 住所1(市区町村)
            buildPropDiff.Street__c                                     = prop.Building__r.Street__c;                                           // 住所2(番地)
            buildPropDiff.PropertyType__c                               = prop.Building__r.PropertyType__c;                                     // 物件種別
            buildPropDiff.Structure__c                                  = prop.Building__r.Structure__c;                                        // 建物構造
            buildPropDiff.BuildingYM__c                                 = prop.Building__r.BuildingYM__c;                                       // 築年月
            buildPropDiff.BuildingYMFormat__c                           = prop.Building__r.BuildingYMFormat__c;                                 // 築年月(編集)
            buildPropDiff.BuildingAge__c                                = prop.Building__r.BuildingAge__c;                                      // 築年数
            buildPropDiff.GroundFloorCount__c                           = prop.Building__r.GroundFloorCount__c;                                 // 地上階数
            buildPropDiff.UndergroundFloorCount__c                      = prop.Building__r.UndergroundFloorCount__c;                            // 地下階数
            buildPropDiff.HouseCount__c                                 = prop.Building__r.HouseCount__c;                                       // 棟総戸数
            buildPropDiff.Leasehold__c                                  = prop.Building__r.Leasehold__c;                                        // 借地権
            buildPropDiff.Location__c                                   = prop.Building__r.Location__c;                                         // 地勢
            buildPropDiff.CaretakerType__c                              = prop.Building__r.CaretakerType__c;                                    // 管理人種別
            buildPropDiff.Longitude__c                                  = prop.Building__r.Longitude__c;                                        // 経度
            buildPropDiff.Latitude__c                                   = prop.Building__r.Latitude__c;                                         // 緯度
            buildPropDiff.PrimarySchool1Name__c                         = prop.Building__r.PrimarySchool1__r.Name;                              // 小学校1
            buildPropDiff.PrimarySchool1Photo__c                        = prop.Building__r.PrimarySchool1__r.PhotoFilePath__c;                  // 小学校写真1
            buildPropDiff.PrimarySchool2Name__c                         = prop.Building__r.PrimarySchool2__r.Name;                              // 小学校2
            buildPropDiff.PrimarySchool2Photo__c                        = prop.Building__r.PrimarySchool2__r.PhotoFilePath__c;                  // 小学校写真2
            buildPropDiff.PrimarySchool3Name__c                         = prop.Building__r.PrimarySchool3__r.Name;                              // 小学校3
            buildPropDiff.PrimarySchool3Photo__c                        = prop.Building__r.PrimarySchool3__r.PhotoFilePath__c;                  // 小学校写真3
            buildPropDiff.PrimarySchoolDistance1__c                     = prop.Building__r.PrimarySchoolDistance1__c;                           // 小学校までの距離1
            buildPropDiff.PrimarySchoolDistance2__c                     = prop.Building__r.PrimarySchoolDistance2__c;                           // 小学校までの距離2
            buildPropDiff.PrimarySchoolDistance3__c                     = prop.Building__r.PrimarySchoolDistance3__c;                           // 小学校までの距離3
            buildPropDiff.PrimarySchoolWalkTime1__c                     = prop.Building__r.PrimarySchoolWalkTime1__c;                           // 小学校までの時間(分)1
            buildPropDiff.PrimarySchoolWalkTime2__c                     = prop.Building__r.PrimarySchoolWalkTime2__c;                           // 小学校までの時間(分)2
            buildPropDiff.PrimarySchoolWalkTime3__c                     = prop.Building__r.PrimarySchoolWalkTime3__c;                           // 小学校までの時間(分)3
            buildPropDiff.PrimarySchoolWalkTimeFormat1__c               = prop.Building__r.PrimarySchoolWalkTimeFormat1__c;                     // 小学校までの時間(分)1(編集)
            buildPropDiff.PrimarySchoolWalkTimeFormat2__c               = prop.Building__r.PrimarySchoolWalkTimeFormat2__c;                     // 小学校までの時間(分)2(編集)
            buildPropDiff.PrimarySchoolWalkTimeFormat3__c               = prop.Building__r.PrimarySchoolWalkTimeFormat3__c;                     // 小学校までの時間(分)3(編集)
            buildPropDiff.JuniorHighSchool1Name__c                      = prop.Building__r.JuniorHighSchool1__r.Name;                           // 中学校1
            buildPropDiff.JuniorHighSchool1Photo__c                     = prop.Building__r.JuniorHighSchool1__r.PhotoFilePath__c;               // 中学校写真1
            buildPropDiff.JuniorHighSchool2Name__c                      = prop.Building__r.JuniorHighSchool2__r.Name;                           // 中学校2
            buildPropDiff.JuniorHighSchool2Photo__c                     = prop.Building__r.JuniorHighSchool2__r.PhotoFilePath__c;               // 中学校写真2
            buildPropDiff.JuniorHighSchool3Name__c                      = prop.Building__r.JuniorHighSchool3__r.Name;                           // 中学校3
            buildPropDiff.JuniorHighSchool3Photo__c                     = prop.Building__r.JuniorHighSchool3__r.PhotoFilePath__c;               // 中学校写真3
            buildPropDiff.JuniorHighSchoolDistance1__c                  = prop.Building__r.JuniorHighSchoolDistance1__c;                        // 中学校までの距離1
            buildPropDiff.JuniorHighSchoolDistance2__c                  = prop.Building__r.JuniorHighSchoolDistance2__c;                        // 中学校までの距離2
            buildPropDiff.JuniorHighSchoolDistance3__c                  = prop.Building__r.JuniorHighSchoolDistance3__c;                        // 中学校までの距離3
            buildPropDiff.JuniorHighSchoolWalkTime1__c                  = prop.Building__r.JuniorHighSchoolWalkTime1__c;                        // 中学校までの時間(分)1
            buildPropDiff.JuniorHighSchoolWalkTime2__c                  = prop.Building__r.JuniorHighSchoolWalkTime2__c;                        // 中学校までの時間(分)2
            buildPropDiff.JuniorHighSchoolWalkTime3__c                  = prop.Building__r.JuniorHighSchoolWalkTime3__c;                        // 中学校までの時間(分)3
            buildPropDiff.JuniorHighSchoolWalkTimeFormat1__c            = prop.Building__r.JuniorHighSchoolWalkTimeFormat1__c;                  // 中学校までの時間(分)1(編集)
            buildPropDiff.JuniorHighSchoolWalkTimeFormat2__c            = prop.Building__r.JuniorHighSchoolWalkTimeFormat2__c;                  // 中学校までの時間(分)2(編集)
            buildPropDiff.JuniorHighSchoolWalkTimeFormat3__c            = prop.Building__r.JuniorHighSchoolWalkTimeFormat3__c;                  // 中学校までの時間(分)3(編集)
            buildPropDiff.HighSchoolName__c                             = prop.Building__r.HighSchool__r.Name;                                  // 高校
            buildPropDiff.HighSchoolPhoto__c                            = prop.Building__r.HighSchool__r.PhotoFilePath__c;                      // 高校写真
            buildPropDiff.HighSchoolDistance__c                         = prop.Building__r.HighSchoolDistance__c;                               // 高校までの距離
            buildPropDiff.HighSchoolWalkTime__c                         = prop.Building__r.HighSchoolWalkTime__c;                               // 高校までの時間(分)
            buildPropDiff.HighSchoolWalkTimeFormat__c                   = prop.Building__r.HighSchoolWalkTimeFormat__c;                         // 高校までの時間(分)(編集)
            buildPropDiff.UniversityName__c                             = prop.Building__r.University__r.Name;                                  // 大学
            buildPropDiff.UniversityPhoto__c                            = prop.Building__r.University__r.PhotoFilePath__c;                      // 大学写真
            buildPropDiff.UniversityDistance__c                         = prop.Building__r.UniversityDistance__c;                               // 大学までの距離
            buildPropDiff.UniversityWalkTime__c                         = prop.Building__r.UniversityWalkTime__c;                               // 大学までの時間(分)
            buildPropDiff.UniversityWalkTimeFormat__c                   = prop.Building__r.UniversityWalkTimeFormat__c;                         // 大学までの時間(分)(編集)
            buildPropDiff.ConvenienceStoreName__c                       = prop.Building__r.ConvenienceStore__r.Name;                            // コンビニ
            buildPropDiff.ConvenienceStorePhoto__c                      = prop.Building__r.ConvenienceStore__r.PhotoFilePath__c;                // コンビニ写真
            buildPropDiff.ConvenienceStoreDistance__c                   = prop.Building__r.ConvenienceStoreDistance__c;                         // コンビニまでの距離
            buildPropDiff.ConvenienceStoreWalkTime__c                   = prop.Building__r.ConvenienceStoreWalkTime__c;                         // コンビニまでの時間(分)
            buildPropDiff.ConvenienceStoreWalkTimeFormat__c             = prop.Building__r.ConvenienceStoreWalkTimeFormat__c;                   // コンビニまでの時間(分)(編集)
            buildPropDiff.SupermarketName__c                            = prop.Building__r.Supermarket__r.Name;                                 // スーパーマーケット
            buildPropDiff.SupermarketPhoto__c                           = prop.Building__r.Supermarket__r.PhotoFilePath__c;                     // スーパーマーケット写真
            buildPropDiff.SupermarketDistance__c                        = prop.Building__r.SupermarketDistance__c;                              // スーパーマーケットまでの距離
            buildPropDiff.SupermarketWalkTime__c                        = prop.Building__r.SupermarketWalkTime__c;                              // スーパーマーケットまでの時間(分)
            buildPropDiff.SupermarketWalkTimeFormat__c                  = prop.Building__r.SupermarketWalkTimeFormat__c;                        // スーパーマーケットまでの時間(分)(編集)
            buildPropDiff.GeneralHospitalName__c                        = prop.Building__r.GeneralHospital__r.Name;                             // 総合病院
            buildPropDiff.GeneralHospitalPhoto__c                       = prop.Building__r.GeneralHospital__r.PhotoFilePath__c;                 // 総合病院写真
            buildPropDiff.GeneralHospitalDistance__c                    = prop.Building__r.GeneralHospitalDistance__c;                          // 総合病院までの距離
            buildPropDiff.GeneralHospitalWalkTime__c                    = prop.Building__r.GeneralHospitalWalkTime__c;                          // 総合病院までの時間(分)
            buildPropDiff.GeneralHospitalWalkTimeFormat__c              = prop.Building__r.GeneralHospitalWalkTimeFormat__c;                    // 総合病院までの時間(分)(編集)
            buildPropDiff.TrainRoute1Name__c                            = prop.Building__r.TrainRoute1__r.Name;                                 // 沿線1
            buildPropDiff.SuumoTrainRoutecode1__c                       = prop.Building__r.TrainRoute1__r.SuumoTrainRouteCode__c;               // SUMMO路線コード1
            buildPropDiff.HomesTrainRoutecode1__c                       = prop.Building__r.TrainRoute1__r.HomesTrainRouteCode__c;               // HOME'S路線コード1
            buildPropDiff.AthomeTrainRoutecode1__c                      = prop.Building__r.TrainRoute1__r.AthomeTrainRouteCode__c;              // at home路線コード1
            buildPropDiff.Station1Name__c                               = prop.Building__r.Station1__r.Name;                                    // 駅1
            buildPropDiff.SuumoStationcode1__c                          = prop.Building__r.Station1__r.SuumoStationCode__c;                     // SUMMO駅コード1
            buildPropDiff.HomesStationcode1__c                          = prop.Building__r.Station1__r.HomesStationCode__c;                     // HOME'S駅コード1
            buildPropDiff.AtHomeStationcode1__c                         = prop.Building__r.Station1__r.AtHomeStationCode__c;                    // at home駅コード1
            buildPropDiff.StationDistance1__c                           = prop.Building__r.StationDistance1__c;                                 // 駅までの距離1
            buildPropDiff.StationWalkTime1__c                           = prop.Building__r.StationWalkTime1__c;                                 // 駅までの時間(分)1
            buildPropDiff.StationWalkTimeFormat1__c                     = prop.Building__r.StationWalkTimeFormat1__c;                           // 駅までの時間(分)1(編集)
            buildPropDiff.TrainRoute2Name__c                            = prop.Building__r.TrainRoute2__r.Name;                                 // 沿線2
            buildPropDiff.SuumoTrainRoutecode2__c                       = prop.Building__r.TrainRoute2__r.SuumoTrainRouteCode__c;               // SUMMO路線コード2
            buildPropDiff.HomesTrainRoutecode2__c                       = prop.Building__r.TrainRoute2__r.HomesTrainRouteCode__c;               // HOME'S路線コード2
            buildPropDiff.AthomeTrainRoutecode2__c                      = prop.Building__r.TrainRoute2__r.AthomeTrainRouteCode__c;              // at home路線コード2
            buildPropDiff.Station2Name__c                               = prop.Building__r.Station2__r.Name;                                    // 駅2
            buildPropDiff.SuumoStationcode2__c                          = prop.Building__r.Station2__r.SuumoStationCode__c;                     // SUMMO駅コード2
            buildPropDiff.HomesStationcode2__c                          = prop.Building__r.Station2__r.HomesStationCode__c;                     // HOME'S駅コード2
            buildPropDiff.AtHomeStationcode2__c                         = prop.Building__r.Station2__r.AtHomeStationCode__c;                    // at home駅コード2
            buildPropDiff.StationDistance2__c                           = prop.Building__r.StationDistance2__c;                                 // 駅までの距離2
            buildPropDiff.StationWalkTime2__c                           = prop.Building__r.StationWalkTime2__c;                                 // 駅までの時間(分)2
            buildPropDiff.StationWalkTimeFormat2__c                     = prop.Building__r.StationWalkTimeFormat2__c;                           // 駅までの時間(分)2(編集)
            buildPropDiff.TrainRoute3Name__c                            = prop.Building__r.TrainRoute3__r.Name;                                 // 沿線3
            buildPropDiff.SuumoTrainRoutecode3__c                       = prop.Building__r.TrainRoute3__r.SuumoTrainRouteCode__c;               // SUMMO路線コード3
            buildPropDiff.HomesTrainRoutecode3__c                       = prop.Building__r.TrainRoute3__r.HomesTrainRouteCode__c;               // HOME'S路線コード3
            buildPropDiff.AthomeTrainRoutecode3__c                      = prop.Building__r.TrainRoute3__r.AthomeTrainRouteCode__c;              // at home路線コード3
            buildPropDiff.Station3Name__c                               = prop.Building__r.Station3__r.Name;                                    // 駅3
            buildPropDiff.SuumoStationcode3__c                          = prop.Building__r.Station3__r.SuumoStationCode__c;                     // SUMMO駅コード3
            buildPropDiff.HomesStationcode3__c                          = prop.Building__r.Station3__r.HomesStationCode__c;                     // HOME'S駅コード3
            buildPropDiff.AtHomeStationcode3__c                         = prop.Building__r.Station3__r.AtHomeStationCode__c;                    // at home駅コード3
            buildPropDiff.StationDistance3__c                           = prop.Building__r.StationDistance3__c;                                 // 駅までの距離3
            buildPropDiff.StationWalkTime3__c                           = prop.Building__r.StationWalkTime3__c;                                 // 駅までの時間(分)3
            buildPropDiff.StationWalkTimeFormat3__c                     = prop.Building__r.StationWalkTimeFormat3__c;                           // 駅までの時間(分)3(編集)
            buildPropDiff.BusRoute1__c                                  = prop.Building__r.BusRoute1__c;                                        // バス路線名
            buildPropDiff.BusStop1__c                                   = prop.Building__r.BusStop1__c;                                         // バス停
            buildPropDiff.BusStopDistance1__c                           = prop.Building__r.BusStopDistance1__c;                                 // バス停までの距離
            buildPropDiff.BusStopWalkTime1__c                           = prop.Building__r.BusStopWalkTime1__c;                                 // バス停までの時間(分)
            buildPropDiff.BusStopWalkTimeFormat1__c                     = prop.Building__r.BusStopWalkTimeFormat1__c;                           // バス停までの時間(分)(編集)
            buildPropDiff.BusRideTime1__c                               = prop.Building__r.BusRideTime1__c;                                     // バス乗車時間(分)
            buildPropDiff.BusRideTimeFormat1__c                         = prop.Building__r.BusRideTimeFormat1__c;                               // バス乗車時間(分)(編集)
            buildPropDiff.BusStopToStationDistance1__c                  = prop.Building__r.BusStopToStationDistance1__c;                        // バス停からの距離
            buildPropDiff.BusStopToStationWalkTime1__c                  = prop.Building__r.BusStopToStationWalkTime1__c;                        // バス停からの時間(分)
            buildPropDiff.BusStopToStationWalkTimeFormat1__c            = prop.Building__r.BusStopToStationWalkTimeFormat1__c;                  // バス停からの時間(分)(編集)
            buildPropDiff.BusRoute2__c                                  = prop.Building__r.BusRoute2__c;                                        // バス路線名2
            buildPropDiff.BusStop2__c                                   = prop.Building__r.BusStop2__c;                                         // バス停2
            buildPropDiff.BusStopDistance2__c                           = prop.Building__r.BusStopDistance2__c;                                 // バス停までの距離2
            buildPropDiff.BusStopWalkTime2__c                           = prop.Building__r.BusStopWalkTime2__c;                                 // バス停までの時間(分)2
            buildPropDiff.BusStopWalkTimeFormat2__c                     = prop.Building__r.BusStopWalkTimeFormat2__c;                           // バス停までの時間(分)2(編集)
            buildPropDiff.BusRideTime2__c                               = prop.Building__r.BusRideTime2__c;                                     // バス乗車時間(分)2
            buildPropDiff.BusRideTimeFormat2__c                         = prop.Building__r.BusRideTimeFormat2__c;                               // バス乗車時間(分)2(編集)
            buildPropDiff.BusStopToStationDistance2__c                  = prop.Building__r.BusStopToStationDistance2__c;                        // バス停からの距離2
            buildPropDiff.BusStopToStationWalkTime2__c                  = prop.Building__r.BusStopToStationWalkTime2__c;                        // バス停からの時間(分)2
            buildPropDiff.BusStopToStationWalkTimeFormat2__c            = prop.Building__r.BusStopToStationWalkTimeFormat2__c;                  // バス停からの時間(分)2(編集)
            buildPropDiff.BusRoute3__c                                  = prop.Building__r.BusRoute3__c;                                        // バス路線名3
            buildPropDiff.BusStop3__c                                   = prop.Building__r.BusStop3__c;                                         // バス停3
            buildPropDiff.BusStopDistance3__c                           = prop.Building__r.BusStopDistance3__c;                                 // バス停までの距離3
            buildPropDiff.BusStopWalkTime3__c                           = prop.Building__r.BusStopWalkTime3__c;                                 // バス停までの時間(分)3
            buildPropDiff.BusStopWalkTimeFormat3__c                     = prop.Building__r.BusStopWalkTimeFormat3__c;                           // バス停までの時間(分)3(編集)
            buildPropDiff.BusRideTime3__c                               = prop.Building__r.BusRideTime3__c;                                     // バス乗車時間(分)3
            buildPropDiff.BusRideTimeFormat3__c                         = prop.Building__r.BusRideTimeFormat3__c;                               // バス乗車時間(分)3(編集)
            buildPropDiff.BusStopToStationDistance3__c                  = prop.Building__r.BusStopToStationDistance3__c;                        // バス停からの距離3
            buildPropDiff.BusStopToStationWalkTime3__c                  = prop.Building__r.BusStopToStationWalkTime3__c;                        // バス停からの時間(分)3
            buildPropDiff.BusStopToStationWalkTimeFormat3__c            = prop.Building__r.BusStopToStationWalkTimeFormat3__c;                  // バス停からの時間(分)3(編集)
            buildPropDiff.District__c                                   = prop.Building__r.District__c;                                         // 地区
            buildPropDiff.BuildingPhotoCount__c                         = prop.Building__r.BuildingPhotoCount__c;                               // 建物写真枚数
            buildPropDiff.BuildingPhotoLastModifiedDate__c              = prop.Building__r.BuildingPhotoLastModifiedDate__c;                    // 建物写真最終更新日
            buildPropDiff.BuildingRemarksPublic__c                      = prop.Building__r.BuildingRemarksPublic__c;                            // 建物備考(公開)
            buildPropDiff.IsBuildingMergeCompletedFlag__c               = prop.Building__r.IsMergeCompletedFlag__c;                             // 建物名寄せ完了フラグ
            buildPropDiff.BuildingRemarksPrivate__c                     = prop.Building__r.BuildingRemarksPrivate__c;                           // 建物備考(非公開)
            buildPropDiff.BuildingMaintenanceType__c                    = prop.Building__r.MaintenanceType__c;                                  // 建物メンテナンス区分
            buildPropDiff.BuildingMaintenanceComment__c                 = prop.Building__r.MaintenanceComment__c;                               // 建物メンテナンスコメント
            buildPropDiff.BuildingImportType__c                         = prop.Building__r.ImportType__c;                                       // 建物取込区分
            buildPropDiff.MaintenanceBuildingCode__c                    = prop.Building__r.MaintenanceBuildingCode__c;                          // メンテナンス建物コード
            // 国土地理協会住所の情報
            if (JGDCAddressMap.containsKey(prop.Building__r.ChoazaCode__c)) {
                buildPropDiff.JGDCAState__c                             = JGDCAddressMap.get(prop.Building__r.ChoazaCode__c).State__c;          // 国土地理協会.都道府県
                buildPropDiff.JGDCACity__c                              = JGDCAddressMap.get(prop.Building__r.ChoazaCode__c).City__c;           // 国土地理協会.市区郡町村
                buildPropDiff.JGDCAOazaAlias__c                         = JGDCAddressMap.get(prop.Building__r.ChoazaCode__c).OazaAlias__c;      // 国土地理協会.大字通称
                buildPropDiff.JGDCAAzaName__c                           = JGDCAddressMap.get(prop.Building__r.ChoazaCode__c).AzaName__c;        // 国土地理協会.字名
            }
            buildPropDiff.IsFirstSurroundingImportFlag__c               = prop.Building__r.IsFirstSurroundingImportFlag__c;                     // 初回周辺取込フラグ
            buildPropDiff.PropertyId__c                                 = prop.Id;                                                              // 物件.カスタムオブジェクト ID
            buildPropDiff.PropertyIsDeleted__c                          = prop.IsDeleted;                                                       // 物件.削除
            buildPropDiff.PropertyName__c                               = prop.Name;                                                            // 物件.部屋番号
            buildPropDiff.PropertyCreatedDate__c                        = prop.CreatedDate;                                                     // 物件.作成日
            buildPropDiff.PropertyCreatedById__c                        = prop.CreatedById;                                                     // 物件.作成者 ID
            buildPropDiff.PropertyLastModifiedDate__c                   = prop.LastModifiedDate;                                                // 物件.最終更新日
            buildPropDiff.PropertyLastModifiedById__c                   = prop.LastModifiedById;                                                // 物件.最終更新者 ID
            buildPropDiff.PropertySystemModstamp__c                     = prop.SystemModstamp;                                                  // 物件.System Modstamp
            buildPropDiff.PropertyCode__c                               = prop.PropertyCode__c;                                                 // 物件コード
            buildPropDiff.Building__c                                   = prop.Building__c;                                                     // 建物
            buildPropDiff.LivedType__c                                  = prop.LivedType__c;                                                    // 未入居種別
            buildPropDiff.LiveStatus__c                                 = prop.LiveStatus__c;                                                   // 現況
            buildPropDiff.FloorType__c                                  = prop.FloorType__c;                                                    // 地下階区分
            buildPropDiff.Floor__c                                      = prop.Floor__c;                                                        // 所在階
            buildPropDiff.RoomArea__c                                   = prop.RoomArea__c;                                                     // 専有面積(㎡)
            buildPropDiff.RoomCount__c                                  = prop.RoomCount__c;                                                    // 部屋数
            buildPropDiff.RoomLayout__c                                 = prop.RoomLayout__c;                                                   // 間取り
            buildPropDiff.BalconyDirection__c                           = prop.BalconyDirection__c;                                             // バルコニー方向
            buildPropDiff.ContractTermYear__c                           = prop.ContractTermYear__c;                                             // 契約期間 (年)
            buildPropDiff.ContractTermMonth__c                          = prop.ContractTermMonth__c;                                            // 契約期間 (月)
            buildPropDiff.RentType__c                                   = prop.RentType__c;                                                     // 定期借家区分
            buildPropDiff.RentTermYear__c                               = prop.RentTermYear__c;                                                 // 定借期間 (年)
            buildPropDiff.RentTermMonth__c                              = prop.RentTermMonth__c;                                                // 定借期間 (月)
            buildPropDiff.RentTermDay__c                                = prop.RentTermDay__c;                                                  // 定借期間 (日)
            buildPropDiff.RenovationComplateYear__c                     = prop.RenovationComplateYear__c;                                       // リノベ施工完了 (年)
            buildPropDiff.RenovationComplateMonth__c                    = prop.RenovationComplateMonth__c;                                      // リノベ施工完了 (月) 
            buildPropDiff.RenovationContent__c                          = prop.RenovationContent__c;                                            // リノベ施工内容
            buildPropDiff.TransactionAspect__c                          = prop.TransactionAspect__c;                                            // 取引態様
            buildPropDiff.DeliveryType__c                               = prop.DeliveryType__c;                                                 // 引渡種別
            buildPropDiff.DeliveryYear__c                               = prop.DeliveryYear__c;                                                 // 引渡 年
            buildPropDiff.DeliveryMonth__c                              = prop.DeliveryMonth__c;                                                // 引渡 月
            buildPropDiff.DeliveryTiming__c                             = prop.DeliveryTiming__c;                                               // 引渡 旬
            buildPropDiff.DeliveryDay__c                                = prop.DeliveryDay__c;                                                  // 引渡 日
            buildPropDiff.DeliveryConsultation__c                       = prop.DeliveryConsultation__c;                                         // 引渡・入居日 (相談内容)
            buildPropDiff.PropertyRemarksPublic__c                      = prop.PropertyRemarksPublic__c;                                        // 物件備考(公開)
            buildPropDiff.PropertyRemarksPrivate__c                     = prop.PropertyRemarksPrivate__c;                                       // 物件備考(非公開)
            buildPropDiff.PropertyComment__c                            = prop.PropertyComment__c;                                              // 物件コメント
            buildPropDiff.RepresentativeComment__c                      = prop.RepresentativeComment__c;                                        // 担当者コメント
            buildPropDiff.RentFee__c                                    = prop.RentFee__c;                                                      // 賃料
            buildPropDiff.ManagementFee__c                              = prop.ManagementFee__c;                                                // 管理費
            buildPropDiff.ManagementFeeTax__c                           = prop.ManagementFeeTax__c;                                             // 管理費(税込)
            buildPropDiff.ManagementFeeTaxType__c                       = prop.ManagementFeeTaxType__c;                                         // 管理費税区分
            buildPropDiff.WortFee__c                                    = prop.WortFee__c;                                                      // 水道料金
            buildPropDiff.WortFeeTax__c                                 = prop.WortFeeTax__c;                                                   // 水道料金(税込)
            buildPropDiff.WortFeeTaxType__c                             = prop.WortFeeTaxType__c;                                               // 水道料金税区分
            buildPropDiff.TownshipFee__c                                = prop.TownshipFee__c;                                                  // 町会費
            buildPropDiff.TownshipFeeTax__c                             = prop.TownshipFeeTax__c;                                               // 町会費(税込)
            buildPropDiff.TownshipFeeTaxType__c                         = prop.TownshipFeeTaxType__c;                                           // 町会費税区分
            buildPropDiff.TownshipFeePaymentType__c                     = prop.TownshipFeePaymentType__c;                                       // 町会費支払区分
            buildPropDiff.RenewalFeeYen__c                              = prop.RenewalFeeYen__c;                                                // 更新料(円)
            buildPropDiff.RenewalFeeMonth__c                            = prop.RenewalFeeMonth__c;                                              // 更新料(ヵ月)
            buildPropDiff.RenewalFee__c                                 = prop.RenewalFee__c;                                                   // 更新料(税込)
            buildPropDiff.RenewalFeeUnit__c                             = prop.RenewalFeeUnit__c;                                               // 更新単位
            buildPropDiff.RenewalFeeTaxType__c                          = prop.RenewalFeeTaxType__c;                                            // 更新税区分
            buildPropDiff.ParkingType__c                                = prop.ParkingType__c;                                                  // 駐車場種別
            buildPropDiff.ParkingDistance__c                            = prop.ParkingDistance__c;                                              // 駐車場までの距離
            buildPropDiff.ParkingFee__c                                 = prop.ParkingFee__c;                                                   // 駐車場料金
            buildPropDiff.ParkingFeeTax__c                              = prop.ParkingFeeTax__c;                                                // 駐車場料金(税込)
            buildPropDiff.ParkingFeeTaxType__c                          = prop.ParkingFeeTaxType__c;                                            // 駐車場料金税区分
            buildPropDiff.ParkingDepositYen__c                          = prop.ParkingDepositYen__c;                                            // 駐車場保証料金(円)
            buildPropDiff.ParkingDepositMonth__c                        = prop.ParkingDepositMonth__c;                                          // 駐車場保証料金(ヵ月)
            buildPropDiff.ParkingDepositUnit__c                         = prop.ParkingDepositUnit__c;                                           // 駐車場保証料単位
            buildPropDiff.ParkingDepositTax__c                          = prop.ParkingDepositTax__c;                                            // 駐車場保証料金(税込)
            buildPropDiff.ParkingDepositTaxType__c                      = prop.ParkingDepositTaxType__c;                                        // 駐車場保証料金税区分
            buildPropDiff.ParkingCompoundingFeeYen__c                   = prop.ParkingCompoundingFeeYen__c;                                     // 駐車場手数料(円)
            buildPropDiff.ParkingCompoundingFeeMonth__c                 = prop.ParkingCompoundingFeeMonth__c;                                   // 駐車場手数料(ヵ月)
            buildPropDiff.ParkingCompoundingFeeUnit__c                  = prop.ParkingCompoundingFeeUnit__c;                                    // 駐車場手数料単位
            buildPropDiff.ParkingCompoundingFeeTaxType__c               = prop.ParkingCompoundingFeeTaxType__c;                                 // 駐車場手数料税区分
            buildPropDiff.ParkingCompoundingFeeTax__c                   = prop.ParkingCompoundingFeeTax__c;                                     // 駐車場手数料(税込)
            buildPropDiff.ParkingRemarksPublic__c                       = prop.ParkingRemarksPublic__c;                                         // 駐車場備考(公開)
            buildPropDiff.ParkingRemarksPrivate__c                      = prop.ParkingRemarksPrivate__c;                                        // 駐車場備考(非公開)
            buildPropDiff.MonetaryPublic__c                             = prop.MonetaryPublic__c;                                               // 金銭備考(公開)
            buildPropDiff.MonetaryPrivate__c                            = prop.MonetaryPrivate__c;                                              // 金銭備考(非公開)
            buildPropDiff.SecurityDepositYen__c                         = prop.SecurityDepositYen__c;                                           // 敷金(円)
            buildPropDiff.SecurityDepositMonth__c                       = prop.SecurityDepositMonth__c;                                         // 敷金(ヵ月)
            buildPropDiff.SecurityDepositUnit__c                        = prop.SecurityDepositUnit__c;                                          // 敷金単位
            buildPropDiff.KeyMoneyYen__c                                = prop.KeyMoneyYen__c;                                                  // 礼金(円)
            buildPropDiff.KeyMoneyMonth__c                              = prop.KeyMoneyMonth__c;                                                // 礼金(ヵ月)
            buildPropDiff.KeyMoneyUnit__c                               = prop.KeyMoneyUnit__c;                                                 // 礼金単位
            buildPropDiff.DepositYen__c                                 = prop.DepositYen__c;                                                   // 保証料金(円)
            buildPropDiff.DepositMonth__c                               = prop.DepositMonth__c;                                                 // 保証料金(ヵ月)
            buildPropDiff.DepositUnit__c                                = prop.DepositUnit__c;                                                  // 保証金単位
            buildPropDiff.CancellationActualFeeYen__c                   = prop.CancellationActualFeeYen__c;                                     // 敷引・償却(円)
            buildPropDiff.CancellationActualFeeMonth__c                 = prop.CancellationActualFeeMonth__c;                                   // 敷引・償却(ヵ月)
            buildPropDiff.CancellationActualFeeRate__c                  = prop.CancellationActualFeeRate__c;                                    // 敷引・償却(%)
            buildPropDiff.CancellationActualFeeUnit__c                  = prop.CancellationActualFeeUnit__c;                                    // 敷引・償却単位
            buildPropDiff.FireInsuranceUseType__c                       = prop.FireInsuranceUseType__c;                                         // 火災保険料(利用区分)
            buildPropDiff.FireInsuranceCompanyName__c                   = prop.FireInsuranceCompany__r.Name;                                    // 火災保険会社
            buildPropDiff.FireInsurancePlanItemName__c                  = prop.FireInsurancePlan__r.ItemName__c;                                // 火災保険名
            buildPropDiff.FireInsurancePlanPaymentType__c               = prop.FireInsurancePlan__r.PaymentType__c;                             // 更新期間
            buildPropDiff.FireInsurancePlanPaymentYear__c               = prop.FireInsurancePlan__r.PaymentYear__c;                             // 更新年数
            buildPropDiff.FireInsurancePlanFireInsuranceYear__c         = prop.FireInsurancePlan__r.FireInsuranceYear__c;                       // 火災保険料(年額)
            buildPropDiff.FireInsurancePlanFireInsuranceMonth__c        = prop.FireInsurancePlan__r.FireInsuranceMonth__c;                      // 火災保険料(月額)
            buildPropDiff.FireInsurancePlanFireInsurance__c             = prop.FireInsurancePlan__r.FireInsurance__c;                           // 保険内容
            buildPropDiff.FireInsurancePlanTenantCompensation__c        = prop.FireInsurancePlan__r.TenantCompensation__c;                      // 借家人賠償額
            buildPropDiff.FireInsurancePlanHouseGoodsDeposit__c         = prop.FireInsurancePlan__r.HouseGoodsDeposit__c;                       // 家財保証額
            buildPropDiff.KeyExchangeFee__c                             = prop.KeyExchangeFee__c;                                               // 鍵交換費
            buildPropDiff.KeyExchangeFeeTax__c                          = prop.KeyExchangeFeeTax__c;                                            // 鍵交換費(税込)
            buildPropDiff.KeyExchangeFeeTaxType__c                      = prop.KeyExchangeFeeTaxType__c;                                        // 鍵交換費税区分
            buildPropDiff.KeyPlace__c                                   = prop.KeyPlace__c;                                                     // 鍵所在
            buildPropDiff.GuaranteeidCompanyType__c                     = prop.GuaranteeidCompanyType__c;                                       // 保証会社(利用区分)
            buildPropDiff.GuaranteeidCompanyName__c                     = prop.GuaranteeidCompany__r.Name;                                      // 保証会社名
            buildPropDiff.GuarantorAgencyCompanyTypeName__c             = prop.GuaranteeidCompany__r.GuarantorAgencyCompanyType__c;             // 保証人代行会社区分コード
            buildPropDiff.GuaranteeidItemName__c                        = prop.Guaranteeid__r.ItemName__c;                                      // 保証名
            buildPropDiff.GuaranteeidItemAssuranceContent__c            = prop.Guaranteeid__r.AssuranceContent__c;                              // 保証内容
            buildPropDiff.GuaranteeidItemDirectDebitFee__c              = prop.Guaranteeid__r.DirectDebitFee__c;                                // 保証手数料
            buildPropDiff.GuaranteeidItemDirectDebitFeeTax__c           = prop.Guaranteeid__r.DirectDebitFeeTax__c;                             // 保証手数料(税込)
            buildPropDiff.GuaranteeidItemDirectDebitFeeTaxType__c       = prop.Guaranteeid__r.DirectDebitFeeTaxType__c;                         // 保証手数料税区分
            buildPropDiff.GuaranteeidItemRemarks__c                     = prop.Guaranteeid__r.Remarks__c;                                       // 備考
            buildPropDiff.FormerSupplierName__c                         = prop.FormerSupplier__r.Name;                                          // 元付業者名
            buildPropDiff.FormerSupplierPropertyType__c                 = prop.FormerSupplier__r.IppamGyobutsu__c;                              // 一般/業物
            buildPropDiff.FormerSupplierFixedTermSend__c                = prop.FormerSupplier__r.FixedTermSend__c;                              // 定期送信
            buildPropDiff.FormerSupplierIntroduction__c                 = prop.FormerSupplier__r.Introduction__c;                               // 紹介
            buildPropDiff.FormerSupplierRenewalFeeShow__c               = prop.FormerSupplier__r.RenewalFeeShow__c;                             // 更新料表記
            buildPropDiff.FormerSupplierCleaningFeeShow__c              = prop.FormerSupplier__r.CleaningFeeShow__c;                            // 定額補修費表記
            buildPropDiff.FormerSupplierPhone__c                        = prop.FormerSupplierPhone__c;                                          // 元付業者.電話番号
            buildPropDiff.FormerSupplierFax__c                          = prop.FormerSupplierFax__c;                                            // 元付業者.Fax
            buildPropDiff.FormerSupplierPostalCode__c                   = prop.FormerSupplierPostalCode__c;                                     // 元付業者.郵便番号
            buildPropDiff.FormerSupplierAddress__c                      = prop.FormerSupplierAddress__c;                                        // 元付業者.住所
            buildPropDiff.FormerSupplierState__c                        = prop.FormerSupplierState__c;                                          // 元付業者.都道府県
            buildPropDiff.FormerSupplierCity__c                         = prop.FormerSupplierCity__c;                                           // 元付業者.住所1(市区町村)
            buildPropDiff.FormerSupplierStreet__c                       = prop.FormerSupplierStreet__c;                                         // 元付業者.住所2(番地)
            buildPropDiff.FormerSupplierEmail__c                        = prop.FormerSupplierEmail__c;                                          // 元付業者.メール
            buildPropDiff.FormerSupplierRepresentative__c               = prop.FormerSupplierRepresentative__c;                                 // 元付業者.担当者名
            buildPropDiff.FormerSupplierDepartment__c                   = prop.FormerSupplierDepartment__c;                                     // 元付業者.担当部署
            buildPropDiff.FormerSupplierRepresentativePhone__c          = prop.FormerSupplierRepresentativePhone__c;                            // 元付業者.担当者電話番号
            buildPropDiff.FormerSupplierRemarks__c                      = prop.FormerSupplier__r.RemarksPublic__c;                              // 元付業者.備考
            buildPropDiff.OwnerName__c                                  = prop.Owner__r.Name;                                                   // 所有者名
            buildPropDiff.OwnerPhone__c                                 = prop.OwnerPhone__c;                                                   // 所有者.電話番号
            buildPropDiff.OwnerFax__c                                   = prop.OwnerFax__c;                                                     // 所有者.Fax
            buildPropDiff.OwnerPostalCode__c                            = prop.OwnerPostalCode__c;                                              // 所有者.郵便番号
            buildPropDiff.OwnerAddress__c                               = prop.OwnerAddress__c;                                                 // 所有者.住所
            buildPropDiff.OwnerState__c                                 = prop.OwnerState__c;                                                   // 所有者.都道府県
            buildPropDiff.OwnerCity__c                                  = prop.OwnerCity__c;                                                    // 所有者.住所1(市区町村)
            buildPropDiff.OwnerStreet__c                                = prop.OwnerStreet__c;                                                  // 所有者.住所2(番地)
            buildPropDiff.OwnerEmail__c                                 = prop.OwnerEmail__c;                                                   // 所有者.メール
            buildPropDiff.OwnerRepresentative__c                        = prop.OwnerRepresentative__c;                                          // 所有者.担当者名
            buildPropDiff.OwnerDepartment__c                            = prop.OwnerDepartment__c;                                              // 所有者.担当部署
            buildPropDiff.OwnerRepresentativePhone__c                   = prop.OwnerRepresentativePhone__c;                                     // 所有者.担当者電話番号
            buildPropDiff.OwnerRemarks__c                               = prop.Owner__r.RemarksPublic__c;                                       // 所有者.元付 元付業者.備考
            buildPropDiff.CreditorName__c                               = prop.Creditor__r.Name;                                                // 貸主名
            buildPropDiff.CreditorPhone__c                              = prop.CreditorPhone__c;                                                // 貸主.電話番号
            buildPropDiff.CreditorFax__c                                = prop.CreditorFax__c;                                                  // 貸主.Fax
            buildPropDiff.CreditorPostalCode__c                         = prop.CreditorPostalCode__c;                                           // 貸主.郵便番号
            buildPropDiff.CreditorAddress__c                            = prop.CreditorAddress__c;                                              // 貸主.住所
            buildPropDiff.CreditorState__c                              = prop.CreditorState__c;                                                // 貸主.都道府県
            buildPropDiff.CreditorCity__c                               = prop.CreditorCity__c;                                                 // 貸主.住所1(市区町村)
            buildPropDiff.CreditorStreet__c                             = prop.CreditorStreet__c;                                               // 貸主.住所2(番地)
            buildPropDiff.CreditorEmail__c                              = prop.CreditorEmail__c;                                                // 貸主.メール
            buildPropDiff.CreditorRepresentative__c                     = prop.CreditorRepresentative__c;                                       // 貸主.担当者名
            buildPropDiff.CreditorDepartment__c                         = prop.CreditorDepartment__c;                                           // 貸主.担当部署
            buildPropDiff.CreditorRepresentativePhone__c                = prop.CreditorRepresentativePhone__c;                                  // 貸主.担当者電話番号
            buildPropDiff.CreditorRemarks__c                            = prop.Creditor__r.RemarksPublic__c;                                    // 貸主.備考
            buildPropDiff.IsPropertyNameHiddenFlag__c                   = prop.IsPropertyNameHiddenFlag__c;                                     // 物件名非表示フラグ
            buildPropDiff.Score__c                                      = prop.Score__c;                                                        // 点数
            buildPropDiff.PropertyPhotoCount__c                         = prop.PropertyPhotoCount__c;                                           // 物件写真枚数
            buildPropDiff.PhotoCount__c                                 = prop.PhotoCount__c;                                                   // 写真枚数
            buildPropDiff.PropertyPhotoLastModifiedDate__c              = prop.PropertyPhotoLastModifiedDate__c;                                // 物件写真最終更新日
            buildPropDiff.PhotoLastModifiedDate__c                      = prop.PhotoLastModifiedDate__c;                                        // 写真最終更新日
            buildPropDiff.RewardType__c                                 = prop.RewardType__c;                                                   // 報酬形態
            buildPropDiff.RewardBurdenLender__c                         = prop.RewardBurdenLender__c;                                           // 報酬負担貸主
            buildPropDiff.RewardBurdenBorrower__c                       = prop.RewardBurdenBorrower__c;                                         // 報酬負担借主
            buildPropDiff.RewardSplitFormerSupplier__c                  = prop.RewardSplitFormerSupplier__c;                                    // 報酬配分元付
            buildPropDiff.RewardSplitCustomer__c                        = prop.RewardSplitCustomer__c;                                          // 報酬配分客付
            buildPropDiff.ADFeeYen__c                                   = prop.ADFeeYen__c;                                                     // 広告料(円)
            buildPropDiff.ADFeeMonth__c                                 = prop.ADFeeMonth__c;                                                   // 広告料(ヵ月)
            buildPropDiff.ADFeeRate__c                                  = prop.ADFeeRate__c;                                                    // 広告料(%)
            buildPropDiff.ADFeeUnit__c                                  = prop.ADFeeUnit__c;                                                    // 広告料単位
            buildPropDiff.ADFeeTax__c                                   = prop.ADFeeTax__c;                                                     // 広告料(税込)
            buildPropDiff.ADFeeTaxType__c                               = prop.ADFeeTaxType__c;                                                 // 広告料税区分
            buildPropDiff.ADFeeComment__c                               = prop.ADFeeComment__c;                                                 // 広告料コメント
            buildPropDiff.WebPublishing__c                              = prop.WebPublishing__c;                                                // web公開
            buildPropDiff.IsPropertyMergeCompletedFlag__c               = prop.IsMergeCompletedFlag__c;                                         // 物件名寄せ完了フラグ
            buildPropDiff.BalconyArea__c                                = prop.BalconyArea__c;                                                  // バルコニー面積
            buildPropDiff.SuumoNetCatch__c                              = CommonUtil.subStringLeft(prop.SuumoNetCatch__r.ExampleSentence__c, 30);           // SUUMOネット用キャッチ
            buildPropDiff.SuumoNetCatchComment__c                       = CommonUtil.subStringLeft(prop.SuumoNetCatchComment__r.ExampleSentence__c, 100);   // SUUMOネット用キャッチコメント
            buildPropDiff.HomesPropertyFeature__c                       = CommonUtil.subStringLeft(prop.HomesPropertyFeature__r.ExampleSentence__c, 100);   // HOME'S物件の特徴
            buildPropDiff.AthomeRecommendComment__c                     = CommonUtil.subStringLeft(prop.AthomeRecommendComment__r.ExampleSentence__c, 200); // at homeおすすめコメント
            buildPropDiff.AthomeRecommendCommentStaffId__c              = prop.AthomeRecommendCommentStaffId__c;                                // at homeおすすめコメントスタッフＩＤ
            buildPropDiff.AthomePanoramaContentsId__c                   = prop.AthomePanoramaContentsId__c;                                     // at homeパノラマコンテンツＩＤ
            buildPropDiff.PropertyImportType__c                         = prop.ImportType__c;                                                   // 物件取込区分
            buildPropDiff.SuumoRemarks__c                               = prop.SuumoRemarks__c;                                                 // SUUMO備考
            buildPropDiff.HomesRemarks__c                               = prop.HomesRemarks__c;                                                 // HOME'S備考
            buildPropDiff.AtHomeRemarks__c                              = prop.AtHomeRemarks__c;                                                // at home備考
            buildPropDiff.FreeRentTermMonth__c                          = null;                                                                 // フリーレント期間(ヶ月)
            buildPropDiff.FreeRentContent__c                            = null;                                                                 // フリーレント内容
            buildPropDiff.MaintenancePropertyCode__c                    = prop.MaintenancePropertyCode__c;                                      // メンテナンス物件コード
            buildPropDiff.ADRemarksPublic__c                            = prop.ADRemarksPublic__c;                                              // 広告備考(公開)
            buildPropDiff.ADRemarksPrivate__c                           = prop.ADRemarksPrivate__c;                                             // 広告備考(非公開)
            buildPropDiff.CATVFee__c                                    = prop.CATVFee__c;                                                      // CATV
            buildPropDiff.CATVFeeTax__c                                 = prop.CATVFeeTax__c;                                                   // CATV(税込)
            buildPropDiff.CATVTaxType__c                                = prop.CATVTaxType__c;                                                  // CATV税区分
            buildPropDiff.GarbageDisposalFee__c                         = prop.GarbageDisposalFee__c;                                           // ゴミ処理費
            buildPropDiff.GarbageDisposalFeeTax__c                      = prop.GarbageDisposalFeeTax__c;                                        // ゴミ処理費(税込)
            buildPropDiff.GarbageDisposalFeeTaxType__c                  = prop.GarbageDisposalFeeTaxType__c;                                    // ゴミ処理費税区分
            buildPropDiff.GarbageDisposalFeePaymentType__c              = prop.GarbageDisposalFeePaymentType__c;                                // ゴミ処理費支払区分
            buildPropDiff.BicycleParkingFee__c                          = prop.BicycleParkingFee__c;                                            // 駐輪場代
            buildPropDiff.BicycleParkingFeeTax__c                       = prop.BicycleParkingFeeTax__c;                                         // 駐輪場代(税込)
            buildPropDiff.BicycleParkingFeeTaxType__c                   = prop.BicycleParkingFeeTaxType__c;                                     // 駐輪場代税区分
            buildPropDiff.BikeParkingSmallFee__c                        = prop.BikeParkingSmallFee__c;                                          // 小型バイク置場料金
            buildPropDiff.BikeParkingSmallFeeTax__c                     = prop.BikeParkingSmallFeeTax__c;                                       // 小型バイク置場料金(税込)
            buildPropDiff.BikeParkingSmallFeeTaxType__c                 = prop.BikeParkingSmallFeeTaxType__c;                                   // 小型バイク置場料金税区分
            buildPropDiff.BikeParkingMediumFee__c                       = prop.BikeParkingMediumFee__c;                                         // 中型バイク置場料金
            buildPropDiff.BikeParkingMediumFeeTax__c                    = prop.BikeParkingMediumFeeTax__c;                                      // 中型バイク置場料金(税込)
            buildPropDiff.BikeParkingMediumFeeTaxType__c                = prop.BikeParkingMediumFeeTaxType__c;                                  // 中型バイク置場料金税区分
            buildPropDiff.BikeParkinLargeFee__c                         = prop.BikeParkinLargeFee__c;                                           // 大型バイク置場料金
            buildPropDiff.BikeParkinLargeFeeTax__c                      = prop.BikeParkinLargeFeeTax__c;                                        // 大型バイク置場料金(税込)
            buildPropDiff.BikeParkinLargeFeeTaxType__c                  = prop.BikeParkinLargeFeeTaxType__c;                                    // 大型バイク置場料金税区分
            buildPropDiff.TownshipInitialFee__c                         = prop.TownshipInitialFee__c;                                           // 入町費
            buildPropDiff.TownshipInitialFeeTax__c                      = prop.TownshipInitialFeeTax__c;                                        // 入町費(税込)
            buildPropDiff.TownshipInitialFeeTaxType__c                  = prop.TownshipInitialFeeTaxType__c;                                    // 入町費税区分
            buildPropDiff.CleaningFeeYen__c                             = prop.CleaningFeeYen__c;                                               // 定額修繕費(円)
            buildPropDiff.CleaningFeeMonth__c                           = prop.CleaningFeeMonth__c;                                             // 定額修繕費(ヵ月)
            buildPropDiff.CleaningFeeTax__c                             = prop.CleaningFeeTax__c;                                               // 定額修繕費(税込)
            buildPropDiff.CleaningFeeUnit__c                            = prop.CleaningFeeUnit__c;                                              // 定額修繕費単位
            buildPropDiff.CleaningFeeTaxType__c                         = prop.CleaningFeeTaxType__c;                                           // 定額修繕費税区分
            buildPropDiff.CleaningFeePaymentType__c                     = prop.CleaningFeePaymentType__c;                                       // 定額修繕費支払区分
            buildPropDiff.IsShortTermPenalty__c                         = prop.IsShortTermPenalty__c;                                           // 短期解約違約金有無
            buildPropDiff.ShortTermPenaltyLessYear__c                   = prop.ShortTermPenaltyLessYear__c;                                     // 短期解約違約金未満(年)
            buildPropDiff.ShortTermPenaltyFee__c                        = prop.ShortTermPenaltyFee__c;                                          // 短期解約違約金
            buildPropDiff.ShortTermPenaltyLessYear2__c                  = prop.ShortTermPenaltyLessYear2__c;                                    // 短期解約違約金未満(年)２
            buildPropDiff.ShortTermPenaltyFee2__c                       = prop.ShortTermPenaltyFee2__c;                                         // 短期解約違約金２
            buildPropDiff.PropertyMaintenanceType__c                    = prop.MaintenanceType__c;                                              // 物件メンテナンス区分
            buildPropDiff.PropertyMaintenanceCommentArea__c             = prop.MaintenanceCommentArea__c;                                       // 物件メンテナンスコメント
            buildPropDiff.IsOwnCompanyPropertyFlag__c                   = prop.IsOwnCompanyPropertyFlag__c;                                     // 自社物フラグ
            buildPropDiff.IsBulkConfirmation__c                         = prop.IsBulkConfirmation__c;                                           // 一括確認チェック
            buildPropDiff.BulkConfirmationDate__c                       = prop.BulkConfirmationDate__c;                                         // 一括確認日
            buildPropDiff.ManualMaintenanceDate__c                      = prop.ManualMaintenanceDate__c;                                        // 手動最終メンテナンス日
            buildPropDiff.AutoMaintenanceDate__c                        = prop.AutoMaintenanceDate__c;                                          // 自動最終メンテナンス日
            buildPropDiff.OwnCompanyManageModDate__c                    = prop.OwnCompanyManageModDate__c;                                      // 自社管理修正日
            buildPropDiff.ManualModifiedDate__c                         = prop.ManualModifiedDate__c;                                           // 手動登録更新日
            buildPropDiff.TemporarySaveDate__c                          = prop.TemporarySaveDate__c;                                            // 一時保存日
            buildPropDiff.SuumoPanoramaShop__c                          = prop.SuumoPanoramaShop__c;                                            // SUUMOパノラマ掲載店舗
            buildPropDiff.HomesPanoramaShop__c                          = prop.HomesPanoramaShop__c;                                            // HOME'Sパノラマ掲載店舗
            buildPropDiff.AtHomePanoramaShop__c                         = prop.AtHomePanoramaShop__c;                                           // at homeパノラマ掲載店舗
            buildPropDiff.SpecificExcellentRentBurdenUpperLimit__c      = prop.SpecificExcellentRentBurdenUpperLimit__c;                        // 特優賃入居負担額上限
            buildPropDiff.SpecificExcellentRentBurdenLowerLimit__c      = prop.SpecificExcellentRentBurdenLowerLimit__c;                        // 特優賃入居負担額下限
            buildPropDiff.SpecificExcellentRentFeeFluctuationType__c    = prop.SpecificExcellentRentFeeFluctuationType__c;                      // 特優賃料金変動区分
            buildPropDiff.SpecificExcellentRentFeeUpwardRate__c         = prop.SpecificExcellentRentFeeUpwardRate__c;                           // 特優賃上昇率
            buildPropDiff.SpecificExcellentRentSupportYears__c          = prop.SpecificExcellentRentSupportYears__c;                            // 特優賃家賃補助年数
            buildPropDiff.SpecificExcellentRentRemarks__c               = prop.SpecificExcellentRentRemarks__c;                                 // 特優賃備考
            buildPropDiff.MaintenanceLastModifiedDate__c                = prop.MaintenanceLastModifiedDate__c;                                  // 最終メンテナンス日付
            buildPropDiff.IsPostingEndDayBefore__c                      = prop.IsPostingEndDayBefore__c;                                        // 掲載終了前日
            buildPropDiff.IsPostingEndRecent__c                         = prop.IsPostingEndRecent__c;                                           // 掲載終了直近
            buildPropDiff.FormerSupplierMaintenanceSupplierCode__c      = prop.FormerSupplierMaintenanceSupplierCode__c;                        // メンテナンス業者コード
            buildPropDiff.BrokerageFeeTax__c                            = prop.BrokerageFeeTax__c;                                              // 仲介手数料(税込)
			// ▼ 2022/03/28 CHINTAI対応追加
			buildPropDiff.ChintaiTrainRoutecode1__c                     = prop.Building__r.TrainRoute1__r.ChintaiTrainRouteCode__c;             // CHINTAI路線コード1
            buildPropDiff.ChintaiTrainRoutecode2__c                     = prop.Building__r.TrainRoute2__r.ChintaiTrainRouteCode__c;             // CHINTAI路線コード2
            buildPropDiff.ChintaiTrainRoutecode3__c                     = prop.Building__r.TrainRoute3__r.ChintaiTrainRouteCode__c;             // CHINTAI路線コード3
            buildPropDiff.ChintaiStationcode1__c                        = prop.Building__r.Station1__r.ChintaiStationCode__c;                   // CHINTAI駅コード1
            buildPropDiff.ChintaiStationcode2__c                        = prop.Building__r.Station2__r.ChintaiStationCode__c;                   // CHINTAI駅コード2
            buildPropDiff.ChintaiStationcode3__c                        = prop.Building__r.Station3__r.ChintaiStationCode__c;                   // CHINTAI駅コード3
			buildPropDiff.ChintaiMagazineComment__c                     = CommonUtil.subStringLeft(prop.ChintaiMagazineComment__r.ExampleSentence__c, 160);// CHINTAI雑誌コメント
			// ▲ 2022/03/28 CHINTAI対応追加
            // 部屋の情報
            if (roomMap.containsKey(prop.Id)) {
                List<Room__c> propRoomList = roomMap.get(prop.Id);
                Integer i = 1;
                for (Room__c room : propRoomList) {
                    if (i > BuildingPropertyUtil.MAXINDEX_BUILDPROPDIFF_ROOM) {    // 10 部屋まで
                        break;
                    }
                    buildPropDiff.put('RoomFloorSpace' + i + '__c', room.RoomFloorSpace__c);
                    buildPropDiff.put('RoomType' + i + '__c'      , room.RoomType__c);
                    i++;
                }
            }
            // 部屋の情報
        
            // 物件条件の情報
            if (facilityMap.containsKey(prop.Id)) {
                //フリーレントが含まれる場合、取り除く（連携を行わないため）
                String conditionsString =facilityMap.get(prop.Id);
                if (String.isNotBlank(conditionsString)){
                    if (conditionsString.contains('フリーレント')){
                        conditionsString = conditionsString.remove(';フリーレント');
                        conditionsString = conditionsString.remove('フリーレント;');
                        conditionsString = conditionsString.remove('フリーレント');
                    }
                }
                buildPropDiff.FacilityList__c           = conditionsString;             // 設備情報（「;」区切りのtrueのチェックボックス表示名）
            }
            if (propCondMap.containsKey(prop.Id)) {
                PropertyConditions__c propCond = propCondMap.get(prop.Id);
                buildPropDiff.FacilityRemarksPublic__c  = propCond.FacilityRemarksPublic__c;    // 設備備考(公開)
                buildPropDiff.ContractRemarks__c        = propCond.ContractRemarks__c;          // 契約備考
                buildPropDiff.PetRemarks__c             = propCond.PetRemarks__c;               // ペット(その他)備考
            }
            // 物件条件の情報

            // 物件管理会社指定商品の情報（金銭備考に入れる）
            // ポータルサイト構築 追加 管理会社指定商品、金銭備考（公開）他社ポータル　の設定もここで行う
            setPropertyManagementCompanyItemData(buildPropDiff, prop, propertyManageCompanyItemMap);
            
            
            buildPropDiffList.add(buildPropDiff);
        }
        // 建物物件差分 作成
        SecureDML.secureInsert(buildPropDiffList);

        // 返却
        Map<Id, Property__c> buildPropDiffIdMap = new Map<Id, Property__c>();
        for (BuildingPropertyDifference__c obj : buildPropDiffList) {
            Property__c porp = new Property__c(Id = obj.PropertyId__c, Building__c = obj.BuildingId__c);
            buildPropDiffIdMap.put(obj.Id, porp);
        }
        return buildPropDiffIdMap;
    }

    // 建物物件差分（写真）の作成
    private static void insertBuildingPropertyDifferencePhoto(Map<Id, Property__c> propBuildDiffMap) {
        // Set<Id>作成
        Set<Id> buildPropIdSet       = new Set<Id>();
        Set<Id> buildPropDiffIdSet = new Set<Id>();
        for (Id key : propBuildDiffMap.keySet()) {
            buildPropDiffIdSet.add(Key);
            buildPropIdSet.add(propBuildDiffMap.get(key).Id);
        }

        // 建物写真情報の取得
        List<BuildingPhoto__c> bpList       = BuildingPropertyUtil.selectBuildingPhotoData(buildPropIdSet);
        Map<Id, AnyPhotoData> buildPhotoMap = new Map<Id, AnyPhotoData>();  //Key:建物ID
        for (BuildingPhoto__c bp : bpList) {
            if (!buildPhotoMap.containsKey(bp.Building__c)) {
                buildPhotoMap.put(bp.Building__c, new AnyPhotoData(bp));
            } 
        }
        // 物件写真情報の取得
        List<PropertyPhoto__c> ppList              = BuildingPropertyUtil.selectPropertyPhotoData(buildPropIdSet);
        Map<Id, AnyPhotoData> propPhotoMap         = new Map<Id, AnyPhotoData>();   //Key:物件ID
        Map<Id, AnyPhotoData> propPanoramaPhotoMap = new Map<Id, AnyPhotoData>();   //Key:物件ID
        for (PropertyPhoto__c pp : ppList) {
            if (!propPhotoMap.containsKey(pp.Property__c)) {
                propPhotoMap.put(pp.Property__c, new AnyPhotoData(pp, false));
            }
            if (!propPanoramaPhotoMap.containsKey(pp.Property__c)) {
                propPanoramaPhotoMap.put(pp.Property__c, new AnyPhotoData(pp, true));
            }
        }

        // 建物物件写真番号の取得
        Map<Id, String> buildPropDiffNameMap = getBuildPropDiffName(buildPropDiffIdSet);    //Key:建物物件差分ID

        // 建物物件差分（写真）への値設定
        List<BuildingPropertyDifferencePhoto__c> buildPropDiffPhotoList = new List<BuildingPropertyDifferencePhoto__c>();
        for (Id key : propBuildDiffMap.keySet()) {
            // ID設定
            Id buildPropDiffId = key;
            Id builldingId     = propBuildDiffMap.get(key).Building__c;
            Id PropertyId      = propBuildDiffMap.get(key).Id;

            BuildingPropertyDifferencePhoto__c buildPropDiffPhoto = new BuildingPropertyDifferencePhoto__c();
            // 物件写真名
            if (buildPropDiffNameMap.containsKey(buildPropDiffId)) {
                buildPropDiffPhoto.Name = buildPropDiffNameMap.get(buildPropDiffId);
            }
            // 建物写真
            Integer i = 1;
            if (buildPhotoMap.containsKey(builldingId)){
                List<BuildingPropertyUtil.PhotoData> photoList = buildPhotoMap.get(builldingId).photoDataList;
                for (BuildingPropertyUtil.PhotoData photoData : photoList) { // 建物写真
                    buildPropDiffPhoto.put('BuildingPhotoTag' + i + '__c'                   , photoData.tag);
                    buildPropDiffPhoto.put('BuildingPhotoComment' + i + '__c'               , photoData.comment);
                    buildPropDiffPhoto.put('BuildingPhotoPhotoFileName' + i + '__c'         , photoData.fileName);
                    buildPropDiffPhoto.put('BuildingPhotoPhoto' + i + '__c'                 , photoData.photo);
                    buildPropDiffPhoto.put('BuildingPhotoSurroundingEnvironment' + i + '__c', photoData.environment);
                    buildPropDiffPhoto.put('BuildingPhotoSurroundingPhotoName' + i + '__c'  , photoData.photoName);
                    buildPropDiffPhoto.put('SurroundingDistance' + i + '__c'                , photoData.distance);
                    i++;
                }
            }

            // 物件写真
            i = 1;
            if (propPhotoMap.containsKey(propertyId)) {
                List<BuildingPropertyUtil.PhotoData> photoList = propPhotoMap.get(propertyId).photoDataList;
                for (BuildingPropertyUtil.PhotoData photoData : photoList) {  // 物件写真
                    buildPropDiffPhoto.put('PropertyPhotoTag' + i + '__c'                   , photoData.tag);
                    buildPropDiffPhoto.put('PropertyPhotoComment' + i + '__c'               , photoData.comment);
                    buildPropDiffPhoto.put('PropertyPhotoPhotoFileName' + i + '__c'         , photoData.fileName);
                    buildPropDiffPhoto.put('PropertyPhotoPhoto' + i + '__c'                 , photoData.photo);
                    i++;
                }
            }
            // 物件パノラマ写真
            i = 1;
            if (propPanoramaPhotoMap.containsKey(propertyId)) {
                List<BuildingPropertyUtil.PhotoData> photoList = propPanoramaPhotoMap.get(propertyId).photoDataList;
                for (BuildingPropertyUtil.PhotoData photoData : photoList) {  
                    buildPropDiffPhoto.put('PanoramaTag' + i + '__c'                   , photoData.tag);
                    buildPropDiffPhoto.put('PanoramaComment' + i + '__c'               , photoData.comment);
                    buildPropDiffPhoto.put('PanoramaPhotoFileName' + i + '__c'         , photoData.fileName);
                    buildPropDiffPhoto.put('PanoramaPhoto' + i + '__c'                 , photoData.photo);
                    i++;
                }
            }

            // 建物物件差分（写真） 作成
            buildPropDiffPhotoList.add(buildPropDiffPhoto);
        }
        // 建物物件差分（写真） 作成
        if (buildPropDiffPhotoList.size() > 0) {
            SecureDML.secureInsert(buildPropDiffPhotoList);
        }
    }
    
    
    // 物件管理会社指定商品の情報設定（金銭備考）
    private static void setPropertyManagementCompanyItemData(BuildingPropertyDifference__c buildPropDiff, Property__c prop, Map<Id, List<PropertyManageCompayItem__c>> propertyManageCompanyItemMap){
        
        //一行目の作成
        String monetaryPublicFirstLine = '';
        if (propertyManageCompanyItemMap.containsKey(prop.Id)) {
            List<PropertyManageCompayItem__c> propertyManageCompanyItemList = propertyManageCompanyItemMap.get(prop.Id);
                    
            //管理会社指定商品ごとに、連結文字列の作成
            monetaryPublicFirstLine = createManagementCompanyItemString(propertyManageCompanyItemList);
        }
        String monetaryPublic = String.isBlank(prop.MonetaryPublic__c) ? '' : prop.MonetaryPublic__c; //金銭備考

        // 金銭備考（公開）他社ポータルは、管理会社指定商品の情報が記載された1行目　＋　本来の金銭備考　とする。
        String newMonetaryPublic = (monetaryPublicFirstLine + '\n' + monetaryPublic);
        buildPropDiff.MonetaryPublic__c = newMonetaryPublic.mid(0,80000);//文字数制限に合わせて切り捨て

        //ポータルサイト構築 追加 Start

        // 金銭備考（公開）自社ポータル　は、本来の金銭備考　とする。
        buildPropDiff.MonetaryPublicMyCompanyPortal__c  = monetaryPublic;
        // 管理会社指定商品　は、管理会社指定商品の情報が記載された1行目
        buildPropDiff.ManagementCompanyDesignationProduct__c = monetaryPublicFirstLine;

        //ポータルサイト構築 追加 End
    }
    
    // 国土地理協会住所情報の取得
    private static JapanGeographicDataCenterAddress__c selectJGDCAddressData(String choazaCode) {
        Set<String> choazaCodeSet = new Set<String>{choazaCode};
        Map<String, JapanGeographicDataCenterAddress__c> choazaMap = BuildingPropertyUtil.selectJGDCAddressData(choazaCodeSet);
        if (choazaMap.containsKey(choazaCode)) {
            return choazaMap.get(choazaCode);
        } else {
            return new JapanGeographicDataCenterAddress__c();
        }
    }
    private static Map<String, JapanGeographicDataCenterAddress__c> selectJGDCAddressData(Set<String> choazaCodeSet) {
        List<JapanGeographicDataCenterAddress__c> JGDCAddressList = [
            SELECT
                 ChoazaCodeNew__c
                ,State__c
                ,City__c
                ,OazaAlias__c
                ,AzaName__c
            FROM
                JapanGeographicDataCenterAddress__c
            WHERE
                ObsoleteYM__c = '000000'
            AND ChoazaCodeNew__c IN :choazaCodeSet
        ];

        Map<String, JapanGeographicDataCenterAddress__c> JGDCAddressMap = new Map<String, JapanGeographicDataCenterAddress__c>();
        for (JapanGeographicDataCenterAddress__c obj : JGDCAddressList) {
            JGDCAddressMap.put(obj.ChoazaCodeNew__c, obj);
        }
        return JGDCAddressMap;
    }

    // 物件写真情報の取得
    private static PropertyPhoto__c selectPropertyPhotoData(Id propertyId) {
        Set<Id> propIdSet = new Set<Id>();
        propIdSet.add(propertyId);
        List<PropertyPhoto__c> propPhotoList = BuildingPropertyUtil.selectPropertyPhotoData(propIdSet);
        if (propPhotoList.size() == 0) {
            return new PropertyPhoto__c();
        }
        return propPhotoList[0];
    }
    private static List<PropertyPhoto__c> selectPropertyPhotoData(Set<Id> propertyIdSet) {
        String sql = '';
        sql += 'SELECT Id ';
        sql += '      ,Property__c ';
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PROPERTY; i++) { // 物件写真
        sql += ' ,PropertyPhotoFileName' + i + '__c ';
        sql += ' ,PropertyPhotoTag' + i + '__c ';
        sql += ' ,PropertyPhotoComment' + i + '__c ';
        sql += ' ,PropertyPhotoFilePath' + i + '__c ';
        }
        for (Integer i = 1; i <= CommonConst.MAXINDEX_PROPERTY_PANORAMA; i++) { // 物件パノラマ
        sql += ' ,PanoramaFileName' + i + '__c ';
        sql += ' ,PanoramaTag' + i + '__c ';
        sql += ' ,PanoramaComment' + i + '__c ';
        sql += ' ,PanoramaFilePath' + i + '__c ';
        }
        sql += ' ,RoomLayoutFileName__c ';  // 物件間取り図
        sql += ' ,RoomLayoutFilePath__c ';
        sql += ' FROM PropertyPhoto__c ';
        sql += ' WHERE Property__c IN :propertyIdSet ';
        List<PropertyPhoto__c> propPhotoList = Database.query(sql);
        if (propPhotoList.size() == 0) {
            return new List<PropertyPhoto__c>();
        }
        return propPhotoList;
    }

    // 建物写真情報の取得
    private static BuildingPhoto__c selectBuildingPhotoData(Id propertyId) {
        Set<Id> propIdSet = new Set<Id>{propertyId};
        List<BuildingPhoto__c> buildPhotoList = BuildingPropertyUtil.selectBuildingPhotoData(propIdSet);
        if (buildPhotoList.size() == 0) {
            return new BuildingPhoto__c();
        }
        return buildPhotoList[0];

    }
    private static List<BuildingPhoto__c> selectBuildingPhotoData(Set<Id> propertyIdSet) {
        String sql = '';
        sql += 'SELECT ';
        sql += '  Id ';
        sql += ' ,Building__c';
        sql += ' ,AppearanceFileName__c ';         // 建物外観
        sql += ' ,AppearanceComment__c ';
        sql += ' ,AppearanceFilePath__c ';
        sql += ' ,AppearanceParseFileName__c ';    // 建物外観パース
        sql += ' ,AppearanceParseComment__c ';
        sql += ' ,AppearanceParseFilePath__c ';
        sql += ' ,EntranceFileName__c ';           // 建物エントランス
        sql += ' ,EntranceComment__c ';
        sql += ' ,EntranceFilePath__c ';
        sql += ' ,LobbyFileName__c ';              // 建物ロビー
        sql += ' ,LobbyComment__c ';
        sql += ' ,LobbyFilePath__c ';
        sql += ' ,ParkingFileName__c ';            // 建物駐車場
        sql += ' ,ParkingComment__c ';
        sql += ' ,ParkingFilePath__c ';
        sql += ' ,OtherSharingFileName__c ';       // 建物その他共有
        sql += ' ,OtherSharingComment__c ';
        sql += ' ,OtherSharingFilePath__c ';
        sql += ' ,MapFileName__c ';                // 建物地図
        sql += ' ,MapComment__c ';
        sql += ' ,MapFilePath__c ';
        sql += ' ,OtherFileName__c ';              // 建物その他
        sql += ' ,OtherComment__c ';
        sql += ' ,OtherFilePath__c ';
        for (Integer i = 1; i <= CommonConst.MAXINDEX_BUILDING_SURROUNDING; i++) {  // 建物周辺
        sql += ' ,SurroundingTag' + i + '__c ';
        sql += ' ,SurroundingComment' + i + '__c ';
        sql += ' ,SurroundingFileName' + i + '__c ';
        sql += ' ,SurroundingFilePath' + i + '__c ';
        sql += ' ,SurroundingPhotoName' + i + '__c ';
        sql += ' ,SurroundingDistance' + i + '__c ';
        }
        sql += ' FROM BuildingPhoto__c ';
        sql += ' WHERE Building__c IN ( ';
        sql += '  SELECT Building__c ';
        sql += '  FROM Property__c ';
        sql += '  WHERE Id IN :propertyIdSet';
        sql += '  ) ';
        List<BuildingPhoto__c> buildPhotoList = Database.query(sql);
        if (buildPhotoList.size() == 0) {
            return new List<BuildingPhoto__c>();
        }
        return buildPhotoList;
    }

    // 物件・建物等の情報取得
    private static Property__c selectBuildingPropertyData(Id propertyId) {
        Set<Id> propertyIdSet = new Set<Id>{propertyId};
        List<Property__c> propList = BuildingPropertyUtil.selectBuildingPropertyData(propertyIdSet);
        if (propList.size() > 0) {
            return propList[0];
        } else {
            return new Property__c();
        }
    }
    private static List<Property__c> selectBuildingPropertyData(Set<Id> propertyIdSet) {
        List<Property__c> propList = [
            SELECT
                Building__r.Id
                ,Building__r.OwnerId
                ,Building__r.IsDeleted
                ,Building__r.Name
                ,Building__r.CreatedDate
                ,Building__r.CreatedById
                ,Building__r.LastModifiedDate
                ,Building__r.LastModifiedById
                ,Building__r.SystemModstamp
                ,Building__r.BuildName2__c
                ,Building__r.BuildName3__c
                ,Building__r.BuildKana__c
                ,Building__r.BuildKana2__c
                ,Building__r.BuildKana3__c
                ,Building__r.PostalCode__c
                ,Building__r.ChoazaCode__c
                ,Building__r.Address__c
                ,Building__r.State__c
                ,Building__r.City__c
                ,Building__r.Street__c
                ,Building__r.PropertyType__c
                ,Building__r.Structure__c
                ,Building__r.BuildingYM__c
                ,Building__r.BuildingYMFormat__c
                ,Building__r.BuildingAge__c
                ,Building__r.GroundFloorCount__c
                ,Building__r.UndergroundFloorCount__c
                ,Building__r.HouseCount__c
                ,Building__r.Leasehold__c
                ,Building__r.Location__c
                ,Building__r.CaretakerType__c
                ,Building__r.Longitude__c
                ,Building__r.Latitude__c
                ,Building__r.PrimarySchool1__r.Name
                ,Building__r.PrimarySchool1__r.PhotoFilePath__c
                ,Building__r.PrimarySchool1__r.PhotoFileName__c
                ,Building__r.PrimarySchool2__r.Name
                ,Building__r.PrimarySchool2__r.PhotoFilePath__c
                ,Building__r.PrimarySchool2__r.PhotoFileName__c
                ,Building__r.PrimarySchool3__r.Name
                ,Building__r.PrimarySchool3__r.PhotoFilePath__c
                ,Building__r.PrimarySchool3__r.PhotoFileName__c
                ,Building__r.PrimarySchoolDistance1__c
                ,Building__r.PrimarySchoolDistance2__c
                ,Building__r.PrimarySchoolDistance3__c
                ,Building__r.PrimarySchoolWalkTime1__c
                ,Building__r.PrimarySchoolWalkTime2__c
                ,Building__r.PrimarySchoolWalkTime3__c
                ,Building__r.PrimarySchoolWalkTimeFormat1__c
                ,Building__r.PrimarySchoolWalkTimeFormat2__c
                ,Building__r.PrimarySchoolWalkTimeFormat3__c
                ,Building__r.JuniorHighSchool1__r.Name
                ,Building__r.JuniorHighSchool1__r.PhotoFilePath__c
                ,Building__r.JuniorHighSchool1__r.PhotoFileName__c
                ,Building__r.JuniorHighSchool2__r.Name
                ,Building__r.JuniorHighSchool2__r.PhotoFilePath__c
                ,Building__r.JuniorHighSchool2__r.PhotoFileName__c
                ,Building__r.JuniorHighSchool3__r.Name
                ,Building__r.JuniorHighSchool3__r.PhotoFilePath__c
                ,Building__r.JuniorHighSchool3__r.PhotoFileName__c
                ,Building__r.JuniorHighSchoolDistance1__c
                ,Building__r.JuniorHighSchoolDistance2__c
                ,Building__r.JuniorHighSchoolDistance3__c
                ,Building__r.JuniorHighSchoolWalkTime1__c
                ,Building__r.JuniorHighSchoolWalkTime2__c
                ,Building__r.JuniorHighSchoolWalkTime3__c
                ,Building__r.JuniorHighSchoolWalkTimeFormat1__c
                ,Building__r.JuniorHighSchoolWalkTimeFormat2__c
                ,Building__r.JuniorHighSchoolWalkTimeFormat3__c
                ,Building__r.HighSchool__r.Name
                ,Building__r.HighSchool__r.PhotoFilePath__c
                ,Building__r.HighSchool__r.PhotoFileName__c
                ,Building__r.HighSchoolDistance__c
                ,Building__r.HighSchoolWalkTime__c
                ,Building__r.HighSchoolWalkTimeFormat__c
                ,Building__r.University__r.Name
                ,Building__r.University__r.PhotoFilePath__c
                ,Building__r.University__r.PhotoFileName__c
                ,Building__r.UniversityDistance__c
                ,Building__r.UniversityWalkTime__c
                ,Building__r.UniversityWalkTimeFormat__c
                ,Building__r.ConvenienceStore__r.Name
                ,Building__r.ConvenienceStore__r.PhotoFilePath__c
                ,Building__r.ConvenienceStore__r.PhotoFileName__c
                ,Building__r.ConvenienceStoreDistance__c
                ,Building__r.ConvenienceStoreWalkTime__c
                ,Building__r.ConvenienceStoreWalkTimeFormat__c
                ,Building__r.Supermarket__r.Name
                ,Building__r.Supermarket__r.PhotoFilePath__c
                ,Building__r.Supermarket__r.PhotoFileName__c
                ,Building__r.SupermarketDistance__c
                ,Building__r.SupermarketWalkTime__c
                ,Building__r.SupermarketWalkTimeFormat__c
                ,Building__r.GeneralHospital__r.Name
                ,Building__r.GeneralHospital__r.PhotoFilePath__c
                ,Building__r.GeneralHospital__r.PhotoFileName__c
                ,Building__r.GeneralHospitalDistance__c
                ,Building__r.GeneralHospitalWalkTime__c
                ,Building__r.GeneralHospitalWalkTimeFormat__c
                ,Building__r.TrainRoute1__r.Name
                ,Building__r.TrainRoute1__r.SuumoTrainRouteCode__c
                ,Building__r.TrainRoute1__r.HomesTrainRouteCode__c
                ,Building__r.TrainRoute1__r.AthomeTrainRouteCode__c
                ,Building__r.Station1__r.Name
                ,Building__r.Station1__r.SuumoStationCode__c
                ,Building__r.Station1__r.HomesStationCode__c
                ,Building__r.Station1__r.AtHomeStationCode__c
                ,Building__r.StationDistance1__c
                ,Building__r.StationWalkTime1__c
                ,Building__r.StationWalkTimeFormat1__c
                ,Building__r.TrainRoute2__r.Name
                ,Building__r.TrainRoute2__r.SuumoTrainRouteCode__c
                ,Building__r.TrainRoute2__r.HomesTrainRouteCode__c
                ,Building__r.TrainRoute2__r.AthomeTrainRouteCode__c
                ,Building__r.Station2__r.Name
                ,Building__r.Station2__r.SuumoStationCode__c
                ,Building__r.Station2__r.HomesStationCode__c
                ,Building__r.Station2__r.AtHomeStationCode__c
                ,Building__r.StationDistance2__c
                ,Building__r.StationWalkTime2__c
                ,Building__r.StationWalkTimeFormat2__c
                ,Building__r.TrainRoute3__r.Name
                ,Building__r.TrainRoute3__r.SuumoTrainRouteCode__c
                ,Building__r.TrainRoute3__r.HomesTrainRouteCode__c
                ,Building__r.TrainRoute3__r.AthomeTrainRouteCode__c
                ,Building__r.Station3__r.Name
                ,Building__r.Station3__r.SuumoStationCode__c
                ,Building__r.Station3__r.HomesStationCode__c
                ,Building__r.Station3__r.AtHomeStationCode__c
                ,Building__r.StationDistance3__c
                ,Building__r.StationWalkTime3__c
                ,Building__r.StationWalkTimeFormat3__c
                ,Building__r.BusRoute1__c
                ,Building__r.BusStop1__c
                ,Building__r.BusStopDistance1__c
                ,Building__r.BusStopWalkTime1__c
                ,Building__r.BusStopWalkTimeFormat1__c
                ,Building__r.BusRideTime1__c
                ,Building__r.BusRideTimeFormat1__c
                ,Building__r.BusStopToStationDistance1__c
                ,Building__r.BusStopToStationWalkTime1__c
                ,Building__r.BusStopToStationWalkTimeFormat1__c
                ,Building__r.BusRoute2__c
                ,Building__r.BusStop2__c
                ,Building__r.BusStopDistance2__c
                ,Building__r.BusStopWalkTime2__c
                ,Building__r.BusStopWalkTimeFormat2__c
                ,Building__r.BusRideTime2__c
                ,Building__r.BusRideTimeFormat2__c
                ,Building__r.BusStopToStationDistance2__c
                ,Building__r.BusStopToStationWalkTime2__c
                ,Building__r.BusStopToStationWalkTimeFormat2__c
                ,Building__r.BusRoute3__c
                ,Building__r.BusStop3__c
                ,Building__r.BusStopDistance3__c
                ,Building__r.BusStopWalkTime3__c
                ,Building__r.BusStopWalkTimeFormat3__c
                ,Building__r.BusRideTime3__c
                ,Building__r.BusRideTimeFormat3__c
                ,Building__r.BusStopToStationDistance3__c
                ,Building__r.BusStopToStationWalkTime3__c
                ,Building__r.BusStopToStationWalkTimeFormat3__c
                ,Building__r.District__c
                ,Building__r.BuildingPhotoCount__c
                ,Building__r.BuildingPhotoLastModifiedDate__c
                ,Building__r.BuildingRemarksPublic__c
                ,Building__r.IsMergeCompletedFlag__c
                ,Building__r.BuildingRemarksPrivate__c
                ,Building__r.MaintenanceType__c
                ,Building__r.MaintenanceComment__c
                ,Building__r.ImportType__c
                ,Building__r.MaintenanceBuildingCode__c
                ,Building__r.IsFirstSurroundingImportFlag__c
                ,Id
                ,IsDeleted
                ,Name
                ,CreatedDate
                ,CreatedById
                ,LastModifiedDate
                ,LastModifiedById
                ,SystemModstamp
                ,PropertyCode__c
                ,Building__c
                ,LivedType__c
                ,LiveStatus__c
                ,FloorType__c
                ,Floor__c
                ,RoomArea__c
                ,RoomCount__c
                ,RoomLayout__c
                ,BalconyDirection__c
                ,ContractTermYear__c
                ,ContractTermMonth__c
                ,RentType__c
                ,RentTermYear__c
                ,RentTermMonth__c
                ,RentTermDay__c
                ,RenovationComplateYear__c
                ,RenovationComplateMonth__c
                ,RenovationContent__c
                ,TransactionAspect__c
                ,DeliveryType__c
                ,DeliveryYear__c
                ,DeliveryMonth__c
                ,DeliveryTiming__c
                ,DeliveryDay__c
                ,DeliveryConsultation__c
                ,PropertyRemarksPublic__c
                ,PropertyRemarksPrivate__c
                ,PropertyComment__c
                ,RepresentativeComment__c
                ,RentFee__c
                ,ManagementFee__c
                ,ManagementFeeTax__c
                ,ManagementFeeTaxType__c
                ,WortFee__c
                ,WortFeeTax__c
                ,WortFeeTaxType__c
                ,TownshipFee__c
                ,TownshipFeeTax__c
                ,TownshipFeeTaxType__c
                ,TownshipFeePaymentType__c
                ,RenewalFeeYen__c
                ,RenewalFeeMonth__c
                ,RenewalFee__c
                ,RenewalFeeUnit__c
                ,RenewalFeeTaxType__c
                ,ParkingType__c
                ,ParkingDistance__c
                ,ParkingFee__c
                ,ParkingFeeTax__c
                ,ParkingFeeTaxType__c
                ,ParkingDepositYen__c
                ,ParkingDepositMonth__c
                ,ParkingDepositUnit__c
                ,ParkingDepositTax__c
                ,ParkingDepositTaxType__c
                ,ParkingCompoundingFeeYen__c
                ,ParkingCompoundingFeeMonth__c
                ,ParkingCompoundingFeeUnit__c
                ,ParkingCompoundingFeeTaxType__c
                ,ParkingCompoundingFeeTax__c
                ,ParkingRemarksPublic__c
                ,ParkingRemarksPrivate__c
                ,MonetaryPublic__c
                ,MonetaryPrivate__c
                ,SecurityDepositYen__c
                ,SecurityDepositMonth__c
                ,SecurityDepositUnit__c
                ,KeyMoneyYen__c
                ,KeyMoneyMonth__c
                ,KeyMoneyUnit__c
                ,DepositYen__c
                ,DepositMonth__c
                ,DepositUnit__c
                ,CancellationActualFeeYen__c
                ,CancellationActualFeeMonth__c
                ,CancellationActualFeeRate__c
                ,CancellationActualFeeUnit__c
                ,FireInsuranceUseType__c
                ,FireInsuranceCompany__r.Name
                ,FireInsurancePlan__r.ItemName__c
                ,FireInsurancePlan__r.PaymentType__c
                ,FireInsurancePlan__r.PaymentYear__c
                ,FireInsurancePlan__r.FireInsuranceYear__c
                ,FireInsurancePlan__r.FireInsuranceMonth__c
                ,FireInsurancePlan__r.FireInsurance__c
                ,FireInsurancePlan__r.TenantCompensation__c
                ,FireInsurancePlan__r.HouseGoodsDeposit__c
                ,KeyExchangeFee__c
                ,KeyExchangeFeeTax__c
                ,KeyExchangeFeeTaxType__c
                ,KeyPlace__c
                ,GuaranteeidCompanyType__c
                ,GuaranteeidCompany__r.Name
                ,GuaranteeidCompany__r.GuarantorAgencyCompanyType__c
                ,Guaranteeid__r.ItemName__c
                ,Guaranteeid__r.AssuranceContent__c
                ,Guaranteeid__r.DirectDebitFee__c
                ,Guaranteeid__r.DirectDebitFeeTax__c
                ,Guaranteeid__r.DirectDebitFeeTaxType__c
                ,Guaranteeid__r.Remarks__c
                ,FormerSupplier__r.Name
                ,FormerSupplier__r.IppamGyobutsu__c
                ,FormerSupplier__r.FixedTermSend__c
                ,FormerSupplier__r.Introduction__c
                ,FormerSupplier__r.RenewalFeeShow__c
                ,FormerSupplier__r.CleaningFeeShow__c
                ,FormerSupplierPhone__c
                ,FormerSupplierFax__c
                ,FormerSupplierPostalCode__c
                ,FormerSupplierAddress__c
                ,FormerSupplierState__c
                ,FormerSupplierCity__c
                ,FormerSupplierStreet__c
                ,FormerSupplierEmail__c
                ,FormerSupplierRepresentative__c
                ,FormerSupplierDepartment__c
                ,FormerSupplierRepresentativePhone__c
                ,FormerSupplier__r.RemarksPublic__c
                ,Owner__r.Name
                ,OwnerPhone__c
                ,OwnerFax__c
                ,OwnerPostalCode__c
                ,OwnerAddress__c
                ,OwnerState__c
                ,OwnerCity__c
                ,OwnerStreet__c
                ,OwnerEmail__c
                ,OwnerRepresentative__c
                ,OwnerDepartment__c
                ,OwnerRepresentativePhone__c
                ,Owner__r.RemarksPublic__c
                ,Creditor__r.Name
                ,CreditorPhone__c
                ,CreditorFax__c
                ,CreditorPostalCode__c
                ,CreditorAddress__c
                ,CreditorState__c
                ,CreditorCity__c
                ,CreditorStreet__c
                ,CreditorEmail__c
                ,CreditorRepresentative__c
                ,CreditorDepartment__c
                ,CreditorRepresentativePhone__c
                ,Creditor__r.RemarksPublic__c
                ,IsPropertyNameHiddenFlag__c
                ,Score__c
                ,PropertyPhotoCount__c
                ,PhotoCount__c
                ,PropertyPhotoLastModifiedDate__c
                ,PhotoLastModifiedDate__c
                ,RewardType__c
                ,RewardBurdenLender__c
                ,RewardBurdenBorrower__c
                ,RewardSplitFormerSupplier__c
                ,RewardSplitCustomer__c
                ,ADFeeYen__c
                ,ADFeeMonth__c
                ,ADFeeRate__c
                ,ADFeeUnit__c
                ,ADFeeTax__c
                ,ADFeeTaxType__c
                ,ADFeeComment__c
                ,WebPublishing__c
                ,IsMergeCompletedFlag__c
                ,BalconyArea__c
                ,SuumoNetCatch__c
                ,SuumoNetCatchComment__c
                ,SuumoNetCatch__r.ExampleSentence__c
                ,SuumoNetCatchComment__r.ExampleSentence__c
                ,HomesPropertyFeature__r.ExampleSentence__c
                ,AthomeRecommendComment__r.ExampleSentence__c
                ,AthomeRecommendCommentStaffId__c
                ,AthomePanoramaContentsId__c
                ,ImportType__c
                ,SuumoRemarks__c
                ,HomesRemarks__c
                ,AtHomeRemarks__c
                ,FreeRentTermMonth__c
                ,FreeRentContent__c
                ,MaintenancePropertyCode__c
                ,ADRemarksPublic__c
                ,ADRemarksPrivate__c
                ,CATVFee__c
                ,CATVFeeTax__c
                ,CATVTaxType__c
                ,GarbageDisposalFee__c
                ,GarbageDisposalFeeTax__c
                ,GarbageDisposalFeeTaxType__c
                ,GarbageDisposalFeePaymentType__c
                ,BicycleParkingFee__c
                ,BicycleParkingFeeTax__c
                ,BicycleParkingFeeTaxType__c
                ,BikeParkingSmallFee__c
                ,BikeParkingSmallFeeTax__c
                ,BikeParkingSmallFeeTaxType__c
                ,BikeParkingMediumFee__c
                ,BikeParkingMediumFeeTax__c
                ,BikeParkingMediumFeeTaxType__c
                ,BikeParkinLargeFee__c
                ,BikeParkinLargeFeeTax__c
                ,BikeParkinLargeFeeTaxType__c
                ,TownshipInitialFee__c
                ,TownshipInitialFeeTax__c
                ,TownshipInitialFeeTaxType__c
                ,CleaningFeeYen__c
                ,CleaningFeeMonth__c
                ,CleaningFeeTax__c
                ,CleaningFeeUnit__c
                ,CleaningFeeTaxType__c
                ,CleaningFeePaymentType__c
                ,IsShortTermPenalty__c
                ,ShortTermPenaltyLessYear__c
                ,ShortTermPenaltyFee__c
                ,ShortTermPenaltyLessYear2__c
                ,ShortTermPenaltyFee2__c
                ,MaintenanceType__c
                ,MaintenanceCommentArea__c
                ,IsOwnCompanyPropertyFlag__c
                ,IsBulkConfirmation__c
                ,BulkConfirmationDate__c
                ,ManualMaintenanceDate__c
                ,AutoMaintenanceDate__c
                ,OwnCompanyManageModDate__c
                ,ManualModifiedDate__c
                ,TemporarySaveDate__c
                ,SuumoPanoramaShop__c
                ,HomesPanoramaShop__c
                ,AtHomePanoramaShop__c
                ,SpecificExcellentRentBurdenUpperLimit__c
                ,SpecificExcellentRentBurdenLowerLimit__c
                ,SpecificExcellentRentFeeFluctuationType__c
                ,SpecificExcellentRentFeeUpwardRate__c
                ,SpecificExcellentRentSupportYears__c
                ,SpecificExcellentRentRemarks__c
                ,MaintenanceLastModifiedDate__c
                ,IsPostingEndDayBefore__c
                ,IsPostingEndRecent__c
                ,FormerSupplierMaintenanceSupplierCode__c
                ,BrokerageFeeTax__c
				// ▼ 2022/03/28 CHINTAI対応追加
				,Building__r.TrainRoute1__r.ChintaiTrainRouteCode__c
				,Building__r.TrainRoute2__r.ChintaiTrainRouteCode__c
				,Building__r.TrainRoute3__r.ChintaiTrainRouteCode__c
				,Building__r.Station1__r.ChintaiStationCode__c
				,Building__r.Station2__r.ChintaiStationCode__c
				,Building__r.Station3__r.ChintaiStationCode__c
				,ChintaiMagazineComment__r.ExampleSentence__c
				// ▲ 2022/03/28 CHINTAI対応追加
            FROM
                Property__c
            WHERE
                Id IN :propertyIdSet
        ];
        return propList;
    }

    // 建物物件差分番号の取得
    private static String getBuildPropDiffName(Id buildPropDiffId) {
        Set<Id> buildPropDiffIdSet = new Set<Id>{buildPropDiffId};
        Map<Id, String> buildPropDiffMap = new Map<Id, String>();
        if (buildPropDiffMap.containsKey(buildPropDiffId)) {
            return buildPropDiffMap.get(buildPropDiffId);
        } else {
            return CommonConst.STRING_EMPTY;
        }
    }
    private static Map<Id, String> getBuildPropDiffName(Set<Id> buildPropDiffIdSet) {
        List<BuildingPropertyDifference__c> buildPropDiffList = [
            SELECT
                Id
                ,Name
            FROM
            BuildingPropertyDifference__c
            WHERE
                Id IN :buildPropDiffIdSet
        ];
        Map<Id, String> buildPropDiffNmMap = new Map<Id, String>();
        for (BuildingPropertyDifference__c bpd : buildPropDiffList) {
            buildPropDiffNmMap.put(bpd.Id, bpd.Name);
        }
        return buildPropDiffNmMap;
    }

    /**
     * 点数計算用物件情報作成
     * @param  List<Property__c>      propList       物件情報のリスト
     * @return Map<id, Building__c> 物件IDと建物情報のMap
     */
    private static Map<id, Building__c> setBuildingDataForCalcScore(List<Property__c> propList) {

        Map<id, Building__c> idBuildMap = new Map<id, Building__c>();
        for(Property__c prop : propList) {
            Building__c build = new Building__c();
            build.id = prop.Building__r.id;
            build.Supermarket__r = new SurroundingFacility__c();
            build.Supermarket__r.PhotoFileName__c = prop.Building__r.Supermarket__r.PhotoFileName__c;            // スーパー
            build.ConvenienceStore__r = new SurroundingFacility__c();
            build.ConvenienceStore__r.PhotoFileName__c = prop.Building__r.ConvenienceStore__r.PhotoFileName__c;  // コンビニ
            build.GeneralHospital__r = new Hospital__c();
            build.GeneralHospital__r.PhotoFileName__c = prop.Building__r.GeneralHospital__r.PhotoFileName__c;    // 病院
            build.PrimarySchool1__r = new School__c();
            build.PrimarySchool1__r.PhotoFileName__c = prop.Building__r.PrimarySchool1__r.PhotoFileName__c;      // 小学校１
            build.PrimarySchool2__r = new School__c();
            build.PrimarySchool2__r.PhotoFileName__c = prop.Building__r.PrimarySchool2__r.PhotoFileName__c;      // 小学校２
            build.PrimarySchool3__r = new School__c();
            build.PrimarySchool3__r.PhotoFileName__c = prop.Building__r.PrimarySchool3__r.PhotoFileName__c;      // 小学校３
            build.JuniorHighSchool1__r = new School__c();
            build.JuniorHighSchool1__r.PhotoFileName__c = prop.Building__r.JuniorHighSchool1__r.PhotoFileName__c;// 中学校１
            build.JuniorHighSchool2__r = new School__c();
            build.JuniorHighSchool2__r.PhotoFileName__c = prop.Building__r.JuniorHighSchool2__r.PhotoFileName__c;// 中学校２
            build.JuniorHighSchool3__r = new School__c();
            build.JuniorHighSchool3__r.PhotoFileName__c = prop.Building__r.JuniorHighSchool3__r.PhotoFileName__c;// 中学校３
            build.HighSchool__r = new SurroundingFacility__c();
            build.HighSchool__r.PhotoFileName__c = prop.Building__r.HighSchool__r.PhotoFileName__c;              // 高校
            build.University__r = new SurroundingFacility__c();
            build.University__r.PhotoFileName__c = prop.Building__r.University__r.PhotoFileName__c;              // 大学
            
            idBuildMap.put(prop.id, build);
        }
        return idBuildMap;
    }

    // 写真情報内部クラス
    private class PhotoData {
        public String tag           { get; set; }   // タグ
        public String comment       { get; set; }   // コメント
        public String fileName      { get; set; }   // ファイル名
        public String photo         { get; set; }   // 写真
        public String environment   { get; set; }   // 周辺写真タグ
        public String photoName     { get; set; }   // 周辺写真名
        public Decimal distance     { get; set; }   // 周辺写真までの距離
    }
    // 写真情報処理用内部クラス
    private class AnyPhotoData {
        public List<PhotoData> photoDataList { get; set; } // 写真情報
        public Integer maxIndex { get; set; } // 写真情報の格納最大件数
        public AnyPhotoData() {
            // 初期化
            this.photoDataList = new List<PhotoData>();
        }
        // コンストラクタ（物件写真）
        public AnyPhotoData(PropertyPhoto__c propertyPhoto, Boolean isPanorama) {
            // 初期化
            this.photoDataList = new List<PhotoData>();
            this.maxIndex = isPanorama ? BuildingPropertyUtil.MAXINDEX_BUILDPROPDIFFPHOTO_PANORAMAPHOTO
                                       : BuildingPropertyUtil.MAXINDEX_BUILDPROPDIFFPHOTO_PROPPHOTO;
            Integer propertyPhotoMaxIndex = isPanorama ? CommonConst.MAXINDEX_PROPERTY_PANORAMA
                                                       : CommonConst.MAXINDEX_PROPERTY_PROPERTY;

            // データ取得
            List<PhotoData> tempPhotoDataList = new List<PhotoData>();  // 処理用List
            Map<String, List<PhotoData>> tagDataListMap = new Map<String, List<PhotoData>>();   // タグ毎の写真一覧データ格納用（Map<タグ,List<写真情報>>）
            // 写真タグごとにListにしてMapに格納
            for (Integer i = 1; i <= propertyPhotoMaxIndex; i++) {
                PhotoData data = new PhotoData();
                if (isPanorama) {
                    // パノラマ写真
                    if (!String.isEmpty((String)propertyPhoto.get('PanoramaFileName' + i + '__c'))) {
                        data = new photoData();
                        data.tag        = (String)propertyPhoto.get('PanoramaTag' + i + '__c');
                        data.comment    = (String)propertyPhoto.get('PanoramaComment' + i + '__c');
                        data.fileName   = (String)propertyPhoto.get('PanoramaFileName' + i + '__c');
                        data.photo      = (String)propertyPhoto.get('PanoramaFilePath' + i + '__c');
                    }
                } else {
                    // 物件写真
                    if (!String.isEmpty((String)propertyPhoto.get('PropertyPhotoFileName' + i + '__c'))) {
                        data = new photoData();
                        data.tag        = (String)propertyPhoto.get('PropertyPhotoTag' + i + '__c');
                        data.comment    = (String)propertyPhoto.get('PropertyPhotoComment' + i + '__c');
                        data.fileName   = (String)propertyPhoto.get('PropertyPhotoFileName' + i + '__c');
                        data.photo      = (String)propertyPhoto.get('PropertyPhotoFilePath' + i + '__c');
                    }
                }
                if (!String.isEmpty(data.tag)) {
                    if (tagDataListMap.containsKey(data.tag)) {
                        tempPhotoDataList = tagDataListMap.get(data.tag);
                    } else {
                        tempPhotoDataList = new List<PhotoData>();
                    }
                    tempPhotoDataList.add(data);
                    tagDataListMap.put(data.tag, tempPhotoDataList);
                }
            }
            // 間取り図（パノラマ写真処理時以外）
            if (!isPanorama && !String.isEmpty(propertyPhoto.RoomLayoutFileName__c)) {
                tempPhotoDataList = new List<PhotoData>();
                PhotoData data = new photoData();
                data.tag        = '間取り';
                data.fileName   = propertyPhoto.RoomLayoutFileName__c;
                data.photo      = propertyPhoto.RoomLayoutFilePath__c;
                tempPhotoDataList.add(data);
                tagDataListMap.put(data.tag, tempPhotoDataList);
            }


            // データ格納
            // 優先順にphotoDataListに格納
            List<String> tagOrderList;
            if (isPanorama) {
                // パノラマ写真
                tagOrderList = new List<String>();
                // ▼問合せ181で変更
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_EXTERIOR);           // 建物外観
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_ENTRANCE_HALL);      // エントランス
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_ROBBY);              // ロビー
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_PARKING);            // 駐車場
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_OTHER_SHARED_AREA);  // その他共有部分
                // ▲問合せ181で変更
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_LIVING);             // 居室・リビング
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_OTHERROOM);          // その他部屋・スペース
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_KITCHEN);            // キッチン
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_BATH);               // バス・シャワールーム
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_TOILET);             // トイレ
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_WASHROOM);           // 洗面設備
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_STORAGE);            // 収納
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_BALCONY);            // バルコニー
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_GARDEN);             // 庭
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_ENTRANCE);           // 玄関
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_SECURITY);           // セキュリティ
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_OTHERFACILITY);      // その他設備
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_VIEW);               // 眺望
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PANORAMATAG_OTHER);              // その他
            } else  {
                tagOrderList = new List<String>();
                tagOrderList.Add('間取り');
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_LIVING);        // 居室・リビング
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_KITCHEN);       // キッチン
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_BATH);          // バス・シャワールーム
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHERROOM);     // その他部屋・スペース
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_TOILET);        // トイレ
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_WASHROOM);      // 洗面設備
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_STORAGE);       // 収納
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_BALCONY);       // バルコニー
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_GARDEN);        // 庭
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_ENTRANCE);      // 玄関
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_SECURITY);      // セキュリティ
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHERFACILITY); // その他設備
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_VIEW);          // 眺望
                tagOrderList.Add(CommonConst.PROPERTYPHOTO_PROPERTYPHOTOTAG_OTHER);         // その他
            }
            for (Integer i = 1; i <= propertyPhotoMaxIndex; i++) {
                for (String tag : tagOrderList) {
                    this.searchTagDataListMap(tagDataListMap, tag, i);
                    if (this.isFull()) {
                        return;
                    }
                }
            }

        }
        // コンストラクタ（建物写真）
        public AnyPhotoData(BuildingPhoto__c buildingPhoto) {
            // 初期化
            this.photoDataList = new List<PhotoData>();
            this.maxIndex = BuildingPropertyUtil.MAXINDEX_BUILDPROPDIFFPHOTO_BUILDPHOTO;

            // データセット
            if (!String.isEmpty(buildingPhoto.AppearanceFileName__c)) {
                // 外観写真
                PhotoData data = new photoData();
                data.tag        = CommonConst.BUILDINGPHOTO_TAG_APPEARANCE;
                data.fileName   = buildingPhoto.AppearanceFileName__c;
                data.comment    = buildingPhoto.AppearanceComment__c;
                data.photo      = buildingPhoto.AppearanceFilePath__c;
                this.photoDataList.add(data);
                if (this.isFull()) {
                    return;
                }
            }
            if (!String.isEmpty(buildingPhoto.AppearanceParseFileName__c)) {
                // 外観パース
                PhotoData data = new photoData();
                data.tag        = CommonConst.BUILDINGPHOTO_TAG_APPEARANCE_PARSE;
                data.fileName   = buildingPhoto.AppearanceParseFileName__c;
                data.comment    = buildingPhoto.AppearanceParseComment__c;
                data.photo      = buildingPhoto.AppearanceParseFilePath__c;
                this.photoDataList.add(data);
                if (this.isFull()) {
                    return;
                }
            }
            if (!String.isEmpty(buildingPhoto.EntranceFileName__c)) {
                // エントランス
                PhotoData data = new photoData();
                data.tag        = CommonConst.BUILDINGPHOTO_TAG_ENTRANCE;
                data.fileName   = buildingPhoto.EntranceFileName__c;
                data.comment    = buildingPhoto.EntranceComment__c;
                data.photo      = buildingPhoto.EntranceFilePath__c;
                this.photoDataList.add(data);
                if (this.isFull()) {
                    return;
                }
            }
            if (!String.isEmpty(buildingPhoto.LobbyFileName__c)) {
                // ロビー
                PhotoData data = new photoData();
                data.tag        = CommonConst.BUILDINGPHOTO_TAG_LOBBY;
                data.fileName   = buildingPhoto.LobbyFileName__c;
                data.comment    = buildingPhoto.LobbyComment__c;
                data.photo      = buildingPhoto.LobbyFilePath__c;
                this.photoDataList.add(data);
                if (this.isFull()) {
                    return;
                }
            }
            if (!String.isEmpty(buildingPhoto.ParkingFileName__c)) {
                // 駐車場
                PhotoData data = new photoData();
                data.tag        = CommonConst.BUILDINGPHOTO_TAG_PARKING;
                data.fileName   = buildingPhoto.ParkingFileName__c;
                data.comment    = buildingPhoto.ParkingComment__c;
                data.photo      = buildingPhoto.ParkingFilePath__c;
                this.photoDataList.add(data);
                if (this.isFull()) {
                    return;
                }
            }
            if (!String.isEmpty(buildingPhoto.OtherSharingFileName__c)) {
                // その他共有
                PhotoData data = new photoData();
                data.tag        = CommonConst.BUILDINGPHOTO_TAG_OTHERSHARING;
                data.fileName   = buildingPhoto.OtherSharingFileName__c;
                data.comment    = buildingPhoto.OtherSharingComment__c;
                data.photo      = buildingPhoto.OtherSharingFilePath__c;
                this.photoDataList.add(data);
                if (this.isFull()) {
                    return;
                }
            }
            if (!String.isEmpty(buildingPhoto.MapFileName__c)) {
                // 地図
                PhotoData data = new photoData();
                data.tag        = CommonConst.BUILDINGPHOTO_TAG_MAP;
                data.fileName   = buildingPhoto.MapFileName__c;
                data.comment    = buildingPhoto.MapComment__c;
                data.photo      = buildingPhoto.MapFilePath__c;
                this.photoDataList.add(data);
                if (this.isFull()) {
                    return;
                }
            }
            if (!String.isEmpty(buildingPhoto.SurroundingFileName1__c)) {
                // 周辺写真（1件目）
                PhotoData data = new photoData();
                data.tag            = CommonConst.BUILDINGPHOTO_TAG_SURROUNDING;
                data.comment        = buildingPhoto.SurroundingComment1__c;
                data.fileName       = buildingPhoto.SurroundingFileName1__c;
                data.photo          = buildingPhoto.SurroundingFilePath1__c;
                data.environment    = buildingPhoto.SurroundingTag1__c;
                data.photoName      = buildingPhoto.SurroundingPhotoName1__c;
                data.distance       = buildingPhoto.SurroundingDistance1__c;
                this.photoDataList.add(data);
                if (this.isFull()) {
                    return;
                }
            }
            if (!String.isEmpty(buildingPhoto.OtherFileName__c)) {
                // その他
                PhotoData data = new photoData();
                data.tag        = CommonConst.BUILDINGPHOTO_TAG_OTHER;
                data.fileName   = buildingPhoto.OtherFileName__c;
                data.comment    = buildingPhoto.OtherComment__c;
                data.photo      = buildingPhoto.OtherFilePath__c;
                this.photoDataList.add(data);
                if (this.isFull()) {
                    return;
                }
            }
            for (Integer i = 2; i <= CommonConst.MAXINDEX_BUILDING_SURROUNDING; i++) {
                if (!String.isEmpty((String)buildingPhoto.get('SurroundingFileName' + i + '__c'))) {
                    // 周辺写真（2件目以降）
                    PhotoData data = new photoData();
                    data.tag            = CommonConst.BUILDINGPHOTO_TAG_SURROUNDING;
                    data.comment        = (String)buildingPhoto.get('SurroundingComment' + i + '__c');
                    data.fileName       = (String)buildingPhoto.get('SurroundingFileName' + i + '__c');
                    data.photo          = (String)buildingPhoto.get('SurroundingFilePath' + i + '__c');
                    data.environment    = (String)buildingPhoto.get('SurroundingTag' + i + '__c');
                    data.photoName      = (String)buildingPhoto.get('SurroundingPhotoName' + i + '__c');
                    data.distance       = (Decimal)buildingPhoto.get('SurroundingDistance' + i + '__c');
                    this.photoDataList.add(data);
                    if (this.isFull()) {
                        return;
                    }
                }
            }
        }
        // データ格納終了判定
        private Boolean isFull() {
            if (this.photoDataList.size() == this.maxIndex) {
                return true;
            }
            return false;
        }
        // タグ毎の写真一覧リストのMapから指定回数、指定タグのデータを取得しphotoDataListに返却する。
        private void searchTagDataListMap(Map<String, List<PhotoData>> searchListMap, String tag, Integer curIndex) {
            if (searchListMap.containsKey(tag)) {
                // 対象タグのデータが存在
                List<PhotoData> photoList = searchListMap.get(tag);
                if (photoList.size() >= curIndex) {
                    // 対象回数目のデータが存在
                    this.photoDataList.add(photoList[curIndex-1]);
                }
            }
        }

    }
    // 部屋情報の取得
    private static List<Room__c> selectRoomData(Id propertyId) {
        Set<Id> propertyIdSet = new Set<Id>{propertyId};
        Map<Id, List<Room__c>> roomMap = BuildingPropertyUtil.selectRoomData(propertyIdSet);
        if (roomMap.containsKey(propertyId)) {
            return roomMap.get(propertyId);
        } else {
            return new List<Room__c>();
        }
    }
    private static Map<Id, List<Room__c>> selectRoomData(Set<Id> propertyIdSet) {
        List<Room__c> roomList = [
            SELECT
                 Property__c
                ,RoomFloorSpace__c
                ,RoomType__c
            FROM
                Room__c
            WHERE
                Property__c IN :propertyIdSet
            ORDER BY
                Property__c
               ,Name
        ];
        Map<Id, List<Room__c>> roomMap = new Map<Id, List<Room__c>>();
        for (Room__c obj : roomList){
            if (roomMap.containsKey(obj.Property__c)){
                roomMap.get(obj.Property__c).add(obj);
            } else {
                roomMap.put(obj.Property__c, new List<Room__c>{obj});
            }
        }
        return roomMap;
    }    
    // 物件条件情報の取得　物件条件情報の取得
    private static PropertyConditions__c selectPropertyConditionsData(Id propertyId) {
        Set<Id> propertyIdSet = new Set<Id>{propertyId};
        Map<Id, PropertyConditions__c> propCondMap = BuildingPropertyUtil.selectPropertyConditionsData(propertyIdSet);
        if (propCondMap.containsKey(propertyId)) {
            return propCondMap.get(propertyId);
        } else {
            return new PropertyConditions__c();
        }
    }
    // 物件条件情報の取得
    private static Map<Id, PropertyConditions__c> selectPropertyConditionsData(Set<Id> propertyIdSet) {
        // データ取得
        List<PropertyConditions__c> propCondList = [
            SELECT
                 Property__c
                ,FacilityRemarksPublic__c
                ,ContractRemarks__c
                ,PetRemarks__c
            FROM
                PropertyConditions__c
            WHERE
                Property__c IN :propertyIdSet
        ];

        // Map作成
        Map<Id, PropertyConditions__c> propCondMap = new Map<Id, PropertyConditions__c>();
        for (PropertyConditions__c obj : propCondList) {
            propCondMap.put(obj.Property__c, obj);
        } 
        
        // 返却
        return propCondMap;
    }
    // 物件条件情報の取得
    private static PropertyConditions__c selectFacilityListData(Id propertyId, Map<String, String> checkFieldMap) {
        Set<Id> propertyIdSet = new Set<Id>{propertyId};
        Map<Id, PropertyConditions__c> propCondMap = BuildingPropertyUtil.selectFacilityListData(propertyIdSet, checkFieldMap);
        if (propCondMap.containsKey(propertyId)) {
            return propCondMap.get(propertyId);
        } else {
            return new PropertyConditions__c();
        }
    }
    private static Map<Id, PropertyConditions__c> selectFacilityListData(Set<Id> propertyIdSet, Map<String, String> checkFieldMap) {
        // データ取得
        String sql = '';
        sql += 'SELECT ';
        sql += ' Id ';
        sql += ',Property__c';
        for (String apiName : checkFieldMap.keySet()) {   // カスタムの全チェックボックス項目
            sql += ',';
            sql += apiName;
        }
        sql += ' FROM PropertyConditions__c ';
        sql += ' WHERE Property__c IN :propertyIdSet ';
        List<PropertyConditions__c> propCondList = Database.query(sql);
        
        // Map化
        Map<Id, PropertyConditions__c> facilityMap = new Map<Id, PropertyConditions__c>();
        for (PropertyConditions__c obj : propCondList) {
            facilityMap.put(obj.Property__c, obj);
        }
        
        // 返却
        return facilityMap;
    }
    
    // 物件管理会社指定商品の取得
    private static Map<Id, List<PropertyManageCompayItem__c>> selectPropertyManageCompanyItemData(Set<Id> propertyIdSet) {
        List<PropertyManageCompayItem__c> propertyManageCompanyItemList = [
            SELECT
            Property__c
            ,Item__r.ItemName__c     //名称
            ,Item__r.AmountTax__c    //税込み金額
            ,Item__r.PaymentType__c  //支払いタイプ
            FROM
            PropertyManageCompayItem__c
            WHERE
            Property__c IN :propertyIdSet
            AND Item__c != null //管理会社指定商品が空のデータはバグデータなので除外
            ORDER BY Property__c ,Name
        ];
        
        //マップ化する
        Map<Id, List<PropertyManageCompayItem__c>> propertyManageCompayItemMap = new Map<Id, List<PropertyManageCompayItem__c>>();//物件Idをキーとしたマップ
        for (PropertyManageCompayItem__c obj : propertyManageCompanyItemList){
            if (propertyManageCompayItemMap.containsKey(obj.Property__c)){
                propertyManageCompayItemMap.get(obj.Property__c).add(obj);
            } else {
                propertyManageCompayItemMap.put(obj.Property__c, new List<PropertyManageCompayItem__c>{obj});
            }
        }
        return propertyManageCompayItemMap;
    }    

    /**
    * 物件条件のチェックボックス項目のみ判定する
    * @param  PropertyConditions__c     propCond       設定先の物件条件
    * @param  String                    facility       設備の文字列
    * @param  String                    externalSiteCd 外部サイトコード
    * @param  String                    delimiter      区切り文字列
    * @return String                                   変更があったメッセージ
    */
    private static String checkPropertyConditions(PropertyConditions__c propCond, String facility
                                                  , String externalSiteCd, String delimiter){
        
        // マッピング情報を取得
        String[] mappingAry = new String[0];
        String recordName = GetMetaDataPropCondRecordName(externalSiteCd);
        List<MetaDataPropCond__mdt> facilityMappingItem = [SELECT AutoMappingFacility__c
                                                           FROM MetaDataPropCond__mdt
                                                           WHERE MasterLabel = :recordName];
        
        if (facilityMappingItem.size() > 0) {
            mappingAry = facilityMappingItem[0].AutoMappingFacility__c.split(';');
        }

        String changeFacilitiesMessage = CommonConst.STRING_EMPTY;
        for(Schema.SObjectField field : Schema.getGlobalDescribe().get('PropertyConditions__c').getDescribe().fields.getMap().values()){
            // カスタム項目&チェックボックス判定用
            Boolean isCustom = field.getDescribe().isCustom();          // カスタム項目フラグ
            Schema.DisplayType type = field.getDescribe().getType();    // データ型                
            // カスタム項目ではなく、チェックボックス型ではない場合
            if (!(isCustom && type == Schema.DisplayType.BOOLEAN)) {    
                // 次のループへ
                continue;
            }

            // マッピング項目チェック
            if (!mappingAry.contains(field.getDescribe().getLabel())) {
                continue;
            }

            // 変更文言の設定
            changeFacilitiesMessage += setChangeMessage(propCond,facility,delimiter,field);

        }
        return changeFacilitiesMessage;
    }

    /**
    * 物件条件のチェック内容と設備内容とで状態が違っている場合にメッセージを返却する
    * @param  PropertyConditions__c     propCond    設定先の物件条件
    * @param  String                    facility    設備の文字列
    * @param  String                    delimiter   区切り文字列
    * @param  Schema.SObjectField       field       物件条件オブジェクトの項目情報
    * @return String                                変更があったメッセージ
    */
    private static String setChangeMessage(PropertyConditions__c propCond, String facility,String delimiter,Schema.SObjectField field){
        // 今の物件条件のチェック状態を取得
        Boolean propCondContents = (Boolean)propCond.get(field.getDescribe().getName());

        // 設備の文字列をリスト化する。
        List<String> facilityList = new List<String>();
        if (!String.isBlank(facility)) {
            facilityList = facility.split(delimiter);
        }

        // 設備に記載されているかどうか。
        List<String> msgParam = new List<String> {field.getDescribe().getLabel()};
        if (facilityList.contains(field.getDescribe().getLabel())){
            // 設備にセットされている場合
            if(!propCondContents){
                // 自動メンテナンスに設備文言：あり、物件条件が「false」、文言をセットする。
                msgParam.add(CommonConst.NOTICE_ITEM_CHECK_FALSE);
                msgParam.add(CommonConst.NOTICE_ITEM_CHECK_TRUE);
                return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_NOTICE_UPDATE_PARAM, msgParam) + CommonConst.BREAK_CODE;
            }
        }else{
            // 設備にセットされていない場合
            if(propCondContents){
                // 自動メンテナンスに設備文言：なし、物件条件が「true」、文言をセットする。
                msgParam.add(CommonConst.NOTICE_ITEM_CHECK_TRUE);
                msgParam.add(CommonConst.NOTICE_ITEM_CHECK_FALSE);
                return CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_NOTICE_UPDATE_PARAM, msgParam) + CommonConst.BREAK_CODE;
            }
        }

        // 設備と物件条件のチェックに差異がなければ、空で返却。
        return '';
    }

    /**
    * 物件条件カスタムメタデータ型のレコード名（表示ラベル）を取得
    * @param  String externalSiteCd 外部サイトコード
    * @return String                レコード名（表示ラベル）
    */
    private static String GetMetaDataPropCondRecordName(String externalSiteCd) {

        String result = CommonConst.STRING_EMPTY;

        // 条件値を設定（Key:外部サイトコード、Value:レコード名）
        Map<String, String> recordNameMap = new Map<String, String> {
            CommonConst.AUTOMAINTEDIFF_SITECODE_REALNETPRO => CommonConst.AUTOMAINTENANCE_CRAWLING_SOURCE_REALPRO
        };

        // レコード名を設定
        if (recordNameMap.containsKey(externalSiteCd)) {
            result = recordNameMap.get(externalSiteCd);
        }

        return result;
    }

    // 定数
    private static final String CHANGE_COLON = '変更：';
    private static final String ARROW = '→';
    private static final String PERCENT = '%';
    private static final String YEN = '円';
    private static final String MONTHS = 'ヵ月';
    private static final String ACTUALCOST = '実費';
    private static final String METER = 'm';
    private static final String CHANGE = '変更';
    private static final String PARKINGTYPE_NO = '無';
    private static final String NOT_SET = '(未設定)';

    /**
    * nullならblankにする処理
    * @param  String item   対象文字列
    * @return String item   引数がnullの場合、空文字/引数がnullでない場合、引数
    */
    private static String convertToBlank(String item) {
        return item == null ? '' : item;
    }

    /**
     * 数値型から文字列に変換する処理
     * @param  変更する数値型
     * @return 引数がnullの場合、空文字/引数がnullでない場合、引数を文字列に変換した値
     */   
    public static String decimalToString(Decimal changeDecimal){ 
        String returnSt;
        
        if (changeDecimal == null){
            //引数がnullの場合、空文字を返す
            returnSt = '';
        }else if (changeDecimal.scale() != 0 ){
            //引数に小数が含まれる場合(整数部カンマ区切り＋小数部)
            returnSt = String.valueOf(changeDecimal.longValue().format()) + (String.valueOf(changeDecimal).right(changeDecimal.scale() + 1));
        }else{
            //引数に小数がない場合（そのままカンマ区切り）
            returnSt =  String.valueOf(changeDecimal.format());
        }
        return returnSt;
    }

    /**
    * 更新前と更新後の項目を比較し、異なる場合はメッセージを返す
    * @param  String itemName           項目名
    * @param  String beforeItem         比較対象の項目
    * @param  String afterItem          比較対象の項目
    * @param  String beforeUnit         比較対象の単位
    * @param  String afterUnit          比較対象の単位
    * @return String result             引数がnullの場合、空文字/(改行):{項目名}変更{比較対象の項目}{比較対象の単位}→{比較対象の項目}{比較対象の単位}
    */
    private static String createReturnMessage(String itemName, String beforeItem, String afterItem
                                            ,String beforeUnit, String afterUnit) {
        String beforeItemStr = convertToBlank(beforeItem);
        String afterItemStr = convertToBlank(afterItem);
        String beforeUnitStr = convertToBlank(beforeUnit);
        String afterUnitStr = convertToBlank(afterUnit);
        String resultBeforeItem;
        String resultAfterItem;
        if(String.isBlank(beforeItemStr) && beforeUnitStr != ACTUALCOST) {
            beforeUnitStr = '';
        }
        if(String.isBlank(afterItemStr) && afterUnitStr != ACTUALCOST) {
            afterUnitStr = '';
        }
        if(beforeItemStr + beforeUnitStr == afterItemStr + afterUnitStr) {
            return '';
        }
        resultBeforeItem = (beforeItemStr + beforeUnitStr).equals('') ? NOT_SET : beforeItemStr + beforeUnitStr;
        resultAfterItem = (afterItemStr + afterUnitStr).equals('') ? NOT_SET : afterItemStr + afterUnitStr;
        return CommonConst.BREAK_TAG + itemName + CHANGE_COLON + resultBeforeItem + ARROW + resultAfterItem;
    }

    /**
    * 更新前と更新後の項目を比較し、異なる場合はメッセージを返す
    * @param  String itemName           項目名
    * @param  Decimal beforeItem        比較対象の項目
    * @param  Decimal afterItem         比較対象の項目
    * @param  String beforeUnit         比較対象の単位
    * @param  String afterUnit          比較対象の単位
    * @return String result             引数がnullの場合、空文字/nullでない場合、createReturnMessage呼び出し
    */
    private static String createReturnMessage(String itemName, Decimal beforeItem, Decimal afterItem
                                            ,String beforeUnit, String afterUnit) {
        if(beforeItem != null && beforeUnit == MONTHS) {
            // DB登録値と揃えるため、小数点第一位までを比較
            beforeItem = beforeItem.setscale(1);
        }
        if(afterItem != null && afterUnit == MONTHS) {
            // DB登録値と揃えるため、小数点第一位までを比較
            afterItem = afterItem.setscale(1);
        }
        if(beforeItem + beforeUnit == afterItem + afterUnit) {
            return '';
        }
        return createReturnMessage(itemName, decimalToString(beforeItem), decimalToString(afterItem), beforeUnit, afterUnit);
    }

    /**
    * 更新前と更新後の項目を比較し、異なる場合はメッセージを返す
    * @param  String itemName         項目名
    * @param  Decimal beforeItem      比較対象の項目
    * @param  Decimal afterItem       比較対象の項目
    * @return String result           引数がnullの場合、空文字/nullでない場合、createReturnMessage呼び出し
    */
    private static String createReturnMessage(String itemName, Decimal beforeItem, Decimal afterItem) {
        if(beforeItem != null) {
            // DB登録値と揃えるため、小数点第一位までを比較
            beforeItem = beforeItem.setscale(1);
        }
        if(afterItem != null) {
            // DB登録値と揃えるため、小数点第一位までを比較
            afterItem = afterItem.setscale(1);
        }
        if(beforeItem == afterItem) {
            return '';
        }
        return createReturnMessage(itemName, decimalToString(beforeItem), decimalToString(afterItem), '', '');
    }

    /**
    * 更新前と更新後の項目を比較し、異なる場合はメッセージを返す
    * @param  String itemName         項目名
    * @param  String beforeItem      比較対象の項目
    * @param  String afterItem       比較対象の項目
    * @return String result           引数がnullの場合、空文字/nullでない場合、createReturnMessage呼び出し
    */
    private static String createReturnMessage(String itemName, String beforeItem, String afterItem) {
        
        String beforeItemStr = convertToBlank(beforeItem);
        String afterItemStr = convertToBlank(afterItem);
        if(beforeItemStr == afterItemStr) {
            return '';
        }
        if(!String.isBlank(beforeItemStr)) {
            beforeItemStr = selectShopName(beforeItemStr);
        }
        if(!String.isBlank(afterItemStr)) {
            afterItemStr = selectShopName(afterItemStr);
        }
        return createReturnMessage(itemName, beforeItemStr, afterItemStr, '', '');
    }

    /**
    * 店舗名を取得
    * @param  String itemName        店舗ID
    * @return String result          店舗名
    */
    private static String selectShopName(String shopId) {
        String result;
        Shop__c shop = [SELECT Name FROM Shop__c WHERE id = :shopId];
        return result = shop.Name;
    }

    /**
    * 更新前と更新後の項目を比較し、異なる場合はメッセージを返す
    * @param  String itemName           項目名
    * @param  String beforeItem         比較対象の項目
    * @param  String afterItem          比較対象の項目
    * @return String result             引数がnullの場合、空文字/nullでない場合、(改行){項目名}{変更}
    */
    private static String createReturnMessageItemNameChange(String itemName, String beforeItem, String afterItem) {
        if(convertToBlank(beforeItem) == convertToBlank(afterItem)) {
            return '';
        }
        return CommonConst.BREAK_TAG + itemName + CHANGE;
    }

    /**
    * 更新前と更新後の項目を比較し、異なる場合はメッセージを返す
    * @param  String itemName           項目名
    * @param  Boolean beforeItem         比較対象の項目
    * @param  Boolean afterItem          比較対象の項目
    * @return String result              引数がnullの場合、空文字/nullでない場合、createReturnMessage呼び出し
    */
    private static String createReturnMessage(String itemName, Boolean beforeItem, Boolean afterItem) {
        // 更新前のチェックボックス
        String beforeCheckBox;
        // 更新後のチェックボックス
        String afterCheckbox;

        if(beforeItem == afterItem) {
            return '';
        }
        if(beforeItem) {
            beforeCheckBox = 'あり';
            afterCheckbox = 'なし';
        } else {
            beforeCheckBox = 'なし';
            afterCheckbox = 'あり';
        }
        return createReturnMessage(itemName, beforeCheckBox, afterCheckbox, '', '');
    }

    /**
    * 更新項目の文字列を取得
    * @param  Property__c initPropertyRecord                      初期表示時の物件
    * @param  Property__c prop                                    更新された物件
    * @param  PropertyConditions__c initPropertyConditionsRecord  初期表示時の物件条件
    * @param  PropertyConditions__c propCond                      更新された物件条件
    * @return String      result                                  変更された項目と単位を結合した文字列
    */
    public static String getMaintenanceItem(Property__c initPropertyRecord, Property__c prop, 
                                            PropertyConditions__c initPropertyConditionsRecord, 
                                            PropertyConditions__c propCond) {
        String result = '';
        // 物件の料金タブの更新項目を取得
        result += createChangePropertyFeeTabItem(initPropertyRecord,prop);
        // 物件の画像タブの更新項目を取得
        result += createChangePropertyPictureTabItem(initPropertyRecord,prop);
        // 物件の公開タブの更新項目を取得
        result += createChangePropertyPublicTabItem(initPropertyRecord,prop);
        // 建物条件の更新項目を取得
        result += createChangePropertyConditionsItemString(initPropertyConditionsRecord, propCond);
        return result;
    }

    /**
    * 物件のレコードの料金タブを比較し、異なる項目と単位を繋げた文字列を返す
    * @param  Property__c beforeProperty  比較する物件のレコード
    * @param  Property__c afterProperty   比較する物件のレコード
    * @return String      result          変更された項目と単位を結合した文字列
    */
    public static String createChangePropertyFeeTabItem(Property__c beforeProperty, Property__c afterProperty) {

        // 戻り値
        String result = '';
        // 更新前の単位
        String beforeTargetUnit;
        // 更新後の単位
        String afterTargetUnit;

        // 賃料
        result += createReturnMessage(Property__c.RentFee__c.getDescribe().getLabel(), beforeProperty.RentFee__c
                                    , afterProperty.RentFee__c, YEN, YEN);

        // 水道料金
        result += createReturnMessage(Property__c.WortFee__c.getDescribe().getLabel(), beforeProperty.WortFee__c
                                    , afterProperty.WortFee__c, YEN, YEN);

        if(((beforeProperty.WortFee__c != null) && (beforeProperty.WortFee__c == 0 && String.isNotBlank(beforeProperty.WortFeeTaxType__c))) 
            || (beforeProperty.WortFee__c == null && String.isBlank(beforeProperty.WortFeeTaxType__c))
            || (beforeProperty.WortFee__c != afterProperty.WortFee__c)) {
            // 水道料金税区分
            result += createReturnMessage(Property__c.WortFeeTaxType__c.getDescribe().getLabel(), beforeProperty.WortFeeTaxType__c
                                        , afterProperty.WortFeeTaxType__c, '', '');
        }

        // 敷金　※単位に応じた項目を比較
        // 更新前の敷金
        Decimal beforeTargetSecurityDeposit;
        beforeTargetUnit = beforeProperty.SecurityDepositUnit__c;
        if(YEN.equals(beforeTargetUnit)) {
            beforeTargetSecurityDeposit = beforeProperty.SecurityDepositYen__c;
        } else if(MONTHS.equals(beforeTargetUnit)) {
            beforeTargetSecurityDeposit = beforeProperty.SecurityDepositMonth__c;
        }
        // 更新後の敷金
        Decimal afterTargetSecurityDeposit;
        afterTargetUnit = afterProperty.SecurityDepositUnit__c;
        if(YEN.equals(afterTargetUnit)) {
            afterTargetSecurityDeposit = afterProperty.SecurityDepositYen__c;
        } else if(MONTHS.equals(afterTargetUnit)) {
            afterTargetSecurityDeposit = afterProperty.SecurityDepositMonth__c;
        }
        result += createReturnMessage('敷金', beforeTargetSecurityDeposit
                                    , afterTargetSecurityDeposit, beforeTargetUnit, afterTargetUnit);

        // 敷引/償却　※単位に応じた項目を比較
        // 更新前の敷引/償却
        Decimal beforeTargetCancellation;
        beforeTargetUnit = beforeProperty.CancellationActualFeeUnit__c;
        if(YEN.equals(beforeTargetUnit)) {
            beforeTargetCancellation = beforeProperty.CancellationActualFeeYen__c;
        } else if(PERCENT.equals(beforeTargetUnit)) {
            beforeTargetCancellation = beforeProperty.CancellationActualFeeRate__c;
        } else if(MONTHS.equals(beforeTargetUnit)) {
            beforeTargetCancellation = beforeProperty.CancellationActualFeeMonth__c;
        }
        // 更新後の敷引/償却
        Decimal afterTargerCancellation;
        afterTargetUnit = afterProperty.CancellationActualFeeUnit__c;
        if(YEN.equals(afterTargetUnit)) {
            afterTargerCancellation = afterProperty.CancellationActualFeeYen__c;
        } else if(PERCENT.equals(afterTargetUnit)) {
            afterTargerCancellation = afterProperty.CancellationActualFeeRate__c;
        } else if(MONTHS.equals(afterTargetUnit)) {
            afterTargerCancellation = afterProperty.CancellationActualFeeMonth__c;
        }
        result += createReturnMessage('敷引/償却', beforeTargetCancellation
        , afterTargerCancellation, beforeTargetUnit, afterTargetUnit);

        // 管理費
        result += createReturnMessage(Property__c.ManagementFee__c.getDescribe().getLabel(), beforeProperty.ManagementFee__c
                                    , afterProperty.ManagementFee__c, YEN, YEN);

        if(((beforeProperty.ManagementFee__c != null) && (beforeProperty.ManagementFee__c == 0 && String.isNotBlank(beforeProperty.ManagementFeeTaxType__c))) 
            || (beforeProperty.ManagementFee__c == null && String.isBlank(beforeProperty.ManagementFeeTaxType__c))
            || (beforeProperty.ManagementFee__c != afterProperty.ManagementFee__c)) {
            // 管理費税区分
            result += createReturnMessage(Property__c.ManagementFeeTaxType__c.getDescribe().getLabel(), beforeProperty.ManagementFeeTaxType__c
                                        , afterProperty.ManagementFeeTaxType__c, '', '');
        }

        // CATV
        result += createReturnMessage(Property__c.CATVFee__c.getDescribe().getLabel(), beforeProperty.CATVFee__c
                                    , afterProperty.CATVFee__c, YEN, YEN);

        if(((beforeProperty.CATVFee__c != null) && (beforeProperty.CATVFee__c == 0 && String.isNotBlank(beforeProperty.CATVTaxType__c))) 
            || (beforeProperty.CATVFee__c == null && String.isBlank(beforeProperty.CATVTaxType__c))
            || (beforeProperty.CATVFee__c != afterProperty.CATVFee__c)) {
            // CATV税区分
            result += createReturnMessage(Property__c.CATVTaxType__c.getDescribe().getLabel(), beforeProperty.CATVTaxType__c
                                        , afterProperty.CATVTaxType__c, '', '');
        }

        // 保証金　※単位に応じた項目を比較
        // 更新前の保証金
        Decimal beforeTargetDeposit;
        beforeTargetUnit = beforeProperty.DepositUnit__c;
        if(YEN.equals(beforeTargetUnit)) {
            beforeTargetDeposit = beforeProperty.DepositYen__c;
        } else if(MONTHS.equals(beforeTargetUnit)) {
            beforeTargetDeposit = beforeProperty.DepositMonth__c;
        }
        // 更新後の保証金
        Decimal afterTargetDeposit;
        afterTargetUnit = afterProperty.DepositUnit__c;
        if(YEN.equals(afterTargetUnit)) {
            afterTargetDeposit = afterProperty.DepositYen__c;
        } else if(MONTHS.equals(afterTargetUnit)) {
            afterTargetDeposit = afterProperty.DepositMonth__c;
        }
        result += createReturnMessage('保証金', beforeTargetDeposit, afterTargetDeposit, beforeTargetUnit, afterTargetUnit);

        // 更新料/更新事務手数料　※単位に応じた項目を比較
        // 更新前の更新料/更新事務手数料
        Decimal beforeTargetRenewalFee;
        beforeTargetUnit = beforeProperty.RenewalFeeUnit__c;
        if(YEN.equals(beforeTargetUnit)) {
            beforeTargetRenewalFee = beforeProperty.RenewalFeeYen__c;
        } else if(MONTHS.equals(beforeTargetUnit)) {
            beforeTargetRenewalFee = beforeProperty.RenewalFeeMonth__c;
        }
        // 更新後の更新料/更新事務手数料
        Decimal afterTargetRenewalFee;
        afterTargetUnit = afterProperty.RenewalFeeUnit__c;
        if(YEN.equals(afterTargetUnit)) {
            afterTargetRenewalFee = afterProperty.RenewalFeeYen__c;
        } else if(MONTHS.equals(afterTargetUnit)) {
            afterTargetRenewalFee = afterProperty.RenewalFeeMonth__c;
        }
        result += createReturnMessage('更新料/更新事務手数料', beforeTargetRenewalFee, afterTargetRenewalFee, beforeTargetUnit, afterTargetUnit);

        if(((beforeTargetRenewalFee != null) && (beforeTargetRenewalFee == 0 && String.isNotBlank(beforeProperty.RenewalFeeTaxType__c))) 
            || (beforeTargetRenewalFee == null && String.isBlank(beforeProperty.RenewalFeeTaxType__c))
            || (beforeTargetRenewalFee != afterTargetRenewalFee)) {
            // 更新料/更新事務手数料税区分
            result += createReturnMessage('更新料/更新事務手数料税区分', beforeProperty.RenewalFeeTaxType__c, afterProperty.RenewalFeeTaxType__c, '', '');
        }

        // 町内会費
        result += createReturnMessage(Property__c.TownshipFee__c.getDescribe().getLabel(), beforeProperty.TownshipFee__c
                                    , afterProperty.TownshipFee__c, YEN, YEN);

        if(((beforeProperty.TownshipFee__c != null) && (beforeProperty.TownshipFee__c == 0 && String.isNotBlank(beforeProperty.TownshipFeePaymentType__c))) 
            || (beforeProperty.TownshipFee__c == null && String.isBlank(beforeProperty.TownshipFeePaymentType__c))
            || (beforeProperty.TownshipFee__c != afterProperty.TownshipFee__c)) {
            // 町内会費支払区分
            result += createReturnMessage(Property__c.TownshipFeePaymentType__c.getDescribe().getLabel(), beforeProperty.TownshipFeePaymentType__c
                                        , afterProperty.TownshipFeePaymentType__c, '', '');
        }

        if(((beforeProperty.TownshipFee__c != null) && (beforeProperty.TownshipFee__c == 0 && String.isNotBlank(beforeProperty.TownshipFeeTaxType__c))) 
            || (beforeProperty.TownshipFee__c == null && String.isBlank(beforeProperty.TownshipFeeTaxType__c))
            || (beforeProperty.TownshipFee__c != afterProperty.TownshipFee__c)) {
            // 町内会費税区分
            result += createReturnMessage(Property__c.TownshipFeeTaxType__c.getDescribe().getLabel(), beforeProperty.TownshipFeeTaxType__c
                                        , afterProperty.TownshipFeeTaxType__c, '', '');
        }

        // ごみ処理費
        result += createReturnMessage(Property__c.GarbageDisposalFee__c.getDescribe().getLabel(), beforeProperty.GarbageDisposalFee__c
                                    , afterProperty.GarbageDisposalFee__c, YEN, YEN);

        if(((beforeProperty.GarbageDisposalFee__c != null) && (beforeProperty.GarbageDisposalFee__c == 0 && String.isNotBlank(beforeProperty.GarbageDisposalFeePaymentType__c))) 
            || (beforeProperty.GarbageDisposalFee__c == null && String.isBlank(beforeProperty.GarbageDisposalFeePaymentType__c))
            || (beforeProperty.GarbageDisposalFee__c != afterProperty.GarbageDisposalFee__c)) {
            // ごみ処理費支払区分
            result += createReturnMessage(Property__c.GarbageDisposalFeePaymentType__c.getDescribe().getLabel(), beforeProperty.GarbageDisposalFeePaymentType__c
                                        , afterProperty.GarbageDisposalFeePaymentType__c, '', '');
        }

        if(((beforeProperty.GarbageDisposalFee__c != null) && (beforeProperty.GarbageDisposalFee__c == 0 && String.isNotBlank(beforeProperty.GarbageDisposalFeeTaxType__c))) 
            || (beforeProperty.GarbageDisposalFee__c == null && String.isBlank(beforeProperty.GarbageDisposalFeeTaxType__c))
            || (beforeProperty.GarbageDisposalFee__c != afterProperty.GarbageDisposalFee__c)) {
            // ごみ処理費税区分
            result += createReturnMessage(Property__c.GarbageDisposalFeeTaxType__c.getDescribe().getLabel(), beforeProperty.GarbageDisposalFeeTaxType__c
                                        , afterProperty.GarbageDisposalFeeTaxType__c, '', '');
        }

        // 礼金　※単位に応じた項目を比較
        // 更新前の礼金
        Decimal beforeTargetKeyMoney;
        beforeTargetUnit = beforeProperty.KeyMoneyUnit__c;
        if(YEN.equals(beforeTargetUnit)) {
            beforeTargetKeyMoney = beforeProperty.KeyMoneyYen__c;
        } else if(MONTHS.equals(beforeTargetUnit)) {
            beforeTargetKeyMoney = beforeProperty.KeyMoneyMonth__c;
        }
        // 更新後の礼金
        Decimal afterTargetKeyMoney;
        afterTargetUnit = afterProperty.KeyMoneyUnit__c;
        if(YEN.equals(afterTargetUnit)) {
            afterTargetKeyMoney = afterProperty.KeyMoneyYen__c;
        } else if(MONTHS.equals(afterTargetUnit)) {
            afterTargetKeyMoney = afterProperty.KeyMoneyMonth__c;
        }
        result += createReturnMessage('礼金', beforeTargetKeyMoney, afterTargetKeyMoney, beforeTargetUnit, afterTargetUnit);

        // 入町費
        result += createReturnMessage(Property__c.TownshipInitialFee__c.getDescribe().getLabel(), beforeProperty.TownshipInitialFee__c
                                    , afterProperty.TownshipInitialFee__c, YEN, YEN);

        if(((beforeProperty.TownshipInitialFee__c != null) && (beforeProperty.TownshipInitialFee__c == 0 && String.isNotBlank(beforeProperty.TownshipInitialFeeTaxType__c))) 
            || (beforeProperty.TownshipInitialFee__c == null && String.isBlank(beforeProperty.TownshipInitialFeeTaxType__c))
            || (beforeProperty.TownshipInitialFee__c != afterProperty.TownshipInitialFee__c)) {
            // 入町費税区分
            result += createReturnMessage(Property__c.TownshipInitialFeeTaxType__c.getDescribe().getLabel(), beforeProperty.TownshipInitialFeeTaxType__c
                                        , afterProperty.TownshipInitialFeeTaxType__c, '', '');
        }

        // 定額修繕費/クリーニング費　※単位に応じた項目を比較
        // 更新前の定額修繕費/クリーニング費
        Decimal beforeTargetCleaningFee;
        beforeTargetUnit = beforeProperty.CleaningFeeUnit__c;
        if(YEN.equals(beforeTargetUnit)) {
            beforeTargetCleaningFee = beforeProperty.CleaningFeeYen__c;
        } else if(MONTHS.equals(beforeTargetUnit)) {
            beforeTargetCleaningFee = beforeProperty.CleaningFeeMonth__c;
        }
        // 更新後の定額修繕費/クリーニング費
        Decimal afterTargetCleaningFee;
        afterTargetUnit = afterProperty.CleaningFeeUnit__c;
        if(YEN.equals(afterTargetUnit)) {
            afterTargetCleaningFee = afterProperty.CleaningFeeYen__c;
        } else if(MONTHS.equals(afterTargetUnit)) {
            afterTargetCleaningFee = afterProperty.CleaningFeeMonth__c;
        }
        result += createReturnMessage('定額修繕費/クリーニング費', beforeTargetCleaningFee
                                    , afterTargetCleaningFee, beforeTargetUnit, afterTargetUnit);

        if(((beforeTargetCleaningFee != null) && (beforeTargetCleaningFee == 0 && String.isNotBlank(beforeProperty.CleaningFeePaymentType__c))) 
            || (beforeTargetCleaningFee == null && String.isBlank(beforeProperty.CleaningFeePaymentType__c))
            || (beforeTargetCleaningFee != afterTargetCleaningFee)) {
            // 定額修繕費/クリーニング費支払区分
            result += createReturnMessage('定額修繕費/クリーニング費支払区分', beforeProperty.CleaningFeePaymentType__c
                                        , afterProperty.CleaningFeePaymentType__c, '', '');
        }

        if(((beforeTargetCleaningFee != null) && (beforeTargetCleaningFee == 0 && String.isNotBlank(beforeProperty.CleaningFeeTaxType__c))) 
            || (beforeTargetCleaningFee == null && String.isBlank(beforeProperty.CleaningFeeTaxType__c))
            || (beforeTargetCleaningFee != afterTargetCleaningFee)) {
            // 定額修繕費/クリーニング費税区分
            result += createReturnMessage('定額修繕費/クリーニング費税区分', beforeProperty.CleaningFeeTaxType__c
                                        , afterProperty.CleaningFeeTaxType__c, '', '');
        }

        // 鍵交換費
        result += createReturnMessage(Property__c.KeyExchangeFee__c.getDescribe().getLabel(), beforeProperty.KeyExchangeFee__c
                                    , afterProperty.KeyExchangeFee__c, YEN, YEN);

        if(((beforeProperty.KeyExchangeFee__c != null) && (beforeProperty.KeyExchangeFee__c == 0 && String.isNotBlank(beforeProperty.KeyExchangeFeeTaxType__c))) 
            || (beforeProperty.KeyExchangeFee__c == null && String.isBlank(beforeProperty.KeyExchangeFeeTaxType__c))
            || (beforeProperty.KeyExchangeFee__c != afterProperty.KeyExchangeFee__c)) {
            // 鍵交換費税区分
            result += createReturnMessage(Property__c.KeyExchangeFeeTaxType__c.getDescribe().getLabel(), beforeProperty.KeyExchangeFeeTaxType__c
                                        , afterProperty.KeyExchangeFeeTaxType__c, '', '');
        }

        // 金銭備考(公開)
        result += createReturnMessageItemNameChange(Property__c.MonetaryPublic__c.getDescribe().getLabel(), beforeProperty.MonetaryPublic__c
                                                    , afterProperty.MonetaryPublic__c);

        // 駐輪場種別
        if(String.isNotBlank(beforeProperty.BicycleParkingType__c) || (String.isBlank(beforeProperty.BicycleParkingType__c) && !PARKINGTYPE_NO.equals(afterProperty.BicycleParkingType__c))) {
            result += createReturnMessage(Property__c.BicycleParkingType__c.getDescribe().getLabel(), beforeProperty.BicycleParkingType__c
            , afterProperty.BicycleParkingType__c, '', '');
        }

        // 駐輪場代
        result += createReturnMessage(Property__c.BicycleParkingFee__c.getDescribe().getLabel(), beforeProperty.BicycleParkingFee__c
                                    , afterProperty.BicycleParkingFee__c, YEN, YEN);

        if(((beforeProperty.BicycleParkingFee__c != null) && (beforeProperty.BicycleParkingFee__c == 0 && String.isNotBlank(beforeProperty.BicycleParkingFeeTaxType__c))) 
            || (beforeProperty.BicycleParkingFee__c == null && String.isBlank(beforeProperty.BicycleParkingFeeTaxType__c))
            || (beforeProperty.BicycleParkingFee__c != afterProperty.BicycleParkingFee__c)) {
            // 駐輪場代税区分
            result += createReturnMessage(Property__c.BicycleParkingFeeTaxType__c.getDescribe().getLabel(), beforeProperty.BicycleParkingFeeTaxType__c
                                        , afterProperty.BicycleParkingFeeTaxType__c, '', '');
        }
        
        // 駐車場種別
        if(String.isNotBlank(beforeProperty.ParkingType__c) || (String.isBlank(beforeProperty.ParkingType__c) && !PARKINGTYPE_NO.equals(afterProperty.ParkingType__c))) {
            result += createReturnMessage(Property__c.ParkingType__c.getDescribe().getLabel(), beforeProperty.ParkingType__c
            , afterProperty.ParkingType__c, '', '');
        }

        // 近隣駐車場までの距離
        result += createReturnMessage(Property__c.ParkingDistance__c.getDescribe().getLabel(), beforeProperty.ParkingDistance__c
                                    , afterProperty.ParkingDistance__c, METER, METER);

        // 駐車場料金
        result += createReturnMessage(Property__c.ParkingFee__c.getDescribe().getLabel(), beforeProperty.ParkingFee__c
                                    , afterProperty.ParkingFee__c, YEN, YEN);

        if(((beforeProperty.ParkingFee__c != null) && (beforeProperty.ParkingFee__c == 0 && String.isNotBlank(beforeProperty.ParkingFeeTaxType__c))) 
            || (beforeProperty.ParkingFee__c == null && String.isBlank(beforeProperty.ParkingFeeTaxType__c))
            || (beforeProperty.ParkingFee__c != afterProperty.ParkingFee__c)) {
            // 駐車場料金税区分
            result += createReturnMessage(Property__c.ParkingFeeTaxType__c.getDescribe().getLabel(), beforeProperty.ParkingFeeTaxType__c
                                        , afterProperty.ParkingFeeTaxType__c, '', '');
        }

        // 駐車場保証金　※単位に応じた項目を比較
        // 更新前の駐車場保証金
        Decimal beforeTargetParkingDeposit;
        beforeTargetUnit = beforeProperty.ParkingDepositUnit__c;
        if(YEN.equals(beforeTargetUnit)) {
            beforeTargetParkingDeposit = beforeProperty.ParkingDepositYen__c;
        } else if(MONTHS.equals(beforeTargetUnit)) {
            beforeTargetParkingDeposit = beforeProperty.ParkingDepositMonth__c;
        }
        // 更新後の駐車場保証金
        Decimal afterTargetParkingDeposit;
        afterTargetUnit = afterProperty.ParkingDepositUnit__c;
        if(YEN.equals(afterTargetUnit)) {
            afterTargetParkingDeposit = afterProperty.ParkingDepositYen__c;
        } else if(MONTHS.equals(afterTargetUnit)) {
            afterTargetParkingDeposit = afterProperty.ParkingDepositMonth__c;
        }
        result += createReturnMessage('駐車場保証金', beforeTargetParkingDeposit
                                    , afterTargetParkingDeposit, beforeTargetUnit, afterTargetUnit);

        if(((beforeTargetParkingDeposit != null) && (beforeTargetParkingDeposit == 0 && String.isNotBlank(beforeProperty.ParkingDepositTaxType__c))) 
            || (beforeTargetParkingDeposit == null && String.isBlank(beforeProperty.ParkingDepositTaxType__c))
            || (beforeTargetParkingDeposit != afterTargetParkingDeposit)) {
            // 駐車場保証料金税区分
            result += createReturnMessage(Property__c.ParkingDepositTaxType__c.getDescribe().getLabel(), beforeProperty.ParkingDepositTaxType__c
                                        , afterProperty.ParkingDepositTaxType__c, '', '');
        }

        // 駐車場手数料　※単位に応じた項目を比較
        // 更新前の駐車場手数料
        Decimal beforeTargetParkingCompoundingFee;
        beforeTargetUnit = beforeProperty.ParkingCompoundingFeeUnit__c;
        if(YEN.equals(beforeTargetUnit)) {
            beforeTargetParkingCompoundingFee = beforeProperty.ParkingCompoundingFeeYen__c;
        } else if(MONTHS.equals(beforeTargetUnit)) {
            beforeTargetParkingCompoundingFee = beforeProperty.ParkingCompoundingFeeMonth__c;
        }
        // 更新後の駐車場手数料
        Decimal afterTargetParkingCompoundingFee;
        afterTargetUnit = afterProperty.ParkingCompoundingFeeUnit__c;
        if(YEN.equals(afterTargetUnit)) {
            afterTargetParkingCompoundingFee = afterProperty.ParkingCompoundingFeeYen__c;
        } else if(MONTHS.equals(afterTargetUnit)) {
            afterTargetParkingCompoundingFee = afterProperty.ParkingCompoundingFeeMonth__c;
        }
        result += createReturnMessage('駐車場手数料', beforeTargetParkingCompoundingFee
                                    , afterTargetParkingCompoundingFee, beforeTargetUnit, afterTargetUnit);
        
        if(((beforeTargetParkingCompoundingFee != null) && (beforeTargetParkingCompoundingFee == 0 && String.isNotBlank(beforeProperty.ParkingCompoundingFeeTaxType__c))) 
            || (beforeTargetParkingCompoundingFee == null && String.isBlank(beforeProperty.ParkingCompoundingFeeTaxType__c))
            || (beforeTargetParkingCompoundingFee != afterTargetParkingCompoundingFee)) {
            // 駐車場手数料税区分
            result += createReturnMessage(Property__c.ParkingCompoundingFeeTaxType__c.getDescribe().getLabel(), beforeProperty.ParkingCompoundingFeeTaxType__c
                                        , afterProperty.ParkingCompoundingFeeTaxType__c, '', '');
        }

        // 駐車場備考(公開)
        result += createReturnMessageItemNameChange(Property__c.ParkingRemarksPublic__c.getDescribe().getLabel(), beforeProperty.ParkingRemarksPublic__c
                                                    , afterProperty.ParkingRemarksPublic__c);
        if(String.isNotBlank(beforeProperty.BikeStorageType__c) || (String.isBlank(beforeProperty.BikeStorageType__c) && !PARKINGTYPE_NO.equals(afterProperty.BikeStorageType__c))) {
            // バイク置場種別
            result += createReturnMessage(Property__c.BikeStorageType__c.getDescribe().getLabel(), beforeProperty.BikeStorageType__c
                                        , afterProperty.BikeStorageType__c, '', '');
        }

        // バイク置場料金　小型
        result += createReturnMessage('バイク置場料金　小型', beforeProperty.BikeParkingSmallFee__c
                                    , afterProperty.BikeParkingSmallFee__c, YEN, YEN);

        if(((beforeProperty.BikeParkingSmallFee__c != null) && (beforeProperty.BikeParkingSmallFee__c == 0 && String.isNotBlank(beforeProperty.BikeParkingSmallFeeTaxType__c))) 
            || (beforeProperty.BikeParkingSmallFee__c == null && String.isBlank(beforeProperty.BikeParkingSmallFeeTaxType__c))
            || (beforeProperty.BikeParkingSmallFee__c != afterProperty.BikeParkingSmallFee__c)) {
            // バイク置場料金　小型税区分
            result += createReturnMessage('バイク置場料金　小型税区分', beforeProperty.BikeParkingSmallFeeTaxType__c
                                        , afterProperty.BikeParkingSmallFeeTaxType__c, '', '');
        }

        // バイク置場料金　中型
        result += createReturnMessage('バイク置場料金　中型', beforeProperty.BikeParkingMediumFee__c
                                    , afterProperty.BikeParkingMediumFee__c, YEN, YEN);

        if(((beforeProperty.BikeParkingMediumFee__c != null) && (beforeProperty.BikeParkingMediumFee__c == 0 && String.isNotBlank(beforeProperty.BikeParkingMediumFeeTaxType__c))) 
            || (beforeProperty.BikeParkingMediumFee__c == null && String.isBlank(beforeProperty.BikeParkingMediumFeeTaxType__c))
            || (beforeProperty.BikeParkingMediumFee__c != afterProperty.BikeParkingMediumFee__c)) {
            // バイク置場料金　中型税区分
            result += createReturnMessage('バイク置場料金　中型税区分', beforeProperty.BikeParkingMediumFeeTaxType__c
                                        , afterProperty.BikeParkingMediumFeeTaxType__c, '', '');
        }

        // バイク置場料金　大型
        result += createReturnMessage('バイク置場料金　大型', beforeProperty.BikeParkinLargeFee__c
                                    , afterProperty.BikeParkinLargeFee__c, YEN, YEN);

        if(((beforeProperty.BikeParkinLargeFee__c != null) && (beforeProperty.BikeParkinLargeFee__c == 0 && String.isNotBlank(beforeProperty.BikeParkinLargeFeeTaxType__c))) 
            || (beforeProperty.BikeParkinLargeFee__c == null && String.isBlank(beforeProperty.BikeParkinLargeFeeTaxType__c))
            || (beforeProperty.BikeParkinLargeFee__c != afterProperty.BikeParkinLargeFee__c)) {
            // バイク置場料金　大型税区分
            result += createReturnMessage('バイク置場料金　大型税区分', beforeProperty.BikeParkinLargeFeeTaxType__c
                                        , afterProperty.BikeParkinLargeFeeTaxType__c, '', '');
        }

        if(String.isNotBlank(beforeProperty.IsShortTermPenalty__c) || (String.isBlank(beforeProperty.IsShortTermPenalty__c) && !PARKINGTYPE_NO.equals(afterProperty.IsShortTermPenalty__c))) {
            // 短期解約違約金有無
            result += createReturnMessage(Property__c.IsShortTermPenalty__c.getDescribe().getLabel(), beforeProperty.IsShortTermPenalty__c
                                        , afterProperty.IsShortTermPenalty__c, '', '');
        }

        // 短期解約違約年数(1)
        result += createReturnMessage(Property__c.ShortTermPenaltyLessYear__c.getDescribe().getLabel(), beforeProperty.ShortTermPenaltyLessYear__c
                                    , afterProperty.ShortTermPenaltyLessYear__c);

        // 短期解約違約金(1)
        result += createReturnMessage(Property__c.ShortTermPenaltyFee__c.getDescribe().getLabel(), beforeProperty.ShortTermPenaltyFee__c
                                    , afterProperty.ShortTermPenaltyFee__c, MONTHS, MONTHS);

        // 短期解約違約年数(2)
        result += createReturnMessage(Property__c.ShortTermPenaltyLessYear2__c.getDescribe().getLabel(), beforeProperty.ShortTermPenaltyLessYear2__c
                                    , afterProperty.ShortTermPenaltyLessYear2__c);

        // 短期解約違約金(2)
        result += createReturnMessage(Property__c.ShortTermPenaltyFee2__c.getDescribe().getLabel(), beforeProperty.ShortTermPenaltyFee2__c
                                    , afterProperty.ShortTermPenaltyFee2__c, MONTHS, MONTHS);

        // 火災保険加入義務
        result += createReturnMessage(Property__c.FireInsuranceUseType__c.getDescribe().getLabel(), beforeProperty.FireInsuranceUseType__c
                                    , afterProperty.FireInsuranceUseType__c, '', '');

        // 保証会社利用区分
        result += createReturnMessage(Property__c.GuaranteeidCompanyType__c.getDescribe().getLabel(), beforeProperty.GuaranteeidCompanyType__c
                                    , afterProperty.GuaranteeidCompanyType__c, '', '');

        // 広告料　※単位に応じた項目を比較
        // 更新前の広告料
        Decimal beforeTargetADFee;
        beforeTargetUnit = beforeProperty.ADFeeUnit__c;
        if(YEN.equals(beforeTargetUnit)) {
            beforeTargetADFee = beforeProperty.ADFeeYen__c;
        } else if(PERCENT.equals(beforeTargetUnit)) {
            beforeTargetADFee = beforeProperty.ADFeeRate__c;
        } else if(MONTHS.equals(beforeTargetUnit)) {
            beforeTargetADFee = beforeProperty.ADFeeMonth__c;
        }
        // 更新後の広告料
        Decimal afterTargetADFee;
        afterTargetUnit = afterProperty.ADFeeUnit__c;
        if(YEN.equals(afterTargetUnit)) {
            afterTargetADFee = afterProperty.ADFeeYen__c;
        } else if(PERCENT.equals(afterTargetUnit)) {
            afterTargetADFee = afterProperty.ADFeeRate__c;
        } else if(MONTHS.equals(afterTargetUnit)) {
            afterTargetADFee = afterProperty.ADFeeMonth__c;
        }
        result += createReturnMessage('広告料', beforeTargetADFee, afterTargetADFee, beforeTargetUnit, afterTargetUnit);

        if(((beforeTargetADFee != null) && (beforeTargetADFee == 0 && String.isNotBlank(beforeProperty.ADFeeTaxType__c))) 
            || (beforeTargetADFee == null && String.isBlank(beforeProperty.ADFeeTaxType__c))
            || (beforeTargetADFee != afterTargetADFee)) {
            // 広告料税区分
            result += createReturnMessage(Property__c.ADFeeTaxType__c.getDescribe().getLabel(), beforeProperty.ADFeeTaxType__c
                                        , afterProperty.ADFeeTaxType__c, '', '');
        }

        // 広告料コメント
        result += createReturnMessageItemNameChange(Property__c.ADFeeComment__c.getDescribe().getLabel(), beforeProperty.ADFeeComment__c
                                                    , afterProperty.ADFeeComment__c);

        // 報酬負担貸主
        result += createReturnMessage(Property__c.RewardBurdenLender__c.getDescribe().getLabel(), beforeProperty.RewardBurdenLender__c
                                    , afterProperty.RewardBurdenLender__c);

        // 報酬負担借主
        result += createReturnMessage(Property__c.RewardBurdenBorrower__c.getDescribe().getLabel(), beforeProperty.RewardBurdenBorrower__c
                                    , afterProperty.RewardBurdenBorrower__c);

        // 報酬配分元付
        result += createReturnMessage(Property__c.RewardSplitFormerSupplier__c.getDescribe().getLabel(), beforeProperty.RewardSplitFormerSupplier__c
                                    , afterProperty.RewardSplitFormerSupplier__c);

        // 報酬配分客付
        result += createReturnMessage(Property__c.RewardSplitCustomer__c.getDescribe().getLabel(), beforeProperty.RewardSplitCustomer__c
                                    , afterProperty.RewardSplitCustomer__c);

        // 鍵所在
        result += createReturnMessageItemNameChange(Property__c.KeyPlace__c.getDescribe().getLabel(), beforeProperty.KeyPlace__c
                                    , afterProperty.KeyPlace__c);

        return result;
    }

    /**
    * 物件のレコードの画像タブを比較し、異なる項目と単位を繋げた文字列を返す
    * @param  Property__c beforeProperty  比較する物件のレコード
    * @param  Property__c afterProperty   比較する物件のレコード
    * @return String      result          変更された項目と単位を結合した文字列
    */
    public static String createChangePropertyPictureTabItem(Property__c beforeProperty, Property__c afterProperty) {

        // 戻り値
        String result = '';

        // at homeパノラマコンテンツＩＤ
        result += createReturnMessage(Property__c.AthomePanoramaContentsId__c.getDescribe().getLabel(), beforeProperty.AthomePanoramaContentsId__c
                                    , afterProperty.AthomePanoramaContentsId__c, '', '');

        // at homeパノラマ掲載店舗
        result += createReturnMessage(Property__c.AtHomePanoramaShop__c.getDescribe().getLabel(), beforeProperty.AtHomePanoramaShop__c
                                    , afterProperty.AtHomePanoramaShop__c);
        
        return result;
    }

    /**
    * 物件のレコードの公開タブを比較し、異なる項目と単位を繋げた文字列を返す
    * @param  Property__c beforeProperty  比較する物件のレコード
    * @param  Property__c afterProperty   比較する物件のレコード
    * @return String      result          変更された項目と単位を結合した文字列
    */
    public static String createChangePropertyPublicTabItem(Property__c beforeProperty, Property__c afterProperty) {

        // 戻り値
        String result = '';

        // web公開
        result += createReturnMessage(Property__c.WebPublishing__c.getDescribe().getLabel(), beforeProperty.WebPublishing__c
                                    , afterProperty.WebPublishing__c, '', '');

        // // 掲載許可済みフラグ
        // result += createReturnMessage(Property__c.IsPermissionPublishing__c.getDescribe().getLabel(), beforeProperty.IsPermissionPublishing__c
        //                             , afterProperty.IsPermissionPublishing__c);

        // 物件名非表示フラグ
        result += createReturnMessage(Property__c.IsPropertyNameHiddenFlag__c.getDescribe().getLabel(), beforeProperty.IsPropertyNameHiddenFlag__c
                                    , afterProperty.IsPropertyNameHiddenFlag__c);

        

        // 取込先
        result += createReturnMessage(Property__c.ImportType__c.getDescribe().getLabel(), beforeProperty.ImportType__c
                                    , afterProperty.ImportType__c, '', '');

        // SUUMOネット用キャッチ
        result += createReturnMessageItemNameChange(Property__c.SuumoNetCatch__c.getDescribe().getLabel(), beforeProperty.SuumoNetCatch__c
                                                    , afterProperty.SuumoNetCatch__c);

        // SUUMOネット用キャッチコメント
        result += createReturnMessageItemNameChange(Property__c.SuumoNetCatchComment__c.getDescribe().getLabel(), beforeProperty.SuumoNetCatchComment__c
                                                    , afterProperty.SuumoNetCatchComment__c);

        // SUUMO備考
        result += createReturnMessageItemNameChange(Property__c.SuumoRemarks__c.getDescribe().getLabel(), beforeProperty.SuumoRemarks__c
                                                    , afterProperty.SuumoRemarks__c);

        // HOME'S物件の特徴
        result += createReturnMessageItemNameChange(Property__c.HomesPropertyFeature__c.getDescribe().getLabel(), beforeProperty.HomesPropertyFeature__c
                                                    , afterProperty.HomesPropertyFeature__c);

        // HOME'S備考
        result += createReturnMessageItemNameChange(Property__c.HomesRemarks__c.getDescribe().getLabel(), beforeProperty.HomesRemarks__c
                                                    , afterProperty.HomesRemarks__c);

        // at homeおすすめコメント
        result += createReturnMessageItemNameChange(Property__c.AthomeRecommendComment__c.getDescribe().getLabel(), beforeProperty.AthomeRecommendComment__c
                                                    , afterProperty.AthomeRecommendComment__c);

        // at homeおすすめコメントスタッフＩＤ
        result += createReturnMessageItemNameChange(Property__c.AthomeRecommendCommentStaffId__c.getDescribe().getLabel(), beforeProperty.AthomeRecommendCommentStaffId__c
                                                    , afterProperty.AthomeRecommendCommentStaffId__c);

        // at home備考
        result += createReturnMessageItemNameChange(Property__c.AtHomeRemarks__c.getDescribe().getLabel(), beforeProperty.AtHomeRemarks__c
                                                    , afterProperty.AtHomeRemarks__c);

		// ▼ 2022/03/28 CHINTAI対応追加 CHINTAI雑誌コメント
        result += createReturnMessageItemNameChange(Property__c.ChintaiMagazineComment__c.getDescribe().getLabel(), beforeProperty.ChintaiMagazineComment__c
                                                    , afterProperty.ChintaiMagazineComment__c);
		// ▲ 2022/03/28 CHINTAI対応追加

        return result;
    }

    /**
    * 物件条件のレコードを比較し、異なる項目と単位を繋げた文字列を返す
    * @param  PropertyConditions__c beforePropertyConditions 比較する物件条件のレコード
    * @param  PropertyConditions__c afterPropertyConditions  比較する物件条件のレコード
    * @return String result         変更された項目と単位を結合した文字列
    */
    public static String createChangePropertyConditionsItemString(PropertyConditions__c beforePropertyConditions, PropertyConditions__c afterPropertyConditions) {

        // 戻り値
        String result = '';

        // 駐輪場
        result += createReturnMessage(PropertyConditions__c.IsBicycleParking__c.getDescribe().getLabel(), beforePropertyConditions.IsBicycleParking__c
                                    , afterPropertyConditions.IsBicycleParking__c);

        // 駐車場2台可
        result += createReturnMessage(PropertyConditions__c.IsPluralCarParking__c.getDescribe().getLabel(), beforePropertyConditions.IsPluralCarParking__c
                                    , afterPropertyConditions.IsPluralCarParking__c);

        // メゾネット
        result += createReturnMessage(PropertyConditions__c.IsMaisonette__c.getDescribe().getLabel(), beforePropertyConditions.IsMaisonette__c
                                    , afterPropertyConditions.IsMaisonette__c);

        // ロフト
        result += createReturnMessage(PropertyConditions__c.IsLoft__c.getDescribe().getLabel(), beforePropertyConditions.IsLoft__c
                                    , afterPropertyConditions.IsLoft__c);

        // デザイナーズ
        result += createReturnMessage(PropertyConditions__c.IsDesigners__c.getDescribe().getLabel(), beforePropertyConditions.IsDesigners__c
                                    , afterPropertyConditions.IsDesigners__c);

        // 分譲賃貸
        result += createReturnMessage(PropertyConditions__c.IsCondominiumRental__c.getDescribe().getLabel(), beforePropertyConditions.IsCondominiumRental__c
                                    , afterPropertyConditions.IsCondominiumRental__c);

        // オール洋間
        result += createReturnMessage(PropertyConditions__c.IsAllWesternStyleRoom__c.getDescribe().getLabel(), beforePropertyConditions.IsAllWesternStyleRoom__c
                                    , afterPropertyConditions.IsAllWesternStyleRoom__c);

        // タワーマンション
        result += createReturnMessage(PropertyConditions__c.IsTowerMansion__c.getDescribe().getLabel(), beforePropertyConditions.IsTowerMansion__c
                                    , afterPropertyConditions.IsTowerMansion__c);

        // バリアフリー
        result += createReturnMessage(PropertyConditions__c.IsBarrierFree__c.getDescribe().getLabel(), beforePropertyConditions.IsBarrierFree__c
                                    , afterPropertyConditions.IsBarrierFree__c);

        // 外壁タイル張り
        result += createReturnMessage(PropertyConditions__c.IsOuterWallTile__c.getDescribe().getLabel(), beforePropertyConditions.IsOuterWallTile__c
                                    , afterPropertyConditions.IsOuterWallTile__c);

        // 制震構造
        result += createReturnMessage(PropertyConditions__c.IsDampingStructure__c.getDescribe().getLabel(), beforePropertyConditions.IsDampingStructure__c
                                    , afterPropertyConditions.IsDampingStructure__c);

        // 耐震構造
        result += createReturnMessage(PropertyConditions__c.IsSeismicStructure__c.getDescribe().getLabel(), beforePropertyConditions.IsSeismicStructure__c
                                    , afterPropertyConditions.IsSeismicStructure__c);

        // 免震構造
        result += createReturnMessage(PropertyConditions__c.IsSeismicIsolationStructure__c.getDescribe().getLabel(), beforePropertyConditions.IsSeismicIsolationStructure__c
                                    , afterPropertyConditions.IsSeismicIsolationStructure__c);

        // 地下室
        result += createReturnMessage(PropertyConditions__c.IsUndergroundRoom__c.getDescribe().getLabel(), beforePropertyConditions.IsUndergroundRoom__c
                                    , afterPropertyConditions.IsUndergroundRoom__c);

        // 防音室
        result += createReturnMessage(PropertyConditions__c.IsSoundproofRoom__c.getDescribe().getLabel(), beforePropertyConditions.IsSoundproofRoom__c
                                    , afterPropertyConditions.IsSoundproofRoom__c);

        // 浄化槽
        result += createReturnMessage(PropertyConditions__c.IsSepticTank__c.getDescribe().getLabel(), beforePropertyConditions.IsSepticTank__c
                                    , afterPropertyConditions.IsSepticTank__c);

        // 閑静な住宅街
        result += createReturnMessage(PropertyConditions__c.IsQuietResidenceTown__c.getDescribe().getLabel(), beforePropertyConditions.IsQuietResidenceTown__c
                                    , afterPropertyConditions.IsQuietResidenceTown__c);

        // 角部屋
        result += createReturnMessage(PropertyConditions__c.IsCornerRoom__c.getDescribe().getLabel(), beforePropertyConditions.IsCornerRoom__c
                                    , afterPropertyConditions.IsCornerRoom__c);

        // 出窓
        result += createReturnMessage(PropertyConditions__c.IsBayWindow__c.getDescribe().getLabel(), beforePropertyConditions.IsBayWindow__c
                                    , afterPropertyConditions.IsBayWindow__c);

        // 専用庭
        result += createReturnMessage(PropertyConditions__c.IsPrivateGarden__c.getDescribe().getLabel(), beforePropertyConditions.IsPrivateGarden__c
                                    , afterPropertyConditions.IsPrivateGarden__c);

        // バルコニー
        result += createReturnMessage(PropertyConditions__c.IsBalcony__c.getDescribe().getLabel(), beforePropertyConditions.IsBalcony__c
                                    , afterPropertyConditions.IsBalcony__c);

        // ルーフバルコニー
        result += createReturnMessage(PropertyConditions__c.IsRoofBalcony__c.getDescribe().getLabel(), beforePropertyConditions.IsRoofBalcony__c
                                    , afterPropertyConditions.IsRoofBalcony__c);

        // ウッドデッキ
        result += createReturnMessage(PropertyConditions__c.IsWoodDeck__c.getDescribe().getLabel(), beforePropertyConditions.IsWoodDeck__c
                                    , afterPropertyConditions.IsWoodDeck__c);

        // ビルトインガレージ
        result += createReturnMessage(PropertyConditions__c.IsBuiltInGarage__c.getDescribe().getLabel(), beforePropertyConditions.IsBuiltInGarage__c
                                    , afterPropertyConditions.IsBuiltInGarage__c);

        // カーポート
        result += createReturnMessage(PropertyConditions__c.IsCarport__c.getDescribe().getLabel(), beforePropertyConditions.IsCarport__c
                                    , afterPropertyConditions.IsCarport__c);

        // エレベーター
        result += createReturnMessage(PropertyConditions__c.IsElevator__c.getDescribe().getLabel(), beforePropertyConditions.IsElevator__c
                                    , afterPropertyConditions.IsElevator__c);

        // エレベーター2基
        result += createReturnMessage(PropertyConditions__c.IsPluralElevators__c.getDescribe().getLabel(), beforePropertyConditions.IsPluralElevators__c
                                    , afterPropertyConditions.IsPluralElevators__c);

        // 敷地内ゴミ置場
        result += createReturnMessage(PropertyConditions__c.IsInSiteTtrashArea__c.getDescribe().getLabel(), beforePropertyConditions.IsInSiteTtrashArea__c
                                    , afterPropertyConditions.IsInSiteTtrashArea__c);

        // 24時間ゴミ出し可
        result += createReturnMessage(PropertyConditions__c.IsAnytimeTtrashArea__c.getDescribe().getLabel(), beforePropertyConditions.IsAnytimeTtrashArea__c
                                    , afterPropertyConditions.IsAnytimeTtrashArea__c);

        // フロントサービス
        result += createReturnMessage(PropertyConditions__c.IsFrontService__c.getDescribe().getLabel(), beforePropertyConditions.IsFrontService__c
                                    , afterPropertyConditions.IsFrontService__c);

        // 宅配ボックス
        result += createReturnMessage(PropertyConditions__c.IsDeliveryBox__c.getDescribe().getLabel(), beforePropertyConditions.IsDeliveryBox__c
                                    , afterPropertyConditions.IsDeliveryBox__c);

        // クリーニングボックス
        result += createReturnMessage(PropertyConditions__c.IsCleaningBox__c.getDescribe().getLabel(), beforePropertyConditions.IsCleaningBox__c
                                    , afterPropertyConditions.IsCleaningBox__c);

        // コインランドリー
        result += createReturnMessage(PropertyConditions__c.IsCoinLaundry__c.getDescribe().getLabel(), beforePropertyConditions.IsCoinLaundry__c
                                    , afterPropertyConditions.IsCoinLaundry__c);

        // カウンターキッチン
        result += createReturnMessage(PropertyConditions__c.IsCounterKitchen__c.getDescribe().getLabel(), beforePropertyConditions.IsCounterKitchen__c
                                    , afterPropertyConditions.IsCounterKitchen__c);

        // システムキッチン
        result += createReturnMessage(PropertyConditions__c.IsSystemKitchen__c.getDescribe().getLabel(), beforePropertyConditions.IsSystemKitchen__c
                                    , afterPropertyConditions.IsSystemKitchen__c);

        // ガスコンロ
        result += createReturnMessage(PropertyConditions__c.IsGasStove__c.getDescribe().getLabel(), beforePropertyConditions.IsGasStove__c
                                    , afterPropertyConditions.IsGasStove__c);

        // 電気コンロ
        result += createReturnMessage(PropertyConditions__c.IsElectricStove__c.getDescribe().getLabel(), beforePropertyConditions.IsElectricStove__c
                                    , afterPropertyConditions.IsElectricStove__c);

        // IHコンロ
        result += createReturnMessage(PropertyConditions__c.IsIhStove__c.getDescribe().getLabel(), beforePropertyConditions.IsIhStove__c
                                    , afterPropertyConditions.IsIhStove__c);

        // コンロ2口
        result += createReturnMessage(PropertyConditions__c.IsTwoGasStove__c.getDescribe().getLabel(), beforePropertyConditions.IsTwoGasStove__c
                                    , afterPropertyConditions.IsTwoGasStove__c);

        // コンロ3口以上
        result += createReturnMessage(PropertyConditions__c.IsMoreGasStove__c.getDescribe().getLabel(), beforePropertyConditions.IsMoreGasStove__c
                                    , afterPropertyConditions.IsMoreGasStove__c);

        // 浄水器
        result += createReturnMessage(PropertyConditions__c.IsWaterPurifier__c.getDescribe().getLabel(), beforePropertyConditions.IsWaterPurifier__c
                                    , afterPropertyConditions.IsWaterPurifier__c);

        // 食器洗い乾燥機
        result += createReturnMessage(PropertyConditions__c.IsDishwasher__c.getDescribe().getLabel(), beforePropertyConditions.IsDishwasher__c
                                    , afterPropertyConditions.IsDishwasher__c);

        // ディスポーザー
        result += createReturnMessage(PropertyConditions__c.IsDisposer__c.getDescribe().getLabel(), beforePropertyConditions.IsDisposer__c
                                    , afterPropertyConditions.IsDisposer__c);

        // バス・トイレ別
        result += createReturnMessage(PropertyConditions__c.IsSeparate__c.getDescribe().getLabel(), beforePropertyConditions.IsSeparate__c
                                    , afterPropertyConditions.IsSeparate__c);

        // 追焚機能
        result += createReturnMessage(PropertyConditions__c.IsReheating__c.getDescribe().getLabel(), beforePropertyConditions.IsReheating__c
                                    , afterPropertyConditions.IsReheating__c);

        // 高温差湯式
        result += createReturnMessage(PropertyConditions__c.IsHotWaterFormula__c.getDescribe().getLabel(), beforePropertyConditions.IsHotWaterFormula__c
                                    , afterPropertyConditions.IsHotWaterFormula__c);

        // 浴室乾燥機
        result += createReturnMessage(PropertyConditions__c.IsBathroomDryer__c.getDescribe().getLabel(), beforePropertyConditions.IsBathroomDryer__c
                                    , afterPropertyConditions.IsBathroomDryer__c);

        // 浴室床暖房
        result += createReturnMessage(PropertyConditions__c.IsBathroomFloorHeating__c.getDescribe().getLabel(), beforePropertyConditions.IsBathroomFloorHeating__c
                                    , afterPropertyConditions.IsBathroomFloorHeating__c);
        
        // TV付浴槽
        result += createReturnMessage(PropertyConditions__c.IsTvBath__c.getDescribe().getLabel(), beforePropertyConditions.IsTvBath__c
                                    , afterPropertyConditions.IsTvBath__c);

        // 温水洗浄便座
        result += createReturnMessage(PropertyConditions__c.IsWashletToiletSeat__c.getDescribe().getLabel(), beforePropertyConditions.IsWashletToiletSeat__c
                                    , afterPropertyConditions.IsWashletToiletSeat__c);

        // タンクレストイレ
        result += createReturnMessage(PropertyConditions__c.IsTanklessToilet__c.getDescribe().getLabel(), beforePropertyConditions.IsTanklessToilet__c
                                    , afterPropertyConditions.IsTanklessToilet__c);

        // 洗面所独立
        result += createReturnMessage(PropertyConditions__c.IsWashroomDscrete__c.getDescribe().getLabel(), beforePropertyConditions.IsWashroomDscrete__c
                                    , afterPropertyConditions.IsWashroomDscrete__c);

        // シャワー付き洗面台
        result += createReturnMessage(PropertyConditions__c.IsShowerWashBasin__c.getDescribe().getLabel(), beforePropertyConditions.IsShowerWashBasin__c
                                    , afterPropertyConditions.IsShowerWashBasin__c);

        // シャワールーム
        result += createReturnMessage(PropertyConditions__c.IsShowerRoom__c.getDescribe().getLabel(), beforePropertyConditions.IsShowerRoom__c
                                    , afterPropertyConditions.IsShowerRoom__c);

        // ミストサウナ
        result += createReturnMessage(PropertyConditions__c.IsMistSauna__c.getDescribe().getLabel(), beforePropertyConditions.IsMistSauna__c
                                    , afterPropertyConditions.IsMistSauna__c);

        // 室内洗濯機置場
        result += createReturnMessage(PropertyConditions__c.IsIndoorWashingMachineStorage__c.getDescribe().getLabel(), beforePropertyConditions.IsIndoorWashingMachineStorage__c
                                    , afterPropertyConditions.IsIndoorWashingMachineStorage__c);

        // 都市ガス
        result += createReturnMessage(PropertyConditions__c.IsCityGas__c.getDescribe().getLabel(), beforePropertyConditions.IsCityGas__c
                                    , afterPropertyConditions.IsCityGas__c);

        // プロパンガス
        result += createReturnMessage(PropertyConditions__c.IsPropaneGas__c.getDescribe().getLabel(), beforePropertyConditions.IsPropaneGas__c
                                    , afterPropertyConditions.IsPropaneGas__c);

        // オール電化
        result += createReturnMessage(PropertyConditions__c.IsAllElectric__c.getDescribe().getLabel(), beforePropertyConditions.IsAllElectric__c
                                    , afterPropertyConditions.IsAllElectric__c);

        // エアコン
        result += createReturnMessage(PropertyConditions__c.IsAirConditioner__c.getDescribe().getLabel(), beforePropertyConditions.IsAirConditioner__c
                                    , afterPropertyConditions.IsAirConditioner__c);

        // 床暖房
        result += createReturnMessage(PropertyConditions__c.IsFloorHeating__c.getDescribe().getLabel(), beforePropertyConditions.IsFloorHeating__c
                                    , afterPropertyConditions.IsFloorHeating__c);

        // ガス暖房
        result += createReturnMessage(PropertyConditions__c.IsGasHeating__c.getDescribe().getLabel(), beforePropertyConditions.IsGasHeating__c
                                    , afterPropertyConditions.IsGasHeating__c);

        // 灯油暖房
        result += createReturnMessage(PropertyConditions__c.IsKeroseneHeating__c.getDescribe().getLabel(), beforePropertyConditions.IsKeroseneHeating__c
                                    , afterPropertyConditions.IsKeroseneHeating__c);

        // 家具付き
        result += createReturnMessage(PropertyConditions__c.IsFurniture__c.getDescribe().getLabel(), beforePropertyConditions.IsFurniture__c
                                    , afterPropertyConditions.IsFurniture__c);

        // 家電付き
        result += createReturnMessage(PropertyConditions__c.IsHomeAppliance__c.getDescribe().getLabel(), beforePropertyConditions.IsHomeAppliance__c
                                    , afterPropertyConditions.IsHomeAppliance__c);

        // 洗濯乾燥機
        result += createReturnMessage(PropertyConditions__c.IsWashingDryer__c.getDescribe().getLabel(), beforePropertyConditions.IsWashingDryer__c
                                    , afterPropertyConditions.IsWashingDryer__c);

        // フローリング
        result += createReturnMessage(PropertyConditions__c.IsFlooring__c.getDescribe().getLabel(), beforePropertyConditions.IsFlooring__c
                                    , afterPropertyConditions.IsFlooring__c);

        // クッションフロア
        result += createReturnMessage(PropertyConditions__c.IsCushionFloor__c.getDescribe().getLabel(), beforePropertyConditions.IsCushionFloor__c
                                    , afterPropertyConditions.IsCushionFloor__c);

        // 無垢材使用
        result += createReturnMessage(PropertyConditions__c.IsSolidWood__c.getDescribe().getLabel(), beforePropertyConditions.IsSolidWood__c
                                    , afterPropertyConditions.IsSolidWood__c);

        // 雨戸
        result += createReturnMessage(PropertyConditions__c.IsStormShutter__c.getDescribe().getLabel(), beforePropertyConditions.IsStormShutter__c
                                    , afterPropertyConditions.IsStormShutter__c);

        // シャッター
        result += createReturnMessage(PropertyConditions__c.IsShutter__c.getDescribe().getLabel(), beforePropertyConditions.IsShutter__c
                                    , afterPropertyConditions.IsShutter__c);

        // 電動シャッター
        result += createReturnMessage(PropertyConditions__c.IsElectricShutter__c.getDescribe().getLabel(), beforePropertyConditions.IsElectricShutter__c
                                    , afterPropertyConditions.IsElectricShutter__c);

        // ハイサッシ
        result += createReturnMessage(PropertyConditions__c.IsHighSash__c.getDescribe().getLabel(), beforePropertyConditions.IsHighSash__c
                                    , afterPropertyConditions.IsHighSash__c);

        // 防音サッシ
        result += createReturnMessage(PropertyConditions__c.IsSoundproofSash__c.getDescribe().getLabel(), beforePropertyConditions.IsSoundproofSash__c
                                    , afterPropertyConditions.IsSoundproofSash__c);

        // 複層ガラス
        result += createReturnMessage(PropertyConditions__c.IsPairGlass__c.getDescribe().getLabel(), beforePropertyConditions.IsPairGlass__c
                                    , afterPropertyConditions.IsPairGlass__c);

        // シューズボックス
        result += createReturnMessage(PropertyConditions__c.IsShoesBox__c.getDescribe().getLabel(), beforePropertyConditions.IsShoesBox__c
                                    , afterPropertyConditions.IsShoesBox__c);

        // シューズクローク
        result += createReturnMessage(PropertyConditions__c.IsShoeCloak__c.getDescribe().getLabel(), beforePropertyConditions.IsShoeCloak__c
                                    , afterPropertyConditions.IsShoeCloak__c);

        // ウォークインクローゼット
        result += createReturnMessage(PropertyConditions__c.IsWalkInCloset__c.getDescribe().getLabel(), beforePropertyConditions.IsWalkInCloset__c
                                    , afterPropertyConditions.IsWalkInCloset__c);

        // トランクルーム
        result += createReturnMessage(PropertyConditions__c.IsTrunkRoom__c.getDescribe().getLabel(), beforePropertyConditions.IsTrunkRoom__c
                                    , afterPropertyConditions.IsTrunkRoom__c);

        // 床下収納
        result += createReturnMessage(PropertyConditions__c.IsUnderfloorStorage__c.getDescribe().getLabel(), beforePropertyConditions.IsUnderfloorStorage__c
                                    , afterPropertyConditions.IsUnderfloorStorage__c);

        // BSアンテナ
        result += createReturnMessage(PropertyConditions__c.IsBSAntenna__c.getDescribe().getLabel(), beforePropertyConditions.IsBSAntenna__c
                                    , afterPropertyConditions.IsBSAntenna__c);

        // CSアンテナ
        result += createReturnMessage(PropertyConditions__c.IsCSAntenna__c.getDescribe().getLabel(), beforePropertyConditions.IsCSAntenna__c
                                    , afterPropertyConditions.IsCSAntenna__c);

        // CATV
        result += createReturnMessage(PropertyConditions__c.IsCATV__c.getDescribe().getLabel(), beforePropertyConditions.IsCATV__c
                                    , afterPropertyConditions.IsCATV__c);

        // CATVインターネット
        result += createReturnMessage(PropertyConditions__c.IsCATVInternet__c.getDescribe().getLabel(), beforePropertyConditions.IsCATVInternet__c
                                    , afterPropertyConditions.IsCATVInternet__c);

        // CATV使用料不要
        result += createReturnMessage(PropertyConditions__c.IsCATVFree__c.getDescribe().getLabel(), beforePropertyConditions.IsCATVFree__c
                                    , afterPropertyConditions.IsCATVFree__c);

        // 光ファイバー
        result += createReturnMessage(PropertyConditions__c.IsOpticalFiber__c.getDescribe().getLabel(), beforePropertyConditions.IsOpticalFiber__c
                                    , afterPropertyConditions.IsOpticalFiber__c);

        // ネット使用料無料
        result += createReturnMessage(PropertyConditions__c.IsInternetFree__c.getDescribe().getLabel(), beforePropertyConditions.IsInternetFree__c
                                    , afterPropertyConditions.IsInternetFree__c);

        // モニター付きインターホン
        result += createReturnMessage(PropertyConditions__c.IsMonitorIntercom__c.getDescribe().getLabel(), beforePropertyConditions.IsMonitorIntercom__c
                                    , afterPropertyConditions.IsMonitorIntercom__c);

        // オートロック
        result += createReturnMessage(PropertyConditions__c.IsAutoLock__c.getDescribe().getLabel(), beforePropertyConditions.IsAutoLock__c
                                    , afterPropertyConditions.IsAutoLock__c);

        // ディンプルキー
        result += createReturnMessage(PropertyConditions__c.IsDimpleKey__c.getDescribe().getLabel(), beforePropertyConditions.IsDimpleKey__c
                                    , afterPropertyConditions.IsDimpleKey__c);

        // 防犯カメラ
        result += createReturnMessage(PropertyConditions__c.IsSurveillanceCamera__c.getDescribe().getLabel(), beforePropertyConditions.IsSurveillanceCamera__c
                                    , afterPropertyConditions.IsSurveillanceCamera__c);

        // 防犯ガラス
        result += createReturnMessage(PropertyConditions__c.IsSecurityGlass__c.getDescribe().getLabel(), beforePropertyConditions.IsSecurityGlass__c
                                    , afterPropertyConditions.IsSecurityGlass__c);

        // 24時間セキュリティ
        result += createReturnMessage(PropertyConditions__c.IsAnytimeSecurity__c.getDescribe().getLabel(), beforePropertyConditions.IsAnytimeSecurity__c
                                    , afterPropertyConditions.IsAnytimeSecurity__c);

        // セキュリティ会社加入済
        result += createReturnMessage(PropertyConditions__c.IsSecurityCompanyJoin__c.getDescribe().getLabel(), beforePropertyConditions.IsSecurityCompanyJoin__c
                                    , afterPropertyConditions.IsSecurityCompanyJoin__c);

        // 保証人不要
        result += createReturnMessage(PropertyConditions__c.IsNoGuarantor__c.getDescribe().getLabel(), beforePropertyConditions.IsNoGuarantor__c
                                    , afterPropertyConditions.IsNoGuarantor__c);

        // 楽器相談可
        result += createReturnMessage(PropertyConditions__c.IsMusicalInstruments__c.getDescribe().getLabel(), beforePropertyConditions.IsMusicalInstruments__c
                                    , afterPropertyConditions.IsMusicalInstruments__c);

        // 外国人契約可
        result += createReturnMessage(PropertyConditions__c.IsForeigner__c.getDescribe().getLabel(), beforePropertyConditions.IsForeigner__c
                                    , afterPropertyConditions.IsForeigner__c);

        // 生活保護契約可
        result += createReturnMessage(PropertyConditions__c.IsWelfareAvailable__c.getDescribe().getLabel(), beforePropertyConditions.IsWelfareAvailable__c
                                    , afterPropertyConditions.IsWelfareAvailable__c);

        // 事務所利用可
        result += createReturnMessage(PropertyConditions__c.IsOfficeAvailable__c.getDescribe().getLabel(), beforePropertyConditions.IsOfficeAvailable__c
                                    , afterPropertyConditions.IsOfficeAvailable__c);

        // ペット可
        result += createReturnMessage(PropertyConditions__c.IsPet__c.getDescribe().getLabel(), beforePropertyConditions.IsPet__c
                                    , afterPropertyConditions.IsPet__c);

        // ペット(小型犬)
        result += createReturnMessage(PropertyConditions__c.IsSmallPet__c.getDescribe().getLabel(), beforePropertyConditions.IsSmallPet__c
                                    , afterPropertyConditions.IsSmallPet__c);

        // ペット(中型犬)
        result += createReturnMessage(PropertyConditions__c.IsMiddlePet__c.getDescribe().getLabel(), beforePropertyConditions.IsMiddlePet__c
                                    , afterPropertyConditions.IsMiddlePet__c);

        // ペット(大型犬)
        result += createReturnMessage(PropertyConditions__c.IsLargePet__c.getDescribe().getLabel(), beforePropertyConditions.IsLargePet__c
                                    , afterPropertyConditions.IsLargePet__c);

        // ペット(猫)
        result += createReturnMessage(PropertyConditions__c.IsCat__c.getDescribe().getLabel(), beforePropertyConditions.IsCat__c
                                    , afterPropertyConditions.IsCat__c);

        // ペット(その他)
        result += createReturnMessage(PropertyConditions__c.IsOtherPet__c.getDescribe().getLabel(), beforePropertyConditions.IsOtherPet__c
                                    , afterPropertyConditions.IsOtherPet__c);

        // 2人入居可
        result += createReturnMessage(PropertyConditions__c.IsTwoTenant__c.getDescribe().getLabel(), beforePropertyConditions.IsTwoTenant__c
                                    , afterPropertyConditions.IsTwoTenant__c);

        // ルームシェア可
        result += createReturnMessage(PropertyConditions__c.IsRoomShare__c.getDescribe().getLabel(), beforePropertyConditions.IsRoomShare__c
                                    , afterPropertyConditions.IsRoomShare__c);

        // マンスリー可
        result += createReturnMessage(PropertyConditions__c.IsMonthly__c.getDescribe().getLabel(), beforePropertyConditions.IsMonthly__c
                                    , afterPropertyConditions.IsMonthly__c);

        // カスタマイズ可
        result += createReturnMessage(PropertyConditions__c.IsCustomize__c.getDescribe().getLabel(), beforePropertyConditions.IsCustomize__c
                                    , afterPropertyConditions.IsCustomize__c);

        // DIY可
        result += createReturnMessage(PropertyConditions__c.IsDIY__c.getDescribe().getLabel(), beforePropertyConditions.IsDIY__c
                                    , afterPropertyConditions.IsDIY__c);

        // IT重説対応物件
        result += createReturnMessage(PropertyConditions__c.IsITImportantDescription__c.getDescribe().getLabel(), beforePropertyConditions.IsITImportantDescription__c
                                    , afterPropertyConditions.IsITImportantDescription__c);

        // 家賃カード決済可
        result += createReturnMessage(PropertyConditions__c.IsRentCreditPayment__c.getDescribe().getLabel(), beforePropertyConditions.IsRentCreditPayment__c
                                    , afterPropertyConditions.IsRentCreditPayment__c);

        // 初期費用カード決済可
        result += createReturnMessage(PropertyConditions__c.IsInitialCostCreditPayment__c.getDescribe().getLabel(), beforePropertyConditions.IsInitialCostCreditPayment__c
                                    , afterPropertyConditions.IsInitialCostCreditPayment__c);

        // 女性限定
        result += createReturnMessage(PropertyConditions__c.IsWoman__c.getDescribe().getLabel(), beforePropertyConditions.IsWoman__c
                                    , afterPropertyConditions.IsWoman__c);

        // 学生限定
        result += createReturnMessage(PropertyConditions__c.IsStudent__c.getDescribe().getLabel(), beforePropertyConditions.IsStudent__c
                                    , afterPropertyConditions.IsStudent__c);

        // 法人契約限定
        result += createReturnMessage(PropertyConditions__c.IsCorporation__c.getDescribe().getLabel(), beforePropertyConditions.IsCorporation__c
                                    , afterPropertyConditions.IsCorporation__c);

        // 高齢者歓迎
        result += createReturnMessage(PropertyConditions__c.IsElderly__c.getDescribe().getLabel(), beforePropertyConditions.IsElderly__c
                                    , afterPropertyConditions.IsElderly__c);

        // LGBTフレンドリー
        result += createReturnMessage(PropertyConditions__c.IsLbgt__c.getDescribe().getLabel(), beforePropertyConditions.IsLbgt__c
                                    , afterPropertyConditions.IsLbgt__c);

        // 子供不可
        result += createReturnMessage(PropertyConditions__c.IsNotChild__c.getDescribe().getLabel(), beforePropertyConditions.IsNotChild__c
                                    , afterPropertyConditions.IsNotChild__c);

        // ペット(その他)備考
        result += createReturnMessageItemNameChange(PropertyConditions__c.PetRemarks__c.getDescribe().getLabel(), beforePropertyConditions.PetRemarks__c
                                    , afterPropertyConditions.PetRemarks__c);

        // 設備備考(公開)
        result += createReturnMessageItemNameChange(PropertyConditions__c.FacilityRemarksPublic__c.getDescribe().getLabel(), beforePropertyConditions.FacilityRemarksPublic__c
                                                    , afterPropertyConditions.FacilityRemarksPublic__c);

        return result;
    }

    /**
     * 物件に紐づく管理会社指定商品の取得
     * @param Set<Id> propertyIdSet 物件.Id
     * @return Map<Id, List<ManagementCompanyItem__c>> key:物件.Id、value:管理会社指定商品
     */
    private static Map<Id, List<ManagementCompanyItem__c>> getPropsManaCorpItem(Set<Id> propertyIdSet) {

        // 管理会社指定商品情報
        ManagementCompanyItem__c                manaCorpItem;             // エンティティ
        List<ManagementCompanyItem__c>          mapValueManaCorpItemList; // マップvalue値
        Map<Id, List<ManagementCompanyItem__c>> propsManaCorpItemMap;     // key:物件.Id、value:管理会社指定商品

        // 物件管理会社指定商品の取得
        List<PropertyManageCompayItem__c> propManaCorpItemList = selectPropManaCorpItem(propertyIdSet);

        // 物件に紐づく管理会社指定商品の取得
        propsManaCorpItemMap = new Map<Id, List<ManagementCompanyItem__c>>();
        for (PropertyManageCompayItem__c propManaCorpItem : propManaCorpItemList) {

            // valueの初期化
            if (!propsManaCorpItemMap.containsKey(propManaCorpItem.Property__c)) {
                propsManaCorpItemMap.put(propManaCorpItem.Property__c, new List<ManagementCompanyItem__c>());
            }

            // 管理会社指定商品の設定と金額(税込)の計算
            manaCorpItem = new ManagementCompanyItem__c(
                PaymentType__c = propManaCorpItem.Item__r.PaymentType__c
                , TaxType__c   = propManaCorpItem.Item__r.TaxType__c
                , Amount__c    = propManaCorpItem.Item__r.Amount__c
            );
            manaCorpItem.recalculateFormulas();

            // 物件に紐づく管理会社指定商品を追加
            mapValueManaCorpItemList = propsManaCorpItemMap.get(propManaCorpItem.Property__c);
            mapValueManaCorpItemList.add(manaCorpItem);
            propsManaCorpItemMap.put(propManaCorpItem.Property__c, mapValueManaCorpItemList);
        }

        return propsManaCorpItemMap;
    }

    /**
     * 物件の取得
     * @param Set<Id> condIdSet 物件.Id
     * @return Map<Id, Property__c> key:物件.Id、value:物件
     */
    private static Map<Id, Property__c> selectProperty(Set<Id> condIdSet) {

        // 物件の取得
        List<Property__c> propertyList;
        propertyList = [SELECT Id
                               , AllRentFee__c                    // 総賃料
                               , RentFee__c                       // 賃料
                               , WortFeeTax__c                    // 水道料金（税込）
                               , ManagementFeeTax__c              // 管理費（税込）
                               , CATVFeeTax__c                    // CATV（税込）
                               , TownshipFeePaymentType__c        // 町内会費支払区分
                               , TownshipFeeTax__c                // 町会費（税込）
                               , GarbageDisposalFeePaymentType__c // ごみ処理費支払区分
                               , GarbageDisposalFeeTax__c         // ごみ処理費（税込）
                               , BicycleParkingFeeTax__c          // 駐輪場料金（税込）
                               , ParkingType__c                   // 駐車場種別
                               , ParkingFeeTax__c                 // 駐車場料金（税込）
                               , FireInsuranceUseType__c          // 火災保険加入義務
                               , FireInsurancePlan__c             // 火災保険タイトル
                               , GuaranteeidCompanyType__c        // 保証会社利用区分
                               , Guaranteeid__c                   // 保証タイトル
                        FROM Property__c
                        WHERE Id = :condIdSet];
        
        // 初期化処理
        Map<Id, Property__c> propertyMap = new Map<Id, Property__c>();
        if (!propertyList.isEmpty()) {
            propertyMap = new Map<Id, Property__c>(propertyList);
        }

        return propertyMap;
    }

    /**
     * 物件管理会社指定商品の取得
     * @param Set<Id> condPropIdSet 物件.Id
     * @return List<PropertyManageCompayItem__c> 物件管理会社指定商品
     */
    private static List<PropertyManageCompayItem__c> selectPropManaCorpItem(Set<Id> condPropIdSet) {

        // 物件管理会社指定商品の取得
        List<PropertyManageCompayItem__c> propManaCorpItemList;
        propManaCorpItemList = [SELECT Id
                                       , Property__c            // 物件
                                       , Item__r.PaymentType__c // 管理会社指定プラン.支払区分
                                       , Item__r.AmountTax__c   // 管理会社指定プラン.金額(税込)
                                       , Item__r.TaxType__c     // 管理会社指定プラン.税区分
                                       , Item__r.Amount__c      // 管理会社指定プラン.金額
                                FROM PropertyManageCompayItem__c
                                WHERE Property__c = :condPropIdSet];

        // 初期化処理
        if (propManaCorpItemList.isEmpty()) {
            propManaCorpItemList = new List<PropertyManageCompayItem__c>();
        }

        return propManaCorpItemList;
    }

    /**
     * 火災保険会社の商品（カスタム）の取得
     * @param Set<Id> condIdSet 商品（カスタム）.Id
     * @return Map<Id, Item__c> key:商品（カスタム）.Id、value:商品（カスタム）
     */
    private static Map<Id, Item__c> selectItemFireInsurance(Set<Id> condIdSet) {

        // 商品（カスタム）の取得
        List<Item__c> itemFireInsuranceList;
        itemFireInsuranceList = [SELECT Id         
                                        , PaymentType__c        // 更新期間
                                        , FireInsuranceMonth__c // 火災保険料(月額)                 
                                 FROM Item__c
                                 WHERE Id = :condIdSet];

        // 初期化処理
        Map<Id, Item__c> itemFireInsuranceMap = new Map<Id, Item__c>();
        if (!itemFireInsuranceList.isEmpty()) {
            itemFireInsuranceMap = new Map<Id, Item__c>(itemFireInsuranceList);
        }

        return itemFireInsuranceMap;
    }

    /**
     * 保証会社の商品（カスタム）の取得
     * @param Set<Id> condIdSet 商品（カスタム）.Id
     * @return Map<Id, Item__c> key:商品（カスタム）.Id、value:商品（カスタム）
     */
    private static Map<Id, Item__c> selectItemDeposit(Set<Id> condIdSet) {

        // 商品（カスタム）の取得
        List<Item__c> itemDepositList;
        itemDepositList = [SELECT Id
                                  , ItemName__c                    // 商品名
                                  , Account__r.IsAllRentFeeType__c // 取引先.総賃料区分
                                  , DirectDebitFeeTaxType__c       // 手数料税区分
                                  , DirectDebitFee__c              // 手数料
                                  , DirectDebitFeeTax__c           // 手数料(税込)
                                  , (SELECT DepositRate__c         // 商品明細.保証料(割合)
                                            , DepositYen__c        // 商品明細.保証料(金額)
                                            , IsRentFeeType__c     // 商品明細.賃料区分
                                     FROM ItemDetailItem__r
                                     LIMIT 1)
                           FROM Item__c
                           WHERE Id = :condIdSet];

        // 初期化処理
        Map<Id, Item__c> itemDepositMap = new Map<Id, Item__c>();
        if (!itemDepositList.isEmpty()) {
            itemDepositMap = new Map<Id, Item__c>(itemDepositList);
        }

        return itemDepositMap;
    }
}