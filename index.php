<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>5uni_twitter</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body>
      <h1>5uni Twitter study</h1>
        <?php
        require_once("./bootstrap.php");
        $scholarsDir = realpath(APP_PATH . '/..');
        $config = new Zend_Config_Ini(CONFIG_PATH);

        $couch = new Couch_Client($config->db->dsn, $config->db->name);
        $parser = new HumanNameParser_Parser();
        
        /***********************************************************************
         * populate the database
         **********************************************************************/

        $scholar = new Scholar($couch);
        $list = new ScholarsList($scholar, $parser);
        //      $list->uploadFileToDB($scholarsDir . '/' . 'all_scholars.txt', 0);
        
        /***********************************************************************
         * make the indexes and lists
         **********************************************************************/    
        
        // get the views
        $namesView = file_get_contents(APP_PATH . '/couchdb/views/names.js');
        $dupesFormList = file_get_contents(APP_PATH . '/couchdb/lists/dupes_form.js');

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


        






      ?>


  </body>
</html>
