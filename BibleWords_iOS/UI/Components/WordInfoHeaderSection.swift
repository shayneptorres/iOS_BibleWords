//
//  WordInfoHeaderSection.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/19/22.
//

import SwiftUI

struct WordInfoHeaderSection: View {
    @Binding var wordInfo: Bible.WordInfo
    var onTapDef: (() -> Void)?

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
                    Text(wordInfo.definition)
                        .font(.headline)
                }
                if onTapDef != nil {
                    Spacer()
                    Button(action: {
                        onTapDef?()
                    }, label: {
                        Image(systemName: "mail.and.text.magnifyingglass")
                    })
                }
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
