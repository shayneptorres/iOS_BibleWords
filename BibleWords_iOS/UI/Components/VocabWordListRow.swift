//
//  VocabWordListRow.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/28/22.
//

import SwiftUI

struct VocabWordListRow: View {
    var list: VocabWordList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(list.defaultTitle)
                .bold()
                .multilineTextAlignment(.leading)
                .foregroundColor(.accentColor)
            Text(list.defaultDetails)
                .font(.caption)
                .foregroundColor(Color(uiColor: .secondaryLabel))
        }
    }
}

//struct VocabWordListRow_Previews: PreviewProvider {
//    static var previews: some View {
//        VocabWordListRow()
//    }
//}
