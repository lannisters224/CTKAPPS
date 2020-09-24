import LightningDatatable from 'lightning/datatable';
import htmlRow from './htmlRow.html';

export default class richTextDataTable extends LightningDatatable {
    static customTypes = {
        htmlCell: {
            template: htmlRow,
            standardCellLayout: true,
            // Provide template data here if needed
            typeAttributes: [],
        }
    };

}