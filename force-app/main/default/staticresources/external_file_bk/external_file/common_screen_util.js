
    
    /**
     ページ遷移
     引数に対応した方法でページ遷移を行います。
     @param pageName 遷移先のページ名
     @param target 遷移方法{'_self', '', '_blank'}
     @param hasHeader ヘッダーがあるか(TRUEかそれ以外かで判定){'TRUE', 'true'}
     @param param パラメータ
    **/
     function showPage(pageName, target, hasHeader, param) {
        // URLにパラメータを付与
        // パラメータはURL末尾に「？」を付けて、その直後に「パラメータ名＝パラメータ値」といった形式で設定
        // 2つ目以降のパラメータは「&」で区切って設定
        
        var url;
        
        var isApp;
        
        if(isApplication()){
            // アプリ版の場合
            isApp = 'true';
        }
        
        //▼問合せNo0567で変更
        // if(hasHeader.toLowerCase() != 'true' && !isApp){
        if(hasHeader.toLowerCase() != 'true' || isApp ){
            // hasHeaderがtrue以外の場合かアプリ版の場合
            //▲問合せNo0567で変更
            url =  '/apex/';
        } else {
            url =  '/one/one.app#/alohaRedirect/apex/';
        }
        
        url += pageName;
        
        // パラメータを設定
        url += '?' + param;
        
        var getTarget = target; // ページの開き方(現ページ、新規タブ、新規ウィンドウ)
        var windowSet = ''; // 画面遷移方法が新規ウィンドウの場合の、オプション設定
        
        // 画面遷移方法が新規ウィンドウの場合に、ウィンドウの高さと幅を設定
        if(getTarget == '_blank'){
            windowSet = 'width=5000,height=5000';
        }      
        
        // アプリ版かどうかを判定
        if(isApp){
            // 画面遷移 アプリ版用
            sforce.one.navigateToURL(url);
        }else{
            // 画面遷移
            // window.open([url],[windowName],[option])
            // [windowName]は新規ウィンドウ('_blank'),新規タブ(''),同ページ('_self')と画面遷移方法を設定
            // [option]は新規ウィンドウを開いた場合のウィンドウの高さや幅を設定
            window.open(url, getTarget, windowSet);
        }
    }
    
    
    /**
    ページを閉じる
    ページ遷移で開いたページを閉じます。
    **/
    function closePage(){
        if(isApplication()){
            // アプリ版用 戻る
            sforce.one.back(true);
        }else{
            //閉じる
            window.open('','_top').close();
        }
    }   
    
    /**
    画面スクロール
    クラス名を指定することで、スクロールします
    toClassには、'.item_section'のような形式でクラスを記載します。
    **/
    function scrollToClass(toClass) {
    
        var n = window.location.href.slice(window.location.href.indexOf('?') + 4);
    
        var p = $(toClass).offset().top;
        $('html,body').animate({ scrollTop: p }, 'slow');
        return false;
    }
    
    /**
    アプリケーション判定
    ページをブラウザから閲覧しているか、アプリケーションで閲覧しているかを判定します。
    @return boolean アプリケーションの場合true、アプリケーション場合なにも返さない
    **/
    function isApplication(){                           
        
        //「/」で区切って分割する
        // ユーザの使用ブラウザ情報を「/」で区切って分割する
        var userAgent = window.navigator.userAgent.toLowerCase().split('/');
        
        // アプリケーションの場合trueを返す
        if(userAgent[0] == 'salesforcemobilesdk'){
            return true;
        }  
    }
    
    
    
    //メッセージ用：ページ最上部に移動
    function gotoTop(){
        $(window).scrollTop(0);
    }
    
    
    //blockUI
    function blockUi() {
        $.blockUI({message: '<img src="/img/loading32.gif" /><h1> Loading...</h1>',
              css: {
                  border: 'none',
                  padding: '15px',
                  backgroundColor: '#FFF',
                  '-webkit-border-radius': '10px',
                  'border-radius': '10px',
                  opacity: 1,
                  color: '#000'
              }
         });
    }
        
        
    //UnblockUI
    function unblockUi() {
        $.unblockUI();
    }
    
    
    //チェックボックス（apex:repeat内）変更時の単一選択処理
    function onchangeListCheckBoxSingleSelect(CheckObject) {
        // Idの最終階層を取得
        var id = CheckObject.id.split(':');
        var searchId = id[id.length-1];
        // 同一リスト内の同Idチェックボックス取得
        var td = $(CheckObject).parent();
        var tr = td.parent();
        var tbody = tr.parent();
        var checkList = tbody.find('input[id$="'+searchId+'"]');
        // 選択変更したチェックボックス以外を未選択に変更
        for (var i=0; i < checkList.length; i++) {
            if (checkList[i].id!=CheckObject.id) {
                checkList[i].checked = false;
            }
        }
    }
    
    
    //チェックボックス ヘッダ行のチェックボックスが操作された際の処理
    function listCheckBoxAllChange(obj, headerCheckboxClass, childCheckboxClass){
        //対象の値を取得
        var flag = $(obj).prop('checked');
        //親要素(table)の配下にあるチェックボックス(.check)の値を操作
        $(obj).closest('table').find(childCheckboxClass).prop('checked',flag);
    }
    
    
    //チェックボックス チェックボックスの値がfalseに変更された場合に、ヘッダ行のチェックボックスの値を操作
    function headCheckBoxChange(obj, headerCheckboxClass, childCheckboxClass){
        //対象の値を取得
        var flag = $(obj).prop('checked');
        
        //ヘッダの値を変更
        if (!flag) {
            $(headerCheckboxClass).prop('checked',false);
        } else {
        
            //全てtrueならtrueに変更
            var isAllTrue = true;
            $(childCheckboxClass).each(function(){
                var childValue = $(this).prop('checked');
                if (!childValue) {
                    isAllTrue = false;
                }
            });
            
            if (isAllTrue) {
                $(headerCheckboxClass).prop('checked',true);
            }
        }
    }
    
    
    //入力検証エラー値のクリア
    function clearValidateErrorValue(input) {
        if (!input.checkValidity()) {
            input.value = '';
        }
        // 日付入力項目のフォーカス制御中の場合、falseを返却します。
        if (isDateInputKeydownFocusAdjust == true) {
            return false;
        }
        return true;
    }
    
    
    // 確認ダイアログを表示
    async function showConfirm(message) {
        var promise = new Promise(function(resolve, reject) {
            
            
            // Dialogを破棄する関数
            var _destroyDialog = async function(dialogElement) {
                dialogElement.dialog('destroy'); // ※destroyなので、closeイベントは発生しない
                dialogElement.remove(); // ※動的に生成された要素を削除する必要がある
            };
            
            // Dialog要素(呼び出し毎に、動的に生成)
            var $dialog = $('<div></div>').text(message);
            
            // 各ボタンに対応する関数を宣言
            // ※Dialogを破棄後、コールバック関数を実行する
            var _funcOk     = function() {
                _destroyDialog($dialog);
                resolve(true);
            };
            
            var _funcCancel = function() { 
                _destroyDialog($dialog);
                resolve(false);
            };
            
            // モーダル幅の設定用（iphone用）
            var clientWidth = 0; 
            if(document.body.clientWidth > 600){
                clientWidth = 600;
            }else{
                clientWidth = document.body.clientWidth;
            }
            
            //動的にダイアログを生成
            $dialog.dialog({
                modal: true,
                title: '',
                width:  clientWidth,
                height: 200,
                
                // 「閉じる」の設定
                // ※Cancel時の処理を「閉じる」に仕込むことで、Cancelと「閉じる」を同一の挙動とする
                closeText: 'Cancel',
                closeOnEscape: true,
                close: _funcCancel,
                
                // 各ボタンの設定
                buttons: [
                    { text: 'OK',     click: _funcOk },
                    { text: 'Cancel', click: function() { $(this).dialog('close'); } } // Dialogのcloseのみ
                ]
            });
        });
        return promise;
    }
    
    //▼問合せNo0549で追加
    /**
     確認ダイアログを表示
     ×ボタンとCancelのボタン押下でパラメータを分ける
     @param message ダイアログの文言
     @param OKButtonText OKボタンの文言（引数無：OK）
     @param cancelButtonText Cancelボタンの文言（引数無：Cancel）
     @param param Integer 1:OK、2:Cancel、0:×による閉じる
    **/
    async function showConfirmCloseMultiple(message,OKButtonText = 'OK',cancelButtonText = 'Cancel') {
        var promise = new Promise(function(resolve, reject) {
            
            // Dialogを破棄する関数
            var _destroyDialog = async function(dialogElement) {
                dialogElement.dialog('destroy'); // ※destroyなので、closeイベントは発生しない
                dialogElement.remove(); // ※動的に生成された要素を削除する必要がある
            };
            
            // Dialog要素(呼び出し毎に、動的に生成)
            var $dialog = $('<div></div>').text(message);
            // ダイアログ押下の戻り値
            let buttonflg = 0;
            // 各ボタンに対応する関数を宣言
            // ※Dialogを破棄後、コールバック関数を実行する
            var _funcOk     = function() {
                buttonflg = 1;
                _destroyDialog($dialog);
                resolve(buttonflg);
            };
            
            var _funcCancel = function() { 
                _destroyDialog($dialog);
                resolve(buttonflg);
            };
            
            // モーダル幅の設定用（iphone用）
            var clientWidth = 0; 
            if(document.body.clientWidth > 600){
                clientWidth = 600;
            }else{
                clientWidth = document.body.clientWidth;
            }
            
            //動的にダイアログを生成
            $dialog.dialog({
                modal: true,
                title: '',
                width:  clientWidth,
                height: 200,
                
                // 「閉じる」の設定
                // ※Cancel時の処理を「閉じる」に仕込むことで、Cancelと「閉じる」を同一の挙動とする
                closeText: 'Cancel',
                closeOnEscape: true,
                close: _funcCancel,
                
                // 各ボタンの設定
                buttons: [
                    { text: OKButtonText,     click: _funcOk },
                    { text: cancelButtonText, click: function() { buttonflg = 2; $(this).dialog('close'); } } // Dialogのcloseのみ
                ]
            });
        });
        return promise;
    }
    //▲問合せNo0549で追加
    
    
    
    // 通知ダイアログを表示
    async function showAlert(message) {
        var promise = new Promise(function(resolve, reject) {
            
            
            // Dialogを破棄する関数
            var _destroyDialog = async function(dialogElement) {
                dialogElement.dialog('destroy'); // ※destroyなので、closeイベントは発生しない
                dialogElement.remove(); // ※動的に生成された要素を削除する必要がある
            };
            
            // Dialog要素(呼び出し毎に、動的に生成)
            var $dialog = $('<div></div>').text(message);
            
            // 各ボタンに対応する関数を宣言
            // ※Dialogを破棄後、コールバック関数を実行する
            var _funcOk     = function() {
                _destroyDialog($dialog);
                resolve(true);
            };
            
            // モーダル幅の設定用（iphone用）
            var clientWidth = 0; 
            if(document.body.clientWidth > 600){
                clientWidth = 600;
            }else{
                clientWidth = document.body.clientWidth;
            }
            
            //動的にダイアログを生成
            $dialog.dialog({
                modal: true,
                title: '',
                width:  clientWidth,
                height: 200,
                
                // 「閉じる」の設定
                // ※OK時の処理を「閉じる」に仕込む
                closeText: 'Cancel',
                closeOnEscape: true,
                close: _funcOk,   
                
                // 各ボタンの設定
                buttons: [
                    { text: 'OK',     click: _funcOk },
                ]
            });
        });
        return promise;
    }
    
    // 通知ダイアログを表示（タグ埋め込み可）
    async function showAlert2(message) {
        let promise = new Promise(function(resolve, reject) {
            
            // Dialogを破棄する関数
            let _destroyDialog = async function(dialogElement) {
                dialogElement.dialog('destroy'); // ※destroyなので、closeイベントは発生しない
                dialogElement.remove(); // ※動的に生成された要素を削除する必要がある
            };
            
            // Dialog要素(呼び出し毎に、動的に生成)
            let $dialog = $('<div class="show-alert-height"></div>').html(message);
            
            // 各ボタンに対応する関数を宣言
            // ※Dialogを破棄後、コールバック関数を実行する
            let _funcOk     = function() {
                _destroyDialog($dialog);
                resolve(true);
            };
            
            // モーダル幅の設定用（iphone用）
            let clientWidth = 0; 
            if(document.body.clientWidth > 600){
                clientWidth = 600;
            }else{
                clientWidth = document.body.clientWidth;
            }
            
            //動的にダイアログを生成
            $dialog.dialog({
                modal: true,
                title: '',
                width:  clientWidth,
                
                // 「閉じる」の設定
                // ※OK時の処理を「閉じる」に仕込む
                closeText: 'Cancel',
                closeOnEscape: true,
                close: _funcOk,   
                
                // 各ボタンの設定
                buttons: [
                    { text: 'OK',     click: _funcOk },
                ]
            });
        });
        return promise;
    }
    
    var isDateInputKeydownFocusAdjust = false;  // 日付フォーカス制御中フラグ
    // 日付入力項目用フォーカス制御処理（keydown時実行）
    function dateInputKeydownFocusAdjust(element, event) {
        
        // 全角入力された場合、フォーカスを他項目に移動しないようにする。
        if (event.keyCode == 229) {
            
            // ダミー要素を（無ければ）作成し日付入力項目の同階層に追加
            var dmyExists = element.parentElement.querySelectorAll('[id="dateInputKeydownFocusAdjustDmy"]');
            var dmy;
            if (dmyExists.length == 0) {
                dmy = document.createElement('input');
                dmy.setAttribute('id', 'dateInputKeydownFocusAdjustDmy');
                dmy.setAttribute('type', 'text');
                dmy.setAttribute('style', 'opacity: 0; width: 0px; height: 0px; position: absolute; top: 0px; left: 0px');  // 透明,幅・高さ0,親要素の左上に絶対位置指定配置
                dmy.setAttribute('tabIndex', '-1');
                element.parentElement.appendChild(dmy);
                element.parentElement.classList.add('inputDateDummyParent');
            } else {
                dmy = dmyExists[0];
            }
            
            // フォーカスをダミー要素経由であて直す
            isDateInputKeydownFocusAdjust = true;
            dmy.focus();
            setTimeout(() => element.focus(), 1);
            //dmy.parentNode.removeChild(dmy);
            isDateInputKeydownFocusAdjust = false;
            
        }
    }
    
    
    // テーブル列移動処理群
    var dragTableId;        // 処理テーブル
    var dragColIndex = -1;  // 処理列番号
    // 列移動処理
    function moveColmun(table, fromIndex, toIndex) {
        var rows = jQuery('tr', table);
        var cols;
        rows.each(function() {
            cols = jQuery(this).children('th, td');
            if (fromIndex > toIndex) {
                cols.eq(fromIndex).detach().insertBefore(cols.eq(toIndex));
            } else {
                cols.eq(fromIndex).detach().insertAfter(cols.eq(toIndex));
            }
            
        });
    }
    // 列移動処理の呼出しイベント設定
    function setDraggableTable(tableId) {
        var draggableTable = document.getElementById(tableId);
        // ドラッグ開始処理作成
        var colDragStart = function(e) {
            var el = e.target;
            if (el.tagName != 'TH') {
                return;
            }
            // ドラッグ列の番号を退避
            dragTableId = draggableTable.id;
            dragColIndex = el.cellIndex;
        }
        // ドラッグ時処理作成
        var colDragover = function(e) {
            // ドロップ可能設定
            e.preventDefault();
        }
        // ドロップ時処理作成
        var colDragEnd = function(e) {
            var el = this;
            if (el.tagName != 'TH') {
                return;
            }
            // ドラッグとドロップがテーブルの場合、処理中止
            if (dragTableId != getTableFromTh(e.currentTarget).id) {
                return;
            }
            // ドロップ列の番号取得
            var dragToIndex = el.cellIndex;
            // ドラッグとドロップが同一列、列番号が不正の場合、処理中止
            if (dragColIndex == dragToIndex || dragColIndex < 0 || dragToIndex < 0) {
                return;
            }
            // ドラッグ列をドロップ列の前に移動
            moveColmun(draggableTable, dragColIndex, dragToIndex);
        }
        // 以下列ヘッダ設定
        var cols = $(draggableTable).find('th');
        // id設定
        var i=0;
        cols.each(function() {
            this.id = draggableTable.id + 'TH' + (i + 1);
            i++;
        });
        $(cols).prop('draggable', true);
        // ドラッグ可能化
        $(cols).prop('draggable', true);
        // 各イベントを紐づけ
        cols.on('dragstart', colDragStart);
        cols.on('dragover', colDragover);
        cols.on('drop', colDragEnd);
    }
    // th指定でtable要素取得
    function getTableFromTh(el) {
        var temp = el.parentElement;
        for (var i=0; i<10; i++) {
            if (temp.tagName == 'TABLE') {
                return temp;
            }
            temp = temp.parentElement;
        }
        return null;
    }
    
    
    // テーブルソート処理群
    var sortOrderImageSrc;
    // ソート処理の呼出しイベント設定
    function setSortableTable(tableId, defaultSortOrder) {
    
        // 対象テーブル取得
        var sortableTable = document.getElementById(tableId);
    
        // デフォルトソート形式取得（指定がなければ昇順とする）
        defaultSortOrder = [null, ''].includes(defaultSortOrder) ? '1' : defaultSortOrder;
        defaultSortOrder = ['1', '-1'].includes(defaultSortOrder) ? defaultSortOrder : '1';
    
        // 連動ソートテーブルId取得
        var linkTableIds = '';
        if (sortableTable.hasAttribute('data-sortLinkTableIds')) {
            linkTableIds = sortableTable.getAttribute('data-sortLinkTableIds');
        }
    
        // クリック処理作成
        var colClick = function(e) {
            //blockUi();
            // ソート列の番号取得
            var sortColIndex = this.cellIndex;
            // ソート形式（昇順/降順）の取得
            var sortOrder = Number(this.getAttribute('data-sortOrder'));
            // ソート型の取得（指定がない場合、文字列）
            var sortType = this.getAttribute('data-sortType');
            sortType = [null, ''].includes(sortType) ? 'string' : sortType.toLowerCase();
            // ソート実行
            sortRows(this, sortableTable, sortColIndex, sortOrder, sortType);
            // ソート形式の切替（昇順<=>降順）
            this.setAttribute('data-sortOrder', sortOrder * -1);
            //unblockUi();
        }
    
        // 各行のtr要素に初期行index設定 ※ヘッダ行（1行目）を除く
        var rows = $(sortableTable).find('tr');
        rows = rows.slice(1, rows.length);
        rows.each(function(index) {
            this.setAttribute('data-initRowIndex', index);
        });
    
        // 連動テーブルを取得
        var linkTableIdList = [null, ''].includes(linkTableIds) ? [] : linkTableIds.split(',');
        // 連動テーブルに初期行indexを設定 ※ヘッダ行（1行目）を除く
        $(linkTableIdList).each(function() {
            // 連動テーブル取得
            var linkSortTable = document.getElementById(this.trim());
            var linkRows = $(linkSortTable).find('tr');
            linkRows = linkRows.slice(1, linkRows.length);
            linkRows.each(function(index) {
                this.setAttribute('data-initRowIndex', index);
            });
        });
    
        // 以下列ヘッダ設定
        var cols = $(sortableTable).find('th');
        cols.each(function() {
            // ソート形式（昇順/降順）の設定
            //  指定なしと1,-1以外をデフォルト値とする
            if (!this.hasAttribute('data-sortOrder') || !['1', '-1'].includes(this.getAttribute('data-sortOrder'))) {
                this.setAttribute('data-sortOrder', defaultSortOrder);
            }
            // ソート形式の初期状態を保持しておく
            this.setAttribute('data-initSortOrder', this.getAttribute('data-sortOrder'));
            // クリックイベントを紐づけ（ソートしない設定された列は除く）
            var colSotable = this.getAttribute('data-colSortable');
            colSotable = [null, ''].includes(colSotable) ? '' : colSotable.toLowerCase();
            if (colSotable != 'false') {
                $(this).on('click', colClick);
            }
            // ソート状態画像初期化 class「sortOrderImage」が設定された列のみ
            var sortOrderImg = $(this).find('.sortOrderImage');
            if (sortOrderImg.length > 0) {
                if (!this.hasAttribute('data-initSortOrderImageKey') || !['1', '0', '-1'].includes(this.getAttribute('data-initSortOrderImageKey'))) {
                    $(sortOrderImg).prop('src', sortOrderImageSrc.get(0));
                } else {
                    // 初期値の指定がされている場合その画像を表示する
                    $(sortOrderImg).prop('src', sortOrderImageSrc.get(Number(this.getAttribute('data-initSortOrderImageKey'))));
                }
            }
        });
    
        // 初期ソートを行う（指定がある場合）
        cols.each(function() {
            if (this.hasAttribute('data-initSort') || ['1', '-1'].includes(this.getAttribute('data-initSort'))) {
                // ソート列の番号取得
                var sortColIndex = this.cellIndex;
                // ソート形式（昇順/降順）の取得
                var sortOrder = Number(this.getAttribute('data-initSort'));
                // ソート型の取得（指定がない場合、文字列）
                var sortType = this.getAttribute('data-sortType');
                sortType = [null, ''].includes(sortType) ? 'string' : sortType.toLowerCase();
                // ソート実行
                sortRows(this, sortableTable, sortColIndex, sortOrder, sortType);
                // ソート形式の切替（昇順<=>降順）
                this.setAttribute('data-sortOrder', sortOrder * -1);
            }
        });
    
    }
    // ソート処理
    function sortRows(th, sortTable, sortColIndex, sortOrder, sortType, tableId) {
        // テーブル全行取得 ※ヘッダ行（1行目）を除く
        var rows = $(sortTable).find('tr');
        rows = rows.slice(1, rows.length);
    
        // ソート実行
        sortType = [null, ''].includes(sortType) ? '' : sortType.toLowerCase();
        rows.sort(function(a, b) {
            return sortCompare(a, b, sortColIndex, sortType, sortOrder);
        });
    
        // 並び変えた行を配置し直す
        var body = $(sortTable).children('tbody');
        if (body.length >= 2) {
            $(sortTable).children('tbody').eq(body.length-1).append(rows.detach());
        } else {
            $(sortTable).children('tbody').append(rows.detach());
        }
    
        // 連動テーブルを取得
        var linkTableIds = sortTable.getAttribute('data-sortLinkTableIds');
        var linkTableIdList = [null, ''].includes(linkTableIds) ? [] : linkTableIds.split(',');
    
        // 連動テーブル設定がされている場合、行ソート順を同期させる
        if (linkTableIdList.length > 0) {
            // ソート後の初期行indexを配列化
            var sortIndexSet = [];
            rows.each(function(index) {
                sortIndexSet.push(Number(this.getAttribute('data-initRowIndex')));
            });
    
            // 連動テーブルにソートをかける
            $(linkTableIdList).each(function() {
                // 連動テーブル取得
                var linkSortTable = document.getElementById(this.trim());
                // 行ソート
                linkSortFromIndex(linkSortTable, sortIndexSet);
            });
        }
    
        var cols = $(sortTable).find('th');
        var rowNumberColIndexs = [];
        var resettingRowNumberColIndexs = [];
        $(cols).each(function() {
            // ソート形式の初期化
            this.setAttribute('data-sortOrder', this.getAttribute('data-initSortOrder'));
            // 行番号の列取得
            if (this.hasAttribute('data-rowNumberCol')) {
                rowNumberColIndexs.push(this.cellIndex);
            }
            // 行番号項目再セット列取得
            if (this.hasAttribute('data-resettingRowNumberCol')) {
                resettingRowNumberColIndexs.push(this.cellIndex);
            }
        });
        // 行番号列の内容設定
        if (rowNumberColIndexs.length > 0) {
            rows.each(function(index) {
                for (var i=0; i < rowNumberColIndexs.length; i++) {
                    $(this).find('td').eq(rowNumberColIndexs[i]).prop('innerText', String(index + 1));
                }
            });
        }
        // 行番号項目への内容設定
        if (resettingRowNumberColIndexs.length > 0) {
            rows.each(function(index) {
                for (var i=0; i < resettingRowNumberColIndexs.length; i++) {
                    $(this).find('td').eq(resettingRowNumberColIndexs[i]).find('[id$=resettingRowNumber]').prop('value', String(index + 1));
                }
            });
        }
    
        // ソート状態画像の変更 class「sortOrderImage」が設定された列のみ
        var sortOrderImg = $(sortTable).find('.sortOrderImage');
        if (sortOrderImg.length > 0) {
            // 初期化
            $(sortOrderImg).prop('src', sortOrderImageSrc.get(0));
        }
        sortOrderImg = $(th).find('.sortOrderImage');
        if (sortOrderImg.length > 0) {
            // 現状態の設定
            $(sortOrderImg).prop('src', sortOrderImageSrc.get(sortOrder));
        }
        // 連動テーブルのソート状態画像初期化
        if (linkTableIdList.length > 0) {
            $(linkTableIdList).each(function() {
                // 連動テーブル取得
                var linkSortTable = document.getElementById(this.trim());
                // ソート形式初期化
                cols = $(linkSortTable).find('th');
                rowNumberColIndexs = [];
                resettingRowNumberColIndexs = [];
                $(cols).each(function() {
                    this.setAttribute('data-sortOrder', this.getAttribute('data-initSortOrder'));
                    // 行番号の列取得
                    if (this.hasAttribute('data-rowNumberCol')) {
                        rowNumberColIndexs.push(this.cellIndex);
                    }
                    // 行番号項目再セット列取得
                    if (this.hasAttribute('data-resettingRowNumberCol')) {
                        resettingRowNumberColIndexs.push(this.cellIndex);
                    }
                });
                // 行番号列の内容設定
                var linkRows = $(linkSortTable).find('tr');
                linkRows = linkRows.slice(1, rows.length);
                if (rowNumberColIndexs.length > 0) {
                    linkRows.each(function(index) {
                        for (var i=0; i < rowNumberColIndexs.length; i++) {
                            $(this).find('td').eq(rowNumberColIndexs[i]).prop('innerText', String(index + 1))
                        }
                    });
                }
                // 行番号項目への内容設定
                if (resettingRowNumberColIndexs.length > 0) {
                    rows.each(function(index) {
                        for (var i=0; i < resettingRowNumberColIndexs.length; i++) {
                            $(this).find('td').eq(resettingRowNumberColIndexs[i]).find('[id$=resettingRowNumber]').prop('value', String(index + 1));
                        }
                    });
                }
                // ソート状態画像初期化
                sortOrderImg = $(linkSortTable).find('.sortOrderImage');
                if (sortOrderImg.length > 0) {
                    // 現状態の設定
                    $(sortOrderImg).prop('src', sortOrderImageSrc.get(0));
                }
            });
        }
    }
    // ソート時の比較処理
    function sortCompare(a, b, colIndex, sortType, sortOrder) {
        // 比較行の対象列データ取得
        var _a = $(a).find('td').eq(colIndex).text();
        var _b = $(b).find('td').eq(colIndex).text();
        // 数値型の比較
        if (sortType == 'number') {
            if (isNumber(_a) && isNumber(_b)) {
                return (_a - _b) * sortOrder;
            }
            if (isNumber(_a)) {
                return 1 * sortOrder;
            }
            if (isNumber(_b)) {
                return -1 * sortOrder;
            }
        }
        // フォーマットが掛かった数値型の比較
        if (sortType == 'format-number') {
            // 数値と「.」「-」以外を取り除いて比較する
            var __a = ['', null].includes(_a) ? '' : _a.replace(/[^0-9.-]/g,'');
            var __b = ['', null].includes(_b) ? '' : _b.replace(/[^0-9.-]/g,'');
            if (isNumber(__a) && isNumber(__b)) {
                return (__a - __b) * sortOrder;
            }
            if (isNumber(__a)) {
                return 1 * sortOrder;
            }
            if (isNumber(__b)) {
                return -1 * sortOrder;
            }
        }
        // 通常比較（文字列）
        if (_a > _b) {
            return 1 * sortOrder;
        }
        if (_a < _b) {
            return -1 * sortOrder;
        }
    }
    // 数値判定
    function isNumber(value) {
        if (!isFinite(value) || value == '' || value == null || typeof value == 'boolean') {
            return false;
        }
        return true;
    }
    // 連動ソートテーブルへのソート反映処理
    function linkSortFromIndex(linkSortTable, sortIndexSet) {
        // 連動テーブル全行取得
        var linkRows = $(linkSortTable).find('tr');
        linkRows = linkRows.slice(1, linkRows.length);
    
        // 初期indexをキーとした現indexの連想配列を作成
        var linkSortIndexSet = {};
        linkRows.each(function(index) {
            linkSortIndexSet[String(this.getAttribute('data-initRowIndex'))] = index;
        });
    
        // ソート後順の初期indexをキーに連動ソート
        var linkSortRows = [];
        $(sortIndexSet).each(function() {
            linkSortRows.push(linkRows[linkSortIndexSet[String(this)]]);
        });
    
        // 並び変えた行を配置し直す
        var body = $(linkSortTable).children('tbody');
        if (body.length >= 2) {
            $(linkSortTable).children('tbody').eq(body.length-1).append($(linkSortRows).detach());
        } else {
            $(linkSortTable).children('tbody').append($(linkSortRows).detach());
        }
    
    }
    
    
    // 横スクロール連動
    function linkScrollX(orgElement, targetElementId) {
        var target = document.getElementById(targetElementId);
        target.scrollLeft = orgElement.scrollLeft;
    }
    // 縦スクロール連動
    var linkScrollYProcessing = 0;
    function linkScrollY(orgElement, targetElementId) {
        if (linkScrollYProcessing == 0) {
            linkScrollYProcessing = 1;
            var target = document.getElementById(targetElementId);
            target.scrollTop = orgElement.scrollTop;
            setTimeout(function() {
                target.scrollTop = orgElement.scrollTop;
                setTimeout(function() {
                    linkScrollYProcessing = 0;
                }, 15);
            }, 20);
        }
    }
    
    
    // テーブルヘッダ、ボディの幅調整処理
    function tableColResize(tableId, isExcludeLastCol) {
    
        // 最終行対象外フラグ
        if (isExcludeLastCol == null) {
            isExcludeLastCol = false;
        }
    
        // 対象テーブル取得
        var targetTable = document.getElementById(tableId);
    
        // テーブルの全行取得
        var rows = jQuery('tr', targetTable);
    
        // データ0行の場合処理終了
        if (rows.length < 2) { return; }
    
        // ヘッダ行の列取得
        var headerCols = rows.eq(0).find('th');
    
        // 1データ目の列取得
        var bodyCols = rows.eq(1).find('td');
    
        // 列幅調整
        headerCols.each(function(index) {
            if (isExcludeLastCol) {
                if (headerCols.length == index + 1) {
                    return false;
                }
            }
            var headerWidth = $(headerCols[index]).outerWidth();
            var bodyWidth   = $(bodyCols[index]).outerWidth();
            if (headerWidth < bodyWidth) {
                // ヘッダ＜データの場合、各列の幅をデータに合わせる
                rows.each(function() {
                    var data = $($(this).children('th, td')).eq(index);
                    $(data).css('min-width', bodyWidth + 'px');
                });
            } else if (headerWidth > bodyWidth) {
                // ヘッダ＞データの場合、各列の幅をヘッダに合わせる
                rows.each(function() {
                    var data = $($(this).children('th, td')).eq(index);
                    $(data).css('min-width', headerWidth + 'px');
                });
            }
        });
    }
    
    /**
     * 使用ブラウザがSafariであるかの判定
     * @return true:safari false:それ以外
     */
    function isUseBrowserSafari() {
      return (useBrowser() == 'safari');
    }
    
    /**
    使用ブラウザ判定処理
    使用しているブラウザを文字列（小文字）にて返却
    @return ブラウザ名
    **/
    function useBrowser() {
      var userAgent = window.navigator.userAgent.toLowerCase();
      var useBrowser = '';
      if(userAgent.indexOf('msie') != -1) {
          useBrowser = 'msie';
      } else if(userAgent.indexOf('trident') != -1) {
          useBrowser = 'trident';
      } else if(userAgent.indexOf('edge') != -1) {
          useBrowser = 'edge';
      } else if(userAgent.indexOf('chrome') != -1) {
          useBrowser = 'chrome';
      } else if(userAgent.indexOf('safari') != -1) {
          useBrowser = 'safari';
      } else if(userAgent.indexOf('firefox') != -1) {
          useBrowser = 'firefox';
      } else if(userAgent.indexOf('opera') != -1) {
          useBrowser = 'opera';
      }
      return useBrowser;
    }
    