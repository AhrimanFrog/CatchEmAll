struct APIEvolutionChainResponse: Decodable {
    let chain: APIEvolutionChain
}

struct APIEvolutionChain: Decodable {
    let evolvesTo: [APIEvolutionChain]
    let species: LightResource
}

enum EvoltionDecoder {
    static func decodeEvolution(fromChain chain: APIEvolutionChain) -> [UInt] {
        var evolutions: [UInt] = []
        var currentChain: APIEvolutionChain? = chain

        while let chain = currentChain {
            evolutions.append(chain.species.id)
            currentChain = chain.evolvesTo.first
        }
        return evolutions
    }
}
