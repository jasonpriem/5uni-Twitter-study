/* 
 * Displays a user_search_results view in a way that makes it quick to judge the
 * match between a certain scholar in our database and the a certain Twitter user.
 */

function (head, req){
    start({
        "headers": {
            "Content-Type": "text/html"
        }
    });
    
    printProperty = function(property){
        var ret = "<dl>";
        ret += "<dt>"+property[0]+"</dt>";
        numValues = property[1].length;
        for (var i=0; i<numValues; i++){
            if (typeof property[1][i] != 'object') { // an object will just be blank
                ret += "<dd>"+property[1][i]+"</dd>";
            }
        }
        ret += "</dl>";
        return ret;
    }

    var toSend = "<style type='text/css'>\n";
    toSend += "h4{color:#fff; background:#999;margin:7em 0 0; clear:both; padding:.2em; font-family:sans-serif;}";
    toSend += "dl{width:33%; float:left; margin:.2em 0 0;}";
    toSend += "dt{font-weight:bold;font-size:1.2em;}";
    toSend += "dd{margin:0;}";
    toSend += "</style>\n";
    send(toSend);

    while(row = getRow()) {
        send("<h4>"+row.key[0]+', '+row.key[1]+"</h4>")
        numProperties = row.value.length;
        for (var i=0; i<numProperties; i++){
            send(printProperty(row.value[i]));
        }
    }
}

