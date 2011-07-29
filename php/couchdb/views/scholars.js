/* 
 * Lists all the scholars in the database
 */
function(doc){
    if (typeof doc.name_string == "string") { // the doc describes a scholar
        stringify = function(x){
            if (typeof x == "object") {
                return "";
            }
            else {
                return x;
            }
        }

        if (typeof doc.matched_twitter_user == "number") {
            user = doc.twitter_users[doc.matched_twitter_user];
        }
        else {
            user = false;
        }

        var ret = {
            scholar: doc._id,
            dept: doc.dept,
            institution: doc.institution,
            name: doc.name_string,
            rank: doc.rank,
            superdiscipline: doc.superdiscipline,
            twitter_users_count: doc.twitter_users.length,
            tw_screen_name: (user) ? user.screen_name : "NA",
            tw_protected: (user) ? user['protected'] : "NA",
            tw_followers_count: (user) ? user.followers_count : "NA",
            tw_friends_count: (user) ? user.friends_count : "NA"
        }


        emit(doc._id, ret);
    }
}


