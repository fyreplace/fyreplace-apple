import Foundation

extension Array where Element == IndexPath {
    init(rows: Range<Int>, section: Int) {
        self.init(rows.map { IndexPath(row: $0, section: section) })
    }

    init(row: Int, section: Int) {
        self.init(rows: row ..< row + 1, section: section)
    }
}
