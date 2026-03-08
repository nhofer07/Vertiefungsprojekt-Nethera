//
//  SpeedView.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import SwiftUI

struct SpeedView: View {
    
    var body: some View {
        
        VStack(spacing: 25) {
            
            SpeedCard(value: "85.7 mb/s", label: "Download Geschwindigkeit")
            
            SpeedCard(value: "98.6 mb/s", label: "Upload Geschwindigkeit")
            
            SpeedCard(value: "72.2 mb/s", label: "ø Download")
            
            Spacer()
        }
        .padding()
        .navigationTitle("Geschwindigkeit")
    }
}
