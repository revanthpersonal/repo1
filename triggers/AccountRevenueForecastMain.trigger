//Naresh Kumar  04/07/2016
trigger AccountRevenueForecastMain on Account_Revenue_Forecast__c (before insert, after insert, before update, after update) {
    if(Util.Bypass_Trigger_Chk)
        return;
    if(trigger.isBefore){
        AccountRevenueForecastHelper.onBeforeInsertUpdate(trigger.new);
        
        //Added by Priyank to populate the GS relationship on ARF.
        AccountRevenueForecastHelper.beforeInsertArfGsfieldPopulate(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
        //AccountRevenueForecastHelper.onAfterUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isInsert){
        CloudForecastQuarterMainHelper.cloneComments(trigger.newMap);
    }
}