struct APIEvolutionChainResponse: Decodable {
    let chain: APIEvolutionChain
}

struct APIEvolutionChain: Decodable {
    let evolvesTo: [APIEvolutionChain]
    let species: LightResource
}

enum EvoltionDecoder {
    static func decodeEvolution(fromChain chain: APIEvolutionChain) -> [LightResource] {
        var evolutions: [LightResource] = []
        var currentChain: APIEvolutionChain? = chain

        while let chain = currentChain {
            let pokemonID = chain.species.url.lastPathComponent
            let strippedURL = chain.species.url.deletingLastPathComponent().deletingLastPathComponent()
            let newURL = strippedURL.appending(path: "pokemon/\(pokemonID)")
            evolutions.append(LightResource(name: chain.species.name, url: newURL))
            currentChain = chain.evolvesTo.first
        }
        return evolutions
    }
}
