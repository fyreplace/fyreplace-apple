import SwiftUI

struct EmailsScreen: View, EmailsScreenProtocol {
    @EnvironmentObject
    var eventBus: EventBus

    @Environment(\.api)
    var api: any APIProtocol

    @State
    var emails: [Components.Schemas.Email] = []

    var body: some View {
        DynamicList {
            ForEach(emails) { email in
                LabeledContent {
                } label: {
                    Text(verbatim: email.email)

                    if email.main {
                        Text("Emails.Main")
                    } else {
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle(Destination.emails.titleKey)
        .onAppear {
            Task {
                await loadEmails()
            }
        }
    }
}

#Preview {
    NavigationStack {
        EmailsScreen()
    }
}
