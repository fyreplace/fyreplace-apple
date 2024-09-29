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

    @Test("Too large avatar produces a failure")
    func tooLargeAvatarProducesFailure() async throws {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        await screen.getCurrentUser()
        await screen.updateAvatar(
            with: try await .init(collecting: FakeClient.largeImageBody, upTo: 64))
        #expect(eventBus.storedEvents.count == 1)
        #expect(screen.currentUser?.avatar == "")
    }

    @Test("Not image avatar produces a failure")
    func notImageAvatarProducesFailure() async throws {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        await screen.getCurrentUser()
        await screen.updateAvatar(
            with: try await .init(collecting: FakeClient.notImageBody, upTo: 64))
        #expect(eventBus.storedEvents.count == 1)
        #expect(screen.currentUser?.avatar == "")
    }

    @Test("Valid avatar produces no failures")
    func validAvatarProducesNoFailures() async throws {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        await screen.getCurrentUser()
        await screen.updateAvatar(
            with: try await .init(collecting: FakeClient.normalImageBody, upTo: 64))
        #expect(eventBus.storedEvents.isEmpty)
        #expect(screen.currentUser?.avatar == FakeClient.avatar)
    }
}
