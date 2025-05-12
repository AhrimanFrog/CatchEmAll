import Foundation

extension Data {
    func decodeToStrings() -> [String]? {
        return try? JSONDecoder().decode([String].self, from: self)
    }
}
