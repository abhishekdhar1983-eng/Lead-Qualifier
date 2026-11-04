public with sharing class HotLeadEscalationJob implements Schedulable {
    public static final Integer SLA_HOURS = 1;
    public void execute(SchedulableContext sc) {
        Datetime cutoff = System.now().addHours(-SLA_HOURS);
        List<Lead> stale = [SELECT Id, OwnerId, Name, Lead_Score__c FROM Lead
            WHERE Score_Tier__c = 'Hot' AND IsConverted = false AND Status = 'Open - Not Contacted'
            AND Escalated__c = false AND Hot_Since__c < :cutoff LIMIT 200];
        Set<Id> ownerIds = new Set<Id>();
        for (Lead l : stale) if (String.valueOf(l.OwnerId).startsWith('005')) ownerIds.add(l.OwnerId);
        Map<Id, User> owners = new Map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN :ownerIds]);
        List<Task> tasks = new List<Task>();
        for (Lead l : stale) {
            User o = owners.get(l.OwnerId);
            tasks.add(new Task(WhoId = l.Id, Priority = 'High', ActivityDate = Date.today(),
                OwnerId = (o != null && o.ManagerId != null) ? o.ManagerId : l.OwnerId,
                Subject = 'ESCALATION: Hot lead untouched for ' + SLA_HOURS + 'h - ' + l.Name));
            l.Escalated__c = true;
        }
        insert tasks; update stale;
    }
}
