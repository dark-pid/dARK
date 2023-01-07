// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../libs/strings.sol";

import "../util/NoidProvider.sol";
import "../util/Entities.sol";
import "../db/AuthoritiesDB.sol";


contract AuthoritiesService {


    address private owner;
    address private db_addr;
    
    // mapping(address => address) private noidprovider_db;
    event log_id(bytes32 indexed id);
    event log_addr(address indexed id);

    
    constructor() {
        owner = msg.sender;
    }

    /**
     * set the PID DB address
     */
    function set_db(address addr) 
    public {
        db_addr = addr;
    }

    /**
     * @dev create a Decentralized Name Mapping Authority (Dnam)
     *
     * @param ror_id ror_id of the authority
     * @param s_prefix shoulder prefix that need to be beta 
     * @param responsable address of the responsble for the Dnam
     *
     * @return dnma_id id of the Dnam
     */
    function create_dnam(string memory ror_id, string memory s_prefix, address responsable)
    public
    returns(bytes32 dnma_id)
    {
        AuthoritiesDB db = AuthoritiesDB(db_addr);
        ror_id = strings.lower(ror_id);
        //TODO: check s_prefix compatibility with betanumeric
        s_prefix = strings.lower(s_prefix);
        
        bool exist_flag = db.exist_dnma(ror_id);

        if ( exist_flag ) {
            Entities.DecentralizedNameMappingAuthority memory dnma = db.get_dnma_by_ror(ror_id);
            dnma_id = dnma.id;
        } else {
            dnma_id = db.save_dnma(ror_id,s_prefix,responsable);
        }
        // REORETORNA O DNMA ID SE EXISTIR
        emit log_id(dnma_id);
    }

    /**
     * @dev create a Section Mapping Authority (sma)
     *
     * @param ror_id ror_id of the authority
     * @param sma_sprefix shoulder prefix that need to be beta 
     * @param responsable address of the responsble for the sma
     *
     * @return sma_id id of the sma
     */
    function create_sma(string memory ror_id, string memory sma_sprefix, address responsable)
    public
    returns(bytes32 sma_id)
    {
        AuthoritiesDB db = AuthoritiesDB(db_addr);
        ror_id = strings.lower(ror_id);
        Entities.DecentralizedNameMappingAuthority memory dnma = db.get_dnma_by_ror(ror_id);
        //TODO: check sma_sprefix compatibility with betanumeric
        sma_sprefix = strings.lower(sma_sprefix);

        
        bytes32 id_sma = keccak256(abi.encodePacked(dnma.id,sma_sprefix));
        
        bool exist_flag = db.exist_sma(id_sma);

        if ( exist_flag ) {
            Entities.SectionMappingAuthority memory sma = db.get_sma(id_sma);
            sma_id = sma.id;
        } else {
            sma_id = db.save_sma(ror_id,sma_sprefix,responsable);
        }
        emit log_id(sma_id);
    }


    // actualu nam
    // _id of authority
    //TODO: ALTERAR NOME
    function configure_noid_provider_dnma(string memory nam, bytes32 auth_id, uint8 noid_len, uint8 _type)
    public 
    returns (address provider_addr)
    {
        require(_type == 1 || _type == 2,"use type=1 for dnma or type=2 for sma");
        
        AuthoritiesDB db = AuthoritiesDB(db_addr);
        
        
        string memory _dnma;
        string memory _sma;
        string memory _sep_token = '3';

        NoidProvider provider = new NoidProvider();

        

        if ( _type == 1){
            Entities.DecentralizedNameMappingAuthority memory dnma = db.get_dnma(auth_id);
            _dnma = dnma.shoulder_prefix;
            _sma = 'f';

            db.set_dnma_noid(dnma.id, address(provider));
        }

        if ( _type == 2){
            Entities.SectionMappingAuthority memory sma = db.get_sma(auth_id);
            Entities.DecentralizedNameMappingAuthority memory dnma = db.get_dnma(sma.dNMA_id);
            _dnma = dnma.shoulder_prefix;
            _sma = sma.shoulder_prefix;

            db.set_sma_noid(sma.id, address(provider));
        }
        
        
        provider.configure(noid_len,nam,_dnma, _sma, _sep_token);
        provider_addr = address(provider);
        emit log_addr(provider_addr);
    }

    /**
     * @dev Return a decentralized name mapping authority for a given id
     * 
     * @param rep_addr address
     * @return provider_addr id 
     */
    function get_proveider_addr(address rep_addr)
    public view 
    returns(address provider_addr) {
        AuthoritiesDB db = AuthoritiesDB(db_addr);
        provider_addr = db.get_proveider_addr(rep_addr);

    }
    


    // function get_authority(address responsable_addr)
    // public view
    // returns (bytes32 auth_id)
    // {
    //     AuthoritiesDB db = AuthoritiesDB(db_addr);
    //     auth_id = db.get(responsable_addr);
    // }

        // responsable_set.insert( keccak256(abi.encodePacked(responsable)) ); //para garantir que so existe um responsavel
        // responsable_db[responsable] = obj_id;


        

        // try new Foo(_owner) returns (Foo foo) {
        //     // you can use variable foo here
        //     emit Log("Foo created");
        // } catch Error(string memory reason) {
        //     // catch failing revert() and require()
        //     emit Log(reason);
        // } catch (bytes memory reason) {
        //     // catch failing assert()
        //     emit LogBytes(reason);
        // }

    // /**
    //  * Add a Dπ PID to search term
    //  *
    //  * - bytes32 search_term_id
    //  * - bytes16 pid uuid
    //  */
    // function add_pid_to_search_term(bytes32 search_term_id,bytes16 pid_uuid)
    // public
    // {
    //     AuthoritiesDB db = AuthoritiesDB(db_addr);
    //     db.save(search_term_id,pid_uuid);
    // }

    
    
}