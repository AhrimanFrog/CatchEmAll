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
}
