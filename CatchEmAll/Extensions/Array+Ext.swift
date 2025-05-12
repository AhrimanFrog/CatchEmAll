import Foundation

extension Array {
    subscript(back i: Int) -> Iterator.Element {
        return self[endIndex.advanced(by: -i)]
    }
}

extension Array where Element == String {
    func encode() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
