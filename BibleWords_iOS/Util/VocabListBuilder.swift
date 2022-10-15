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
        let refWordIds: Set<String> = .init(words.compactMap { $0["id"] as? String })
        let wordInfos = refWordIds.map {
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
