trigger AddressTrigger on Address__c (before insert,before update) {
    
    for (Address__c add : trigger.new){
        //I4, I3, I2, I1
        if(add.Validity_Status__c=='I4' || add.Validity_Status__c=='I3' || add.Validity_Status__c=='I2' ||
          add.Validity_Status__c=='I1' || add.Validity_Status__c=='V4' || add.Validity_Status__c=='C4' || add.Validity_Status__c=='V3' ||
          add.Validity_Status__c=='C3'){
            add.Validity_Status__c ='Valid';
          }
        //N4, N3, N2, N1
        if(add.Validity_Status__c=='N4' || add.Validity_Status__c=='N3' || add.Validity_Status__c=='N2' ||
          add.Validity_Status__c=='N1'){
            add.Validity_Status__c ='Not Valid';
        }
    }

}