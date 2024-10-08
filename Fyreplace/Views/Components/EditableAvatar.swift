import PhotosUI
import SwiftUI

struct EditableAvatar: View {
    let user: Components.Schemas.User?

    let avatarSelected: (Data) async -> Void

    let avatarRemoved: () async -> Void

    @EnvironmentObject
    private var eventBus: EventBus

    @State
    private var showEditOverlay = false

    @State
    private var showPhotosPicker = false

    @State
    private var avatarItem: PhotosPickerItem?

    var body: some View {
        Button {
            showPhotosPicker = true
        } label: {
            Avatar(user: user, blurred: showEditOverlay)
                .overlay {
                    Image(systemName: "pencil")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .background(.black.opacity(0.5))
                        .foregroundStyle(.white)
                        .opacity(showEditOverlay ? 1.0 : 0.0)
                        .clipShape(.circle)
                }
        }
        .animation(.default.speed(3), value: showEditOverlay)
        .buttonStyle(.borderless)
        .photosPicker(isPresented: $showPhotosPicker, selection: $avatarItem)
        .onHover { showEditOverlay = $0 }
        .contextMenu {
            Button {
                showPhotosPicker = true
            } label: {
                Label("EditableAvatar.ContextMenu.Change", systemImage: "photo")
            }
            .disabled(user == nil)

            Button(role: .destructive) {
                avatarItem = nil

                Task {
                    await avatarRemoved()
                }
            } label: {
                Label("EditableAvatar.ContextMenu.Remove", systemImage: "trash")
            }
            .disabled(user?.avatar.isEmpty ?? true)
        }
        .dropDestination(for: Data.self) { items, _ in
            guard let data = items.first else { return false }
            avatarItem = nil

            Task {
                await avatarSelected(data)
            }

            return true
        }
        .onChange(of: avatarItem) { item in
            guard let item else { return }
            avatarItem = nil

            Task {
                await usePhotoItem(item)
            }
        }
    }

    private func usePhotoItem(_ item: PhotosPickerItem) async {
        if let data = try? await item.loadTransferable(type: Data.self) {
            await avatarSelected(data)
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
