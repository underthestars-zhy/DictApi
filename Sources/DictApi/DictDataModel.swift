//
//  DictDataModel.swift
//  DictDataModel
//
//  DictDataModel by 朱浩宇 on 2021/8/27.
//

import Foundation
import ObjectMapper

@dynamicMemberLookup
public protocol WriteAndReadAble {
    var hashTable: [String : Any] { get set }
    
    mutating func set(_ name: String, with value: Any)
    func `get`(_ name: String) -> Any?
}

extension WriteAndReadAble {
    public mutating func set(_ name: String, with value: Any) {
        hashTable[name] = value
    }
    
    public func `get`(_ name: String) -> Any? {
        return hashTable[name]
    }
    
    public subscript(dynamicMember keyPath: String) -> Any? {
        set {
            hashTable[keyPath] = newValue
        }
        get {
            hashTable[keyPath]
        }
    }
}


public struct DictDataModel: Identifiable, WriteAndReadAble, Mappable {
    public init(sound: URL?, word: String, pt: String, paraphrase: [Paraphrase]) {
        if let sound = sound {
            self._sound = "\(sound)"
        } else {
            self._sound = nil
        }
        self.word = word
        self.pt = pt
        self.paraphrase = paraphrase
    }
    
    public init?(map: Map) {

    }
    
    public mutating func mapping(map: Map) {
        _sound <- map["sound"]
        word <- map["word"]
        pt <- map["pt"]
        paraphrase <- map["paraphrase"]
        hashTable <- map["hashTable"]
        reverse <- map["reverse"]
    }
    
    public var hashTable: [String : Any] = [:]
    
    public let id = UUID()
    private var _sound: String?
    public var sound: URL? {
        if let sound = _sound {
            return URL(string: sound)
        } else {
            return nil
        }
    }
    public var word: String!
    public var pt: String! // 音标
    public var paraphrase: [Paraphrase]!
    public var reverse:Bool! = false
}

public struct Paraphrase: WriteAndReadAble, Identifiable, Mappable {
    public init(ps: String, explain: [String], exampleSentence: [[String]]) {
        self.ps = ps
        self.explain = explain
        self.exampleSentence = exampleSentence
    }
    
    public init?(map: Map) {

    }
    
    public mutating func mapping(map: Map) {
        ps <- map["ps"]
        explain <- map["explain"]
        exampleSentence <- map["exampleSentence"]
        hashTable <- map["hashTable"]
    }
    
    
    public var hashTable: [String : Any] = [:]
    
    public let id = UUID()
    
    public var ps: String! // 词性
    public var explain: [String]! // 释义
    public var exampleSentence: [[String]]! // 例句
}
