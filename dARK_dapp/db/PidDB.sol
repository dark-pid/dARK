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
    mapping(bytes32 => Entities.Payload) private payload_db;
    mapping(bytes32 => Entities.PayloadSchema) private payload_schema_db;
    
    // logs
    event ID(bytes32 indexed uuid, address indexed owner, uint timestamp);
    event STORE_PAYLOAD(bytes32 id, bytes32 schema, int256 attribute);


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
        // p.owner = tx.origin;

        //TODO EMITIR EVENTO
        // emit createURL(id, word, pid_hash, msg.sender);
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
        //TODO EMITIR EVENTO
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
        //TODO EMITIR EVENTO
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
     * @notice TEMPORARY
     * @notice RETURN THE THE INDEX OF THE ATTRIBUTE
     * @param schema the noid (bytes32) of the PID that the payload will assoietated
     * @param attribute the noid (bytes32) of the PID that the payload will assoietated
     * @return int256 with the index, default -1 (notfound)
     */
    function find_attribute_position(Entities.PayloadSchema memory schema, string memory attribute)
    public pure returns (int256) {
        for (uint256 i = 0; i < schema.attribute_list.length; i++) {
            if (keccak256(bytes(schema.attribute_list[i])) == keccak256(bytes(attribute))) {
                return int256(i); // Retorna a posição do atributo se encontrado
            }
        }
        return -1;
        // return type(uint256).max; // Retorna um valor especial se o atributo não for encontrado
    }

}
