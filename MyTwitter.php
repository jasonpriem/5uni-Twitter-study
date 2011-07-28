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

}
?>
