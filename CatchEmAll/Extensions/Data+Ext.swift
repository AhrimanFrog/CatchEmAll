import Foundation

extension Data {
    private static let decoder = JSONDecoder()

    func decodeTo<T: Decodable>(type: T.Type) -> T? {
        return try? Data.decoder.decode(type, from: self)
    }
}
