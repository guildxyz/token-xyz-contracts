// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20InitialSupply } from "../features/deployables/token/ERC20/ERC20InitialSupply.sol";
import { IWETH } from "../features/deployables/interfaces/IWETH.sol";

/// @title A minimal implementation of WETH for testing purposes.
/// @dev It has many flaws and doesn't work correctly. Don't even think of using it in production!
contract WETHMock is IWETH, ERC20InitialSupply {
    // solhint-disable no-empty-blocks
    mapping(address => uint256) internal _balances;

    constructor(
        string memory name,
        string memory symbol,
        uint8 tokenDecimals,
        address supplyReceiver,
        uint256 initialSupply
    ) ERC20InitialSupply(name, symbol, tokenDecimals, supplyReceiver, initialSupply) {}

    /// @notice Deposit ether to get wrapped ether.
    function deposit() external payable {
        _balances[msg.sender] += msg.value;
    }

    /// @notice Withdraw wrapped ether to get ether.
    /// @param wad The amount of ether to withdraw.
    function withdraw(uint256 wad) external {
        _balances[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
    }

    /// @dev This should be used instead of the original.
    function balanceOf2(address account) public view returns (uint256) {
        return _balances[account];
    }

    // Update the mapping declared here...
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        _balances[from] -= amount;
        _balances[to] += amount;
    }
}