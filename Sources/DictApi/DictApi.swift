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
        case .youdao: return await getYouDaoData(for: word, from: from, to: to)
        }
    }
    
    private func getCollinsData(for word: String, from: Language, to: Language) async -> DictDataModel? {
        guard !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        
        switch (from, to) {
        case (.en, .cn): return await getCollinsDataFromEnToCn(word)
        default: return nil
        }
    }
    
    private func getYouDaoData(for word: String, from: Language, to: Language) async -> DictDataModel? {
        guard !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        
        switch (from, to) {
        case (.en, .cn): return await getYouDaoDataFromEnToCn(word)
        default: return nil
        }
    }
    
    private func getYouDaoDataFromEnToCn(_ word: String) async -> DictDataModel? {
        let word = word.replacingOccurrences(of: " ", with: "%20")
        
        guard let url = URL(string: "http://dict.youdao.com/w/\(word)/#keyfrom=dict2.top") else {
            return nil
        }
        
        do {
            let (data, _): (Data, URLResponse) = try await URLSession.shared.data(from: url)
            
            guard let html = String(data: data, encoding: .utf8) else { return nil }

            let doc: Document = try SwiftSoup.parse(html)
            
            let contentElement = try doc.body()?
                .getElementById("doc")?
                .getElementById("scontainer")?
                .getElementById("container")?
                .getElementById("results-contents")
            
            guard let _word = try contentElement?
                    .getElementById("phrsListTab")?
                    .getElementsByClass("wordbook-js")
                    .first()?
                    .getElementsByClass("keyword")
                    .first()?
                    .text() else { return nil }
            
            let enSound = "http://dict.youdao.com/dictvoice?type=1&audio=\(word)"
            let usSound = "http://dict.youdao.com/dictvoice?type=2&audio=\(word)"
            
            guard let enPt = try contentElement?
                    .getElementById("phrsListTab")?
                    .getElementsByClass("wordbook-js")
                    .first()?
                    .getElementsByClass("pronounce")
                    .first()?
                    .getElementsByClass("phonetic")
                    .first()?
                    .text() else { return nil }
            
            guard let usPt = try contentElement?
                    .getElementById("phrsListTab")?
                    .getElementsByClass("wordbook-js")
                    .first()?
                    .getElementsByClass("pronounce")
                    .last()?
                    .getElementsByClass("phonetic")
                    .first()?
                    .text() else { return nil }
            
            let pt = "UK: \(enPt)\nUS: \(usPt)"
            
            guard let explainConten = try contentElement?
                    .getElementById("phrsListTab")?
                    .getElementsByClass("trans-container")
                    .first()?
                    .getElementsByTag("ul")
                    .first() else { return nil }
            
            var explain = [String]()
            
            for li in explainConten.children().array() {
                if li.tagName() == "li" {
                    explain.append(try li.text())
                }
            }
            
            let addition = try contentElement?
                .getElementById("phrsListTab")?
                .getElementsByClass("trans-container")
                .first()?.getElementsByClass("additional").map({ node in
                    try node.text()
                })
            
            let phrase = try contentElement?
                .getElementById("webTrans")?
                .getElementById("tWebTrans")?
                .getElementById("webPhrase")?
                .children()
                .array()
                .filter { node in
                    if node.tagName() == "p" && node.hasClass("wordGroup") {
                        return true
                    } else {
                        return false
                    }
                }
                .map {
                    try $0.text()
                }
            
            var model = DictDataModel(sound: nil, word: _word, pt: pt, paraphrase: [])
            model.enSound = enSound
            model.usSound = usSound
            model.explain = explain
            model.addtion = addition
            model.phrase = phrase
            
            return model
            
        } catch {
            SentrySDK.capture(error: error)
        }
        
        return nil
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
            
            let _word_node = try contentElement?
                .getElementsByClass("cB-h")
                .first()?
                .select("h2")
                .first()
            
            for child in _word_node?.children().array() ?? [] {
                if child.hasClass("homnum") {
                    try _word_node?.removeChild(child)
                }
            }
            
            guard let _word = try _word_node?
                    .text() else { return nil }
            
            if let soundUrlString = try contentElement?
                .getElementsByClass("cB-h")
                .first()?
                .getElementsByClass("pron")
                .first()?
                .select("a")
                .first()?
                .attr("data-src-mp3") {
                sound_url = URL(string: soundUrlString)
            } else {
                sound_url = nil
            }
            
            var pt: String = ""
            
            if let res = try contentElement?
                   .getElementsByClass("cB-h")
                   .first()?
                   .getElementsByClass("pron")
                   .first()?
                   .text() { pt = res }
            
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
                        var childList = [Node]()
                        
                        for child in li.children().array() {
                            if child.hasClass("p phrase") {
                                example.append(try child.text())
                                childList.append(child)
                            }
                        }
                        
                        for child in childList {
                            try li.removeChild(child)
                        }
                        
                        text = try li.text()
                    }
                    
                    if !text.isEmpty {
                        explains.append(text)
                    }
                    
                    examples.append(example)
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

public enum DictType: String, CaseIterable {
    case collins = "Collins"
    case youdao = "YouDao"
    
    public func fromLanguage() -> [Language] {
        switch self {
        case .collins: return [.en]
        case .youdao: return[.en]
        }
    }
    
    public func toLanguage(from: Language) -> [Language] {
        switch self {
        case .collins:
            switch from {
            case .cn:
                return []
            case .en:
                return [.cn]
            }
        case .youdao:
            switch from {
            case .cn:
                return []
            case .en:
                return [.cn]
            }
        }
    }
    
    public var bilingual: Bool {
        switch self {
        case .collins:
            return false
        case .youdao:
            return true
        }
    }
}

public enum Language: String {
    case cn = "Chinese"
    case en = "English"
    
    public var keyboardLanguage: String {
        switch self {
        case .cn:
            return "cn"
        case .en:
            return "en"
        }
    }
}
