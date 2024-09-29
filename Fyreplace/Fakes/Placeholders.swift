extension Components.Schemas.User {
    static var placeholder: Self {
        make(named: "random_user")
    }

    static func make(named username: String) -> Self {
        return Self(
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
