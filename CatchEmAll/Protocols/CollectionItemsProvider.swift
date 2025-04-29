import Combine

protocol CollectionItemsProvider {
    func getPokemonForCollection() -> AnyPublisher<[PokemonLight], Error>
}
