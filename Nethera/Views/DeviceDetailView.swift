import SwiftUI

struct DeviceDetailView: View {

    let device: Device

    var body: some View {
        
        ZStack {
            
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.18, blue: 0.22),
                    Color(red: 0.02, green: 0.02, blue: 0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Image(systemName: device.type)
                    .font(.system(size: 50))
                    .foregroundColor(.white) // Symbol sichtbar
                    .padding()
                
                Text(device.name)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white) // Name sichtbar
                
                // InfoCards unverändert
                InfoCard(title: device.onlineTime, subtitle: "Online")
                InfoCard(title: device.dataUsage, subtitle: "Datenverbrauch")
                
                Spacer()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Gerät entfernen") {
                    print("Gerät entfernt")
                }
                .foregroundColor(.white) // Button sichtbar
            }
        }
    }
}

#Preview {
    NavigationStack {
        DeviceDetailView(device: Device(name: "iPhone von Nico", type: "iphone.homebutton", onlineTime: "12h", dataUsage: "57 GB"))
    }
}
