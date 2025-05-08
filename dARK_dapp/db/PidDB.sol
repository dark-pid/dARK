// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


import "../util/NoidProvider.sol";
import "../libs/HitchensUnorderedKeySet.sol";
import "../util/Entities.sol";
import "../libs/strings.sol";

// import "../util/UUIDProvider.sol";

contract PidDB {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    
    address private owner;

    HitchensUnorderedKeySetLib.Set pid_set;
    mapping(bytes32 => Entities.PID) private pid_db;
    
    // logs
    event ID(bytes32 indexed uuid, address indexed owner, uint timestamp);
    event SET_PAYLOAD(bytes32 id, bytes32 schema, bytes32 ipfs_hash, uint timestamp);


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
        pid.pid_hash = b32_noid;
        pid.noid = noid;
        // pid.owner = msg.sender;
        pid.owner = tx.origin;

        emit ID(pid.pid_hash, pid.owner, block.timestamp);

        return b32_noid;
    }

    /**
     * Return Dπ PID for a given uuid.
     * - uuid (bytes16)
     * case uuid is unsee throws expcetion  :: id does not exist
     *
     * return Entities.PID
     */
    function get(bytes32 pid_hash)
    public view
    returns(Entities.PID memory pid)
    {
        require( pid_set.exists(pid_hash), "uuid does not exists");
        pid = pid_db[pid_hash];
    }

    /**
     * Return Dπ PID for a given uuid.
     * - uuid (bytes16)
     * case uuid is unsee throws expcetion  :: id does not exist
     *
     * return Entities.PID
     */
    function get_by_noid(string memory darkid)
    public view
    returns(Entities.PID memory pid)
    {
        bytes32 uuid = keccak256(abi.encodePacked(darkid));
        require( pid_set.exists(uuid), "dark does not exists");
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
    function add_url(bytes32 uuid,bytes32 url_id)
    public
    {
        get(uuid);
        Entities.PID storage pid = pid_db[uuid];
        pid.url = url_id;
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



    //
    // PAYLOAD
    //

    /**
     * @notice Store a payload schema
     *
     * @param darkid The ID of the schema
     * @param payload_hash The hash of the payload
     * @param payload_schema The schema of the payload
     **/
    function store_payload(bytes32 darkid,bytes32 payload_hash, bytes32 payload_schema)
    public {
        get(darkid);

        Entities.PID storage pid = pid_db[darkid];
        Entities.Payload memory payload = Entities.Payload(payload_schema, payload_hash);
        pid.payload.push(payload);

        emit SET_PAYLOAD(darkid,payload_schema,payload_hash, block.timestamp);
        // pid.payload.push(payload_hash);
    }

    // /**
    //  * @notice Update a payload schema
    //  *
    //  * @param darkid The ID of the schema
    //  * @param index The index of the payload to update
    //  * @param payload_hash The hash of the payload
    //  * @param payload_schema The schema of the payload
    //  **/
    // function update_payload(bytes32 darkid, uint index, bytes32 payload_hash, bytes32 payload_schema)
    // public {
    //     get(darkid);

    //     Entities.PID storage pid = pid_db[darkid];
    //     Entities.Payload memory new_payload = Entities.Payload(payload_schema, payload_hash);

    //     Entities.updatePayload(pid, index, new_payload);

    //     emit SET_PAYLOAD(darkid,payload_schema,payload_hash, block.timestamp);
    //     // pid.payload.push(payload_hash);
    // }


    // 
    // MISC
    // 



}
