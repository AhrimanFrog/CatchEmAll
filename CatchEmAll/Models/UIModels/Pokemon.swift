struct Pokemon {
    let id: UInt
    let name: String
    let height: UInt
    let weight: UInt
    let abilities: [String]
    let moves: [String]
    let stats: [Stat]
    var evolutions: [PokemonLight]?

    var attack: UInt { stats.first { $0.name == "attack" }?.value ?? 0 }
    var damage: UInt { stats.first { $0.name == "defense" }?.value ?? 0 }

    func light() -> PokemonLight {
        return .init(id: id, name: name, abilities: abilities)
    }

    static func fromDBData(_ dbPokemon: DBPokemon) -> Pokemon {
        return .init(
            id: UInt(dbPokemon.id),
            name: dbPokemon.name ?? "Unknown",
            height: UInt(dbPokemon.height),
            weight: UInt(dbPokemon.weight),
            abilities: dbPokemon.abilities?.decodeTo(type: [String].self) ?? [],
            moves: dbPokemon.moves?.decodeTo(type: [String].self) ?? [],
            stats: dbPokemon.stats?.compactMap {
                guard let dbStat = ($0 as? DBStat) else { return nil }
                return Stat(value: UInt(dbStat.value), name: dbStat.name ?? "Unknown")
            } ?? [],
            evolutions: nil
        )
    }

    static func fromAPIData(_ apiPokemon: APIPokemon) -> Pokemon {
        return .init(
            id: apiPokemon.id,
            name: apiPokemon.name,
            height: apiPokemon.height,
            weight: apiPokemon.weight,
            abilities: apiPokemon.abilities.map { $0.ability.name },
            moves: apiPokemon.moves.map { $0.move.name },
            stats: apiPokemon.stats.map { .init(value: $0.baseStat, name: $0.stat.name) },
            evolutions: nil
        )
    }
}
