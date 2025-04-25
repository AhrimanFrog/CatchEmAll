import UIKit

class Coordinator {
    let navigationController = UINavigationController(rootViewController: KnowThemAll())

    init() {
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.titleTextAttributes = [
            .font: UIFont.lato(ofSize: 24, weight: .bold)!
        ]
        navigationController.navigationBar.backItem?.title = ""
        navigationController.navigationBar.backIndicatorImage = .init(systemName: "arrow.left")
        navigationController.navigationBar.tintColor = .label
    }
}
