import XCTest
@testable import DictApi

@available(macOS 12.0.0, *)
final class DictApiTests: XCTestCase {
    func testGetHtml() async throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let res = await DictApi.shared.getData(with: .collins, for: "Swift", from: .en, to: .cn)
        print(res ?? "")
    }
}
