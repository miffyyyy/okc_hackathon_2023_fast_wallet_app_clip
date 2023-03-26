//
//  balanceView.swift
//  walletAppClip
//
//  Created by xinyi wu on 3/25/23.
//
import SwiftUI
import Alamofire

struct BalanceResponse: Codable {
    let name: String
    let balance: Double
}

struct BalanceView: View {
    let walletAddress: String
    @Binding var showBalanceView: Bool
    @State private var balance: BalanceResponse?

    var body: some View {
        VStack {
            Text("Your Wallet Balance:")
                .foregroundColor(.white)
            HStack {
                Text(balance?.name ?? "Fetching token...")
                    .foregroundColor(.white)
                Spacer()
                Text(balance != nil ? "\(balance!.balance)" : "Fetching balance...")
                    .foregroundColor(.white)
            }

            Spacer()

            Button(action: {
                showBalanceView = false
            }) {
                Text("close")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
        }
        .padding()
        .onAppear {
            fetchBalance()
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }

    func fetchBalance() {
        let balanceURL = "http://localhost:8000/balance/0x9715CA05c0336408a1Cc04e5B2cA2bd5F89Ca622/\(walletAddress)"
        AF.request(balanceURL)
            .responseDecodable(of: BalanceResponse.self) { response in
                switch response.result {
                case .success(let balanceResponse):
                    DispatchQueue.main.async {
                        balance = balanceResponse
                    }
                case .failure(let error):
                    print("Error fetching balance: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        
                    }
                }
            }
    }
}
