/* 
 * Gets documents that don't have the  twitter_users field.
 */
function(doc){
    if (typeof doc.twitter_users == "undefined") {
        emit(doc.id, null)
    }
}

