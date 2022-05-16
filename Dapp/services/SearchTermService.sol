// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../db/SearchTermDB.sol";

contract SearchTermService {


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
     * If the search term is new (not stored in the db) this methods creates a new search term and return the id (bytes32) of the search term.
     * 
     */
    function get_or_create_search_term(string memory term)
    public
    returns(bytes32 term_id)
    {
        SearchTermDB db = SearchTermDB(db_addr);
        bool exist_flag = db.exist(term);

        if ( exist_flag ) {
            Entities.SearchTerm memory st = db.get(term);
            term_id = st.id;
        } else {
            term_id = db.save(term);
        }
    }

    /**
     * Add a Dπ PID to search term
     *
     * - bytes32 search_term_id
     * - bytes16 pid uuid
     */
    function add_pid_to_search_term(bytes32 search_term_id,bytes16 pid_uuid)
    public
    {
        SearchTermDB db = SearchTermDB(db_addr);
        db.save(search_term_id,pid_uuid);
    }
    
}