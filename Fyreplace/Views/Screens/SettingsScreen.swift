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

    @Namespace
    private var namespace

    var body: some View {
        DynamicForm {
            Section {
                LabeledContent(
                    "Settings.Username", value: currentUser?.username ?? .init(localized: "Loading")
                )
                LabeledContent("Settings.DateJoined") {
                    DateText(date: currentUser?.dateCreated)
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
                    PickableAvatar(user: currentUser) { item in
                        Task {
                            await updateAvatar(with: item)
                        }
                    }
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

    private func updateAvatar(with item: PhotosPickerItem) async {
        if let data = try? await item.loadTransferable(type: Data.self) {
            await updateAvatar(with: data)
        } else {
            eventBus.send(
                .failure(
                    title: "Settings.Error.Image.Title",
                    text: "Settings.Error.Image.Message"
                )
            )
        }
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}

private struct DateText: View {
    let date: Date?

    var body: some View {
        if let date {
            #if os(macOS)
                let dateFormatStyle = Date.FormatStyle.DateStyle.long
            #else
                let dateFormatStyle = Date.FormatStyle.DateStyle.abbreviated
            #endif

            Text(
                verbatim: date.formatted(
                    date: dateFormatStyle,
                    time: .shortened
                )
            )
        } else {
            Text("Loading")
        }
    }
}

private struct PickableAvatar: View {
    let user: Components.Schemas.User?

    let avatarSelected: (PhotosPickerItem) -> Void

    @State
    private var showEditOverlay = false

    @State
    private var avatarItem: PhotosPickerItem?

    var body: some View {
        let opacity = showEditOverlay ? 1.0 : 0.0
        let blurred = showEditOverlay
        PhotosPicker(selection: $avatarItem) {
            Avatar(user: user, blurred: blurred)
                .overlay {
                    Image(systemName: "pencil")
                        .scaleEffect(2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .background(.black.opacity(0.5))
                        .foregroundStyle(.white)
                        .clipShape(.circle)
                        .opacity(opacity)
                }
        }
        .animation(.default.speed(3), value: showEditOverlay)
        .buttonStyle(.borderless)
        .onHover { showEditOverlay = $0 }
        .onChange(of: avatarItem) {
            if let item = $0 {
                avatarSelected(item)
            }
        }
    }
}
