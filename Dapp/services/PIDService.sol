// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../util/EntitiesLib.sol";
import "../db/PID_DB.sol";
import "./SearchTermService.sol";


contract PIDService {


    address private owner;
    address private pid_db_addr;
    address private searchterm_service_addr;


    constructor() {
        owner = msg.sender;
    }

    /**
     * set the PID DB address
     */
    function set_pid_db(address addr) 
    public {
        pid_db_addr = addr;
    }

    /**
     * set the PID DB address
     */
    function set_search_term_service(address addr) 
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
    function assing_uuid()
    public
    returns(bytes16 uuid)
    {
        PID_DB db = PID_DB(pid_db_addr);
        uuid = db.assing_uuid();
    }

    /**
     * Add a SearchTerm to a  Dπ PID.
     * params::
     * - uuid (bytes16)
     * - searchTerm_id (bytes32)
     *
     * case uuid is unsee throws expcetion  :: id does not exist
     */
    function add_search_term(bytes16 uuid,string memory search_term)
    public
    {
        PID_DB db = PID_DB(pid_db_addr);
        SearchTermService sts = SearchTermService(searchterm_service_addr);
        
        Entities.PID memory pid = db.get(uuid);

        bytes32 st_id = sts.get_or_create_search_term(search_term);        

        bool insert_flag = false;
        if (pid.searchTerms.length == 0 ){
            insert_flag = true;
        }

        uint16 i = 0;
        while (!insert_flag || i < pid.searchTerms.length){
            if ( pid.searchTerms[i] == st_id ){
                    insert_flag = true;
                }
            i++;
        }

        if (insert_flag) {
            db.add_search_term(uuid, st_id);
            sts.add_pid_to_search_term(st_id, uuid);
        }
        
    }
    
    
}