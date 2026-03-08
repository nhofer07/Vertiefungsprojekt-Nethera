//
//  Devices.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import Foundation

struct Device: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let onlineTime: String
    let dataUsage: String
}
