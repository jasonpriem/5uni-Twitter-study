<?php
/**
 * Downloads and stores all the tweets of each scholar with a confirmed twitter
 * username (up to Twitter's max allowed).
 *
 * @param Couch_Client $couch
 * @param Zend_Config $config
 */
function getTweets(Couch_Client $couch, Zend_Config $config, $i=0){
    $tweetsPerPage = 100;
    $response = $couch->limit(1)
            ->include_docs(true)
            ->getView('main', 'missing_tweets');
    $screenName = $response->rows[0]->value;
    $twitterId = (int)$response->rows[0]->key;
    $doc = $response->rows[0]->doc;
    $pageToGet = (isset($doc->tweets)) ? count($doc->tweets) / $tweetsPerPage +1 : 1;
    if (round($pageToGet) != $pageToGet) {
        throw new Exception("The last twitter search got less than a full page");
    }
    if (!isset($doc->tweets)) $doc->tweets = array();
        
    
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

    $options = array(
        'user_id' => $twitterId,
        'trim_user' => 1,
        'count' => $tweetsPerPage,
        'page' => $pageToGet
    );
    $res = $twitter->status->userTimeline($options);
    echo date('H:i j M ') . " scholar ". $doc->_id . " ($screenName): ";

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
    if (count($tweets) < $tweetsPerPage){
        $doc->got_all_tweets = true;
    }
    echo count($tweets). " tweets on page $pageToGet saved";
    echo ($protected) ? " (protected).\n" : ".\n";
    $couch->storeDoc($doc);    
    sleep(5);
    return ($i < 7) ? getTweets($couch, $config, $i+1) : true;

}


?>
