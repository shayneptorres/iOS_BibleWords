//
//  Bible.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/22/22.
//

import Foundation

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

        func word(for strongID: String, source: String = "dc86985c-3dd5-11ed-a92f-4a45421fd684") -> Bible.WordInfo {
            guard
                let wordsForSource = self.lex[source],
                let wordDict = wordsForSource[strongID]
            else {
                return .init([:])
            }

            return .init(wordDict)
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
    }
    
    struct WordInfo: Identifiable, Hashable {
        var id: String
        var lemma: String
        var definition: String
        var usage: String
        var instances: [WordInstance]

        init(_ dict: [String:AnyObject]) {
            self.id = dict["id"] as? String ?? ""
            self.lemma = dict["lemma"] as? String  ?? ""
            self.definition = dict["definition"] as? String  ?? ""
            self.usage = dict["usage"] as? String  ?? ""
            let instancesArr = dict["instances"] as? [[String:AnyObject]] ?? []
            instances = instancesArr.map { WordInstance(dict: $0) }
        }
    }
    
    struct WordInstance: Identifiable, Hashable {
        let id: String
        let index: Int
        let lemma: String
        let surface: String
        let rawSurface: String
        let cleanSurface: String
        let parsing: String
        let refStr: String

        init(dict: [String:AnyObject]) {
            self.id = UUID().uuidString
            self.lemma = dict["lemma"] as? String ?? ""
            self.index = dict["index"] as? Int ?? 0
            self.surface = dict["surface"] as? String ?? ""
            self.parsing = dict["parse"] as? String ?? ""
            self.refStr = dict["ref"] as? String ?? ""
            self.rawSurface = dict["rawSurface"] as? String ?? ""
            self.cleanSurface = dict["cleanSurface"] as? String ?? ""
        }

        var bibleBook: Bible.Book {
            guard let id = Int(refStr.split(separator: ".").first ?? "") else { return .matthew }
            return .init(rawValue: id) ?? .matthew
        }
        
        var chapter: Int {
            guard let id = Int(refStr.split(separator: ".")[1]) else { return 0 }
            return id
        }
        
        var verse: Int {
            guard let id = Int(refStr.split(separator: ".")[2]) else { return 0 }
            return id
        }
    }
    
//    struct Hebrew {
//        static var main = Hebrew()
//        var references = References()
//        var words = Words()
//
//        struct Book {
//            struct Chapter {
//                struct Verse {
//                    struct Word {
//                        var values: [String] = []
//                        var surface: String { values[0] }
//                        var strongRaw: String { values[1] }
//                        var parsing: String { values[2] }
//                        var strongID: String {
//                            return "H" + strongRaw.getDigits
//                        }
//                    }
//                    var words: [Word] = []
//                }
//                var verses: [Verse] = []
//            }
//            var title: String = ""
//            var chapters: [Chapter] = []
//        }
//
//        struct StrongIDCount {
//            static var main = StrongIDCount(dict: [:])
//            var dict: [String:Int] = [:]
//        }
//
//        struct References {
//            var books: [String:Hebrew.Book] = [:]
//
//            init() {}
//
//            init(from data: [[String:AnyObject]]) {
//                let importedBooks = data[0]
//                var newBooks: [String:Bible.Hebrew.Book] = [:]
//                for bibleBook in Bible.Book.oldTestament {
//                    var newChapters: [Hebrew.Book.Chapter] = []
//                    for chap in (importedBooks[bibleBook.title] as? [[[[String]]]] ?? []) {
//                        var newVerses: [Hebrew.Book.Chapter.Verse] = []
//                        for verses in chap {
//                            var newWords: [Hebrew.Book.Chapter.Verse.Word] = []
//                            for word in verses {
//                                let strongs = word[1].components(separatedBy: CharacterSet(charactersIn: "/ "))
//                                for str in strongs {
//                                    let count = StrongIDCount.main.dict[str] ?? 0
//                                    StrongIDCount.main.dict[str] = (count + 1)
//                                }
//                                newWords.append(.init(values: word))
//                            }
//                            newVerses.append(.init(words: newWords))
//                        }
//                        newChapters.append(.init(verses: newVerses))
//                    }
//                    newBooks[bibleBook.title] = .init(title: bibleBook.title, chapters: newChapters)
//                }
//                self.books = newBooks
//            }
//
//            func get(_ bookInt: Int) -> Bible.Hebrew.Book {
//                let bibleBook = Bible.Book(rawValue: bookInt) ?? .genesis
//                return books[bibleBook.title] ?? .init()
//            }
//
//            func get(_ book: Bible.Book) -> Bible.Hebrew.Book {
//                return books[book.title] ?? .init()
//            }
//
//            func get(_ book: Bible.Book, chapter: Int) -> Bible.Hebrew.Book.Chapter {
//                return get(book).chapters[chapter]
//            }
//
//            func get(_ bookInt: Int, chapter: Int) -> Bible.Hebrew.Book.Chapter {
//                return get(bookInt).chapters[chapter]
//            }
//
//            func get(_ book: Bible.Book, chapter: Int, verse: Int) -> Bible.Hebrew.Book.Chapter.Verse {
//                return get(book).chapters[chapter].verses[verse]
//            }
//        }
//
//        struct Words {
//            private var dict: [String:[String:[String:AnyObject]]] = [:]
//
//            init(dict: [String:[String:[String:AnyObject]]] = [:]) {
//                self.dict = dict
//            }
//
//            func word(for strongID: String, source: String = "dc86985c-3dd5-11ed-a92f-4a45421fd684") -> Bible.WordInfo {
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
//    }
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
