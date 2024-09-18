extension Components.Schemas.User {
    static let placeholder = Self(
        id: .randomUuid,
        dateCreated: .now,
        username: "random_user",
        rank: .CITIZEN,
        avatar: "",
        bio: "Hello there",
        banned: false,
        blocked: false,
        tint: .init(r: 0x7F, g: 0x7F, b: 0x7F)
    )
}
