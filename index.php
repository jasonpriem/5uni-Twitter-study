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
      $scholarsDir = realpath(APP_PATH . '/../scholars');
      $config = new Zend_Config_Ini(CONFIG_PATH);
      
      $couch = new Couch_Client($config->db->dsn, $config->db->name);
      $parser = new HumanNameParser_Parser();

      $scholar = new Scholar($couch);
      $list = new ScholarsList($scholar, $parser);
      $list->uploadDirToDB($scholarsDir);

//      $list->uploadFileToDB($scholarsDir . '/' . 'Brandeis_scholars.txt', 0);




      ?>


  </body>
</html>
