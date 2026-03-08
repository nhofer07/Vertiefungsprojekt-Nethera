//
//  BlocklistView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 08.03.26.
//

import Foundation

import SwiftUI

struct BlocklistView: View {
    
    @State private var gamblingEnabled = true
    @State private var adultEnabled = true
    @State private var socialEnabled = true
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.2, blue: 0.25),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            
            VStack(spacing: 20) {
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        ManageBlocklistButton
                        
                        VStack(alignment: .leading, spacing: 18) {
                            
                            Text("Empfohlene Blocklisten:")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                            
                            BlocklistRow(
                                title: "Glücksspiele:",
                                domains: "bet365.com, bwin.com, tipico.de, win2day.at, royalvegas.com...",
                                moreCount: 43,
                                isOn: $gamblingEnabled
                            )
                            
                            BlocklistRow(
                                title: "18+ Inhalte:",
                                domains: "pornhub.com, youporn.com, brazzers.com, susi.live, onlyfans.com...",
                                moreCount: 213,
                                isOn: $adultEnabled
                            )
                            
                            BlocklistRow(
                                title: "Social-Media:",
                                domains: "facebook.com, instagram.com, tiktok.com, snapchat.com, x.com...",
                                moreCount: 13,
                                isOn: $socialEnabled
                            )
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.ultraThinMaterial)
                        )
                        
                        Button("alle anzeigen") {
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.6))
                        )
                    }
                    .padding()
                }
            }
        }
    }
}

var ManageBlocklistButton: some View {
    HStack {
        Image(systemName: "puzzlepiece")
            .font(.title2)
        
        Text("Blocklisten verwalten")
            .font(.title2.bold())
    }
    .foregroundColor(.white)
    .padding(24)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
        RoundedRectangle(cornerRadius: 28)
            .fill(.ultraThinMaterial)
    )
}

// Einzelnes Blocklisten-Paket

struct BlocklistRow: View {
    
    let title: String
    let domains: String
    let moreCount: Int
    
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .tint(Color(red: 0.2, green: 0.6, blue: 1))
                    .labelsHidden()
            }
            .foregroundColor(.white)
            
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "info.circle")
                
                VStack(alignment: .leading) {
                    Text("Blockierte Domains:")
                        .font(.caption)
                    
                    Text("\(domains) + \(moreCount) weitere")
                        .font(.caption)
                        .lineLimit(2)
                }
            }
            .foregroundColor(.white.opacity(0.8))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.08))
        )
    }
}
