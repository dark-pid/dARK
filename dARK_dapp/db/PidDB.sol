// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


import "../util/NoidProvider.sol";
import "../libs/HitchensUnorderedKeySet.sol";
import "../util/Entities.sol";
import "../libs/strings.sol";

// import "../util/UUIDProvider.sol";

/**
 * @title PidDB
 * @dev Storage contract for Persistent Identifiers (PIDs) in the dARK system
 * @notice Manages the creation, storage, and retrieval of PIDs and their associated data
 */
contract PidDB {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    
    address private owner;

    HitchensUnorderedKeySetLib.Set pid_set;
    mapping(bytes32 => Entities.PID) private pid_db;
    mapping(bytes32 => Entities.Payload) private payload_db;
    mapping(bytes32 => Entities.PayloadSchema) private payload_schema_db;
    
    // Events
    /** @dev Emitted when a new PID is created */
    event ID(bytes32 indexed uuid, address indexed owner, uint timestamp);
    /** @dev Emitted when payload data is stored */
    event STORE_PAYLOAD(bytes32 id, bytes32 schema, int256 attribute);

    /**
     * @dev Contract constructor
     * @notice Sets the contract deployer as the owner, used for access control
     */
    constructor() {
        owner = msg.sender;
    }

    /**
    * @dev Assigns a new dARK PID
    * @param proveider_addr The address of the NOID provider contract
    * @return The PID hash (bytes32)
    */
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
        pid.owner = msg.sender;

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
    function add_url(bytes32 uuid,bytes32 url_id)
    public
    {
        get(uuid);
        Entities.PID storage pid = pid_db[uuid];
        pid.url = url_id;
    }

    /**
     * @dev Add an ExternalPID to a dARK PID
     * @param uuid The PID hash
     * @param external_pid_id The external PID identifier
     */
    function add_externalPid(bytes32 uuid, bytes32 external_pid_id)
    public
    {
        get(uuid);
        Entities.PID storage pid = pid_db[uuid];
        pid.externalPIDs.push(external_pid_id);
    }


    
    //
    // PAYLOAD SCHEMA
    //

    /**
     * @notice Create a new payload schema
     * @param schema_name The name of the schema to which the attribute will be added.
     */
    function save_payload_schema(string memory schema_name)
    public returns(bytes32)
    {
        schema_name = strings.upper(schema_name);
        bytes32 id = keccak256(abi.encodePacked(schema_name));

        // Check if the id already exists in the payload_schema_db
        require(bytes(payload_schema_db[id].schema_name).length == 0, "Schema already exists");

        Entities.PayloadSchema storage p = payload_schema_db[id];
        p.schema_name = schema_name;
        p.configured = false;
        
        // Emit event for schema creation
        emit STORE_PAYLOAD(id, bytes32(0), -1);
        return id;
    }



    /**
     * @notice Adds an attribute to an existing payload schema.
     * @param schema_name The name of the schema to which the attribute will be added.
     * @param attribute_name The name of the attribute to be added.
     */
    function add_attribute_to_schema(string memory schema_name, string memory attribute_name)
    public  {
        schema_name = strings.upper(schema_name);
        attribute_name = strings.upper(attribute_name);

        bytes32 id = keccak256(abi.encodePacked(schema_name));

        // Check if the id already exists in the payload_schema_db
        require(bytes(payload_schema_db[id].schema_name).length != 0, "Schema does not exists");
        require(payload_schema_db[id].configured != true, "Schema marked as configured");

        Entities.PayloadSchema storage p = payload_schema_db[id];
        p.attribute_list.push(attribute_name);
        
        // Emit event for attribute addition
        emit STORE_PAYLOAD(id, id, int256(p.attribute_list.length - 1));
    }

    /**
     * @notice Marks an existing payload schema as configured.
     * @param schema_name The name of the schema to be marked as configured.
     */
    function mark_schema_as_configured(string memory schema_name)
    public  {
        schema_name = strings.upper(schema_name);

        bytes32 id = keccak256(abi.encodePacked(schema_name));

        // Check if the id already exists in the payload_schema_db
        require(bytes(payload_schema_db[id].schema_name).length != 0, "Schema does not exists");

        Entities.PayloadSchema storage p = payload_schema_db[id];
        p.configured = true;
        
        // Emit event for schema configuration
        emit STORE_PAYLOAD(id, id, -2);
    }

    /**
     * @notice Retrieves a payload schema by its name.
     * @param schema_name The name of the schema to be retrieved.
     * @return schema The payload schema associated with the given name.
     */
    function get_payload_schema(string memory schema_name) 
    public view returns (Entities.PayloadSchema memory schema) {
        schema_name = strings.upper(schema_name);

        bytes32 id = keccak256(abi.encodePacked(schema_name));

        // Check if the id already exists in the payload_schema_db
        require(bytes(payload_schema_db[id].schema_name).length != 0, "Schema does not exists");

        schema = payload_schema_db[id];
    }

    /**
     * @notice Retrieves a payload schema by its name.
     * @param schema_hash The name of the schema to be retrieved.
     * @return schema The payload schema associated with the given name.
     */
    function get_payload_schema(bytes32 schema_hash) 
    public view returns (Entities.PayloadSchema memory schema) {
        

        // Check if the id already exists in the payload_schema_db
        require(bytes(payload_schema_db[schema_hash].schema_name).length != 0, "Schema does not exists");

        schema = payload_schema_db[schema_hash];
    }

    //
    // PAYLOAD
    //

    /**
     * @notice Retrieves a payload schema by its name.
     * @param payload_noid the noid (bytes32) of the PID that the payload will assoietated
     * @param payload_schema The name of the schema to be retrieved.
     * @param payload_attribute The payload sttribute
     * @param payload_value The payload value
     */
    function store_payload(bytes32 payload_noid,
                            string memory payload_schema, string memory payload_attribute,
                            string memory payload_value )
    public returns (bytes32 payload_addr) {
        Entities.PayloadSchema memory schema = get_payload_schema(payload_schema);
        
        // Verifica se o atributo existe no schema
        // int256 pos = Entities.find_attribute_position(schema, payload_attribute);
        int256 pos = find_attribute_position(schema, payload_attribute);
        require(pos != -1, "Attribute does not exist in Schema");
        
        
        Entities.Payload storage payload = payload_db[payload_noid];
        
        // Verifica se o payload já existe; se não, cria um novo
        if (payload.payload_schema == 0) {
            payload_schema = strings.upper(payload_schema);
            bytes32 schema_id = keccak256(abi.encodePacked(payload_schema));

            // cria um novo array de tamanho especifico vazio
            string[] memory newValues = new string[](schema.attribute_list.length);
            payload.attributes_values = newValues;
            // seta o schema
            payload.payload_schema = schema_id;
        }
        
        // Atribui o valor à posição correta no array
        payload.attributes_values[uint256(pos)] = payload_value;
        
        //TODO: REVER TAMANHO VARIAVEL POS
        emit STORE_PAYLOAD(payload_noid,payload.payload_schema,pos);
                
        return payload_noid;
    }

    function set_payload_in_pid(bytes32 pid_hash_id,bytes32 payload_hash_id)
    public {
        get(pid_hash_id);
        get_payload(payload_hash_id);

        Entities.PID storage pid = pid_db[pid_hash_id];
        pid.payload = payload_hash_id;
    }

    /**
     * @notice Retrieves a payload schema by its name.
     * @param id bytes32 id of payload
     * @return payload The payload
     */
    function get_payload(bytes32 id) 
    public view returns (Entities.Payload memory payload) {
        // Check if the id already exists in the payload_schema_db
        require(payload_db[id].payload_schema.length != 0, "Schema does not exists");

        payload = payload_db[id];
    }

    // 
    // MISC
    // 

    /**
     * @notice Returns the index of the attribute in the schema
     * @param schema The payload schema to search in
     * @param attribute The attribute name to find
     * @return int256 with the index, -1 if not found
     */
    function find_attribute_position(Entities.PayloadSchema memory schema, string memory attribute)
    public pure returns (int256) {
        return Entities.find_attribute_position(schema, attribute);
    }

}
