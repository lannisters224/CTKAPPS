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

import { LightningElement, track, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import form_factor from '@salesforce/client/formFactor';
import getSobjectData from '@salesforce/apex/CTKDynamicDataHelper.getSobjectData';
import getSobjectFields from '@salesforce/apex/CTKDynamicDataHelper.getSobjectFields';

export default class dynamicRelatedList extends NavigationMixin(LightningElement) {
    @track columns = [];
    @track records = [];
    
    @api recordId;
    @api title;
    @api footer;
    @api objectName;
    @api fieldSetName;
    @api filters;
    @api headerIcon;
    @api recordCount;
    @api isObjectAccessible;
    @api actionFieldName;
    @api isPhoneFactor;
    @api columnsInDeviceMode;
    @api sortByFieldName;
    @api sortDirection;
    @api sortDescending;
    @api maxRecords;

    _isRendered = false;

    @track isLoading;

    renderedCallback(){
        this.isObjectAccessible = true;

        if(this._isRendered === false){
            this.isPhoneFactor = (form_factor === 'Small');

            this.recordCount = 0;
            this.isLoading = true;
            
            this.loadFields();

            this.loadData();

            this._isRendered = true;
        }
    }

    loadFields(){
        // get sobject fields (columns)
        getSobjectFields({
            sobjectName : this.objectName , 
            fieldSetName : this.fieldSetName
        })  
        .then(data => {
            var fieldKeys;
            var _self = this;
            _self._columns = [];
            
            data.forEach( function (fieldInfo, index){

                var newCol = {};
                if(_self.actionFieldName && fieldInfo.apiName.toUpperCase() === _self.actionFieldName.toUpperCase()){
                    // display name field as hyperlink to record
                    newCol = {   label: fieldInfo.label, 
                                            sortable : true, 
                                            fieldName: fieldInfo.apiName, 
                                            type : 'button', 
                                            typeAttributes : {label : { fieldName: _self.actionFieldName }, name : { fieldName: 'id' }, variant : 'base'}};
                }
                else if(fieldInfo.isHTML){
                    // for formula fields with html - bind custom type to display html/ richtext
                    newCol = {   label: fieldInfo.label, 
                        type : 'htmlCell',
                        sortable : true, 
                        fieldName: fieldInfo.apiName};
                }
                else{
                    newCol = {   label: fieldInfo.label, 
                                            type : fieldInfo.dataType,
                                            sortable : true, 
                                            fieldName: fieldInfo.apiName};
                }
                
                if(index == 0 && !_self.sortByFieldName){
                    _self.sortByFieldName = fieldInfo.apiName;
                    _self.sortDirection = 'asc';
                    _self.sortDescending = false;
                }

                _self._columns.push(newCol);
            });

            if(!this.columnsInDeviceMode) {
                this.columnsInDeviceMode = 3;         //set default value
            }
            
            // In device mode, show limited attributes
            if(this.isPhoneFactor){
                this.columns = _self._columns.slice(0, this.columnsInDeviceMode);
            }
            else{
                this.columns = _self._columns;
            }

            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.columns = undefined;
        }); 
    }

    loadData(){
        // get data
        this.isLoading = true;
        var sortDir = this.sortDirection === 'desc' ? true : false;
        getSobjectData({
            sobjectName : this.objectName , 
            fieldSetName : this.fieldSetName, 
            filters : this.filters,
            recordId : this.recordId,
            sortByFieldName : this.sortByFieldName,
            sortDescending : sortDir,
            maxRecords : this.maxRecords
        })
        .then(data =>{
            this.records = data;
            this.error = undefined;
            this.isLoading = false;
            this.recordCount = data.length;
        })
        .catch(error => {
            this.error = error;
            this.records = undefined;

            this.isLoading = false;
        });
    }
    

    navigateToRecord(evt){
        var recordId = evt.detail.row.Id;
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: this.objectName,
                actionName: 'view'
            }
        });
    }

    updateColumnSorting(event) {
        this.sortByFieldName = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.loadData();
    }
}