/* 
 * lists all the tweets in the database, by scholar ID
 */
function(doc){
    if (typeof doc.tweets == "object"){
        for (i in doc.tweets){
            var thisTweet = doc.tweets[i];
            var value = {
                id: thisTweet.id,
                scholar: doc._id,
                created_at: thisTweet.created_at,
                text: thisTweet.text
            }
            emit([doc._id, thisTweet.id], value);
        }
    }
}

