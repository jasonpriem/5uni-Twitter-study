<?php
function makeDesignDoc(Couch_Client $couch, Zend_Config $config){
    // get the views
    $namesView = file_get_contents(APP_PATH . '/couchdb/views/names.js');
    $dupesFormList = file_get_contents(APP_PATH . '/couchdb/lists/dupes_form.js');
    $dupesFormList = str_replace("[FUTON_URL]", $config->db->futonUrl, $dupesFormList);

    // get the CouchDB design doc
    try {
        $doc = new Couch_Document($couch);
        $doc->_id = "_design/main";
    }
    catch (Exception $e){ // it's already been created, we need to update it
        $doc = Couch_Document::getInstance($couch, "_design/main");
    }

    // set the design doc
    $doc->set(
        array(
            "views" => array("names" => array("map" => $namesView)),
            "lists" => array("dupes_form" => $dupesFormList)
            )
    );
}

?>
