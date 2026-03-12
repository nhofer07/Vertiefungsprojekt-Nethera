//
//  DevicesView.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import SwiftUI

struct DevicesView: View {
    
    @State private var devices = [
        Device(name: "iPhone von Nico", type: "iphone.homebutton", onlineTime: "12h", dataUsage: "57 GB", group: "Eltern"),
        Device(name: "MacBook Nico", type: "laptopcomputer", onlineTime: "5h", dataUsage: "12 GB", group: "Eltern"),
        Device(name: "Annas iPhone", type: "iphone", onlineTime: "6h", dataUsage: "4 GB", group: "Kinder"),
        Device(name: "Smart TV", type: "tv", onlineTime: "3h", dataUsage: "8 GB", group: "Wohnzimmer")
    ]
    
    var groupedDevices: [String: [Device]] {
        Dictionary(grouping: devices, by: { $0.group })
    }
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.18, blue: 0.22),
                        Color(red: 0.02, green: 0.02, blue: 0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                List {
                    
                    ForEach(groupedDevices.keys.sorted(), id: \.self) { group in
                        
                        Section(header:
                            Text(group)
                                .foregroundColor(.white)
                                .font(.headline)
                        ) {
                            
                            ForEach(groupedDevices[group]!) { device in
                                
                                NavigationLink(
                                    destination: DeviceDetailView(device: device)
                                ) {
                                    
                                    HStack {
                                        
                                        Image(systemName: device.type)
                                            .font(.title2)
                                            .frame(width: 35)
                                            .foregroundColor(.white)
                                        
                                        VStack(alignment: .leading) {
                                            Text(device.name)
                                                .foregroundColor(.white)
                                            
                                            Text("Online")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
                                )
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
    }
}

#Preview {
    DevicesView()
}
