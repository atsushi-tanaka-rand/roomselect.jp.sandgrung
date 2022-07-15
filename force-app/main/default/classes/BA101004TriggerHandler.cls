//反響メールトリガハンドラ
public with sharing class BA101004TriggerHandler {
    
    /** トリガから実行 */
    private boolean m_isExecuting = false;
    /** 新旧両方のトリガコール内のレコードの数 */
    private integer BatchSize = 0;
	// ▼ 2021.12.27 LINE連携対応より、不要フラグの削除
	// ▲ 2021.12.27

    // 定数系
    private static final Id RECTYPEID_ACCOUNT_CUS = CommonUtil.getRecordTypeId('Account', CommonConst.ACCOUNT_RECTYPE_CUSTOMER);    // 取引先のレコードタイプID（顧客）を取得
    private static List<String> liveStatusList = getLiveStatusList(); // 生きているステータスのListを作成
	// ▼ 2021.12.27 LINE連携対応より、自動返信時の種別を追加
	// ※LINE受信時の自動返信処理は不要となったが、コードは削除せずに残す
	private final String AUTO_RECIVE_TYPE_LINE = 'LINE返信';
	private final String AUTO_RECIVE_TYPE_MAIL = 'メール返信';
	// ▲ 2021.12.27

    // 列挙型
    private enum MAIL_TYPE {PORTAL, ERROR, INQUIRY} // メールタイプ

    
    /** コンストラクタ */
    public BA101004TriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    /** 登録前処理 */
    public void onBeforeInsert(EchoMail__c[] newObjs){
        
    }
    
    /** 登録後処理 */
    public void onAfterInsert(EchoMail__c[] newObjs, Map<ID, EchoMail__c> newObjMap){

        // メールの紐づけの対象を作成(トリガ用)
        List<EchoMail__c> targetList = setTargetList(newObjs);

        // メールの対応紐づけ
        connectMailToCorrespond(targetList);      
    }
    
    /** 更新前処理 */
    public void onBeforeUpdate(EchoMail__c[] oldObjs, Map<ID, EchoMail__c> oldObjMap, EchoMail__c[] newObjs, Map<ID, EchoMail__c> newObjMap){
        
    }
    /** 更新後処理 */
    public void onAfterUpdate(EchoMail__c[] oldObjs, Map<ID, EchoMail__c> oldObjMap, EchoMail__c[] newObjs, Map<ID, EchoMail__c> newObjMap){
        
    }
    /** 削除前処理 */
    public void onBeforeDelete(EchoMail__c[] oldObjs, Map<ID, EchoMail__c> oldObjMap){
        
    }
    /** 削除後処理 */
    public void onAfterDelete(EchoMail__c[] oldObjs, Map<ID, EchoMail__c> oldObjMap){
        
    }
    /** 復元後処理 */
    public void onUndelete(EchoMail__c[] newObjs){
        
    }
    
    
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // ---------privateメソッド-----------------------------------------------
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    //
    //メールの対応紐づけの対象設定（トリガ用）
    //
    private List<Echomail__c> setTargetList(Echomail__c[] newObjs) {
        //バッチ対象のもの(バッチステータス=未処理)はバッチで紐づける。それ以外がトリガ対象
        List<EchoMail__c> targetList = new List<EchoMail__c>();
        for (EchoMail__c newObj: newObjs) {
            if (newObj.BatchStatus__c != CommonConst.BATCH_STUTAS_WAITING) {
                targetList.add(newObj);
            }
        }
        return targetList;
    }
    
    
    //
    //メールの対応紐づけ
    //
    //※バッチからも呼ばれるのでpublicです
    public void connectMailToCorrespond(EchoMail__c[] newObjs) {
        Savepoint sp = Database.setSavepoint();      //セーブポイント作成
        //DB情報保持
        MAP<Id, PortalSite__c> portalSiteMap = new Map<Id, PortalSite__c>();        // ポータルサイト
        MAP<String, Shop__c> shopMap     = new Map<String, Shop__c>();              // 店舗
        MAP<Id, Property__c> propertyMap = new Map<Id, Property__c>();              // 物件
        MAP<String, Member__c> memberMap = new Map<String, Member__c>();            // ポータルサイト構築 追加 会員
		// ▼ 2021.12.27 LINE連携対応より、LINEの自動返信用変数の追加、定義箇所の見直し
		List<EchoMail__c>		lineEchoMailList	= new List<EchoMail__c>();		// LINEでの反響メール
		List<AutoReciveInfo>	autoReciveMailList	= new List<AutoReciveInfo>();	// 自動受信メール保持
		// ▲ 2021.12.27
        
        // マッチング用
        List<String> customerNmMatchList = new List<String>(); // お客様名
        List<String> phoneMatchList      = new List<String>(); // 電話番号
        List<String> fromEmailMatchList  = new List<String>(); // Fromメールアドレス
        List<String> mailMatchList       = new List<String>(); // メール(店舗取得用)
        List<String> responseMatchList   = new List<String>(); // 物件コード
        List<String> memberIdMatchList   = new List<String>(); // ポータルサイト構築 追加 本会員

        //取引先情報
        List<AccountInformation> accountInformationList = new List<AccountInformation>();//取引先情報（内部クラス）用List
        AccountInformation nonAccountInformation = new AccountInformation(null);         //取引先情報（取引先紐づけ無の対応保存用）←取引先はnullで作成する
        
        try {          
            // マッチング情報設定
            setMatchingList(newObjs, customerNmMatchList, fromEmailMatchList, phoneMatchList, mailMatchList, responseMatchList ,memberIdMatchList);
            // 情報の取得
            setPortalSiteMap(portalSiteMap);                         // ポータルサイト情報の取得と設定
            setshopMap(mailMatchList, shopMap);                      // 店舗情報の取得と設定
            setPropertyMap(responseMatchList, propertyMap);          // 物件情報の取得と設定
            setMemberMap(memberIdMatchList, memberMap);              //ポータルサイト構築 追加 会員情報の取得と設定
			// ▼ 2021.12.27 LINE連携対応より、自動返信情報の設定処理の追加・修正
			// 問合せ御礼メール設定の取得（key:送信種別、value:問合せ御礼メール設定）
			Map<String, ThanksMailSetting__c> thanksMailSettingMap = this.getThanksMailSetting();

			// 自動返信用店舗の取得（key:店舗ID、value:店舗）
			Set<Id> shopId = new Set<Id>();
			for (ThanksMailSetting__c thanksMailSetting : thanksMailSettingMap.values()) {
				shopId.add(thanksMailSetting.SendByShop__c);
			}
			Map<Id, Shop__c> autoReciveShopMap = this.selectAutoReciveShop(shopId);

			// 自動返信メールフォーマットの取得（key:送信種別、valuse:メール送信情報）
			Map<String, MailUtil.MailData> autoReciveMailFormatMap = this.getAutoReciveMailFormat(thanksMailSettingMap, autoReciveShopMap);

			// LINE会員に紐づく対応の取得（key:LINE会員.Id、value:対応）
			Map<String, List<Correspond__c>> lineMemberCorrespondMap = this.getLineMemberCorrespond(newObjs);
			// ▲ 2021.12.27

            // 取引先情報Listの設定         
            accountInformationList = setAccountInformationList(customerNmMatchList, fromEmailMatchList, phoneMatchList);
            // -----------------------------------------------------
            // メイン処理　開始
            // -----------------------------------------------------
            for (EchoMail__c obj : newObjs) { 
                //指定メールの場合、処理しない
                if(obj.IsSpecifiedMail__c) {
                    continue;
                }

                //店舗宛てのメールでない場合、処理しない
                if (!shopMap.containsKey(obj.Email__c)) {
                    continue;
                }

				// ▼ 2021.12.27 LINE連携対応より、定義箇所の見直しで削除
				// ▲ 2021.12.27

                //ポータルサイト構築 変更 引数にポータルサイトマップを追加する
                //反響メールから、反響メール情報作成
                EchoMailInformation echoMailInfo  = new EchoMailInformation(obj, shopMap.get(obj.Email__c), propertyMap, portalSiteMap);
                //反響メール種類判別

                echoMailInfo.judgeMailType(portalSiteMap, echoMailInfo);

				// ▼ 2021.12.27 LINE連携対応より、"LINE会員"、"LINE履歴"のCRUDパラメータの取得処理を追加
				if (echoMailInfo.obj.IsLineReceive__c) {
					lineEchoMailList.add(echoMailInfo.obj);
				}
				// ▲ 2021.12.27

                //メール種別による処理分岐
                switch on echoMailInfo.mailType {
                    when PORTAL  { //反響メール             ポータルサイト構築 追加 引数追加   
						// ▼ 2021.12.27 LINE連携対応より、自動返信用の引数を追加、不要変数の削除
						connectMailToCorrespondFromPortal(echoMailInfo, accountInformationList, nonAccountInformation, memberMap
															, autoReciveMailList, autoReciveMailFormatMap, lineMemberCorrespondMap
															, autoReciveShopMap, thanksMailSettingMap);
						// ▲ 2021.12.27
                    }
                    when ERROR   { //宛先不明のエラーメール
                        connectMailToCorrespondFromError(echoMailInfo, accountInformationList, nonAccountInformation);
                    }
                    when INQUIRY { //問合せメール           ポータルサイト構築 追加 引数追加
                        connectMailToCorrespondFromInquiry(echoMailInfo, accountInformationList, nonAccountInformation, memberMap);
                    }
                }
                
            }

			// ▼ 2021.12.27 LINE連携対応より、LINE受信時のCRUD処理を追加、凝集度の見直しから自動返信処理を独立化
			//データの登録・更新処理
			writeData(accountInformationList, nonAccountInformation);

			// LINE会員（受信）の更新
			this.updateLineMember(lineEchoMailList, CommonConst.LINE_MEMBER_STATUS_NOT_REPLIED);
				
			// LINE履歴（受信内容）の登録
			this.insertLineHistory(lineEchoMailList, CommonConst.LINE_HISTORY_SEND_TYPE_CUSTOMER);

			// 自動返信処理
			this.autoReciveProcess(autoReciveMailList);
			// ▲ 2021.12.27
            
        } catch (Exception e){
            System.debug('例外メッセージ:' + e.getMessage());
            System.debug('例外スタックトレース:' + e.getStackTraceString());
            Database.rollback(sp);//処理をロールバック
        }
    }
    
    
	// ▼ 2021.12.27 LINE連携対応より、自動返信用の引数を追加、不要変数の削除
	/**
	 * 対応紐づけ処理（ポータル反響メール）
	 * ポータルサイト構築 追加 引数追加
	 * @param EchoMailInformation				echoMailInfo			反響メール情報
	 * @param List<AccountInformation>			accountInformationList	取引先情報（対応と紐づけ）
	 * @param AccountInformation				nonAccountInformation	取引先情報（対応と未紐づけ）
	 * @param Map<String,Member__c>				memberMap				本会員（key:会員ID、value:本会員）
	 * @param List<AutoReciveInfo>				autoReciveInfoList		自動返信情報
	 * @param Map<String, MailUtil.MailData>	autoReciveMailFormatMap	自動返信メールフォーマット（key:送信種別、valuse:メール送信情報）
	 * @param Map<String, List<Correspond__c>>	lineMemberCorrespondMap	LINE会員に紐づく対応（key:LINE会員.Id、value:対応）
	 * @param Map<Id, Shop__c>					autoReciveShopMap		自動返信用店舗（key:店舗ID、value:店舗）
	 * @param Map<String, ThanksMailSetting__c>	thanksMailSettingMap	問合せ御礼メール設定（key:送信種別、value:問合せ御礼メール設定）
	 */
	private void connectMailToCorrespondFromPortal(EchoMailInformation echoMailInfo, List<AccountInformation> accountInformationList, AccountInformation nonAccountInformation ,Map<String,Member__c> memberMap
													, List<AutoReciveInfo> autoReciveInfoList, Map<String, MailUtil.MailData> autoReciveMailFormatMap, Map<String, List<Correspond__c>> lineMemberCorrespondMap
													, Map<Id, Shop__c> autoReciveShopMap, Map<String, ThanksMailSetting__c>	thanksMailSettingMap) {                                                
	// ▲ 2021.12.27

        // 自動返信取引先情報
        AccountInformation autoMailAccInfo = null;
        Integer correspondInfoIdx = 0;

        // 紐づく取引先情報の存在チェック
        List<Integer> accountIndexList    = getAccountIndexList(echoMailInfo, accountInformationList); // 取引先情報のindex記録用List        
        if (!accountIndexList.isEmpty()) {
            //■取引先あり
            if (accountIndexList.size() > 1) {
				// ▼ 2021.12.27 LINE連携対応より、取引先との未紐づけ時はLINE会員との紐づけ処理を行うよう修正
				//●取引先複数
				this.setUnlinkedCorrespond(nonAccountInformation, echoMailInfo, lineMemberCorrespondMap);
				// ▲ 2021.12.27

                // 自動返信対応
                autoMailAccInfo = nonAccountInformation;
            } else {
                //●取引先一つ
                //紐づく対応情報の存在チェック
                AccountInformation targetAccountInfo = accountInformationList[accountIndexList[0]]; //対象の取引先情報
                List<Integer> correspondIndexList = getCorrespondIndexList(echomailInfo, targetAccountInfo.correspondInformationList); // 対応情報のindex記録用List 
                if (!correspondIndexList.isEmpty()){
                    //▲対応あり
                    targetAccountInfo.updateCorrespond(echoMailInfo, correspondIndexList[0]);//対応の更新と、対応明細の追加
                    correspondInfoIdx = correspondIndexList[0];
                } else {
                    //▲対応なし
                    targetAccountInfo.createCorrespond(echoMailInfo);                        //対応の作成と、対応明細の追加
                }

                targetAccountInfo.addFavoritePropertyList(echoMailInfo);// お気に入り物件の設定
                //ポータルサイト構築 追加 Start

                targetAccountInfo.setMemberSet(echoMailInfo ,memberMap);//本会員の設定
                //ポータルサイト構築 追加 End

                // 自動返信対応
                autoMailAccInfo = targetAccountInfo;

                //取引先の空項目がある場合メールアドレスを設定。
                setUpdateAccoutMail(targetAccountInfo,echoMailInfo);

                //取引先の空項目がある場合電話番号を設定。
                setUpdateAccoutPhone(targetAccountInfo,echoMailInfo);

                //▼問合せNo0536で追加
                // ポータルサイトからの来店予約メールの場合
                if (echoMailInfo.mailType == MAIL_TYPE.PORTAL && echoMailInfo.portalMailType == CommonConst_ptl.ECHOMAIL_MAILTYPE_VISITRESERVATION) {
                    // 反響メールから取引先の内容をセットする
                    setUpdateAccout(targetAccountInfo,echoMailInfo);
                }
                //▲問合せNo0536で追加
            }

        } else {
            //■取引先なし
            if (echoMailInfo.obj.CustomerName__c == null) {
				// ▼ 2021.12.27 LINE連携対応より、取引先との未紐づけ時はLINE会員との紐づけ処理を行うよう修正
				//●取引先名なし
				this.setUnlinkedCorrespond(nonAccountInformation, echoMailInfo, lineMemberCorrespondMap);
				// ▲ 2021.12.27

                // 自動返信対応
                autoMailAccInfo = nonAccountInformation;
                
            } else {
                //●取引先名あり
                AccountInformation newAccountInfo = new AccountInformation(createNewAccount(echoMailInfo.obj));// 取引先情報の新規作成
                newAccountInfo.createCorrespond(echoMailInfo);                    // 対応と対応明細の追加
                newAccountInfo.addFavoritePropertyList(echoMailInfo); // お気に入り物件の設定
                //ポータルサイト構築 追加 Start
                newAccountInfo.setMemberSet(echoMailInfo ,memberMap);//本会員の設定
                //ポータルサイト構築 追加 End                
                accountInformationList.add(newAccountInfo);                       // 新規取引先をListに追加
                
                // 自動返信対応
                autoMailAccInfo = newAccountInfo;
                correspondInfoIdx = autoMailAccInfo.correspondInformationList.size() - 1;
            }
        }

		// ▼ 2021.12.27 LINE連携対応より、関数機能の見直し
		// 自動返信情報の設定
		this.setAutoRecivedInfo(
			autoMailAccInfo
			, correspondInfoIdx
			, echoMailInfo
			, autoReciveInfoList
			, autoReciveMailFormatMap
			, autoReciveShopMap
			, thanksMailSettingMap
		);
		// ▲ 2021.12.27
    }
    
    
    //
    //対応紐づけ処理（宛先不明メール）
    //
    private void connectMailToCorrespondFromError(EchoMailInformation echoMailInfo, List<AccountInformation> accountInformationList, AccountInformation nonAccountInformation) {      
        // 紐づく取引先情報の存在チェック
        List<Integer> accountIndexList    = getAccountIndexList(echomailInfo, accountInformationList); // 取引先情報のindex記録用List
        // マッチング開始
        if (!accountIndexList.isEmpty()) {
            //■取引先あり
            //紐づく対応情報の存在チェック
            AccountInformation targetAccountInfo = accountInformationList[accountIndexList[0]]; //対象の取引先情報
            List<Integer> correspondIndexList = getCorrespondIndexList(echomailInfo, targetAccountInfo.correspondInformationList); // 対応情報のindex記録用List 
            if (!correspondIndexList.isEmpty()){
                //●対応あり
                targetAccountInfo.updateCorrespond(echoMailInfo, correspondIndexList[0]);//対応の更新と、対応明細の追加
            //ポータルサイト構築 追加 Start
            } else {
                //▲対応なし
                targetAccountInfo.createCorrespond(echoMailInfo);//対応の作成
            }
        } else {
            //■取引先なし
            setNonAccountCorrespond(echoMailInfo, nonAccountInformation);// 未紐づけ用取引先情報に追加
        }
        //ポータルサイト構築 追加 End
    }
    
    
    
    //
    //対応紐づけ処理（問合せメール）
    //ポータルサイト構築 追加 引数追加
    private void connectMailToCorrespondFromInquiry(EchoMailInformation echoMailInfo, List<AccountInformation> accountInformationList, AccountInformation nonAccountInformation,Map<String,Member__c> memberMap) {
		
        // 紐づく取引先情報の存在チェック
        List<Integer> accountIndexList    = getAccountIndexList(echomailInfo, accountInformationList); // 取引先情報のindex記録用List  
        
        // マッチング処理開始
        if (!accountIndexList.isEmpty()) {
            //■取引先あり
            
            if (accountIndexList.size()  > 1) {
                //●取引先複数
                setNonAccountCorrespond(echoMailInfo, nonAccountInformation);// 未紐づけ用取引先情報に追加
                
            } else {
                //●取引先一つ
                //紐づく対応情報の存在チェック
                AccountInformation targetAccountInfo = accountInformationList[accountIndexList[0]]; //対象の取引先情報
                List<Integer> correspondIndexList = getCorrespondIndexList(echomailInfo, targetAccountInfo.correspondInformationList); // 対応情報のindex記録用List  
                
                if (!correspondIndexList.isEmpty()) {
                    //▲対応あり
                    
                    // 有効な対応の一覧を取得
                    List<Integer> aliveCorrespondIndexList = getAliveCorrespondIndexList(targetAccountInfo.correspondInformationList, correspondIndexList);
                    
                    if (!aliveCorrespondIndexList.isEmpty()) {
                        //★有効な対応あり
                        
                        //有効な対応はすべて更新する
                        for (Integer i = 0; i < aliveCorrespondIndexList.size(); i++) {
                            targetAccountInfo.updateCorrespond(echoMailInfo, aliveCorrespondIndexList[i]);
                        }
                        
                    } else {
                        //★有効な対応なし

                        //終了している対応の一覧を取得
                        List<Integer> closeCorrespondIndexList = getCloseCorrespondIndexList(targetAccountInfo.correspondInformationList, correspondIndexList);
                        
                        if (!closeCorrespondIndexList.isEmpty()) {
                            //♪終了の対応あり
                            targetAccountInfo.updateCorrespond(echoMailInfo, correspondIndexList[closeCorrespondIndexList[0]]);//最新の終了の対応を更新する
                        } else {
                            //♪終了の対応なし
                            targetAccountInfo.createCorrespond(echoMailInfo);//対応の作成
                        }
                    }

                    //ポータルサイト構築 追加 Start
                    targetAccountInfo.setMemberSet(echoMailInfo, memberMap);//本会員の設定
                    //ポータルサイト構築 追加 End

                } else {
                    //▲対応なし

                    targetAccountInfo.createCorrespond(echoMailInfo);//対応の作成
                }
                
                //▼問合せNo0536で追加
                // ポータルサイトからの問合せメールの場合
                if (echoMailInfo.portalMailType == CommonConst_ptl.ECHOMAIL_MAILTYPE_INQUIRY) {
                    // 反響メールから取引先の内容をセットする
                    setUpdateAccout(targetAccountInfo,echoMailInfo);
                }
                //▲問合せNo0536で追加
            }
        } else {
            //■取引先なし

            //自社ポータルかつ問合せメールの内容に名前の入力がある場合
            if(echoMailInfo.isMyPortal && String.isNotBlank(echoMailInfo.obj.CustomerName__c)){
                AccountInformation newAccountInfo = new AccountInformation(createNewAccount(echoMailInfo.obj));// 取引先情報の新規作成
                newAccountInfo.createCorrespond(echoMailInfo);                    // 対応と対応明細の追加
                newAccountInfo.setMemberSet(echoMailInfo ,memberMap);             // 本会員の設定
                accountInformationList.add(newAccountInfo);                       // 新規取引先をListに追加 
            }else{
                setNonAccountCorrespond(echoMailInfo, nonAccountInformation);// 未紐づけ用取引先情報に追加
            }
        }
    }
    
	// ▼ 2021.12.27 LINE連携対応より、処理の追加とコードの見直し
	/**
	 * 定休日チェック
	 * @return Boolean true:定休日、false:非定休日
	 */
	private Boolean isRegularHolidayToday() {
			
		// カレンダーの取得
		List<Calendar> calenderList = selectCalendar(SystemConfig__c.getInstance().RegularHolidayCalendar__c);
		if (calenderList.size() == 0){
			return false;
		}
			
		// 行動（定休日）の取得
		List<Event> eventList = selectEventRegularHoliday(calenderList[0].Id);
		if (eventList.size() == 0){
			return false;
		}
			
		return true;
	}

	/**
	 * 自動返信メールフォーマットの取得
	 * @param Map<String, ThanksMailSetting__c> thanksMailSettingMap	問合せ御礼メール設定（key:送信種別、value:問合せ御礼メール設定）
	 * @param Map<Id, Shop__c> 					autoReciveShopMap		自動返信用店舗（key:店舗ID、value:店舗）
	 * @return Map<String, MailUtil.MailData> 自動返信メールフォーマット
	 */
	private Map<String, MailUtil.MailData> getAutoReciveMailFormat(
		Map<String, ThanksMailSetting__c> thanksMailSettingMap
		, Map<Id, Shop__c> autoReciveShopMap
	) {

		// 自動返信メールフォーマット
		Map<String, MailUtil.MailData> autoReciveMailFormatMap = new Map<String, MailUtil.MailData>();

		// フォーマット取得処理（※店舗の存在チェックは参照関係オプションより削除不可の為、未実施）
		for (ThanksMailSetting__c thanksMailSetting : thanksMailSettingMap.values()) {

			// フォーマットの取得
			MailUtil.MailData mailData = new MailUtil.MailData();
			mailData.fromAddress	= autoReciveShopMap.get(thanksMailSetting.SendByShop__c).Email__c;
			mailData.subject		= thanksMailSetting.Subject__c;
			mailData.textBody		= thanksMailSetting.Body__c;

			autoReciveMailFormatMap.put(thanksMailSetting.SendType__c, mailData);
		}

		return autoReciveMailFormatMap;
	}

	/**
	 * 自動返信対象の問合せ御礼メール設定を取得
	 * @return Map<String, ThanksMailSetting__c> key:送信種別、value:問合せ御礼メール設定
	 */
	private Map<String, ThanksMailSetting__c> getThanksMailSetting() {

		// 戻り値
		Map<String, ThanksMailSetting__c> thanksMailSettingMap = new Map<String, ThanksMailSetting__c>();

		// 問合せ御礼メール設定の存在チェック
		List<ThanksMailSetting__c> thanksMailSettingList = this.selectThanksMailSetting();
		if (thanksMailSettingList.size() == 0) {
			return thanksMailSettingMap;
		}
			
		// 自動返信対象の取得
		for (ThanksMailSetting__c thanksMailSetting : thanksMailSettingList) {

			// 送信種別の最新レコードのみ格納
			if (thanksMailSettingMap.containsKey(thanksMailSetting.SendType__c)) {
				continue;
			}

			// 取得対象チェック
			if (this.isGetTargetThanksMailSetting(thanksMailSetting)) {
				thanksMailSettingMap.put(thanksMailSetting.SendType__c, thanksMailSetting);
			}
		}
			
		return thanksMailSettingMap;
	}

	/**
	 * 問合せ御礼メール設定の取得対象チェック
	 * @param ThanksMailSetting__c thanksMailSetting 問合せ御礼メール設定
	 * @return Boolean true:取得対象、false:取得対象外
	 */
	private Boolean isGetTargetThanksMailSetting(ThanksMailSetting__c thanksMailSetting) {

		// 定休日チェック
		if (thanksMailSetting.isAutoReciveAllDay__c) {
			if (this.isRegularHolidayToday()) {
				return true;
			}
			return false;
		}
				
		// 非送信時間チェック
		// 非送信時間が未設定
		if (thanksMailSetting.NonSendStartTime__c == null && thanksMailSetting.NonSendEndTime__c == null) {
			return true;
		}

		// 開始時間 < 終了時間
		String sysDate = CommonUtil.getNow().format('yyyy/MM/dd HH:mm');
		Time sysTime = Datetime.parse(sysDate).time();
		if ((thanksMailSetting.NonSendStartTime__c < thanksMailSetting.NonSendEndTime__c)
			&& (sysTime < thanksMailSetting.NonSendStartTime__c || thanksMailSetting.NonSendEndTime__c < sysTime)) {
			return true;
		}
				
		// 開始時間 > 終了時間
		if ((thanksMailSetting.NonSendStartTime__c > thanksMailSetting.NonSendEndTime__c)
			&& (sysTime < thanksMailSetting.NonSendStartTime__c && thanksMailSetting.NonSendEndTime__c < sysTime)) {
			return true;
		}

		return false;
	}

	/**
	 * 自動返信メールチェック
	 * @param EchoMailInformation				echoMailInfo			反響メール情報
	 * @param Map<Id, Shop__c>					autoReciveShopMap		key:店舗ID、valuse:店舗
	 * @param Map<String, ThanksMailSetting__c>	thanksMailSettingMap	key:送信種別、valuse:問合せ御礼メール設定
	 * @return Boolean true:返信対象、false:返信対象外
	 */
	private Boolean isAutoReciveMailAddress(
		EchoMailInformation echoMailInfo
		, Map<Id, Shop__c> autoReciveShopMap
		, Map<String, ThanksMailSetting__c>	thanksMailSettingMap
	) {

		// 返信期間内の問合せ御礼メール設定の存在チェック
		if (!thanksMailSettingMap.containsKey(echoMailInfo.autoReciveSendType)) {
			return false;
		}

		// 送信種別に応じた問合せ御礼メール設定の存在チェック
		Id shopId = thanksMailSettingMap.get(echoMailInfo.autoReciveSendType).SendByShop__c;
		if (!autoReciveShopMap.containsKey(shopId)) {
			return false;
		}
	
		// 自社反響メールチェック
		if (echoMailInfo.isMyPortal) {
			return false;
		}

		// 返信対象外のメールアドレス（システムメール）
		Set<String> notReplyEmail = new Set<String> {
			CommonConst.EMAIL_SUMO
			, CommonConst.EMAIL_HOMES
			, CommonConst.EMAIL_ATHOME
            , CommonConst.EMAIL_CHINTAI // CHINTAI対応追加　2022/3/8
		};

		// 返信対象外メールアドレスチェック
		String email = echoMailInfo.obj.FromEmail__c;
		if (String.isBlank(email) || notReplyEmail.contains(email)) {
			return false;
		}

		return true;
	}

	/**
	 * 自動返信情報の設定
	 * @param AccountInformation				accountInfo				取引先情報
	 * @param Integer							correspondInfoIdx		対応情報番号
	 * @param EchoMailInformation				echoMailInfo			反響メール情報
	 * @param List<AutoReciveInfo>				autoReciveInfoList		自動返信リスト
	 * @param Map<String, MailUtil.MailData>	autoReciveMailFormatMap	自動返信用メール送信情報
	 * @param Map<Id, Shop__c>					autoReciveShopMap		key:店舗ID、valuse:店舗
	 * @param Map<String, ThanksMailSetting__c>	thanksMailSettingMap	key:送信種別、valuse:問合せ御礼メール設定
	 */
	private void setAutoRecivedInfo(
		AccountInformation accountInfo
		, Integer correspondInfoIdx
		, EchoMailInformation echoMailInfo
		, List<AutoReciveInfo> autoReciveInfoList
		, Map<String, MailUtil.MailData> autoReciveMailFormatMap
		, Map<Id, Shop__c> autoReciveShopMap
		, Map<String, ThanksMailSetting__c>	thanksMailSettingMap
	) {

		// 処理継続チェック
		if (!isAutoReciveMailAddress(echoMailInfo, autoReciveShopMap, thanksMailSettingMap)) {
			return;
		}

		// 設定対象の取得
		ThanksMailSetting__c	thanksMailSetting	= thanksMailSettingMap.get(echoMailInfo.autoReciveSendType);
		CorrespondInformation	correspondInfo		= accountInfo.correspondInformationList[correspondInfoIdx];

		// 置換情報の取得
		ReplaceTextInfo replaceTextInfo = new ReplaceTextInfo();
		replaceTextInfo.shop			= autoReciveShopMap.get(thanksMailSetting.SendByShop__c);
		replaceTextInfo.sendingTime		= null;
		replaceTextInfo.echoMail		= echoMailInfo.obj;
		replaceTextInfo.correspond		= correspondInfo.correspondRecord;
		replaceTextInfo.account			= (accountInfo.accountRecord == null) ? new Account(): accountInfo.accountRecord;
		replaceTextInfo.account.Name	= createAccountName(echoMailInfo.obj.CustomerName__c, true, false);
		replaceTextInfo.customerName	= replaceTextInfo.account.Name;

		// 取引先名が存在しない場合、LINE会員名で置換
		if (String.isBlank(replaceTextInfo.customerName)) {
			replaceTextInfo.customerName = echoMailInfo.obj.LineName__c;
		}

		// メール送信情報の取得
		MailUtil.MailData mailData = autoReciveMailFormatMap.get(echoMailInfo.autoReciveSendType).clone();
		mailData.isLineIntroduction = thanksMailSetting.IsLineIntroduction__c;
		mailData.toAddress = new List<string> {echoMailInfo.obj.FromEmail__c};

		// 自動返信情報の設定
		AutoReciveInfo autoReciveInfo = new AutoReciveInfo();
		autoReciveInfo.mailData			= mailData;
		autoReciveInfo.replaceTextInfo	= replaceTextInfo;
		autoReciveInfo.correspond		= correspondInfo.correspondRecord;
		autoReciveInfo.correspondDetail	= this.getAutoReciveCorrespondDetail(replaceTextInfo, echoMailInfo.obj);
		autoReciveInfo.isLineReceive	= echoMailInfo.obj.IsLineReceive__c;
		autoReciveInfo.lineMember		= this.getAutoReciveLineMember(autoReciveInfo);
		autoReciveInfo.lineHistory		= this.getAutoReciveLineHistory(autoReciveInfo);
		autoReciveInfoList.add(autoReciveInfo);

		// 対応IDを自動返信情報に設定する為の対応（※後続処理で参照渡しを実施）
		correspondInfo.autoReciveInfoSet.add(autoReciveInfo);
	}
	// ▲ 2021.12.27
    
    //***************************************************************************************　情報の取得と初期設定　*****************************************************************************************
    
    
    //
    //ポータルサイト情報の取得と設定
    //
    private static void setPortalSiteMap(MAP<Id, PortalSite__c> portalSiteMap ) {
        
        //ポータルサイトの取得
        List<PortalSite__c> getPortalSite = [
            SELECT
            Id
            ,Email__c
            ,Url__c
            FROM
            PortalSite__c
            LIMIT :CommonConst.GOVERNOR_SELECT_LIMIT
        ];
        
        // 対象となるポータルサイトのメールアドレスとを問い合わせメール件名リスト格納
        // スーモ、ホームズ、アットホーム、自社ポータル
        for (PortalSite__c portal : getPortalSite) {
            if (portal.Email__c == CommonConst.EMAIL_SUMO ||
                portal.Email__c == CommonConst.EMAIL_HOMES ||
                portal.Email__c == CommonConst.EMAIL_ATHOME ||
                portal.Email__c == CommonConst.EMAIL_CHINTAI ||   // CHINTAI対応追加　2022/3/8
                portal.Email__c == CommonConst_ptl.EMAIL_PORTAL) {//ポータルサイト構築 追加
                    portalSiteMap.put(portal.Id, portal); 
            }
        }  
    }
    
    
    
    //
    // 取引先の取得
    // @param  customerNmMatchList　取引先名リスト（空白加工後）
    // @param  phoneMatchList   電話番号リスト
    // @param  fromEmailMatchList   Fromメールアドレスリスト
    // @return Map<Id, 取引先>
    //
    private static MAP<Id, Account> getAccountMap(
        List<String> customerNmMatchList,
        List<String> phoneMatchList, 
        List<String> fromEmailMatchList) {
            
            MAP<Id, Account> accountMap = new Map<Id, Account>();
            String sql = '';
            // ここでは全てOR条件で取得し、メインロジック内で絞り込む
            sql += ' SELECT '; 
            sql += '    Id '; 
            sql += '   ,Name';
            sql += '   ,Email__c';
            sql += '   ,Email2__c';
            sql += '   ,Email3__c';
            sql += '   ,Phone';
            sql += '   ,Phone2__c';
            sql += '   ,Phone3__c';
            sql += '   ,RecordTypeId';
            sql += '   ,RecordType.DeveloperName';
            //▼問合せNo0429で追加
            sql += '   ,(SELECT id           FROM IntroductionMailInformationAccount__r) '; //紹介メール情報 
            //▲問合せNo0429で追加
            sql += ',IsMergeCompletedFlag__c';//名寄せ完了フラグ
            sql += ',IsMergeUnnecessaryFlag__c';//名寄せ不要フラグ
            //▼問合せNo0536で追加
            sql += '    ,PostalCode__c ';         // 郵便番号
            sql += '    ,Birthdate__c ';          // 生年月日
            sql += '    ,DesiredArea__c ';        // 希望地域
            sql += '    ,HomeMovingSeason__c ';   // 引越時期
            sql += '    ,HomeMovingDate__c ';     // 引越時期（日付）までに
            sql += '    ,TenantCount__c ';        // 入居人数
            sql += '    ,State__c ';              // 都道府県
            sql += '    ,City__c ';               // 住所１（市区町村）
            sql += '    ,Street__c ';             // 住所２（番地）
            //▲問合せNo0536で追加
            sql += ' FROM ';
            sql += '    Account ';
            sql += ' WHERE ';
            sql += '    Name IN :customerNmMatchList';
            sql += ' OR  Email__c IN :fromEmailMatchList';
            sql += ' OR  Email2__c IN :fromEmailMatchList';
            sql += ' OR  Email3__c IN :fromEmailMatchList';
            sql += ' OR  Phone IN :phoneMatchList';
            sql += ' OR  Phone2__c IN :phoneMatchList';
            sql += ' OR  Phone3__c IN :phoneMatchList';      
            sql += ' ORDER BY ';
            sql += '    SystemModstamp desc ';
            List<Account> account = Database.query(sql);
            for (Account dt : account) {
                accountMap.put(dt.Id, dt);
            }
            
            return accountMap;
        }
    
    
    //
    // 対応の取得
    // @param  accountIdSet    取引先Idセット<Id>
    // @return List<Id, 対応>
    //
    private static List<Correspond__c> getCorrespondList(
        Set<Id> accountIdSet) {
            String sql = '';        
            
            sql += ' SELECT '; 
            sql += '    Id ';
            sql += '    ,AccountId__c ';            // 取引先
            sql += '    ,AccountRecordType__c ';    // 取引先レコードタイプ
            sql += '    ,District__c ';             // 地区
            sql += '    ,EchoShop__c ';             // 反響担当店舗
            sql += '    ,VisitShop__c ';            // 来店担当店舗
            sql += '    ,EchoStaff__c ';            // 担当者（反響）
            sql += '    ,ShopStaff__c ';            // 担当者（来店）
            sql += '    ,Status__c ';               // ステータス
            //ポータルサイト構築 追加 Start
            sql += '    ,FirstVisitReservationDate__c '; //来店予約日
            sql += '    ,ReceiveMailDatePortal__c';      //メール受信日時（ポータル）
            //ポータルサイト構築 追加 End
			sql += '	,LineMember__c'; // 2022.2.9 LINE連携対応より、追加
            
            sql += ' FROM ';
            sql += '    Correspond__c ';
            sql += ' WHERE ';
            sql += '     AccountId__c IN :accountIdSet';
            sql += ' ORDER BY ';
            sql += '    EventDateTime__c desc ';
            
            List<Correspond__c> correspondList = Database.query(sql);
            
            return correspondList;
        }   
    
    //
    // お気に入り物件の取得
    //
    private static List<FavoriteProperty__c> getfavorite(Set<Id> accountIdSet) {
        
        String sql = '';
        
        sql += ' SELECT '; 
        sql += '    Account__c ';       // 取引先
        sql += '    ,Property__c ';     // 物件
        sql += ' FROM ';
        sql += '    FavoriteProperty__c ';
        sql += ' WHERE ';
        sql += '     Account__c IN :accountIdSet';
        
        List<FavoriteProperty__c> favorite = Database.query(sql);
        
        return favorite;
    }
    
    //
    // 店舗の取得と設定
    //
    private static void setshopMap(List<String> mailMatchList, MAP<String, Shop__c> shopMap) {
        
        String sql = '';
        sql += ' SELECT '; 
        sql += '    Id ';
        sql += '    ,Email__c ';
        sql += '    ,Name ';
        sql += '    ,IsShopType__c '; //ISかどうか
        sql += ' FROM ';
        sql += '    Shop__c ';
        sql += ' WHERE ';
        sql += '     Email__c IN :mailMatchList';
        
        List<Shop__c> shop = Database.query(sql);
        
        for (Shop__c dt : shop) {
            shopMap.put(dt.Email__c, dt);
        }
    }
    
    //
    // 物件の取得と設定
    //
    private static void setPropertyMap(List<Id> responseMatchList, MAP<Id, Property__c> propertyMap) {
        
        String sql = '';
        sql += ' SELECT '; 
        sql += '    Id ';
        sql += '    ,Building__c ';    // 建物
        sql += '    ,Building__r.District__c '; // 建物.地区
        sql += ' FROM ';
        sql += '    Property__c ';
        sql += ' WHERE ';
        sql += '     Id IN :responseMatchList';
        
        List<Property__c> property = Database.query(sql);
        
        for (Property__c dt : property) {
            propertyMap.put(dt.Id, dt);
        }
    }
    
    //
    //ポータルサイト構築 追加 Start
    // 本会員の取得と設定
    private static void setMemberMap(List<String> memberIdMatchList, Map<String, Member__c>  memberMap) {
        String nyuukai = CommonConst_ptl.MEMBER_MEMBERSTATU_ADMISSION;
        String sql = '';
        sql += ' SELECT '; 
        sql += '    Id ';
        sql += '    ,Account__c ';    //　取引先
        sql += '    ,MemberId__c ';   //　会員Id
        sql += '    ,QuitDate__c ';   //　退会日
        sql += '    ,MemberStatus__c ';   //　会員状況
        sql += '    ,Blacklist__c ';   //　ブラックリスト
        sql += '    ,Email__c ';       // メールアドレス
        sql += '    ,Tell__c ';        // 電話番号
        sql += ' FROM ';
        sql += '    Member__c ';
        sql += ' WHERE ';
        sql += '     MemberId__c IN :memberIdMatchList';
        
        List<Member__c> member = Database.query(sql);
        
        for (Member__c dt : member) {
            memberMap.put(dt.MemberId__c, dt);
        }
    }

	// ▼ 2021.12.27 LINE連携対応より、項目の追加、機能と無意味なコードの見直し
	/**
	 * カレンダーの取得
	 * @param String condCalendarName カレンダー名
	 * @return List<Calendar> カレンダー
	 */
	private static List<Calendar> selectCalendar(String condCalendarName) {

		List<Calendar> calendarList = [
			SELECT Id
			FROM Calendar
			WHERE Name = :condCalendarName
		];

		return calendarList;
	}

	/**
	 * 行動（定休日）の取得
	 * @param Id condCalendarId カレンダー.Id
	 * @return List<Event> 行動
	 */
	private static List<Event> selectEventRegularHoliday(Id condCalendarId) {

        List<Event> eventList = [
			SELECT
				Id
				, StartDateTime
			FROM Event
			WHERE
				Subject = :CommonConst.SUBJECT_REGULARHOLIDAY
				AND OwnerId = :condCalendarId
				AND StartDateTime <= TODAY
				AND EndDateTime >= TODAY
		];

		return eventList;
	}

	/**
	 * 問合せ御礼メール設定の取得
	 * @return List<ThanksMailSetting__c> 問合せ御礼メール設定
	 */
	private List<ThanksMailSetting__c> selectThanksMailSetting() {
			
		List<ThanksMailSetting__c> thanksMailSettingList = [
			SELECT
				Id
				, Subject__c
				, Body__c
				, StartDate__c
				, EndDate__c
				, NonSendStartTime__c
				, NonSendEndTime__c
				, SendByShop__c
				, isAutoReciveAllDay__c
				, IsLineIntroduction__c
				, SendType__c
			FROM ThanksMailSetting__c
			WHERE
				StartDate__c <= TODAY
				AND EndDate__c >= TODAY
			ORDER BY
				isAutoReciveAllDay__c DESC
				, StartDate__c DESC
				, CreatedDate DESC
		];
			
		return thanksMailSettingList;
	}

	/**
	 * 自動返信用店舗の取得
	 * @param Set<Id> condShopIdSet 店舗ID
	 * @param Map<Id, Shop__c> key:店舗ID、value:店舗
	 */
	private Map<Id, Shop__c> selectAutoReciveShop(Set<Id> condShopIdSet) {
			
		List<Shop__c> shopList = [
			SELECT
				Id
				, Email__c
				, Name
				, PostalCode__c
				, City__c
				, Street__c
				, Phone__c
				, Fax__c
				, BusinessHours__c
				, RegularHoliday__c
				, Homepage__c
			FROM Shop__c
			WHERE Id = :condShopIdSet
		];
		
		Map<Id, Shop__c> shopMap = new Map<Id, Shop__c>();
		if (!shopList.isEmpty()) {
			shopMap = new Map<Id, Shop__c>(shopList);
		}
			
		return shopMap;
	}

	/**
	 * メールメッセージの取得
	 * @param String condSubject 件名
	 * @return List<EmailMessage> メールメッセージ
	 */
	private List<EmailMessage> selectEmailMessage(String condSubject) {

		List<EmailMessage> emailMessageList = [
			SELECT Id
			FROM EmailMessage
			WHERE
				Subject = :condSubject
				AND CreatedDate >= TODAY
		];
			
		return emailMessageList;
	}

	/**
	 * LINE会員の対応を取得
	 * @param Set<Id> condLineMemberIdSet LINE会員ID
	 * @return List<Correspond__c> 対応
	 */
	private List<Correspond__c> selectLineMemberCorrespond(Set<Id> condLineMemberIdSet) {

		List<Correspond__c> correspondList = [
			SELECT
				LineMember__c
				, AccountId__c
				, AccountRecordType__c
				, District__c
				, EchoShop__c
				, VisitShop__c
				, EchoStaff__c
				, ShopStaff__c
				, Status__c
				, FirstVisitReservationDate__c
				, ReceiveMailDatePortal__c
			FROM Correspond__c
			WHERE 
				LineMember__c = :condLineMemberIdSet
				AND LineMember__c != null
 			ORDER BY EventDateTime__c DESC
		];

		return correspondList;
	}
	// ▲ 2021.12.27
    
    //
    //マッチング情報Listの設定　
    //ポータルサイト構築 追加 引数追加
    private static void setMatchingList(List<EchoMail__c> newObjs, List<String> customerNmMatchList, List<String> fromEmailMatchList, List<String> phoneMatchList, List<String> mailMatchList, List<String> responseMatchList, List<String> memberIdMatchList) {
        
        // 必要な抽出条件を全て格納
        for (EchoMail__c obj : newObjs) {
            
            // 共通部品にて、不要な空白除去を行い格納
            if (String.isNotBlank(obj.CustomerName__c)) {
                customerNmMatchList.add(createAccountName(obj.CustomerName__c, true, false));    // お客様名
            }
            if (String.isNotBlank(obj.FromEmail__c)) {
                fromEmailMatchList.add(obj.FromEmail__c);   // Fromメールアドレス
            }
            if (String.isNotBlank(obj.Phone__c)) {
                phoneMatchList.add(obj.Phone__c);       // 電話番号
            }
            
            // 宛先エラー時様に、元のFromメールアドレスを格納
            //ポータルサイト構築 追加 Start
            String containsWord = '';
            if (obj.FromEmail__c == SystemConfig__c.getInstance().ErrorEmaiPortal__c){
                containsWord = 'To:';
            }else{
                containsWord = '宛先不明のメールアドレス：';
            }
            //ポータルサイト構築 追加 End

            if (String.isNotBlank(obj.Body__c) && obj.Body__c.contains(containsWord)) {
                List<String> errBodyList = obj.Body__c.split('\n');
                for (String errBody : errBodyList) {
                    if (errBody.contains(containsWord)) {
                        fromEmailMatchList.add(errBody.remove(containsWord).deleteWhitespace());
                        break;
                    }
                }
            }
            if (String.isNotBlank(obj.Email__c)) {
                mailMatchList.add(obj.Email__c);    // メール
            }
            if (String.isNotBlank(obj.Response__c)) {
                responseMatchList.add(obj.Response__c);     // 物件
            }
            if (String.isNotBlank(obj.MemberId__c)) {
                memberIdMatchList.add(obj.MemberId__c);     // 会員Id
            }

        }        
    }
    
	// ▼ 2021.12.27 LINE連携対応より、追加
	/**
	 * LINE会員に紐づく対応を取得
	 * @param EchoMail__c[] echoMailList 反響メール
	 * @return Map<String, List<Correspond__c>> key:LINE会員.Id、value:対応
	 */
	private Map<String, List<Correspond__c>> getLineMemberCorrespond(EchoMail__c[] echoMailList) {

		// LINE会員の取得
		Set<Id> lineMemberIdSet = new Set<Id>();
		for (EchoMail__c echoMail : echoMailList) {
			lineMemberIdSet.add(echoMail.LineMember__c);
		}

		// LINE会員に紐づく対応を取得
		List<Correspond__c> correspondList = this.selectLineMemberCorrespond(lineMemberIdSet);

		// Map値の取得
		Map<String, List<Correspond__c>> lineMemberCorrespondMap = CommonUtil.getKeysObject(
			correspondList
			, Correspond__c.LineMember__c.getDescribe().getName()
		);
		return lineMemberCorrespondMap;
	}
	// ▲ 2021.12.27
    
    //
    // 取引先情報Listの作成
    //
    private static List<AccountInformation> setAccountInformationList(List<String> customerNmMatchList, List<String> fromEmailMatchList, List<String> phoneMatchList) {
        
        //返却用変数の宣言
        List<AccountInformation> accountInformationList = new List<AccountInformation>();
        
        // ＜既存の取引先データ取得処理＞            
        Map<Id, Account> accountMap = getAccountMap(customerNmMatchList, phoneMatchList,fromEmailMatchList);
        for(Account acc: accountMap.values()){
            accountInformationList.add(new accountInformation(acc));//内部クラスに設定
        }
        
        Set<Id> accountIdSet = accountMap.keySet(); //取引先Idをセットに格納（対応取得用）
        
        // ＜既存の対応データ取得処理＞
        List<Correspond__c> correspondList = getCorrespondList(accountIdSet);
        for(Correspond__c cor: correspondList){
            correspondInformation corInfo = new correspondInformation(cor);
            for(accountInformation accInfo : accountInformationList){
                //取引先情報（内部クラス）の対応情報Setに格納していく
                if(corInfo.correspondRecord.AccountId__c == accInfo.accountRecord.Id){
                    accInfo.correspondInformationList.add(corInfo);
                }
            }
        }
        
        // ＜既存のお気に入り物件データ取得処理＞
        List<FavoriteProperty__c> favoritePropertyList = getfavorite(accountIdSet);
        for(FavoriteProperty__c favoProp: favoritePropertyList){
            for(accountInformation accInfo : accountInformationList){
                //取引先情報（内部クラス）の対応情報Setに格納していく
                if(favoProp.Account__c == accInfo.accountRecord.Id){
                    accInfo.favoritePropertySet.add(favoProp);
                }
            }
        }
        
        return accountInformationList;
    }
    
    
    
    //
    // 生きている対応ステータスのList作成
    // 
    private static List<String> getLiveStatusList() {
        List<String> liveStatusList = new List<String>();
        
        //有効ステータスの格納
        liveStatusList.add(CommonConst.CORRESPOND_STATUS_NOTSUPPORTED);       // 未対応
        liveStatusList.add(CommonConst.CORRESPOND_STATUS_PURSUIT);            // 追客中
        liveStatusList.add(CommonConst.CORRESPOND_STATUS_APPOINTMENT);        // アポイント確定
        liveStatusList.add(CommonConst.CORRESPOND_STATUS_VISITED);            // 来店済
        liveStatusList.add(CommonConst.CORRESPOND_STATUS_CONSIDERVISITING);   // 来店後検討
        liveStatusList.add(CommonConst.CORRESPOND_STATUS_UNEARNED);           // 未収入金
        liveStatusList.add(CommonConst.CORRESPOND_STATUS_DEPOSIT);            // 入金済
        liveStatusList.add(CommonConst.CORRESPOND_STATUS_PURSUITHOLD);        // 追客保留中
        liveStatusList.add(CommonConst.CORRESPOND_STATUS_APOCANCEL);          // アポイントキャンセル
        liveStatusList.add(CommonConst.CORRESPOND_STATUS_APOCANCEL_PURSUIT);  // アポキャンセル後追客中
        liveStatusList.add(CommonConst.CORRESPOND_STATUS_VISITED_PURSUIT);    // 来店後追客中
        liveStatusList.add(CommonConst.CORRESPOND_STATUS_APPLCANCEL);         // 申込キャンセル
        liveStatusList.add(CommonConst.CORRESPOND_STATUS_APPLCANCEL_PURSUIT); // 申込キャンセル後追客中
        
        return liveStatusList;
    }    

	// ▼ 2021.12.27 LINE連携対応より、機能の独立化、LINE受信時処理の修正、コードの見直し
	/**
	 * 自動返信メールの送信
	 * @param List<autoReciveInfo> autoReciveInfoList 自動返信情報
	 */
	private void autoReciveProcess(List<autoReciveInfo> autoReciveInfoList) {

		// 実施チェック
		if (autoReciveInfoList.size() == 0) {
			return;
		}

		// 文字置換用
		List<String> replaceTextList;

		// 自動返信メール
		List<MailUtil.MailData> mailDataList = new List<MailUtil.MailData>();

		// CRUD処理用
		List<Correspond__c>			updCorrespond		= new List<Correspond__c>();		// 対応
		List<CorrespondDetail__c>	updCorrespondDetail	= new List<CorrespondDetail__c>();	// 対応明細
		List<LineHistory__c>		lineHistoryList		= new List<LineHistory__c>();		// LINE履歴
		List<LineMember__c>			lineMemberList		= new List<LineMember__c>();		// LINE会員

		// メールテンプレート(HTML用)の取得
		HtmlMailTemplate__c htmlMailTemplate = MailUtil.selectHtmlMailTemplate(
			SystemConfig__c.getInstance().LineIntroductionMailTemplateName__c
		);

        // ▼ 2022.2.2 LINE連携より、メールテンプレート（テキスト用）の修正
        // メールテンプレート(テキスト用)の取得
		TextMailTemplate__c textMailTemplate = MailUtil.selectTextMailTemplate(
			SystemConfig__c.getInstance().LineIntroductionMailTemplateName__c
		);
        // ▲ 2022.2.2

		// 自動返信用の項目値の設定
		for (AutoReciveInfo autoReciveInfo : autoReciveInfoList) {

			// 件名、本文の置換値の取得・設定（※対応IDが必要の為、採番後のタイミングで実施）
			replaceTextList = MailUtil.getMailReplaceText(
				new List<String> {autoReciveInfo.mailData.subject, autoReciveInfo.mailData.textBody}
                , autoReciveInfo.replaceTextInfo.customerName
				, autoReciveInfo.replaceTextInfo.chargeName
				, autoReciveInfo.replaceTextInfo.shop
				, autoReciveInfo.replaceTextInfo.account
				, autoReciveInfo.replaceTextInfo.echoMail
				, null
				, autoReciveInfo.replaceTextInfo.correspond.Id
                , false
			);

			// 送信種別による分岐
			if (autoReciveInfo.isLineReceive) {
				// LINE会員ID
				// LINE会員の重複を省く
				if (!lineMemberList.contains(autoReciveInfo.LineMember)) {
					lineMemberList.add(autoReciveInfo.LineMember);
				}

				// LINE履歴
				autoReciveInfo.lineHistory.Message__c = replaceTextList[1];
				lineHistoryList.add(autoReciveInfo.lineHistory);
			} else {
				// メール送信
				autoReciveInfo.mailData.subject		= replaceTextList[0];
				autoReciveInfo.mailData.textBody	= replaceTextList[1];

				// HTML本文の取得
				autoReciveInfo.mailData.htmlBody = MailUtil.getMailBody(
					autoReciveInfo.mailData.isLineIntroduction ? htmlMailTemplate: new HtmlMailTemplate__c()
					, autoReciveInfo.mailData
					, autoReciveInfo.replaceTextInfo.account
                    , true
				);

                // ▼ 2022.2.2 LINE連携対応より、メールテンプレート（テキスト用）の修正
                // テキスト本文の取得
				autoReciveInfo.mailData.textBody = MailUtil.getMailBody(
					autoReciveInfo.mailData.isLineIntroduction ? textMailTemplate: new TextMailTemplate__c()
					, autoReciveInfo.mailData
					, autoReciveInfo.replaceTextInfo.account
                    , false
				);
				// ▲ 2022.2.2
                mailDataList.add(autoReciveInfo.mailData);
			}

			// 対応明細
			autoReciveInfo.correspondDetail.Corresponds__c		=	autoReciveInfo.correspond.Id;
			autoReciveInfo.correspondDetail.SupportedTitle__c	=	replaceTextList[0];
			autoReciveInfo.correspondDetail.SupportedContent__c	+=	replaceTextList[1];	// ヘッダ + 本文
			updCorrespondDetail.add(autoReciveInfo.correspondDetail);

			// 対応
			if(!updCorrespond.contains(autoReciveInfo.correspond)){
				autoReciveInfo.correspond.ThanksMailSettingSendDate__c = commonUtil.getNow().addSeconds(1); //問合せ435　自動返信時刻が最新になるよう１秒追加
				updCorrespond.add(autoReciveInfo.correspond);
			}
		}

		// 対応の更新
		SecureDML.secureUpdate(updCorrespond);

        System.debug(updCorrespondDetail);
		// 対応明細の登録
		SecureDML.secureInsert(updCorrespondDetail);

		// LINE会員（返信）の更新
		SecureDML.secureUpdate(lineMemberList);

		// LINE履歴（返信内容）の登録
		SecureDML.secureInsert(lineHistoryList);

		// 自動返信メールの送信
		this.sendAutoReciveMail(mailDataList);

		// リダイレクトURLオブジェクトの一括処理（※ガバナ制限回避の為）
		MailUtil.redirectUrlBulkDml();
	}

	/**
	 * 自動返信メールの送信
	 * @param List<MailUtil.MailData> mailDataList メール送信情報
	 */
	private void sendAutoReciveMail(List<MailUtil.MailData> mailDataList) {

		// 実施チェック
		if (mailDataList.size() == 0) {
			return;
		}

		try {
			// 自動返信メール送信
			List<Messaging.SendEmailResult> resultList = MailUtil.sendHtmlMail(mailDataList);
				
			// 警告メッセージ送信件数を取得
			Integer warnigParam	= CommonConst.GOVERNOR_TOTAL_SEND_MAIL - SystemConfig__c.getInstance().sendMailLimitWarningCount__c.intValue();

			// 外部メール送信件数チェック（累計メール送信件数 + メール送信件数 + 警告メッセージ送信件数）
			// ※ガバナ制限の場合、例外処理で警告メールを送信
			Messaging.reserveSingleEmailCapacity(resultList.size() + warnigParam);
		} catch (HandledException e) {
			
			// システム管理者の取得
			List<Profile> profileList = [
				SELECT Id 
				FROM Profile
				WHERE Name = :CommonConst.PROFILE_SYSTEM_ADMINISTRATOR
			];
				
			// メールアドレスの取得
			List<User> userList = [
				SELECT Email
				FROM User
				WHERE ProfileId = :profileList
			];

			// 警告メール送信済みチェック
			List<EmailMessage> emailMessageList = this.selectEmailMessage(CommonConst.MSG_ACC_W_SEND_MAIL_LIMIT_SUBJECT);
			if (emailMessageList.size() == 0 && userList.size() > 0) {

				// 送信先の取得
				List<String> systemEmailList = new List<String>();
				for (User user : userList) {
					systemEmailList.add(user.Email);
				}
					
				// 警告メール送信
				MailUtil.MailData warnMailData = new MailUtil.MailData();
				warnMailData.toAddress		= systemEmailList;
				warnMailData.ccAddress		= null;
				warnMailData.fromAddress	= null;
				warnMailData.subject		= CommonConst.MSG_ACC_W_SEND_MAIL_LIMIT_SUBJECT;
				warnMailData.textBody		= CommonConst.MSG_ACC_W_SEND_MAIL_LIMIT_TEXT_BODY;

				MailUtil.sendMail(new List<MailUtil.MailData> {warnMailData});
			}               
		}
	}
	// ▲ 2021.12.27

    //***************************************************************************************データの加工・作成**************************************************************************************************
    
    //
    // 取引先を登録用に設定(反響メールによる新規顧客)
    //
    private static Account createNewAccount(EchoMail__c obj) {
        
        // 取引先オブジェクトの設定（登録）
        Account insertAccount = new Account();
        insertAccount.RecordTypeId     = RECTYPEID_ACCOUNT_CUS;                                    // レコードタイプID（顧客）
        insertAccount.Phone            = obj.Phone__c;                                             // 電話番号
        insertAccount.Fax              = obj.Fax__c;                                               // 取引先 Fax
        insertAccount.Name             = createAccountName(obj.CustomerName__c, true, false);      // 取引先名
        insertAccount.LastName__c      = createAccountName(obj.CustomerName__c, false, true);      // 姓
        insertAccount.FirstName__c     = createAccountName(obj.CustomerName__c, false, false);     // 名
        insertAccount.NameKana__c      = createAccountName(obj.CustomerNameKana__c, true, false);  // 取引先名（カナ）
        insertAccount.LastNameKana__c  = createAccountName(obj.CustomerNameKana__c, false, true);  // 姓（カナ）
        insertAccount.FirstNameKana__c = createAccountName(obj.CustomerNameKana__c, false, false); // 名（カナ）
        insertAccount.Email__c         = obj.FromEmail__c;                                         // メール

        //▼問合せNo0536で追加
        insertAccount.Birthdate__c          = obj.Birthdate__c;                                    // 生年月日
        insertAccount.PostalCode__c         = obj.PostalCode__c;                                   // 郵便番号
        insertAccount.State__c              = obj.State__c;                                        // 都道府県
        insertAccount.City__c               = obj.City__c;                                         // 住所１（市区町村）
        insertAccount.Street__c             = obj.Street__c;                                       // 住所２（番地）
        insertAccount.DesiredArea__c        = obj.DesiredArea__c;                                  // 希望地域
        insertAccount.HomeMovingSeason__c   = obj.HomeMovingSeason__c;                             // 引越時期
        insertAccount.HomeMovingDate__c     = obj.HomeMovingDate__c;                               // 引越時期（日付）までに
        insertAccount.TenantCount__c        = CommonUtil.stringToDecimal(obj.TenantCount__c);      // 入居人数
        //▲問合せNo0536で追加
        
        return insertAccount;
    }
    
    // 取引先情報Listから、サーチ対象の取引先情報のindexList返却
    private static List<Integer> getAccountIndexList(EchoMailInformation echoMailInfo, List<AccountInformation> accountInformationList) {

        List<Integer> accountIndexList    = new List<Integer>();       // 取引先情報のindex記録用List
        
        // 紐づく取引先情報の存在チェック
        for (Integer i = 0; i < accountInformationList.size(); i++ ) {
            // 探している取引先があれば
            if (accountInformationList[i].isSearchAccount(echoMailInfo)){
                accountIndexList.add(i);//インデックスを記録
            }
        }
        return accountIndexList;
    }
    
    // 対応情報Listから、サーチ対象の対応情報のindexList返却
    private static List<Integer> getCorrespondIndexList(EchoMailInformation echoMailInfo, List<CorrespondInformation> correspondInformationList) {

        List<Integer> correspondIndexList    = new List<Integer>();       // 対応情報のindex記録用List
        
        // 紐づく対応情報の存在チェック
        for (Integer i = 0; i < correspondInformationList.size(); i++ ) {
            // 探している対応があれば
            if (correspondInformationList[i].isSearchCorrespond(echoMailInfo)){
                correspondIndexList.add(i);//インデックスを記録
            }
        }
        return correspondIndexList;
    }
    
    // 対応情報Listから、生きている対応情報のindexList返却
    private static List<Integer> getAliveCorrespondIndexList(List<CorrespondInformation> correspondInformationList, List<Integer> correspondIndexList ) {
        
        // 有効な対応の一覧を取得
        List<Integer> aliveCorrespondIndexList = new List<Integer>();
        for (Integer i = 0; i < correspondIndexList.size(); i++) {
            if (correspondInformationList[correspondIndexList[i]].isLiveStatus()) {
                aliveCorrespondIndexList.add(correspondIndexList[i]);
            }
        }
        return aliveCorrespondIndexList;
    }
    
    // 対応情報Listから、終了している対応情報のindexList返却
    private static List<Integer> getCloseCorrespondIndexList(List<CorrespondInformation> correspondInformationList, List<Integer> correspondIndexList ) {
        
        // 終了している対応の一覧を取得
        List<Integer> closeCorrespondIndexList = new List<Integer>();
        for (Integer i = 0; i < correspondIndexList.size(); i++) {
            if (correspondInformationList[correspondIndexList[i]].isCloseStatus()) {
                closeCorrespondIndexList.add(correspondIndexList[i]);
            }
        }
        return closeCorrespondIndexList;
    }
    
    //
    // 取引先名の加工
    // @param  baseName   変換対象となる取引先名（漢字、かな両方）
    // @param  fullFlg   true：姓名結合を返却  false：姓、もしくは名のみ返却
    // @param  seiFlg    true：姓を返却　false：名を返却（fullFlgがfalseの場合のみ判断に利用）
    // @return 変換した取引先名
    //
    private static String createAccountName(String baseName, boolean fullFlg, boolean seiFlg) {
        
        String returnName = '';
        String sei = '';
        String mei = '';
        String subSt = '';
        boolean breakFlg = false;
        
        if (String.isNotEmpty(baseName)) {
            
            // ★★ 取引先名の分割処理 ★★
            
            // 対象文字列の空白存在チェック
            if (baseName.containsWhitespace()) {
                
                for (Integer i = 1; i <= baseName.length(); i++) {
                    
                    // 分割の仕様は以下の通り
                    // ・最初の空白位置の前後で分割し、前を姓、後ろを名に格納する（空白は除外）
                    // ・2つめ以降の空白はそのまま残す。ただし、初回空白と連続する空白は除外する
                    // ・空白が存在しない場合は、全て姓に格納し、名は設定しない
                    // ・フルネールは姓＋名を設定する
                    subSt = baseName.substring(i-1, i);
                    if (!breakFlg) {
                        if (subSt == ' ' || subSt == '　') {
                            // 初回の空白値た来た場合、姓の格納を終えて名の格納に移る
                            breakFlg = true;
                            continue;
                        } else {
                            sei += subSt;
                        }
                    } else {
                        // 名に移って初回に空白が来た場合、姓の空白と同じ塊と判断して除外する
                        if (mei == '' && (subSt == ' ' || subSt == '　')) {
                            continue;
                        } else {
                            mei += subSt;
                        }
                    }
                }
            } else {
                // 空白が存在しない場合は、そのままseiに設定
                sei = baseName;
            }
            
            if (fullFlg) {
                returnName = sei + mei;
            } else if (seiFlg) {
                returnName = sei;
            } else {
                returnName = mei;
            }
        }
        return returnName;
    }
    
    
    //
    // 宛先不明本文からメールアドレスの取得
    //
    private static String getErrorMailAddress(EchoMail__c obj) {
        
        List<String> errBodyList = obj.Body__c.split('\n');
        String errorMailAddress = '';
        //ポータルサイト構築 追加 Start
        String containsWord = '';
        if (obj.FromEmail__c == SystemConfig__c.getInstance().ErrorEmaiPortal__c){
            //自社ポータルからのエラーメール
            containsWord = 'To:';
        }else{
            //自社ポータル以外からのエラーメール
            containsWord = '宛先不明のメールアドレス：';
        }
        //ポータルサイト構築 追加 End

        for (String errBody : errBodyList) {
            if (errBody.contains(containsWord)) {
                errorMailAddress = errBody.remove(containsWord).deleteWhitespace();
                break;
            }
        }       
        return errorMailAddress;
    }
    
	// ▼ 2021.12.27 LINE連携対応より、追加
	/**
	 * 未紐づけ時の対応の設定
	 * @param AccountInformation				accInfo					取引先情報
	 * @param EchoMailInformation				echoMailInfo			反響メール情報
	 * @param Map<String, List<Correspond__c>>	lineMemberCorrespondMap	key:LINE会員ID、value:対応
	 */
	private void setUnlinkedCorrespond(
		AccountInformation accInfo
		, EchoMailInformation echoMailInfo
		, Map<String, List<Correspond__c>> lineMemberCorrespondMap
	) {

		// LINE会員の場合、既存対応と紐づけ
		if (lineMemberCorrespondMap.containsKey(echoMailInfo.obj.LineMember__c)) {

			for(Correspond__c correspond: lineMemberCorrespondMap.get(echoMailInfo.obj.LineMember__c)){
				accInfo.correspondInformationList.add(new correspondInformation(correspond));
			}
			accInfo.updateCorrespond(echoMailInfo, 0);
		// 非LINE会員の場合、対応を新規作成
		} else {
			accInfo.createCorrespond(echoMailinfo);
		}
	}
	// ▲ 2021.12.27
    
    //
    // 未紐づけ対応の保存
    //
    private void setNonAccountCorrespond(EchoMailInformation echoMailInfo, AccountInformation nonAccountInformation) {
        
        //対応情報を作成して、追加
        nonAccountInformation.createCorrespond(echoMailInfo);
        
    }

    /**
     * 取引先の空項目がある場合メールアドレスを設定。
     * @param AccountInformation accountInfo 取引先情報
     * @param EchoMailInformation targetEchoMailInfo 反響メール情報
     */
    private void setUpdateAccoutMail(AccountInformation accountInfo, EchoMailInformation targetEchoMailInfo){
        //取引先のメールアドレスを更新するか判断する
        if(judgeMailUpdate(accountInfo,targetEchoMailInfo)){
        
            //取引先にメールアドレスが登録済みでない場合
            setAccountMail(accountInfo,targetEchoMailInfo);
            accountInfo.isMergeCheckFlg = true;     
            accountInfo.accountRecord.IsMergeUnnecessaryFlag__c = false;
            accountInfo.updateFlag = true;       
        }
    }
    
     /**
     * 取引先の空項目がある場合電話番号を設定。
     * @param AccountInformation accountInfo 取引先情報
     * @param EchoMailInformation targetEchoMailInfo 反響メール情報
     */
    private void setUpdateAccoutPhone(AccountInformation accountInfo, EchoMailInformation targetEchoMailInfo){
                
        //取引先の電話番号を更新するか判断する
        if(judgePhoneUpdate(accountInfo,targetEchoMailInfo)){

            //取引先に電話番号が登録済みでない場合
            setAccountPhone(accountInfo,targetEchoMailInfo);
            accountInfo.isMergeCheckFlg = true;     
            accountInfo.accountRecord.IsMergeUnnecessaryFlag__c = false;
            accountInfo.updateFlag = true;
        }
    }

    //▼問合せNo0536で追加
    /**
     * 項目をセット
     * @param AccountInformation accountInfo 取引先情報
     * @param EchoMailInformation targetEchoMailInfo 反響メール情報
     */
    private void setUpdateAccout(AccountInformation accountInfo, EchoMailInformation targetEchoMailInfo){
                
        accountInfo.accountRecord.Birthdate__c          = judgeAccountItemDate(accountInfo.accountRecord.Birthdate__c,targetEchoMailInfo.obj.Birthdate__c,false);           // 生年月日
        accountInfo.accountRecord.PostalCode__c         = judgeAccountItem(accountInfo.accountRecord.PostalCode__c,targetEchoMailInfo.obj.PostalCode__c,false);             // 郵便番号
        accountInfo.accountRecord.State__c              = judgeAccountItem(accountInfo.accountRecord.State__c,targetEchoMailInfo.obj.State__c,false);                       // 都道府県
        accountInfo.accountRecord.City__c               = judgeAccountItem(accountInfo.accountRecord.City__c,targetEchoMailInfo.obj.City__c,false);                         // 住所１（市区町村）
        accountInfo.accountRecord.Street__c             = judgeAccountItem(accountInfo.accountRecord.Street__c,targetEchoMailInfo.obj.Street__c,false);                     // 住所２（番地）
        accountInfo.accountRecord.DesiredArea__c        = judgeAccountItem(accountInfo.accountRecord.DesiredArea__c,targetEchoMailInfo.obj.DesiredArea__c,true);            // 希望地域
        accountInfo.accountRecord.HomeMovingSeason__c   = judgeAccountItem(accountInfo.accountRecord.HomeMovingSeason__c,targetEchoMailInfo.obj.HomeMovingSeason__c,true);  // 引越時期
        accountInfo.accountRecord.HomeMovingDate__c     = judgeAccountItemDate(accountInfo.accountRecord.HomeMovingDate__c,targetEchoMailInfo.obj.HomeMovingDate__c,true);  // 引越時期（日付）までに
        accountInfo.accountRecord.TenantCount__c        = CommonUtil.stringToDecimal(judgeAccountItem(CommonUtil.decimalToString(accountInfo.accountRecord.TenantCount__c),targetEchoMailInfo.obj.TenantCount__c,true));            // 入居人数
        accountInfo.updateFlag = true;
    }
    //▲問合せNo0536で追加

    /**
     * 取引先のメールアドレスを更新するか判断する
     * @param AccountInformation accountInfo　取引先情報
     * @param EchoMailInformation targetEchoMailInfo 反響メール情報
     * @return Boolean 更新する場合Trueを返す
     */
    private Boolean judgeMailUpdate(AccountInformation accountInfo, EchoMailInformation targetEchoMailInfo){
        //メールアドレスが空白または登録済みの場合更新不要
        if(targetEchoMailInfo.obj.FromEmail__c == null
        ||targetEchoMailInfo.obj.FromEmail__c == accountInfo.accountRecord.Email__c
        ||targetEchoMailInfo.obj.FromEmail__c == accountInfo.accountRecord.Email2__c
        ||targetEchoMailInfo.obj.FromEmail__c == accountInfo.accountRecord.Email3__c){
            return false;
        }
        //メールアドレスが登録済みでないかつメールアドレス1~3が埋まっている場合更新不要
        if(String.isNotBlank(accountInfo.accountRecord.Email__c) 
        && String.isNotBlank(accountInfo.accountRecord.Email2__c) 
        && String.isNotBlank(accountInfo.accountRecord.Email3__c)){
            return false;
        }
        return true;
    }

    /**
     * 取引先の電話番号を更新するか判断する
     * @param AccountInformation accountInfo　取引先情報
     * @param EchoMailInformation targetEchoMailInfo 反響メール情報
     * @return Boolean 更新する場合Trueを返す
     */
    private Boolean judgePhoneUpdate(AccountInformation accountInfo, EchoMailInformation targetEchoMailInfo){
        //電話番号が空白または登録済みの場合更新不要
        if(targetEchoMailInfo.obj.Phone__c == null
        ||targetEchoMailInfo.obj.Phone__c == accountInfo.accountRecord.Phone
        ||targetEchoMailInfo.obj.Phone__c == accountInfo.accountRecord.Phone2__c
        ||targetEchoMailInfo.obj.Phone__c == accountInfo.accountRecord.Phone3__c){
            return false;
        }
        //電話番号が登録済みでないかつ電話番号1~3が埋まっている場合更新不要
        if(String.isNotBlank(accountInfo.accountRecord.Phone) 
        && String.isNotBlank(accountInfo.accountRecord.Phone2__c) 
        && String.isNotBlank(accountInfo.accountRecord.Phone3__c)){
            return false;
        }
        return true;
    }

    //▼問合せNo0536で追加
    /**
     * 取引先の項目をセットする（文字）
     * @param String accountInfo　取引先情報
     * @param String targetEchoMailInfo 反響メール情報
     * @param Boolean setDataType 項目の有無に関わらずセットするか（True:上書き、False：上書きしない）
     * @return String セットする項目
     */
    private String judgeAccountItem(String accountInfo, String targetEchoMailInfo,Boolean setDataType){
        if(String.isEmpty(targetEchoMailInfo)){
            return accountInfo;
        }

        // 反響メールの内容で置き換え
        if(setDataType){
            return targetEchoMailInfo;
        }

        // 取引先に設定が無ければ反響メールをセット
        if(String.isEmpty(accountInfo)){
            return targetEchoMailInfo;
        }
        return accountInfo;
    }

    /**
     * 取引先の項目をセットする（日付）
     * @param Date accountInfo　取引先情報
     * @param Date targetEchoMailInfo 反響メール情報
     * @param Boolean setDataType 項目の有無に関わらずセットするか（True:上書き、False：上書きしない）
     * @return Date セットする項目
     */
    private Date judgeAccountItemDate(Date accountInfo, Date targetEchoMailInfo,Boolean setDataType){
        // 空はセットしない
       if(targetEchoMailInfo == null){
            return accountInfo;
        }

        // 反響メールの内容で置き換え
        if(setDataType){
            return targetEchoMailInfo;
        }

        // 取引先に設定が無ければ反響メールをセット
        if(accountInfo == null){
            return targetEchoMailInfo;
        }
        return accountInfo;
    }
    //▲問合せNo0536で追加

    /**
     * 取引先の空項目にメールアドレスを設定。
     * @param AccountInformation accountInfo 取引先情報
     * @param EchoMailInformation targetEchoMailInfo 反響メール情報
     */
    private void setAccountMail(AccountInformation accountInfo, EchoMailInformation targetEchoMailInfo){

        if(String.isBlank(accountInfo.accountRecord.Email__c)){
            accountInfo.accountRecord.Email__c = targetEchoMailInfo.obj.FromEmail__c;
             
        }else if(String.isBlank(accountInfo.accountRecord.Email2__c)){
            accountInfo.accountRecord.Email2__c = targetEchoMailInfo.obj.FromEmail__c;
            
        }else if(String.isBlank(accountInfo.accountRecord.Email3__c)){
            accountInfo.accountRecord.Email3__c = targetEchoMailInfo.obj.FromEmail__c;
        }
    }
 
     /**
      * 取引先の空項目に電話番号を設定。
      * @param AccountInformation accountInfo 取引先情報
      * @param EchoMailInformation targetEchoMailInfo 反響メール情報
      */
    private void setAccountPhone(AccountInformation accountInfo, EchoMailInformation targetEchoMailInfo){
 
        if(String.isBlank(accountInfo.accountRecord.Phone)){
            accountInfo.accountRecord.Phone = targetEchoMailInfo.obj.Phone__c;
             
        }else if(String.isBlank(accountInfo.accountRecord.Phone2__c)){
            accountInfo.accountRecord.Phone2__c = targetEchoMailInfo.obj.Phone__c;
 
        }else if(String.isBlank(accountInfo.accountRecord.Phone3__c)){
            accountInfo.accountRecord.Phone3__c = targetEchoMailInfo.obj.Phone__c;
        }
    }

	// ▼ 2021.12.27 LINE連携対応より、機能の独立化、LINE受信時処理の追加
	/**
	 * 自動返信用対応明細の取得
	 * @param ReplaceTextInfo	replaceTextInfo	文字列置換情報
	 * @param EchoMail__c		echoMail		反響メール
	 * @return CorrespondDetail__c 対応明細
	 */
	private CorrespondDetail__c getAutoReciveCorrespondDetail(
		ReplaceTextInfo replaceTextInfo
		, EchoMail__c echoMail
	) {

		// 反響メールの受信情報（メール、LINE）
		String receiveType		= this.AUTO_RECIVE_TYPE_MAIL;
		String correspondType	= CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE;

		if (echoMail.IsLineReceive__c) {
			receiveType		= this.AUTO_RECIVE_TYPE_LINE;
			correspondType	= CommonConst.TASK_CORRESPONDTYPE_AUTO_RECIVE_LINE;
		}

		// 対応明細の作成
		CorrespondDetail__c correspondDetail = new CorrespondDetail__c();

		// 共通内容の取得
		correspondDetail.SupportedContent__c = 
			'TO:' + echoMail.FromEmail__c + CommonConst.LINE_FEED
			+ receiveType + CommonConst.LINE_FEED
			+ CommonConst.LINE_FEED;

		correspondDetail.SupportedDateTime__c	= CommonUtil.getNow();
		correspondDetail.Shop__c				= replaceTextInfo.shop.Id;
		correspondDetail.MailType__c			= CommonConst.CORRESPONDDETAIL_MAILTYPE_SEND;
		correspondDetail.Email__c				= replaceTextInfo.shop.Email__c;
		correspondDetail.CorrespondType__c		= correspondType;
		correspondDetail.EchoMail__c			= echoMail.Id;

		return correspondDetail;
	}

	/**
	 * 自動返信用LINE会員の取得
	 * @param AutoReciveInfo autoReciveInfo 自動返信情報
	 * @return LineMember__c LINE会員
	 */
	private LineMember__c getAutoReciveLineMember(AutoReciveInfo autoReciveInfo) {

		// 実施チェック
		if (!autoReciveInfo.isLineReceive) {
			return new LineMember__c();
		}

		// LINE会員の作成
		LineMember__c lineMember = new LineMember__c(
			Id	= autoReciveInfo.correspond.LineMember__c
			, Status__c	= CommonConst.LINE_MEMBER_STATUS_DONE_REPLIED
		);

		return lineMember;
	}

	/**
	 * 自動返信用LINE履歴の取得
	 * @param AutoReciveInfo autoReciveInfo 自動返信情報
	 * @return LineHistory__c LINE履歴
	 */
	private LineHistory__c getAutoReciveLineHistory(AutoReciveInfo autoReciveInfo) {

		// 実施チェック
		if (!autoReciveInfo.isLineReceive) {
			return new LineHistory__c();
		}

		// LINE履歴の作成
		LineHistory__c lineHistory = new LineHistory__c(
			LineMember__c	= autoReciveInfo.correspond.LineMember__c
			, SendType__c	= CommonConst.LINE_HISTORY_SEND_TYPE_MANAGER
			, SendTime__c	= autoReciveInfo.correspondDetail.SupportedDateTime__c
		);

		return lineHistory;
	}
    // ▲ 2021.12.27

    //***************************************************************************************** データの更新 ***************************************************************************************************

	// ▼ 2021.12.27 LINE連携対応より、凝集度の見直しから自動返信処理を削除
	//
	// データのupsert（取引先、対応、対応明細、お気に入り物件）
	// ポータルサイト構築 変更 引数追加
	private void writeData(List<AccountInformation> accountInformationList, AccountInformation nonAccountInformation) {
	// ▲ 2021.12.27

        //▼問合せNo0429で追加
        updateAccountList(accountInformationList);                          // 取引先の更新、（自動追客時紹介メール情報の削除）
        //▲問合せNo0429で追加
        writeAccountList(accountInformationList);                           //取引先
		// ▼ 2021.12.27 LINE連携対応より、凝集度の見直しから自動返信処理を削除
		writeCorrespondList(accountInformationList, nonAccountInformation); //対応+対応明細
		// ▲ 2021.12.27

        writeFavoritePropertyList(accountInformationList);                  //お気に入り物件
        //ポータルサイト構築 追加 Start
        writeMemberList(accountInformationList);                  //本会員、本会員差分
        //ポータルサイト構築 追加 End
    }

    //▼問合せNo0429で追加
    //
    // 取引先の更新と紹介メール情報の削除、名寄せ設定(更新)
    //
    private void updateAccountList(List<AccountInformation> accountInformationList) {
        List<Account> updateAccountList = new List<Account>();
        List<Account> mergeAccountList = new List<Account>();
        List<Id> IdList = new List<Id>();
        List<IntroductionMailInformation__c> deleteIntroductionMailInformationList = new List<IntroductionMailInformation__c>();
        for (AccountInformation accInfo : accountInformationList) {
            //メール受信した顧客の自動追客を解除
            //未紐づけの対応はメール受信でしかできない前提
            if(accInfo.accountRecord.Id != null && accInfo.introductionMailInformationId != null){
                
                IntroductionMailInformation__c deleteIntroductionMailInformation = new IntroductionMailInformation__c();
                deleteIntroductionMailInformation.id = accInfo.introductionMailInformationId; // 紹介メール情報．ID
                deleteIntroductionMailInformationList.add(deleteIntroductionMailInformation);
               
                accInfo.accountRecord.IntroMailInfoStatus__c = CommonConst_ptl.INTRODUCTION_SENDSTOP;//配信状況を配信停止に変更
               
                accInfo.updateFlag = true;
            }
            if(accInfo.isMergeCheckFlg){
                idList.add(accInfo.accountRecord.id);
                mergeAccountList.add(accInfo.accountRecord);
            }

            if(accInfo.updateFlag){
                updateAccountList.add(accInfo.accountRecord);
            }
        }

        //取引先名寄せ設定(更新時)
        if(!mergeAccountList.isEmpty()){
            NameMergeUtil.setCustomerMergeCompletedFlag(mergeAccountList,idList);
        }

        // 紹介メール情報の削除
        if (!deleteIntroductionMailInformationList.isEmpty()) {
             SecureDML.secureDelete(deleteIntroductionMailInformationList);
        }
        if (!updateAccountList.isEmpty()) {
            SecureDML.secureUpdate(updateAccountList);
        }
    }
    //▲問合せNo0429で追加
    
    //
    // データ書き込み（取引先）
    //
    private void writeAccountList(List<AccountInformation> accountInformationList) {

        List<Account> insertAccountList = new List<Account>();
        
        //対象の洗い出し
        for (AccountInformation accInfo: accountInformationList) {
            if (accInfo.accountRecord.Id == null) {
                insertAccountList.add(accInfo.accountRecord);
            }
        }
        if (!insertAccountList.isEmpty()) {
            NameMergeUtil.setCustomerMergeCompletedFlag(insertAccountList); //名寄せフラグを設定する
            SecureDML.secureInsert(insertAccountList);
        }
    }
    
	// ▼ 2021.12.27 LINE連携対応より、凝集度の見直しから自動返信処理を削除
	//
	// データ書き込み（対応＋対応明細）
	//
	private void writeCorrespondList(List<AccountInformation> accountInformationList, AccountInformation nonAccountInformation) {
	// ▲ 2021.12.27

        //更新対象の対応情報の一覧を作成する
        List<CorrespondInformation> upsertCorrespondInformationList = new List<CorrespondInformation>();
        for (AccountInformation accInfo: accountInformationList) {
            for (CorrespondInformation coreInfo: accInfo.correspondInformationList) {
                if (coreInfo.isUpsert) { //更新対象なら
                    if (coreInfo.correspondRecord.AccountId__c == null) { //取引先をinsertしたので、Idを入れる
                        coreInfo.correspondRecord.AccountId__c = accInfo.accountRecord.Id;
                    }
                    upsertCorrespondInformationList.add(coreInfo); //更新対象に追加
                }
            }
        }
        //未紐づけの対応情報を追加する
        if (nonAccountInformation != null) {
            upsertCorrespondInformationList.addAll(nonAccountInformation.correspondInformationList);
        }
        
        //対象の洗い出し（対応）
        List<Correspond__c> upsertCorrespondList = new List<Correspond__c>();

		List<Id> corerespondIdList = new List<Id>();
        for (CorrespondInformation coreInfo: upsertCorrespondInformationList) {
			
			// 対応の重複データを省く
			if (!corerespondIdList.contains(coreInfo.correspondRecord.Id) || coreInfo.correspondRecord.Id == null) { //2022.03.25 No0779 null考慮追加
				corerespondIdList.add(coreInfo.correspondRecord.Id);
				upsertCorrespondList.add(coreInfo.correspondRecord);
			}
        }
        if (!upsertCorrespondList.isEmpty()) {
            SecureDML.secureUpsert(upsertCorrespondList);
        }
        
        //対象の洗い出し（対応明細）
        List<CorrespondDetail__c> insertCorrespondDetailList = new List<CorrespondDetail__c>();
        for (CorrespondInformation coreInfo: upsertCorrespondInformationList) {
            for (CorrespondDetail__c coreDetail: coreInfo.correspondDetailSet) {
                coreDetail.Corresponds__c = coreInfo.correspondRecord.Id; //対応をinsertしたので、Idを入れる
                insertCorrespondDetailList.add(coreDetail); //更新対象に追加
            }

			// ▼ 2021.12.27 LINE連携対応より、コメントを追加
			// 自動返信情報にCRUD処理後の対応を設定
            for(AutoReciveInfo auto: coreInfo.autoReciveInfoSet){
                auto.correspond = coreInfo.correspondRecord;
            }
			// ▲ 2021.12.27
        }
        System.debug(insertCorrespondDetailList);
        if (!insertCorrespondDetailList.isEmpty()) {
            SecureDML.secureInsert(insertCorrespondDetailList);
        }
        
		// ▼ 2021.12.27 LINE連携対応より、凝集度の見直しから自動返信処理を削除
		// ▲ 2021.12.27
    }
    
    //
    // データ書き込み（お気に入り物件）
    //
    private void writeFavoritePropertyList(List<AccountInformation> accountInformationList) {

        List<FavoriteProperty__c> insertFavoritePropertyList = new List<FavoriteProperty__c>();
        
        //データの洗い出し
        
        for (AccountInformation accInfo: accountInformationList) {
            for (FavoriteProperty__c favo: accInfo.favoritePropertySet) {
                if (favo.Id == null) {
                    favo.Account__c = accInfo.accountRecord.Id; //取引先をinsertしたので、Idを入れる
                    insertFavoritePropertyList.add(favo);
                }
            }
        }
        if (!insertFavoritePropertyList.isEmpty()) {
            SecureDML.secureInsert(insertFavoritePropertyList);
        }
    }

    //ポータルサイト構築 追加 Strat
    // データ更新（本会員）
    //
    private void writeMemberList(List<AccountInformation> accountInformationList) {

        List<Member__c> updateMemberList = new List<Member__c>();
        
        //データの洗い出し
        for (AccountInformation accInfo: accountInformationList) {
            for (Member__c mem: accInfo.memberSet) {
                //メールに会員IDがある　かつ　メールの取引先と既存の本会員の取引先が一致しない　ときのみ
                if (mem.Account__c != accInfo.accountRecord.Id) {
                    mem.Account__c = accInfo.accountRecord.Id; //取引先をinsertしたので、Idを入れる
                    updateMemberList.add(mem);
                }
            }
        }
        if (!updateMemberList.isEmpty()) {
            SecureDML.secureUpdate(updateMemberList);
            //会員を更新した場合、更新した会員の差分を作成
            writeMemberDifferenceList(updateMemberList);
        }
    }

    // データ登録（本会員差分）
    //
    private void writeMemberDifferenceList(List<Member__c> memberList) {

        List<MemberDifference__c> insertMemberDiffList = new List<MemberDifference__c>();
        for (Member__c mem : memberList) {
            MemberDifference__c memdiff = new MemberDifference__c(
                CrudCd__c = 'U',               //クラッドコード
                LinkCd__c = 'StoH',            //連携コード    
                MemberId__c = mem.MemberId__c, //会員ID
                Email__c = PortalUtil.encryption(mem.Email__c),       //メールアドレス（暗号化状態）
                Tell__c  = PortalUtil.encryption(mem.Tell__c),        //電話番号（暗号化状態）
                Account__c = mem.Account__c,   //取引先
                QuitDate__c = mem.QuitDate__c,            //退会日    
                MemberStatus__c = mem.MemberStatus__c,    //会員状況
                Blacklist__c = mem.Blacklist__c           //ブラックリスト
            );
            insertMemberDiffList.add(memdiff);
        }
        if (!insertMemberDiffList.isEmpty()) {
            SecureDML.secureInsert(insertMemberDiffList);
        }
    }
    //ポータルサイト構築 追加 End

	// ▼ 2021.12.27 LINE連携対応より、追加
	/**
	 * LINE履歴の登録
	 * @param List<EchoMail__c> echoMailList	反響メール
	 * @param String			sendType		送信種別
	 */
	private void insertLineHistory(List<EchoMail__c> echoMailList, String sendType) {

		// Entity
		LineHistory__c			lineHistory;
		List<LineHistory__c>	lineHistoryList	= new List<LineHistory__c>();

		// 登録情報の取得
		for (EchoMail__c echoMail : echoMailList) {
			lineHistory = new LineHistory__c(
				LineMember__c		= echoMail.LineMember__c
				, Message__c		= echoMail.LineMessage__c
				, FileName__c		= echoMail.LineFileName__c
				, FileURL__c		= echoMail.LineFileUrl__c
				, ThumbnailName__c	= echoMail.LineThumbnailName__c
				, ThumbnailURL__c	= echoMail.LineThumbnailUrl__c
				, SendType__c		= sendType
				, SendTime__c		= echoMail.LineReceiveTime__c
			);

			lineHistoryList.add(lineHistory);
		}

		// LINE履歴の登録
		SecureDML.secureInsert(lineHistoryList);
	}

	/**
	 * LINE会員の更新
	 * @param List<EchoMail__c> echoMailList	反響メール
	 * @param String 			status			ステータス
	 */
	private void updateLineMember(List<EchoMail__c> echoMailList, String status) {

		// Entity
		LineMember__c		lineMember;
		List<LineMember__c> lineMemberList	= new List<LineMember__c>();
		List<String> lineIdList = new List<String>();

		// 更新情報の取得
		for (EchoMail__c echoMail : echoMailList) {
			lineMember = new LineMember__c(
				Id			= echoMail.LineMember__c
				, Name		= echoMail.LineName__c
				, Status__c	= status
				, LineId__c	= echoMail.LineId__c
			);
			
			// LINE会員の重複を省く
			if (!lineIdList.contains(echoMail.LineId__c)) {
				lineIdList.add(echoMail.LineId__c);
				lineMemberList.add(lineMember);
			}
		}

		// LINE会員の更新
		SecureDML.secureUpdate(lineMemberList);
	}
	// ▲ 2021.12.27

    // ------------------------------------------------------------------------------------------------------------------------------------------------------
    // 内部クラス
    // ------------------------------------------------------------------------------------------------------------------------------------------------------                                                      
    
    //
    // 取引先情報
    //
    public class AccountInformation{
        
        public Account accountRecord;   //取引先
        public List<CorrespondInformation> correspondInformationList; //対応情報（内部クラス）
        public Set<FavoriteProperty__c> favoritePropertySet; //お気に入り物件
        public Set<Member__c> memberSet;  //ポータルサイト構築 追加 本会員
        public Id introductionMailInformationId; //紹介メール情報ID //問合せNo0429で追加
        public Boolean updateFlag; //updateフラグ
        public Boolean isMergeCheckFlg; //名寄せ確認フラグ

        //コンストラクタ(取引先のみ)
        public AccountInformation(Account acc){
            this.accountRecord = acc;
            this.correspondInformationList = new List<CorrespondInformation>();
            this.favoritePropertySet = new Set<FavoriteProperty__c>();
            this.memberSet = new Set<Member__c>();                    //ポータルサイト構築 追加
            //▼問合せNo0429で追加
            this.introductionMailInformationId = null;
            if(acc != null){
                if(acc.IntroductionMailInformationAccount__r.size() > 0){
                    this.introductionMailInformationId = acc.IntroductionMailInformationAccount__r[0].Id; // 紹介メール情報．ID
                }
            }
            //▲問合せNo0429で追加
            this.updateFlag = false;
            this.isMergeCheckFlg = false;
        }
        
        
        //*********************************** publicメソッド *********************************
        
        //求めている取引先かどうか
        public Boolean isSearchAccount(EchoMailInformation echoMailInfo) {
            
            Boolean isMatch;
            switch on echoMailInfo.mailType {
                when PORTAL {
                    isMatch = isPortalAccount(createAccountName(echoMailInfo.obj.CustomerName__c, true, false), echoMailInfo.obj.FromEmail__c, echoMailInfo.obj.Phone__c);
                }
                when ERROR {
                    isMatch = isOtherAccount(echoMailInfo.errorFromMailAddress);
                }
                when INQUIRY {
					//▼ 2022.04.04 No0745 対応で変更
                    // Lineでの受信の場合
					if (echoMailInfo.obj.LineMember__c != null) {
						isMatch = isOtherAccountLine(echoMailInfo.obj.LineMember__r.Account__c);
					}else{
						isMatch = isOtherAccount(echoMailInfo.obj.FromEmail__c);
					}
					//▲ 2022.04.04 No0745 対応で変更
                    
                }
            }
            return isMatch;
        }
        
        //生きている対応のIndex返却
        public Integer getLiveCorrespondIndex() {
            
            Integer liveCorrespondIndex = null;
            //対応を一つずつ調査
            for (Integer i = 0; i< correspondInformationList.size(); i++) {
                if (correspondInformationList[i].isLiveStatus()) { //対応情報が生きているなら
                    liveCorrespondIndex = i;
                    break;
                }
            }
            return liveCorrespondIndex;
        }
        
        //対応の作成+対応明細の追加
        public void createCorrespond(EchoMailInformation echoMailinfo) {
            
            //対応情報を新規作成する
            CorrespondInformation newCorrespondInfo;
            if (this.accountRecord == null) {
                newCorrespondInfo = new CorrespondInformation(echoMailInfo, true );//取引先なしで作成する(店舗設定なし)
            } else {
                newCorrespondInfo = new CorrespondInformation(echoMailInfo, false);
            }
            
            //並び順を変更する
            List<CorrespondInformation> newList = new List<CorrespondInformation>();
            newList.add(newCorrespondInfo);                       //作成順に並んでいるので、先頭に追加する
            newList.addAll(this.correspondInformationList);       //現在あるものを全て後ろに追加する
            this.correspondInformationList = newList;
        }
        
        //対応の更新+対応明細の追加
        public void updateCorrespond(EchoMailInformation echoMailInfo, Integer correspondIndex) {
            this.correspondInformationList[correspondIndex].updateCorrespond(echoMailInfo);
            this.correspondInformationList[correspondIndex].addCorrespondDetail(echoMailInfo);  
        }

        //ポータルサイト構築 追加 Start
        //お気に入り物件の追加（物件リスト対応）
        public void addFavoritePropertyList(EchoMailInformation echoMailInfo){

            //自社ポータルフラグがfalse
            if (!echoMailInfo.isMyPortal){
                //お気に入り物件の追加
                addFavoriteProperty(echoMailInfo.obj.Response__c);

            //自社ポータルフラグがtrue　かつ　物件リストがnullでない
            }else if(echoMailInfo.isMyPortal && String.isNotBlank(echoMailInfo.obj.PropertyList__c)){
                //,区切りの物件リストをリストに変更
                List<String> proIdList = echoMailInfo.obj.PropertyList__c.split(',');
                for (String proId : proIdList){
                    //お気に入り物件の追加
                    addFavoriteProperty(proId);               
                }
            }
        }

        //本会員設定
        public void setMemberSet(EchoMailInformation echoMailInfo,Map<String, Member__c> memberMap){
            //自社ポータルからのメールなら本会員設定を行う
            if (echoMailInfo.isMyPortal){
                if (memberMap.containsKey(echoMailInfo.obj.MemberId__c)){
                    this.memberSet.add(memberMap.get(echoMailInfo.obj.MemberId__c));
                }
                
            }
        }
        //ポータルサイト構築 追加 End
        
        //*********************************** privateメソッド *********************************
        
        //取引先チェック（ポータル用）
        private Boolean isPortalAccount(String accountName , String email, String phone){
            
            Boolean isSame = false;
            if (   accountRecord.RecordTypeId == RECTYPEID_ACCOUNT_CUS //レコードタイプが顧客で
                && accountRecord.Name == accountName                   //取引先名が一致してあり
                && (  ( String.isNotBlank(email) && (accountRecord.Email__c  == email || accountRecord.Email2__c == email || accountRecord.Email3__c == email) )//メールか
                    ||( String.isNotBlank(phone) && (accountRecord.Phone     == phone || accountRecord.Phone2__c == phone || accountRecord.Phone3__c == phone) )//電話が一致
                   )
               ){
                   isSame = true;
               }
            return isSame;
        }
        
		//取引先チェック（その他用）
		private Boolean isOtherAccount(String email){
			
			Boolean isSame = false;
			if (( String.isNotBlank(email) && (accountRecord.Email__c  == email || accountRecord.Email2__c == email || accountRecord.Email3__c == email) )){ //メールが一致
				isSame = true;
			}
			return isSame;
		}

		//▼ 2022.04.04 No0745 対応で追加
		/**
		* 取引先チェック（ライン受信時用）
		* @param   accountId Id 取引先ID
		* @return  取引先一致（True：一致、False：不一致）
		*/
		private Boolean isOtherAccountLine(Id accountId){
	
			Boolean isSame = false;
			if(accountId == accountRecord.Id){
				isSame = true;
			}
			return isSame;
		}
		//▲ 2022.04.04 No0745 対応で追加

        //お気に入り物件の追加
        private void addFavoriteProperty(Id propertyId){
            //すでに登録されているお気に入り物件か調査
            Boolean isDuplicate = false; //重複フラグ
            for (FavoriteProperty__c favoritePropertyData : this.favoritePropertySet) {
                if (favoritePropertyData.Property__c == propertyId) {
                    isDuplicate = true;
                    break;
                }
            }
            
            //重複していないなら追加
            if (!isDuplicate) {
                this.favoritePropertySet.add(new FavoriteProperty__c(Property__c = propertyId));
            }
        }
    }
    
    //
    // 対応情報
    //
    public class CorrespondInformation {
        
        public Correspond__c correspondRecord;               //対応
        public Boolean isUpsert;                             //upsert処理を行うフラグ
        public Set<CorrespondDetail__c> correspondDetailSet; //対応明細Set
        public Set<AutoReciveInfo> autoReciveInfoSet; //自動返信Set
        
        
        //コンストラクタ（反響メール情報から）
        public CorrespondInformation(EchoMailInformation echoMailInfo, Boolean isAccountNull) {
            this.isUpsert = true;                                            //更新フラグ
            this.correspondRecord = setCorrespondRecord(echoMailInfo, null); //対応の新規作成
            
            //反響メールで、未紐づけなら店舗を設定しない
            if (echoMailInfo.mailType == MAIL_TYPE.PORTAL && isAccountNull) {
                this.correspondRecord.EchoShop__c  = null;
                this.correspondRecord.VisitShop__c = null;
            }
            
            this.correspondDetailSet = new Set<CorrespondDetail__c>();       //対応明細Set初期化
            addCorrespondDetail(echoMailInfo);//対応明細の追加
            this.autoReciveInfoSet = new Set<AutoReciveInfo>(); //自動返信Set初期化
        }
        
        //コンストラクタ（対応から）←既存対応
        public CorrespondInformation(Correspond__c oldCorrespond) {
            this.isUpsert = false;                                     //更新フラグ
            this.correspondRecord = oldCorrespond;                     //対応
            this.correspondDetailSet = new Set<CorrespondDetail__c>(); //対応明細Set初期化
            this.autoReciveInfoSet = new Set<AutoReciveInfo>(); //自動返信Set初期化
        }
        
        //******************************* publicメソッド ***********************************
        
        //対応の更新
        public void updateCorrespond(EchoMailInformation echoMailInfo) {
            this.isUpsert = true;
            this.correspondRecord = setCorrespondRecord(echoMailInfo, this.correspondRecord);
        }
        
        //対応明細の追加
        public void addCorrespondDetail(EchoMailInformation echoMailInfo) {
            
            CorrespondDetail__c addCorrespondDetail = createCorrespondDetail(echoMailInfo); //対応明細の作成
            this.correspondDetailSet.add(addCorrespondDetail);//対応明細を追加する
            
        }
        
        //対応チェック（生きているか）
        public Boolean isLiveStatus() {
            if (liveStatusList.contains(this.correspondRecord.Status__c)) {
                return true;
            } else {
                return false;
            }
        }
        
        //対応チェック（終了か）
        public Boolean isCloseStatus() {
            if (this.correspondRecord.Status__c == CommonConst.CORRESPOND_STATUS_CLOSE || this.correspondRecord.Status__c == CommonConst.CORRESPOND_STATUS_AGREEMENT) {
                return true;
            } else {
                return false;
            }
        }
        
        //求めている対応かどうか
        public Boolean isSearchCorrespond(EchoMailInformation echoMailInfo) {
            
            Boolean isMatch;
            switch on echoMailInfo.mailType {
                when PORTAL {
                    //ポータルサイト構築 追加 Start　条件追加
                    //自社ポータル_メール種別が来店予約メール　または　来店受付キャンセルメールのとき、地区を条件に入れない
                    if (echoMailInfo.portalMailType == CommonConst_ptl.ECHOMAIL_MAILTYPE_VISITRESERVATION ||
                        echoMailInfo.portalMailType == CommonConst_ptl.ECHOMAIL_MAILTYPE_VISITRESERVATIONCHANCEL){
                        
                        isMatch = isPortalCorrespond(echoMailInfo.district, false);

                    //来店予約、来店予約キャンセル以外の反響
                    }else{
                        isMatch = isPortalCorrespond(echoMailInfo.district, true);
                    }
                    //ポータルサイト構築 追加End
                    
                }
                when ERROR {
                    isMatch = true; //エラーメールは、どんな対応でもOK
                }
                when INQUIRY {
					// ▼ 2022.2.9 LINE連携対応より、LINE情報も取得するよう修正
					isMatch = isInquiryCorrespond(echoMailInfo);
					// ▲ 2022.2.9
                }
            }
            return isMatch;
        }
        
        //******************************* privateメソッド ***********************************

        //ポータルサイト構築 変更 引数追加、条件追加、条件パターン追加
        //対応チェック（ポータルサイト用）
        private Boolean isPortalCorrespond(String district, Boolean isCheckDistrict) {
            
            //メール種別が来店受付、来店予約キャンセル以外のときのみ対応一致条件　地区が等しく、生きている
            if (isCheckDistrict && this.correspondRecord.District__c == district && this.isLiveStatus()) {
                return true;

            //メール種別が来店受付、来店予約キャンセル以外のときの対応一致条件　対応が生きている
            } else if (!isCheckDistrict && this.isLiveStatus()){
                return true;       
                
            } else {
                return false;
            }
        }

		// ▼ 2022.2.9 LINE連携対応より、LINE連携時の条件の修正とコードの見直し
		/**
		 * 対応チェック（問合せメール用）
		 * @param EchoMailInformation echoMailInfo 反響メール情報
		 * @return Boolean true:条件一致、false:条件不一致
		 */
		private Boolean isInquiryCorrespond(EchoMailInformation echoMailInfo) {

			// LINE受信時
			if (echoMailInfo.obj.IsLineReceive__c && String.isNotBlank(this.correspondRecord.LineMember__c)) {
				return true;
			}

			// 店舗が等しい
			if (this.correspondRecord.EchoShop__c == echoMailInfo.shopId 
				|| this.correspondRecord.VisitShop__c  == echoMailInfo.shopId) {
				return true;
			}

			return false;
		}
		// ▲ 2022.2.9
        
        //対応の設定(新規登録、更新)
        private Correspond__c setCorrespondRecord(EchoMailInformation echoMailInfo, Correspond__c oldCorrespond) {
            //フラグ
            Boolean isSettingListViewDate = true;                   // 一覧表示日時設定するか否か
            Boolean isNew = (oldCorrespond == null) ? true : false; // 新規対応か否か
            
            //更新用対応の宣言            
            Correspond__c newCorrespond = new Correspond__c();
            if (isNew) { //新規時のみ
                
                newCorrespond.Status__c              = CommonConst.CORRESPOND_STATUS_NOTSUPPORTED; // ステータス（未対応）
                newCorrespond.StaffSupportedFlg__c   = True;                                       // スタッフ対応フラグ
                newCorrespond.IsSupportedListShow__c = True;                                       // 対応確認フラグ
                
				// LINE受信時にLINE情報を設定 ▼ 2022.04.20 No0758 対応で追加
				if (echoMailInfo.obj.IsLineReceive__c) {
					newCorrespond.FirstLineAddFlg__c = True;	// 初回LINE追加フラグ
				}else{
					// LINE追加時以外の場合のみ 2022.05.16 No0759 対応で変更
					newCorrespond.FirstInquiryMeans__c   = CommonConst.FIRSTINQUIRYMEANS_MAIL;         // 初回問合せ方法（メール）
				}
				// ▲ 2022.04.20 No0758 対応で追加
            } else { //更新時のみ
                
                newCorrespond = oldCorrespond.clone(true,true); //Id含めてコピーTrue、値渡しTrue
                
                //更新時は、顧客でないなら一覧表示日時を設定しない
                if (oldCorrespond.AccountRecordType__c != CommonConst.ACCOUNT_RECTYPE_CUSTOMER) {
                    isSettingListViewDate = false;
                }
                //2020/6/9追加：追客解除設定日時をnullに更新する
                newCorrespond.PursuitDissolveSettingDate__c = null;

                //▼問合せNo0568で追加
                // ポータルサイトからのメールの場合
                if (echoMailInfo.mailType == MAIL_TYPE.PORTAL) {
                    newCorrespond.StaffSupportedFlg__c = True;                                  // スタッフ対応フラグ
                }
                //▲問合せNo0568で追加

            }
            
            // 新規時、更新時 共通の設定
            newCorrespond.EventDateTime__c = echoMailInfo.obj.InquiryDateTime__c;   // イベント時刻
            newCorrespond.IsBrowseFlg__c   = False;                                 // 閲覧フラグ

			// ▼ 2021.12.27 LINE連携対応より、追加
			// LINE受信時にLINE情報を設定
			if (echoMailInfo.obj.IsLineReceive__c) {

				// LINE会員
				newCorrespond.LineMember__c	= echoMailInfo.obj.LineMember__c;

				// LINEお友達登録日時
				if (echoMailInfo.obj.LineReceiveType__c == CommonConst.LINE_RECEIVE_TYPE_ADD) {
					newCorrespond.LineFriendAddDate__c = echoMailInfo.obj.InquiryDateTime__c;
				} 
				
				// LINE受信日時
				if (echoMailInfo.obj.LineReceiveType__c == CommonConst.LINE_RECEIVE_TYPE_RECEIVE) {
					newCorrespond.LineReceiveDate__c = echoMailInfo.obj.LineReceiveTime__c;
				}
			}
			// ▲ 2021.12.27
            
            if (isSettingListViewDate) {
                newCorrespond.ListViewDate__c = echoMailInfo.obj.InquiryDateTime__c;// 一覧表示日時
            }



            // ポータルサイトからのメールの場合
            if (echoMailInfo.mailType == MAIL_TYPE.PORTAL) {

                //▼ 2022.05.16 No0759 対応で変更　LINE追加時はポータルサイトをセットしない（反響数の制御）
                if (!echoMailInfo.obj.IsLineReceive__c) {
                    newCorrespond.PortalSite__c            = echoMailInfo.obj.FromPotalSite__c;   // ポータルサイト
                    newCorrespond.PortalSiteUrl__c         = echoMailInfo.url;                    // ポータルサイトURL
                }
                //▲ 2022.05.16 No0759 対応で変更
                // 問合せ323で追加　備考にお問合せ内容を追加
                newCorrespond.Remarks__c = echoMailInfo.obj.InquiryContent__c;
                //自社ポータルの来店予約メールか来店予約キャンセルメールの場合
                if (echoMailInfo.portalMailType == CommonConst_ptl.ECHOMAIL_MAILTYPE_VISITRESERVATION || echoMailInfo.portalMailType == CommonConst_ptl.ECHOMAIL_MAILTYPE_VISITRESERVATIONCHANCEL){
                    newCorrespond.ReceiveMailDateVisitReservation__c = echoMailInfo.obj.InquiryDateTime__c; // メール受信日時（来店予約）
                    newCorrespond.AppointmentReceiptNoMaintenance__c = true;    // 来店受付メンテ不要
                //他社ポータルか自社ポータル反響メールの場合
                }else{
                    newCorrespond.ReceiveMailDatePortal__c = echoMailInfo.obj.InquiryDateTime__c; // メール受信日時（ポータル）
                }
                
                if (isNew || oldCorrespond.EchoShop__c == null) { //新規or未設定なら
                    newCorrespond.EchoShop__c = echoMailInfo.shopId;                          // 反響担当店舗
                }
                
                if (isNew) { //新規なら 
                    newCorrespond.FirstInquiryProperty__c = echoMailInfo.obj.Response__c; // 初回問合せ物件
                    newCorrespond.District__c = echoMailInfo.district;                    // 地区 
                }
                
            } else {// ポータルサイト以外のメールの場合
                
                newCorrespond.ReceiveMailDateOther__c = echomailInfo.obj.InquiryDateTime__c; // メール受信日時（その他）
                
                if (echoMailInfo.isInnerSales) { //IS宛てのメールの場合
                    if (isNew || oldCorrespond.EchoShop__c == null ) { //新規or未設定なら
                        newCorrespond.EchoShop__c = echoMailInfo.shopId;                     // 反響担当店舗
                    }
                } else { //店舗宛てのメールの場合
                    if (isNew || oldCorrespond.VisitShop__c == null ) { //新規or未設定なら
                        newCorrespond.VisitShop__c = echoMailInfo.shopId;                    // 来店担当店舗
                    }
                }
            }
            

            //ポータルサイト構築 追加 Start
            //（自社ポータルで）メール種別が　来店予約メール
            if(echoMailInfo.portalMailType == CommonConst_ptl.ECHOMAIL_MAILTYPE_VISITRESERVATION){
                newCorrespond.VisitReservationFlag__c = true;               //来店予約フラグ
                newCorrespond.FirstVisitReservationCancelFlg__c = false;    //初回来店予約キャンセルフラグ
                //新規対応　または　対応の初回来店予約日がnullの既存対応
                if (isNew || (!isNew && oldCorrespond.FirstVisitReservationDate__c == null)){
                    if (echoMailInfo.obj.VisitReservationDate__c != null){
                        newCorrespond.FirstVisitReservationDate__c = echoMailInfo.obj.VisitReservationDate__c.date();//初回来店予約日

                    }
                }

                //対応のメール受信日時（ポータル）が空の場合、反響数非計算フラグ = true
                if (newCorrespond.ReceiveMailDatePortal__c == null){
                    newCorrespond.IsEchoNotCalculation__c = true;
                }

            //（自社ポータルで）メール種別が　来店予約キャンセルメール
            }else if (echoMailInfo.portalMailType == CommonConst_ptl.ECHOMAIL_MAILTYPE_VISITRESERVATIONCHANCEL){
                newCorrespond.FirstVisitReservationCancelFlg__c = true;      //初回来店予約キャンセルフラグ
            }
            //ポータルサイト構築 追加 End
            return newCorrespond; 
        }
        

        // 対応明細を登録用に作成
        private CorrespondDetail__c createCorrespondDetail(EchoMailInformation echoMailInfo) {
            
            CorrespondDetail__c coreDetail = new CorrespondDetail__c();
            coreDetail.SupportedDateTime__c = CommonUtil.getNow();                  // 対応日時
            coreDetail.SupportedTitle__c    = echoMailInfo.obj.Subject__c;          // 対応表題
            coreDetail.SupportedContent__c  = echoMailInfo.obj.Body__c;             // 対応内容
            coreDetail.Shop__c              = echoMailInfo.shopId;                  // 店舗
            coreDetail.MailType__c          = CommonConst.CORRESPONDDETAIL_MAILTYPE_RECEIVE; // メール種別
            coreDetail.Email__c             = echoMailInfo.obj.FromEmail__c;        // メール
            coreDetail.CorrespondType__c    = CommonConst.TASK_CORRESPONDTYPE_MAIL; // 対応種別
            coreDetail.EchoMail__c          = echoMailInfo.obj.Id;                  // 反響メール
            
            // ポータルサイトからの連携の場合のみ、以下の情報を設定する
            if (echoMailInfo.mailType == MAIL_TYPE.PORTAL) {
                coreDetail.PortalSiteUrl__c = echoMailInfo.url;             // ポータルサイトURL
            }
            
            //対応の情報から担当者を設定する
            if (this.correspondRecord.VisitShop__c == echoMailInfo.shopId) {       //来店店舗なら、来店担当者を設定
                coreDetail.Staff__c = this.correspondRecord.ShopStaff__c;
            } else if (this.correspondRecord.EchoShop__c == echoMailInfo.shopId) { //反響店舗なら、反響担当者を設定
                coreDetail.Staff__c = this.correspondRecord.EchoStaff__c;
            } else {
                coreDetail.Staff__c = null;                                        //両方違うなら、担当者を設定しない
            }
            
            return coreDetail;
        }

    }
    
    
    //
    //反響メール情報（対応や対応明細の引数用のクラス）
    //
    public class EchoMailInformation {
        
        public EchoMail__c obj;             //反響メールレコード
        public MAIL_TYPE mailType;          //メールタイプ（列挙型）

        //ポータルサイト構築 追加 Start
        public Boolean isMyPortal;             //自社ポータルフラグ
        public String portalMailType;       //自社ポータルメール種別
        //ポータルサイト構築 追加 End

        public Id shopId;                   //店舗Id
        public Boolean isInnerSales;        //ISかどうか
        public Id buildingId;               //建物Id(objの物件の建物)
        public String district;             //地区(objの物件の地区)
        
        //mailTypeがポータルサイトの場合に追加設定
        public String url;                  //URL
        
        //mailTypeがエラーメールの場合に追加設定
        public String errorFromMailAddress; //エラーの場合の顧客メール
		// ▼ 2021.12.27 LINE連携対応より、自動返信送信種別を追加
		public String autoReciveSendType;
		// ▲ 2021.12.27
        
        //コンストラクタ
        public EchoMailInformation(EchoMail__c obj, Shop__c targetShop, MAP<Id, Property__c> propertyMap, Map<Id,PortalSite__c> portalsitemap) {
            this.obj          = obj;                       // 反響メールレコード
            this.shopId       = targetShop.Id;             // 店舗Id
            this.isInnerSales = !targetShop.isShopType__c; // ISかどうか
            //ポータルサイト構築 追加 Start
            this.isMyPortal = false;                       //初期化
            if (portalSiteMap.containsKey(obj.FromPotalSite__c) && portalSiteMap.get(obj.FromPotalSite__c).Email__c == CommonConst_ptl.EMAIL_PORTAL){
                //fromポータルサイトが自社ポータルの場合
                this.isMyPortal = true;                       //自社ポータルフラグtrue
            }
            this.portalMailType = obj.MailType__c;          //自社ポータルメール種別
            //ポータルサイト構築 追加 End
            //メールに物件情報が含まれている場合
            if (propertyMap.containsKey(obj.Response__c)) {
                this.buildingId  = propertyMap.get(obj.Response__c).Building__c;             // 建物
                this.district    = propertyMap.get(obj.Response__c).Building__r.District__c; // 地区
            }
			// ▼ 2021.12.27 LINE連携対応より、自動返信送信種別を追加
			this.autoReciveSendType = CommonConst.THANKS_MAIL_SETTING_SEND_TYPE_MAIL;
			if (obj.IsLineReceive__c) {
				this.autoReciveSendType = CommonConst.THANKS_MAIL_SETTING_SEND_TYPE_LINE;
			}
			// ▲ 2021.12.27
        }
        
        //反響メールの種別判定と項目設定
        public void judgeMailType(MAP<Id, PortalSite__c> portalSiteMap, EchoMailInformation echoMailInfo) {
            if (portalSiteMap.containsKey(this.obj.FromPotalSite__c) && 
                echoMailInfo.portalMailType != CommonConst_ptl.ECHOMAIL_MAILTYPE_INQUIRY ) {
                // ポータルサイトからのメール かつ 
                //自社ポータル用メール種別が問合せメール以外である（ポータルサイト構築変更）
                setDetailFromPortal(portalSiteMap.get(this.obj.FromPotalSite__c).Url__c);
                
            //ポータルサイト構築 追加 自社ポータル用にエラーメール判断条件追加
            } else if (obj.FromEmail__c == CommonConst.EMAIL_ERROR || obj.FromEmail__c == SystemConfig__c.getInstance().ErrorEmaiPortal__c) {
                // 宛名なしエラーメールである
                setDetailFromError();                
            }else {
                // 問合せメールである
                setDetailFromInquiry();
            }
        }
        
        
        //反響メールがポータルサイトの場合の設定
        private void setDetailFromPortal(String url) {
            this.mailType = MAIL_TYPE.PORTAL; //ポータルサイトからのメールである
            this.url      = url;   //URL
        }
        
        //反響メールがエラーメールの場合の設定
        private void setDetailFromError() {
            this.mailType = MAIL_TYPE.ERROR; //エラーのメールである
            //エラーメールの顧客アドレスを本文から抽出
            if (this.obj.Body__c != null) {
                this.errorFromMailAddress = getErrorMailAddress(this.obj);
            }
        }

        
        //反響メールが問合せメールの場合の設定
        private void setDetailFromInquiry() {
            this.mailType = MAIL_TYPE.INQUIRY; //問合せのメールである
        }
        

    }
    
	// ▼ 2021.12.27 LINE連携対応より、"LINE履歴"、"LINE受信フラグ"、"お客様名"を追加、コードの見直し
	/**
	 * 自動返信情報
	 */
	public class AutoReciveInfo {

		/** 項目 */
		public ReplaceTextInfo		replaceTextInfo;	// 文字列置換情報
		public MailUtil.MailData	mailData;			// メール送信情報
		public Correspond__c		correspond;			// 対応
		public CorrespondDetail__c	correspondDetail;	// 対応明細
		public LineMember__c		lineMember;			// LINE会員
		public LineHistory__c		lineHistory;		// LINE履歴
		public Boolean				isLineReceive;		// LINE受信フラグ

		/**
		 * コンストラクタ
		 */
		public autoReciveInfo() {
			this.replaceTextInfo	= new ReplaceTextInfo();
			this.mailData			= new MailUtil.MailData();
			this.correspond			= new Correspond__c();
			this.correspondDetail	= new CorrespondDetail__c();
			this.lineMember			= new LineMember__c();
			this.lineHistory		= new LineHistory__c();
			this.isLineReceive		= false;
		}
	}

	/**
	 * 文字列置換情報
	 */
	public class ReplaceTextInfo {

		/** 項目 */
		public Account 			account;		// 取引先
		public Shop__c 			shop;			// 店舗
		public EchoMail__c 		echoMail;		// 反響メール
		public Correspond__c	correspond;		// 対応
		public String			customerName;	// お客様名
		public String			chargeName;		// 担当者名
		public String			sendingTime;	// 挨拶時刻

		/**
		 * コンストラクタ
		 */
		ReplaceTextInfo() {
			this.account		= new Account();
			this.shop			= new Shop__c();
			this.echoMail		= new EchoMail__c();
			this.correspond		= new Correspond__c();
			this.customerName	= CommonConst.STRING_EMPTY;
			this.chargeName		= CommonConst.STRING_EMPTY;
			this.sendingTime	= CommonConst.STRING_EMPTY;
		}
	}
	// ▲ 2021.12.27
}