trigger PersonTracingTrigger on Person__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            for(Person__c person : Trigger.new){
                if(person.Health_Status__c == null){
                    person.Health_Status__c = 'Green';
                }
                if(person.Mobile__c != null){
                    person.Token__c = CTPersonController.getToken(person.Mobile__c);
                }
            }
        }
        when BEFORE_UPDATE {
            for(Person__c person : Trigger.new){
                Person__c oldPerson = Trigger.oldMap.get(person.Id);
                if(person.Health_Status__c != oldPerson.Health_Status__c){
                    person.Status_Update_Date__c = Date.today();
                }
            }
        }
        when else {

        }
    }
    
}