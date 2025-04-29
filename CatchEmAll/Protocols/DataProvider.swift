import Combine

protocol DataProvider {
    func getPokemons(offset: Int) -> AnyPublisher<[Pokemon], Error>
}
