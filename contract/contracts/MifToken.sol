// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MifToken is ERC20, Ownable {
    uint256 public constant MAX_CLAIM_AMOUNT = 1 * 10;
    uint256 public totalClaimed;

    // Mapping to track if an address has already claimed a token
    mapping(address => bool) public hasClaimed;

    // Constructor function that initializes the contract
    constructor() ERC20("Miffy Token", "MIF") {
        // Mint 1000 tokens and assign them to the contract creator
        _mint(msg.sender, 1000 * (10 ** uint256(decimals())));
        // Initialize the totalClaimed variable to 0
        totalClaimed = 0;
    }

    // Function that allows anyone to claim a token
    function claim() public {
        _claim(msg.sender);
    }

    function claimFor(address recipient) public {
        _claim(recipient);
    }

    function _claim(address recipient) internal {
        // Check if there are tokens left to be claimed
        require(totalClaimed < totalSupply(), "All tokens have been claimed");
        // Check if the recipient has already claimed a token
        require(!hasClaimed[recipient], "Address has already claimed a token");

        // Mint the claimable amount of tokens directly to the recipient
        _mint(recipient, MAX_CLAIM_AMOUNT);
        // Update the total claimed tokens
        totalClaimed += MAX_CLAIM_AMOUNT;
        // Mark the recipient address as having claimed a token
        hasClaimed[recipient] = true;
    }
}
