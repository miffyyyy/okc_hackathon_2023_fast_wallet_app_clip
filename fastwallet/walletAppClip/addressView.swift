//
//  addressView.swift
//  walletAppClip
//
//  Created by xinyi wu on 3/26/23.
//

import SwiftUI

struct AddressView: View {
    @State private var showBalanceView = false
    let walletAddress: String
    let mnemonic: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Congratulations! You just created a wallet:")
                .foregroundColor(.white)
            
            Button(action: {
                UIPasteboard.general.string = walletAddress
            }) {
                Text(walletAddress)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.green)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.yellow, lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Please keep the mnemonic:")
                .foregroundColor(.white)
            
            Button(action: {
                UIPasteboard.general.string = mnemonic
            }) {
                Text(mnemonic)
                    .font(.callout)
                    .padding()
                    .foregroundColor(.green)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.yellow, lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                showBalanceView = true
            }) {
                Text("Check Balance")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showBalanceView) {
            BalanceView(walletAddress: walletAddress, showBalanceView: $showBalanceView)
                .fullBackground(color: .black) // Apply the full background color modifier
        }
    }
}

struct FullBackgroundModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        ZStack {
            color.edgesIgnoringSafeArea(.all)
            content
        }
    }
}

extension View {
    func fullBackground(color: Color) -> some View {
        self.modifier(FullBackgroundModifier(color: color))
    }
}
