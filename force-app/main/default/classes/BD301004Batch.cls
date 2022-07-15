global with sharing class BD301004Batch implements Database.Batchable<PortalSitePostingProperty__c>, Database.Stateful{

    //更新条件
    private Id condFormerSupplier{ get; set; } //更新対象の元付業者

    //更新値
    private Boolean updIsDispSuumo{ get; set; }     //SUUMO掲載フラグ
    private Boolean updIsDispHomes{ get; set; }     //HOME'S掲載フラグ
    private Boolean updIsDispAtHome{ get; set; }    //at home掲載フラグ
    private Boolean updIsDispChintai{ get; set; }   //CHINTAI掲載フラグ　2022.04.06 CHINTAI対応追加
    private Boolean updIsDispOurHp{ get; set; }     //自社ポータル掲載フラグ

    //変更フラグ
    private Boolean isChgSuumo{ get; set; }     //SUUMO
    private Boolean isChgHomes{ get; set; }     //HOME'S
    private Boolean isChgAtHome{ get; set; }    //at home
    private Boolean isChgChintai{ get; set; }   //CHINTAI　2022.04.06 CHINTAI対応追加
    private Boolean isChgOurHp{ get; set; }     //自社ポータル掲載

    //処理結果
    private Boolean isErrResult{ get; set; }  //エラー
    private string accountName{ get; set; }   //業者名

    //コンストラクタ
    global BD301004Batch(id formerSupplier, Boolean isDispSuumo, Boolean isDispHomes, Boolean isDispAtHome, Boolean isDispOurHp
						,string fromName, Boolean isChgSuumo ,Boolean isChgHomes, Boolean isChgAtHome, Boolean isChgOurHp) {
                            // ▼ 2022.05.17 CHINTAI対応にて追加
                            this(formerSupplier,  isDispSuumo,  isDispHomes,  isDispAtHome, false, isDispOurHp
								,fromName,  isChgSuumo , isChgHomes, isChgAtHome, false, isChgOurHp);
                            // ▲ 2022.05.17 CHINTAI対応にて追加
	}
    // 2022.05.17 CHINTAI対応にてパッケージ環境でグローバルのメソッド名や引数、返り値の情報を変更できないため追加 
    global BD301004Batch(id formerSupplier, Boolean isDispSuumo, Boolean isDispHomes, Boolean isDispAtHome, Boolean isDispChintai, Boolean isDispOurHp
						, string fromName, Boolean isChgSuumo ,Boolean isChgHomes, Boolean isChgAtHome, Boolean isChgChintai, Boolean isChgOurHp) {
 
        //更新条件を設定
        this.condFormerSupplier = formerSupplier;

        //更新値を設定
        this.updIsDispSuumo = isDispSuumo;
        this.updIsDispHomes = isDispHomes;
        this.updIsDispAtHome = isDispAtHome;
        this.updIsDispChintai = isDispChintai;  // 2022.04.06 CHINTAI対応追加
        this.updIsDispOurHp = isDispOurHp;

        //送信元を設定
        this.accountName = fromName;

        //変更フラグを設定
        this.isChgSuumo = isChgSuumo;
        this.isChgHomes = isChgHomes;
        this.isChgAtHome = isChgAtHome;
        this.isChgChintai = isChgChintai;   // 2022.04.06 CHINTAI対応追加
        this.isChgOurHp = isChgOurHp;

        //初期値設定
        this.isErrResult = false;
    }

    //データ取得
    global Iterable<PortalSitePostingProperty__c> start(Database.BatchableContext BC) {

        // 既存ポータルサイト掲載物件の取得（更新・削除）
        String soql = '';
        soql += 'SELECT IsAtHome__c ';
        soql += '       , IsHomes__c ';
        soql += '       , IsSuumo__c ';
        soql += '       , IsChintaiNet__c ';    // 2022.04.06 CHINTAI対応追加
        soql += '       , IsChintaiPanoramaPosting__c ';    // 2022.04.06 CHINTAI対応追加
        soql += '       , IsPortal__c ';
        soql += '       , Shop__c ';
        soql += 'FROM PortalSitePostingProperty__c ';
        soql += 'WHERE Property__r.FormerSupplier__c = \'' + this.condFormerSupplier + '\'';
        List<PortalSitePostingProperty__c> targetList = Database.query(soql);

        // 新規ポータルサイト掲載物件の取得（登録）
        if (this.updIsDispOurHp) {
            targetList.addAll(GetRegistPortalSitePostingPropertyList(this.condFormerSupplier));
        }
        return targetList;    
    }
        
    //開始
    global void execute(Database.BatchableContext BC, List<PortalSitePostingProperty__c> targetList){

        List<PortalSitePostingProperty__c> updList = new List<PortalSitePostingProperty__c>();
        List<PortalSitePostingProperty__c> delList = new List<PortalSitePostingProperty__c>();
            
        //再販対応 追加 Start
        Boolean isOpetionPortal = SystemConfig__c.getInstance().UseAuthority_Portal__c;//ポータル権限取得
        //再販対応 追加 End
        
        //DML処理
        for (PortalSitePostingProperty__c portalSitePostingProperty : targetList) {
            if (portalSitePostingProperty.Id == null) {
                //登録処理
                this.SetRegistPortalSitePostingProperty(portalSitePostingProperty);
                updList.Add(portalSitePostingProperty);
            } else {
                //更新処理
                //SUUMO掲載フラグ
                if (this.isChgSuumo && !this.updIsDispSuumo) {
                    portalSitePostingProperty.IsSuumo__c = this.updIsDispSuumo;
                }

                //HOME'S掲載フラグ
                if (this.isChgHomes && !this.updIsDispHomes) {
                    portalSitePostingProperty.IsHomes__c = this.updIsDispHomes;
                }

                //at home掲載フラグ
                if (this.isChgAtHome && !this.updIsDispAtHome) {
                    portalSitePostingProperty.IsAtHome__c = this.updIsDispAtHome;
                }

                // ▼ 2022.04.06 CHINTAI対応追加
                if (this.isChgChintai && !this.updIsDispChintai) {
                    portalSitePostingProperty.IsChintaiNet__c = this.updIsDispChintai;
                    portalSitePostingProperty.IsChintaiPanoramaPosting__c = false;
                }
				// ▲ 2022.04.06 CHINTAI対応追加

                //自社ポータル掲載フラグ
                //再販対応 変更 Start
                if (isOpetionPortal){
                if (this.isChgOurHp) {
                    portalSitePostingProperty.IsPortal__c = this.updIsDispOurHp;
                }
                }else{//自社HP権限がなけれればfalseに設定
                    portalSitePostingProperty.IsPortal__c = false;
                }
                //再販対応 変更 End

                //更新・削除の分別
                if (portalSitePostingProperty.IsSuumo__c ||
                    portalSitePostingProperty.IsHomes__c ||
                    portalSitePostingProperty.IsAtHome__c ||
                    portalSitePostingProperty.IsChintaiNet__c ||	// 2022.04.06 CHINTAI対応追加
                    portalSitePostingProperty.IsPortal__c) {
                    //掲載サイト有
                    updList.Add(portalSitePostingProperty);
                }
                else {
                    //掲載サイト無
                    delList.Add(portalSitePostingProperty);
                }
            }
        }

        // DML実施
        Savepoint sp = Database.setSavepoint();
        try {
            // 登録・更新
            if (updList.size() > 0) {
                SecureDML.secureUpsert(updList);
            }
            
            // 削除
            if (delList.size() > 0) {
                SecureDML.secureDelete(delList);
            }

        } catch (Exception e) {
            isErrResult = true;
            Database.rollback(sp);
        }
    }
        
    //終了
    global void finish(Database.BatchableContext BC) {

        //メール送信確認
        if (isErrResult) {
            return;
        }
        
        //店舗情報取得
        Shop__c shop = CommonUtil.getStaffCurrentShop();

        //送信メール設定
        List<MailUtil.MailData> mailList = new List<MailUtil.MailData>();
        MailUtil.MailData mailData = new MailUtil.MailData();
        mailData.toAddress      = new List<string> {shop.Email__c};
        mailData.ccAddress      = null;
        mailData.fromAddress    = null;
        mailData.subject        = CommonUtil.callMessageCreate(CommonConst.MSG_ACC_I_TRADER_REGIST_MAIL_SUBJECT);
        mailData.textBody       = CommonUtil.callMessageCreate(CommonConst.MSG_ACC_I_TRADER_REGIST_MAIL_TEXT_BODY, this.accountName);

        mailList.add(mailData);

        //メール送信
        List<Messaging.SendEmailResult> resultList = MailUtil.sendMail(mailList);
    }

    // ポータルサイト掲載物件の登録情報を設定
    private void SetRegistPortalSitePostingProperty(PortalSitePostingProperty__c portalSitePostingProperty) {
        portalSitePostingProperty.IsSuumo__c = false;
        portalSitePostingProperty.IsHomes__c = false;
        portalSitePostingProperty.IsAtHome__c = false;
        portalSitePostingProperty.IsChintaiNet__c = false; // 2022.04.06 CHINTAI対応追加
        portalSitePostingProperty.IsChintaiPanoramaPosting__c = false; // 2022.04.06 CHINTAI対応追加
        portalSitePostingProperty.IsPortal__c = true;
    }

    // ポータルサイト掲載物件の登録情報を取得
    private List<PortalSitePostingProperty__c> GetRegistPortalSitePostingPropertyList(String condFormerSupplier) {
        
        // 返却値
        List<PortalSitePostingProperty__c> result = new List<PortalSitePostingProperty__c>();
        
        // クエリ用パラメータ
        String      PROPERTY_WEBPUBLISHING_EXISTS = CommonConst.PROPERTY_WEBPUBLISHING_EXISTS;
        String      PROPERTY_FORMER_SUPPLIER      = condFormerSupplier;
        Set<String> PROPERTY_LIVESTATUS           = new Set<String> {CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE
                                                                     , CommonConst.PROPERTY_LIVESTATUS_VACANCY};
            
        // 物件の取得
        Map<Id,Property__c> propertyMap = new Map<Id,Property__c>([SELECT Id
                                                                          , Building__r.District__c // 地区
                                                                          , RentFee__c              // 賃料
                                                                   FROM Property__c
                                                                   WHERE FormerSupplier__c = :PROPERTY_FORMER_SUPPLIER
                                                                         AND WebPublishing__c = :PROPERTY_WEBPUBLISHING_EXISTS
                                                                         AND LiveStatus__c IN :PROPERTY_LIVESTATUS]);
        
        // 物件・店舗情報の作成
        List<Shop__c> shopList = [SELECT Id, PortalSitePostingDistrict__c FROM Shop__c WHERE PortalSitePostingDistrict__c != null];
        
        Map<Id, List<Id>> properyShopMap = new Map<Id, List<Id>>();
        for(Id propertyId : propertyMap.keyset()){
            properyShopMap.put(propertyId, new List<Id>());
        
            for (Shop__c shop : shopList){
                if(shop.PortalSitePostingDistrict__c.split(';').contains(propertyMap.get(propertyId).Building__r.District__c)){
                    properyShopMap.get(propertyId).add(shop.Id);
                }
            }
        }
        
        // 既存のポータル連携物件を取得
        Set<Id> propertyIdSet = propertyMap.keySet();
        List<PortalSitePostingProperty__c> portalSitePropertyList = [SELECT Shop__c
                                                                            , Property__c
                                                                     FROM PortalSitePostingProperty__c 
                                                                     WHERE Property__c IN :propertyIdSet];
        
        // ポータル連携物件情報が存在する場合は登録対象から削除
        List<Id> shopIdList = new List<Id>();
        Integer index = 0;
        for (PortalSitePostingProperty__c portalSiteProperty : portalSitePropertyList) {
        
            shopIdList = properyShopMap.get(portalSiteProperty.Property__c);
        
            // 店舗のポータル連携物件存在チェック
            if (shopIdList.contains(portalSiteProperty.Shop__c) ) {
                index = shopIdList.indexOf(portalSiteProperty.Shop__c);
                shopIdList.remove(index);
            }
        }
        
        // 地区別メンテナンス条件情報の作成
        List<AreaMaintenanceCondition__c> areaMaintenanceList = [SELECT PropertyAmountLowerLimit__c   // 取扱い物件 金額(下限)
                                                                        , PropertyAmountUpperLimit__c // 取扱い物件 金額(上限)
                                                                        , District__c                 // 地区
                                                                 FROM AreaMaintenanceCondition__c];

        Map<String, AreaMaintenanceCondition__c> areaMaintenanceMap = new Map<String, AreaMaintenanceCondition__c>();
        for (AreaMaintenanceCondition__c area : areaMaintenanceList) {
            areaMaintenanceMap.put(area.District__c, area);
        }
        
        // 地区別メンテナンス条件の金額上限内の物件を取得
        List<Property__c> targetList = new List<Property__c>();
        AreaMaintenanceCondition__c areaMaintenanceCondition = new AreaMaintenanceCondition__c();
        for(Property__c target : propertyMap.values()){
        
            String district = propertyMap.get(target.Id).Building__r.District__c;
        
            // 地区存在チェック
            if (String.isBlank(district)) {
                continue;
            }
        
            // 金額上限内チェック
            if (areaMaintenanceMap.containsKey(district)) {
                areaMaintenanceCondition = areaMaintenanceMap.get(district);
                
                if (areaMaintenanceCondition.PropertyAmountLowerLimit__c != null && target.RentFee__c < areaMaintenanceCondition.PropertyAmountLowerLimit__c
                    || areaMaintenanceCondition.PropertyAmountUpperLimit__c != null && target.RentFee__c > areaMaintenanceCondition.PropertyAmountUpperLimit__c) {
                    continue;
                }
            }
            targetList.add(target);
        }

        // 登録対象の物件と店舗のIDリストを取得
        PortalSitePostingProperty__c portalSitePostingProperty;
        for(Property__c target : targetList){
            for(Id shopId : properyShopMap.get(target.Id)) {
                // 登録情報の設定
                portalSitePostingProperty = new PortalSitePostingProperty__c(
                    Shop__c = shopId
                    , Property__c = target.Id
                );
                result.add(portalSitePostingProperty);
            }
        }
                 
        return result;
    }
}