//
//  BibleRange.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/12/22.
//

import Foundation

struct BibleRange: Identifiable, Bindable, Equatable {
    var id: String = UUID().uuidString
    var bookStart: Int = 40
    var bookEnd: Int = 40
    var chapStart: Int = 1
    var chapEnd: Int = 1
    var occurrencesTxt: String = ""
    var occurrencesInt: Int { Int(occurrencesTxt) ?? 0 }
    
    static func ==(lhs: BibleRange, rhs: BibleRange) -> Bool {
        return lhs.id == rhs.id &&
        lhs.bookStart == rhs.bookStart &&
        lhs.chapStart == rhs.chapStart &&
        lhs.bookEnd == rhs.bookEnd &&
        lhs.chapEnd == rhs.chapEnd &&
        lhs.occurrencesInt == rhs.occurrencesInt
    }
    
    var title: String {
        let startBook = Bible.Book(rawValue: bookStart) ?? .matthew
        let endBook = Bible.Book(rawValue: bookEnd) ?? .matthew
        
        if startBook == endBook {
            return "\(startBook.title) \(chapStart) - \(chapEnd)"
        } else {
            return "\(startBook.title) \(chapStart) - \(endBook.title) \(chapEnd)"
        }
    }
    
    var details: String {
        if occurrencesTxt == "0" {
            return "All occurrences"
        } else {
            return "Words with \(occurrencesTxt)+ occurrences"
        }
    }
    
    mutating func set(bookStart: Int) {
        self.bookStart = bookStart
        onRangeUpdated()
    }
    
    mutating func set(chapStart: Int) {
        self.chapStart = chapStart
        onRangeUpdated()
    }
    
    mutating func set(bookEnd: Int) {
        self.bookEnd = bookEnd
        onRangeUpdated()
    }
    
    mutating func set(chapEnd: Int) {
        self.chapEnd = chapEnd
        onRangeUpdated()
    }
    
    mutating func onRangeUpdated() {
        if self.bookStart < 40 && self.bookEnd > 39 {
            // picking an OT range
            self.bookEnd = self.bookStart
        }
        
        if self.bookEnd < self.bookStart {
            self.bookEnd = self.bookStart
        }
        
        if self.bookStart == self.bookEnd && self.chapEnd < self.chapStart {
            self.chapEnd = self.chapStart
        }
    }
}

struct TextbookRange: Identifiable, Bindable, Equatable {
    var id: String = UUID().uuidString
    var info: API.Source.Info
    var chapStart: Int
    var chapEnd: Int
    
    static func ==(lhs: TextbookRange, rhs: TextbookRange) -> Bool {
        return lhs.id == rhs.id &&
        lhs.chapStart == rhs.chapStart &&
        lhs.chapEnd == rhs.chapEnd &&
        lhs.info.id == lhs.info.id
    }
    
    var title: String {
        return info.shortName
    }
    
    var details: String {
        return "Ch\(chapStart) - Ch\(chapEnd)"
    }
}
