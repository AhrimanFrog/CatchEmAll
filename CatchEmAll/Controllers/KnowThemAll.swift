import UIKit
import Combine
import SnapKit

class KnowThemAll: UIViewController {
    private let backgroundLightningView = UIImageView(image: .lightning)
    private let collection: AllPokemonsCollection<KnowThemAllViewModel>

    init(itemProvider: KnowThemAllViewModel) {
        collection = .init(itemProvider: itemProvider)
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
        navigationItem.backButtonTitle = ""
    }

    private func setConstraints() {
        view.addSubviews(backgroundLightningView, collection)

        collection.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }

        backgroundLightningView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(114)
            make.bottom.lessThanOrEqualTo(collection).offset(16)
        }
    }
}
