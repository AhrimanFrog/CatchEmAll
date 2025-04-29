import UIKit

struct Pokemon {
    let id: UInt
    let name: String
    let image: UIImage?
    let height: UInt
    let weight: UInt
    let powers: [String]
    let attack: UInt
    let damage: UInt

    func light() -> PokemonLight {
        return .init(name: name, powers: powers)
    }
}
