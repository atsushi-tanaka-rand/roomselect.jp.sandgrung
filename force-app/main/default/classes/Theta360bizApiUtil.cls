/**
 * パノラマツアー非公開関連共通クラス
 */
public with sharing class Theta360bizApiUtil {

    /** private定数 */
    private static final String THETA_360BIZ_API_ID         = SystemConfig__c.getInstance().Theta360bizApiId__c;        // パノラマツアー認証Id
    private static final String THETA_360BIZ_API_ACCESSKEY  = SystemConfig__c.getInstance().Theta360bizApiAccessKey__c; // パノラマツアーAccessKey
    //再販対応　追加 Starat
    private static final Boolean isUseAuthorityPanoramaTour = AuthorityCheckUtil.getAuthorityOptionPanoramaTour(false); // パノラマツアー権限
    //再販対応 追加 End

    /**
     * コンストラクタ
     * @param  なし
     * @return なし
     */
    public Theta360bizApiUtil() {

    }
    
//************************************************************************** publicメソッド *************************************************************
    /**
     * パノラマツアー非公開処理
     * @param  Id     targetRecommendPropertyId         おすすめ物件ID
     */
    public static void callTheta360bizToursStatus(Id targetRecommendPropertyId){
        //再販対応 追加 Start
        if (!isUseAuthorityPanoramaTour){
            return; //権限がなければ処理を行わない
        }
        //再販対応 追加 End

        // ツアー情報のセット
        List<Id> targetRecommendPropertyIdList = new List<id>();
        targetRecommendPropertyIdList.add(targetRecommendPropertyId);
        callTheta360bizToursStatus(targetRecommendPropertyIdList);
    }
    public static List<RecommendProperty__c> callTheta360bizToursStatus(List<Id> targetRecommendPropertyIdList){
        //再販対応 追加 Start
        List<RecommendProperty__c> recommendPropertyList = selectRecommendProperty(targetRecommendPropertyIdList);
        List<RecommendProperty__c> changeRecommendPropertylList = new List<RecommendProperty__c>();

        if (!isUseAuthorityPanoramaTour){       //権限がない場合、対象全ての表示フラグをfalseに変更
            for (RecommendProperty__c rcPro : recommendPropertyList){
                changeRecommendPropertylList.add(setDisplayFlag(rcPro.id));
                return changeRecommendPropertylList;
            }
        }
        //再販対応 追加 End        

        // おすすめ物件のパノラマツアーを非公開するAPIを実行
        String user_access_key_id = getTheta360bizAuthentications();

        // ツアー情報一覧を取得します。
        Map<String,JsonForGetTheta360biz.tours> toursMap = getTheta360bizTours(user_access_key_id);

        // 重複URL判定対象のおすすめ物件を取得
        List<RecommendProperty__c> recommendPropertyDuplicateUrlList = selectDuplicateRecommendProperty(targetRecommendPropertyIdList);



        changeRecommendPropertylList = checkToursStatus(user_access_key_id,recommendPropertyDuplicateUrlList,recommendPropertyList,toursMap);

        return changeRecommendPropertylList;
    }

    /**
     * パノラマツアー非公開処理（パノラマツアーURLから）
     * @param  String     targetRecommendPropertyId         パノラマツアーURL
     */
    public static void callTheta360bizToursStatus(String targetPanoramaTourUrl){

        //再販対応 追加 Start
        if (!isUseAuthorityPanoramaTour){
            return; //権限がなければ処理を行わない
        }
        //再販対応 追加 End

        // パノラマツアーURLが設定されていなければ処理しない
        if(String.isEmpty(targetPanoramaTourUrl)){
            return;
        }

        // ツアー情報のセット
        List<String> targetPanoramaTourUrlList = new List<String>();
        targetPanoramaTourUrlList.add(targetPanoramaTourUrl);
        callTheta360bizToursStatus(targetPanoramaTourUrlList);
    }
    public static void callTheta360bizToursStatus(List<String> targetPanoramaTourUrlList){
        //再販対応 追加 Start
        if (!isUseAuthorityPanoramaTour){
            return; //権限がなければ処理を行わない
        }
        //再販対応 追加 End
        
        // おすすめ物件のパノラマツアーを非公開するAPIを実行
        String user_access_key_id = getTheta360bizAuthentications();
        
        // ツアー情報一覧を取得します。
        Map<String,JsonForGetTheta360biz.tours> toursMap = getTheta360bizTours(user_access_key_id);
        
        // 重複URL判定対象のおすすめ物件を取得
        List<RecommendProperty__c> recommendPropertyDuplicateUrlList = selectDuplicateRecommendPropertyURL(targetPanoramaTourUrlList);
        
        checkToursStatus(user_access_key_id,recommendPropertyDuplicateUrlList,targetPanoramaTourUrlList,toursMap);
    }

//************************************************************************** privateメソッド *************************************************************
    // THETA 360.biz Web API 認証情報の取得
    private static string getTheta360bizAuthentications(){

        // 認証情報を取得するAPIを実行
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.theta360.biz/authentications/' + THETA_360BIZ_API_ID); // ユーザIDあり
        request.setMethod('GET');        // 取得
        Http http = new Http();
        HttpResponse res = http.send(request);

        // レスポンス結果が正常になっていなければ終了する
        if(res.getStatusCode() != 201  && !Test.isRunningTest()){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_EXCEPTION,res.getBody()));
            throw ex;
        }
        JsonForGetTheta360biz Json = JsonForGetTheta360biz.parse(res.getBody());
        return Json.user_access_key_id;
    }

    // ツアー情報一覧を取得します。
    private static Map<String,JsonForGetTheta360biz.tours> getTheta360bizTours(String user_access_key_id){
        // ヘッダー情報のセットをする。
        String nowDateTime = DateTime.now().formatgmt('EEE, dd MMM yyyy HH:mm:ss z');
        String command = 'GET';
        String uripath = '/tours';

        // Httpリクエスト初期化
        string signature = setSignature(command,uriPath,nowDateTime);

        HttpRequest request = new HttpRequest();

        request.setMethod(command);        // GET
        request.setHeader('Date'            , nowDateTime);
        request.setHeader('Authorization'   , 'THETA360BIZ ' + user_access_key_id  + ':' + signature);
        request.setEndpoint('https://api.theta360.biz/tours');         // ツアー情報一覧を取得

        // Httpリクエスト送信
        Http http = new Http();
        HTTPResponse res = http.send(request);

        // レスポンス結果が正常になっていなければ終了する
        if(res.getStatusCode() != 200 ){
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst.MSG_COM_E_SYSTEM_EXCEPTION,'ツアー情報一覧を取得できませんでした。'));
            throw ex;
        }

        // 取れてきたツアーの情報をView URLをキーとしてMapに設定する。
        Map<String,JsonForGetTheta360biz.tours> toursMap = new Map<String, JsonForGetTheta360biz.tours>();
        JsonForGetTheta360biz Json = JsonForGetTheta360biz.parse(res.getBody());
        
        for(JsonForGetTheta360biz.tours tours : Json.tours){
            toursMap.put(tours.view_uri, tours);
        }
        return toursMap;
    }
    
    //  ツアー情報と一致するものを検出しツアー情報を非公開にする（その際、対象となるおすすめ物件のデータを取得する）
    private static List<RecommendProperty__c> checkToursStatus(String user_access_key_id,List<RecommendProperty__c> recommendPropertyDuplicateUrlList,List<RecommendProperty__c> recommendPropertylList, Map<String,JsonForGetTheta360biz.tours> toursMap){
        // 変更対象
        List<RecommendProperty__c> changeRecommendPropertylList = new List<RecommendProperty__c>();
        for(RecommendProperty__c RecommendProperty : recommendPropertylList){
            // URLが一致しなければデータをセットし次へ
            if(!toursMap.containsKey(RecommendProperty.PanoramaTourUrl__c)){
                changeRecommendPropertylList.add(setDisplayFlag(RecommendProperty.id));
                continue;
            }

            // 対象外でパノラマツアーURLがセットされていれば非公開にしない。
            if(checkPanoramaTourUrlDuplicate(recommendPropertyDuplicateUrlList,RecommendProperty.PanoramaTourUrl__c)){
                changeRecommendPropertylList.add(setDisplayFlag(RecommendProperty.id));
                continue;
            }

            // ツアーのステータスを更新
            if (!setTheta360bizToursStatus(user_access_key_id,toursMap.get(RecommendProperty.PanoramaTourUrl__c).id)){
                // 更新できなかった場合
                continue;
            }

            changeRecommendPropertylList.add(setDisplayFlag(RecommendProperty.id));
        }   
        return changeRecommendPropertylList;                
    }

    //  ツアー情報と一致するものを検出しツアー情報を非公開にする（その際、対象となるおすすめ物件のデータを取得する）
    private static void checkToursStatus(String user_access_key_id,List<RecommendProperty__c> recommendPropertyDuplicateUrlList,List<string> panoramaTourUrlList, Map<String,JsonForGetTheta360biz.tours> toursMap){

        for(String panoramaTourUrl : panoramaTourUrlList){
            // URLが一致しなければデータをセットし次へ
            if(!toursMap.containsKey(panoramaTourUrl)){
                continue;
            }

            // 対象外でパノラマツアーURLがセットされていれば非公開にしない。
            if(checkPanoramaTourUrlDuplicate(recommendPropertyDuplicateUrlList,panoramaTourUrl)){
                continue;
            }

            // ツアーのステータスを更新
            if (!setTheta360bizToursStatus(user_access_key_id,toursMap.get(panoramaTourUrl).id)){
                // 更新できなかった場合
                continue;
            }
        }           
    }

    // 表示フラグの更新データをセットする（表示フラグがTrueをFalseに変更する：パノラマツアーの有無に限らず）
    private static RecommendProperty__c setDisplayFlag(Id recommendPropertyId){
        return new RecommendProperty__c(
            Id = recommendPropertyId ,
            DisplayFlag__c = false
        );
    }

    // 対象のおすすめ物件のツアー情報を非公開にする。
    private static Boolean setTheta360bizToursStatus(String user_access_key_id,String toursId){
        String nowDateTime = DateTime.now().formatgmt('EEE, dd MMM yyyy HH:mm:ss z');
        String command = 'PUT';
        String uripath = '/tours/' + toursId + '/status';
        String signature = setSignature(command,uriPath,nowDateTime);


        HttpRequest request = new HttpRequest();
        request.setMethod(command);        // PUT
        request.setHeader('Date'            , nowDateTime);
        request.setHeader('Authorization'   , 'THETA360BIZ ' + user_access_key_id  + ':' + signature);
        request.setHeader('Content-Type'    , 'application/json');
        request.setBody('{"published": "false"}');                                              //更新内容（非公開：False）
        request.setEndpoint('https://api.theta360.biz/tours/' + toursId + '/status');           // 更新URL

        // Httpリクエスト送信
        Http http = new Http();
        HTTPResponse res = http.send(request);

        // レスポンス結果が正常になっていなければfalseを返す。
        if(res.getStatusCode() != 200 ){
            return false;
        }

        // 更新成功
        return true;
    }

    // 認証ヘッダ情報の生成
    private static String setSignature(String command,String uripath, String nowDateTime){
        // ヘッダー情報のセットをする。
        Url theta360 = new URL('https://api.theta360.biz');
        String host  = theta360.getHost();

        // Httpリクエスト初期化
        String Signature = getRestSignature(
            command
            ,host 
            ,uripath
            ,nowDateTime);

        return Signature;
    }

    // REST用のsignature作成
    private static String getRestSignature(
        String command
        ,String host
        ,String uripath
        ,String nowDateTime) {

        String stringToSign = command + '\n'
                            + host + '\n'
                            + EncodingUtil.urlEncode(uripath,'UTF-8') + '\n'
                            + nowDateTime;

        // 署名生成
        return EncodingUtil.base64Encode(Crypto.generateMac(
            'HmacSHA256', 
            Blob.valueOf(stringToSign),
            Blob.valueOf(THETA_360BIZ_API_ACCESSKEY)   // user_secret_access_key
        )).trim();

    }

    // パノラマツアーURL重複チェック
    private static Boolean checkPanoramaTourUrlDuplicate(List<RecommendProperty__c> recommendPropertyDuplicateUrlList,String panoramaTourUrl){
        
        for(RecommendProperty__c recommendPropertyDuplicateUrl : recommendPropertyDuplicateUrlList){
            // 公開状態のおすすめ物件のURLが他に存在している場合
            if(panoramaTourUrl == recommendPropertyDuplicateUrl.PanoramaTourUrl__c){
                // 重複あり
                return true;
            }
        }

        // 重複なし
        return false;

    }

    // おすすめ物件取得
    private static List<RecommendProperty__c> selectRecommendProperty(List<Id> recommendPropertyIdList){
        //おすすめ物件
        List<RecommendProperty__c> recoProp = [
            SELECT 
                Id,PanoramaTourUrl__c
            FROM 
            RecommendProperty__c
            WHERE Id In :recommendPropertyIdList
        ];

        return recoProp;
    }
    // おすすめ物件取得（対象おすすめ物件以外でURLが有る）
    private static List<RecommendProperty__c> selectDuplicateRecommendProperty(List<Id> recommendPropertyIdList){
        //おすすめ物件
        List<RecommendProperty__c> recoProp = [
            SELECT 
                Id,PanoramaTourUrl__c
            FROM 
            RecommendProperty__c
            WHERE Id Not In :recommendPropertyIdList
            AND   PanoramaTourRegister__c = :CommonConst_ptl.PANORAMA_TOUR_REGISTER_AVAILABLE
            AND   DisplayFlag__c = True
        ];

        return recoProp;
    }

    // おすすめ物件取得（対象おすすめ物件以外でURLが有る）
    private static List<RecommendProperty__c> selectDuplicateRecommendPropertyURL(List<String> panoramaTourUrlList){
        //おすすめ物件
        List<RecommendProperty__c> recoProp = [
            SELECT 
                Id,PanoramaTourUrl__c
            FROM 
            RecommendProperty__c
            WHERE PanoramaTourUrl__c In :panoramaTourUrlList
            AND   PanoramaTourRegister__c = :CommonConst_ptl.PANORAMA_TOUR_REGISTER_AVAILABLE
            AND   DisplayFlag__c = True
        ];

        return recoProp;
    }
}