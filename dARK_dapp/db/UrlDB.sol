// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../libs/HitchensUnorderedKeySet.sol";
import "../libs/strings.sol";

import "../util/Entities.sol";
// import {Entities.Person} from "./libs/EntitiesLib.sol";

contract UrlDB
 {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    
    
    HitchensUnorderedKeySetLib.Set url_set;

    address private owner;
    mapping(bytes32 => Entities.URL) private url_db;
    
    // UnorderedKeySetLib.Set pid_set;
    // mapping(bytes16 => Entities.PID) private pid_db;
    mapping(bytes32 => HitchensUnorderedKeySetLib.Set) private pid_set;

    // logs
    event createURL(bytes32 indexed url_id,string indexed url, bytes32 indexed pid_hash, address owner);
    event link_pid_2_url(bytes32 url_id, bytes32 pid_hash, address user);


    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        //usar para controle de acesso
        owner = msg.sender; 
    }

    /**
     * Save a serarch term.
     * every word will be saved as upper case
     *
     *
     * - word : search term
     * - return id of the searth term
    **/
    function save(string memory word, bytes32 pid_hash)
    public 
    returns(bytes32)
    {
        word = strings.upper(word);
        bytes32 id = keccak256(abi.encodePacked(word));
        //Note: it will fail automatically if the key already exists.
        url_set.insert(id); 
        
        Entities.URL storage p = url_db[id];
        p.id = id;
        p.url = word;
        p.owner = tx.origin;

        HitchensUnorderedKeySetLib.Set storage pids = pid_set[id];
        if ( !pids.exists(pid_hash) ) {
            pids.insert(pid_hash);
            emit link_pid_2_url(id, pid_hash, tx.origin);
        }

        emit createURL(id, word, pid_hash, msg.sender);
        return id;
    }

    /**
     * Check if a search term exist in the database
     *
     * - return true of false
     */
    function exist(string memory word)
    public view 
    returns(bool status) {
        status = url_set.exists( keccak256(abi.encodePacked(strings.upper(word))) );
    }

    /**
     * Return a researcher for a given id
     * - return (string nome, address owner)
     */
    function get(bytes32 _id) 
    public view 
    returns(Entities.URL memory st) {
        require(url_set.exists(_id), "Can't retrive a search term that doesn't exist.");
        
        // Entities.URL storage term = url_db[_id];
        return url_db[_id];
    }

    /**
     * Return a researcher for a given id
     * - return (string nome, address owner)
     */
    function get(string memory word) 
    public view 
    returns(Entities.URL memory term) {
        word = strings.upper(word);
        bytes32 _id = keccak256(abi.encodePacked(word));
        return get(_id);
    }

    /**
     * Return the SearchTerm id at a especific index position
     */
    function get_by_index(uint256 index) public view returns(bytes32 key) {
        return url_set.keyAtIndex(index);
    }

    /**
     * count the number of SearchTerm
     */
    function count() public view returns(uint256) {
        return url_set.count();
    }

    /**
     * get pids (bytes16 pid_hash) from a search_term
     *
     */
    function get_pids(bytes32 url_id)
    public view
    returns ( bytes32[] memory uuids)
    {
        get(url_id);
        HitchensUnorderedKeySetLib.Set storage pids = pid_set[url_id];

        uint256 num = pids.count();
        bytes32[] memory uuid_list = new bytes32[](num);

        for ( uint i = 0; i < num ; i++){
            uuid_list[i] = pids.keyAtIndex(i);
        }

        return uuid_list;
    }
    
}