@isTest
private class AccountActiveContractsExtensionTest {

    @testSetup
    static void setUpData() {
        Account objAccount = TestUtil.createAccounts(1, false)[0];
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        insert objAccount;
        Opportunity objOpportunity  = TestUtil.createOpportunities(1,objAccount.id, false)[0];
        objOpportunity.StageName = '6.Closed';
        objOpportunity.Win_Loss_Status__c = 'Won';
      	objOpportunity.Lines_of_Businesses__c = 'PureCloud';
        insert objOpportunity;
        zqu__Quote__c objQuote = setupZuoraQuote('PureCloud Test ZQuote 1', objOpportunity.AccountId ,objOpportunity.id, 24);
   		 objQuote.zqu__StartDate__c = System.today()- 730; 
        insert objQuote;
        GCR_Content_Document_Detail__c objContract1 = setupContracts(objQuote);
        GCR_Content_Document_Detail__c objContract2 = setupContracts(objQuote);
        List<GCR_Content_Document_Detail__c> list_Contracts = new List<GCR_Content_Document_Detail__c>{objContract1, objContract2};
        insert list_Contracts;
        List<dsfs__DocuSign_Status__c> list_DocSignsStatus = setupDocSignsStatus(list_Contracts);
        List<Attachment> list_Attachments = setupAttachments(list_DocSignsStatus);
    }
    
    public static testmethod void testInitialMethod(){
        Account objAccount = [SELECT id FROM Account LIMIT 1];
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objAccount);
        Test.setCurrentPage(Page.AccountActiveContracts);
        ApexPages.currentPage().getParameters().put('id',objAccount.Id);
        AccountActiveContractsExtension objAccountActivConExt = new AccountActiveContractsExtension(sc);
        Attachment objAttachment = [SELECT id FROM Attachment LIMIT 1][0];
        objAccountActivConExt.strAttachmentId = objAttachment.id;
        objAccountActivConExt.strContractId = [SELECT id FROM GCR_Content_Document_Detail__c LIMIT 1][0].id;
        objAccountActivConExt.createContent();
        Test.stopTest();
    }
    
    static zqu__Quote__c setupZuoraQuote(String strName, String strAccId , String strOppId, Integer intPeriod ){
        zqu__Quote__c objZquQuote = new zqu__Quote__c();
        objZquQuote.Name = strName;
        objZquQuote.zqu__Account__c = strAccId;
        objZquQuote.zqu__Opportunity__c = strOppId;
        objZquQuote.PureCloud_Ramp_Up_Period__c = intPeriod;
        return objZquQuote;
    }
    
    static GCR_Content_Document_Detail__c setupContracts(zqu__Quote__c objQuote){
        GCR_Content_Document_Detail__c objContract = new GCR_Content_Document_Detail__c();
        objContract.Account_Name__c = objQuote.zqu__Account__c;
        objContract.Opportunity__c = objQuote.zqu__Opportunity__c;
        objContract.Document_Name__c = 'Cloud Billing Contract';
        objContract.Zuora_Quote__c = objQuote.id;
        objContract.Order_Date_Option__c = 'Last Day of Usage Month';
        objContract.Status__c = 'New';
        objContract.Active__c = true;
        objContract.Status__c = 'Approved';
        objContract.Pricing_Start_Date__c = System.today() - 730 ;
        return objContract;
    }
    
    static List<dsfs__DocuSign_Status__c> setupDocSignsStatus(List<GCR_Content_Document_Detail__c> list_Contracts){
    List<dsfs__DocuSign_Status__c> list_DocSignsStatus = new List<dsfs__DocuSign_Status__c>();
        
        for(GCR_Content_Document_Detail__c objContract : list_Contracts){
            list_DocSignsStatus.add(new dsfs__DocuSign_Status__c( GCR_Content_Document__c = objContract.id, dsfs__Opportunity__c = objContract.Opportunity__c));
        }
        insert list_DocSignsStatus;
        return list_DocSignsStatus;
    }
    
    static List<Attachment> setupAttachments(List<dsfs__DocuSign_Status__c> list_DocSignsStatus){
        List<Attachment> list_Attachments = new List<Attachment>();
        for(integer i = 0 ; i< list_DocSignsStatus.size() ; i++){
           list_Attachments.add(new Attachment(name = 'Test'+i+'.txt', parentId = list_DocSignsStatus[i].id, Body = Blob.valueOf('Test')));
        }
        insert list_Attachments;
        return list_Attachments;
    }
}