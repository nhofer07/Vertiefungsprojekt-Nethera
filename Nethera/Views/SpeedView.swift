import SwiftUI

struct SpeedView: View {
    
    var body: some View {
        
        @State var buttonPressed = false
        
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
                    

                    Button {
                        buttonPressed.toggle()
                        print("Speedtest gestartet")
                    } label: {
                        Text("Geschwindigkeit testen")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.blue.opacity(0.3))
                                    .shadow(
                                        color: Color.blue.opacity(buttonPressed ? 0.5 : 0.3),
                                        radius: buttonPressed ? 12 : 6,
                                        x: 0,
                                        y: buttonPressed ? 6 : 4
                                    )
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
