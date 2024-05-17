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

    struct PayloadSchema {
        string schema_name;
        string[] attribute_list;
        bool configured;
    }

    struct Payload {
        bytes32 payload_schema;
        string[] attributes_values;
    }


    function find_attribute_position(Entities.PayloadSchema memory schema, string memory attribute)
    public pure returns (int256) {
        for (uint256 i = 0; i < schema.attribute_list.length; i++) {
            if (keccak256(bytes(schema.attribute_list[i])) == keccak256(bytes(attribute))) {
                return int256(i); // Retorna a posição do atributo se encontrado
            }
        }
        return -1;
        // return type(uint256).max; // Retorna um valor especial se o atributo não for encontrado
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
        //TODO ADICIONAR O ESQUEMA DO PAYLOAD A AUTORIDADE

        string default_payload_schema;
    }

}
    