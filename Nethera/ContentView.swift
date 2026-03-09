//
//  ContentView.swift
//  Nethera
//
//  Created by Nico Hofer on 08.03.26.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
        
            GeraeteView()
                .tabItem {
                    Label("Geräte", systemImage: "desktopcomputer")
                }
            
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            EinstellungenView()
                .tabItem {
                    Label("Einstellungen", systemImage: "gearshape")
                }
            
        }
    }
}

#Preview {
    ContentView()
}

struct GeraeteView: View {
    var body: some View {
        NavigationStack {
            DevicesView()
        }
    }
}

struct EinstellungenView: View {
    var body: some View {
        Text("Einstellungen")
    }
}

