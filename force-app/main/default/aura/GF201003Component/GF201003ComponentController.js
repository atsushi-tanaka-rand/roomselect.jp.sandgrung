({
	New : function(component, event, helper) {     
        var url = '/apex/OpenDummyWindow?pageName=GF201004View';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
	},
    
	Item : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:GF201001Component"
        });
        evt.fire();
    }
})