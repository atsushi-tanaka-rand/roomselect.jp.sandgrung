//物件登録画面 の 部屋明細モーダル
public class GA104006Modal1Controller {

    public GA104006Modal1ParameterClass parameter { get; set; } // 
    public ModalScreenRecord screenRecord { get; set; }         // 画面用の項目

    public Boolean isOpenError { get; set; }        // 画面遷移時のエラーフラグ
    public Boolean hasErrorMessage { get; set; }    // エラーメッセージ保有フラグ

    // 部屋タイプ表示用
    private List<SelectOption> selectRoomTypeList { get; set; } // 部屋タイプ
    public List<String> roomTypeValueList { get; set; }         // 部屋タイプ選択リスト（値）
    public Map<String, String> roomTypeNameList { get; set; }   // 部屋タイプ選択リスト（値、表示名）
    public Map<String, Boolean> roomTypeCheckList { get; set; } // 部屋タイプチェック状態（値、チェック）

    // ページの初期表示処理実行用
    public Boolean init {
        get {
            if (this.parameter.isDrawing) {
                initAction();
                this.parameter.isDrawing = false;
                return false;
            }
            return true;
        }
    }

    // コンストラクタ
    public GA104006Modal1Controller() {
    }

    // ページの初期表示の具体的な処理
    public void initAction(){
        try{
            // 初期化
            this.isOpenError = false;
            this.hasErrorMessage = false;

            // パラメータから画面項目を設定
            this.screenRecord = new ModalScreenRecord(this.parameter.targetRoom);

            // 部屋タイプの選択リスト内容取得
            this.selectRoomTypeList = CommonUtil.getSelectOptionFromObject('Room__c', 'RoomType__c', false);

            // 部屋タイプ表示用のList,Map設定
            this.roomTypeValueList = new List<String>();
            this.roomTypeNameList = new Map<String, String>();
            this.roomTypeCheckList = new Map<String, Boolean>();
            for (SelectOption roomType : this.selectRoomTypeList) {
                String value = roomType.getValue();
                String label = roomType.getLabel();
                this.roomTypeValueList.add(value);
                this.roomTypeNameList.put(value,label);
                this.roomTypeCheckList.put(value,false);
            }
            if (this.roomTypeNameList.containsKey(this.screenRecord.RoomType)) {
                this.roomTypeCheckList.put(this.screenRecord.RoomType,true);
            }

        } catch (Exception e) {
            this.isOpenError = true;
            CommonUtil.setErrorMessage(e);
        }
    }

    // 登録ボタン押下時処理
    public void closeModal() {
        try{
            this.hasErrorMessage = false;
            BusinessLogicException ex = new BusinessLogicException();

            //画面をパラメータに連携
            this.parameter.targetRoom.Id                = this.screenRecord.Id;
            this.parameter.targetRoom.Property__c       = this.screenRecord.PropertyId;
            this.parameter.targetRoom.RoomFloorSpace__c = CommonUtil.stringToDecimal(this.screenRecord.RoomFloorSpace);
            this.screenRecord.RoomType = null;
            for (String roomType : this.roomTypeValueList) {
                if (this.roomTypeCheckList.get(roomType)) {
                    this.screenRecord.RoomType = roomType;
                }
            }
            parameter.targetRoom.RoomType__c            = this.screenRecord.RoomType;

        } catch (Exception e) {
            this.hasErrorMessage = true; //エラーを設定
            CommonUtil.setErrorMessage(e);
        }
    }

    // 画面表示用クラス
    public class ModalScreenRecord {
        public Id Id { get; set; }                  // Id
        public Id PropertyId { get; set; }          // 物件Id
        public String RoomFloorSpace { get; set; }  // 部屋帖数
        public String RoomType { get; set; }        // 部屋タイプ
        public ModalScreenRecord(Room__c room) {
            this.Id             = room.Id;
            this.PropertyId     = room.Property__c;
            this.RoomFloorSpace = CommonUtil.decimalToString(room.RoomFloorSpace__c);
            this.RoomType       = room.RoomType__c;
        }
    }

}