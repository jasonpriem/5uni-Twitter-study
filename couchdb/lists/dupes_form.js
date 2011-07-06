/* here is a comment */
function(head, req){
    var dupes = {
        "key":"",
        "values":[],
        "print":function(){
            var ret = "";
            for (i in this.values){
                ret += toJSON(this.values[i]) + "\n";
            }
            return ret + "\n";
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

    while(row = getRow()) {
        var thisKeyStr = toJSON(row.key);
        dupes.setKey(thisKeyStr, row.value);
    }
}
