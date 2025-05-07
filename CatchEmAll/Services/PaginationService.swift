class PaginationService {
    private(set) var offset: UInt = 0
    let limit: UInt = 36

    func shouldRequestMore(for index: UInt) -> Bool {
        let threeQuartersOfRequest = offset + limit / 4 * 3
        return index >= threeQuartersOfRequest
    }

    func moveForward(withCall callback: ((offset: UInt, limit: UInt)) -> Void) {
        offset += limit
        callback((offset, limit))
    }
}
