// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title Interface for an ownable NFT with capped supply.
interface IERC721CappedSupply is IERC721 {
    function maxSupply() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transferOwnership(address newOwner) external;
}
