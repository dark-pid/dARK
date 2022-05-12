// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../db/ExternalPidDB.sol";

contract ExternalPIDService {


    address private owner;
    address private db_addr;
    
    constructor() {
        owner = msg.sender;
    }

    /**
     * set the PID DB address
     */
    function set_db(address addr) 
    public {
        db_addr = addr;
    }

    /**
     * If the ExternalPID is new (not stored in the db) this methods creates a new search term and return the id (bytes32) of the search term.
     * 
     */
    function get_or_create_externalPid(string memory schema,string memory pid,bytes16 dpi_uuid)
    public
    returns(bytes32 term_id)
    {
        ExternalPidDB db = ExternalPidDB(db_addr);
        
        bool exist_flag = db.exist(pid);

        if ( exist_flag ) {
            Entities.ExternalPID memory epid = db.get(pid);
            term_id = epid.id;
        } else {
            term_id = db.save(schema,pid,dpi_uuid);
        }
    }
    
}