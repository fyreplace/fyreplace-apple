extension FPRank: Comparable {
    static func < (lhs: FPRank, rhs: FPRank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
