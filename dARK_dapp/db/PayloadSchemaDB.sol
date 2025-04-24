// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


import "../libs/HitchensUnorderedKeySet.sol";
import "../util/Entities.sol";
import "../libs/strings.sol";

// import "../util/UUIDProvider.sol";

contract PayloadSchemaDB {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    
    address private owner;

    HitchensUnorderedKeySetLib.Set payload_schema_set;
    mapping(bytes32 => SystemEntities.PayloadSchema) private payload_schema_db;
    
    // logs
    // event ID(bytes32 indexed uuid, address indexed owner, uint timestamp);
    event STORE_PAYLOAD_SCHEMA(bytes32 indexed id, string schema_name,
                                string schema_version, bool configured , 
                                address indexed owner);
    event ADD_URL_TO_SCHEMA(bytes32 indexed id, string server_addr,
                                address indexed owner);
    event SET_SCHEMA_STATUS(bytes32 indexed id, bool old_status, bool new_status, address indexed owner);


    /**
     * @dev Set contract deployer as owner
     *  max indexed 2^256
     */
    constructor() {
        //usar para controle de acesso
        owner = msg.sender;
    }

    /**
    * @notice Generates a schema ID based on the schema name and version.
    *
    * @param schema_name The name of the schema.
    * @param schema_version The version of the schema.
    * @return The generated schema ID as a bytes32 value.
    **/
    function gen_schema_id(string memory schema_name, string memory schema_version) 
        private view returns (bytes32) {
        
        string memory tmp_id = strings.concat(schema_name, schema_version);
        tmp_id = strings.lower(tmp_id);
        bytes32 b32id = keccak256(abi.encodePacked(tmp_id));
        return b32id;
    }

    function count() public view returns(uint256) {
        return payload_schema_set.count();
    }

    
    //
    // PAYLOAD SCHEMA
    //

    /**
     * @notice Create a new payload schema
     *
     * @param schema_name The name of the schema
     * @param schema_version The version of the schema
     * @param configured whether the pauload schema is configured or not
     */
    function save(string memory schema_name, 
                                 string memory schema_version,
                                 bool memory configured
                                )
    public returns(bytes32)
    {

        bytes32 b32id = gen_schema_id(schema_name, schema_version);

        // Check if the id already exists in the payload_schema_db
        require(bytes(payload_schema_db[b32id].schema_name).length == 0, "Schema already exists");
        require(payload_schema_db[b32id].configured == true, "Schema already exists");

        payload_schema_set.insert(b32id);

        SystemEntities.PayloadSchema storage ps = payload_schema_db[b32id];
        ps.schema_name = schema_name;
        ps.configured = configured;
        ps.schema_version = schema_version;
        // ps.ipfs_servers.push("https://ipfs.io/ipfs/");
        
        emit STORE_PAYLOAD_SCHEMA(b32id, schema_name, schema_version, ps.configured , msg.sender);
        return b32id;
    }

    /**
     * @notice Retrieves a payload schema by its name.
     *
     * @param schema_hash The name of the schema to be retrieved.
     * @return schema The payload schema associated with the given name.
     */
    function get(bytes32 schema_hash) 
    public view returns (SystemEntities.PayloadSchema memory schema) {
        
        // Check if the id already exists in the payload_schema_db
        require(bytes(payload_schema_db[schema_hash].schema_name).length != 0, "Schema does not exists");

        schema = payload_schema_db[schema_hash];
    }

    /**
     * @notice Retrieves a payload schema by its name.
     *
     * @param schema_name The name of the schema to be retrieved.
     * @return schema The payload schema associated with the given name.
     */
    function get(string memory schema_name, string memory schema_version) 
    public view returns (SystemEntities.PayloadSchema memory schema) {
        bytes32 b32id = gen_schema_id(schema_name, schema_version);
        schema = get(b32id);
    }

    function get_by_index(uint256 index) public view returns(bytes32 key) {
        return payload_schema_set.keyAtIndex(index);
    }

    /**
     * @notice Adds a server to an existing payload schema.
     *
     * @param ps_id The ID of the payload schema.
     * @param server_addr The address of the server to be added.
     */
    function add_server_to_schema(bytes32 ps_id, string memory server_addr)
    public  {

        // Check if the id already exists in the payload_schema_db
        require(bytes(payload_schema_db[ps_id].schema_name).length != 0, "Schema does not exists");

        SystemEntities.PayloadSchema storage p = payload_schema_db[ps_id];
        p.ipfs_servers.push(server_addr);
        
        emit ADD_URL_TO_SCHEMA(ps_id, server_addr, msg.sender);
    }

    /**
     * @notice Adds a server to an existing payload schema.
     *
     * @param schema_name The name of the schema.
     * @param schema_version The version of the schema.
     * @param server_addr The address of the server to be added.
     */
    function add_server_to_schema(string memory schema_name, 
                                    string memory schema_version,
                                    string memory server_addr)
    public  {
        bytes32 b32id = gen_schema_id(schema_name, schema_version);
        // chama o metodo original
        add_server_to_schema(b32id, server_addr);
    }


    /**
     * @notice Marks an existing payload schema as configured.
     * @param schema_id The ID of the schema to be marked as configured.
     * @param configured The status to set for the schema.
     */
    function set_schema_status(bytes32 schema_id, bool configured)
    public  {
        // Check if the id already exists in the payload_schema_db
        require(bytes(payload_schema_db[schema_id].schema_name).length != 0, "Schema does not exists");

        SystemEntities.PayloadSchema storage p = payload_schema_db[schema_id];
        bool old_status = p.configured;
        p.configured = configured;

        emit SET_SCHEMA_STATUS(schema_id, old_status, configured, msg.sender);
    }

    /**
     * @notice Marks an existing payload schema as configured.
     *
     * @param schema_name The name of the schema to be marked as configured.
     * @param schema_version The version of the schema to be marked as configured.
     * @param configured The status to set for the schema.
     */
    function set_schema_status(string memory schema_name, string memory schema_version, bool configured)
    public  {
        bytes32 b32id = gen_schema_id(schema_name, schema_version);
        set_schema_status(b32id, configured);

    }




    
}
