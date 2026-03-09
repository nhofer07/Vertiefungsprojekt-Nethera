import SwiftUI

struct ParentalControlView: View {

    let devices = [
        Device(name: "iPhone von Nico", type: "iphone.homebutton", onlineTime: "12h", dataUsage: "57 GB"),
        Device(name: "iPad Wohnzimmer", type: "ipad", onlineTime: "4h", dataUsage: "10 GB"),
        Device(name: "Laptop Anna", type: "laptopcomputer", onlineTime: "6h", dataUsage: "20 GB")
    ]

    var body: some View {
        
        

        ZStack {
            
            
            // Dunkler Hintergrund
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.18, blue: 0.22),
                    Color(red: 0.02, green: 0.02, blue: 0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                
                HStack {
                    Text("Kindersicherung")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                List(devices) { device in
                    
                    NavigationLink(destination: DeviceDetailView(device: device)) {
                        
                        HStack(spacing: 15) {
                            Image(systemName: device.type)
                                .foregroundColor(.white)
                                .font(.system(size: 25))
                            
                            Text(device.name)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(red: 0.1, green: 0.15, blue: 0.2)) // dunkle List-Item Card
                        .cornerRadius(12)
                    }
                    .listRowBackground(Color.clear) // List-Hintergrund transparent für Gradient
                }
                .listStyle(PlainListStyle())
            }
            
        }
    }
}

#Preview {
    NavigationStack {
        ParentalControlView()
    }
}
