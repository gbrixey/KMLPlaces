import Foundation

extension Numeric {

    var nilIfZero: Self? {
        self == 0 ? nil : self
    }
}

extension Collection {

    var nilIfEmpty: Self? {
        self.isEmpty ? nil : self
    }

    func containsMultiple(where predicate: (Element) -> Bool) -> Bool {
        var number = 0
        for element in self {
            if predicate(element) {
                number += 1
                if number > 1 {
                    return true
                }
            }
        }
        return false
    }
}

extension Optional where Wrapped: Collection {

    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}

extension Array {

    func withoutNils<T>() -> [T] where Element == T? {
        compactMap { $0 }
    }
}

extension Array where Element == String {

    var commaSeparated: String {
        joined(separator: ", ")
    }
}
