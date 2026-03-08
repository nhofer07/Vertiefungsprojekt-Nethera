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

        List(devices) { device in

            NavigationLink(destination: DeviceDetailView(device: device)) {

                HStack {

                    Image(systemName: device.type)
                        .font(.title2)
                        .frame(width: 35)

                    VStack(alignment: .leading) {
                        Text(device.name)
                            .font(.headline)

                        Text("Online")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Geräte")
    }
}
