# Lead Qualifier (Sales Cloud)
Deploy: `sf project deploy start -o <your-sandbox-alias>` then `sf org assign permset -n Lead_Qualifier_User`.
Schedule escalation (Developer Console > Anonymous Apex), every 15 min:
  for (Integer m : new Integer[]{0,15,30,45}) System.schedule('Hot Lead Escalation '+m, '0 '+m+' * * * ?', new HotLeadEscalationJob());
Then: add Lead_Score__c / Score_Tier__c / Score_Reason__c to the Lead page layout and a "Hot Leads" list view sorted by score.
Einstein Lead Scoring and Agentforce for Sales are licensed features turned on in Setup (see chat notes).
