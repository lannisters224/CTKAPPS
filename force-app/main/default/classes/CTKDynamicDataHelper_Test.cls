@isTest
public class CTKDynamicDataHelper_Test {
    static testMethod void getSobjectData_Test(){
        Contact c=new Contact(
            FirstName='fname',
            LastName = 'lname',
            Email = 'email@gmail.com',
            Phone = '9743800309'); 
        insert c;
        Integer maxRecords = 5 ;
        test.startTest();
        Exception unexpectedException;
        try
        {
            // some operation that should not throw
            CTKDynamicDataHelper.getSobjectData('Contact', 'ActiveContacts', 'Name=\'[Name]\'', c.Id, '', false, maxRecords); 
        	CTKDynamicDataHelper.getSobjectFields('Contact', 'ActiveContacts');
        }
        catch (Exception e)
        {
            unexpectedException = e;
        } 
        test.stopTest();
		system.assertEquals(null, unexpectedException, '<message>');
        
    }
}