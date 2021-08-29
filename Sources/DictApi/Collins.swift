//
//  Collins.swift
//  Collins
//
//  Created by 朱浩宇 on 2021/8/27.
//

import Foundation

public struct CollinsData: Identifiable {
    public let id = UUID()
    public let word: String
    public let paraphrase: [CollinsParaphrase]
}

public struct CollinsParaphrase {
    public let sound: URL
    public let ps: String // 词性
    public let explain: [String]
    public let exampleSentence: [[String]]
}
