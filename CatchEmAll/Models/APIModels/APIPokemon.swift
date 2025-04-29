import CoreData

struct APIPokemon: Decodable {
    let id: Int
    let name: String
    let height: UInt
    let weight: UInt

    let abilities: [APIAbility]
    let moves: [APIMove]
    let stats: [APIStat]
    let species: LightResource
}

extension APIPokemon: Persistable {
    func persist(inObject pokemon: DBPokemon) {
        pokemon.id = Int64(id)
        pokemon.name = name
        pokemon.height = Int16(height)
        pokemon.weight = Int16(weight)        
    }
}
