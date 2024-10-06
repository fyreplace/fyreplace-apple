import PhotosUI
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

    @Environment(\.config)
    private var config

    @Namespace
    private var namespace

    @State
    private var showPhotosPicker = false

    @State
    private var avatarItem: PhotosPickerItem?

    var body: some View {
        DynamicForm {
            Section {
                let logoutButton = Button("Settings.Logout", role: .destructive, action: logout)

                HStack {
                    EditableAvatar(
                        user: currentUser,
                        avatarSelected: updateAvatar,
                        avatarRemoved: removeAvatar
                    )
                    .frame(width: .logoSize, height: .logoSize)

                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        Text(verbatim: currentUser?.username ?? .init(localized: "Loading"))
                            .font(.headline)
                        DateJoinedText(date: currentUser?.dateCreated)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }

                    #if os(macOS)
                        Spacer()
                        logoutButton
                    #endif
                }

                #if !os(macOS)
                    HStack {
                        Spacer()
                        logoutButton
                        Spacer()
                    }
                #endif
            } header: {
                Text("Settings.Profile.Header")
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

private struct DateJoinedText: View {
    let date: Date?

    var body: some View {
        if let date {
            #if os(macOS)
                let dateFormatStyle = Date.FormatStyle.DateStyle.long
            #else
                let dateFormatStyle = Date.FormatStyle.DateStyle.abbreviated
            #endif

            Text("Settings.DateJoined:\(date.formatted(date: dateFormatStyle, time: .shortened))")
        } else {
            Text("Loading")
        }
    }
}
