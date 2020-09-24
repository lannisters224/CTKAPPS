/*
 *     Copyright 2020 Cynoteck @ http://www.cynoteck.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *          http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@namespaceAccessible 
public with sharing class CTKDynamicDataHelper {
    
    /*
        return data 
    */
    @AuraEnabled(cacheable = true)
    public static List<SObject> getSobjectData(string sobjectName, string fieldSetName, string filters, string recordId, string sortByFieldName, boolean sortDescending, Integer maxRecords) {
        //get fields from fieldset
        List<Schema.FieldSetMember> lstfields = getFieldsFromFieldset(String.escapeSingleQuotes(sobjectName), fieldSetName);

        //remove inacessible fields
        List<Schema.FieldSetMember> lstAccessiblefields = removeInAccessibleFields(lstfields);

        //resolve filters with merged values
        filters = SOQLHelper.resolveFilters(filters, recordId);

        if(String.isBlank(sortByFieldName) && lstAccessiblefields.size() > 0){
            // set first column as sort column
            sortByFieldName = lstAccessiblefields[0].getFieldPath();
        }

        //get SOQL with mergeed filters and fields
        String dynamicSOQL = SOQLHelper.generateDynamicSOQL(String.escapeSingleQuotes(sobjectName), lstAccessiblefields, filters, sortByFieldName, sortDescending, maxRecords);
        //retrieve records
        List<SObject> lstRecords = Database.query(dynamicSOQL);
        return lstRecords;
    }

    /*
        Removes field inaccessible by current user
    */
    public static List<Schema.FieldSetMember> removeInAccessibleFields(List<Schema.FieldSetMember> lstfields){
        //remove inacessible fields
        system.debug('--- lstfields' + lstfields);
        List<Schema.FieldSetMember> lstAccessiblefields = new List<Schema.FieldSetMember>();
        for(Schema.FieldSetMember fieldSetField : lstfields){
            system.debug('--- fieldSetField ' + fieldSetField);
            system.debug('--- fieldSetField.getSObjectField().getDescribe() ' + fieldSetField.getSObjectField().getDescribe());
            if(fieldSetField.getSObjectField().getDescribe().isAccessible()){
                lstAccessiblefields.add(fieldSetField);
            }
        }
        system.debug('--- lstAccessiblefields' + lstAccessiblefields);
        return lstAccessiblefields;
    }

    /*
        return object fields map 
    */

    @AuraEnabled(cacheable = true)
    public static List<FieldInfo> getSobjectFields(string sobjectName, string fieldSetName) {
        
        List<FieldInfo> lstFields = new List<FieldInfo>();
        List<Schema.FieldSetMember> lstFieldSetFields = getFieldsFromFieldset(sobjectName, fieldSetName);

        //remove inacessible fields
        List<Schema.FieldSetMember> lstAccessiblefields = removeInAccessibleFields(lstFieldSetFields);

        for(Schema.FieldSetMember fsetMem : lstAccessiblefields){
            lstFields.add( new FieldInfo(fsetMem));
        }

        return lstFields;
    }

    /*
        Returns fields details of given object name and fieldset
    */
    public static List<Schema.FieldSetMember> getFieldsFromFieldset(String objectName, String fieldSetName)
    {
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
    }  
}