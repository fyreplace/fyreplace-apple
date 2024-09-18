protocol SettingsScreenProtocol: ViewProtocol {
    var api: APIProtocol { get }

    var token: String { get nonmutating set }
    var currentUser: Components.Schemas.User? { get nonmutating set }
}

extension SettingsScreenProtocol {
    func getCurrentUser() async {
        await call {
            let response = try await api.getCurrentUser()

            switch response {
            case let .ok(ok):
                switch ok.body {
                case let .json(user):
                    currentUser = user
                }

                return nil

            case .unauthorized:
                return .authorizationIssue()

            case .forbidden, .default:
                return .error(UnknownError())
            }
        }
    }

    func logout() {
        token = ""
    }
}
