<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Satellite_Meeting_Approved_Notification</fullName>
        <description>Satellite Meeting Approved Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Event_Collaborator_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Event_primary_contact_email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EMT_Email_Templates/Satellite_meeting_approved</template>
    </alerts>
</Workflow>
