# okc_hackathon_2023_fast_wallet_app_clip
a lightweight wallet application that enables quick access and usage.

### General Use Case:
The main use case of this application is to create an airdrop smart contract on the OKChain network and distribute tokens to users who scan a QR code on a website. Users scan the QR code using the App Clip functionality, which opens a lightweight app for verification. Upon successful verification, users receive a key, allowing them to collect tokens, sign transactions, and copy their seed phrase. Due to limitations in the test environment and not being part of the Apple Developer Program, deep links for App Clips could not be implemented. However, the App Clip functionality can be tested and demonstrated in a test environment.

### Interface and Acceptance Criteria:

- Users can access the wallet creation functionality without having to install the full app. 
- The App Clip should create a wallet for the user.
- The App Clip should verify the user and provide a key to collect tokens.
- The App should receive tokens on the created wallet.
- Users should have access to their wallet with the received token.
- Users should be able to sign transactions and copy their seed phrase using the App Clip.


## Output a Skeleton of Code:

## airdrop smart contract skeleton

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
}
```

## Generate and display the QR code on the website

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

## App Clip code skeleton
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



## Python FastAPI Backend:

Install the necessary dependencies: web3 for Ethereum interactions, fastapi for the FastAPI framework, and uvicorn for serving the FastAPI app.

## Create a FastAPI app to handle token distribution:
```
from fastapi import FastAPI
from web3 import Web3

app = FastAPI()
w3 = Web3(Web3.HTTPProvider("https://okchain-rpc-url"))

airdrop_contract_address = "0x..."  # Airdrop contract address
private_key = "..."  # Private key for signing transactions
airdrop_abi = [...]  # Airdrop contract ABI


@app.post("/claim_tokens/")
async def claim_tokens(user_address: str):
    airdrop_contract = w3.eth.contract(address=airdrop_contract_address, abi=airdrop_abi)

    # Implement token claiming logic using airdrop_contract and user_address
    # For example, call the smart contract function to transfer tokens to the user's address

    return {"status": "success", "message": "Tokens claimed successfully"}
 ```
## Serve the FastAPI app:
 
```
$ uvicorn main:app --host 0.0.0.0 --port 8000

```

===================================================================================


## create wallet
```
curl -X POST "http://localhost:8000/create_wallet_account/" -H "Content-Type: application/json" -d '{"device_id": "device_test_account_create_3"}'
```

## claim token
```
curl -X POST "http://127.0.0.1:8000/claim_tokens/" -H "accept: application/json" -H "Content-Type: application/json" -d '{"wallet_address": {"address": "0xfad21d41f0913464242518f3fc502b25cec1e7f4"}, "device_id": "test1"}'
```


## get balance
```
curl -X GET "http://localhost:8000/balance/0x619fEbfa88C5f8a2b11Bc1A50e01b14AcfA0565E/0x80dB20805c18cc5659D5523626ab18d95bF4B7de" -H "accept: application/json"
```
