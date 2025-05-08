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

    var attack: UInt { stats.first { $0.stat.name == "attack" }?.baseStat ?? 0 }
    var damage: UInt { stats.first { $0.stat.name == "special-attack" }?.baseStat ?? 0 }
}
