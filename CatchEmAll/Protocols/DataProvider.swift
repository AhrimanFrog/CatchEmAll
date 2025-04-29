import Combine

protocol DataProvider {
    func getPokemons(offset: UInt) -> AnyPublisher<[Pokemon], Error>
}
