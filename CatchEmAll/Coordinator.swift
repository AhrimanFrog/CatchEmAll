import UIKit
import CoreData

@MainActor
class Coordinator {
    enum Screen {
        case start
        case detail(UInt)
    }

    let navigationController = UINavigationController()
    private let dataService: DataService
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
        case let .detail(pokemonID):
            showPokemonDetail(for: pokemonID)
        }
    }

    func showPokemonDetail(for pokemonID: UInt) {
        if let existingVC = navigationController.viewControllers.first(where: { viewController in
            return pokemonID == ((viewController as? PokemonDetail)?.viewModel.pokemon?.id ?? 0)
        }) {
            navigationController.popToViewController(existingVC, animated: true)
        } else {
            let viewModel = PokemonDetailViewModel(
                dataService: dataService,
                pokemonID: pokemonID,
                navigationDispatcher: newNavigationDispatcher()
            )
            navigationController.pushViewController(PokemonDetail(viewModel: viewModel), animated: true)
        }
    }

    func displayError(_ error: any Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            self.navigationController.present(alert, animated: true)
        }
    }

    private func newNavigationDispatcher() -> NavigationDispatcher {
        return NavigationDispatcher(
            onItemSelect: { [weak self] in self?.navigate(toScreen: .detail($0)) },
            onErrorOccur: { [weak self] in self?.displayError($0) }
        )
    }

    private func configureNavigationController() {
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.titleTextAttributes = [
            .font: UIFont.lato(ofSize: 24, weight: .bold)
        ]
        navigationController.navigationBar.tintColor = .label
        navigationController.navigationBar.backIndicatorTransitionMaskImage = .init(systemName: "arrow.left")
        navigationController.navigationBar.backIndicatorImage = .init(systemName: "arrow.left")
    }
}
