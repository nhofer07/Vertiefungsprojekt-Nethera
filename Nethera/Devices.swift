//
//  Devices.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import Foundation

struct Device: Identifiable {
    let id = UUID()
    var name: String
    var type: String
    var onlineTime: String
    var dataUsage: String
    var group: String = "Neu verbunden"
}
