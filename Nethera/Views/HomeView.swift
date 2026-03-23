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
                    PageHeaderView(title: "Start")

                    Image("Nethera_Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 170)
                        .padding(.top, 8)
                        .padding(.bottom, 2)
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                    
                    VStack(spacing: 20) {
                        
                        NavigationLink(destination: DevicesView()) {
                            StatCard(
                                iconName: "iphone.gen3",
                                title: "Geräte",
                                subtitle: "5 aktiv"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: SpeedView()) {
                            StatCard(
                                iconName: "speedometer",
                                title: "Geschwindigkeit",
                                subtitle: "85,7 Mb/s Download"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: ParentalControlView()) {
                            StatCard(
                                iconName: "lock.shield",
                                title: "Kindersicherung",
                                subtitle: "3 Geräte geschützt"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: AdBlockDashboardView()) {
                            StatCard(
                                iconName: "shield.lefthalf.filled",
                                title: "AdBlock",
                                subtitle: "138 heute blockiert"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: BlacklistDashboardView()) {
                            StatCard(
                                iconName: "nosign",
                                title: "Blacklist",
                                subtitle: "4 manuelle Sperren"
                            )
                        }
                        .buttonStyle(.plain)
                        
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
