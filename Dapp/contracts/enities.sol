// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

import "./utils/HitchensUnorderedKeySet.sol";

// - type (article; conferenceObject; masterThesis; doctoralThesis)
enum Publication_type {
        Article,
        ConferenceObject
}

// Defining Structure
    // - title
    // - year
    // - author(s)
    // - advisor(s)

struct Person {
        string name;
        //provenance_data
        address creator;
}

struct Publication {
        // id?
        // keccak256
        // Declaring different data types
        string title;
        uint8 year;
        Publication_type publication_type;
        // mapping (address => mapping (address => uint256)) private _allowances;
        // substituir o array
        // usar no mapping reverso
        Person[] authors;
        // uma tese/dissertacao e uma publicacao?
        Person[] advisors; 

        //provenance_data
        address creator;
}

contract DpiEntites {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    
    HitchensUnorderedKeySetLib.Set researcher_set;
    HitchensUnorderedKeySetLib.Set publications_set;

    
    address private owner;

    // logs
    event LogCreatePerson(address creator, bytes32 key, string name);
    event LogPerson(bytes32 key, string name, address creator);

    // util
    mapping(bytes32 => Person) private researcher_db;    
        //podemos quebrar por tipo?
    mapping(bytes32 => Publication) private publications_db;

    /**
     * @dev Set contract deployer as owner
     *  max indexed 2^256
     */
    constructor() {
        //usar para controle de acesso
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        // emit log(address(0), owner);
    }

    /**
     * 
    **/
    function createResearcher(string memory _name)
    public 
    returns(bytes32)
    {
        bytes32 id = keccak256(abi.encodePacked(_name));
        researcher_set.insert(id); // Note that this will fail automatically if the key already exists.
        
        Person storage p = researcher_db[id];
        p.name = _name;
        p.creator = msg.sender;
        emit LogCreatePerson(msg.sender, id, _name);
        return id;
    }

    function getResearcherById(bytes32 id) 
    public view 
    returns(string memory name, address creator) {
        require(researcher_set.exists(id), "Can't retrive a author that doesn't exist.");
        
        Person storage p = researcher_db[id];

        return(p.name, p.creator);
    }

    function getResearcherByName(string memory _name) 
    public view 
    returns(string memory name, address creator) {
        bytes32 id = keccak256(abi.encodePacked(_name));
        require(researcher_set.exists(id), "Can't retrive a author that doesn't exist.");
        
        Person storage p = researcher_db[id];

        return(p.name, p.creator);
    }

    function getResearcherAddressByName(string memory _name) 
    public view 
    returns(bytes32 id) {
        bytes32 id = keccak256(abi.encodePacked(_name));
        require(researcher_set.exists(id), "Can't retrive a author that doesn't exist.");

        return(id);
    }

    function countResearchers() public view returns(uint count) {
        return researcher_set.count();
    }
    
    function getResearchersAtIndex(uint index) public view returns(bytes32 key) {
        return researcher_set.keyAtIndex(index);
    }

    // PROBLEMA
    // function listAllResearchers() 
    // public // view?
    // // returns(bytes32[] memory ids) 
    // {
        
    //     // WARN: This unbounded for loop is an anti-pattern
    //     uint count = countResearchers();
    //     // bytes32[count] memory researches_id;
    //     bytes32[] memory researches_ids;
    //     require(count > 0, "researcher db is empty");

    //     for (uint i=0; i<count; i++) {
    //         researches_ids[i] = getResearchersAtIndex(i);
    //         bytes32 _id = getResearchersAtIndex(i);
    //         emit LogPerson(_id, researcher_db[_id].name,researcher_db[_id].creator);
    //     }

    //     // return researches_ids;
        
    // }

}
