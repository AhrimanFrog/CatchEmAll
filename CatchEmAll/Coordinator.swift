import UIKit
import CoreData

class Coordinator {
    let navigationController: UINavigationController

    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CatchEmAll")
        container.loadPersistentStores { _, error in
            if let nsError = error as NSError? { fatalError("Unresolved error \(nsError), \(nsError.userInfo)") }
        }
        return container
    }()

    init() {
        let viewModel = KnowThemAllViewModel(
            dataProvider: DataService(
                apiProvider: APIService(),
                dbProvider: DatabaseService(dbContext: Coordinator.persistentContainer.viewContext)
            )
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
