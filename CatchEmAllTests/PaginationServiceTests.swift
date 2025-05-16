import XCTest
import Combine
@testable import CatchEmAll

final class PaginationServiceTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testRequestMoreIfNeeded_DoesNotTrigger_WhenIndexBelowThreshold() {
        let expectation = self.expectation(description: "Should not emit")
        expectation.isInverted = true

        let pagination = PaginationService(
            limit: 10,
            isProcessingAvailable: { true },
            getItemsCount: { 100 }
        )

        pagination.requestMorePubl
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        pagination.requestMoreIfNeeded(for: 50) // < 75

        wait(for: [expectation], timeout: 0.5)
    }

    func testRequestMoreIfNeeded_DoesNotTrigger_WhenProcessingUnavailable() {
        let expectation = self.expectation(description: "Should not emit")
        expectation.isInverted = true

        let pagination = PaginationService(
            limit: 20,
            isProcessingAvailable: { false },
            getItemsCount: { 80 }
        )

        pagination.requestMorePubl
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        pagination.requestMoreIfNeeded(for: 60) // >= 75% but unavailable

        wait(for: [expectation], timeout: 0.5)
    }

    func testRequestMoreIfNeeded_Triggers_WhenThresholdReachedAndAvailable() {
        let expectation = self.expectation(description: "Should emit")

        let pagination = PaginationService(
            limit: 15,
            isProcessingAvailable: { true },
            getItemsCount: { 40 }
        )

        pagination.requestMorePubl
            .sink { result in
                XCTAssertEqual(result.offset, 40)
                XCTAssertEqual(result.limit, 15)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        pagination.requestMoreIfNeeded(for: 30) // exactly 75%

        wait(for: [expectation], timeout: 1.0)
    }
}
