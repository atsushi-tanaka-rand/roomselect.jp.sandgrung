/** 
 *入力規則用例外クラス
 */
public class BusinessLogicException extends Exception {
    //エラーメッセージ格納変数
    public List<String> errMessage;
    
    //リストにメッセージを格納するメソッド
    public void addMessage(String message){
        if (this.errMessage == null){
            this.errMessage = new List<String>();
        }
        this.errMessage.add(message);
    }
    
    //メッセージの有無を判定するメソッド
    public Boolean hasMessage(){
        Boolean hasMessage = false;
        //エラーメッセージがない場合
        if (this.errMessage == null){          
            return false;
        }
        
        //メッセージが1つ以上あればTRUE
        if (this.errMessage.size() > 0)
        {
            hasMessage = true;
        }
        return hasMessage;
    }
}