import SwiftData

@Model
class StyleMap {
    var id: String
    var normal: String?
    var highlighted: String?

    init(
        id: String,
        normal: String? = nil,
        highlighted: String? = nil
    ) {
        self.id = id
        self.normal = normal
        self.highlighted = highlighted
    }
}
