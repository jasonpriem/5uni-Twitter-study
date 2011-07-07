<?php
function populateDatabase(Couch_Client $couch, Zend_Config $config){

    $parser = new HumanNameParser_Parser();
    $scholar = new Scholar($couch);
    $list = new ScholarsList($scholar, $parser);

    // sometimes this dies in the middle and you have to manually enter the line
    //     and id you want to finish from.
    $list->uploadFileToDB(realpath( APP_PATH . '/../' . 'all_scholars.txt'));

}
?>
