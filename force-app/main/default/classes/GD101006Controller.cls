/**
 * @File Name          : GD101006Controller.cls
 * @Description        : 業者名寄せ比較画面のコントローラ
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 2020/3/31 11:29:26
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2020/3/17   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public inherited sharing class GD101006Controller {

/** パブリック変数 */    
//メッセージ系
public String MSG_COM_V_EXECUTE_MERGE {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_EXECUTE_MERGE);} private set;}    //js用名寄せ確認メッセージ
public String MSG_COM_I_MERGE_END {get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_MERGE_END);} private set;}    //js用名寄せ完了メッセージ
public String MSG_COM_I_PROPERTYBULKUPDATE {get {return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_PROPERTYBULKUPDATE);} private set;}    //js用一括確認完了メッセージ
public String MSG_COM_I_MERGE { get; set; } //物件の更新完了メッセージ(判定用)

//パブリック変数
public Boolean isNew { get; set; }                 //新規登録フラグ
public Boolean isOpenError { get; set; }           //エラーフラグ
public Boolean hasErrorMessage { get; set; }       //エラーメッセージ保有フラグ
public Boolean propertyBulkUpdate { get; set; }   //物件更新完了フラグ


public String transitionId { get; set; }           //画面遷移用建物Id

//業者リスト
public Account leftAccount { get; set; }//左
public Account rightAccount { get; set; }//右
//関連リスト
public List<InsuranceGuarantee__c> leftGuaranteeList { get; set; }//保証会社プラン
public List<InsuranceGuarantee__c> rightGuaranteeList { get; set; }
public List<InsuranceGuarantee__c> leftFireList { get; set; }//火災保険会社プラン
public List<InsuranceGuarantee__c> rightFireList { get; set; }
public List<ManagementCompanyItem__c> leftMCIList { get; set; }//管理会社指定商品
public List<ManagementCompanyItem__c> rightMCIList { get; set; }
public List<PropertyManageCompayItem__c> leftPMCIList { get; set; }//物件管理会社指定商品（2020.05.11追加）
public List<PropertyManageCompayItem__c> rightPMCIList { get; set; }
public List<Building__c> leftBuildingList { get; set; }//建物
public List<Building__c> rightBuildingList { get; set; }

//ラジオボタン値
public String MaintenanceRadioButton { get; set; }//メンテナンスセクション
public String BasicInfoRadioButton { get; set; }//基本情報セクション

//ラジオボタン変更無効化フラグ
public Boolean IsDisableMaintenanceRadioButton { get; set; }//メンテナンスセクションのラジオボタン値変更無効化フラグ

/** プライベート変数 */
private String id1;   //取引先IDパラメータ1
private String id2;  //取引先IDパラメータ2
private Account ExchangeRecord;//左右入れ替え用（初期表示の際のみ使う）
private Id guarRecordTypeId;//取引先保険保証(保証)のレコードタイプId
private Id fireRecordTypeId;//取引先保険保証(火災)のレコードタイプId
private Integer selectLimit; //業者名寄せ物件更新数（システム設定）
private Integer selectBuildingLimit;//2020/7/3：業者に紐付けされている建物取得時の最大数 （システム設定）


//コンストラクタ
public GD101006Controller() {
try{
    this.isOpenError = false;
    this.hasErrorMessage = false;
    //店舗異動が取得できなければエラー
    CommonUtil.getStaffCurrentShop();
    //パラメータ取得        
    this.id1 = ApexPages.currentPage().getParameters().get('id1');//取引先id1
    this.id2 = ApexPages.currentPage().getParameters().get('id2'); //取引先id2


    //初期化
    init();

}catch(Exception e){
    //エラーを設定
    isOpenError = true;
    CommonUtil.setErrorMessage(e);
}
}

//=====以下publicメソッド========================================================================================
/**
* @description メンテナンスセクションのラジオボタン
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/17 
* @return List<SelectOption> 
**/
public List<SelectOption> getMaintenanceRadioButtonSetting(){
List<SelectOption> options = new List<SelectOption>();
options.add(new SelectOption('左', ''));
options.add(new SelectOption('右', ''));
return options;
}


/**
* @description 基本情報ラジオボタン
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/17 
* @return List<SelectOption> 
**/
public List<SelectOption> getBasicInfoRadioButtonSetting(){
List<SelectOption> options = new List<SelectOption>();
options.add(new SelectOption('左', ''));
options.add(new SelectOption('右', ''));
return options;
}


/**
* @description 登録(名寄せ)処理
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/17 
* @return void 
**/
public void save(){
Savepoint sp = Database.setSavepoint();//セーブポイント作成

try{
    hasErrorMessage = false;
    system.debug('登録');

    //楽観ロックチェック
    List<Account> leftCheckOptimisticLockExceptionRecord = new List<Account>();
    List<Account> rightCheckOptimisticLockExceptionRecord = new List<Account>();

    leftCheckOptimisticLockExceptionRecord = [SELECT id
                                                FROM Account
                                                WHERE id = :leftAccount.Id
                                                AND SystemModStamp = :leftAccount.systemModStamp];

    rightCheckOptimisticLockExceptionRecord = [SELECT id
                                                FROM Account
                                                WHERE id = :rightAccount.Id
                                                AND SystemModStamp = :rightAccount.systemModStamp];

    //どちらかでもデータを取得できない場合、楽観ロックチェックExceptionを発行
    if (leftCheckOptimisticLockExceptionRecord.isEmpty() || rightCheckOptimisticLockExceptionRecord.isEmpty()) {
        OptimisticLockException ex = new OptimisticLockException();
        throw ex;
    }

    Account mergeAcc;//残す業者
    Account delAcc;//消す業者
    List<InsuranceGuarantee__c> mergeGuaranteeList;//変更する保証会社プラン
    List<InsuranceGuarantee__c> mergeFireList;//変更する火災保険会社プラン
    List<ManagementCompanyItem__c> mergeMCIList;//変更する管理会社指定商品
    List<PropertyManageCompayItem__c> mergePMCIList;//変更する物件管理会社指定商品（2020.05.11追加）
    Set<Id> leaveGuaranteeItemSet = new Set<Id>();//2020/5/28追加：残す保証会社プラン商品セット
    Set<Id> leaveFireItemSet = new Set<Id>();//2020/5/28追加：残す火災保険会社プラン商品セット

    //基本情報のチェック側に寄せる
    if(BasicInfoRadioButton=='左'){
        //★残す側を左に設定
        mergeAcc = leftAccount;
        //関連リストの残す側を右（idを左にする）
        mergeGuaranteeList = rightGuaranteeList;//保証会社プラン
        mergeFireList = rightFireList;//火災保険会社プラン
        mergeMCIList = rightMCIList;//管理会社指定商品
        mergePMCIList = rightPMCIList;//物件管理会社指定商品（2020.05.11追加）

        //2020/5/28追加：残される保証プランの商品リスト
        for (InsuranceGuarantee__c g : leftGuaranteeList){
            leaveGuaranteeItemSet.add(g.Item__c);
        }
        //2020/5/28追加：残される火災保険プランの商品リスト
        for (InsuranceGuarantee__c f : leftFireList){
            leaveFireItemSet.add(f.Item__c);
        }

        //右を消す
        delAcc = rightAccount;

    }else{
        //★残す側を右に設定
        mergeAcc = rightAccount;
        //関連リストの残す側を左（idを右にする）
        mergeGuaranteeList = leftGuaranteeList;//保証会社プラン
        mergeFireList = leftFireList;//火災保険会社プラン
        mergeMCIList = leftMCIList;//管理会社指定商品
        mergePMCIList = leftPMCIList;//物件管理会社指定商品（2020.05.11追加）

        //2020/5/28追加：残される保証プランの商品リスト
        for (InsuranceGuarantee__c g : rightGuaranteeList){
            leaveGuaranteeItemSet.add(g.Item__c);
        }
        //2020/5/28追加：残される火災保険プランの商品リスト
        for (InsuranceGuarantee__c f : rightFireList){
            leaveFireItemSet.add(f.Item__c);
        }
        //左を消す
        delAcc = leftAccount;
    }

    system.debug('残す業者；' + mergeAcc);
    system.debug('消す業者；' + delAcc);

    //消す業者が紐づいている物件を探す(建物リスト対応)
    List<Property__c> usedSupplierPropertyList =[SELECT Id, FormerSupplier__c, Creditor__c, Owner__c
                                                    FROM Property__c
                                                    WHERE (FormerSupplier__c = :delAcc.Id
                                                    OR Creditor__c  = :delAcc.Id
                                                    OR Owner__c  = :delAcc.Id)
                                                    LIMIT :selectLimit + 1];                                            

    //物件更新完了メッセージの設定
    if(usedSupplierPropertyList.size() <= selectLimit){
        MSG_COM_I_MERGE = CommonUtil.callMessageCreate(MSG_COM_I_MERGE_END);
        propertyBulkUpdate = true;//物件更新完了フラグをtrueに                
    }else{
        MSG_COM_I_MERGE = CommonUtil.callMessageCreate(MSG_COM_I_PROPERTYBULKUPDATE, String.valueOf(selectLimit));
        usedSupplierPropertyList.remove(selectLimit); //最後の一つをついでに除去(removeの引数はindexなのでselectLimit+1番目が除去される)
        propertyBulkUpdate = false;//物件更新完了フラグをfalseに
    }
    
                        
    //消す業者が物件に紐づいている場合
    if(!usedSupplierPropertyList.isEmpty()){
        for(Property__c p : usedSupplierPropertyList){
            if(p.FormerSupplier__c == delAcc.Id){//元付業者
                p.FormerSupplier__c = mergeAcc.Id;
            }
            if(p.Creditor__c == delAcc.Id){//貸主
                p.Creditor__c = mergeAcc.Id;
            }
            if(p.Owner__c == delAcc.Id){//所有者
                p.Owner__c = mergeAcc.Id;
            }                    
        }
        SecureDML.secureUpdate(usedSupplierPropertyList);                                
    }

    //物件更新完了フラグがtrueの場合、残りの処理を実施する
    if(propertyBulkUpdate == true){
            
        //基本情報セクションとラジオボタンの値が違う場合、上書き
        if (MaintenanceRadioButton != BasicInfoRadioButton){
            //メンテナンス情報
            mergeAcc.MaintenanceSupplierCode__c = delAcc.MaintenanceSupplierCode__c;//メンテナンス業者コード
            mergeAcc.ImportType__c = delAcc.ImportType__c;//取込区分
        }

        //消す業者に関連リストがある場合、残す業者に寄せて更新
        //保証会社プラン
        if(!mergeGuaranteeList.isEmpty()){
            for(InsuranceGuarantee__c ig : mergeGuaranteeList){
                //2020/5/28追加：残す取引先保険保証（保証）商品リストに消す取引先保険保証（保証）の商品が含まれていない場合のみ、名寄せを行う
                if (! leaveGuaranteeItemSet.contains(ig.Item__c)){
                    ig.Account__c = mergeAcc.Id;
                }
            }
            SecureDML.secureUpdate(mergeGuaranteeList);
        }
        //火災保険会社プラン
        if(!mergeFireList.isEmpty()){
            for(InsuranceGuarantee__c ig : mergeFireList){
                //2020/5/28追加：残す取引先保険保証（火災保険）商品リストに消す取引先保険保証（火災保険）の商品が含まれていない場合のみ、名寄せを行う
                if (! leaveFireItemSet.contains(ig.Item__c)){
                    ig.Account__c = mergeAcc.Id;
                }
            }
            SecureDML.secureUpdate(mergeFireList);
        }
        //管理会社指定商品
        if(!mergeMCIList.isEmpty()){
            for(ManagementCompanyItem__c mci : mergeMCIList){
                mci.Account__c = mergeAcc.Id;
            }
            SecureDML.secureUpdate(mergeMCIList);
        }

        //物件管理会社指定商品（2020.05.11追加）
        if(!mergePMCIList.isEmpty()){
            for(PropertyManageCompayItem__c pmci : mergePMCIList){
                pmci.Account__c = mergeAcc.Id;
            }
            SecureDML.secureUpdate(mergePMCIList);
        }

        
        //名寄せ完了フラグ更新
        if (NameMergeUtil.getSupplierMergeList(mergeAcc,delAcc.Id).size() != 0){
            //リストあり…名寄せ完了フラグfalse
            mergeAcc.IsMergeCompletedFlag__c = false;
        }else{
            //リスト空…名寄せフラグtrue
            mergeAcc.IsMergeCompletedFlag__c = true;
        }

        //削除側の自動メンテナンスレコードを残る側のidに更新
        List<AutoMaintenance__c> autoMaint =[SELECT id FROM AutoMaintenance__c WHERE FormerSupplier__c = :delAcc.Id];
        if (autoMaint.size() != 0){
            for (AutoMaintenance__c a :autoMaint){
                a.FormerSupplier__c = mergeAcc.id;
            }
            SecureDML.secureUpdate(autoMaint);
        }

        //更新
        SecureDML.secureUpdate(mergeAcc);
        
        //削除
        SecureDML.secureDelete(delAcc);                
    }

    //画面遷移用の物件Id設定
    this.transitionId = mergeAcc.id;

}catch(Exception e){
    Database.rollback(sp);//処理をロールバック
    hasErrorMessage = true;
    CommonUtil.setErrorMessage(e);
}
}


//-----以下privateメソッド-----------------------------------------------------------------------------------
/**
* @description 初期化メソッド
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/18 
* @return void 
**/
private void init(){
//関連リスト初期化
this.leftGuaranteeList = new List<InsuranceGuarantee__c>();//保証会社プラン
this.rightGuaranteeList = new List<InsuranceGuarantee__c>();
this.leftFireList = new List<InsuranceGuarantee__c>();//火災保険会社プラン
this.rightFireList = new List<InsuranceGuarantee__c>();
this.leftMCIList = new List<ManagementCompanyItem__c>();//管理会社指定商品
this.rightMCIList = new List<ManagementCompanyItem__c>();
this.leftPMCIList = new List<PropertyManageCompayItem__c>();//物件管理会社指定商品(2020.05.11追加)
this.rightPMCIList = new List<PropertyManageCompayItem__c>();
this.leftBuildingList = new List<Building__c>();//建物
this.rightBuildingList = new List<Building__c>();

//取引先保険保証のレコードタイプId取得
this.guarRecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', CommonConst.INSURANCE_RECTYPE_GUARANTEE_GUARANTEE);
this.fireRecordTypeId = CommonUtil.getRecordTypeId('InsuranceGuarantee__c', CommonConst.INSURANCE_RECTYPE_GUARANTEE_FIREINSURANCE);

//システム設定
this.selectLimit = Integer.valueOf(SystemConfig__c.getInstance().SupplierMerge_PropertyUpdateMaxCount__c);
this.selectBuildingLimit = Integer.valueOf(SystemConfig__c.getInstance().SupplierMerge_BuildingMaxCount__c);

//■業者
selectAccountInfo(id1);
selectAccountInfo(id2);
//■取引先保険保証、管理会社指定商品、建物を取得（データ数が多すぎてエラーが出るため、サブクエリから分離）
//2020.05.11 物件管理会社指定商品の取得を追加
selectSubQueryInfo(leftAccount.id,'左');
selectSubQueryInfo(rightAccount.id,'右');

//ラジオボタン初期値
BasicInfoRadioButton= '左';

//メンテナンスラジオボタン初期値設定
setMaintenanceRadioButton();
}
private void selectSubQueryInfo(id targetId,String leftOrRight){
//取引先保険保証
List<InsuranceGuarantee__c> InsGuarList =[SELECT Id,
                                    RecordTypeId,
                                    Item__r.Account__r.Name,//保証会社名
                                    Item__r.ItemName__c,//プラン名
                                    Item__r.AssuranceContent__c,//保証内容
                                    Item__r.FireInsurance__c,//保険内容
                                    Item__r.Remarks__c//保証備考
                            FROM InsuranceGuarantee__c
                            WHERE Account__c = :targetId];
    //管理会社指定商品
List<ManagementCompanyItem__c> mciList =[SELECT Id,
                                            ItemName__c,//商品名
                                            AmountTax__c//金額
                                    FROM ManagementCompanyItem__c
                                    WHERE Account__c = :targetId];

    //物件管理会社指定商品（2020.05.11追加）
    List<PropertyManageCompayItem__c> pmciList =[SELECT Id
                                    FROM PropertyManageCompayItem__c
                                    WHERE Account__c = :targetId];
                                    
    //建物
    List<Building__c> builList = [SELECT Id, 
                                        Name,//建物名
                                        Address__c,//住所
                                        BuildingYMFormat__c,//築年月
                                        TrainRoute1__r.Name,//沿線
                                        Station1__r.Name,//最寄駅
                                        StationWalkTimeFormat1__c//駅徒歩
                                FROM Building__c
                                WHERE Id IN (SELECT Building__c FROM property__c WHERE FormerSupplier__c =:targetId) 
                                ORDER BY Name 
                                LIMIT :selectBuildingLimit];
                                //■左右の関連リスト取得

if (rightAccount.InsuranceGuaranteeAccount__r.size()!=0){//右
    system.debug('右に商品あり');
    List<InsuranceGuarantee__c> rightIGList = rightAccount.InsuranceGuaranteeAccount__r;
    for(InsuranceGuarantee__c ig : rightIGList){
        if(ig.RecordTypeId == fireRecordTypeId){
            this.rightFireList.add(ig);//火災
        }else{
            this.rightGuaranteeList.add(ig);//保証
        }
    }
}

//保証会社プラン・火災保険会社プランの火災と保証振り分け
List<InsuranceGuarantee__c> InsList = new List<InsuranceGuarantee__c>();
List<InsuranceGuarantee__c> GuarList = new List<InsuranceGuarantee__c>();
if (InsGuarList.size()!=0){
    for(InsuranceGuarantee__c ig : InsGuarList){
        if(ig.RecordTypeId == fireRecordTypeId){
            InsList.add(ig);//火災
        }else{
            GuarList.add(ig);//保証
        }
    }            
}
if (leftOrRight =='左'){//左
    //保証会社プラン・火災保険会社プラン
    leftFireList = InsList;
    leftGuaranteeList = GuarList;

    //管理会社指定商品
    if (mciList.size()!=0){
        system.debug('左に管理会社指定商品あり');
        leftMCIList = mciList; 
    }
    //物件管理会社指定商品（2020.05.11追加）
    if (pmciList.size()!=0){
        leftPMCIList = pmciList; 
    }
    //建物
    if (builList.size()!=0){
        leftBuildingList = builList; 
    }
        
}else{//右
    //保証会社プラン・火災保険会社プラン
    rightFireList = InsList;
    rightGuaranteeList = GuarList;

    //管理会社指定商品
    if (mciList.size()!=0){
        system.debug('右に管理会社指定商品あり');
        rightMCIList = mciList; 
    }
    //物件管理会社指定商品（2020.05.11追加）
    if (pmciList.size()!=0){
        rightPMCIList = pmciList; 
    }    
    //建物
    if (builList.size()!=0){
        rightBuildingList = builList; 
    }  
}
}

/**
* @description 業者情報取得と左右レコード振り分け
* @author ChangeMeIn@UserSettingsUnder.SFDoc | 2020/3/18 
* @param String accountId 
* @return void 
**/
private void selectAccountInfo(String accountId){
List<Account> accountList = [
    SELECT id,
            MaintenanceSupplierCode__c,//メンテナンス業者コード
            ImportType__c,//取込区分
            //基本情報
            Name,//業者名
            NameKana__c,//業者名カナ
            SupplierType__c,//業者種別
            PostalCode__c,//郵便番号
            Address__c,//住所
            State__c,//都道府県
            City__c,//所在地１(市区町村・丁目まで)
            Street__c,//所在地２(番地以降)
            Phone,//電話番号
            Fax,//FAX
            Email__c,//メールアドレス
            Introduction__c,//紹介
            IppamGyobutsu__c,//一般/業物
            FixedTermSend__c,//定期送信
            RenewalFeeShow__c,//更新料表記
            CleaningFeeShow__c,//定額補修費表記
            GuarantorAgencyCompanyType__c,//suumo保証人代行会社区分コード
            RemarksPublic__c,//備考(公開)
            RemarksPrivate__c,//備考(非公開)
            //担当者情報
            Representative__c,//担当者名
            RepresentativeDepartment__c,//担当部署
            RepresentativePhone__c,//担当電話番号
            //電物
            DembutsuDate__c,//電物日
            DembutsuStatus__c,//電物ステータス
            DembutsuStaff__c,//電物担当者
            DembutsuEventMemo__c,//電物メモ
            
            CreatedDate,
            SystemModstamp  
    FROM Account 
    WHERE Id = :accountId];
//レコード情報が取得できなければビジネスロジックException発行
if( accountList.size()==0 ){
    BusinessLogicException ex = new BusinessLogicException();
    ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
    throw ex;
}

//★取得1回目の場合、ExchangeListに入れる
if (ExchangeRecord == null){
    ExchangeRecord = accountList[0].clone(true,false,true);

//★取得2回目の場合、どちらが古いかを比較し、左右のレコードに振り分け
}else{
    //1回目のレコードが2回目より古い場合、1回目が左、2回目が右のレコードに入る
    if(ExchangeRecord.CreatedDate < accountList[0].CreatedDate){
        leftAccount = ExchangeRecord.clone(true,false,true);
        rightAccount = accountList[0].clone(true,false,true);
    
    //2回目のレコードが1回目より古い場合、2回目が左、1回目が右のレコードに入る
    }else{
    leftAccount = accountList[0].clone(true,false,true);
    rightAccount = ExchangeRecord.clone(true,false,true);
    }
}
}

/**
* @description メンテナンス情報ラジオボタン設定
* @author 2020/4/28 
* @return void 
**/
private void setMaintenanceRadioButton(){

MaintenanceRadioButton= '左';//メンテナンスセクションのラジオボタン初期設定
IsDisableMaintenanceRadioButton = false;//メンテナンスセクションのラジオボタン値変更可能に初期設定

//左右のメンテナンスコードの片方のみ入力されている場合、入力されている側にラジオボタンを固定する
if(String.isBlank(leftAccount.MaintenanceSupplierCode__c)
&& String.isNotBlank(rightAccount.MaintenanceSupplierCode__c)){
    //右側のみメンテナンスコードがある場合
    IsDisableMaintenanceRadioButton = true;//メンテナンスセクションのラジオボタン値変更不可能に設定
    MaintenanceRadioButton= '右';//右側にメンテナンスセクションのラジオボタン値固定
    
}else if(String.isNotBlank(leftAccount.MaintenanceSupplierCode__c)
        && String.isBlank(rightAccount.MaintenanceSupplierCode__c)){
        //左側のみメンテナンスコードがある場合
        IsDisableMaintenanceRadioButton = true;//メンテナンスセクションのラジオボタン値変更不可能に設定
        //ラジオボタン初期設定の左側にメンテナンスセクションのラジオボタン値固定

}
}

}