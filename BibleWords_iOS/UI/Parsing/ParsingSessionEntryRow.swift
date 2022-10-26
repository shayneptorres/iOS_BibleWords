//
//  ParsingSessionEntryRow.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/20/22.
//

import SwiftUI

struct ParsingSessionEntryRow: View {
    @Binding var entry: StudySessionEntry
    
    var body: some View {
        HStack {
            entry.answerType.rowImage
                .font(.title2)
                .padding(.trailing)
                .frame(width: 45)
            VStack(alignment: .leading) {
                HStack {
                    Text("Surface: ")
                        .font(.subheadline)
                        .foregroundColor(.init(uiColor: .secondaryLabel))
                    +
                    Text(entry.studiedText ?? "")
                        .font(.bible24)
                }
                HStack {
                    Text("Lexical: ")
                        .font(.subheadline)
                        .foregroundColor(.init(uiColor: .secondaryLabel))
                    +
                    Text(entry.studiedDescription ?? "")
                        .font(.bible24)
                }
                .padding(.bottom, 4)
                Text(entry.studiedDetail ?? "")
                    .foregroundColor(entry.answerType.color)
            }
        }
    }
}

//struct ParsingSessionEntryRow_Previews: PreviewProvider {
//    static var previews: some View {
//        List {
//            ParsingSessionEntryRow(answerType: .wrong)
//            ParsingSessionEntryRow(answerType: .hard)
//            ParsingSessionEntryRow(answerType: .good)
//            ParsingSessionEntryRow(answerType: .easy)
//        }
//    }
//}
