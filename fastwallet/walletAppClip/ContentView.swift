//
//  ContentView.swift
//  walletAppClip
//
//  Created by xinyi wu on 3/25/23.
//
import SwiftUI
import UIKit
import Alamofire
import SwiftyJSON
import Foundation

// ContentView as a SwiftUI View
struct ContentView: View {
    @State private var isLoading = false

    var body: some View {
        ZStack {
            ViewControllerRepresentable(isLoading: $isLoading)
            if isLoading {
                ActivityIndicator(isAnimating: $isLoading)
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .cornerRadius(10)
            }
        }
    }
}

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = ViewController
    @Binding var isLoading: Bool

    func makeUIViewController(context: Context) -> ViewController {
        return ViewController(isLoading: $isLoading)
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

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        return activityIndicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        if isAnimating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}

class ViewController: UIViewController {
    @Binding var isLoading: Bool
    var uniqueDeviceID: String {
        get {
            if let uuid = UserDefaults.standard.string(forKey: "uniqueDeviceID") {
                return uuid
            } else {
                let newUUID = UUID().uuidString
                UserDefaults.standard.set(newUUID, forKey: "uniqueDeviceID")
                return newUUID
            }
        }
    }

    init(isLoading: Binding<Bool>) {
        _isLoading = isLoading
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let claimButton = UIButton(type: .system)
        claimButton.setTitle("ʕ̯•͡ˑ͓•̯᷅ʔʕ̯•͡ˑ͓•̯᷅ʔ Click me ʕ̯•͡ˑ͓•̯᷅ʔʕ̯•͡ˑ͓•̯᷅ʔ", for: .normal)
        claimButton.frame = CGRect(x: 100, y: 100, width: 200, height: 60)
        claimButton.backgroundColor = UIColor.green
        claimButton.layer.cornerRadius = 10
        claimButton.setTitleColor(.black, for: .normal)

        // Add a hover effect
        claimButton.addTarget(self, action: #selector(claimButtonHighlighted), for: .touchDown)
        claimButton.addTarget(self, action: #selector(claimButtonUnhighlighted), for: .touchDragExit)

        claimButton.addTarget(self, action: #selector(claimButtonTapped), for: .touchUpInside)

        view.addSubview(claimButton)
        view.backgroundColor = .black
    }

    @objc func claimButtonTapped() {
        isLoading = true

        createWalletAccountAndClaimTokens { walletAddress, mnemonic in
            self.isLoading = false
            self.showAddressView(walletAddress: walletAddress, mnemonic: mnemonic)
        }
    }

    @objc func claimButtonHighlighted(sender: UIButton) {
        sender.backgroundColor = UIColor(red: 0/255, green: 255/255, blue: 0/255, alpha: 1.0) // set a darker shade of green
    }

    @objc func claimButtonUnhighlighted(sender: UIButton) {
        sender.backgroundColor = UIColor.green // revert back to the original green color
    }


}

extension ViewController {
    func showAddressView(walletAddress: String, mnemonic: String) {
        let addressView = AddressView(walletAddress: walletAddress, mnemonic: mnemonic)
        let hostingController = UIHostingController(rootView: addressView)
        hostingController.view.backgroundColor = .black
        present(hostingController, animated: true, completion: nil)
    }

    func createWalletAccountAndClaimTokens(completion: @escaping (String, String) -> Void) {
        // get device uuid
        let deviceID = uniqueDeviceID

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
                                    completion(accountAddress, accountMnemonic)
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
