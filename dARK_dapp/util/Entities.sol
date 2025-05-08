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
        Payload[] payload; //

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

    ///
    /// methods
    /// 

    function isDraft(Entities.PID memory p)
    public pure
    returns (bool draft_flag){
        if (p.url == bytes32(0)) {
            draft_flag = false;
        } else {
            draft_flag = true;
        }
    }

    /**
     * @dev Busca a posição de um Payload em um PID.
     * @param pid O PID onde o Payload será buscado.
     * @param payload O Payload que estamos procurando.
     * @return index O índice do Payload no array, ou um valor de erro se não encontrado.
     */
    function findPayloadIndex(PID memory pid, Payload memory payload) 
    public view returns (int) 
    {
        for (uint i = 0; i < pid.payload.length; i++) {
            if (pid.payload[i].payload_schema == payload.payload_schema && pid.payload[i].ipfs_hash == payload.ipfs_hash) {
                return int(i); 
            }
        }
        return -1; 
    }

    /**
     * @dev Updates a Payload in a PID at the specified index.
     * @param pid The PID containing the Payload to be updated.
     * @param index The index of the Payload to update.
     * @param newPayload The new Payload data to set.
     */
    function updatePayload(PID memory pid, uint index, Payload memory newPayload) public pure {
        require(index < pid.payload.length, "Index out of bounds"); 
        pid.payload[index] = newPayload;
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

    }

    function isSchemaActive(SystemEntities.PayloadSchema memory p)
    public pure
    returns (bool draft_flag){
        return p.configured;
    }

}
    