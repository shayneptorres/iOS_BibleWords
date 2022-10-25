//
//  Array+Extensions.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/25/22.
//

import Foundation

extension Array where Element == Bible.WordInfo {
    var uniqueInfos: [Bible.WordInfo] {
        var uniqueDict: [String: Bible.WordInfo] = [:]
        self.forEach { uniqueDict[$0.id] = $0 }
        return Array(uniqueDict.values)
    }
    
    var sortedInfos: [Bible.WordInfo] {
        return self.sorted {
            $0.lemma.lowercased().strippingAccents.strippingHebrewVowels < $1.lemma.lowercased().strippingAccents.strippingHebrewVowels
        }
    }
    
    var uniqueSorted: [Bible.WordInfo] {
        return self.uniqueInfos.sortedInfos
    }
}
