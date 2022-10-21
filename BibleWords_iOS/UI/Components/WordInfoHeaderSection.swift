//
//  WordInfoHeaderSection.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/19/22.
//

import SwiftUI

struct WordInfoHeaderSection: View {
    @Binding var wordInfo: Bible.WordInfo
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text("lemma")
                    .font(.subheadline)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                Text(wordInfo.lemma)
                    .font(.bible40)
            }
            VStack(alignment: .leading) {
                Text("definition")
                    .font(.subheadline)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                Text(wordInfo.definition)
                    .font(.headline)
            }
        } header: {
            Text("Word info")
        }
    }
}

//struct WordInfoHeaderSection_Previews: PreviewProvider {
//    static var previews: some View {
//        WordInfoHeaderSection()
//    }
//}
