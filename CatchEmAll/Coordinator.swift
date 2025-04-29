import UIKit

class Coordinator {
    let navigationController: UINavigationController

    init() {
        let viewModel = KnowThemAllViewModel(
            dataProvider: DataService(apiProvider: APIService(), dbProvider: DatabaseService())
        )
        navigationController = .init(rootViewController: KnowThemAll(viewModel: viewModel))
        configureNavigationController()
    }

    private func configureNavigationController() {
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.titleTextAttributes = [
            .font: UIFont.lato(ofSize: 24, weight: .bold)!
        ]
        navigationController.navigationBar.backItem?.title = ""
        navigationController.navigationBar.backIndicatorImage = .init(systemName: "arrow.left")
        navigationController.navigationBar.tintColor = .label
    }
}
