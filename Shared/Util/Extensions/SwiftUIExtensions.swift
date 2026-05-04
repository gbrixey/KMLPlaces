import SwiftUI

extension Color {

    /// Parse color from an 8-character hex string in ABGR format.
    init?(abgrHexString: String) {
        guard abgrHexString.count == 8 else { return nil }
        var abgr: UInt64 = 0
        guard Scanner(string: abgrHexString).scanHexInt64(&abgr) else { return nil }
        let red, green, blue, alpha: CGFloat
        alpha = CGFloat((abgr & 0xFF000000) >> 24) / 255.0
        blue = CGFloat((abgr & 0x00FF0000) >> 16) / 255.0
        green = CGFloat((abgr & 0x0000FF00) >> 8) / 255.0
        red = CGFloat(abgr & 0x000000FF) / 255.0
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension EdgeInsets {

    static var zero: EdgeInsets {
        EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}

extension View {

    func padding(horizontal: CGFloat = 0, vertical: CGFloat = 0) -> some View {
        padding(EdgeInsets(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal))
    }
}
