// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

//util

//db
import "../util/Entities.sol";
import "../db/PidDB.sol";
//services
import "./UrlService.sol";
import "./ExternalPIDService.sol";
import "./AuthoritiesService.sol";

contract PIDService {

    address private owner;
    address private pid_db_addr;
    address private url_service_addr;
    address private externalpid_service_addr;
    address private auth_service_addr;

    event log_id(bytes32 id);

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Checks if a PID has a URL associated with it
     * @param p The PID to check
     * @return has_url Whether the PID has a URL
     */
    function is_a_draft(Entities.PID memory p)
    public pure
    returns (bool has_url) {
        // A PID is considered a draft if it doesn't have a URL
        return p.url != bytes32(0);
    }

    /**
     * @dev Verifies that a PID is valid (has a URL associated)
     * @param p The PID to validate
     */
    function is_a_valid_pid(Entities.PID memory p)
    public pure {
        require(is_a_draft(p), 'This PID is a draft and has no URL.');
    }

    /**
     * set the PID DB address
     */
    function set_db(address addr) 
    public {
        pid_db_addr = addr;
    }

    /**
     * set the PID DB address
     */
     //TODO: COLOCAR NO SETUP
    function set_auth_service(address addr) 
    public {
        auth_service_addr = addr;
    }

    /**
     * set the PID DB address
     */
    function set_externalpid_service(address addr) 
    public {
        externalpid_service_addr = addr;
    }

    /**
     * set the PID DB address
     */
    function set_url_service(address addr) 
    public {
        url_service_addr = addr;
    }

    //
    // Methods
    //

    /**
     * @dev Assigns a new dARK PID
     * @param sender The address to assign as the owner
     * @return pid_hash The hash of the generated PID
     */
    function assingID(address sender)
    public
    returns(bytes32 pid_hash)
    {
        AuthoritiesService aths = AuthoritiesService(auth_service_addr);
        PidDB db = PidDB(pid_db_addr);

        address proveider_addr = aths.get_proveider_addr(sender);
        
        pid_hash = db.assing_id(proveider_addr);
        emit log_id(pid_hash);
        return pid_hash;
    }

    /**
     * @dev Bulk assigns 100 PIDs at once
     * @param sender The address to assign as the owner
     * @return pid_hashes Array of 100 generated PID hashes
     */
    function bulk_assingID(address sender)
    public
    returns(bytes32[100] memory pid_hashes)
    {
        AuthoritiesService aths = AuthoritiesService(auth_service_addr);
        PidDB db = PidDB(pid_db_addr);

        address proveider_addr = aths.get_proveider_addr(sender);
        
        for (uint i = 0; i < 100; i++) {
            pid_hashes[i] = db.assing_id(proveider_addr);
            emit log_id(pid_hashes[i]);
        }
        
        return pid_hashes;
    }

    /**
     * Add a SearchTerm to a  Dπ PID.
     * params::
     * - uuid (bytes16)
     * - searchTerm (string)
     *
     * case uuid is unsee throws expcetion  :: id does not exist
     */
    function set_url(bytes32 pid_hash,string memory url)
    public
    {
        PidDB db = PidDB(pid_db_addr);
        UrlService url_serv = UrlService(url_service_addr);

        db.get(pid_hash); //valida o uuid

        bytes32 url_id = url_serv.get_or_create_url(url,pid_hash);
        Entities.PID memory p = db.get(pid_hash); //valida o uuid

        // Entities.URL memory url_obj = url_serv.get(url_id);
        // require(url_obj.pid_hash == pid_hash, 'URL already linked to other pid');

        if (url_id != p.url){
            db.add_url(pid_hash, url_id);
        }
        
    }

    /**
     * Add a ExternalPID to a Dπ PID.
     * params::
     * - uuid (bytes16)
     * - schema (string)
     * - external_pid (string)
     *
     * case uuid is unsee throws expcetion  :: id does not exist
     */
    function addExternalPid(bytes32 pid_hash,uint8 schema,string memory external_pid)
    public
    {
        //TODO: validar os schemas
        PidDB db = PidDB(pid_db_addr);
        ExternalPIDService epid_service = ExternalPIDService(externalpid_service_addr);

        Entities.PID memory p = db.get(pid_hash); //valida o uuid
        is_a_valid_pid(p); // check if pid is a draft
        bytes32 epid_id = epid_service.get_or_create_externalPid(schema,external_pid,pid_hash);

        // avoid duplicated external PIDs
        bool add_epid_flag = true;
        if (p.externalPIDs.length != 0) {
            
            for (uint i = 0; i < p.externalPIDs.length ; i++) {
                bytes32 pid_epid_id = p.externalPIDs[i];
                
                if (pid_epid_id == epid_id) {
                    add_epid_flag = false;
                }
            }
        }
        
        
        //todo: verificar se o link nao existe
        if (add_epid_flag == true){
            db.add_externalPid(pid_hash,epid_id);
        }
        
    }

    // 
    // PAYLOAD
    // 

     /**
     * @notice Creates a new payload schema in the PidDB contract.
     * @param pid_hash The name of the payload schema 
     * @param pid_payload_name The attribute name
     * @param pid_payload_value The attribute value
     * 
     */
    function set_payload(bytes32 pid_hash,string memory pid_payload_name,
                        string memory pid_payload_value)
    public
    {
        AuthoritiesService aths = AuthoritiesService(auth_service_addr);
        PidDB db = PidDB(pid_db_addr);
        address sender = msg.sender;

        address proveider_addr = aths.get_proveider_addr(sender);
        
        //RECUPERANDO O DNMA
        NoidProvider noidProvider = NoidProvider(proveider_addr);
        // bytes32 dnma_id = noidProvider.DNMA_id;
        bytes32 dnma_id = noidProvider.get_decentralized_name_mapping_id();
        SystemEntities.DecentralizedNameMappingAuthority memory dnma = aths.get_dnma(dnma_id);
        string memory schema = dnma.default_payload_schema;

        // int256 att_pos = Entities.find_attribute_position(schema, pid_payload_name);
        // require(att_pos != -1, "Attribute not found in Schema");

        Entities.PID memory p = db.get(pid_hash); //valida o uuid
        is_a_valid_pid(p); // check if pid is a draft

        db.store_payload(pid_hash, schema , pid_payload_name , pid_payload_value);
    }

    /**
     * @notice Creates a new payload schema in the PidDB contract.
     * @param pid_hash The name of the payload schema 
     * @param schema_name The payload schema name
     * @param pid_payload_name The attribute name
     * @param pid_payload_value The attribute value
     * 
     */
    function set_payload_tmp(bytes32 pid_hash,
                        string memory schema_name,
                        string memory pid_payload_name,
                        string memory pid_payload_value)
    public
    {
        //TODO: ELIMINAR ESSE METODO
        PidDB db = PidDB(pid_db_addr);

        Entities.PID memory p = db.get(pid_hash); //valida o uuid
        is_a_valid_pid(p); // check if pid is a draft

        db.store_payload(pid_hash, schema_name , pid_payload_name , pid_payload_value);
        db.set_payload_in_pid(pid_hash, pid_hash);        
    }

    // 
    // PAYLOAD SCHEMA
    // 


    /**
     * @notice Creates a new payload schema in the PidDB contract.
     * @param schema_name The name of the schema to be created.
     * @return schema_id The unique identifier of the created schema.
     */
    function create_payload_schema(string memory schema_name)
    public returns(bytes32 schema_id) {

        PidDB db = PidDB(pid_db_addr);
        schema_id = db.save_payload_schema(schema_name);
    }

    /**
     * @notice Adds an attribute to an existing payload schema in the PidDB contract.
     * @param schema_name The name of the schema to which the attribute will be added.
     * @param att_name The name of the attribute to be added to the schema.
     */
    function add_attribute_payload_schema(string memory schema_name, string memory att_name)
    public {

        PidDB db = PidDB(pid_db_addr);
        db.add_attribute_to_schema(schema_name,att_name);
    }

    /**
     * @notice Marks an existing payload schema as configured and ready for use in the PidDB contract.
     * @param schema_name The name of the schema to be marked as ready.
     */
    function mark_payload_schema_ready(string memory schema_name)
    public {

        PidDB db = PidDB(pid_db_addr);
        db.mark_schema_as_configured(schema_name);
    }
    
    
}