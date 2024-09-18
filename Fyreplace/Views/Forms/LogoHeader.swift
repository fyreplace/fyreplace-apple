import SwiftUI

struct LogoHeader<ImageContent, TextContent>: View where ImageContent: View, TextContent: View {
    let namespace: Namespace.ID

    @ViewBuilder
    let imageContent: () -> ImageContent

    @ViewBuilder
    let textContent: () -> TextContent

    var body: some View {
        VStack {
            HStack {
                Spacer()
                imageContent()
                    #if os(macOS)
                        .frame(width: 60, height: 60)
                    #else
                        .frame(width: 80, height: 80)
                    #endif
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
        .matchedGeometryEffect(id: "header", in: namespace)
    }
}
