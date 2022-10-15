//
//  WordInPassageView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/14/22.
//

import SwiftUI

struct WordInPassageView: View {
    @Binding var word: Bible.WordInfo
    @Binding var instance: Bible.WordInstance
    
    var body: some View {
        List {
            Section {
                Text(word.lemma)
                    .font(.bible40)
                Text(word.definition)
            }
            Section {
                Text(instance.prettyRefStr)
                    .font(.title3)
                Text(instance.surface.isEmpty ? instance.rawSurface : instance.surface)
                    .font(.bible32)
                Text(instance.parsing)
                    .font(.title3)
                Text(instance.wordInPassage) { string in
                    let attributedStr = instance.surface.isEmpty ? instance.rawSurface : instance.surface
                    if let range = string.range(of: attributedStr) { /// here!
                        string[range].foregroundColor = .accentColor
                    }
                }
                    .font(.bible40)
            }
        }
    }
}

/// extension to make applying AttributedString even easier
extension Text {
    init(_ string: String, configure: ((inout AttributedString) -> Void)) {
        var attributedString = AttributedString(string) /// create an `AttributedString`
        configure(&attributedString) /// configure using the closure
        self.init(attributedString) /// initialize a `Text`
    }
}

struct WordInPassageView_Previews: PreviewProvider {
    static var previews: some View {
        WordInPassageView(word: Bible.WordInfo.init([:]).bound(), instance: Bible.WordInstance.init(dict: [:]).bound())
    }
}
