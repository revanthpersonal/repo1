global without sharing class AccountBillingInfoUtil {
    // How many email addresses the Account_Billing_Info__c object contains so as not to NPE on the email addition loop
    private static Integer EMAIL_COUNT = 10;
    // Picklist value for Account_Billing_Info__c.Status__c 
    private static String STATUS_NEW = 'New';
    // Picklist value for Account_Billing_Info__c.Status__c 
    private static String STATUS_ATTACHED = 'PDF Attached';
    
    webservice static String attachPDF(Id theId) {
        System.debug('attachPDF with Id ' + theId);
        
        String status = 'PDF Successfully Attached';
        
        Account_Billing_Info__c objAccountBillingInfo = [SELECT Id, Name, Order__c, Document_Type__c, Attachment_Name__c FROM Account_Billing_Info__c 
                                                         WHERE Id = :theID and Order__r.RecordType.Name = 'Cloud Monthly Billing Order' and (Status__c = :STATUS_NEW or Status__c = null) ];
        Account_Order_Address__c objBillingAddress = [SELECT Order__c,Email__c,Additional_Emails__c FROM Account_Order_Address__c 
                                                      WHERE Order__c = :objAccountBillingInfo.Order__c AND Address_Type__c = 'Bill To'];
        String strEmails = '';
        
        if(String.isNotBlank(objBillingAddress.Email__c))
            strEmails += objBillingAddress.Email__c + ';';
        if(String.isNotBlank(objBillingAddress.Additional_Emails__c))
            strEmails += objBillingAddress.Additional_Emails__c;
        //System.debug('Got emails ' + strEmails);
        
        // Populating email ids on email fields
        if(String.isNotBlank(strEmails))
        {
            List<String> list_EmailIds = strEmails.split(';');
            for( Integer i=0 ; i < EMAIL_COUNT && i < list_EmailIds.size() ; i++)
                objAccountBillingInfo.put('Email' + String.valueOf(i+1) + '__c',list_EmailIds[i]);
        }
        System.debug('Attemp attach for ' + objAccountBillingInfo.Name);
        PageReference pdfPage = new PageReference('/apex/CloudAccountBillingPdf');
        pdfPage.getParameters().put('id',objAccountBillingInfo.Id);
        Attachment objPDF = new Attachment();
        
        objPDF.Name = objAccountBillingInfo.Attachment_Name__c + '.pdf';
        
        objPDF.ParentId = objAccountBillingInfo.Id;
        if (Test.IsRunningTest())
            objPDF.Body = Blob.valueOf('UNIT.TEST');
        else
            objPDF.Body = pdfPage.getContentAsPdf();
        objPDF.Description = 'Account Billing Info';
        objPDF.ContentType  = 'application/pdf'; 
        // Insert pdf attachment 
        System.debug('Attempt PDF insert for parent ' + objPDF.ParentId + ' got Id ' + objPDF.Id);
        insert objPDF;
        
        objAccountBillingInfo.Status__c = STATUS_ATTACHED;
        update objAccountBillingInfo;

        return status;
    }
}