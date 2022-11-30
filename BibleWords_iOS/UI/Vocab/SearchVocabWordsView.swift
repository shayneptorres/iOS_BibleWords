//
//  SearchVocabWordsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/29/22.
//

import SwiftUI

struct SearchVocabWordsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var searchText = ""
    @State var wordInfos: [Bible.WordInfo] = []
    @State var isSearching = false
    
    var body: some View {
        List {
            if isSearching {
                HStack {
                    Label("Searching...", systemImage: "binoculars")
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.automatic)
                        .padding(.trailing)
                }
            }
            ForEach(wordInfos) { wordInfo in
                NavigationLink(destination: {
                    WordInfoDetailsView(word: wordInfo.bound())
                }, label: {
                    WordInfoRow(wordInfo: wordInfo.bound())
                })
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a greek/hebrew word")
        .onChange(of: searchText) { search in
            if search.isEmpty {
                wordInfos.removeAll()
            }
        }
        .onSubmit(of: .search) {
            isSearching = true
            search()
        }
        .navigationBarTitle("Search", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    
                }, label: {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Dismiss")
                            .bold()
                    })
                })
            }
        }
    }
    
    func search() {
        var results: [Bible.WordInfo] = []

        DispatchQueue.global().async {
            results = Bible.main.greekLexicon.words()
                .filter {
                    $0.definition.lowercased().contains(self.searchText.lowercased()) ||
                    $0.id.lowercased().contains(self.searchText.lowercased()) ||
                    $0.xlit.lowercased().contains(self.searchText.lowercased()) ||
                    $0.lemma.strippingAccents.lowercased().contains(self.searchText.strippingAccents.lowercased())
                }
            results += Bible.main.hebrewLexicon.words()
                .filter {
                    $0.definition.lowercased().contains(self.searchText.lowercased()) ||
                    $0.id.lowercased().contains(self.searchText.lowercased()) ||
                    $0.xlit.lowercased().contains(self.searchText.lowercased()) ||
                    $0.lemma.strippingAccents.lowercased().contains(self.searchText.strippingAccents.lowercased()) ||
                    $0.lemma.strippingHebrewVowels.lowercased().contains(self.searchText.strippingAccents.lowercased())
                }
            results.sort {
                $0.lemma.lowercased().strippingAccents.strippingHebrewVowels <
                    $1.lemma.lowercased().strippingAccents.strippingHebrewVowels
            }

            DispatchQueue.main.async {
                self.wordInfos = results
                self.isSearching = false
            }
        }
    }
}

struct SearchVocabWordsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchVocabWordsView()
    }
}
