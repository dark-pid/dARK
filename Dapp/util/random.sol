// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

/**
 *
 *
 */
library Random {

    /**
    *   return a random number (uint8) from 0 to 250
    */
    function random() public view returns (uint8 random_int) {
            return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender )))%251);
    }

}