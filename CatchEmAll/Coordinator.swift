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
        let viewModel = KnowThemAllViewModel(dataProvider: dataService)
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
            let viewModel = PokemonDetailViewModel(dataService: dataService, pokemonID: pokemonID)
            navigationController.pushViewController(
                PokemonDetail(viewModel: viewModel, pokemonImage: image),
                animated: true
            )
        }
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
