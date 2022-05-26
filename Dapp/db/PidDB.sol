// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../libs/UnorderedKeySet.sol";
import "../util/Entities.sol";
import "../util/UUIDProvider.sol";

contract PidDB {
    
    using UnorderedKeySetLib for UnorderedKeySetLib.Set;
    
    address private owner;
    address private UUIDProvider_addr;

    UnorderedKeySetLib.Set pid_set;
    mapping(bytes16 => Entities.PID) private pid_db;
    
    // logs
    event UUID(bytes16 indexed uuid, address indexed owner, uint timestamp);

    function set_uuid_provider(address addr) 
    public
    {
        UUIDProvider_addr = addr;
    }

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
        
        UUIDProvider provider= UUIDProvider(UUIDProvider_addr);

        (uuid,uuid_alternativo) = provider.getUUID4();

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
        pid = pid_db[uuid];
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
        get(uuid);
        Entities.PID storage pid = pid_db[uuid];
        pid.payload = pid_payload;
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
        get(uuid);
        Entities.PID storage pid = pid_db[uuid];
        pid.externalLinks.push(url);
    }

}