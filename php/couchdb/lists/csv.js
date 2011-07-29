/* 
 * prints a set of values from a veiw as csv-formatted rows.
 */
function(head, req){
    objToStr = function(obj){
        ret = '';
        for (i in obj){
            val = obj[i];
            if (typeof val == "string"){
                val = val.replace(/"/g, '""'); // escape quotes
                val = '"'+val+'"';
            }
            
            ret += (ret) ? ','+val : val;
        }
        return ret;
    }
    printHeader = function(obj){
        ret = '';
        for (i in obj){
            label = '"'+i+'"';
            ret += (ret) ? ','+label : label;
        }
        return ret;
    }

    start({
        "headers": {
            "Content-Type": "text/html; charset=utf-8"
        }
    });
    var firstRow = true;
    while (row = getRow()){
        if (firstRow) send(printHeader(row.value) + "\n");
        send(objToStr(row.value) + "\n");
        firstRow = false;
    }

}


