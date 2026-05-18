import SwiftUI

struct PageHeaderView<TrailingContent: View>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    let title: String
    let showBackButton: Bool
    @ViewBuilder var trailingContent: () -> TrailingContent

    init(
        title: String,
        showBackButton: Bool = false,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.title = title
        self.showBackButton = showBackButton
        self.trailingContent = trailingContent
    }

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 52)

            HStack {
                Group {
                    if showBackButton && presentationMode.wrappedValue.isPresented {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(width: 34, height: 34)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Circle())
                        }
                    } else {
                        Color.clear
                            .frame(width: 34, height: 34)
                    }
                }

                Spacer()

                trailingContent()
                    .frame(width: 34, height: 34, alignment: .trailing)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.1))
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [Color.blue, Color.black], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

        VStack {
            PageHeaderView(title: "Sehr langer Seitentitel zum Umbrechen", showBackButton: true) {
                Button {
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }

            Spacer()
        }
    }
}
