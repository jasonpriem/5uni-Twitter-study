<?php
function makeDesignDoc(Couch_Client $couch, Zend_Config $config){
    // get the views
    $namesView = file_get_contents(APP_PATH . '/couchdb/views/names.js');
    $no_twitter_usersView = file_get_contents(APP_PATH . '/couchdb/views/no_twitter_users.js');
    $user_search_resultsView = file_get_contents(APP_PATH . '/couchdb/views/user_search_results.js');
    $missing_tweetsView = file_get_contents(APP_PATH . '/couchdb/views/missing_tweets.js');
    $tweetsView = file_get_contents(APP_PATH . '/couchdb/views/tweets.js');
    $scholarsView = file_get_contents(APP_PATH . '/couchdb/views/scholars.js');

    // get lists
    $dupesFormList = file_get_contents(APP_PATH . '/couchdb/lists/dupes_form.js');
    $dupesFormList = str_replace("[FUTON_URL]", $config->db->futonUrl, $dupesFormList);
    $judge_user_search_resultsList = file_get_contents(APP_PATH . '/couchdb/lists/judge_user_search_results.js');
    $csvList = file_get_contents(APP_PATH . '/couchdb/lists/csv.js');

    // get the CouchDB design doc
    try {
        $doc = new Couch_Document($couch);
        $doc->_id = "_design/main";
    }
    catch (Exception $e){ // it's already been created, we need to update it
        $doc = Couch_Document::getInstance($couch, "_design/main");
    }

    // set the design doc
    $doc->set(
        array(
            "views" => array(
                "names" => array("map" => $namesView),
                "no_twitter_users" => array("map" => $no_twitter_usersView),
                "user_search_results" => array("map" => $user_search_resultsView),
                "missing_tweets" => array("map" => $missing_tweetsView),
                "tweets" => array("map" => $tweetsView),
                "scholars" => array("map" => $scholarsView)
                ),
            "lists" => array(
                "dupes_form" => $dupesFormList,
                "judge_user_search_results" => $judge_user_search_resultsList,
                "csv" => $csvList
                )
            )
    );
}

?>