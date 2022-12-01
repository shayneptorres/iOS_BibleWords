//
//  PassageBookmark+Extensions.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 12/1/22.
//

import Foundation

extension PassageBookmark {
    var book: Bible.Book {
        return Bible.Book(rawValue: self.bookInt.toInt) ?? .genesis
    }
    
    var passage: Passage {
        return Passage(book: self.book, chapter: self.chapterInt.toInt, verse: -1)
    }
}
