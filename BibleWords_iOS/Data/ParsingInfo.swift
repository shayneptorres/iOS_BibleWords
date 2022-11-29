//
//  ParsingInfo.swift
//  BibleWords
//
//  Created by Shayne Torres on 10/6/22.
//

import Foundation

struct ParsingInfo {
    let lemma: String
    let surface: String
    let gloss: String
    let parsings: Set<String>
    
    var wordType: Parsing.WordType {
        if allParsingsStr.contains("noun") {
            return .noun
        } else if allParsingsStr.contains("verb") {
            return .verb
        } else {
            return .other
        }
    }
    
    var allParsingsStr: String {
        return Array(parsings).joined(separator: ", ").lowercased()
    }
}

struct Parsing {
    enum WordType: String, CaseIterable {
        case noun
        case verb
        case other
        
        var name: String {
            switch self {
            case .noun: return "Noun"
            case .verb: return "Verb"
            case .other: return "?"
            }
        }
    }
    
    enum Gender: String, CaseIterable {
        case masculine
        case feminine
        case neuter
        case common
        
        static func all(for lang: Language) -> [Gender] {
            switch lang {
            case .hebrew, .aramaic:
                return [.masculine, .feminine, .common]
            case .greek:
                return [.masculine, .feminine, .neuter]
            case .all, .custom:
                return []
            }
        }
    }
    
    enum Person: String, CaseIterable {
        case first
        case second
        case third
        
        var shortTitle: String {
            switch self {
            case .first: return "1st"
            case .second: return "2nd"
            case .third: return "3rd"
            }
        }
        
        var parsingKey: String {
            switch self {
            case .first: return "common"
            case .second: return "second"
            case .third: return "third"
            }
        }
    }
    
    enum Number: String, CaseIterable {
        case singular
        case plural
        case dual
        
        static func all(for lang: Language) -> [Number] {
            switch lang {
            case .hebrew, .aramaic:
                return Number.allCases
            case .greek:
                return [.singular, .plural]
            case .all, .custom:
                return []
            }
        }
    }
    
    struct Parsable {
        var type: WordType
        var lemma: String
        var surface: String
        var gloss: String
        var tense: Parsing.Greek.Tense?
        var voice: Parsing.Greek.Voice?
        var stem: Parsing.Hebrew.Stem?
        var verbType: Parsing.Hebrew.VerbType?
        var moods: [Parsing.Greek.Mood]
        var cases: [Parsing.Greek.Case]
        var genders: [Gender]
        var numbers: [Number]
        var persons: [Person]
        
        static var parsableTypes: [WordType] = [.noun, .verb]
        
        init(for info: ParsingInfo) {
            
            for t in Parsing.Greek.Tense.allCases {
                if info.allParsingsStr.lowercased().contains(t.rawValue) {
                    self.tense = t
                }
            }
            
            for v in Parsing.Greek.Voice.allCases {
                if info.allParsingsStr.contains(v.rawValue) {
                    self.voice = v
                }
            }
            
            self.moods = []
            for m in Parsing.Greek.Mood.allCases {
                if info.allParsingsStr.contains(m.rawValue) {
                    self.moods.append(m)
                }
            }
            
            for s in Parsing.Hebrew.Stem.allCases {
                if info.allParsingsStr.contains(s.rawValue) {
                    stem = s
                }
            }
            
            for v in Parsing.Hebrew.VerbType.allCases {
                if info.allParsingsStr.contains(v.parsingKey) {
                    verbType = v
                }
            }
            
            
            self.cases = []
            for c in Parsing.Greek.Case.allCases {
                if info.allParsingsStr.contains(c.rawValue) {
                    self.cases.append(c)
                }
            }
            
            self.genders = []
            for g in Gender.allCases {
                if info.allParsingsStr.contains(g.rawValue) {
                    self.genders.append(g)
                }
            }
            
            self.numbers = []
            for n in Number.allCases {
                if info.allParsingsStr.contains(n.rawValue) {
                    self.numbers.append(n)
                }
            }
            
            self.persons = []
            for p in Person.allCases {
                if info.allParsingsStr.contains(p.parsingKey) {
                    self.persons.append(p)
                }
            }
            
            self.type = info.wordType
            self.lemma = info.lemma
            self.surface = info.surface
            self.gloss = info.gloss
        }
        
        var parsing: String {
            var parsingings: [String] = []
            if type == .noun {
                parsingings = [
                    cases.map { $0.rawValue }.joined(separator: " or "),
                    persons.map { $0.rawValue }.joined(separator: " or "),
                    genders.map { $0.rawValue }.joined(separator: " or "),
                    numbers.map { $0.rawValue }.joined(separator: " or "),
                ]
            } else if type == .verb {
                if moods.map({ $0.rawValue.lowercased() }).contains("participle") {
                    parsingings = [
                        tense?.rawValue ?? "",
                        voice?.rawValue ?? "",
                        moods.map { $0.rawValue }.joined(separator: " or "),
                        cases.map { $0.rawValue }.joined(separator: " or "),
                        genders.map { $0.rawValue }.joined(separator: " or "),
                        numbers.map { $0.rawValue }.joined(separator: " or "),
                    ]
                } else {
                    parsingings = [
                        tense?.rawValue ?? "",
                        voice?.rawValue ?? "",
                        stem?.rawValue ?? "",
                        verbType?.rawValue ?? "",
                        genders.map { $0.rawValue }.joined(separator: " or "),
                        moods.map { $0.rawValue }.joined(separator: " or "),
                        persons.map { $0.rawValue }.joined(separator: " or "),
                        numbers.map { $0.rawValue }.joined(separator: " or "),
                    ]
                }
            }
            return type.name + ", " + parsingings.joined(separator: ", ").replacingOccurrences(of: " ,", with: "")
        }
    }
    
    struct Greek {
        
        enum Tense: String, CaseIterable {
            case present
            case imperfect
            case future
            case aorist
            case perfect
            case pluperfect
            
            var shortTitle: String {
                switch self {
                case .present: return "Pres"
                case .imperfect: return "Impf"
                case .future: return "Fut"
                case .aorist: return "Aor"
                case .perfect: return "Perf"
                case .pluperfect: return "PlPerf"
                }
            }
        }
        
        enum Voice: String, CaseIterable {
            case active
            case middle
            case middleDeponent
            case passive
            
            var shortTitle: String {
                switch self {
                case .active: return "Act"
                case .middle: return "mid"
                case .middleDeponent: return "Mid/Dep"
                case .passive: return "Pass"
                }
            }
        }
        
        enum Mood: String, CaseIterable {
            case indicative
            case subjunctive
            case imperative
            case infinitive
            case optative
            case participle
            
            var shortTitle: String {
                switch self {
                case .indicative: return "Indic"
                case .subjunctive: return "Subj"
                case .imperative: return "Impv"
                case .infinitive: return "Infin"
                case .optative: return "Opt"
                case .participle: return "Part"
                }
            }
        }
        
        enum Case: String, CaseIterable {
            case nominative
            case genitive
            case dative
            case accusative
            case vocative
            
            var shortTitle: String {
                switch self {
                case .nominative: return "Nom"
                case .genitive: return "Gen"
                case .dative: return "Dat"
                case .accusative: return "Acc"
                case .vocative: return "Voc"
                }
            }
        }
        
        static func parsble(for info: ParsingInfo) -> Parsable? {
            return Parsable(for: info)
        }
    }
}

extension Parsing {
    struct Hebrew {
        
        enum Stem: String, CaseIterable {
            case qal
            case niphal
            case piel
            case pual
            case hiphil
            case hophal
            case hithpael
            case polel
            case polal
            case hithpolel
            case poel
            case poal
            case palel
            case pulal
        }
        
        enum VerbType: String, CaseIterable {
            case qatal
            case weqatal
            case yiqtol
            case wayyiqtol
            case imperative
            case participleActive
            case participlePassive
            case infinitiveAbsolute
            case infinitiveConstruct
            
            var parsingKey: String {
                switch self {
                case .qatal: return " perfect "
                case .weqatal: return " sequential perfect "
                case .yiqtol: return "imperfect"
                case .wayyiqtol: return "sequential imperfect"
                case .imperative: return "imperative"
                case .participleActive: return "participle active"
                case .participlePassive: return "participle passive"
                case .infinitiveAbsolute: return "infinitive absolute"
                case .infinitiveConstruct: return "infinitive construct"
                }
            }
        }
    }
}
