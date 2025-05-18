// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SmartWallet {
    address public owner;
    uint256 public nonce; // Prevents replay attacks

    constructor(address _owner) {
        owner = _owner;
    }

    // Executes arbitrary calls from the wallet
    function execute(address to, uint256 value, bytes calldata data) external {
        require(msg.sender == owner, "Not owner");
        (bool success, ) = to.call{value: value}(data);
        require(success, "Execution failed");
    }
    // Simulates EIP-4337 signature validation
    function validateUserOp(
        address user,
        // bytes calldata signature,
        uint256 _nonce
    ) external view returns (bool) {
        require(_nonce == nonce, "Invalid nonce");
        // In a real AA wallet, this would verify a signature
        return user == owner;
    }

    // Increments nonce after each operation
    function incrementNonce() external {
        require(msg.sender == owner, "Not owner");
        nonce++;
    }
}

// Simple Paymaster for gas sponsorship
contract Paymaster {
    event GasSponsored(address indexed user, uint256 gasCost);

    function sponsorGas(address wallet, uint256 gasCost) external {
        // In reality, this would check conditions (e.g., user has NFT)
        payable(wallet).transfer(gasCost);
        emit GasSponsored(msg.sender, gasCost);
    }

    // Optional: Accept ERC20 for gas payments
    function payGasInERC20(
        IERC20 token,
        address user,
        uint256 amount
    ) external {
        token.transferFrom(user, address(this), amount);
        emit GasSponsored(user, amount);
    }
}