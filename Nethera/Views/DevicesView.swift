//
//  DevicesView.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import SwiftUI

struct DevicesView: View {
    
    let devices = [
        Device(name: "iPhone von Nico", type: "iphone", onlineTime: "12h", dataUsage: "57 GB"),
        Device(name: "MacBook Nico", type: "laptopcomputer", onlineTime: "5h", dataUsage: "12 GB"),
        Device(name: "Smart TV", type: "tv", onlineTime: "3h", dataUsage: "8 GB")
    ]
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                // Hintergrund Gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.2, blue: 0.25),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Weißer großer Titel selbstgebaut
                    HStack {
                        Text("Geräte")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Liste der Geräte
                    List(devices) { device in
                        
                        NavigationLink(destination: DeviceDetailView(device: device)) {
                            
                            HStack {
                                
                                Image(systemName: device.type)
                                    .font(.title2)
                                    .frame(width: 35)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading) {
                                    Text(device.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text("Online")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
        }
    }
}

#Preview {
    DevicesView()
}
