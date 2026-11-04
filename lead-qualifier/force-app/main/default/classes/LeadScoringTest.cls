@IsTest
private class LeadScoringTest {
    @IsTest static void hotLeadScoresAndEscalates() {
        Lead l = new Lead(LastName='Doe', Company='Acme', Title='VP Operations', Industry='Technology',
            AnnualRevenue=20000000, NumberOfEmployees=900, LeadSource='Referral', Email='a@b.com', Phone='555',
            Budget_Confirmed__c=true, Timeline_Under_90_Days__c=true);
        insert l;
        l = [SELECT Lead_Score__c, Score_Tier__c, Hot_Since__c FROM Lead WHERE Id = :l.Id];
        System.assertEquals('Hot', l.Score_Tier__c);
        System.assertEquals(100, l.Lead_Score__c);
        l.Hot_Since__c = System.now().addHours(-3); update l;
        Test.startTest(); new HotLeadEscalationJob().execute(null); Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhoId = :l.Id AND Subject LIKE 'ESCALATION%']);
    }
    @IsTest static void coldLead() {
        Lead l = new Lead(LastName='Low', Company='Tiny'); insert l;
        System.assertEquals('Cold', [SELECT Score_Tier__c FROM Lead WHERE Id = :l.Id].Score_Tier__c);
    }
}
