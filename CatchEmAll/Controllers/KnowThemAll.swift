import UIKit

class KnowThemAll: UIViewController {
    private let collection: AllPokemonsCollection

    init() {
        collection = .init(frame: .zero, collectionViewLayout: .init())
        super.init()
        configure()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {}

    private func setConstraints() {}
}
