//
//  WordInstancesView.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/11/22.
//

import SwiftUI

struct WordInstancesView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var word: Bible.WordInfo
    
    var body: some View {
        List {
            Section {
                Text(word.lemma)
                    .font(.bible40)
                Text(word.definition)
            }
            Section {
                ForEach(word.instances) { instance in
                    NavigationLink(value: instance) {
                        VStack(alignment: .leading) {
                            Text(instance.cleanSurface.isEmpty ? instance.surface : instance.cleanSurface)
                                .font(.bible32)
                            Text(instance.prettyRefStr)
                            Text(instance.parsing)
                        }
                    }
                }
            }
        }
        .navigationDestination(for: Bible.WordInstance.self) { instance in
            WordInPassageView(word: $word, instance: instance.bound())
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done", action: { presentationMode.wrappedValue.dismiss() })
            }
        }
    }
}

struct WordInstancesView_Previews: PreviewProvider {
    static var previews: some View {
        WordInstancesView(word: .constant(.init([:])))
    }
}
