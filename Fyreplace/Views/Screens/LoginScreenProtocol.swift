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
            } else {
                try await sendEmail()
            }
        }
    }

    func cancel() {
        isWaitingForRandomCode = false
        randomCode = ""
    }

    func sendEmail() async throws {
        let response = try await client.createNewToken(body: .json(.init(identifier: identifier)))

        switch response {
        case .ok:
            isWaitingForRandomCode = true

        case .badRequest:
            eventBus.send(.failure(
                title: "Error.BadRequest.Title",
                text: "Error.BadRequest.Message"
            ))

        case .forbidden:
            eventBus.send(.failure(
                title: "Error.Forbidden.Title",
                text: "Error.Forbidden.Message"
            ))

        case .notFound:
            eventBus.send(.failure(
                title: "Login.Error.NotFound.Title",
                text: "Login.Error.NotFound.Message"
            ))

        case .default:
            eventBus.send(.error(UnknownError()))
        }
    }

    func createToken() async throws {
        let response = try await client.createToken(body: .json(.init(identifier: identifier, secret: randomCode)))

        switch response {
        case let .created(created):
            switch created.body {
            case let .plainText(text):
                token = try await .init(collecting: text, upTo: 1024)
                identifier = ""
                randomCode = ""
                isWaitingForRandomCode = false

                #if !os(macOS)
                    scheduleTokenRefresh()
                #endif
            }

        case .badRequest:
            eventBus.send(.failure(
                title: "Account.Error.CreateToken.BadRequest.Title",
                text: "Account.Error.CreateToken.BadRequest.Message"
            ))

        case .notFound:
            eventBus.send(.failure(
                title: "Login.Error.NotFound.Title",
                text: "Login.Error.NotFound.Message"
            ))

        case .default:
            eventBus.send(.error(UnknownError()))
        }
    }
}
