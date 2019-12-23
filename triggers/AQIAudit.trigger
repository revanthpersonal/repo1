trigger AQIAudit on AQI_Audit__c (after insert, after update) {

	   	AQIAuditSharingRules sharingRules = new AQIAuditSharingRules(Trigger.new);
		sharingRules.shareAuditWithAuthor();

}