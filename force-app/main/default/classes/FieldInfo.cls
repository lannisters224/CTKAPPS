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

global with sharing class FieldInfo {
    
    @AuraEnabled public String apiName {get; set;}

    
    @AuraEnabled public String label {get; set;}

    
    @AuraEnabled public String dataType {get; set;}

    @AuraEnabled public Boolean isHTML {get; set;}
    
    private static Map<String, String> mapLWCTypeToFieldType = new Map<String, String>{
        'ADDRESS'       => 'text',
        'BOOLEAN'       => 'boolean',
        'COMBOBOX'      => 'text',
        'CURRENCY'      => 'currency',
        'DATE'          => 'date',
        'DATETIME'      => 'date',
        'DOUBLE'        => 'number',
        'EMAIL'         => 'email',
        'ID'            => 'text',
        'INTEGER'       => 'number',
        'LONG'          => 'number',
        'MULTIPICKLIST' => 'text',
        'PERCENT'       => 'percent',
        'PHONE'         => 'phone',
        'PICKLIST'      => 'text',
        'REFERENCE'     => 'text',
        'STRING'        => 'text',
        'TEXTAREA'      => 'text',
        'TIME'          => 'number',
        'URL'           => 'text'
    };

    public FieldInfo(Schema.FieldSetMember fieldSetField) {
        this.isHTML = false;

        this.apiName = fieldSetField.getFieldPath();
        this.label = fieldSetField.getLabel();
        
        Schema.DisplayType displayType = fieldSetField.getType();

        // resolve field data type for display
        if(FieldInfo.mapLWCTypeToFieldType.containsKey(displayType.name())){
            this.dataType = mapLWCTypeToFieldType.get(displayType.name());
        }
        else{
            this.dataType =  'text';
        }

        // if formatted html then flag field
        if(fieldSetField.getSObjectField().getDescribe().isHtmlFormatted()){
            this.isHTML = true;
        }
    }
}