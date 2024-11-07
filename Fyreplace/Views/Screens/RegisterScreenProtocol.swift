@MainActor
protocol RegisterScreenProtocol: LoadingViewProtocol {
    var username: String { get nonmutating set }
    var email: String { get nonmutating set }
    var randomCode: String { get nonmutating set }
    var isWaitingForRandomCode: Bool { get nonmutating set }
    var hasAcceptedTerms: Bool { get nonmutating set }
    var isRegistering: Bool { get nonmutating set }
    var token: String { get nonmutating set }
}

@MainActor
extension RegisterScreenProtocol {
    var isUsernameValid: Bool { 3...50 ~= username.count }
    var isEmailValid: Bool { 3...254 ~= email.count && email.contains("@") }
    var canSubmit: Bool {
        !isLoading && hasAcceptedTerms
            && (isWaitingForRandomCode ? randomCode.count >= 8 : isUsernameValid && isEmailValid)
    }

    func submit() async {
        await callWhileLoading {
            try await (isWaitingForRandomCode ? createToken() : sendEmail())
        }
    }

    func cancel() {
        isWaitingForRandomCode = false
        randomCode = ""
        isRegistering = false
    }

    func sendEmail() async throws -> UnfortunateEvent? {
        let response = try await api.createUser(
            body: .json(.init(email: email, username: username))
        )

        switch response {
        case .created:
            isWaitingForRandomCode = true
            isRegistering = true
            return nil

        case let .badRequest(badRequest):
            switch badRequest.body {
            case let .json(json) where json.violations?.first?.field == "createUser.input.username":
                return .failure(
                    title: "Register.Error.CreateUser.BadRequest.Username.Title",
                    text: "Register.Error.CreateUser.BadRequest.Username.Message"
                )

            case let .json(json) where json.violations?.first?.field == "createUser.input.email":
                return .failure(
                    title: "Register.Error.CreateUser.BadRequest.Email.Title",
                    text: "Register.Error.CreateUser.BadRequest.Email.Message"
                )

            case .json:
                return .failure(
                    title: "Error.BadRequest.Title",
                    text: "Error.BadRequest.Message"
                )
            }

        case .forbidden:
            return .failure(
                title: "Register.Error.CreateUser.Forbidden.Title",
                text: "Register.Error.CreateUser.Forbidden.Message"
            )

        case let .conflict(conflict):
            switch conflict.body {
            case let .json(explanation) where explanation.reason == "username_taken":
                return .failure(
                    title: "Register.Error.CreateUser.Conflict.Username.Title",
                    text: "Register.Error.CreateUser.Conflict.Username.Message"
                )

            case .json:
                return .failure(
                    title: "Register.Error.CreateUser.Conflict.Email.Title",
                    text: "Register.Error.CreateUser.Conflict.Email.Message"
                )
            }

        case .default:
            return .error()
        }
    }

    func createToken() async throws -> UnfortunateEvent? {
        let response = try await api.createToken(
            body: .json(.init(identifier: email, secret: randomCode))
        )

        switch response {
        case let .created(created):
            switch created.body {
            case let .plainText(text):
                token = try await .init(collecting: text, upTo: 1024)
                username = ""
                email = ""
                randomCode = ""
                isWaitingForRandomCode = false
                isRegistering = false

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
                title: "Register.Error.CreateToken.NotFound.Title",
                text: "Register.Error.CreateToken.NotFound.Message"
            )

        case .default:
            return .error()
        }
    }
}
