import SwiftUI

struct SettingsScreen: View, SettingsScreenProtocol {
    @EnvironmentObject
    var eventBus: EventBus

    @Environment(\.api)
    var api

    @KeychainStorage("connection.token")
    var token

    @State
    var currentUser: Components.Schemas.User?

    @Namespace
    private var namespace

    var body: some View {
        DynamicForm {
            Section {
                LabeledContent(
                    "Settings.Username", value: currentUser?.username ?? .init(localized: "Loading")
                )
                LabeledContent("Settings.DateJoined") {
                    if let user = currentUser {
                        #if os(macOS)
                            let dateFormatStyle = Date.FormatStyle.DateStyle.long
                        #else
                            let dateFormatStyle = Date.FormatStyle.DateStyle.abbreviated
                        #endif

                        Text(
                            verbatim: user.dateCreated.formatted(
                                date: dateFormatStyle,
                                time: .shortened
                            )
                        )
                    } else {
                        Text("Loading")
                    }
                }

                HStack {
                    Spacer()
                    Button("Settings.Logout", role: .destructive, action: logout)
                    #if !os(macOS)
                        Spacer()
                    #endif
                }
            } header: {
                LogoHeader(namespace: namespace) {
                    Avatar(user: currentUser)
                } textContent: {
                    Text("Settings.Header")
                }
            }
        }
        .navigationTitle(Destination.settings.titleKey)
        .onAppear {
            Task {
                await getCurrentUser()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
