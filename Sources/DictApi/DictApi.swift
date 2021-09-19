import Sentry
import SwiftSoup
import Foundation

@available(iOS 15.0.0, *)
@available(macOS 12.0.0, *)
@available(watchOS 8.0.0, *)
@available(tvOS 15.0.0, *)
public struct DictApi {
    public static let shared = DictApi()
    
    public func getData(with type: DictType, for word: String, from: Language, to: Language) async -> DictDataModel? {
        switch type {
        case .collins: return await getCollinsData(for: word, from: from, to: to)
        }
    }
    
    private func getCollinsData(for word: String, from: Language, to: Language) async -> DictDataModel? {
        switch (from, to) {
        case (.en, .cn): return await getCollinsDataFromEnToCn(word)
        default: return nil
        }
    }
    
    private func getCollinsDataFromEnToCn(_ word: String) async -> DictDataModel? {
        let word = word.replacingOccurrences(of: " ", with: "-")
        
        guard let url = URL(string: "https://www.collinsdictionary.com/dictionary/english-chinese/\(word.lowercased())") else {
            return nil
        }
        
        let sound_url: URL?
        
        do {
            let (data, _): (Data, URLResponse) = try await URLSession.shared.data(from: url)
            
            guard let html = String(data: data, encoding: .utf8) else { return nil }

            let doc: Document = try SwiftSoup.parse(html)
            
            let contentElement = try doc.body()?
                .getElementsByTag("main")
                .first()?
                .getElementById("main_content")?
                .getElementsByClass("res_cell_center")
                .first()?
                .getElementsByClass("dc res_cell_center_content")
                .first()?
                .getElementsByClass("he")
                .first()?
                .getElementsByClass("cB cB-t")
                .first()
            
            guard let _word = try contentElement?
                    .getElementsByClass("cB-h")
                    .first()?
                    .select("h2")
                    .first()?
                    .text() else { return nil }
            
            if let soundUrlString = try contentElement?
                    .getElementsByClass("cB-h")
                    .first()?
                    .getAllElements()
                    .get(2)
                    .select("a")
                .attr("data-src-mp3") {
                sound_url = URL(string: soundUrlString)
            } else {
                sound_url = nil
            }
            
            guard var pt = try contentElement?
                    .getElementsByClass("cB-h")
                    .first()?
                    .getAllElements()
                    .get(2)
                    .text() else { return nil }
            
            removeParentheses(&pt)
            
            guard let allExplain = try contentElement?
                    .getElementsByClass("hom").array() else { return nil }
            
            var psArray = [String]()
            var explainArray = [[String]]()
            var exampleSentencesArray = [[[String]]]()
            
            for ele in allExplain {
                guard let text = try ele.getElementsByClass("gramGrp h3_entry").first()?.text() else { return nil }
                psArray.append(text.uppercased())
                
                var explains = [String]()
                var examples = [[String]]()
                
                for li in try ele.getElementsByTag("ol").first()?.getElementsByTag("li").array() ?? [] {
                    var text = ""
                    var example = [String]()
                    if li.hasClass("level_1") {
                        for child in li.children().array() {
                            if !child.hasClass("p phrase") {
                                text += try child.text()
                            } else {
                                example.append(try child.text())
                            }
                        }
                    }
                    
                    if !text.isEmpty {
                        explains.append(text)
                        examples.append(example)
                    }
                }
                
                explainArray.append(explains)
                exampleSentencesArray.append(examples)
            }
            
            var paraphrase = [Paraphrase]()
            
            for (ps, (explains, examples)) in zip(psArray, zip(explainArray, exampleSentencesArray)) {
                paraphrase.append(Paraphrase(ps: ps, explain: explains, exampleSentence: examples))
            }
            
            return DictDataModel(sound: sound_url, word: _word, pt: pt, paraphrase: paraphrase)
        } catch {
            SentrySDK.capture(error: error)
            return nil
        }
    }
    
    private func removeParentheses(_ text: inout String) {
        while let index = text.firstIndex(where: { $0 == "(" || $0 == ")" }) {
            text.remove(at: index)
        }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public enum DictType: String {
    case collins
    
    public func fromLanguage() -> [Language] {
        switch self {
        case .collins: return [.en]
        }
    }
    
    public func toLanguage() -> [Language] {
        switch self {
        case .collins: return [.cn]
        }
    }
    
    public var bilingual: Bool {
        switch self {
        case .collins:
            return false
        }
    }
}

public enum Language: String {
    case cn = "Chinese"
    case en = "English"
}
