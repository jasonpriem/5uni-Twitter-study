<?php
/**
 * The twitter_scholars.txt file has a list of those scholars that we've been
 * able to positively connect to a twitter user, and the key of that user.
 *
 * This function parses that file, then uploads that data to the database.
 *
 * @param Couch_Client $couch
 * @param Zend_Config $config
 */
function putTwitterScholarsListInDB(Couch_Client $couch, Zend_Config $config){
    $filename = '../twitter_scholars.txt';

    $str = file_get_contents($filename);
    $rows = explode("\n", $str);
    $names = array();
    foreach ($rows as $k => $row){
        $parts = explode(",", $row);
        $id = $parts[0];
        $twitterUser = (int)$parts[1];
        echo "storing user $id (matched_twitter_user = $twitterUser)...";

        $doc = $couch->getDoc($id);
        $doc->matched_twitter_user = $twitterUser;
        $response = $couch->storeDoc($doc);
        echo $response->id . " has been stored<br />\n";
    }
}
?>
