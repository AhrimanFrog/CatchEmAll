struct LightResource: Decodable {
    let name: String
    let url: String

    var id: UInt { UInt(url.split(separator: "/").last ?? "0") ?? 0 }
}
