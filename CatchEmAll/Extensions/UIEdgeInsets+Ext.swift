import UIKit

extension UIEdgeInsets {
    var horizontal: CGFloat { left + right }

    init(all: CGFloat) {
        self.init(top: all, left: all, bottom: all, right: all)
    }
}
