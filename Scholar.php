<?php
/**
 * Does stuff with a scholar's name
 * I think this is basically a decorator
 *
 * @author jason
 */
class Scholar {
    private $couch;
    private $_id;
    private $_rev;
    private $dept;
    private $institution;
    private $superdiscipline;
    private $rank;
    private $name_string;
    private $name_obj;
    private $is_redundant;


    function __construct(Couch_Client $couch) {
        $this->couch = $couch;
    }




    public function save(){
        $vars = get_object_vars($this);
        $doc = new stdClass();
        foreach ($vars as $k => $v){
            // _id and _rev are allowed to be empty or null; nothing else is.
            if ($k == "_id" || $k == "_rev") {
                // doesn't matter, if they're blank the DB will set 'em.
            }
            elseif (!isset($k) || $k === ''){
                throw new Exception("You're trying to save this object without '$k' being set: <br>" . print_r($this, true));
            }

            if ($k != 'couch'){
                $doc->$k = $v;
            }
        }

        $this->couch->storeDoc($doc);
    }

    public function reset(){
        $vars = get_object_vars($this);
        foreach ($vars as $k=>$v){
            if ($k != 'couch') {
                unset($this->$k);
            }
        }
    }

    public function setPropertiesFromObj(stdClass $obj){
        $vars = get_object_vars($obj);
        foreach ($vars as $k => $v){
            if (!property_exists($this, $k)){
                throw new Exception("The supplied data object has a property that the Scholar object doesn't: $k");
            }
            $this->$k = $v;
        }
    }

    public function getCouchDoc() {
        return $this->couchDoc;
    }
    public function setCouch($couch) {
        $this->couch = $couch;
    }

    public function set_id($_id) {
        $this->_id = $_id;
    }

    public function set_rev($_rev) {
        $this->_rev = $_rev;
    }

    public function setDept($dept) {
        $this->dept = $dept;
    }

    public function setInstitution($institution) {
        $this->institution = $institution;
    }

    public function setSuperdiscipline($superdiscipline) {
        $this->superdiscipline = $superdiscipline;
    }

    public function setRank($rank) {
        $this->rank = $rank;
    }

    public function setName_string($name_string) {
        $this->name_string = $name_string;
    }

    public function setName_obj($name_obj) {
        $this->name_obj = $name_obj;
    }

    public function setIs_redundant($is_redundant) {
        $this->is_redundant = $is_redundant;
    }










}
?>
