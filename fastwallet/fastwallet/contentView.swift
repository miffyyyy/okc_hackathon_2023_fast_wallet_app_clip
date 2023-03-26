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
        
        claimButton.backgroundColor = UIColor(red: 0.83, green: 0.77, blue: 0.98, alpha: 1.00)
        claimButton.setTitleColor(UIColor.white, for: .normal)
        claimButton.layer.borderWidth = 2
        claimButton.layer.borderColor = UIColor(red: 0.83, green: 0.77, blue: 0.98, alpha: 1.00).cgColor
        claimButton.layer.cornerRadius = claimButton.frame.height/2
        claimButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)

        view.addSubview(claimButton)
    }

    
    @objc func claimButtonTapped() {
        // 创建第一个方框
        let walletView = UIView()
        walletView.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        walletView.center = view.center
        walletView.backgroundColor = UIColor.white
        walletView.layer.borderColor = UIColor(red: 0.83, green: 0.77, blue: 0.98, alpha: 1.00).cgColor
        walletView.layer.borderWidth = 2
        view.addSubview(walletView)
        
        // 添加第一个方框的文本标签
        let walletLabel = UILabel()
        walletLabel.numberOfLines = 0
        walletLabel.text = "Wallet:\nahsdbahjsdvjhsd"
        walletLabel.textAlignment = .left
        walletLabel.frame = walletView.bounds
        walletLabel.sizeToFit()
        walletView.addSubview(walletLabel)
        
        // 创建第二个方框
        let wordsView = UIView()
        wordsView.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        wordsView.center = CGPoint(x: walletView.center.x, y: walletView.center.y + walletView.frame.size.height + 50)
        wordsView.backgroundColor = UIColor.white
        wordsView.layer.borderColor = UIColor(red: 0.83, green: 0.77, blue: 0.98, alpha: 1.00).cgColor
        wordsView.layer.borderWidth = 2
        view.addSubview(wordsView)
        
        // 添加第二个方框的文本标签
        let wordsLabel = UILabel()
        wordsLabel.text = "Words:\nCat\nDog\nBunny"
        wordsLabel.numberOfLines = 0
        wordsLabel.textAlignment = .left
        wordsLabel.frame = wordsView.bounds
        wordsLabel.sizeToFit()
        wordsView.addSubview(wordsLabel)
        
        // 3秒后移除walletLabel和wordsLabel
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            wordsView.removeFromSuperview()
            walletView.removeFromSuperview()
            walletLabel.removeFromSuperview()
            wordsLabel.removeFromSuperview()
        }
        
//        createWalletAccountAndClaimTokens { walletAddress in
//                    self.showBalanceView(walletAddress: walletAddress)
//                }
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


