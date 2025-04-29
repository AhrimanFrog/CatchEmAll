import SnapKit
import UIKit

class PokemonPreviewCell: UICollectionViewCell, ReuseIdentifiable {
    private let image = UIImageView()
    private let name = PokemonCellTitleLabel()
    private let summary = TextLabel(style: .secondary)

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setConstraints()
        backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setPokemon(_ pokemon: PokemonLight) {
        name.text = pokemon.name.capitalized
        summary.text = pokemon.powers.joined(separator: ", ")
    }

    private func setConstraints() {
        addSubviews(image, name, summary)

        image.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(snp.centerX).offset(12)
        }

        name.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.leading.equalToSuperview().offset(11)
            make.trailing.equalTo(snp.centerX)
            make.height.lessThanOrEqualTo(16)
        }

        summary.snp.makeConstraints { make in
            make.leading.equalTo(name)
            make.trailing.equalTo(image).offset(-5)
            make.top.equalTo(name.snp.bottom).offset(6)
            make.height.lessThanOrEqualTo(13)
        }
    }
}
