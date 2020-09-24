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
public with sharing class StringHelper {
    
    // Extract list of values in a string bounded by special characters
    public static Set<String> extractBoundedValues(String value, string startBound, string endBound){
        Set<String> setVals = new Set<String>();
        
        if(value.contains(startBound) && value.contains(endBound)){
            while(value.contains(startBound)){
                string val = value.substring( value.indexOf(startBound) + 1, value.indexOf(endBound));
                setVals.add(val);
                value = value.substring(value.indexOf(endBound) + 1);
            }
        }

        return setVals;
    }
}