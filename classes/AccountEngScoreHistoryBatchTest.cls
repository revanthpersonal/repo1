//Naresh Kumar	05/11/2016
@isTest(seeAllData=true)
private class AccountEngScoreHistoryBatchTest {
	static testMethod void AccountEngScoreHistoryBatch(){
		Account testAccount = TestUtil.createAccounts(1, false)[0];
		testAccount.PE_SS_Flag__c = true;
		insert testAccount;
		SML_Account_Engagement_Score__c testEngScore = new SML_Account_Engagement_Score__c();
		testEngScore.Account__c = testAccount.id;
		insert testEngScore;
		SML_Account_Engagement_Score_History__c testScoreHistory = new SML_Account_Engagement_Score_History__c();
		testScoreHistory.SML_Account_Engagement_Score__c = testEngScore.id;
		testScoreHistory.New_Score__c = 10;
		testScoreHistory.Old_Score__c = 20;		
		insert testScoreHistory;
		Test.startTest();
       	AccountEngScoreHistoryBatch objBatch = new AccountEngScoreHistoryBatch('SELECT id FROM Account WHERE id = \'' + testAccount.id + '\'');
        Database.executeBatch(objBatch);
        Test.stopTest();
	}
}