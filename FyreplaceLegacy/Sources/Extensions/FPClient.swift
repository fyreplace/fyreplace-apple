extension FPClient {
    static var `default`: Self {
        .with {
            $0.hardware = "mobile"
            $0.software = "darwin"
        }
    }
}
