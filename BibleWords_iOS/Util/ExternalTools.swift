//
//  ExternalTools.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/20/22.
//

import Foundation
import UIKit

struct Logos {
    private static let baseLogosWordStudyURL = "https://ref.ly/logos4/Guide?t=My+Bible+Word+Study&lemma=lbs%2fhe%"
    
    static func logosWordStudyURL(for lemma: String) -> String {
        return baseLogosWordStudyURL + lemma
    }
    
    static func openBibleWordStudy(for lemma: String) {
        let urlStr = logosWordStudyURL(for: lemma).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        guard let url = URL(string: urlStr) else {
            print("Not a valid link: \(urlStr)")
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot open link")
        }
    }
}

