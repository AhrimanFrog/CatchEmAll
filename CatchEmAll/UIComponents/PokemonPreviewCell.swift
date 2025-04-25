import UIKit

class PokemonPreviewCell: UICollectionViewCell, ReuseIdentifiable {
    private let image = UIImageView()
    private let name = PokemonCellTitleLabel()
    private let summary = TextLabel(style: .secondary)

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setConstraints() {
    }
}
