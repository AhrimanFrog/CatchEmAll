import Foundation

enum DBError: LocalizedError {
    case notFound
    case expired

    var errorDescription: String {
        return switch self {
        case .notFound: "No items found"
        case .expired: "Request has expired. Please try again"
        }
    }

    var localizedDescription: String { errorDescription }
}
