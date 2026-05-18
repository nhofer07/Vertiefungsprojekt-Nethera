import SwiftUI

struct SpeedCard: View {
    
    var value: String
    var label: String
    
    var body: some View {
        
        VStack {
            Text(value)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white) // Wert sichtbar
            
            Text(label)
                .foregroundColor(.gray) // Label dezent
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.1, green: 0.15, blue: 0.2)) // dunkler Hintergrund
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    SpeedCard(value: "120 Mbps", label: "Download")
        .padding()
        .background(Color.black)
}
