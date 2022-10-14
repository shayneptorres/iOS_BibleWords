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
            let chapRange = Array(Int((chapStart))...Int((chapEnd)))
            bookChapRange = [bookStart:chapRange]
        } else {
            let bookIntRange = Array(bookStart...bookEnd)
            
            let startBookChapRange = Array(Int(chapStart)..<Bible.main.references.values[bookStart].count)
            bookChapRange[bookStart] = startBookChapRange
            let endBookChapRange = Array(0..<Int(chapEnd))
            bookChapRange[bookEnd] = endBookChapRange
            
            let middleBooks = Array(bookIntRange.dropFirst().dropLast())
            for book in middleBooks {
                bookChapRange[book] = Array(0..<Bible.main.references.values[book - 1].count)
            }
        }
        var chapters: [[[[String : AnyObject]]]] = []
        for (bookInt, chapInts) in bookChapRange.sorted(by: { $0.key < $1.key }) {
            for chapInt in chapInts {
                chapters.append(Bible.main.references.values[bookInt-1][chapInt-1])
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
