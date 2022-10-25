//
//  ParsingListSessionsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/20/22.
//

import SwiftUI

struct ParsingListSessionsView: View {
    @Binding var list: ParsingList
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            if list.sessionsArr.isEmpty {
                Text("You haven't completed any parsing sessions yet. To practice your parsing, go back to the previous page and tap the 'Practice Parsing' button at the bottom of the screen")
                    .multilineTextAlignment(.center)
                    .fontWeight(.semibold)
            } else {
                ForEach(list.sessionsArr.sorted { $0.startDate! > $1.startDate! }) { session in
                    NavigationLink(value: AppPath.parsingSessionDetail(session)) {
                        VStack(alignment: .leading) {
                            Text(session.startDate?.toPrettyDate ?? "")
                                .padding(.bottom, 4)
                            HStack {
                                HStack {
                                    SessionEntryAnswerType.wrong.rowImage
                                    Text("\(session.entriesArr.filter { $0.answerType == .wrong }.count)")
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                HStack {
                                    SessionEntryAnswerType.hard.rowImage
                                    Text("\(session.entriesArr.filter { $0.answerType == .hard }.count)")
                                }
                                .foregroundColor(.orange)
                                .frame(maxWidth: .infinity)
                                HStack {
                                    SessionEntryAnswerType.good.rowImage
                                    Text("\(session.entriesArr.filter { $0.answerType == .good }.count)")
                                }
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity)
                                HStack {
                                    SessionEntryAnswerType.easy.rowImage
                                    Text("\(session.entriesArr.filter { $0.answerType == .easy }.count)")
                                }
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity)
                            }
                            .font(.subheadline)
                        }
                    }
                    .navigationViewStyle(.stack)
                    .swipeActions {
                        Button(action: {
                            withAnimation {
                                onDelete(session: session)
                            }
                        }, label: {
                            Text("Delete")
                        })
                        .tint(.red)
                    }
                }
            }
        }
        .navigationTitle("Parsing Sessions")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: StudySession.self) { session in
            List {
                ForEach(session.entriesArr.sorted { $0.createdAt! < $1.createdAt! }) { entry in
                    ParsingSessionEntryRow(entry: entry.bound())
                }
            }
        }
    }
    
    func onDelete(session: StudySession) {
        CoreDataManager.transaction(context: context) {
            context.delete(session)
        }
    }
}

//struct ParsingListSessionReportsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ParsingListSessionReportsView()
//    }
//}
