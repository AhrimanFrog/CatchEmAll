import UIKit
import SnapKit

class KnowThemAll: UIViewController {
    private let backgroundLightningView = UIImageView(image: .lightning)
    private let collection: AllPokemonsCollection
    private let collectionDataProvider: CollectionItemsProvider

    init(viewModel: CollectionItemsProvider) {
        let publisher = viewModel.getPokemonForCollection()
            .replaceError(with: []) // TODO: add error handling
            .eraseToAnyPublisher()
        collection = .init(dataPublisher: publisher)
        collectionDataProvider = viewModel
        super.init(nibName: nil, bundle: nil)
        configure()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Know Them All"
    }

    private func setConstraints() {
        view.addSubviews(backgroundLightningView, collection)

        backgroundLightningView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(114)
            make.height.lessThanOrEqualTo(617)
        }

        collection.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalToSuperview().offset(180)
        }
    }
}
