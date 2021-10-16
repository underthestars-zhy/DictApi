import XCTest
@testable import DictApi

@available(macOS 12.0.0, *)
final class DictApiTests: XCTestCase {
    func testGetHtmlFromCollinsFromEnToCn() async throws {
        let res = await DictApi.shared.getData(with: .collins, for: "make up", from: .en, to: .cn)
        print(res?.toJSONString() ?? "")
    }
    
    func testGetHtmlFromYoudaoFromEnToCn() async throws {
        let res = await DictApi.shared.getData(with: .youdao, for: "sugar mummy", from: .en, to: .cn)
        print(res ?? "")
    }
    
    func testGetHtmlFromYoudaoFromEnToCnReverse() async throws {
        let res = await DictApi.shared.getData(with: .youdao, for: "复杂的", from: .en, to: .cn)
        print(res ?? "")
    }
    
    func testGetHtmlFromWordsApiFromEnToEn() async throws {
        let res = await DictApi.shared.getData(with: .wordsapi, for: "example", from: .en, to: .en, api: "")
        print(res ?? "")
    }
    
    func testCn() {
        XCTAssertEqual(Language.identify("你好"), .cn)
        XCTAssertEqual(Language.identify("hello"), .en)
    }
}
