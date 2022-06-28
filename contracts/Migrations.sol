// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/// @title Helper contract for a Truffle feature.
contract Migrations {
    address public owner = msg.sender;
    uint256 public last_completed_migration;

    modifier restricted() {
        require(msg.sender == owner, "Restricted to the owner");
        _;
    }

    function setCompleted(uint256 completed) public restricted {
        last_completed_migration = completed;
    }
}
