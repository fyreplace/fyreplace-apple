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

    @State
    var bio = ""

    @State
    var isLoadingAvatar = false

    @Environment(\.config)
    private var config

    @Namespace
    private var namespace

    @State
    private var showPhotosPicker = false

    @State
    private var avatarItem: PhotosPickerItem?

    @FocusState
    private var bioFocused: Bool

    var body: some View {
        DynamicForm {
            Section("Settings.Profile.Header") {
                let logoutButton = Button("Settings.Logout", role: .destructive, action: logout)

                HStack {
                    ZStack {
                        if isLoadingAvatar {
                            ProgressView()
                        } else {
                            EditableAvatar(
                                user: currentUser,
                                avatarSelected: updateAvatar,
                                avatarRemoved: removeAvatar
                            )
                        }
                    }
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
            }

            Section {
                TextEditor(text: $bio)
                    .scrollContentBackground(.hidden)
                    .frame(maxHeight: 160)

                HStack {
                    Spacer()
                    Button("Settings.Bio.Update") {
                        Task {
                            await updateBio()
                        }
                    }
                    .disabled(!canUpdateBio)
                    #if !os(macOS)
                        Spacer()
                    #endif
                }
            } header: {
                Text("Settings.Bio.Header")
            } footer: {
                Text("Settings.Bio.Footer:\(bio.count),\(Components.Schemas.User.maxBioSize)")
            }

            Section("Settings.Emails.Header") {
                NavigationLink("Settings.Emails") {
                    Screen(destination: .emails)
                }
            }

            Section("Settings.About.Header") {
                Link(destination: config.app.info.website) {
                    Label("App.Help.Website", systemImage: "safari")
                }
                .foregroundStyle(.tint)

                Link(destination: config.app.info.termsOfService) {
                    Label("App.Help.TermsOfService", systemImage: "shield")
                }
                .foregroundStyle(.tint)

                Link(destination: config.app.info.privacyPolicy) {
                    Label("App.Help.PrivacyPolicy", systemImage: "lock")
                }
                .foregroundStyle(.tint)

                Link(destination: config.app.info.sourceCode) {
                    Label("App.Help.SourceCode", systemImage: "curlybraces")
                }
                .foregroundStyle(.tint)
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
