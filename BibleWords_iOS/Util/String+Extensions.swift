//
//  String+Extensions.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/14/22.
//

import Foundation

extension String {
    var toInt: Int {
        return Int(self) ?? -1
    }
    
    var strippingAccents: String {
        applyingTransform(.stripDiacritics, reverse: false) ?? ""
    }
    
    var strippingHebrewVowels: String {
        return self.replacing("[\\u0591-\\u05BD\\u05BF-\\u05C2\\u05C4-\\u05C7]", with: "")
    }
}
