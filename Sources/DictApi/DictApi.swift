import Sentry
import SwiftSoup
import Foundation

@available(iOS 15.0.0, *)
@available(macOS 12.0.0, *)
@available(watchOS 8.0.0, *)
@available(tvOS 15.0.0, *)
public struct DictApi {
    public static let shared = DictApi()
    
    public func getCollinsData(with word: String, from: Language, to: Language) async -> CollinsData? {
        switch (from, to) {
        case (.en, .cn): return await getCollinsDataFromEnToCn(word)
        default: return nil
        }
    }
    
    private func getCollinsDataFromEnToCn(_ word: String) async -> CollinsData? {
        guard let url = URL(string: "https://www.collinsdictionary.com/dictionary/english-chinese/\(word.lowercased())") else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
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
            
            guard let soundUrlString = try contentElement?
                    .getElementsByClass("cB-h")
                    .first()?
                    .getAllElements()
                    .get(2)
                    .select("a")
                    .attr("data-src-mp3"),
                let sound_url = URL(string: soundUrlString) else { return nil }
            
            guard let allExplain = try contentElement?
                    .getElementsByClass("hom").array() else { return nil }
            
            var psArray = [String]()
            
            for ele in allExplain {
                guard let text = try ele.getElementsByClass("gramGrp h3_entry").first()?.text() else { return nil }
                psArray.append(text.uppercased())
            }
            
            print(psArray)
            
            return nil
        } catch {
            SentrySDK.capture(error: error)
            return nil
        }
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
}

public enum Language: String {
    case cn = "Chinese"
    case en = "English"
}
