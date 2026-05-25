import SwiftUI

struct ContentView: View {
    
    // Auswahl für TabView
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
        
            DevicesView()
                .tabItem {
                    Label("Geräte", systemImage: "desktopcomputer")
                }
                .tag(0)
            
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(1)
            
            PresetsView()
                .tabItem {
                    Label("Presets", systemImage: "slider.horizontal.3")
                }
                .tag(2)

            SettingsChoiceView()
                .tabItem {
                    Label("Einstellungen", systemImage: "gearshape")
                }
                .tag(3)
            
        }
        .background(Color(red: 0.02, green: 0.03, blue: 0.08).ignoresSafeArea())
        .onOpenURL { url in
            openWidgetLink(url)
        }
    }

    // öffnet den passenden tab wenn man auf ein widget tippt:
    private func openWidgetLink(_ url: URL) {
        switch url.host {
        case "devices":
            selectedTab = 0
        case "guest":
            selectedTab = 3
        case "presets":
            selectedTab = 2
        default:
            selectedTab = 1
        }
    }
}

#Preview {
    ContentView()
}
