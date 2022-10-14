//
//  GreekCodeables.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/22/22.
//

import Foundation
import CoreData

struct Greek {
    struct WordInfo {
        
    }
}

extension Greek {
    static var main = Greek()
    
    struct CodeableVocabList: Codable, VocabWordListable {
        let words: [CodeableWordInfo]
    }
    
    struct CodeableWordInfo: Codable, Identifiable {
        let id: String
        let gid: String
        let lemma: String
        let gloss: String
        let instances: [CodeableWordInstance]
    }
    
    struct CodeableWordInstance: Codable, Identifiable {
        let id: String
        let ref: CodeableBibRef
        let lemma: String
        let gid: String
        let surface: String
        let gloss: String
        let parsing: String
    }
    
    struct CodeableBibRef: Codable, Identifiable {
        let id: String
        let chapter: String
        let verse: String
        let book: String
    }
}

