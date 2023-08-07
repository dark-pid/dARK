// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../db/UrlDB.sol";
import "../util/Entities.sol";

contract UrlService {


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
    function get_or_create_url(string memory url, bytes32 pid_hash)
    public
    returns(bytes32 url_id)
    {
        UrlDB db = UrlDB(db_addr);
        bool exist_flag = db.exist(url);

        if ( exist_flag ) {
            Entities.URL memory st = db.get(url);
            url_id = st.id;
        } else {
            url_id = db.save(url,pid_hash);
        }
    }


    function get(bytes32 url_id)
    public view
    returns(Entities.URL memory url_obj)
    {
        UrlDB db = UrlDB(db_addr);
        Entities.URL memory url_obj = db.get(url_id);
    }

    
    
}