public with sharing class CTPersonController {
    
    public static String getToken(String MobileNo){
        Blob value = Blob.valueOf(MobileNo);
        Blob hash = Crypto.generateDigest('MD5', value);
        return EncodingUtil.base64Encode(hash);
    }
    
    public static List<Person__c> getRecentHealtChanges(){       
        List<Person__c> persons = [SELECT Id, Token__c, Name,	Mobile__c, Health_Status__c,Status_Update_Date__c 
                                    FROM Person__c 
                                    ORDER BY Status_Update_Date__c  DESC LIMIT 100];
        return persons;       
    }
    
    public static List<Person__c> searchPeople(String searchText) {
        return [SELECT Id, Token__c, Name, Mobile__c, Health_Status__c, Status_Update_Date__c 
                FROM Person__c 
                WHERE Name LIKE :('%' + searchText + '%') OR Mobile__c LIKE :('%' + searchText + '%')
                OR Token__c LIKE :('%' + searchText + '%') ORDER BY Status_Update_Date__c DESC]; 
    }


    public static Person__c getPersonById(Id IdUser){  
        Person__c query = [SELECT Id, Token__c, Name, Mobile__c, Health_Status__c, Status_Update_Date__c 
                            FROM Person__c 
                            WHERE Id = :IdUser];        
        if (query != null){
            return query;
        }else{
            return null;
        }
    }

    public static Map<String,Integer> getHealthStatusCount(){
        Map<String, Integer> healthStatusCount = new Map<String, Integer>();
        for (Person__c p : [SELECT Health_Status__c FROM Person__c]){
            if(!healthStatusCount.containsKey(p.Health_Status__c)) {
                healthStatusCount.put(p.Health_Status__c, 1);
            }else{
                Integer currentvalue = healthStatusCount.get(p.Health_Status__c);
                healthStatusCount.put(p.Health_Status__c, currentvalue + 1);
            }
        }
        return healthStatusCount;
    }
}