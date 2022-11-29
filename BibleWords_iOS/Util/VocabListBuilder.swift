//
//  VocabListBuilder.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/22/22.
//

import Foundation
import CoreData

class VocabListBuilder {
    
    static func buildVocabList(bookStart: Int, chapStart: Int, bookEnd: Int, chapEnd: Int, occurrences: Int) -> [Bible.WordInfo] {
        
        var bookChapRange: [Int:[Int]] = [:]
        
        if bookStart == bookEnd {
            if chapStart == chapEnd {
                bookChapRange = [bookStart-1:[chapStart-1]]
            } else {
                let chapRange = Array(Int((chapStart-1))...Int((chapEnd-1)))
                bookChapRange = [bookStart-1:chapRange]
            }
        } else {
            let bookIntRange = Array(bookStart-1...bookEnd-1)
            
            let startBookChapRange = Array(Int(chapStart-1)..<Bible.main.references.values[bookStart].count)
            bookChapRange[bookStart-1] = startBookChapRange
            let endBookChapRange = Array(0...Int(chapEnd-1))
            bookChapRange[bookEnd-1] = endBookChapRange
            
            let middleBooks = Array(bookIntRange.dropFirst().dropLast())
            for book in middleBooks {
                bookChapRange[book] = Array(0..<Bible.main.references.values[book].count)
            }
        }
        var chapters: [[[[String : AnyObject]]]] = []
        for (bookInt, chapInts) in bookChapRange.sorted(by: { $0.key < $1.key }) {
            for chapInt in chapInts {
                chapters.append(Bible.main.references.values[bookInt][chapInt])
            }
        }
        
        let verses = chapters.flatMap { $0 }
        let words = verses.flatMap { $0 }
        var refWordIds = Set<String>.init(words.compactMap { $0["id"] as? String })
        if bookStart < 40 {
            refWordIds = Set<String>.init(refWordIds.map { $0.getDigits })
        }
        let wordInfos = refWordIds.compactMap {
            if bookStart >= 40 {
                return Bible.main.greekLexicon.word(for: $0)
            } else {
                return Bible.main.hebrewLexicon.word(for: $0)
            }
        }
        
        return wordInfos
            .filter { !$0.definition.isEmpty }
            .filter { $0.instances.count >= occurrences }
    }
    
    static func buildHebrewTextbookList(sourceId: String, chapterStart: Int, chapterEnd: Int) -> [Bible.WordInfo] {
        let textbookWords = Bible.main.hebrewLexicon.words(source: sourceId)
        let textbookChapterFilterdWords = textbookWords.filter ({ $0.chapter.toInt >= chapterStart && $0.chapter.toInt <= chapterEnd })
        
        return textbookChapterFilterdWords
    }
    
    static func buildParsingList(range: BibleRange, language: Language, wordType: Parsing.WordType, cases: [Parsing.Greek.Case], genders: [Parsing.Gender], numbers: [Parsing.Number], tenses: [Parsing.Greek.Tense], voices: [Parsing.Greek.Voice], moods: [Parsing.Greek.Mood], persons: [Parsing.Person], stems: [Parsing.Hebrew.Stem], verbTypes: [Parsing.Hebrew.VerbType], onComplete: ([Bible.WordInstance]) -> Void) {
        
        let words = VocabListBuilder.buildVocabList(bookStart: range.bookStart,
                                             chapStart: range.chapStart,
                                             bookEnd: range.bookEnd,
                                             chapEnd: range.chapEnd,
                                                    occurrences: range.occurrencesInt).filter { $0.instances.first != nil && $0.instances.first!.parsing.lowercased().contains(wordType.name.lowercased()) }
        
        var filteredWordInstanceDict: [String:Bible.WordInstance] = [:]
        var filteredWordInstanceArr: [Bible.WordInstance] = []
        var instances = words.flatMap { $0.instances }
        
        if wordType == .verb {
            if language == .greek {
                // tense
                if !tenses.isEmpty {
                    tenses.forEach { t in
                        instances.forEach { i in
                            if i.parsing.lowercased().contains(t.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                } else {
                    for i in instances { filteredWordInstanceDict[i.textSurface] = i }
                }
                
                // voice
                if !voices.isEmpty {
                    instances = Array(filteredWordInstanceDict.values)
                    filteredWordInstanceDict.removeAll()
                    instances.forEach { i in
                        voices.forEach { v in
                            if i.parsing.lowercased().contains(v.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                }
                
                // mood
                if !moods.isEmpty {
                    instances = Array(filteredWordInstanceDict.values)
                    filteredWordInstanceDict.removeAll()
                    instances.forEach { i in
                        moods.forEach { m in
                            if i.parsing.lowercased().contains(m.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                }
                
                // person
                if !persons.isEmpty {
                    instances = Array(filteredWordInstanceDict.values)
                    filteredWordInstanceDict.removeAll()
                    instances.forEach { i in
                        persons.forEach { p in
                            if i.parsing.lowercased().contains(p.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                }
                
                // number
                if !numbers.isEmpty {
                    instances = Array(filteredWordInstanceDict.values)
                    filteredWordInstanceDict.removeAll()
                    instances.forEach { i in
                        numbers.forEach { n in
                            if i.parsing.lowercased().contains(n.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                }
                
                if moods.contains(.participle) {
                    // cases for participles
                    var participleInstances = Array(filteredWordInstanceDict.values).filter { $0.parsing.lowercased().contains("participle") }
                    
                    let nonParticipleInstances = Array(filteredWordInstanceDict.values).filter { !$0.parsing.lowercased().contains("participle") }
                    
                    filteredWordInstanceDict.removeAll()
                    
                    if !cases.isEmpty {
                        cases.forEach { c in
                            participleInstances.forEach { i in
                                if i.parsing.lowercased().contains(c.rawValue) {
                                    filteredWordInstanceDict[i.textSurface] = i
                                }
                            }
                        }
                    } else {
                        participleInstances.forEach { filteredWordInstanceDict[$0.textSurface] = $0 }
                    }
                    
                    participleInstances = Array(filteredWordInstanceDict.values).filter { $0.parsing.lowercased().contains("participle") }
                    
                    // gender for participles
                    if !genders.isEmpty {
                        participleInstances.forEach { i in
                            genders.forEach { g in
                                if i.parsing.lowercased().contains(g.rawValue) {
                                    filteredWordInstanceDict[i.textSurface] = i
                                }
                            }
                        }
                    } else {
                        participleInstances.forEach { filteredWordInstanceDict[$0.textSurface] = $0 }
                    }
                    
                    nonParticipleInstances.forEach { filteredWordInstanceDict[$0.textSurface] = $0 }
                }
                
                filteredWordInstanceArr = Array(filteredWordInstanceDict.values)
            } else if language == .hebrew {
                // stems
                if !stems.isEmpty {
                    stems.forEach { s in
                        instances.forEach { i in
                            if i.parsing.lowercased().contains(s.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                } else {
                    for i in instances { filteredWordInstanceDict[i.textSurface] = i }
                }
                
                // verb types
                if !verbTypes.isEmpty {
                    instances = Array(filteredWordInstanceDict.values)
                    filteredWordInstanceDict.removeAll()
                    instances.forEach { i in
                        verbTypes.forEach { vt in
                            if i.parsing.lowercased().contains(vt.parsingKey) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                }
                
                // gender
                if !genders.isEmpty {
                    instances = Array(filteredWordInstanceDict.values)
                    filteredWordInstanceDict.removeAll()
                    instances.forEach { i in
                        genders.forEach { g in
                            if i.parsing.lowercased().contains(g.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                }
                
                // person
                if !persons.isEmpty {
                    instances = Array(filteredWordInstanceDict.values)
                    filteredWordInstanceDict.removeAll()
                    instances.forEach { i in
                        persons.forEach { p in
                            if i.parsing.lowercased().contains(p.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                }
                
                // number
                if !numbers.isEmpty {
                    instances = Array(filteredWordInstanceDict.values)
                    filteredWordInstanceDict.removeAll()
                    instances.forEach { i in
                        numbers.forEach { n in
                            if i.parsing.lowercased().contains(n.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                }
                
                filteredWordInstanceArr = Array(filteredWordInstanceDict.values)
            }
        } else if wordType == .noun {
            if language == .greek {
                var instances = words.flatMap { $0.instances }
                // case
                if !cases.isEmpty {
                    cases.forEach { c in
                        instances.forEach { i in
                            if i.parsing.lowercased().contains(c.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                } else {
                    for i in instances { filteredWordInstanceDict[i.textSurface] = i }
                }
                
                // number
                if !numbers.isEmpty {
                    instances = Array(filteredWordInstanceDict.values)
                    filteredWordInstanceDict.removeAll()
                    numbers.forEach { n in
                        instances.forEach { i in
                            if i.parsing.lowercased().contains(n.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                }
                
                // gender
                if !genders.isEmpty {
                    instances = Array(filteredWordInstanceDict.values)
                    filteredWordInstanceDict.removeAll()
                    genders.forEach { g in
                        instances.forEach { i in
                            if i.parsing.lowercased().contains(g.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                }

                filteredWordInstanceArr = Array(filteredWordInstanceDict.values)
            } else if language == .hebrew {
                // gender
                if !genders.isEmpty {
                    instances = Array(filteredWordInstanceDict.values)
                    filteredWordInstanceDict.removeAll()
                    genders.forEach { g in
                        instances.forEach { i in
                            if i.parsing.lowercased().contains(g.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                } else {
                    for i in instances { filteredWordInstanceDict[i.textSurface] = i }
                }
                
                // person
                if !persons.isEmpty {
                    instances = Array(filteredWordInstanceDict.values)
                    filteredWordInstanceDict.removeAll()
                    instances.forEach { i in
                        persons.forEach { p in
                            if i.parsing.lowercased().contains(p.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                }
                
                // number
                if !numbers.isEmpty {
                    instances = Array(filteredWordInstanceDict.values)
                    filteredWordInstanceDict.removeAll()
                    numbers.forEach { n in
                        instances.forEach { i in
                            if i.parsing.lowercased().contains(n.rawValue) {
                                filteredWordInstanceDict[i.textSurface] = i
                            }
                        }
                    }
                }
                
                filteredWordInstanceArr = Array(filteredWordInstanceDict.values)
            }
        }
        
        onComplete(filteredWordInstanceArr)
    }
}

func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("Time elapsed for \(title): \(timeElapsed) s.")
}

func timeElapsedInSecondsWhenRunningCode(operation: ()->()) -> Double {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    return Double(timeElapsed)
}
