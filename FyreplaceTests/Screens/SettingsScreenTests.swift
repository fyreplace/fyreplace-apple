import Foundation
import Testing

@testable import Fyreplace

@Suite("Settings screen")
@MainActor
struct SettingsScreenTests {
    class FakeScreen: FakeScreenBase, SettingsScreenProtocol {
        var token = ""
        var currentUser: Components.Schemas.User?
    }

    @Test("Screen retrieves current user")
    func screenRetrievesCurrentUser() async {
        let screen = FakeScreen(eventBus: .init(), api: .fake())
        await screen.getCurrentUser()
        #expect(screen.currentUser != nil)
    }

    @Test("Updating avatar with a too large image produces a failure")
    func updateAvatarTooLargeProducesFailure() async throws {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        await screen.getCurrentUser()
        await screen.updateAvatar(
            with: try await .init(collecting: FakeClient.largeImageBody, upTo: 64))
        #expect(eventBus.storedEvents.count == 1)
        #expect(screen.currentUser?.avatar == "")
    }

    @Test("Updating avatar with an invalid image produces a failure")
    func updateAvatarNotImageProducesFailure() async throws {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        await screen.getCurrentUser()
        await screen.updateAvatar(
            with: try await .init(collecting: FakeClient.notImageBody, upTo: 64))
        #expect(eventBus.storedEvents.count == 1)
        #expect(screen.currentUser?.avatar == "")
    }

    @Test("Updating avatar with a valid image produces no failures")
    func updateAvatarValidProducesNoFailures() async throws {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        await screen.getCurrentUser()
        await screen.updateAvatar(
            with: try await .init(collecting: FakeClient.normalImageBody, upTo: 64))
        #expect(eventBus.storedEvents.isEmpty)
        #expect(screen.currentUser?.avatar == FakeClient.avatar)
    }

    @Test("Removing avatar produces no failures")
    func removeAvatarProducesNoFailures() async throws {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        await screen.getCurrentUser()
        await screen.updateAvatar(
            with: try await .init(collecting: FakeClient.normalImageBody, upTo: 64))
        await screen.removeAvatar()
        #expect(eventBus.storedEvents.isEmpty)
        #expect(screen.currentUser?.avatar == "")
    }
}
