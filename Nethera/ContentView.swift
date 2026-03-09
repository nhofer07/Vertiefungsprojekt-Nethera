import SwiftUI

struct ContentView: View {
    
    // Auswahl für TabView
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
        
            GeraeteView()
                .tabItem {
                    Label("Geräte", systemImage: "desktopcomputer")
                }
                .tag(0)
            
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(1)
            
            EinstellungenView()
                .tabItem {
                    Label("Einstellungen", systemImage: "gearshape")
                }
                .tag(2)
            
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
