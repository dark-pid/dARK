// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

/**
 *
 *
 */
library Entities {
    // - type (article; conferenceObject; masterThesis; doctoralThesis)
    enum Publication_type {
            article,
            conferenceObject,
            masterThesis,
            doctoralThesis
    }

    // Defining Structure
    // - title
    // - year
    // - author(s)
    // - advisor(s)

    struct Person {
        bytes32 id;
        string name;
        //provenance_data
        address owner;
    }

    struct Publication {
        // id?
        // keccak256
        // Declaring different data types
        bytes32 id;
        string title;
        uint16 year;
        string publication_type;
        // mapping (address => mapping (address => uint256)) private _allowances;
        // substituir o array
        // usar no mapping reverso
        bytes32[] authors;
        bytes32[] advisors; 

        //provenance_data
        address owner;
    }

}