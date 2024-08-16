protocol RegisterScreenProtocol: LoadingViewProtocol {
    var username: String { get nonmutating set }
    var email: String { get nonmutating set }
}

extension RegisterScreenProtocol {
    var isUsernameValid: Bool { 3 ... 50 ~= username.count }
    var isEmailValid: Bool { 3 ... 254 ~= email.count && email.contains("@") }
    var canSubmit: Bool { isUsernameValid && isEmailValid && !isLoading }
}
