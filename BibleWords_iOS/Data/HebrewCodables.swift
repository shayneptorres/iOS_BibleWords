//
//  HebrewCodables.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/27/22.
//

import Foundation
import CoreData

protocol VocabWordListable {
}

//protocol VocabWordable {
//    func vocabWord(context: NSManagedObjectContext) -> VocabWord
//}

//struct CodeableHebrewWordList: Codable {
//    var words: [CodableHebrewWord]
//}
//
//struct CodableHebrewWord: Codable, Hashable {
////    func vocabWord(context: NSManagedObjectContext) -> VocabWord {
////        return vocabWord(context: context)
////    }
//    
//    let lemma: String
//    let xLiteration: String
//    let lang: String
//    let usage: String
//    let pronunciation: String
//    let strongId: String
//    let partOfSpeech: String
//    let meaning: String
//    
//    init(from info: Hebrew.WordInfo) {
//        self.lemma = info.lemma
//        self.xLiteration = info.transliteration
//        self.lang = "?"
//        self.usage = info.usage
//        self.pronunciation = info.pronounciation
//        self.strongId = info.id
//        self.partOfSpeech = ""
//        self.meaning = info.definition
//    }
//    
////    func vocabWord(context: NSManagedObjectContext) -> VocabWord {
////        return VocabWord.newHebrew(for: context, word: self)
////    }
//}
//
//struct CodableBibleWordByWord: Codable {
//    let book: [[[String]]]
//}
