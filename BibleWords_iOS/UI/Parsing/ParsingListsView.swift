//
//  ParsingListsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/18/22.
//

import SwiftUI

struct ParsingListsView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ParsingList.createdAt, ascending: true)],
        animation: .default)
    var lists: FetchedResults<ParsingList>
    
    @State var showBuildParingList = false
    var body: some View {
        ZStack {
            List {
                if lists.isEmpty {
                    Text("You don't have any parsing lists saved yet. Tap the button at the bottom to create one")
                        .multilineTextAlignment(.center)
                } else {
                    ForEach(lists) { list in
                        NavigationLink(value: AppPath.parsingListDetail(list)) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(list.defaultTitle)
                                    Spacer()
                                    Text(list.defaultDetails)
                                        .font(.subheadline)
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                                Text(list.parsingDetails)
                                    .font(.subheadline)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                        }
                        .swipeActions {
                            Button(action: {
                                withAnimation {
                                    onDelete(list)
                                }
                            }, label: { Text("Delete") })
                            .tint(.red)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showBuildParingList) {
            NavigationStack {
                BuildParsingListView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showBuildParingList = true
                }, label: {
                    Image(systemName: "plus.circle")
                        .fontWeight(.semibold)
                })
                .labelStyle(.titleAndIcon)
            }
        }
        .navigationTitle("Parsing Lists")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AppPath.self) { path in
            switch path {
            case .parsingListDetail(let list):
                ParsingListDetailView(viewModel: .init(list: list))
            case .parsingSessionsList(let list):
                ParsingListSessionsView(list: list.bound())
            case .parsingSessionDetail(let session):
                List {
                    ForEach(session.entriesArr.sorted { $0.createdAt! < $1.createdAt! }) { entry in
                        ParsingSessionEntryRow(entry: entry.bound())
                    }
                }
            default:
                Text("?")
            }
        }
    }
}

extension ParsingListsView {
    func onDelete(_ list: ParsingList) {
        CoreDataManager.transaction(context: context) {
            context.delete(list)
        }
    }
}

struct ParsingLists_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ParsingListsView()
        }
    }
}
