import UIKit

extension UIFont {
    enum FontStyle: String {
        case bold, regular
    }

    static func lato(ofSize: CGFloat, style: FontStyle = .regular) -> UIFont? {
        return UIFont(name: "Lato-\(style.rawValue.capitalized)", size: ofSize)
    }
}
