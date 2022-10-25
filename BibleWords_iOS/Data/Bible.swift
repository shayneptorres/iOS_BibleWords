//
//  Bible.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/22/22.
//

import Foundation
import CoreData

struct Bible {
    static var main = Bible()
    var references = References()
    var greekLexicon = Lexicon()
    var hebrewLexicon = Lexicon()
    
    struct Lexicon {
        private var lex: [String:[String:[String:AnyObject]]] = [:]

        init(lex: [String:[String:[String:AnyObject]]] = [:]) {
            self.lex = lex
        }
        
        mutating func add(newLex: [String:[String:[String:AnyObject]]] = [:], source: String) {
            self.lex[source] = newLex[source]!
        }
        
        mutating func add(list: [TextbookImportWord], id: String) {
            for word in list {
                let wordData: [String: AnyObject] = [
                    "id": word.strongId as AnyObject,
                    "lemma": word.lemma as AnyObject,
                    "definition": word.gloss as AnyObject,
                    "chapter": word.chap as AnyObject,
                    "usage": "" as AnyObject,
                    "instances":[] as AnyObject
                ]
                if lex[id] == nil {
                    lex[id] = [String:[String:AnyObject]]()
                }
                lex[id]![word.strongId] = wordData
            }
        }
        
        func words(source: String = API.Source.Info.app.id) -> [Bible.WordInfo] {
            guard let sourceLex = self.lex[source] else { return [] }
                    
            let i = sourceLex.compactMap { $0.value["id"] as? String}
            let words: [Bible.WordInfo] = i.compactMap { word(for: $0, source: source) }

            return words
        }

        func word(for strongID: String, source: String = API.Source.Info.app.id) -> Bible.WordInfo? {
            guard
                let sourceLex = self.lex[source],
                let wordDict = sourceLex[strongID]
            else {
                return .init([:])
            }
            
            if source == API.Source.Info.app.id {
                // getting word from app lexicon, return right away
                return .init(wordDict)
            } else {
                // getting word from textbook import, get instances from main lexicon
                if let appLexWord = self.lex[API.Source.Info.app.id]?[strongID] {
                    let appWordInfo = Bible.WordInfo(appLexWord)
                    var word = Bible.WordInfo(wordDict)
                    word.instances = appWordInfo.instances
                    return word
                } else {
                    return Bible.WordInfo(wordDict)
                }
            }
        }
    }
    
    struct References {
        var values: [[[[[String:AnyObject]]]]] = []
        struct Word: Identifiable, Hashable {
            var id: String
            var surface: String
            var parsing: String
            var ref: String
            
            init(_ dict: [String:AnyObject]) {
                self.id = dict["id"] as? String ?? ""
                self.surface = dict["surface"] as? String ?? ""
                self.parsing = dict["parsing"] as? String ?? ""
                self.ref = dict["ref"] as? String  ?? ""
            }
        }
        
        func verse(book: Int, chapter: Int, verse: Int) -> [WordInstance] {
            if Bible.main.references.values.count >= book {
                if Bible.main.references.values[book-1].count >= chapter {
                    // get the specified verse
                    if Bible.main.references.values[book-1][chapter-1].count >= verse {
                        let verse = Bible.main.references.values[book-1][chapter-1][verse-1]
                        let words = verse.map { WordInstance(dict: $0) }
                        return words
                    }
                }
                return []
            }
            return []
        }
        
        func verses(book: Int, chapter: Int, verse: Int) -> [WordInstance] {
            if Bible.main.references.values.count >= book {
                if Bible.main.references.values[book-1].count >= chapter {
                    if verse == -1 {
                        // if verse is -1, get all verses
                        var versesArr = Bible.main.references.values[book-1][chapter-1]
                        for i in 0..<versesArr.count {
                            versesArr[i].insert(["id":"verse-num","surface":"\(i+1)"] as [String:AnyObject], at: 0)
                        }
                        
                        let words = versesArr.flatMap { $0 }.map { WordInstance(dict: $0) }
                        return words
                    } else {
                        // get the specified verse
                        if Bible.main.references.values[book-1][chapter-1].count >= verse {
                            let verse = Bible.main.references.values[book-1][chapter-1][verse-1]
                            let words = verse.map { WordInstance(dict: $0) }
                            return words
                        }
                    }
                }
                return []
            }
            return []
        }
    }
    
    struct WordInfo: Identifiable, Hashable {
        var id: String
        var lemma: String
        var definition: String
        var usage: String
        var instances: [WordInstance]
        // Textbook import only
        var chapter: String

        init(_ dict: [String:AnyObject]) {
            self.id = dict["id"] as? String ?? ""
            self.lemma = dict["lemma"] as? String  ?? ""
            self.definition = dict["definition"] as? String  ?? ""
            self.usage = dict["usage"] as? String  ?? ""
            self.chapter = dict["chapter"] as? String  ?? "-1"
            let instancesArr = dict["instances"] as? [[String:AnyObject]] ?? []
            instances = instancesArr.map { WordInstance(dict: $0) }
        }
        
        func vocabWord(context: NSManagedObjectContext) -> VocabWord? {
            let vocabFetchRequest = NSFetchRequest<VocabWord>(entityName: "VocabWord")
            vocabFetchRequest.predicate = NSPredicate(format: "SELF.id == %@", self.id)
            
            var word: VocabWord?
            do {
                word = try context.fetch(vocabFetchRequest).first
            } catch let err {
                print(err)
            }
            
            return word
        }
        
        var language: Language {
            if instances.first?.bibleBook.rawValue ?? 0 <= Bible.Book.malachi.rawValue {
                return .hebrew
            } else {
                return .greek
            }
        }
        
        var parsingInfo: ParsingInfo {
            var parsingDict: [String:WordInstance] = [:]
            for instance in instances {
                parsingDict[instance.parsing] = instance
            }
            let uniqueInstances = parsingDict.map { $0.value }
            
            return .init(strongId: self.id, lemma: self.lemma, definition: self.definition, instances: uniqueInstances)
        }
        
        func parsingInfo(for wordType: Parsing.WordType) -> ParsingInfo {
            var parsingDict: [String:WordInstance] = [:]
            for instance in instances {
                parsingDict[instance.parsing] = instance
            }
            let uniqueInstances = parsingDict.map { $0.value }
            
            return .init(strongId: self.id, lemma: self.lemma, definition: self.definition, instances: uniqueInstances)
        }
    }
    
    struct ParsingInfo: Identifiable, Hashable {
        let id: String = UUID().uuidString
        let strongId: String
        let lemma: String
        let definition: String
        var instances: [WordInstance]
    }
    
    struct WordInstance: Identifiable, Hashable {
        let id: String
        let strongId: String
        let index: Int
        let lemma: String
        let surfaceComponents: String
        let rawSurface: String
//        let surfaceComponents: String
        let parsing: String
        let refStr: String

        init(dict: [String:AnyObject]) {
            self.id = UUID().uuidString
            self.strongId = dict["id"] as? String ?? UUID().uuidString
            self.lemma = dict["lemma"] as? String ?? ""
            self.index = dict["index"] as? Int ?? 0
            self.surfaceComponents = dict["surface"] as? String ?? ""
            self.rawSurface = dict["rawSurface"] as? String ?? ""
            self.parsing = dict["parsing"] as? String ?? ""
            self.refStr = dict["ref"] as? String ?? ""
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(textSurface)
        }

        var bibleBook: Bible.Book {
            guard let id = Int(refStr.split(separator: ".").first ?? "") else { return .matthew }
            return .init(rawValue: id) ?? .matthew
        }
        
        var bookInt: Int {
            guard let id = Int(refStr.split(separator: ".")[0]) else { return 0 }
            return id
        }
        
        var chapter: Int {
            guard let id = Int(refStr.split(separator: ".")[1]) else { return 0 }
            return id
        }
        
        var verse: Int {
            guard let id = Int(refStr.split(separator: ".")[2]) else { return 0 }
            return id
        }
        
        var prettyRefStr: String {
            return "\(bibleBook.shortTitle) \(chapter):\(verse)"
        }
        
        var surface: String {
            return surfaceComponents.replacingOccurrences(of: "/", with: "")
        }
        
        var textSurface: String {
            return rawSurface.isEmpty ? surface : rawSurface
        }
        
        var parsingStr: String {
//            if parsing.first == " " {
//                return String(parsing.dropFirst())
//            }
            return parsing
        }
        
        var displayParsingStr: String {
            if language == .greek {
                return parsing
            } else  {
                var str = ""
                str = parsing.replacingOccurrences(of: " perfect ", with: " Qatal (perfect) ")
                str = str.replacingOccurrences(of: " sequential perfect ", with: " WeQatal (sequential perfect) ")
                str = str.replacingOccurrences(of: " imperfect ", with: " Yiqtol (imperfect) ")
                str = str.replacingOccurrences(of: " sequential imperfect ", with: " WayYiqtol (sequential imperfect) ")
                if str.first == " " {
                    return String(str.dropFirst())
                }
                return str
            }
        }
        
        var language: Language {
            if bookInt < 40 {
                return .hebrew
            } else {
                return .greek
            }
        }
        
        var wordInPassage: String {
            if Bible.main.references.values.count >= bookInt {
                if Bible.main.references.values[bookInt-1].count >= chapter {
                    if Bible.main.references.values[bookInt-1][chapter-1].count >= verse {
                        let verse = Bible.main.references.values[bookInt-1][chapter-1][verse-1]
                        let words = verse.compactMap { ($0["surface"] as? String)?.replacingOccurrences(of: "/", with: "") }
                        return words.joined(separator: " ")
                    }
                }
                return ""
            }
            return ""
        }
        
        var wordInfo: WordInfo {
            if language == .greek {
                return Bible.main.greekLexicon.word(for: self.strongId) ?? .init([:])
            } else {
                return Bible.main.hebrewLexicon.word(for: self.strongId.getDigits) ?? .init([:])
            }
        }
    }
}

extension Bible {
    enum Book: Int, CaseIterable {
        case genesis = 1
        case exodus
        case leviticus
        case numbers
        case deuteronomy
        case joshua
        case judges
        case ruth
        case samuel1
        case samuel2
        case kings1
        case kings2
        case chronicles1
        case chronicles2
        case ezra
        case nehemiah
        case esther
        case job
        case psalms
        case provebers
        case ecclesiastes
        case songOfSolomon
        case isaiah
        case jeremiah
        case lamentations
        case ezekiel
        case daniel
        case hosea
        case joel
        case amos
        case obadiah
        case jonah
        case micah
        case nahum
        case habakkuk
        case zephaniah
        case haggai
        case zechariah
        case malachi
        case matthew
        case mark
        case luke
        case john
        case acts
        case romans
        case corinthians1
        case corinthians2
        case galatians
        case ephesians
        case philippians
        case colossians
        case thessalonians1
        case thessalonians2
        case timothy1
        case timothy2
        case titus
        case philemon
        case hebrews
        case james
        case peter1
        case peter2
        case john1
        case john2
        case john3
        case jude
        case revelation
        
        var title: String {
            switch self {
            case .genesis: return "Genesis"
            case .exodus: return "Exodus"
            case .leviticus: return "Leviticus"
            case .numbers: return "Numbers"
            case .deuteronomy: return "Deuteronomy"
            case .joshua: return "Joshua"
            case .judges: return "Judges"
            case .ruth: return "Ruth"
            case .samuel1: return "I Samuel"
            case .samuel2: return "II Samuel"
            case .kings1: return "I Kings"
            case .kings2: return "II Kings"
            case .chronicles1: return "I Chronicles"
            case .chronicles2: return "II Chronicles"
            case .ezra: return "Ezra"
            case .nehemiah: return "Nehemiah"
            case .esther: return "Esther"
            case .job: return "Job"
            case .psalms: return "Psalms"
            case .provebers: return "Proverbs"
            case .ecclesiastes: return "Ecclesiastes"
            case .songOfSolomon: return "Song of Solomon"
            case .isaiah: return "Isaiah"
            case .jeremiah: return "Jeremiah"
            case .lamentations: return "Lamentations"
            case .ezekiel: return "Ezekiel"
            case .daniel: return "Daniel"
            case .hosea: return "Hosea"
            case .joel: return "Joel"
            case .amos: return "Amos"
            case .obadiah: return "Obadiah"
            case .jonah: return "Jonah"
            case .micah: return "Micah"
            case .nahum: return "Nahum"
            case .habakkuk: return "Habakkuk"
            case .zephaniah: return "Zephaniah"
            case .haggai: return "Haggai"
            case .zechariah: return "Zechariah"
            case .malachi: return "Malachi"
            case .matthew: return "Matthew"
            case .mark: return "Mark"
            case .luke: return "Luke"
            case .john: return "John"
            case .acts: return "Acts"
            case .romans: return "Romans"
            case .corinthians1: return "1 Corinthians"
            case .corinthians2: return "2 Corinthians"
            case .galatians: return "Galatians"
            case .ephesians: return "Ephesians"
            case .philippians: return "Philippians"
            case .colossians: return "Colossians"
            case .thessalonians1: return "1 Thessalonians"
            case .thessalonians2: return "2 Thessalonians"
            case .timothy1: return "1 Timothy"
            case .timothy2: return "2 Timothy"
            case .titus: return "Titus"
            case .philemon: return "Philemon"
            case .hebrews: return "Hebrews"
            case .james: return "James"
            case .peter1: return "1 Peter"
            case .peter2: return "2 Peter"
            case .john1: return "1 John"
            case .john2: return "2 John"
            case .john3: return "3 John"
            case .jude: return "Jude"
            case .revelation: return "Revelation"
            }
        }
        
        var shortTitle: String {
            switch self {
            case .genesis: return "Gen"
            case .exodus: return "Ex"
            case .leviticus: return "Lev"
            case .numbers: return "Num"
            case .deuteronomy: return "Deut"
            case .joshua: return "Josh"
            case .judges: return "Jud"
            case .ruth: return "Rth"
            case .samuel1: return "I Sm"
            case .samuel2: return "II Sm"
            case .kings1: return "I Kg"
            case .kings2: return "II Kg"
            case .chronicles1: return "I Chrn"
            case .chronicles2: return "II Chrn"
            case .ezra: return "Ez"
            case .nehemiah: return "Neh"
            case .esther: return "Esth"
            case .job: return "Jb"
            case .psalms: return "Ps"
            case .provebers: return "Prv"
            case .ecclesiastes: return "Eccl"
            case .songOfSolomon: return "Song"
            case .isaiah: return "Is"
            case .jeremiah: return "Jer"
            case .lamentations: return "Lam"
            case .ezekiel: return "Ez"
            case .daniel: return "Dan"
            case .hosea: return "Hos"
            case .joel: return "Jl"
            case .amos: return "Am"
            case .obadiah: return "Ob"
            case .jonah: return "Jonah"
            case .micah: return "Mic"
            case .nahum: return "Nah"
            case .habakkuk: return "Hab"
            case .zephaniah: return "Zeph"
            case .haggai: return "Hag"
            case .zechariah: return "Zech"
            case .malachi: return "Mal"
            case .matthew: return "Mt"
            case .mark: return "Mk"
            case .luke: return "Lk"
            case .john: return "Jn"
            case .acts: return "Act"
            case .romans: return "Rom"
            case .corinthians1: return "1 Cor"
            case .corinthians2: return "2 Cor"
            case .galatians: return "Gal"
            case .ephesians: return "Eph"
            case .philippians: return "Phil"
            case .colossians: return "Col"
            case .thessalonians1: return "1 Thess"
            case .thessalonians2: return "2 Thess"
            case .timothy1: return "1 Tim"
            case .timothy2: return "2 Tim"
            case .titus: return "Titus"
            case .philemon: return "Phile"
            case .hebrews: return "Heb"
            case .james: return "Jam"
            case .peter1: return "1 Pet"
            case .peter2: return "2 Pet"
            case .john1: return "1 Jn"
            case .john2: return "2 Jn"
            case .john3: return "3 Jn"
            case .jude: return "Jude"
            case .revelation: return "Rev"
            }
        }
        
        var searchTitle: String {
            return title.replacingOccurrences(of: " ", with: "")
        }
        
        static var oldTestament: [Bible.Book] {
            return [
                .genesis,
                .exodus,
                .leviticus,
                .numbers,
                .deuteronomy,
                .joshua,
                .judges,
                .ruth,
                .samuel1,
                .samuel2,
                .kings1,
                .kings2,
                .chronicles1,
                .chronicles2,
                .ezra,
                .nehemiah,
                .esther,
                .job,
                .psalms,
                .provebers,
                .ecclesiastes,
                .songOfSolomon,
                .isaiah,
                .jeremiah,
                .lamentations,
                .ezekiel,
                .daniel,
                .hosea,
                .joel,
                .amos,
                .obadiah,
                .jonah,
                .micah,
                .nahum,
                .habakkuk,
                .zephaniah,
                .haggai,
                .zechariah,
                .malachi
            ]
        }
        
        var chapterCount: Int {
            switch self {
            case .genesis: return 50
            case .exodus: return 40
            case .leviticus: return 27
            case .numbers: return 36
            case .deuteronomy: return 34
            case .joshua: return 25
            case .judges: return 21
            case .ruth: return 4
            case .samuel1: return 31
            case .samuel2: return 24
            case .kings1: return 22
            case .kings2: return 25
            case .chronicles1: return 29
            case .chronicles2: return 36
            case .ezra: return 10
            case .nehemiah: return 13
            case .esther: return 10
            case .job: return 42
            case .psalms: return 150
            case .provebers: return 31
            case .ecclesiastes: return 12
            case .songOfSolomon: return 8
            case .isaiah: return 66
            case .jeremiah: return 52
            case .lamentations: return 5
            case .ezekiel: return 48
            case .daniel: return 12
            case .hosea: return 14
            case .joel: return 3
            case .amos: return 9
            case .obadiah: return 1
            case .jonah: return 4
            case .micah: return 7
            case .nahum: return 3
            case .habakkuk: return 3
            case .zephaniah: return 3
            case .haggai: return 2
            case .zechariah: return 14
            case .malachi: return 3
            case .matthew: return 28
            case .mark: return 16
            case .luke: return 24
            case .john: return 21
            case .acts: return 28
            case .romans: return 16
            case .corinthians1: return 16
            case .corinthians2: return 13
            case .galatians: return 6
            case .ephesians: return 6
            case .philippians: return 4
            case .colossians: return 4
            case .thessalonians1: return 5
            case .thessalonians2: return 3
            case .timothy1: return 6
            case .timothy2: return 4
            case .titus: return 3
            case .philemon: return 1
            case .hebrews: return 13
            case .james: return 5
            case .peter1: return 5
            case .peter2: return 3
            case .john1: return 5
            case .john2: return 1
            case .john3: return 1
            case .jude: return 1
            case .revelation: return 22
            }
        }
    }
}

extension Bible {
//    struct Greek {
//        static var main = Greek()
//        var references = References([:])
//        var words = Words()
//        struct Words {
//            private var dict: [String:[String:[String:AnyObject]]] = [:]
//
//            init(dict: [String:[String:[String:AnyObject]]] = [:]) {
//                self.dict = dict
//            }
//
//            func word(for strongID: String, source: String = "dc86985c-3dd5-11ed-a92f-4a45421fd684") -> WordInfo {
//                guard
//                    let wordsForSource = self.dict[source],
//                    let wordDict = wordsForSource[strongID]
//                else {
//                    return .init([:])
//                }
//
//                return .init(wordDict)
//            }
//        }
//
//        struct References {
//            var dict: [String: [String:[String:[[String:AnyObject]]]]] = [:]
//            init(_ dict: [String: [String:[String:[[String:AnyObject]]]]]) {
//                self.dict = dict
//            }
//
//            func instances(for book: Bible.Book, chapter: Int, verse: String) -> [WordInstance] {
//                let arr = dict["\(book.rawValue)"]!["\(chapter)"]![verse] ?? []
//                return arr.compactMap { WordInstance(dict: $0) }
//            }
//        }
//    }
}

extension String {
    var getDigits: String {
        self.components(separatedBy:CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
