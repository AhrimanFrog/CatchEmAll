import Combine

class PaginationService {
    let limit: UInt
    var requestMorePubl: AnyPublisher<(offset: UInt, limit: UInt), Never> { requestMoreSubj.eraseToAnyPublisher() }

    private let requestMoreSubj = PassthroughSubject<(offset: UInt, limit: UInt), Never>()
    private var isProcessingAvailable: () -> Bool
    private var getItemsCount: () -> UInt

    init(
        limit: UInt = 36,
        isProcessingAvailable: @escaping () -> Bool,
        getItemsCount: @escaping () -> UInt
    ) {
        self.limit = limit
        self.isProcessingAvailable = isProcessingAvailable
        self.getItemsCount = getItemsCount
    }

    func requestMoreIfNeeded(for index: UInt) {
        let itemsCount = getItemsCount()
        let threeQuartersOfRequest = itemsCount / 4 * 3
        if index >= threeQuartersOfRequest && isProcessingAvailable() {
            requestMoreSubj.send((itemsCount, limit))
        }
    }
}
