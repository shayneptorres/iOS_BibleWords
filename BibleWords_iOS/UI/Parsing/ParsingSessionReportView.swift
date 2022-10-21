//
//  ParsingSessionReportView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/20/22.
//

import SwiftUI

struct ParsingSessionReportView: View {
    @Environment(\.presentationMode) var presentationMode
    let session: StudySession
    let list: ParsingList
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(session.entriesArr.sorted { $0.createdAt! < $1.createdAt! }) { entry in
                        ParsingSessionEntryRow(entry: entry.bound())
                    }
                }
            }
            .toolbar {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Dismiss")
                        .bold()
                })
            }
        }
    }
}

//struct ParsingSessionReportView_Previews: PreviewProvider {
//    static var previews: some View {
//        ParsingSessionReportView()
//    }
//}
