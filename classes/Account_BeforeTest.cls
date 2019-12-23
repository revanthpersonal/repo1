@isTest(seeAllData = true)
private class Account_BeforeTest {
    static testMethod void myUnitTest1() 
    {  
        GCRApprovalsToApproveController GCRTest = new GCRApprovalsToApproveController();
    }
    
    static testMethod void myUnitTest2() 
    { 
        
        RecordType RT = [select Id,  Name from RecordType where  Name = 'EMG - Customer Record Type'];
        Country__c TestCountry = [select Id, Name from Country__c where Name = 'Mexico'];
        Account[] Acc = new Account[]{
            new Account( RecordTypeId = RT.Id 
                        ,Name = 'TestAccount'
                        ,Street1__c = 'Test Street'
                        ,ZipCode__c = '90001'
                        , City__c = 'Test City'
                        ,Country__c = TestCountry.Id
                        ,Industry  = 'EDUCATION'
                        ,Industry__c = 'Technical and Trade Schools'
                        ,AccountClassification__c =  'Small'
                        ,Type = 'Customer'
                        ,CurrencyIsoCode =  'USD'
                       )
                };
                    
                    insert Acc; 
        Account Acctest = [Select recordtypeid from Account where id =: Acc[0].id ];
        Acctest.Recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EMG - Prospect Record Type').getRecordTypeId();  
        Update Acctest;          
        delete Acc;
    }
    
    static testMethod void myUnitTest3() 
    { 
        
        RecordType RT = [select Id,  Name from RecordType where  Name = 'EMG - Customer Record Type'];
        Country__c TestCountry = [select Id, Name from Country__c where Name = 'Mexico'];
        Account[] Acc = new Account[]{
            new Account( RecordTypeId = RT.Id 
                        ,Name = 'TestAccount'
                        ,Street1__c = 'Test Street'
                        ,ZipCode__c = '90001'
                        , City__c = 'Test City'
                        ,Country__c = TestCountry.Id
                        ,Industry  = 'EDUCATION'
                        ,Industry__c = 'Technical and Trade Schools'
                        ,AccountClassification__c =  'Small'
                        ,Type = 'Prospect'
                        ,CurrencyIsoCode =  'USD'
                       )
                };
                    
                    insert Acc; 
        delete Acc;
    }
    
    static testMethod void myUnitTest4() 
    { 
        
        RecordType RT = [select Id,  Name from RecordType where  Name = 'EMG - Customer Record Type'];
        Country__c TestCountry = [select Id, Name from Country__c where Name = 'Mexico'];
        Account[] Acc = new Account[]{
            new Account( RecordTypeId = RT.Id 
                        ,Name = 'TestAccount'
                        ,Street1__c = 'Test Street'
                        ,ZipCode__c = '90001'
                        , City__c = 'Test City'
                        ,Country__c = TestCountry.Id
                        ,Industry  = 'EDUCATION'
                        ,Industry__c = 'Technical and Trade Schools'
                        ,AccountClassification__c =  'Small'
                        ,Type = 'Partner'
                        ,CurrencyIsoCode =  'USD'
                       )
                };
                    
                    insert Acc; 
        List<Address__c> listaddress = [select id from Address__c where Account__c = :Acc[0].id and Address_Type__c = 'Corporate']; 
        if(listaddress.size() > 0)
            delete listaddress;
        TriggerFlowManager.ACCOUNT_ADDRESS_UPDATE = true;        
        update Acc;
        
        delete Acc;
    }
    
    static testMethod void myUnitTest5() 
    { 
        
        RecordType RT = [select Id,  Name from RecordType where  Name = 'EMG - Customer Record Type'];
        Country__c TestCountry = [select Id, Name from Country__c where Name = 'Mexico'];
        Account[] Acc = new Account[]{
            new Account( RecordTypeId = RT.Id 
                        ,Name = 'TestAccount'
                        ,Street1__c = 'Test Street'
                        ,ZipCode__c = '90001'
                        , City__c = 'Test City'
                        ,Country__c = TestCountry.Id
                        ,Industry  = 'EDUCATION'
                        ,Industry__c = 'Technical and Trade Schools'
                        ,AccountClassification__c =  'Small'
                        ,Type = 'Partner'
                        ,Jigsaw = 'test'
                        ,CurrencyIsoCode =  'USD',Billingcountry = 'India',BillingPostalCode='1111111',BillingCity = 'test',BillingState='test'
                       )
                };
                    
                    insert Acc; 
        List<Address__c> listaddress = [select id from Address__c where Account__c = :Acc[0].id and Address_Type__c = 'Corporate']; 
        if(listaddress.size() > 0)
            delete listaddress;
        update Acc;
        
        delete Acc;
    }
    
    static testMethod void myUnitTest6() 
    { 
        
        RecordType RT = [select Id,  Name from RecordType where  Name = 'EMG - Customer Record Type'];
        Country__c TestCountry = [select Id, Name from Country__c where Name = 'United States'];
        Account[] Acc = new Account[]{
            new Account( RecordTypeId = RT.Id 
                        ,Name = 'TestAccount'
                        ,Street1__c = 'Test Street'
                        ,ZipCode__c = '90001'
                        , City__c = 'Test City'
                        ,Country__c = TestCountry.Id
                        ,Industry  = 'EDUCATION'
                        ,Industry__c = 'Technical and Trade Schools'
                        ,AccountClassification__c =  'Small'
                        ,Type = 'Partner'
                        ,Jigsaw = 'test'
                        ,CurrencyIsoCode =  'USD',Billingcountry = 'India',BillingPostalCode='1111111',BillingCity = 'test',BillingState='test'
                       )
                };
                    
                    insert Acc; 
        List<Address__c> listaddress = [select id from Address__c where Account__c = :Acc[0].id and Address_Type__c = 'Corporate']; 
        if(listaddress.size() > 0)
            delete listaddress;
        update Acc;
        
        delete Acc;
    }
    
    static testMethod void myUnitTest7() 
    { 
        
        RecordType RT = [select Id,  Name from RecordType where  Name = 'Enterprise - Business Partner'];
        Country__c TestCountry = [select Id, Name from Country__c where Name = 'United States'];
        Account[] Acc = new Account[]{
            new Account( RecordTypeId = RT.Id 
                        ,Name = 'TestAccount'
                        ,Street1__c = 'Test Street'
                        ,ZipCode__c = '90001'
                        , City__c = 'Test City'
                        ,Country__c = TestCountry.Id
                        ,Industry  = 'EDUCATION'
                        ,Industry__c = 'Technical and Trade Schools'
                        ,AccountClassification__c =  'Small'
                        ,Type = 'Customer'
                        ,Jigsaw = 'test'
                        ,CurrencyIsoCode =  'USD',Billingcountry = 'India',BillingPostalCode='1111111',BillingCity = 'test',BillingState='test'
                       )
                };
                    
                    insert Acc; 
        List<Address__c> listaddress = [select id from Address__c where Account__c = :Acc[0].id and Address_Type__c = 'Corporate']; 
        if(listaddress.size() > 0)
            delete listaddress;
        update Acc;
        
        delete Acc;
    }
    
     static testMethod void myUnitTest8() 
    { 
        
        RecordType RT = [select Id,  Name from RecordType where  Name = 'Enterprise - Business Partner'];
        Country__c TestCountry = [select Id, Name from Country__c where Name = 'United States'];
        Account[] Acc = new Account[]{
            new Account( RecordTypeId = RT.Id 
                        ,Name = 'TestAccount'
                        ,Street1__c = 'Test Street'
                        ,ZipCode__c = '90001'
                        , City__c = 'Test City'
                        ,Country__c = TestCountry.Id
                        ,Industry  = 'EDUCATION'
                        ,Industry__c = 'Technical and Trade Schools'
                        ,AccountClassification__c =  'Small'
                        ,Type = 'Customer'
                        ,Jigsaw = 'test'
                        ,CurrencyIsoCode =  'USD',Billingcountry = 'India',BillingPostalCode='1111111',BillingCity = 'test',BillingState='test'
                       )
                };
                    
                    insert Acc; 
        List<Address__c> listaddress = [select id from Address__c where Account__c = :Acc[0].id and Address_Type__c = 'Corporate']; 
        if(listaddress.size() > 0)
            delete listaddress;
        update Acc;
        
        delete Acc;
    }
    static testMethod void myUnitTest9() 
    { 
        
        RecordType TR = [select Id,  Name from RecordType where  Name = 'Enterprise - Business Partner'];
        Country__c TestCountry = [select Id, Name from Country__c where Name = 'United States'];
        Account[] Acc = new Account[]{
            new Account( RecordTypeId = RT.Id 
                        ,Name = 'TestAccount'
                        ,Street1__c = 'Test Street'
                        ,ZipCode__c = '90001'
                        , City__c = 'Test City'
                        ,Country__c = TestCountry.Id
                        ,Industry  = 'EDUCATION'
                        ,Industry__c = 'Technical and Trade Schools'
                        ,AccountClassification__c =  'Small'
                        ,Type = 'Customer'
                        ,Jigsaw = 'test'
                        ,CurrencyIsoCode =  'USD',Billingcountry = 'India',BillingPostalCode='1111111',BillingCity = 'test',BillingState='test'
                       )
                };
                    
                    insert Acc; 
        List<Address__c> listaddress = [select id from Address__c where Account__c = :Acc[0].id and Address_Type__c = 'Corporate']; 
        if(listaddress.size() > 0)
            delete listaddress;
        update Acc;
        
        delete Acc;
    }
    
}