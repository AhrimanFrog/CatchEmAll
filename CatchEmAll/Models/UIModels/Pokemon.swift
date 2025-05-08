struct Pokemon {
    let id: UInt
    let name: String
    let height: UInt
    let weight: UInt
    let powers: [String]
    let attack: UInt
    let damage: UInt

    func light() -> PokemonLight {
        return .init(id: id, name: name, powers: powers)
    }

    static func fromDBData(_ dbPokemon: DBPokemon) -> Pokemon {
        return .init(
            id: UInt(dbPokemon.id),
            name: dbPokemon.name ?? "Unknown",
            height: UInt(dbPokemon.height),
            weight: UInt(dbPokemon.weight),
            powers: dbPokemon.abilities?.allObjects.compactMap { ($0 as? DBAbility)?.name } ?? [],
            attack: UInt(dbPokemon.attack),
            damage: UInt(dbPokemon.damage)
        )
    }

    static func fromAPIData(_ apiPokemon: APIPokemon) -> Pokemon {
        return .init(
            id: apiPokemon.id,
            name: apiPokemon.name,
            height: apiPokemon.height,
            weight: apiPokemon.weight,
            powers: apiPokemon.abilities.map { $0.ability.name },
            attack: apiPokemon.attack,
            damage: apiPokemon.damage
        )
    }
}
