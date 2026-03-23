//
//  AdBlockDashboardView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 08.03.26.
//

import Foundation

import SwiftUI

struct AdBlockDashboardView: View {
    
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
            
            VStack(spacing: 10) {
                PageHeaderView(title: "Geblockte Werbung", showBackButton: true)
                
                VStack(spacing: 20) {
                    statsRow
                    blockedDomainsCard
                    SingleStatBoxCard
                }
                .padding(.horizontal)
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    var statsRow: some View {
        HStack(spacing: 16) {
            StatBox(
                icon: "shield.fill",
                number: "138",
                subtitle: "Heute geblockt:"
            )
            
            StatBox(
                icon: "shield.lefthalf.filled",
                number: "12,4K",
                subtitle: "Gesamt geblockt:"
            )
        }
    }
    
    var blockedDomainsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            Text("Zuletzt geblockte Domains:")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                DomainRow(name: "googleads.g.doubleclick.net", time: "2m")
                DomainRow(name: "connect.facebook.com", time: "4m")
                DomainRow(name: "stats.g.doubleclick.net", time: "17m")
                DomainRow(name: "adservice.google.com", time: "29m")
            }
        }
        .padding()
        .background(.white.opacity(0.08))
        .cornerRadius(24)
    }
    
    var SingleStatBoxCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SingleStatBox(
                icon: "shield.fill",
                text: "Sie haben 97% aller Anfragen blockiert!"
            )
        }
        .padding()
        .background(.white.opacity(0.08))
        .cornerRadius(24)
    }
    
   
    
}


// Wiederverwendbare Structs:

// Glasbox mit Info:

struct StatBox: View {
    let icon: String
    let number: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Image(systemName: icon)
                .foregroundColor(.white)
            
            Text(number)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.footnote)
                .multilineTextAlignment(.leading)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.1))
        .cornerRadius(22)
    }
}

// Reihe in der Liste der geblockten Domains:

struct DomainRow: View {
    let name: String
    let time: String
    
    var body: some View {
        HStack {
            Text("- \(name)")
                .foregroundColor(.white)
                .lineLimit(1)
                .font(.title3)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "clock")
                Text(time)
            }
            .foregroundColor(.white.opacity(0.7))
        }
        .font(.subheadline)
    }
}

struct SingleStatBox: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 42))
                
                Text(text)
                    .font(.system(size: 22, weight: .bold))
            }
            .foregroundColor(.white)
            
            Spacer()
        }
        .frame(maxWidth: 400)
        .padding()
        .background(.white.opacity(0.1))
        .cornerRadius(22)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AdBlockDashboardView()
}
