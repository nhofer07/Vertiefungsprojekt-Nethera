//
//  DeviceDetailView.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import SwiftUI

struct DeviceDetailView: View {

    let device: Device

    var body: some View {

        VStack(spacing: 20) {

            Image(systemName: device.type)
                .font(.system(size: 50))
                .padding()

            Text(device.name)
                .font(.title)
                .bold()

            InfoCard(title: device.onlineTime, subtitle: "Online")

            InfoCard(title: device.dataUsage, subtitle: "Datenverbrauch")

            Spacer()
        }
        .padding()
        .navigationTitle(device.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Gerät entfernen") {
                    print("Gerät entfernt")
                }
            }
        }
    }
}
