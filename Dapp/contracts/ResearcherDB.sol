// SPDX-License-Identifier: GPL-3.0
// ola mundo
pragma solidity >=0.4.0 <0.9.0;

import "./util/HitchensUnorderedKeySet.sol";
// import "./libs/EntitiesLib.sol" as entities;
import "./libs/EntitiesLib.sol";
// import {Entities.Person} from "./libs/EntitiesLib.sol";

contract ResearcherDB {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    
    
    HitchensUnorderedKeySetLib.Set researcher_set;
    address private owner;
    mapping(bytes32 => Entities.Person) private researcher_db;

    // logs
    event LogCreatePerson(address indexed owner, bytes32 indexed id, string indexed name);
    event LogPerson(address indexed owner, bytes32 indexed id, string indexed name);


    /**
     * @dev Set contract deployer as owner
     *  max indexed 2^256
     */
    constructor() {
        //usar para controle de acesso
        owner = msg.sender; 
    }

    /**
     * Create a researcher. 
     * - _name the researcher name
     * - return Dπ id of the researcher
    **/
    function createResearcher(string memory _name)
    public 
    returns(bytes32)
    {
        bytes32 id = keccak256(abi.encodePacked(_name));
        researcher_set.insert(id); // Note that this will fail automatically if the key already exists.
        
        Entities.Person storage p = researcher_db[id];
        p.id = id;
        p.name = _name;
        p.owner = msg.sender;

        emit LogCreatePerson(msg.sender, id, _name);
        return id;
    }

    /**
     * Return a researcher for a given id
     * - return (string nome, address owner)
     */
    function getResearcherById(bytes32 id) 
    public view 
    returns(string memory name, address creator) {
        require(researcher_set.exists(id), "Can't retrive a researcher that doesn't exist.");
        
        Entities.Person storage p = researcher_db[id];

        return(p.name, p.owner);
    }

    /**
     * Return a researcher for a given name
     * - return (boolean exists, address owner)
     */
    function getResearcherByName(string memory _name) 
    public view 
    returns(bool _exist_flag, bytes32 _id) {
        bytes32 id = keccak256(abi.encodePacked(_name));
        
        bool exist_flag = false;

        if (researcher_set.exists(id)){
            exist_flag = true;
        }
        
        return (exist_flag, id);
    }

    /**
     * count the number of researchers
     */
    function countResearchers() public view returns(uint count) {
        return researcher_set.count();
    }
    
    /**
     * Return the researcher id at a especific index position
     */
    function getResearcherIdAtIndex(uint index) public view returns(bytes32 key) {
        return researcher_set.keyAtIndex(index);
    }
}