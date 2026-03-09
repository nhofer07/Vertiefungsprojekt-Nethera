//
//  HomeView.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        
        NavigationStack {
            
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
                
                VStack {
                    
                    HStack {
                        Text("Start")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    VStack(spacing: 20) {
                        
                        NavigationLink(destination: DevicesView()) {
                            StatCard(title: "11 Geräte aktiv", subtitle: "Geräte")
                        }
                        
                        NavigationLink(destination: SpeedView()) {
                            StatCard(title: "200 mb/s", subtitle: "Durchschnittlicher Verbrauch")
                        }
                        
                        NavigationLink(destination: ParentalControlView()) {
                            StatCard(title: "3 Geräte", subtitle: "von Kindersicherung betroffen")
                        }
                        
                        NavigationLink(destination: AdBlockDashboardView()) {
                            StatCard(title: "2k Domains", subtitle: "für Werbung blockiert")
                        }
                        
                        NavigationLink(destination: BlacklistDashboardView()) {
                            StatCard(title: "7 Domains", subtitle: "auf Blacklist")
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
