import CoreData

struct APIPokemon: Decodable {
    let id: UInt
    let name: String
    let height: UInt
    let weight: UInt

    let abilities: [APIAbility]
    let moves: [APIMove]
    let stats: [APIStat]
}
