// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../libs/HitchensUnorderedKeySet.sol";
import "../libs/strings.sol";

import "../util/Entities.sol";
// import {Entities.Person} from "./libs/EntitiesLib.sol";

contract SearchTermDB
 {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    
    
    HitchensUnorderedKeySetLib.Set searchterm_set;

    address private owner;
    mapping(bytes32 => Entities.SearchTerm) private searchterm_db;
    
    // UnorderedKeySetLib.Set pid_set;
    // mapping(bytes16 => Entities.PID) private pid_db;
    mapping(bytes32 => HitchensUnorderedKeySetLib.Set) private pid_set;

    // logs
    event createSearchTerm(bytes32 indexed id,string indexed word, address indexed owner);
    event addPID2SearchTerm(bytes32 search_word_id, bytes32 pid_uuid, address user);


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
    function save(string memory word)
    public 
    returns(bytes32)
    {
        word = strings.upper(word);
        bytes32 id = keccak256(abi.encodePacked(word));
        //Note: it will fail automatically if the key already exists.
        searchterm_set.insert(id); 
        
        Entities.SearchTerm storage p = searchterm_db[id];
        p.id = id;
        p.word = word;
        p.owner = tx.origin;

        emit createSearchTerm(id, word, msg.sender);
        return id;
    }

    /**
     * save pid (bytes16 pid_uuid) to a a search term set
     *
     */
    function save(bytes32 search_word_id, bytes32 pid_uuid)
    public 
    {
        get(search_word_id);
        
        HitchensUnorderedKeySetLib.Set storage pids = pid_set[search_word_id];
        if ( !pids.exists(pid_uuid) ) {
            pids.insert(pid_uuid);
            emit addPID2SearchTerm(search_word_id, pid_uuid, tx.origin);
        }
    }

    /**
     * Check if a search term exist in the database
     *
     * - return true of false
     */
    function exist(string memory word)
    public view 
    returns(bool status) {
        status = searchterm_set.exists( keccak256(abi.encodePacked(strings.upper(word))) );
    }

    /**
     * Return a researcher for a given id
     * - return (string nome, address owner)
     */
    function get(bytes32 _id) 
    public view 
    returns(Entities.SearchTerm memory st) {
        require(searchterm_set.exists(_id), "Can't retrive a search term that doesn't exist.");
        
        // Entities.SearchTerm storage term = searchterm_db[_id];
        return searchterm_db[_id];
    }

    /**
     * Return a researcher for a given id
     * - return (string nome, address owner)
     */
    function get(string memory word) 
    public view 
    returns(Entities.SearchTerm memory term) {
        word = strings.upper(word);
        bytes32 _id = keccak256(abi.encodePacked(word));
        return get(_id);
    }

    /**
     * Return the SearchTerm id at a especific index position
     */
    function get_by_index(uint256 index) public view returns(bytes32 key) {
        return searchterm_set.keyAtIndex(index);
    }

    /**
     * count the number of SearchTerm
     */
    function count() public view returns(uint256) {
        return searchterm_set.count();
    }

    /**
     * get pids (bytes16 pid_uuid) from a search_term
     *
     */
    function get_pids(bytes32 search_word_id)
    public view
    returns ( bytes32[] memory uuids)
    {
        get(search_word_id);
        HitchensUnorderedKeySetLib.Set storage pids = pid_set[search_word_id];

        uint256 num = pids.count();
        bytes32[] memory uuid_list = new bytes32[](num);

        for ( uint i = 0; i < num ; i++){
            uuid_list[i] = pids.keyAtIndex(i);
        }

        return uuid_list;
    }
    
}