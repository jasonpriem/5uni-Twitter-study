/* 
 * Gets docs where there's a scholar who has a twitter username, but all her
 * tweets haven't been stored yet.
 */
function(doc) {
    if (typeof doc.matched_twitter_user != "undefined") {
//        var twitterId = doc.twitter_users[doc.matched_twitter_user]['id'];
//        emit(twitterId, doc.screen_name);
        emit(doc._id,null);
    }
}

