import SwiftUI

struct LogoHeader: View {
    let text: LocalizedStringKey

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image("Logo", label: Text("Logo"))
                    .resizable()
                #if os(macOS)
                    .frame(width: 50, height: 50)
                #else
                    .frame(width: 80, height: 80)
                #endif
                Spacer()
            }
            #if os(macOS)
            .padding(.bottom)
            #else
            .padding(.vertical, 40)
            #endif

            HStack {
                #if os(macOS)
                    Spacer()
                #endif
                Text(text)
                    .fixedSize(horizontal: false, vertical: true)
                #if os(macOS)
                    .font(.headline)
                #endif
                Spacer()
            }
        }
    }
}
