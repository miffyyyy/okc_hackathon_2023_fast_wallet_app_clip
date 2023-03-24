from fastapi import FastAPI, HTTPException, Body, Query
from starlette.responses import JSONResponse
from pydantic import BaseModel, validator
from web3 import Web3
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from databases import Database
from dotenv import load_dotenv
from pathlib import Path
import json
import os
from web3.exceptions import ValidationError


abi = [
    {
        "inputs": [
            {"internalType": "string", "name": "name_", "type": "string"},
            {"internalType": "string", "name": "symbol_", "type": "string"},
        ],
        "stateMutability": "nonpayable",
        "type": "constructor",
    },
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
        "name": "name",
        "outputs": [{"internalType": "string", "name": "", "type": "string"}],
        "stateMutability": "view",
        "type": "function",
    },
    {
        "inputs": [],
        "name": "symbol",
        "outputs": [{"internalType": "string", "name": "", "type": "string"}],
        "stateMutability": "view",
        "type": "function",
    },
    {
        "inputs": [],
        "name": "decimals",
        "outputs": [{"internalType": "uint8", "name": "", "type": "uint8"}],
        "stateMutability": "view",
        "type": "function",
    },
    {
        "inputs": [],
        "name": "totalSupply",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function",
    },
    {
        "inputs": [{"internalType": "address", "name": "account", "type": "address"}],
        "name": "balanceOf",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function",
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
            {"internalType": "address", "name": "owner", "type": "address"},
            {"internalType": "address", "name": "spender", "type": "address"},
        ],
        "name": "allowance",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function",
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
        "inputs": [
            {"internalType": "address", "name": "spender", "type": "address"},
            {"internalType": "uint256", "name": "subtractedValue", "type": "uint256"},
        ],
        "name": "decreaseAllowance",
        "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
        "stateMutability": "nonpayable",
        "type": "function",
    },
]

env_path = Path("..") / ".env"
load_dotenv(dotenv_path=env_path)

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

    id = Column(Integer, primary_key=True, index=True)
    device_id = Column(String(255), primary_key=True, unique=True, nullable=False)


Base.metadata.create_all(bind=engine)


app = FastAPI()


class WalletAddress(BaseModel):
    address: str

    @validator("address")
    def validate_wallet_address(cls, address):
        if not is_valid_wallet_address(address):
            raise ValueError("Invalid wallet address")
        return address


@app.on_event("startup")
async def startup():
    await database.connect()


@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()


@app.get("/ping")
async def ping():
    return {"ping": "pong"}


@app.post("/claim_tokens/")
async def claim_tokens(
    wallet_address: WalletAddress = Body(...), device_id: str = Body(..., embed=True)
):
    async with database.transaction():
        device = await database.fetch_one(
            "SELECT * FROM devices WHERE device_id=:device_id", {"device_id": device_id}
        )
        if device:
            raise HTTPException(
                status_code=400, detail="This device has already claimed a token."
            )

    w3 = Web3(Web3.HTTPProvider("https://exchaintestrpc.okex.org"))
    contract_address = Web3.to_checksum_address(
        "0x0e31bd3a567055b62f1e4232b488a5b99b6c1530"
    )
    contract = w3.eth.contract(address=contract_address, abi=abi)

    authorized_wallet_private_key = AUTH_WALLET_PRIVATE_KEY
    authorized_wallet_address = AUTH_WALLET_ADDRESS

    try:
        gas_price = w3.toWei(1, "gwei")
    except ValidationError:
        raise HTTPException(
            status_code=400,
            detail="Invalid gas price value. Please provide a valid value in gwei.",
        )

    transaction = {
        "to": Web3.to_checksum_address("0xfad21d41f0913464242518f3fc502b25cec1e7f4"),
        "from": authorized_wallet_address,
        "value": 0,
        "gas": 2000000,
        "gasPrice": w3.toWei(gas_price, "gwei"),
        "nonce": w3.eth.getTransactionCount(authorized_wallet_address),
        "data": contract.functions.claim(wallet_address.address).buildTransaction({})[
            "data"
        ],
        "chainId": 65,
    }

    signed_tx = w3.eth.account.signTransaction(
        transaction, authorized_wallet_private_key
    )

    transaction_hash = w3.eth.sendRawTransaction(signed_tx.rawTransaction)

    async with database.transaction():
        query = "INSERT INTO devices (device_id) VALUES (:device_id)"
        await database.execute(query, {"device_id": device_id})

    return JSONResponse(
        content={
            "success": "Token claimed successfully",
            "transaction_hash": transaction_hash.hex(),
        },
        status_code=200,
    )


def is_valid_wallet_address(address: str) -> bool:
    return Web3.is_address(address)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
