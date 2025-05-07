class PaginationService {
    struct Pagination {
        var offset: UInt = 0
        let limit: UInt = 36

        var next: Pagination { .init(offset: offset + limit) }
    }

    private var current: Pagination = .init()

    func shouldRequestMore(for index: UInt) -> Bool {
        let threeQuartersOfRequest = current.offset + current.limit / 4 * 3
        return index >= threeQuartersOfRequest
    }

    func moveForward(withCall callback: (Pagination) -> Void) {
        callback(current)
        current = current.next
    }
}
