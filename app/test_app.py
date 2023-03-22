import unittest
from fastapi.testclient import TestClient
from pydantic import ValidationError
from app import app, WalletAddress, Device, SessionLocal
from sqlalchemy.orm import Session

client = TestClient(app)


class TestFastAPIApp(unittest.TestCase):
    def setUp(self):
        # Set up any necessary variables or objects for your tests here
        self.wallet_address = WalletAddress(
            address="0x742d35Cc6634C0532925a3b844Bc454e4438f44e"
        )
        self.device_id = "test_device"

    def test_claim_tokens(self):
        with TestClient(app) as client:
            response = client.post(
                "/claim_tokens/",
                json={
                    "wallet_address": self.wallet_address.dict(),
                    "device_id": self.device_id,
                },
            )
            self.assertEqual(response.status_code, 200)
            self.assertIn("transaction_hash", response.json())

    def test_claim_tokens_device_already_claimed(self):
        with TestClient(app) as client:
            response = client.post(
                "/claim_tokens/",
                json={
                    "wallet_address": self.wallet_address.dict(),
                    "device_id": self.device_id,
                },
            )
            print(response.content)

            self.assertEqual(response.status_code, 400)
            self.assertIn(
                "This device has already claimed a token.", response.json()["detail"]
            )

    def test_wallet_address_validation(self):
        with self.assertRaises(ValidationError):
            WalletAddress(address="invalid_wallet_address")

    def tearDown(self):
        # Clean up the database after tests
        session = SessionLocal()
        session.query(Device).filter(Device.device_id == self.device_id).delete()
        session.commit()
        session.close()


if __name__ == "__main__":
    unittest.main()
