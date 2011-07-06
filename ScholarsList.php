<?php
/**
 * Handles a list of scholars
 *
 * @author jason
 */
class ScholarsList {
    private $scholar;
    private $parser;

    function __construct(Scholar $scholar, HumanNameParser_Parser $parser) {
        $this->scholar = $scholar;
        $this->parser = $parser;
    }

    public function uploadFileToDB($loc){
        $namesInThisFile = 0;
        $str = file_get_contents($loc);
        $lines = preg_split("/\r\n|\r|\n/", $str);
        $dept = '';
        foreach ($lines as $k => $line){
            $lineNumber  = $k + 1;

            $this->scholar->reset();
            if (preg_match('/^\*\* \w/', $line)){ // this line indicates the department
                echo "line $lineNumber: $line<br>";
                $dept = substr($line, 3);
            }
            elseif(strpos($line, '*') === false && strpos($line, '|')) { // it's a line with scholar data
                $namesInThisFile++;
                $id = str_pad($namesInThisFile, 5, "0", STR_PAD_LEFT);
                echo "now parsing line $lineNumber (id: $id): $line...<br>";
                $fields = explode('|', $line);
                
                $this->scholar->setDept($dept);
                $this->scholar->setInstitution($fields[0]);
                $this->scholar->setSuperdiscipline($fields[1]);
                $this->scholar->setRank($fields[2]);
                $this->scholar->setIs_duplicated(false);
                $this->scholar->setIs_redundant(false);
                $this->scholar->setName_string($fields[3]);
                $this->scholar->set_id($id);

                $this->parser->setName($fields[3]);
                $this->scholar->setName_obj($this->parser->getArray());

                $this->scholar->save();
            }
            else { // it's a blank or comment line, do nothing
            }
        }
        return $namesInThisFile;

    }
}
?>
