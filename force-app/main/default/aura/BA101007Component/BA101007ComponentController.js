({
    
    //画面遷移処理 1
    showPage1 : function(component, event, helper) {     
        var url = '/apex/GA101001View';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    
    //画面遷移処理 2
    showPage2 : function(component, event, helper) {     
        var url = '/apex/GA101002View';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    
    //画面遷移処理 3
    showPage3 : function(component, event, helper) {     
        var url = '/apex/GA106001View';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }
    
})