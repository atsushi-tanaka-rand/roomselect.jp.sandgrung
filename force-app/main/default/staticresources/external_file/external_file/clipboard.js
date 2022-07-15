/**
 * クリップボード書き込みクラス
 */
function ClipBoard(){
    
    this._successMsg = "クリップボードにコピーしました。";
    this._errorMsg   = "クリップボードのコピーに失敗しました。";
    
    this.setClipBoard = function(string){
        let _this = this;
        return new Promise(function (resolve, reject) {
            // 改行
            string = string.replace(/<br>/g,'\r\n');
            // 空div 生成
            var tmp = document.createElement("div");
            // 選択用のタグ生成
            var pre = document.createElement('pre');
            // 親要素のCSSで user-select: none だとコピーできないので書き換える
            pre.style.webkitUserSelect = 'auto';
            pre.style.userSelect = 'auto';
            console.log(string);
            tmp.appendChild(pre).textContent = string;
            // 要素を画面外へ
            var s = tmp.style;
            s.position = 'fixed';
            s.right = '200%';
            
            // body に追加
            document.body.appendChild(tmp);
            // 要素を選択
            document.getSelection().selectAllChildren(tmp);
            
            // クリップボードにコピー
            var result = document.execCommand("copy");
            
            // 要素削除
            document.body.removeChild(tmp);
            
            if(result){
                resolve(_this._successMsg);
            }else{
                reject(new Error(_this._errorMsg));
            }
        });
    }
    /**
     * @param ペーストする文字列 
     * @return 結果 
     */                
    ClipBoard.prototype.writeText = function(text){
        // クリップボード貼り付け処理をコールする
        return this.setClipBoard(text);
    }
}