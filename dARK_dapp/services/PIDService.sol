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
import "./PayloadSchemaService.sol";

contract PIDService {

    address private owner;
    address private pid_db_addr;
    address private url_service_addr;
    address private externalpid_service_addr;
    address private auth_service_addr;
    address private payload_schema_service_addr;

    event log_id(bytes32 id);

    constructor() {
        owner = msg.sender;
    }


    function is_a_valid_pid(Entities.PID memory p)
    public pure returns (bool) 
    {
        // bool draft_flag = is_a_draft(p);
        require(p.url != bytes32(0), 'This is a draft.');
        // if (p.pid_hash == bytes32(0)) {
        //     revert('This PID does not exist.');
        // }
        // if ( p.url == bytes32(0) ) {
        //     revert('This is a draft.');
        // }
        
        return true;
    }

    function is_a_valid_payloadSchema(SystemEntities.PayloadSchema memory ps)
    public pure returns (bool) 
    {
        // bool draft_flag = is_a_draft(p);
        require(ps.configured != true, 'Schema is not configured');
        // if (p.pid_hash == bytes32(0)) {
        //     revert('This PID does not exist.');
        // }
        // if ( p.url == bytes32(0) ) {
        //     revert('This is a draft.');
        // }
        
        return true;
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

    /**
     * set the PID DB address
     */
     //TODO: COLOCAR NO SETUP
    function set_payload_schema_service(address addr) 
    public {
        payload_schema_service_addr = addr;
    }

    //
    // Methods
    //

    /**
     *  Assing a new Dπ uuid to the tx.origin
     *  - return uuid (bytes19)
     */
    function assingID(address sender)
    public
    returns(bytes32 pid_hash)
    {
        AuthoritiesService aths = AuthoritiesService(auth_service_addr);
        PidDB db = PidDB(pid_db_addr);

        // address proveider_addr = aths.get_proveider_addr(msg.sender);
        address proveider_addr = aths.get_proveider_addr(sender);
        
        pid_hash = db.assing_id(proveider_addr);
        // TODO: REMOVER ESSE EMIT NO FUTURO
        emit log_id(pid_hash);
        return pid_hash;
    }

    /**
     * Bulk assing 100 pids
     * 
     * - return 
     */
    function bulk_assingID(address sender)
    public
    returns(bytes32[100] memory pid_hashes)
    {
        AuthoritiesService aths = AuthoritiesService(auth_service_addr);
        PidDB db = PidDB(pid_db_addr);

        // address proveider_addr = aths.get_proveider_addr(msg.sender);
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
        
        // check if pid is a draft
        is_a_valid_pid(p); 
        // require(p.url == bytes32(0), 'This is a draft.');
        // if ( Entities.isDraft(p) == true) {
        //     revert('This is a draft.');
        // }

        bytes32 epid_id = epid_service.get_or_create_externalPid(schema,external_pid,pid_hash);

        // avoid duplicated urls in pid
        bool add_epid_flag = true;
        if (p.extarnalPIDs.length != 0) {
            
            for (uint i = 0; i < p.extarnalPIDs.length ; i++) {
                bytes32 pid_epid_id = p.extarnalPIDs[i];
                
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
     * @param payload_schema The attribute name
     * @param payload_hash The attribute value
     * 
     */
    function set_payload(bytes32 pid_hash,
                        bytes32 payload_schema,
                        bytes32 payload_hash)
    public
    {
        // AuthoritiesService aths = AuthoritiesService(auth_service_addr);
        PidDB db = PidDB(pid_db_addr);
        // address sender = msg.sender;
        // address proveider_addr = aths.get_proveider_addr(sender);
        PayloadSchemaService ps_serv = PayloadSchemaService(payload_schema_service_addr);
        Entities.PID memory p = db.get(pid_hash); //valida o uuid
        is_a_valid_pid(p); 
        SystemEntities.PayloadSchema memory ps = ps_serv.get(payload_schema);
        is_a_valid_payloadSchema(ps);

        db.store_payload(pid_hash,payload_hash,payload_schema);
    }

    // /**
    //  * @notice Updates an existing payload schema in the PidDB contract.
    //  * @param pid_hash The name of the payload schema 
    //  * @param old_payload_schema The old payload schema name
    //  * @param old_payload_hash The old payload hash
    //  * @param new_payload_schema The new payload schema name
    //  * @param new_payload_hash The new payload hash
    //  */
    // function update_payload(bytes32 pid_hash,
    //                     bytes32 old_payload_schema,
    //                     bytes32 old_payload_hash,
    //                     bytes32 new_payload_schema,
    //                     bytes32 new_payload_hash)
    // public
    // {
    //     // AuthoritiesService aths = AuthoritiesService(auth_service_addr);
    //     PidDB db = PidDB(pid_db_addr);
    //     // address sender = msg.sender;
    //     // address proveider_addr = aths.get_proveider_addr(sender);
    //     PayloadSchemaService ps_serv = PayloadSchemaService(payload_schema_service_addr);
        

    //     Entities.PID memory p = db.get(pid_hash); //valida o uuid
    //     is_a_valid_pid(p);

    //     Entities.Payload memory old_payload = Entities.Payload(old_payload_schema, old_payload_hash);
    //     int pindex = Entities.findPayloadIndex(p, old_payload);
    //     require(pindex >= 0, 'Payload not registred in pid');

    //     SystemEntities.PayloadSchema memory ps = ps_serv.get(new_payload_schema);
    //     is_a_valid_payloadSchema(ps);
        

    //     db.update_payload(pid_hash, uint256(pindex), new_payload_hash, new_payload_schema);
    // }
    
    
}