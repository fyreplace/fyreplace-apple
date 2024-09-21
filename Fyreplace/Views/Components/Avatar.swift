import SwiftUI

struct Avatar: View {
    let user: Components.Schemas.User?

    private var tint: Color {
        if let user = user {
            .init(
                red: Double(user.tint.r) / 255,
                green: Double(user.tint.g) / 255,
                blue: Double(user.tint.b) / 255
            )
        } else {
            .gray
        }
    }

    var body: some View {
        ZStack {
            if let avatar = user?.avatar, !avatar.isEmpty {
                AsyncImage(url: .init(string: avatar)) {
                    $0.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white.gradient, tint.gradient)
            }
        }
        .clipShape(.circle)
    }
}

#Preview {
    Avatar(user: .placeholder)
        .frame(width: 100, height: 100)
        .padding()
}
