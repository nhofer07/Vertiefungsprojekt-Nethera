import SwiftUI

struct SpeedView: View {
    
    var body: some View {
        
        ZStack {
            // Dunkler Hintergrund-Gradient
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
                    Text("Geschwindigkeit")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                VStack(spacing: 25) {
                    
                    SpeedCard(value: "85.7 mb/s", label: "Download Geschwindigkeit")
                    
                    SpeedCard(value: "98.6 mb/s", label: "Upload Geschwindigkeit")
                    
                    SpeedCard(value: "72.2 mb/s", label: "ø Download")
                    
                    Button(action: {
                        print("Speedtest gestartet")
                    }) {
                        Text("Geschwindigkeit testen")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial) 
                                    
                                    LinearGradient(
                                        colors: [
                                            Color.blue.opacity(0.35),
                                            Color.cyan.opacity(0.25)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        
    }
}

#Preview {
    NavigationStack {
        SpeedView()
    }
}
