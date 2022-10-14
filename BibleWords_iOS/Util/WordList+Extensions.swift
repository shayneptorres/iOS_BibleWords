//
//  WordList+Extensions.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/13/22.
//

import Foundation

extension WordList {
    var rangesArr: [WordRange] {
        return (ranges?.allObjects ?? []) as! [WordRange]
    }
    
    var defaultTitle: String {
        if rangesArr.isEmpty {
            return "No ranges selected"
        } else if rangesArr.count == 1, let range = rangesArr.first {
            return "\(Bible.Book(rawValue: range.bookStart.toInt)?.shortTitle ?? "") \(range.chapStart) - \(Bible.Book(rawValue: range.bookEnd.toInt)?.shortTitle ?? "") \(range.chapEnd)"
        } else {
            var str = ""
            for range in rangesArr.sorted(by: { $0.bookStart < $1.bookStart }) {
                str += "\(Bible.Book(rawValue: range.bookStart.toInt) ?? .genesis) \(range.chapStart) - \(Bible.Book(rawValue: range.bookEnd.toInt) ?? .genesis) \(range.chapEnd), "
            }
            return str
        }
    }
    
    var defaultDetails: String {
        if rangesArr.count == 1, let range = rangesArr.first {
            return "\(range.occurrences)+ occurrences"
        } else {
            return "Mixed ranges/occurences"
        }
    }
}
