import UIKit

class PokemonCellTitleLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        textColor = .systemRed
        font = .lato(ofSize: 13, weight: .bold)
    }
}
