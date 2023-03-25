//
//  BalanceView.swift
//  fastwallet
//
//  Created by xinyi wu on 3/25/23.
//

import SwiftUI
import UIKit
import Alamofire
import SwiftyJSON
import Foundation

struct BalanceResponse: Codable {
    let balance: Int64
    let name: String
}

struct BalanceView: View {
    @Environment(\.presentationMode) var presentationMode
    let walletAddress: String
    @State private var balance: String = "Loading..."
    
    var body: some View {
        VStack {
            Text("Balance:")
            Text(balance)
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Go Back")
            }
        }
        .onAppear {
            fetchBalance()
        }
    }
    
    func fetchBalance() {
        // Fetch balance from the server and update `balance` state
        let balanceURL = "http://localhost:8000/balance/0x619fEbfa88C5f8a2b11Bc1A50e01b14AcfA0565E/\(walletAddress)"
        AF.request(balanceURL)
            .responseDecodable(of: BalanceResponse.self) { response in
                switch response.result {
                case .success(let balanceResponse):
                    DispatchQueue.main.async {
                        balance = "\(balanceResponse.name): \(balanceResponse.balance)"
                    }
                case .failure(let error):
                    print("Error fetching balance: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        balance = "Error fetching balance"
                    }
                }
            }
    }

}
