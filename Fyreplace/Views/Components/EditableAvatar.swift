import PhotosUI
import SwiftUI

struct EditableAvatar: View {
    let user: Components.Schemas.User?

    let avatarSelected: (Data) async -> Void

    @EnvironmentObject
    private var eventBus: EventBus

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
        .dropDestination(for: Data.self) { items, _ in
            guard let data = items.first else { return false }

            Task {
                await avatarSelected(data)
            }

            return true
        }
        .onChange(of: avatarItem) { item in
            guard let item else { return }

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
