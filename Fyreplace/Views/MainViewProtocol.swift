import Foundation
import Sentry

@MainActor
protocol MainViewProtocol: APIViewProtocol {
    var showError: Bool { get nonmutating set }
    var showFailure: Bool { get nonmutating set }
    var showEmailVerified: Bool { get nonmutating set }
    var errors: [CriticalError] { get nonmutating set }
    var failures: [Failure] { get nonmutating set }
    var verifiedEmail: String { get nonmutating set }
    var currentUserId: String { get nonmutating set }
    var token: String { get nonmutating set }
}

@MainActor
extension MainViewProtocol {
    func handle(event: Event) {
        switch event {
        case let .error(description):
            addError(.init(description: description))

        case let .failure(title, text):
            addFailure(.init(title: title, text: text))

        case .authorizationIssue:
            token = ""
            eventBus.send(
                .failure(
                    title: "Error.Unauthorized.Title",
                    text: "Error.Unauthorized.Text"
                )
            )

        case let .emailVerification(email, randomCode):
            Task {
                await verifyEmail(email: email, code: randomCode)
            }

        case let .emailVerified(email):
            verifiedEmail = email
            showEmailVerified = true

        default:
            break
        }
    }

    func addError(_ error: CriticalError) {
        errors.append(error)
        tryShowSomething()
    }

    func removeError() async {
        errors.removeFirst()
        await wait()
        tryShowSomething()
    }

    func addFailure(_ failure: Failure) {
        failures.append(failure)
        tryShowSomething()
    }

    func removeFailure() async {
        failures.removeFirst()
        await wait()
        tryShowSomething()
    }

    func storeCurrentUser(for token: String) async {
        guard !token.isEmpty else {
            currentUserId = ""
            SentrySDK.setUser(nil)
            return
        }

        await call {
            let response = try await api.getCurrentUser()

            switch response {
            case let .ok(ok):
                switch ok.body {
                case let .json(json):
                    currentUserId = json.id
                    let user = User(userId: currentUserId)
                    user.username = json.username
                    SentrySDK.setUser(user)
                }

                return nil

            case .unauthorized:
                return .authorizationIssue

            case .forbidden, .default:
                return .error()
            }
        }
    }

    func verifyEmail(email: String, code: String) async {
        await call {
            let response = try await api.verifyEmail(body: .json(.init(email: email, code: code)))

            switch response {
            case .ok:
                eventBus.send(.emailVerified(email: email))
                return nil

            case .badRequest:
                return .failure(
                    title: "Error.BadRequest.Title",
                    text: "Error.BadRequest.Message"
                )

            case .notFound:
                return .failure(
                    title: "Main.Error.EmailVerification.NotFound.Title",
                    text: "Main.Error.EmailVerification.NotFound.Message"
                )

            case .unauthorized:
                return .authorizationIssue

            case .forbidden, .default:
                return .error()
            }
        }
    }

    private func wait() async {
        try? await Task.sleep(for: .milliseconds(100))
    }

    private func tryShowSomething() {
        if !errors.isEmpty {
            showError = true
        } else if !failures.isEmpty {
            showFailure = true
        }
    }
}
