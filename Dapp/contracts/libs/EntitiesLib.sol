// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

/**
 *
 *
 */
library Entities {

    
    string constant dpi_schema_name = "Dpi";

    struct ExternalPID {
        bytes32 id;
        string pid;
        string schema;
        address owner;
    }
    //

    struct SearchTerm {
        bytes32 id;
        string term;
        address owner;
    }

    struct ResourceType{
        string id;
        string name;
        string urls;
        address owner;

    }

    struct PID{

        // ID - X dígitos hexadecimais (2 são reservados para verificação de validez, exemplo: c1bd-d228-1cf9-7d99)
        bytes16 id;
        string schema;
        ExternalPID[] extarnalPIDs;

        
        string[] externalLinks; //TRANSFORMAR EM OBJETS EXTERNOS
        uint16 preferedLink; 
        SearchTerm[] searchTerms;
        uint16 preferedExternalPid;
        ResourceType resourceType;

        // JSON
        string payload;

        // OWNER
        address owner;
    }

    /**
     * Parse a Dπ id to a 5 hex components
     */
    function parse(PID memory p) 
    public pure
    returns (bytes4 first,bytes2 second,bytes2 third,bytes2 fourth,bytes6 node) {
        
        // TimeLow : 4 Bytes (8 hex chars) from the integer value of the low 32 bits of current UTC timestamp
        // TimeMid : 2 Bytes (4 hex chars) from the integer value of the middle 16 bits of current UTC time
        // TimeHighAndVersion : 2 Bytes (4 hex chars) contain the 4 bit UUID version (most significant bits) and the integer value of the high remaining 12 bits of current UTC time (timestamp is comprised of 60 bits)
        // ClockSequenceHiAndRes && ClockSequenceLow : 2 Bytes (4 hex chars) where the 1 through 3 (significant) bits contain the “variant” of the UUID version being used, and the remaining bits contain the clock sequence. The clock sequence is used to help avoid collisions if there a multiple UUID generators within the system or if a system clock for a generator was set backwards or doesn’t advance fast enough. For additional information around changing Node IDs and other collision considerations, see section 4.1.5 of the IETF RFC
        // Node : 6 bytes (12 hex chars) that represent the 48-bit “node id”, which is usually the MAC address of the host hardware that generated it
        
        bytes16 uuid = p.id;

        first = bytes4(uuid);        //4
        second = bytes2(uuid << 32); //2;
        third  = bytes2(uuid << 48); //2
        fourth = bytes2(uuid <<64);  //2
        node   = bytes6(uuid <<80);  //6

    }

}