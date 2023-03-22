from web3.auto import w3
from eth_account import Account


MNEMONIC = ""

Account.enable_unaudited_hdwallet_features()

account = Account.from_mnemonic(MNEMONIC)
private_key = Account.decrypt(
    w3.eth.account.encrypt(account.privateKey, "password"), "password"
)

print(f"Private key: {private_key.hex()}")
