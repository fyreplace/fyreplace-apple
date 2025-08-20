import SwiftUI

struct LogoHeader<ImageContent, TextContent>: View where ImageContent: View, TextContent: View {
    @ViewBuilder
    let imageContent: () -> ImageContent

    @ViewBuilder
    let textContent: () -> TextContent

    var body: some View {
        VStack {
            HStack {
                Spacer()
                imageContent().frame(width: .logoSize, height: .logoSize)
                Spacer()
            }
            #if os(macOS)
                .padding(.bottom)
            #else
                .padding(.top, 40)
                .padding(.bottom, 20)
            #endif

            HStack {
                #if os(macOS)
                    Spacer()
                #endif
                textContent()
                    .fixedSize(horizontal: false, vertical: true)
                    #if os(macOS)
                        .font(.headline)
                    #endif
                Spacer()
            }
        }
    }
}

#Preview {
    LogoHeader {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
    } textContent: {
        Text(verbatim: "Header text")
    }
}
