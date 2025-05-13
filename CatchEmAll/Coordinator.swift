import UIKit
import CoreData

class Coordinator {
    enum Screen {
        case start
        case detail(UIImage, UInt)
    }

    let navigationController = UINavigationController()
    private let dataService: DataService<APIService, DatabaseService>
    private var startingController: UIViewController?

    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CatchEmAll")
        container.loadPersistentStores { _, error in
            if let nsError = error as NSError? { fatalError("Unresolved error \(nsError), \(nsError.userInfo)") }
        }
        return container
    }()

    init() {
        dataService = DataService(
            apiProvider: APIService(),
            dbProvider: DatabaseService(container: persistentContainer)
        )
        configureNavigationController()
    }

    func start() {
        let viewModel = KnowThemAllViewModel(
            dataProvider: dataService,
            navigationDispatcher: newNavigationDispatcher()
        )
        let knowThemAll = KnowThemAll(itemProvider: viewModel)
        navigationController.setViewControllers([knowThemAll], animated: true)
        startingController = knowThemAll
    }

    func navigate(toScreen screen: Screen) {
        switch screen {
        case .start:
            guard let startingController else { return }
            navigationController.popToViewController(startingController, animated: true)
        case let .detail(image, pokemonID):
            let viewModel = PokemonDetailViewModel(
                dataService: dataService,
                pokemonID: pokemonID,
                navigationDispatcher: newNavigationDispatcher()
            )
            navigationController.pushViewController(
                PokemonDetail(viewModel: viewModel, pokemonImage: image),
                animated: true
            )
        }
    }

    func displayError(_ error: any Error) {
        let alert = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }

    private func newNavigationDispatcher() -> NavigationDispatcher {
        return NavigationDispatcher(
            onItemSelect: { [weak self] in self?.navigate(toScreen: .detail($0, $1)) },
            onErrorOccur: { [weak self] in self?.displayError($0) }
        )
    }

    private func configureNavigationController() {
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.titleTextAttributes = [
            .font: UIFont.lato(ofSize: 24, weight: .bold)!
        ]
        navigationController.navigationBar.tintColor = .label
        navigationController.navigationBar.backIndicatorTransitionMaskImage = .init(systemName: "arrow.left")
        navigationController.navigationBar.backIndicatorImage = .init(systemName: "arrow.left")
    }
}
