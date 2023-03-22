// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MifToken is ERC20, Ownable {
    uint256 public constant MAX_CLAIM_AMOUNT = 1;
    uint256 public totalClaimed;

    // Constructor function that initializes the contract
    constructor() ERC20("Miffy Token", "MIF") {
        // Mint 1000 tokens and assign them to the contract creator
        _mint(msg.sender, 1000 * (10 ** uint256(decimals())));
        // Initialize the totalClaimed variable to 0
        totalClaimed = 0;
    }

    // Function that allows anyone to claim a token
    function claim() public {
        // Check if there are tokens left to be claimed
        require(totalClaimed < totalSupply(), "All tokens have been claimed");
        // Check if the claim amount would exceed the total token supply
        require(
            balanceOf(msg.sender) + MAX_CLAIM_AMOUNT <= totalSupply(),
            "Claim amount exceeds token supply"
        );

        // Transfer the claimable amount of tokens from the owner to the sender
        _transfer(owner(), msg.sender, MAX_CLAIM_AMOUNT);
        // Update the total claimed tokens
        totalClaimed += MAX_CLAIM_AMOUNT;
    }
}
