//名寄せ画面のコントローラー
public inherited sharing class GA102003Controller {

    //Public変数
    public Account targetRecord { get; set; } //画面表示用アカウントレコード
    public List<Selected> displayCandidateResult { get; set; } //名寄せ対象アカウントリスト
    public Integer mergeSelectedIndex { get; set; } //名寄せリストセットインデックス
    public Boolean isOpenError { get; set; }     //エラーフラグ
    public Boolean hasErrorMessage { get; set; } //エラーメッセージ保有フラグ
    private Boolean isOpetionPortal { get; set; } // 自社ポータル権限
    public String portalMemberId { get; set; } //ポータル会員ID
    public Boolean isDeleteIntroMail { get; set; }//紹介メール情報削除メッセージ常時フラグ  //追加要望
    public String MSG_COM_V_EXECUTE_NON_MERGE { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_EXECUTE_NON_MERGE); } private set; } //js用名寄せ不要確認メッセージ
    public String MSG_COM_I_NON_MERGE_END { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_NON_MERGE_END); } private set; } //js用名寄せ不要完了メッセージ
    public String MSG_COM_V_EXECUTE_MERGE { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_EXECUTE_MERGE); } private set; } //js用名寄せ実行確認メッセージ
    public String MSG_COM_I_MERGE_END { get { return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_MERGE_END); } private set; } //js用名寄せ実行完了メッセージ
    public String MSG_COM_I_MERGE_END_SENDSTOP { get { return CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_I_MERGE_END_SENDSTOP); } private set; } //js用紹介メール情報削除メッセージ  //追加要望

    //Private変数
    private id targetAccountId;
    private List<Account> candidateResultList;
    private Boolean emailChangeFlg = false;     // 名寄せによりメールが変更されたか判定
    private Boolean phoneChangeFlg = false;     // 名寄せにより電話番号が変更されたか判定  

    //コンストラクタ
    public GA102003Controller() {

        try{

            //targetAccountIdを設定
            targetAccountId = ApexPages.currentPage().getParameters().get('Id');

            //レコード情報取得
            this.targetRecord = SelectRecordInfo(targetAccountId);
            this.isOpetionPortal = AuthorityCheckUtil.getAuthorityOptionPortal(false);         //自社ポータル権限を取得
            portalMemberId  = '';
            for( Member__c mem : targetRecord.MemberAccount__r){
                portalMemberId  += mem.Email__c + ', ';	//本会員項目の文字列作成
            }
            if(String.isNotEmpty(portalMemberId)){
                    portalMemberId  = portalMemberId.removeEnd(', ');	//最後の,を除去
            }
                    
            //追加要望 追加 Start
            this.isDeleteIntroMail = false;
            //追加要望 追加 End
            
            //検索対象リスト取得
            this.candidateResultList = NameMergeUtil.getCustomerMergeList(targetRecord, null);

            //表示用リストをnewする。
            displayCandidateResult = new List<Selected>();
            Integer IndexCount = 0;


            //内部クラスSelectedにインデックスをセットする。
            for(Account candidate :candidateResultList) {
                Selected a1 = new Selected(candidate, Indexcount, isOpetionPortal);
                displayCandidateResult.add(a1);
                IndexCount += 1;
            }

        } catch(Exception e) {

            //エラーを設定
            isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }



    }

    //リスト表示用内部クラス
    public class Selected {

        public Account candidateResult { get; set; }
        public Integer setIndex { get; set; }
        public Member__c candidateMember{ get; set; }	//本会員

        public Selected(Account candidateResult, Integer setIndex, Boolean isOpetionPortal) {
            this.candidateResult = candidateResult;
            this.setIndex = setIndex;

            
            if (! candidateResult.MemberAccount__r.isEmpty()){	//関連する本会員がある
                 candidateMember = candidateResult.MemberAccount__r[0];      //本会員の情報をcandidateMemberに収納
            }else{
                 candidateMember = new Member__c();
            }
        }

    }

    //名寄せ不要メソッド
    public void margeCompleted() {
        Savepoint sp = Database.setSavepoint();
        try{
            hasErrorMessage = false;

            //楽観ロックチェック
            optimisticLockCheck(targetRecord);

            //2020.09.03 名寄せ完了フラグと名寄せ不要フラグを更新
            Account account = new Account(id = targetAccountId, IsMergeCompletedFlag__c = true, IsMergeUnnecessaryFlag__c = true);

            SecureDML.secureUpdate(account);

        } catch(Exception e) {
            Database.rollback(sp);
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }

    }

    //選択取引先名寄せ実行メソッド
    public void mergeAccounts() {
        Savepoint sp = Database.setSavepoint();
        try{
            System.debug(mergeSelectedIndex);
            hasErrorMessage = false;

            //楽観ロックチェック（元レコード）
            optimisticLockCheck(targetRecord);

            //楽観ロックチェック（対象レコード）
            optimisticLockCheck(displayCandidateResult [mergeSelectedIndex].candidateResult);

            //2020.09.03 名寄せ検索に使用する項目をすべてコピーしておく
            Account updateResult = new Account( id = displayCandidateResult [mergeSelectedIndex].candidateResult.id,
                                                Name = displayCandidateResult [mergeSelectedIndex].candidateResult.Name,
                                                Phone = displayCandidateResult [mergeSelectedIndex].candidateResult.Phone,
                                                Phone2__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Phone2__c,
                                                Phone3__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Phone3__c,
                                                Email__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Email__c,
                                                Email2__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Email2__c,
                                                Email3__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Email3__c,
                                                IsMergeUnnecessaryFlag__c = displayCandidateResult [mergeSelectedIndex].candidateResult.IsMergeUnnecessaryFlag__c
            );

            //名寄せメール更新メソッド起動
            updateResult = mergeEmail(updateResult, targetRecord, displayCandidateResult [mergeSelectedIndex].candidateResult);


            //名寄せ電話番号更新メソッド起動
            updateResult = mergePhone(updateResult, targetRecord, displayCandidateResult [mergeSelectedIndex].candidateResult);


            //名寄せ対象再検索
            List<Account> AccountResultList = NameMergeUtil.getCustomerMergeList(updateResult, targetRecord.Id);

            //名寄せ完了フラグ設定
            if(AccountResultList.isEmpty()) {
                updateResult.IsMergeCompletedFlag__c = true;
            } else {
                updateResult.IsMergeCompletedFlag__c = false;
                //2020.09.03 名寄せで一致対象とされた取引先の名寄せ不要フラグを更新
                NameMergeUtil.setCustomerMergeUnnecessaryFlag(AccountResultList);
            }

            //2020.09.11 名寄せ実行時、無条件で名寄せ不要フラグを初期化する
            updateResult.IsMergeUnnecessaryFlag__c = false;
            //問合せNo341で追加　元レコードの電話反響登録済みフラグがtrueの場合、名寄せ先レコードの電話反響登録済みフラグを更新
            if(targetRecord.EchoTelephoneFlag__c){
                updateResult.EchoTelephoneFlag__c = true;
            }
            // ▼問合せNo411で追加　元レコードのリベロ反響登録済みフラグ、LINE反響済みフラグがtrueの場合、名寄せ先レコードのリベロ反響フラグ、LINE反響フラグを更新
            if(targetRecord.EchoLineFlag__c){
                updateResult.EchoLineFlag__c = true;
            }
            if(targetRecord.EchoLiveroFlag__c){
                updateResult.EchoLiveroFlag__c = true;
            }
			// ▲問合せNo411で追加

            //追加要望 追加 Start
            //権限があり、残る取引先に紹介メール情報がある場合
            if (isOpetionPortal && !displayCandidateResult [mergeSelectedIndex].candidateResult.IntroductionMailInformationAccount__r.isEmpty()){
                updateResult.IntroMailInfoStatus__c = CommonConst_ptl.INTRODUCTION_SENDSTOP;//配信状況を配信停止に変更                
            }
            //追加要望 追加 End
            SecureDML.secureUpdate(updateResult);


            //親変更：申込
            for (Application__c applicationAccountData :targetRecord.ApplicationAccount__r) {
                applicationAccountData.Account__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Id;
            }
            SecureDML.secureUpdate(targetRecord.ApplicationAccount__r);


            //親変更：来店カード
            for (VisitCard__c visitCardsAccountData :targetRecord.VisitsCardAccount__r) {
                visitCardsAccountData.Account__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Id;
            }
            SecureDML.secureUpdate(targetRecord.VisitsCardAccount__r);


			// 親変更、物件条件名重複対応：お客様物件条件
			mergeAccountPropertyConditions();//2021.10.08 No.307 対応で追加

            //親変更：お気に入り物件
            //2020/6/25：追加　残す側（名寄せする側）のお気に入り物件を取得
            List<FavoriteProperty__c> candiateFavoritePropertyList =[SELECT Property__c 
                                                                 FROM FavoriteProperty__c 
                                                                 WHERE Account__c = :displayCandidateResult [mergeSelectedIndex].candidateResult.Id];
            //2020/6/25：追加　残す側の物件を残す側物件Idセットに追加
            Set<Id> candiateFavoritePropertySet = new Set<Id>();
            for (FavoriteProperty__c favoritePropertyAccountData : candiateFavoritePropertyList){
                candiateFavoritePropertySet.add(favoritePropertyAccountData.Property__c);
            }
            
            for (FavoriteProperty__c favoritePropertyAccountData :targetRecord.FavoritePropertyAccount__r) {
                //2020/6/25：追加　対象の消す側の物件項目が残す側物件IDセットの中のIDと重複していない場合のみ、取引先を残す側の取引先に変更
                if (! candiateFavoritePropertySet.contains(favoritePropertyAccountData.Property__c)){
                    favoritePropertyAccountData.Account__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Id;
                }
            }
            SecureDML.secureUpdate(targetRecord.FavoritePropertyAccount__r);

            
            //親変更：仮見積
            for (ProvisionalQuote__c provisionalQuoteAccountData :targetRecord.ProvisionalQuoteAccount__r) {
                provisionalQuoteAccountData.Account__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Id;
            }
            SecureDML.secureUpdate(targetRecord.ProvisionalQuoteAccount__r);

            //親変更：メール時間指定送信
            for (MailTimeSpecificationSending__c mailTimeSpecificationSendingAccountData :targetRecord.MailTimeSpecificationSendingAccount__r) {
                mailTimeSpecificationSendingAccountData.Account__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Id;
            }
            SecureDML.secureUpdate(targetRecord.MailTimeSpecificationSendingAccount__r);
            
            //親変更：メール下書き
            for (MailDraft__c mailDraftData :targetRecord.MailDraftAccount__r) {
                mailDraftData.Account__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Id;
            }
            SecureDML.secureUpdate(targetRecord.MailDraftAccount__r);

            //親変更：本会員
            if (isOpetionPortal && ! targetRecord.MemberAccount__r.isEmpty()){      //権限がある　かつ　本会員の関連がある場合のみ登録、更新を行う
                List<MemberDifference__c> insertMemDiffList = new List<MemberDifference__c>();						//insert用本会員差分宣言
                for (Member__c mem :targetRecord.MemberAccount__r) {
                    mem .Account__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Id;	//本会員の取引先変更

                    //本会員差分の作成
                    MemberDifference__c memDiff = new MemberDifference__c(				
                        CrudCd__c = 'U'               //クラッドコード
                        ,LinkCd__c = 'StoH'            //連携コード
                        ,MemberId__c = mem.MemberId__c //会員ID
                        ,Email__c = PortalUtil.encryption(mem.Email__c)        //メールアドレス（暗号化）
                        ,Tell__c  = PortalUtil.encryption(mem.Tell__c)        //電話番号（暗号化）
                        ,Account__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Id    //取引先
                        ,QuitDate__c = mem.QuitDate__c      //退会日
                        ,Blacklist__c = mem.BlackList__c     //ブラックリスト
                        ,MemberStatus__c = mem.MemberStatus__c      //会員状況
                        
                    );

                    insertMemDiffList.add(memDiff); 
                }
                if (! targetRecord.MemberAccount__r.isEmpty()){	//関連する本会員が空じゃなければ更新
                    SecureDML.secureUpdate(targetRecord.MemberAccount__r);
                }
                if (! insertMemDiffList.isEmpty()){			//insert用本会員差分が空じゃなければ更新

                    SecureDML.secureInsert(insertMemDiffList);
                }
            }            
            
            //親変更：対応
            for (Correspond__c CorrespondData :targetRecord.CorrespondAccountId__r) {
                CorrespondData.AccountId__c = displayCandidateResult [mergeSelectedIndex].candidateResult.Id;
            }
            SecureDML.secureUpdate(targetRecord.CorrespondAccountId__r);
            
            //親変更：行動
            for (Event eventsAccountIdData :targetRecord.Events) {
                eventsAccountIdData.WhatId = displayCandidateResult [mergeSelectedIndex].candidateResult.Id;
            }
            SecureDML.secureUpdate(targetRecord.Events);
            
            //追加要望 追加 Start
            //親変更：紹介メール情報
            if (isOpetionPortal && !displayCandidateResult [mergeSelectedIndex].candidateResult.IntroductionMailInformationAccount__r.isEmpty()){
                //対象レコードに紹介メール情報がある場合削除
                SecureDML.secureDelete(displayCandidateResult [mergeSelectedIndex].candidateResult.IntroductionMailInformationAccount__r);
                this.isDeleteIntroMail = true;
            }
            //削除される取引先に紹介メール情報がある場合もメッセージ表記フラグをtrueにする
            if (isOpetionPortal && !targetRecord.IntroductionMailInformationAccount__r.isEmpty()){
                SecureDML.secureDelete(targetRecord.IntroductionMailInformationAccount__r);
                this.isDeleteIntroMail = true;
            }
            //追加要望 追加 End

			// ▼ 2022.1.7 LINE連携対応より、LINE会員、LINE会員候補の名寄せ処理を追加、コードの見直し
			// 空室予約物件の名寄せ
			this.mergeVacancyReservationProp(updateResult.Id, targetRecord.Id);

			// LINE会員の名寄せ
			this.mergeLineMember(updateResult.Id, targetRecord.Id);

			// LINE会員候補の名寄せ
			this.mergeLineMemberCandidate(updateResult.Id, targetRecord.Id);
			// ▲ 2022.1.7

            SecureDML.secureDelete(targetRecord);

            
            //対応明細の追加の為に、最新の対応を取得
            List<Correspond__c> cList = [SELECT id FROM Correspond__c WHERE AccountId__c =:displayCandidateResult[mergeSelectedIndex].candidateResult.Id ORDER BY SystemModStamp DESC LIMIT 1];
            
            if (!cList.isEmpty()) {
                //対応明細を追加
                CorrespondDetail__c insertData = new CorrespondDetail__c(
                      SupportedDateTime__c  = CommonUtil.getNow()  //対応日時
                    , SupportedTitle__c     = '名寄せ'             //対応表題
                    , SupportedContent__c   = CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_MERGE_HISTORY, displayCandidateResult [mergeSelectedIndex].candidateResult.Name, targetRecord.Name)//対応内容 
                    , CorrespondType__c     = CommonConst.TASK_CORRESPONDTYPE_MERGE //対応種別
                    , Staff__c              = UserInfo.getUserId() //担当者
                    , Corresponds__c        = cList[0].Id          //対応番号
                );
                
                SecureDML.secureInsert(insertData);
            }
            


        } catch(Exception e) {
            Database.rollback(sp);
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

	// ▼2021.10.08 No.307 対応で追加
	/**
     * お客様物件条件の名寄せ
	 */
	private void mergeAccountPropertyConditions(){
		Map<String, Map<String,Integer>> apcDuplicationMap = new Map<String, Map<String,Integer>>();	//物件条件名をキーとしてた、Id、重複数マップ
		Map<String, AccountPropertyConditions__c> upudateApcMap = new Map<String, AccountPropertyConditions__c>();	//更新対象お客様物件条件
		AccountPropertyConditions__c targetApc = new AccountPropertyConditions__c();	//元取引先レコードの物件条件を元としたお客様物件条件

		targetApc.Name = targetRecord.PropertyConditionsName__c;								//物件条件名
		targetApc.IsReservePropertyConditions__c = targetRecord.IsReservePropertyConditions__c;	//予約物件条件
		targetApc.DesiredArea__c = targetRecord.DesiredArea__c;					//希望地域
		targetApc.DesiredTrainRoute1__c = targetRecord.DesiredTrainRoute1__c;	//希望沿線１
		targetApc.DesiredTrainRoute2__c = targetRecord.DesiredTrainRoute2__c;	//希望沿線２
		targetApc.DesiredTrainRoute3__c = targetRecord.DesiredTrainRoute3__c;	//希望沿線３
		targetApc.WalkingTime__c = targetRecord.WalkingTime__c;	//徒歩
		targetApc.IsOneRoom__c = targetRecord.IsOneRoom__c;		//ワンルーム
		targetApc.Is1K__c = targetRecord.Is1K__c;				//1K
		targetApc.Is1DK__c = targetRecord.Is1DK__c;				//1DK
		targetApc.Is1LDK1SLDK__c = targetRecord.Is1LDK1SLDK__c;	//1LDK/SLDK
		targetApc.Is2K2DK__c = targetRecord.Is2K2DK__c;			//2K/DK
		targetApc.Is2LDK2SLDK__c = targetRecord.Is2LDK2SLDK__c;	//2LDK/SLDK
		targetApc.Is3K3DK__c = targetRecord.Is3K3DK__c;			//3K/DK
		targetApc.Is3LDK3SLDK__c = targetRecord.Is3LDK3SLDK__c;	//3LDK/SLDK
		targetApc.Is4K4DK4LDKFrom__c = targetRecord.Is4K4DK4LDKFrom__c;			//4K/DK/LDK~
		targetApc.IsWooden__c = targetRecord.IsWooden__c;						//木造
		targetApc.IsLightweightSteel__c = targetRecord.IsLightweightSteel__c;	//軽量鉄骨
		targetApc.IsSteel__c = targetRecord.IsSteel__c;				//鉄骨造
		targetApc.IsRC__c = targetRecord.IsRC__c;					//RC
		targetApc.IsSRC__c = targetRecord.IsSRC__c;					//SRC
		targetApc.IsNorth__c = targetRecord.IsNorth__c;				//北
		targetApc.IsNorthEast__c = targetRecord.IsNorthEast__c;		//北東
		targetApc.IsEast__c = targetRecord.IsEast__c;				//東
		targetApc.IsSouthEast__c = targetRecord.IsSouthEast__c;		//南東
		targetApc.IsSouth__c = targetRecord.IsSouth__c;				//南
		targetApc.IsSouthWest__c = targetRecord.IsSouthWest__c;		//南西
		targetApc.IsWest__c = targetRecord.IsWest__c;				//西
		targetApc.IsNorthWest__c = targetRecord.IsNorthWest__c;		//北西
		targetApc.IsNonDeposit__c = targetRecord.IsNonDeposit__c;	//敷金/保証金なし
		targetApc.IsNonKeyMoney__c = targetRecord.IsNonKeyMoney__c;			//礼金なし
		targetApc.IsNonCleaningFee__c = targetRecord.IsNonCleaningFee__c;	//定額修繕費なし
		targetApc.IsNonRenewalFee__c = targetRecord.IsNonRenewalFee__c;		//更新料なし
		targetApc.RentFeeFrom__c = targetRecord.RentFeeFrom__c;				//賃料から
		targetApc.RentFeeTo__c = targetRecord.RentFeeTo__c;					//賃料まで
		targetApc.IsIncludeManagementFee__c = targetRecord.IsIncludeManagementFee__c;	//管理費込み
		targetApc.IsIncludeParkingFee__c = targetRecord.IsIncludeParkingFee__c;			//駐車場代込み
		targetApc.OccupancyAreaLowerLimit__c = targetRecord.OccupancyAreaLowerLimit__c;	//占有面積（下限）
		targetApc.OccupancyAreaUpperLimit__c = targetRecord.OccupancyAreaUpperLimit__c;	//占有面積（上限）
		targetApc.BuildingAge__c = targetRecord.BuildingAge__c;			//築年数
		targetApc.IsDetachedHouse__c = targetRecord.IsDetachedHouse__c;	//戸建て
		targetApc.IsMaisonette__c = targetRecord.IsMaisonette__c;		//メゾネット
		targetApc.IsLoft__c = targetRecord.IsLoft__c;					//ロフト
		targetApc.IsDesigners__c = targetRecord.IsDesigners__c;			//デザイナーズ
		targetApc.IsRenovation__c = targetRecord.IsRenovation__c;		//リノベーション
		targetApc.IsCondominiumRental__c = targetRecord.IsCondominiumRental__c;//分譲賃貸
		targetApc.IsAllWestern__c = targetRecord.IsAllWestern__c;			//オール洋間
		targetApc.IsFirstFloor__c = targetRecord.IsFirstFloor__c;			//1階
		targetApc.IsSecondFloorOver__c = targetRecord.IsSecondFloorOver__c;	//2階以上
		targetApc.IsTopFloor__c = targetRecord.IsTopFloor__c;				//最上階
		targetApc.IsCornerRoom__c = targetRecord.IsCornerRoom__c;			//角部屋
		targetApc.IsBalcony__c = targetRecord.IsBalcony__c;					//バルコニー
		targetApc.IsRoofBalcony__c = targetRecord.IsRoofBalcony__c;			//ルーフバルコニー
		targetApc.IsPrivateGarden__c = targetRecord.IsPrivateGarden__c;		//専用庭
		targetApc.IsParking__c = targetRecord.IsParking__c;					//駐車場空きあり
		targetApc.IsInSiteParking__c = targetRecord.IsInSiteParking__c;		//敷地内駐車場
		targetApc.IsPluralCarParking__c = targetRecord.IsPluralCarParking__c;//駐車場2台可
		targetApc.IsBuiltInGarage__c = targetRecord.IsBuiltInGarage__c;		//ビルトインガレージ
		targetApc.IsCarport__c = targetRecord.IsCarport__c;					//カーポート
		targetApc.IsBicycleParking__c = targetRecord.IsBicycleParking__c;	//駐輪場
		targetApc.IsBikeStorage__c = targetRecord.IsBikeStorage__c;			//バイク可
		targetApc.IsSmallBike__c = targetRecord.IsSmallBike__c;				//小型バイク
		targetApc.IsMediumBike__c = targetRecord.IsMediumBike__c;			//中型バイク
		targetApc.IsLargeBike__c = targetRecord.IsLargeBike__c;				//大型バイク
		targetApc.IsElevator__c = targetRecord.IsElevator__c;				//エレベーター
		targetApc.IsDeliveryBox__c = targetRecord.IsDeliveryBox__c;			//宅配ボックス
		targetApc.IsCounterKitchen__c = targetRecord.IsCounterKitchen__c;	//カウンターキッチン
		targetApc.IsSystemKitchen__c = targetRecord.IsSystemKitchen__c;		//システムキッチン
		targetApc.IsGasStove__c = targetRecord.IsGasStove__c;				//ガスコンロ
		targetApc.IsElectricStove__c = targetRecord.IsElectricStove__c;		//電気コンロ
		targetApc.IsInductionHeating__c = targetRecord.IsInductionHeating__c;//IHコンロ
		targetApc.IsTwoGasStove__c = targetRecord.IsTwoGasStove__c;			//コンロ2口
		targetApc.IsMoreGasStove__c = targetRecord.IsMoreGasStove__c;		//コンロ3口以上
		targetApc.IsSepalateBathAndRestroom__c = targetRecord.IsSepalateBathAndRestroom__c;	//バス・トイレ別
		targetApc.IsAditionalBoiling__c = targetRecord.IsAditionalBoiling__c;				//追焚機能
		targetApc.IsDehumidifierForBathroom__c = targetRecord.IsDehumidifierForBathroom__c;	//浴室乾燥機
		targetApc.IsWashlet__c = targetRecord.IsWashlet__c;					//温水洗浄便座
		targetApc.IsShowerWashBasin__c = targetRecord.IsShowerWashBasin__c;	//シャワー付き洗面台
		targetApc.IsRegalLavatory__c = targetRecord.IsRegalLavatory__c;		//洗面所独立
		targetApc.IsInnerLandry__c = targetRecord.IsInnerLandry__c;			//室内洗濯機置場
		targetApc.IsTownGas__c = targetRecord.IsTownGas__c;					//都市ガス
		targetApc.IsPropaneGas__c = targetRecord.IsPropaneGas__c;			//プロパンガス
		targetApc.IsAllElectric__c = targetRecord.IsAllElectric__c;			//オール電化
		targetApc.IsAirConditioner__c = targetRecord.IsAirConditioner__c;	//エアコン
		targetApc.IsFloorHeating__c = targetRecord.IsFloorHeating__c;		//床暖房
		targetApc.IsShoesBox__c = targetRecord.IsShoesBox__c;				//シューズボックス
		targetApc.IsShoeCloak__c = targetRecord.IsShoeCloak__c;				//シューズクローク
		targetApc.IsWalkInCloset__c = targetRecord.IsWalkInCloset__c;		//ウォークインクローゼット
		targetApc.IsTrunkRoom__c = targetRecord.IsTrunkRoom__c;				//トランクルーム
		targetApc.IsBSAntenna__c = targetRecord.IsBSAntenna__c;				//BSアンテナ
		targetApc.IsCSAntenna__c = targetRecord.IsCSAntenna__c;				//CSアンテナ
		targetApc.IsCATV__c = targetRecord.IsCATV__c;						//CATV
		targetApc.IsInternetFree__c = targetRecord.IsInternetFree__c;		//ネット使用料無料
		targetApc.IsMonitorIntercom__c = targetRecord.IsMonitorIntercom__c;	//モニター付きインターホン
		targetApc.IsAutoLock__c = targetRecord.IsAutoLock__c;				//オートロック
		targetApc.IsFurniture__c = targetRecord.IsFurniture__c;				//家具付き
		targetApc.IsHomeAppliance__c = targetRecord.IsHomeAppliance__c;		//家電付き
		targetApc.IsNoGuarantor__c = targetRecord.IsNoGuarantor__c;			//保証人不要
		targetApc.IsNonGuaranteeidCompany__c = targetRecord.IsNonGuaranteeidCompany__c;	//保証会社不要
		targetApc.IsMusicalInstruments__c = targetRecord.IsMusicalInstruments__c;		//楽器相談可
		targetApc.IsForeigner__c = targetRecord.IsForeigner__c;							//外国人契約可
		targetApc.IsOfficeAvailable__c = targetRecord.IsOfficeAvailable__c;				//事務所利用可
		targetApc.IsWelfareAvailable__c = targetRecord.IsWelfareAvailable__c;			//生活保護契約可
		targetApc.IsPet__c = targetRecord.IsPet__c;				//ペット可
		targetApc.IsLargePet__c = targetRecord.IsLargePet__c;	//ペット(大型犬)
		targetApc.IsMiddlePet__c = targetRecord.IsMiddlePet__c;	//ペット(中型犬)
		targetApc.IsSmallPet__c = targetRecord.IsSmallPet__c;	//ペット(小型犬)
		targetApc.IsCat__c = targetRecord.IsCat__c;				//ペット(猫)
		targetApc.IsOtherPet__c = targetRecord.IsOtherPet__c;	//ペット(その他)
		targetApc.IsTwoTenant__c = targetRecord.IsTwoTenant__c;	//2人入居可
		targetApc.IsRoomShare__c = targetRecord.IsRoomShare__c;	//ルームシェア可
		targetApc.IsIppambutsu__c = targetRecord.IsIppambutsu__c;//一般物
		targetApc.IsElderly__c = targetRecord.IsElderly__c;		//高齢者歓迎
		targetApc.IsWoman__c = targetRecord.IsWoman__c;			//女性限定
		targetApc.IsStudent__c = targetRecord.IsStudent__c;		//学生限定マンション
		targetApc.CarCount__c = targetRecord.CarCount__c;		//台数
		targetApc.ParkingFeeLimit__c = targetRecord.ParkingFeeLimit__c;//1台当たりの料金上限
		targetApc.Parking__c = targetRecord.Parking__c;			//駐車場
		targetApc.DesiredJuniorHighSchoolArea__c = targetRecord.DesiredJuniorHighSchoolArea__c;//中学校希望学区（エリア）
		targetApc.DesiredElementarySchoolArea__c = targetRecord.DesiredElementarySchoolArea__c;//小学校希望学区（エリア）

		//名寄せ元取引先レコードの物件条件を元としたお客様物件条件を重複番号マップに追加する
		apcDuplicationMap = splitApcNameDuplNum(targetApc.Name, '取引先1', apcDuplicationMap);
		//更新対象お客様物件条件にセット
		upudateApcMap.put('取引先1', targetApc);

		//名寄せ先取引先レコードの物件条件名を重複番号マップに追加する
		apcDuplicationMap = splitApcNameDuplNum(displayCandidateResult[mergeSelectedIndex].candidateResult.PropertyConditionsName__c, '取引先2', apcDuplicationMap);

		//名寄せ先取引先と紐づくお客様物件条件の物件条件名を重複番号マップに追加する
		for (AccountPropertyConditions__c apcData :displayCandidateResult[mergeSelectedIndex].candidateResult.AccountPropertyConditionss__r){
			apcDuplicationMap = splitApcNameDuplNum(apcData.Name, apcData.Id, apcDuplicationMap);
		}

		//名寄せ先取引先と紐づくお客様物件条件の物件条件名を重複番号マップに追加し、更新対象にセットする
		for (AccountPropertyConditions__c apcData :targetRecord.AccountPropertyConditionss__r){
			//物件条件名を物件条件名と重複番号に分割し、重複番号マップに追加する
			apcDuplicationMap = splitApcNameDuplNum(apcData.Name, apcData.Id, apcDuplicationMap);

			//更新対象お客様物件条件にセット
			upudateApcMap.put(apcData.Id, apcData);
		}

		//物件条件名をキーとしてた、Id、重複数マップをもとに更新対象お客様物件条件を修正
		for(String apcName: apcDuplicationMap.keySet()){

			for(String apcId: apcDuplicationMap.get(apcName).keySet()){
				//更新対象お客様物件条件のみを処理対象とする
				if(!upudateApcMap.containsKey(apcId)){
					continue;
				}

				//物件条件名の一致する、自分以外の重複番号マップ
				Map<String,Integer> containCheckMap = apcDuplicationMap.get(apcName).clone();
				containCheckMap.remove(apcId);

				Integer duplicationNum = apcDuplicationMap.get(apcName).get(apcId);//重複番号
				if(containCheckMap.values().contains(duplicationNum)){
					//物件条件名と重複番号ともに重複する場合、重複しない重複番号に更新する
					while(containCheckMap.values().contains(duplicationNum)){
						duplicationNum++;
					}
				}
				String updateApcName = apcName;
				if(duplicationNum != 0){
					//重複番号がある場合、'物件条件名(重複番号)'の形式とする
					updateApcName += '(' + String.valueOf(duplicationNum) + ')';
					//重複番号マップを更新
					apcDuplicationMap.get(apcName).put(apcId, duplicationNum);
				}
			
				//お客様物件条件の物件条件名と取引先を更新
				AccountPropertyConditions__c upudateApc = upudateApcMap.get(apcId);
				upudateApc.Name = updateApcName;
				upudateApc.Account__c = displayCandidateResult[mergeSelectedIndex].candidateResult.id;
			}
		}

		if(!upudateApcMap.isEmpty()){
			SecureDML.secureUpsert(upudateApcMap.values());
		}
	}

	/**
	 * 物件条件名を物件条件名と重複番号に分割し、重複番号マップに追加する
	 * @param String apcName 物件条件名
	 * @param String apcId 重複番号マップに使用するお客様物件条件Id、取引先を使用する場合は区別するための文字列となる
	 * @param Map<String,Map<String,Integer>> apcDuplicationMap 物件条件名、お客様物件条件Idをキーとした重複番号マップ
	 * @return Map<String,Map<String,Integer>> 更新後の物件条件名、お客様物件条件Idをキーとした重複番号マップ
	 */
	private Map<String,Map<String,Integer>> splitApcNameDuplNum(String apcName, String apcId, Map<String,Map<String,Integer>> apcDuplicationMap){
		Integer duplicationNum = 0;
		//終端が'(数値)'の形式となっているか確認する
		if(Pattern.matches('.+[\\(]{1}\\d{1,4}[\\)]{1}+$', apcName)){
			//物件条件名の終端が(数字)となっている場合、既に重複判定の書式として、重複数マップに入れておく
			duplicationNum = Integer.valueOf(apcName.substringAfterLast('(').remove(')'));
			apcName = apcName.substringBeforeLast('(');
		}

		//物件条件名をキーとしてた、Id、重複数マップに値を入れる
		if(!apcDuplicationMap.containsKey(apcName)){
			apcDuplicationMap.put(apcName, new Map<String, Integer>());
		}

		apcDuplicationMap.get(apcName).put(apcId, duplicationNum);

		return apcDuplicationMap;
	}
	// ▲2021.10.08 No.307 対応で追加

    // ▼ 2022.1.7 LINE連携対応より、LINE会員、LINE会員候補の名寄せ処理を追加、コードの見直し
	/**
	 * 空室予約物件の名寄せ
	 * @param Id updAccId 名寄せ先の取引先.ID
	 * @param Id delAccId 削除される取引先.ID
	 */
	private void mergeVacancyReservationProp(Id updAccId, Id delAccId) {
			
		// 重複データの取得（key:建物.ID、value:間取り）
		List<VacancyReservationProperty__c> duplicateBuildingList = this.selectVacancyReservationProperty(updAccId);
		Map<String, Set<String>> duplicateMap = CommonUtil.getKeysSetVal(
			duplicateBuildingList
			, VacancyReservationProperty__c.Building__c.getDescribe().getName()
			, VacancyReservationProperty__c.PropertyFloorPlan__c.getDescribe().getName()
		);
			
		// 名寄せ対象の取得
		List<VacancyReservationProperty__c> mergeTargetList = this.selectVacancyReservationProperty(delAccId);
			
		// 空室予約物件のDML処理用
		List<SObject> delObjList = new List<SObject>();
		List<SObject> updObjList = new List<SObject>();
		SObject tmpObj;

		// 名寄せ値の取得
		for (VacancyReservationProperty__c mergeTarget : mergeTargetList) {

			// 重複データの削除（建物、取引先、間取りの一意チェック）
			if (duplicateMap.containsKey(mergeTarget.Building__c)
				&& duplicateMap.get(mergeTarget.Building__c).contains(mergeTarget.PropertyFloorPlan__c)) {

				tmpObj = new VacancyReservationProperty__c(Id = mergeTarget.Id);
				delObjList.add(tmpObj);
			
			// 更新
			} else {
				tmpObj = new VacancyReservationProperty__c(
					Id = mergeTarget.Id
					, Account__c = updAccId
				);

				updObjList.add(tmpObj);
			}
		}

		// 名寄せ処理
		SecureDML.secureUpdate(updObjList);
		SecureDML.secureDelete(delObjList);
	}

	/**
	 * LINE会員の名寄せ
	 * @param Id updAccId 名寄せ先の取引先.ID
	 * @param Id delAccId 削除される取引先.ID
	 */
	private void mergeLineMember(Id updAccId, Id delAccId) {

		// 重複データの取得
		List<LineMember__c> duplicateList = this.selectLineMember(updAccId);

		// 名寄せ対象の取得
		List<LineMember__c> mergeTargetList = this.selectLineMember(delAccId);

		// LINE会員のDML処理用
		List<SObject> delObjList = new List<SObject>();
		List<SObject> updObjList = new List<SObject>();
		SObject tmpObj;

		// 名寄せ値の取得
		for (LineMember__c mergeTarget : mergeTargetList) {

			// 重複データの削除
			if (duplicateList.size() > 0) {
				tmpObj = new LineMember__c(Id = mergeTarget.Id);
				delObjList.add(tmpObj);

			// 更新
			} else {
				tmpObj = new LineMember__c(
					Id = mergeTarget.Id
					, Account__c = updAccId
				);

				updObjList.add(tmpObj);
			}
		}

		// 名寄せ処理
		SecureDML.secureUpdate(updObjList);
		SecureDML.secureDelete(delObjList);
	}

	/**
	 * LINE会員候補の名寄せ
	 * @param Id updAccId 名寄せ先の取引先.ID
	 * @param Id delAccId 削除される取引先.ID
	 */
	private void mergeLineMemberCandidate(Id updAccId, Id delAccId) {

		// 重複データの取得
		List<LineMemberCandidate__c> duplicateList = this.selectLineMemberCandidate(updAccId);

		// 名寄せ対象の取得
		List<LineMemberCandidate__c> mergeTargetList = this.selectLineMemberCandidate(delAccId);

		// LINE会員候補のDML処理用
		List<SObject> delObjList = new List<SObject>();
		List<SObject> updObjList = new List<SObject>();
		SObject tmpObj;

		// 名寄せ値の取得
		for (LineMemberCandidate__c mergeTarget : mergeTargetList) {

			// 重複データの削除
			if (duplicateList.size() > 0) {
				tmpObj = new LineMemberCandidate__c(Id = mergeTarget.Id);
				delObjList.add(tmpObj);

			// 更新
			} else {
				tmpObj = new LineMemberCandidate__c(
					Id = mergeTarget.Id
					, Account__c = updAccId
				);

				updObjList.add(tmpObj);
			}
		}

		// 名寄せ処理
		SecureDML.secureUpdate(updObjList);
		SecureDML.secureDelete(delObjList);
	}

	/**
	 * 空室予約物件の取得
	 * @param Id condAccountId 取引先ID
	 * @return List<VacancyReservationProperty__c> 空室予約物件
	 */
	private List<VacancyReservationProperty__c> selectVacancyReservationProperty(Id condAccountId) {

		List<VacancyReservationProperty__c> vrpList = [
			SELECT
				Id
				, Building__c
				, Account__c
				, PropertyFloorPlan__c
			FROM VacancyReservationProperty__c
			WHERE Account__c = :condAccountId
		];

		return vrpList;
	}

	/**
	 * LINE会員の取得
	 * @param Id condAccountId 取引先ID
	 * @return List<LineMember__c> LINE会員
	 */
	private List<LineMember__c> selectLineMember(Id condAccountId) {

		List<LineMember__c> lineMemberList = [
			SELECT
				Id
				, Account__c
			FROM LineMember__c
			WHERE Account__c = :condAccountId
		];

		return lineMemberList;
	}

	/**
	 * LINE会員候補の取得
	 * @param Id condAccountId 取引先ID
	 * @return List<LineMemberCandidate__c> LINE会員候補
	 */
	private List<LineMemberCandidate__c> selectLineMemberCandidate(Id condAccountId) {

		List<LineMemberCandidate__c> lineMemberCandidateList = [
			SELECT
				Id
				, Account__c
			FROM LineMemberCandidate__c
			WHERE Account__c = :condAccountId
		];

		return lineMemberCandidateList;
	}
	// ▲ 2022.1.7

    //レコード情報取得
    private Account SelectRecordInfo(Id targetAccountId) {
        List<Account> targetRecordList = [SELECT id, 
			Name, 
			NameKana__c, 
			PostalCode__c, 
			Address__c, 
			Email__c, 
			Email2__c, 
			Email3__c, 
			Phone, 
			Phone2__c, 
			Phone3__c, 
			//2020.09.03 名寄せ不要フラグ追加
			IsMergeUnnecessaryFlag__c,
			//問合せNo341で追加　電話反響登録済みフラグ
			EchoTelephoneFlag__c,
			EchoLineFlag__c,
			EchoLiveroFlag__c,
			SystemModstamp,
			// ▼2021.10.08 No.307 対応で物件条件項目追加
			PropertyConditionsName__c,		//物件条件名
			IsReservePropertyConditions__c,	//予約物件条件
			DesiredArea__c,					//希望地域
			DesiredTrainRoute1__c,	//希望沿線１
			DesiredTrainRoute2__c,	//希望沿線２
			DesiredTrainRoute3__c,	//希望沿線３
			WalkingTime__c,			//徒歩
			IsOneRoom__c,			//ワンルーム
			Is1K__c,				//1K
			Is1DK__c,				//1DK
			Is1LDK1SLDK__c,			//1LDK/SLDK
			Is2K2DK__c,				//2K/DK
			Is2LDK2SLDK__c,			//2LDK/SLDK
			Is3K3DK__c,				//3K/DK
			Is3LDK3SLDK__c,			//3LDK/SLDK
			Is4K4DK4LDKFrom__c,		//4K/DK/LDK~
			IsWooden__c,			//木造
			IsLightweightSteel__c,	//軽量鉄骨
			IsSteel__c,				//鉄骨造
			IsRC__c,				//RC
			IsSRC__c,				//SRC
			IsNorth__c,				//北
			IsNorthEast__c,			//北東
			IsEast__c,				//東
			IsSouthEast__c,			//南東
			IsSouth__c,				//南
			IsSouthWest__c,			//南西
			IsWest__c,				//西
			IsNorthWest__c,			//北西
			IsNonDeposit__c,		//敷金/保証金なし
			IsNonKeyMoney__c,		//礼金なし
			IsNonCleaningFee__c,	//定額修繕費なし
			IsNonRenewalFee__c,		//更新料なし
			RentFeeFrom__c,			//賃料から
			RentFeeTo__c,			//賃料まで
			IsIncludeManagementFee__c,	//管理費込み
			IsIncludeParkingFee__c,		//駐車場代込み
			OccupancyAreaLowerLimit__c,	//占有面積（下限）
			OccupancyAreaUpperLimit__c,	//占有面積（上限）
			BuildingAge__c,			//築年数
			IsDetachedHouse__c,		//戸建て
			IsMaisonette__c,		//メゾネット
			IsLoft__c,				//ロフト
			IsDesigners__c,			//デザイナーズ
			IsRenovation__c,		//リノベーション
			IsCondominiumRental__c,	//分譲賃貸
			IsAllWestern__c,		//オール洋間
			IsFirstFloor__c,		//1階
			IsSecondFloorOver__c,	//2階以上
			IsTopFloor__c,			//最上階
			IsCornerRoom__c,		//角部屋
			IsBalcony__c,			//バルコニー
			IsRoofBalcony__c,		//ルーフバルコニー
			IsPrivateGarden__c,		//専用庭
			IsParking__c,			//駐車場空きあり
			IsInSiteParking__c,		//敷地内駐車場
			IsPluralCarParking__c,	//駐車場2台可
			IsBuiltInGarage__c,		//ビルトインガレージ
			IsCarport__c,			//カーポート
			IsBicycleParking__c,	//駐輪場
			IsBikeStorage__c,		//バイク可
			IsSmallBike__c,			//小型バイク
			IsMediumBike__c,		//中型バイク
			IsLargeBike__c,			//大型バイク
			IsElevator__c,			//エレベーター
			IsDeliveryBox__c,		//宅配ボックス
			IsCounterKitchen__c,	//カウンターキッチン
			IsSystemKitchen__c,		//システムキッチン
			IsGasStove__c,			//ガスコンロ
			IsElectricStove__c,		//電気コンロ
			IsInductionHeating__c,	//IHコンロ
			IsTwoGasStove__c,		//コンロ2口
			IsMoreGasStove__c,		//コンロ3口以上
			IsSepalateBathAndRestroom__c,	//バス・トイレ別
			IsAditionalBoiling__c,			//追焚機能
			IsDehumidifierForBathroom__c,	//浴室乾燥機
			IsWashlet__c,					//温水洗浄便座
			IsShowerWashBasin__c,			//シャワー付き洗面台
			IsRegalLavatory__c,	//洗面所独立
			IsInnerLandry__c,	//室内洗濯機置場
			IsTownGas__c,		//都市ガス
			IsPropaneGas__c,	//プロパンガス
			IsAllElectric__c,	//オール電化
			IsAirConditioner__c,//エアコン
			IsFloorHeating__c,	//床暖房
			IsShoesBox__c,		//シューズボックス
			IsShoeCloak__c,		//シューズクローク
			IsWalkInCloset__c,	//ウォークインクローゼット
			IsTrunkRoom__c,		//トランクルーム
			IsBSAntenna__c,		//BSアンテナ
			IsCSAntenna__c,		//CSアンテナ
			IsCATV__c,				//CATV
			IsInternetFree__c,		//ネット使用料無料
			IsMonitorIntercom__c,	//モニター付きインターホン
			IsAutoLock__c,			//オートロック
			IsFurniture__c,			//家具付き
			IsHomeAppliance__c,		//家電付き
			IsNoGuarantor__c,		//保証人不要
			IsNonGuaranteeidCompany__c,	//保証会社不要
			IsMusicalInstruments__c,	//楽器相談可
			IsForeigner__c,				//外国人契約可
			IsOfficeAvailable__c,		//事務所利用可
			IsWelfareAvailable__c,		//生活保護契約可
			IsPet__c,			//ペット可
			IsLargePet__c,		//ペット(大型犬)
			IsMiddlePet__c,		//ペット(中型犬)
			IsSmallPet__c,		//ペット(小型犬)
			IsCat__c,			//ペット(猫)
			IsOtherPet__c,		//ペット(その他)
			IsTwoTenant__c,		//2人入居可
			IsRoomShare__c,		//ルームシェア可
			IsIppambutsu__c,	//一般物
			IsElderly__c,		//高齢者歓迎
			IsWoman__c,			//女性限定
			IsStudent__c,		//学生限定マンション
			CarCount__c,		//台数
			ParkingFeeLimit__c,	//1台当たりの料金上限
			Parking__c,			//駐車場
			DesiredJuniorHighSchoolArea__c,		//中学校希望学区（エリア）
			DesiredElementarySchoolArea__c,		//小学校希望学区（エリア）
			(SELECT Account__c, Name FROM AccountPropertyConditionss__r),	//お客様物件条件
			// ▲2021.10.08 No.307 対応で物件条件項目追加
			(SELECT Account__c   FROM ApplicationAccount__r),                 //申込
			(SELECT Account__c   FROM VisitsCardAccount__r),                  //来店カード
			(SELECT Account__c,Property__r.Name,
			Property__c          FROM FavoritePropertyAccount__r),            //お気に入り物件
			(SELECT Account__c   FROM ProvisionalQuoteAccount__r),            //仮見積
			(SELECT Account__c   FROM MailTimeSpecificationSendingAccount__r),//メール時間指定送信
			(SELECT Account__c   FROM MailDraftAccount__r),                   //メール下書き
			(SELECT AccountID__c FROM CorrespondAccountId__r),                //対応
			(SELECT WhatId       FROM Events),                                //行動
			(SELECT Id, Account__c, MemberId__c, Email__c, Tell__c, QuitDate__c, Blacklist__c, MemberStatus__c  FROM MemberAccount__r ORDER BY CreatedDate DESC),     //本会員
			(SELECT id           FROM IntroductionMailInformationAccount__r)   //紹介メール情報    //追加要望　追加
			FROM Account
			WHERE Id = :targetAccountId AND
			RecordType.DeveloperName = :CommonConst.ACCOUNT_RECTYPE_CUSTOMER];

        //レコード情報が取得できなければビジネスロジックException発行
        if(targetRecordList.isEmpty()) {
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
            throw ex;
        }

        return targetRecordList [0];

    }

    //楽観ロックチェックメソッド
    private void optimisticLockCheck(Account lockCheckTarget) {
        List<Account> checkOptimisticLockExceptionRecord = new List<Account>();
        checkOptimisticLockExceptionRecord = [SELECT id
                                              FROM Account
                                              WHERE id = :lockCheckTarget.Id
                                              AND SystemModStamp = :lockCheckTarget.systemModStamp
        ];

        if(checkOptimisticLockExceptionRecord.isEmpty()) {

            OptimisticLockException ex = new OptimisticLockException();
            throw ex;
        }

    }

    //名寄せメール更新メソッド
    private Account mergeEmail(Account updateResult, Account displayTarget, Account mergeTarget) {

        List<String> emailToAddList = new List<String>();

        //Email__cチェック
        if(!String.isBlank(displayTarget.Email__c) &&
           displayTarget.Email__c != mergeTarget.Email__c &&
           displayTarget.Email__c != mergeTarget.Email2__c &&
           displayTarget.Email__c != mergeTarget.Email3__c) {
            emailToAddList.add(displayTarget.Email__c);
        }

        //Email2__cチェック
        if(!String.isBlank(displayTarget.Email2__c) &&
           displayTarget.Email2__c != mergeTarget.Email__c &&
           displayTarget.Email2__c != mergeTarget.Email2__c &&
           displayTarget.Email2__c != mergeTarget.Email3__c) {
            emailToAddList.add(displayTarget.Email2__c);
        }

        //Email3__cチェック
        if(!String.isBlank(displayTarget.Email3__c) &&
           displayTarget.Email3__c != mergeTarget.Email__c &&
           displayTarget.Email3__c != mergeTarget.Email2__c &&
           displayTarget.Email3__c != mergeTarget.Email3__c) {
            emailToAddList.add(displayTarget.Email3__c);
        }

        //メアドコピー１／３
        if(String.isBlank(mergeTarget.Email__c) && !emailToAddList.isEmpty()) {
            updateResult.Email__c = emailToAddList [0];
            emailToAddList.remove(0);
            emailChangeFlg = true;
        }

        //メアドコピー２／３
        if(String.isBlank(mergeTarget.Email2__c) && !emailToAddList.isEmpty()) {
            updateResult.Email2__c = emailToAddList [0];
            emailToAddList.remove(0);
            emailChangeFlg = true;
        }

        //メアドコピー３／３
        if(String.isBlank(mergeTarget.Email3__c) && !emailToAddList.isEmpty()) {
            updateResult.Email3__c = emailToAddList [0];
            emailToAddList.remove(0);
            emailChangeFlg = true;
        }

        if(!emailToAddList.isEmpty()) {
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_EXECUTE_MERGE));
            throw ex;
        }
        return updateResult;
    }

    //名寄せ電話番号更新メソッド
    private Account mergePhone(Account updateResult, Account displayTarget, Account mergeTarget) {
        List<String> phoneToAddList = new List<String>();

        //Phoneチェック
        if(!String.isBlank(displayTarget.Phone) &&
           displayTarget.Phone != mergeTarget.Phone &&
           displayTarget.Phone != mergeTarget.Phone2__c &&
           displayTarget.Phone != mergeTarget.Phone3__c) {
            phoneToAddList.add(displayTarget.Phone);
        }

        //Phone2__cチェック
        if(!String.isBlank(displayTarget.Phone2__c) &&
           displayTarget.Phone2__c != mergeTarget.Phone &&
           displayTarget.Phone2__c != mergeTarget.Phone2__c &&
           displayTarget.Phone2__c != mergeTarget.Phone3__c) {
            phoneToAddList.add(displayTarget.Phone2__c);
        }

        //Phone3__cチェック
        if(!String.isBlank(displayTarget.Phone3__c) &&
           displayTarget.Phone3__c != mergeTarget.Phone &&
           displayTarget.Phone3__c != mergeTarget.Phone2__c &&
           displayTarget.Phone3__c != mergeTarget.Phone3__c) {
            phoneToAddList.add(displayTarget.Phone3__c);
        }

        //電話番号コピー１／３
        if(String.isBlank(mergeTarget.Phone) && !phoneToAddList.isEmpty()) {
            updateResult.Phone = phoneToAddList [0];
            phoneToAddList.remove(0);
            phoneChangeFlg = true;
        }

        //電話番号コピー２／３
        if(String.isBlank(mergeTarget.Phone2__c) && !phoneToAddList.isEmpty()) {
            updateResult.Phone2__c = phoneToAddList [0];
            phoneToAddList.remove(0);
            phoneChangeFlg = true;
        }

        //電話番号コピー３／３
        if(String.isBlank(mergeTarget.Phone3__c) && !phoneToAddList.isEmpty()) {
            updateResult.Phone3__c = phoneToAddList [0];
            phoneToAddList.remove(0);
            phoneChangeFlg = true;
        }

        if(!phoneToAddList.isEmpty()) {
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_EXECUTE_MERGE));
            throw ex;
        }
        return updateResult;
    }



}