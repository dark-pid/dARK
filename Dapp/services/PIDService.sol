// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

//db
import "../util/Entities.sol";
import "../db/PidDB.sol";
//services
import "./SearchTermService.sol";
import "./ExternalPIDService.sol";


contract PIDService {

    address private owner;
    address private pid_db_addr;
    address private searchterm_service_addr;
    address private externalpid_service_addr;

    constructor() {
        owner = msg.sender;
    }

    /**
     * set the PID DB address
     */
    function set_db(address addr) 
    public {
        pid_db_addr = addr;
    }

    /**
     * set the PID DB address
     */
    function set_externalpid_service(address addr) 
    public {
        externalpid_service_addr = addr;
    }

    /**
     * set the PID DB address
     */
    function set_searchterm_service(address addr) 
    public {
        searchterm_service_addr = addr;
    }

    //
    // Methods
    //

    /**
     *  Assing a new Dπ uuid to the tx.origin
     *  - return uuid (bytes19)
     */
    function assingUUID()
    public
    returns(bytes16 uuid)
    {
        PidDB db = PidDB(pid_db_addr);
        uuid = db.assing_uuid();
    }

    /**
     * Add a SearchTerm to a  Dπ PID.
     * params::
     * - uuid (bytes16)
     * - searchTerm (string)
     *
     * case uuid is unsee throws expcetion  :: id does not exist
     */
    function addSearchTerm(bytes16 uuid,string memory search_term)
    public
    {
        PidDB db = PidDB(pid_db_addr);
        SearchTermService sts = SearchTermService(searchterm_service_addr);
        
        // Entities.PID memory pid = db.get(uuid);

        bytes32 st_id = sts.get_or_create_search_term(search_term);        

        bool insert_flag = true;
        // bool insert_flag = false;
        // if (pid.searchTerms.length == 0 ){
        //     insert_flag = true;
        // }

        // while (!insert_flag || i < pid.searchTerms.length){
        // for (uint16 i = 0; i < pid.searchTerms.length - 1; i++) {
        //     if ( pid.searchTerms[i] == st_id ){
        //             insert_flag = false;
        //         }
        //     i++;
        // }

        if (insert_flag) {
            db.add_searchTerm(uuid, st_id);
            sts.add_pid_to_search_term(st_id, uuid);
        }
        
    }

    /**
     * Add a ExternalPID to a Dπ PID.
     * params::
     * - uuid (bytes16)
     * - schema (string)
     * - external_pid (string)
     *
     * case uuid is unsee throws expcetion  :: id does not exist
     */
    function addExternalPid(bytes16 uuid,string memory schema,string memory external_pid)
    public
    {
        //TODO: validar os schemas
        PidDB db = PidDB(pid_db_addr);
        ExternalPIDService epid_service = ExternalPIDService(externalpid_service_addr);

        db.get(uuid); //valida o uuid
        bytes32 epid_id = epid_service.get_or_create_externalPid(schema,external_pid,uuid);

        db.add_externalPid(uuid,epid_id);
    }

    /**
     * set Dπ PID payload.
     * params::
     * - uuid (bytes16)
     * - payload (string)
     *
     * case uuid is unsee throws expcetion  :: id does not exist
     *
     */
    function set_payload(bytes16 uuid,string memory pid_payload)
    public
    {
        PidDB db = PidDB(pid_db_addr);
        db.set_payload(uuid, pid_payload);
    }

    /**
     * Add a externalLinks to a  Dπ PID.
     * params::
     * - uuid (bytes16)
     * - url (string)
     *
     * case uuid is unsee throws expcetion  :: id does not exist
     *
     */
    function add_externalLinks(bytes16 uuid,string memory url)
    public
    {
        PidDB db = PidDB(pid_db_addr);
        db.set_payload(uuid, url);
    }
    
    
}