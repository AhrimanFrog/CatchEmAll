import UIKit

class TextLabel: UILabel {
    enum Style {
        case primary, secondary
    }

    init(style: Style) {
        super.init(frame: .zero)
        font = .lato(ofSize: 13)
        textColor = style == .primary ? .label : .systemGray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
