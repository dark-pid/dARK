// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

import "./util/HitchensUnorderedKeySet.sol";
// import "./libs/EntitiesLib.sol" as entities;
import "./libs/EntitiesLib.sol";
// import {Entities.Person} from "./libs/EntitiesLib.sol";

contract PublicationDB {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    
    
    HitchensUnorderedKeySetLib.Set publication_set;
    address private owner;
    mapping(bytes32 => Entities.Publication) private publications_db;

    // logs
    //TODO: INCLUIR Entities.Person authors
    event LogCreatePublication(address owner, bytes32 id, string name, uint16 year,string pub_type);
    event LogAddAuthorToPublication(address owner, bytes32 pub_id, bytes32 author_id, uint num_anterior , uint num_atual );

    /**
     * @dev Set contract deployer as owner
     *  max indexed 2^256
     */
    constructor() {
        //usar para controle de acesso
        owner = msg.sender; 
    }

    /**
     * Create a Publication:
     *
     * - _name the researcher name
     * - return Dπ id of the Publication
    **/
        // bytes32 id;
        // string title;
        // uint8 year;
        // Publication_type publication_type;
        // Person[] authors;
        // Person[] advisors; 
    function createPublication(string memory _title, uint16 _year,
                                string memory _publication_type,
                                bytes32[] memory _authors
                                // bytes32[] memory _advisors
    ) public 
    returns(bytes32)
    {
        
        // ERROR CHECK
        require(_authors.length > 0,  "Can't create a publication with no authors.");

        // if (_publication_type == Entities.Publication_type.masterThesis || _publication_type == Entities.Publication_type.doctoralThesis) {
        //     require(_advisors.length > 0,  "Can't create this publication with no _advisors.");
        // }

        // _authors colocar um elemento

        bytes32 first_author = _authors[0];
        bytes32 id = keccak256(abi.encodePacked(_title,_year,_publication_type,first_author));
        publication_set.insert(id); // Note that this will fail automatically if the key already exists.
        
        Entities.Publication storage p = publications_db[id];
        p.id = id;
        p.title = _title;
        p.year = _year;
        p.publication_type = _publication_type;
        p.authors = _authors;

        // if (_publication_type == Entities.Publication_type.masterThesis || _publication_type == Entities.Publication_type.doctoralThesis) {
        //     p.advisors = _advisors;
        // }

        p.owner = msg.sender;

        emit LogCreatePublication(msg.sender, id, _title,_year,_publication_type);
        return id;
    }

    function addAuthorToPublication(bytes32 pub_id, bytes32 author ) public 
    {
        require(publication_set.exists(pub_id), "Can't retrive a publication that doesn't exist.");
        Entities.Publication storage p = publications_db[pub_id];
        // p.authors[p.authors.length] = author;//TODO:REVER ISSO
        uint anterior = p.authors.length;
        p.authors.push(author);
        
        emit LogAddAuthorToPublication(msg.sender, p.id, author, anterior , p.authors.length );
    }

    /**
     * Return a Publication for a given id
     * - return (p.name,p.year,p.publication_type,p.authors,p.advisors.p.owner)
     */
    function getPublicationById(bytes32 id) 
    public view 
    returns(string memory title, uint year, string memory pub_type, bytes32[] memory authors,bytes32[] memory advisors, address creator) {
        require(publication_set.exists(id), "Can't retrive a publication that doesn't exist.");
        
        Entities.Publication storage p = publications_db[id];

        return(p.title,p.year,p.publication_type,p.authors,p.advisors,p.owner);
    }

    /**
     * count the number of researchers
     */
    function countPublications() public view returns(uint count) {
        return publication_set.count();
    }
    
    /**
     * Return the researcher id at a especific index position
     */
    function getPublicationIdAtIndex(uint index) public view returns(bytes32 key) {
        return publication_set.keyAtIndex(index);
    }
}