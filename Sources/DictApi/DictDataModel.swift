//
//  DictDataModel.swift
//  DictDataModel
//
//  DictDataModel by 朱浩宇 on 2021/8/27.
//

import Foundation

protocol WriteAndReadAble {
    var hashTable: [String : String] { get set }
    
    mutating func set(_ name: String, with value: String)
    func `get`(_ name: String) -> String?
}

extension WriteAndReadAble {
    public mutating func set(_ name: String, with value: String) {
        hashTable[name] = value
    }
    
    public func `get`(_ name: String) -> String? {
        return hashTable[name]
    }
}

public struct DictDataModel: Identifiable, WriteAndReadAble {
    var hashTable: [String : String] = [:]
    
    public let id = UUID()
    public let word: String
    public let paraphrase: [Paraphrase]
}

public struct Paraphrase: WriteAndReadAble {
    var hashTable: [String : String] = [:]
    
    public let sound: URL
    public let ps: String // 词性
    public let explain: [String]
    public let exampleSentence: [[String]]
}
