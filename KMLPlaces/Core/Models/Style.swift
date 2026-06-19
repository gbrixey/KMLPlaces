import SwiftData

@Model
class Style {
    var id: String
    var icon: String
    var scale: Double
    var strokeWidth: Double?
    var strokeColorHexString: String?
    var fillColorHexString: String?
    var hotspotX: Double
    var hotspotXUnits: String?
    var hotspotY: Double
    var hotspotYUnits: String?

    init(
        id: String,
        icon: String,
        scale: Double = 1,
        strokeWidth: Double? = nil,
        strokeColorHexString: String? = nil,
        fillColorHexString: String? = nil,
        hotspotX: Double = 0,
        hotspotXUnits: String? = nil,
        hotspotY: Double = 0,
        hotspotYUnits: String? = nil
    ) {
        self.id = id
        self.icon = icon
        self.scale = scale
        self.strokeWidth = strokeWidth
        self.strokeColorHexString = strokeColorHexString
        self.fillColorHexString = fillColorHexString
        self.hotspotX = hotspotX
        self.hotspotXUnits = hotspotXUnits
        self.hotspotY = hotspotY
        self.hotspotYUnits = hotspotYUnits
    }
}
