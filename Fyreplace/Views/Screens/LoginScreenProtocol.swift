import SwiftUI

protocol LoginScreenProtocol: LoadingViewProtocol {
    var eventBus: EventBus { get }
    var client: APIProtocol { get }

    var identifier: String { get nonmutating set }
    var randomCode: String { get nonmutating set }
    var isWaitingForRandomCode: Bool { get nonmutating set }
    var token: String { get nonmutating set }
}

@MainActor
extension LoginScreenProtocol {
    var canSubmit: Bool {
        !isLoading && (isWaitingForRandomCode ? randomCode.count >= 8 : 3 ... 254 ~= identifier.count)
    }

    func submit() async {
        await callWhileLoading(failOn: eventBus) {
            if isWaitingForRandomCode {
                try await createToken()
            } else if try await sendEmail() {
                withAnimation {
                    isWaitingForRandomCode = true
                }
            }
        }
    }

    func cancel() {
        withAnimation {
            isWaitingForRandomCode = false
            randomCode = ""
        }
    }

    func sendEmail() async throws -> Bool {
        let response = try await client.createNewToken(body: .json(.init(identifier: identifier)))

        switch response {
        case .ok:
            return true
        case .badRequest:
            eventBus.send(.failure(title: "Error.BadRequest.Title", text: "Error.BadRequest.Message"))
        case .notFound:
            eventBus.send(.failure(title: "Login.Error.NotFound.Title", text: "Login.Error.NotFound.Message"))
        case .default:
            eventBus.send(.error(UnknownError()))
        }

        return false
    }

    func createToken() async throws {
        let response = try await client.createToken(body: .json(.init(identifier: identifier, secret: randomCode)))

        switch response {
        case let .created(response):
            switch response.body {
            case let .plainText(body):
                token = try await .init(collecting: body, upTo: 1024)
                randomCode = ""
                isWaitingForRandomCode = false
            }
        case .badRequest:
            eventBus.send(.failure(title: "Login.Error.BadRequest.Title", text: "Login.Error.BadRequest.Message"))
        case .notFound:
            eventBus.send(.failure(title: "Login.Error.NotFound.Title", text: "Login.Error.NotFound.Message"))
        case .default:
            eventBus.send(.error(UnknownError()))
        }
    }
}
