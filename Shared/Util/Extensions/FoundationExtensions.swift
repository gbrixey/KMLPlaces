import Foundation

extension Collection {

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

extension String {

    init(key: String) {
        self = NSLocalizedString(key, comment: "")
    }
}
