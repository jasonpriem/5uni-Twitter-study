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
                var nameStyle = "normal";
                var closeImg = "./close.png";
                if (this.values[i].is_redundant) {
                    nameStyle = "strike";
                    closeImg = "./close-inactive.png"
                }
                var name =  this.values[i].name_string;
                var id = this.values[i]._id;

                ret += "<li class='"+nameStyle+"' id='"+id+"'>";
                ret += "<a href='#' class='db'><img src='"+closeImg+"' /></a> ";
                ret += "<strong><a href='[FUTON_URL]" +id+ "'>" +name+ "</a></strong>";
                ret += ", <span>"+ this.values[i].institution +"</span> ";
                ret += " <span>"+ this.values[i].rank +"</span> ";
                ret += " in <span>"+ this.values[i].dept +"</span> ";
                ret += " <span><em>("+ this.values[i].superdiscipline +")</em></span> ";
                ret += " <small><a href='http://www.google.com/search?ie=UTF-8&oe=UTF-8&sourceid=navclient&gfns=1&q=\"";
                ret += name +"\" "+ this.values[i].institution +"'>google</a></small> ";
                ret += "</li>";
            }
            return ret + "</ul>";
        },
        "setKey":function(newKey, value){
            var printed = false;
            if (newKey == this.key) {
                this.values.push(value);
            }
            else {
                if (this.values.length > 1) {
                    send(this.print());
                    printed = true;
                }
                this.values = [value];
                this.key = newKey;
            }
            return printed;
        }
    };
    start({
        "headers": {
            "Content-Type": "text/html"
        }
    });

    var toSend = "<style type='text/css'>.strike{text-decoration:line-through;color:#ccc;}\n";
    toSend += ".strike a{color:#ccc;}\n";
    toSend += "li {list-style:none}\n";
    toSend += "</style>\n";
    toSend += "<script type='text/javascript' src='https://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js'></script>\n";
    toSend += "<script type='text/javascript'>\n"
    toSend += "$(document).ready(function(){\n"
    toSend += "   $('a.db').click(function(){\n"
    toSend += "      var id = $(this).parent().attr('id');\n"
    toSend += "      $(this).replaceWith(\"<img src='./ajax-loader.gif' class='loader'/>\")\n";
    toSend += "      $.get('./ajax.php?setRedundant='+id, function(d){\n"
    toSend += "         if (d === '1') {$('#'+id).addClass('strike')}\n"
    toSend += "         else {alert('problem with database: '+d); return false;}\n"
    toSend += "         $('.loader').replaceWith(\"<img src='./close-inactive.png' />\")\n";
    toSend += "         return true;"
    toSend += "      });\n"
    toSend += "      return false;\n"
    toSend += "   });\n"
    toSend += "});\n"
    toSend += "</script>\n"
    send(toSend);

    var printed = false;
    while(row = getRow()) {
        var thisKeyStr = toJSON(row.key);
        printed = dupes.setKey(thisKeyStr, row.value);
    }
}
