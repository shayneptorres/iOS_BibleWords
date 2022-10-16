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
                .font(wordInfo.language == .hebrew ? .bible40 : .bible32)
            Text(wordInfo.definition)
                .font(.headline)
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .multilineTextAlignment(.leading)
        }
    }
}
