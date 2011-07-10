<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>5uni_twitter</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body>
      <h1>5uni Twitter study</h1>
      <pre>
        <?php
        set_time_limit(600);
        require_once("./bootstrap.php");
        require_once("./populateDatabase.php");
        require_once("./makeDesignDoc.php");
        require_once("./findTwitterNames.php");
        $config = new Zend_Config_Ini(CONFIG_PATH);
        $couch = new Couch_Client($config->db->dsn, $config->db->name);
        
        /* put the text file names in the database
         */
//        populateDatabase($couch, $config);
        
        /*setup the database queries we can use
         */
//        makeDesignDoc($couch, $config);
        
        /* print a list of the duplicated names; we'll manually go through these and
         * figure out which ones are redundant with others and mark them accordingly
         * using Futon, the CouchDB UI.
         */
//        echo $couch->getList("main", "dupes_form", "names");

        /* search the twitter user/search API to find twitter names based on people's
         * real names; for each person, add the list of possible Twitter matches
         * to their name in the DB.
         */
        for ($i=0; $i<60; $i++){
            findTwitterNames($couch, $config);
            
        }
        







      ?>

      </pre>
  </body>
</html>
