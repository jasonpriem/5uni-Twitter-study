<?php
/**
 * Downloads and stores all the tweets of each scholar with a confirmed twitter
 * username (up to Twitter's max allowed).
 *
 * @param Couch_Client $couch
 * @param Zend_Config $config
 */
function getTweets(Couch_Client $couch, Zend_Config $config){
    $response = $couch->limit(1)
            ->include_docs(true)
            ->getView('main', 'missing_tweets');
    $screenName = $response->rows[0]->value;
    $twitterId = $response->rows[0]->key;
    $doc = $response->rows[0]->doc;
    
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

    $res = $twitter->status->publicTimeline('k8lin');
    echo date('H:i j M ');

    print_r($res);
}
?>
