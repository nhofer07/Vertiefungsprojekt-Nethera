//
//  SpeedCard.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import SwiftUI

struct SpeedCard: View {
    
    var value: String
    var label: String
    
    var body: some View {
        
        VStack {
            Text(value)
                .font(.largeTitle)
                .bold()
            
            Text(label)
                .opacity(0.7)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
