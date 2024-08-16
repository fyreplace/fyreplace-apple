protocol SettingsScreenProtocol: ViewProtocol {
    var token: String { get nonmutating set }
}

extension SettingsScreenProtocol {
    func logout() {
        token = ""
    }
}
