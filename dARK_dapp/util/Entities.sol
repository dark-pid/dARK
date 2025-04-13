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
        // string payload; //4
        bytes32 payload; //4

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


    struct Payload {
        bytes32 payload_schema;
        bytes32 ipfs_hash;
    }



}

    /// DARK ENTITIES
library SystemEntities {
    
    struct PayloadSchema {
        string schema_name;
        string schema_version;
        bool configured;
        string[] ipfs_servers;
    }

    struct DecentralizedNameMappingAuthority {

        bytes32 id;
        string name;
        string mail;
        string naan;

        string shoulder;
        
        address noid_proveider_addr;
        
        address responsable;
        //TODO ADICIONAR O ESQUEMA DO PAYLOAD A AUTORIDADE

        //TODO MAKE THIS UNMATABLE
        string default_payload_schema;
    }

}
    