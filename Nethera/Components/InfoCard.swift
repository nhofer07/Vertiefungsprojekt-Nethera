//
//  InfoCard.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import SwiftUI

struct InfoCard: View {

    let title: String
    let subtitle: String

    var body: some View {

        VStack {
            Text(title)
                .font(.title2)
                .bold()

            Text(subtitle)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
