//
//  WordInfoRow.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/16/22.
//

import SwiftUI

struct WordInfoRow: View {
    @Binding var wordInfo: Bible.WordInfo
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(wordInfo.lemma)
                .font(wordInfo.language.meduimBibleFont)
                .padding(.bottom, 4)
            Text(wordInfo.definition)
                .font(.subheadline)
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .multilineTextAlignment(.leading)
        }
    }
}
