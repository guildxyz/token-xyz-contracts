// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC721MerkleDrop } from "../../interfaces/IERC721MerkleDrop.sol";
import { IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Provides ERC721 token minting with access to individual IDs restricted based on a Merkle tree.
contract ERC721MerkleDrop is ERC721, IERC721MerkleDrop, Ownable {
    using Strings for uint256;

    /// @inheritdoc IERC721MerkleDrop
    bytes32 public immutable merkleRoot;
    /// @inheritdoc IERC721MerkleDrop
    uint256 public immutable distributionEnd;
    /// @inheritdoc IERC721MerkleDrop
    uint256 public immutable maxSupply;
    /// @inheritdoc IERC721MerkleDrop
    uint256 public totalSupply;
    string internal cid;

    /// @notice Sets metadata, drop config and transfers ownership to `owner`.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @param cid_ The ipfs hash, under which the off-chain metadata is uploaded.
    /// @param maxSupply_ The maximum number of NFTs that can ever be minted.
    /// @param merkleRoot_ The root of the Merkle tree generated from the distribution list.
    /// @param distributionDuration The time interval while the distribution lasts in seconds.
    /// @param owner The owner address: will be able to mint tokens after `distributionDuration` ends.
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

    /// @inheritdoc IERC721MerkleDrop
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

    /// An optimized version of {_safeMint} using custom errors.
    function _safeMint(address to, uint256 tokenId) internal override {
        if (tokenId >= maxSupply) revert TokenIdOutOfBounds(tokenId, maxSupply);
        unchecked {
            ++totalSupply;
        }
        _safeMint(to, tokenId, "");
    }

    /// @inheritdoc IERC721Metadata
    /// @param tokenId The id of the token.
    function tokenURI(uint256 tokenId) public view override(ERC721, IERC721Metadata) returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken(tokenId);
        return string(abi.encodePacked("ipfs://", cid, "/", tokenId.toString(), ".json"));
    }
}
