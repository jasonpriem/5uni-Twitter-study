<?php
/**
 * Downloads and stores all the tweets of each scholar with a confirmed twitter
 * username (up to Twitter's max allowed).
 *
 * @param Couch_Client $couch
 * @param Zend_Config $config
 */
function removeTweets(Couch_Client $couch, Zend_Config $config, $i=0){
    $response = $couch->include_docs(1)->getView('misc', 'with_tweets');
    $changedDocs = array();
    foreach($response->rows as $k => $row){
        $doc = $row->doc;
        unset($doc->tweets);
        unset($doc->got_all_tweets);
        $docs[] = $doc;
    }
    $couch->storeDocs($docs);

}


?>

