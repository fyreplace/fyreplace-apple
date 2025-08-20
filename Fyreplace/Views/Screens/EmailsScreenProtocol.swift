@MainActor
protocol EmailsScreenProtocol: LoadingViewProtocol {
    var showAddEmail: Bool { get nonmutating set }
    var showVerifyEmail: Bool { get nonmutating set }
    var emails: [Components.Schemas.Email] { get nonmutating set }
    var newEmail: String { get nonmutating set }
    var unverifiedEmail: String { get nonmutating set }
    var randomCode: String { get nonmutating set }
}

@MainActor
extension EmailsScreenProtocol {
    var canAddNewEmail: Bool {
        !newEmail.isEmpty
    }

    func loadEmails() async {
        emails.removeAll()
        var page: Int32 = 0

        while await loadEmails(at: page) {
            page += 1
        }
    }

    func loadEmails(at page: Int32) async -> Bool {
        var hasMore = false

        await call {
            let response = try await api.listEmails(query: .init(page: page))

            switch response {
            case let .ok(ok):
                switch ok.body {
                case let .json(json):
                    hasMore = !json.isEmpty
                    emails.append(contentsOf: json)
                }

                return nil

            case .badRequest:
                return .failure(
                    title: "Error.BadRequest.Title",
                    text: "Error.BadRequest.Message"
                )

            case .unauthorized:
                return .authorizationIssue

            case .forbidden, .default:
                return .error()
            }
        }

        return hasMore
    }

    func addEmail() async {
        defer {
            newEmail = ""
        }

        await callWhileLoading {
            let response = try await api.createEmail(body: .json(.init(email: newEmail)))

            switch response {
            case let .created(created):
                switch created.body {
                case let .json(json):
                    emails.append(json)
                }

                return nil

            case .badRequest:
                return .failure(
                    title: "Emails.Error.BadRequest.Title",
                    text: "Emails.Error.BadRequest.Message"
                )

            case .conflict:
                return .failure(
                    title: "Emails.Error.Conflict.Title",
                    text: "Emails.Error.Conflict.Message"
                )

            case .unauthorized:
                return .authorizationIssue

            case .forbidden, .default:
                return .error()
            }
        }
    }

    func verifyEmail() {
        eventBus.send(.emailVerification(email: unverifiedEmail, randomCode: randomCode))
        randomCode = ""
    }

    func finishVerifyingEmail(_ email: String) {
        if let index = emails.firstIndex(where: { $0.email == email }) {
            emails[index].verified = true
        }
    }
}
