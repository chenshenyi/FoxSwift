import Foundation

extension Array where Element: Hashable {
    var noDuplicate: Array {
        Array(Set(self))
    }
}
