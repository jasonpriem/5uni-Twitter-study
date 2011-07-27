<?php
/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of MyTwitter
 *
 * @author jason
 */
class MyTwitter extends Zend_Service_Twitter {
    /**
     * Find users that match a name string
     *
     * @param  string $name A person's name
     * @param bool $lite Whether to return statuses along with the returned user objects
     * @throws Zend_Http_Client_Exception if HTTP request fails or times out
     * @return Zend_Rest_Client_Result
     */
    public function userSearch($name, $lite = true)
    {
        $this->_init();
        $path = '/1/users/search.xml';
        $response = $this->_get($path, array(
            'q'=>$name,
            'skip_status'=>$lite
            ));
        return new Zend_Rest_Client_Result($response->getBody());
    }
    /**
     * User Timeline status
     *
     * $params may include one or more of the following keys
     * - id: ID of a friend whose timeline you wish to receive
     * - since_id: return results only after the tweet id specified
     * - page: return page X of results
     * - count: how many statuses to return
     * - max_id: returns only statuses with an ID less than or equal to the specified ID
     * - user_id: specifies the ID of the user for whom to return the user_timeline
     * - screen_name: specfies the screen name of the user for whom to return the user_timeline
     * - include_rts: whether or not to return retweets
     * - trim_user: whether to return just the user ID or a full user object; omit to return full object
     * - include_entities: whether or not to return entities nodes with tweet metadata
     *
     * @throws Zend_Http_Client_Exception if HTTP request fails or times out
     * @return Zend_Rest_Client_Result
     */
    public function statusUserTimeline(array $params = array())
    {
        $this->_init();
        $path = '/1/statuses/user_timeline';
        $_params = array();
        foreach ($params as $key => $value) {
            switch (strtolower($key)) {
                case 'id':
                    $path .= '/' . $value;
                    break;
                case 'page':
                    $_params['page'] = (int) $value;
                    break;
                case 'count':
                    $count = (int) $value;
                    if (0 >= $count) {
                        $count = 1;
                    } elseif (200 < $count) {
                        $count = 200;
                    }
                    $_params['count'] = $count;
                    break;
                case 'user_id':
                    $_params['user_id'] = $this->_validInteger($value);
                    break;
                case 'screen_name':
                    $_params['screen_name'] = $this->_validateScreenName($value);
                    break;
                case 'since_id':
                    $_params['since_id'] = $this->_validInteger($value);
                    break;
                case 'max_id':
                    $_params['max_id'] = $this->_validInteger($value);
                    break;
                case 'include_rts':
                case 'trim_user':
                case 'include_entities':
                    $_params[strtolower($key)] = $value ? '1' : '0';
                    break;
                default:
                    break;
            }
        }
        $path .= '.xml';
        $response = $this->_get($path, $_params);
        return new Zend_Rest_Client_Result($response->getBody());
    }
}
?>
