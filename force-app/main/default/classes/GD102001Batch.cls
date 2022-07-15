// 業者プラン一括変更バッチ
global with sharing class GD102001Batch implements Database.Batchable<Property__c>, Database.Stateful{

    /** バッチ変数 */
    private Set<Id>  buildingIdSet           { get; set; } // 建物ID
    private Id       formerSupplier          { get; set; } // 元付業者
    private String   formerSupplierName      { get; set; } // 元付業者
    private Id       chgDestinationAccountId { get; set; } // 変更先取引先ID
    private Id       chgOriginalObjId        { get; set; } // 変更元オブジェクトID
    private Id       chgDestinationObjId     { get; set; } // 変更先オブジェクトID
    private String   chgOriginalName         { get; set; } // 変更元名称
    private String   chgDestinationName      { get; set; } // 変更先名称
    private String   dispKind                { get; set; } // 画面種別（業者プラン一括変更画面パラメータ）
    private Datetime sysDate                 { get; set; } // システム日付
    private String   dispKindMsg             { get; set; } // 画面種別メッセージ
    private Boolean  isExecuteErr            { get; set; } // Execute処理エラーフラグ

    /** 定数_件名 */
    private final String COMPLETE_MAIL_SUBJECT; // 正常終了時
    private final String ERR_MAIL_SUBJECT;      // 異常終了時

    /** 定数_画面種別 */
    private final String DISP_KIND_GUARANTEEID_CORP    = GD101002Modal2ParameterClass.DispKind.guaranteeidCorp.name();   // 保証会社
    private final String DISP_KIND_FIRE_INSURANCE_CORP = GD101002Modal2ParameterClass.DispKind.fireInsuranceCorp.name(); // 火災保険会社
    private final String DISP_KIND_MANA_CORP_ITEM      = GD101002Modal2ParameterClass.DispKind.manaCorpItem.name();      // 管理会社指定商品

    /**
     * コンストラクタ
     * @param Set<Id> buildingIdSet           建物ID
     * @param Id      formerSupplier          元付業者
     * @param String  formerSupplierName      元付業者
     * @param Id      chgDestinationAccountId 変更先取引先ID
     * @param Id      chgOriginalObjId        変更元オブジェクトID
     * @param Id      chgDestinationObjId     変更先オブジェクトID
     * @param String  chgOriginalName         変更元名称
     * @param String  chgDestinationName      変更先名称
     * @param String  dispKind                画面種別（業者プラン一括変更画面パラメータ）
     */
    global GD102001Batch(Set<Id>  buildingIdSet
                         , Id     formerSupplier
                         , String formerSupplierName
                         , Id     chgDestinationAccountId
                         , Id     chgOriginalObjId
                         , Id     chgDestinationObjId
                         , String chgOriginalName
                         , String chgDestinationName
                         , String dispKind) {

        // バッチ変数の初期化
        this.buildingIdSet           = buildingIdSet;           // 建物ID
        this.formerSupplier          = formerSupplier;          // 元付業者
        this.formerSupplierName      = formerSupplierName;      // 元付業者名
        this.chgDestinationAccountId = chgDestinationAccountId; // 変更先取引先ID
        this.chgOriginalObjId        = chgOriginalObjId;        // 変更元オブジェクトID
        this.chgDestinationObjId     = chgDestinationObjId;     // 変更先オブジェクトID
        this.chgOriginalName         = chgOriginalName;         // 変更元名称
        this.chgDestinationName      = chgDestinationName;      // 変更先名称
        this.dispKind                = dispKind;                // 画面種別
        this.sysDate                 = CommonUtil.getNow();     // システム日付
        this.isExecuteErr            = false;                   // Execute処理エラーフラグ

        // 画面種別に応じた件名、本文用文字の取得
        this.dispKindMsg = CommonConst.SUPPLIER_PLAN_BULK_CHG_ITEM;
        if (dispKind == this.DISP_KIND_GUARANTEEID_CORP || dispKind == this.DISP_KIND_FIRE_INSURANCE_CORP) {
            this.dispKindMsg = CommonConst.SUPPLIER_PLAN_BULK_CHG_PLAN;
        }

        // 定数の設定
        this.COMPLETE_MAIL_SUBJECT = CommonUtil.callMessageCreate(CommonConst.MSG_PROP_I_PROCESS_END, this.dispKindMsg + 'の一括変更');
        this.ERR_MAIL_SUBJECT      = CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_PROCESS,      this.dispKindMsg + 'の一括変更処理');
    }

    /**
     * データ取得
     * @param Database.BatchableContext BC 一括処理ジョブメソッドパラメータ
     * @return Iterable<Property__c> 物件
     */
    global Iterable<Property__c> start(Database.BatchableContext BC){

        // 物件の取得
        return this.selectProperty(this.formerSupplier
                                   , this.chgOriginalObjId
                                   , this.dispKind
                                   , this.buildingIdSet);    
    }
        
    /**
     * 開始
     * @param Database.BatchableContext BC 一括処理ジョブメソッドパラメータ
     * @param List<Property__c> propertyList 物件
     */
    global void execute(Database.BatchableContext BC, List<Property__c> propertyList){

        Savepoint sp = Database.setSavepoint();
        try {
            // CRUD処理用
            List<SObject> updObjList = new List<SObject>(); // 更新
            List<SObject> delObjList = new List<SObject>(); // 削除
            List<SObject> tmpObjList = new List<SObject>(); // 一時保存用

            Set<Id> updAllRentPropIdSet          = new Set<Id>(); // 総賃料更新用物件Id
            Set<Id> insBuildingPropDiffPropIdSet = new Set<Id>(); // 建物物件差分用物件Id

            // 変更後の管理会社指定プランを持つ物件管理会社指定商品（key:物件.Id、value:物件）
            Map<Id, Property__c> existsPropertyManaCorpMap = new Map<Id, Property__c>();
            if (dispKind == DISP_KIND_MANA_CORP_ITEM) {
                List<Property__c> chgDestinationProp = this.selectProperty(this.formerSupplier
                                                                           , this.chgDestinationObjId
                                                                           , this.dispKind
                                                                           , this.buildingIdSet);

                if (chgDestinationProp.size() > 0) {
                    existsPropertyManaCorpMap = new Map<Id, Property__c>(chgDestinationProp);
                }
            }

            // 画面種別に応じた更新・削除値の取得
            for (Property__c property : propertyList) {

                // 物件の保証会社プランの更新
                if (dispKind == DISP_KIND_GUARANTEEID_CORP) {
                    property.GuaranteeidCompany__c = this.chgDestinationAccountId; // 保証会社
                    property.Guaranteeid__c        = this.chgDestinationObjId;     // 保証タイトル
                    updObjList.add(property);
                // 物件の火災保険会社プランの更新
                } else if (dispKind == DISP_KIND_FIRE_INSURANCE_CORP) {
                    property.FireInsuranceCompany__c = this.chgDestinationAccountId; // 火災保険会社
                    property.FireInsurancePlan__c    = this.chgDestinationObjId;     // 火災保険タイトル
                    updObjList.add(property);
                // 物件に紐づく物件管理会社指定商品の更新・削除
                } else if (dispKind == DISP_KIND_MANA_CORP_ITEM) {

                    // 物件管理会社指定商品の取得
                    tmpObjList = new List<SObject>();
                    for (PropertyManageCompayItem__c propertyManaCorpItem : property.propertyManageCompayItemProperty__r) {
                        tmpObjList.add(new PropertyManageCompayItem__c(
                                                Id        = propertyManaCorpItem.Id  // Id
                                                , Item__c = this.chgDestinationObjId // 管理会社指定プラン
                                            ));
                    }

                    // CRUD処理チェック
                    if (!existsPropertyManaCorpMap.containsKey(property.id)) {
                        // 更新
                        updObjList.addAll(tmpObjList);
                    } else {
                        // 削除
                        delObjList.addAll(tmpObjList);
                    }
                }

                //総賃料更新対象の取得
                updAllRentPropIdSet.add(property.Id);

                // 建物物件差分作成対象の取得
                if (property.WebPublishing__c == CommonConst.PROPERTY_WEBPUBLISHING_EXISTS) {
                    insBuildingPropDiffPropIdSet.add(property.Id);
                }
            }

            // 更新処理
            if (updObjList.size() > 0) {
                SecureDML.secureUpdate(updObjList);
            }

            // 削除処理
            if (delObjList.size() > 0) {
                SecureDML.secureDelete(delObjList);
            }

            // 総賃料の更新
            if (updAllRentPropIdSet.size() > 0) {
                BuildingPropertyUtil.updateCalcAllRent(updAllRentPropIdSet);
            }

            // 建物物件差分の作成
            if (insBuildingPropDiffPropIdSet.size() > 0) {
                BuildingPropertyUtil.createBuildingPropertyDifference(insBuildingPropDiffPropIdSet);
            }

        } catch (Exception e) {
            System.debug('例外メッセージ:' + e.getMessage());
            System.debug('例外スタックトレース:' + e.getStackTraceString());
            Database.rollback(sp);

            // 多重エラー処理チェック
            if (this.isExecuteErr) {
                return;
            }

            // エラーメールの送信
            if (String.isNotBlank(SystemConfig__c.getInstance().ErrorEmailDestination__c)) {

                // エラーメールの送信
                MailUtil.MailData errMailData = new MailUtil.MailData();
                errMailData.toAddress   = new List<String>{SystemConfig__c.getInstance().ErrorEmailDestination__c};
                errMailData.ccAddress   = null;
                errMailData.fromAddress = null;
                errMailData.subject     = this.ERR_MAIL_SUBJECT;
                errMailData.textBody    = 'エラー内容をご確認ください' + CommonConst.BREAK_CODE
                                        + '〔業者〕'       + this.formerSupplierName + '(' + this.formerSupplier      + ')' + CommonConst.BREAK_CODE
                                        + '〔変更元〕'     + this.chgOriginalName    + '(' + this.chgOriginalObjId    + ')' + CommonConst.BREAK_CODE
                                        + '〔変更先〕'     + this.chgDestinationName + '(' + this.chgDestinationObjId + ')' + CommonConst.BREAK_CODE
                                        + '〔エラー内容〕' + e.getMessage() + CommonConst.BREAK_CODE
                                        + '〔エラー箇所〕' + e.getStackTraceString();

                MailUtil.sendMail(new List<MailUtil.MailData>{errMailData});
            }

            this.isExecuteErr = true;
        }
    }
        
    /**
     * 終了
     * @param Database.BatchableContext BC 一括処理ジョブメソッドパラメータ
     */
    global void finish(Database.BatchableContext BC) {

        // 正常メールの送信チェック
        if (this.isExecuteErr) {
            return;
        }

        // 処理完了メールの送信
        MailUtil.MailData completeMailData = new MailUtil.MailData();
        completeMailData.toAddress   = new List<String>{UserInfo.getUserEmail()};
        completeMailData.ccAddress   = null;
        completeMailData.fromAddress = null;

        completeMailData.subject  = this.COMPLETE_MAIL_SUBJECT;
        completeMailData.textBody = '変更元：' + this.chgOriginalName + CommonConst.BREAK_CODE
                                  + '変更先：' + this.chgDestinationName;

        MailUtil.sendMail(new List<MailUtil.MailData>{completeMailData});
    }

    /**
     * 物件の取得
     * @param Id      condAccountId 取引先ID
     * @param Id      condObjId     オブジェクトID
     * @param String  dispKind      画面種別
     * @param Set<Id> buildingIdSet 建物Id
     * @return List<Property__c> 物件
     */
    private List<Property__c> selectProperty(Id condAccountId
                                             , Id condObjId
                                             , String dispKind
                                             , Set<Id> buildingIdSet) {

        // 物件取得クエリの作成
        String sql = CommonConst.STRING_EMPTY;
        sql = 'SELECT Id '
            + '       , GuaranteeidCompany__c '   // 保証会社
            + '       , Guaranteeid__c '          // 保証タイトル
            + '       , FireInsuranceCompany__c ' // 火災保険会社
            + '       , FireInsurancePlan__c '    // 火災保険タイトル
            + '       , WebPublishing__c ';       // web公開

        // 画面種別（商品）対応
        if (dispKind == DISP_KIND_MANA_CORP_ITEM) {
            sql += '       , (SELECT Id '        // 物件管理会社指定商品.Id
                 + '                 , Item__c ' // 物件管理会社指定商品.管理会社指定プラン
                 + '          FROM propertyManageCompayItemProperty__r '
                 + '          WHERE Item__c = \'' + CommonUtil.escapeSingleQuotesEx(condObjId) + '\' '
                 + '                AND Account__c = \'' + CommonUtil.escapeSingleQuotesEx(condAccountId) + '\' '
                 + '         ) ';
        }
        
        sql += 'FROM Property__c '
             + 'WHERE FormerSupplier__c = \'' + CommonUtil.escapeSingleQuotesEx(condAccountId) + '\' ';

        // 建物の条件を追加
        String condBuildingSql = CommonConst.STRING_EMPTY;
        for (Id buildingId : buildingIdSet) {
            condBuildingSql += ' Building__c = \'' + CommonUtil.escapeSingleQuotesEx(buildingId) + '\' OR';
        }

        if (String.isNotBlank(condBuildingSql)) {
            sql += ' AND (' + condBuildingSql.removeEnd('OR')  + ')';
        }

        // 画面種別に応じた物件の取得
        if (dispKind == DISP_KIND_GUARANTEEID_CORP) {
            sql += ' AND Guaranteeid__c = \'' + CommonUtil.escapeSingleQuotesEx(condObjId) + '\' ';
        } else if (dispKind == DISP_KIND_FIRE_INSURANCE_CORP) {
            sql += ' AND FireInsurancePlan__c = \'' + CommonUtil.escapeSingleQuotesEx(condObjId) + '\' ';
        } else if (dispKind == DISP_KIND_MANA_CORP_ITEM) {
            sql += ' AND Id IN (SELECT Property__c '
                 + '            FROM PropertyManageCompayItem__c '
                 + '            WHERE Item__c = \'' + CommonUtil.escapeSingleQuotesEx(condObjId) + '\' '
                 + '                  AND Account__c = \'' + CommonUtil.escapeSingleQuotesEx(condAccountId) + '\' '
                 + '           ) ';
        }

        // 物件の取得
        List<Property__c> propertyList = Database.query(sql);

        // 初期化処理
        if (propertyList.isEmpty()) {
            propertyList = new List<Property__c>();
        }

        return propertyList;
    }
}