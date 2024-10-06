import SwiftUI

struct Avatar: View {
    let user: Components.Schemas.User?

    var blurred = false

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
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    AsyncImage(url: .init(string: avatar)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                    } placeholder: {
                        ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white.gradient, tint.gradient)
            }
        }
        .blur(radius: blurred ? 1 : 0)
        .clipShape(.circle)
    }
}

#Preview {
    Avatar(user: .placeholder)
        .frame(width: 100, height: 100)
        .padding()
}
