//
//  ContentView.swift
//  fastwallet
//
//  Created by xinyi wu on 3/24/23.
//

import SwiftUI
import UIKit
import Alamofire
import SwiftyJSON
import Foundation


// ContentView as a SwiftUI View
struct ContentView: View {
    var body: some View {
        ViewControllerRepresentable()
    }
}

// Wrap ViewController in a SwiftUI UIViewRepresentable
struct ViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = ViewController

    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // Leave this empty
    }
}

struct CreateWalletResponse: Codable {
    let address: String
    let mnemonic: String
}

struct ClaimTokensResponse: Codable {
    let success: Bool
    // Add other properties as needed, based on the expected JSON response
}


class ViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let claimButton = UIButton(type: .system)
        claimButton.setTitle("Claim Tokens", for: .normal)
        claimButton.frame = CGRect(x: 100, y: 100, width: 200, height: 40)
        claimButton.addTarget(self, action: #selector(claimButtonTapped), for: .touchUpInside)
        
        view.addSubview(claimButton)
    }
    
    @objc func claimButtonTapped() {
        createWalletAccountAndClaimTokens { walletAddress in
            self.showBalanceView(walletAddress: walletAddress)
        }
    }
}

extension ViewController {
    func showBalanceView(walletAddress: String) {
        let balanceView = BalanceView(walletAddress: walletAddress)
        let hostingController = UIHostingController(rootView: balanceView)
        present(hostingController, animated: true, completion: nil)
    }

    func createWalletAccountAndClaimTokens(completion: @escaping (String) -> Void) {
        // get device uuid
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"

        
        // first post request: create_wallet_account
        let createWalletURL = "http://localhost:8000/create_wallet_account/"
        let createWalletParameters: [String: Any] = ["device_id": deviceID]
        
        AF.request(createWalletURL, method: .post, parameters: createWalletParameters, encoding: JSONEncoding.default)
            .responseDecodable(of: CreateWalletResponse.self) { response in
                debugPrint(response)
            switch response.result {
            case .success(let createWalletResponse):
                let accountAddress = createWalletResponse.address
                let accountMnemonic = createWalletResponse.mnemonic
                debugPrint("aaaa", accountAddress)
                debugPrint("mmmm", accountMnemonic)

                // second request: claim_tokens
                let claimTokensURL = "http://localhost:8000/claim_tokens/"
                let walletAddress = ["address": accountAddress]
                let claimTokensParameters: [String: Any] = ["wallet_address": walletAddress, "device_id": deviceID]
                debugPrint(claimTokensParameters)
                

                AF.request(claimTokensURL, method: .post, parameters: claimTokensParameters, encoding: JSONEncoding.default)
                    .responseDecodable(of: ClaimTokensResponse.self) { response in
                        debugPrint(response)
                    switch response.result {
                    case .success(let claimTokensResponse):
                        print("Successfully claimed tokens: \(claimTokensResponse)")
                        
                        DispatchQueue.main.async {
                                completion(accountAddress)
                            }
                    case .failure(let error):
                        print("Error claiming tokens: \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                print("Error creating wallet account: \(error.localizedDescription)")
            }
        }
    }
}

//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundColor(.accentColor)
//            Text("Hello, world!")
//        }
//        .padding()
//    }
//}
//
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}


