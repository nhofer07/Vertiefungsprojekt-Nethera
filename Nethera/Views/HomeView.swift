//
//  HomeView.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                NavigationLink(destination: DevicesView()) {
                    StatCard(title: "11 Geräte aktiv", subtitle: "Geräte")
                }
                
                NavigationLink(destination: SpeedView()) {
                    StatCard(title: "200 mb/s", subtitle: "Durchschnittlicher Verbrauch")
                }
                
                NavigationLink(destination: ParentalControlView()) {
                    StatCard(title: "3 Geräte", subtitle: "von Kindersicherung betroffen")
                }
                
               
                
                Spacer()
            }
            .padding()
            .navigationTitle("Start")
        }
    }
}
