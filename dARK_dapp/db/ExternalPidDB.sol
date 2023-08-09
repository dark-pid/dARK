// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../libs/HitchensUnorderedKeySet.sol";
import "../libs/strings.sol";

import "../util/Entities.sol";
// import {Entities.Person} from "./libs/EntitiesLib.sol";

contract ExternalPidDB
 {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    HitchensUnorderedKeySetLib.Set externalPid_set;

    address private owner;

    mapping(bytes32 => Entities.ExternalPID) private externalPid_db;
    
    // logs
    event createExternalPID(bytes32 indexed id,bytes32 indexed dpi_uuid, address indexed owner);


    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        //usar para controle de acesso
        owner = msg.sender; 
    }

    /**
     * Save a External PID.
     * every word will be saved as upper case
     *
     * - schema : pid schema (e.g., doi)
     * - pid : pid
     * - dpi_uuid : dpi object id
     *
     * - return id of the searth term
     **/
    function save(uint8 schema, string memory pid,bytes32 _pid_hash)
    public 
    returns(bytes32)
    {
        //note: tudo em UPPER
        pid = strings.upper(pid);

        //note: sera que existe colisão de pids diferentes? por exemplo doi e ark. 
        //para poder buscar unificado. 
        bytes32 id = keccak256(abi.encodePacked(pid));
        
        //Note: it will fail automatically if the key already exists.
        externalPid_set.insert(id); 
        
        Entities.ExternalPID storage p = externalPid_db[id];
        p.id = id;
        p.pid_type = schema;
        p.pid = pid;
        p.pid_hash = _pid_hash;
        p.owner = tx.origin;

        emit createExternalPID(id, _pid_hash, p.owner);
        return id;
    }

    /**
     * Check if a pid term exist in the database
     *
     * - return true of false
     */
    function exist(string memory pid)
    public view 
    returns(bool status) {
        status = externalPid_set.exists( keccak256(abi.encodePacked(strings.upper(pid))) );
    }

    /**
     * Return a ExternalPID for a given id
     * 
     */
    function get(bytes32 _id) 
    public view 
    returns(Entities.ExternalPID memory st) {
        require(externalPid_set.exists(_id), "Can't retrive a search term that doesn't exist.");
        return externalPid_db[_id];
    }

    /**
     * Return a ExternalPID for a given pid
     * 
     */
    function get(string memory pid) 
    public view 
    returns(Entities.ExternalPID memory term) {
        pid = strings.upper(pid);
        bytes32 _id = keccak256(abi.encodePacked(pid));
        return get(_id);
    }

    /**
     * Return the ExternalPID id at a especific index position
     */
    function get_by_index(uint256 index) public view returns(bytes32 key) {
        return externalPid_set.keyAtIndex(index);
    }

    /**
     * count the number of ExternalPID
     */
    function count() public view returns(uint256) {
        return externalPid_set.count();
    }
    
}