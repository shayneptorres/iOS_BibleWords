//
//  Codables.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/14/22.
//

import Foundation

struct TextbookImportWord: Codable {
    let lemma: String
    let chap: String
    let strongId: String
    let gloss: String
}

