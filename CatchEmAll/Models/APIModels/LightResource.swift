import Foundation

struct LightResource: Decodable {
    let name: String
    let url: URL

    var id: UInt { UInt(url.lastPathComponent) ?? 0 }
}
