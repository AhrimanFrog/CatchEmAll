import SnapKit
import UIKit
import Combine

class PokemonPreviewCell: UICollectionViewCell, ReuseIdentifiable {
    let image = UIImageView()
    private let name = PokemonCellTitleLabel()
    private let summary = TextLabel(style: .secondary)
    private var imageSubscription: AnyCancellable?

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setConstraints()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        name.text = ""
        summary.text = ""
        image.image = nil
        imageSubscription?.cancel()
    }

    func setPokemon(_ pokemon: PokemonLight, imagePublisher: AnyPublisher<UIImage, Never>) {
        name.text = pokemon.name.capitalized
        summary.text = pokemon.abilities.joined(separator: ", ")
        imageSubscription = imagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pokemonImage in self?.image.image = pokemonImage }
    }

    private func configure() {
        backgroundColor = .systemBackground
        image.contentMode = .scaleAspectFit
        summary.numberOfLines = 0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
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
            make.trailing.equalTo(image.snp.leading).offset(-5)
            make.top.equalTo(name.snp.bottom).offset(6)
            make.bottom.equalToSuperview().offset(-6)
        }
    }
}
