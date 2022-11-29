//
//  WordInfoHeaderSection.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/19/22.
//

import SwiftUI

struct WordInfoHeaderSection: View {
    @Environment(\.managedObjectContext) var context
    @Binding var wordInfo: Bible.WordInfo

    var body: some View {
        Section {
            HStack {
                VStack(alignment: .leading) {
                    Text("lemma")
                        .font(.subheadline)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                    Text(wordInfo.lemma)
                        .font(.bible40)
                }
                Spacer()
                Button(action: {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = wordInfo.lemma
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }, label: {
                    Image(systemName: "arrow.right.doc.on.clipboard")
                })
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("definition")
                        .font(.subheadline)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                    if let vocab = wordInfo.vocabWord(context: context) {
                        Text(vocab.definition)
                            .font(.headline)
                    } else {
                        Text(wordInfo.definition)
                            .font(.headline)
                    }
                }
            }
            VStack(alignment: .leading) {
                Text("Language")
                    .font(.subheadline)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                Text(wordInfo.language.title)
                    .font(.headline)
            }
            VStack(alignment: .leading) {
                Text("Strong's ID")
                    .font(.subheadline)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                Text(wordInfo.id)
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
