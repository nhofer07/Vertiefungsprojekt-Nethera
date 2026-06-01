import SwiftUI

struct SpeedCard: View {
    
    var value: String
    var label: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
            
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.66))
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.16), radius: 12, x: 0, y: 6)
        )
    }
}

#Preview {
    SpeedCard(value: "120 Mbps", label: "Download")
        .padding()
        .background(Color.black)
}
