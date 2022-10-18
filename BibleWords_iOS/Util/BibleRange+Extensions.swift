//
//  BibleRange+Extensions.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/15/22.
//

import Foundation

extension Array where Element == BibleRange {
    var title: String {
        guard !self.isEmpty else { return "No ranges for this list" }
        // we have ranges from the bible
        if self.count == 1, let range = self.first {
            return "\(Bible.Book(rawValue: range.bookStart)?.shortTitle ?? "") \(range.chapStart) - \(Bible.Book(rawValue: range.bookEnd)?.shortTitle ?? "") \(range.chapEnd)"
        } else {
            var str = ""
            for range in self.sorted(by: { $0.bookStart < $1.bookStart }) {
                str += "\(Bible.Book(rawValue: range.bookStart) ?? .genesis) \(range.chapStart) - \(Bible.Book(rawValue: range.bookEnd) ?? .genesis) \(range.chapEnd), "
            }
            return str
        }
    }
    
    var details: String {
        guard !self.isEmpty else { return "-" }
        
        // we have ranges from the bible
        if self.count == 1, let range = self.first {
            if range.occurrencesInt == 0 {
                return "All occurrences"
            }
            return "\(range.occurrencesInt)+ occurrences"
        } else {
            return "Mixed ranges/occurences"
        }
    }
}

extension Array where Element == TextbookRange {
    var title: String {
        guard !self.isEmpty else { return "No ranges for this list" }
        // we have ranges from a textbook
        if self.count == 1, let range = self.first, let info = API.Source.Info.info(for: range.info.id) {
            return "\(info.shortName)"
        } else {
            return "Random ranges"
        }
    }
    
    var details: String {
        guard !self.isEmpty else { return "-" }
        // we have ranges from a textbook
        if self.count == 1, let range = self.first {
            return "Chapter \(range.chapStart) - Chapter \(range.chapEnd)"
        } else {
            return "Multiple ranges selected"
        }
    }
}