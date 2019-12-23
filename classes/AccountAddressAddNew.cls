public class AccountAddressAddNew {
	
	public AccountAddressAddNew(Account acct) {
	    
	  if ( acct.Street1__c == null || acct.Street1__c == '')
	       return;
	    
	  try {	
		Address__c addr = new Address__c();
		
		addr.Name = acct.Name;
		addr.Account__c = acct.Id;
		addr.Address_Line_1__c = acct.Street1__c;
		addr.Address_Line_2__c = acct.Street2__c;
		addr.Zipcode__c = acct.ZipCode__c;
		addr.City__c = acct.City__c;
		addr.State__c = acct.StateProvince__c;
		addr.Active_Status__c = true;
		addr.Type__c = 'Primary Address';
		Country__c country = [Select Name From Country__c Where Id= :acct.Country__c];
		addr.Country__c = country.Name;
		insert addr;
	  }
	  catch (Exception e) {
	  	 
	  }
	}
	
	@isTest
	private static void myUnitTest() {
		Account testAccount = TestUtil.createAccounts(1, false)[0];
		testAccount.Street1__c = 'street1';
		AccountAddressAddNew addr = new AccountAddressAddNew(testAccount);
	}

}