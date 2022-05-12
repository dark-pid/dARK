// SPDX-License-Identifier: GPL-3.0
// ola mundo
pragma solidity ^0.8.0;

import "../libs/UnorderedKeySet.sol";
// import "./libs/EntitiesLib.sol" as entities;
import "../util/EntitiesLib.sol";
import "../util/UUIDProvider.sol";
// import {Entities.Person} from "./libs/EntitiesLib.sol";

contract PID_DB {
    
    using UnorderedKeySetLib for UnorderedKeySetLib.Set;
    
    
    address private owner;
    UnorderedKeySetLib.Set pid_set;
    mapping(bytes16 => Entities.PID) private pid_db;
    
    

    // logs
    event UUID(bytes16 indexed uuid, address indexed owner, uint timestamp);
    // event LogCreatePerson(address indexed owner, bytes32 indexed id, string indexed name);
    // event LogPerson(address indexed owner, bytes32 indexed id, string indexed name);


    /**
     * @dev Set contract deployer as owner
     *  max indexed 2^256
     */
    constructor() {
        //usar para controle de acesso
        owner = msg.sender;
    }

    /**
    *  Assing a new Dπ PID
    *
    * - return :: Dπ uuid (bytes16)
    **/
    function assing_uuid()
    public 
    returns(bytes16)
    {
        bytes16 uuid;
        bytes16 uuid_alternativo;

        (uuid,uuid_alternativo) = UUIDProvider.getUUID4();

        if ( pid_set.exists(uuid) ){
            uuid = uuid_alternativo;
        } 

        require( !pid_set.exists(uuid), "unable to create unique uuid try again later");

        pid_set.insert(uuid);
        Entities.PID storage pid = pid_db[uuid];
        
        pid.uuid = uuid;
        // pid.owner = msg.sender;
        pid.owner = tx.origin;

        emit UUID(pid.uuid, pid.owner, block.timestamp);

        return uuid;
    }

    /**
     * Return Dπ PID for a given uuid.
     * - uuid (bytes16)
     * case uuid is unsee throws expcetion  :: id does not exist
     *
     * return Entities.PID
     */
    function get(bytes16 uuid)
    public view
    returns(Entities.PID memory pid)
    {
        require( pid_set.exists(uuid), "uuid does not exists");
        Entities.PID memory pid = pid_db[uuid];
    }

    /**
     * Return the PID at a especific index position
     */
    function get_by_index(uint256 index) public view returns(bytes32 key) {
        return pid_set.keyAtIndex(index);
    }

    /**
     * count the number of PID
     */
    function count() public view returns(uint256) {
        return pid_set.count();
    }

    /**
     * Add a SearchTerm to a  Dπ PID.
     * params::
     * - uuid (bytes16)
     * - searchTerm_id (bytes32)
     *
     * case uuid is unsee throws expcetion  :: id does not exist
     *
     */
    function add_searchTerm(bytes16 uuid,bytes32 searchTerm_id)
    public
    {
        get(uuid);
        Entities.PID storage pid = pid_db[uuid];
        pid.searchTerms.push(searchTerm_id);
    }

    /**
     * Add a ExternalPID to a  Dπ PID.
     * params::
     * - uuid (bytes16)
     * - ExternalPID_id (bytes32)
     *
     * case uuid is unsee throws expcetion  :: id does not exist
     *
     */
    function add_externalPid(bytes16 uuid,bytes32 searchTerm_id)
    public
    {
        get(uuid);
        Entities.PID storage pid = pid_db[uuid];
        pid.searchTerms.push(searchTerm_id);
    }


    //DEMO
    function get_uuid_formated(bytes16 uuid)
    public 
    returns(bytes4 a,bytes2 b, bytes2 c, bytes2 d, bytes6 node)
    {
        Entities.PID memory p = get(uuid);
        return Entities.parse(p);
    }

}