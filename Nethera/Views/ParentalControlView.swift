import SwiftUI

struct ParentalControlView: View {

    let devices = [
        Device(name: "iPhone von Nico", type: "iphone.homebutton", onlineTime: "12h", dataUsage: "57 GB", group: "Kinder"),
        Device(name: "iPad Wohnzimmer", type: "ipad", onlineTime: "4h", dataUsage: "10 GB", group: "Wohnzimmer"),
        Device(name: "Laptop Anna", type: "laptopcomputer", onlineTime: "6h", dataUsage: "20 GB", group: "Eltern")
    ]

    var body: some View {
        
        NavigationStack {
            
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
                
                VStack(spacing: 0) {
                    PageHeaderView(title: "Kindersicherung", showBackButton: true)
                    
                    // Liste der Geräte
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
                    .scrollContentBackground(.hidden)
                    // transparentes List-Hintergrund
                    .background(Color.clear)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    ParentalControlView()
    
}
