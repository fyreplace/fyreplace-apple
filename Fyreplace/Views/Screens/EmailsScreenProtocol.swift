@MainActor
protocol EmailsScreenProtocol: APIViewProtocol {
    var emails: [Components.Schemas.Email] { get nonmutating set }
}

@MainActor
extension EmailsScreenProtocol {
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
}
