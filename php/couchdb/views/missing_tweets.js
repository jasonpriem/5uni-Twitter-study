/* 
 * Gets docs where there's a scholar who has a twitter username, but all her
 * tweets haven't been stored yet.
 */
function(doc) {
    if (typeof doc.matched_twitter_user != "undefined" && !doc.got_all_tweets) {
        var user = doc.twitter_users[doc.matched_twitter_user];
        emit(user.id, user.screen_name);
    }
}

