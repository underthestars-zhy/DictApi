# DictApi

A powerful library for swift programmer to get word from dicts.

## DictType

### Collins

* from language: en
* to language: cn
* pronunciation: US
* method: web
* Extra attributes: None
```swift
let data = await DictApi.shared.getData(with: .collins, for: "Swift", from: .en, to: .cn)
print(data.word)
```

## Data Model

### DictDataModel

Flow: Identifiable, WriteAndReadAble, Mappable

1. sound: Extra attributes
2. pt: Extra attributes
3. word: the word you search, actually is lowercase
4. paraphrase: Paraphrase array

### Paraphrase

Flow: Identifiable, WriteAndReadAble, Mappable

1. ps: Part of speech
2. explain: Paraphrase (array)
3. exampleSentence: Sentence (Corresponds to explain)
