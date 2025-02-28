// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

/**
 * @title Entities
 * @dev Library containing data structures and utility functions for the dARK system
 * @notice Defines core data structures for PIDs, URLs, and other entities in the dARK ecosystem
 */
library Entities {  

    /**
     * @dev Persistent Identifier structure
     * @notice Core data structure for dARK identifiers
     */
    struct PID {
        bytes32 pid_hash;   // Hash of the PID
        string noid;        // Nice Opaque Identifier
        
        bytes32[] externalPIDs;   // Array of external PID references
        bytes32 url;        // Reference to URL
        bytes32 payload;    // Reference to payload data

        address owner;      // Owner of the PID
    }

    /**
     * @dev External PID reference structure
     * @notice Maps external identifiers to dARK PIDs
     */
    struct ExternalPID {
        bytes32 id;         // Unique ID
        bytes32 pid_hash;   // Reference to the PID hash
        
        string pid;         // External PID identifier
        uint8 pid_type;     // Type of external PID (e.g., DOI, ORCID)
        
        address owner;      // Owner of the external PID mapping
    }

    /**
     * @dev URL structure
     * @notice Stores URL information for a PID
     */
    struct URL {
        bytes32 id;         // Unique ID
        bytes32 pid_hash;   // Reference to the PID hash
        string url;         // The URL string
        
        address owner;      // Owner of the URL
    }

    /**
     * @dev Schema for payload data
     * @notice Defines the structure of payload data
     */
    struct PayloadSchema {
        string schema_name;         // Name of the schema
        string[] attribute_list;    // List of attributes in the schema
        bool configured;            // Whether the schema is configured
    }

    /**
     * @dev Payload data structure
     * @notice Stores payload data according to a schema
     */
    struct Payload {
        bytes32 payload_schema;      // Reference to the schema
        string[] attributes_values;  // Values for each attribute in the schema
    }

    /**
     * @dev Finds the position of an attribute in a schema
     * @param schema The payload schema to search in
     * @param attribute The attribute name to find
     * @return The position of the attribute, or -1 if not found
     */
    function find_attribute_position(Entities.PayloadSchema memory schema, string memory attribute)
    public pure returns (int256) {
        for (uint256 i = 0; i < schema.attribute_list.length; i++) {
            if (keccak256(bytes(schema.attribute_list[i])) == keccak256(bytes(attribute))) {
                return int256(i);
            }
        }
        return -1;
    }
}

/**
 * @title SystemEntities
 * @dev Library containing system-level entities for the dARK system
 * @notice Defines governance and authority structures
 */
library SystemEntities {

    /**
     * @dev Decentralized Name Mapping Authority structure
     * @notice Represents an authority that can issue PIDs within the system
     */
    struct DecentralizedNameMappingAuthority {
        bytes32 id;                     // Unique identifier
        string name;                    // Name of the authority
        string mail;                    // Contact email
        string naan;                    // Name Assigning Authority Number
        string shoulder;                // Shoulder for NOID generation
        address noid_proveider_addr;    // Address of the NOID provider
        address responsable;            // Address of the responsible entity
        string default_payload_schema;  // Default schema for payload data
    }
}