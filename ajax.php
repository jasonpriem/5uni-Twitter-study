<?php
require_once './bootstrap.php';
$config = new Zend_Config_Ini(CONFIG_PATH);
$couch = new Couch_Client($config->db->dsn, $config->db->name);


$id = strip_tags($_GET['setRedundant']);
$doc = $couch->getDoc($id);
$doc->is_redundant = 1;
$couch->storeDoc($doc);
echo "1";








?>
