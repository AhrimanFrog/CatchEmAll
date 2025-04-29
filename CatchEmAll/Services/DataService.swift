import Combine

class DataService<API: APIProvider, DB: DBProvider>: DataProvider {
    private let apiProvider: API
    private let dbProvider: DB

    init(apiProvider: API, dbProvider: DB) {
        self.apiProvider = apiProvider
        self.dbProvider = dbProvider
    }

    func getPokemons(offset: Int = 0) -> AnyPublisher<[Pokemon], Error> {
        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
