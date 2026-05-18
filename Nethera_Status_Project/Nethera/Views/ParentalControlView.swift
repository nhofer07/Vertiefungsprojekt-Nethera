import SwiftUI

struct ParentalControlView: View {

    // dummydaten:
    @State private var devices = [
        Device(id: UUID(), name: "iPhone von Nico", type: "iphone.homebutton", onlineTime: "12h", dataUsage: "57 GB", group: "Kinder"),
        Device(id: UUID(), name: "iPad Wohnzimmer", type: "ipad", onlineTime: "4h", dataUsage: "10 GB", group: "Wohnzimmer"),
        Device(id: UUID(), name: "Laptop Anna", type: "laptopcomputer", onlineTime: "6h", dataUsage: "20 GB", group: "Eltern")
    ]

    private let groups = ["Eltern", "Kinder", "Wohnzimmer", "Neu verbunden", "Gast"]

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
                
                VStack(spacing: 12) {
                    PageHeaderView(title: "Kindersicherung", showBackButton: true)

                    Text("\(devices.count) Geräte geschützt")
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.white.opacity(0.78))
                    .padding(.horizontal)
                    
                    // Liste der Geräte
                    List(devices.indices, id: \.self) { index in
                        let device = devices[index]
                        
                        NavigationLink(destination: DeviceDetailView(device: $devices[index], groups: groups)) {
                            
                            HStack {
                                
                                Image(systemName: device.type)
                                    .font(.title2)
                                    .frame(width: 35)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(device.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text("\(device.onlineTime) online")
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
                                .fill(Color.white.opacity(0.09))
                        )
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    // transparentes List-Hintergrund
                    .background(Color.clear)
                    .padding(.horizontal)
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
