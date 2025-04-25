struct APIPokemon: Decodable {
    let id: Int
    let name: String
    let height: UInt8
    let weight: UInt8

    let abilities: [APIAbility]
    let moves: [APIMove]
    let stats: [APIStat]
    let species: LightResource
}
