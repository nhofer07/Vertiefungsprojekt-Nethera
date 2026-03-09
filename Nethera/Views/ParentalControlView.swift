import SwiftUI

struct ParentalControlView: View {

    let devices = [
        Device(name: "iPhone von Nico", type: "iphone.homebutton", onlineTime: "12h", dataUsage: "57 GB"),
        Device(name: "iPad Wohnzimmer", type: "ipad", onlineTime: "4h", dataUsage: "10 GB"),
        Device(name: "Laptop Anna", type: "laptopcomputer", onlineTime: "6h", dataUsage: "20 GB")
    ]

    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                // Dunkler Hintergrund Gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.18, blue: 0.22),
                        Color(red: 0.02, green: 0.02, blue: 0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Titel
                    HStack {
                        Text("Kindersicherung")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Liste der Geräte (im DevicesView-Style)
                    List(devices) { device in
                        
                        NavigationLink(destination: DeviceDetailView(device: device)) {
                            
                            HStack {
                                
                                Image(systemName: device.type)
                                    .font(.title2)
                                    .frame(width: 35)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(device.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text("Online")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                // Pfeil rechts
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .padding(.vertical, 6)
                        }
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
                                .opacity(0.9)
                        )
                    }
                    .scrollContentBackground(.hidden) // transparentes List-Hintergrund
                    .background(Color.clear)
                }
            }
        }
    }
}

#Preview {
    ParentalControlView()
    
}
