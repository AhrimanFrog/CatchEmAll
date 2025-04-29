import Foundation

struct LightResource: Decodable {
    let name: String
    let url: String

    var id: UInt { UInt(NSString(string: url).lastPathComponent) ?? 0 }
}
