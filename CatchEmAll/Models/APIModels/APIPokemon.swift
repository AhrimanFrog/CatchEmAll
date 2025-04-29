import CoreData

struct APIPokemon: Decodable {
    let id: UInt
    let name: String
    let height: UInt
    let weight: UInt

    let abilities: [APIAbility]
    let moves: [APIMove]
    let stats: [APIStat]
    let species: LightResource

    func toUIPokemon() -> Pokemon { // temporary for demo
        return .init(
            id: id,
            name: name,
            image: nil,
            height: height,
            weight: weight,
            powers: abilities.map { $0.ability.name },
            attack: 0,
            damage: 0
        )
    }
}

extension APIPokemon: Persistable {
    func persist(inObject pokemon: DBPokemon) {
        pokemon.id = Int64(id)
        pokemon.name = name
        pokemon.height = Int16(height)
        pokemon.weight = Int16(weight)
    }
}
