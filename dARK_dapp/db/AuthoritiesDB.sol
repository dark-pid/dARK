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

    mapping(bytes32 => SystemEntities.DecentralizedNameMappingAuthority) private dnma_db;
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

    function save_dnma(string memory name, string memory email, string memory naan, 
                        string memory shoulder,string memory default_payload_schema,
                        address responsable)
    public 
    returns(bytes32)
    {
        name = strings.lower(name);
        email = strings.lower(email);
        naan = strings.lower(naan);
        default_payload_schema = strings.upper(default_payload_schema);

        bytes32 id = keccak256(abi.encodePacked(naan));

        // bytes32 resp_id = keccak256(abi.encodePacked(responsable));
        shoulder = strings.lower(shoulder);

        require(strings.strlen(shoulder) <= 4); //TODO: testar se funciona


        //Note: it will fail automatically if the key already exists.
        dnma_set.insert(id);

        SystemEntities.DecentralizedNameMappingAuthority storage dnma = dnma_db[id];
        dnma.id = id;
        dnma.name = name;
        dnma.mail = email;
        dnma.naan = naan;
        dnma.shoulder = shoulder;
        dnma.responsable = responsable;
        dnma.default_payload_schema = default_payload_schema;
        
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
        SystemEntities.DecentralizedNameMappingAuthority storage dnma = dnma_db[_dnma_id];
        dnma.noid_proveider_addr = _noid_provider_addr;
    }


    /**
     * @dev Return a decentralized name mapping authority for a given id
     * 
     * @param naan string ror id
     * @return status boolean
     */
    function exist_dnma(string memory naan)
    public view 
    returns(bool status) {
        status = dnma_set.exists( keccak256(abi.encodePacked(strings.lower(naan))) );
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

    // /**
    //  * @dev Return a decentralized name mapping authority for a given id
    //  * 
    //  * @param _id bytes32 id
    //  * @return dnma Struct Entities.DecentralizedNameMappingAuthority 
    //  */
    function get_dnma(bytes32 _id) 
    public view 
    returns(SystemEntities.DecentralizedNameMappingAuthority memory dnma) {
        require(dnma_set.exists(_id), "Can't retrive an Authority that doesn't exist.");
        return dnma_db[_id];
    }

    // /**
    //  * @dev Return a decentralized name mapping authority for a given id
    //  * 
    //  * @param _id bytes32 id
    //  * @return dnma Struct Entities.DecentralizedNameMappingAuthority 
    //  */
    function get_dnma(string memory naan) 
    public view 
    returns(SystemEntities.DecentralizedNameMappingAuthority memory dnma) {
        bytes32 _id = keccak256(abi.encodePacked(naan));
        require(dnma_set.exists(_id), "Can't retrive an Authority that doesn't exist.");
        return dnma_db[_id];
    }


    // /**
    //  * @dev Return a decentralized name mapping authority id (key) for a given id
    //  * 
    //  * @param index bytes32 id
    //  * @return key id bytes32
    //  */
    function get_dnma_by_index(uint256 index) public view returns(bytes32 key) {
        return dnma_set.keyAtIndex(index);
    }

    // /**
    //  * @dev Return the number of decentralized name mapping authority stored in db
    //  * 
    //  * @return count number of dnma
    //  */
    function count_dnma() public view returns(uint256) {
        return dnma_set.count();
    }

    //
    // responsable_set
    //

    // /**
    //  * @dev check if the addres has 
    //  * 
    //  * @param rep_addr string ror id
    //  * @return status boolean
    //  */
    function exist(address rep_addr)
    public view 
    returns(bool status) {

        status = responsable_set.exists(  keccak256(abi.encodePacked(rep_addr)) );
    }

    // /**
    //  * @dev Return a decentralized name mapping authority for a given id
    //  * 
    //  * @param rep_addr address
    //  * @return provider_addr id 
    //  */
    function get_proveider_addr(address rep_addr)
    public view 
    returns(address provider_addr) {
        bytes32 _id = keccak256(abi.encodePacked(rep_addr));
        require(responsable_set.exists(_id), "There is no Authority associetaded with this address.");
        bytes32 proveider_index = responsable_db[rep_addr];

        if ( exist_dnma(proveider_index) ) {

            SystemEntities.DecentralizedNameMappingAuthority memory dnma = get_dnma(proveider_index);
            provider_addr = dnma.noid_proveider_addr;
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