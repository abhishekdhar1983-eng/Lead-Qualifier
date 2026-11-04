trigger LeadTrigger on Lead (before insert, before update) {
    LeadScoringService.score(Trigger.new, Trigger.oldMap);
}
