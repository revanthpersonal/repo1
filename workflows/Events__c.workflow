<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_for_Event_Collaborater_Invitation</fullName>
        <description>Email for Event Collaborater Invitation</description>
        <protected>false</protected>
        <recipients>
            <field>Event_Collaborator_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EMT_Email_Templates/Event_collaboration</template>
    </alerts>
    <rules>
        <fullName>Event Collaborate Invite</fullName>
        <actions>
            <name>Email_for_Event_Collaborater_Invitation</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Collaborator_has_been_Notified</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>EMT Application : This workflow is built for to notify the Event Collaborators.</description>
        <formula>( IF(ISBLANK(Event_Collaborator_Email__c), false, true) &amp;&amp;   ISNEW()) || (ISCHANGED(Event_Collaborator_Email__c) &amp;&amp; IF(ISBLANK(Event_Collaborator_Email__c), false, true))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
