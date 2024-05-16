// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
// import "../libs/UnorderedKeySet.sol";

/**
 *
 *
 */
library Entities {  

    struct PID{

        // ID - X dígitos hexadecimais (2 são reservados para verificação de validez, exemplo: c1bd-d228-1cf9-7d99)
        bytes32 pid_hash; //0
        string noid; //1
        
        bytes32[] extarnalPIDs; //2
        bytes32 url; //3
        // JSON
        string payload; //4

        // OWNER
        address owner; //5
    }

    /// ARK
    struct ExternalPID {
        bytes32 id;
        bytes32 pid_hash; //TODO: e uma lista

        string pid;
        uint8 pid_type;

        address owner;
    }

    struct URL {
        bytes32 id;
        bytes32 pid_hash;
        string url;

        address owner;
    }

    struct PayloadSchema {
        bytes32 id;
        string schema_name;
        string[] attribute_list;
    }

    struct Payload {
        bytes32 id;
        bytes32 payload_schema;
        string[] attributes_values;
    }




    // check wheter a pid is a draft
    // function is_a_draft(PID memory p)
    // public pure
    // returns (bool draft_flag){
    //     draft_flag = p.url == bytes32(0);
    // }

}

    /// DARK ENTITIES
library SystemEntities {

    struct DecentralizedNameMappingAuthority {

        bytes32 id;
        string name;
        string mail;
        string naan;

        string shoulder;
        
        address noid_proveider_addr;
        
        address responsable;
    }

}
    