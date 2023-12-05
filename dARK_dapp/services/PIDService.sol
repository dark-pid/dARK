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

    function is_a_draft(Entities.PID memory p)
    public pure
    returns (bool draft_flag){
        if (p.url == bytes32(0)) {
            draft_flag = false;
        } else {
            draft_flag = true;
        }
    }

    /**
     * check if a pid is not a draft
     */
    function is_a_valid_pid(Entities.PID memory p)
    public pure {
        // bool draft_flag = is_a_draft(p);
        require( is_a_draft(p) == true, 'This PID is a draft.');
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

        // Entities.URL memory url_obj = url_serv.get(url_id);
        // require(url_obj.pid_hash == pid_hash, 'URL already linked to other pid');

        db.add_url(pid_hash, url_id);
        
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
        //todo: verificar se o link nao existe
        db.add_externalPid(pid_hash,epid_id);
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
    function set_payload(bytes32 pid_hash,string memory pid_payload)
    public
    {
        PidDB db = PidDB(pid_db_addr);
        Entities.PID memory p = db.get(pid_hash); //valida o uuid
        is_a_valid_pid(p); // check if pid is a draft
        db.set_payload(pid_hash, pid_payload);
    }
    
    
}