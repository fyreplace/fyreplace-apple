protocol MainViewProtocol: ViewProtocol {
    var showError: Bool { get nonmutating set }
    var showFailure: Bool { get nonmutating set }
    var errors: [UnexpectedError] { get nonmutating set }
    var failures: [FailureEvent] { get nonmutating set }
}

@MainActor
extension MainViewProtocol {
    func addError(_ error: UnexpectedError) {
        errors.append(error)
        tryShowSomething()
    }

    func removeError() async {
        errors.removeFirst()
        await wait()
        tryShowSomething()
    }

    func addFailure(_ failure: FailureEvent) {
        failures.append(failure)
        tryShowSomething()
    }

    func removeFailure() async {
        failures.removeFirst()
        await wait()
        tryShowSomething()
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
