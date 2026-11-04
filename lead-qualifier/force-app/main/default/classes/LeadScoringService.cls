public with sharing class LeadScoringService {
    static final Set<String> TARGET_INDUSTRIES = new Set<String>{
        'Technology','Manufacturing','Finance','Banking','Insurance','Transportation','Consulting'};
    static final Set<String> HIGH_VALUE_SOURCES = new Set<String>{'Partner','Referral','Employee Referral'};

    public static void score(List<Lead> leads, Map<Id, Lead> oldMap) {
        for (Lead l : leads) {
            Integer s = 0; List<String> why = new List<String>();
            if (l.Industry != null && TARGET_INDUSTRIES.contains(l.Industry)) { s += 15; why.add('Target industry +15'); }
            if (l.AnnualRevenue != null) {
                if (l.AnnualRevenue >= 10000000) { s += 15; why.add('Revenue >= $10M +15'); }
                else if (l.AnnualRevenue >= 1000000) { s += 8; why.add('Revenue >= $1M +8'); }
            }
            if (l.NumberOfEmployees != null) {
                if (l.NumberOfEmployees >= 500) { s += 10; why.add('500+ employees +10'); }
                else if (l.NumberOfEmployees >= 50) { s += 5; why.add('50+ employees +5'); }
            }
            String t = l.Title == null ? '' : l.Title.toLowerCase();
            if (t.contains('chief') || t.contains('vp') || t.contains('vice president') || t.contains('director') || t.contains('head of') || t.contains('owner')) { s += 20; why.add('Decision-maker title +20'); }
            else if (t.contains('manager')) { s += 10; why.add('Manager title +10'); }
            if (l.LeadSource != null && HIGH_VALUE_SOURCES.contains(l.LeadSource)) { s += 15; why.add('High-value source +15'); }
            else if (l.LeadSource == 'Web' || l.LeadSource == 'Webinar') { s += 6; why.add('Inbound interest +6'); }
            if (l.Email != null) { s += 5; why.add('Email +5'); }
            if (l.Phone != null) { s += 5; why.add('Phone +5'); }
            if (l.Budget_Confirmed__c) { s += 10; why.add('Budget confirmed +10'); }
            if (l.Timeline_Under_90_Days__c) { s += 10; why.add('Buying within 90 days +10'); }
            s = Math.min(s, 100);
            l.Lead_Score__c = s;
            l.Score_Tier__c = s >= 70 ? 'Hot' : (s >= 40 ? 'Warm' : 'Cold');
            l.Score_Reason__c = String.join(why, '\n');
            Boolean wasHot = oldMap != null && oldMap.containsKey(l.Id) && oldMap.get(l.Id).Score_Tier__c == 'Hot';
            if (l.Score_Tier__c == 'Hot' && !wasHot) { l.Hot_Since__c = System.now(); l.Escalated__c = false; }
        }
    }
}
