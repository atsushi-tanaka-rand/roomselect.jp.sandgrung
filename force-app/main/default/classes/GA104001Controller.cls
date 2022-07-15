/* *
 * 物件検索画面
 * GA104001
 */
public class GA104001Controller {

    /** パブリック変数 */
    Transient public Boolean isOpenError { get; set; }                      // エラーフラグ
    public Integer detailIndex { get;set; }                                 // 明細行Index
    Transient public Boolean hasErrorMessage {get; set;}                    // エラーメッセージ
    public List<SelectOption> trainRouteOption  { get; set; }               // 選択リスト（路線）
    public List<SelectOption> walkingTimeOption { get; set; }               // 選択リスト（徒歩）
    public List<SelectOption> occupancyAreaLowerLimitOption { get; set; }   // 選択リスト（占有面積下限）
    public List<SelectOption> occupancyAreaUpperLimitOption { get; set; }   // 選択リスト（占有面積上限）
    public List<SelectOption> buildingAgeOption { get; set; }               // 選択リスト（築年数）
    public List<SelectOption> districtOption { get; set; }                  // 問合せ367で追加　地区
    public Boolean            allSelected   { get; set; }                   // 全選択チェックボックス
    public Boolean            isVisitor { get; private set; }
    public String             GA104002Parameter { get; set; }               // 物件MAP照会用引渡パラメータ
    Transient public String   attachmentIdList { get; set; }                // 添付Id格納用

    // メッセージ(js用)
    public String MSG_COM_V_FAVORITE    { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_V_REGISTRATION, 'お気に入り物件を');}     private set; }  //js用保存確認メッセージ}
    public String MSG_COM_I_FAVORITE    { get{return CommonUtil.callMessageCreate(CommonConst.MSG_COM_I_SAVE);}                                 private set; }  //js用保存確認メッセージ}

    /** 内部クラスレコード */
    public DisplaySearchCondition           dispCondition {get; set;}
    public DispaySearchCount                dispSerachCount {get; set;}
    Transient public List<DisplaySearchResult> searchResultList { get; set; }   // 検索結果
    public List<DisplaySearchResultCheck>   detailCheck { get; set; }           // 検索結果のチェック状態保持用
    public List<List<Integer>>              searchResultIndexList {get; set;}   // 検索結果の表示制御、内部制御用インデックス ※1000件毎の2階層List

    /** 共通クラス */
    public GA104007ParameterClass GA104007Parameter{ get; set; }  // 駅モーダルパラメタ
    public GA202002ParameterClass GA202002Parameter{get; set;}    // 学区選択モーダル　問合せ367で追加

    /** プライベート定数 */
    private final String OCCUPANCYAREA_LOWERLIMIT_NULL = '0';
    private final String OCCUPANCYAREA_UPPERIMIT_NULL  = '999';
    private final String WALKINGTIME_NULL              = '999';
    private final String BUILDINGAGE_NULL              = '999';

    /** プライベート変数 */
	private Id spcId = null; // 2021.10.08 No.307 対応で追加
    private Id accountId = null;

    // 検索上限取得
    private Integer searchLimit = Integer.valueOf(SystemConfig__c.getInstance().PropertySearchMaxCount__c);
    
    // 検索条件
    private String searchPropNameText               = CommonConst.STRING_EMPTY; // 物件名
    private String searchSupplierNameText           = CommonConst.STRING_EMPTY; // 元付業者
    private List<String> searchAddressText          = new List<String>();       // 住所
    private List<Station__c> searchSetationIdText   = new List<Station__c>();   // 駅
    private List<String> searchLiveStatusText       = new List<String>();       // 現況
    private List<String> searchStructureText        = new List<String>();       // 建物構造
    private List<String> searchBalconyDirectionText = new List<String>();       // 方角
    private List<String> searchPointText            = new List<String>();       // 点数

    //モーダル画面の判別用フラグ
    private Integer modalMode;

    //コンストラクタ
    public GA104001Controller() {
        try {

            // エラーフラグ初期化
            this.isOpenError = false;
            this.hasErrorMessage = false;

            //パラメタ取得
			// ▼2021.10.08 No.307 対応で取得パラメータ変更
			this.spcId = ApexPages.currentPage().getParameters().get('Id');
			this.accountId = ApexPages.currentPage().getParameters().get('accountId');
			// ▲2021.10.08 No.307 対応で取得パラメータ変更

            // 初期化処理
            init();

            //店舗異動が取得できなければエラー
            CommonUtil.getStaffCurrentShop();

            // 内部クラス作成
			// ▼2021.10.08 No.307 対応でお客様物件条件を使用するケースを追加
			if(this.spcId != null){
				this.isVisitor = true;
				if(isIdTypeAccount(this.spcId)){
					Account ac = selectAccount(this.spcId);
					Map<Id, List<Station__c>> stationMap = selectTrain(ac);
					// 問合せ367で追加
					Map<id, List<school__c>> schoolMap = selectSchool(ac);
					// 問合せ367で引数stationMap追加
					this.dispCondition          = new DisplaySearchCondition(ac, stationMap, schoolMap);
				}else{
					AccountPropertyConditions__c spc = selectSpc(this.spcId);
					Map<Id, List<Station__c>> stationMap = selectTrain(spc);
					// 問合せ367で追加
					Map<id, List<school__c>> schoolMap = selectSchool(spc);
					// 問合せ367で引数stationMap追加
					this.dispCondition          = new DisplaySearchCondition(spc, stationMap, schoolMap);
				}
				
			// ▲2021.10.08 No.307 対応でお客様物件条件を使用するケースを追加
                this.searchResultList       = selectProperty(this.dispCondition);
                this.setSearchResultIndexList(this.searchResultList);
                this.dispSerachCount        = selectCount(this.dispCondition, this.searchResultList.size());
                this.initDetailCheckList(this.searchResultList);
            }else{
                this.isVisitor              = false;
                this.dispCondition          = new DisplaySearchCondition();
                this.searchResultList       = new List<DisplaySearchResult>();
                this.searchResultIndexList  = new List<List<Integer>>();
                this.dispSerachCount        = new DispaySearchCount();
                this.detailCheck            = new List<DisplaySearchResultCheck>();
            }

        } catch (BusinessLogicException e) {
            this.isOpenError = true;
            for (String err : e.errMessage) {
                // 検索結果件数エラー時は、起動時エラーとしない。
                if (err == CommonConst.MSG_COM_W_SEARCH_NO_DATA || err == CommonConst.MSG_COM_W_SEARCH_RESULT_LIMIT_OVER) {
                    this.isOpenError = false;
                }
            }
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        } catch (Exception e) {
            this.isOpenError = true;
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }



    /**
     * 初期化処理
     * @param  なし
     * @return なし
     */
    private void init() {
        //モーダルパラメタ初期化
        this.GA104007Parameter = new GA104007ParameterClass ();   // 駅モーダルパラメタ
        this.GA202002Parameter = new GA202002ParameterClass();   // 学区選択モーダル　問合せ367で追加

        // 選択リストの設定
        this.trainRouteOption               = CommonUtil.getSelectOptionFromObjectData('TrainRoute__c','Id','Name', 'SortOrder__c');   // 路線
		// ▼2021.10.08 No.307 対応でお客様物件条件を使用するケースを追加
		if(isIdTypeAccount(this.spcId)){
			this.walkingTimeOption              = CommonUtil.getSelectOptionFromObject('Account', 'WalkingTime__c', false);					// 徒歩
			this.occupancyAreaLowerLimitOption  = CommonUtil.getSelectOptionFromObject('Account', 'OccupancyAreaLowerLimit__c', false);		// 占有面積(下限)
			this.occupancyAreaUpperLimitOption  = CommonUtil.getSelectOptionFromObject('Account', 'OccupancyAreaUpperLimit__c', false);		// 占有面積(下限)
			this.buildingAgeOption              = CommonUtil.getSelectOptionFromObject('Account', 'BuildingAge__c', false);					// 築年数
		}else{
			this.walkingTimeOption              = CommonUtil.getSelectOptionFromObject('AccountPropertyConditions__c', 'WalkingTime__c', false);				// 徒歩
			this.occupancyAreaLowerLimitOption  = CommonUtil.getSelectOptionFromObject('AccountPropertyConditions__c', 'OccupancyAreaLowerLimit__c', false);	// 占有面積(下限)
			this.occupancyAreaUpperLimitOption  = CommonUtil.getSelectOptionFromObject('AccountPropertyConditions__c', 'OccupancyAreaUpperLimit__c', false);	// 占有面積(下限)
			this.buildingAgeOption              = CommonUtil.getSelectOptionFromObject('AccountPropertyConditions__c', 'BuildingAge__c', false);				// 築年数
		}
		// ▲2021.10.08 No.307 対応でお客様物件条件を使用するケースを追加
        // 問合せ367で追加
        List<SelectOption> districtOption = new List<SelectOption>();
        List<SelectOption> beforeProcessList = new List<SelectOption>();
        beforeProcessList = CommonUtil.getSelectOptionFromObject('DesiredSchoolArea__c', 'SchoolArea__c', TRUE);// 問合せ415で追加　学区
        for (SelectOption so : beforeProcessList) {
            if(so.getLabel() != 'その他') {
                districtOption.add(so);
            }
        }
        this.districtOption = districtOption;

        // 内部クラス初期化
        this.dispCondition          = new DisplaySearchCondition();
        this.searchResultList       = new List<DisplaySearchResult>();
        this.searchResultIndexList  = new List<List<Integer>>();
        this.dispSerachCount        = new DispaySearchCount();
        this.detailCheck            = new List<DisplaySearchResultCheck>();

        this.allSelected   = false;
    }


    
    //******************************************************************** publicメソッド ********************************************************************

    /**
     * 画面.路線1変更時処理
     * @param  なし
     * @return なし
     */
    public void changeTrainRoute1(){
        this.dispCondition.stations1     = new List<Station__c>();    // 選択された駅を初期化
        this.dispCondition.stationsChar1 = null;                      // 表示用の選択された駅を初期化
    }
    /**
     * 画面.路線2変更時処理
     * @param  なし
     * @return なし
     */
    public void changeTrainRoute2(){
        this.dispCondition.stations2     = new List<Station__c>();    // 選択された駅を初期化
        this.dispCondition.stationsChar2 = null;                      // 表示用の選択された駅を初期化
    }
    /**
     * 画面.路線3変更時処理
     * @param  なし
     * @return なし
     */
    public void changeTrainRoute3(){
        this.dispCondition.stations3     = new List<Station__c>();    // 選択された駅を初期化
        this.dispCondition.stationsChar3 = null;                      // 表示用の選択された駅を初期化
    }

    // ▼問合せ367で追加
    // 中学校変更処理
    public void changeJuniorHighSchool() {
        this.dispCondition.juniorHighSchoolList = new List<School__c>();//選択された中学校を初期化
        this.dispCondition.juniorHighSchool = null;//表示用の選択された中学校を初期化
    }

    // 小学校変更処理
    public void changeElementarySchool() {
        this.dispCondition.elementarySchoolList = new List<School__c>();//選択された小学校を初期化
        this.dispCondition.elementarySchool = null;//表示用の選択された小学校を初期化
    }
    // ▲問合せ367で追加

    /**
     * 駅１モーダルOpenの処理
     * @param  なし
     * @return なし
     */
    public void openStations1Modal() {
        try {
            hasErrorMessage = false;
            modalMode = 1;
            openModal();
        } catch(Exception e) {
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 駅２モーダルOpenの処理
     * @param  なし
     * @return なし
     */
    public void openStations2Modal() {
        try {
            hasErrorMessage = false;
            modalMode = 2;
            openModal();
        } catch(Exception e) {
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 駅３モーダルOpenの処理
     * @param  なし
     * @return なし
     */
    public void openStations3Modal() {
        try {
            hasErrorMessage = false;
            modalMode = 3;
            openModal();
        } catch(Exception e) {
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // ▼問合せ367で追加
    //中学校区モーダルOpenの処理
    public void openJuniorHighSchoolDistrictModal() {
        
        try{
            hasErrorMessage = FALSE;
            modalMode = 4;
            openModal();
        }catch(Exception e){
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //小学校区モーダルOpenの処理
    public void openElementarySchoolDistrictModal() {
    
        try{
            hasErrorMessage = FALSE;
            modalMode = 5;
            openModal();
        }catch(Exception e){
            //エラーを設定
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }
    // ▲問合せ367で追加

    /**
     * OpenModal共通
     * @param  なし
     * @return なし
     */
    public void openModal() {
        if (modalMode == 1) {
            // 駅１
            this.GA104007Parameter.isDrawing          = true;
            this.GA104007Parameter.noFirst            = true;
            if (dispCondition.trainRoute1 != null ){//選択された路線を設定
                this.GA104007Parameter.selectedTrainRoute = [SELECT Id, Name FROM TrainRoute__c WHERE Id = :dispCondition.trainRoute1];
            }        
            this.GA104007Parameter.selectedStation = new List<Station__c>();//パラメータ初期化
            if (this.dispCondition.stations1.size() > 0) {//選択された駅を設定
                this.GA104007Parameter.selectedStation    = this.dispCondition.stations1;
            }
        } else if (modalMode == 2) {
            // 駅２
            this.GA104007Parameter.isDrawing          = true;
            this.GA104007Parameter.noFirst            = true;
            if (dispCondition.trainRoute2 != null ){//選択された路線を設定
                this.GA104007Parameter.selectedTrainRoute = [SELECT Id, Name FROM TrainRoute__c WHERE Id = :dispCondition.trainRoute2];
            }        
            this.GA104007Parameter.selectedStation = new List<Station__c>();//パラメータ初期化
            if (this.dispCondition.stations2.size() > 0) {//選択された駅を設定
                this.GA104007Parameter.selectedStation    = this.dispCondition.stations2;
            }
        } else if (modalMode == 3) {
            // 駅３
            this.GA104007Parameter.isDrawing          = true;
            this.GA104007Parameter.noFirst            = true;
            if (dispCondition.trainRoute3 != null ){//選択された路線を設定
                this.GA104007Parameter.selectedTrainRoute = [SELECT Id, Name FROM TrainRoute__c WHERE Id = :dispCondition.trainRoute3];
            }        
            this.GA104007Parameter.selectedStation = new List<Station__c>();//パラメータ初期化
            if (this.dispCondition.stations3.size() > 0) {//選択された駅を設定
                this.GA104007Parameter.selectedStation    = this.dispCondition.stations3;
            }

        // 問合せ415で追加
        } else if (modalMode == 4) {
            // 中学校区
            this.GA202002Parameter.isDrawing          = true;
            this.GA202002Parameter.noFirst            = true;
            if (dispCondition.juniorHighSchoolArea != null ){//選択された中学校区を設定
                this.GA202002Parameter.juniorHighSchoolArea = dispCondition.juniorHighSchoolArea;
            }

            this.GA202002Parameter.selectedSchool = new List<School__c>();//パラメータ初期化
            if (this.dispCondition.juniorHighSchoolList.size() > 0) {//選択された学校を設定
                this.GA202002Parameter.selectedSchool    = this.dispCondition.juniorHighSchoolList;
            }

            // モーダル側での小学校か中学校かの判定のため
            this.GA202002Parameter.modalMode = 6;

        } else if (modalMode == 5) {
            // 小学校区
            this.GA202002Parameter.isDrawing          = true;
            this.GA202002Parameter.noFirst            = true;
            if (dispCondition.elementarySchoolArea != null ){//選択された小学校区を設定
                this.GA202002Parameter.elementarySchoolArea = dispCondition.elementarySchoolArea;
            }

            this.GA202002Parameter.selectedSchool = new List<School__c>();//パラメータ初期化
            if (this.dispCondition.elementarySchoolList.size() > 0) {//選択された学校を設定
                this.GA202002Parameter.selectedSchool    = this.dispCondition.elementarySchoolList;
            }

            // モーダル側での小学校か中学校かの判定のため
            this.GA202002Parameter.modalMode = 7;
        } 
    }
    /**
     * モーダル共通close
     *  ※modalModeの値により、モーダルを特定
     * @param  なし
     * @return なし
     */
    public void closeModal(){
        if(modalMode== 1){
            // 路線１
            this.dispCondition.stations1     = this.GA104007Parameter.selectedStation;//モーダルで選択された駅
            this.dispCondition.stationsChar1 = convStationListToString(this.GA104007Parameter.selectedStation);//表示用のモーダルで選択された駅
        } else if(modalMode == 2){
            // 路線２
            this.dispCondition.stations2     = this.GA104007Parameter.selectedStation;//モーダルで選択された駅
            this.dispCondition.stationsChar2 = convStationListToString(this.GA104007Parameter.selectedStation);//表示用のモーダルで選択された駅

        } else if(modalMode == 3){
            // 路線３
            this.dispCondition.stations3     = this.GA104007Parameter.selectedStation;//モーダルで選択された駅
            this.dispCondition.stationsChar3 = convStationListToString(this.GA104007Parameter.selectedStation);//表示用のモーダルで選択された駅
        // ▼問合せ415で追加
        } else if(modalMode == 4) {
            // 中学校
            this.dispCondition.juniorHighSchoolList = this.GA202002Parameter.selectedSchool;//モーダルで選択された学校（中学校）
            this.dispCondition.juniorHighSchool = convSchoolListToString(this.GA202002Parameter.selectedSchool);//表示用のモーダルで選択された学校（中学校）
        } else if(modalMode == 5) {
            // 小学校
            this.dispCondition.elementarySchoolList = this.GA202002Parameter.selectedSchool;//モーダルで選択された学校（小学校）
            this.dispCondition.elementarySchool = convSchoolListToString(this.GA202002Parameter.selectedSchool);//表示用のモーダルで選択された学校（小学校）
        } 
        // ▲問合せ415で追加
        modalMode = 0;//モーダルの判別フラグを初期化
    }


    /**
     * 検索ボタン 押下
     * 　入力した条件にて、物件を検索
     * @param  なし
     * @return なし
     */
    public void searchProperty() {
        try {
            // 初期化
            this.allSelected = false;
            this.hasErrorMessage = false;

            // 検索結果 初期化
            this.searchResultList = new List<DisplaySearchResult>();
            this.setSearchResultIndexList(this.searchResultList);
            this.initDetailCheckList(this.searchResultList);

            // 検索条件チェック
            // 入力チェック
            BusinessLogicException ex = new BusinessLogicException();
            ex = checkSearchCondition(ex, this.dispCondition);

            // 入力チェック結果にエラーがある場合、例外をスローさせる
            if (ex.hasMessage()){ 
                throw ex;
            }

            // 検索条件を保存()
            if (this.isVisitor) {
				// ▼2021.10.08 No.307 対応でお客様物件条件を使用するケースを追加
				if(isIdTypeAccount(this.spcId)){
					upsertAccount(this.dispCondition);
				}else{
					upsertSpc(this.dispCondition);
				}
				// ▲2021.10.08 No.307 対応でお客様物件条件を使用するケースを追加
            }

            // 物件検索
            this.searchResultList = selectProperty(this.dispCondition);
            this.setSearchResultIndexList(this.searchResultList);
            this.initDetailCheckList(this.searchResultList);

            // 件数カウント
            this.dispSerachCount = selectCount(this.dispCondition, this.searchResultList.size());

        } catch(Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }


    /**
     * お気に入り登録ボタン 押下
     *  選択した物件をお気に入りに登録する
     * @param  なし
     * @return なし
     */
    public void saveFavorite() {
        try {

            // チェック数をカウント
            Integer cnt = 0;
            for (DisplaySearchResultCheck obj : this.detailCheck) {
                if (obj.isCheck) {
                    cnt++;
                    break;
                }
            }

            if (cnt == 0) {
                BusinessLogicException ex = new BusinessLogicException();
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION,'お気に入り登録', '検索結果から物件'));
                throw ex;
            }

            // 登録済みのお気に入り取得
            Set<Id> searchSetId = new Set<Id>();
            for (FavoriteProperty__c obj : [SELECT Property__c FROM FavoriteProperty__c WHERE Account__c = :this.accountId]) {
                searchSetId.add(obj.Property__c);
            }
            // 登録用リスト作成
            List<FavoriteProperty__c> favoriteList = new List<FavoriteProperty__c>();
            for (DisplaySearchResultCheck obj : this.detailCheck) {
                if (obj.isCheck && !searchSetId.contains(obj.propertyId)) {
                    favoriteList.add(new FavoriteProperty__c(Account__c  = this.accountId
                                                            ,Property__c = obj.propertyId));
                }
            }

            // お気に入り登録
            if (favoriteList.size() > 0) {
                SecureDML.secureInsert(favoriteList);
            }

        } catch(Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 地図を表示ボタン 押下
     *  物件MAP照会画面への遷移準備処理
     * @param  なし
     * @return なし
     */
    public void createPropertyMapParameter() {
        try {
            // 初期化
            this.hasErrorMessage = false;

            // チェック有物件のId取得
            String idList = '';    //チェックされたとき用
            String idAllList = ''; //未チェック用（※全件チェックされているとみなす）
            for (DisplaySearchResultCheck obj : this.detailCheck) {
                if (obj.isCheck) {
                    idList  += String.isEmpty(idList) ? '' : ',';
                    idList  += obj.propertyId;
                }
                idAllList += String.isEmpty(idAllList) ? '' : ',';
                idAllList += obj.propertyId;
            }

            // 未選択の場合
            if (String.isEmpty(idList)) {
                idList = idAllList;
            }

            // 物件MAP照会へのパラメータ引渡用のレコードを作成する
            PropertyMapParameter__c propMapParam = new PropertyMapParameter__c(
                PropertyIdList__c = idList
            );
            SecureDML.secureInsert(propMapParam);

            // パラメータをPage公開用の変数に設定
            this.GA104002Parameter = 'isClient=false';
            this.GA104002Parameter += '&propertyMapParamId=' + propMapParam.Id;
            if (this.isVisitor) {
                this.GA104002Parameter += '&accountId=' + this.accountId;
            }

        } catch(Exception e) {
            this.hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    //******************************************************************** privateメソッド ********************************************************************

    /**
     * 検索条件チェック
     * @param   BusinessLogicException ex   Exception
     * @param   DisplaySearchCondition cd   取得条件
     * @return  なし
     */
    private BusinessLogicException checkSearchCondition(BusinessLogicException ex, DisplaySearchCondition cd) {
        //路線選択時は、駅必須
        if ((cd.trainRoute1 != null && cd.stations1.size() == 0) ||
            (cd.trainRoute2 != null && cd.stations2.size() == 0) ||
            (cd.trainRoute3 != null && cd.stations3.size() == 0)) {
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'路線を選択した場合、駅', '1'));
        }
        // 校区選択時は学校必須　問合せ367で追加
        if((cd.juniorHighSchoolArea != null && cd.juniorHighSchoolList.size() == 0) ||
            (cd.elementarySchoolArea != null && cd.elementarySchoolList.size() == 0)) {
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SELECTION_OR_MORE,'校区を選択した場合、学校', '1'));
        }
        return ex;
    }

    /**
     * 物件検索の実行
     * @param   DisplaySearchCondition cd   取得条件
     * @return  List<DisplaySearchResult>   検索結果
     */
    private List<DisplaySearchResult> selectProperty(DisplaySearchCondition cd) {
        BusinessLogicException ex = new BusinessLogicException();//ビジネスロジックException準備
        // 検索条件初期化
        searchPropNameText         = CommonConst.STRING_EMPTY; // 物件名
        searchSupplierNameText     = CommonConst.STRING_EMPTY; // 元付業者
        searchAddressText          = new List<String>();       // 住所
        searchSetationIdText       = new List<Station__c>();   // 駅
        searchLiveStatusText       = new List<String>();       // 現況
        searchStructureText        = new List<String>();       // 建物構造
        searchBalconyDirectionText = new List<String>();       // 方角
        searchPointText            = new List<String>();       // 点数

        // SOQL作成
        String sectionW = createWhereSection(cd);
        String sectionS = createSelectSection();
        String sql = sectionS + sectionW + ' LIMIT :searchLimit';

        // SQL発行
        Map<Id, Property__c> propertyMap = new Map<Id, Property__c>((List<Property__c>)Database.query(sql));

        // データ件数超過の場合はエラー
        if (propertyMap.size() > searchLimit) {
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_RESULT_LIMIT_OVER ));
            throw ex;
        }

        // フリーワード検索
        List<sObject> findResult = new List<sObject>();
        if (String.isBlank(cd.propertyCode) && !String.isBlank(cd.freeWord)) {
            sql = 'FIND \'*' + String.escapeSingleQuotes(cd.freeWord) + '*\' IN ALL FIELDS RETURNING PROPERTY__c(Id)';
            findResult = search.query(sql)[0];
        }

        // 検索結果作成
        List<DisplaySearchResult> resultList = new List<DisplaySearchResult>();
        if (!String.isBlank(cd.freeWord)) {
            for (sObject find : findResult) {
                Property__c prop = (Property__c)find;
                if (propertyMap.containskey(prop.Id)) {
                    Property__c propData = propertyMap.get(prop.Id);
                    resultList.add(new DisplaySearchResult(propData));
                }
            }
        } else {
            for (Id key : propertyMap.keySet()) {
                Property__c prop = propertyMap.get(key);
                resultList.add(new DisplaySearchResult(prop));
            }
        }

        // 該当データが存在しない場合はエラー
        if (resultList.size() == 0) {
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA ));
            throw ex;
        }

        // 返却
        return resultList;
    }

    private void setSearchResultIndexList(List<DisplaySearchResult> displaySearchResult) {
        //Listを画面表示用に1000件毎に分割した2階層List化する
        this.searchResultIndexList = new List<List<Integer>>();
        this.searchResultIndexList.add(new List<Integer>());
        Integer parentIndex = 0;
        Integer childIndex = 0;
        for (DisplaySearchResult record : displaySearchResult) {
            if (Math.mod(childIndex, 1000) == 0) {
                this.searchResultIndexList.add(new List<Integer>());
                parentIndex++;
            }
            this.searchResultIndexList[parentIndex].add(childIndex);
            childIndex++;
        }
    }

    /**
     * 明細チェック状態保持用Listの初期化
     */
    private void initDetailCheckList(List<DisplaySearchResult> displaySearchResult) {
        this.detailCheck = new List<DisplaySearchResultCheck>();
        for (DisplaySearchResult obj : displaySearchResult) {
            detailCheck.add(new DisplaySearchResultCheck(obj.propertyId));
        }
    }


    /**
     * 物件検索 WHERE句作成処理
     * @param DisplaySearchCondition cd  検索条件
     * @return String   Where句文字列
     */
    private String createWhereSection(DisplaySearchCondition cd) {
        String sectionW = CommonConst.STRING_EMPTY;

        List<String> whereList          = new List<String>();   // 建物,物件用条件
        List<String> propCnoudWhereList = new List<String>();   // 物件条件用条件


        // ▼ 物件IDによる検索※物件IDが入力されている場合は、物件IDでのみ検索
        if (!String.isBlank(cd.propertyCode)) {
            return ' WHERE PropertyCode__c = \'' + String.escapeSingleQuotes(cd.propertyCode) + '\'';
        }
        // ▲ 物件IDによる検索

        
        // ▼ テキスト検索項目
        // 物件名 ※建物名１～３、建物名カナ１～３にて検索
        if (!String.isBlank(cd.propertyName)) {
            searchPropNameText    = '%' + CommonUtil.convertDisableWildcard(cd.propertyName)       + '%';
            whereList.add('((Building__r.Name          LIKE :searchPropNameText ) OR ' + 
                          ' (Building__r.BuildName2__c LIKE :searchPropNameText ) OR ' + 
                          ' (Building__r.BuildName3__c LIKE :searchPropNameText ) OR ' + 
                          ' (Building__r.BuildKana__c  LIKE :searchPropNameText ) OR ' + 
                          ' (Building__r.BuildKana2__c LIKE :searchPropNameText ) OR ' + 
                          ' (Building__r.BuildKana3__c LIKE :searchPropNameText ))   ' );
        }

        // 元付業者
        if (!String.isBlank(cd.formerSupplierName)) {
            searchSupplierNameText = '%' + CommonUtil.convertDisableWildcard(cd.formerSupplierName) + '%';
            whereList.add('FormerSupplier__r.Name LIKE :searchSupplierNameText');
        }

        // 住所
        if (!String.isBlank(cd.address)) {
            searchAddressText = new List<String>();
            for (String str : cd.address.split('( |　)+')) {
                searchAddressText.add('%'+ CommonUtil.convertDisableWildcard(str) + '%');
            }
            whereList.add('Building__r.Address__c LIKE :searchAddressText');
        }
        // ▲ テキスト項目項目

        // ▼ 路線
        // 駅 ※緯度、経度にて検索を実施
        Set<Id> stationSetId = new Set<Id>();
        for (Station__c obj : cd.stations1) {
            stationSetId.add(obj.Id);
        }
        for (Station__c obj : cd.stations2) {
            stationSetId.add(obj.Id);
        }
        for (Station__c obj : cd.stations3) {
            stationSetId.add(obj.Id);
        }
        if (stationSetId.size() > 0) {
            // 緯度,経度より対象となる駅のID取得
            List<String> tmpList = new List<String>();
            List<Station__c> condStationList = [SELECT Latitude__c, Longitude__c FROM Station__c WHERE Id IN :stationSetId AND Latitude__c != null AND Longitude__c != null];
            for (Station__c obj : condStationList) {
                tmpList.add('(Latitude__c = ' + obj.Latitude__c + ' AND Longitude__c = ' + obj.Longitude__c + ')');
            }
            // 対象の経度,緯度が設定されている場合のみ設定
            if (condStationList.size() > 0) {
                String sql = CommonConst.STRING_EMPTY;
                sql += 'SELECT ID FROM Station__c WHERE ' + String.join(tmpList, ' OR ');
                searchSetationIdText = Database.query(sql);

                // ★駅の指定がある & 駅までの徒歩時間の指定もある場合
                if (cd.walkingTime != null){
                    whereList.add('((Building__r.Station1__c IN :searchSetationIdText AND Building__r.StationWalkTime1__c <= ' + cd.walkingTime + ' ) OR ' +
                    '(Building__r.Station2__c IN :searchSetationIdText AND Building__r.StationWalkTime2__c <= ' + cd.walkingTime + ' ) OR ' +
                    '(Building__r.Station3__c IN :searchSetationIdText AND Building__r.StationWalkTime3__c <= ' + cd.walkingTime + ' )) ');

                // 駅の指定がある & 駅までの徒歩時間の指定なしの場合
                }else{
                    whereList.add('(Building__r.Station1__c IN :searchSetationIdText OR ' +
                                  ' Building__r.Station2__c IN :searchSetationIdText OR ' +
                                  ' Building__r.Station3__c IN :searchSetationIdText)');
                }

            }
        }else{
             // 駅が選択されていない & 駅までの徒歩時間の指定ありの場合
            if (cd.walkingTime != WALKINGTIME_NULL && !String.isBlank(cd.walkingTime)) {
                whereList.add('(Building__r.StationWalkTime1__c <= ' + cd.walkingTime + ' OR ' +
                            ' Building__r.StationWalkTime2__c <= ' + cd.walkingTime + ' OR ' +
                            ' Building__r.StationWalkTime3__c <= ' + cd.walkingTime + ')') ;
            }
        }

       
        // ▲ 路線

        // ▼ 校区　問合せ367で追加
        // 中学校
        Set<Id> juniorHighSchoolSetId = new Set<Id>();
        // 小学校
        Set<Id> elementarySchoolSetId = new Set<Id>();
        
        if(cd.juniorHighSchoolList.size() != 0) {
            for(School__c juniorHighSchool : cd.juniorHighSchoolList){//選択された中学校区から希望学校を設定
                juniorHighSchoolSetId.add(juniorHighSchool.id);
            }
        }

        if(cd.elementarySchoolList.size() != 0) {
            for(School__c elementarySchool : cd.elementarySchoolList){//選択された小学校区から希望学校を設定
                elementarySchoolSetId.add(elementarySchool.id);
            }
        }

        if(juniorHighSchoolSetId.size() > 0) {
            String juniorHighSchoolId = '(';
            Integer loopCount = 1;
            for(id jhid : juniorHighSchoolSetId) {
                if(juniorHighSchoolSetId.size() == loopCount) {
                    juniorHighSchoolId += '\'' + jhid + '\'';
                } else {
                    juniorHighSchoolId += '\'' + jhid + '\',';
                }
                loopCount++;
            }
            juniorHighSchoolId += ')';
            whereList.add('((Building__r.JuniorHighSchool1__c IN ' + juniorHighSchoolId + ') OR ('
            + 'Building__r.JuniorHighSchool2__c IN ' + juniorHighSchoolId + ') OR ('
            + 'Building__r.JuniorHighSchool3__c IN ' + juniorHighSchoolId + '))');
        }
        if(elementarySchoolSetId.size() > 0) {
            String elementarySchoolId = '(';
            Integer loopCount = 1;
            for(id eid : elementarySchoolSetId) {
                if(elementarySchoolSetId.size() == loopCount) {
                    elementarySchoolId += '\'' + eid + '\'';
                } else {
                    elementarySchoolId += '\'' + eid + '\',';
                }
                loopCount++;
            }
            elementarySchoolId += ')';
            whereList.add('((Building__r.PrimarySchool1__c IN ' + elementarySchoolId + ') OR ('
            + 'Building__r.PrimarySchool2__c IN ' + elementarySchoolId + ') OR ('
            + 'Building__r.PrimarySchool3__c IN ' + elementarySchoolId + '))');
        }

        // ▼ 住居条件
        // 居住中, 空室, 退去予定
        if (cd.isLiveStatusLive || cd.isLiveStatusEmpty || cd.IsLiveStatusLeaveSchedule) {
            // 住居中
            if (cd.isLiveStatusLive) {
                searchLiveStatusText.add(String.escapeSingleQuotes(CommonConst.PROPERTY_LIVESTATUS_RESIDENT));
            }
            // 空室
            if (cd.isLiveStatusEmpty) {
                searchLiveStatusText.add(String.escapeSingleQuotes(CommonConst.PROPERTY_LIVESTATUS_VACANCY));
            }
            // 退去予定
            if (cd.IsLiveStatusLeaveSchedule) {
                searchLiveStatusText.add(String.escapeSingleQuotes(CommonConst.PROPERTY_LIVESTATUS_SCHEDULEDTOLEAVE));
            }
            whereList.add('LiveStatus__c IN :searchLiveStatusText');
        }

        // 間取り ※いずれかにチェックがあった場合
        if (cd.isOneRoom || cd.is1K || cd.is1DK || cd.is1LDK1SLDK || cd.is2K2DK || cd.is2LDK2SLDK || cd.is3K3DK || cd.is3LDK3SLDK || cd.is4K4DK4LDKFrom) {
            List<String> tmpList = new List<String>();

            // ワンルーム
            if (cd.isOneRoom) {
                tmpList.add('(RoomCount__c = 1 AND RoomLayout__c = \'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_R) + '\')');
            }
            // 1K
            if (cd.is1K) {
                tmpList.add('(RoomCount__c = 1 AND RoomLayout__c IN (\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_K)  + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SK)  + '\'))');
            }
            // 1DK
            if (cd.is1DK) {
                tmpList.add('(RoomCount__c = 1 AND RoomLayout__c IN (\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_DK)  + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_LK)  + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SDK) + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SLK) + '\'))');
            }

            // 1LDK,1SLDK
            if (cd.is1LDK1SLDK) {
                tmpList.add('(RoomCount__c = 1 AND RoomLayout__c IN (\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_LDK)  + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SLDK) + '\'))');
            }
            // 2k,2DK
            if (cd.is2K2DK) {
                tmpList.add('(RoomCount__c = 2 AND RoomLayout__c IN (\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_K)   + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_DK)  + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_LK)  + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SK)  + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SDK) + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SLK) + '\'))');
            }
            // 2LDK,2SLDK
            if (cd.is2LDK2SLDK) {
                tmpList.add('(RoomCount__c = 2 AND RoomLayout__c IN (\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_LDK)  + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SLDK) + '\'))');
            }
            // 3K,3DK
            if (cd.is3K3DK) {
                tmpList.add('(RoomCount__c = 3 AND RoomLayout__c IN (\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_K)   + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_DK)  + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_LK)  + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SK)  + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SDK) + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SLK) + '\'))');
            }
            // 3LDK,3SLDK
            if (cd.is3LDK3SLDK) {
                tmpList.add('(RoomCount__c = 3 AND RoomLayout__c IN (\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_LDK)  + '\''
                                                                 + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SLDK) + '\'))');
            }

            // 4K,4DK,4LDK
            if (cd.is4K4DK4LDKFrom) {
                tmpList.add('(RoomCount__c >= 4 AND RoomLayout__c IN (\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_K)    + '\''
                                                                  + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_DK)   + '\''
                                                                  + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_LK)   + '\''
                                                                  + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_LDK)  + '\''
                                                                  + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SK)   + '\''
                                                                  + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SDK)  + '\''
                                                                  + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SLK)  + '\''
                                                                  + ',\'' + String.escapeSingleQuotes(CommonConst.PROPERTY_ROOMLAYOUT_SLDK) + '\'))');
            }
            whereList.add('(' + String.join(tmpList, ' OR ') + ')');
        }

        // 構造
        if ( (cd.isWooden || cd.isLightweightSteel || cd.isSteel || cd.isRC || cd.isSRC)) {

            // 初期化
            searchStructureText = new List<String>();

            // 木造
            if (cd.isWooden) {
                searchStructureText.add(CommonUtil.convertDisableWildcard(CommonConst.BUILDING_STRUCTURE_WOODEN));
            }
            // 軽量鉄骨
            if (cd.isLightweightSteel) {
                searchStructureText.add(CommonUtil.convertDisableWildcard(CommonConst.BUILDING_STRUCTURE_LIGHTWEIGHTSTEEL));
            }
            // 鉄骨
            if (cd.isSteel) {
                searchStructureText.add(CommonUtil.convertDisableWildcard(CommonConst.BUILDING_STRUCTURE_STEEL));
            }
            // RC
            if (cd.isRC) {
                searchStructureText.add(CommonUtil.convertDisableWildcard(CommonConst.BUILDING_STRUCTURE_RC));
            }
            // SRC
            if (cd.isSRC) {
                searchStructureText.add(CommonUtil.convertDisableWildcard(CommonConst.BUILDING_STRUCTURE_SRC));
            }
            if (searchStructureText.size() > 0 ){
                whereList.add('(Building__r.Structure__c IN :searchStructureText)');
            }
        }

        // 方角 ※いずれかにチェックがあった場合
        if ((cd.isNorth || cd.isNortheast || cd.isEast || cd.isSouthEast || cd.isSouth || cd.isSouthWest || cd.isWest  || cd.isNorthWest)) {

            // 初期化
            searchBalconyDirectionText = new List<String>();

            // 北
            if (cd.isNorth) {
                searchBalconyDirectionText.add(CommonUtil.convertDisableWildcard(CommonConst.PROPERTY_BALCONYDIRECTION_NORTH));
            }
            // 北東
            if (cd.isNortheast) {
                searchBalconyDirectionText.add(CommonUtil.convertDisableWildcard(CommonConst.PROPERTY_BALCONYDIRECTION_NORTHEAST));
            }
            // 東
            if (cd.isEast) {
                searchBalconyDirectionText.add(CommonUtil.convertDisableWildcard(CommonConst.PROPERTY_BALCONYDIRECTION_EAST));
            }
            // 南東
            if (cd.isSouthEast) {
                searchBalconyDirectionText.add(CommonUtil.convertDisableWildcard(CommonConst.PROPERTY_BALCONYDIRECTION_SOUTHEAST));
            }
            // 南
            if (cd.isSouth) {
                searchBalconyDirectionText.add(CommonUtil.convertDisableWildcard(CommonConst.PROPERTY_BALCONYDIRECTION_SOUTH));
            }
            // 南西
            if (cd.isSouthWest) {
                searchBalconyDirectionText.add(CommonUtil.convertDisableWildcard(CommonConst.PROPERTY_BALCONYDIRECTION_SOUTHWEST));
            }
            // 西
            if (cd.isWest) {
                searchBalconyDirectionText.add(CommonUtil.convertDisableWildcard(CommonConst.PROPERTY_BALCONYDIRECTION_WEST));
            }
            // 北西
            if (cd.isNorthWest) {
                searchBalconyDirectionText.add(CommonUtil.convertDisableWildcard(CommonConst.PROPERTY_BALCONYDIRECTION_NORTHWEST));
            }

            // バルコニー方向連絡
            if (searchBalconyDirectionText.size() > 0) {
                whereList.add('BalconyDirection__c IN :searchBalconyDirectionText');
            }
        }        

        // 敷金/保証金なし
        if (cd.isNonDeposit) {
            whereList.add('(SecurityDepositYenSearch__c = 0 AND SecurityDepositMonthSearch__c = 0 AND DepositYenSearch__c = 0 AND DepositMonthSearch__c = 0)');
        }
        // 礼金なし
        if (cd.isNonKeyMoney) {
            whereList.add('(KeyMoneyYenSearch__c = 0 AND KeyMoneyMonthSearch__c = 0)');
        }
        // 定額修繕費なし
        if (cd.isNonCleaningFee) {
            whereList.add('(CleaningFeeYenSearch__c = 0 AND CleaningFeeMonthSearch__c = 0)');
        }
        // 更新料なし
        if (cd.isNonRenewalFee) {
            whereList.add('(RenewalFeeYenSearch__c = 0 AND RenewalFeeMonthSearch__c = 0)');
        }

        // 賃料(下限)
        if (String.isNotBlank(cd.rentFeeFrom)) {
            String rentFeeFrom = String.valueOf(CommonUtil.stringToDecimal(cd.rentFeeFrom));
            if (!cd.isIncludeManagementFee && !cd.isIncludeParkingFee) {
                // 賃料のみ
                whereList.add('RentFeeSearch__c >= ' + rentFeeFrom);
            } else if (cd.isIncludeManagementFee && !cd.isIncludeParkingFee) {
                // 管理費コミのみ
                whereList.add('RentFeeSearchManagement__c >= ' + rentFeeFrom);
            } else if (!cd.isIncludeManagementFee && cd.isIncludeParkingFee) {
                // 駐車場コミのみ
                whereList.add('RentFeeSearchParking__c >= ' + rentFeeFrom);
            } else if (cd.isIncludeManagementFee && cd.isIncludeParkingFee) {
                // 管理費,駐車場コミ
                whereList.add('RentFeeSearchManagementParking__c >= ' + rentFeeFrom);
            }
        }
        // 賃料(上限)
        if (String.isNotBlank(cd.rentFeeTo)) {
            String rentFeeTo   = String.valueOf(CommonUtil.stringToDecimal(cd.rentFeeTo));
            if (!cd.isIncludeManagementFee && !cd.isIncludeParkingFee) {
                // 賃料のみ
                whereList.add('RentFeeSearch__c <= ' + rentFeeTo);
            } else if (cd.isIncludeManagementFee && !cd.isIncludeParkingFee) {
                // 管理費コミのみ
                whereList.add('RentFeeSearchManagement__c <= ' + rentFeeTo);
            } else if (!cd.isIncludeManagementFee && cd.isIncludeParkingFee) {
                // 駐車場コミのみ
                whereList.add('RentFeeSearchParking__c <= ' + rentFeeTo);
            } else if (cd.isIncludeManagementFee && cd.isIncludeParkingFee) {
                // 管理費,駐車場コミ
                whereList.add('RentFeeSearchManagementParking__c <= ' + rentFeeTo);
            }
        }

        // 占有面積（下限）
        if (cd.occupancyAreaLowerLimit != OCCUPANCYAREA_LOWERLIMIT_NULL && !String.isBlank(cd.occupancyAreaLowerLimit)) {
            whereList.add('RoomArea__c >= ' + cd.occupancyAreaLowerLimit);
        }

        // 占有面積（上限）
        if (cd.occupancyAreaUpperLimit != OCCUPANCYAREA_UPPERIMIT_NULL && !String.isBlank(cd.occupancyAreaUpperLimit)) {
            whereList.add('RoomArea__c <= ' + cd.occupancyAreaUpperLimit);
        }

        //築年数
        if (cd.buildingAge != BUILDINGAGE_NULL && !String.isBlank(cd.buildingAge)) {
            whereList.add('Building__r.BuildingAge__c <= ' + cd.buildingAge);
        }

        // 点数
        if ((cd.isScore34Less || cd.isScore34to35 || cd.isScore36More) && !cd.isScoreAll) {
            List<String> tmpList = new List<String>();

            // 34点未満
            if (cd.isScore34Less) {
                tmpList.add('Score__c < 34');
            }
            // 34～35点
            if (cd.isScore34to35) {
                tmpList.add('(Score__c >= 34 AND Score__c <= 35)');
            }
            // 36点以上
            if (cd.isScore36More) {
                tmpList.add('Score__c >= 36');
            }
            whereList.add('(' + String.join(tmpList, ' OR ') + ')');
        }
        // ▲ 住居条件


        // ▼ 設備・条件 詳細
        // --▼ 構造・工法
        //  戸建て ※RC選択時はマンションも対象とする。
        if (cd.isDetachedHouse) {
            whereList.add('Building__r.PropertyType__c = \'' + String.escapeSingleQuotes(CommonConst.BUILDING_PROPERTYTYPE_DETACHEDHOUSE) + '\'');
        }

        // メゾネット
        if (cd.isMaisonette) {
            propCnoudWhereList.add('IsMaisonette__c = True');
        }
        // ロフト
        if (cd.isLoft) {
            propCnoudWhereList.add('IsLoft__c = True');
        }
        // デザイナーズ
        if (cd.isDesigners) {
            propCnoudWhereList.add('IsDesigners__c = True');
        }
        // リノベーション
        if (cd.isRenovation) {
            propCnoudWhereList.add('IsRenovation__c = True');
        }
        // 分譲賃貸
        if (cd.isCondominiumRental) {
            propCnoudWhereList.add('IsCondominiumRental__c = True');
        }
        // オール洋間
        if (cd.isAllWestern) {
            propCnoudWhereList.add('IsAllWesternStyleRoom__c = True');
        }
        // --▲ 構造・工法

        // --▼ フロア・庭バルコニー
        // 1階
        if (cd.isFirstFloor) {
            propCnoudWhereList.add('IsFirstFloor__c = True');
        }
        // 2階以上
        if (cd.isSecondFloorOver) {
            propCnoudWhereList.add('IsSecondFloorOver__c = True');
        }
        // 最上階
        if (cd.isTopFloor) {
            propCnoudWhereList.add('IsTopFloor__c = True');
        }
        // 角部屋
        if (cd.isCornerRoom) {
            propCnoudWhereList.add('IsCornerRoom__c = True');
        }
        // バルコニー
        if (cd.isBalcony) {
            propCnoudWhereList.add('IsBalcony__c = True');
        }
        // ルーフバルコニー
        if (cd.isRoofBalcony) {
            propCnoudWhereList.add('IsRoofBalcony__c = True');
        }
        // 専用庭
        if (cd.isPrivateGarden) {
            propCnoudWhereList.add('IsPrivateGarden__c = True');
        }
        // --▲ フロア・庭バルコニー

        // --▼ 駐車・駐輪 共用部
        // 駐車場空きあり
        if (cd.isParking) {
            propCnoudWhereList.add('IsParking__c = True');
        }
        // 敷地内駐車場
        if (cd.isInSiteParking) {
            propCnoudWhereList.add('IsInSiteParking__c = True');
        }
        // 駐車場2台可
        if (cd.isPluralCarParking) {
            propCnoudWhereList.add('IsPluralCarParking__c = True');
        }
        // ビルトインガレージ
        if (cd.isBuiltInGarage) {
            propCnoudWhereList.add('IsBuiltInGarage__c = True');
        }
        // カーポート
        if (cd.isCarport) {
            propCnoudWhereList.add('IsCarport__c = True');
        }
        // 駐輪場
        if (cd.isBicycleParking) {
            propCnoudWhereList.add('IsBicycleParking__c = True');
        }
        // バイク可
        if (cd.isBikeStorage) {
            propCnoudWhereList.add('(IsBikeStorage__c = True or IsSmallBike__c = true or IsMediumBike__c = true or IsLargeBike__c = true)');
        }
        // 小型バイク
        if (cd.isSmallBike) {
            propCnoudWhereList.add('(IsSmallBike__c = True or IsMediumBike__c = true or IsLargeBike__c = true)');
        }
        // 中型バイク
        if (cd.isMediumBike) {
            propCnoudWhereList.add('(IsMediumBike__c = true or IsLargeBike__c = true)');
        }
        // 大型バイク
        if (cd.isLargeBike) {
            propCnoudWhereList.add('IsLargeBike__c = True');
        }
        // エレベーター
        if (cd.isElevator) {
            propCnoudWhereList.add('IsElevator__c = True');
        }
        // 宅配ボックス
        if (cd.isDeliveryBox) {
            propCnoudWhereList.add('IsDeliveryBox__c = True');
        }
        // --▲ 駐車・駐輪 共用部

        // --▼ キッチン
        // カウンターキッチン
        if (cd.isCounterKitchen) {
            propCnoudWhereList.add('IsCounterKitchen__c = True');
        }
        // システムキッチン
        if (cd.isSystemKitchen) {
            propCnoudWhereList.add('IsSystemKitchen__c = True');
        }
        // ガスコンロ
        if (cd.isGasStove) {
            propCnoudWhereList.add('IsGasStove__c = True');
        }
        // 電気コンロ
        if (cd.isElectricStove) {
            propCnoudWhereList.add('IsElectricStove__c = True');
        }
        // IHコンロ
        if (cd.isInductionHeating) {
            propCnoudWhereList.add('IsIhStove__c = True');
        }
        // コンロ2口
        if (cd.isTwoGasStove) {
            propCnoudWhereList.add('(IsTwoGasStove__c = True OR IsMoreGasStove__c = True)');
        }
        // コンロ3口以上
        if (cd.isMoreGasStove) {
            propCnoudWhereList.add('IsMoreGasStove__c = True');
        }
        // --▲ キッチン

        // --▼ バス・トイレ洗面所
        // バス・トイレ別
        if (cd.isSepalateBathAndRestroom) {
            propCnoudWhereList.add('IsSeparate__c = True');
        }
        // 追焚機能
        if (cd.isAditionalBoiling) {
            propCnoudWhereList.add('IsReheating__c = True');
        }
        // 浴室乾燥機
        if (cd.isDehumidifierForBathroom) {
            propCnoudWhereList.add('IsBathroomDryer__c = True');
        }
        // 温水洗浄便座
        if (cd.isWashlet) {
            propCnoudWhereList.add('IsWashletToiletSeat__c = True');
        }
        // シャワー付き洗面台
        if (cd.isShowerWashBasin) {
            propCnoudWhereList.add('IsShowerWashBasin__c = True');
        }
        // 洗面所独立
        if (cd.isRegalLavatory) {
            propCnoudWhereList.add('IsWashroomDscrete__c = True');
        }
        // 室内洗濯機置場
        if (cd.isInnerLandry) {
            propCnoudWhereList.add('IsIndoorWashingMachineStorage__c = True');
        }
        // --▲ バス・トイレ洗面所

        // --▼ 光熱設備・空調
        // 都市ガス
        if (cd.isTownGas) {
            propCnoudWhereList.add('IsCityGas__c = True');
        }
        // プロパンガス
        if (cd.isPropaneGas) {
            propCnoudWhereList.add('IsPropaneGas__c = True');
        }
        // オール電化
        if (cd.isAllElectric) {
            propCnoudWhereList.add('IsAllElectric__c = True');
        }
        // エアコン
        if (cd.isAirConditioner) {
            propCnoudWhereList.add('IsAirConditioner__c = True');
        }
        // 床暖房
        if (cd.isFloorHeating) {
            propCnoudWhereList.add('IsFloorHeating__c = True');
        }
        // --▲ 光熱設備・空調

        // --▼ 収納
        // シューズボックス
        if (cd.isShoesBox) {
            propCnoudWhereList.add('IsShoesBox__c = True');
        }
        // シューズクローク
        if (cd.isShoeCloak) {
            propCnoudWhereList.add('IsShoeCloak__c = True');
        }
        // ウォークインクローゼット
        if (cd.isWalkInCloset) {
            propCnoudWhereList.add('IsWalkInCloset__c = True');
        }
        // トランクルーム
        if (cd.isTrunkRoom) {
            propCnoudWhereList.add('IsTrunkRoom__c = True');
        }
        // --▲ 収納

        // --▼ 通信設備
        // BSアンテナ
        if (cd.isBSAntenna) {
            propCnoudWhereList.add('IsBSAntenna__c = True');
        }
        // CSアンテナ
        if (cd.isCSAntenna) {
            propCnoudWhereList.add('IsCSAntenna__c = True');
        }
        // CATV
        if (cd.isCATV) {
            propCnoudWhereList.add('IsCATV__c = True');
        }
        // ネット使用料無料
        if (cd.isInternetFree) {
            propCnoudWhereList.add('IsInternetFree__c = True');
        }
        // --▲ 通信設備

        // --▼ セキュリティ
        // モニター付きインターホン
        if (cd.isMonitorIntercom) {
            propCnoudWhereList.add('IsMonitorIntercom__c = True');
        }
        // オートロック
        if (cd.isAutoLock) {
            propCnoudWhereList.add('IsAutoLock__c = True');
        }
        // --▲ セキュリティ

        // --▼ 家具・家電
        // 家具付き
        if (cd.isFurniture) {
            propCnoudWhereList.add('IsFurniture__c = True');
        }
        // 家電付き
        if (cd.isHomeAppliance) {
            propCnoudWhereList.add('IsHomeAppliance__c = True');
        }
        // --▲ 家具・家電
        // --▼ 入居条件 支払方法
        // 保証人不要
        if (cd.isNoGuarantor) {
            propCnoudWhereList.add('IsNoGuarantor__c = True');
        }
        // 保証会社不要　※物件Obj
        if (cd.isNonGuaranteeidCompany) {
            whereList.add('GuaranteeidCompanyType__c = \'' + String.escapeSingleQuotes(CommonConst.PROPERTY_GUARANTEEIDCOMPANYTYPE_POSSIBLE) + '\'');
        }
        // 楽器相談可
        if (cd.isMusicalInstruments) {
            propCnoudWhereList.add('IsMusicalInstruments__c = True');
        }
        // 外国人契約可
        if (cd.isForeigner) {
            propCnoudWhereList.add('IsForeigner__c = True');
        }
        // 生活保護契約可
        if (cd.isWelfareAvailable) {
            propCnoudWhereList.add('IsWelfareAvailable__c = True');
        }
        // 事務所利用可
        if (cd.isOfficeAvailable) {
            propCnoudWhereList.add('IsOfficeAvailable__c = True');
        }
        // ペット可
        if (cd.isPet) {
            propCnoudWhereList.add('(IsPet__c = True OR IsSmallPet__c = True OR IsMiddlePet__c = True OR IsLargePet__c = True OR IsCat__c = True OR IsOtherPet__c = True)');
        }
        // ペット(小型犬) ※中型犬,大型犬も含む
        if (cd.isSmallPet) {
            propCnoudWhereList.add('(IsSmallPet__c = True OR IsMiddlePet__c = True OR IsLargePet__c = True)');
        }
        // ペット(中型犬) ※大型犬も含む
        if (cd.isMiddlePet) {
            propCnoudWhereList.add('(IsMiddlePet__c = True OR IsLargePet__c = True)');
        }
        // ペット(大型犬)
        if (cd.isLargePet) {
            propCnoudWhereList.add('IsLargePet__c = True');
        }
        // ペット(猫)
        if (cd.isCat) {
            propCnoudWhereList.add('IsCat__c = True');
        }
        // ペット(その他)
        if (cd.isOtherPet) {
            propCnoudWhereList.add('IsOtherPet__c = True');
        }
        // 2人入居可
        if (cd.isTwoTenant) {
            propCnoudWhereList.add('IsTwoTenant__c = True');
        }
        // ルームシェア可
        if (cd.isRoomShare) {
            propCnoudWhereList.add('IsRoomShare__c = True');
        }
        // 一般物
        if (cd.isIppambutsu) {
            whereList.add('FormerSupplier__r.IppamGyobutsu__c = \'' + String.escapeSingleQuotes(CommonConst.ACCOUNT_IPPANGYOBUTSU_IPPAN) + '\'');
        }
        // 高齢者歓迎
        if (cd.isElderly) {
            propCnoudWhereList.add('IsElderly__c = True');
        }
        // 女性限定
        if (cd.isWoman) {
            propCnoudWhereList.add('IsWoman__c = True');
        }
        // 学生限定マンション
        if (cd.isStudent) {
            propCnoudWhereList.add('IsStudent__c = True');
        }
        // 家賃カード決済可
        if (cd.isRentCreditPayment) {
            propCnoudWhereList.add('IsRentCreditPayment__c = True');
        }
        // 初期費用カード決済可
        if (cd.isInitialCostCreditPayment) {
            propCnoudWhereList.add('IsInitialCostCreditPayment__c = True');
        }
        // --▲ 入居条件 支払方法
        // ▲ 設備・条件 詳細

        //Where句　結合
        if (whereList.size() > 0) {
            sectionW += ' WHERE ' + String.join(whereList, ' AND ');
        }
        if (propCnoudWhereList.size() > 0) {
            if (String.isBlank(sectionW)) {
                sectionW += ' WHERE ';
            } else {
                sectionW += ' AND ';
            }
            sectionW += 'Id IN (SELECT Property__c FROM PropertyConditions__c WHERE ' + String.join(propCnoudWhereList, ' AND ') + ')';
        }
        Return sectionW;
    }


    /**
     * 登記簿出力　ボタン押下
     *  選択した物件の登記簿を出力(ZIP)
     * @param  なし
     * @return なし
     */
    public void downloadRegistry() {
        try {
            BusinessLogicException ex = new BusinessLogicException();

            // 初期化
            this.hasErrorMessage = false;

            //添付取得
            List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :this.detailCheck[this.detailIndex].propertyId];

            // データがない場合はエラー
            if (attachments.size() == 0) {
                ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_W_SEARCH_NO_DATA));
                throw ex;
            }

            // 添付ファイルID文字列作成（「,」区切り複数）
            String retId = '';
            for(Attachment file : attachments) {
                retId += String.isEmpty(retId) ? '' : ',';
                retId += file.Id;
            }
            this.attachmentIdList = retId;

        } catch(Exception e) {
            hasErrorMessage = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    /**
     * 駅Listから画面表示用の文字列作成
     * 
     * @param  List<Station__c> objList 対象となる駅のLIST
     * @return String           文字列(セミコロン区切り)
     */
    private String convStationListToString(List<Station__c> objList) {
        List<String> tmp = new List<String>();
        for (Station__c obj : objList) {
            tmp.add(obj.name);
        }
        return String.join(tmp, ';');
    }

    // ▼問合せ367で追加
    // 学校Listから画面表示用の文字列作成
    private String convSchoolListToString(List<School__c> objList) {
        List<String> tmp = new List<String>();
        for (School__c obj : objList) {
            tmp.add(obj.name);
        }
        return String.join(tmp, ';');//「;」区切りの文字列にする
    }
    // ▲問合せ367で追加

	/**
     * 指定した取引先のレコードを取得するメソッド
     *
     * @param targetId 取引先ID
     * @return 取引先レコード
     */
    private Account selectAccount(Id targetId) {
        //取引先の条件取得
        List<Account> targetList
            = [ SELECT
					Id
				, SystemModStamp							// SystemModStamp
				, DesiredArea__c                            // 希望地域
				//
				, DesiredTrainRoute1__c                     // 希望路線１
				, DesiredTrainRoute1__r.TrainRoute__c
				, DesiredTrainRoute1__r.TrainRoute__r.Id
				, DesiredTrainRoute1__r.TrainRoute__r.Name

				, DesiredTrainRoute2__c                     // 希望路線２
				, DesiredTrainRoute2__r.TrainRoute__c
				, DesiredTrainRoute2__r.TrainRoute__r.Id
				, DesiredTrainRoute2__r.TrainRoute__r.Name

				, DesiredTrainRoute3__c                     // 希望路線３
				, DesiredTrainRoute3__r.TrainRoute__c
				, DesiredTrainRoute3__r.TrainRoute__r.Id
				, DesiredTrainRoute3__r.TrainRoute__r.Name
				, WalkingTime__c                            // 徒歩
				//
				, IsOneRoom__c                              // ワンルーム
				, Is1K__c                                   // 1K
				, Is1DK__c                                  // 1DK
				, Is1LDK1SLDK__c                            // 1LDK/SLDK
				, Is2K2DK__c                                // 2K/DK
				, Is2LDK2SLDK__c                            //2LDK/SLDK
				, Is3K3DK__c                                // 3K/DK
				, Is3LDK3SLDK__c                            // 3LDK/SLDK
				, Is4K4DK4LDKFrom__c                        // 4K/DK/LDK~
				//
				, IsWooden__c                               // 木造
				, IsLightweightSteel__c                              //軽量鉄骨
				, IsSteel__c                              //鉄骨造
				, IsRC__c                              //RC
				, IsSRC__c                              //SRC
				//
				, IsNorth__c                              //北
				, IsNorthEast__c                              //北東
				, IsEast__c                              //東
				, IsSouthEast__c                              //南東
				, IsSouth__c                              //南
				, IsSouthWest__c                              //南西
				, IsWest__c                              //西
				, IsNorthWest__c                              //北西
				//
				, IsNonDeposit__c                              //敷金/保証金なし
				, IsNonKeyMoney__c                              //礼金なし
				, IsNonCleaningFee__c                              //定額修繕費なし
				, IsNonRenewalFee__c                              //更新料なし
				//
				, RentFeeFrom__c                                     //希望賃料（下限）
				, RentFeeTo__c                                       //希望賃料（上限）
				, IsIncludeManagementFee__c                              //管理費込み
				, IsIncludeParkingFee__c                              //駐車場代込み
				, OccupancyAreaLowerLimit__c                              //占有面積（下限）
				, OccupancyAreaUpperLimit__c                              //占有面積（上限）
				, BuildingAge__c                                 //築年数
				, IsScore34Less__c                              //34点未満
				, IsScore34to35__c                              //34～35点
				, IsScore36More__c                              //36点以上
				, IsScoreAll__c                              //全て
				//
				, IsDetachedHouse__c                              //戸建て
				, IsMaisonette__c                        //メゾネット
				, IsLoft__c                              //ロフト
				, IsDesigners__c                                 //デザイナーズ
				, IsRenovation__c                                //リノベーション
				, IsCondominiumRental__c                              //分譲賃貸
				, IsAllWestern__c                              //オール洋間
				//
				, IsFirstFloor__c                              //1階
				, IsSecondFloorOver__c                         //2階以上
				, IsTopFloor__c                              //最上階
				, IsCornerRoom__c                              //角部屋
				, IsBalcony__c                              //バルコニー
				, IsRoofBalcony__c                              //ルーフバルコニー
				, IsPrivateGarden__c                              //専用庭
				//
				, IsParking__c                              //駐車場空きあり
				, IsInSiteParking__c                              //敷地内駐車場
				, IsPluralCarParking__c                              //駐車場2台可
				, IsBuiltInGarage__c                              //ビルトインガレージ
				, IsCarport__c                              //カーポート
				, IsBicycleParking__c                              //駐輪場
				, IsBikeStorage__c                              //バイク可
				, IsSmallBike__c                              //小型バイク
				, IsMediumBike__c                              //中型バイク
				, IsLargeBike__c                              //大型バイク
				, IsElevator__c                              //エレベーター
				, IsDeliveryBox__c                              //宅配ボックス
				//
				, IsCounterKitchen__c                              //カウンターキッチン
				, IsSystemKitchen__c                              //システムキッチン
				, IsGasStove__c                              //ガスコンロ
				, IsElectricStove__c                              //��気コンロ
				, IsInductionHeating__c                              //IHコンロ
				, IsTwoGasStove__c                              //コンロ2口
				, IsMoreGasStove__c                              //コンロ3口以上
				//
				, IsSepalateBathAndRestroom__c         //バス・トイレ別
				, IsAditionalBoiling__c                              //追焚機能
				, IsDehumidifierForBathroom__c                              //浴室乾燥機
				, IsWashlet__c                              //温水洗浄便座
				, IsShowerWashBasin__c                              //シャワー付き洗面台
				, IsRegalLavatory__c                              //洗面所独立
				, IsInnerLandry__c                              //室内洗濯機置場
				//
				, IsTownGas__c                              //都市ガス
				, IsPropaneGas__c                              //プロパンガス
				, IsAllElectric__c                              //オール電化
				, IsAirConditioner__c                              //エアコン
				, IsFloorHeating__c                              //床暖房
				//
				, IsShoesBox__c                              //シューズボックス
				, IsShoeCloak__c                              //シューズクローク
				, IsWalkInCloset__c                              //ウォークインクローゼット
				, IsTrunkRoom__c                              //トランクルーム
				//
				, IsBSAntenna__c                              //BSアンテナ
				, IsCSAntenna__c                              //CSアンテナ
				, IsCATV__c                              //CATV
				, IsInternetFree__c                              //ネット使用料無料
				//
				, IsMonitorIntercom__c                              //モニタ付インターホン
				, IsAutoLock__c                              //オートロック
				//
				, IsFurniture__c                              //家具付き
				, IsHomeAppliance__c                              //家電付き
				//
				, IsNoGuarantor__c                              //保証人不要
				, IsNonGuaranteeidCompany__c                              //保証会社不要
				, IsMusicalInstruments__c                              //楽器相談可
				, IsForeigner__c                              //外国人契約可
				, IsWelfareAvailable__c                              //生活保護契約可
				, IsOfficeAvailable__c                              //事務所利用可
				, IsPet__c                              //ペット可
				, IsSmallPet__c                              //ペット(小型犬)
				, IsMiddlePet__c                              //ペット(中型犬)
				, IsLargePet__c                              //ペット(大型犬)
				, IsCat__c                              //ペット(猫)
				, IsOtherPet__c                              //ペット(その他)
				, IsTwoTenant__c                              //2人入居可
				, IsRoomShare__c                              //ルームシェア可
				, IsIppambutsu__c                              //一般物
				, IsElderly__c                              //高齢者歓迎
				, IsWoman__c                              //女性限定
				, IsStudent__c                              //学生限定マンション
				, IsRentCreditPayment__c                              //家賃カード決済可
				, IsInitialCostCreditPayment__c         //初期費用カード決済可
				// ▼問合せ367で追加
				, DesiredJuniorHighSchoolArea__c                 //中学校希望学区（エリア）
				, DesiredJuniorHighSchoolArea__r.SchoolArea__c   //中学校希望学区（エリア）.希望学区（エリア）
				, DesiredElementarySchoolArea__c                 //小学校希望学区（エリア）
				, DesiredElementarySchoolArea__r.SchoolArea__c   //小学校希望学区（エリア）.希望学区（エリア）
				// ▲問合せ367で追加
				FROM Account
				WHERE
					Id =: targetId
			];
		//レコードが取得できない場合はビジネスロジックExceptionを発行する
		if(targetList.isEmpty()){
			BusinessLogicException ex = new BusinessLogicException();
			ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
			throw ex;
		}
		return targetList[0];
	}

	// ▼2021.10.08 No.307 対応でお客様物件条件追加
	/**
	 * 指定したお客様物件条件のレコードを取得するメソッド
	 *
	 * @param targetId お客様物件条件ID
	 * @return お客様物件条件レコード
	 */
	private AccountPropertyConditions__c selectSpc(Id targetId) {
		//お客様物件条件の条件取得
		List<AccountPropertyConditions__c> targetList
			= [ SELECT
					Id
				, SystemModStamp							//お客様物件条件.SystemModStamp
				, Account__c								//お客様物件条件.取引先
				, DesiredArea__c							//お客様物件条件.希望地域
				//
				, DesiredTrainRoute1__c						//お客様物件条件.希望路線１
				, DesiredTrainRoute1__r.TrainRoute__c
				, DesiredTrainRoute1__r.TrainRoute__r.Id
				, DesiredTrainRoute1__r.TrainRoute__r.Name

				, DesiredTrainRoute2__c						//お客様物件条件.希望路線２
				, DesiredTrainRoute2__r.TrainRoute__c
				, DesiredTrainRoute2__r.TrainRoute__r.Id
				, DesiredTrainRoute2__r.TrainRoute__r.Name

				, DesiredTrainRoute3__c						//お客様物件条件.希望路線３
				, DesiredTrainRoute3__r.TrainRoute__c
				, DesiredTrainRoute3__r.TrainRoute__r.Id
				, DesiredTrainRoute3__r.TrainRoute__r.Name
				, WalkingTime__c							//お客様物件条件.徒歩
				//
				, IsOneRoom__c								//お客様物件条件.ワンルーム
				, Is1K__c									//お客様物件条件.1K
				, Is1DK__c									//お客様物件条件.1DK
				, Is1LDK1SLDK__c							//お客様物件条件.1LDK/SLDK
				, Is2K2DK__c								//お客様物件条件.2K/DK
				, Is2LDK2SLDK__c							//お客様物件条件.2LDK/SLDK
				, Is3K3DK__c								//お客様物件条件.3K/DK
				, Is3LDK3SLDK__c							//お客様物件条件.3LDK/SLDK
				, Is4K4DK4LDKFrom__c						//お客様物件条件.4K/DK/LDK~
				//
				, IsWooden__c								//お客様物件条件.木造
				, IsLightweightSteel__c						//お客様物件条件.軽量鉄骨
				, IsSteel__c								//お客様物件条件.鉄骨造
				, IsRC__c									//お客様物件条件.RC
				, IsSRC__c									//お客様物件条件.SRC
				//
				, IsNorth__c								//お客様物件条件.北
				, IsNorthEast__c							//お客様物件条件.北東
				, IsEast__c									//お客様物件条件.東
				, IsSouthEast__c							//お客様物件条件.南東
				, IsSouth__c								//お客様物件条件.南
				, IsSouthWest__c							//お客様物件条件.南西
				, IsWest__c									//お客様物件条件.西
				, IsNorthWest__c							//お客様物件条件.北西
				//
				, IsNonDeposit__c							//お客様物件条件.敷金/保証金なし
				, IsNonKeyMoney__c							//お客様物件条件.礼金なし
				, IsNonCleaningFee__c						//お客様物件条件.定額修繕費なし
				, IsNonRenewalFee__c						//お客様物件条件.更新料なし
				//
				, RentFeeFrom__c							//お客様物件条件.希望賃料（下限）
				, RentFeeTo__c								//お客様物件条件.希望賃料（上限）
				, IsIncludeManagementFee__c					//お客様物件条件.管理費込み
				, IsIncludeParkingFee__c					//お客様物件条件.駐車場代込み
				, OccupancyAreaLowerLimit__c				//お客様物件条件.占有面積（下限）
				, OccupancyAreaUpperLimit__c				//お客様物件条件.占有面積（上限）
				, BuildingAge__c							//お客様物件条件.築年数
				, IsScore34Less__c							//お客様物件条件.34点未満
				, IsScore34to35__c							//お客様物件条件.34～35点
				, IsScore36More__c							//お客様物件条件.36点以上
				, IsScoreAll__c								//お客様物件条件.全て
				//
				, IsDetachedHouse__c						//お客様物件条件.戸建て
				, IsMaisonette__c							//お客様物件条件.メゾネット
				, IsLoft__c									//お客様物件条件.ロフト
				, IsDesigners__c							//お客様物件条件.デザイナーズ
				, IsRenovation__c							//お客様物件条件.リノベーション
				, IsCondominiumRental__c					//お客様物件条件.分譲賃貸
				, IsAllWestern__c							//お客様物件条件.オール洋間
				//
				, IsFirstFloor__c							//お客様物件条件.1階
				, IsSecondFloorOver__c						//お客様物件条件.2階以上
				, IsTopFloor__c								//お客様物件条件.最上階
				, IsCornerRoom__c							//お客様物件条件.角部屋
				, IsBalcony__c								//お客様物件条件.バルコニー
				, IsRoofBalcony__c							//お客様物件条件.ルーフバルコニー
				, IsPrivateGarden__c						//お客様物件条件.専用庭
				//
				, IsParking__c								//お客様物件条件.駐車場空きあり
				, IsInSiteParking__c						//お客様物件条件.敷地内駐車場
				, IsPluralCarParking__c						//お客様物件条件.駐車場2台可
				, IsBuiltInGarage__c						//お客様物件条件.ビルトインガレージ
				, IsCarport__c								//お客様物件条件.カーポート
				, IsBicycleParking__c						//お客様物件条件.駐輪場
				, IsBikeStorage__c							//お客様物件条件.バイク可
				, IsSmallBike__c							//お客様物件条件.小型バイク
				, IsMediumBike__c							//お客様物件条件.中型バイク
				, IsLargeBike__c							//お客様物件条件.大型バイク
				, IsElevator__c								//お客様物件条件.エレベーター
				, IsDeliveryBox__c							//お客様物件条件.宅配ボックス
				//
				, IsCounterKitchen__c						//お客様物件条件.カウンターキッチン
				, IsSystemKitchen__c						//お客様物件条件.システムキッチン
				, IsGasStove__c								//お客様物件条件.ガスコンロ
				, IsElectricStove__c						//お客様物件条件.電気コンロ
				, IsInductionHeating__c						//お客様物件条件.IHコンロ
				, IsTwoGasStove__c							//お客様物件条件.コンロ2口
				, IsMoreGasStove__c							//お客様物件条件.コンロ3口以上
				//
				, IsSepalateBathAndRestroom__c				//お客様物件条件.バス・トイレ別
				, IsAditionalBoiling__c						//お客様物件条件.追焚機能
				, IsDehumidifierForBathroom__c				//お客様物件条件.浴室乾燥機
				, IsWashlet__c								//お客様物件条件.温水洗浄便座
				, IsShowerWashBasin__c						//お客様物件条件.シャワー付き洗面台
				, IsRegalLavatory__c						//お客様物件条件.洗面所独立
				, IsInnerLandry__c							//お客様物件条件.室内洗濯機置場
				//
				, IsTownGas__c								//お客様物件条件.都市ガス
				, IsPropaneGas__c							//お客様物件条件.プロパンガス
				, IsAllElectric__c							//お客様物件条件.オール電化
				, IsAirConditioner__c						//お客様物件条件.エアコン
				, IsFloorHeating__c							//お客様物件条件.床暖房
				//
				, IsShoesBox__c								//お客様物件条件.シューズボックス
				, IsShoeCloak__c							//お客様物件条件.シューズクローク
				, IsWalkInCloset__c							//お客様物件条件.ウォークインクローゼット
				, IsTrunkRoom__c							//お客様物件条件.トランクルーム
				//
				, IsBSAntenna__c							//お客様物件条件.BSアンテナ
				, IsCSAntenna__c							//お客様物件条件.CSアンテナ
				, IsCATV__c									//お客様物件条件.CATV
				, IsInternetFree__c							//お客様物件条件.ネット使用料無料
				//
				, IsMonitorIntercom__c						//お客様物件条件.モニタ付インターホン
				, IsAutoLock__c								//お客様物件条件.オートロック
				//
				, IsFurniture__c							//お客様物件条件.家具付き
				, IsHomeAppliance__c						//お客様物件条件.家電付き
				//
				, IsNoGuarantor__c							//お客様物件条件.保証人不要
				, IsNonGuaranteeidCompany__c				//お客様物件条件.保証会社不要
				, IsMusicalInstruments__c					//お客様物件条件.楽器相談可
				, IsForeigner__c							//お客様物件条件.外国人契約可
				, IsWelfareAvailable__c						//お客様物件条件.生活保護契約可
				, IsOfficeAvailable__c						//お客様物件条件.事務所利用可
				, IsPet__c									//お客様物件条件.ペット可
				, IsSmallPet__c								//お客様物件条件.ペット(小型犬)
				, IsMiddlePet__c							//お客様物件条件.ペット(中型犬)
				, IsLargePet__c								//お客様物件条件.ペット(大型犬)
				, IsCat__c									//お客様物件条件.ペット(猫)
				, IsOtherPet__c								//お客様物件条件.ペット(その他)
				, IsTwoTenant__c							//お客様物件条件.2人入居可
				, IsRoomShare__c							//お客様物件条件.ルームシェア可
				, IsIppambutsu__c							//お客様物件条件.一般物
				, IsElderly__c								//お客様物件条件.高齢者歓迎
				, IsWoman__c								//お客様物件条件.女性限定
				, IsStudent__c								//お客様物件条件.学生限定マンション
				, IsRentCreditPayment__c					//お客様物件条件.家賃カード決済可
				, IsInitialCostCreditPayment__c				//お客様物件条件.初期費用カード決済可
				// ▼問合せ367で追加
				, DesiredJuniorHighSchoolArea__c				//お客様物件条件.中学校希望学区（エリア）
				, DesiredJuniorHighSchoolArea__r.SchoolArea__c	//お客様物件条件.中学校希望学区（エリア）.希望学区（エリア）
				, DesiredElementarySchoolArea__c				//お客様物件条件.小学校希望学区（エリア）
				, DesiredElementarySchoolArea__r.SchoolArea__c	//お客様物件条件.小学校希望学区（エリア）.希望学区（エリア）
				// ▲問合せ367で追加
				FROM AccountPropertyConditions__c
				WHERE
					Id =: targetId
			];
		//レコードが取得できない場合はビジネスロジックExceptionを発行する
		if(targetList.isEmpty()){
			BusinessLogicException ex = new BusinessLogicException();
			ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_PARAMETER));
			throw ex;
		}
		return targetList[0];
	}
	// ▲2021.10.08 No.307 対応でお客様物件条件追加

	/**
	 * IdのsObjectTypがAccountか判定する
	 *
	 * @param   Id checkId  検査対象ID
	 * @return  Boolean		true:IdのsObjectTypがAccount、false:IdのsObjectTypがAccount以外またはnull
	 */
	private Boolean isIdTypeAccount(Id checkId){
		if(checkId == null)return false;
		return this.spcId.getSObjectType().getDescribe().getName().equals('Account');
	}

	/**
	 * 指定した取引先の希望路線の情報を取得
	 *
	 * @param   Account ac  取引先情報
	 * @return  Map<Id, List<Station__c>>   取引先の希望条件に関連する駅
	 */
	private Map<Id, List<Station__c>> selectTrain(Account ac) {

		Set<Id> ids = new Set<Id>();
		ids.add(ac.DesiredTrainRoute1__c);
		ids.add(ac.DesiredTrainRoute2__c);
		ids.add(ac.DesiredTrainRoute3__c);

		Map<Id, List<Station__c>> result = new Map<Id, List<Station__c>>();
		for (DesiredTrainRoute__c obj : [SELECT Id
											, (SELECT Station__r.Id
													, Station__r.Name
												FROM  DesiredStationDesiredTrainRoute__r
												WHERE  Station__c != null
											)
										FROM DesiredTrainRoute__c
										WHERE Id = :ids
									]) {
			List<Station__c> stations = new List<Station__c>();
			for (DesiredStation__c child : obj.DesiredStationDesiredTrainRoute__r) {
				stations.add(child.Station__r);
			}
			result.put(obj.Id, stations);
		}
		return result;
	}

	// ▼2021.10.08 No.307 対応でお客様物件条件追加
	/**
	 * 指定したお客様物件条件の希望路線の情報を取得
	 *
	 * @param   AccountPropertyConditions__c spc  お客様物件条件
	 * @return  Map<Id, List<Station__c>>         お客様物件条件の希望条件に関連する駅
	 */
	private Map<Id, List<Station__c>> selectTrain(AccountPropertyConditions__c spc) {

		Set<Id> ids = new Set<Id>();
		ids.add(spc.DesiredTrainRoute1__c);
		ids.add(spc.DesiredTrainRoute2__c);
		ids.add(spc.DesiredTrainRoute3__c);

		Map<Id, List<Station__c>> result = new Map<Id, List<Station__c>>();
		for (DesiredTrainRoute__c obj : [SELECT Id
											, (SELECT Station__r.Id
													, Station__r.Name
												FROM  DesiredStationDesiredTrainRoute__r
												WHERE  Station__c != null
											)
										FROM DesiredTrainRoute__c
										WHERE Id = :ids
									]) {
			List<Station__c> stations = new List<Station__c>();
			for (DesiredStation__c child : obj.DesiredStationDesiredTrainRoute__r) {
				stations.add(child.Station__r);
			}
			result.put(obj.Id, stations);
		}
		return result;
	} 
	// ▲2021.10.08 No.307 対応でお客様物件条件追加

	/**
	 * 指定した取引先の希望学校の情報を取得
	 *
	 * @param   Account ac  取引先情報
	 * @return  Map<Id, List<School__c>>   取引先の希望条件に関連する学校
	 */
	private Map<Id, List<School__c>> selectSchool(Account ac) {

		Set<Id> ids = new Set<Id>();
		// 値を返すマップ
		Map<id, List<school__c>> result = new Map<id, List<school__c>>();
		ids.add(ac.DesiredJuniorHighSchoolArea__c);
		ids.add(ac.DesiredElementarySchoolArea__c);

		if(ac.DesiredJuniorHighSchoolArea__c == null && ac.DesiredElementarySchoolArea__c == null) {
			return result;
		} else {
			// 希望学区をもとに希望学校を取得
			List<DesiredSchool__c> desiredScList = new List<DesiredSchool__c>(
				[SELECT id, School__r.id, School__r.NAME, DesiredSchoolArea__c FROM DesiredSchool__c WHERE DesiredSchoolArea__c in :ids]
			);
			List<school__c> resultSchool;
			for (DesiredSchool__c ds: desiredScList) {
				if(!result.containskey(ds.DesiredSchoolArea__c)) {
					resultSchool = new List<school__c>();
				} else {
					resultSchool = result.get(ds.DesiredSchoolArea__c);
				}
				school__c addsc = new school__c(id = ds.School__r.id, NAME = ds.School__r.NAME);
				resultSchool.add(addsc);
				result.put(ds.DesiredSchoolArea__c, resultSchool);
			}
		}
		
		return result;
	} 

	// ▼2021.10.08 No.307 対応でお客様物件条件追加
	/**
	 * 指定したお客様物件条件の希望学校の情報を取得
	 *
	 * @param   AccountPropertyConditions__c spc  お客様物件条件
	 * @return  Map<Id, List<School__c>>         お客様物件条件の希望条件に関連する学校
	 */
	private Map<Id, List<School__c>> selectSchool(AccountPropertyConditions__c spc) {

		Set<Id> ids = new Set<Id>();
		// 値を返すマップ
		Map<id, List<school__c>> result = new Map<id, List<school__c>>();
		ids.add(spc.DesiredJuniorHighSchoolArea__c);
		ids.add(spc.DesiredElementarySchoolArea__c);

		if(spc.DesiredJuniorHighSchoolArea__c == null && spc.DesiredElementarySchoolArea__c == null) {
			return result;
		} else {
			// 希望学区をもとに希望学校を取得
			List<DesiredSchool__c> desiredScList = new List<DesiredSchool__c>(
				[SELECT id, School__r.id, School__r.NAME, DesiredSchoolArea__c FROM DesiredSchool__c WHERE DesiredSchoolArea__c in :ids]
			);
			List<school__c> resultSchool;
			for (DesiredSchool__c ds: desiredScList) {
				if(!result.containskey(ds.DesiredSchoolArea__c)) {
					resultSchool = new List<school__c>();
				} else {
					resultSchool = result.get(ds.DesiredSchoolArea__c);
				}
				school__c addsc = new school__c(id = ds.School__r.id, NAME = ds.School__r.NAME);
				resultSchool.add(addsc);
				result.put(ds.DesiredSchoolArea__c, resultSchool);
			}
		}
		
		return result;
	} 
	// ▲2021.10.08 No.307 対応でお客様物件条件追加

    /**
     * 該当件数取得処理
     * 
     * @param   DisplaySearchCondition cd   取得条件
     * @return  DispaySearchCount           件数情報
     */
    private DispaySearchCount selectCount(DisplaySearchCondition cd, Integer hitCount) {
        // 件数カウント
        DispaySearchCount result = new DispaySearchCount();
        result.hitCount = hitCount;

        // 追焚
        if (cd.isAditionalBoiling) {
            cd.isAditionalBoiling = false;
            result.nonReheatingCount = selectProperty(cd).size();
            cd.isAditionalBoiling = true;
        } else {
            result.nonReheatingCount = hitCount;
        }

        // エアコン
        if (cd.isAirConditioner) {
            cd.isAirConditioner = false;
            result.nonAirConditionerCount = selectProperty(cd).size();
            cd.isAirConditioner = true;
        } else {
            result.nonAirConditionerCount = hitCount;
        }

        // 浴室乾燥機
        if (cd.isDehumidifierForBathroom) {
            cd.isDehumidifierForBathroom = false;
            result.nonBathroomDryerCount = selectProperty(cd).size();
            cd.isDehumidifierForBathroom = true;
        } else {
            result.nonBathroomDryerCount = hitCount;
        }

        // オートロック
        if (cd.isAutoLock) {
            cd.isAutoLock = false;
            result.nonAutoLockCount = selectProperty(cd).size();
            cd.isAutoLock = true;
        } else {
            result.nonAutoLockCount = hitCount;
        }

        // カウンターキッチン
        if (cd.isCounterKitchen) {
            cd.isCounterKitchen = false;
            result.counterKitchenCount = selectProperty(cd).size();
            cd.isCounterKitchen = true;
        } else {
            result.counterKitchenCount = hitCount;
        }

        return result;
    }

    /**
     * 物件検索 Select句作成処理
     *
     * @param なし
     * @return String Select句文字列
     */
    private String createSelectSection() {
        String sql = commonConst.STRING_EMPTY;
        sql += ' SELECT Id';                                    // 物件ID
        sql += '      , Building__c';                           // 建物
        sql += '      , Building__r.Name';                      // 建物名
        sql += '      , Building__r.Structure__c';              // 建物構造
        sql += '      , Building__r.Address__c';                // 住所
        sql += '      , Building__r.TrainRoute1__c';            // 沿線１
        sql += '      , Building__r.Station1__c';               // 駅１
        sql += '      , Building__r.Station1__r.Name';          // 駅１
        sql += '      , Building__r.StationWalkTimeFormat1__c'; // 駅までの時間(分)
        sql += '      , Building__r.BuildingYMFormat__c';       // 築年月
        sql += '      , KeyMoneyYen__c';                        // 礼金(円)
        sql += '      , KeyMoneyMonth__c';                      // 礼金(ヵ月)
        sql += '      , KeyMoneyUnit__c';                       // 礼金単位
        sql += '      , CleaningFeeYen__c';                     // 定額修繕費(円)
        sql += '      , CleaningFeeMonth__c';                   // 定額修繕費(ヵ月)
        sql += '      , CleaningFeeUnit__c';                    // 定額修繕費単位
        sql += '      , Name';                                  // 物件名
        sql += '      , LastModifiedDate';                      // 更新日
        sql += '      , LiveStatus__c';                         // 現況
        sql += '      , DeliveryDateView__c';                   // 引渡日(表示用）
        sql += '      , DeliveryType__c';                       // 引渡種別
        sql += '      , DeliveryYear__c';                       // 引渡年
        sql += '      , DeliveryMonth__c';                      // 引渡月
        sql += '      , DeliveryTiming__c';                     // 引渡旬
        sql += '      , PhotoCount__c';                         // 写真枚数
        sql += '      , RentFee__c';                            // 賃料
        sql += '      , ManagementFee__c';                      // 管理費
        sql += '      , SecurityDepositYen__c';                 // 敷金(円)
        sql += '      , SecurityDepositMonth__c';               // 敷金(ヵ月)
        sql += '      , SecurityDepositUnit__c';                // 敷金単位
        sql += '      , DepositYen__c';	                        // 保証料金(円)
        sql += '      , DepositMonth__c';                       // 保証料金(ヵ月)
        sql += '      , DepositUnit__c';                        // 保証金単位
        sql += '      , ParkingType__c';                        // 駐車場種別
        sql += '      , ParkingFee__c';                         // 駐車場料金
        sql += '      , RoomCount__c';                          // 部屋数
        sql += '      , RoomLayout__c';                         // 間取り
        sql += '      , RoomArea__c';                           // 専有面積（㎡）
        sql += '      , BalconyDirection__c';                   // バルコニー方向
        sql += '      , FormerSupplier__r.Name';                // 元付業者名
        sql += '      , FormerSupplier__r.Phone';               // 元付業者TEL
        sql += '      , ADFeeTax__c';                           // 広告料(税込)
        sql += '      , ADFeeMonth__c';                         // 広告料(ヵ月)
        sql += '      , ADFeeRate__c';                          // 広告料(%)
        sql += '      , ADFeeUnit__c';                          // 広告料単位
        sql += '      , (SELECT Id';
        sql += '              , IsSuumo__c';
        sql += '              , IsHomes__c';
        sql += '              , IsAtHome__c';
        sql += '           FROM PortalSitePostingPropertyProperty__r';
        sql += '          WHERE IsAtHome__c = True';
        sql += '             OR IsHomes__c  = True';
        sql += '             OR IsSuumo__c  = True';
        sql += '        )                         ';
        sql += '   FROM Property__c';
        return sql;
    }

	/**
	 * 検索条件保存
	 * 
	 * @param DisplaySearchCondition cd  検索条件
	 * @return なし
	 */
	private void upsertAccount(DisplaySearchCondition cd) {

		// ▼ 希望路線の作成　※既存の希望路線については、取引先登録後に削除を実施
		// 削除用に事前にデータを退避
		Account ac = selectAccount(accountId);

		// ▼2021.10.08 No.307 対応で追加
		// 楽観ロックチェックExceptionを発行
		if (ac.SystemModstamp != cd.systemmodstamp){
			OptimisticLockException ex = new OptimisticLockException();
			throw ex;
		}
		// ▲2021.10.08 No.307 対応で追加

		// 希望路線作成
		List<DesiredTrainRoute__c> desiredTrainRouteList = new List<DesiredTrainRoute__c>();
		if (cd.trainRoute1 != null) {
			desiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = cd.trainRoute1));
		}
		if (cd.trainRoute2 != null) {
			desiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = cd.trainRoute2));
		}
		if (cd.trainRoute3 != null) {
			desiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = cd.trainRoute3));
		}
		if (desiredTrainRouteList.size() > 0) {
			SecureDML.secureUpsert(desiredTrainRouteList);//希望路線を作成
		}

		// 希望駅作成
		List<DesiredStation__c> desiredStationList = new List<DesiredStation__c>();//保存用 希望駅
		Integer idx = 0;
		if (cd.trainRoute1 != null && desiredTrainRouteList.size() > 0) {
			for(Station__c desiredStation : cd.stations1){//選択された駅1から希望駅を設定
				desiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = desiredTrainRouteList[idx].Id, Station__c = desiredStation.Id));
			}
			idx++;
		}
		if (cd.trainRoute2 != null && desiredTrainRouteList.size() > 0) {
			for(Station__c desiredStation : cd.stations2){//選択された駅2から希望駅を設定
				desiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = desiredTrainRouteList[idx].Id, Station__c = desiredStation.Id));
			}
			idx++;
		}
		if (cd.trainRoute3 != null && desiredTrainRouteList.size() > 0) {
			for(Station__c desiredStation : cd.stations3){//選択された駅3から希望駅を設定
				desiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = desiredTrainRouteList[idx].Id, Station__c = desiredStation.Id));
			}
		}
		if (desiredStationList.size() > 0) {
			SecureDML.secureUpsert(desiredStationList);
		}
		// ▲ 希望駅の更新

		// ▼問合せ367で追加 希望学区の作成　※既存の希望学区については、取引先登録後に削除を実施

		// 希望学区作成
		List<DesiredSchoolArea__c> desiredSchoolAreaList = new List<DesiredSchoolArea__c>();
		if (cd.juniorHighSchoolArea != null) {
			desiredSchoolAreaList.add(new DesiredSchoolArea__c(SchoolArea__c = cd.juniorHighSchoolArea));
		}
		if (cd.elementarySchoolarea != null) {
			desiredSchoolAreaList.add(new DesiredSchoolArea__c(SchoolArea__c = cd.elementarySchoolArea));
		}
		if (desiredSchoolAreaList.size() > 0) {
			SecureDML.secureUpsert(desiredSchoolAreaList);//希望学区を作成
		}

		// 希望学校作成
		List<DesiredSchool__c> desiredSchoolList = new List<DesiredSchool__c>();//保存用 希望学校
		Integer index = 0;
		if (cd.juniorHighSchoolArea != null && desiredSchoolAreaList.size() > 0) {
			for(School__c desiredSchool : cd.juniorHighSchoolList){//選択された中学校区から希望学校を設定
				desiredSchoolList.add(new DesiredSchool__c(DesiredSchoolArea__c = desiredSchoolAreaList[index].Id, School__c = desiredSchool.Id));
			}
			index++;
		}
		if (cd.elementarySchoolarea != null && desiredSchoolAreaList.size() > 0) {
			for(School__c desiredSchool : cd.elementarySchoolList){//選択された小学校区から希望学校を設定
				desiredSchoolList.add(new DesiredSchool__c(DesiredSchoolArea__c = desiredSchoolAreaList[index].Id, School__c = desiredSchool.Id));
			}
			index++;
		}
		if (desiredSchoolList.size() > 0) {
			SecureDML.secureUpsert(desiredSchoolList);
		}
		// ▲ 希望学校の更新

		// ▼ 取引先の更新
		Account upsertAccount = new Account(
				Id							= cd.accountId									// 取引先.ID
			, DesiredArea__c				= cd.address									// 取引先.住所
			, WalkingTime__c				= cd.walkingTime								// 取引先.徒歩
			, IsOneRoom__c					= cd.isOneRoom									// 取引先.ワンルーム
			, Is1K__c						= cd.is1K										// 取引先.1K
			, Is1DK__c						= cd.is1DK										// 取引先.1DK
			, Is1LDK1SLDK__c				= cd.is1LDK1SLDK								// 取引先.1LDK/SLDK
			, Is2K2DK__c					= cd.is2K2DK									// 取引先.2K/DK
			, Is2LDK2SLDK__c				= cd.is2LDK2SLDK								// 取引先.2LDK/SLDK
			, Is3K3DK__c					= cd.is3K3DK									// 取引先.3K/DK
			, Is3LDK3SLDK__c				= cd.is3LDK3SLDK								// 取引先.3LDK/SLDK
			, Is4K4DK4LDKFrom__c			= cd.is4K4DK4LDKFrom							// 取引先.4K/DK/LDK~
			, IsWooden__c					= cd.isWooden									// 取引先.木造
			, IsLightweightSteel__c			= cd.isLightweightSteel							// 取引先.軽量鉄骨
			, IsSteel__c					= cd.isSteel									// 取引先.鉄骨造
			, IsRC__c						= cd.isRC										// 取引先.RC
			, IsSRC__c						= cd.isSRC										// 取引先.SRC
			, IsNorth__c					= cd.isNorth									// 取引先.北
			, IsNorthEast__c				= cd.isNortheast								// 取引先.北東
			, IsEast__c						= cd.isEast										// 取引先.東
			, IsSouthEast__c				= cd.isSouthEast								// 取引先.南東
			, IsSouth__c					= cd.isSouth									// 取引先.南
			, IsSouthWest__c				= cd.isSouthWest								// 取引先.南西
			, IsWest__c						= cd.isWest										// 取引先.西
			, IsNorthWest__c				= cd.isNorthWest								// 取引先.北西
			, IsNonDeposit__c				= cd.isNonDeposit								// 取引先.敷金/保証金なし
			, IsNonKeyMoney__c				= cd.isNonKeyMoney								// 取引先.礼金なし
			, IsNonCleaningFee__c			= cd.isNonCleaningFee							// 取引先.定額修繕費なし
			, IsNonRenewalFee__c			= cd.isNonRenewalFee							// 取引先.更新料なし
			, RentFeeFrom__c				= CommonUtil.stringToDecimal(cd.rentFeeFrom)	// 取引先.賃料From
			, RentFeeTo__c					= CommonUtil.stringToDecimal(cd.rentFeeTo)		// 取引先.賃料To
			, IsIncludeManagementFee__c		= cd.isIncludeManagementFee						// 取引先.管理費込み
			, IsIncludeParkingFee__c		= cd.isIncludeParkingFee						// 取引先.駐車場代込み
			, OccupancyAreaLowerLimit__c	= cd.occupancyAreaLowerLimit					// 取引先.占有面積From※選択リスト
			, OccupancyAreaUpperLimit__c	= cd.occupancyAreaUpperLimit					// 取引先.占有面積To※選択リスト
			, BuildingAge__c				= cd.buildingAge								// 取引先.築年数
			, IsScore34Less__c				= cd.isScore34Less								// 取引先.34点未満
			, IsScore34to35__c				= cd.isScore34to35								// 取引先.34～35点
			, IsScore36More__c				= cd.isScore36More								// 取引先.36点以上
			, IsScoreAll__c					= cd.isScoreAll									// 取引先.全て
			, IsDetachedHouse__c			= cd.isDetachedHouse							// 取引先.戸建て
			, IsMaisonette__c				= cd.isMaisonette								// 取引先.メゾネット
			, IsLoft__c						= cd.isLoft										// 取引先.ロフト
			, IsDesigners__c				= cd.isDesigners								// 取引先.デザイナーズ
			, IsRenovation__c				= cd.isRenovation								// 取引先.リノベーション
			, IsCondominiumRental__c		= cd.isCondominiumRental						// 取引先.分譲賃貸
			, IsAllWestern__c				= cd.isAllWestern								// 取引先.オール洋間
			, IsFirstFloor__c				= cd.isFirstFloor								// 取引先.1階
			, IsSecondFloorOver__c			= cd.isSecondFloorOver							// 取引先.2階以上
			, IsTopFloor__c					= cd.isTopFloor									// 取引先.最上階
			, IsCornerRoom__c				= cd.isCornerRoom								// 取引先.角部屋
			, IsBalcony__c					= cd.isBalcony									// 取引先.バルコニー
			, IsRoofBalcony__c				= cd.isRoofBalcony								// 取引先.ルーフバルコニー
			, IsPrivateGarden__c			= cd.isPrivateGarden							// 取引先.専用庭
			, IsParking__c					= cd.isParking									// 取引先.駐車場空きあり
			, IsInSiteParking__c			= cd.isInSiteParking							// 取引先.敷地内駐車場
			, IsPluralCarParking__c			= cd.isPluralCarParking							// 取引先.駐車場2台可
			, IsBuiltInGarage__c			= cd.isBuiltInGarage							// 取引先.ビルトインガレージ
			, IsCarport__c					= cd.isCarport									// 取引先.カーポート
			, IsBicycleParking__c			= cd.isBicycleParking							// 取引先.駐輪場
			, IsBikeStorage__c				= cd.isBikeStorage								// 取引先.バイク可
			, IsSmallBike__c				= cd.isSmallBike								// 取引先.小型バイク
			, IsMediumBike__c				= cd.isMediumBike								// 取引先.中型バイク
			, IsLargeBike__c				= cd.isLargeBike								// 取引先.大型バイク
			, IsElevator__c					= cd.isElevator									// 取引先.エレベーター
			, IsDeliveryBox__c				= cd.isDeliveryBox								// 取引先.宅配ボックス
			, IsCounterKitchen__c			= cd.isCounterKitchen							// 取引先.カウンターキッチン
			, IsSystemKitchen__c			= cd.isSystemKitchen							// 取引先.システムキッチン
			, IsGasStove__c					= cd.isGasStove									// 取引先.ガスコンロ
			, IsElectricStove__c			= cd.isElectricStove							// 取引先.電気コンロ
			, IsInductionHeating__c			= cd.isInductionHeating							// 取引先.IHコンロ
			, IsTwoGasStove__c				= cd.isTwoGasStove								// 取引先.コンロ2口
			, IsMoreGasStove__c				= cd.isMoreGasStove								// 取引先.コンロ3口以上
			, IsSepalateBathAndRestroom__c	= cd.isSepalateBathAndRestroom					// 取引先.バス・トイレ別
			, IsAditionalBoiling__c			= cd.isAditionalBoiling							// 取引先.追焚機能
			, IsDehumidifierForBathroom__c	= cd.isDehumidifierForBathroom					// 取引先.浴室乾燥機
			, IsWashlet__c					= cd.isWashlet									// 取引先.温水洗浄便座
			, IsShowerWashBasin__c			= cd.isShowerWashBasin							// 取引先.シャワー付き洗面台
			, IsRegalLavatory__c			= cd.isRegalLavatory							// 取引先.洗面所独立
			, IsInnerLandry__c				= cd.isInnerLandry								// 取引先.室内洗濯機置場
			, IsTownGas__c					= cd.isTownGas									// 取引先.都市ガス
			, IsPropaneGas__c				= cd.isPropaneGas								// 取引先.プロパンガス
			, IsAllElectric__c				= cd.isAllElectric								// 取引先.オール電化
			, IsAirConditioner__c			= cd.isAirConditioner							// 取引先.エアコン
			, IsFloorHeating__c				= cd.isFloorHeating								// 取引先.床暖房
			, IsShoesBox__c					= cd.isShoesBox									// 取引先.シューズボックス
			, IsShoeCloak__c				= cd.isShoeCloak								// 取引先.シューズクローク
			, IsWalkInCloset__c				= cd.isWalkInCloset								// 取引先.ウォークインクローゼット
			, IsTrunkRoom__c				= cd.isTrunkRoom								// 取引先.トランクルーム
			, IsBSAntenna__c				= cd.isBSAntenna								// 取引先.BSアンテナ
			, IsCSAntenna__c				= cd.isCSAntenna								// 取引先.CSアンテナ
			, IsCATV__c						= cd.isCATV										// 取引先.CATV
			, IsInternetFree__c				= cd.isInternetFree								// 取引先.ネット使用料無料
			, IsMonitorIntercom__c			= cd.isMonitorIntercom							// 取引先.モニタ付インターホン
			, IsAutoLock__c					= cd.isAutoLock									// 取引先.オートロック
			, IsFurniture__c				= cd.isFurniture								// 取引先.家具付き
			, IsHomeAppliance__c			= cd.isHomeAppliance							// 取引先.家電付き
			, IsNoGuarantor__c				= cd.isNoGuarantor								// 取引先.保証人不要
			, IsNonGuaranteeidCompany__c	= cd.isNonGuaranteeidCompany					// 取引先.保証会社不要
			, IsMusicalInstruments__c		= cd.isMusicalInstruments						// 取引先.楽器相談可
			, IsForeigner__c				= cd.isForeigner								// 取引先.外国人契約可
			, IsWelfareAvailable__c			= cd.isWelfareAvailable							// 取引先.生活保護契約可
			, IsOfficeAvailable__c			= cd.isOfficeAvailable							// 取引先.事務所利用可
			, IsPet__c						= cd.isPet										// 取引先.ペット可
			, IsSmallPet__c					= cd.isSmallPet									// 取引先.ペット(小型犬)
			, IsMiddlePet__c				= cd.isMiddlePet								// 取引先.ペット(中型犬)
			, IsLargePet__c					= cd.isLargePet									// 取引先.ペット(大型犬)
			, IsCat__c						= cd.isCat										// 取引先.ペット(猫)
			, IsOtherPet__c					= cd.isOtherPet									// 取引先.ペット(その他)
			, IsTwoTenant__c				= cd.isTwoTenant								// 取引先.2人入居可
			, IsRoomShare__c				= cd.isRoomShare								// 取引先.ルームシェア可
			, IsIppambutsu__c				= cd.isIppambutsu								// 取引先.一般物
			, IsElderly__c					= cd.isElderly									// 取引先.高齢者歓迎
			, IsWoman__c					= cd.isWoman									// 取引先.女性限定
			, IsStudent__c					= cd.isStudent									// 取引先.学生限定マンション
			, IsRentCreditPayment__c		= cd.isRentCreditPayment						// 取引先.家賃カード決済可
			, IsInitialCostCreditPayment__c	= cd.isInitialCostCreditPayment					// 取引先.初期費用カード決済可
		);
		// 希望路線設定
		idx = 0;
		if (cd.trainRoute1 != null && desiredTrainRouteList.size() > 0) {
			upsertAccount.DesiredTrainRoute1__c = desiredTrainRouteList[idx].id;
			idx++;
		} else {
			upsertAccount.DesiredTrainRoute1__c = null;
		}
		if (cd.trainRoute2 != null && desiredTrainRouteList.size() > 0) {
			upsertAccount.DesiredTrainRoute2__c = desiredTrainRouteList[idx].id;
			idx++;
		} else {
			upsertAccount.DesiredTrainRoute2__c = null;
		}
		if (cd.trainRoute3 != null && desiredTrainRouteList.size() > 0) {
			upsertAccount.DesiredTrainRoute3__c = desiredTrainRouteList[idx].id;
		} else {
			upsertAccount.DesiredTrainRoute3__c = null;
		}
		// ▼問合せ367で追加　希望学区設定
		index = 0;
		if (cd.juniorHighSchoolArea != null && desiredSchoolAreaList.size() > 0) {
			upsertAccount.DesiredJuniorHighSchoolArea__c = desiredSchoolAreaList[index].id;
			index++;
		} else {
			upsertAccount.DesiredJuniorHighSchoolArea__c = null;
		}
		if (cd.elementarySchoolArea != null && desiredSchoolAreaList.size() > 0) {
			upsertAccount.DesiredElementarySchoolArea__c = desiredSchoolAreaList[index].id;
			index++;
		} else {
			upsertAccount.DesiredElementarySchoolArea__c = null;
		}
		// ▲問合せ367で追加

		// 取引先登録 ※旧希望路線の削除の為、更新前データを保存
		SecureDML.secureUpsert(upsertAccount);
		//楽観ロック用の更新日時を最新化 2022.01.11 No.307 対応で追加
		if(upsertAccount.Id != null){
			cd.SystemModstamp = [SELECT Id, SystemModstamp FROM Account WHERE Id =: upsertAccount.Id].SystemModstamp;
		}
		// ▲ 取引先の更新

		// ▼ 希望路線を削除 ※旧希望路線のデータ
		// 削除対象データのID設定
		Set<Id> trainDelSetId = new Set<Id>();
		if (ac.DesiredTrainRoute1__c != null) {
			trainDelSetId.add(ac.DesiredTrainRoute1__c);
		}
		if (ac.DesiredTrainRoute2__c != null) {
			trainDelSetId.add(ac.DesiredTrainRoute2__c);
		}
		if (ac.DesiredTrainRoute3__c != null) {
			trainDelSetId.add(ac.DesiredTrainRoute3__c);
		}
		// 対象データ削除
		List<DesiredTrainRoute__c> trainDelList = new List<DesiredTrainRoute__c>();
		if (trainDelSetId.size() > 0) {
			trainDelList = [SELECT ID FROM DesiredTrainRoute__c WHERE ID IN :trainDelSetId];
			SecureDML.secureDelete(trainDelList);
		}
		// ▲ 希望路線を削除

		// ▼ 問合せ367で追加　希望学区を削除 ※旧希望学区のデータ
		// 削除対象データのID設定
		List<DesiredSchoolArea__c> delList = new List<DesiredSchoolArea__c>();
		if (ac.DesiredJuniorHighSchoolArea__c != null) {
			DesiredSchoolArea__c delJuniorHighSchool = new DesiredSchoolArea__c();
			delJuniorHighSchool.id = ac.DesiredJuniorHighSchoolArea__c;
			delList.add(delJuniorHighSchool);
		}
		if (ac.DesiredElementarySchoolArea__c != null) {
			DesiredSchoolArea__c delElementarySchool = new DesiredSchoolArea__c();
			delElementarySchool.id = ac.DesiredElementarySchoolArea__c;
			delList.add(delElementarySchool);
		}
		// 対象データ削除
		SecureDML.secureDelete(delList);
		// ▲ 希望学区を削除
	}

	// ▼2021.10.08 No.307 対応でお客様物件条件追加
	/**
	 * 検索条件保存
	 * 
	 * @param DisplaySearchCondition cd  検索条件
	 * @return なし
	 */
	private void upsertSpc(DisplaySearchCondition cd) {

		// ▼ 希望路線の作成　※既存の希望路線については、お客様物件条件登録後に削除を実施
		// 削除用に事前にデータを退避
		AccountPropertyConditions__c spc = selectSpc(spcId);

		// ▼2021.10.08 No.307 対応で追加
		// 楽観ロックチェックExceptionを発行
		if (spc.SystemModstamp != cd.systemmodstamp){
			OptimisticLockException ex = new OptimisticLockException();
			throw ex;
		}
		// ▲2021.10.08 No.307 対応で追加

		// 希望路線作成
		List<DesiredTrainRoute__c> desiredTrainRouteList = new List<DesiredTrainRoute__c>();
		if (cd.trainRoute1 != null) {
			desiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = cd.trainRoute1));
		}
		if (cd.trainRoute2 != null) {
			desiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = cd.trainRoute2));
		}
		if (cd.trainRoute3 != null) {
			desiredTrainRouteList.add(new DesiredTrainRoute__c(TrainRoute__c = cd.trainRoute3));
		}
		if (desiredTrainRouteList.size() > 0) {
			SecureDML.secureUpsert(desiredTrainRouteList);//希望路線を作成
		}

		// 希望駅作成
		List<DesiredStation__c> desiredStationList = new List<DesiredStation__c>();//保存用 希望駅
		Integer idx = 0;
		if (cd.trainRoute1 != null && desiredTrainRouteList.size() > 0) {
			for(Station__c desiredStation : cd.stations1){//選択された駅1から希望駅を設定
				desiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = desiredTrainRouteList[idx].Id, Station__c = desiredStation.Id));
			}
			idx++;
		}
		if (cd.trainRoute2 != null && desiredTrainRouteList.size() > 0) {
			for(Station__c desiredStation : cd.stations2){//選択された駅2から希望駅を設定
				desiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = desiredTrainRouteList[idx].Id, Station__c = desiredStation.Id));
			}
			idx++;
		}
		if (cd.trainRoute3 != null && desiredTrainRouteList.size() > 0) {
			for(Station__c desiredStation : cd.stations3){//選択された駅3から希望駅を設定
				desiredStationList.add(new DesiredStation__c(DesiredTrainRoute__c = desiredTrainRouteList[idx].Id, Station__c = desiredStation.Id));
			}
		}
		if (desiredStationList.size() > 0) {
			SecureDML.secureUpsert(desiredStationList);
		}
		// ▲ 希望駅の更新

		// ▼問合せ367で追加 希望学区の作成　※既存の希望学区については、お客様物件条件登録後に削除を実施

		// 希望学区作成
		List<DesiredSchoolArea__c> desiredSchoolAreaList = new List<DesiredSchoolArea__c>();
		if (cd.juniorHighSchoolArea != null) {
			desiredSchoolAreaList.add(new DesiredSchoolArea__c(SchoolArea__c = cd.juniorHighSchoolArea));
		}
		if (cd.elementarySchoolarea != null) {
			desiredSchoolAreaList.add(new DesiredSchoolArea__c(SchoolArea__c = cd.elementarySchoolArea));
		}
		if (desiredSchoolAreaList.size() > 0) {
			SecureDML.secureUpsert(desiredSchoolAreaList);//希望学区を作成
		}

		// 希望学校作成
		List<DesiredSchool__c> desiredSchoolList = new List<DesiredSchool__c>();//保存用 希望学校
		Integer index = 0;
		if (cd.juniorHighSchoolArea != null && desiredSchoolAreaList.size() > 0) {
			for(School__c desiredSchool : cd.juniorHighSchoolList){//選択された中学校区から希望学校を設定
				desiredSchoolList.add(new DesiredSchool__c(DesiredSchoolArea__c = desiredSchoolAreaList[index].Id, School__c = desiredSchool.Id));
			}
			index++;
		}
		if (cd.elementarySchoolarea != null && desiredSchoolAreaList.size() > 0) {
			for(School__c desiredSchool : cd.elementarySchoolList){//選択された小学校区から希望学校を設定
				desiredSchoolList.add(new DesiredSchool__c(DesiredSchoolArea__c = desiredSchoolAreaList[index].Id, School__c = desiredSchool.Id));
			}
			index++;
		}
		if (desiredSchoolList.size() > 0) {
			SecureDML.secureUpsert(desiredSchoolList);
		}
		// ▲ 希望学校の更新

		// ▼ お客様物件条件の更新
		AccountPropertyConditions__c upsertSpc = new AccountPropertyConditions__c(
				Id							= cd.spcId									// お客様物件条件.ID
			, Account__c					= cd.accountId								// お客様物件条件.取引先
			, DesiredArea__c				= cd.address								// お客様物件条件.住所
			, WalkingTime__c				= cd.walkingTime							// お客様物件条件.徒歩
			, IsOneRoom__c					= cd.isOneRoom								// お客様物件条件.ワンルーム
			, Is1K__c						= cd.is1K									// お客様物件条件.1K
			, Is1DK__c						= cd.is1DK									// お客様物件条件.1DK
			, Is1LDK1SLDK__c				= cd.is1LDK1SLDK							// お客様物件条件.1LDK/SLDK
			, Is2K2DK__c					= cd.is2K2DK								// お客様物件条件.2K/DK
			, Is2LDK2SLDK__c				= cd.is2LDK2SLDK							// お客様物件条件.2LDK/SLDK
			, Is3K3DK__c					= cd.is3K3DK								// お客様物件条件.3K/DK
			, Is3LDK3SLDK__c				= cd.is3LDK3SLDK							// お客様物件条件.3LDK/SLDK
			, Is4K4DK4LDKFrom__c			= cd.is4K4DK4LDKFrom						// お客様物件条件.4K/DK/LDK~
			, IsWooden__c					= cd.isWooden								// お客様物件条件.木造
			, IsLightweightSteel__c			= cd.isLightweightSteel						// お客様物件条件.軽量鉄骨
			, IsSteel__c					= cd.isSteel								// お客様物件条件.鉄骨造
			, IsRC__c						= cd.isRC									// お客様物件条件.RC
			, IsSRC__c						= cd.isSRC									// お客様物件条件.SRC
			, IsNorth__c					= cd.isNorth								// お客様物件条件.北
			, IsNorthEast__c				= cd.isNortheast							// お客様物件条件.北東
			, IsEast__c						= cd.isEast									// お客様物件条件.東
			, IsSouthEast__c				= cd.isSouthEast							// お客様物件条件.南東
			, IsSouth__c					= cd.isSouth								// お客様物件条件.南
			, IsSouthWest__c				= cd.isSouthWest							// お客様物件条件.南西
			, IsWest__c						= cd.isWest									// お客様物件条件.西
			, IsNorthWest__c				= cd.isNorthWest							// お客様物件条件.北西
			, IsNonDeposit__c				= cd.isNonDeposit							// お客様物件条件.敷金/保証金なし
			, IsNonKeyMoney__c				= cd.isNonKeyMoney							// お客様物件条件.礼金なし
			, IsNonCleaningFee__c			= cd.isNonCleaningFee						// お客様物件条件.定額修繕費なし
			, IsNonRenewalFee__c			= cd.isNonRenewalFee						// お客様物件条件.更新料なし
			, RentFeeFrom__c				= CommonUtil.stringToDecimal(cd.rentFeeFrom)// お客様物件条件.賃料From
			, RentFeeTo__c					= CommonUtil.stringToDecimal(cd.rentFeeTo)	// お客様物件条件.賃料To
			, IsIncludeManagementFee__c		= cd.isIncludeManagementFee					// お客様物件条件.管理費込み
			, IsIncludeParkingFee__c		= cd.isIncludeParkingFee					// お客様物件条件.駐車場代込み
			, OccupancyAreaLowerLimit__c	= cd.occupancyAreaLowerLimit				// お客様物件条件.占有面積From※選択リスト
			, OccupancyAreaUpperLimit__c	= cd.occupancyAreaUpperLimit				// お客様物件条件.占有面積To※選択リスト
			, BuildingAge__c				= cd.buildingAge							// お客様物件条件.築年数
			, IsScore34Less__c				= cd.isScore34Less							// お客様物件条件.34点未満
			, IsScore34to35__c				= cd.isScore34to35							// お客様物件条件.34～35点
			, IsScore36More__c				= cd.isScore36More							// お客様物件条件.36点以上
			, IsScoreAll__c					= cd.isScoreAll								// お客様物件条件.全て
			, IsDetachedHouse__c			= cd.isDetachedHouse						// お客様物件条件.戸建て
			, IsMaisonette__c				= cd.isMaisonette							// お客様物件条件.メゾネット
			, IsLoft__c						= cd.isLoft									// お客様物件条件.ロフト
			, IsDesigners__c				= cd.isDesigners							// お客様物件条件.デザイナーズ
			, IsRenovation__c				= cd.isRenovation							// お客様物件条件.リノベーション
			, IsCondominiumRental__c		= cd.isCondominiumRental					// お客様物件条件.分譲賃貸
			, IsAllWestern__c				= cd.isAllWestern							// お客様物件条件.オール洋間
			, IsFirstFloor__c				= cd.isFirstFloor							// お客様物件条件.1階
			, IsSecondFloorOver__c			= cd.isSecondFloorOver						// お客様物件条件.2階以上
			, IsTopFloor__c					= cd.isTopFloor								// お客様物件条件.最上階
			, IsCornerRoom__c				= cd.isCornerRoom							// お客様物件条件.角部屋
			, IsBalcony__c					= cd.isBalcony								// お客様物件条件.バルコニー
			, IsRoofBalcony__c				= cd.isRoofBalcony							// お客様物件条件.ルーフバルコニー
			, IsPrivateGarden__c			= cd.isPrivateGarden						// お客様物件条件.専用庭
			, IsParking__c					= cd.isParking								// お客様物件条件.駐車場空きあり
			, IsInSiteParking__c			= cd.isInSiteParking						// お客様物件条件.敷地内駐車場
			, IsPluralCarParking__c			= cd.isPluralCarParking						// お客様物件条件.駐車場2台可
			, IsBuiltInGarage__c			= cd.isBuiltInGarage						// お客様物件条件.ビルトインガレージ
			, IsCarport__c					= cd.isCarport								// お客様物件条件.カーポート
			, IsBicycleParking__c			= cd.isBicycleParking						// お客様物件条件.駐輪場
			, IsBikeStorage__c				= cd.isBikeStorage							// お客様物件条件.バイク可
			, IsSmallBike__c				= cd.isSmallBike							// お客様物件条件.小型バイク
			, IsMediumBike__c				= cd.isMediumBike							// お客様物件条件.中型バイク
			, IsLargeBike__c				= cd.isLargeBike							// お客様物件条件.大型バイク
			, IsElevator__c					= cd.isElevator								// お客様物件条件.エレベーター
			, IsDeliveryBox__c				= cd.isDeliveryBox							// お客様物件条件.宅配ボックス
			, IsCounterKitchen__c			= cd.isCounterKitchen						// お客様物件条件.カウンターキッチン
			, IsSystemKitchen__c			= cd.isSystemKitchen						// お客様物件条件.システムキッチン
			, IsGasStove__c					= cd.isGasStove								// お客様物件条件.ガスコンロ
			, IsElectricStove__c			= cd.isElectricStove						// お客様物件条件.電気コンロ
			, IsInductionHeating__c			= cd.isInductionHeating						// お客様物件条件.IHコンロ
			, IsTwoGasStove__c				= cd.isTwoGasStove							// お客様物件条件.コンロ2口
			, IsMoreGasStove__c				= cd.isMoreGasStove							// お客様物件条件.コンロ3口以上
			, IsSepalateBathAndRestroom__c	= cd.isSepalateBathAndRestroom				// お客様物件条件.バス・トイレ別
			, IsAditionalBoiling__c			= cd.isAditionalBoiling						// お客様物件条件.追焚機能
			, IsDehumidifierForBathroom__c	= cd.isDehumidifierForBathroom				// お客様物件条件.浴室乾燥機
			, IsWashlet__c					= cd.isWashlet								// お客様物件条件.温水洗浄便座
			, IsShowerWashBasin__c			= cd.isShowerWashBasin						// お客様物件条件.シャワー付き洗面台
			, IsRegalLavatory__c			= cd.isRegalLavatory						// お客様物件条件.洗面所独立
			, IsInnerLandry__c				= cd.isInnerLandry							// お客様物件条件.室内洗濯機置場
			, IsTownGas__c					= cd.isTownGas								// お客様物件条件.都市ガス
			, IsPropaneGas__c				= cd.isPropaneGas							// お客様物件条件.プロパンガス
			, IsAllElectric__c				= cd.isAllElectric							// お客様物件条件.オール電化
			, IsAirConditioner__c			= cd.isAirConditioner						// お客様物件条件.エアコン
			, IsFloorHeating__c				= cd.isFloorHeating							// お客様物件条件.床暖房
			, IsShoesBox__c					= cd.isShoesBox								// お客様物件条件.シューズボックス
			, IsShoeCloak__c				= cd.isShoeCloak							// お客様物件条件.シューズクローク
			, IsWalkInCloset__c				= cd.isWalkInCloset							// お客様物件条件.ウォークインクローゼット
			, IsTrunkRoom__c				= cd.isTrunkRoom							// お客様物件条件.トランクルーム
			, IsBSAntenna__c				= cd.isBSAntenna							// お客様物件条件.BSアンテナ
			, IsCSAntenna__c				= cd.isCSAntenna							// お客様物件条件.CSアンテナ
			, IsCATV__c						= cd.isCATV									// お客様物件条件.CATV
			, IsInternetFree__c				= cd.isInternetFree							// お客様物件条件.ネット使用料無料
			, IsMonitorIntercom__c			= cd.isMonitorIntercom						// お客様物件条件.モニタ付インターホン
			, IsAutoLock__c					= cd.isAutoLock								// お客様物件条件.オートロック
			, IsFurniture__c				= cd.isFurniture							// お客様物件条件.家具付き
			, IsHomeAppliance__c			= cd.isHomeAppliance						// お客様物件条件.家電付き
			, IsNoGuarantor__c				= cd.isNoGuarantor							// お客様物件条件.保証人不要
			, IsNonGuaranteeidCompany__c	= cd.isNonGuaranteeidCompany				// お客様物件条件.保証会社不要
			, IsMusicalInstruments__c		= cd.isMusicalInstruments					// お客様物件条件.楽器相談可
			, IsForeigner__c				= cd.isForeigner							// お客様物件条件.外国人契約可
			, IsWelfareAvailable__c			= cd.isWelfareAvailable						// お客様物件条件.生活保護契約可
			, IsOfficeAvailable__c			= cd.isOfficeAvailable						// お客様物件条件.事務所利用可
			, IsPet__c						= cd.isPet									// お客様物件条件.ペット可
			, IsSmallPet__c					= cd.isSmallPet								// お客様物件条件.ペット(小型犬)
			, IsMiddlePet__c				= cd.isMiddlePet							// お客様物件条件.ペット(中型犬)
			, IsLargePet__c					= cd.isLargePet								// お客様物件条件.ペット(大型犬)
			, IsCat__c						= cd.isCat									// お客様物件条件.ペット(猫)
			, IsOtherPet__c					= cd.isOtherPet								// お客様物件条件.ペット(その他)
			, IsTwoTenant__c				= cd.isTwoTenant							// お客様物件条件.2人入居可
			, IsRoomShare__c				= cd.isRoomShare							// お客様物件条件.ルームシェア可
			, IsIppambutsu__c				= cd.isIppambutsu							// お客様物件条件.一般物
			, IsElderly__c					= cd.isElderly								// お客様物件条件.高齢者歓迎
			, IsWoman__c					= cd.isWoman								// お客様物件条件.女性限定
			, IsStudent__c					= cd.isStudent								// お客様物件条件.学生限定マンション
			, IsRentCreditPayment__c		= cd.isRentCreditPayment					// お客様物件条件.家賃カード決済可
			, IsInitialCostCreditPayment__c	= cd.isInitialCostCreditPayment				// お客様物件条件.初期費用カード決済可
		);
		// 希望路線設定
		idx = 0;
		if (cd.trainRoute1 != null && desiredTrainRouteList.size() > 0) {
			upsertSpc.DesiredTrainRoute1__c = desiredTrainRouteList[idx].id;
			idx++;
		} else {
			upsertSpc.DesiredTrainRoute1__c = null;
		}
		if (cd.trainRoute2 != null && desiredTrainRouteList.size() > 0) {
			upsertSpc.DesiredTrainRoute2__c = desiredTrainRouteList[idx].id;
			idx++;
		} else {
			upsertSpc.DesiredTrainRoute2__c = null;
		}
		if (cd.trainRoute3 != null && desiredTrainRouteList.size() > 0) {
			upsertSpc.DesiredTrainRoute3__c = desiredTrainRouteList[idx].id;
		} else {
			upsertSpc.DesiredTrainRoute3__c = null;
		}
		// ▼問合せ367で追加　希望学区設定
		index = 0;
		if (cd.juniorHighSchoolArea != null && desiredSchoolAreaList.size() > 0) {
			upsertSpc.DesiredJuniorHighSchoolArea__c = desiredSchoolAreaList[index].id;
			index++;
		} else {
			upsertSpc.DesiredJuniorHighSchoolArea__c = null;
		}
		if (cd.elementarySchoolArea != null && desiredSchoolAreaList.size() > 0) {
			upsertSpc.DesiredElementarySchoolArea__c = desiredSchoolAreaList[index].id;
			index++;
		} else {
			upsertSpc.DesiredElementarySchoolArea__c = null;
		}
		// ▲問合せ367で追加

		// お客様物件条件登録 ※旧希望路線の削除の為、更新前データを保存
		SecureDML.secureUpsert(upsertSpc);
		//楽観ロック用の更新日時を最新化 2022.01.11 No.307 対応で追加
		if(upsertSpc.Id != null){
			cd.SystemModstamp = [SELECT Id, SystemModstamp FROM AccountPropertyConditions__c WHERE Id =: upsertSpc.Id].SystemModstamp;
		}
		// ▲ お客様物件条件の更新

		// ▼ 希望路線を削除 ※旧希望路線のデータ
		// 削除対象データのID設定
		Set<Id> trainDelSetId = new Set<Id>();
		if (spc.DesiredTrainRoute1__c != null) {
			trainDelSetId.add(spc.DesiredTrainRoute1__c);
		}
		if (spc.DesiredTrainRoute2__c != null) {
			trainDelSetId.add(spc.DesiredTrainRoute2__c);
		}
		if (spc.DesiredTrainRoute3__c != null) {
			trainDelSetId.add(spc.DesiredTrainRoute3__c);
		}
		// 対象データ削除
		List<DesiredTrainRoute__c> trainDelList = new List<DesiredTrainRoute__c>();
		if (trainDelSetId.size() > 0) {
			trainDelList = [SELECT ID FROM DesiredTrainRoute__c WHERE ID IN :trainDelSetId];
			SecureDML.secureDelete(trainDelList);
		}
		// ▲ 希望路線を削除

		// ▼ 問合せ367で追加　希望学区を削除 ※旧希望学区のデータ
		// 削除対象データのID設定
		List<DesiredSchoolArea__c> delList = new List<DesiredSchoolArea__c>();
		if (spc.DesiredJuniorHighSchoolArea__c != null) {
			DesiredSchoolArea__c delJuniorHighSchool = new DesiredSchoolArea__c();
			delJuniorHighSchool.id = spc.DesiredJuniorHighSchoolArea__c;
			delList.add(delJuniorHighSchool);
		}
		if (spc.DesiredElementarySchoolArea__c != null) {
			DesiredSchoolArea__c delElementarySchool = new DesiredSchoolArea__c();
			delElementarySchool.id = spc.DesiredElementarySchoolArea__c;
			delList.add(delElementarySchool);
		}
		// 対象データ削除
		SecureDML.secureDelete(delList);
		// ▲ 希望学区を削除
	}
	// ▲2021.10.08 No.307 対応でお客様物件条件追加

    /**
     * 画面表示用内部クラス（検索件数）
     */
    public class DispaySearchCount {
        public Integer hitCount {get; set;}
        public Integer nonReheatingCount {get; set;}
        public Integer nonAirConditionerCount {get; set;}
        public Integer nonBathroomDryerCount {get; set;}
        public Integer nonAutoLockCount {get; set;}
        public Integer counterKitchenCount {get; set;}

        /**
         * コンストラクタ
         */
        public DispaySearchCount() {
            this.hitCount               = 0;
            this.nonReheatingCount      = 0;
            this.nonAirConditionerCount = 0;
            this.nonBathroomDryerCount  = 0;
            this.nonAutoLockCount       = 0;
            this.counterKitchenCount    = 0;
        }
    }


    /* *
     * 画面表示用内部クラス（検索条件）
     */
    public class DisplaySearchCondition {
		public Id spcId {get; set;}						//ID 2021.10.08 No.307 対応で追加
		public Id accountId {get; set;}					//取引先
		public Datetime systemModStamp { get; set; }	//SystemModStamp
        public String propertyName {get; set;}          //物件名
        public String address {get; set;}               //住所（丁目まで）
        public String formerSupplierName {get; set;}    //元付業者
        public String propertyCode {get; set;}          //物件コード
        public String freeWord {get; set;}              //フリーワード
        // 路線
        public Id trainRoute1 {get; set;}               // 路線1
        public Id trainRoute2 {get; set;}               // 路線2
        public Id trainRoute3 {get; set;}               // 路線3
        public List<Station__c> stations1 {get; set;}   // 駅１
        public List<Station__c> stations2 {get; set;}   // 駅２
        public List<Station__c> stations3 {get; set;}   // 駅３
        public String stationsChar1 {get; set;}          //駅１文字列
        public String stationsChar2 {get; set;}          //駅２文字列
        public String stationsChar3 {get; set;}          //駅１文字列
        public String walkingTime {get; set;}            //徒歩
        // 現況
        public Boolean isLiveStatusLive {get; set;}             // 居住中
        public Boolean isLiveStatusEmpty {get; set;}            // 空室
        public Boolean IsLiveStatusLeaveSchedule {get; set;}    // 退去予定
        // 間取り
        public Boolean isOneRoom {get; set;}            // ワンルーム
        public Boolean is1K {get; set;}                 // 1K
        public Boolean is1DK {get; set;}                // 1DK
        public Boolean is1LDK1SLDK {get; set;}          // 1LDK/SLDK
        public Boolean is2K2DK {get; set;}              // 2K/DK
        public Boolean is2LDK2SLDK {get; set;}          // 2LDK/SLDK
        public Boolean is3K3DK {get; set;}              // 3K/DK 
        public Boolean is3LDK3SLDK {get; set;}          // 3LDK/SLDK 
        public Boolean is4K4DK4LDKFrom {get; set;}      // 4K/DK/LDK~
        // 構造
        public Boolean isWooden {get; set;}             // 木造
        public Boolean isLightweightSteel {get; set;}   // 軽量鉄骨
        public Boolean isSteel {get; set;}              // 鉄骨造
        public Boolean isRC {get; set;}                 // RC
        public Boolean isSRC {get; set;}                // SRC
        // 方角
        public Boolean isNorth {get; set;}              //北
        public Boolean isNortheast {get; set;}          //北東
        public Boolean isEast {get; set;}               //東
        public Boolean isSouthEast {get; set;}          //南東
        public Boolean isSouth {get; set;}              //南
        public Boolean isSouthWest {get; set;}          //南西
        public Boolean isWest {get; set;}               //西
        public Boolean isNorthWest {get; set;}          //北西
        // 敷礼・更新料
        public Boolean isNonDeposit {get; set;}         //敷金/保証金なし
        public Boolean isNonKeyMoney {get; set;}        //礼金なし
        public Boolean isNonCleaningFee {get; set;}     //定額修繕費なし
        public Boolean isNonRenewalFee {get; set;}      //更新料なし
        //住居条件
        public String rentFeeFrom {get; set;}               //賃料 From     
        public String rentFeeTo {get; set;}                 //賃料 To       
        public Boolean isIncludeManagementFee {get; set;}   // 管理費込み
        public Boolean isIncludeParkingFee {get; set;}      //駐車場代込み
        public String occupancyAreaLowerLimit { get; set; } //占有面積（下限）
        public String occupancyAreaUpperLimit { get; set; }     //占有面積（上限）
        public String buildingAge {get; set;}               //築年数
        // public String carCount { get; set; }                //台数
        // public String parkingFeeLimit {get; set;}           // 1台当たりの料金上限
        public Boolean isScore34Less {get; set;}           //34点未満
        public Boolean isScore34to35 {get; set;}            //34～35点
        public Boolean isScore36More {get; set;}            //36点以上
        public Boolean isScoreAll {get; set;}               //全て
        // 構造・工法
        public Boolean isDetachedHouse {get; set;}      //戸建て
        public Boolean isMaisonette {get; set;}        //メゾネット
        public Boolean isLoft {get; set;}               //ロフト
        public Boolean isDesigners {get; set;}          //デザイナーズ
        public Boolean isRenovation {get; set;}         //リノベーション
        public Boolean isCondominiumRental {get; set;}  //分譲賃貸
        public Boolean isAllWestern {get; set;}         //オール洋間
        // フロア・庭バルコニー
        public Boolean isFirstFloor {get; set;}         //1階
        public Boolean isSecondFloorOver {get; set;}  //2階以上
        public Boolean isTopFloor {get; set;}           //最上階
        public Boolean isCornerRoom {get; set;}         //角部屋
        public Boolean isBalcony {get; set;}            //バルコニー
        public Boolean isRoofBalcony {get; set;}        //ルーフバルコニー
        public Boolean isPrivateGarden {get; set;}      //専用庭
        // 駐車・駐輪共用部
        public Boolean isParking {get; set;}    //駐車場空きあり
        public Boolean isInSiteParking {get; set;}      //敷地内駐車場
        public Boolean isPluralCarParking {get; set;}   //駐車場2台可
        public Boolean isBuiltInGarage {get; set;}      //ビルトインガレージ
        public Boolean isCarport {get; set;}            //カーポート
        public Boolean isBicycleParking {get; set;}     //駐輪場
        public Boolean isBikeStorage {get; set;}               //バイク可
        public Boolean isSmallBike {get; set;}          //小型バイク
        public Boolean isMediumBike {get; set;}         //中型バイク
        public Boolean isLargeBike {get; set;}          //大型バイク
        public Boolean isElevator {get; set;}           //エレベーター
        public Boolean isDeliveryBox {get; set;}        //宅配ボックス
        // キッチン
        public Boolean isCounterKitchen {get; set;}     //カウンターキッチン
        public Boolean isSystemKitchen {get; set;}      //システムキッチン
        public Boolean isGasStove {get; set;}           //ガスコンロ
        public Boolean isElectricStove {get; set;}      //電気コンロ
        public Boolean isInductionHeating {get; set;}            //IHコンロ
        public Boolean isTwoGasStove {get; set;}        //コンロ2口
        public Boolean isMoreGasStove {get; set;}       //コンロ3口以上
        // バス・トイレ洗面所
        public Boolean isSepalateBathAndRestroom {get; set;}           //バス・トイレ別
        public Boolean isAditionalBoiling {get; set;}          //追焚機能
        public Boolean isDehumidifierForBathroom {get; set;}      //浴室乾燥機
        public Boolean isWashlet {get; set;}  //温水洗浄便座
        public Boolean isShowerWashBasin {get; set;}    //シャワー付き洗面台
        public Boolean isRegalLavatory {get; set;}    //洗面所独立
        public Boolean isInnerLandry {get; set;}//室内洗濯機置場
        // 光熱設備・空調
        public Boolean isTownGas {get; set;}            //都市ガス
        public Boolean isPropaneGas {get; set;}         //プロパンガス
        public Boolean isAllElectric {get; set;}        //オール電化
        public Boolean isAirConditioner {get; set;}     //エアコン
        public Boolean isFloorHeating {get; set;}       //床暖房
        // 収納
        public Boolean isShoesBox {get; set;}           //シューズボックス
        public Boolean isShoeCloak {get; set;}          //シューズクローク
        public Boolean isWalkInCloset {get; set;}       //ウォークインクローゼット
        public Boolean isTrunkRoom {get; set;}          //トランクルーム
        // 通信設備
        public Boolean isBSAntenna {get; set;}          //BSアンテナ
        public Boolean isCSAntenna {get; set;}          //CSアンテナ
        public Boolean isCATV {get; set;}               //CATV
        public Boolean isInternetFree {get; set;}       //ネット使用料無料
        // セキュリティ
        public Boolean isMonitorIntercom {get; set;}    //モニター付きインターホン
        public Boolean isAutoLock {get; set;}           //オートロック
        // 家具・家電
        public Boolean isFurniture {get; set;}          //家具付き
        public Boolean isHomeAppliance {get; set;}      //家電付き
        // 入居条件・支払方法
        public Boolean isNoGuarantor {get; set;}                //保証人不要
        public Boolean isNonGuaranteeidCompany {get; set;}       //保証会社不要
        public Boolean isMusicalInstruments {get; set;}         //楽器相談可
        public Boolean isForeigner {get; set;}                  //外国人契約可
        public Boolean isWelfareAvailable {get; set;}          //生活保護契約可
        public Boolean isOfficeAvailable {get; set;}            //事務所利用可
        public Boolean isPet {get; set;}                        //ペット可
        public Boolean isSmallPet {get; set;}                   //ペット(小型犬)
        public Boolean isMiddlePet {get; set;}                  //ペット(中型犬)
        public Boolean isLargePet {get; set;}                   //ペット(大型犬)
        public Boolean isCat {get; set;}                        //ペット(猫)
        public Boolean isOtherPet {get; set;}                   //ペット(その他)
        public Boolean isTwoTenant {get; set;}                  //2人入居可
        public Boolean isRoomShare {get; set;}                  //ルームシェア可
        public Boolean isIppambutsu {get; set;}                 //一般物
        public Boolean isElderly {get; set;}                    //高齢者歓迎
        public Boolean isWoman {get; set;}                      //女性限定
        public Boolean isStudent {get; set;}                    //学生限定マンション
        public Boolean isRentCreditPayment {get; set;}          //家賃カード決済可
        public Boolean isInitialCostCreditPayment {get; set;}   //初期費用カード決済可
        public String juniorHighSchoolDistrict { get; set; }    //中学校希望学区(エリア)　問合せ367で追加
        public String elementarySchoolDistrict { get; set; }    //小学校希望学区(エリア)　問合せ367で追加
        public String juniorHighSchoolArea { get; set; }        //中学校希望学区(エリア).希望学区　問合せ367で追加
        public String elementarySchoolArea { get; set; }        //小学校希望学区(エリア).希望学区　問合せ367で追加
        public String juniorHighSchool { get; set; }            //中学校文字列　問合せ367で追加
        public String elementarySchool { get; set; }            //小学校文字列　問合せ367で追加
        public List<School__c> juniorHighSchoolList {get; set;} //中学校リスト 問合せ367で追加 
        public List<School__c> elementarySchoolList {get; set;} //小学校リスト 問合せ367で追加

        /**
         * コンストラクタ
         * @param  なし
         * @return なし
         */
        public DisplaySearchCondition() {
            //初期化
			this.spcId				= null;						   //ID 2021.10.08 No.307 対応で追加
			this.accountId			= null;						   //取引先
			this.systemModStamp		= null;						   //SystemModStamp
            this.propertyName       = CommonConst.STRING_EMPTY;    //物件名
            this.address            = CommonConst.STRING_EMPTY;    //住所（丁目まで）
            this.formerSupplierName = CommonConst.STRING_EMPTY;    //元付業者
            this.propertyCode       = CommonConst.STRING_EMPTY;    //物件コード
            this.freeWord           = CommonConst.STRING_EMPTY;    //フリーワード
            // 路線
            this.trainRoute1 = null;     // 路線
            this.trainRoute2 = null;     // 路線
            this.trainRoute3 = null;     // 路線
            this.stations1   = new List<Station__c>();      // 駅１
            this.stations2   = new List<Station__c>();      // 駅２
            this.stations3   = new List<Station__c>();      // 駅３
            this.stationsChar1 = CommonConst.STRING_EMPTY;           //駅１文字列
            this.stationsChar2 = CommonConst.STRING_EMPTY;           //駅２文字列
            this.stationsChar3 = CommonConst.STRING_EMPTY;           //駅１文字列
            this.walkingTime = CommonConst.STRING_EMPTY;       //徒歩
            // 学区　問合せ367で追加
            this.juniorHighSchoolDistrict = null;               // 中学校希望学区(エリア)
            this.elementarySchoolDistrict = null;               // 小学校希望学区(エリア)
            this.juniorHighSchoolArea = null;                   // 中学校希望学区(エリア).希望学区
            this.elementarySchoolArea = null;                   // 小学校希望学区(エリア).希望学区
            this.juniorHighSchool = null;                       // 中学校文字列
            this.elementarySchool = null;                       // 小学校文字列
            this.juniorHighSchoolList = new List<School__c>();  // 中学校リスト
            this.elementarySchoolList = new List<School__c>();  // 小学校リスト
            // 現況
            this.isLiveStatusLive           = false;    // 居住中
            this.isLiveStatusEmpty          = true;     // 空室
            this.IsLiveStatusLeaveSchedule  = true;    // 退去予定
            // 間取り
            this.isOneRoom         = false;    //ワンルーム
            this.is1K              = false;    //1K
            this.is1DK             = false;    //1DK
            this.is1LDK1SLDK       = false;    //1LDK/SLDK
            this.is2K2DK           = false;    //2K/DK
            this.is2LDK2SLDK       = false;    //2LDK/SLDK
            this.is3K3DK           = false;    //3K/DK 
            this.is3LDK3SLDK       = false;    //3LDK/SLDK 
            this.is4K4DK4LDKFrom   = false;        //4K/DK/LDK~
            // 構造
            this.isWooden           = false;   //木造
            this.isLightweightSteel = false;   //軽量鉄骨
            this.isSteel            = false;   //鉄骨造
            this.isRC               = false;   //RC
            this.isSRC              = false;   //SRC
            // 方角
            this.isNorth            = false;   //北
            this.isNortheast        = false;   //北東
            this.isEast             = false;   //東
            this.isSouthEast        = false;   //南東
            this.isSouth            = false;   //南
            this.isSouthWest        = false;   //南西
            this.isWest             = false;   //西
            this.isNorthWest        = false;   //北西
            // 敷礼・更新料
            this.isNonDeposit       = false;   //敷金/保証金なし
            this.isNonKeyMoney      = false;   //礼金なし
            this.isNonCleaningFee   = false;   //定額修繕費なし
            this.isNonRenewalFee    = false;   //更新料なし// 
            //住居条件
            this.rentFeeFrom                = CommonConst.STRING_EMPTY;     // 賃料 From     
            this.rentFeeTo                  = CommonConst.STRING_EMPTY;     // 賃料 To       
            this.isIncludeManagementFee     = false;                        // 管理費込み
            this.isIncludeParkingFee        = false;                        // 駐車場代込み
            this.occupancyAreaLowerLimit    = CommonConst.STRING_EMPTY;     // 占有面積（下限）
            this.occupancyAreaUpperLimit    = CommonConst.STRING_EMPTY;     // 占有面積（上限）
            this.buildingAge                = CommonConst.STRING_EMPTY;     // 築年数
            // this.carCount                   = CommonConst.STRING_EMPTY;     // 台数
            // this.parkingFeeLimit            = CommonConst.STRING_EMPTY;     // 1台当たりの料金上限
            this.isScore34Less = false;           //34点未満
            this.isScore34to35 = false;            //34～35点
            this.isScore36More = false;            //36点以上
            this.isScoreAll    = false;            //全て
            // 構造・工法
            this.isDetachedHouse     = false;  //戸建て
            this.isMaisonette        = false; //メゾネット
            this.isLoft              = false;  //ロフト
            this.isDesigners         = false;  //デザイナーズ
            this.isRenovation        = false;  //リノベーション
            this.isCondominiumRental = false;  //分譲賃貸
            this.isAllWestern        = false;  //オール洋間
            // フロア・庭バルコニー
            this.isFirstFloor      = false;    //1階
            this.isSecondFloorOver = false;  //2階以上
            this.isTopFloor        = false;    //最上階
            this.isCornerRoom      = false;    //角部屋
            this.isBalcony         = false;    //バルコニー
            this.isRoofBalcony     = false;    //ルーフバルコニー
            this.isPrivateGarden   = false;    //専用庭
            // 駐車・駐輪共用部
            this.isParking          = false;    //駐車場空きあり
            this.isInSiteParking    = false;   //敷地内駐車場
            this.isPluralCarParking = false;   //駐車場2台可
            this.isBuiltInGarage    = false;   //ビルトインガレージ
            this.isCarport          = false;   //カーポート
            this.isBicycleParking   = false;   //駐輪場
            this.isBikeStorage      = false;          //バイク可
            this.isSmallBike        = false;   //小型バイク
            this.isMediumBike       = false;   //中型バイク
            this.isLargeBike        = false;   //大型バイク
            this.isElevator         = false;   //エレベーター
            this.isDeliveryBox      = false;   //宅配ボックス
            // キッチン
            this.isCounterKitchen   = false;   //カウンターキッチン
            this.isSystemKitchen    = false;   //システムキッチン
            this.isGasStove         = false;   //ガスコンロ
            this.isElectricStove    = false;   //電気コンロ
            this.isInductionHeating = false;            //IHコンロ
            this.isTwoGasStove      = false;   //コンロ2口
            this.isMoreGasStove     = false;   //コンロ3口以上
            // バス・トイレ洗面所
            this.isSepalateBathAndRestroom = false;           //バス・トイレ別
            this.isAditionalBoiling        = false;   //追焚機能
            this.isDehumidifierForBathroom = false;      //浴室乾燥機
            this.isWashlet                 = false;     //温水洗浄便座
            this.isShowerWashBasin         = false;         //シャワー付き洗面台
            this.isRegalLavatory           = false;       //洗面所独立
            this.isInnerLandry             = false;      //室内洗濯機置場
            // 光熱設備・空調
            this.isTownGas         = false;    //都市ガス
            this.isPropaneGas      = false;    //プロパンガス
            this.isAllElectric     = false;    //オール電化
            this.isAirConditioner  = false;    //エアコン
            this.isFloorHeating    = false;    //床暖房
            // 収納
            this.isShoesBox        = false;    //シューズボックス
            this.isShoeCloak       = false;    //シューズクローク
            this.isWalkInCloset    = false;    //ウォークインクローゼット
            this.isTrunkRoom       = false;    //トランクルーム
            // 通信設備
            this.isBSAntenna       = false;    //BSアンテナ
            this.isCSAntenna       = false;    //CSアンテナ
            this.isCATV            = false;    //CATV
            this.isInternetFree    = false;    //ネット使用料無料
            // セキュリティ
            this.isMonitorIntercom = false;    //モニター付きインターホン
            this.isAutoLock        = false;    //オートロック
            // 家具・家電
            this.isFurniture       = false;    //家具付き
            this.isHomeAppliance   = false;    //家電付き
            // 入居条件・支払方法
            this.isNoGuarantor               = false;     //保証人不要
            this.isNonGuaranteeidCompany     = false;      //保証会社不要
            this.isMusicalInstruments        = false;     //楽器相談可
            this.isForeigner                 = false;     //外国人契約可
            this.isWelfareAvailable          = false;    //生活保護契約可
            this.isOfficeAvailable           = false;     //事務所利用可
            this.isPet                       = false;     //ペット可
            this.isSmallPet                  = false;     //ペット(小型犬)
            this.isMiddlePet                 = false;     //ペット(中型犬)
            this.isLargePet                  = false;     //ペット(大型犬)
            this.isCat                       = false;     //ペット(猫)
            this.isOtherPet                  = false;     //ペット(その他)
            this.isTwoTenant                 = false;     //2人入居可
            this.isRoomShare                 = false;     //ルームシェア可
            this.isIppambutsu                = false;     //一般物
            this.isElderly                   = false;     //高齢者歓迎
            this.isWoman                     = false;     //女性限定
            this.isStudent                   = false;     //学生限定マンション
            this.isRentCreditPayment         = false;     //家賃カード決済可
            this.isInitialCostCreditPayment  = false;  //初期費用カード決済可
        }

		/**
		 * コンストラクタ
		 * @param  Account                ac           取引先
		 * @param  Map<Id, List<Station>> stationMap   取引先の希望路線に紐づく駅
		 * @return なし
		 */
		public DisplaySearchCondition(Account ac, Map<Id, List<Station__c>> stationMap, Map<Id, List<School__c>> schoolMap) {
			// 初期化
			this.stations1   = new List<Station__c>();
			this.stations2   = new List<Station__c>();
			this.stations3   = new List<Station__c>();
			this.elementarySchoolList = new List<School__c>();
			this.juniorHighSchoolList = new List<School__c>();
			//
			this.accountId			= ac.Id;							// 取引先ID
			this.SystemModStamp		= ac.SystemModStamp;				// SystemModStamp
			this.propertyName		= CommonConst.STRING_EMPTY;			// 物件名
			this.address			= ac.DesiredArea__c;				// 住所（丁目まで）
			this.formerSupplierName	= CommonConst.STRING_EMPTY;			// 元付業者
			this.propertyCode		= CommonConst.STRING_EMPTY;			// 物件コード
			this.freeWord			= CommonConst.STRING_EMPTY;			// フリーワード
			// 路線
			this.trainRoute1 = ac.DesiredTrainRoute1__r.TrainRoute__c;  //路線１
			this.trainRoute2 = ac.DesiredTrainRoute2__r.TrainRoute__c;  //路線２
			this.trainRoute3 = ac.DesiredTrainRoute3__r.TrainRoute__c;  //路線３
			if (stationMap.containskey(ac.DesiredTrainRoute1__c)) {
				this.stations1	= stationMap.get(ac.DesiredTrainRoute1__c);			// 駅１
				List<String> temp = new List<String>();
				for (Station__c obj : stationMap.get(ac.DesiredTrainRoute1__c)) {
					temp.add(obj.Name);
				}
				if (temp.size() > 0) {
					this.stationsChar1 = String.join(temp,';');
				}
			}
			if (stationMap.containskey(ac.DesiredTrainRoute2__c)) {
				this.stations2	= stationMap.get(ac.DesiredTrainRoute2__c);			// 駅２
				List<String> temp = new List<String>();
				for (Station__c obj : stationMap.get(ac.DesiredTrainRoute2__c)) {
					temp.add(obj.Name);
				}
				if (temp.size() > 0) {
					this.stationsChar2 = String.join(temp,';');
				}
			}
			if (stationMap.containskey(ac.DesiredTrainRoute3__c)) {
				this.stations3	= stationMap.get(ac.DesiredTrainRoute3__c);			// 駅３
				List<String> temp = new List<String>();
				for (Station__c obj : stationMap.get(ac.DesiredTrainRoute3__c)) {
					temp.add(obj.Name);
				}
				if (temp.size() > 0) {
					this.stationsChar3 = String.join(temp,';');
				}
			}
			this.walkingTime   =  ac.WalkingTime__c;		//徒歩
			// 学区　問合せ367で追加
			this.juniorHighSchoolDistrict = ac.DesiredJuniorHighSchoolArea__c;				// 中学校希望学区(エリア)
			this.elementarySchoolDistrict = ac.DesiredElementarySchoolArea__c;				// 小学校希望学区(エリア)
			this.juniorHighSchoolArea = ac.DesiredJuniorHighSchoolArea__r.SchoolArea__c;	// 中学校希望学区(エリア).希望学区
			this.elementarySchoolArea = ac.DesiredElementarySchoolArea__r.SchoolArea__c;	// 小学校希望学区(エリア).希望学区
			if (schoolMap.containskey(ac.DesiredJuniorHighSchoolArea__c)) {
				this.juniorHighSchoolList	= schoolMap.get(ac.DesiredJuniorHighSchoolArea__c);	// 中学校リスト
				List<String> temp = new List<String>();
				for (School__c obj : schoolMap.get(ac.DesiredJuniorHighSchoolArea__c)) {
					temp.add(obj.Name);
				}
				if (temp.size() > 0) {
					this.juniorHighSchool = String.join(temp,';');  // 小学校文字列
				}
			}
			if (schoolMap.containskey(ac.DesiredElementarySchoolArea__c)) {
				this.elementarySchoolList	= schoolMap.get(ac.DesiredElementarySchoolArea__c);	// 小学校リスト
				List<String> temp = new List<String>();
				for (School__c obj : schoolMap.get(ac.DesiredElementarySchoolArea__c)) {
					temp.add(obj.Name);
				}
				if (temp.size() > 0) {
					this.elementarySchool = String.join(temp,';');  // 中学校文字列
				}
			}
			// 現況
			this.isLiveStatusLive			= false;	//住居中
			this.isLiveStatusEmpty			= true;		//空室
			this.IsLiveStatusLeaveSchedule	= true;		//退去予定
			//間取り
			this.isOneRoom			= ac.IsOneRoom__c;			//ワンルーム
			this.is1K				= ac.Is1K__c;				//1K
			this.is1DK				= ac.Is1DK__c;				//1DK
			this.is1LDK1SLDK		= ac.Is1LDK1SLDK__c;		//1LDK/SLDK
			this.is2K2DK			= ac.Is2K2DK__c;			//2K/DK
			this.is2LDK2SLDK		= ac.Is2LDK2SLDK__c;		//2LDK/SLDK
			this.is3K3DK			= ac.Is3K3DK__c;			//3K/DK
			this.is3LDK3SLDK		= ac.Is3LDK3SLDK__c;		//3LDK/SLDK
			this.is4K4DK4LDKFrom	= ac.Is4K4DK4LDKFrom__c;	//4K/DK/LDK~
			//構造
			this.isWooden			= ac.IsWooden__c;			//木造
			this.isLightweightSteel	= ac.IsLightweightSteel__c;	//軽量鉄骨
			this.isSteel			= ac.IsSteel__c;			//鉄骨造
			this.isRC				= ac.IsRC__c;				//RC
			this.isSRC				= ac.IsSRC__c;				//SRC
			//方角
			this.isNorth		= ac.IsNorth__c;		//北
			this.isNortheast	= ac.IsNorthEast__c;	//北東
			this.isEast			= ac.IsEast__c;			//東
			this.isSouthEast	= ac.IsSouthEast__c;	//南東
			this.isSouth		= ac.IsSouth__c;		//南
			this.isSouthWest	= ac.IsSouthWest__c;	//南西
			this.isWest			= ac.IsWest__c;			//西
			this.isNorthWest	= ac.IsNorthWest__c;	//北西
			//敷礼・更新料
			this.isNonDeposit		= ac.IsNonDeposit__c;		//敷金/保証金なし
			this.isNonKeyMoney		= ac.IsNonKeyMoney__c;		//礼金なし
			this.isNonCleaningFee	= ac.IsNonCleaningFee__c;	//定額修繕費なし
			this.isNonRenewalFee	= ac.IsNonRenewalFee__c;	//更新料なし
			//
			this.rentFeeFrom				= CommonUtil.decimalToString(ac.RentFeeFrom__c);//賃料From
			this.rentFeeTo					= CommonUtil.decimalToString(ac.RentFeeTo__c);	//賃料To
			this.isIncludeManagementFee		= ac.IsIncludeManagementFee__c;					//管理費込み
			this.isIncludeParkingFee		= ac.IsIncludeParkingFee__c;					//駐車場代込み
			this.occupancyAreaLowerLimit	= ac.occupancyAreaLowerLimit__c;				//占有面積From※選択リスト
			this.occupancyAreaUpperLimit	= ac.OccupancyAreaUpperLimit__c;				//占有面積To※選択リスト

			this.buildingAge		= ac.BuildingAge__c;		//築年数
			this.isScore34Less		= ac.IsScore34Less__c;		//34点未満
			this.isScore34to35		= ac.IsScore34to35__c;		//34～35点
			this.isScore36More		= ac.IsScore36More__c;		//36点以上
			this.isScoreAll			= ac.IsScoreAll__c;			//全て
			//構造・工法
			this.isDetachedHouse	= ac.IsDetachedHouse__c;	//戸建て
			this.isMaisonette		= ac.IsMaisonette__c;		//メゾネット
			this.isLoft				= ac.IsLoft__c;				//ロフト
			this.isDesigners		= ac.IsDesigners__c;		//デザイナーズ
			this.isRenovation		= ac.IsRenovation__c;		//リノベーション
			this.isCondominiumRental= ac.IsCondominiumRental__c;//分譲賃貸
			this.isAllWestern		= ac.IsAllWestern__c;		//オール洋間
			//フロア・庭バルコニー
			this.isFirstFloor		= ac.IsFirstFloor__c;		//1階
			this.isSecondFloorOver	= ac.IsSecondFloorOver__c;	//2階以上
			this.isTopFloor			= ac.IsTopFloor__c;			//最上階
			this.isCornerRoom		= ac.IsCornerRoom__c;		//角部屋
			this.isBalcony			= ac.IsBalcony__c;			//バルコニー
			this.isRoofBalcony		= ac.IsRoofBalcony__c;		//ルーフバルコニー
			this.isPrivateGarden	= ac.IsPrivateGarden__c;	//専用庭
			//駐車・駐輪共用部
			this.isParking			= ac.IsParking__c;			//駐車場空きあり
			this.isInSiteParking	= ac.IsInSiteParking__c;	//敷地内駐車場
			this.isPluralCarParking	= ac.IsPluralCarParking__c;	//駐車場2台可
			this.isBuiltInGarage	= ac.IsBuiltInGarage__c;	//ビルトインガレージ
			this.isCarport			= ac.IsCarport__c;			//カーポート
			this.isBicycleParking	= ac.IsBicycleParking__c;	//駐輪場
			this.isBikeStorage		= ac.IsBikeStorage__c;		//バイク可
			this.isSmallBike		= ac.IsSmallBike__c;		//小型バイク
			this.isMediumBike		= ac.IsMediumBike__c;		//中型バイク
			this.isLargeBike		= ac.IsLargeBike__c;		//大型バイク
			this.isElevator			= ac.IsElevator__c;			//エレベーター
			this.isDeliveryBox		= ac.IsDeliveryBox__c;		//宅配ボックス
			//キッチン
			this.isCounterKitchen	= ac.IsCounterKitchen__c;	//カウンターキッチン
			this.isSystemKitchen	= ac.IsSystemKitchen__c;	//システムキッチン
			this.isGasStove			= ac.IsGasStove__c;			//ガスコンロ
			this.isElectricStove	= ac.IsElectricStove__c;	//電気コンロ
			this.isInductionHeating	= ac.IsInductionHeating__c;	//IHコンロ
			this.isTwoGasStove		= ac.IsTwoGasStove__c;		//コンロ2口
			this.isMoreGasStove		= ac.IsMoreGasStove__c;		//コンロ3口以上
			//バス・トイレ洗面所
			this.isSepalateBathAndRestroom	= ac.IsSepalateBathAndRestroom__c;	//バス・トイレ別
			this.isAditionalBoiling			= ac.IsAditionalBoiling__c;			//追焚機能
			this.isDehumidifierForBathroom	= ac.IsDehumidifierForBathroom__c;	//浴室乾燥機
			this.isWashlet					= ac.IsWashlet__c;					//温水洗浄便座
			this.isShowerWashBasin			= ac.IsShowerWashBasin__c;			//シャワー付き洗面台
			this.isRegalLavatory			= ac.IsRegalLavatory__c;			//洗面所独立
			this.isInnerLandry				= ac.IsInnerLandry__c;				//室内洗濯機置場
			//光熱設備・空調
			this.isTownGas			= ac.IsTownGas__c;			//都市ガス
			this.isPropaneGas		= ac.IsPropaneGas__c;		//プロパンガス
			this.isAllElectric		= ac.IsAllElectric__c;		//オール電化
			this.isAirConditioner	= ac.IsAirConditioner__c;	//エアコン
			this.isFloorHeating		= ac.IsFloorHeating__c;		//床暖房
			//収納
			this.isShoesBox		= ac.IsShoesBox__c;			//シューズボックス
			this.isShoeCloak	= ac.IsShoeCloak__c;		//シューズクローク
			this.isWalkInCloset	= ac.IsWalkInCloset__c;		//ウォークインクローゼット
			this.isTrunkRoom	= ac.IsTrunkRoom__c;		//トランクルーム
			//通信設備
			this.isBSAntenna	= ac.IsBSAntenna__c;		//BSアンテナ
			this.isCSAntenna	= ac.IsCSAntenna__c;		//CSアンテナ
			this.isCATV			= ac.IsCATV__c;				//CATV
			this.isInternetFree	= ac.IsInternetFree__c;		//ネット使用料無料
			//セキュリティ
			this.isMonitorIntercom	= ac.IsMonitorIntercom__c;	//モニタ付インターホン
			this.isAutoLock			= ac.IsAutoLock__c;			//オートロック
			//家具・家電
			this.isFurniture		= ac.IsFurniture__c;		//家具付き
			this.isHomeAppliance	= ac.IsHomeAppliance__c;	//家電付き
			//入居条件・支払方法
			this.isNoGuarantor				= ac.IsNoGuarantor__c;				//保証人不要
			this.isNonGuaranteeidCompany	= ac.IsNonGuaranteeidCompany__c;	//保証会社不要
			this.isMusicalInstruments		= ac.IsMusicalInstruments__c;		//楽器相談可
			this.isForeigner				= ac.IsForeigner__c;				//外国人契約可
			this.isWelfareAvailable			= ac.IsWelfareAvailable__c;			//生活保護契約可
			this.isOfficeAvailable			= ac.IsOfficeAvailable__c;			//事務所利用可
			this.isPet						= ac.IsPet__c;						//ペット可
			this.isSmallPet					= ac.IsSmallPet__c;					//ペット(小型犬)
			this.isMiddlePet				= ac.IsMiddlePet__c;				//ペット(中型犬)
			this.isLargePet					= ac.IsLargePet__c;					//ペット(大型犬)
			this.isCat						= ac.IsCat__c;						//ペット(猫)
			this.isOtherPet					= ac.IsOtherPet__c;					//ペット(その他)
			this.isTwoTenant				= ac.IsTwoTenant__c;				//2人入居可
			this.isRoomShare				= ac.IsRoomShare__c;				//ルームシェア可
			this.isIppambutsu				= ac.IsIppambutsu__c;				//一般物
			this.isElderly					= ac.IsElderly__c;					//高齢者歓迎
			this.isWoman					= ac.IsWoman__c;					//女性限定
			this.isStudent					= ac.IsStudent__c;					//学生限定マンション
			this.isRentCreditPayment		= ac.IsRentCreditPayment__c;		//家賃カード決済可
			this.isInitialCostCreditPayment	= ac.IsInitialCostCreditPayment__c;	//初期費用カード決済可
		}

		// ▼2021.10.08 No.307 対応でお客様物件条件追加
		/**
		 * コンストラクタ
		 * @param  AccountPropertyConditions__c spc    お客様物件条件
		 * @param  Map<Id, List<Station>> stationMap   お客様物件条件の希望路線に紐づく駅
		 * @return なし
		 */
		public DisplaySearchCondition(AccountPropertyConditions__c spc, Map<Id, List<Station__c>> stationMap, Map<Id, List<School__c>> schoolMap) {
			// 初期化
			this.stations1   = new List<Station__c>();
			this.stations2   = new List<Station__c>();
			this.stations3   = new List<Station__c>();
			this.elementarySchoolList = new List<School__c>();
			this.juniorHighSchoolList = new List<School__c>();
			//
			this.spcId				= spc.Id;						// お客様物件条件ID
			this.accountId			= spc.Account__c;				// 取引先ID
			this.SystemModStamp		= spc.SystemModStamp;			// SystemModStamp
			this.propertyName		= CommonConst.STRING_EMPTY;		// 物件名
			this.address			= spc.DesiredArea__c;			// 住所（丁目まで）
			this.formerSupplierName	= CommonConst.STRING_EMPTY;		// 元付業者
			this.propertyCode		= CommonConst.STRING_EMPTY;		// 物件コード
			this.freeWord			= CommonConst.STRING_EMPTY;		// フリーワード
			// 路線
			this.trainRoute1 = spc.DesiredTrainRoute1__r.TrainRoute__c;  //路線１
			this.trainRoute2 = spc.DesiredTrainRoute2__r.TrainRoute__c;  //路線２
			this.trainRoute3 = spc.DesiredTrainRoute3__r.TrainRoute__c;  //路線３
			if (stationMap.containskey(spc.DesiredTrainRoute1__c)) {
				this.stations1	= stationMap.get(spc.DesiredTrainRoute1__c);	// 駅１
				List<String> temp = new List<String>();
				for (Station__c obj : stationMap.get(spc.DesiredTrainRoute1__c)) {
					temp.add(obj.Name);
				}
				if (temp.size() > 0) {
					this.stationsChar1 = String.join(temp,';');
				}
			}
			if (stationMap.containskey(spc.DesiredTrainRoute2__c)) {
				this.stations2	= stationMap.get(spc.DesiredTrainRoute2__c);	// 駅２
				List<String> temp = new List<String>();
				for (Station__c obj : stationMap.get(spc.DesiredTrainRoute2__c)) {
					temp.add(obj.Name);
				}
				if (temp.size() > 0) {
					this.stationsChar2 = String.join(temp,';');
				}
			}
			if (stationMap.containskey(spc.DesiredTrainRoute3__c)) {
				this.stations3	= stationMap.get(spc.DesiredTrainRoute3__c);	// 駅３
				List<String> temp = new List<String>();
				for (Station__c obj : stationMap.get(spc.DesiredTrainRoute3__c)) {
					temp.add(obj.Name);
				}
				if (temp.size() > 0) {
					this.stationsChar3 = String.join(temp,';');
				}
			}
			this.walkingTime   =  spc.WalkingTime__c;	//徒歩
			// 学区　問合せ367で追加
			this.juniorHighSchoolDistrict = spc.DesiredJuniorHighSchoolArea__c;				// 中学校希望学区(エリア)
			this.elementarySchoolDistrict = spc.DesiredElementarySchoolArea__c;				// 小学校希望学区(エリア)
			this.juniorHighSchoolArea = spc.DesiredJuniorHighSchoolArea__r.SchoolArea__c;	// 中学校希望学区(エリア).希望学区
			this.elementarySchoolArea = spc.DesiredElementarySchoolArea__r.SchoolArea__c;	// 小学校希望学区(エリア).希望学区
			if (schoolMap.containskey(spc.DesiredJuniorHighSchoolArea__c)) {
				this.juniorHighSchoolList	= schoolMap.get(spc.DesiredJuniorHighSchoolArea__c);	// 中学校リスト
				List<String> temp = new List<String>();
				for (School__c obj : schoolMap.get(spc.DesiredJuniorHighSchoolArea__c)) {
					temp.add(obj.Name);
				}
				if (temp.size() > 0) {
					this.juniorHighSchool = String.join(temp,';');  // 小学校文字列
				}
			}
			if (schoolMap.containskey(spc.DesiredElementarySchoolArea__c)) {
				this.elementarySchoolList	= schoolMap.get(spc.DesiredElementarySchoolArea__c);	// 小学校リスト
				List<String> temp = new List<String>();
				for (School__c obj : schoolMap.get(spc.DesiredElementarySchoolArea__c)) {
					temp.add(obj.Name);
				}
				if (temp.size() > 0) {
					this.elementarySchool = String.join(temp,';');  // 中学校文字列
				}
			}
			// 現況
			this.isLiveStatusLive			= false;	//住居中
			this.isLiveStatusEmpty			= true;		//空室
			this.IsLiveStatusLeaveSchedule	= true;		//退去予定
			//間取り
			this.isOneRoom			= spc.IsOneRoom__c;			//ワンルーム
			this.is1K				= spc.Is1K__c;				//1K
			this.is1DK				= spc.Is1DK__c;				//1DK
			this.is1LDK1SLDK		= spc.Is1LDK1SLDK__c;		//1LDK/SLDK
			this.is2K2DK			= spc.Is2K2DK__c;			//2K/DK
			this.is2LDK2SLDK		= spc.Is2LDK2SLDK__c;		//2LDK/SLDK
			this.is3K3DK			= spc.Is3K3DK__c;			//3K/DK
			this.is3LDK3SLDK		= spc.Is3LDK3SLDK__c;		//3LDK/SLDK
			this.is4K4DK4LDKFrom	= spc.Is4K4DK4LDKFrom__c;	//4K/DK/LDK~
			//構造
			this.isWooden			= spc.IsWooden__c;			//木造
			this.isLightweightSteel	= spc.IsLightweightSteel__c;//軽量鉄骨
			this.isSteel			= spc.IsSteel__c;			//鉄骨造
			this.isRC				= spc.IsRC__c;				//RC
			this.isSRC				= spc.IsSRC__c;				//SRC
			//方角
			this.isNorth		= spc.IsNorth__c;		//北
			this.isNortheast	= spc.IsNorthEast__c;	//北東
			this.isEast			= spc.IsEast__c;		//東
			this.isSouthEast	= spc.IsSouthEast__c;	//南東
			this.isSouth		= spc.IsSouth__c;		//南
			this.isSouthWest	= spc.IsSouthWest__c;	//南西
			this.isWest			= spc.IsWest__c;		//西
			this.isNorthWest	= spc.IsNorthWest__c;	//北西
			//敷礼・更新料
			this.isNonDeposit		= spc.IsNonDeposit__c;		//敷金/保証金なし
			this.isNonKeyMoney		= spc.IsNonKeyMoney__c;		//礼金なし
			this.isNonCleaningFee	= spc.IsNonCleaningFee__c;	//定額修繕費なし
			this.isNonRenewalFee	= spc.IsNonRenewalFee__c;	//更新料なし
			//
			this.rentFeeFrom				= CommonUtil.decimalToString(spc.RentFeeFrom__c);	//賃料From
			this.rentFeeTo					= CommonUtil.decimalToString(spc.RentFeeTo__c);		//賃料To
			this.isIncludeManagementFee		= spc.IsIncludeManagementFee__c;					//管理費込み
			this.isIncludeParkingFee		= spc.IsIncludeParkingFee__c;						//駐車場代込み
			this.occupancyAreaLowerLimit	= spc.occupancyAreaLowerLimit__c;					//占有面積From※選択リスト
			this.occupancyAreaUpperLimit	= spc.OccupancyAreaUpperLimit__c;					//占有面積To※選択リスト

			this.buildingAge		= spc.BuildingAge__c;		//築年数
			this.isScore34Less		= spc.IsScore34Less__c;		//34点未満
			this.isScore34to35		= spc.IsScore34to35__c;		//34～35点
			this.isScore36More		= spc.IsScore36More__c;		//36点以上
			this.isScoreAll			= spc.IsScoreAll__c;		//全て
			//構造・工法
			this.isDetachedHouse	= spc.IsDetachedHouse__c;		//戸建て
			this.isMaisonette		= spc.IsMaisonette__c;			//メゾネット
			this.isLoft				= spc.IsLoft__c;				//ロフト
			this.isDesigners		= spc.IsDesigners__c;			//デザイナーズ
			this.isRenovation		= spc.IsRenovation__c;			//リノベーション
			this.isCondominiumRental= spc.IsCondominiumRental__c;	//分譲賃貸
			this.isAllWestern		= spc.IsAllWestern__c;			//オール洋間
			//フロア・庭バルコニー
			this.isFirstFloor		= spc.IsFirstFloor__c;		//1階
			this.isSecondFloorOver	= spc.IsSecondFloorOver__c;	//2階以上
			this.isTopFloor			= spc.IsTopFloor__c;		//最上階
			this.isCornerRoom		= spc.IsCornerRoom__c;		//角部屋
			this.isBalcony			= spc.IsBalcony__c;			//バルコニー
			this.isRoofBalcony		= spc.IsRoofBalcony__c;		//ルーフバルコニー
			this.isPrivateGarden	= spc.IsPrivateGarden__c;	//専用庭
			//駐車・駐輪共用部
			this.isParking			= spc.IsParking__c;			//駐車場空きあり
			this.isInSiteParking	= spc.IsInSiteParking__c;	//敷地内駐車場
			this.isPluralCarParking	= spc.IsPluralCarParking__c;//駐車場2台可
			this.isBuiltInGarage	= spc.IsBuiltInGarage__c;	//ビルトインガレージ
			this.isCarport			= spc.IsCarport__c;			//カーポート
			this.isBicycleParking	= spc.IsBicycleParking__c;	//駐輪場
			this.isBikeStorage		= spc.IsBikeStorage__c;		//バイク可
			this.isSmallBike		= spc.IsSmallBike__c;		//小型バイク
			this.isMediumBike		= spc.IsMediumBike__c;		//中型バイク
			this.isLargeBike		= spc.IsLargeBike__c;		//大型バイク
			this.isElevator			= spc.IsElevator__c;		//エレベーター
			this.isDeliveryBox		= spc.IsDeliveryBox__c;		//宅配ボックス
			//キッチン
			this.isCounterKitchen	= spc.IsCounterKitchen__c;	//カウンターキッチン
			this.isSystemKitchen	= spc.IsSystemKitchen__c;	//システムキッチン
			this.isGasStove			= spc.IsGasStove__c;		//ガスコンロ
			this.isElectricStove	= spc.IsElectricStove__c;	//電気コンロ
			this.isInductionHeating	= spc.IsInductionHeating__c;//IHコンロ
			this.isTwoGasStove		= spc.IsTwoGasStove__c;		//コンロ2口
			this.isMoreGasStove		= spc.IsMoreGasStove__c;	//コンロ3口以上
			//バス・トイレ洗面所
			this.isSepalateBathAndRestroom	= spc.IsSepalateBathAndRestroom__c;	//バス・トイレ別
			this.isAditionalBoiling			= spc.IsAditionalBoiling__c;		//追焚機能
			this.isDehumidifierForBathroom	= spc.IsDehumidifierForBathroom__c;	//浴室乾燥機
			this.isWashlet					= spc.IsWashlet__c;					//温水洗浄便座
			this.isShowerWashBasin			= spc.IsShowerWashBasin__c;			//シャワー付き洗面台
			this.isRegalLavatory			= spc.IsRegalLavatory__c;			//洗面所独立
			this.isInnerLandry				= spc.IsInnerLandry__c;				//室内洗濯機置場
			//光熱設備・空調
			this.isTownGas			= spc.IsTownGas__c;			//都市ガス
			this.isPropaneGas		= spc.IsPropaneGas__c;		//プロパンガス
			this.isAllElectric		= spc.IsAllElectric__c;		//オール電化
			this.isAirConditioner	= spc.IsAirConditioner__c;	//エアコン
			this.isFloorHeating		= spc.IsFloorHeating__c;	//床暖房
			//収納
			this.isShoesBox		= spc.IsShoesBox__c;		//シューズボックス
			this.isShoeCloak	= spc.IsShoeCloak__c;		//シューズクローク
			this.isWalkInCloset	= spc.IsWalkInCloset__c;	//ウォークインクローゼット
			this.isTrunkRoom	= spc.IsTrunkRoom__c;		//トランクルーム
			//通信設備
			this.isBSAntenna	= spc.IsBSAntenna__c;		//BSアンテナ
			this.isCSAntenna	= spc.IsCSAntenna__c;		//CSアンテナ
			this.isCATV			= spc.IsCATV__c;			//CATV
			this.isInternetFree	= spc.IsInternetFree__c;	//ネット使用料無料
			//セキュリティ
			this.isMonitorIntercom	= spc.IsMonitorIntercom__c;	//モニタ付インターホン
			this.isAutoLock			= spc.IsAutoLock__c;		//オートロック
			//家具・家電
			this.isFurniture		= spc.IsFurniture__c;		//家具付き
			this.isHomeAppliance	= spc.IsHomeAppliance__c;	//家電付き
			//入居条件・支払方法
			this.isNoGuarantor				= spc.IsNoGuarantor__c;					//保証人不要
			this.isNonGuaranteeidCompany	= spc.IsNonGuaranteeidCompany__c;		//保証会社不要
			this.isMusicalInstruments		= spc.IsMusicalInstruments__c;			//楽器相談可
			this.isForeigner				= spc.IsForeigner__c;					//外国人契約可
			this.isWelfareAvailable			= spc.IsWelfareAvailable__c;			//生活保護契約可
			this.isOfficeAvailable			= spc.IsOfficeAvailable__c;				//事務所利用可
			this.isPet						= spc.IsPet__c;							//ペット可
			this.isSmallPet					= spc.IsSmallPet__c;					//ペット(小型犬)
			this.isMiddlePet				= spc.IsMiddlePet__c;					//ペット(中型犬)
			this.isLargePet					= spc.IsLargePet__c;					//ペット(大型犬)
			this.isCat						= spc.IsCat__c;							//ペット(猫)
			this.isOtherPet					= spc.IsOtherPet__c;					//ペット(その他)
			this.isTwoTenant				= spc.IsTwoTenant__c;					//2人入居可
			this.isRoomShare				= spc.IsRoomShare__c;					//ルームシェア可
			this.isIppambutsu				= spc.IsIppambutsu__c;					//一般物
			this.isElderly					= spc.IsElderly__c;						//高齢者歓迎
			this.isWoman					= spc.IsWoman__c;						//女性限定
			this.isStudent					= spc.IsStudent__c;						//学生限定マンション
			this.isRentCreditPayment		= spc.IsRentCreditPayment__c;			//家賃カード決済可
			this.isInitialCostCreditPayment	= spc.IsInitialCostCreditPayment__c;	//初期費用カード決済可
		}
		// ▲2021.10.08 No.307 対応でお客様物件条件追加


    }

    /* *
     * 画面表示用内部クラス（検索結果）
     */
    public class DisplaySearchResult {
        public Id buildingId {get; set;}                //建物ID
        public String buildingName {get; set;}          //建物名
        public Id propertyId {get; set;}                //物件ID
        public String propertyName {get; set;}          //物件名
        public String updateDate {get; set;}            //更新日
        public String liveStatus {get; set;}            //現況
        public String deliveryYM {get; set;}            //引き渡し年月
        public String photoCount {get; set;}            //写真枚数
        public String structure {get; set;}             //建物構造
        public String address {get; set;}               //住所
        public String RentFee {get; set;}               //賃料
        public String managementFee {get; set;}         //管理費
        public String deposit {get; set;}               //敷金/保証金
        public String keyMoney {get; set;}              //礼金
        public String cleaningFee {get; set;}           //定額修繕費
        public String nearestStation {get; set;}        //最寄駅
        public String buildingYear {get; set;}          //築年
        public String carParking {get; set;}            //駐車場
        public String roomLayout {get; set;}            //間取り
        public String occupiedArea {get; set;}          //占有面積
        public String direction {get; set;}             //方角
        public String formerSupplierName {get; set;}    //元付業者名
        public String formerSupplierPhone {get; set;}   //元付業者TEL
        public String posting {get; set;}               //掲載
        public String ad {get; set;}                    //AD

        /**
         * コンストラクタ
         */
        public DisplaySearchResult() {
            //初期化
        }

        /**
         * コンストラクタ
         */
        public DisplaySearchResult(Property__c prop) {
            this.buildingId          = prop.Building__c;                // 建物ID
            this.buildingName        = prop.Building__r.Name;           // 建物名
            this.propertyId          = prop.Id;                         // 物件ID
            this.propertyName        = prop.Name;                       // 物件名
            this.updateDate          = prop.LastModifiedDate.format('yyyy/MM/dd', 'JST');   //更新日
            this.liveStatus          = prop.LiveStatus__c;              // 現況
            this.deliveryYM          = prop.DeliveryDateView__c;        // 引き渡し年月
            this.photoCount          = CommonUtil.decimalToString(prop.PhotoCount__c);   //写真枚数
            this.structure           = prop.Building__r.Structure__c;   // 建物構造
            this.address             = prop.Building__r.Address__c;     // 住所

            // 賃料
            this.RentFee             = CommonUtil.decimalToString(prop.RentFee__c);   //賃料
            if (String.isNotEmpty(this.RentFee)) {
                this.RentFee += CommonConst.PROPERTY_FEEUNIT_YEN;
            }

            // 管理費
            this.managementFee       = CommonUtil.decimalToString(prop.ManagementFee__c);  //管理費
            if (String.isNotEmpty(this.managementFee)) {
                this.managementFee += CommonConst.PROPERTY_FEEUNIT_YEN;
            }

            // 敷金/保証金
            // 敷金
            String securityDeposit = CommonConst.STRING_EMPTY;
            if (prop.SecurityDepositUnit__c == CommonConst.PROPERTY_FEEUNIT_YEN && prop.SecurityDepositYen__c != null) {
                securityDeposit = CommonUtil.decimalToString(prop.SecurityDepositYen__c)   + CommonConst.PROPERTY_FEEUNIT_YEN;
            } else if(prop.SecurityDepositUnit__c == CommonConst.PROPERTY_FEEUNIT_MONTH && prop.SecurityDepositMonth__c != null) {
                securityDeposit = CommonUtil.decimalToString(prop.SecurityDepositMonth__c) + CommonConst.PROPERTY_FEEUNIT_MONTH;
            }
            // 保証金
            this.deposit = CommonConst.STRING_EMPTY;
            if (prop.DepositUnit__c == CommonConst.PROPERTY_FEEUNIT_YEN && prop.DepositYen__c != null) {
                this.deposit = CommonUtil.decimalToString(prop.DepositYen__c)   + CommonConst.PROPERTY_FEEUNIT_YEN;
            } else if(prop.DepositUnit__c == CommonConst.PROPERTY_FEEUNIT_MONTH && prop.DepositMonth__c != null) {
                this.deposit = CommonUtil.decimalToString(prop.DepositMonth__c) + CommonConst.PROPERTY_FEEUNIT_MONTH;
            }
            if (String.isNotEmpty(this.deposit + securityDeposit)) {
                this.deposit = securityDeposit + ' / ' + this.deposit;
            }

            // 礼金
            if (prop.KeyMoneyUnit__c == CommonConst.PROPERTY_FEEUNIT_YEN && prop.KeyMoneyYen__c != null) {
                    this.keyMoney = CommonUtil.decimalToString(prop.KeyMoneyYen__c) + CommonConst.PROPERTY_FEEUNIT_YEN;
            } else if(prop.KeyMoneyUnit__c == CommonConst.PROPERTY_FEEUNIT_MONTH && prop.KeyMoneyMonth__c != null) {
                    this.keyMoney = CommonUtil.decimalToString(prop.KeyMoneyMonth__c) + CommonConst.PROPERTY_FEEUNIT_MONTH;
            } else {
                    this.keyMoney = CommonConst.STRING_EMPTY;
            }
            //定額修繕費
            if (prop.CleaningFeeUnit__c == CommonConst.PROPERTY_FEEUNIT_YEN && prop.CleaningFeeYen__c != null) {
                this.cleaningFee = CommonUtil.decimalToString(prop.CleaningFeeYen__c) + CommonConst.PROPERTY_FEEUNIT_YEN;
            } else if(prop.CleaningFeeUnit__c == CommonConst.PROPERTY_FEEUNIT_MONTH && prop.CleaningFeeMonth__c != null) {
                this.cleaningFee = CommonUtil.decimalToString(prop.CleaningFeeMonth__c) + CommonConst.PROPERTY_FEEUNIT_MONTH;
            } else {
                this.cleaningFee = CommonConst.STRING_EMPTY;
            }
            this.nearestStation      = prop.Building__r.Station1__r.Name;  //最寄駅
            this.buildingYear        = prop.Building__r.BuildingYMFormat__c;  //築年

            //駐車場
            this.carParking = String.isNotEmpty(prop.ParkingType__c) ? prop.ParkingType__c + ' ' : CommonConst.STRING_EMPTY;
            if (String.isNotEmpty(CommonUtil.decimalToString(prop.ParkingFee__c))) {
                this.carParking += CommonUtil.decimalToString(prop.ParkingFee__c) + CommonConst.PROPERTY_FEEUNIT_YEN;
            }

            //間取り
            if (prop.RoomCount__c != null && !String.isBlank(prop.RoomLayout__c)) {
                this.roomLayout = CommonUtil.decimalToString(prop.RoomCount__c)
                                + prop.RoomLayout__c;
            }
            this.occupiedArea        = CommonUtil.decimalToString(prop.RoomArea__c);    // 占有面積
            this.direction           = prop.BalconyDirection__c;                        // 方角
            this.formerSupplierName  = prop.FormerSupplier__r.Name;                     // 元付業者名
            this.formerSupplierPhone = prop.FormerSupplier__r.Phone;                    // 元付業者TEL

            // 掲載
            Boolean isSuumo  = false;
            Boolean isHomes  = false;
            Boolean isAthome = false;
            for (PortalSitePostingProperty__c obj : prop.PortalSitePostingPropertyProperty__r) {
                if (isSuumo && isHomes && isAthome) {
                    break;
                }
                if (obj.IsSuumo__c) {
                    isSuumo = true;
                } 
                if (obj.IsHomes__c) {
                    isHomes = true;
                } 
                if (obj.IsAtHome__c) {
                    isAthome = true;
                }
            }
            List<String> postingList = new List<String>();
            if (isSuumo) {
                postingList.add('SUUMO');
            }
            if (isHomes) {
                postingList.add('HOME\'S');
            }
            if (isAthome) {
                postingList.add('at home');
            }
            this.posting = String.join(postingList, ',');
            // AD
            this.ad = CommonConst.STRING_EMPTY;
            if (String.isNotEmpty(CommonUtil.decimalToString(prop.ADFeeTax__c))) {
                if (prop.ADFeeUnit__c == CommonConst.PROPERTY_FEEUNIT_YEN) {
                    this.ad = CommonUtil.decimalToString(prop.ADFeeTax__c) + CommonConst.PROPERTY_FEEUNIT_YEN;
                } else if (prop.ADFeeUnit__c == CommonConst.PROPERTY_FEEUNIT_MONTH) {
                    this.ad = CommonUtil.decimalToString(prop.ADFeeMonth__c) + CommonConst.PROPERTY_FEEUNIT_MONTH;
                } else if (prop.ADFeeUnit__c == CommonConst.PROPERTY_FEEUNIT_RATE) {
                    this.ad = CommonUtil.decimalToString(prop.ADFeeRate__c) + CommonConst.PROPERTY_FEEUNIT_RATE;
                }
            }
        }
    }

    /* *
     * 画面表示用内部クラス（検索結果チェック状態保持用）
     */
    public class DisplaySearchResultCheck {
        public Boolean isCheck { get; set; }
        public Id propertyId { get; set; }
        public DisplaySearchResultCheck() {
            //初期化
            this.isCheck = false;
            this.propertyId = null;
        }
        public DisplaySearchResultCheck(Id propertyId) {
            //初期化
            this.isCheck = false;
            this.propertyId = propertyId;
        }
    }
}