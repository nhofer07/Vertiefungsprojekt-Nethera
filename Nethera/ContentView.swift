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
            
            VerwaltenView()
                .tabItem {
                    Label("Verwalten", systemImage: "square.grid.2x2")
                }
            
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
            
            KontoView()
                .tabItem {
                    Label("Konto", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}

struct VerwaltenView: View {
    var body: some View {
        AddDomainView()
    }
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

struct KontoView: View {
    var body: some View {
        Text("Konto")
    }
}
