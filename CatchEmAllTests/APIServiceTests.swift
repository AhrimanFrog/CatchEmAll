import XCTest
import Combine
@testable import CatchEmAll

class APIServiceTests: XCTestCase {
    var service: APIService!
    var cancellables = Set<AnyCancellable>()
    let dummyData = """
    {
        "id": 1,
        "name": "bulbasaur",
        "height": 7,
        "weight": 69,
        "abilities": [],
        "moves": [],
        "stats": []
    }
    """.data(using: .utf8)!

    override func setUp() {
        super.setUp()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]

        service = APIService(session: URLSession(configuration: config))
    }

    override func tearDown() {
        service = nil
        cancellables.removeAll()
        URLProtocolStub.testData = nil
        URLProtocolStub.response = nil
        URLProtocolStub.error = nil
        super.tearDown()
    }

    func testFetchPokemonByIDSuccess() {
        let expectation = self.expectation(description: "fetchPokemonByID")
        URLProtocolStub.testData = dummyData
        URLProtocolStub.response = HTTPURLResponse(
            url: URL(string: "https://pokeapi.co")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        service.fetchPokemon(byID: 1)
            .sink { result in
                switch result {
                case .failure(let error):
                    XCTFail("Unexpected failure: \(error)")
                case .success(let pokemon):
                    XCTAssertEqual(pokemon.name, "bulbasaur")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchPokemonByIDInvalidStatusCode() {
        let expectation = self.expectation(description: "invalid status code")
        URLProtocolStub.testData = Data()
        URLProtocolStub.response = HTTPURLResponse(
            url: URL(string: "https://pokeapi.co")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )

        service.fetchPokemon(byID: 1)
            .sink { result in
                switch result {
                case .success:
                    XCTFail("Expected failure, got success")
                case .failure(let error):
                    XCTAssertEqual(error, .wrongStatusCode(404))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchPokemonImageReturnsDataEvenOnFailure() {
        let expectation = self.expectation(description: "fetchPokemonImage")

        URLProtocolStub.error = URLError(.notConnectedToInternet)

        service.fetchPokemonImage(byID: 1)
            .sink{ data in
                XCTAssertEqual(data, Data())
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }
}


class URLProtocolStub: URLProtocol {
    static var testData: Data?
    static var response: HTTPURLResponse?
    static var error: Error?

    override static func canInit(with request: URLRequest) -> Bool { true }
    override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let error = Self.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = Self.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = Self.testData {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
