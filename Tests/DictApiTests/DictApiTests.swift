import XCTest
@testable import DictApi

@available(macOS 12.0.0, *)
final class DictApiTests: XCTestCase {
    func testGetHtmlFromCollinsFromEnToCn() async throws {
        let res = await DictApi.shared.getData(with: .collins, for: "test", from: .en, to: .cn)
        print(res ?? "")
    }
    
    func testGetHtmlFromYoudaoFromEnToCn() async throws {
        let res = await DictApi.shared.getData(with: .youdao, for: "swift", from: .en, to: .cn)
        print(res ?? "")
    }
}
