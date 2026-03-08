//
//  ParentalControlView.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import SwiftUI

struct ParentalControlView: View {

    let devices = [
        Device(name: "iPhone von Nico", type: "iphone", onlineTime: "12h", dataUsage: "57 GB"),
        Device(name: "iPad Wohnzimmer", type: "ipad", onlineTime: "4h", dataUsage: "10 GB"),
        Device(name: "Laptop Anna", type: "laptopcomputer", onlineTime: "6h", dataUsage: "20 GB")
    ]

    var body: some View {

        List(devices) { device in

            NavigationLink(destination: DeviceDetailView(device: device)) {

                HStack {

                    Image(systemName: device.type)

                    Text(device.name)

                    Spacer()
                }
            }
        }
        .navigationTitle("Kindersicherung")
    }
}
