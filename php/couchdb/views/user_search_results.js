/* 
 * Prints the Twitter user accounts returned by a user search, next to the
 * names used as search terms. The idea is that we can compare the search
 * name with the data from each returned account to decide which account (if any)
 * really belongs to the person whose name we searched on.
 */
function (doc){

    valInStr = function(arr, str){
        if (typeof str != "string") return false;
        
        arrCount = arr.length;
        for (var i=0; i<arrCount; i++){
            str = str.toLowerCase();
            if (str.indexOf(arr[i]) > -1) {
                return true
            }
        }
        return false;
    }

    hasWrongOffset = function(user){
        var okOffsets = [
            '0',      // Nottingham
            '-18000', // Brandeis, Dickinson
            '-21600'  // Illinois, Mississippi
        ];
        offsetHasValue = user.utc_offset.__count__;
        offsetIsWrong = (okOffsets.indexOf(user.utc_offset) == -1);        
        return (offsetHasValue && offsetIsWrong);
    }
    hasNoInfo = function(user){
        return (!user.description.__count__ && !user.url.__count__ && !user.location.__count__);
    }
    isBlacklisted = function(user){
        var blacklist = {
            'justinbieber':1,
            'JohnCena':1,
            'Oprah':1,
            'tyrabanks':1,
            'aplusk':1,
            'thalia':1,
            'MissKeriBaby':1,
            'donghae861015':1,
            '106andpark':1,
            'LilTwist':1,
            'DulceMaria':1,
            'IAMQUEENLATIFAH':1,
            'ricky_martin':1,
            'sachin_rt':1,
            'TweetDeck':1,
            'beyonce':1,
            'ebertchicago':1,
            'kevinjonas':1,
            'NellyFurtado':1,
            'luansantana':1
        };
        return (user.screen_name in blacklist);

    }

    isCorrectCity = function(user){
        var cities = [
            'boston',
            'waterton',
            'somerville',
            'cambridge',
            'carlisle',
            'harrisburg',
            'urbana',
            'champaign',
            'oxford',
            'nottingham'
        ];
        return valInStr(cities, user.location)
    }


    descrLooksGood = function(user){
        var criteria = {
            cities: [
            'boston',
            'waterton',
            'somerville',
            'cambridge',
            'carlisle',
            'harrisburg',
            'urbana',
            'champaign',
            'oxford',
            'nottingham'
            ],
            unis: [
            'brandeis',
            'dickinson',
            'illinois',
            'uiuc',
            'miss',
            'nottingham'
            ],
            keywords: [
            'scholar',
            'researcher',
            'professor',
            'student',
            'lecturer',
            'scientist',
            'humanist',
            'phd',
            'postdoc',
            'doctoral',
            'faculty',
            'studying'
            ]
        };
        
        for (var m in criteria){
            if (valInStr(criteria[m], user.description)) {
                return true;
            }
        }
        return false;
    }

    if (typeof doc.twitter_users != "undefined" && doc.is_redundant == 0){
        var numUsers = doc.twitter_users.length;

        // if there are not twitter users, no point in continuing
        // if there are 20, the person's name is too popular, and won't be checked.
        if (numUsers > 0 && numUsers < 20) {
//            emit(doc.name_string, null);
            for (var i=0; i<numUsers; i++){
                var thisUser = doc.twitter_users[i];

                // This user must have some info we can use to judge who she is,
                //   and must not live in the wrong time zone.
                try {
                    if (!hasNoInfo(thisUser) && !hasWrongOffset(thisUser) && !isBlacklisted(thisUser)) {
                        var ret = [
                            [doc.name_string, [thisUser.name, thisUser.screen_name]],
                            [doc.institution, [thisUser.location, thisUser.utc_offset / 3600]],
                            [doc.dept, [thisUser.description, thisUser.url]],

                        ];

                        emit([doc._id, i], ret);
                    }
                }
                catch (e){
                    emit(null, ["error: the user object seems to be malformed", doc.name_string, i]);
                }
            }
        }
    }
}

