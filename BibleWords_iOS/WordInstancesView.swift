//
//  WordInstancesView.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/11/22.
//

import SwiftUI

struct WordInstancesView: View {
    @Binding var word: Bible.WordInfo
    
    var body: some View {
        List {
            Section {
                Text(word.lemma)
                    .font(.title3)
                    .padding(.bottom)
                Text(word.definition)
                    .padding(.bottom)
                Text(word.usage)
                    .padding(.bottom)
            }
            Section {
                ForEach(word.instances) { instance in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(instance.cleanSurface)
                            .font(.title3)
                        Text("\(instance.bibleBook.title) \(instance.chapter):\(instance.verse)")
                        Text(instance.parsing)
                    }
                }
            }
        }
    }
}

struct WordInstancesView_Previews: PreviewProvider {
    static var previews: some View {
        WordInstancesView(word: .constant(.init([:])))
    }
}
