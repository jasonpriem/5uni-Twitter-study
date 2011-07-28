<?php
/**
 * Subtracts one from a long numeric string, getting around PHP's inability
 * to deal with really big ints.
 *
 * @param String $str
 * @return string The string with one subtracted from it.
 */
function strMinusOne($str){
    if (!is_string($str)){
        throw new Exception("arg must be a string");
    }
    $ret = "";
    if (strlen($str) < 11) {
        $ret = (string)($str - 1);
    }
    else {
        $tail = substr($str, -10);
        $head = substr($str, 0, -10);
        $ret = $head . ($tail - 1);
    }
    return $ret;
}
/**
 * Downloads and stores all the tweets of each scholar with a confirmed twitter
 * username (up to Twitter's max allowed).
 *
 * @param Couch_Client $couch
 * @param Zend_Config $config
 */
function getTweets(Couch_Client $couch, Zend_Config $config, $i=0){
    $tweetsPerPage = 200;

    // first, we get a twitter account to retrieve tweets for.
    $response = $couch->limit(1)
            ->include_docs(true)
            ->getView('main', 'missing_tweets');
    $screenName = $response->rows[0]->value;
    $twitterId = (int)$response->rows[0]->key;
    $doc = $response->rows[0]->doc;
    if (!isset($doc->tweets)) $doc->tweets = array();

    // set options for the crawler
    $twitterApiArgs = array(
        'user_id' => $twitterId,
        'trim_user' => 1,
        'include_rts' => 1,
        'count' => $tweetsPerPage
    );

    $oldestTweet = end($doc->tweets);
    if ($oldestTweet){
        $twitterApiArgs['max_id'] = strMinusOne($oldestTweet->id);
    }
        
    
    // instantiate the twitter crawler
    $token = new Zend_Oauth_Token_Access;
    $token->setParams(array(
        'oauth_token' => $config->twitter->accessToken,
        'oauth_token_secret' => $config->twitter->accessTokenSecret
    ));

    $twitter = new MyTwitter(array(
        'consumerKey' => $config->twitter->consumerKey,
        'consumerSecret' => $config->twitter->consumerKeySecret,
        'accessToken' => $token
    ));


    $res = $twitter->status->userTimeline($twitterApiArgs);
    echo date('H:i j M ') . ", scholar ". $doc->_id
            . " ($screenName) with max_id: '{$twitterApiArgs['max_id']}'...";

    $tweets = array();
    $protected = false;
    if (!isset($res->error)){ //no errors, get the tweets
        foreach($res as $v){
            if (!$v->text) { // this is generally an "over capacity" page...
                throw new Exception("Fail: Twitter returned something that's not a tweet...\n");
            }
            $tweets[] = $v;
        }
    }
    elseif ($res->error == 'Not authorized'){ // profile is protected, do nothing
        $protected = true;
    }
    else { // an error we probably care about, like over rate-limit
        throw new Exception("Fail: '" .$res->error. "'\n");
    }

    $doc->tweets = array_merge($doc->tweets, $tweets);
    if (count($tweets) == 0){
        $doc->got_all_tweets = true;
    }
    try {
        $couch->storeDoc($doc);
        echo count($tweets). " tweets saved";
        echo ($protected) ? " (protected).\n" : ".\n";
    }
    catch(Exception $e){
        echo "Couldn't store doc: '{$e->getMessage}'";
    }
    sleep(5);
    return ($i < 7) ? getTweets($couch, $config, $i+1) : true;

}


?>
