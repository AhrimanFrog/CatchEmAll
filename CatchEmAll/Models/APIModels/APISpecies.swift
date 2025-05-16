struct APISpecies: Decodable {
    struct EvolutionChainURL: Decodable {
        let url: String
    }
    let evolutionChain: EvolutionChainURL
}
