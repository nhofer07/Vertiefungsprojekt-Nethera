//
//  StatCard.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import SwiftUI

struct StatCard: View {
    
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack {
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .bold()
                
                Text(subtitle)
                    .font(.subheadline)
                    .opacity(0.7)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .opacity(0.6)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(radius: 3)
    }
}
