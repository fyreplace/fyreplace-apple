protocol LoginScreenProtocol: LoadingViewProtocol {
    var api: APIProtocol { get }

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
        await callWhileLoading {
            try await (isWaitingForRandomCode ? createToken() : sendEmail())
        }
    }

    func cancel() {
        isWaitingForRandomCode = false
        randomCode = ""
    }

    func sendEmail() async throws -> UnfortunateEvent? {
        let response = try await api.createNewToken(body: .json(.init(identifier: identifier)))

        switch response {
        case .ok:
            isWaitingForRandomCode = true
            return nil

        case .badRequest:
            return .failure(
                title: "Error.BadRequest.Title",
                text: "Error.BadRequest.Message"
            )

        case .forbidden:
            return .failure(
                title: "Error.Forbidden.Title",
                text: "Error.Forbidden.Message"
            )

        case .notFound:
            return .failure(
                title: "Login.Error.NotFound.Title",
                text: "Login.Error.NotFound.Message"
            )

        case .default:
            return .error(UnknownError())
        }
    }

    func createToken() async throws -> UnfortunateEvent? {
        let response = try await api.createToken(body: .json(.init(identifier: identifier, secret: randomCode)))

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

                return nil
            }

        case .badRequest:
            return .failure(
                title: "Account.Error.CreateToken.BadRequest.Title",
                text: "Account.Error.CreateToken.BadRequest.Message"
            )

        case .notFound:
            return .failure(
                title: "Login.Error.NotFound.Title",
                text: "Login.Error.NotFound.Message"
            )

        case .default:
            return .error(UnknownError())
        }
    }
}
