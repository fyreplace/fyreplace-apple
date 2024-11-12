extension Components.Schemas.User {
    static var placeholder: Self {
        make(named: "random_user")
    }

    static func make(named username: String) -> Self {
        return .init(
            id: .randomUuid,
            dateCreated: .now,
            username: username,
            rank: .CITIZEN,
            avatar: "",
            bio: "Hello there",
            banned: false,
            blocked: false,
            tint: .init(r: 0x7F, g: 0x7F, b: 0x7F)
        )
    }
}

extension Components.Schemas.Email {
    static func make(verified: Bool = true, main: Bool = false) -> Self {
        let id = String.randomUuid
        return .init(
            id: id,
            email: "\(id)@example.org",
            verified: verified,
            main: main
        )
    }
}
