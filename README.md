# okc_hackathon_2023_fast_wallet_app_clip_draft
a lightweight wallet application that enables quick access and usage.

General Use Case:
The main use case of this application is to create an airdrop smart contract on the OKChain network and distribute tokens to users who scan a QR code on a website. Users scan the QR code using the App Clip functionality, which opens a lightweight app for verification. Upon successful verification, users receive a key, allowing them to collect tokens, sign transactions, and copy their seed phrase.

Interface and Acceptance Criteria:

The smart contract should be able to deploy on the OKChain network.
The smart contract should have a function to airdrop tokens to verified addresses.
The website should display a QR code that directs users to the App Clip.
The App should have a QR code scanner to read the QR code and extract the URL.
Upon scanning the QR code, the App should create a wallet for the user.
The App Clip should verify the user and provide a key to collect tokens.
The App should receive tokens on the created wallet.
Users should have access to their wallet with the received token.
Users should be able to sign transactions and copy their seed phrase using the App Clip.

Output a Skeleton of Code:

// airdrop smart contract skeleton

```// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AirdropToken is ERC20 {
    constructor() ERC20("Airdrop Token", "ADT") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract Airdrop {
    AirdropToken private token;
    mapping(address => bool) public hasClaimed;

    constructor(address tokenAddress) {
        token = AirdropToken(tokenAddress);
    }

    function claimTokens(address recipient, uint256 amount) external {
        require(!hasClaimed[recipient], "Tokens already claimed");
        hasClaimed[recipient] = true;
        token.transfer(recipient, amount);
    }
}```

// Generate and display the QR code on the website

```<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Airdrop QR Code</title>
    <script src="https://cdn.jsdelivr.net/npm/qrcode"></script>
</head>
<body>
    <h1>Scan the QR Code to Claim Airdrop Tokens</h1>
    <div id="qrcode"></div>
    
    <script>
        const appClipURL = "https://your-app-clip-url";
        const qrCodeElement = document.getElementById("qrcode");

        QRCode.toCanvas(qrCodeElement, appClipURL, (error) => {
            if (error) {
                console.error("Error generating QR code:", error);
            } else {
                console.log("QR code generated successfully");
            }
        });
    </script>
</body>
</html>
```
// App Clip code skeleton
```
const airdropContractAddress = "0x..."; // Airdrop contract address
const privateKey = "..."; // Private key for signing transactions

async function main() {
  const web3 = new Web3("https://okchain-rpc-url"); // OKChain RPC URL
  const airdropContract = new web3.eth.Contract(airdropABI, airdropContractAddress);
  const userAddress = "..."; // User address

  // Verify user and get key
  const key = await verifyUser();

  // Claim tokens
  const claimTokens = airdropContract.methods.claimTokens(userAddress, key);
  const gasPrice = await web3.eth.getGasPrice();
  const gasEstimate = await claimTokens.estimateGas({ from: userAddress });

  const signedTransaction = await web3.eth.accounts.signTransaction({
    to: airdropContractAddress,
    data: claimTokens.encodeABI(),
    gas: gasEstimate,
    gasPrice: gasPrice,
    nonce: await web3.eth.getTransactionCount(userAddress),
  }, privateKey);

  const transactionReceipt = await web3.eth.sendSignedTransaction(signedTransaction.rawTransaction);
  console.log("Transaction Receipt:", transactionReceipt);
}

async function verifyUser() {
  // Implement user verification logic
}

main().catch(console.error);
```
\\ Create a wallet, claim tokens, and sign transactions in the App

```
// App code skeleton

const airdropContractAddress = "0x..."; // Airdrop contract address
const privateKey = "..."; // Private key for signing transactions

async function main() {
  const web3 = new Web3("https://okchain-rpc-url"); // OKChain RPC URL
  const airdropContract = new web3.eth.Contract(airdropABI, airdropContractAddress);

  // Create a new wallet for the user
  const userWallet = web3.eth.accounts.create();
  const userAddress = userWallet.address;

  // Verify user and get key
  const key = await verifyUser();

  // Claim tokens
  await claimTokens(userAddress, key);

  // Display wallet information to the user
  console.log("Wallet Address:", userAddress);
  console.log("Private Key:", userWallet.privateKey);

  // Sign a transaction
  const toAddress = "0x..."; // Destination address
  const amount = web3.utils.toWei("1", "ether");
  const signedTransaction = await signTransaction(userWallet, toAddress, amount);

  // Display transaction details
  console.log("Signed Transaction:", signedTransaction);
}

async function verifyUser() {
  // Implement user verification logic
}

async function claimTokens(userAddress, key) {
  // Implement token claiming logic using the airdropContract instance and key
}

async function signTransaction(userWallet, toAddress, amount) {
  // Implement transaction signing logic using userWallet, toAddress, and amount
}

main().catch(console.error);
```
