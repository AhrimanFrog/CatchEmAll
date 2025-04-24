import UIKit

class PokemonPreviewCell: UICollectionViewCell, ReuseIdentifiable {
    private let image = UIImageView()
    private let name = UILabel()
    private let summary = UILabel()

    init() {
        super.init(frame: .zero)
        configure()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
    }

    private func setConstraints() {
    }
}
