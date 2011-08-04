/* 
 * lists all the tweets in the database, by scholar ID
 * 
 * This has a bug in it: it doesn't filter out tweets from redundant scholars.
 * In practice, this wasn't a problem as none of the redundant scholars had
 * Twitter accts, so I'm leaving it as is for now (Jason, 4 Aug)
 */
function(doc){
    if (typeof doc.tweets == "object"){
        for (i in doc.tweets){
            var thisTweet = doc.tweets[i];
            var value = {
                id: thisTweet.id,
                scholar_id: doc._id,
                created_at: thisTweet.created_at,
                text: thisTweet.text
            }
            emit([doc._id, thisTweet.id], value);
        }
    }
}

