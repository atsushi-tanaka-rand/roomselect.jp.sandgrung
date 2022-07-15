trigger HelloWorldTrigger on Account (before insert,after insert,before update, after update) {
    if(Trigger.isBefore){
        System.debug('-----トリガーの値isBefore-----');
        System.debug('Trigger.oldは：' + Trigger.old);
        System.debug('Trigger.oldMapは：' + Trigger.oldMap);
        System.debug('Trigger.newは：' + Trigger.new);
        System.debug('Trigger.newMap：' + Trigger.newMap);
    }
    if(Trigger.isAfter){
        System.debug('-----トリガーの値isAfter-----');
        System.debug('Trigger.oldは：' + Trigger.old);
        System.debug('Trigger.oldMapは：' + Trigger.oldMap);
        System.debug('Trigger.newは：' + Trigger.new);
        System.debug('Trigger.newMap：' + Trigger.newMap);
    }
}