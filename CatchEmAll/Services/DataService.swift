import Combine

class DataService<API: APIProvider, DB: DBProvider>: DataProvider {
    private let apiProvider: API
    private let dbProvider: DB

    init(apiProvider: API, dbProvider: DB) {
        self.apiProvider = apiProvider
        self.dbProvider = dbProvider
    }

    func getPokemons(offset: UInt = 0) -> AnyPublisher<[Pokemon], Error> {
        return apiProvider.fetchPokemons(offset: offset)
            .map { result in result.map { $0.toUIPokemon() } }
            .mapError { $0 as Error } // idk why APIError != any Error
            .eraseToAnyPublisher()
    }
}
