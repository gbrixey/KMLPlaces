import SwiftUI

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
