/* Prints out the duplicated names nice and pretty so we can manually decide which
 *     are redundant, and which are actually seperate people.
 *
 * This will NOT WORK AS IS;
 * the [FUTON_URL] token must be replaced with the URL where you access
 *     futon for this installation of CouchDB.
 */

function(head, req){
    var dupes = {
        "key":"",
        "values":[],
        "print":function(){
            var ret = "<ul>";
            for (i in this.values){
                var name =  this.values[i].name_string;
                var id = this.values[i]._id;
                ret += "<li>";
                ret += ("<strong><a href='[FUTON_URL]" +id+ "'>" +name+ "</a></strong>");
                ret += (", <span>"+ this.values[i].institution +"</span> ");
                ret += (" <span>"+ this.values[i].rank +"</span> ");
                ret += (" in <span>"+ this.values[i].dept +"</span> ");
                ret += (" <span><em>("+ this.values[i].superdiscipline +")</em></span> ");
                ret += "</li>";
            }
            return ret + "</ul>";
        },
        "setKey":function(newKey, value){
            if (newKey == this.key) {
                this.values.push(value);
            }
            else {
                if (this.values.length > 1) {
                    send(this.print());
                }
                this.values = [value];
                this.key = newKey;
            }
        }
    };
    start({
        "headers": {
            "Content-Type": "text/html"
        }
    });


    while(row = getRow()) {
        var thisKeyStr = toJSON(row.key);
        dupes.setKey(thisKeyStr, row.value);
    }
}
