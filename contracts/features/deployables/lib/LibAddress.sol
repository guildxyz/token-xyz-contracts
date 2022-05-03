// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Library for functions related to addresses
library LibAddress {
    error FailedToSendEther();

    function sendEther(address payable _recipient, uint256 _amount) internal {
        (bool success, ) = _recipient.call{value: _amount}("");
        if (!success) revert FailedToSendEther();
    }
}
