// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


import "../util/NoidProvider.sol";
import "../libs/HitchensUnorderedKeySet.sol";
import "../util/Entities.sol";
// import "../util/UUIDProvider.sol";

contract PidDB {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    
    address private owner;

    HitchensUnorderedKeySetLib.Set pid_set;
    mapping(bytes32 => Entities.PID) private pid_db;
    
    // logs
    event ID(bytes32 indexed uuid, address indexed owner, uint timestamp);


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
    function assing_id(address proveider_addr)
    public 
    returns(bytes32)
    {        
        NoidProvider noid_provider = NoidProvider(proveider_addr);

        string memory noid = noid_provider.gen();
        bytes32 b32_noid = keccak256(abi.encodePacked(noid));

        require( !pid_set.exists(b32_noid), "unable to create unique uuid try again later");

        pid_set.insert(b32_noid);
        Entities.PID storage pid = pid_db[b32_noid];
        pid.uuid = b32_noid;
        pid.noid = noid;
        // pid.owner = msg.sender;
        pid.owner = tx.origin;

        emit ID(pid.uuid, pid.owner, block.timestamp);

        return b32_noid;
    }

    /**
     * Return Dπ PID for a given uuid.
     * - uuid (bytes16)
     * case uuid is unsee throws expcetion  :: id does not exist
     *
     * return Entities.PID
     */
    function get(bytes32 uuid)
    public view
    returns(Entities.PID memory pid)
    {
        require( pid_set.exists(uuid), "uuid does not exists");
        pid = pid_db[uuid];
    }

    /**
     * Return Dπ PID for a given uuid.
     * - uuid (bytes16)
     * case uuid is unsee throws expcetion  :: id does not exist
     *
     * return Entities.PID
     */
    function get_by_noid(string memory noid)
    public view
    returns(Entities.PID memory pid)
    {
        bytes32 uuid = keccak256(abi.encodePacked(noid));
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
    function add_searchTerm(bytes32 uuid,bytes32 searchTerm_id)
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
    function add_externalPid(bytes32 uuid,bytes32 searchTerm_id)
    public
    {
        get(uuid);
        Entities.PID storage pid = pid_db[uuid];
        pid.extarnalPIDs.push(searchTerm_id);
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
    function add_externalLinks(bytes32 uuid,string memory url)
    public
    {
        get(uuid);
        Entities.PID storage pid = pid_db[uuid];
        pid.externalLinks.push(url);
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
    function set_payload(bytes32 uuid,string memory pid_payload)
    public
    {
        get(uuid);
        Entities.PID storage pid = pid_db[uuid];
        pid.payload = pid_payload;
    }

}