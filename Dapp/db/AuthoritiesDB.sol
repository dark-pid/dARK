// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../libs/HitchensUnorderedKeySet.sol";
import "../libs/UnorderedKeySet.sol";
import "../libs/strings.sol";

import "../util/Entities.sol";
// import {Entities.Person} from "./libs/EntitiesLib.sol";

contract AuthoritiesDB
 {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;    
    
    HitchensUnorderedKeySetLib.Set dnma_set;
    HitchensUnorderedKeySetLib.Set sma_set;
    HitchensUnorderedKeySetLib.Set responsable_set;

    address private owner;

    mapping(bytes32 => Entities.DecentralizedNameMappingAuthority) private dnma_db;
    mapping(bytes32 => Entities.SectionMappingAuthority) private sma_db;
    mapping(address => bytes32) private responsable_db;
    

    // logs
    // event createSearchTerm(bytes32 indexed id,string indexed word, address indexed owner);
    // event addPID2SearchTerm(bytes32 search_word_id, bytes16 pid_uuid, address user);


    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        //usar para controle de acesso
        owner = msg.sender; 
    }

    /**
     * 
     *
     *
     * - word : search term
     * - return id of the searth term
    **/

    function save_responsable(bytes32 obj_id, address responsable)
    public 
    {
        responsable_set.insert( keccak256(abi.encodePacked(responsable)) ); //para garantir que so existe um responsavel
        responsable_db[responsable] = obj_id;
    }

    function save_dnma(string memory ror_id, string memory s_prefix, address responsable)
    public 
    returns(bytes32)
    {
        ror_id = strings.lower(ror_id);
        bytes32 id = keccak256(abi.encodePacked(ror_id));
        // bytes32 resp_id = keccak256(abi.encodePacked(responsable));
        s_prefix = strings.lower(s_prefix);

        require(strings.strlen(s_prefix) <= 4); //TODO: testar se funciona


        //Note: it will fail automatically if the key already exists.
        dnma_set.insert(id);

        Entities.DecentralizedNameMappingAuthority storage dnma = dnma_db[id];
        dnma.id = id;
        dnma.ror_id = ror_id;
        dnma.shoulder_prefix = s_prefix;
        dnma.responsable = responsable;
        // emit createSearchTerm(id, word, msg.sender);
        // salva o responsavel
        save_responsable(id,responsable);

        return id;
    }

    /**
     * @dev set Decentralized Name Mapping Authority
     * 
     * @param _dnma_id bytes32 dnam id
     * @param _noid_provider_addr noid provider addr
     */
    function set_dnma_noid(bytes32 _dnma_id, address _noid_provider_addr)
    public {
        get_dnma(_dnma_id);
        Entities.DecentralizedNameMappingAuthority storage dnma = dnma_db[_dnma_id];
        dnma.noid_proveider_addr = _noid_provider_addr;
    }

    function save_sma(string memory ror_id_dnma, string memory sma_sprefix, address responsable)
    public 
    returns(bytes32)
    {
        sma_sprefix = strings.lower(sma_sprefix);
        require(strings.strlen(sma_sprefix) <= 4);


        //Note: it will fail automatically if the key already exists.
        Entities.DecentralizedNameMappingAuthority memory mdnma = get_dnma_by_ror(ror_id_dnma);
        Entities.DecentralizedNameMappingAuthority storage dnma = dnma_db[mdnma.id];

        bytes32 id_sma = keccak256(abi.encodePacked(dnma.id,sma_sprefix));
        
        sma_set.insert(id_sma); 
        
        Entities.SectionMappingAuthority storage sma = sma_db[id_sma];
        sma.id = id_sma;
        sma.dNMA_id = dnma.id;
        sma.shoulder_prefix = sma_sprefix;
        dnma.responsable = responsable;

        //log
        dnma.section_authorities.push(sma.id);

        //set o responsavel
        save_responsable(id_sma,responsable);

        // emit createSearchTerm(id, word, msg.sender);
        return id_sma;
    }

    /**
     * @dev set Decentralized Name Mapping Authority
     * 
     * @param _sma_id bytes32 dnam id
     * @param _noid_provider_addr noid provider addr
     */
    function set_sma_noid(bytes32 _sma_id, address _noid_provider_addr)
    public {
        get_sma(_sma_id);
        Entities.SectionMappingAuthority storage sma = sma_db[_sma_id];
        sma.noid_proveider_addr = _noid_provider_addr;
    }


    /**
     * @dev Return a decentralized name mapping authority for a given id
     * 
     * @param ror_id string ror id
     * @return status boolean
     */
    function exist_dnma(string memory ror_id)
    public view 
    returns(bool status) {
        status = dnma_set.exists( keccak256(abi.encodePacked(strings.lower(ror_id))) );
    }

    /**
     * @dev Return a decentralized name mapping authority for a given id
     * 
     * @param _id string ror id
     * @return status boolean
     */
    function exist_dnma(bytes32 _id)
    public view 
    returns(bool status) {
        status = dnma_set.exists( _id );
    }

    ///
    /// SMA
    ///

    /**
     * @dev Return a decentralized name mapping authority for a given id
     * 
     * @param _id bytes32 id
     * @return dnma Struct Entities.DecentralizedNameMappingAuthority 
     */
    function get_dnma(bytes32 _id) 
    public view 
    returns(Entities.DecentralizedNameMappingAuthority memory dnma) {
        require(dnma_set.exists(_id), "Can't retrive an Authority that doesn't exist.");
        return dnma_db[_id];
    }

    /**
     * @dev Return a decentralized name mapping authority for a given ror id
     * 
     * @param ror_id bytes32 id
     * @return dnma Struct Entities.DecentralizedNameMappingAuthority 
     */
    function get_dnma_by_ror(string memory ror_id) 
    public view 
    returns(Entities.DecentralizedNameMappingAuthority memory dnma) {
        ror_id = strings.lower(ror_id);
        bytes32 _id = keccak256(abi.encodePacked(ror_id));
        return get_dnma(_id);
    }

    /**
     * @dev Return a decentralized name mapping authority id (key) for a given id
     * 
     * @param index bytes32 id
     * @return key id bytes32
     */
    function get_dnma_by_index(uint256 index) public view returns(bytes32 key) {
        return dnma_set.keyAtIndex(index);
    }

    /**
     * @dev Return the number of decentralized name mapping authority stored in db
     * 
     * @return count number of dnma
     */
    function count_dnma() public view returns(uint256) {
        return dnma_set.count();
    }

    /**
     * @dev Return a decentralized name mapping authority for a given id
     * 
     * @param sma_id string ror id
     * @return status boolean
     */
    function exist_sma(bytes32 sma_id)
    public view 
    returns(bool status) {
        status = sma_set.exists( sma_id );
    }

    /**
     * @dev Return a decentralized name mapping authority for a given id
     * 
     * @param _id bytes32 id
     * @return sma Struct Entities.SectionMappingAuthority 
     */
    function get_sma(bytes32 _id) 
    public view 
    returns(Entities.SectionMappingAuthority memory sma) {
        require(sma_set.exists(_id), "Can't retrive an Authority that doesn't exist.");
        return sma_db[_id];
    }

    /**
     * @dev Return a decentralized name mapping authority for a given ror id
     * 
     * @param sma_sprefix string id
     * @param dnma_id bytes32 id of dnma_id
     * @return sma Entities.SectionMappingAuthority 
     */
    function get_sma(string memory sma_sprefix, bytes32 dnma_id) 
    public view 
    returns(Entities.SectionMappingAuthority memory sma) {
        sma_sprefix = strings.lower(sma_sprefix);
        bytes32 _id = keccak256(abi.encodePacked(dnma_id,sma_sprefix));
        return get_sma(_id);
    }

    /**
     * @dev Return a decentralized name mapping authority id (key) for a given id
     * 
     * @param index bytes32 id
     * @return key id bytes32
     */
    function get_sma_by_index(uint256 index) public view returns(bytes32 key) {
        return sma_set.keyAtIndex(index);
    }

    /**
     * @dev Return the number of decentralized name mapping authority stored in db
     * 
     * @return count number of dnma
     */
    function count_sma() public view returns(uint256) {
        return sma_set.count();
    }

    //
    // responsable_set
    //

    /**
     * @dev check if the addres has 
     * 
     * @param rep_addr string ror id
     * @return status boolean
     */
    function exist(address rep_addr)
    public view 
    returns(bool status) {

        status = responsable_set.exists(  keccak256(abi.encodePacked(rep_addr)) );
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
        bytes32 _id = keccak256(abi.encodePacked(rep_addr));
        require(responsable_set.exists(_id), "There is no Authority associetaded with this address.");
        bytes32 proveider_index = responsable_db[rep_addr];

        if ( exist_dnma(proveider_index) ) {

            Entities.DecentralizedNameMappingAuthority memory dnma = get_dnma(proveider_index);
            provider_addr = dnma.noid_proveider_addr;

        } else if (exist_sma(proveider_index)) {
            Entities.SectionMappingAuthority memory sma = get_sma(proveider_index);
            provider_addr = sma.noid_proveider_addr;

        } else {
            revert("No provider founded!");
        }

        return provider_addr;
    }

    // mapping(bytes32 => Entities.DecentralizedNameMappingAuthority) private dnma_db;
    // mapping(bytes32 => Entities.SectionMappingAuthority) private sma_db;
    // mapping(address => bytes32) private responsable_db;

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

    
}