import SwiftUI

struct InfoCard: View {

    let title: String
    let subtitle: String

    var body: some View {

        VStack {
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(.white) // Weißer Text

            Text(subtitle)
                .foregroundColor(.gray) // Subtitle bleibt grau
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.1, green: 0.15, blue: 0.2)) // dunkle Hintergrundfarbe
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2) // leichter Schatten
        )
    }
}

#Preview {
    InfoCard(title: "12h", subtitle: "Online")
        .padding()
        .background(Color.black)
}
