// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../../interfaces/IERC721MerkleDrop.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Allows anyone to mint a certain amount of this token if they exist in a Merkle root.
contract ERC721BatchMerkleDrop is ERC721, IERC721MerkleDrop, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    bytes32 public immutable merkleRoot;
    uint256 public immutable distributionEnd;
    uint256 public immutable maxSupply;
    string internal cid;
    Counters.Counter internal tokenIdCounter;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

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
        uint256 tokenId = tokenIdCounter.current();
        if (tokenId >= maxSupply) revert TokenIdOutOfBounds();
        tokenIdCounter.increment();
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
        uint256 tokenId = tokenIdCounter.current();
        uint256 lastTokenId = tokenId + amount - 1;
        if (lastTokenId >= maxSupply) revert TokenIdOutOfBounds();
        for (; tokenId <= lastTokenId; ) {
            tokenIdCounter.increment();
            _safeMint(to, tokenId);
            unchecked {
                ++tokenId;
            }
        }
    }

    function _setClaimed(uint256 index) internal {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, IERC721Metadata) returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken(tokenId);
        return string(abi.encodePacked("ipfs://", cid, "/", tokenId.toString(), ".json"));
    }

    function totalSupply() public view returns (uint256) {
        return tokenIdCounter.current();
    }
}
