#if canImport(Sentry)
import Sentry
#endif
import SwiftSoup
import SwiftyJSON
import Foundation

@available(iOS 15.0.0, *)
@available(macOS 12.0.0, *)
@available(watchOS 8.0.0, *)
@available(tvOS 15.0.0, *)
public struct DictApi {
    // MARK: - API
    public static let shared = DictApi()
    
    public func getData(with type: DictType, for word: String, from: Language, to: Language, api: String? = nil) async -> DictDataModel? {
        switch type {
        case .collins: return await getCollinsData(for: word, from: from, to: to)
        case .youdao: return await getYouDaoData(for: word, from: from, to: to)
        case .wordsapi: return await getWordsApiData(for: word, from: from, to: to, api: api)
        case .local: return nil
        }
    }
    
    // MARK: - Distribution
    private func getWordsApiData(for word: String, from: Language, to: Language, api: String? = nil) async -> DictDataModel? {
        guard !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        guard let api = api else { return nil }

        
        switch (from, to) {
        case (.en, .en): return await geWordsApiDataFromEnToEn(word, api: api)
        default: return nil
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
        
        if from == Language.identify(word) {
            switch (from, to) {
            case (.en, .cn): return await getYouDaoDataFromEnToCn(word)
            default: return nil
            }
        } else {
            switch (from, to) {
            case (.en, .cn): return await getYouDaoDataFromEnToCnReverse(word)
            default: return nil
            }
        }
    }
    
    // MARK: - Accomplish
    private func geWordsApiDataFromEnToEn(_ word: String, api: String) async -> DictDataModel? {
        guard let word = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        
        let headers = [
            "x-rapidapi-host": "wordsapiv1.p.rapidapi.com",
            "x-rapidapi-key": api
        ]
        
        guard let url = URL(string: "https://wordsapiv1.p.rapidapi.com/words/\(word)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        do {
            let (data, _): (Data, URLResponse) = try await URLSession.shared.data(for: request)
            
            let json = try JSON(data: data)
            
            var pt = ""
            
            guard let _word = json["word"].string else { return nil }
            
            guard let ptDict = json["pronunciation"].dictionary else { return nil }
            
            for (key, value): (String, JSON) in ptDict {
                pt += "\(key):[\(value.string ?? "")] "
            }
            pt = pt.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let results = json["results"].array else { return nil }
            
            var paraphrase = [Paraphrase]()
            
            for result in results {
                let ps = result["partOfSpeech"].string ?? "other"
                guard let definition = result["definition"].string else { return nil }
                
                var p = Paraphrase(ps: ps, explain: [], exampleSentence: [])
                p.definition = definition
                
                if let res = result["synonyms"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.synonyms = res
                }
                
                if let res = result["antonyms"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.antonyms = res
                }
                
                if let res = result["examples"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.examples = res
                }
                
                if let res = result["typeOf"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.typeOf = res
                }
                
                if let res = result["hasTypes"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.hasTypes = res
                }
                
                if let res = result["partOf"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.partOf = res
                }
                
                if let res = result["hasParts"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.hasParts = res
                }
                
                if let res = result["instanceOf"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.instanceOf = res
                }
                
                if let res = result["hasInstances"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.hasInstances = res
                }
                
                if let res = result["similarTo"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.similarTo = res
                }
                
                if let res = result["also"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.also = res
                }
                
                if let res = result["entails"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.entails = res
                }
                
                if let res = result["memberOf"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.memberOf = res
                }
                
                if let res = result["hasMembers"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.hasMembers = res
                }
                
                if let res = result["substanceOf"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.substanceOf = res
                }
                
                if let res = result["hasSubstances"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.hasSubstances = res
                }
                
                if let res = result["inCategory"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.inCategory = res
                }
                
                if let res = result["hasCategories"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.hasCategories = res
                }
                
                if let res = result["usageOf"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.usageOf = res
                }
                
                if let res = result["hasUsages"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.hasUsages = res
                }
                
                if let res = result["inRegion"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.inRegion = res
                }
                
                if let res = result["regionOf"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.regionOf = res
                }
                
                if let res = result["pertainsTo"].array?.map({ json in
                    json.string ?? ""
                }).filter({
                    !$0.isEmpty
                }) {
                    p.pertainsTo = res
                }
                
                paraphrase.append(p)
            }
            
            let model = DictDataModel(sound: nil, word: _word, pt: pt, paraphrase: paraphrase)
            
            return model
        } catch {
            SentrySDK.capture(error: error)
        }
        
        return nil
    }
    
    private func getYouDaoDataFromEnToCnReverse(_ word: String) async -> DictDataModel? {
        guard let word = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        
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
            
            let pt: String
            
            if let res = try contentElement?
                .getElementById("phrsListTab")?
                .getElementsByClass("wordbook-js")
                .first()?
                .getElementsByClass("phonetic")
                .first()?
                .text() {
                pt = res
            } else { pt = "" }
            
            let englishWords = try contentElement?
                .getElementById("phrsListTab")?
                .getElementsByClass("trans-container")
                .first()?
                .getElementsByTag("ul")
                .first()?
                .getElementsByClass("wordGroup")
                .first()?
                .getElementsByClass("contentTitle")
                .map {
                    try $0
                        .getElementsByTag("a")
                        .first()?
                        .text() ?? ""
                }
                .filter {
                    $0 != ""
                }
            
            let examples: [[String]] = try contentElement?
                .getElementById("examples")?
                .getElementById("bilingual")?
                .getElementsByTag("ul")
                .first()?
                .getElementsByTag("li")
                .map {
                    [
                        try $0.getElementsByTag("p").get(0).text(),
                        try $0.getElementsByTag("p").get(1).text(),
                        "http://dict.youdao.com/dictvoice?type=1&audio=\(try $0.getElementsByTag("p").get(1).getElementsByTag("a").first()?.attr("data-rel") ?? "")",
                        "http://dict.youdao.com/dictvoice?type=2&audio=\(try $0.getElementsByTag("p").get(1).getElementsByTag("a").first()?.attr("data-rel") ?? "")"
                    ]
                } ?? []
            
            var model = DictDataModel(sound: nil, word: _word, pt: pt, paraphrase: [])
            model.reverse = true
            model.englishWords = englishWords
            model.examples = examples
            
            return model
        } catch {
            SentrySDK.capture(error: error)
        }
        
        return nil
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
            
            let enPt:String
            let usPt:String
            let pt: String
            
            if let res = try contentElement?
                .getElementById("phrsListTab")?
                .getElementsByClass("wordbook-js")
                .first()?
                .getElementsByClass("pronounce")
                .first()?
                .getElementsByClass("phonetic")
                .first()?
                .text() { enPt = res } else { enPt = "" }
            
            if let res = try contentElement?
                .getElementById("phrsListTab")?
                .getElementsByClass("wordbook-js")
                .first()?
                .getElementsByClass("pronounce")
                .last()?
                .getElementsByClass("phonetic")
                .first()?
                .text() { usPt = res } else { usPt = "" }
            
            if enPt.isEmpty && usPt.isEmpty {
                pt = ""
            } else {
                pt = "UK: \(enPt) US: \(usPt)"
            }
            
            guard let explainConten = try contentElement?
                    .getElementById("phrsListTab")?
                    .getElementsByClass("trans-container")
                    .first()?
                    .getElementsByTag("ul")
                    .first() else { return nil }
            
            var explain: [String] = [String]()
            
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
            
            let wordGroup = try contentElement?
                .getElementById("eTransform")?
                .getElementById("transformToggle")?
                .getElementById("wordGroup")?
                .getElementsByTag("p")
                .array().map {
                    try $0.text()
                }
            
            var synonyms = [String : [String]]()
            var last = ""
            
            for node in try contentElement?
                    .getElementById("eTransform")?
                    .getElementById("transformToggle")?
                    .getElementById("synonyms")?
                    .getElementsByTag("ul")
                    .first()?.children().array() ?? [] {
                if node.tagName() == "li" {
                    synonyms[try node.text()] = []
                    last = try node.text()
                } else if try node.tagName() == "p" &&  node.className() == "wordGroup" {
                    synonyms[last] = try node.children().map {
                        try $0.getElementsByTag("a").first()?.text() ?? ""
                    }
                }
            }
            
            let sameRootWord = try contentElement?
                .getElementById("eTransform")?
                .getElementById("transformToggle")?
                .getElementById("relWordTab")?
                .children().map {
                    try $0.text()
                }
            
            let discrimination = try contentElement?
                .getElementById("eTransform")?
                .getElementById("transformToggle")?
                .getElementById("discriminate")?
                .getElementsByClass("wt-container")
                .first()?
                .getElementsByClass("collapse-content")
                .first()?
                .getElementsByClass("wordGroup")
                .map {
                    try $0.text()
                }
            
            let example: [[String]]  = try contentElement?
                .getElementById("examples")?
                .getElementById("examplesToggle")?
                .getElementById("bilingual")?
                .getElementsByTag("ul")
                .first()?
                .getElementsByTag("li")
                .map { node in
                    [
                        try node.getElementsByTag("p").get(0).text(),
                        try node.getElementsByTag("p").get(1).text(),
                        "http://dict.youdao.com/dictvoice?type=1&audio=\(try node.getElementsByTag("p").get(0).getElementsByTag("a").first()?.attr("data-rel") ?? "")",
                        "http://dict.youdao.com/dictvoice?type=2&audio=\(try node.getElementsByTag("p").get(0).getElementsByTag("a").first()?.attr("data-rel") ?? "")"
                    ]
                } ?? []
            
            
            var model = DictDataModel(sound: nil, word: _word, pt: pt, paraphrase: [])
            model.reverse = false
            model.enSound = enSound
            model.usSound = usSound
            model.explain = explain
            model.addtion = addition
            model.phrase = phrase
            model.wordGroup = wordGroup
            model.synonyms = synonyms
            model.sameRootWord = sameRootWord
            model.discrimination = discrimination
            model.example = example
            
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
            #if canImport(Sentry)
            SentrySDK.capture(error: error)
            #endif
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
    case wordsapi = "WordsApi"
    case local = "Local"
    
    public func fromLanguage() -> [Language] {
        switch self {
        case .collins: return [.en]
        case .youdao: return [.en]
        case .wordsapi: return [.en]
        case .local: return []
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
        case .wordsapi:
            switch from {
            case .cn:
                return []
            case .en:
                return [.en]
            }
        case .local: return []
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
    
    public static func identify(_ word: String) -> Language {
        if isIncludeChineseIn(string: word) {
            return .cn
        }
        return .en
    }
    
    private static func isIncludeChineseIn(string: String) -> Bool {
        
        for (_, value) in string.enumerated() {

            if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                return true
            }
        }
        
        return false
    }
}
