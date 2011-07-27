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

        $res = $couch->limit(1)->include_docs(true)->getView("main", "no_twitter_users");
        $doc = $res->rows[0]->doc;
        
        $res = $twitter->user->search($doc->name_string);
        echo date('H:i j M ');
        if (!isset($res->error)){
            
            /* I can't figure out how to get stuff out of Zend_Rest_Client_Response;
             * only thing that works is to iterate over it and make a new users object.
            */
            $twitterUsers = array();
            foreach($res as $v){
                if (!$v->name) { // this is generally an "over capacity" page...
                    echo "Fail: Twitter returned something that's not a Twitter user...\n";
                    return false;
                }
                $twitterUsers[] = $v;
            }
            $doc->twitter_users = $twitterUsers;
            $couch->storeDoc($doc);
            echo count($res->user) . " Twitter users saved for scholar " . $doc->_id . "\n";
            return true;
        } 
        else {
            echo "Fail: " . $res->error . "\n";
            return false;
        }



}
?>
