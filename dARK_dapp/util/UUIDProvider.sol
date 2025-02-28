// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// import "../libs/strings.sol";
// import "./Random.sol";

// library Random {

//     /**
//     *   return a random number (uint8) from 0 to 250
//     */
//     function random() public view returns (uint8 random_int) {
//             return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender )))%251);
//     }

// }

/**
 * @title UUIDProvider
 * @dev Provides UUID generation functionality for the dARK system
 * @notice An alternative identifier provider using UUIDs
 */
contract UUIDProvider {

    address private owner;

    /**
     * @dev Contract constructor
     * @notice Sets the contract deployer as the owner
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Generates a random number between 0 and 250
     * @return random_int A pseudo-random number
     */
    function random() public view returns (uint8 random_int) {
            return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender )))%251);
    }

    /**
     * @dev Generates entropy for UUID creation
     * @return key A bytes32 value with high entropy
     */
    function getEntropy() public view returns (bytes32 key) {
        uint r1 = random();
        bytes32 random_key_part;
        random_key_part = keccak256(abi.encodePacked(block.timestamp,r1));
        // nao funciona na simulacao
        // if (block.number - r1 > 0){
        //     random_key_part = blockhash(block.number - r1);
        // } else {
        //     random_key_part = blockhash(block.number);
        // }

        uint op = random() % 8; // %8 NUMERO DE OPCOES DE ENTROPIA
        

        if (op == 0) {
            key = keccak256(abi.encodePacked(block.timestamp,random_key_part));    
        }
        if (op == 1) {
            key = keccak256(abi.encodePacked(gasleft(),random_key_part));
        }
        if (op == 2) {
            key = keccak256(abi.encodePacked(block.difficulty,random_key_part));
        }
        if (op == 3) {
            key = keccak256(abi.encodePacked(msg.sender,random_key_part));
        }
        if (op == 4) {
            key = keccak256(abi.encodePacked(msg.sender,random_key_part));
        }
        if (op == 5) {
            key = keccak256(abi.encodePacked(block.gaslimit,random_key_part));
        }
        if (op == 6) {
            key = keccak256(abi.encodePacked(tx.gasprice,random_key_part));
        }
        if (op == 7) {
            key = keccak256(abi.encodePacked(address(this),random_key_part));
        }

        return key;
    }


    /**
     * @dev Generates a UUID version 4 identifier and an alternative
     * @return uuid The primary UUID
     * @return alternative_uuid A secondary UUID derived from the primary
     */
    function getUUID4() public view returns (bytes16 uuid, bytes16 alternative_uuid) {
        bytes16 seed = bytes16(keccak256(abi.encodePacked(msg.sender, block.timestamp, random(), getEntropy())));
        
        bytes32 buf = keccak256(abi.encodePacked(seed, getEntropy()));
        uuid = bytes16(buf);

        uint128 cast_buf = uint128(uint256(buf) / 2 ** 128);
        alternative_uuid = bytes16(cast_buf);
    }

    /**
     * @dev Generates a UUID version 4 identifier from a provided seed
     * @param seed The seed to use for generation
     * @return uuid The primary UUID
     * @return alternative_uuid A secondary UUID derived from the primary
     */
    function getUUID4(bytes16 seed) public returns (bytes16 uuid, bytes16 alternative_uuid) {
        bytes32 buf = keccak256(abi.encodePacked(seed, getEntropy()));
        uuid = bytes16(buf);

        uint128 cast_buf = uint128(uint256(buf) / 2 ** 128);
        alternative_uuid = bytes16(cast_buf);
    }


    /**
     * @dev Ensures a bytes16 value conforms to UUID version 4 format
     * @param v The bytes16 value to format as UUID v4
     * @return The formatted UUID v4 bytes16 value
     */
    function setUUID4Bytes(bytes16 v) public view returns (bytes16) {

        bytes1 byte_5 = bytes1( uint8(uint128(v) * 2 ** (8 * 5)) );
        bytes1 byte_7 = bytes1( uint8(uint128(v) * 2 ** (8 * 7)) );

        if (byte_7 < 0x40 || byte_7 >= 0x50) {
            byte_7 = bytes1(uint8(byte_7) % 16 + 64);
            v &= 0xffffffffffffffff00ffffffffffffff;
            v |= bytes16( uint128(uint8(byte_7) * 2 ** (8 * 7)) );
        }

        if (byte_5 < 0x80 || byte_5 > 0xb0) {
            byte_5 = bytes1(uint8(byte_5) % 64 + 128);
            v &= 0xffffffffffffffffffff00ffffffffff;
            v |= bytes16( uint128(uint8(byte_5) * 2 ** (8 * 5)) );
        }

        return v;
    }

    // return string (abi.encodePacked(first,second,third,fourth,node));

}