from fastapi import FastAPI, HTTPException, Body
from starlette.responses import JSONResponse
from pydantic import BaseModel, validator
from web3 import Web3
from sqlalchemy import create_engine, Column, Integer, String, Sequence, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from databases import Database
from dotenv import load_dotenv
from pathlib import Path
from web3.exceptions import ValidationError
import asyncio
from eth_account import Account
from pydantic import BaseModel, validator
import json
import os
import secrets

abi = [
    {"inputs": [], "stateMutability": "nonpayable", "type": "constructor"},
    {
        "anonymous": False,
        "inputs": [
            {
                "indexed": True,
                "internalType": "address",
                "name": "owner",
                "type": "address",
            },
            {
                "indexed": True,
                "internalType": "address",
                "name": "spender",
                "type": "address",
            },
            {
                "indexed": False,
                "internalType": "uint256",
                "name": "value",
                "type": "uint256",
            },
        ],
        "name": "Approval",
        "type": "event",
    },
    {
        "anonymous": False,
        "inputs": [
            {
                "indexed": True,
                "internalType": "address",
                "name": "previousOwner",
                "type": "address",
            },
            {
                "indexed": True,
                "internalType": "address",
                "name": "newOwner",
                "type": "address",
            },
        ],
        "name": "OwnershipTransferred",
        "type": "event",
    },
    {
        "anonymous": False,
        "inputs": [
            {
                "indexed": True,
                "internalType": "address",
                "name": "from",
                "type": "address",
            },
            {
                "indexed": True,
                "internalType": "address",
                "name": "to",
                "type": "address",
            },
            {
                "indexed": False,
                "internalType": "uint256",
                "name": "value",
                "type": "uint256",
            },
        ],
        "name": "Transfer",
        "type": "event",
    },
    {
        "inputs": [],
        "name": "MAX_CLAIM_AMOUNT",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function",
        "constant": True,
    },
    {
        "inputs": [
            {"internalType": "address", "name": "owner", "type": "address"},
            {"internalType": "address", "name": "spender", "type": "address"},
        ],
        "name": "allowance",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function",
        "constant": True,
    },
    {
        "inputs": [
            {"internalType": "address", "name": "spender", "type": "address"},
            {"internalType": "uint256", "name": "amount", "type": "uint256"},
        ],
        "name": "approve",
        "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
        "stateMutability": "nonpayable",
        "type": "function",
    },
    {
        "inputs": [{"internalType": "address", "name": "account", "type": "address"}],
        "name": "balanceOf",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function",
        "constant": True,
    },
    {
        "inputs": [],
        "name": "decimals",
        "outputs": [{"internalType": "uint8", "name": "", "type": "uint8"}],
        "stateMutability": "view",
        "type": "function",
        "constant": True,
    },
    {
        "inputs": [
            {"internalType": "address", "name": "spender", "type": "address"},
            {"internalType": "uint256", "name": "subtractedValue", "type": "uint256"},
        ],
        "name": "decreaseAllowance",
        "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
        "stateMutability": "nonpayable",
        "type": "function",
    },
    {
        "inputs": [{"internalType": "address", "name": "", "type": "address"}],
        "name": "hasClaimed",
        "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
        "stateMutability": "view",
        "type": "function",
        "constant": True,
    },
    {
        "inputs": [
            {"internalType": "address", "name": "spender", "type": "address"},
            {"internalType": "uint256", "name": "addedValue", "type": "uint256"},
        ],
        "name": "increaseAllowance",
        "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
        "stateMutability": "nonpayable",
        "type": "function",
    },
    {
        "inputs": [],
        "name": "name",
        "outputs": [{"internalType": "string", "name": "", "type": "string"}],
        "stateMutability": "view",
        "type": "function",
        "constant": True,
    },
    {
        "inputs": [],
        "name": "owner",
        "outputs": [{"internalType": "address", "name": "", "type": "address"}],
        "stateMutability": "view",
        "type": "function",
        "constant": True,
    },
    {
        "inputs": [],
        "name": "renounceOwnership",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function",
    },
    {
        "inputs": [],
        "name": "symbol",
        "outputs": [{"internalType": "string", "name": "", "type": "string"}],
        "stateMutability": "view",
        "type": "function",
        "constant": True,
    },
    {
        "inputs": [],
        "name": "totalClaimed",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function",
        "constant": True,
    },
    {
        "inputs": [],
        "name": "totalSupply",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function",
        "constant": True,
    },
    {
        "inputs": [
            {"internalType": "address", "name": "to", "type": "address"},
            {"internalType": "uint256", "name": "amount", "type": "uint256"},
        ],
        "name": "transfer",
        "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
        "stateMutability": "nonpayable",
        "type": "function",
    },
    {
        "inputs": [
            {"internalType": "address", "name": "from", "type": "address"},
            {"internalType": "address", "name": "to", "type": "address"},
            {"internalType": "uint256", "name": "amount", "type": "uint256"},
        ],
        "name": "transferFrom",
        "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
        "stateMutability": "nonpayable",
        "type": "function",
    },
    {
        "inputs": [{"internalType": "address", "name": "newOwner", "type": "address"}],
        "name": "transferOwnership",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function",
    },
    {
        "inputs": [],
        "name": "claim",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function",
    },
    {
        "inputs": [{"internalType": "address", "name": "recipient", "type": "address"}],
        "name": "claimFor",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function",
    },
]

env_path = Path("..") / ".env"
load_dotenv(dotenv_path=env_path)
DECIMAL = 10**18
DECIMAL_GWEI = 10**9
MAX_GWEI_PRICE = 100
MYSQL_USERNAME = os.getenv("MYSQL_USERNAME")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD")
AUTH_WALLET_PRIVATE_KEY = os.getenv("AUTH_WALLET_PRIVATE_KEY")

AUTH_WALLET_ADDRESS = Web3.to_checksum_address(os.getenv("AUTH_WALLET_ADDRESS"))
print("aaaaa", AUTH_WALLET_ADDRESS)

print("MYSQL_USERNAME:", MYSQL_USERNAME)
print("MYSQL_PASSWORD:", MYSQL_PASSWORD)

DATABASE_URL = f"mysql://{MYSQL_USERNAME}:{MYSQL_PASSWORD}@localhost/mydatabase"
database = Database(DATABASE_URL)
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


Base = declarative_base()


class Device(Base):
    __tablename__ = "devices"

    device_id = Column(String(255), primary_key=True)
    wallet_created = Column(Boolean, default=False)
    token_claimed = Column(Boolean, default=False)


Base.metadata.create_all(bind=engine)


app = FastAPI()


class WalletAddress(BaseModel):
    address: str

    @validator("address")
    def validate_wallet_address(cls, address):
        if not is_valid_wallet_address(address):
            raise ValueError("Invalid wallet address")
        return address


class BalanceResponse(BaseModel):
    balance: float
    name: str


class Wallet(BaseModel):
    address: str
    mnemonic: str


class DeviceIDInput(BaseModel):
    device_id: str


@app.post("/create_wallet_account/")
async def create_wallet_account(device_id_input: DeviceIDInput):
    device_id = device_id_input.device_id

    async with database.transaction():
        device = await database.fetch_one(
            "SELECT * FROM devices WHERE device_id=:device_id", {"device_id": device_id}
        )
        if device:
            if device["wallet_created"]:
                raise HTTPException(
                    status_code=400, detail="This device has already created a wallet."
                )
        else:
            # Create a new wallet account
            Account.enable_unaudited_hdwallet_features()
            acct, mnemonic = Account.create_with_mnemonic()
            print(acct == Account.from_mnemonic(mnemonic))
            print("account: ", acct)
            print("mnemonic: ", mnemonic)

            # Save the device_id in the database with wallet_created set to True
            query = "INSERT INTO devices (device_id, wallet_created) VALUES (:device_id, :wallet_created)"
            await database.execute(
                query, {"device_id": device_id, "wallet_created": True}
            )

            return Wallet(address=acct.address, mnemonic=mnemonic)


@app.on_event("startup")
async def startup():
    await database.connect()


@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()


@app.get("/ping")
async def ping():
    return {"ping": "pong"}


@app.get("/balance/{contract_address}/{account_address}")
async def get_erc20_balance(
    contract_address: str, account_address: str
) -> BalanceResponse:
    w3 = Web3(Web3.HTTPProvider("https://rpc.ankr.com/eth_goerli"))
    _contract_address = Web3.to_checksum_address(contract_address)
    contract = w3.eth.contract(address=_contract_address, abi=abi)
    # get the balance of the account
    balance = contract.functions.balanceOf(
        Web3.to_checksum_address(account_address)
    ).call()
    name = contract.functions.name().call()
    print(f"balanceOf({account_address}):", balance)
    print(f"name():", name)
    return BalanceResponse(balance=balance, name=name)


@app.post("/claim_tokens/")
async def claim_tokens(
    wallet_address: WalletAddress = Body(...), device_id: str = Body(..., embed=True)
):
    async with database.transaction():
        device = await database.fetch_one(
            "SELECT * FROM devices WHERE device_id=:device_id", {"device_id": device_id}
        )
        if not device or device["token_claimed"]:
            raise HTTPException(
                status_code=400, detail="This device has already claimed a token."
            )

    w3 = Web3(Web3.HTTPProvider("https://rpc.ankr.com/eth_goerli"))
    contract_address = Web3.to_checksum_address(
        "0x619fEbfa88C5f8a2b11Bc1A50e01b14AcfA0565E"
    )
    contract = w3.eth.contract(address=contract_address, abi=abi)

    authorized_wallet_private_key = AUTH_WALLET_PRIVATE_KEY
    authorized_wallet_address = AUTH_WALLET_ADDRESS

    gas_price = await get_gas_price_async()

    function_input = contract.encodeABI(
        fn_name="claimFor", args=[Web3.to_checksum_address(wallet_address.address)]
    )
    await asyncio.sleep(2)
    nonce = w3.eth.get_transaction_count(authorized_wallet_address, "pending")
    print(f"Current nonce for address {authorized_wallet_address}: {nonce}")

    transaction_data = {
        "from": authorized_wallet_address,
        "to": contract_address,
        "gas": 1_000_000,
        "gasPrice": gas_price,
        "nonce": nonce,
        "chainId": 5,
        "data": function_input,
    }

    transaction = {
        "to": contract_address,
        "from": authorized_wallet_address,
        "value": 0,
        "gas": 1_000_000,
        "gasPrice": gas_price,
        "nonce": w3.eth.get_transaction_count(authorized_wallet_address),
        "chainId": 5,
        "data": transaction_data["data"],
    }

    signed_tx = w3.eth.account.sign_transaction(
        transaction, authorized_wallet_private_key
    )

    transaction_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)

    async with database.transaction():
        # Update token_claimed to True after successfully claiming tokens
        query = (
            "UPDATE devices SET token_claimed=:token_claimed WHERE device_id=:device_id"
        )
        await database.execute(query, {"device_id": device_id, "token_claimed": True})

    return JSONResponse(
        content={
            "success": True,
            "transaction_hash": transaction_hash.hex(),
        },
        status_code=200,
    )


def is_valid_wallet_address(address: str) -> bool:
    return Web3.is_address(address)


async def get_gas_price_async():
    loop = asyncio.get_event_loop()
    w3 = Web3(Web3.HTTPProvider("https://rpc.ankr.com/eth_goerli"))

    def fetch_gas_price():
        return w3.eth.gas_price

    gas_price = await loop.run_in_executor(None, fetch_gas_price)
    current_gas = gas_price / DECIMAL_GWEI
    if current_gas * 5 > MAX_GWEI_PRICE:
        gas_price = round(MAX_GWEI_PRICE * DECIMAL_GWEI)
    else:
        gas_price = round(gas_price * 5)
    # Increase gas price by 50% if it is still below 10 Gwei
    if gas_price / DECIMAL_GWEI < 1000:
        gas_price = round(gas_price * 1.5)

    return gas_price


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
