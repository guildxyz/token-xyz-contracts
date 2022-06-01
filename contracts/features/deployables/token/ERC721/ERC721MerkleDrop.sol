// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "../../interfaces/IERC721MerkleDrop.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Allows anyone to mint a token with a specific ID if they exist in a Merkle root.
contract ERC721MerkleDrop is ERC721, IERC721MerkleDrop, Ownable {
    using Strings for uint256;

    bytes32 public immutable merkleRoot;
    uint256 public immutable distributionEnd;
    uint256 public immutable maxSupply;
    uint256 public totalSupply;
    string internal cid;

    constructor(
        string memory name,
        string memory symbol,
        string memory cid_,
        uint256 maxSupply_,
        bytes32 merkleRoot_,
        uint256 distributionDuration,
        address owner
    ) ERC721(name, symbol) {
        if (owner == address(0) || merkleRoot_ == bytes32(0)) revert InvalidParameters();
        if (maxSupply_ == 0) revert MaxSupplyZero();
        cid = cid_;
        maxSupply = maxSupply_;
        merkleRoot = merkleRoot_;
        distributionEnd = block.timestamp + distributionDuration;
        _transferOwnership(owner);
    }

    function claim(
        uint256 index,
        address account,
        uint256 tokenId,
        bytes32[] calldata merkleProof
    ) external override {
        if (block.timestamp > distributionEnd) revert DistributionEnded(block.timestamp, distributionEnd);

        // Verify the Merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, tokenId));
        if (!MerkleProof.verify(merkleProof, merkleRoot, node)) revert InvalidProof();

        // Mint the token.
        _safeMint(account, tokenId);
    }

    /// @notice Mint a token to the given address.
    /// @param to The address receiving the token.
    /// @param tokenId The id of the token to be minted.
    function safeMint(address to, uint256 tokenId) external onlyOwner {
        if (block.timestamp <= distributionEnd) revert DistributionOngoing(block.timestamp, distributionEnd);
        _safeMint(to, tokenId);
    }

    function _safeMint(address to, uint256 tokenId) internal override {
        if (tokenId >= maxSupply) revert TokenIdOutOfBounds(tokenId, maxSupply);
        ++totalSupply;
        _safeMint(to, tokenId, "");
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, IERC721Metadata) returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken(tokenId);
        return string(abi.encodePacked("ipfs://", cid, "/", tokenId.toString(), ".json"));
    }
}
