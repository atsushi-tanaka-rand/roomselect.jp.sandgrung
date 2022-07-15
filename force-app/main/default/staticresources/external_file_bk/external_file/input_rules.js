
    
    /**
    入力規則の判定処理
    入力規則に合わせて対象の値を修正します。
    @param Target 入力規則を確認する対象の項目
    @param type 入力項目の型{text, textKana, number, currency, email, date, time, tel, postalCode, yearMonth}
    @param maxLength 最大文字数or数値の場合、整数部の最大桁数
    @param maxDecimalLength 数値の場合、小数部の最大桁数
    @param maxDecimalValue 数値の場合、最大値
    @param enabledCommaFormat 数値の場合、3桁「,」区切り有効設定（true:有効/false:無効）※デフォルト有効
    @param maxDecimalValue 数値の場合、最小値
    **/
    function correctInputRules(Target, type, maxLength, maxDecimalLength, maxDecimalValue, enabledCommaFormat, minDecimalValue ) {
        var myTarget = Target; // 入力規則を確認する対象の項目
        var myType = type; // 入力項目の型
        var myMaxLength = maxLength; // 最大文字数or数値の場合、整数部の最大桁数
        var myMaxDecimalLength = maxDecimalLength; // 数値の場合、小数部の最大桁数
        var myMaxDecimalValue = maxDecimalValue; // 数値の場合、最大値
        var myEnabledCommaFormat = true; // 数値の場合、3桁「,」区切り有効設定
        var myMinDecimalValue = minDecimalValue; // 数値の場合、最小値
        
        // 小数部の最大桁数が未設定の場合は0に設定する
        if(myMaxDecimalLength == ''){
            myMaxDecimalLength = 0;
        }
        
        // 3桁「,」区切り有効設定
        if(typeof(enabledCommaFormat) == 'boolean'){
            myEnabledCommaFormat = enabledCommaFormat;
        }
        
        if(myType == 'yearMonth'){
            // YYYYMMの年月用
            myTarget.value = toHalfWidth(myTarget.value); // 全角数字は半角数字に変換
            myTarget.value = setDateString(myTarget.value);
        }
        
        if(myType == 'number' || myType == 'currency' ){
            myTarget.value = toHalfWidth(myTarget.value); // 全角数字は半角数字に変換
            myTarget.value = setNumberString(myTarget.value, myMaxLength, myMaxDecimalLength); // 数値用の修正
            
            if(myTarget.value != ''){
                // 空白の場合は処理しない
                if(parseFloat(myTarget.value) > parseFloat(myMaxDecimalValue) && myMaxDecimalValue != ''){
                    // 数値の最大値が設定されていた場合、最大値以上は最大値に修正する
                    myTarget.value = myMaxDecimalValue;
                }
                if(parseFloat(myTarget.value) < parseFloat(myMinDecimalValue) && myMinDecimalValue != ''){
                    // 数値の最小値が設定されていた場合、最小値以下は最小値に修正する
                    myTarget.value = myMinDecimalValue;
                }
                
                // 3桁区切り用のフォーマット「Intl.NumberFormat」を使用
                var numberWithComma = new Intl.NumberFormat('ja-JP', {
                    maximumFractionDigits: myMaxDecimalLength // 使用する端数の最大数
                });
                
                // 3桁区切り用のフォーマットを適用する
                if(myEnabledCommaFormat){
                    myTarget.value =  numberWithComma.format(myTarget.value);
                }
            }
            
            if(myType == 'currency'){
                // 通貨用の処理
            }
        }
    if(myType == 'email'){
        // emailの最大文字数は固定で80
        myMaxLength = 80;
    }
    
    if(myType == 'tel'){
        // telの最大文字数は固定で40
        myMaxLength = 40;
        myTarget.value = toHalfWidth(myTarget.value); // 全角を半角に変換
        myTarget.value = setTelString(myTarget.value); // 電話用の修正
    }
    
    if(myType == 'textKana'){
        // ひらがなをカタカナに変換(カタカナ以外は削除)
        myTarget.value = setKanaString(myTarget.value); // カタカナ用の修正
    }
    
    if(myType == 'postalCode'){
        // postalCodeの最大文字数は固定で8
        myMaxLength = 8;
        myTarget.value = toHalfWidth(myTarget.value); // 全角数字は半角数字に変換
        myTarget.value = setPostalCodeString(myTarget.value); // 郵便番号用の修正
        
    }
    
    if( myType == 'text' || myType == 'textKana' || myType == 'email' || myType == 'tel' || myType == 'postalCode'){
        if(myTarget.value.length > myMaxLength){
            // 最大文字数以降の文字は削除
            myTarget.value = sliceMaxLength(myTarget.value, myMaxLength); // 最大文字数の修正
        }
    }
    }     
    
    /**
    最大文字数処理
    文字列を頭から最大文字数分までに修正します
    @param text  処理対象の文字列
    @param maxLength  最大文字数
    @return 修正した最大文字数分までの文字列
    **/
    function sliceMaxLength(text, maxLength) {
        // 文字列の頭から最大文字数まで切り取る
        return text.slice(0, maxLength) ;
    }
    
    /**
    カタカナ変換処理
    ひらがなをカタカナに変換し、それ以外の文字は削除します。
    @param text 変換対象の文字列
    @return 変換したカタカナの文字列
    **/
    function setKanaString(text) {
        // 正規表現とreplaceでひらがなをカタカナに置き換える(「ひらがな」の文字コードに「0x60」を足せば「カタカナ」に変換)
        text = text.replace(/[ぁ-ゖ]/g, function(s) {
            return String.fromCharCode(s.charCodeAt(0) + 0x60);
        });
        
        // 正規表現とreplaceでカタカナ、ハイフン、空白以外を削除する(「ひらがな」は「カタカナ」に変換済み)
        text = text.replace(/[^ァ-ヶー\s]/g, '');
        
        return text;
    }
    
    
    
    /**
    半角変換処理
    全角英数字と全角記号を半角に変換し、それ以外の文字は削除します。
    @param strVal 変換対象の文字列
    @return 変換した半角の文字列
    **/
    function toHalfWidth(strVal){
        // 半角変換
        var halfVal = strVal.replace(/[！-～]/g,
                                     function( tmpStr ) {
                                         // 文字コードをシフト
                                         return String.fromCharCode( tmpStr.charCodeAt(0) - 0xFEE0 );
                                     }
                                    );
        
        // 文字コードシフトで対応できない文字の変換
        halfVal = halfVal.replace(/”/g, "\"")
        .replace(/’/g, "'")
        .replace(/‘/g, "`")
        .replace(/￥/g, "\\")
        .replace(/　/g, " ")
        .replace(/〜/g, "~");
        
        
        // 正規表現とreplaceで半角以外を空白に置き換える(「全角英数字記号」は「半角」に変換済み)
        
        halfVal = halfVal.replace(/[^A-Za-z0-9!-~]/g, '');
        return halfVal;
    }
    
    /**
    電話の入力規則の判定処理
    入力規則に合わせて対象の値を修正します。
    @param text 入力規則を確認する対象の文字列
    @return 修正した電話の文字列
    **/
    function setTelString(text) {
        text = text.replace(/[^0-9-()]/g, ''); // 正規表現とreplaceで数字と「-」「(」「)」以外を排除
        
        // 文の先頭と末尾の1文字を取得
        var headText = text.slice(0,1);
        var endText =  text.slice(-1);
        
        // 先頭・末尾の「-」を排除する。先頭の「)」末尾の「(」を排除する。
        if( headText == '-' || headText == ')'){
            text = text.slice(1); // 文の先頭を削除
        }
        
        if( endText == '-' || endText == '(' ){
            text = text.slice(0,-1); // 文の末尾を削除
        }
        
        return text;
    }
    
    
    
    /**
    数値の入力規則の判定処理
    入力規則に合わせて対象の値を修正します。
    @param text 入力規則を確認する対象の文字列
    @param maxLength 整数部の最大桁数
    @param maxDecimalLength 小数部の最大桁数
    @return 修正した数値の文字列
    **/
    function setNumberString(text, maxLength, maxDecimalLength) {
        text = text.replace(/[^0-9-.]/g, ''); // 正規表現とreplaceで入力値から数字と「-」「.」以外を排除
        
        // 文の先頭と末尾の1文字を取得
        var headText = text.slice(0,1);
        var endText =  text.slice(-1);
        
        text = headText + text.slice(1).replace(/[-]/g, ''); // 先頭以外の「-」を排除
        
        var signText = ''; // 文の符号部分(「+」か「-」か)
        
        if(endText == '-'){
           // 末尾が「-」なら終了
           return '';
        }

        
        if(headText == '-'){
            // 文の符号が「-」の場合に符号を取得して文からは削除する
            signText = headText;
            text = text.slice(1);// 文の符号(文の先頭)を文から削除
            headText = text.slice(0,1);
        }
        
        
        if(headText == '.'){
            // 文の先頭が「.」の場合に文の先頭に0を追加する
            text = '0' + text;
            headText = text.slice(0,1);
        }
        
        if(endText == '.'){
            // 末尾が「.」なら取り除く
            text = text.slice(0, -1);
            endText = text.slice(-1);
        }
        
        var splitText =  text.split('.'); // 文を「.」ごとに区切る
        
        var integerText = ''; // 文の整数部分
        var decimalText = ''; // 文の小数部分
        
        if(splitText.length > 0){
            integerText = splitText[0];
            
            if(splitText.length > 1){
                for(var i = 1 ; i < splitText.length ;){
                    // 文の小数部分を「.」なしで1つの変数に格納する(「.」が2つ以上存在する場合2つ目以降を排除)
                    decimalText += splitText[i];
                    i++;
                }
            }
            
            if(integerText.length > maxLength){
                // 整数部が最大桁数を超える場合は最大値とする
                integerText = '';
                integerText = paddingRight('','9',maxLength) // 整数部を最大桁数分「9」で埋める
            }
            
            if(decimalText.length > maxDecimalLength){
                // 小数部が最大桁数を超える場合収まるように四捨五入する
                var beforDecimal = decimalText.slice(0,maxDecimalLength); // 小数部の最大桁数までの値
                var afterDecimal = decimalText.slice(maxDecimalLength); // 小数部の最大桁数以降の値
                
                var CorrectionTargetDecimal = beforDecimal + '.' + afterDecimal;
                
                decimalText = Math.round(CorrectionTargetDecimal); // 「.」以降を四捨五入する
                
            }
            
            if(decimalText == ''){
                text = signText + integerText; // 符号、整数部を繋げる
            }else{
                text = signText + integerText + '.' + decimalText; // 符号、整数部、小数部を繋げる
            }
            
            // -0 対応
            if (text == '-0') {
                text = '0';
            }
        }
        
        return text;
    }
    
    /**
    右埋めする処理
    指定桁数になるまで対象文字列の右側に
    指定された文字を埋めます。
    @param val 右埋め対象文字列
    @param char 埋める文字
    @param n 指定桁数
    @return 右埋めした文字列
    **/
    function paddingRight(val,char,n){
        for(; val.length < n; val+=char);
        return val;
    }
    
    /**
    左埋めする処理
    指定桁数になるまで対象文字列の左側に
    指定された文字を埋めます。
    @param val 左埋め対象文字列
    @param char 埋める文字
    @param n 指定桁数
    @return 左埋めした文字列
    **/
    function paddingLeft(val,char,n){
        for(; val.length < n; char+=val);
        return val;
    }
    
    
    /**
    郵便番号の入力規則の判定処理
    入力規則に合わせて対象の値を修正します。
    @param text 入力規則を確認する対象の文字列
    @return 修正した郵便番号の文字列
    **/
    function setPostalCodeString(text){
        text = text.replace(/[^0-9-]/g, ''); // 正規表現とreplaceで数字と「-」以外を排除
        
        var firstHyphen = text.search( /[-]/ ); // 文内で一番最初の「-」があるのが何文字目か
        
        // 文を3つの変数に分ける
        var leftText = ''; // 「-」の左側の文
        var middleText = ''; // 「-」の文
        var rightText = ''; // 「-」の右側の文
        
        var templateText = text; // 修正を行う文
        
        if(firstHyphen >= 0){
            // 文内に「-」がある場合
            leftText = text.slice(0,firstHyphen);
            middleText = text.charAt(firstHyphen);
            rightText =  text.slice(firstHyphen+1);
            
            rightText = rightText.replace(/[-]/g, ''); // 正規表現とreplaceで一つ目以外のハイフンを排除する
            
            if(firstHyphen != 3){
                //一つ目の「-」が、文の4文字目以外なら排除
                middleText = '';
            }
            templateText = leftText + middleText + rightText;
        }
        
        if(templateText.length >= 4 && middleText == ''){
            // 文が4文字以上かつ「-」がない場合
            leftText = templateText.slice(0,3);
            middleText = '-'; // 4文字目に「-」を挿入する
            rightText =  templateText.slice(3);
            
            templateText = leftText + middleText + rightText;
        }
        
        text = templateText;
        
        return text;
    }
    
    
    /**
    日付(YYYYMM)の入力規則の判定処理
    入力規則に合わせて対象の値を修正します。
    @param text 入力規則を確認する対象の文字列
    @return 修正したYYYYMMの文字列
    **/
    function setDateString(text) {
        text = text.replace(/[^0-9]/g, ''); // 正規表現とreplaceで数字以外を排除
        
        // 数字6文字(YYYYMM)かどうか
        if(text.length != 6){
            text = '';
            
        }else{
            // YYYYMMのMM部分が1月～12月の間かどうか
            if(text.slice(4) >= 1 && text.slice(4) <= 12){
                return text;
            }        
            text = '';
        }
        
        return text;
    }
    