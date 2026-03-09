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
                colors: [Color(red: 0.05, green: 0.2, blue: 0.25), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                        HStack {
                        Image(systemName: "puzzlepiece")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Blocklisten verwalten")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.08))
                        .blur(radius: 2)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5))
                    
                    VStack(spacing: 20) {
                        Text("Empfohlene Blocklisten")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        BlocklistRowFloating(title: "Glücksspiele",
                                             domains: "bet365.com, bwin.com, tipico.de, win2day.at, royalvegas.com...",
                                             moreCount: 43,
                                             isOn: $gamblingEnabled)
                        
                        BlocklistRowFloating(title: "18+ Inhalte",
                                             domains: "pornhub.com, youporn.com, brazzers.com, susi.live, onlyfans.com...",
                                             moreCount: 213,
                                             isOn: $adultEnabled)
                        
                        BlocklistRowFloating(title: "Social-Media",
                                             domains: "facebook.com, instagram.com, tiktok.com, snapchat.com, x.com...",
                                             moreCount: 13,
                                             isOn: $socialEnabled)
                    }
                    .padding(25)
                    .background(RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.08))
                        .blur(radius: 2)
                        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6))
                    
                    Button("Alle anzeigen") {}
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 40)
                        .background(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.6)))
                    
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
            }
        }
    }
}

struct BlocklistRowFloating: View {
    
    let title: String
    let domains: String
    let moreCount: Int
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .tint(.blue)
                    .labelsHidden()
            }
            
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .foregroundColor(.white.opacity(0.7))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Blockierte Domains:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(domains) + \(moreCount) weitere")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 22)
            .fill(Color.white.opacity(0.08))
            .blur(radius: 1)
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4))
    }
}

#Preview {
    BlocklistView()
}
