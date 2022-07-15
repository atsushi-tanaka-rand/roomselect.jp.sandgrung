/**
 * @File Name          : GH101003Modal1ParameterClass.cls
 * @Description        : 新規ユーザー異動のパラメータクラス
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 2020/3/10 14:24:58
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2020/3/3   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class GH101003Modal1ParameterClass {

    /** 初回描画フラグ */
    public Boolean isDrawing{ get; set;}
    
    /** 描画実施済みフラグ */
    public Boolean noFirst{ get; set;}

    //返却される店舗異動情報List
    public ShopTransfer__c paramSTRecord{ get; set;}
    
    //ユーザー名
    public String paramStaffName{ get; set; }

    //組織階層名
    public String paramOrganizationName{ get; set; }

    //店舗異動情報明細
    public List<GH101003Controller.ScreenShopTransferInfo> paramSTList{ get; set; }

    //店舗異動情報明細の行番号
    public Integer paramIndex{ get; set; }

    //コンストラクタ
    public GH101003Modal1ParameterClass() {

        // フラグ初期化処理
        isDrawing = false;
        noFirst = false;
        
        // 初期化処理
        paramSTRecord = new ShopTransfer__c();

        
    }
}