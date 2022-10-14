//
//  WordList+Extensions.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/13/22.
//

import Foundation

extension VocabWordList {
    
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
                return "Chapter \(range.chapStart) - Chapter \(range.chapEnd)"
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
}
