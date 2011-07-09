<?php
function findTwitterNames(Couch_Client $couch, Zend_Config $config){
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

        print_r($twitter->user->search("Kaitlin Costello"));


}
?>
