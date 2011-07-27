<?php
/**
 * Downloads and stores all the tweets of each scholar with a confirmed twitter
 * username (up to Twitter's max allowed).
 *
 * @param Couch_Client $couch
 * @param Zend_Config $config
 */
function getTweets(Couch_Client $couch, Zend_Config $config){
    $doc = $couch->getDoc($id);
    $doc->matched_twitter_user = $twitterUser;
    $couch->storeDoc($doc);
}
?>
