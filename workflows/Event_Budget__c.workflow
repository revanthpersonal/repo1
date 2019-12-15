<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Budget_Revision_Approved_Alert</fullName>
        <description>Budget Revision Approved Alert</description>
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
        <template>EMT_Email_Templates/Budget_revision_approved</template>
    </alerts>
</Workflow>
