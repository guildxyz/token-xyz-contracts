// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC721MerkleDrop } from "../../interfaces/IERC721MerkleDrop.sol";
import { IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Provides ERC721 token minting with amount restricted based on a Merkle tree.
contract ERC721BatchMerkleDrop is ERC721, IERC721MerkleDrop, Ownable {
    using Strings for uint256;

    /// @inheritdoc IERC721MerkleDrop
    bytes32 public immutable merkleRoot;
    /// @inheritdoc IERC721MerkleDrop
    uint256 public immutable distributionEnd;
    /// @inheritdoc IERC721MerkleDrop
    uint256 public immutable maxSupply;
    /// @inheritdoc IERC721MerkleDrop
    uint256 public totalSupply; // Not using Counters because we don't always increment it by 1.
    string internal cid;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

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
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external override {
        if (block.timestamp > distributionEnd) revert DistributionEnded(block.timestamp, distributionEnd);
        if (isClaimed(index)) revert AlreadyClaimed();

        // Verify the Merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProof.verify(merkleProof, merkleRoot, node)) revert InvalidProof();

        // Mark it claimed and mint the token(s).
        _setClaimed(index);
        _safeBatchMint(account, amount);
    }

    /// @notice Mint the next token to the given address.
    /// @param to The address receiving the token.
    function safeMint(address to) external onlyOwner {
        if (block.timestamp <= distributionEnd) revert DistributionOngoing(block.timestamp, distributionEnd);
        uint256 tokenId = totalSupply;
        if (tokenId >= maxSupply) revert TokenIdOutOfBounds(tokenId, maxSupply);
        unchecked {
            ++totalSupply;
        }
        _safeMint(to, tokenId);
    }

    /// @notice Mint a certain amount of tokens to the given address.
    /// @param to The address receiving the tokens.
    /// @param amount The amount of tokens to mint.
    function safeBatchMint(address to, uint256 amount) external onlyOwner {
        if (block.timestamp <= distributionEnd) revert DistributionOngoing(block.timestamp, distributionEnd);
        _safeBatchMint(to, amount);
    }

    function _safeBatchMint(address to, uint256 amount) internal {
        uint256 tokenId = totalSupply;
        uint256 nextTotalSupply = tokenId + amount;
        if (nextTotalSupply > maxSupply) revert TokenIdOutOfBounds(nextTotalSupply, maxSupply);
        totalSupply = nextTotalSupply;
        for (; tokenId < nextTotalSupply; ) {
            _safeMint(to, tokenId);
            unchecked {
                ++tokenId;
            }
        }
    }

    /// Sets token(s) on `index` as claimed.
    function _setClaimed(uint256 index) internal {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    /// @notice Returns true if the index has been marked claimed.
    /// @param index A value from the generated input list.
    /// @return claimed Whether the tokens from `index` have been claimed.
    function isClaimed(uint256 index) public view returns (bool claimed) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    /// @inheritdoc IERC721Metadata
    /// @param tokenId The id of the token.
    function tokenURI(uint256 tokenId) public view override(ERC721, IERC721Metadata) returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken(tokenId);
        return string(abi.encodePacked("ipfs://", cid, "/", tokenId.toString(), ".json"));
    }
}
