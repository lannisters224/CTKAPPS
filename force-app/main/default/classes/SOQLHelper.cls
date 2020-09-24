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
public with sharing class SOQLHelper {
    
    static final string STARTBOUND = '[';
    static final string ENDBOUND = ']';

    public static String resolveFilters(string filters, String recordId){

        string resolvedFilters = '';
        
        // resolve parameters passed in filters
        // for e.g. accountid = [id] and account.parentid = [Parentid]
        
        // retrieve list of merged filter values
        Set<String> setVals = StringHelper.extractBoundedValues(filters, STARTBOUND, ENDBOUND);
        
        if(setVals.isEmpty() == false){
            resolvedFilters = filters;

            string soql = getSOQLForRecordById(recordId, setVals);

            sobject currentObj = Database.query(soql);

            // resolve merge filter values with actual values
            Map<String, string> mapResolvedValues = new Map<String, String>();
            for(String val : setVals){
                resolvedFilters = resolvedFilters.replace(STARTBOUND + val + ENDBOUND, (String) currentObj.get(val));
            }
        }

        return resolvedFilters;
    }

    public static String getSOQLForRecordById(string recordId, Set<String> fields){
        
        // add id field to act as key
        fields.add('id');
        
        List<String> lstVals = new List<String>();
        lstVals.addAll(fields);

        ID objId = ID.valueOf(recordId);
        
        // retrieve current record
        String soql =   ' select  ' + String.join(lstVals, ',') + 
                        ' from ' + objId.getSobjectType() + 
                        ' where id = :recordId';
        return soql;
    }

    /*
        Generate and return dynamic soql query
        Contact, OrgContacts
    */
    public static string generateDynamicSOQL(String sobjectName, List<Schema.FieldSetMember> lstfields, String filters, string sortByFieldName, boolean sortDescending, Integer maxRecords){
        
        List<String> lstfieldNames = new List<String>();
        for(Schema.FieldSetMember fsetMem : lstfields){
            lstfieldNames.add(fsetMem.getFieldPath());
        }

        string soql = 'SELECT {0} FROM {1}';

        soql = String.format(soql, new List<String>{
                                    String.join(lstfieldNames, ','),    // 0
                                    sobjectName                         // 1
                                    });                              
        
        if(String.isNotBlank(filters)){
            soql += ' WHERE ' + filters;
        }

        // set sort order for query
        if(String.isNotBlank(sortByFieldName)){
            soql += ' ORDER BY ' + sortByFieldName;

            if(sortDescending){
                soql += ' DESC NULLS LAST';
            }
        }

        if(maxRecords == null) maxRecords = 5;          // set default value of max records to 5

        soql += ' LIMIT ' + maxRecords;

        return soql;
    }

}