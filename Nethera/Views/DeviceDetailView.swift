import SwiftUI

struct DeviceDetailView: View {

    let device: Device
    
    @State private var parentalControl = true
    @State private var prioritized = false
    @State private var timeLimitEnabled = false
    @State private var startTime = Date()
    @State private var endTime = Date()
    
    @State private var group = "Eltern"
    
    let groups = ["Eltern","Kinder","Wohnzimmer","Gast"]

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
                    .foregroundColor(.white)
                    .padding()
                
                Text(device.name)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                
                InfoCard(title: device.onlineTime, subtitle: "Online")
                InfoCard(title: device.dataUsage, subtitle: "Datenverbrauch")
                
                // GRUPPE ÄNDERN
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Gerätegruppe")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Picker("Gruppe", selection: $group) {
                        ForEach(groups, id:\.self) { g in
                            Text(g)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
                )
            
                
                VStack(spacing: 15) {
                    
                    Toggle("Kindersicherung", isOn: $parentalControl)
                        .toggleStyle(SwitchToggleStyle(tint: .cyan))
                        .foregroundColor(.white)
                    
                    Toggle("Gerät priorisieren", isOn: $prioritized)
                        .toggleStyle(SwitchToggleStyle(tint: .cyan))
                        .foregroundColor(.white)
                    
                    Toggle("Zeitbeschränkung", isOn: $timeLimitEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .cyan))
                        .foregroundColor(.white)
                    
                    if timeLimitEnabled {
                        
                        VStack(spacing: 12) {
                            
                            HStack {
                                Text("Von")
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                DatePicker(
                                    "",
                                    selection: $startTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                                .tint(Color(red: 0.35, green: 0.75, blue: 0.9))
                                .colorScheme(.dark)
                            }
                            
                            HStack {
                                Text("Bis")
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                DatePicker(
                                    "",
                                    selection: $endTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                                .tint(Color(red: 0.35, green: 0.75, blue: 0.9))
                                .colorScheme(.dark)
                            }
                            
                            Text("Internet verboten von \(startTime.formatted(date: .omitted, time: .shortened)) bis \(endTime.formatted(date: .omitted, time: .shortened))")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .colorScheme(.dark)
                    }
                    
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.35, green: 0.75, blue: 0.9).opacity(0.25), lineWidth: 1)
                )
                
                Spacer()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Gerät entfernen") {
                    print("Gerät entfernt")
                }
                .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DeviceDetailView(
            device: Device(
                name: "iPhone von Nico",
                type: "iphone.homebutton",
                onlineTime: "12h",
                dataUsage: "57 GB",
                group: "Eltern"
            )
        )
    }
}
