//
//  ParsingFormListRow.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/28/22.
//

import SwiftUI

struct ParsingFormListRow: View {
    var instance: Bible.WordInstance
    
    var body: some View {
        NavigationLink(destination: {
            WordInstancePassageDetailsView(word: instance.wordInfo, instance: instance)
        }, label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(instance.textSurface.lowercased())
                    .font(instance.language.meduimBibleFont)
                    .foregroundColor(.accentColor)
                Text(instance.parsing.capitalized)
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
}

struct ParsingSurfaceGroupListRow: View {
    var group: Bible.ParsingSurfaceGroup
    
    var body: some View {
        NavigationLink(destination: {
            ParsingFormDetailView(parsingGroup: group)
        }, label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(group.surface.lowercased())
                    .font(group.language.meduimBibleFont)
                    .foregroundColor(.accentColor)
                Text(group.parsing.capitalized)
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
}

//struct ParsingFormListRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ParsingFormListRow()
//    }
//}
