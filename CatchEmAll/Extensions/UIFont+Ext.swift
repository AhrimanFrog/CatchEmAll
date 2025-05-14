import UIKit

extension UIFont {
    enum FontWeight: String {
        case bold, regular
    }

    static func lato(ofSize: CGFloat, weight: FontWeight = .regular) -> UIFont {
        return UIFont(name: "Lato-\(weight.rawValue.capitalized)", size: ofSize)!
    }
}
