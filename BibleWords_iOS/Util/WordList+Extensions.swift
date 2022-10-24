//
//  WordList+Extensions.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/13/22.
//

import Foundation

extension VocabWordList {
    
    static func == (lhs: VocabWordList, rhs: VocabWordList) -> Bool {
        return (lhs.id ?? "") == (rhs.id ?? "")
    }
    
    enum SourceType {
        case app
        case textbook
    }
    
    var wordsArr: [VocabWord] {
        return (words?.allObjects ?? []) as! [VocabWord]
    }
    
    var dueWords: [VocabWord] {
        return wordsArr.filter { $0.dueDate! < Date() }.sorted { $0.dueDate! < $1.dueDate! }
    }
    
    var rangesArr: [VocabWordRange] {
        return (ranges?.allObjects ?? []) as! [VocabWordRange]
    }
    
    var sourceType: SourceType {
        if sources.contains(where: { $0.id == API.Source.Info.app.id }) {
            return .app
        } else {
            return .textbook
        }
    }
    
    var sources: [API.Source.Info] {
        return rangesArr.compactMap { $0.sourceId }.compactMap { API.Source.Info.info(for: $0) }
    }
    
    var defaultTitle: String {
        guard !rangesArr.isEmpty else { return "No ranges for this list" }
        if sources.first(where: { $0.id != API.Source.Info.app.id }) != nil {
            // we have ranges from a textbook
            if rangesArr.count == 1, let range = rangesArr.first, let info = API.Source.Info.info(for: range.sourceId ?? "") {
                return "\(info.shortName)"
            } else {
                return "Random ranges"
            }
        } else {
            // we have ranges from the bible
            if rangesArr.count == 1, let range = rangesArr.first {
                return "\(Bible.Book(rawValue: range.bookStart.toInt)?.shortTitle ?? "") \(range.chapStart) - \(Bible.Book(rawValue: range.bookEnd.toInt)?.shortTitle ?? "") \(range.chapEnd)"
            } else {
                var str = ""
                for range in rangesArr.sorted(by: { $0.bookStart < $1.bookStart }) {
                    str += "\(Bible.Book(rawValue: range.bookStart.toInt) ?? .genesis) \(range.chapStart) - \(Bible.Book(rawValue: range.bookEnd.toInt) ?? .genesis) \(range.chapEnd), "
                }
                return str
            }
        }
    }
    
    var defaultDetails: String {
        guard !rangesArr.isEmpty else { return "-" }
        
        if sources.first(where: { $0.id != API.Source.Info.app.id }) != nil {
            // we have ranges from a textbook
            if rangesArr.count == 1, let range = rangesArr.first {
                return "Ch \(range.chapStart) - Ch \(range.chapEnd)"
            } else {
                return "Multiple ranges selected"
            }
        } else {
            // we have ranges from the bible
            if rangesArr.count == 1, let range = rangesArr.first {
                return "\(range.occurrences)+ occurrences"
            } else {
                return "Mixed ranges/occurences"
            }
        }
    }
    
    var isDueWordList: Bool {
        return self.id == "TEMP-DUE-WORD-LIST"
    }
}

extension ParsingList {
    var sessionsArr: [StudySession] {
        return (studySessions?.allObjects ?? []) as! [StudySession]
    }
    
    var language: Language {
        return Language(rawValue: self.languageInt) ?? .greek
    }
    
    var wordType: Parsing.WordType {
        return .init(rawValue: self.wordTypeStr ?? "") ?? .noun
    }
    
    var cases: [Parsing.Greek.Case] {
        self.casesStr?.split(separator: ".").compactMap { Parsing.Greek.Case(rawValue: String($0)) } ?? []
    }
    
    var genders: [Parsing.Gender] {
        self.gendersStr?.split(separator: ".").compactMap { Parsing.Gender(rawValue: String($0)) } ?? []
    }
    
    var numbers: [Parsing.Number] {
        self.numbersStr?.split(separator: ".").compactMap { Parsing.Number(rawValue: String($0)) } ?? []
    }
    
    var tenses: [Parsing.Greek.Tense] {
        self.tensesStr?.split(separator: ".").compactMap { Parsing.Greek.Tense(rawValue: String($0)) } ?? []
    }
    
    var voices: [Parsing.Greek.Voice] {
        self.voicesStr?.split(separator: ".").compactMap { Parsing.Greek.Voice(rawValue: String($0)) } ?? []
    }
    
    var moods: [Parsing.Greek.Mood] {
        self.moodsStr?.split(separator: ".").compactMap { Parsing.Greek.Mood(rawValue: String($0)) } ?? []
    }
    
    var persons: [Parsing.Person] {
        self.personsStr?.split(separator: ".").compactMap { Parsing.Person(rawValue: String($0)) } ?? []
    }
    
    var stems: [Parsing.Hebrew.Stem] {
        self.stemsStr?.split(separator: ".").compactMap { Parsing.Hebrew.Stem(rawValue: String($0)) } ?? []
    }
    
    var verbTypes: [Parsing.Hebrew.VerbType] {
        self.hebVerbTypesStr?.split(separator: ".").compactMap { Parsing.Hebrew.VerbType(rawValue: String($0)) } ?? []
    }
    
    var defaultTitle: String {
        guard let range = range else { return "" }
        return "\(Bible.Book(rawValue: range.bookStart.toInt)!.title) \(range.chapStart) - \(Bible.Book(rawValue: range.bookEnd.toInt)!.title) \(range.chapEnd)"
    }
    
    var shortTitle: String {
        guard let range = range else { return "" }
        return "\(Bible.Book(rawValue: range.bookStart.toInt)!.shortTitle) \(range.chapStart) - \(Bible.Book(rawValue: range.bookEnd.toInt)!.shortTitle) \(range.chapEnd)"
    }
    
    var defaultDetails: String {
        guard let range = range else { return "" }
        return "\(range.occurrences)+ occurrences"
    }
    
    var parsingDetails: String {
        var str = wordType.rawValue.capitalized.appending("s: ")
        if wordType == .noun {
            if language == .greek {
                str += [
                    (casesStr ?? "").split(separator: ".").joined(separator: ", "),
                    (numbersStr ?? "").split(separator: ".").joined(separator: ", "),
                    (gendersStr ?? "").split(separator: ".").joined(separator: ", ")
                ].joined(separator: "; ")
            } else {
                str += [
                    (personsStr ?? "").split(separator: ".").joined(separator: ", "),
                    (gendersStr ?? "").split(separator: ".").joined(separator: ", "),
                    (numbersStr ?? "").split(separator: ".").joined(separator: ", ")
                ].joined(separator: "; ")
            }
        } else {
            if language == .greek {
                str += [
                    (tensesStr ?? "").split(separator: ".").joined(separator: ", "),
                    (voicesStr ?? "").split(separator: ".").joined(separator: ", "),
                    (moodsStr ?? "").split(separator: ".").joined(separator: ", ")
                ].joined(separator: "; ")
                if moods.contains(.participle) {
                    str += [
                        (casesStr ?? "").split(separator: ".").joined(separator: ", "),
                        (numbersStr ?? "").split(separator: ".").joined(separator: ", "),
                        (gendersStr ?? "").split(separator: ".").joined(separator: ", ")
                    ].joined(separator: "; ")
                } else {
                    str += [
                        (personsStr ?? "").split(separator: ".").joined(separator: ", "),
                        (numbersStr ?? "").split(separator: ".").joined(separator: ", ")
                    ].joined(separator: "; ")
                }
            } else {
                str += [
                    (stemsStr ?? "").split(separator: ".").joined(separator: ", "),
                    (hebVerbTypesStr ?? "").split(separator: ".").joined(separator: ", "),
                    (personsStr ?? "").split(separator: ".").joined(separator: ", "),
                    (gendersStr ?? "").split(separator: ".").joined(separator: ", "),
                    (numbersStr ?? "").split(separator: ".").joined(separator: ", ")
                ].joined(separator: "; ")
            }
        }
        return str
    }
}
